/*
 * ngsplay ? NeoGS 8-channel S3M player for NedoOS
 *
 * Usage: ngsplay.com file.s3m
 *        ngsplay.com          (usage)
 *
 * Keys while playing: Space = pause/continue, Esc = stop and quit
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include "ngsplay.h"

static unsigned char title[32];
static unsigned char paused;

static void wait_key(void)
{
	unsigned int key;

	printf("Press any key...\r\n");
	do
	{
		YIELD();
		key = _low_level_get();
	} while (key == 0);
}

static void usage(void)
{
	printf("ngsplay.com - NeoGS 8ch S3M player\r\n");
	printf("Usage: ngsplay.com file.s3m\r\n");
	printf("Keys: Space pause, Esc quit\r\n");
}

static void play_loop(void)
{
	unsigned int key;

	paused = 0;
	printf("\r\nPlaying: %s\r\n", title);
	printf("Space=pause  Esc=stop\r\n");

	for (;;)
	{
		YIELD();
		key = _low_level_get();
		if (key == 27u) /* Esc */
		{
			(void)ngs_stop_play();
			break;
		}
		if (key == 32u) /* Space */
		{
			if (paused)
			{
				(void)ngs_cont_play();
				paused = 0;
				printf("Continue\r\n");
			}
			else
			{
				(void)ngs_stop_play();
				paused = 1;
				printf("Pause\r\n");
			}
		}
	}
}

C_task main(int argc, char *argv[])
{
	unsigned char err;
	static unsigned char path[128];
	unsigned char i;
	unsigned char c;

	os_initstdio();
	OS_SETGFX(6); /* text */

	if (argc < 2)
	{
		usage();
		exit(0);
	}

	/*
	 * Copy argv[1] into static storage before any helpers.
	 * IAR Z80 can pass argv pointers poorly across calls (see playwav).
	 */
	for (i = 0; i < 127u; i++)
	{
		c = (unsigned char)argv[1][i];
		path[i] = c;
		if (c == 0)
			break;
	}
	path[127] = 0;

	err = ngs_load_s3m(path, title);
	if (err != 0)
	{
		printf("Load failed (%u)\r\n", (unsigned int)err);
		wait_key();
		exit(1);
	}

	printf("OK loaded: %s\r\n", title);
	printf("Start play...\r\n");
	if (!ngs_start_play(0, 0))
	{
		printf("Play failed\r\n");
		wait_key();
		exit(1);
	}

	play_loop();
	exit(0);
}
