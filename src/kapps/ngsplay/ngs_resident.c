#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include <stdio.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include "ngs_plug.h"

/*
 * CODE_RESIDENT linked at C000; physical copy is window_3 (residentPg).
 * No BSS here ? only stack/args and low-memory globals from ngs_plug.h.
 */

void r_spaces(unsigned char n)
{
	while (n > 0)
	{
		putchar(' ');
		n--;
	}
}

void r_print_static(const char *s)
{
	while (*s)
		putchar(*s++);
}

void r_put_clipped(const unsigned char *s, unsigned char maxn)
{
	unsigned char i;

	for (i = 0; i < maxn && s[i] != 0; i++)
		putchar(s[i]);
}

void r_restore_right_border_row(struct coordinates win, unsigned char row)
{
	OS_SETCOLOR(win.color);
	OS_SETXY(win.winX + win.winW, win.winY + row);
	putchar(186);
}

void r_clear_window_bg(struct coordinates win)
{
	unsigned char q;

	OS_SETCOLOR(win.color);
	for (q = 0; q < win.winH; q++)
	{
		OS_SETXY(win.winX, win.winY + q);
		r_spaces(win.winW);
	}
}

void r_draw_player_frame(struct coordinates win)
{
	unsigned char q;

	OS_SETCOLOR(win.color);
	OS_SETXY(win.winX - 1, win.winY - 1);
	putchar(201);
	for (q = 0; q < win.winW; q++)
		putchar(205);
	putchar(187);

	for (q = 0; q < win.winH; q++)
	{
		OS_SETXY(win.winX - 1, win.winY + q);
		putchar(186);
		OS_SETXY(win.winX + win.winW, win.winY + q);
		putchar(186);
	}

	OS_SETXY(win.winX - 1, win.winY + win.winH);
	putchar(200);
	for (q = 0; q < win.winW; q++)
		putchar(205);
	putchar(188);
}

void r_draw_title_bar(void)
{
	unsigned char i;
	unsigned char n;

	OS_SETCOLOR(COL_STAT);
	OS_SETXY(0, 0);
	r_spaces(80);
	OS_SETXY(0, 0);
	printf(" NeoGS Player  ");
	n = 0;
	for (i = 0; path_buf[i] != 0 && n < 50u; i++)
	{
		putchar(path_buf[i]);
		n++;
	}
}

void r_draw_hint_bar(void)
{
	OS_SETCOLOR(COL_STAT);
	OS_SETXY(0, 23);
	r_spaces(80);
	OS_SETXY(0, 23);
	r_print_static(" [Enter] Play  [N] Next  [Space] Pause  [S] Stop  [R] Refr  [Esc] Quit ");
}

void r_clear_status_line(unsigned char row)
{
	OS_SETCOLOR(statPos.color);
	OS_SETXY(statPos.winX, statPos.winY + row);
	r_spaces(statPos.winW);
}

unsigned char r_status_bar_w(void)
{
	if (statPos.winW > 14u)
		return (unsigned char)(statPos.winW - 14u);
	return 8;
}

void r_progress_bar_reset(void)
{
	unsigned char bar_w;
	unsigned char i;
	unsigned char x;
	unsigned char y;
	unsigned char last;

	last = (unsigned char)(statPos.winH - 1u);
	bar_w = r_status_bar_w();
	x = (unsigned char)(statPos.winX + 1);
	y = (unsigned char)(statPos.winY + last);
	OS_SETCOLOR(statPos.color);
	r_clear_status_line(last);
	OS_SETXY(x, y);
	putchar('[');
	for (i = 0; i < bar_w; i++)
		putchar('.');
	putchar(']');
	printf("%3u%%", 0u);
	r_restore_right_border_row(statPos, last);
	bar_filled = 0;
	bar_inited = 1;
}

void r_progress_bar_grow(unsigned char pct)
{
	unsigned char bar_w;
	unsigned char filled;
	unsigned char x;
	unsigned char y;
	unsigned char i;

	bar_w = r_status_bar_w();
	x = (unsigned char)(statPos.winX + 1);
	y = (unsigned char)(statPos.winY + statPos.winH - 1u);

	if (!bar_inited)
		r_progress_bar_reset();

	if (pct > 100u)
		pct = 100;
	filled = (unsigned char)(((unsigned int)pct * bar_w) / 100u);
	if (filled > bar_w)
		filled = bar_w;

	OS_SETCOLOR(statPos.color);
	if (filled > bar_filled)
	{
		OS_SETXY((unsigned char)(x + 1u + bar_filled), y);
		for (i = bar_filled; i < filled; i++)
			putchar(219);
		bar_filled = filled;
	}
	OS_SETXY((unsigned char)(x + bar_w + 2u), y);
	printf("%3u%%", (unsigned int)pct);
}

void r_draw_status_meta(void)
{
	const char *st;
	unsigned char maxn;

	OS_SETCOLOR(statPos.color);

	r_clear_status_line(0);
	OS_SETXY(statPos.winX + 1, statPos.winY);
	if (is_loading)
		st = "[LOADING]";
	else if (is_paused)
		st = "[PAUSE]  ";
	else if (is_playing)
		st = "[PLAYING]";
	else
		st = "[STOPPED]";
	printf("%s ", st);
	maxn = (statPos.winW > 12u) ? (unsigned char)(statPos.winW - 12u) : 0;
	r_put_clipped(cur_file, maxn);

	r_clear_status_line(1);
	OS_SETXY(statPos.winX + 1, statPos.winY + 1);
	if (mod.title[0] != 0)
		r_put_clipped(mod.title, (unsigned char)(statPos.winW > 2u ? statPos.winW - 2u : 0));
	else
		r_print_static("Select .S3M / .MOD / .MP3 and press Enter");

	r_clear_status_line(2);
	OS_SETXY(statPos.winX + 1, statPos.winY + 2);
	if (mod.title[0] != 0)
	{
		printf("Ch:%u Ord:%u Pat:%u Ins:%u  Spd:%u Tmp:%u",
			(unsigned int)mod.channels,
			mod.orders, mod.patterns, mod.instruments,
			(unsigned int)mod.speed, (unsigned int)mod.tempo);
	}

	r_restore_right_border_row(statPos, 0);
	r_restore_right_border_row(statPos, 1);
	r_restore_right_border_row(statPos, 2);
}

void r_draw_status_bottom(void)
{
	unsigned long elapsed;
	unsigned int em;
	unsigned int es;
	unsigned char last;

	last = (unsigned char)(statPos.winH - 1u);
	OS_SETCOLOR(statPos.color);

	if (is_loading)
	{
		if (!bar_inited)
			r_progress_bar_reset();
		else
			r_progress_bar_grow(load_pct);
		return;
	}

	r_clear_status_line(last);
	OS_SETXY(statPos.winX + 1, (unsigned char)(statPos.winY + last));
	bar_inited = 0;
	bar_filled = 0;

	if (is_playing || is_paused)
	{
		elapsed = 0;
		if (play_start_tick != 0)
		{
			elapsed = (unsigned long)(time() - play_start_tick);
			elapsed = elapsed / 50u;
		}
		em = (unsigned int)(elapsed / 60u);
		es = (unsigned int)(elapsed % 60u);
		shown_time_sec = (unsigned int)elapsed;
		printf("Time %02u:%02u", em, es);
	}
	else
	{
		r_print_static("Ready");
	}

	r_restore_right_border_row(statPos, last);
}

void r_draw_status(void)
{
	unsigned char q;

	for (q = 3; q + 1u < statPos.winH; q++)
	{
		r_clear_status_line(q);
		r_restore_right_border_row(statPos, q);
	}
	r_draw_status_meta();
	r_draw_status_bottom();
}

void r_draw_static_chrome(void)
{
	/* OS_CLS must run from low CODE (main) ? BDOS may page C000. */
	r_clear_window_bg(winPos);
	r_clear_window_bg(statPos);
	r_draw_player_frame(winPos);
	r_draw_player_frame(statPos);
	r_draw_title_bar();
	r_draw_hint_bar();
	r_draw_status();
}
