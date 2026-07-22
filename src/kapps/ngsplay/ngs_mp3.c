/*
 * NeoGS MP3/OGG/AAC streaming via GP's gscode (VS10xx on NeoGS).
 * Protocol from C:\TEMP\NOS\src\gp\mp3.asm + ngsdec/gscode.asm
 */
#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "ngsplay.h"
#include "app_bank.h"

#define GSCOM 187
#define GSDAT 179
#define GSCTR 0x33
#define C_GRST 0x80

#define CMDRESET 0
#define CMDGETFREEBUFFERSPACE 1
#define CMDGETCHIPID 2
#define CMDRESTARTSTREAM 3
#define CMDGETSTREAMINFO 6

#define GSPROGSTART 0x4000u
#define MP3_PAD_FRAMES 150u
#define MP3_FRAME_LEN 417u
#define MP3_CHUNK 1024u
#define SS_VER_VS1103 0x70

extern const unsigned char gscode_bin[];
extern const unsigned int gscode_bin_len;

static FILE *mp3_fp;
static unsigned char mp3_active;
static unsigned char mp3_vsver;
static unsigned int pad_frames_sent;
static unsigned char using_first_pad;
static unsigned char chunk[MP3_CHUNK];
static unsigned int chunk_len;
static unsigned int chunk_pos;
static unsigned long mp3_file_left;
unsigned long ngs_mp3_total;
unsigned long ngs_mp3_done;

/* Silence MP3 frames (from GP mp3.asm) ? 36-byte header + 381?0x55 */
static const unsigned char pad_first_hdr[36] = {
	0xFF, 0xFB, 0x90, 0x64, 0x00, 0x0F, 0xF0, 0x00, 0x00,
	0x69, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x0D, 0x20,
	0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0xA4, 0x00, 0x00,
	0x00, 0x20, 0x00, 0x00, 0x34, 0x80, 0x00, 0x00, 0x04
};
static const unsigned char pad_next_hdr[36] = {
	0xFF, 0xFB, 0x90, 0x64, 0x40, 0x8F, 0xF0, 0x00, 0x00,
	0x69, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x0D, 0x20,
	0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0xA4, 0x00, 0x00,
	0x00, 0x20, 0x00, 0x00, 0x34, 0x80, 0x00, 0x00, 0x04
};

static unsigned char wait_cmd_busy(void)
{
	unsigned int n;
	for (n = 0; n < 30000u; n++)
		if ((input(GSCOM) & 1) == 0)
			return 1;
	return 0;
}

static unsigned char wait_dat_clear_busy(void)
{
	unsigned int n;
	for (n = 0; n < 30000u; n++)
		if ((input(GSCOM) & 128) == 0)
			return 1;
	return 0;
}

static unsigned char wait_dat_set_busy(void)
{
	unsigned int n;
	for (n = 0; n < 30000u; n++)
		if ((input(GSCOM) & 128) != 0)
			return 1;
	return 0;
}

static unsigned char mp3_cmd_byte(unsigned char cmd, unsigned char *out)
{
	output(GSCOM, cmd);
	if (!wait_cmd_busy())
		return 0;
	if (!wait_dat_set_busy())
		return 0;
	*out = input(GSDAT);
	return 1;
}

static unsigned char mp3_cmd_only(unsigned char cmd)
{
	output(GSCOM, cmd);
	return wait_cmd_busy();
}

static void mp3_hw_reset(void)
{
	unsigned char t;

	output(GSCTR, C_GRST);
	for (t = 0; t < 3u; t++)
		YIELD();
	output(GSCOM, 0xF3);
	for (t = 0; t < 50u; t++)
	{
		if ((input(GSCOM) & 1) == 0)
			break;
		YIELD();
	}
}

static unsigned char mp3_start_gscode(void)
{
	unsigned int len;
	unsigned int addr;
	unsigned char t;

	/* Stock GS firmware upload ? GP uses WC after SC #14 (not WD). */
	len = gscode_bin_len;
	addr = GSPROGSTART;
	output(GSDAT, (unsigned char)(len & 0xffu));
	output(GSCOM, 0x14);
	if (!wait_cmd_busy())
		return 0;
	output(GSDAT, (unsigned char)(len >> 8));
	if (!wait_dat_clear_busy())
		return 0;
	output(GSDAT, (unsigned char)(addr & 0xffu));
	if (!wait_dat_clear_busy())
		return 0;
	output(GSDAT, (unsigned char)(addr >> 8));
	if (!wait_dat_clear_busy())
		return 0;
	if (!gs_send_bytes(gscode_bin, len))
		return 0;

	output(GSDAT, (unsigned char)(addr & 0xffu));
	output(GSCOM, 0x13);
	if (!wait_cmd_busy())
		return 0;
	output(GSDAT, (unsigned char)(addr >> 8));
	(void)wait_dat_clear_busy();
	for (t = 0; t < 3u; t++)
		YIELD();
	return 1;
}

static void fill_pad_frame(unsigned char *dst, const unsigned char *hdr)
{
	unsigned int i;

	memcpy(dst, hdr, 36);
	for (i = 36; i < MP3_FRAME_LEN; i++)
		dst[i] = 0x55;
}

static unsigned char refill_chunk(void)
{
	unsigned int got;
	unsigned int need;
	const unsigned char *hdr;

	chunk_pos = 0;
	chunk_len = 0;

	if (mp3_fp != 0 && mp3_file_left != 0)
	{
		need = MP3_CHUNK;
		if ((unsigned long)need > mp3_file_left)
			need = (unsigned int)mp3_file_left;
		got = OS_READHANDLE(chunk, mp3_fp, need);
		if (got == 0)
			mp3_file_left = 0;
		else
		{
			chunk_len = got;
			mp3_file_left -= got;
			ngs_mp3_done += got;
			return 1;
		}
	}

	/* EOF ? silence padding frames (GP: 150 ? 417). */
	if (pad_frames_sent >= MP3_PAD_FRAMES)
		return 0;

	need = 0;
	while (need + MP3_FRAME_LEN <= MP3_CHUNK && pad_frames_sent < MP3_PAD_FRAMES)
	{
		hdr = using_first_pad ? pad_first_hdr : pad_next_hdr;
		fill_pad_frame(chunk + need, hdr);
		using_first_pad = 0;
		need = (unsigned int)(need + MP3_FRAME_LEN);
		pad_frames_sent++;
	}
	chunk_len = need;
	return chunk_len != 0;
}

unsigned char ngs_mp3_is_active(void)
{
	return mp3_active;
}

unsigned char ngs_mp3_vs_version(void)
{
	return mp3_vsver;
}

void ngs_mp3_stop(void)
{
	if (mp3_fp != 0)
	{
		OS_CLOSEHANDLE(mp3_fp);
		mp3_fp = 0;
	}
	if (mp3_active)
		(void)mp3_cmd_only(CMDRESET);
	mp3_active = 0;
	chunk_len = 0;
	chunk_pos = 0;
	pad_frames_sent = 0;
}

/* Returns 0 ok. SoftSmpl state is destroyed (caller must clear gs_ok). */
unsigned char ngs_mp3_start(unsigned char *path, unsigned long filesize)
{
	unsigned char ver;
	unsigned char t;

	ngs_mp3_stop();
	mp3_hw_reset();
	ngs_invalidate();

	/* One upload: gscode enters preload and waits for stream bytes. */
	if (!mp3_start_gscode())
		return 1;
	if (!mp3_cmd_byte(CMDGETCHIPID, &ver))
		return 2;
	mp3_vsver = ver;
	if (ver > SS_VER_VS1103)
		return 3;

	/*
	 * Restart stream (stay in gscode) so preload is clean after chip-id.
	 * Do NOT CMDRESET+reupload: CMDRESET does jp 0 (stock) and a second
	 * #14 race fails (was error 5).
	 */
	if (!mp3_cmd_only(CMDRESTARTSTREAM))
	{
		/* Older path: brief settle then continue; preload may still be ok. */
		for (t = 0; t < 5u; t++)
			YIELD();
	}

	mp3_fp = OS_OPENHANDLE(path, 0x80);
	if (((int)mp3_fp) & 0xff)
	{
		mp3_fp = 0;
		return 6;
	}

	if (filesize == 0)
		filesize = OS_GETFILESIZE(mp3_fp);
	mp3_file_left = filesize;
	ngs_mp3_total = filesize;
	ngs_mp3_done = 0;
	pad_frames_sent = 0;
	using_first_pad = 1;
	chunk_len = 0;
	chunk_pos = 0;
	mp3_active = 1;
	return 0;
}

/* Call from UI loop while playing. Returns 1=still going, 0=finished. */
unsigned char ngs_mp3_pump(void)
{
	unsigned char free_pages;
	unsigned int n;
	unsigned int send_n;

	if (!mp3_active)
		return 0;

	for (;;)
	{
		if (chunk_pos >= chunk_len)
		{
			if (!refill_chunk())
			{
				ngs_mp3_stop();
				return 0;
			}
		}

		if (!mp3_cmd_byte(CMDGETFREEBUFFERSPACE, &free_pages))
		{
			ngs_mp3_stop();
			return 0;
		}
		if (free_pages < 6u)
			return 1;

		n = (unsigned int)(chunk_len - chunk_pos);
		/* Cap burst; re-poll free every ~512 B like GP. */
		send_n = n;
		if (send_n > 512u)
			send_n = 512u;
		if (!gs_send_bytes(chunk + chunk_pos, send_n))
		{
			ngs_mp3_stop();
			return 0;
		}
		chunk_pos = (unsigned int)(chunk_pos + send_n);
	}
}
