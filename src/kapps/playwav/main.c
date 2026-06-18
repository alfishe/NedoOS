#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "wav.h"

extern unsigned char covox_hx;
extern void covox_play(void);

unsigned char pagetable[256];

#define IOBUF ((unsigned char *)0x8000)
#define IOBUF_SIZE 16384u

static unsigned char sample_pages[256];
static unsigned char page_count;
static unsigned char pages_loaded;
static unsigned char saved_c000_page;

static void free_pages(void);

static void restore_c000_page(void)
{
	SETPG32KHIGH(saved_c000_page);
}

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

static void free_pages(void)
{
	unsigned char i;

	for (i = 0; i < page_count; ++i)
		OS_DELPAGE((char)sample_pages[i]);
	page_count = 0;
}

static void init_memory(void)
{
	union APP_PAGES main_pg;

	main_pg.l = OS_GETMAINPAGES();
	saved_c000_page = main_pg.pgs.window_3;
}

static unsigned char raw_to_covox(unsigned char raw)
{
	if (raw == 0)
		return 1;
	return raw;
}

static void fix_zeros_in_place(unsigned char *data, unsigned int len)
{
	unsigned int i;

	for (i = 0; i < len; ++i)
		data[i] = raw_to_covox(data[i]);
}

static unsigned char mix_stereo_byte(unsigned char left, unsigned char right)
{
	unsigned int sum;

	left = raw_to_covox(left);
	right = raw_to_covox(right);
	sum = (unsigned int)left + (unsigned int)right;
	return (unsigned char)((sum + 1u) >> 1);
}

#define ADPCM_DECODE_OBUF 2048u

static unsigned char adpcm_decobuf[ADPCM_DECODE_OBUF];

static unsigned char adpcm_emit_sample(unsigned char sample,
									   unsigned char *page_idx, unsigned int *page_off, unsigned char max_pages)
{
	if (*page_idx >= max_pages)
		return 0;

	((unsigned char *)0xC000)[*page_off] = sample;
	++(*page_off);
	if (*page_off >= WAV_PAGE_BYTES)
	{
		*page_off = 0;
		++(*page_idx);
		if (*page_idx < max_pages)
			SETPG32KHIGH(sample_pages[*page_idx]);
	}
	return 1;
}

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

		got = OS_READHANDLE(IOBUF + *buf_len, fp, IOBUF_SIZE - *buf_len);
		if (got == 0)
			return 0;
		putchar('.');
		*buf_len += got;
	}
	return 1;
}

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
	unsigned int i;
	unsigned char truncated;
	unsigned long total;

	if (max_pages == 0)
		return 0;

	ba = info->block_align;
	if (ba == 0 || ba > IOBUF_SIZE)
		return 0;
	if (info->samples_per_block > ADPCM_DECODE_OBUF)
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
					decoded = wav_ima_decode_block(IOBUF + buf_pos, block_len,
												   info, adpcm_decobuf, ADPCM_DECODE_OBUF);
					for (i = 0; i < decoded; ++i)
					{
						if (!adpcm_emit_sample(adpcm_decobuf[i], &page_idx, &page_off,
											   max_pages))
						{
							truncated = 1;
							goto done;
						}
						++total;
					}
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
		decoded = wav_ima_decode_block(IOBUF + buf_pos, block_len, info,
									   adpcm_decobuf, ADPCM_DECODE_OBUF);
		if (decoded == 0)
			break;

		for (i = 0; i < decoded; ++i)
		{
			if (!adpcm_emit_sample(adpcm_decobuf[i], &page_idx, &page_off, max_pages))
			{
				truncated = 1;
				goto done;
			}
			++total;
		}
		buf_pos += ba;
	}

done:
	if (total == 0)
		return 0;

	if (page_off == 0 && page_idx > 0)
	{
		pages_loaded = page_idx;
		*last_page_off = WAV_PAGE_BYTES - 1u;
	}
	else
	{
		pages_loaded = (unsigned char)(page_idx + 1u);
		*last_page_off = page_off;
	}
	return 1;
}

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
		n = (unsigned int)samples_in_page;
		putchar('.');
		if (OS_READHANDLE(dst, fp, n) != n)
			return 0;
		fix_zeros_in_place(dst, n);
	}
	else if (!bits16 && stereo)
	{
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
				dst[out++] = mix_stereo_byte(IOBUF[i], IOBUF[i + 1u]);
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
				dst[i] = wav_s16_to_covox(
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
				int left;
				int right;
				int mix;

				left = (int)(short)((unsigned int)IOBUF[i * 4u] + ((unsigned int)IOBUF[i * 4u + 1u] << 8));
				right = (int)(short)((unsigned int)IOBUF[i * 4u + 2u] + ((unsigned int)IOBUF[i * 4u + 3u] << 8));
				mix = (left + right) >> 1;
				dst[i] = wav_s16_to_covox(mix);
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

static void write_terminator(unsigned char page_idx, unsigned int page_off)
{
	SETPG32KHIGH(sample_pages[page_idx]);
	((unsigned char *)(0xC000u + page_off))[0] = 0;
}

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

		{
			unsigned char i;
			unsigned char allocated = page_count;

			page_count = pages_loaded;
			for (i = pages_loaded; i < allocated; ++i)
				OS_DELPAGE((char)sample_pages[i]);
			for (i = pages_loaded; i < (unsigned char)255; ++i)
				pagetable[i] = 0;
		}

		write_terminator((unsigned char)(pages_loaded - 1u), last_page_off);
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

		if (samples_left <= samples_in_page && samples_in_page >= WAV_PAGE_BYTES)
			samples_in_page = WAV_PAGE_BYTES - 1u;

		if (samples_in_page == 0)
			break;

		if (!load_page_pcm(fp, info, page_idx, samples_in_page))
		{
			free_pages();
			return 0;
		}
		samples_left -= samples_in_page;
		last_page_off = (unsigned int)samples_in_page;
		++page_idx;
	}

	pages_loaded = page_idx;
	if (pages_loaded == 0)
		return 0;

	{
		unsigned char i;
		unsigned char allocated = page_count;

		page_count = pages_loaded;
		for (i = pages_loaded; i < allocated; ++i)
			OS_DELPAGE((char)sample_pages[i]);
		for (i = pages_loaded; i < (unsigned char)255; ++i)
			pagetable[i] = 0;
	}

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

static void play_sample(const wav_info_t *info)
{
	if (page_count == 0 || info->covox_delay == 0)
		return;

	covox_hx = info->covox_delay;
	covox_play();
	restore_c000_page();
}

static void wait_key(void)
{
	unsigned char key;

	do
	{
		key = (unsigned char)_low_level_get();
	} while (key == 0);
}

C_task main(int argc, char *argv[])
{
	FILE *fp;
	wav_info_t info;
	unsigned char free_mem;
	unsigned int pages_needed;
	unsigned char pages_to_use;
	unsigned char err;

	os_initstdio();
	OS_SETGFX(0x86);
	OS_CLS(0);

	if (argc < 2)
	{
		printf("Usage: playwav <file.wav>\r\n");
		printf("PCM 8/16-bit or IMA ADPCM WAV.\r\n");
		wait_key();
		exit(1);
	}

	init_memory();
	free_mem = get_free_pages();

	fp = OS_OPENHANDLE((unsigned char *)argv[1], 0x80);
	if (((int)fp) & 0xff)
	{
		printf("Error: %s\r\n", argv[1]);
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

	OS_CLOSEHANDLE(fp);
	play_sample(&info);
	putchar('\n');
	free_pages();
	restore_c000_page();
	exit(0);
}
