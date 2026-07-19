#ifndef PLAYWAV_WAV_H
#define PLAYWAV_WAV_H

#include <osfs.h>

#define WAV_PAGE_BYTES 16384u

#define WAV_FMT_PCM        1u
#define WAV_FMT_MS_ADPCM   2u   /* legacy Microsoft ADPCM, not supported */
#define WAV_FMT_IMA_ADPCM  17u  /* 0x11, "Microsoft IMA ADPCM" in editors */

typedef struct
{
	unsigned long file_size;
	unsigned int sample_rate;
	unsigned char channels;
	unsigned char bits;
	unsigned char format_tag;
	unsigned int block_align;
	unsigned int samples_per_block;
	unsigned long data_offset;
	unsigned long data_size;
	unsigned long num_samples;
	unsigned char covox_delay;
	unsigned char valid;
} wav_info_t;

#define WAV_OK           0
#define WAV_ERR_SIZE     1
#define WAV_ERR_RIFF     2
#define WAV_ERR_FMT      3
#define WAV_ERR_FORMAT   4
#define WAV_ERR_CHANNELS 5
#define WAV_ERR_BITS     6
#define WAV_ERR_ALIGN    7
#define WAV_ERR_DATA     8
#define WAV_ERR_RATE     9
#define WAV_ERR_ADPCM   10

unsigned char wav_parse(FILE *fp, wav_info_t *info);
const char *wav_strerror(unsigned char err);
const char *wav_format_name(unsigned char format_tag);
unsigned char wav_rate_to_delay(unsigned int rate);

/* Signed 16-bit sample -> unsigned 8-bit Covox (silence 0x80, no 0x00). */
unsigned char wav_s16_to_covox(int sample);

#define WAV_CLAMP_COVOX(v) ((unsigned char)((v) < 1 ? 1 : ((v) > 255 ? 255 : (v))))
#define WAV_S16_TO_COVOX(s) WAV_CLAMP_COVOX(((s) >> 8) + 128)

/* Decode one IMA ADPCM block into 16K pages (asm). Returns sample count. */
unsigned int wav_ima_decode_block_pages(const unsigned char *block, unsigned int block_len,
	const wav_info_t *info, unsigned char *page_idx, unsigned int *page_off,
	unsigned char max_pages);

#endif
