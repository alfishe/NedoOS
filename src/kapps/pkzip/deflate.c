#include <stdio.h>
#include <oscalls.h>
#include <osfs.h>

#include "deflate.h"
#include "crc32.h"
#include "winmem.h"

/* Progress: one '.' per 4K uncompressed. */
#define PROG_STEP 4096UL

#define HASH_BITS 12
#define HASH_SIZE (1u << HASH_BITS)
#define HASH_MASK (HASH_SIZE - 1u)

#define MIN_MATCH 3u
#define MAX_MATCH 258u
#define MAX_DIST WIN_SIZE
#define MIN_LOOKAHEAD (MAX_MATCH + MIN_MATCH)
#define OUT_CHUNK 512
#define IN_CHUNK 1024
#define ABORT_CHECK PROG_STEP

static int g_level = DEFL_FAST;

static unsigned int g_head[HASH_SIZE];

static unsigned long g_bitbuf;
static unsigned char g_bitcnt;
static unsigned char g_out[OUT_CHUNK];
static unsigned int g_outlen;
static unsigned long g_csize;
static FILE *g_outh;
static unsigned long g_prog_next;

static unsigned char g_inbuf[IN_CHUNK];

static unsigned int g_lit_code[286];
static unsigned char g_lit_bits[286];
static unsigned char g_dist_rev[30];
static unsigned char g_len_slot[256];
static unsigned char g_tab_ready;

static const unsigned int length_base[29] = {
	3u, 4u, 5u, 6u, 7u, 8u, 9u, 10u, 11u, 13u, 15u, 17u, 19u, 23u, 27u, 31u,
	35u, 43u, 51u, 59u, 67u, 83u, 99u, 115u, 131u, 163u, 195u, 227u, 258u
};
static const unsigned char length_extra[29] = {
	0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
	3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0
};
static const unsigned int dist_base[30] = {
	1u, 2u, 3u, 4u, 5u, 7u, 9u, 13u, 17u, 25u, 33u, 49u, 65u, 97u, 129u, 193u,
	257u, 385u, 513u, 769u, 1025u, 1537u, 2049u, 3073u, 4097u, 6145u, 8193u,
	12289u, 16385u, 24577u
};
static const unsigned char dist_extra[30] = {
	0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6,
	7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13
};

void deflate_set_level(int level)
{
	if (level == DEFL_RLE)
		g_level = DEFL_RLE;
	else
		g_level = DEFL_FAST;
}

static unsigned int bitrev(unsigned int v, unsigned int n)
{
	unsigned int r;

	r = 0;
	while (n)
	{
		r = (unsigned int)((r << 1) | (v & 1u));
		v >>= 1;
		n--;
	}
	return r;
}

static void build_tables(void)
{
	unsigned int sym;
	unsigned int i;
	unsigned int len;
	unsigned int slot;

	for (sym = 0; sym <= 143u; sym++)
	{
		g_lit_code[sym] = bitrev(0x30u + sym, 8);
		g_lit_bits[sym] = 8;
	}
	for (sym = 144; sym <= 255u; sym++)
	{
		g_lit_code[sym] = bitrev(0x190u + (sym - 144u), 9);
		g_lit_bits[sym] = 9;
	}
	for (sym = 256; sym <= 279u; sym++)
	{
		g_lit_code[sym] = bitrev(sym - 256u, 7);
		g_lit_bits[sym] = 7;
	}
	for (sym = 280; sym <= 285u; sym++)
	{
		g_lit_code[sym] = bitrev(0xC0u + (sym - 280u), 8);
		g_lit_bits[sym] = 8;
	}

	for (i = 0; i < 30u; i++)
		g_dist_rev[i] = (unsigned char)bitrev(i, 5);

	for (len = 3; len <= 258u; len++)
	{
		slot = 0;
		while (slot < 28u && len >= length_base[slot + 1u])
			slot++;
		g_len_slot[len - 3u] = (unsigned char)slot;
	}

	g_tab_ready = 1;
}

static void prog_tick(unsigned long strstart)
{
	while (strstart >= g_prog_next)
	{
		putchar('.');
		g_prog_next += PROG_STEP;
	}
}

static int flush_out(void)
{
	unsigned int n;
	unsigned int got;
	unsigned char *p;

	n = g_outlen;
	if (n == 0u)
		return 0;
	p = g_out;
	while (n)
	{
		got = OS_WRITEHANDLE(p, g_outh, n);
		if (got == 0u)
			return -1;
		p += got;
		n = (unsigned int)(n - got);
		g_csize += got;
	}
	g_outlen = 0;
	return 0;
}

static int put_bits(unsigned int val, unsigned int nbits)
{
	g_bitbuf |= ((unsigned long)val) << g_bitcnt;
	g_bitcnt = (unsigned char)(g_bitcnt + nbits);
	while (g_bitcnt >= 8u)
	{
		g_out[g_outlen++] = (unsigned char)g_bitbuf;
		g_bitbuf >>= 8;
		g_bitcnt = (unsigned char)(g_bitcnt - 8u);
		if (g_outlen >= OUT_CHUNK)
		{
			if (flush_out() != 0)
				return -1;
		}
	}
	return 0;
}

static int put_lit(unsigned int sym)
{
	return put_bits(g_lit_code[sym], g_lit_bits[sym]);
}

static int put_len_dist(unsigned int len, unsigned int dist)
{
	unsigned int slot;
	unsigned int extra;

	slot = g_len_slot[len - 3u];
	if (put_lit(257u + slot) != 0)
		return -1;
	extra = length_extra[slot];
	if (extra)
	{
		if (put_bits(len - length_base[slot], extra) != 0)
			return -1;
	}

	slot = 0;
	while (slot < 29u && dist >= dist_base[slot + 1u])
		slot++;
	if (put_bits(g_dist_rev[slot], 5) != 0)
		return -1;
	extra = dist_extra[slot];
	if (extra)
	{
		if (put_bits(dist - dist_base[slot], extra) != 0)
			return -1;
	}
	return 0;
}

static unsigned int hash3(unsigned long pos)
{
	unsigned int h;

	h = win_get(pos);
	h = (unsigned int)((h << 5) ^ win_get(pos + 1UL));
	h = (unsigned int)((h << 5) ^ win_get(pos + 2UL));
	return h & HASH_MASK;
}

static unsigned int match_len_at(unsigned long pos, unsigned int dist, unsigned int maxlen)
{
	unsigned int p;
	unsigned int q;
	unsigned int n;
	unsigned char *a;
	unsigned char *b;

	p = (unsigned int)pos & WIN_MASK;
	q = (unsigned int)(pos - (unsigned long)dist) & WIN_MASK;
	n = 0;

	if ((unsigned int)(p + maxlen) >= p && (unsigned int)(p + maxlen) <= WIN_SIZE &&
	    (unsigned int)(q + maxlen) >= q && (unsigned int)(q + maxlen) <= WIN_SIZE)
	{
		a = WIN_BASE + p;
		b = WIN_BASE + q;
		while (n < maxlen && a[n] == b[n])
			n++;
		return n;
	}

	while (n < maxlen)
	{
		if (win_get(pos + (unsigned long)n) != win_get(pos - (unsigned long)dist + (unsigned long)n))
			break;
		n++;
	}
	return n;
}

static unsigned long abs_from_head(unsigned long strstart, unsigned int prev16)
{
	unsigned long abs_prev;

	abs_prev = (strstart & 0xffff0000UL) | (unsigned long)prev16;
	if (abs_prev > strstart)
		abs_prev -= 0x10000UL;
	return abs_prev;
}

static int fill_window(FILE *in, unsigned long *wfill, unsigned long usize, unsigned long strstart, unsigned int *lookahead)
{
	unsigned int want;
	unsigned int got;
	unsigned int i;
	unsigned long left;
	unsigned long base;

	left = usize - *wfill;
	if (left == 0UL)
		return 0;

	want = IN_CHUNK;
	if ((unsigned long)want > left)
		want = (unsigned int)left;

	got = OS_READHANDLE(g_inbuf, in, want);
	if (got == 0u)
		return -1;

	crc32_update(g_inbuf, got);

	base = *wfill;
	i = (unsigned int)base & WIN_MASK;
	if ((unsigned int)(i + got) >= i && (unsigned int)(i + got) <= WIN_SIZE)
	{
		unsigned char *d;
		unsigned int j;

		d = WIN_BASE + i;
		for (j = 0; j < got; j++)
			d[j] = g_inbuf[j];
	}
	else
	{
		for (i = 0; i < got; i++)
			win_put(base + (unsigned long)i, g_inbuf[i]);
	}

	*wfill = base + got;
	*lookahead = (unsigned int)(*wfill - strstart);
	return 0;
}

static int crc_rest(FILE *in, unsigned long *wfill, unsigned long usize)
{
	unsigned int want;
	unsigned int got;
	unsigned long left;

	left = usize - *wfill;
	while (left)
	{
		want = IN_CHUNK;
		if ((unsigned long)want > left)
			want = (unsigned int)left;
		got = OS_READHANDLE(g_inbuf, in, want);
		if (got == 0u)
			return -1;
		crc32_update(g_inbuf, got);
		*wfill += got;
		left -= got;
		prog_tick(*wfill);
	}
	return 0;
}

int deflate_to_handle(
	FILE *in,
	FILE *out,
	unsigned long usize,
	unsigned long *csize_out,
	unsigned long *crc_out)
{
	unsigned long strstart;
	unsigned long wfill;
	unsigned int lookahead;
	unsigned int h;
	unsigned int prev16;
	unsigned long abs_prev;
	unsigned long dist_ul;
	unsigned int dist;
	unsigned int best;
	unsigned int maxlen;
	unsigned char aborting;

	if (!g_tab_ready)
		build_tables();

	if (usize == 0UL)
	{
		*csize_out = 0UL;
		crc32_reset();
		*crc_out = crc32_get();
		return 0;
	}

	g_outh = out;
	g_outlen = 0;
	g_csize = 0;
	g_bitbuf = 0;
	g_bitcnt = 0;
	g_prog_next = PROG_STEP;
	aborting = 0;

	crc32_reset();
	strstart = 0;
	wfill = 0;
	lookahead = 0;

	if (put_bits(3u, 3) != 0)
		return -1;

	while (strstart < usize)
	{
		while (lookahead < MIN_LOOKAHEAD && wfill < usize)
		{
			if (fill_window(in, &wfill, usize, strstart, &lookahead) != 0)
				return -1;
		}

		best = 0;
		dist = 0;

		if (g_level == DEFL_RLE)
		{
			if (strstart > 0UL && lookahead >= MIN_MATCH &&
			    win_get(strstart) == win_get(strstart - 1UL))
			{
				maxlen = lookahead;
				if (maxlen > MAX_MATCH)
					maxlen = MAX_MATCH;
				best = match_len_at(strstart, 1u, maxlen);
				if (best >= MIN_MATCH)
					dist = 1u;
				else
					best = 0;
			}
		}
		else if (lookahead >= MIN_MATCH)
		{
			h = hash3(strstart);
			prev16 = g_head[h];
			g_head[h] = (unsigned int)strstart;

			abs_prev = abs_from_head(strstart, prev16);
			if (abs_prev < strstart)
			{
				dist_ul = strstart - abs_prev;
				if (dist_ul >= 1UL && dist_ul <= (unsigned long)MAX_DIST)
				{
					dist = (unsigned int)dist_ul;
					maxlen = lookahead;
					if (maxlen > MAX_MATCH)
						maxlen = MAX_MATCH;
					best = match_len_at(strstart, dist, maxlen);
					if (best < MIN_MATCH)
						best = 0;
				}
			}
		}

		if (best >= MIN_MATCH)
		{
			if (put_len_dist(best, dist) != 0)
				return -1;
			strstart += best;
			lookahead = (unsigned int)(wfill - strstart);
		}
		else
		{
			if (lookahead == 0u)
				return -1;
			if (put_lit(win_get(strstart)) != 0)
				return -1;
			strstart++;
			lookahead--;
		}

		prog_tick(strstart);

		if (strstart >= ABORT_CHECK && g_csize >= strstart)
		{
			aborting = 1;
			break;
		}
	}

	if (aborting)
	{
		if (crc_rest(in, &wfill, usize) != 0)
			return -1;
		*csize_out = usize;
		*crc_out = crc32_get();
		return 0;
	}

	if (put_lit(256u) != 0)
		return -1;

	if (g_bitcnt)
	{
		g_out[g_outlen++] = (unsigned char)g_bitbuf;
		g_bitbuf = 0;
		g_bitcnt = 0;
		if (g_outlen >= OUT_CHUNK)
		{
			if (flush_out() != 0)
				return -1;
		}
	}
	if (flush_out() != 0)
		return -1;

	*csize_out = g_csize;
	*crc_out = crc32_get();
	return 0;
}
