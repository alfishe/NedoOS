/*
 * playwav ? load a WAV file into 16K RAM pages and play via Covox.
 * Supports PCM 8/16 mono/stereo and MS IMA ADPCM (0x11).
 * -p: asm covox_play_pages() ? all pages in one di loop, fast bank switch
 *     at each 16K boundary (no ret to C between pages).
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "wav.h"

extern unsigned char covox_hx;
extern void covox_play(void);
extern void covox_play_pages(void);
extern unsigned char covox_play_stopped;

unsigned char pagetable[256];

#define IOBUF ((unsigned char *)0x8000)
#define IOBUF_SIZE 16384u

unsigned char sample_pages[256];
unsigned long page_samples[256];
unsigned char page_count;
unsigned char pages_loaded;
static unsigned char saved_c000_page;
static unsigned char play_paged_mode;

/* Restore C000 window mapping saved at startup. */
static void restore_c000_page(void)
{
	SETPG32KHIGH(saved_c000_page);
}

/* Count free 16K pages, reserving a few for the system. */
static unsigned char get_free_pages(void)
{
	unsigned char free_pages = 0;
	unsigned char i;

	for (i = 0; i < 255; ++i)
	{
		if (OS_GETPAGEOWNER((unsigned char)(~i)) == 0)
			++free_pages;
	}
	if (free_pages > 8)
		free_pages -= 8;
	return free_pages;
}

static void free_pages(void)
{
	unsigned char i;

	for (i = 0; i < page_count; ++i)
		OS_DELPAGE((char)sample_pages[i]);
	page_count = 0;
}

/* Allocate count pages and fill pagetable[] for covox_play(). */
static unsigned char alloc_pages(unsigned char count)
{
	unsigned char i;
	unsigned int r;

	page_count = 0;
	memset(pagetable, 0, sizeof(pagetable));
	for (i = 0; i < count; ++i)
	{
		r = OS_NEWPAGE();
		if (r > 255u)
		{
			free_pages();
			return 0;
		}
		sample_pages[i] = (unsigned char)r;
		pagetable[i] = sample_pages[i];
	}
	page_count = count;
	return 1;
}

/* Drop pages allocated above used count; zero tail of pagetable[]. */
static void trim_unused_pages(unsigned char used)
{
	unsigned char i;
	unsigned char allocated = page_count;

	page_count = used;
	for (i = used; i < allocated; ++i)
		OS_DELPAGE((char)sample_pages[i]);
	for (i = used; i < (unsigned char)255; ++i)
		pagetable[i] = 0;
}

/* Remember current C000 page before we remap it for loading. */
static void init_memory(void)
{
	union APP_PAGES main_pg;

	main_pg.l = OS_GETMAINPAGES();
	saved_c000_page = main_pg.pgs.window_3;
}

/* Top up IOBUF from file; compact leftover bytes after partial block consume. */
static unsigned char adpcm_refill_buf(FILE *fp, unsigned int ba,
									  unsigned int *buf_pos, unsigned int *buf_len)
{
	unsigned int rem;

	if (*buf_pos > 0 && *buf_len > *buf_pos)
	{
		rem = *buf_len - *buf_pos;
		memmove(IOBUF, IOBUF + *buf_pos, rem);
		*buf_len = rem;
		*buf_pos = 0;
	}
	else
	{
		*buf_pos = 0;
		*buf_len = 0;
	}

	if (*buf_len < ba)
	{
		unsigned int got;
		
		putchar('.');
		got = OS_READHANDLE(IOBUF + *buf_len, fp, IOBUF_SIZE - *buf_len);
		if (got == 0)
			return 0;
		*buf_len += got;
	}
	return 1;
}

/*
 * Stream-decode IMA ADPCM from file into 16K pages (16384 bytes each).
 * Reads through IOBUF; decodes only full blocks except at EOF.
 */
static unsigned char load_adpcm_streaming(FILE *fp, const wav_info_t *info,
										  unsigned char max_pages, unsigned int *last_page_off)
{
	unsigned char page_idx;
	unsigned int page_off;
	unsigned int ba;
	unsigned int hdr_min;
	unsigned int buf_pos;
	unsigned int buf_len;
	unsigned int block_len;
	unsigned int decoded;
	unsigned char truncated;
	unsigned long total;

	if (max_pages == 0)
		return 0;

	ba = info->block_align;
	if (ba == 0 || ba > IOBUF_SIZE)
		return 0;

	hdr_min = (unsigned int)info->channels * 4u;
	page_idx = 0;
	page_off = 0;
	buf_pos = 0;
	buf_len = 0;
	truncated = 0;
	total = 0;

	SETPG32KHIGH(sample_pages[0]);

	for (;;)
	{
		if (buf_len - buf_pos < ba)
		{
			unsigned int prev_avail;

			prev_avail = buf_len - buf_pos;
			if (!adpcm_refill_buf(fp, ba, &buf_pos, &buf_len))
			{
				block_len = buf_len - buf_pos;
				if (block_len >= hdr_min)
				{
					decoded = wav_ima_decode_block_pages(IOBUF + buf_pos, block_len,
														 info, &page_idx, &page_off,
														 max_pages);
					total += decoded;
					if (page_idx >= max_pages && total < info->num_samples)
						truncated = 1;
				}
				break;
			}
			if (buf_len - buf_pos < hdr_min)
				break;
			if (buf_len - buf_pos < ba)
			{
				if (buf_len - buf_pos <= prev_avail)
					break;
				continue;
			}
		}

		block_len = ba;
		decoded = wav_ima_decode_block_pages(IOBUF + buf_pos, block_len, info,
											 &page_idx, &page_off, max_pages);
		if (decoded == 0)
			break;

		total += decoded;
		buf_pos += ba;
		if (page_idx >= max_pages)
		{
			if (total < info->num_samples)
				truncated = 1;
			break;
		}
	}

	if (total == 0)
		return 0;

	if (page_off == 0 && page_idx > 0)
	{
		pages_loaded = page_idx;
		/* Byte count for paged play; terminator path may overwrite last sample. */
		*last_page_off = WAV_PAGE_BYTES;
	}
	else
	{
		pages_loaded = (unsigned char)(page_idx + 1u);
		*last_page_off = page_off;
	}

	{
		unsigned char i;

		for (i = 0; i + 1u < pages_loaded; ++i)
			page_samples[i] = WAV_PAGE_BYTES;
		page_samples[pages_loaded - 1u] = *last_page_off;
	}

	if (truncated)
		printf("Warn: out of memory during ADPCM decode\r\n");

	return 1;
}

/* Load one 16K page of PCM (any supported bit depth/channels) into C000. */
static unsigned char load_page_pcm(FILE *fp, const wav_info_t *info,
								   unsigned char page_idx, unsigned long samples_in_page)
{
	unsigned char *dst;
	unsigned long remaining;
	unsigned int chunk_bytes;
	unsigned int chunk_samples;
	unsigned int i;
	unsigned int out;
	unsigned int n;
	unsigned char stereo;
	unsigned char bits16;

	if (page_idx >= page_count || samples_in_page == 0)
		return 0;

	stereo = (unsigned char)(info->channels == 2u);
	bits16 = (unsigned char)(info->bits == 16u);

	SETPG32KHIGH(sample_pages[page_idx]);
	dst = (unsigned char *)0xC000;

	if (!bits16 && !stereo)
	{
		unsigned char b;

		n = (unsigned int)samples_in_page;
		putchar('.');
		if (OS_READHANDLE(dst, fp, n) != n)
			return 0;
		for (i = 0; i < n; ++i)
		{
			b = dst[i];
			if (b == 0)
				dst[i] = 1;
		}
	}
	else if (!bits16 && stereo)
	{
		unsigned char left;
		unsigned char right;

		remaining = samples_in_page;
		while (remaining > 0)
		{
			chunk_bytes = IOBUF_SIZE;
			if ((unsigned long)chunk_bytes > remaining * 2u)
				chunk_bytes = (unsigned int)(remaining * 2u);
			putchar('.');
			if (OS_READHANDLE(IOBUF, fp, chunk_bytes) != chunk_bytes)
				return 0;
			out = 0;
			for (i = 0; i + 1u < chunk_bytes; i += 2u)
			{
				left = IOBUF[i];
				right = IOBUF[i + 1u];
				if (left == 0)
					left = 1;
				if (right == 0)
					right = 1;
				dst[out++] = (unsigned char)(
					((unsigned int)left + (unsigned int)right + 1u) >> 1);
			}
			dst += out;
			remaining -= out;
		}
	}
	else if (bits16 && !stereo)
	{
		remaining = samples_in_page;
		while (remaining > 0)
		{
			chunk_samples = IOBUF_SIZE / 2u;
			if (chunk_samples > remaining)
				chunk_samples = (unsigned int)remaining;
			chunk_bytes = chunk_samples * 2u;
			putchar('.');
			if (OS_READHANDLE(IOBUF, fp, chunk_bytes) != chunk_bytes)
				return 0;
			for (i = 0; i < chunk_samples; ++i)
			{
				dst[i] = WAV_S16_TO_COVOX(
					(int)(short)((unsigned int)IOBUF[i * 2u] + ((unsigned int)IOBUF[i * 2u + 1u] << 8)));
			}
			dst += chunk_samples;
			remaining -= chunk_samples;
		}
	}
	else
	{
		remaining = samples_in_page;
		while (remaining > 0)
		{
			chunk_samples = IOBUF_SIZE / 4u;
			if (chunk_samples > remaining)
				chunk_samples = (unsigned int)remaining;
			chunk_bytes = chunk_samples * 4u;
			putchar('.');
			if (OS_READHANDLE(IOBUF, fp, chunk_bytes) != chunk_bytes)
				return 0;
			for (i = 0; i < chunk_samples; ++i)
			{
				long left;
				long right;
				long mix;

				left = (long)(short)((unsigned int)IOBUF[i * 4u] + ((unsigned int)IOBUF[i * 4u + 1u] << 8));
				right = (long)(short)((unsigned int)IOBUF[i * 4u + 2u] + ((unsigned int)IOBUF[i * 4u + 3u] << 8));
				mix = (left + right) / 2L;
				dst[i] = WAV_S16_TO_COVOX((int)mix);
			}
			dst += chunk_samples;
			remaining -= chunk_samples;
		}
	}

	if (samples_in_page < WAV_PAGE_BYTES)
		memset((unsigned char *)0xC000 + samples_in_page, 0x80,
			   (unsigned int)(WAV_PAGE_BYTES - samples_in_page));
	return 1;
}

/* Write Covox stop byte (0x00) after the last audio byte in continuous mode. */
static void write_terminator(unsigned char page_idx, unsigned int page_off)
{
	SETPG32KHIGH(sample_pages[page_idx]);
	((unsigned char *)(0xC000u + page_off))[0] = 0;
}

/*
 * Load WAV sample data into allocated pages.
 * Continuous mode: one 0x00 terminator on the last page only.
 * Paged mode (-p): no terminators; covox_play_pages() plays by byte count.
 */
static unsigned char load_sample_data(FILE *fp, const wav_info_t *info, unsigned char max_pages)
{
	unsigned long samples_left;
	unsigned long samples_in_page;
	unsigned char page_idx;
	unsigned int last_page_off;

	if (max_pages == 0)
		return 0;

	if (!alloc_pages(max_pages))
		return 0;

	if (info->format_tag == WAV_FMT_IMA_ADPCM)
	{
		if (!load_adpcm_streaming(fp, info, max_pages, &last_page_off))
		{
			free_pages();
			return 0;
		}
		trim_unused_pages(pages_loaded);
		if (!play_paged_mode)
		{
			/* Continuous mode needs a 0x00 stop byte; if the last page is
			 * completely full, overwrite the final sample. */
			if (last_page_off >= WAV_PAGE_BYTES)
				write_terminator((unsigned char)(pages_loaded - 1u),
								 (unsigned int)(WAV_PAGE_BYTES - 1u));
			else
				write_terminator((unsigned char)(pages_loaded - 1u), last_page_off);
		}
		return 1;
	}

	samples_left = info->num_samples;
	page_idx = 0;
	last_page_off = 0;
	pages_loaded = 0;

	while (samples_left > 0 && page_idx < max_pages)
	{
		samples_in_page = samples_left;
		if (samples_in_page > WAV_PAGE_BYTES)
			samples_in_page = WAV_PAGE_BYTES;

		/* Leave room for stop byte on the final page when it would fill 16K. */
		if (samples_left <= samples_in_page && samples_in_page >= WAV_PAGE_BYTES)
			samples_in_page = WAV_PAGE_BYTES - 1u;

		if (samples_in_page == 0)
			break;

		if (!load_page_pcm(fp, info, page_idx, samples_in_page))
		{
			free_pages();
			return 0;
		}
		page_samples[page_idx] = samples_in_page;
		samples_left -= samples_in_page;
		last_page_off = (unsigned int)samples_in_page;
		++page_idx;
	}

	pages_loaded = page_idx;
	if (pages_loaded == 0)
		return 0;

	trim_unused_pages(pages_loaded);
	if (!play_paged_mode)
		write_terminator((unsigned char)(pages_loaded - 1u), last_page_off);
	return 1;
}

static void print_wav_info(const wav_info_t *info)
{
	unsigned long duration_ms;

	printf("WAV: %s %u Hz %u ch %u-bit",
		   wav_format_name(info->format_tag),
		   (unsigned int)info->sample_rate,
		   (unsigned int)info->channels,
		   (unsigned int)info->bits);
	if (info->format_tag == WAV_FMT_PCM && info->bits == 16u)
		printf(" -> 8");
	printf("\r\n");
	printf("  data %lu bytes, %lu samples\r\n",
		   info->data_size, info->num_samples);
	if (info->format_tag == WAV_FMT_IMA_ADPCM)
		printf("  ADPCM block %u, %u samples/block\r\n",
			   (unsigned int)info->block_align,
			   (unsigned int)info->samples_per_block);

	duration_ms = 0;
	if (info->sample_rate)
		duration_ms = (info->num_samples * 1000ul) / info->sample_rate;
	printf("  duration %lu.%03lu s\r\n", duration_ms / 1000ul, duration_ms % 1000ul);
	if (info->format_tag == WAV_FMT_IMA_ADPCM)
	{
		unsigned int pages;

		pages = (unsigned int)((info->num_samples + WAV_PAGE_BYTES - 1u) / WAV_PAGE_BYTES);
		printf("  need ~%u RAM pages (16K each)\r\n", pages);
	}
}

/* Single covox_play() over full pagetable[] (kernel switches pages). */
static void play_sample_continuous(const wav_info_t *info)
{
	if (page_count == 0 || info->covox_delay == 0)
		return;

	covox_hx = info->covox_delay;
	covox_play();
	restore_c000_page();
}

/*
 * Asm multi-page player: fast bank switch, keyboard poll between pages.
 * Any key sets covox_play_stopped and ends playback.
 */
static void play_sample_paged(const wav_info_t *info)
{
	if (pages_loaded == 0 || info->covox_delay == 0)
		return;

	covox_hx = info->covox_delay;
	covox_play_stopped = 0;
	covox_play_pages();
	restore_c000_page();

	if (covox_play_stopped != 0)
		printf("Stopped (key %u).\r\n", (unsigned int)covox_play_stopped);
}

static void wait_key(void)
{
	unsigned char key;

	do
	{
		key = (unsigned char)_low_level_get();
	} while (key == 0);
}

static void print_usage(void)
{
	printf("Usage: playwav [-p] <file.wav>\r\n");
	printf("  -p  paged play + key to stop (use plain playwav for music)\r\n");
	printf("PCM 8/16-bit or IMA ADPCM WAV.\r\n");
}

C_task main(int argc, char *argv[])
{
	FILE *fp;
	wav_info_t info;
	unsigned char free_mem;
	unsigned int pages_needed;
	unsigned char pages_to_use;
	unsigned char err;
	char *wav_path;
	int i;

	os_initstdio();
	OS_SETGFX(0x86);
	OS_CLS(0);

	/* Parse -p anywhere on the command line; last non-flag arg is the file.
	 * Keep argv use inside main ? IAR Z80 passes argv poorly to helpers. */
	play_paged_mode = 0;
	wav_path = NULL;

	for (i = 1; i < argc; ++i)
	{
		if (argv[i][0] == '-' && argv[i][1] == 'p' && argv[i][2] == 0)
			play_paged_mode = 1;
		else
			wav_path = argv[i];
	}

	if (wav_path == NULL)
	{
		print_usage();
		wait_key();
		exit(1);
	}

	init_memory();
	free_mem = get_free_pages();

	fp = OS_OPENHANDLE((unsigned char *)wav_path, 0x80);
	if (((int)fp) & 0xff)
	{
		printf("Error: %s\r\n", wav_path);
		wait_key();
		exit(1);
	}

	err = wav_parse(fp, &info);
	if (err != WAV_OK)
	{
		printf("Error: %s\r\n", wav_strerror(err));
		OS_CLOSEHANDLE(fp);
		wait_key();
		exit(1);
	}

	print_wav_info(&info);

	pages_needed = (unsigned int)((info.num_samples + WAV_PAGE_BYTES - 1u) / WAV_PAGE_BYTES);
	if (pages_needed == 0u)
		pages_needed = 1u;
	if (pages_needed > 255u)
		pages_needed = 255u;

	pages_to_use = (unsigned char)pages_needed;
	if (pages_to_use > free_mem)
	{
		printf("Warn: need %u pages, have %u - track will be cut\r\n",
			   (unsigned int)pages_needed, (unsigned int)free_mem);
		pages_to_use = free_mem;
	}
	if (pages_to_use == 0)
	{
		printf("Error: not enough memory.\r\n");
		OS_CLOSEHANDLE(fp);
		wait_key();
		exit(1);
	}

	if (!load_sample_data(fp, &info, pages_to_use))
	{
		printf("Error: load failed.\r\n");
		OS_CLOSEHANDLE(fp);
		wait_key();
		exit(1);
	}

	printf("\r\nLoaded %u pages, %s play...\r\n",
		   (unsigned int)pages_loaded,
		   play_paged_mode ? "paged" : "continuous");

	OS_CLOSEHANDLE(fp);

	if (play_paged_mode)
	{
		OS_SETGFX(0x0e);
		YIELD();
		play_sample_paged(&info);
		OS_SETGFX(0x86);
	}
	else
		play_sample_continuous(&info);

	putchar('\n');
	free_pages();
	restore_c000_page();
	exit(0);
}
