/*
 * Time Gal: the video engine plays each clip, the script only wakes up
 * between frames when a choice window is open.
 *
 * Gray squares mark directions, a circle at the bottom is fire.
 * They go away once the right key is pressed.
 * Cursor keys, fire is Enter, 0 or m.
 * Any key skips the intro. Esc leaves during a level.
 * Clips are timegal\<name>, the folder next to this .com in /nedogame/.
 */
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <graphic.h>
#include <tgvplay.h>
#include "script.h"

static char path[24];

static void make_path(const char *name)
{
	unsigned char i;
	unsigned char n;
	static const char dir[] = "timegal\\";

	for (i = 0u; dir[i] != 0; i++)
		path[i] = dir[i];
	for (n = 0u; name[n] != 0 && n < 12u; n++)
		path[i++] = name[n];
	path[i] = 0;
}

static unsigned char play_name(const char *name)
{
	int err;

	make_path(name);
	err = tgv_fmv_play(path);
	if (err != 0)
		return 2u;
	if (tgv_fmv_aborted())
		return 1u;
	return 0u;
}

static unsigned char clips_ready(void)
{
	FILE *fp;

	make_path("gintro");
	fp = OS_OPENHANDLE((unsigned char *)path, 0x80);
	if (((unsigned int)fp & 0xFFu) != 0u)
		return 0u;
	OS_CLOSEHANDLE(fp);
	return 1u;
}

static void wait_key(void)
{
	unsigned char k;
	unsigned int n;

	/* The key that started the program is still queued. Drop it,
	   then wait for a new one, or the message disappears at once. */
	for (n = 0u; n < 64u; n++)
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

/* CP866. Text mode first: after OS_HIDEFROMPARENT there is no screen yet. */
static void say_missing(void)
{
	OS_SETGFX(6u);
	OS_HALT();
	OS_CLS(0);
	OS_SETCOLOR(7u);
	puts("\x94\xA0\xA9\xAB\xEB \xA8\xA3\xE0\xEB \xAD\xA5 \xAD\xA0\xA9\xA4\xA5\xAD\xEB, \xAF\xAE\xA6\xA0\xAB\xE3\xA9\xE1\xE2\xA0  \xE1\xAA\xA0\xE7\xA0\xA9\xE2\xA5 \xAE\xA1\xE0\xA0\xA7 \xA8\xA3\xE0\xEB \xE1 \xE1\xA0\xA9\xE2\xA0\r\n");
	puts("http://atmturbo.nedopc.com/download/cdsoft/time_gal/time_gal.htm\r\n");
	puts("\xA8 \xE0\xA0\xE1\xAF\xA0\xAA\xE3\xA9\xE2\xA5 \xE4\xA0\xA9\xAB\xEB \xA8\xA7 ISO \xAE\xA1\xE0\xA0\xA7\xA0 \xA2 \xAF\xA0\xAF\xAA\xE3 timegal\r\n");
	wait_key();
}

C_task main(void)
{
	unsigned char lv;
	unsigned char n;
	unsigned char st;
	unsigned char started;
	const char *death;

	st = 0u;
	started = 0u;
	script_reset();
	OS_HIDEFROMPARENT();
	if (!clips_ready())
	{
		st = 2u;
		say_missing();
		return 0;
	}

	tgv_on_sector = script_pump;
	tgv_session_begin();
	started = 1u;

	script_bind(0);
	tgv_key_skip = 1u;
	st = play_name(script_file(0));
	tgv_key_skip = 0u;
	if (st != 0u)
		goto done;

	n = script_levels();
	for (lv = 1u; lv < n; lv++) {
		script_use_mirror(0u);
		for (;;) {
			script_bind(lv);
			st = play_name(script_level_file(lv));
			if (st != 0u)
				goto done;
			if (!script_failed())
			{
				script_use_mirror(0u);
				break;
			}
			if (script_take_life() == 0u)
			{
				st = 3u;
				goto done;
			}
			death = script_death();
			if (death != 0) {
				tgv_ev_disarm();
				st = play_name(death);
				if (st != 0u)
					goto done;
			}
			script_use_mirror(script_death_to_mirror());
		}
	}

done:
	/* Picture lives next to the clips. Text only if that file is not there. */
	if (st == 3u && started)
	{
		make_path("gover");
		if (tgv_show_still(path) == 0)
		{
			wait_key();
			st = 4u;
		}
	}
	if (started)
		tgv_session_end();
	OS_CLS(0);
	OS_SETCOLOR(7u);
	if (st == 2u)
		say_missing();
	else if (st == 3u)
	{
		OS_SETGFX(6u);
		OS_HALT();
		OS_CLS(0);
		OS_SETCOLOR(7u);
		puts("\x86\x88\x87\x8D\x88 \x8A\x8E\x8D\x97\x88\x8B\x88\x91\x9C\r\n");
		wait_key();
	}
	else if (st == 1u)
		puts("Stopped.\r\n");
	else if (st == 0u)
		puts("The end.\r\n");
	return 0;
}
