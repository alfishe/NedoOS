/*
 * WAV header parser and MS IMA ADPCM block decoder for playwav.
 */

#include "wav.h"
#include <intrz80.h>
#include <string.h>

extern unsigned char sample_pages[256];

#define IMA_UPDATE(nibble, pred, step_idx) \
	do { \
		int _step = ima_step_table[(step_idx)]; \
		int _diff = _step >> 3; \
		if ((nibble) & 4) \
			_diff += _step; \
		if ((nibble) & 2) \
			_diff += _step >> 1; \
		if ((nibble) & 1) \
			_diff += _step >> 2; \
		if ((nibble) & 8) \
			_diff = -_diff; \
		(pred) += _diff; \
		if ((pred) > 32767) \
			(pred) = 32767; \
		else if ((pred) < -32768) \
			(pred) = -32768; \
		(step_idx) += (int)ima_index_table[(nibble) & 15]; \
		if ((step_idx) < 0) \
			(step_idx) = 0; \
		else if ((step_idx) > 88) \
			(step_idx) = 88; \
	} while (0)

#define WAV_PAGE_STORE(sample, pidx, poff, maxpg, full) \
	do { \
		if (*(pidx) >= (maxpg)) \
			(full) = 1; \
		else { \
			((unsigned char *)0xC000)[*(poff)] = (sample); \
			++(*(poff)); \
			if (*(poff) >= WAV_PAGE_BYTES) { \
				*(poff) = 0; \
				++(*(pidx)); \
				if (*(pidx) < (maxpg)) \
					SETPG32KHIGH(sample_pages[*(pidx)]); \
			} \
		} \
	} while (0)

static unsigned int read_u16(const unsigned char *p)
{
	return (unsigned int)p[0] + ((unsigned int)p[1] << 8);
}

static unsigned long read_u32(const unsigned char *p)
{
	return (unsigned long)p[0]
		+ ((unsigned long)p[1] << 8)
		+ ((unsigned long)p[2] << 16)
		+ ((unsigned long)p[3] << 24);
}

static const short ima_step_table[89] = {
	7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
	19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
	50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
	130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
	337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
	876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
	2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
	5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
	15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
};

static const signed char ima_index_table[16] = {
	-1, -1, -1, -1, 2, 4, 6, 8,
	-1, -1, -1, -1, 2, 4, 6, 8
};

/* Map sample rate to Covox HX delay byte (0 = unsupported). */
unsigned char wav_rate_to_delay(unsigned int rate)
{
	switch (rate)
	{
	case 8000u:
		return 27;
	case 11025u:
		return 18;
	case 16000u:
		return 11;
	case 22000u:
	case 22050u:
		return 7;
	case 32000u:
		return 3;
	case 44100u:
		return 1;
	default:
		return 0;
	}
}

/* Signed 16-bit linear sample -> 8-bit Covox (0x80 silence, never 0x00). */
unsigned char wav_s16_to_covox(int sample)
{
	int v;

	v = (sample >> 8) + 128;
	if (v < 1)
		v = 1;
	if (v > 255)
		v = 255;
	return (unsigned char)v;
}

const char *wav_format_name(unsigned char format_tag)
{
	switch (format_tag)
	{
	case WAV_FMT_PCM:
		return "PCM";
	case WAV_FMT_IMA_ADPCM:
		return "MS IMA ADPCM";
	default:
		return "?";
	}
}

/*
 * Decode one IMA ADPCM block into 16K pages (mono Covox, stereo downmixed).
 * Stops early if max_pages is exhausted.
 */
unsigned int wav_ima_decode_block_pages(const unsigned char *block, unsigned int block_len,
	const wav_info_t *info, unsigned char *page_idx, unsigned int *page_off,
	unsigned char max_pages)
{
	unsigned char channels;
	unsigned int hdr_bytes;
	unsigned int pos;
	unsigned int out_count;
	unsigned char ch;
	unsigned char page_full;
	int predictor[2];
	int step_index[2];
	unsigned char b;
	unsigned char nib;
	unsigned int i;
	unsigned char left;
	unsigned char right;
	unsigned char covox;

	channels = info->channels;
	if (channels < 1u || channels > 2u || block_len == 0 || *page_idx >= max_pages)
		return 0;

	hdr_bytes = (unsigned int)channels * 4u;
	if (block_len < hdr_bytes)
		return 0;

	pos = 0;
	for (ch = 0; ch < channels; ++ch)
	{
		predictor[ch] = (int)(short)read_u16(block + pos);
		pos += 2u;
	}
	for (ch = 0; ch < channels; ++ch)
	{
		step_index[ch] = (int)block[pos++];
		if (step_index[ch] > 88)
			step_index[ch] = 88;
	}
	for (ch = 0; ch < channels; ++ch)
		++pos; /* reserved */

	out_count = 0;
	page_full = 0;
	if (channels == 1u)
	{
		covox = WAV_S16_TO_COVOX(predictor[0]);
		WAV_PAGE_STORE(covox, page_idx, page_off, max_pages, page_full);
		if (page_full)
			return out_count;
		++out_count;

		while (pos < block_len && !page_full)
		{
			b = block[pos++];
			nib = (unsigned char)(b & 15u);
			IMA_UPDATE(nib, predictor[0], step_index[0]);
			covox = WAV_S16_TO_COVOX(predictor[0]);
			WAV_PAGE_STORE(covox, page_idx, page_off, max_pages, page_full);
			if (page_full)
				break;
			++out_count;

			nib = (unsigned char)(b >> 4);
			IMA_UPDATE(nib, predictor[0], step_index[0]);
			covox = WAV_S16_TO_COVOX(predictor[0]);
			WAV_PAGE_STORE(covox, page_idx, page_off, max_pages, page_full);
			if (page_full)
				break;
			++out_count;
		}
	}
	else
	{
		left = WAV_S16_TO_COVOX(predictor[0]);
		right = WAV_S16_TO_COVOX(predictor[1]);
		covox = (unsigned char)(((unsigned int)left + (unsigned int)right + 1u) >> 1);
		WAV_PAGE_STORE(covox, page_idx, page_off, max_pages, page_full);
		if (page_full)
			return out_count;
		++out_count;

		ch = 0;
		while (pos < block_len && !page_full)
		{
			b = block[pos++];
			for (i = 0; i < 2u; ++i)
			{
				nib = (i == 0u) ? (unsigned char)(b & 15u) : (unsigned char)(b >> 4);
				IMA_UPDATE(nib, predictor[ch], step_index[ch]);
				ch = (unsigned char)(1u - ch);
				if (ch == 0u)
				{
					left = WAV_S16_TO_COVOX(predictor[0]);
					right = WAV_S16_TO_COVOX(predictor[1]);
					covox = (unsigned char)(
						((unsigned int)left + (unsigned int)right + 1u) >> 1);
					WAV_PAGE_STORE(covox, page_idx, page_off, max_pages, page_full);
					if (page_full)
						break;
					++out_count;
				}
			}
		}
	}

	return out_count;
}

/* Scan RIFF chunks after the WAVE header. */
static unsigned char find_chunk(FILE *fp, unsigned long size, const char *id,
	unsigned long *chunk_size, unsigned long *chunk_data_off)
{
	unsigned char buf[8];
	unsigned long pos = 12;
	unsigned long chunk_len;

	while (pos + 8 <= size)
	{
		OS_SEEKHANDLE(fp, pos);
		if (OS_READHANDLE(buf, fp, 8) != 8)
			return 0;
		chunk_len = read_u32(buf + 4);
		if (pos + 8 + chunk_len > size)
			return 0;
		if (!memcmp(buf, id, 4))
		{
			*chunk_size = chunk_len;
			*chunk_data_off = pos + 8;
			return 1;
		}
		pos += 8 + chunk_len + (chunk_len & 1u);
	}
	return 0;
}

/* Estimate sample count from ADPCM data size when fact chunk is absent. */
static unsigned long ima_total_samples(unsigned long data_size, const wav_info_t *info)
{
	unsigned long blocks;
	unsigned long last_size;
	unsigned long samples;
	unsigned long extra;

	if (info->block_align == 0 || data_size < info->block_align)
		return 0;

	blocks = data_size / info->block_align;
	last_size = data_size - blocks * info->block_align;
	samples = blocks * info->samples_per_block;
	if (last_size >= (unsigned long)info->channels * 4u)
	{
		extra = 1u + ((last_size - (unsigned long)info->channels * 4u) * 2u)
			/ (unsigned long)info->channels;
		samples += extra;
	}
	return samples;
}

static unsigned long read_fact_samples(FILE *fp, unsigned long file_size)
{
	unsigned char buf[4];
	unsigned long chunk_size;
	unsigned long chunk_off;

	if (!find_chunk(fp, file_size, "fact", &chunk_size, &chunk_off))
		return 0;
	if (chunk_size < 4u)
		return 0;
	OS_SEEKHANDLE(fp, chunk_off);
	if (OS_READHANDLE(buf, fp, 4) != 4)
		return 0;
	return read_u32(buf);
}

const char *wav_strerror(unsigned char err)
{
	switch (err)
	{
	case WAV_ERR_SIZE:
		return "file too small";
	case WAV_ERR_RIFF:
		return "not a RIFF/WAVE file";
	case WAV_ERR_FMT:
		return "fmt chunk not found";
	case WAV_ERR_FORMAT:
		return "unsupported format (need PCM or IMA ADPCM 0x11, not MS ADPCM 0x02)";
	case WAV_ERR_CHANNELS:
		return "need mono or stereo";
	case WAV_ERR_BITS:
		return "need 8/16-bit PCM or 4-bit IMA ADPCM";
	case WAV_ERR_ALIGN:
		return "unexpected block alignment";
	case WAV_ERR_DATA:
		return "data chunk not found";
	case WAV_ERR_RATE:
		return "unsupported sample rate";
	case WAV_ERR_ADPCM:
		return "invalid IMA ADPCM fmt";
	default:
		return "unknown error";
	}
}

/*
 * Parse RIFF/WAVE header, validate format, seek to data chunk.
 * On success fp is positioned at the first audio byte.
 */
unsigned char wav_parse(FILE *fp, wav_info_t *info)
{
	unsigned char hdr[64];
	unsigned long file_size;
	unsigned long fmt_size;
	unsigned long fmt_off;
	unsigned long data_size;
	unsigned long data_off;
	unsigned int audio_format;
	unsigned int block_align;
	unsigned int bits;
	unsigned int cb_size;
	unsigned int samples_per_block;

	memset(info, 0, sizeof(*info));
	file_size = OS_GETFILESIZE(fp);
	info->file_size = file_size;
	if (file_size < 44u)
		return WAV_ERR_SIZE;

	OS_SEEKHANDLE(fp, 0);
	if (OS_READHANDLE(hdr, fp, 44) != 44)
		return WAV_ERR_SIZE;

	if (memcmp(hdr, "RIFF", 4) != 0 || memcmp(hdr + 8, "WAVE", 4) != 0)
		return WAV_ERR_RIFF;

	if (!find_chunk(fp, file_size, "fmt ", &fmt_size, &fmt_off))
		return WAV_ERR_FMT;
	if (fmt_size < 16u)
		return WAV_ERR_FMT;

	if (fmt_size > sizeof(hdr))
		fmt_size = sizeof(hdr);
	OS_SEEKHANDLE(fp, fmt_off);
	if (OS_READHANDLE(hdr, fp, (unsigned int)fmt_size) != (int)fmt_size)
		return WAV_ERR_FMT;

	audio_format = read_u16(hdr);
	info->channels = (unsigned char)read_u16(hdr + 2);
	info->sample_rate = (unsigned int)read_u32(hdr + 4);
	block_align = read_u16(hdr + 12);
	bits = read_u16(hdr + 14);
	info->format_tag = (unsigned char)audio_format;
	info->block_align = block_align;

	if (info->channels != 1u && info->channels != 2u)
		return WAV_ERR_CHANNELS;

	if (audio_format == WAV_FMT_PCM)
	{
		if (bits != 8u && bits != 16u)
			return WAV_ERR_BITS;
		if (block_align != (unsigned int)info->channels * (bits / 8u))
			return WAV_ERR_ALIGN;
		info->bits = (unsigned char)bits;
	}
	else if (audio_format == WAV_FMT_IMA_ADPCM)
	{
		if (bits != 4u)
			return WAV_ERR_BITS;
		if (block_align < (unsigned int)info->channels * 4u)
			return WAV_ERR_ALIGN;
		if (fmt_size < 18u)
			return WAV_ERR_ADPCM;
		cb_size = read_u16(hdr + 16);
		if (cb_size < 2u)
			return WAV_ERR_ADPCM;
		samples_per_block = read_u16(hdr + 18);
		info->bits = 4;
		info->samples_per_block = 1u + ((block_align - (unsigned int)info->channels * 4u) * 2u)
			/ (unsigned int)info->channels;
		if (samples_per_block != 0u && samples_per_block < info->samples_per_block)
			info->samples_per_block = samples_per_block;
	}
	else
	{
		return WAV_ERR_FORMAT;
	}

	if (!find_chunk(fp, file_size, "data", &data_size, &data_off))
		return WAV_ERR_DATA;

	if (data_off > file_size)
		return WAV_ERR_DATA;
	if (data_off + data_size > file_size)
		data_size = file_size - data_off;
	if (data_size == 0)
		return WAV_ERR_DATA;

	info->data_offset = data_off;
	info->data_size = data_size;

	if (audio_format == WAV_FMT_PCM)
		info->num_samples = data_size / (unsigned long)block_align;
	else
		info->num_samples = ima_total_samples(data_size, info);

	{
		unsigned long fact_samples;

		fact_samples = read_fact_samples(fp, file_size);
		if (fact_samples > 0 && audio_format == WAV_FMT_IMA_ADPCM)
			info->num_samples = fact_samples;
	}

	if (info->num_samples == 0)
		return WAV_ERR_DATA;

	info->covox_delay = wav_rate_to_delay(info->sample_rate);
	if (info->covox_delay == 0)
		return WAV_ERR_RATE;

	info->valid = 1;
	OS_SEEKHANDLE(fp, data_off);
	return WAV_OK;
}
