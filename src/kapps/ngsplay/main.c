/*
 * ngsplay ? NeoGS 8-channel S3M player for NedoOS
 * UI style matches cdplay.com (double-line frames, list + status).
 *
 * Keys: Up/Down browse, Enter open/play, Space pause, S stop, R refresh, Esc/Q quit
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include "ngsplay.h"

#define MAX_ENTRIES 64
#define NAME_MAX 40
#define COL_LIST 103
#define COL_CURSOR 188
#define COL_STAT 223
#define ATTR_DIR 0x10

struct coordinates
{
	unsigned char winX;
	unsigned char winY;
	unsigned char winW;
	unsigned char winH;
	unsigned char color;
};

struct dir_entry
{
	unsigned char name[NAME_MAX];
	unsigned char is_dir;
	unsigned long size;
};

static struct coordinates winPos;
static struct coordinates statPos;
static struct dir_entry entries[MAX_ENTRIES];
static unsigned char entry_count;
static unsigned char ui_selected;
static unsigned char ui_scroll;
static unsigned char need_redraw;
static unsigned char status_dirty;

static unsigned char is_playing;
static unsigned char is_paused;
static unsigned char is_loading;
static unsigned char gs_ok;

static ngs_mod_info mod;
static unsigned char cur_file[NAME_MAX];
static unsigned char path_buf[80];
static fileInfo dir_fi;

static long play_start_tick;
static unsigned char load_pct;
static unsigned char shown_load_pct;
static unsigned int shown_time_sec;
static unsigned long prog_last_done;
static unsigned char prog_last_decade;
static unsigned char bar_filled;	/* cells already painted with 219 */
static unsigned char bar_inited;	/* empty frame drawn */
static unsigned char autostart[128];

#define KEY_UP 250
#define KEY_DOWN 249
#define KEY_LEFT 248
#define KEY_RIGHT 251
#define PROG_STEP_BYTES 65536UL /* ~64KB between bar updates */

static unsigned char pct_of(unsigned long done, unsigned long total)
{
	unsigned int d;
	unsigned int t;
	unsigned int p;

	if (total == 0)
		return 0;
	if (done >= total)
		return 100;
	/* Avoid 32x32 mul overflow quirks: scale to 16-bit pages. */
	d = (unsigned int)(done >> 8);
	t = (unsigned int)(total >> 8);
	if (t == 0)
		t = 1;
	p = (unsigned int)(((unsigned long)d * 100u) / t);
	if (p > 100u)
		p = 100;
	return (unsigned char)p;
}

static void spaces(unsigned char n)
{
	while (n > 0)
	{
		putchar(' ');
		n--;
	}
}

static void printStaticStr(const char *s)
{
	while (*s)
		putchar(*s++);
}

static void quit_app(void)
{
	if (is_playing || is_paused)
		(void)ngs_stop_play();
	OS_SETGFX(0x86);
	exit(0);
}

static unsigned char ensure_gs(void)
{
	unsigned char attempt;
	unsigned char t;

	if (gs_ok)
		return 1;

	for (attempt = 0; attempt < 3u; attempt++)
	{
		if (attempt != 0)
		{
			for (t = 0; t < 25u; t++)
				YIELD();
		}
		if (ngs_bootstrap())
		{
			gs_ok = 1;
			return 1;
		}
	}
	gs_ok = 0;
	return 0;
}

static void clearWindowBackground(struct coordinates win)
{
	unsigned char q;

	OS_SETCOLOR(win.color);
	for (q = 0; q < win.winH; q++)
	{
		OS_SETXY(win.winX, win.winY + q);
		spaces(win.winW);
	}
}

static void drawPlayerFrame(struct coordinates win)
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

/* Restore right double-line after interior text may have overwritten it. */
static void restore_right_border_row(struct coordinates win, unsigned char row)
{
	OS_SETCOLOR(win.color);
	OS_SETXY(win.winX + win.winW, win.winY + row);
	putchar(186);
}

static void put_clipped(const unsigned char *s, unsigned char maxn)
{
	unsigned char i;

	for (i = 0; i < maxn && s[i] != 0; i++)
		putchar(s[i]);
}

static void clear_status_line(unsigned char row)
{
	OS_SETCOLOR(statPos.color);
	OS_SETXY(statPos.winX, statPos.winY + row);
	spaces(statPos.winW);
}

static unsigned char status_bar_w(void)
{
	if (statPos.winW > 14u)
		return (unsigned char)(statPos.winW - 14u);
	return 8;
}

static void draw_progress_bar(unsigned char x, unsigned char y, unsigned char width, unsigned char pct)
{
	unsigned char filled;
	unsigned char i;

	if (pct > 100u)
		pct = 100;
	filled = (unsigned char)(((unsigned int)pct * width) / 100u);
	if (filled > width)
		filled = width;

	OS_SETXY(x, y);
	putchar('[');
	for (i = 0; i < filled; i++)
		putchar(219);
	for (i = filled; i < width; i++)
		putchar('.');
	putchar(']');
	printf(" %3u%%", (unsigned int)pct);
}

/* Draw empty bar once; later only append new fill cells + refresh %. */
static void progress_bar_reset(void)
{
	unsigned char bar_w;
	unsigned char i;
	unsigned char x;
	unsigned char y;

	bar_w = status_bar_w();
	x = (unsigned char)(statPos.winX + 1);
	y = (unsigned char)(statPos.winY + 3);
	OS_SETCOLOR(statPos.color);
	clear_status_line(3);
	OS_SETXY(x, y);
	putchar('[');
	for (i = 0; i < bar_w; i++)
		putchar('.');
	putchar(']');
	printf("   0%%");
	restore_right_border_row(statPos, 3);
	bar_filled = 0;
	bar_inited = 1;
	shown_load_pct = 0;
}

static void progress_bar_grow(unsigned char pct)
{
	unsigned char bar_w;
	unsigned char filled;
	unsigned char x;
	unsigned char y;
	unsigned char i;

	bar_w = status_bar_w();
	x = (unsigned char)(statPos.winX + 1);
	y = (unsigned char)(statPos.winY + 3);

	if (!bar_inited)
		progress_bar_reset();

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
	/* percent text sits after ']' */
	OS_SETXY((unsigned char)(x + bar_w + 2u), y);
	printf("%3u%%", (unsigned int)pct);
	shown_load_pct = pct;
}

static void refresh_path(void)
{
	unsigned char i;

	for (i = 0; i < 79u; i++)
		path_buf[i] = 0;
	(void)OS_GETPATH((unsigned int)path_buf);
	path_buf[79] = 0;
}

static void draw_title_bar(void)
{
	unsigned char i;
	unsigned char n;

	OS_SETCOLOR(COL_STAT);
	OS_SETXY(0, 0);
	spaces(80);
	OS_SETXY(0, 0);
	printf(" NeoGS S3M Player  ");
	n = 0;
	for (i = 0; path_buf[i] != 0 && n < 50u; i++)
	{
		putchar(path_buf[i]);
		n++;
	}
}

static void draw_hint_bar(void)
{
	OS_SETCOLOR(COL_STAT);
	OS_SETXY(0, 23);
	spaces(80);
	OS_SETXY(0, 23);
	printStaticStr(" [Enter] Play  [Space] Pause  [S] Stop  [R] Refresh  [Esc] Quit ");
}

static void draw_status_meta(void)
{
	const char *st;
	unsigned char maxn;

	OS_SETCOLOR(statPos.color);

	clear_status_line(0);
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
	maxn = (unsigned char)(statPos.winW - 12u);
	put_clipped(cur_file, maxn);

	clear_status_line(1);
	OS_SETXY(statPos.winX + 1, statPos.winY + 1);
	if (mod.title[0] != 0)
		put_clipped(mod.title, (unsigned char)(statPos.winW - 2u));
	else
		printStaticStr("Select an .S3M file and press Enter");

	clear_status_line(2);
	OS_SETXY(statPos.winX + 1, statPos.winY + 2);
	if (mod.title[0] != 0)
	{
		printf("Ch:%u Ord:%u Pat:%u Ins:%u  Spd:%u Tmp:%u",
			(unsigned int)mod.channels,
			mod.orders, mod.patterns, mod.instruments,
			(unsigned int)mod.speed, (unsigned int)mod.tempo);
	}

	restore_right_border_row(statPos, 0);
	restore_right_border_row(statPos, 1);
	restore_right_border_row(statPos, 2);
}

static void draw_status_bottom(void)
{
	unsigned long elapsed;
	unsigned int em;
	unsigned int es;

	OS_SETCOLOR(statPos.color);

	if (is_loading)
	{
		if (!bar_inited)
			progress_bar_reset();
		else
			progress_bar_grow(load_pct);
		return;
	}

	clear_status_line(3);
	OS_SETXY(statPos.winX + 1, statPos.winY + 3);
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
		printStaticStr("Ready");
	}

	restore_right_border_row(statPos, 3);
}

static void draw_status(void)
{
	draw_status_meta();
	draw_status_bottom();
	status_dirty = 0;
}

static void mark_status_dirty(void)
{
	status_dirty = 1;
}

/* Clock / progress only ? does not touch title/meta lines. */
static void update_status_bottom_if_needed(void)
{
	unsigned long elapsed;
	unsigned int sec;

	if (is_loading)
		return;

	if (is_playing && !is_paused)
	{
		elapsed = 0;
		if (play_start_tick != 0)
		{
			elapsed = (unsigned long)(time() - play_start_tick);
			elapsed = elapsed / 50u;
		}
		sec = (unsigned int)elapsed;
		if (sec != shown_time_sec)
			draw_status_bottom();
	}
}

static void draw_static_screen(void)
{
	OS_CLS(0);
	clearWindowBackground(winPos);
	clearWindowBackground(statPos);
	drawPlayerFrame(winPos);
	drawPlayerFrame(statPos);
	draw_title_bar();
	draw_hint_bar();
	mark_status_dirty();
	draw_status();
	need_redraw = 1;
}

static unsigned char is_s3m_name(const unsigned char *name)
{
	unsigned char i;
	unsigned char dot;
	unsigned char c;

	dot = 255;
	for (i = 0; name[i] != 0; i++)
	{
		if (name[i] == '.')
			dot = i;
	}
	if (dot == 255 || name[dot + 1] == 0)
		return 0;
	c = name[dot + 1];
	if (c != 'S' && c != 's')
		return 0;
	c = name[dot + 2];
	if (c != '3')
		return 0;
	c = name[dot + 3];
	if ((c == 'M' || c == 'm') && name[dot + 4] == 0)
		return 1;
	return 0;
}

static void copy_name(unsigned char *dst, const unsigned char *src, unsigned char maxlen)
{
	unsigned char i;
	unsigned char lim;

	lim = (unsigned char)(maxlen - 1u);
	for (i = 0; i < lim; i++)
	{
		dst[i] = src[i];
		if (src[i] == 0)
			break;
	}
	dst[i] = 0;
	dst[maxlen - 1u] = 0;
}

static const unsigned char *entry_display_name(fileInfo *fi)
{
	if (fi->lfname[0] != 0)
		return fi->lfname;
	return fi->fname;
}

static unsigned char scan_dir(void)
{
	unsigned char err;
	unsigned char n;
	unsigned char is_dir;
	const unsigned char *nm;

	entry_count = 0;
	ui_selected = 0;
	ui_scroll = 0;
	refresh_path();

	err = OS_OPENDIR("");
	if (err != 0)
		return 0;

	n = 0;
	for (;;)
	{
		dir_fi.lfname[0] = 0;
		err = OS_READDIR(&dir_fi);
		if (err != 0)
			break;

		if (dir_fi.fname[0] == 0)
			continue;
		if (dir_fi.fname[0] == '.' && dir_fi.fname[1] == 0)
			continue;

		is_dir = (unsigned char)((dir_fi.fattrib & ATTR_DIR) != 0);
		nm = entry_display_name(&dir_fi);
		if (!is_dir && !is_s3m_name(nm) && !is_s3m_name(dir_fi.fname))
			continue;

		if (n >= MAX_ENTRIES)
			break;

		copy_name(entries[n].name, nm, NAME_MAX);
		entries[n].is_dir = is_dir;
		entries[n].size = dir_fi.fsize;
		n++;
	}
	entry_count = n;
	need_redraw = 1;
	draw_title_bar();
	return 1;
}

/* One list row (zxdb-style). idx = entry index; only paints if visible. */
static void draw_file_row(unsigned char idx, unsigned char selected)
{
	unsigned char q;
	unsigned char i;
	unsigned char name_w;
	unsigned char row_color;

	if (idx < ui_scroll)
		return;
	q = (unsigned char)(idx - ui_scroll);
	if (q >= winPos.winH)
		return;

	if (winPos.winW > 10u)
		name_w = (unsigned char)(winPos.winW - 9u);
	else
		name_w = winPos.winW;

	OS_SETXY(winPos.winX, winPos.winY + q);
	if (idx >= entry_count)
	{
		OS_SETCOLOR(COL_LIST);
		spaces(winPos.winW);
		restore_right_border_row(winPos, q);
		return;
	}

	row_color = selected ? COL_CURSOR : COL_LIST;
	OS_SETCOLOR(row_color);
	spaces(winPos.winW);
	OS_SETXY(winPos.winX, winPos.winY + q);
	putchar(' ');
	if (entries[idx].is_dir)
	{
		printStaticStr("<DIR> ");
		put_clipped(entries[idx].name, (unsigned char)(name_w > 6u ? name_w - 6u : name_w));
	}
	else
	{
		put_clipped(entries[idx].name, name_w);
		i = 0;
		while (entries[idx].name[i] != 0 && i < name_w)
			i++;
		while (i < name_w)
		{
			putchar(' ');
			i++;
		}
		printf("%6lu", entries[idx].size);
	}
	restore_right_border_row(winPos, q);
}

static void draw_file_list(void)
{
	unsigned char q;
	unsigned char idx;

	for (q = 0; q < winPos.winH; q++)
	{
		idx = (unsigned char)(ui_scroll + q);
		if (idx < entry_count)
			draw_file_row(idx, (unsigned char)(idx == ui_selected));
		else
		{
			OS_SETCOLOR(COL_LIST);
			OS_SETXY(winPos.winX, winPos.winY + q);
			spaces(winPos.winW);
			restore_right_border_row(winPos, q);
		}
	}
}

static void on_load_progress(unsigned long done)
{
	unsigned char pct;
	unsigned char decade;
	unsigned char need;
	unsigned char bar_w;
	unsigned char filled;
	unsigned long t;

	t = ngs_load_total;
	if (t == 0)
		return;

	pct = pct_of(done, t);
	load_pct = pct;
	decade = (unsigned char)(pct / 10u);
	need = 0;

	bar_w = status_bar_w();
	filled = (unsigned char)(((unsigned int)pct * bar_w) / 100u);
	if (filled > bar_w)
		filled = bar_w;

	/* Redraw when a new cell lights up, or on decade / 100% / first paint. */
	if (filled > bar_filled)
		need = 1;
	if (done >= prog_last_done + PROG_STEP_BYTES)
		need = 1;
	if (decade != prog_last_decade)
		need = 1;
	if (pct == 100u && shown_load_pct != 100u)
		need = 1;
	if (!bar_inited)
		need = 1;

	if (need)
	{
		prog_last_done = done;
		prog_last_decade = decade;
		progress_bar_grow(pct);
	}
}

static void play_selected(void)
{
	unsigned char err;
	struct dir_entry *e;

	if (ui_selected >= entry_count)
		return;
	e = &entries[ui_selected];

	if (e->is_dir)
	{
		if (OS_CHDIR(e->name) == 0)
			(void)scan_dir();
		return;
	}

	if (is_playing || is_paused)
	{
		(void)ngs_stop_play();
		is_playing = 0;
		is_paused = 0;
	}

	copy_name(cur_file, e->name, NAME_MAX);
	memset(&mod, 0, sizeof(mod));
	mod.filesize = e->size;
	ngs_load_total = e->size;
	is_loading = 1;
	load_pct = 0;
	shown_load_pct = 255;
	prog_last_done = 0;
	prog_last_decade = 255;
	bar_inited = 0;
	bar_filled = 0;
	mark_status_dirty();
	draw_status_meta();
	progress_bar_reset();

	ngs_set_quiet(1);
	ngs_set_load_progress(on_load_progress);
	err = ngs_load_s3m(e->name, &mod);
	ngs_set_load_progress((ngs_load_progress_fn)0);
	is_loading = 0;

	if (err != 0)
	{
		mod.title[0] = 0;
		mark_status_dirty();
		draw_status();
		OS_SETCOLOR(statPos.color);
		clear_status_line(1);
		OS_SETXY(statPos.winX + 1, statPos.winY + 1);
		printf("Load failed (%u)", (unsigned int)err);
		restore_right_border_row(statPos, 1);
		return;
	}

	/* Load re-inits NeoGS if needed ? treat success as ready. */
	gs_ok = 1;

	if (!ngs_start_play(0, 0))
	{
		mark_status_dirty();
		draw_status();
		OS_SETCOLOR(statPos.color);
		clear_status_line(1);
		OS_SETXY(statPos.winX + 1, statPos.winY + 1);
		printStaticStr("Play failed");
		restore_right_border_row(statPos, 1);
		return;
	}

	is_playing = 1;
	is_paused = 0;
	play_start_tick = time();
	shown_time_sec = 0xffffu;
	mark_status_dirty();
	draw_status();
}

static void move_sel(int delta)
{
	int ns;
	unsigned char old_sel;
	unsigned char old_scroll;

	if (entry_count == 0)
		return;

	old_sel = ui_selected;
	old_scroll = ui_scroll;
	ns = (int)ui_selected + delta;
	if (ns < 0)
		ns = 0;
	if (ns >= (int)entry_count)
		ns = (int)entry_count - 1;
	if ((unsigned char)ns == old_sel)
		return;

	ui_selected = (unsigned char)ns;
	if (ui_selected < ui_scroll)
		ui_scroll = ui_selected;
	if (ui_selected >= (unsigned char)(ui_scroll + winPos.winH))
		ui_scroll = (unsigned char)(ui_selected - winPos.winH + 1);

	/* Scroll changed: full list. Else only old+new rows (like zxdb). */
	if (ui_scroll != old_scroll)
		need_redraw = 1;
	else
	{
		draw_file_row(old_sel, 0);
		draw_file_row(ui_selected, 1);
	}
}

static void handle_key(unsigned char key)
{
	if (key == 27 || key == 'q' || key == 'Q')
		quit_app();
	else if (key == KEY_UP || key == 'a' || key == 'A')
		move_sel(-1);
	else if (key == KEY_DOWN || key == 'b' || key == 'B')
		move_sel(1);
	else if (key == 13)
		play_selected();
	else if (key == 'r' || key == 'R')
		(void)scan_dir();
	else if (key == 's' || key == 'S')
	{
		(void)ngs_stop_play();
		is_playing = 0;
		is_paused = 0;
		mark_status_dirty();
		draw_status();
	}
	else if (key == 32)
	{
		if (is_playing && !is_paused)
		{
			(void)ngs_stop_play();
			is_paused = 1;
			mark_status_dirty();
			draw_status();
		}
		else if (is_paused)
		{
			(void)ngs_cont_play();
			is_paused = 0;
			is_playing = 1;
			mark_status_dirty();
			draw_status();
		}
	}
	else if (key == 31)
		draw_static_screen();
}

static void try_autostart(void)
{
	if (autostart[0] == 0)
		return;
	if (!is_s3m_name(autostart))
	{
		(void)OS_CHDIR(autostart);
		return;
	}

	copy_name(cur_file, autostart, NAME_MAX);
	memset(&mod, 0, sizeof(mod));
	/* Size filled by host via GETFILESIZE into ngs_load_total. */
	ngs_load_total = 0;
	mod.filesize = 0;
	is_loading = 1;
	load_pct = 0;
	shown_load_pct = 255;
	prog_last_done = 0;
	prog_last_decade = 255;
	bar_inited = 0;
	bar_filled = 0;
	mark_status_dirty();
	draw_status_meta();
	progress_bar_reset();
	ngs_set_quiet(1);
	ngs_set_load_progress(on_load_progress);
	if (ngs_load_s3m(autostart, &mod) == 0 && ngs_start_play(0, 0))
	{
		gs_ok = 1;
		is_playing = 1;
		is_paused = 0;
		play_start_tick = time();
		shown_time_sec = 0xffffu;
	}
	ngs_set_load_progress((ngs_load_progress_fn)0);
	is_loading = 0;
	mark_status_dirty();
	draw_status();
}

static void run_ui(void)
{
	unsigned char key;
	unsigned int poll;
	unsigned char st;

	poll = 0;
	draw_static_screen();

	/*
	 * Do not bootstrap NeoGS here ? first attempt often races after SETGFX
	 * and shows a false "init failed". ngs_load_s3m() inits on first play.
	 */
	mark_status_dirty();
	draw_status();

	try_autostart();
	(void)scan_dir();
	need_redraw = 1;

	for (;;)
	{
		if (need_redraw)
		{
			draw_file_list();
			need_redraw = 0;
		}

		/* OS_GETKEY returns long; key code is low byte (see nc/cdplay). */
		key = (unsigned char)OS_GETKEY();
		if (key != 0)
			handle_key(key);

		poll++;
		if ((poll & 31u) == 0 && is_playing && !is_paused && gs_ok)
		{
			st = ngs_status_play();
			if (st == 0)
			{
				is_playing = 0;
				is_paused = 0;
				mark_status_dirty();
				draw_status();
			}
			else
				update_status_bottom_if_needed();
		}
		else if (status_dirty)
			draw_status();
		else if ((poll & 31u) == 0)
			update_status_bottom_if_needed();

		YIELD();
	}
}

C_task main(int argc, char *argv[])
{
	unsigned char i;
	unsigned char c;

	os_initstdio();
	OS_HIDEFROMPARENT();
	OS_SETGFX(0x86);
	OS_CLS(0);
	YIELD();

	/* Even 1-row gaps: title | list | status | hint */
	winPos.winX = 13;
	winPos.winY = 3;
	winPos.winW = 48;
	winPos.winH = 11;
	winPos.color = COL_LIST;

	/* list frame bottom @14; black @15; status frame top @16, content @17 */
	statPos.winX = 4;
	statPos.winY = 17;
	statPos.winW = 70;
	statPos.winH = 4;
	statPos.color = COL_STAT;

	mod.title[0] = 0;
	cur_file[0] = 0;
	path_buf[0] = 0;
	autostart[0] = 0;
	gs_ok = 0;
	is_playing = 0;
	is_paused = 0;
	is_loading = 0;
	status_dirty = 1;
	shown_load_pct = 255;
	shown_time_sec = 0xffffu;

	if (argc >= 2)
	{
		for (i = 0; i < 127u; i++)
		{
			c = (unsigned char)argv[1][i];
			autostart[i] = c;
			if (c == 0)
				break;
		}
		autostart[127] = 0;
	}

	run_ui();
	quit_app();
	return 0;
}
