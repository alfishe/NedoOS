/*
 * NeoGS host: bootstrap NeoTracker player, S3M load/play protocol.
 */
#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "ngsplay.h"

#define GSCOM 187
#define GSDAT 179
#define GSCTR 0x33
#define C_GRST 0x80

#define GS_TICKS_LONG 2000L
#define GS_TICKS_CMD 400L
#define GS_TICKS_BYTE 200L
#define GS_TICKS_LOAD 5000L

#define IOBUF ((unsigned char *)0xC000)

static unsigned char buf_page;
static unsigned char saved_c000;
static unsigned char ngs_ready;

/*
 * NeoTracker-style waits: busy-poll, no YIELD during transfer.
 * Bound the spin so a stuck C/D bit fails in ~1-2s, not minutes.
 */
static unsigned char wait_cmd_busy(void)
{
	unsigned int n;

	for (n = 0; n < 30000u; n++)
	{
		if ((input(GSCOM) & 1) == 0)
			return 1;
	}
	return 0;
}

static unsigned char wait_dat_clear_busy(void)
{
	unsigned int n;

	for (n = 0; n < 30000u; n++)
	{
		if ((input(GSCOM) & 128) == 0)
			return 1;
	}
	return 0;
}

static unsigned char wait_dat_set_busy(void)
{
	unsigned int n;

	for (n = 0; n < 30000u; n++)
	{
		if ((input(GSCOM) & 128) != 0)
			return 1;
	}
	return 0;
}

/* Timed waits only for reset/detect (may YIELD). */
static unsigned char wait_cmd(long ticks)
{
	long deadline;

	deadline = time() + ticks;
	while ((input(GSCOM) & 1) != 0)
	{
		if (time() >= deadline)
			return 0;
		YIELD();
	}
	return 1;
}

static unsigned char wait_dat_clear(long ticks)
{
	long deadline;

	deadline = time() + ticks;
	while ((input(GSCOM) & 128) != 0)
	{
		if (time() >= deadline)
			return 0;
		YIELD();
	}
	return 1;
}

static unsigned char wait_dat(long ticks)
{
	long deadline;

	deadline = time() + ticks;
	while ((input(GSCOM) & 128) == 0)
	{
		if (time() >= deadline)
			return 0;
		YIELD();
	}
	return 1;
}

static unsigned char send_cmd(unsigned char cmd, long ticks)
{
	output(GSCOM, cmd);
	return wait_cmd(ticks);
}

static unsigned char send_dat(unsigned char data, long ticks)
{
	output(GSDAT, data);
	return wait_dat_clear(ticks);
}

static void poke_dat(unsigned char data)
{
	output(GSDAT, data);
}

static unsigned char get_dat(void)
{
	return input(GSDAT);
}

static void gs_drain(void)
{
	unsigned int n;

	for (n = 0; n < 32u; n++)
	{
		if ((input(GSCOM) & 128) == 0)
			break;
		(void)get_dat();
	}
}

/*
 * COM#14 ? exact NeoTracker save_NGS sequence:
 *   SD C / SC #14 / WD / SD B / WD / SD E / WD / SD D / WD / data...
 * Note: after SC #14 it is WD (data bit), NOT WC (command bit).
 */
unsigned char ngs_upload(const unsigned char *src, unsigned int len, unsigned int gs_addr)
{
	unsigned int i;

	if (len == 0)
		return 1;

	poke_dat((unsigned char)(len & 0xFFu));
	output(GSCOM, 0x14);
	if (!wait_dat_clear_busy())
		return 0;

	output(GSDAT, (unsigned char)(len >> 8));
	if (!wait_dat_clear_busy())
		return 0;

	output(GSDAT, (unsigned char)(gs_addr & 0xFFu));
	if (!wait_dat_clear_busy())
		return 0;

	output(GSDAT, (unsigned char)(gs_addr >> 8));
	if (!wait_dat_clear_busy())
		return 0;

	for (i = 0; i < len; i++)
	{
		output(GSDAT, src[i]);
		if (!wait_dat_clear_busy())
			return 0;
	}
	return 1;
}

/*
 * COM#13 ? Start5100 / Start0000:
 *   SD L / SC #13 / WC / SD H / WD
 * After JP, GS may not clear D from our POV ? don't hard-fail on WD.
 */
unsigned char ngs_jump(unsigned int gs_addr)
{
	poke_dat((unsigned char)(gs_addr & 0xFFu));
	output(GSCOM, 0x13);
	if (!wait_cmd_busy())
		return 0;
	output(GSDAT, (unsigned char)(gs_addr >> 8));
	(void)wait_dat_clear_busy();
	return 1;
}

/*
 * COM#15 ? NeoTracker load_NGS / StartLoad:
 *   ResetFlag(#00) / SD C / SC #15 / WD / SD B / WD / SD L / WD / SD H / WD_ER / WN+GD...
 * After the address high byte GS may already raise D with the first payload
 * byte before ZX sees D clear ? use best-effort WD (WD_ER), then WN+GD.
 */
static unsigned char ngs_download(unsigned char *dst, unsigned int len, unsigned int gs_addr)
{
	unsigned int i;
	unsigned int n;

	if (len == 0)
		return 1;

	/* ResetFlag: clear leftover C/D before #15 */
	output(GSCOM, 0x00);
	if (!wait_cmd_busy())
		return 0;

	poke_dat((unsigned char)(len & 0xFFu));
	output(GSCOM, 0x15);
	if (!wait_dat_clear_busy())
		return 0;
	output(GSDAT, (unsigned char)(len >> 8));
	if (!wait_dat_clear_busy())
		return 0;
	output(GSDAT, (unsigned char)(gs_addr & 0xFFu));
	if (!wait_dat_clear_busy())
		return 0;
	output(GSDAT, (unsigned char)(gs_addr >> 8));
	/* WD_ER: brief wait only ? D may already be set by first OUT ZXDATWR */
	for (n = 0; n < 256u; n++)
	{
		if ((input(GSCOM) & 128) == 0)
			break;
	}

	for (i = 0; i < len; i++)
	{
		if (!wait_dat_set_busy())
			return 0;
		dst[i] = get_dat();
	}
	return 1;
}

unsigned char ngs_set_page2(unsigned char page)
{
	poke_dat(page);
	return send_cmd(0xE0, GS_TICKS_CMD);
}

unsigned char ngs_set_page3(unsigned char page)
{
	poke_dat(page);
	return send_cmd(0xE1, GS_TICKS_CMD);
}

/*
 * sjasm ld hl,"TN" => HL=#544E => (#BC00)='N', (#BC01)='T'.
 * Neo8Tr compares the same 16-bit "TN" constant after load_NGS.
 */
unsigned char ngs_peek_nt(void)
{
	unsigned char id[2];

	if (!ngs_set_page2(1))
	{
		printf("peek: SetPage2 fail\r\n");
		return 0;
	}
	if (!ngs_download(id, 2, 0xBC00u))
	{
		printf("peek: #15 fail\r\n");
		return 0;
	}
	if (id[0] == 'N' && id[1] == 'T')
		return 1;
	printf("peek: got %02X %02X (want 4E 54 NT)\r\n",
		(unsigned int)id[0], (unsigned int)id[1]);
	return 0;
}

/* Sync to stock/NeoGS firmware: hw reset + #F3 (no #F4 cold test). */
static unsigned char ngs_reset_fw(void)
{
	gs_drain();
	output(GSCTR, C_GRST);
	YIELD();
	YIELD();
	YIELD();

	output(GSCOM, 0xF3);
	if (!wait_cmd(GS_TICKS_LONG))
		return 0;
	gs_drain();
	return 1;
}

unsigned char ngs_detect(void)
{
	return ngs_reset_fw();
}

unsigned char ngs_bootstrap(void)
{
	ngs_ready = 0;

	printf("NeoGS: reset...\r\n");
	if (!ngs_reset_fw())
	{
		printf("NeoGS: reset failed\r\n");
		return 0;
	}

	printf("NeoGS: uploading loader...\r\n");
	if (!ngs_upload(ngsldr_bin, ngsldr_bin_len, 0x5100u))
	{
		printf("upload loader failed\r\n");
		return 0;
	}
	printf("NeoGS: jump loader...\r\n");
	if (!ngs_jump(0x5100u))
	{
		printf("jump loader failed\r\n");
		return 0;
	}
	/* Loader stub only handles #13/#14 ? do NOT send #00 here (C-bit sticks). */

	printf("NeoGS: uploading ngsdrv (%u)...\r\n", ngsdrv_bin_len);
	if (!ngs_upload(ngsdrv_bin, ngsdrv_bin_len, 0x0000u))
	{
		printf("upload ngsdrv failed\r\n");
		return 0;
	}
	printf("NeoGS: jump ngsdrv...\r\n");
	if (!ngs_jump(0x0000u))
	{
		printf("jump ngsdrv failed\r\n");
		return 0;
	}
	/*
	 * initngs runs after JP #0000. Give it time, then sync with #00
	 * (full BIOS handles COM00 and clears C).
	 */
	printf("NeoGS: wait initngs...\r\n");
	{
		unsigned char i;
		for (i = 0; i < 30u; i++)
			YIELD();
	}
	output(GSCOM, 0x00);
	if (!wait_cmd(GS_TICKS_LOAD))
	{
		printf("initngs sync failed\r\n");
		return 0;
	}

	printf("NeoGS: uploading neopg2...\r\n");
	if (!ngs_set_page3(2))
	{
		printf("set page3 failed\r\n");
		return 0;
	}
	if (!ngs_upload(neopg2_bin, neopg2_bin_len, 0xD000u))
	{
		printf("upload neopg2 failed\r\n");
		return 0;
	}

	if (!ngs_peek_nt())
	{
		printf("NeoTracker ID not found @BC00\r\n");
		return 0;
	}

	ngs_ready = 1;
	printf("NeoGS: player ready\r\n");
	return 1;
}

unsigned char ngs_start_load(unsigned char slot, const unsigned char *header256)
{
	unsigned int i;

	if (slot >= 12u)
		return 0;
	poke_dat(slot);
	output(GSCOM, 0xE8);
	if (!wait_cmd_busy())
		return 0;
	/* After E8 GS consumes slot (D clears); then accept 256-byte header */
	if (!wait_dat_clear_busy())
		return 0;
	for (i = 0; i < 256u; i++)
	{
		output(GSDAT, header256[i]);
		if (!wait_dat_clear_busy())
			return 0;
	}
	/*
	 * After the 256th byte GS still runs Load_s3m (C-bit already clear!).
	 * Sync with #00: C stays set until Load finishes and COMINT handles it.
	 */
	output(GSCOM, 0x00);
	return wait_cmd(GS_TICKS_LOAD);
}

unsigned char ngs_get_next_block(unsigned char *type, unsigned int *ofs256, unsigned int *len256)
{
	unsigned char lo, hi;

	/* NeoTracker: SC #E9 / WC / GD / WN+GD... */
	output(GSCOM, 0xE9);
	if (!wait_cmd_busy())
		return 0;
	if (!wait_dat_set_busy())
		return 0;
	*type = get_dat();
	if (!wait_dat_set_busy())
		return 0;
	lo = get_dat();
	if (!wait_dat_set_busy())
		return 0;
	hi = get_dat();
	*ofs256 = ((unsigned int)hi << 8) | lo;
	if (!wait_dat_set_busy())
		return 0;
	lo = get_dat();
	if (!wait_dat_set_busy())
		return 0;
	hi = get_dat();
	*len256 = ((unsigned int)hi << 8) | lo;
	return 1;
}

unsigned char ngs_save_block(const unsigned char *data, unsigned char pages256)
{
	unsigned int n;
	unsigned int i;

	if (pages256 == 0)
		return 1;
	/* NeoTracker Save_Block: SD A / SC #EA / WD / OUT+WD loop (no YIELD) */
	n = (unsigned int)pages256 << 8;
	poke_dat(pages256);
	output(GSCOM, 0xEA);
	if (!wait_cmd_busy())
		return 0;
	if (!wait_dat_clear_busy())
		return 0;
	for (i = 0; i < n; i++)
	{
		output(GSDAT, data[i]);
		if (!wait_dat_clear_busy())
			return 0;
	}
	return 1;
}

unsigned char ngs_init_sample(unsigned char module, unsigned char smp)
{
	poke_dat(module);
	if (!send_cmd(0xE2, GS_TICKS_CMD))
		return 0;
	if (!wait_dat_clear(GS_TICKS_CMD))
		return 0;
	return send_dat(smp, GS_TICKS_BYTE);
}

unsigned char ngs_start_play(unsigned char module, unsigned char order)
{
	poke_dat(module);
	if (!send_cmd(0xE3, GS_TICKS_CMD))
		return 0;
	if (!wait_dat_clear(GS_TICKS_CMD))
		return 0;
	return send_dat(order, GS_TICKS_BYTE);
}

unsigned char ngs_stop_play(void)
{
	return send_cmd(0xE4, GS_TICKS_CMD);
}

unsigned char ngs_cont_play(void)
{
	return send_cmd(0xE5, GS_TICKS_CMD);
}

unsigned char ngs_status_play(void)
{
	if (!send_cmd(0xE6, GS_TICKS_CMD))
		return 0;
	if (!wait_dat(GS_TICKS_CMD))
		return 0;
	return get_dat();
}

static unsigned char alloc_iobuf(void)
{
	union APP_PAGES main_pg;
	unsigned int r;

	main_pg.l = OS_GETMAINPAGES();
	saved_c000 = main_pg.pgs.window_3;
	r = OS_NEWPAGE();
	if (r > 255u)
		return 0;
	buf_page = (unsigned char)r;
	SETPG32KHIGH(buf_page);
	return 1;
}

static void free_iobuf(void)
{
	if (buf_page)
	{
		SETPG32KHIGH(saved_c000);
		OS_DELPAGE((char)buf_page);
		buf_page = 0;
	}
}

unsigned char ngs_load_s3m(unsigned char *path, unsigned char *title_out)
{
	FILE *fp;
	unsigned char typ;
	unsigned int ofs256;
	unsigned int len256;
	unsigned int got;
	unsigned long seekb;
	unsigned int chunk;
	unsigned int left;
	unsigned char *p;

	title_out[0] = 0;
	if (!ngs_ready && !ngs_bootstrap())
		return 1;

	if (!alloc_iobuf())
	{
		printf("No free RAM page for buffer\r\n");
		return 2;
	}

	fp = OS_OPENHANDLE(path, 0x80);
	/* NedoOS: HL = handle<<8 | errno; success when low byte is 0 (handle may be 0). */
	if (((int)fp) & 0xff)
	{
		printf("Cannot open %s (err %u)\r\n", path, (unsigned int)(((int)fp) & 0xff));
		free_iobuf();
		return 3;
	}

	got = OS_READHANDLE(IOBUF, fp, 256);
	if (got < 256u)
	{
		printf("Short file\r\n");
		OS_CLOSEHANDLE(fp);
		free_iobuf();
		return 4;
	}

	/* SCRM at offset 0x2C */
	if (IOBUF[0x2C] != 'S' || IOBUF[0x2D] != 'C' ||
	    IOBUF[0x2E] != 'R' || IOBUF[0x2F] != 'M')
	{
		printf("Not an S3M file (no SCRM)\r\n");
		OS_CLOSEHANDLE(fp);
		free_iobuf();
		return 5;
	}

	memcpy(title_out, IOBUF, 28);
	title_out[28] = 0;
	/* Make title safe for printf / BDOS */
	{
		unsigned char i;
		unsigned char c;

		for (i = 0; i < 28u; i++)
		{
			c = title_out[i];
			if (c == 0)
				break;
			if (c < 32u || c > 126u || c == (unsigned char)'%')
				title_out[i] = '.';
		}
	}

	printf("Loading: %s\r\n", title_out);

	/* Count enabled channels in S3M map (0x40..0x7F); warn if >8 */
	{
		unsigned int ch;
		unsigned int nch;

		nch = 0;
		for (ch = 0; ch < 32u; ch++)
		{
			if (IOBUF[0x40u + ch] != 255u)
				nch++;
		}
		printf("Channels: %u\r\n", nch);
		if (nch > 8u)
			printf("Warning: mixer uses 8\r\n");
	}

	printf("S3M Start_Load...\r\n");
	if (!ngs_start_load(0, IOBUF))
	{
		printf("Start_Load failed\r\n");
		OS_CLOSEHANDLE(fp);
		free_iobuf();
		return 6;
	}

	printf("S3M blocks...\r\n");
	for (;;)
	{
		if (!ngs_get_next_block(&typ, &ofs256, &len256))
		{
			printf("GetNextBlock failed\r\n");
			OS_CLOSEHANDLE(fp);
			free_iobuf();
			return 7;
		}
		if (typ == 0)
		{
			printf("Blocks done\r\n");
			break;
		}
		if (typ == 255u || typ == 123u)
		{
			printf("Load error type %u\r\n", (unsigned int)typ);
			OS_CLOSEHANDLE(fp);
			free_iobuf();
			return 8;
		}

		/* Feed requested pages in <=16K chunks (COMEA max #40) */
		seekb = (unsigned long)ofs256 << 8;
		OS_SEEKHANDLE(fp, seekb);
		left = len256;
		while (left != 0)
		{
			chunk = left;
			if (chunk > 64u)
				chunk = 64u; /* 16K */
			got = OS_READHANDLE(IOBUF, fp, (unsigned int)chunk << 8);
			if (got < ((unsigned int)chunk << 8))
			{
				/* pad remainder with zeros if short read at EOF */
				p = IOBUF + got;
				while (got < ((unsigned int)chunk << 8))
				{
					*p++ = 0;
					got++;
				}
			}
			if (!ngs_save_block(IOBUF, (unsigned char)chunk))
			{
				printf("Save_Block failed\r\n");
				OS_CLOSEHANDLE(fp);
				free_iobuf();
				return 9;
			}
			left = (unsigned int)(left - chunk);
		}
	}

	OS_CLOSEHANDLE(fp);

	printf("InitSample...\r\n");
	if (!ngs_init_sample(0, 255))
	{
		printf("InitSample failed\r\n");
		free_iobuf();
		return 10;
	}

	free_iobuf();
	return 0;
}
