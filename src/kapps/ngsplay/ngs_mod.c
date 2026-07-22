/*
 * NeoGS / General Sound stock MOD player (same protocol as GP mp3.asm loadmod).
 * Requires stock GS firmware (not SoftSmpl / not gscode).
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

#define IOBUF ((unsigned char *)0xC000)
#define MOD_CHUNK 16384u

static unsigned char mod_active;
static unsigned char mod_pos;
static unsigned char buf_page;
static unsigned char saved_c000;

static unsigned char wait_cmd_busy(void)
{
	unsigned int n;
	for (n = 0; n < 30000u; n++)
		if ((input(GSCOM) & 1) == 0)
			return 1;
	return 0;
}

/* Play Module (#31) can hold C while GS inits patterns ? seconds on big MODs. */
static unsigned char wait_cmd_busy_long(void)
{
	unsigned int outer;
	unsigned int n;

	for (outer = 0; outer < 500u; outer++)
	{
		for (n = 0; n < 2000u; n++)
			if ((input(GSCOM) & 1) == 0)
				return 1;
		YIELD();
	}
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

static unsigned char mod_cmd(unsigned char cmd)
{
	output(GSCOM, cmd);
	return wait_cmd_busy();
}

static unsigned char mod_cmd_long(unsigned char cmd)
{
	output(GSCOM, cmd);
	return wait_cmd_busy_long();
}

static void mod_hw_reset(void)
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

static unsigned char alloc_iobuf(void)
{
	union APP_PAGES pg;
	unsigned int r;

	pg.l = OS_GETMAINPAGES();
	saved_c000 = pg.pgs.window_3;
	r = OS_NEWPAGE();
	if (r > 255u)
		return 0;
	buf_page = (unsigned char)r;
	SETPG32KHIGH(buf_page);
	return 1;
}

static void free_iobuf(void)
{
	SETPG32KHIGH(saved_c000);
	if (buf_page != 0)
	{
		OS_DELPAGE(buf_page);
		buf_page = 0;
	}
}

static void copy_mod_title(ngs_mod_info *info)
{
	unsigned char i;
	unsigned char c;

	if (info == 0)
		return;
	for (i = 0; i < 20u && i < 28u; i++)
	{
		c = IOBUF[i];
		if (c == 0)
			break;
		if (c < 32u || c > 126u)
			c = ' ';
		info->title[i] = c;
	}
	info->title[i] = 0;
}

unsigned char ngs_mod_is_active(void)
{
	return mod_active;
}

void ngs_mod_stop(void)
{
	if (mod_active)
	{
		/* GP: warm reset unloads MOD */
		(void)mod_cmd(0xF3);
		mod_active = 0;
	}
	mod_pos = 0;
}

/* Returns 0 ok. Destroys SoftSmpl/gscode ? caller clears gs_ok. */
unsigned char ngs_mod_start(unsigned char *path, unsigned long filesize, ngs_mod_info *info)
{
	FILE *fp;
	unsigned int got;
	unsigned long done;
	unsigned long total;

	ngs_mod_stop();
	mod_hw_reset();
	ngs_invalidate();

	if (info != 0)
	{
		info->title[0] = 0;
		info->orders = 0;
		info->patterns = 0;
		info->instruments = 0;
		info->channels = 0;
		info->speed = 0;
		info->tempo = 0;
		if (filesize != 0)
			info->filesize = filesize;
	}

	fp = OS_OPENHANDLE(path, 0x80);
	if (((int)fp) & 0xff)
		return 1;

	if (filesize == 0)
		filesize = OS_GETFILESIZE(fp);
	total = filesize;
	done = 0;
	ngs_load_total = total;

	if (!alloc_iobuf())
	{
		OS_CLOSEHANDLE(fp);
		return 2;
	}

	/* #30 Load Module */
	if (!mod_cmd(0x30))
	{
		free_iobuf();
		OS_CLOSEHANDLE(fp);
		return 3;
	}
	/* #D1 Open stream */
	if (!mod_cmd(0xD1))
	{
		free_iobuf();
		OS_CLOSEHANDLE(fp);
		return 4;
	}

	for (;;)
	{
		got = OS_READHANDLE(IOBUF, fp, MOD_CHUNK);
		if (got == 0)
			break;
		if (done == 0)
			copy_mod_title(info);
		if (!gs_send_bytes(IOBUF, got))
		{
			(void)mod_cmd(0xD2);
			free_iobuf();
			OS_CLOSEHANDLE(fp);
			return 5;
		}
		done += got;
		if (total != 0)
			ngs_call_progress(done);
		if (got < MOD_CHUNK)
			break;
	}

	OS_CLOSEHANDLE(fp);
	/* #D2 Close stream */
	if (!mod_cmd(0xD2))
	{
		free_iobuf();
		return 6;
	}

	/* SD 1 / SC #31 Play Module.
	 * GS often starts audio before clearing C; short WC falsely returns 7
	 * while the module is already playing. */
	(void)wait_dat_clear_busy();
	output(GSDAT, 1);
	(void)wait_dat_clear_busy();
	if (!mod_cmd_long(0x31))
	{
		/* Still treat as playing if position (#60) answers. */
		output(GSCOM, 0x60);
		if (!wait_cmd_busy_long() || !wait_dat_set_busy())
		{
			free_iobuf();
			(void)mod_cmd(0xF3);
			return 7;
		}
		mod_pos = input(GSDAT);
	}

	free_iobuf();
	if (info != 0)
		info->filesize = total;
	if (total != 0)
		ngs_call_progress(total);

	mod_pos = 0;
	mod_active = 1;
	return 0;
}

/* 1 = still playing, 0 = finished (order position wrapped). */
unsigned char ngs_mod_pump(void)
{
	unsigned char pos;

	if (!mod_active)
		return 0;

	/* #60 Get play position */
	output(GSCOM, 0x60);
	if (!wait_cmd_busy())
	{
		ngs_mod_stop();
		return 0;
	}
	if (!wait_dat_set_busy())
	{
		ngs_mod_stop();
		return 0;
	}
	pos = input(GSDAT);

	/* GP: end when position decreases (restart wrap). */
	if (pos < mod_pos)
	{
		ngs_mod_stop();
		return 0;
	}
	mod_pos = pos;
	return 1;
}
