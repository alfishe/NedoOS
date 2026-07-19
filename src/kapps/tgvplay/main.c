/*
 * tgvplay - AloneVid FMV player (NedoOS).
 *
 *   tgvplay <file>         play FMV
 *   tgvplay nhalt <file>   play without HALT latch (may tear)
 */
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <tgvplay.h>

static void wait_key(void)
{
	unsigned char k;
	unsigned int n;

	for (n = 0u; n < 256u; n++)
	{
		k = (unsigned char)(OS_GETKEY() & 0xFFu);
		if (k == 0u)
			break;
		YIELD();
	}
	for (;;)
	{
		k = (unsigned char)(OS_GETKEY() & 0xFFu);
		if (k != 0u)
			return;
		YIELD();
	}
}

static void usage(void)
{
	puts("Usage:\r\n");
	puts("  tgvplay <file>        play FMV\r\n");
	puts("  tgvplay nhalt <file>  play w/o HALT (may tear)\r\n");
	puts("Esc aborts.\r\n");
}

C_task main(int argc, const char *argv[])
{
	int err;
	const char *path;

	OS_HIDEFROMPARENT();

	if (argc < 2)
	{
		usage();
		puts("Press any key...\r\n");
		wait_key();
		return 1;
	}

	tgv_fmv_no_halt = 0u;
	if (strcmp(argv[1], "nhalt") == 0)
	{
		if (argc < 3)
		{
			usage();
			puts("Press any key...\r\n");
			wait_key();
			return 1;
		}
		tgv_fmv_no_halt = 1u;
		path = argv[2];
		tgv_text_mode();
		printf("tgvplay nhalt: %s\r\n", path);
	}
	else
	{
		path = argv[1];
		tgv_text_mode();
		printf("tgvplay: %s\r\n", path);
	}

	err = tgv_fmv_play(path);

	tgv_text_mode();
	OS_CLS(0);
	OS_SETCOLOR(7u);

	if (err != 0)
	{
		printf("FMV error %d\r\n", err);
		puts("Press any key...\r\n");
		wait_key();
		return (unsigned char)err;
	}

	if (tgv_fmv_aborted())
		puts("Stopped by Esc.\r\n");
	else
		puts("Done.\r\n");
	puts("Press any key...\r\n");
	wait_key();
	return 0;
}
