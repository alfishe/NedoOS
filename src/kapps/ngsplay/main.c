/*
 * ngsplay ? NeoGS 8-channel S3M player for NedoOS
 * Main 0100-BFFF: browser paint, scan/sort, S3M load.
 * C000: CODE_RESIDENT chrome + list data pages + IOBUF during load.
 *
 * Keys: Up/Down browse, Enter open/play, Space pause, S stop, R refresh, Esc/Q quit
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include "ngsplay.h"
#include "app_bank.h"
#include "ngs_plug.h"
#include "ui_mouse.h"

#define ATTR_DIR 0x10

unsigned char residentPg;
unsigned char list_pg[NGS_LIST_PAGES];
union APP_PAGES main_pg;

struct coordinates winPos;
struct coordinates statPos;
struct coordinates btnPos;
unsigned int entry_count;
unsigned int ui_selected;
unsigned int ui_scroll;
unsigned char need_redraw;
unsigned char status_dirty;

unsigned char is_playing;
unsigned char is_paused;
unsigned char is_loading;
static unsigned char gs_ok;
static unsigned char play_kind; /* 0=none 1=s3m 2=mp3 3=mod */

ngs_mod_info mod;
unsigned char cur_file[NGS_NAME_LEN];
unsigned char path_buf[80];
static fileInfo dir_fi;

long play_start_tick;
unsigned char load_pct;
static unsigned char shown_load_pct;
unsigned int shown_time_sec;
static unsigned long prog_last_done;
static unsigned char prog_last_decade;
unsigned char bar_filled;
unsigned char bar_inited;
static unsigned char autostart[128];

/* Display order ? physical slot on list pages. */
static unsigned short sort_idx[NGS_MAX_ENTRIES];

#define KEY_UP 250
#define KEY_DOWN 249
#define PROG_STEP_BYTES 65536UL

void ui_resident_map(void)
{
	bank_window_map(residentPg);
}

void ngs_init_banks(void)
{
	main_pg.l = OS_GETMAINPAGES();
	residentPg = main_pg.pgs.window_3;
	bank_slot_set(NGS_BANK_SLOT_RESIDENT, residentPg);
	list_pg[0] = 0;
	list_pg[1] = 0;
	if (!bank_os_new_page(&list_pg[0]) || list_pg[0] == residentPg)
		list_pg[0] = 0;
	if (!bank_os_new_page(&list_pg[1]) || list_pg[1] == residentPg)
		list_pg[1] = 0;
	bank_slot_set(NGS_BANK_SLOT_LIST0, list_pg[0]);
	bank_slot_set(NGS_BANK_SLOT_LIST1, list_pg[1]);
	ui_resident_map();
}

static void ngs_free_list_pages(void)
{
	if (list_pg[0] != 0)
	{
		bank_os_release_page(list_pg[0]);
		list_pg[0] = 0;
	}
	if (list_pg[1] != 0)
	{
		bank_os_release_page(list_pg[1]);
		list_pg[1] = 0;
	}
}

/* Buttons live in low CODE ? safe vs C000 banking. */
static void print_centered(const char *s, unsigned char width)
{
	unsigned char len;
	unsigned char left;
	unsigned char i;

	len = 0;
	while (s[len] != 0)
		len++;
	if (len > width)
		len = width;
	left = (unsigned char)((width - len) / 2u);
	for (i = 0; i < left; i++)
		putchar(' ');
	for (i = 0; i < len; i++)
		putchar(s[i]);
	for (i = (unsigned char)(left + len); i < width; i++)
		putchar(' ');
}

static void draw_one_btn(unsigned char x, unsigned char y, unsigned char label)
{
	unsigned char i;

	/* No OS_SETCOLOR here; no (y+n) in OS_SETXY args ? IAR register spill rake. */
	OS_SETXY(x, y);
	putchar(218);
	for (i = 0; i < (BTN_W - 2u); i++)
		putchar(196);
	putchar(191);
	// y++;
	OS_SETXY(x, y + 1);
	putchar(179);
	putchar(' ');
	putchar(label);
	putchar(' ');
	putchar(179);
	// y++;
	OS_SETXY(x, y + 2);
	putchar(192);
	for (i = 0; i < (BTN_W - 2u); i++)
		putchar(196);
	putchar(217);
}

void ui_draw_stat_buttons(void)
{
	unsigned char x0;
	unsigned char x1;
	unsigned char y0;
	unsigned char y1;

	x0 = btnPos.winX;
	x1 = btnPos.winX + BTN_W + BTN_GAP;
	y0 = btnPos.winY;
	y1 = btnPos.winY + BTN_H;

	OS_SETCOLOR(btnPos.color);
	draw_one_btn(x0, y0, 17);  // Prev
	draw_one_btn(x1, y0, 16);  // Next
	draw_one_btn(x0, y1, 219); // Stop
	draw_one_btn(x1, y1, 186); // Pause
}

void ui_draw_static_chrome(void)
{
	/* CLS from low memory ? never call BDOS page-sensitive ops from CODE_RESIDENT. */
	OS_CLS(0);
	ui_resident_map();
	r_draw_static_chrome();
	ui_draw_stat_buttons();
}

void ui_draw_title_bar(void)
{
	ui_resident_map();
	r_draw_title_bar();
}

void ui_draw_status(void)
{
	ui_resident_map();
	r_draw_status();
	ui_draw_stat_buttons();
	status_dirty = 0;
}

void ui_draw_status_meta(void)
{
	ui_resident_map();
	r_draw_status_meta();
	ui_draw_stat_buttons();
}

void ui_draw_status_bottom(void)
{
	ui_resident_map();
	r_draw_status_bottom();
	ui_draw_stat_buttons();
}

void ui_progress_bar_reset(void)
{
	ui_resident_map();
	r_progress_bar_reset();
	shown_load_pct = 0;
}

void ui_progress_bar_grow(unsigned char pct)
{
	ui_resident_map();
	r_progress_bar_grow(pct);
	shown_load_pct = pct;
}

static unsigned char pct_of(unsigned long done, unsigned long total)
{
	unsigned int d;
	unsigned int t;
	unsigned int p;

	if (total == 0)
		return 0;
	if (done >= total)
		return 100;
	d = (unsigned int)(done >> 8);
	t = (unsigned int)(total >> 8);
	if (t == 0)
		t = 1;
	p = (unsigned int)(((unsigned long)d * 100u) / t);
	if (p > 100u)
		p = 100;
	return (unsigned char)p;
}

static void stop_current(void)
{
	if (play_kind == 2)
		ngs_mp3_stop();
	else if (play_kind == 3)
		ngs_mod_stop();
	else if (play_kind == 1)
		(void)ngs_stop_play();
	is_playing = 0;
	is_paused = 0;
	play_kind = 0;
}

static void quit_app(void)
{
	stop_current();
	ngs_free_list_pages();
	ui_resident_map();
	OS_SETGFX(0x86);
	exit(0);
}

static void mark_status_dirty(void)
{
	status_dirty = 1;
}

static void refresh_path(void)
{
	unsigned char i;

	for (i = 0; i < 79u; i++)
		path_buf[i] = 0;
	(void)OS_GETPATH(path_buf);
	path_buf[79] = 0;
}

static void store_name64(unsigned char *dst, const unsigned char *src)
{
	unsigned char i;

	for (i = 0; i < NGS_NAME_LEN; i++)
	{
		if (src[i] == 0)
		{
			for (; i < NGS_NAME_LEN; i++)
				dst[i] = 0;
			return;
		}
		dst[i] = src[i];
	}
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

static unsigned char is_s3m_name(const unsigned char *name)
{
	unsigned char i;
	unsigned char dot;
	unsigned char c;

	dot = 255;
	for (i = 0; i < NGS_NAME_LEN && name[i] != 0; i++)
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
	if ((c == 'M' || c == 'm') && (dot + 4 >= NGS_NAME_LEN || name[dot + 4] == 0))
		return 1;
	return 0;
}

static unsigned char is_mp3_name(const unsigned char *name)
{
	unsigned char i;
	unsigned char dot;
	unsigned char a;
	unsigned char b;
	unsigned char c;

	dot = 255;
	for (i = 0; i < NGS_NAME_LEN && name[i] != 0; i++)
	{
		if (name[i] == '.')
			dot = i;
	}
	if (dot == 255 || name[dot + 1] == 0)
		return 0;
	a = name[dot + 1];
	b = name[dot + 2];
	c = name[dot + 3];
	/* .mp3 */
	if ((a == 'M' || a == 'm') && (b == 'P' || b == 'p') && (c == '3') &&
		(dot + 4 >= NGS_NAME_LEN || name[dot + 4] == 0))
		return 1;
	/* .ogg (VS1053+) ? still attempt; codec may reject */
	if ((a == 'O' || a == 'o') && (b == 'G' || b == 'g') && (c == 'G' || c == 'g') &&
		(dot + 4 >= NGS_NAME_LEN || name[dot + 4] == 0))
		return 1;
	return 0;
}

static unsigned char is_mod_name(const unsigned char *name)
{
	unsigned char i;
	unsigned char dot;
	unsigned char a;
	unsigned char b;
	unsigned char c;

	dot = 255;
	for (i = 0; i < NGS_NAME_LEN && name[i] != 0; i++)
	{
		if (name[i] == '.')
			dot = i;
	}
	if (dot == 255 || name[dot + 1] == 0)
		return 0;
	a = name[dot + 1];
	b = name[dot + 2];
	c = name[dot + 3];
	if ((a == 'M' || a == 'm') && (b == 'O' || b == 'o') && (c == 'D' || c == 'd') &&
		(dot + 4 >= NGS_NAME_LEN || name[dot + 4] == 0))
		return 1;
	return 0;
}

static unsigned char is_playable_name(const unsigned char *name)
{
	return (unsigned char)(is_s3m_name(name) || is_mp3_name(name) || is_mod_name(name));
}

static const unsigned char *entry_display_name(fileInfo *fi)
{
	if (fi->lfname[0] != 0)
		return fi->lfname;
	return fi->fname;
}

static unsigned char list_page_of(unsigned int phys)
{
	return list_pg[phys / NGS_ENT_PER_PAGE];
}

static unsigned int list_off_of(unsigned int phys)
{
	return (unsigned int)((phys % NGS_ENT_PER_PAGE) * NGS_FENT_SIZE);
}

static ngs_fent *list_ptr_mapped(unsigned int phys)
{
	return (ngs_fent *)(BANK_WINDOW_ADDR + list_off_of(phys));
}

static void list_write_phys(unsigned int phys, const ngs_fent *e)
{
	unsigned char saved;
	ngs_fent *p;

	saved = bank_push(list_page_of(phys));
	p = list_ptr_mapped(phys);
	memcpy(p, e, NGS_FENT_SIZE);
	bank_pop(saved);
}

static void list_read_phys(unsigned int phys, ngs_fent *e)
{
	unsigned char saved;
	ngs_fent *p;

	saved = bank_push(list_page_of(phys));
	p = list_ptr_mapped(phys);
	memcpy(e, p, NGS_FENT_SIZE);
	bank_pop(saved);
}

static unsigned int vis_to_phys(unsigned int vis)
{
	if (vis >= entry_count)
		return 0;
	return (unsigned int)sort_idx[vis];
}

static unsigned char upcase(unsigned char c)
{
	if (c >= 'a' && c <= 'z')
		return (unsigned char)(c - 32u);
	return c;
}

/* dirs first, then case-insensitive name; ".." before other dirs */
static int ent_cmp_phys(unsigned int pa, unsigned int pb)
{
	ngs_fent a;
	ngs_fent b;
	unsigned char da;
	unsigned char db;
	unsigned char i;
	unsigned char ca;
	unsigned char cb;
	unsigned char a_dot;
	unsigned char b_dot;

	list_read_phys(pa, &a);
	list_read_phys(pb, &b);
	da = (unsigned char)((a.flags & NGS_FENT_DIR) != 0);
	db = (unsigned char)((b.flags & NGS_FENT_DIR) != 0);
	if (da != db)
		return da ? -1 : 1;

	a_dot = (unsigned char)(a.name[0] == '.' && a.name[1] == '.' && a.name[2] == 0);
	b_dot = (unsigned char)(b.name[0] == '.' && b.name[1] == '.' && b.name[2] == 0);
	if (a_dot != b_dot)
		return a_dot ? -1 : 1;

	for (i = 0; i < NGS_NAME_LEN; i++)
	{
		ca = upcase(a.name[i]);
		cb = upcase(b.name[i]);
		if (ca != cb)
			return (ca < cb) ? -1 : 1;
		if (ca == 0)
			return 0;
	}
	return 0;
}

static int ent_cmp_vis(unsigned int va, unsigned int vb)
{
	return ent_cmp_phys((unsigned int)sort_idx[va], (unsigned int)sort_idx[vb]);
}

static void heap_sift(unsigned int heap_size, unsigned int root)
{
	unsigned int largest;
	unsigned int left;
	unsigned int right;
	unsigned short t;

	for (;;)
	{
		largest = root;
		left = root * 2u + 1u;
		right = left + 1u;
		if (left < heap_size && ent_cmp_vis(left, largest) > 0)
			largest = left;
		if (right < heap_size && ent_cmp_vis(right, largest) > 0)
			largest = right;
		if (largest == root)
			break;
		t = sort_idx[root];
		sort_idx[root] = sort_idx[largest];
		sort_idx[largest] = t;
		root = largest;
	}
}

static void heap_sort_entries(void)
{
	unsigned int n;
	unsigned int i;
	unsigned short t;

	n = entry_count;
	if (n < 2u)
		return;

	for (i = n / 2u; i > 0u; i--)
		heap_sift(n, i - 1u);

	for (i = n; i > 1u; i--)
	{
		t = sort_idx[0];
		sort_idx[0] = sort_idx[i - 1u];
		sort_idx[i - 1u] = t;
		heap_sift(i - 1u, 0u);
	}
}

static unsigned char scan_dir(void)
{
	unsigned char err;
	unsigned int n;
	unsigned char is_dir;
	const unsigned char *nm;
	ngs_fent ent;

	entry_count = 0;
	ui_selected = 0;
	ui_scroll = 0;
	refresh_path();

	if (list_pg[0] == 0 || list_pg[1] == 0)
		return 0;

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
		if (!is_dir && !is_playable_name(nm) && !is_playable_name(dir_fi.fname))
			continue;

		if (n >= NGS_MAX_ENTRIES)
			break;

		memset(&ent, 0, sizeof(ent));
		store_name64(ent.name, nm);
		ent.size = dir_fi.fsize;
		ent.flags = is_dir ? NGS_FENT_DIR : 0;
		list_write_phys(n, &ent);
		sort_idx[n] = (unsigned short)n;
		n++;
	}
	entry_count = n;
	heap_sort_entries();
	need_redraw = 1;
	ui_draw_title_bar();
	ui_resident_map();
	return 1;
}

/* idx = visible (sorted) index. Maps list page for the read. */
static void draw_file_row(unsigned int vis, unsigned char selected)
{
	unsigned char q;
	unsigned char i;
	unsigned char name_w;
	unsigned char row_color;
	unsigned int phys;
	unsigned char saved;
	ngs_fent *e;

	if (vis < ui_scroll)
		return;
	q = (unsigned char)(vis - ui_scroll);
	if (q >= winPos.winH)
		return;

	if (winPos.winW > 10u)
		name_w = (unsigned char)(winPos.winW - 9u);
	else
		name_w = winPos.winW;

	OS_SETXY(winPos.winX, winPos.winY + q);
	if (vis >= entry_count)
	{
		OS_SETCOLOR(COL_LIST);
		i = winPos.winW;
		while (i--)
			putchar(' ');
		ui_resident_map();
		r_restore_right_border_row(winPos, q);
		return;
	}

	phys = vis_to_phys(vis);
	saved = bank_push(list_page_of(phys));
	e = list_ptr_mapped(phys);

	row_color = selected ? COL_CURSOR : COL_LIST;
	OS_SETCOLOR(row_color);
	i = winPos.winW;
	while (i--)
		putchar(' ');
	OS_SETXY(winPos.winX, winPos.winY + q);
	putchar(' ');
	if (e->flags & NGS_FENT_DIR)
	{
		printf("<DIR> ");
		{
			unsigned char maxn;
			maxn = (unsigned char)(name_w > 6u ? name_w - 6u : name_w);
			for (i = 0; i < maxn && e->name[i] != 0; i++)
				putchar(e->name[i]);
		}
	}
	else
	{
		for (i = 0; i < name_w && e->name[i] != 0; i++)
			putchar(e->name[i]);
		while (i < name_w)
		{
			putchar(' ');
			i++;
		}
		printf("%6lu", e->size);
	}
	bank_pop(saved);
	ui_resident_map();
	r_restore_right_border_row(winPos, q);
}

static void draw_file_list(void)
{
	unsigned char q;
	unsigned int vis;

	for (q = 0; q < winPos.winH; q++)
	{
		vis = ui_scroll + (unsigned int)q;
		if (vis < entry_count)
			draw_file_row(vis, (unsigned char)(vis == ui_selected));
		else
		{
			OS_SETCOLOR(COL_LIST);
			OS_SETXY(winPos.winX, winPos.winY + q);
			{
				unsigned char i;
				i = winPos.winW;
				while (i--)
					putchar(' ');
			}
			ui_resident_map();
			r_restore_right_border_row(winPos, q);
		}
	}
	ui_resident_map();
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

	/* Status chrome may be resident; progress uses low callback + remaps. */
	bar_w = (statPos.winW > 14u) ? (unsigned char)(statPos.winW - 14u) : 8;
	filled = (unsigned char)(((unsigned int)pct * bar_w) / 100u);
	if (filled > bar_w)
		filled = bar_w;

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
		/* During load C000=IOBUF ? grow bar via direct console (no r_*). */
		{
			unsigned char x;
			unsigned char y;
			unsigned char i;
			unsigned char bf;

			x = (unsigned char)(statPos.winX + 1);
			y = (unsigned char)(statPos.winY + statPos.winH - 1u);
			OS_SETCOLOR(statPos.color);
			if (!bar_inited)
			{
				OS_SETXY(statPos.winX, y);
				i = statPos.winW;
				while (i--)
					putchar(' ');
				OS_SETXY(x, y);
				putchar('[');
				for (i = 0; i < bar_w; i++)
					putchar('.');
				putchar(']');
				printf("%3u%%", 0u);
				bar_filled = 0;
				bar_inited = 1;
			}
			bf = bar_filled;
			if (filled > bf)
			{
				OS_SETXY((unsigned char)(x + 1u + bf), y);
				for (i = bf; i < filled; i++)
					putchar(219);
				bar_filled = filled;
			}
			OS_SETXY((unsigned char)(x + bar_w + 2u), y);
			printf("%3u%%", (unsigned int)pct);
			shown_load_pct = pct;
		}
	}
}

static void after_load_restore_ui(void)
{
	ui_resident_map();
	need_redraw = 1;
}

static void play_selected(void)
{
	unsigned char err;
	ngs_fent e;
	unsigned int phys;
	unsigned char namebuf[NGS_NAME_LEN];

	if (ui_selected >= entry_count)
		return;

	phys = vis_to_phys(ui_selected);
	list_read_phys(phys, &e);
	store_name64(namebuf, e.name);

	if (e.flags & NGS_FENT_DIR)
	{
		if (OS_CHDIR(namebuf) == 0)
			(void)scan_dir();
		return;
	}

	if (is_playing || is_paused || play_kind != 0)
		stop_current();

	copy_name(cur_file, namebuf, NGS_NAME_LEN);
	memset(&mod, 0, sizeof(mod));
	mod.filesize = e.size;

	if (is_mp3_name(namebuf))
	{
		gs_ok = 0;
		is_loading = 1;
		mark_status_dirty();
		ui_draw_status_meta();
		ui_resident_map();
		err = ngs_mp3_start(namebuf, e.size);

		is_loading = 0;
		after_load_restore_ui();
		if (err != 0)
		{
			mod.title[0] = 0;
			mark_status_dirty();
			ui_draw_status();
			ui_resident_map();
			OS_SETCOLOR(statPos.color);
			r_clear_status_line(1);
			OS_SETXY(statPos.winX + 1, statPos.winY + 1);
			printf("MP3 failed (%u)", (unsigned int)err);
			r_restore_right_border_row(statPos, 1);
			return;
		}
		copy_name(mod.title, namebuf, 28);
		play_kind = 2;
		is_playing = 1;
		is_paused = 0;
		play_start_tick = time();
		shown_time_sec = 0xffffu;
		mark_status_dirty();
		ui_draw_status();
		return;
	}

	if (is_mod_name(namebuf))
	{
		gs_ok = 0;
		is_loading = 1;
		load_pct = 0;
		shown_load_pct = 255;
		prog_last_done = 0;
		prog_last_decade = 255;
		bar_inited = 0;
		bar_filled = 0;
		ngs_load_total = e.size;
		mark_status_dirty();
		ui_draw_status_meta();
		ui_progress_bar_reset();
		ui_resident_map();
		ngs_set_load_progress(on_load_progress);
		err = ngs_mod_start(namebuf, e.size, &mod);
		ngs_set_load_progress((ngs_load_progress_fn)0);
		is_loading = 0;
		after_load_restore_ui();
		if (err != 0)
		{
			mod.title[0] = 0;
			mark_status_dirty();
			ui_draw_status();
			ui_resident_map();
			OS_SETCOLOR(statPos.color);
			r_clear_status_line(1);
			OS_SETXY(statPos.winX + 1, statPos.winY + 1);
			printf("MOD failed (%u)", (unsigned int)err);
			r_restore_right_border_row(statPos, 1);
			return;
		}
		play_kind = 3;
		is_playing = 1;
		is_paused = 0;
		play_start_tick = time();
		shown_time_sec = 0xffffu;
		mark_status_dirty();
		ui_draw_status();
		return;
	}

	ngs_load_total = e.size;
	is_loading = 1;
	load_pct = 0;
	shown_load_pct = 255;
	prog_last_done = 0;
	prog_last_decade = 255;
	bar_inited = 0;
	bar_filled = 0;
	mark_status_dirty();
	ui_draw_status_meta();
	ui_progress_bar_reset();

	/* Map resident so free_iobuf restores COM page, not a list page. */
	ui_resident_map();
	ngs_set_quiet(1);
	ngs_set_load_progress(on_load_progress);
	err = ngs_load_s3m(namebuf, &mod);
	ngs_set_load_progress((ngs_load_progress_fn)0);
	is_loading = 0;
	after_load_restore_ui();

	if (err != 0)
	{
		mod.title[0] = 0;
		mark_status_dirty();
		ui_draw_status();
		ui_resident_map();
		OS_SETCOLOR(statPos.color);
		r_clear_status_line(1);
		OS_SETXY(statPos.winX + 1, statPos.winY + 1);
		printf("Load failed (%u)", (unsigned int)err);
		r_restore_right_border_row(statPos, 1);
		return;
	}

	gs_ok = 1;
	play_kind = 1;

	if (!ngs_start_play(0, 0))
	{
		play_kind = 0;
		mark_status_dirty();
		ui_draw_status();
		ui_resident_map();
		OS_SETCOLOR(statPos.color);
		r_clear_status_line(1);
		OS_SETXY(statPos.winX + 1, statPos.winY + 1);
		r_print_static("Play failed");
		r_restore_right_border_row(statPos, 1);
		return;
	}

	is_playing = 1;
	is_paused = 0;
	play_start_tick = time();
	shown_time_sec = 0xffffu;
	mark_status_dirty();
	ui_draw_status();
}

static void ensure_sel_visible(void)
{
	if (ui_selected < ui_scroll)
		ui_scroll = ui_selected;
	if (ui_selected >= ui_scroll + (unsigned int)winPos.winH)
		ui_scroll = ui_selected - (unsigned int)winPos.winH + 1u;
	need_redraw = 1;
}

static unsigned char names_equal64(const unsigned char *a, const unsigned char *b)
{
	unsigned char i;

	for (i = 0; i < NGS_NAME_LEN; i++)
	{
		if (a[i] != b[i])
			return 0;
		if (a[i] == 0)
			return 1;
	}
	return 1;
}

/* Sync cursor to currently playing file name (after scan/autostart). */
static void select_by_name(const unsigned char *name)
{
	unsigned int i;
	ngs_fent e;

	for (i = 0; i < entry_count; i++)
	{
		list_read_phys(vis_to_phys(i), &e);
		if (names_equal64(e.name, name))
		{
			ui_selected = i;
			ensure_sel_visible();
			return;
		}
	}
}

static unsigned char select_next_s3m(void)
{
	unsigned int i;
	ngs_fent e;

	for (i = ui_selected + 1u; i < entry_count; i++)
	{
		list_read_phys(vis_to_phys(i), &e);
		if ((e.flags & NGS_FENT_DIR) == 0 && is_playable_name(e.name))
		{
			ui_selected = i;
			ensure_sel_visible();
			return 1;
		}
	}
	return 0;
}

static unsigned char select_prev_s3m(void)
{
	unsigned int i;
	ngs_fent e;

	if (ui_selected == 0)
		return 0;
	i = ui_selected;
	do
	{
		i--;
		list_read_phys(vis_to_phys(i), &e);
		if ((e.flags & NGS_FENT_DIR) == 0 && is_playable_name(e.name))
		{
			ui_selected = i;
			ensure_sel_visible();
			return 1;
		}
	} while (i != 0);
	return 0;
}

static void move_sel(int delta)
{
	int ns;
	unsigned int old_sel;
	unsigned int old_scroll;

	if (entry_count == 0)
		return;

	old_sel = ui_selected;
	old_scroll = ui_scroll;
	ns = (int)ui_selected + delta;
	if (ns < 0)
		ns = 0;
	if (ns >= (int)entry_count)
		ns = (int)entry_count - 1;
	if ((unsigned int)ns == old_sel)
		return;

	ui_selected = (unsigned int)ns;
	if (ui_selected < ui_scroll)
		ui_scroll = ui_selected;
	if (ui_selected >= ui_scroll + (unsigned int)winPos.winH)
		ui_scroll = ui_selected - (unsigned int)winPos.winH + 1u;

	ui_mouse_hide();
	if (ui_scroll != old_scroll)
		need_redraw = 1;
	else
	{
		draw_file_row(old_sel, 0);
		draw_file_row(ui_selected, 1);
	}
	ui_mouse_show();
}

static void handle_key(unsigned char key);

static void handle_mouse(void)
{
	signed char w;
	unsigned char hit;
	unsigned int idx;
	unsigned int old_sel;
	unsigned int old_scroll;

	w = ui_mouse_wheel_delta();
	if (w > 0)
		move_sel(1);
	else if (w < 0)
		move_sel(-1);

	if (!ui_mouse_lmb_click())
		return;

	hit = ui_mouse_hit();
	if (hit == UI_MOUSE_HIT_BTN0)
	{
		if (select_prev_s3m())
			play_selected();
	}
	else if (hit == UI_MOUSE_HIT_BTN1)
	{
		if (select_next_s3m())
			play_selected();
	}
	else if (hit == UI_MOUSE_HIT_BTN2)
	{
		stop_current();
		mark_status_dirty();
		ui_mouse_hide();
		ui_draw_status();
		ui_mouse_show();
	}
	else if (hit == UI_MOUSE_HIT_BTN3)
	{
		handle_key(32);
	}
	else if (hit == UI_MOUSE_HIT_LIST)
	{
		idx = ui_scroll + (unsigned int)ui_mouse_list_row();
		if (idx >= entry_count)
			return;
		if (idx == ui_selected)
		{
			play_selected();
			return;
		}
		old_sel = ui_selected;
		old_scroll = ui_scroll;
		ui_selected = idx;
		ensure_sel_visible();
		ui_mouse_hide();
		if (ui_scroll != old_scroll)
			need_redraw = 1;
		else
		{
			draw_file_row(old_sel, 0);
			draw_file_row(ui_selected, 1);
		}
		ui_mouse_show();
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
	else if (key == 'n' || key == 'N')
	{
		if (select_next_s3m())
			play_selected();
	}
	else if (key == 's' || key == 'S')
	{
		stop_current();
		mark_status_dirty();
		ui_mouse_hide();
		ui_draw_status();
		ui_mouse_show();
	}
	else if (key == 32)
	{
		if (is_playing && !is_paused)
		{
			if (play_kind == 1)
				(void)ngs_stop_play();
			/* MP3/MOD: pause = freeze UI; MP3 stops feed, MOD keeps sounding. */
			is_paused = 1;
			mark_status_dirty();
			ui_mouse_hide();
			ui_draw_status();
			ui_mouse_show();
		}
		else if (is_paused)
		{
			if (play_kind == 1)
				(void)ngs_cont_play();
			is_paused = 0;
			is_playing = 1;
			mark_status_dirty();
			ui_mouse_hide();
			ui_draw_status();
			ui_mouse_show();
		}
	}
	else if (key == 31)
	{
		ui_mouse_hide();
		ui_draw_static_chrome();
		need_redraw = 1;
		ui_mouse_show();
	}
}

static void try_autostart(void)
{
	if (autostart[0] == 0)
		return;
	if (!is_playable_name(autostart))
	{
		(void)OS_CHDIR(autostart);
		return;
	}

	copy_name(cur_file, autostart, NGS_NAME_LEN);
	memset(&mod, 0, sizeof(mod));

	if (is_mp3_name(autostart))
	{
		gs_ok = 0;
		is_loading = 1;
		mark_status_dirty();
		ui_draw_status_meta();
		ui_resident_map();
		if (ngs_mp3_start(autostart, 0) == 0)
		{
			copy_name(mod.title, autostart, 28);
			play_kind = 2;
			is_playing = 1;
			is_paused = 0;
			play_start_tick = time();
			shown_time_sec = 0xffffu;
		}
		is_loading = 0;
		after_load_restore_ui();
		mark_status_dirty();
		ui_draw_status();
		return;
	}

	if (is_mod_name(autostart))
	{
		gs_ok = 0;
		is_loading = 1;
		load_pct = 0;
		ngs_load_total = 0;
		mark_status_dirty();
		ui_draw_status_meta();
		ui_progress_bar_reset();
		ui_resident_map();
		ngs_set_load_progress(on_load_progress);
		if (ngs_mod_start(autostart, 0, &mod) == 0)
		{
			play_kind = 3;
			is_playing = 1;
			is_paused = 0;
			play_start_tick = time();
			shown_time_sec = 0xffffu;
		}
		ngs_set_load_progress((ngs_load_progress_fn)0);
		is_loading = 0;
		after_load_restore_ui();
		mark_status_dirty();
		ui_draw_status();
		return;
	}

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
	ui_draw_status_meta();
	ui_progress_bar_reset();
	ui_resident_map();
	ngs_set_quiet(1);
	ngs_set_load_progress(on_load_progress);
	if (ngs_load_s3m(autostart, &mod) == 0 && ngs_start_play(0, 0))
	{
		gs_ok = 1;
		play_kind = 1;
		is_playing = 1;
		is_paused = 0;
		play_start_tick = time();
		shown_time_sec = 0xffffu;
	}
	ngs_set_load_progress((ngs_load_progress_fn)0);
	is_loading = 0;
	after_load_restore_ui();
	mark_status_dirty();
	ui_draw_status();
}

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
		{
			ui_mouse_hide();
			ui_draw_status_bottom();
			ui_mouse_show();
		}
	}
}

static void run_ui(void)
{
	unsigned char key;
	unsigned int poll;
	unsigned char st;
	signed long gk;

	poll = 0;
	ui_draw_static_chrome();
	ui_mouse_init();
	mark_status_dirty();
	ui_draw_status();
	ui_mouse_show();

	try_autostart();
	(void)scan_dir();
	if (cur_file[0] != 0)
		select_by_name(cur_file);
	need_redraw = 1;

	for (;;)
	{
		if (need_redraw)
		{
			ui_mouse_hide();
			draw_file_list();
			need_redraw = 0;
			ui_mouse_show();
		}

		gk = OS_GETKEY();
		if (((unsigned long)gk & 0x80000000UL) != 0UL)
		{
			/* No focus: OS zeroes mouse; do not drive the soft cursor. */
			ui_mouse_hide();
		}
		else
		{
			key = (unsigned char)gk;
			if (key != 0)
			{
				ui_mouse_hide();
				handle_key(key);
				ui_mouse_show();
			}
			ui_mouse_poll();
			handle_mouse();
		}

		poll++;
		if (play_kind == 2 && is_playing && !is_paused)
		{

			if (!ngs_mp3_pump())
			{
				is_playing = 0;
				is_paused = 0;
				play_kind = 0;
				if (select_next_s3m())
					play_selected();
				else
				{
					mark_status_dirty();
					ui_mouse_hide();
					ui_draw_status();
					ui_mouse_show();
				}
			}
			else
				update_status_bottom_if_needed();
		}
		else if ((poll & 31u) == 0 && play_kind == 3 && is_playing && !is_paused)
		{
			if (!ngs_mod_pump())
			{
				is_playing = 0;
				is_paused = 0;
				play_kind = 0;
				if (select_next_s3m())
					play_selected();
				else
				{
					mark_status_dirty();
					ui_mouse_hide();
					ui_draw_status();
					ui_mouse_show();
				}
			}
			else
				update_status_bottom_if_needed();
		}
		else if ((poll & 31u) == 0 && play_kind == 1 && is_playing && !is_paused && gs_ok)
		{
			st = ngs_status_play();
			if (st == 0)
			{
				is_playing = 0;
				is_paused = 0;
				play_kind = 0;
				if (select_next_s3m())
				{
					/* Auto-advance to next playable in the list. */
					play_selected();
				}
				else
				{
					mark_status_dirty();
					ui_mouse_hide();
					ui_draw_status();
					ui_mouse_show();
				}
			}
			else
				update_status_bottom_if_needed();
		}
		else if (status_dirty)
		{
			ui_mouse_hide();
			ui_draw_status();
			ui_mouse_show();
		}
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

	ngs_init_banks();

	winPos.winX = 14;
	winPos.winY = 3;
	winPos.winW = 48;
	winPos.winH = 11;
	winPos.color = COL_LIST;

	/* Outer frame = 6 rows: border@16 + content H=4 + border@21. */
	statPos.winX = 4;
	statPos.winY = 17;
	statPos.winW = 58;
	statPos.winH = 4;
	statPos.color = COL_STAT;

	/* 2x3 buttons cover the same 6 rows as the status outer frame. */
	btnPos.winX = (unsigned char)(statPos.winX + statPos.winW + 4u);
	btnPos.winY = (unsigned char)(statPos.winY - 1u);
	btnPos.winW = BTN_PANEL_W;
	btnPos.winH = 6;
	btnPos.color = COL_BTN;

	mod.title[0] = 0;
	cur_file[0] = 0;
	path_buf[0] = 0;
	autostart[0] = 0;
	gs_ok = 0;
	play_kind = 0;
	is_playing = 0;
	is_paused = 0;
	is_loading = 0;
	status_dirty = 1;
	shown_load_pct = 255;
	shown_time_sec = 0xffffu;
	entry_count = 0;
	ui_selected = 0;
	ui_scroll = 0;

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
