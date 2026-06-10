#include "nc_inc.h"
#include "nc_plug.h"

/*
 * NC ? ?????? ????? ? ????? (16 KB = 0x4000 ?? ??????).
 *
 * === ?????? ?????? OS (OS_NEWPAGE), 8 ??. ===
 *   left_panel.bank_ids[0..3]  ? ????? ??????
 *   right_panel.bank_ids[0..3] ? ???? ??????
 *   [0..2]  file pages: ?? 180 fileInfo ?? ?????? (540 ???? ?? ??????)
 *   [3]     meta page:    ???????/???? ?????? + nv.ext ? ???
 *
 *   ?????? (?? ?? ??? copy), ??? 4 ?????? OS_NEWPAGE:
 *   g_copy_temp_page  ? ????? copy-cache (map ? 0xC000)
 *   g_copy_snap_page  ? ???? ??? ??? ???? (SETPG32KHIGH(g_copy_snap_page))
 *   g_copy_io_page    ? I/O ???? 16 KB (map ? 0xC000)
 *   g_copy_stack_page  ? ?? ??????? copy + tmp/snap date/time (map ? 0xC000)
 *
 *   Delete (?? ??? ?????): g_delete_stack_page ? ?? ??? (map ? 0xC000)
 *
 *   residentPg = main_pg.pgs.window_3 ? C000-????? ???? nc.com (?? OS_NEWPAGE).
 *   SETPG32KHIGH(residentPg) ??????? ???? 0xC000 ?? resident ??? bank/copy ?????.
 *
 * === ???? nc.com (0000/4000/8000/C000) ===
 *   ?? ???????? ????????? ???? ?????? ? ??? ????; ? ???? 0x0000 ??????
 *   ???????? ????? ? ???????? ???? (????? ??????? ?? ??? ??????).
 *   ??? ? ????? nc (lnk.xcl) ???????? ?? ?????? ????; ??? bank/copy/I/O remapping
 *   ????? ?? SETPG32KHIGH ? ??????? ???? 0xC000..0xFFFF.
 *
 *   ??????? ????? ?????? ??????? ?? BANK_WINDOW_ADDRESS = 0xC000.
 *
 *   File page [0..2] ?? map ?? 0xC000:
 *     0xC000 .. 0xC000+15479   fileInfo[180], ?? 86 ???? (PANEL_PAGE_FILES_BYTES)
 *     0xC000+15480 .. 0xFFFF   ??? ?????? (~904 B): PAGE_EXTRA (cpm11, lfn-??? ????)
 *
 *   Meta page [3] ?? map ?? 0xC000:
 *     0xC000 .. 0xC000+15119   sort meta + marks (PANEL_META_USED_BYTES = 15120)
 *       +0      vis?phys idx[540] (2 B ? 540)
 *       +1080   kind[540]
 *       +1620   name4, ext4, lfn4, lfnext4, size, date, time ? ?. PANEL_META_OFF_*
 *       +14580  mark[540] - ??????? Insert ??? '*' (PANEL_META_OFF_MARK)
 *     0xC000+15120 .. 0xFFFF   NC_NVEXT_SPARE (~1264 B): nv.ext (NC_NVEXT_OFF, max NC_NVEXT_MAX)
 *
 *   Copy temp page ?? map ?? 0xC000 (SETPG32KHIGH(g_copy_temp_page)):
 *     0xC000+0     uint32 count
 *     0xC000+4     flags[251]
 *     0xC000+255   names[251?64]
 *     (fdate/ftime ? ?? g_copy_stack_page, ?? ? BSS)
 *
 *   Copy I/O page ?? SETPG32KHIGH(g_copy_io_page):
 *     0xC000 .. 0xFFFF  COPY_IO_ADDR, chunk COPY_IO_CHUNK (16384)
 *
 * === ????? ???? (gopher OS_SHELL ? term.com) ===
 *     OS_SHELL("cmd.com M:/path/file.bat") loads term.com via readfile_pages_dehl order:
 *     window_0 @ 0xC100 (tail), window_1..3 @ 0xC000 (full pages); cmdline at 0xC080.
 *
 * === ??? ? BSS nc.com ===
 *     0x0000..0xBFFF  CODE+DATA nc (?? ????, lnk.xcl), ?? CSTACK+200
 *     0xC000..0xFFFF  bank window: ??????, copy temp/snap/io, residentPg nc
 *     PanelState, ???, ini ? ??. ? UDATA0 ? ?????? ?????
 *
 * ????????: ???? ?????? bank-????? ? 0xC000; ??? BDOS-????? ? SETPG32KHIGH(residentPg).
 */

#define screenWidth 80

#define BLACK 0
#define BLUE 1
#define RED 2
#define CYAN 5
#define YELLOW 6
#define WHITE 7
#define BR_BOTH 0xC0
#define MAKE_COLOR(bright, paper, ink) ((unsigned char)((bright) | ((paper) << 3) | (ink)))
#define COLOR_PANEL_MAIN MAKE_COLOR(BR_BOTH, BLUE, WHITE)
#define COLOR_PANEL_CURSOR MAKE_COLOR(BR_BOTH, CYAN, BLACK)
#define COLOR_STATUS_BAR MAKE_COLOR(BR_BOTH, CYAN, BLACK)
#define COLOR_COPY_UI MAKE_COLOR(BR_BOTH, YELLOW, BLACK)
#define COLOR_COPY_BAR_FILL MAKE_COLOR(BR_BOTH, YELLOW, BLACK)
#define COLOR_OVERWRITE_UI MAKE_COLOR(BR_BOTH, RED, WHITE)
#define COLOR_MENU_NORM COLOR_STATUS_BAR
#define COLOR_PANEL_MARKED MAKE_COLOR(BR_BOTH, BLUE, YELLOW)
#define COLOR_PANEL_CURSOR_MARKED MAKE_COLOR(BR_BOTH, CYAN, YELLOW)
/* Insert (key_ins) or '*' toggles file mark in active panel. */
#define NC_KEY_MARK_INS 29
#define NC_KEY_MARK_STAR 42
#define NC_KEY_SHIFT_6 94
#define NC_KEY_FOCUS 31 /* app regained focus: reload dirs and redraw */
/* NedOOS F-keys: extbase=0xB0 (sysdefs.asm key_F1..key_F10) */
#define NC_KEY_F10 176
#define NC_KEY_F9 185
#define COPY_CH_BAR_FILL 219
#define COPY_CH_BAR_EMPTY 176

#define COPY_OW_SKIP_ALL 0u
#define COPY_OW_ASK_EACH 1u
#define COPY_OW_REPLACE_ALL 2u
#define COPY_OW_ABORT 3u

#define COPY_FILE_OK 0u
#define COPY_FILE_ERR 1u
#define COPY_FILE_SKIP 2u
#define COPY_FILE_ABORT 3u
#define COPY_ITEM_NOMEM 255u

/* Key 8 ? delete: one Yes/No confirm, then silent tree purge. */

/* Directory copy/delete: path stacks on OS_NEWPAGE @ 0xC000, not BSS. */
#define COPY_DIR_STACK_MAX 20u
#define DELETE_DIR_STACK_MAX 20u

#define BANK_WINDOW_ADDRESS 0xC000
#define BANK_PAGE_SIZE 16384u
#define FILINFO_RECORD_SIZE 86u
#define FILES_PER_PAGE 180u
#define PANEL_PAGE_FILES_BYTES (FILES_PER_PAGE * FILINFO_RECORD_SIZE)
#define PANEL_PAGE_EXTRA_OFF PANEL_PAGE_FILES_BYTES
#define PANEL_PAGE_EXTRA_SIZE (BANK_PAGE_SIZE - PANEL_PAGE_EXTRA_OFF)
#define PAGE_EXTRA_FIRSTCHAR_OFF 0u
#define PANEL_META_IDX_SIZE 2u
#define PANEL_FILE_PAGES 3
#define PANEL_META_PAGE 3
#define MAX_FILES_PER_PANEL (FILES_PER_PAGE * PANEL_FILE_PAGES)
#define PANEL_SORT_NOTICE_FILES 50u /* show wait box when sorting more entries */
#define PANEL_SORT_KEY_LEN 4u
#define PANEL_META_OFF_IDX 0u
#define PANEL_META_OFF_KIND (PANEL_META_OFF_IDX + MAX_FILES_PER_PANEL * PANEL_META_IDX_SIZE)
#define PANEL_META_OFF_NAME4 (PANEL_META_OFF_KIND + MAX_FILES_PER_PANEL)
#define PANEL_META_OFF_EXT4 (PANEL_META_OFF_NAME4 + MAX_FILES_PER_PANEL * PANEL_SORT_KEY_LEN)
#define PANEL_META_OFF_LFN4 (PANEL_META_OFF_EXT4 + MAX_FILES_PER_PANEL * PANEL_SORT_KEY_LEN)
#define PANEL_META_OFF_LFNEXT4 (PANEL_META_OFF_LFN4 + MAX_FILES_PER_PANEL * PANEL_SORT_KEY_LEN)
#define PANEL_META_OFF_SIZE (PANEL_META_OFF_LFNEXT4 + MAX_FILES_PER_PANEL * PANEL_SORT_KEY_LEN)
#define PANEL_META_OFF_DATE (PANEL_META_OFF_SIZE + MAX_FILES_PER_PANEL * 4u)
#define PANEL_META_OFF_TIME (PANEL_META_OFF_DATE + MAX_FILES_PER_PANEL * 2u)
#define PANEL_META_OFF_MARK (PANEL_META_OFF_TIME + MAX_FILES_PER_PANEL * 2u)
#define PANEL_META_MARK_BYTES MAX_FILES_PER_PANEL
#define PANEL_META_USED_BYTES (PANEL_META_OFF_MARK + PANEL_META_MARK_BYTES)
#define NC_NVEXT_OFF PANEL_META_USED_BYTES
#define NC_NVEXT_SPARE (BANK_PAGE_SIZE - PANEL_META_USED_BYTES)
#define NC_NVEXT_MAX 1024u /* nv.ext; must fit in NC_NVEXT_SPARE (~1804 B) */

#define PANEL_KIND_FILE 0u
#define PANEL_KIND_DIR 1u
#define PANEL_KIND_DOTDOT 2u

#define COPY_TEMP_PAGE_ENTRIES 251

#define PANEL_DRIVE_MAX 15u
#define PANEL_COL_WIDTH 40u
#define PANEL_COL_LEFT 0u
#define PANEL_COL_RIGHT 40u
#define DRIVE_POPUP_Y 1u
#define DRIVE_POPUP_INNER_W 26u /* inner text width; frame adds 2 border cols */
#define DRIVE_ITEM_W DRIVE_POPUP_INNER_W
#define DRVF_NONE 0u
#define DRVF_NEOGS 1u
#define DRVF_ZXNET 2u
#define DRVF_TRDOS 4u /* A..D: always in menu, no CHDRV probe (floppy timeouts) */

#define COPY_CACHE_FLAGS_OFF 4u
#define COPY_CACHE_NAMES_OFF (4u + COPY_TEMP_PAGE_ENTRIES)

#define COPY_IO_CHUNK 16384u

struct setup set;

void switch_file_page(PanelState *panel, unsigned int file_idx);
int ext_cmp(const char *s1, const char *s2);
void build_full_path(char *dest, const char *path, const char *filename);

unsigned char uVer[] = "0.5";
unsigned char botMenu[] = "1Left  2Right 3View 4Edit 5Copy 6Rename 7MkDir 8Delete 9Menu 0Quit";

static char r_src_full[200];
static char r_dst_full[200];
static fileInfo r_global_info;

static unsigned char g_copy_temp_page;
static unsigned char g_copy_snap_page;
static unsigned char g_copy_io_page;
static unsigned char g_copy_stack_page;
static unsigned char g_copy_page_active;
unsigned char g_panel_page_used[256];

static unsigned char os_request_page(unsigned char *page_out)
{
	unsigned int newPage;

	newPage = OS_NEWPAGE();
	if (newPage > 255u)
		return 0;
	*page_out = (unsigned char)newPage;
	return 1;
}

static void panel_pages_mark_clear(void)
{
	memset(g_panel_page_used, 0, sizeof(g_panel_page_used));
}

unsigned char panel_request_unique_page(unsigned char *page_out)
{
	unsigned char attempt;
	unsigned char pg;

	for (attempt = 0; attempt < 64u; attempt++)
	{
		if (!os_request_page(&pg))
			return 0;
		if (g_panel_page_used[pg])
		{
			OS_DELPAGE(pg);
			continue;
		}
		g_panel_page_used[pg] = 1;
		*page_out = pg;
		return 1;
	}
	return 0;
}

static unsigned char g_delete_stack_page;
static unsigned char g_delete_page_active;

static void panels_remap_bank_window(void);
static void copy_io_unmap(void);
static void nc_nvext_load(void);
static void nc_run_selected_file(PanelState *panel);
static void nc_action_view(PanelState *panel);
static void nc_action_edit(PanelState *panel);
static void redraw_panels_full(void);
static void ui_draw_frame(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char color,
						  const char *title);
static void panel_sort_notice_show(PanelState *panel);
static void panel_clamp_scroll(PanelState *panel);
static unsigned char panel_find_by_name(PanelState *panel, const char *hint, unsigned int *out_idx);
static void fileop_progress_begin(unsigned char is_delete);
static void fileop_progress_begin_title(unsigned char is_delete, const char *title);
static void fileop_progress_restore(void);
static void ui_error_dialog(const char *title, const char *msg);
static unsigned char copy_dest_path_ok(void);
static void panels_refresh_after_copy_snaps(PanelState *src_panel, PanelState *dst_panel, const char *snap_left,
											const char *snap_right, const char *hint);
static void move_delete_path(const char *path);
static void move_delete_dir_path(const char *full_dir_path);
static void delete_progress_ensure(void);
static void panels_redraw_current(PanelState *active_p);
static void panels_refresh_after_delete(PanelState *del_panel);
static void ui_str_append_uint(char *buf, unsigned char *pi, unsigned int val);
static unsigned char nc_mkdir_name_valid(const char *name);
static unsigned char g_copy_overwrite_mode;
static char g_copy_ow_msg[80];
static unsigned char g_fileop_abort;	 /* Esc during copy/delete progress */
static unsigned char g_focus_pending;	 /* NC_KEY_FOCUS seen during fileop poll */
static unsigned char g_delete_progress;	 /* 1: red "Deleting" window, no progress bar */
static unsigned char g_move_active;		 /* 1: move op ? "Moving" progress, delete source after OK copy */
static unsigned char g_copy_tree_failed; /* copy_tree_iter hit error (not user skip) */
static char g_fileop_title[16];
static unsigned char g_deldir_sp;

typedef struct
{
	char src[64];
	char dst[64];
	unsigned int i;
	unsigned int n;
	unsigned int skip; /* non-dot entries already copied in this dir */
	unsigned char snap_valid;
	unsigned char dir_more; /* full batch read; more entries may follow */
} CopyDirFrame;

static unsigned char g_copy_sp;

static void fileop_abort_clear(void)
{
	g_fileop_abort = 0;
}

static void fileop_poll_abort(void)
{
	unsigned char k;

	k = (unsigned char)OS_GETKEY();
	if (k == NC_KEY_FOCUS)
		g_focus_pending = 1;
	else if (k == 27 || k == 176)
		g_fileop_abort = 1;
}

unsigned char residentPg;
union APP_PAGES main_pg;

static unsigned char bank_window_current(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_3;
}

static void bank_window_map(unsigned char page)
{
	SETPG32KHIGH(page);
}

/* BDOS and CODE_RESIDENT at C000: map residentPg before OS_* / show_dialog. */
static unsigned char resident_bank_push(void)
{
	unsigned char saved;

	saved = bank_window_current();
	SETPG32KHIGH(residentPg);
	return saved;
}

static void resident_bank_pop(unsigned char saved)
{
	bank_window_map(saved);
}

static void fileop_yield(void)
{
	unsigned char saved;

	saved = bank_window_current();
	if (saved != residentPg)
		SETPG32KHIGH(residentPg);
	fileop_poll_abort();
	YIELD();
	if (saved != residentPg)
		bank_window_map(saved);
}

#define COPY_IO_ADDR ((unsigned char *)BANK_WINDOW_ADDRESS)

unsigned char g_menu_active;
unsigned char g_menu_level;
unsigned char g_menu_sel;

unsigned char g_drive_active;
PanelState *g_drive_panel;
unsigned char g_drive_sel;
static unsigned char g_drive_popup_x; /* left edge of drive popup on active panel */
unsigned char g_drive_count;
static unsigned char g_drive_letters[PANEL_DRIVE_MAX];
char g_ini_hide_drives[64];
char g_ini_viewer[NC_INI_APP_LEN];
char g_ini_editor[NC_INI_APP_LEN];
unsigned char g_ini_has_left_path;
unsigned char g_ini_has_right_path;
unsigned char g_ini_read_on_focus;
static char g_ini_buf[NC_INI_BUF_SIZE];
char g_nc_startup_path[64];
static char g_drive_labels[PANEL_DRIVE_MAX][26];

static unsigned int g_nvext_size;
static char g_run_saved_cwd[64];

#define PANEL_PORT_NEOGS_GSCFG 0x0Fu
#define PANEL_PORT_SL811_SEL 0xABu

/* ngssddrv INSTSDD: GSCFG0==0xFF => classic GS without NeoGS SD */
static unsigned char panel_hw_neogs_sd_present(void)
{
	return (unsigned char)(input(PANEL_PORT_NEOGS_GSCFG) != 0xFFu);
}

/* fatfsdrv disk_status SL811 probe for ZXNETUSB */
static unsigned char panel_hw_zxnet_present(void)
{
	unsigned char v;

	v = input(PANEL_PORT_SL811_SEL);
	v = (unsigned char)(v & 0xAFu);
	output(PANEL_PORT_SL811_SEL, v);
	output(PANEL_PORT_SL811_SEL, 0x0Du);
	v = input(PANEL_PORT_SL811_SEL);
	if (v == 0u)
		return 0u;
	if ((v & 0x40u) == 0u)
		return 0u;
	return 1u;
}

static struct
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char bar_x;
	unsigned char bar_y;
	unsigned char bar_w;
	unsigned char name_y;
	unsigned char last_pct;
	unsigned char drawn;
} copy_prog;
static char copy_prog_current_name[64];

static unsigned char copy_workspace_begin(void)
{
	unsigned char io_reused;

	if (g_copy_page_active)
		return 1;

	io_reused = (unsigned char)(g_copy_io_page != 0u);

	if (!panel_request_unique_page(&g_copy_temp_page))
		return 0;
	if (!panel_request_unique_page(&g_copy_snap_page))
	{
		OS_DELPAGE(g_copy_temp_page);
		g_panel_page_used[g_copy_temp_page] = 0;
		g_copy_temp_page = 0;
		return 0;
	}
	if (!io_reused)
	{
		if (!panel_request_unique_page(&g_copy_io_page))
		{
			OS_DELPAGE(g_copy_snap_page);
			g_panel_page_used[g_copy_snap_page] = 0;
			OS_DELPAGE(g_copy_temp_page);
			g_panel_page_used[g_copy_temp_page] = 0;
			g_copy_snap_page = 0;
			g_copy_temp_page = 0;
			return 0;
		}
	}
	if (!panel_request_unique_page(&g_copy_stack_page))
	{
		if (!io_reused)
		{
			OS_DELPAGE(g_copy_io_page);
			g_panel_page_used[g_copy_io_page] = 0;
			g_copy_io_page = 0;
		}
		OS_DELPAGE(g_copy_snap_page);
		g_panel_page_used[g_copy_snap_page] = 0;
		OS_DELPAGE(g_copy_temp_page);
		g_panel_page_used[g_copy_temp_page] = 0;
		g_copy_snap_page = 0;
		g_copy_temp_page = 0;
		return 0;
	}
	g_copy_page_active = 1;
	return 1;
}

static void copy_workspace_end(void)
{
	if (!g_copy_page_active)
		return;
	copy_io_unmap();
	OS_DELPAGE(g_copy_io_page);
	g_panel_page_used[g_copy_io_page] = 0;
	OS_DELPAGE(g_copy_snap_page);
	g_panel_page_used[g_copy_snap_page] = 0;
	OS_DELPAGE(g_copy_temp_page);
	g_panel_page_used[g_copy_temp_page] = 0;
	OS_DELPAGE(g_copy_stack_page);
	g_panel_page_used[g_copy_stack_page] = 0;
	g_copy_io_page = 0;
	g_copy_snap_page = 0;
	g_copy_temp_page = 0;
	g_copy_stack_page = 0;
	g_copy_page_active = 0;
}

static unsigned char copy_io_ensure(void)
{
	if (g_copy_page_active || g_copy_io_page != 0)
		return 1;
	if (!panel_request_unique_page(&g_copy_io_page))
		return 0;
	return 1;
}

static void copy_io_release(void)
{
	if (g_copy_page_active || g_copy_io_page == 0)
		return;
	copy_io_unmap();
	OS_DELPAGE(g_copy_io_page);
	g_panel_page_used[g_copy_io_page] = 0;
	g_copy_io_page = 0;
}

#define COPY_STACK_FRAME_BYTES ((unsigned int)sizeof(CopyDirFrame))
#define COPY_STACK_TMPDATE_OFF (COPY_STACK_FRAME_BYTES * COPY_DIR_STACK_MAX)
#define COPY_STACK_TMPTIME_OFF (COPY_STACK_TMPDATE_OFF + COPY_TEMP_PAGE_ENTRIES * 2u)
#define COPY_STACK_SNAPDATE_OFF (COPY_STACK_TMPTIME_OFF + COPY_TEMP_PAGE_ENTRIES * 2u)
#define COPY_STACK_SNAPTIME_OFF (COPY_STACK_SNAPDATE_OFF + COPY_TEMP_PAGE_ENTRIES * 2u)

static void copy_stack_map(void)
{
	SETPG32KHIGH(g_copy_stack_page);
}

static CopyDirFrame *copy_stack_frame_ptr(unsigned char idx)
{
	return (CopyDirFrame *)((unsigned char *)BANK_WINDOW_ADDRESS + (unsigned int)idx * COPY_STACK_FRAME_BYTES);
}

static unsigned short *copy_stack_dates_ptr(unsigned int base_off)
{
	return (unsigned short *)((unsigned char *)BANK_WINDOW_ADDRESS + base_off);
}

static unsigned char delete_workspace_begin(void)
{
	if (g_delete_page_active)
		return 1;

	if (!panel_request_unique_page(&g_delete_stack_page))
		return 0;
	g_delete_page_active = 1;
	return 1;
}

static void delete_workspace_end(void)
{
	if (!g_delete_page_active)
		return;
	SETPG32KHIGH(residentPg);
	OS_DELPAGE(g_delete_stack_page);
	g_panel_page_used[g_delete_stack_page] = 0;
	g_delete_stack_page = 0;
	g_delete_page_active = 0;
}

static void delete_stack_map(void)
{
	SETPG32KHIGH(g_delete_stack_page);
}

static char *delete_stack_slot(unsigned char idx)
{
	delete_stack_map();
	return (char *)((unsigned char *)BANK_WINDOW_ADDRESS + (unsigned int)idx * 64u);
}

static void panel_meta_map(PanelState *panel)
{
	SETPG32KHIGH(panel->bank_ids[PANEL_META_PAGE]);
}

static unsigned int panel_meta_idx_get(const unsigned char *base, unsigned int vis_idx)
{
	const unsigned char *p;

	p = base + PANEL_META_OFF_IDX + vis_idx * PANEL_META_IDX_SIZE;
	return (unsigned int)p[0] | ((unsigned int)p[1] << 8);
}

static void panel_meta_idx_set(unsigned char *base, unsigned int vis_idx, unsigned int phys_idx)
{
	unsigned char *p;

	p = base + PANEL_META_OFF_IDX + vis_idx * PANEL_META_IDX_SIZE;
	p[0] = (unsigned char)(phys_idx & 0xFFu);
	p[1] = (unsigned char)((phys_idx >> 8) & 0xFFu);
}

static void panel_file_map(PanelState *panel, unsigned char file_page)
{
	SETPG32KHIGH(panel->bank_ids[file_page]);
}

static unsigned char panel_banks_ok(const PanelState *panel)
{
	unsigned char a;
	unsigned char b;

	for (a = 0; a < PAGES_PER_PANEL; a++)
	{
		if (panel->bank_ids[a] == 0)
			return 0;
		for (b = (unsigned char)(a + 1u); b < PAGES_PER_PANEL; b++)
		{
			if (panel->bank_ids[a] == panel->bank_ids[b])
				return 0;
		}
	}
	return 1;
}

static void panel_clear_finfo(fileInfo *fi)
{
	unsigned int i;
	unsigned char *p;

	p = (unsigned char *)fi;
	for (i = 0; i < FILINFO_RECORD_SIZE; i++)
		p[i] = 0;
}

/* Before OS_READDIR: BDOS overwrites numeric fields; clear LFN head only. */
static void panel_prep_finfo_for_readdir(fileInfo *fi)
{
	fi->lfname[0] = 0;
}

static void panel_trim_fname(fileInfo *fi)
{
	unsigned int i;

	for (i = 0; i < 12u; i++)
	{
		if (fi->fname[i] == 0 || fi->fname[i] == ' ')
			break;
	}
	fi->fname[i] = 0;
}

static void panel_normalize_fname(fileInfo *fi)
{
	unsigned int i;
	unsigned int j;
	unsigned int name_end;

	if (fi->fname[0] == '.')
	{
		if (fi->fname[1] == '.')
		{
			fi->fname[0] = '.';
			fi->fname[1] = '.';
			fi->fname[2] = 0;
			strcpy((char *)fi->lfname, "..");
			return;
		}
		if (fi->fname[1] == 0)
		{
			fi->fname[0] = '.';
			fi->fname[1] = 0;
			strcpy((char *)fi->lfname, ".");
			return;
		}
	}

	panel_trim_fname(fi);

	if (fi->lfname[0] != 0)
	{
		for (i = 0; i < 63u && fi->lfname[i] != 0; i++)
			;
		fi->lfname[i] = 0;
		if (fi->fname[0] == 0)
			panel_trim_fname(fi);
		return;
	}

	for (i = 0; i < 12u; i++)
	{
		if (fi->fname[i] == 0)
			break;
	}
	name_end = i;

	j = 0;
	for (i = 0; i < name_end && j < 63u; i++)
		fi->lfname[j++] = fi->fname[i];
	fi->lfname[j] = 0;

	if (j == 0)
		fi->fname[0] = 0;
}

static char *panel_entry_name(const fileInfo *fi)
{
	if (fi->lfname[0] != 0)
		return (char *)fi->lfname;
	if (fi->fname[0] == 0)
		return (char *)"";
	return (char *)fi->fname;
}

static unsigned char panel_entry_is_dotdot(const fileInfo *fi)
{
	if (fi->fname[0] == '.' && fi->fname[1] == '.' && fi->fname[2] == 0)
		return 1;
	if (fi->lfname[0] == '.' && fi->lfname[1] == '.' && fi->lfname[2] == 0)
		return 1;
	return 0;
}

static unsigned char panel_fold_char(unsigned char c)
{
	if (c >= 'a' && c <= 'z')
		return (unsigned char)(c - ('a' - 'A'));
	return c;
}

static void panel_name_to_key4(const char *name, unsigned char *k4)
{
	unsigned int i;

	for (i = 0; i < PANEL_SORT_KEY_LEN; i++)
		k4[i] = 0;
	for (i = 0; i < PANEL_SORT_KEY_LEN && name[i] != 0; i++)
		k4[i] = panel_fold_char((unsigned char)name[i]);
}

static void panel_name_to_key4_at(const char *name, unsigned int skip, unsigned char *k4)
{
	unsigned int i;

	for (i = 0; i < PANEL_SORT_KEY_LEN; i++)
		k4[i] = 0;
	while (skip > 0u && name[0] != 0)
	{
		name++;
		skip--;
	}
	for (i = 0; i < PANEL_SORT_KEY_LEN && name[i] != 0; i++)
		k4[i] = panel_fold_char((unsigned char)name[i]);
}

static int panel_cmp_key4_cached(const unsigned char *a, const unsigned char *b)
{
	unsigned int i;

	for (i = 0; i < PANEL_SORT_KEY_LEN; i++)
	{
		if (a[i] != b[i])
			return (int)a[i] - (int)b[i];
	}
	return 0;
}

static void panel_name_to_ext4(const char *name, unsigned char *e4)
{
	unsigned int i;
	unsigned int dot;
	unsigned int j;

	for (i = 0; i < PANEL_SORT_KEY_LEN; i++)
		e4[i] = 0;
	dot = 0;
	for (i = 0; name[i] != 0; i++)
	{
		if (name[i] == '.')
			dot = i;
	}
	if (dot == 0u)
		return;
	j = 0;
	for (i = dot + 1u; name[i] != 0 && j < PANEL_SORT_KEY_LEN - 1u; i++)
		e4[j++] = panel_fold_char((unsigned char)name[i]);
	e4[j] = 0;
}

static int panel_cmp_str_fold(const char *a, const char *b)
{
	while (a[0] != 0 && panel_fold_char((unsigned char)a[0]) == panel_fold_char((unsigned char)b[0]))
	{
		a++;
		b++;
	}
	return (int)panel_fold_char((unsigned char)a[0]) - (int)panel_fold_char((unsigned char)b[0]);
}

static void panel_page_extra_clear(PanelState *panel, unsigned char file_page)
{
	panel_file_map(panel, file_page);
	memset((void *)(BANK_WINDOW_ADDRESS + PANEL_PAGE_EXTRA_OFF), 0, (size_t)PANEL_PAGE_EXTRA_SIZE);
}

static void panel_path_normalize(PanelState *panel, const char *path)
{
	unsigned int len;
	unsigned int i;

	len = 0;
	while (path[len] != 0 && len < 63u)
		len++;
	for (i = 0; i < len; i++)
		panel->current_path[i] = path[i];
	panel->current_path[len] = 0;
	if (len > 0 && panel->current_path[len - 1u] != '/' && len < 62u)
	{
		panel->current_path[len] = '/';
		panel->current_path[len + 1u] = 0;
	}
}

static unsigned char panel_chdir_only(const char *path)
{
	char try_path[64];
	unsigned int len;

	if (OS_CHDIR((unsigned char *)path) == 0)
		return 1;

	strncpy(try_path, path, sizeof(try_path) - 1u);
	try_path[sizeof(try_path) - 1u] = 0;
	len = 0;
	while (try_path[len] != 0)
		len++;
	if (len > 0 && try_path[len - 1u] == '/')
	{
		try_path[len - 1u] = 0;
		if (OS_CHDIR((unsigned char *)try_path) == 0)
			return 1;
	}
	return 0;
}

static unsigned char panel_chdir_for_read(const char *path)
{
	if (!panel_chdir_only(path))
		return 0;
	OS_OPENDIR("");
	return 1;
}

static void panel_sync_path(PanelState *panel)
{
	char path_buf[64];

	OS_GETPATH((unsigned int)path_buf);
	panel_path_normalize(panel, path_buf);
}

static void panel_fixup_startup_path(PanelState *panel)
{
	if (panel->current_path[0] == 0)
	{
		panel_path_normalize(panel, g_nc_startup_path);
		return;
	}
	if (panel_chdir_for_read(panel->current_path))
		return;
	if (panel_chdir_for_read(g_nc_startup_path))
		panel_sync_path(panel);
	else
		panel_path_normalize(panel, g_nc_startup_path);
}

static void path_basename_from(const char *path, char *out)
{
	unsigned int len;
	unsigned int i;
	unsigned int start;

	out[0] = 0;
	len = 0;
	while (path[len] != 0 && len < 63u)
		len++;
	while (len > 0 && path[len - 1u] == '/')
		len--;
	start = 0;
	for (i = 0; i < len; i++)
	{
		if (path[i] == '/')
			start = i + 1u;
	}
	for (i = 0; start < len && i < 63u; i++)
	{
		out[i] = path[start];
		start++;
	}
	out[i] = 0;
}

static void panel_path_basename(PanelState *panel, char *out)
{
	path_basename_from(panel->current_path, out);
}

static unsigned int panel_meta_get_index(PanelState *panel, unsigned int vis_idx)
{
	panel_meta_map(panel);
	return panel_meta_idx_get((const unsigned char *)BANK_WINDOW_ADDRESS, vis_idx);
}

static unsigned char panel_meta_get_kind(PanelState *panel, unsigned int phys_idx)
{
	unsigned char *base;

	panel_meta_map(panel);
	base = (unsigned char *)BANK_WINDOW_ADDRESS;
	return base[PANEL_META_OFF_KIND + phys_idx];
}

static void panel_meta_set_index(PanelState *panel, unsigned int vis_idx, unsigned int phys_idx,
								 unsigned char file_page)
{
	panel_meta_map(panel);
	panel_meta_idx_set((unsigned char *)BANK_WINDOW_ADDRESS, vis_idx, phys_idx);
	if (file_page < PANEL_FILE_PAGES)
		panel_file_map(panel, file_page);
}

static void panel_dotname_to_cpm11(const char *s, unsigned char out[11])
{
	unsigned char i;
	unsigned char n;
	const char *p;

	for (i = 0; i < 11u; i++)
		out[i] = ' ';
	if (s[0] == 0)
		return;
	if (s[0] == '.' && (s[1] == 0 || (s[1] == '.' && s[2] == 0)))
	{
		for (i = 0; i < 11u && s[i] != 0; i++)
			out[i] = (unsigned char)s[i];
		return;
	}

	p = s;
	n = 0;
	while (*p != 0 && *p != '.' && n < 8u)
		out[n++] = (unsigned char)*p++;
	if (*p == '.')
	{
		p++;
		i = 0;
		while (*p != 0 && i < 3u)
			out[8u + i++] = (unsigned char)*p++;
		return;
	}
	while (*p != 0 && *p != '.')
		p++;
	if (*p == '.')
	{
		p++;
		i = 0;
		while (*p != 0 && i < 3u)
			out[8u + i++] = (unsigned char)*p++;
	}
}

static void panel_fi_to_cpm11(const fileInfo *fi, unsigned char out[11])
{
	unsigned int i;
	const char *s;

	if (fi->fname[0] == '.' && fi->fname[1] == '.')
	{
		panel_dotname_to_cpm11((const char *)fi->fname, out);
		return;
	}

	s = (const char *)fi->fname;
	for (i = 0; i < 12u && fi->fname[i] != 0; i++)
	{
		if (fi->fname[i] == '.')
		{
			panel_dotname_to_cpm11(s, out);
			return;
		}
	}
	if (fi->lfname[0] != 0)
		s = (const char *)fi->lfname;
	panel_dotname_to_cpm11(s, out);
}

/* LFN sort cache: lfn4/ext keys + name[4..11] in NAME4/EXT4 for tie without SETPG. */
static void panel_cache_entry_lfn(PanelState *panel, unsigned int real_idx, unsigned int page_offset,
								  unsigned char file_page)
{
	fileInfo *fi;
	const char *disp;
	unsigned char kind;
	unsigned char lfn4[PANEL_SORT_KEY_LEN];
	unsigned char lfnext4[PANEL_SORT_KEY_LEN];
	unsigned char *base;
	unsigned char *extra;

	panel_file_map(panel, file_page);
	fi = &set.bank_array[page_offset];
	if (fi->fname[0] == '.' && fi->fname[1] == '.')
		kind = PANEL_KIND_DOTDOT;
	else if (fi->fattrib & 0x10)
		kind = PANEL_KIND_DIR;
	else
		kind = PANEL_KIND_FILE;

	disp = panel_entry_name(fi);
	panel_name_to_key4(disp, lfn4);
	panel_name_to_ext4(disp, lfnext4);

	extra = (unsigned char *)(BANK_WINDOW_ADDRESS + PANEL_PAGE_EXTRA_OFF + PAGE_EXTRA_FIRSTCHAR_OFF);
	if (disp[0] != 0)
		extra[page_offset] = (unsigned char)tolower((unsigned char)panel_fold_char((unsigned char)disp[0]));
	else
		extra[page_offset] = 0;

	panel_meta_map(panel);
	base = (unsigned char *)BANK_WINDOW_ADDRESS;
	panel_meta_idx_set(base, real_idx, real_idx);
	base[PANEL_META_OFF_KIND + real_idx] = kind;
	memcpy(base + PANEL_META_OFF_LFN4 + real_idx * PANEL_SORT_KEY_LEN, lfn4, PANEL_SORT_KEY_LEN);
	memcpy(base + PANEL_META_OFF_LFNEXT4 + real_idx * PANEL_SORT_KEY_LEN, lfnext4, PANEL_SORT_KEY_LEN);
	panel_name_to_key4_at(disp, 4u, base + PANEL_META_OFF_NAME4 + real_idx * PANEL_SORT_KEY_LEN);
	panel_name_to_key4_at(disp, 8u, base + PANEL_META_OFF_EXT4 + real_idx * PANEL_SORT_KEY_LEN);
	*(unsigned long *)(base + PANEL_META_OFF_SIZE + real_idx * 4u) = fi->fsize;
	*(unsigned short *)(base + PANEL_META_OFF_DATE + real_idx * 2u) = (unsigned short)fi->fdate;
	*(unsigned short *)(base + PANEL_META_OFF_TIME + real_idx * 2u) = (unsigned short)fi->ftime;
}

/* Short sort meta from fileInfo already in hand (no file-page SETPG). */
static void panel_cache_entry_short_fi(PanelState *panel, unsigned int real_idx, const fileInfo *fi)
{
	unsigned char kind;
	unsigned char cpm11[11];
	unsigned char *base;

	if (fi->fname[0] == '.' && fi->fname[1] == '.')
		kind = PANEL_KIND_DOTDOT;
	else if (fi->fattrib & 0x10)
		kind = PANEL_KIND_DIR;
	else
		kind = PANEL_KIND_FILE;

	panel_fi_to_cpm11(fi, cpm11);
	panel_meta_map(panel);
	base = (unsigned char *)BANK_WINDOW_ADDRESS;
	panel_meta_idx_set(base, real_idx, real_idx);
	base[PANEL_META_OFF_KIND + real_idx] = kind;
	memcpy(base + PANEL_META_OFF_NAME4 + real_idx * PANEL_SORT_KEY_LEN, cpm11, PANEL_SORT_KEY_LEN);
	base[PANEL_META_OFF_EXT4 + real_idx * PANEL_SORT_KEY_LEN + 0u] = cpm11[8];
	base[PANEL_META_OFF_EXT4 + real_idx * PANEL_SORT_KEY_LEN + 1u] = cpm11[9];
	base[PANEL_META_OFF_EXT4 + real_idx * PANEL_SORT_KEY_LEN + 2u] = cpm11[10];
	base[PANEL_META_OFF_EXT4 + real_idx * PANEL_SORT_KEY_LEN + 3u] = ' ';
	memcpy(base + PANEL_META_OFF_LFN4 + real_idx * PANEL_SORT_KEY_LEN, cpm11 + 4, PANEL_SORT_KEY_LEN);
	*(unsigned long *)(base + PANEL_META_OFF_SIZE + real_idx * 4u) = fi->fsize;
	*(unsigned short *)(base + PANEL_META_OFF_DATE + real_idx * 2u) = (unsigned short)fi->fdate;
	*(unsigned short *)(base + PANEL_META_OFF_TIME + real_idx * 2u) = (unsigned short)fi->ftime;
}

/* Short sort: CPM11 keys + cpm[4..7] in LFN4 slot; no LFN keys / page-extra / SETPG in sort. */
static void panel_cache_entry_short(PanelState *panel, unsigned int real_idx, unsigned int page_offset,
									unsigned char file_page)
{
	panel_file_map(panel, file_page);
	panel_cache_entry_short_fi(panel, real_idx, &set.bank_array[page_offset]);
}

/* Short-name compare helpers (panel_heap_sort_fn83). */
#define SORTFN_KEY_LEN 4u
#define SORTFN_KIND_DIR 1u
#define SORTFN_KIND_DOTDOT 2u

static int sortfn_cmp_byte(unsigned char a, unsigned char b)
{
	unsigned char ca;
	unsigned char cb;

	ca = panel_fold_char(a);
	cb = panel_fold_char(b);
	if (ca == cb)
		return 0;
	return (int)ca - (int)cb;
}

static int sortfn_cmp_key4(const unsigned char *a, const unsigned char *b)
{
	unsigned int i;
	int cmp;

	for (i = 0; i < SORTFN_KEY_LEN; i++)
	{
		cmp = sortfn_cmp_byte(a[i], b[i]);
		if (cmp != 0)
			return cmp;
	}
	return 0;
}

static int sortfn_cmp_kind_meta(unsigned char ka, unsigned char kb)
{
	if (ka == kb)
		return 0;
	if (ka == SORTFN_KIND_DOTDOT)
		return -1;
	if (kb == SORTFN_KIND_DOTDOT)
		return 1;
	if (ka == SORTFN_KIND_DIR)
		return -1;
	if (kb == SORTFN_KIND_DIR)
		return 1;
	return 0;
}

static int sortfn_cmp_cpm11_tail_meta(const unsigned char *cpm4_a, const unsigned char *cpm4_b,
									  const unsigned char *ext_a, const unsigned char *ext_b)
{
	unsigned char i;
	int cmp;

	cmp = sortfn_cmp_key4(cpm4_a, cpm4_b);
	if (cmp != 0)
		return cmp;
	for (i = 0; i < 3u; i++)
	{
		if (ext_a[i] != ext_b[i])
			return (int)ext_a[i] - (int)ext_b[i];
	}
	return 0;
}

static int panel_cmp_lfn_name_tail_meta(const unsigned char *na, const unsigned char *nb,
										const unsigned char *ea, const unsigned char *eb)
{
	int cmp;

	cmp = panel_cmp_key4_cached(na, nb);
	if (cmp != 0)
		return cmp;
	return panel_cmp_key4_cached(ea, eb);
}

static int panel_cmp_lfn_tie_bank(PanelState *panel, unsigned int pa, unsigned int pb)
{
	unsigned char page_a;
	unsigned char page_b;
	unsigned int off_a;
	unsigned int off_b;
	const char *sa;
	const char *sb;
	int cmp;

	page_a = (unsigned char)(pa / FILES_PER_PAGE);
	page_b = (unsigned char)(pb / FILES_PER_PAGE);
	off_a = pa % FILES_PER_PAGE;
	off_b = pb % FILES_PER_PAGE;
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	panel_file_map(panel, page_a);
	sa = panel_entry_name(&set.bank_array[off_a]);
	if (page_a == page_b)
		sb = panel_entry_name(&set.bank_array[off_b]);
	else
	{
		panel_file_map(panel, page_b);
		sb = panel_entry_name(&set.bank_array[off_b]);
	}
	cmp = panel_cmp_str_fold(sa, sb);
	panel_meta_map(panel);
	return cmp;
}

typedef struct PanelFn83Ctx
{
	unsigned char *base;
	unsigned char *kind;
	unsigned char *name4;
	unsigned char *ext4;
	unsigned char *cpm4;
	unsigned long *sizes;
	unsigned short *dates;
	unsigned short *times;
	unsigned short *idx;
	unsigned char sort_mode;
	unsigned char sort_desc;
} PanelFn83Ctx;

typedef struct PanelLfnCtx
{
	PanelState *panel;
	unsigned char *kind;
	unsigned char *lfn4;
	unsigned char *lfnext4;
	unsigned char *nm4;
	unsigned char *ex4;
	unsigned long *sizes;
	unsigned short *dates;
	unsigned short *times;
	unsigned short *idx;
	unsigned char sort_mode;
	unsigned char sort_desc;
} PanelLfnCtx;

/* >0 if phys_a sorts after phys_b (heap uses ascending: .., dirs, files). */
static int panel_cmp_fn83_phys(const PanelFn83Ctx *ctx, unsigned int pa, unsigned int pb)
{
	unsigned char ka;
	unsigned char kb;
	int cmp;
	const unsigned char *na;
	const unsigned char *nb;
	const unsigned char *ea;
	const unsigned char *eb;
	const unsigned char *ma;
	const unsigned char *mb;

	ka = ctx->kind[pa];
	kb = ctx->kind[pb];
	if (ka != kb)
		return sortfn_cmp_kind_meta(ka, kb);

	na = ctx->name4 + pa * PANEL_SORT_KEY_LEN;
	nb = ctx->name4 + pb * PANEL_SORT_KEY_LEN;
	ea = ctx->ext4 + pa * PANEL_SORT_KEY_LEN;
	eb = ctx->ext4 + pb * PANEL_SORT_KEY_LEN;
	ma = ctx->cpm4 + pa * PANEL_SORT_KEY_LEN;
	mb = ctx->cpm4 + pb * PANEL_SORT_KEY_LEN;

	switch (ctx->sort_mode)
	{
	case NC_PANEL_SORT_EXT:
		cmp = sortfn_cmp_key4(ea, eb);
		if (cmp == 0)
			cmp = sortfn_cmp_key4(na, nb);
		if (cmp == 0)
			cmp = sortfn_cmp_cpm11_tail_meta(ma, mb, ea, eb);
		break;

	case NC_PANEL_SORT_SIZE:
		if (ctx->sizes[pa] < ctx->sizes[pb])
			cmp = -1;
		else if (ctx->sizes[pa] > ctx->sizes[pb])
			cmp = 1;
		else
		{
			cmp = sortfn_cmp_key4(na, nb);
			if (cmp == 0)
				cmp = sortfn_cmp_cpm11_tail_meta(ma, mb, ea, eb);
		}
		break;

	case NC_PANEL_SORT_TIME:
		if (ctx->dates[pa] < ctx->dates[pb])
			cmp = -1;
		else if (ctx->dates[pa] > ctx->dates[pb])
			cmp = 1;
		else if (ctx->times[pa] < ctx->times[pb])
			cmp = -1;
		else if (ctx->times[pa] > ctx->times[pb])
			cmp = 1;
		else
		{
			cmp = sortfn_cmp_key4(na, nb);
			if (cmp == 0)
				cmp = sortfn_cmp_cpm11_tail_meta(ma, mb, ea, eb);
		}
		break;

	case NC_PANEL_SORT_NAME:
	default:
		cmp = sortfn_cmp_key4(na, nb);
		if (cmp == 0)
			cmp = sortfn_cmp_cpm11_tail_meta(ma, mb, ea, eb);
		break;
	}

	if (ctx->sort_desc && cmp != 0)
		cmp = -cmp;
	return cmp;
}

static int panel_cmp_fn83_vis(const PanelFn83Ctx *ctx, unsigned int vis_a, unsigned int vis_b)
{
	unsigned int pa;
	unsigned int pb;

	pa = (unsigned int)ctx->idx[vis_a];
	pb = (unsigned int)ctx->idx[vis_b];
	return panel_cmp_fn83_phys(ctx, pa, pb);
}

static void panel_heap_sift_fn83(PanelFn83Ctx *ctx, unsigned int heap_size, unsigned int root)
{
	unsigned int largest;
	unsigned int left;
	unsigned int right;
	int cmp;

	for (;;)
	{
		largest = root;
		left = root * 2u + 1u;
		right = left + 1u;
		if (left < heap_size)
		{
			cmp = panel_cmp_fn83_vis(ctx, left, largest);
			if (cmp > 0)
				largest = left;
		}
		if (right < heap_size)
		{
			cmp = panel_cmp_fn83_vis(ctx, right, largest);
			if (cmp > 0)
				largest = right;
		}
		if (largest == root)
			break;
		{
			unsigned short t;

			t = ctx->idx[root];
			ctx->idx[root] = ctx->idx[largest];
			ctx->idx[largest] = t;
		}
		root = largest;
	}
}

static void panel_heap_sort_fn83(PanelState *panel)
{
	PanelFn83Ctx ctx;
	unsigned int n;
	unsigned int i;

	if (panel->file_count < 2u)
		return;

	panel_meta_map(panel);
	ctx.base = (unsigned char *)BANK_WINDOW_ADDRESS;
	ctx.kind = ctx.base + PANEL_META_OFF_KIND;
	ctx.name4 = ctx.base + PANEL_META_OFF_NAME4;
	ctx.ext4 = ctx.base + PANEL_META_OFF_EXT4;
	ctx.cpm4 = ctx.base + PANEL_META_OFF_LFN4;
	ctx.sizes = (unsigned long *)(ctx.base + PANEL_META_OFF_SIZE);
	ctx.dates = (unsigned short *)(ctx.base + PANEL_META_OFF_DATE);
	ctx.times = (unsigned short *)(ctx.base + PANEL_META_OFF_TIME);
	ctx.idx = (unsigned short *)(ctx.base + PANEL_META_OFF_IDX);
	ctx.sort_mode = panel->sort_mode;
	ctx.sort_desc = panel->sort_desc;

	n = panel->file_count;
	for (i = n / 2u; i > 0u; i--)
		panel_heap_sift_fn83(&ctx, n, i - 1u);

	for (i = n; i > 1u; i--)
	{
		unsigned short t;

		t = ctx.idx[0];
		ctx.idx[0] = ctx.idx[i - 1u];
		ctx.idx[i - 1u] = t;
		panel_heap_sift_fn83(&ctx, i - 1u, 0u);
	}

	panel_file_map(panel, 0);
}

static int panel_cmp_lfn_phys(const PanelLfnCtx *ctx, unsigned int pa, unsigned int pb)
{
	unsigned char ka;
	unsigned char kb;
	int cmp;
	const unsigned char *na;
	const unsigned char *nb;
	const unsigned char *ea;
	const unsigned char *eb;

	ka = ctx->kind[pa];
	kb = ctx->kind[pb];
	if (ka != kb)
		return sortfn_cmp_kind_meta(ka, kb);

	na = ctx->lfn4 + pa * PANEL_SORT_KEY_LEN;
	nb = ctx->lfn4 + pb * PANEL_SORT_KEY_LEN;
	ea = ctx->lfnext4 + pa * PANEL_SORT_KEY_LEN;
	eb = ctx->lfnext4 + pb * PANEL_SORT_KEY_LEN;

	switch (ctx->sort_mode)
	{
	case NC_PANEL_SORT_EXT:
		cmp = panel_cmp_key4_cached(ea, eb);
		if (cmp == 0)
			cmp = panel_cmp_key4_cached(na, nb);
		if (cmp == 0)
			cmp = panel_cmp_lfn_name_tail_meta(ctx->nm4 + pa * PANEL_SORT_KEY_LEN,
											   ctx->nm4 + pb * PANEL_SORT_KEY_LEN,
											   ctx->ex4 + pa * PANEL_SORT_KEY_LEN,
											   ctx->ex4 + pb * PANEL_SORT_KEY_LEN);
		if (cmp == 0)
			cmp = panel_cmp_lfn_tie_bank(ctx->panel, pa, pb);
		break;

	case NC_PANEL_SORT_SIZE:
		if (ctx->sizes[pa] < ctx->sizes[pb])
			cmp = -1;
		else if (ctx->sizes[pa] > ctx->sizes[pb])
			cmp = 1;
		else
		{
			cmp = panel_cmp_key4_cached(na, nb);
			if (cmp == 0)
				cmp = panel_cmp_lfn_name_tail_meta(ctx->nm4 + pa * PANEL_SORT_KEY_LEN,
												   ctx->nm4 + pb * PANEL_SORT_KEY_LEN,
												   ctx->ex4 + pa * PANEL_SORT_KEY_LEN,
												   ctx->ex4 + pb * PANEL_SORT_KEY_LEN);
			if (cmp == 0)
				cmp = panel_cmp_lfn_tie_bank(ctx->panel, pa, pb);
		}
		break;

	case NC_PANEL_SORT_TIME:
		if (ctx->dates[pa] < ctx->dates[pb])
			cmp = -1;
		else if (ctx->dates[pa] > ctx->dates[pb])
			cmp = 1;
		else if (ctx->times[pa] < ctx->times[pb])
			cmp = -1;
		else if (ctx->times[pa] > ctx->times[pb])
			cmp = 1;
		else
		{
			cmp = panel_cmp_key4_cached(na, nb);
			if (cmp == 0)
				cmp = panel_cmp_lfn_name_tail_meta(ctx->nm4 + pa * PANEL_SORT_KEY_LEN,
												   ctx->nm4 + pb * PANEL_SORT_KEY_LEN,
												   ctx->ex4 + pa * PANEL_SORT_KEY_LEN,
												   ctx->ex4 + pb * PANEL_SORT_KEY_LEN);
			if (cmp == 0)
				cmp = panel_cmp_lfn_tie_bank(ctx->panel, pa, pb);
		}
		break;

	case NC_PANEL_SORT_NAME:
	default:
		cmp = panel_cmp_key4_cached(na, nb);
		if (cmp == 0)
			cmp = panel_cmp_lfn_name_tail_meta(ctx->nm4 + pa * PANEL_SORT_KEY_LEN,
											   ctx->nm4 + pb * PANEL_SORT_KEY_LEN,
											   ctx->ex4 + pa * PANEL_SORT_KEY_LEN,
											   ctx->ex4 + pb * PANEL_SORT_KEY_LEN);
		if (cmp == 0)
			cmp = panel_cmp_lfn_tie_bank(ctx->panel, pa, pb);
		break;
	}

	if (ctx->sort_desc && cmp != 0)
		cmp = -cmp;
	return cmp;
}

static int panel_cmp_lfn_vis(const PanelLfnCtx *ctx, unsigned int vis_a, unsigned int vis_b)
{
	return panel_cmp_lfn_phys(ctx, (unsigned int)ctx->idx[vis_a], (unsigned int)ctx->idx[vis_b]);
}

static void panel_heap_sift_lfn(PanelLfnCtx *ctx, unsigned int heap_size, unsigned int root)
{
	unsigned int largest;
	unsigned int left;
	unsigned int right;
	int cmp;

	for (;;)
	{
		largest = root;
		left = root * 2u + 1u;
		right = left + 1u;
		if (left < heap_size)
		{
			cmp = panel_cmp_lfn_vis(ctx, left, largest);
			if (cmp > 0)
				largest = left;
		}
		if (right < heap_size)
		{
			cmp = panel_cmp_lfn_vis(ctx, right, largest);
			if (cmp > 0)
				largest = right;
		}
		if (largest == root)
			break;
		{
			unsigned short t;

			t = ctx->idx[root];
			ctx->idx[root] = ctx->idx[largest];
			ctx->idx[largest] = t;
		}
		root = largest;
	}
}

static void panel_heap_sort_lfn(PanelState *panel)
{
	PanelLfnCtx ctx;
	unsigned char *base;
	unsigned int n;
	unsigned int i;

	if (panel->file_count < 2u)
		return;

	panel_meta_map(panel);
	base = (unsigned char *)BANK_WINDOW_ADDRESS;
	ctx.panel = panel;
	ctx.kind = base + PANEL_META_OFF_KIND;
	ctx.lfn4 = base + PANEL_META_OFF_LFN4;
	ctx.lfnext4 = base + PANEL_META_OFF_LFNEXT4;
	ctx.nm4 = base + PANEL_META_OFF_NAME4;
	ctx.ex4 = base + PANEL_META_OFF_EXT4;
	ctx.sizes = (unsigned long *)(base + PANEL_META_OFF_SIZE);
	ctx.dates = (unsigned short *)(base + PANEL_META_OFF_DATE);
	ctx.times = (unsigned short *)(base + PANEL_META_OFF_TIME);
	ctx.idx = (unsigned short *)(base + PANEL_META_OFF_IDX);
	ctx.sort_mode = panel->sort_mode;
	ctx.sort_desc = panel->sort_desc;

	n = panel->file_count;
	for (i = n / 2u; i > 0u; i--)
		panel_heap_sift_lfn(&ctx, n, i - 1u);

	for (i = n; i > 1u; i--)
	{
		unsigned short t;

		t = ctx.idx[0];
		ctx.idx[0] = ctx.idx[i - 1u];
		ctx.idx[i - 1u] = t;
		panel_heap_sift_lfn(&ctx, i - 1u, 0u);
	}

	panel_file_map(panel, 0);
}

static void panel_refresh_sort_cache(PanelState *panel)
{
	unsigned int phys;
	unsigned char page;
	unsigned int off;

	for (phys = 0; phys < panel->file_count; phys++)
	{
		page = (unsigned char)(phys / FILES_PER_PAGE);
		off = phys % FILES_PER_PAGE;
		if (panel->sort_lfn)
			panel_cache_entry_lfn(panel, phys, off, page);
		else
			panel_cache_entry_short(panel, phys, off, page);
	}
}

static void panel_sort_indices(PanelState *panel)
{
	if (!panel->sort_lfn)
		panel_heap_sort_fn83(panel);
	else
		panel_heap_sort_lfn(panel);
}
/////////////////////////////////////////////////////////////////////////////////////////////////
static void panel_resort_keep_cursor(PanelState *panel)
{
	unsigned int real_at_cursor;
	unsigned int i;

	if (panel->file_count == 0u)
		return;

	real_at_cursor = panel_meta_get_index(panel, panel->cursor_idx);
	panel_sort_indices(panel);

	for (i = 0; i < panel->file_count; i++)
	{
		if (panel_meta_get_index(panel, i) == real_at_cursor)
		{
			panel->cursor_idx = i;
			break;
		}
	}
	if (panel->cursor_idx < panel->scroll_offset)
		panel->scroll_offset = panel->cursor_idx;
	if (panel->cursor_idx >= panel->scroll_offset + 18u)
		panel->scroll_offset = panel->cursor_idx - 18u + 1u;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static unsigned int *copy_cache_count_ptr(void)
{
	return (unsigned int *)BANK_WINDOW_ADDRESS;
}

static unsigned char *copy_cache_flags_ptr(void)
{
	return (unsigned char *)(BANK_WINDOW_ADDRESS + COPY_CACHE_FLAGS_OFF);
}

static char *copy_cache_name_ptr(unsigned int idx)
{
	return (char *)(BANK_WINDOW_ADDRESS + COPY_CACHE_NAMES_OFF + idx * 64u);
}

static unsigned char copy_is_dot_entry(const fileInfo *fi)
{
	if (fi->fname[0] == '.' && fi->fname[1] == 0)
		return 1;
	if (fi->fname[0] == '.' && fi->fname[1] == '.' &&
		(fi->fname[2] == 0 || fi->fname[2] == ' '))
		return 1;
	return 0;
}

static void copy_name_preserve_case(const fileInfo *fi, char *buf)
{
	unsigned int i;
	unsigned int j;

	buf[0] = 0;
	if (fi->lfname[0] != 0)
	{
		for (i = 0; i < 63u && fi->lfname[i] != 0; i++)
			buf[i] = (char)fi->lfname[i];
		buf[i] = 0;
		return;
	}

	j = 0;
	for (i = 0; i < 12u; i++)
	{
		if (fi->fname[i] == 0 || fi->fname[i] == ' ')
			break;
		buf[j++] = (char)fi->fname[i];
	}
	buf[j] = 0;
}

static void copy_store_name(unsigned int idx, const fileInfo *fi)
{
	copy_name_preserve_case(fi, copy_cache_name_ptr(idx));
}

static unsigned char copy_collect_dir(const char *base_src, unsigned int skip, unsigned char *dir_more_out)
{
	unsigned char res;
	unsigned int n;
	unsigned int skipped;
	unsigned int *pcount;
	unsigned char *pflags;

	if (!g_copy_page_active)
		return 0;

	if (OS_CHDIR((unsigned char *)base_src) != 0)
		return 0;

	OS_OPENDIR("");
	SETPG32KHIGH(g_copy_temp_page);

	pcount = copy_cache_count_ptr();
	pflags = copy_cache_flags_ptr();
	n = 0;
	skipped = 0;

	while (n < COPY_TEMP_PAGE_ENTRIES)
	{
		fileop_poll_abort();
		if (g_fileop_abort)
			break;
		panel_clear_finfo(&r_global_info);
		res = OS_READDIR(&r_global_info);
		if (res == 4)
			break;
		if (res != 0)
			return 0;

		if (copy_is_dot_entry(&r_global_info))
			continue;

		if (skipped < skip)
		{
			skipped++;
			continue;
		}

		copy_store_name(n, &r_global_info);
		panel_normalize_fname(&r_global_info);
		pflags[n] = (r_global_info.fattrib & 0x10) ? 1 : 0;
		copy_stack_map();
		copy_stack_dates_ptr(COPY_STACK_TMPDATE_OFF)[n] = r_global_info.fdate;
		copy_stack_dates_ptr(COPY_STACK_TMPTIME_OFF)[n] = r_global_info.ftime;
		SETPG32KHIGH(g_copy_temp_page);
		n++;
	}

	if (dir_more_out != 0)
	{
		if (n >= COPY_TEMP_PAGE_ENTRIES)
		{
			panel_clear_finfo(&r_global_info);
			res = OS_READDIR(&r_global_info);
			if (res == 4)
				*dir_more_out = 0;
			else if (res != 0)
				return 0;
			else
				*dir_more_out = 1;
		}
		else
			*dir_more_out = 0;
	}

	fileop_poll_abort();
	YIELD();

	*pcount = n;
	return g_fileop_abort ? 0 : 1;
}

static void copy_take_dir_snapshot(void)
{
	unsigned int i;
	unsigned int n;
	unsigned char fl;
	unsigned short *tmp_d;
	unsigned short *tmp_t;
	unsigned short *snap_d;
	unsigned short *snap_t;

	SETPG32KHIGH(g_copy_temp_page);
	n = *copy_cache_count_ptr();

	SETPG32KHIGH(g_copy_snap_page);
	*copy_cache_count_ptr() = n;

	for (i = 0; i < n; i++)
	{
		SETPG32KHIGH(g_copy_temp_page);
		fl = copy_cache_flags_ptr()[i];
		strcpy(r_src_full, copy_cache_name_ptr(i));
		SETPG32KHIGH(g_copy_snap_page);
		copy_cache_flags_ptr()[i] = fl;
		strcpy(copy_cache_name_ptr(i), r_src_full);
	}

	copy_stack_map();
	tmp_d = copy_stack_dates_ptr(COPY_STACK_TMPDATE_OFF);
	tmp_t = copy_stack_dates_ptr(COPY_STACK_TMPTIME_OFF);
	snap_d = copy_stack_dates_ptr(COPY_STACK_SNAPDATE_OFF);
	snap_t = copy_stack_dates_ptr(COPY_STACK_SNAPTIME_OFF);
	for (i = 0; i < n; i++)
	{
		snap_d[i] = tmp_d[i];
		snap_t[i] = tmp_t[i];
	}
}

static unsigned char panel_mark_get_phys(PanelState *panel, unsigned int phys_idx)
{
	unsigned char *base;

	if (phys_idx >= MAX_FILES_PER_PANEL)
		return 0;
	panel_meta_map(panel);
	base = (unsigned char *)BANK_WINDOW_ADDRESS;
	return base[PANEL_META_OFF_MARK + phys_idx];
}

static void panel_mark_set_phys(PanelState *panel, unsigned int phys_idx, unsigned char on)
{
	unsigned char *base;

	if (phys_idx >= MAX_FILES_PER_PANEL)
		return;
	panel_meta_map(panel);
	base = (unsigned char *)BANK_WINDOW_ADDRESS;
	base[PANEL_META_OFF_MARK + phys_idx] = on;
}

static void panel_mark_clear_all(PanelState *panel)
{
	if (!panel_banks_ok(panel))
		return;
	panel_meta_map(panel);
	memset((void *)(BANK_WINDOW_ADDRESS + PANEL_META_OFF_MARK), 0, (size_t)PANEL_META_MARK_BYTES);
}

static unsigned char panel_entry_marked(PanelState *panel, unsigned int list_pos)
{
	unsigned int phys;

	if (list_pos >= panel->file_count)
		return 0;
	phys = panel_meta_get_index(panel, list_pos);
	return panel_mark_get_phys(panel, phys);
}

static unsigned char copy_get_marked_count(PanelState *panel)
{
	unsigned int i;
	unsigned char cnt;

	cnt = 0;
	for (i = 0; i < panel->file_count; i++)
	{
		if (panel_entry_marked(panel, i))
			cnt++;
	}
	return cnt;
}

static unsigned char panel_item_at_vis(PanelState *panel, unsigned int list_pos, char *name_out,
									   unsigned char *is_dir_out)
{
	unsigned int real_idx;
	unsigned int page_offset;
	char *src;
	unsigned int i;

	if (list_pos >= panel->file_count)
		return 0;

	real_idx = panel_meta_get_index(panel, list_pos);
	switch_file_page(panel, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;

	src = panel_entry_name(&set.bank_array[page_offset]);

	for (i = 0; i < 63u && src[i] != 0; i++)
		name_out[i] = src[i];
	name_out[i] = 0;

	*is_dir_out = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;
	return 1;
}

static unsigned char copy_panel_item_at(PanelState *panel, unsigned int list_pos, char *name_out, unsigned char *is_dir_out)
{
	if (!panel_entry_marked(panel, list_pos))
		return 0;
	return panel_item_at_vis(panel, list_pos, name_out, is_dir_out);
}

PanelState left_panel;
PanelState right_panel;

struct coordinates
{
	unsigned char winX;
	unsigned char winY;
	unsigned char winW;
	unsigned char winH;
	unsigned char color;
};

static void ui_dlg_preset(DialogWindow *dlg, unsigned char x, unsigned char y, unsigned char w,
						  unsigned char h, unsigned char color, const char *title, const char *prompt);
static void ui_dlg_centered(DialogWindow *dlg, unsigned char w, unsigned char h, unsigned char y,
							unsigned char color, const char *title, const char *prompt);
static unsigned char ui_show_dialog(DialogWindow *dlg, char *buffer, unsigned char max_len,
									unsigned char btn_mask);
static unsigned char ui_dialog_input(const char *title, const char *prompt);
static unsigned char ui_dialog_confirm(const char *title, const char *prompt, unsigned char btn_mask);
static unsigned char ui_dialog_delete_confirm(const char *title, const char *prompt);
static void ui_print_centered(unsigned char x, unsigned char y, unsigned char width, const char *str);
static void ui_alert_dialog(const char *title, const char *prompt);

static void nc_ini_rtrim(char *s)
{
	unsigned int n;

	n = 0;
	while (s[n] != 0)
		n++;
	while (n > 0u && (s[n - 1u] == ' ' || s[n - 1u] == '\t' || s[n - 1u] == '\r' || s[n - 1u] == '\n'))
	{
		n--;
		s[n] = 0;
	}
}

static unsigned char nc_ini_drive_hidden(unsigned char letter)
{
	const char *p;
	unsigned char u;

	u = letter;
	if (u >= 'a' && u <= 'z')
		u = (unsigned char)(u - 'a' + 'A');
	p = g_ini_hide_drives;
	while (*p != 0)
	{
		unsigned char c;

		c = (unsigned char)*p;
		if (c == ',' || c == ' ' || c == '\t')
		{
			p++;
			continue;
		}
		if (c >= 'a' && c <= 'z')
			c = (unsigned char)(c - 'a' + 'A');
		if (c == u)
		{
			p++;
			if (*p == 0 || *p == ',' || *p == ' ' || *p == '\t')
				return 1;
		}
		p++;
	}
	return 0;
}

static const char *nc_ini_sort_mode_name(unsigned char mode)
{
	switch (mode)
	{
	case NC_PANEL_SORT_EXT:
		return "ext";
	case NC_PANEL_SORT_SIZE:
		return "size";
	case NC_PANEL_SORT_TIME:
		return "time";
	default:
		return "name";
	}
}

static unsigned char nc_ini_set_location(void)
{
	unsigned int res;

	res = OS_SETSYSDRV();
	if ((res & 0xff00u) != 0u)
		return 0;
	return (unsigned char)(OS_CHDIR((unsigned char *)NC_INI_DIR) == 0);
}

static void nc_ini_restore_cwd(void)
{
	PanelState *active;

	active = left_panel.is_active ? &left_panel : &right_panel;
	panel_chdir_only(active->current_path);
}

static void nc_ini_append(char *buf, unsigned int *pos, const char *text)
{
	unsigned int n;

	n = 0;
	while (text[n] != 0)
		n++;
	if (*pos + n >= NC_INI_BUF_SIZE - 1u)
		return;
	memcpy(buf + *pos, text, n);
	*pos += n;
	buf[*pos] = 0;
}

static void nc_ini_append_u8(char *buf, unsigned int *pos, unsigned char v)
{
	char tmp[4];
	unsigned char n;

	n = 0;
	if (v >= 100u)
	{
		tmp[n++] = (char)('0' + (v / 100u));
		v = (unsigned char)(v % 100u);
	}
	if (n > 0u || v >= 10u)
	{
		tmp[n++] = (char)('0' + (v / 10u));
		v = (unsigned char)(v % 10u);
	}
	tmp[n++] = (char)('0' + v);
	tmp[n] = 0;
	nc_ini_append(buf, pos, tmp);
}

static void nc_ini_append_kv(char *buf, unsigned int *pos, const char *key, const char *val)
{
	nc_ini_append(buf, pos, key);
	nc_ini_append(buf, pos, "=");
	nc_ini_append(buf, pos, val);
	nc_ini_append(buf, pos, "\r\n");
}

static void nc_ini_append_kv_u8(char *buf, unsigned int *pos, const char *key, unsigned char val)
{
	nc_ini_append(buf, pos, key);
	nc_ini_append(buf, pos, "=");
	nc_ini_append_u8(buf, pos, val);
	nc_ini_append(buf, pos, "\r\n");
}

static void nc_ini_save(void)
{
	FILE *fp;
	unsigned int pos;

	pos = 0;
	g_ini_buf[0] = 0;
	nc_ini_append(g_ini_buf, &pos, "# NC settings\r\n");
	nc_ini_append_kv(g_ini_buf, &pos, "LeftPath", left_panel.current_path);
	nc_ini_append_kv(g_ini_buf, &pos, "RightPath", right_panel.current_path);
	nc_ini_append_kv(g_ini_buf, &pos, "LeftSort", nc_ini_sort_mode_name(left_panel.sort_mode));
	nc_ini_append_kv(g_ini_buf, &pos, "RightSort", nc_ini_sort_mode_name(right_panel.sort_mode));
	nc_ini_append_kv(g_ini_buf, &pos, "LeftSortDir", left_panel.sort_desc ? "desc" : "asc");
	nc_ini_append_kv(g_ini_buf, &pos, "RightSortDir", right_panel.sort_desc ? "desc" : "asc");
	nc_ini_append_kv_u8(g_ini_buf, &pos, "LeftSortLfn", left_panel.sort_lfn);
	nc_ini_append_kv_u8(g_ini_buf, &pos, "RightSortLfn", right_panel.sort_lfn);
	nc_ini_append_kv_u8(g_ini_buf, &pos, "LeftActive", left_panel.is_active);
	nc_ini_append(g_ini_buf, &pos, "# Comma-separated letters to hide in drive menu (e.g. J,K,L)\r\n");
	nc_ini_append_kv(g_ini_buf, &pos, "HideDrives", g_ini_hide_drives);
	nc_ini_append(g_ini_buf, &pos, "# F3 viewer / F4 editor: .com launched with file path as argument\r\n");
	nc_ini_append_kv(g_ini_buf, &pos, "Viewer", g_ini_viewer);
	nc_ini_append_kv(g_ini_buf, &pos, "Editor", g_ini_editor);
	nc_ini_append(g_ini_buf, &pos, "# 1 = re-read both panels when app regains focus (key 31)\r\n");
	nc_ini_append_kv_u8(g_ini_buf, &pos, "ReadOnFocus", g_ini_read_on_focus);

	if (!nc_ini_set_location())
	{
		nc_ini_restore_cwd();
		return;
	}
	fp = OS_CREATEHANDLE((unsigned char *)NC_INI_NAME, 0x80);
	if (((int)fp) & 0xff)
	{
		nc_ini_restore_cwd();
		return;
	}
	(void)OS_WRITEHANDLE((unsigned char *)g_ini_buf, fp, pos);
	OS_CLOSEHANDLE(fp);
	nc_ini_restore_cwd();
}

static void print_cstr(const char *s)
{
	unsigned char i;

	i = 0;
	while (s[i] != 0)
	{
		putchar(s[i]);
		i++;
	}
}

static void print_crlf(void)
{
	putchar('\r');
	putchar('\n');
}

void fast_print_str_width(const char *str, unsigned char width)
{
	unsigned char i;
	i = 0;

	while (str[i] != 0 && i < width)
	{
		putchar(str[i]);
		i++;
	}
}

static void BDBOX(unsigned char Xbox, unsigned char Ybox, unsigned char Wbox, unsigned char Hbox,
				  unsigned char Cbox, unsigned char character)
{
	unsigned char x;
	unsigned char y;

	OS_SETCOLOR(Cbox);
	for (y = 0; y < Hbox; y++)
	{
		OS_SETXY(Xbox, (unsigned char)(Ybox + y));
		for (x = 0; x < Wbox; x++)
			putchar(character);
	}
}

void switch_file_page(PanelState *panel, unsigned int file_idx)
{
	unsigned char page_num;

	page_num = (unsigned char)(file_idx / FILES_PER_PAGE);
	if (page_num >= PANEL_FILE_PAGES)
		page_num = (unsigned char)(PANEL_FILE_PAGES - 1);
	panel_file_map(panel, page_num);
}

static void panels_remap_bank_window(void)
{
	unsigned int vis;
	unsigned int phys;

	if (left_panel.file_count > 0u)
	{
		vis = left_panel.scroll_offset;
		if (vis >= left_panel.file_count)
			vis = 0u;
		phys = panel_meta_get_index(&left_panel, vis);
		switch_file_page(&left_panel, phys);
	}
	else
		panel_file_map(&left_panel, 0);

	if (right_panel.file_count > 0u)
	{
		vis = right_panel.scroll_offset;
		if (vis >= right_panel.file_count)
			vis = 0u;
		phys = panel_meta_get_index(&right_panel, vis);
		switch_file_page(&right_panel, phys);
	}
	else
		panel_file_map(&right_panel, 0);
}

static void copy_io_unmap(void)
{
	if (g_copy_page_active)
		SETPG32KHIGH(residentPg);
	else
	{
		panels_remap_bank_window();
		SETPG32KHIGH(residentPg);
	}
}

static void panel_place_cursor_on_dotdot(PanelState *panel)
{
	unsigned int i;
	unsigned int phys;
	unsigned char *base;
	unsigned char k;

	if (panel->file_count == 0u)
	{
		panel->cursor_idx = 0;
		panel->scroll_offset = 0;
		return;
	}

	panel_meta_map(panel);
	base = (unsigned char *)BANK_WINDOW_ADDRESS;
	for (i = 0; i < panel->file_count; i++)
	{
		phys = panel_meta_idx_get(base, i);
		k = base[PANEL_META_OFF_KIND + phys];
		if (k == PANEL_KIND_DOTDOT)
		{
			panel->cursor_idx = i;
			panel->scroll_offset = 0;
			panel_file_map(panel, (unsigned char)(phys / FILES_PER_PAGE));
			panel_clamp_scroll(panel);
			return;
		}
	}
	panel->cursor_idx = 0;
	panel->scroll_offset = 0;
	panel_file_map(panel, 0);
	panel_clamp_scroll(panel);
}

static unsigned char read_panel_dir_at(PanelState *panel, const char *dir_path, unsigned char preserve_cursor)
{
	unsigned char result;
	unsigned int idx;

	unsigned int page_offset;
	unsigned char current_page;
	char req_path[64];
	char saved_name[64];
	unsigned int saved_scroll;
	unsigned int restore_idx;
	unsigned char have_saved;

	if (!panel_banks_ok(panel))
	{
		panel->file_count = 0;
		panel->files_only_count = 0;
		panel->total_bytes = 0;
		panel->cursor_idx = 0;
		panel->scroll_offset = 0;
		return 0;
	}

	panel_path_normalize(panel, dir_path);
	strncpy(req_path, panel->current_path, sizeof(req_path) - 1u);
	req_path[sizeof(req_path) - 1u] = 0;

	have_saved = 0;
	if (preserve_cursor && panel->file_count > 0u && panel->cursor_idx < panel->file_count)
	{
		unsigned int save_ridx;

		save_ridx = panel_meta_get_index(panel, panel->cursor_idx);
		switch_file_page(panel, save_ridx);
		page_offset = save_ridx % FILES_PER_PAGE;
		strncpy(saved_name, panel_entry_name(&set.bank_array[page_offset]), sizeof(saved_name) - 1u);
		saved_name[sizeof(saved_name) - 1u] = 0;
		saved_scroll = panel->scroll_offset;
		have_saved = 1;
	}

	current_page = 0;
	panel_file_map(panel, current_page);
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;

	if (!panel_chdir_for_read(req_path))
	{
		panel->file_count = 0;
		panel->files_only_count = 0;
		panel->total_bytes = 0;
		panel->cursor_idx = 0;
		panel->scroll_offset = 0;
		panel_file_map(panel, 0);
		return 0;
	}

	idx = 0;
	panel->file_count = 0;
	panel->files_only_count = 0;
	panel->total_bytes = 0;
	panel_meta_map(panel);
	panel_mark_clear_all(panel);
	if (panel->sort_lfn)
		panel_page_extra_clear(panel, 0);

	while (idx < MAX_FILES_PER_PANEL)
	{
		page_offset = idx % FILES_PER_PAGE;

		if (idx > 0 && page_offset == 0)
		{
			current_page++;
			if (current_page >= PANEL_FILE_PAGES)
				break;
			if (panel->sort_lfn)
				panel_page_extra_clear(panel, current_page);
			else
				panel_file_map(panel, current_page);
		}
		else
			panel_file_map(panel, current_page);

		panel_prep_finfo_for_readdir(&set.bank_array[page_offset]);
		result = OS_READDIR(&set.bank_array[page_offset]);
		if (result == 4)
			break;
		if (result != 0)
			break;

		panel_normalize_fname(&set.bank_array[page_offset]);

		if (set.bank_array[page_offset].fname[0] == '.' && set.bank_array[page_offset].fname[1] == 0)
			continue;
		if (set.bank_array[page_offset].fname[0] == 0)
			continue;

		{
			unsigned char is_dir;
			unsigned long fsize;

			is_dir = (set.bank_array[page_offset].fattrib & 0x10) ? 1u : 0u;
			fsize = set.bank_array[page_offset].fsize;
			if (panel->sort_lfn)
				panel_cache_entry_lfn(panel, idx, page_offset, current_page);
			else
				panel_cache_entry_short_fi(panel, idx, &set.bank_array[page_offset]);
			if (!is_dir)
			{
				panel->files_only_count++;
				panel->total_bytes += fsize;
			}
		}
		idx++;
	}

	panel->file_count = idx;

	if (panel->file_count >= 2u)
	{
		if (panel->file_count > PANEL_SORT_NOTICE_FILES)
		{
			SETPG32KHIGH(residentPg);
			panel_sort_notice_show(panel);
		}
		panel_sort_indices(panel);
	}

	if (have_saved && panel_find_by_name(panel, saved_name, &restore_idx))
	{
		panel->cursor_idx = restore_idx;
		panel->scroll_offset = saved_scroll;
		panel_clamp_scroll(panel);
	}
	else
		panel_place_cursor_on_dotdot(panel);

	panel_path_normalize(panel, req_path);
	return 1;
}

void fast_print_str_pad(const char *str, unsigned char width)
{
	unsigned char i;

	fast_print_str_width(str, width);
	for (i = 0; str[i] != 0 && i < width; i++)
		;
	while (i < width)
	{
		putchar(' ');
		i++;
	}
}

#define SZ_1MB 1048576UL
#define SZ_100MB 104857600UL
#define PANEL_ROW_WIDTH 38u

static char g_panel_row[PANEL_ROW_WIDTH + 1u];
static unsigned char g_panel_row_marked;
static unsigned char g_panel_row_marked_row[18];
static unsigned int g_panel_row_phys[18];

static const char g_month_abbr[12][2] = {
	{'j', 'a'}, {'f', 'b'}, {'m', 'r'}, {'a', 'p'}, {'m', 'y'}, {'j', 'n'}, {'j', 'l'}, {'a', 'g'}, {'s', 'p'}, {'o', 'c'}, {'n', 'v'}, {'d', 'c'}};

static void panel_row_format(const fileInfo *fi);
static void panel_row_format_empty(void);
static void draw_panel_row_empty(unsigned char start_x, unsigned char row_y);
static void ui_panel_fmt_size(char *dst, unsigned long size, unsigned char is_dir);

static void panel_row_out(unsigned char start_x, unsigned char row_y, unsigned int file_idx, const PanelState *panel)
{
	unsigned char i;

	SETPG32KHIGH(residentPg);
	OS_SETXY((unsigned char)(start_x + 1u), (unsigned char)(3u + row_y));
	if (file_idx == panel->cursor_idx && panel->is_active)
	{
		if (g_panel_row_marked)
			OS_SETCOLOR(COLOR_PANEL_CURSOR_MARKED);
		else
			OS_SETCOLOR(COLOR_PANEL_CURSOR);
	}
	else if (g_panel_row_marked)
		OS_SETCOLOR(COLOR_PANEL_MARKED);
	else
		OS_SETCOLOR(COLOR_PANEL_MAIN);
	for (i = 0; i < PANEL_ROW_WIDTH; i++)
		putchar((unsigned char)g_panel_row[i]);
}

static void panel_draw_vis_row(PanelState *panel, unsigned char start_x, unsigned char row_y, unsigned int vis_idx)
{
	unsigned int phys_idx;
	const unsigned char *meta_base;

	panel_meta_map(panel);
	meta_base = (const unsigned char *)BANK_WINDOW_ADDRESS;
	phys_idx = panel_meta_idx_get(meta_base, vis_idx);
	g_panel_row_marked = meta_base[PANEL_META_OFF_MARK + phys_idx];
	switch_file_page(panel, phys_idx);
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	panel_row_format(&set.bank_array[phys_idx % FILES_PER_PAGE]);
	panel_row_out(start_x, row_y, vis_idx, panel);
}

static void panel_fmt_pad(char *dst, const char *src, unsigned char width)
{
	unsigned char i;

	i = 0;
	while (src[i] != 0 && i < width)
	{
		dst[i] = src[i];
		i++;
	}
	while (i < width)
		dst[i++] = ' ';
}

static void panel_fmt_datetime(char *dst, unsigned int fdate, unsigned int ftime)
{
	unsigned char day;
	unsigned char month;
	unsigned char year_short;
	unsigned char hour;
	unsigned char minute;
	unsigned char i;
	unsigned char mi;

	day = (unsigned char)(fdate & 0x1F);
	month = (unsigned char)((fdate >> 5) & 0x0F);
	year_short = (unsigned char)((((fdate >> 9) & 0x7F) + 1980) % 100);
	minute = (unsigned char)((ftime >> 5) & 0x3F);
	hour = (unsigned char)((ftime >> 11) & 0x1F);

	i = 0;
	dst[i++] = (unsigned char)('0' + (day / 10));
	dst[i++] = (unsigned char)('0' + (day % 10));
	if (month >= 1u && month <= 12u)
	{
		mi = (unsigned char)(month - 1u);
		dst[i++] = g_month_abbr[mi][0];
		dst[i++] = g_month_abbr[mi][1];
	}
	else
	{
		dst[i++] = '?';
		dst[i++] = '?';
	}
	dst[i++] = (unsigned char)('0' + (year_short / 10));
	dst[i++] = (unsigned char)('0' + (year_short % 10));
	dst[i++] = ' ';
	dst[i++] = (unsigned char)('0' + (hour / 10));
	dst[i++] = (unsigned char)('0' + (hour % 10));
	dst[i++] = ':';
	dst[i++] = (unsigned char)('0' + (minute / 10));
	dst[i++] = (unsigned char)('0' + (minute % 10));
	while (i < 12u)
		dst[i++] = ' ';
}

static void panel_row_format(const fileInfo *fi)
{
	const char *src;

	src = panel_entry_name((fileInfo *)fi);
	panel_fmt_pad(g_panel_row, src, 18);
	g_panel_row[18] = (char)179;
	ui_panel_fmt_size(g_panel_row + 19, fi->fsize, (unsigned char)((fi->fattrib & 0x10) ? 1 : 0));
	g_panel_row[25] = (char)179;
	panel_fmt_datetime(g_panel_row + 26, fi->fdate, fi->ftime);
}

static void panel_row_format_empty(void)
{
	unsigned char i;

	for (i = 0; i < PANEL_ROW_WIDTH; i++)
		g_panel_row[i] = ' ';
	g_panel_row[18] = (char)179;
	g_panel_row[25] = (char)179;
}

static void draw_panel_row_empty(unsigned char start_x, unsigned char row_y)
{
	g_panel_row_marked = 0;
	panel_row_format_empty();
	panel_row_out(start_x, row_y, 0xFFFFu, &left_panel);
}

void fast_print_size(unsigned long size)
{
	unsigned int total_mb;
	unsigned int whole;
	unsigned int frac;
	unsigned char d[6];
	unsigned char i;
	unsigned char lead;

	if (size >= SZ_100MB)
	{
		total_mb = (unsigned int)(size / SZ_1MB);
		whole = total_mb / 1024u;
		frac = (total_mb % 1024u) * 100u / 1024u;
		putchar((unsigned char)('0' + whole));
		putchar('.');
		putchar((unsigned char)('0' + frac / 10u));
		putchar((unsigned char)('0' + frac % 10u));
		putchar('G');
		putchar(' ');
		return;
	}

	if (size >= SZ_1MB)
	{
		whole = (unsigned int)(size / SZ_1MB);
		frac = (unsigned int)(((size % SZ_1MB) * 100UL) / SZ_1MB);
		if (whole >= 10u)
			putchar((unsigned char)('0' + whole / 10u));
		else
			putchar(' ');
		putchar((unsigned char)('0' + whole % 10u));
		putchar('.');
		putchar((unsigned char)('0' + frac / 10u));
		putchar((unsigned char)('0' + frac % 10u));
		putchar('M');
		return;
	}

	d[5] = (unsigned char)(size % 10UL);
	size /= 10UL;
	d[4] = (unsigned char)(size % 10UL);
	size /= 10UL;
	d[3] = (unsigned char)(size % 10UL);
	size /= 10UL;
	d[2] = (unsigned char)(size % 10UL);
	size /= 10UL;
	d[1] = (unsigned char)(size % 10UL);
	size /= 10UL;
	d[0] = (unsigned char)(size % 10UL);

	lead = 0;
	for (i = 0; i < 5u; i++)
	{
		if (d[i] != 0u || lead)
		{
			putchar((unsigned char)('0' + d[i]));
			lead = 1;
		}
		else
			putchar(' ');
	}
	putchar((unsigned char)('0' + d[5]));
}

void draw_bottom_info(PanelState *active_p)
{
	unsigned int phys_idx;
	unsigned int page_offset;
	const unsigned char *meta_base;
	char *full_name;
	static char bottom_name[65];
	unsigned long f_size;
	unsigned char is_dir;

	panel_meta_map(active_p);
	meta_base = (const unsigned char *)BANK_WINDOW_ADDRESS;
	phys_idx = panel_meta_idx_get(meta_base, active_p->cursor_idx);
	switch_file_page(active_p, phys_idx);
	page_offset = phys_idx % FILES_PER_PAGE;
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	full_name = panel_entry_name(&set.bank_array[page_offset]);
	f_size = set.bank_array[page_offset].fsize;
	is_dir = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;

	strncpy(bottom_name, full_name, 64u);
	bottom_name[64] = 0;

	SETPG32KHIGH(residentPg);
	OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLACK, WHITE));
	OS_SETXY(0, 22);

	fast_print_str_pad("Sz:", 3);
	if (is_dir)
	{
		fast_print_str_pad("<DIR>", 10);
	}
	else
	{
		fast_print_size(f_size);
		putchar(' ');
		putchar(' ');
		putchar(' ');
	}

	fast_print_str_pad("Nm:", 3);
	fast_print_str_pad(bottom_name, 64);
}

void draw_panel_frame(unsigned char start_x, unsigned char color)
{
	unsigned char q;
	unsigned char width = 39;

	OS_SETCOLOR(color);
	OS_SETXY(start_x, 0);
	putchar(201);
	for (q = 1; q < width; q++)
		putchar(205);
	putchar(187);

	for (q = 1; q <= 21; q++)
	{
		OS_SETXY(start_x, q);
		putchar(186);
		OS_SETXY((unsigned char)(start_x + width), q);
		putchar(186);
	}

	OS_SETXY(start_x, 21);
	putchar(200);
	for (q = 1; q < width; q++)
		putchar(205);
	putchar(188);
}

static void ui_panel_fmt_size(char *dst, unsigned long size, unsigned char is_dir)
{
	unsigned char c000_saved;

	c000_saved = bank_window_current();
	SETPG32KHIGH(residentPg);
	panel_fmt_size(dst, size, is_dir);
	SETPG32KHIGH(c000_saved);
}

static void ui_panel_draw_footer(PanelState *panel, unsigned char start_x)
{
	unsigned char c000_saved;

	c000_saved = bank_window_current();
	SETPG32KHIGH(residentPg);
	panel_draw_footer(panel, start_x);
	SETPG32KHIGH(c000_saved);
}

void draw_panel_background(PanelState *panel, unsigned char start_x)
{
	int i;

	draw_panel_frame(start_x, COLOR_PANEL_MAIN);

	OS_SETCOLOR(COLOR_PANEL_MAIN);
	OS_SETXY((unsigned char)(start_x + 2), 0);
	putchar('[');
	i = 0;
	while (panel->current_path[i] != 0)
	{
		putchar((unsigned char)panel->current_path[i]);
		i++;
	}
	putchar(']');

	OS_SETXY((unsigned char)(start_x + 1), 1);
	OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));

	fast_print_str_pad("Name", 18);
	putchar(179);
	fast_print_str_pad("Size", 6);
	putchar(179);
	fast_print_str_pad(" Date/Time", 12);

	OS_SETXY((unsigned char)(start_x + 1), 2);
	OS_SETCOLOR(COLOR_PANEL_MAIN);
	for (i = 0; i < 38; i++)
		putchar(196);

	ui_panel_draw_footer(panel, start_x);
}

static void draw_panel(PanelState *panel, unsigned char start_x, unsigned char height)
{
	unsigned char i;
	unsigned int vis_idx;
	unsigned int phys_idx;
	const unsigned char *meta_base;

	if (panel->file_count == 0u)
	{
		for (i = 0; i < height; i++)
			draw_panel_row_empty(start_x, i);
		return;
	}

	panel_meta_map(panel);
	meta_base = (const unsigned char *)BANK_WINDOW_ADDRESS;
	for (i = 0; i < height; i++)
	{
		vis_idx = panel->scroll_offset + (unsigned int)i;
		if (vis_idx >= panel->file_count)
		{
			g_panel_row_phys[i] = 0xFFFFu;
			g_panel_row_marked_row[i] = 0;
		}
		else
		{
			phys_idx = panel_meta_idx_get(meta_base, vis_idx);
			g_panel_row_phys[i] = phys_idx;
			g_panel_row_marked_row[i] = meta_base[PANEL_META_OFF_MARK + phys_idx];
		}
	}

	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	for (i = 0; i < height; i++)
	{
		vis_idx = panel->scroll_offset + (unsigned int)i;
		if (vis_idx >= panel->file_count)
		{
			draw_panel_row_empty(start_x, i);
			continue;
		}
		phys_idx = g_panel_row_phys[i];
		g_panel_row_marked = g_panel_row_marked_row[i];
		switch_file_page(panel, phys_idx);
		panel_row_format(&set.bank_array[phys_idx % FILES_PER_PAGE]);
		panel_row_out(start_x, i, vis_idx, panel);
	}
}

static void redraw_panels_full(void)
{
	PanelState *active_p;

	SETPG32KHIGH(residentPg);
	active_p = (left_panel.is_active) ? &left_panel : &right_panel;
	draw_panel_background(&left_panel, 0);
	draw_panel_background(&right_panel, 40);
	draw_panel(&left_panel, 0, 18);
	draw_panel(&right_panel, 40, 18);
	draw_bottom_info(active_p);
	draw_status_bar();
}

typedef struct
{
	unsigned char letter;
	const char *caption;
	unsigned char filter;
} PanelDriveDef;

static const PanelDriveDef g_drive_table[] = {
	{'A', "1st Floppy", DRVF_TRDOS},
	{'B', "2nd Floppy", DRVF_TRDOS},
	{'C', "3rd Floppy", DRVF_TRDOS},
	{'D', "4th Floppy", DRVF_TRDOS},
	{'E', "IDE Master p.1", DRVF_NONE},
	{'F', "IDE Master p.2", DRVF_NONE},
	{'G', "IDE Master p.3", DRVF_NONE},
	{'H', "IDE Master p.4", DRVF_NONE},
	{'I', "IDE Slave p.1", DRVF_NONE},
	{'J', "IDE Slave p.2", DRVF_NONE},
	{'K', "IDE Slave p.3", DRVF_NONE},
	{'L', "IDE Slave p.4", DRVF_NONE},
	{'M', "SD Z-controller", DRVF_NONE},
	{'N', "SD NeoGS", DRVF_NEOGS},
	{'O', "USB flash zx-net", DRVF_ZXNET},
};

#define PANEL_DRIVE_TABLE_LEN (sizeof(g_drive_table) / sizeof(g_drive_table[0]))

static unsigned char panel_drive_chdrv_ok(unsigned char letter)
{
	return (unsigned char)(OS_CHDRV(letter) == 0u);
}

static void panel_drive_build_list(const PanelState *panel)
{
	unsigned char i;
	unsigned char saved;
	unsigned char neogs;
	char saved_path[64];

	strncpy(saved_path, panel->current_path, sizeof(saved_path) - 1u);
	saved_path[sizeof(saved_path) - 1u] = 0;
	saved = panel_drive_saved_letter(panel);
	neogs = panel_hw_neogs_sd_present();
	/* zxnet = panel_hw_zxnet_present(); always show O: (probe disabled) */
	g_drive_count = 0;

	for (i = 0; i < PANEL_DRIVE_TABLE_LEN; i++)
	{
		const PanelDriveDef *def = &g_drive_table[i];

		if (def->filter == DRVF_NEOGS && neogs == 0u)
			continue;
		/* if (def->filter == DRVF_ZXNET && zxnet == 0u) continue; */
		if ((def->filter & (DRVF_TRDOS | DRVF_ZXNET)) == 0u && !panel_drive_chdrv_ok(def->letter))
			continue;
		if (nc_ini_drive_hidden(def->letter))
			continue;
		g_drive_letters[g_drive_count] = def->letter;
		panel_drive_format_line(g_drive_labels[g_drive_count], def->letter, def->caption);
		g_drive_count++;
		if (g_drive_count >= PANEL_DRIVE_MAX)
			break;
	}

	OS_CHDRV(saved);
	panel_chdir_only(saved_path);
}

static unsigned char panel_drive_popup_x_for(const PanelState *panel)
{
	unsigned char start;

	/* Center ~26-col menu inside the 40-col active panel column. */
	start = (panel == &right_panel) ? PANEL_COL_RIGHT : PANEL_COL_LEFT;
	return (unsigned char)(start + (PANEL_COL_WIDTH - DRIVE_POPUP_INNER_W - 2u) / 2u);
}

static unsigned char panel_drive_popup_inner_h(void)
{
	unsigned char n;

	/* h = Y offset of bottom border; need one row below last drive line */
	n = g_drive_count;
	if (n == 0u)
		n = 1u;
	return (unsigned char)(n + 1u);
}

static void panel_drive_draw_row(unsigned char idx, unsigned char selected)
{
	unsigned char y;

	if (idx >= g_drive_count)
		return;
	y = (unsigned char)(DRIVE_POPUP_Y + 1u + idx);
	menu_draw_item((unsigned char)(g_drive_popup_x + 1u), y, DRIVE_ITEM_W, selected, g_drive_labels[idx], 0);
}

static void panel_drive_redraw(void)
{
	unsigned char i;
	unsigned char inner_h;

	inner_h = panel_drive_popup_inner_h();
	ui_draw_frame(g_drive_popup_x, DRIVE_POPUP_Y, DRIVE_POPUP_INNER_W, inner_h, COLOR_MENU_NORM, "Drive");
	for (i = 0; i < g_drive_count; i++)
		panel_drive_draw_row(i, (unsigned char)(i == g_drive_sel));
}

static void panel_drive_open(PanelState *panel)
{
	unsigned char i;
	unsigned char saved;

	panel_drive_build_list(panel);
	g_drive_popup_x = panel_drive_popup_x_for(panel);
	g_drive_panel = panel;
	g_drive_active = 1;
	g_drive_sel = 0;
	saved = panel_drive_saved_letter(panel);
	for (i = 0; i < g_drive_count; i++)
	{
		if (g_drive_letters[i] == saved)
		{
			g_drive_sel = i;
			break;
		}
	}
	panel_drive_redraw();
}

static void panel_drive_close(void)
{
	g_drive_active = 0;
	g_drive_panel = NULL;
	g_drive_sel = 0;
	panels_remap_bank_window();
	redraw_panels_full();
	draw_bottom_info((left_panel.is_active) ? &left_panel : &right_panel);
}

static void panel_drive_msg(unsigned char letter, const char *text)
{
	unsigned char i;

	i = 0;
	set.temp_path[i++] = (char)letter;
	set.temp_path[i++] = ':';
	set.temp_path[i++] = ' ';
	while (text[0] != 0 && i < sizeof(set.temp_path) - 1u)
	{
		set.temp_path[i++] = text[0];
		text++;
	}
	set.temp_path[i] = 0;

	ui_alert_dialog("Drive error", set.temp_path);
}

static unsigned char panel_drive_apply(PanelState *panel, unsigned char letter)
{
	char path[8];
	char saved_path[64];
	unsigned char saved_letter;
	unsigned char start_x;

	strncpy(saved_path, panel->current_path, sizeof(saved_path) - 1u);
	saved_path[sizeof(saved_path) - 1u] = 0;
	saved_letter = panel_drive_saved_letter(panel);

	if (OS_CHDRV(letter) != 0u)
	{
		panel_drive_msg(letter, "not available");
		return 0;
	}

	path[0] = (char)letter;
	path[1] = ':';
	path[2] = '/';
	path[3] = 0;

	panel->cursor_idx = 0u;
	panel->scroll_offset = 0u;
	if (!read_panel_dir_at(panel, path, 0))
	{
		OS_CHDRV(saved_letter);
		read_panel_dir_at(panel, saved_path, 1);
		panel_chdir_only(saved_path);
		panel_drive_msg(letter, "cannot read");
		start_x = (panel == &left_panel) ? 0u : 40u;
		panels_remap_bank_window();
		draw_panel_background(panel, start_x);
		draw_panel(panel, start_x, 18);
		return 0;
	}

	panel_chdir_only(panel->current_path);
	start_x = (panel == &left_panel) ? 0u : 40u;
	panels_remap_bank_window();
	draw_panel_background(panel, start_x);
	draw_panel(panel, start_x, 18);
	return 1;
}

static void panel_drive_sel_move(unsigned char new_sel)
{
	unsigned char old_sel;

	if (g_drive_count == 0u)
		return;
	if (new_sel >= g_drive_count)
		new_sel = (unsigned char)(g_drive_count - 1u);
	old_sel = g_drive_sel;
	if (new_sel == old_sel)
		return;
	g_drive_sel = new_sel;
	panel_drive_draw_row(old_sel, 0);
	panel_drive_draw_row(new_sel, 1);
}

static unsigned char panel_drive_handle_key(unsigned char key)
{
	PanelState *panel;

	panel = g_drive_panel;
	if (panel == NULL)
		return 1;

	if (key == 27)
	{
		panel_drive_close();
		return 1;
	}
	if (g_drive_count == 0u)
		return 1;

	if (key == 250 || key == 248)
	{
		if (g_drive_sel > 0u)
			panel_drive_sel_move((unsigned char)(g_drive_sel - 1u));
		return 1;
	}
	if (key == 249 || key == 251)
	{
		if (g_drive_sel + 1u < g_drive_count)
			panel_drive_sel_move((unsigned char)(g_drive_sel + 1u));
		return 1;
	}
	if (key == 13)
	{
		panel_drive_apply(panel, g_drive_letters[g_drive_sel]);
		panel_drive_close();
		return 1;
	}
	return 1;
}

void menu_close_and_redraw(void)
{
	g_menu_active = 0;
	g_menu_level = NC_MENU_LEVEL_TOP;
	g_menu_sel = 0;
	panels_remap_bank_window();
	redraw_panels_full();
}

void menu_apply_choice(unsigned char choice)
{
	PanelState *active_p;
	unsigned char resort;

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;
	resort = 1;

	if (choice <= NC_MFI_TIME)
		active_p->sort_mode = choice;
	else if (choice == NC_MFI_AZ)
		active_p->sort_desc = 0;
	else if (choice == NC_MFI_ZA)
		active_p->sort_desc = 1;
	else if (choice == NC_MFI_LFN_SORT)
	{
		active_p->sort_lfn = (unsigned char)(active_p->sort_lfn ? 0u : 1u);
		if (active_p->file_count > 0u)
			panel_refresh_sort_cache(active_p);
	}
	else if (choice == NC_MFI_READ_ON_FOCUS)
	{
		g_ini_read_on_focus = (unsigned char)(g_ini_read_on_focus ? 0u : 1u);
		resort = 0;
	}

	g_menu_active = 0;
	g_menu_level = NC_MENU_LEVEL_TOP;
	g_menu_sel = 0;

	if (resort && active_p->file_count >= 2u)
		panel_resort_keep_cursor(active_p);

	redraw_panels_full();
}

void draw_file_line(PanelState *panel, unsigned char start_x, unsigned int file_idx)
{
	unsigned char row_y;

	if (file_idx < panel->scroll_offset || file_idx >= panel->scroll_offset + 18u)
		return;

	row_y = (unsigned char)(file_idx - panel->scroll_offset);
	if (file_idx >= panel->file_count)
	{
		draw_panel_row_empty(start_x, row_y);
		return;
	}

	panel_draw_vis_row(panel, start_x, row_y, file_idx);
}

static void panel_mark_toggle_cursor(PanelState *panel)
{
	unsigned int phys;
	unsigned int old_idx;
	unsigned int old_scroll;
	unsigned char kind;
	unsigned char start_x;
	unsigned char on;

	if (panel->file_count == 0u)
		return;
	phys = panel_meta_get_index(panel, panel->cursor_idx);
	kind = panel_meta_get_kind(panel, phys);
	if (kind == PANEL_KIND_DOTDOT)
		return;
	on = panel_mark_get_phys(panel, phys);
	panel_mark_set_phys(panel, phys, (unsigned char)(on ? 0u : 1u));

	start_x = (panel == &left_panel) ? 0u : 40u;
	old_idx = panel->cursor_idx;
	draw_file_line(panel, start_x, old_idx);

	if (old_idx + 1u >= panel->file_count)
	{
		if (panel->is_active)
			draw_bottom_info(panel);
		return;
	}

	old_scroll = panel->scroll_offset;
	panel->cursor_idx = old_idx + 1u;
	if (panel->cursor_idx >= panel->scroll_offset + 18u)
		panel->scroll_offset = panel->cursor_idx - 18u + 1u;

	if (panel->scroll_offset != old_scroll)
		draw_panel(panel, start_x, 18);
	else
	{
		draw_file_line(panel, start_x, old_idx);
		draw_file_line(panel, start_x, panel->cursor_idx);
	}
	if (panel->is_active)
		draw_bottom_info(panel);
}

int ext_cmp(const char *s1, const char *s2)
{
	return panel_cmp_str_fold(s1, s2);
}

void handle_enter(PanelState *active_p)
{
	unsigned int real_idx;
	char *n;
	unsigned int page_offset;
	static char enter_path[200];

	if (!panel_chdir_only(active_p->current_path))
		return;

	real_idx = panel_meta_get_index(active_p, active_p->cursor_idx);
	switch_file_page(active_p, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	set.current_file = set.bank_array[page_offset];

	if (set.current_file.fattrib & 0x10)
	{
		strcpy(set.local_dir_name, panel_entry_name(&set.current_file));

		if (panel_entry_is_dotdot(&set.current_file))
		{
			panel_path_basename(active_p, set.exited_dir_name);
			OS_CHDIR((unsigned char *)"..");
			panel_sync_path(active_p);
			read_panel_dir_at(active_p, active_p->current_path, 1);

			if (set.exited_dir_name[0] != 0)
			{
				unsigned int search_idx;
				for (search_idx = 0; search_idx < active_p->file_count; search_idx++)
				{
					unsigned int r_idx = panel_meta_get_index(active_p, search_idx);
					switch_file_page(active_p, r_idx);
					page_offset = r_idx % FILES_PER_PAGE;

					n = panel_entry_name(&set.bank_array[page_offset]);
					if (strcmp(n, set.exited_dir_name) == 0)
					{
						active_p->cursor_idx = search_idx;
						if (active_p->cursor_idx >= 18)
						{
							active_p->scroll_offset = active_p->cursor_idx - 18 + 1;
						}
						break;
					}
				}
			}
		}
		else
		{
			build_full_path(enter_path, active_p->current_path, set.local_dir_name);
			read_panel_dir_at(active_p, enter_path, 0);
		}

		if (active_p->file_count > 0)
		{
			switch_file_page(active_p, panel_meta_get_index(active_p, active_p->scroll_offset));
		}

		draw_panel_background(active_p, (left_panel.is_active) ? 0 : 40);
		draw_panel(active_p, (left_panel.is_active) ? 0 : 40, 18);
		return;
	}

	nc_run_selected_file(active_p);
}

static void panel_clamp_scroll(PanelState *panel)
{
	if (panel->file_count == 0u)
	{
		panel->cursor_idx = 0;
		panel->scroll_offset = 0;
		return;
	}
	if (panel->cursor_idx >= panel->file_count)
		panel->cursor_idx = panel->file_count - 1u;
	if (panel->cursor_idx < panel->scroll_offset)
		panel->scroll_offset = panel->cursor_idx;
	else if (panel->cursor_idx >= panel->scroll_offset + 18u)
		panel->scroll_offset = panel->cursor_idx - 18u + 1u;
}

static unsigned char panel_find_by_name(PanelState *panel, const char *hint, unsigned int *out_idx)
{
	unsigned int i;
	unsigned int r_idx;
	unsigned int page_offset;
	char *name;

	if (hint == NULL || hint[0] == 0 || panel->file_count == 0u)
		return 0;

	for (i = 0; i < panel->file_count; i++)
	{
		r_idx = panel_meta_get_index(panel, i);
		switch_file_page(panel, r_idx);
		page_offset = r_idx % FILES_PER_PAGE;
		name = panel_entry_name(&set.bank_array[page_offset]);
		if (panel_cmp_str_fold(name, hint) == 0)
		{
			*out_idx = i;
			return 1;
		}
	}
	return 0;
}

static void panels_redraw_both(void)
{
	panels_remap_bank_window();
	redraw_panels_full();
}

static void panels_reload_both(const char *snap_left, const char *snap_right)
{
	panel_path_normalize(&left_panel, snap_left);
	panel_path_normalize(&right_panel, snap_right);
	if (left_panel.is_active)
	{
		read_panel_dir_at(&left_panel, snap_left, 1);
		read_panel_dir_at(&right_panel, snap_right, 1);
	}
	else
	{
		read_panel_dir_at(&right_panel, snap_right, 1);
		read_panel_dir_at(&left_panel, snap_left, 1);
	}

	if (left_panel.is_active)
		panel_chdir_only(left_panel.current_path);
	else
		panel_chdir_only(right_panel.current_path);
}

static void panels_draw_all(PanelState *active_p)
{
	SETPG32KHIGH(residentPg);
	draw_panel_background(&left_panel, 0);
	draw_panel_background(&right_panel, 40);
	draw_panel(&left_panel, 0, 18);
	draw_panel(&right_panel, 40, 18);
	draw_bottom_info(active_p);
	draw_status_bar();
}

static void panels_refresh_after_copy_snaps(PanelState *src_panel, PanelState *dst_panel, const char *snap_left,
											const char *snap_right, const char *hint)
{
	PanelState *active_p;
	unsigned int idx;

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;
	if (src_panel == NULL)
		src_panel = active_p;
	if (dst_panel == NULL)
		dst_panel = (src_panel == &left_panel) ? &right_panel : &left_panel;

	panels_reload_both(snap_left, snap_right);

	if (hint != NULL && hint[0] != 0 && panel_find_by_name(src_panel, hint, &idx))
	{
		src_panel->cursor_idx = idx;
		panel_clamp_scroll(src_panel);
	}

	g_focus_pending = 0;
	copy_prog.drawn = 0;
	panels_draw_all(active_p);
}

static void panels_refresh_after_copy(PanelState *src_panel, PanelState *dst_panel, const char *hint)
{
	char snap_left[64];
	char snap_right[64];

	strncpy(snap_left, left_panel.current_path, sizeof(snap_left) - 1u);
	snap_left[sizeof(snap_left) - 1u] = 0;
	strncpy(snap_right, right_panel.current_path, sizeof(snap_right) - 1u);
	snap_right[sizeof(snap_right) - 1u] = 0;
	panels_refresh_after_copy_snaps(src_panel, dst_panel, snap_left, snap_right, hint);
}

void panels_refresh_all(const char *next_file_hint)
{
	PanelState *active_p;
	unsigned int idx;
	char snap_left[64];
	char snap_right[64];

	g_focus_pending = 0;
	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	strncpy(snap_left, left_panel.current_path, sizeof(snap_left) - 1u);
	snap_left[sizeof(snap_left) - 1u] = 0;
	strncpy(snap_right, right_panel.current_path, sizeof(snap_right) - 1u);
	snap_right[sizeof(snap_right) - 1u] = 0;

	panels_reload_both(snap_left, snap_right);

	if (next_file_hint != NULL && panel_find_by_name(active_p, next_file_hint, &idx))
	{
		active_p->cursor_idx = idx;
		panel_clamp_scroll(active_p);
	}
	panels_draw_all(active_p);
}

static void panels_refresh_after_delete(PanelState *del_panel)
{
	read_panel_dir_at(del_panel, del_panel->current_path, 1);
	g_focus_pending = 0;
	copy_prog.drawn = 0;
	g_delete_progress = 0;
	panels_redraw_both();
}

static void ui_str_append_uint(char *buf, unsigned char *pi, unsigned int val)
{
	char tmp[6];
	unsigned char n;
	unsigned char j;

	n = 0;
	if (val == 0u)
	{
		buf[(*pi)++] = '0';
		return;
	}
	while (val > 0u && n < 6u)
	{
		tmp[n++] = (char)('0' + (val % 10u));
		val /= 10u;
	}
	j = n;
	while (j > 0u)
		buf[(*pi)++] = tmp[--j];
}

static void nc_on_focus_refresh(void)
{
	g_focus_pending = 0;
	panels_remap_bank_window();
	SETPG32KHIGH(residentPg);
	if (g_ini_read_on_focus)
		panels_refresh_all(NULL);
	else
		redraw_panels_full();
	if (g_drive_active)
		panel_drive_redraw();
	else if (g_menu_active)
		draw_menu_overlay();
}

static void ui_dlg_preset(DialogWindow *dlg, unsigned char x, unsigned char y, unsigned char w, unsigned char h,
						  unsigned char color, const char *title, const char *prompt)
{
	dlg->x = x;
	dlg->y = y;
	dlg->w = w;
	dlg->h = h;
	dlg->color = color;
	dlg->title = title;
	dlg->prompt = prompt;
}

static void ui_dlg_centered(DialogWindow *dlg, unsigned char w, unsigned char h, unsigned char y,
							unsigned char color, const char *title, const char *prompt)
{
	ui_dlg_preset(dlg, (unsigned char)((screenWidth - w - 2u) / 2u), y, w, h, color, title, prompt);
}

static unsigned char ui_show_dialog(DialogWindow *dlg, char *buffer, unsigned char max_len,
									unsigned char btn_mask)
{
	unsigned char c000_saved;
	unsigned char res;

	c000_saved = bank_window_current();
	SETPG32KHIGH(residentPg);
	res = show_dialog(dlg, buffer, max_len, btn_mask);
	bank_window_map(c000_saved);
	return res;
}

static unsigned char ui_dialog_input(const char *title, const char *prompt)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_INPUT_W, UI_DLG_INPUT_H, UI_DLG_INPUT_Y, COLOR_COPY_UI, title, prompt);
	return ui_show_dialog(&dlg, set.temp_path, sizeof(set.temp_path), D_MASK_OK_CANCEL);
}

static unsigned char ui_dialog_confirm(const char *title, const char *prompt, unsigned char btn_mask)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_CONFIRM_W, UI_DLG_CONFIRM_H, UI_DLG_CONFIRM_Y, COLOR_OVERWRITE_UI, title, prompt);
	return ui_show_dialog(&dlg, NULL, 0, btn_mask);
}

static unsigned char ui_dialog_delete_confirm(const char *title, const char *prompt)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_PROGRESS_W, UI_DLG_PROGRESS_H, UI_DLG_PROGRESS_Y, COLOR_OVERWRITE_UI, title, prompt);
	return ui_show_dialog(&dlg, NULL, 0, D_MASK_DELETE);
}

static void ui_alert_dialog(const char *title, const char *prompt)
{
	DialogWindow dlg;

	ui_dlg_preset(&dlg, UI_DLG_ALERT_X, UI_DLG_ALERT_Y, UI_DLG_CONFIRM_W, UI_DLG_ALERT_H, COLOR_OVERWRITE_UI, title,
				  prompt);
	(void)ui_show_dialog(&dlg, NULL, 0, D_BTN_OK);
}

static void ui_error_dialog(const char *title, const char *msg)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_INPUT_W, UI_DLG_ALERT_H, UI_DLG_INPUT_Y, COLOR_OVERWRITE_UI, title, msg);
	(void)ui_show_dialog(&dlg, NULL, 0, D_BTN_OK);
}

static unsigned char copy_dest_path_ok(void)
{
	return panel_chdir_for_read(set.temp_path);
}

static void ui_draw_frame(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char color, const char *title)
{
	unsigned char wcount;
	unsigned char tempx;
	unsigned char titleStart;

	/* w = horizontal 205 count between corners; h = Y offset of bottom border row */
	BDBOX(x, y, (unsigned char)(w + 2), (unsigned char)(h + 1), color, 32);

	OS_SETXY(x, y);
	OS_SETCOLOR(color);
	putchar(201);
	for (wcount = 0; wcount < w; wcount++)
		putchar(205);
	putchar(187);

	OS_SETXY(x, (unsigned char)(y + h));
	putchar(200);
	for (wcount = 0; wcount < w; wcount++)
		putchar(205);
	putchar(188);

	tempx = (unsigned char)(x + w + 1);
	for (wcount = 1; wcount < h; wcount++)
	{
		OS_SETXY(x, (unsigned char)(y + wcount));
		putchar(186);
		OS_SETXY(tempx, (unsigned char)(y + wcount));
		putchar(186);
	}

	if (title != NULL)
	{
		titleStart = (unsigned char)(x + (w / 2));
		if (strlen(title) < w)
			titleStart -= (unsigned char)(strlen(title) / 2);
		OS_SETXY(titleStart, y);
		OS_SETCOLOR(color);
		putchar('[');
		print_cstr(title);
		putchar(']');
	}
}

static void ui_print_centered(unsigned char x, unsigned char y, unsigned char width, const char *str)
{
	unsigned char len;
	unsigned char pad;
	unsigned char i;
	const char *show;

	show = str;
	if (show == NULL)
		show = "";
	len = 0;
	while (show[len] != 0)
		len++;
	if (len > width)
	{
		show = show + len - width;
		len = width;
	}
	pad = (unsigned char)((width - len) / 2u);
	OS_SETXY(x, y);
	for (i = 0; i < width; i++)
		putchar(' ');
	if (len != 0u)
	{
		OS_SETXY((unsigned char)(x + pad), y);
		for (i = 0; i < len; i++)
			putchar(show[i]);
	}
}

static void panel_sort_notice_show(PanelState *panel)
{
	unsigned char col_x;
	unsigned char frame_x;
	unsigned char frame_y;
	unsigned char inner_y;
	const char *msg = "Sorting catalog...";
	const unsigned char box_w = 24u;
	const unsigned char box_h = 4u;

	col_x = (panel == &right_panel) ? PANEL_COL_RIGHT : PANEL_COL_LEFT;
	frame_x = (unsigned char)(col_x + (PANEL_COL_WIDTH - (box_w + 2u)) / 2u);
	frame_y = (unsigned char)(3u + (18u - (box_h + 1u)) / 2u);
	ui_draw_frame(frame_x, frame_y, box_w, box_h, COLOR_STATUS_BAR, "NC");
	OS_SETCOLOR(COLOR_STATUS_BAR);
	inner_y = (unsigned char)(frame_y + 1u + (box_h - 1u) / 2u);
	ui_print_centered((unsigned char)(frame_x + 1u), inner_y, box_w, msg);
	YIELD();
}

static void fileop_progress_layout(unsigned char with_bar)
{
	if (with_bar)
	{
		copy_prog.w = UI_DLG_INPUT_W;
		copy_prog.h = UI_DLG_INPUT_H;
		copy_prog.x = (unsigned char)((screenWidth - copy_prog.w - 2u) / 2u);
		copy_prog.y = UI_DLG_INPUT_Y;
		copy_prog.name_y = (unsigned char)(copy_prog.y + 4u);
		copy_prog.bar_w = (unsigned char)(copy_prog.w - 10u);
		copy_prog.bar_x = (unsigned char)(copy_prog.x + 5u);
		copy_prog.bar_y = (unsigned char)(copy_prog.y + 2u);
	}
	else
	{
		copy_prog.w = UI_DLG_PROGRESS_W;
		copy_prog.h = UI_DLG_PROGRESS_H;
		copy_prog.x = (unsigned char)((screenWidth - copy_prog.w - 2u) / 2u);
		copy_prog.y = UI_DLG_PROGRESS_Y;
		copy_prog.name_y = (unsigned char)(copy_prog.y + 2u);
	}
}

static void fileop_progress_fill_bg(unsigned char color)
{
	unsigned char row;
	unsigned char col;

	OS_SETCOLOR(color);
	for (row = 1; row < copy_prog.h; row++)
	{
		OS_SETXY((unsigned char)(copy_prog.x + 1), (unsigned char)(copy_prog.y + row));
		for (col = 0; col < copy_prog.w; col++)
			putchar(' ');
	}
}

static void copy_progress_draw_bar(unsigned char pct);
static void copy_progress_draw_name(const char *name);

static void fileop_progress_store_name(const char *name)
{
	const char *show;

	show = name;
	if (show == NULL)
		show = "";
	strncpy(copy_prog_current_name, show, sizeof(copy_prog_current_name) - 1u);
	copy_prog_current_name[sizeof(copy_prog_current_name) - 1u] = 0;
	copy_prog.last_pct = 255u;
	copy_progress_draw_name(copy_prog_current_name);
}

static void fileop_progress_repaint(unsigned char color, const char *title, unsigned char restore_bar)
{
	unsigned char pct;

	if (!copy_prog.drawn)
		return;

	pct = 0u;
	if (restore_bar)
	{
		pct = copy_prog.last_pct;
		if (pct > 100u)
			pct = 0u;
	}

	ui_draw_frame(copy_prog.x, copy_prog.y, copy_prog.w, copy_prog.h, color, title);
	fileop_progress_fill_bg(color);
	copy_prog.last_pct = 255u;
	copy_progress_draw_name(copy_prog_current_name);
	if (restore_bar && !g_delete_progress)
		copy_progress_draw_bar(pct);
}

static void fileop_progress_open(unsigned char color, const char *title, unsigned char with_bar)
{
	fileop_progress_layout(with_bar);
	copy_prog.last_pct = 255;
	copy_prog.drawn = 0;
	ui_draw_frame(copy_prog.x, copy_prog.y, copy_prog.w, copy_prog.h, color, title);
	fileop_progress_fill_bg(color);
	copy_prog.drawn = 1;
	if (with_bar)
		copy_progress_draw_bar(0);
	fileop_progress_store_name("");
}

static void fileop_progress_begin_title(unsigned char is_delete, const char *title)
{
	const char *show;

	show = title;
	if (show == NULL || show[0] == 0)
		show = is_delete ? "Deleting" : "Copying";
	strncpy(g_fileop_title, show, sizeof(g_fileop_title) - 1u);
	g_fileop_title[sizeof(g_fileop_title) - 1u] = 0;
	g_delete_progress = is_delete;
	fileop_progress_open(is_delete ? COLOR_OVERWRITE_UI : COLOR_COPY_UI, g_fileop_title, !is_delete);
}

static void fileop_progress_begin(unsigned char is_delete)
{
	fileop_progress_begin_title(is_delete, is_delete ? "Deleting" : "Copying");
}

static void fileop_progress_restore(void)
{
	fileop_progress_repaint(g_delete_progress ? COLOR_OVERWRITE_UI : COLOR_COPY_UI, g_fileop_title,
							g_delete_progress ? 0u : 1u);
}

static void copy_progress_draw_bar(unsigned char pct)
{
	unsigned char i;
	unsigned char filled;

	/* No percent bar while deleting ? only the current name line updates. */
	if (g_delete_progress)
		return;

	if (pct > 100)
		pct = 100;
	if (copy_prog.drawn && pct == copy_prog.last_pct)
		return;
	copy_prog.last_pct = pct;

	if (!copy_prog.drawn)
		fileop_progress_begin_title(g_delete_progress, g_fileop_title);

	filled = (unsigned char)(((unsigned int)copy_prog.bar_w * pct) / 100u);

	OS_SETXY(copy_prog.bar_x, copy_prog.bar_y);
	OS_SETCOLOR(COLOR_COPY_UI);
	putchar('[');
	for (i = 0; i < copy_prog.bar_w; i++)
	{
		if (i < filled)
		{
			OS_SETCOLOR(COLOR_COPY_BAR_FILL);
			putchar((char)COPY_CH_BAR_FILL);
		}
		else
		{
			OS_SETCOLOR(COLOR_COPY_UI);
			putchar((char)COPY_CH_BAR_EMPTY);
		}
	}
	OS_SETCOLOR(COLOR_COPY_UI);
	putchar(']');
}

static void copy_progress_draw_name(const char *name)
{
	const char *show;

	if (!copy_prog.drawn)
		fileop_progress_begin_title(g_delete_progress, g_fileop_title);

	show = name;
	if (show == NULL)
		show = "";

	OS_SETCOLOR(g_delete_progress ? COLOR_OVERWRITE_UI : COLOR_COPY_UI);
	ui_print_centered((unsigned char)(copy_prog.x + 1u), copy_prog.name_y, copy_prog.w, show);
}

static void path_parent_from(const char *path, char *parent_out)
{
	unsigned int len;
	unsigned int i;

	len = strlen(path);
	if (len >= 200u)
		len = 199u;
	strncpy(parent_out, path, len);
	parent_out[len] = 0;
	while (len > 0u && (parent_out[len - 1u] == '/' || parent_out[len - 1u] == '\\'))
		parent_out[--len] = 0;
	if (len == 0u)
	{
		parent_out[0] = 0;
		return;
	}
	for (i = len; i > 0u; i--)
	{
		if (parent_out[i - 1u] == '/' || parent_out[i - 1u] == '\\')
		{
			parent_out[i - 1u] = 0;
			len = i - 1u;
			if (len > 0u && parent_out[len - 1u] == ':')
			{
				parent_out[len] = '/';
				parent_out[len + 1u] = 0;
			}
			return;
		}
	}
	parent_out[0] = 0;
}

static void move_delete_path(const char *path)
{
	unsigned char saved;

	saved = resident_bank_push();
	(void)OS_DELETE((unsigned char *)path);
	resident_bank_pop(saved);
}

/* Directory delete: CHDIR parent first (CWD may still be inside the tree). */
static void move_delete_dir_path(const char *full_dir_path)
{
	char parent[200];
	char base[64];
	unsigned char saved;

	path_parent_from(full_dir_path, parent);
	path_basename_from(full_dir_path, base);
	if (parent[0] == 0 || base[0] == 0)
		return;
	saved = resident_bank_push();
	(void)OS_CHDIR((unsigned char *)parent);
	(void)OS_DELETE((unsigned char *)base);
	resident_bank_pop(saved);
}

static void copy_progress_file_begin(const char *name, unsigned char is_dir)
{
	fileop_progress_store_name(name);
	if (!g_delete_progress)
	{
		if (is_dir)
			copy_progress_draw_bar(100);
		else
			copy_progress_draw_bar(0);
	}
}

static void delete_progress_show_name(const char *name)
{
	if (copy_prog.drawn)
		fileop_progress_store_name(name);
}

static void delete_progress_ensure(void)
{
	if (!copy_prog.drawn)
		fileop_progress_begin(1);
}

static void copy_progress_file_bytes(unsigned long done, unsigned long total)
{
	unsigned char pct;

	if (total == 0)
		pct = 100;
	else
		pct = (unsigned char)((done * 100ul) / total);
	copy_progress_draw_bar(pct);
}

static void path_append_name(char *dest, const char *name)
{
	unsigned int len;

	len = strlen(dest);
	if (len > 0u && dest[len - 1u] != '/' && dest[len - 1u] != '\\')
		strcat(dest, "/");
	strcat(dest, name);
}

void build_full_path(char *dest, const char *path, const char *filename)
{
	strcpy(dest, path);
	path_append_name(dest, filename);
}

static unsigned char *nc_nvext_base(void)
{
	return (unsigned char *)(BANK_WINDOW_ADDRESS + NC_NVEXT_OFF);
}

static void nc_nvext_map(void)
{
	panel_meta_map(&left_panel);
}

static void nc_nvext_unmap(void)
{
	SETPG32KHIGH(residentPg);
	panels_remap_bank_window();
}

static void nc_nvext_load(void)
{
	FILE *nvf;
	unsigned int nvextSize;
	unsigned int loop;
	unsigned int loaded;
	unsigned int toRead;
	unsigned char *dst;
	char io_chunk[128];

	g_nvext_size = 0;
	if (!panel_banks_ok(&left_panel))
		return;

	SETPG32KHIGH(residentPg);
	OS_SETSYSDRV();
	nvf = OS_OPENHANDLE((unsigned char *)"nv.ext", 0x80);
	if (((int)nvf) & 0xff)
	{
		print_cstr("nv.ext not found.");
		print_crlf();
		return;
	}

	SETPG32KHIGH(residentPg);
	nvextSize = OS_GETFILESIZE(nvf);
	if (nvextSize >= NC_NVEXT_MAX)
		nvextSize = NC_NVEXT_MAX - 1u;

	nc_nvext_map();
	dst = nc_nvext_base();
	loop = 0;
	while (loop < nvextSize)
	{
		toRead = nvextSize - loop;
		if (toRead > sizeof(io_chunk))
			toRead = (unsigned int)sizeof(io_chunk);
		SETPG32KHIGH(residentPg);
		loaded = OS_READHANDLE((unsigned char *)io_chunk, nvf, toRead);
		if (loaded == 0)
			break;
		nc_nvext_map();
		memcpy(dst + loop, io_chunk, loaded);
		loop += loaded;
	}
	SETPG32KHIGH(residentPg);
	OS_CLOSEHANDLE(nvf);
	g_nvext_size = loop;
	nc_nvext_map();
	dst[loop] = 0;
	SETPG32KHIGH(residentPg);
}

static unsigned char nc_nvext_find_handler(const char *ext, char *handler, unsigned int handler_sz)
{
	const unsigned char *pDb;
	const unsigned char *pEnd;
	const unsigned char *pLineStart;
	unsigned char extLow[4];
	unsigned char found;
	unsigned int i;

	found = 0;
	if (g_nvext_size == 0u)
		return 0;

	for (i = 0; i < 3u && ext[i] != 0 && ext[i] != ' '; i++)
		extLow[i] = (unsigned char)tolower((unsigned char)ext[i]);
	extLow[i] = 0;
	if (extLow[0] == 0)
		return 0;

	nc_nvext_map();
	pDb = (const unsigned char *)nc_nvext_base();
	pEnd = pDb + g_nvext_size;

	while (pDb < pEnd && *pDb != 0)
	{
		pLineStart = pDb;
		while (pDb < pEnd && *pDb != 0x0d && *pDb != 0x0a && *pDb != 0)
		{
			i = 0;
			while (extLow[i] != 0 && extLow[i] == (unsigned char)tolower(pDb[i]))
				i++;
			if (extLow[i] == 0 && (pDb[i] == ':' || pDb[i] == ','))
			{
				while (pDb < pEnd && *pDb != ':' && *pDb != 0x0d && *pDb != 0x0a && *pDb != 0)
					pDb++;
				if (pDb < pEnd && *pDb == ':')
				{
					pDb++;
					while (pDb < pEnd && *pDb == ' ')
						pDb++;
					i = 0;
					while (pDb < pEnd && *pDb != 0x0d && *pDb != 0x0a && *pDb != 0 && i + 1u < handler_sz)
						handler[i++] = (char)*pDb++;
					handler[i] = 0;
					found = 1;
					goto nc_nvext_find_done;
				}
			}
			while (pDb < pEnd && *pDb != ',' && *pDb != ':' && *pDb != 0x0d && *pDb != 0x0a && *pDb != 0)
				pDb++;
			if (pDb < pEnd && *pDb == ',')
				pDb++;
			else
				break;
		}
		pDb = pLineStart;
		while (pDb < pEnd && *pDb != 0x0d && *pDb != 0)
			pDb++;
		if (pDb < pEnd && *pDb == 0x0d)
			pDb++;
		if (pDb < pEnd && *pDb == 0x0a)
			pDb++;
	}

nc_nvext_find_done:
	nc_nvext_unmap();
	return found;
}

static void nc_build_shell_cmd(const char *handler, const char *fullpath, char *out, unsigned int outsz)
{
	unsigned int n;

	n = 0;
	while (handler[n] != 0 && n + 1u < outsz)
	{
		out[n] = handler[n];
		n++;
	}
	if (n + 1u < outsz)
		out[n++] = ' ';
	strncpy(out + n, fullpath, outsz - n - 1u);
	out[outsz - 1u] = 0;
}

#define SHELL_LOAD_TAIL (0x10000u - 0xC100u) /* first page: 0xC100..0xFFFF */
#define SHELL_LOAD_FULL 0x4000u				 /* next pages: full 16 KB at 0xC000 */

/* term/cmd readfile_pages_dehl: optional pages may EOF with 0 bytes (errno 0xFF). */
static unsigned char nc_shell_loadpage(unsigned char page, unsigned char *addr, unsigned int max_sz, FILE *fp,
									   unsigned char required)
{
	unsigned int n;

	SETPG32KHIGH(page);
	errno = 0;
	n = OS_READHANDLE(addr, fp, max_sz);
	if (required)
		return (n > 0u && errno == 0) ? 1u : 0u;
	if (n == 0u)
		return 1u;
	return (errno == 0) ? 1u : 0u;
}

static unsigned char nc_readfile_pages_dehl(const union APP_PAGES *pg, FILE *fp)
{
	if (!nc_shell_loadpage(pg->pgs.window_0, (unsigned char *)0xC100, SHELL_LOAD_TAIL, fp, 1))
		return 0;
	if (!nc_shell_loadpage(pg->pgs.window_1, (unsigned char *)0xC000, SHELL_LOAD_FULL, fp, 0))
		return 0;
	if (!nc_shell_loadpage(pg->pgs.window_2, (unsigned char *)0xC000, SHELL_LOAD_FULL, fp, 0))
		return 0;
	if (!nc_shell_loadpage(pg->pgs.window_3, (unsigned char *)0xC000, SHELL_LOAD_FULL, fp, 0))
		return 0;
	return 1;
}

/* gopher.com OS_SHELL: load term.com into child pages; cmdline "term.com " + command. */
static void nc_app_discard(unsigned char pId, unsigned char resident_page)
{
	if (pId != 0u)
		OS_DROPAPP(pId);
	SETPG32KHIGH(resident_page);
}

static unsigned char OS_SHELL(const char *command)
{
	unsigned char fileName[] = "term.com";
	unsigned char appCmd[128];
	unsigned char savedResidentPg;
	unsigned char childId;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg_run;
	FILE *fp3;
	unsigned int cmdLen;

	strcpy((char *)appCmd, "term.com ");
	strncat((char *)appCmd, command, 118);

	main_pg_run.l = OS_GETMAINPAGES();
	savedResidentPg = main_pg_run.pgs.window_3;
	SETPG32KHIGH(residentPg);
	OS_GETPATH((unsigned int)g_run_saved_cwd);
	OS_SETSYSDRV();

	fp3 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp3) & 0xff)
	{
		print_cstr("term.com not found.");
		print_crlf();
		return 0;
	}

	OS_CHDIR((unsigned char *)g_run_saved_cwd);

	OS_NEWAPP((unsigned int)&shell_pg);
	if (shell_pg.pgs.error != 0u)
	{
		OS_CLOSEHANDLE(fp3);
		SETPG32KHIGH(savedResidentPg);
		print_cstr("No free app slot.");
		print_crlf();
		return 0;
	}
	childId = shell_pg.pgs.pId;
	shell_pg.l = OS_GETAPPMAINPAGES(childId);

	SETPG32KHIGH(shell_pg.pgs.window_0);
	cmdLen = strlen((char *)appCmd) + 1u;
	memcpy((unsigned char *)(0xC080), appCmd, cmdLen);

	if (!nc_readfile_pages_dehl(&shell_pg, fp3))
	{
		OS_CLOSEHANDLE(fp3);
		nc_app_discard(childId, savedResidentPg);
		print_cstr("term.com load failed.");
		print_crlf();
		return 0;
	}

	OS_CLOSEHANDLE(fp3);

	SETPG32KHIGH(savedResidentPg);
	OS_RUNAPP(childId);
	YIELD();
	return 1;
}

static void nc_run_shell_cmd(const char *handler, const char *fullpath)
{
	char cmdbuf[128];

	nc_build_shell_cmd(handler, fullpath, cmdbuf, sizeof(cmdbuf));
	OS_SHELL(cmdbuf);
}

static void nc_run_restore_ui(PanelState *panel)
{
	SETPG32KHIGH(residentPg);
	panel_chdir_only(panel->current_path);
	panels_remap_bank_window();
	redraw_panels_full();
	draw_bottom_info((left_panel.is_active) ? &left_panel : &right_panel);
}

static unsigned char nc_get_file_under_cursor(PanelState *panel, char *name_out, unsigned char *is_dir_out)
{
	unsigned int real_idx;
	unsigned int page_offset;
	fileInfo *fi;

	if (panel->file_count == 0u)
		return 0;
	if (!panel_chdir_only(panel->current_path))
		return 0;

	real_idx = panel_meta_get_index(panel, panel->cursor_idx);
	switch_file_page(panel, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	fi = &set.bank_array[page_offset];

	if (fi->fattrib & 0x10)
	{
		*is_dir_out = 1;
		return 1;
	}

	*is_dir_out = 0;
	strcpy(name_out, panel_entry_name(fi));
	return 1;
}

static void nc_run_selected_file(PanelState *panel)
{
	char fullpath[200];
	char name[64];
	char handler[64];
	const char *ext;
	unsigned char is_dir;

	if (!nc_get_file_under_cursor(panel, name, &is_dir))
		return;
	if (is_dir)
		return;

	build_full_path(fullpath, panel->current_path, name);
	panel_chdir_only(panel->current_path);

	ext = strrchr(name, '.');
	if (ext == NULL)
	{
		print_cstr("No extension: ");
		print_cstr(name);
		print_crlf();
		nc_run_restore_ui(panel);
		return;
	}
	ext++;

	if (nc_nvext_find_handler(ext, handler, sizeof(handler)))
	{
		nc_run_shell_cmd(handler, fullpath);
	}
	else if (ext_cmp(ext, "com") == 0 || ext_cmp(ext, "bin") == 0)
	{
		nc_run_shell_cmd("cmd.com", fullpath);
	}
	else
	{
		print_cstr("No handler for .");
		print_cstr(ext);
		print_crlf();
	}
	nc_run_restore_ui(panel);
}

static void nc_action_view(PanelState *panel)
{
	char fullpath[200];
	char name[64];
	unsigned char is_dir;

	if (!nc_get_file_under_cursor(panel, name, &is_dir))
		return;
	if (is_dir)
		return;

	build_full_path(fullpath, panel->current_path, name);
	panel_chdir_only(panel->current_path);
	nc_run_shell_cmd(g_ini_viewer, fullpath);
	nc_run_restore_ui(panel);
}

static void nc_action_edit(PanelState *panel)
{
	char fullpath[200];
	char name[64];
	unsigned char is_dir;

	if (!nc_get_file_under_cursor(panel, name, &is_dir))
		return;
	if (is_dir)
		return;

	build_full_path(fullpath, panel->current_path, name);
	panel_chdir_only(panel->current_path);
	nc_run_shell_cmd(g_ini_editor, fullpath);
	nc_run_restore_ui(panel);
}

static unsigned char copy_dest_exists(const char *path)
{
	FILE *h;
	unsigned char saved;
	unsigned char exists;

	saved = resident_bank_push();
	h = OS_OPENHANDLE((unsigned char *)path, 0x80);
	if (((int)h) & 0xff)
		exists = 0;
	else
	{
		OS_CLOSEHANDLE(h);
		exists = 1;
	}
	resident_bank_pop(saved);
	return exists;
}

static unsigned char copy_dir_exists(const char *path)
{
	FILINFO finfo;
	unsigned char saved;
	unsigned char exists;

	saved = resident_bank_push();
	if ((unsigned char)OS_GETFILINFO((unsigned char *)path, &finfo) != 0u)
		exists = 0;
	else
		exists = (unsigned char)((finfo.fattrib & 0x10) ? 1u : 0u);
	resident_bank_pop(saved);
	return exists;
}

static void copy_ow_msg_build(const char *kind, const char *dst_path)
{
	char base[64];

	strcpy(g_copy_ow_msg, kind);
	path_basename_from(dst_path, base);
	strcat(g_copy_ow_msg, base);
	strcat(g_copy_ow_msg, " exist");
}

/* exists + cached overwrite mode, or one Copy confirm dialog. */
static unsigned char copy_overwrite_resolve(unsigned char exists, const char *dialog_msg)
{
	unsigned char res;

	if (!exists)
		return COPY_FILE_OK;
	if (g_copy_overwrite_mode == COPY_OW_SKIP_ALL)
		return COPY_FILE_SKIP;
	if (g_copy_overwrite_mode == COPY_OW_REPLACE_ALL)
		return COPY_FILE_OK;
	if (g_copy_overwrite_mode == COPY_OW_ABORT)
		return COPY_FILE_ABORT;

	res = ui_dialog_confirm(g_move_active ? "Move" : "Copy", dialog_msg, D_MASK_OVERWRITE);
	fileop_progress_restore();

	switch (res)
	{
	case D_RES_YES:
		return COPY_FILE_OK;
	case D_RES_NO:
	case D_RES_SKIP:
		return COPY_FILE_SKIP;
	case D_RES_SKIP_ALL:
		g_copy_overwrite_mode = COPY_OW_SKIP_ALL;
		return COPY_FILE_SKIP;
	case D_RES_REPLACE_ALL:
		g_copy_overwrite_mode = COPY_OW_REPLACE_ALL;
		return COPY_FILE_OK;
	case D_RES_CANCEL:
	default:
		g_copy_overwrite_mode = COPY_OW_ABORT;
		return COPY_FILE_ABORT;
	}
}

static unsigned char copy_check_dir_merge(const char *dst_path)
{
	copy_ow_msg_build("folder ", dst_path);
	return copy_overwrite_resolve(copy_dir_exists(dst_path), g_copy_ow_msg);
}

static unsigned char copy_check_overwrite(const char *dst_path)
{
	copy_ow_msg_build("file ", dst_path);
	return copy_overwrite_resolve(copy_dest_exists(dst_path), g_copy_ow_msg);
}

unsigned char copy_single_file_core(const char *src_path, const char *dst_path, unsigned int src_fdate,
									unsigned int src_ftime)
{
	FILE *h_src;
	FILE *h_dst;
	unsigned int bytes_read;
	unsigned int bytes_written;
	unsigned long remaining;
	unsigned long file_size;
	unsigned int chunk;
	unsigned char ui_tick;
	unsigned int fdate;
	unsigned int ftime;
	unsigned char ow;
	unsigned char bank_saved;

	fdate = src_fdate;
	ftime = src_ftime;

	bank_saved = resident_bank_push();

	ow = copy_check_overwrite(dst_path);
	if (ow == COPY_FILE_SKIP)
	{
		resident_bank_pop(bank_saved);
		return COPY_FILE_SKIP;
	}
	if (ow == COPY_FILE_ABORT)
	{
		resident_bank_pop(bank_saved);
		return COPY_FILE_ABORT;
	}

	h_src = OS_OPENHANDLE((unsigned char *)src_path, 0x80);
	if (((int)h_src) & 0xff)
	{
		resident_bank_pop(bank_saved);
		return COPY_FILE_ERR;
	}

	if (fdate == 0 && ftime == 0)
		OS_GETFILETIME((unsigned char *)src_path, &fdate, &ftime);

	file_size = OS_GETFILESIZE(h_src);
	remaining = file_size;
	ui_tick = 0;

	h_dst = OS_CREATEHANDLE((unsigned char *)dst_path, 0x80);
	if (((int)h_dst) & 0xff)
	{
		OS_CLOSEHANDLE(h_src);
		resident_bank_pop(bank_saved);
		return COPY_FILE_ERR;
	}

	/* I/O phase: only g_copy_io_page at C000; no resident/CODE_RESIDENT calls until unmap. */
	SETPG32KHIGH(g_copy_io_page);

	while (remaining > 0)
	{
		if (g_fileop_abort)
		{
			copy_io_unmap();
			OS_CLOSEHANDLE(h_dst);
			OS_CLOSEHANDLE(h_src);
			(void)OS_DELETE((unsigned char *)dst_path);
			return COPY_FILE_ABORT;
		}
		SETPG32KHIGH(g_copy_io_page);
		chunk = (remaining > COPY_IO_CHUNK) ? COPY_IO_CHUNK : (unsigned int)remaining;
		errno = 0;
		bytes_read = OS_READHANDLE(COPY_IO_ADDR, h_src, chunk);
		if (bytes_read == 0u)
		{
			copy_io_unmap();
			OS_CLOSEHANDLE(h_dst);
			OS_CLOSEHANDLE(h_src);
			(void)OS_DELETE((unsigned char *)dst_path);
			return COPY_FILE_ERR;
		}

		errno = 0;
		bytes_written = OS_WRITEHANDLE(COPY_IO_ADDR, h_dst, bytes_read);
		if (bytes_written != bytes_read)
		{
			copy_io_unmap();
			OS_CLOSEHANDLE(h_dst);
			OS_CLOSEHANDLE(h_src);
			(void)OS_DELETE((unsigned char *)dst_path);
			return COPY_FILE_ERR;
		}

		if (bytes_read >= remaining)
			remaining = 0;
		else
			remaining -= bytes_read;

		ui_tick++;
		if ((ui_tick & 3u) == 0u || remaining == 0u)
		{
			SETPG32KHIGH(residentPg);
			copy_progress_file_bytes(file_size - remaining, file_size);
			SETPG32KHIGH(g_copy_io_page);
		}
		fileop_yield();
		if (remaining > 0u)
			SETPG32KHIGH(g_copy_io_page);
	}

	copy_io_unmap();
	OS_SEEKHANDLE(h_dst, file_size);
	OS_CLOSEHANDLE(h_dst);
	OS_CLOSEHANDLE(h_src);
	OS_SETFILETIME((unsigned char *)dst_path, fdate, ftime);
	return COPY_FILE_OK;
}

static void copy_tree_iter(const char *base_src, const char *base_dst)
{
	CopyDirFrame *frame;
	CopyDirFrame *child;
	const char *name_ptr;
	unsigned char is_dir;
	unsigned char copy_res;
	unsigned int snap_idx;
	unsigned int snap_fdate;
	unsigned int snap_ftime;

	if (!g_copy_page_active)
		return;

	g_copy_tree_failed = 0;
	g_copy_sp = 1;
	copy_stack_map();
	frame = copy_stack_frame_ptr(0);
	frame->src[0] = 0;
	frame->dst[0] = 0;
	strncpy(frame->src, base_src, sizeof(frame->src) - 1u);
	frame->src[sizeof(frame->src) - 1u] = 0;
	strncpy(frame->dst, base_dst, sizeof(frame->dst) - 1u);
	frame->dst[sizeof(frame->dst) - 1u] = 0;
	frame->i = 0;
	frame->n = 0;
	frame->skip = 0;
	frame->snap_valid = 0;
	frame->dir_more = 0;

	/* Do not gate on COPY_OW_ABORT here: Move sets it up-front to skip overwrite
	 * dialogs; abort is handled per-file in copy_single_file_core and via break. */
	while (g_copy_sp > 0u && !g_fileop_abort)
	{
		copy_stack_map();
		frame = copy_stack_frame_ptr(g_copy_sp - 1u);

		if (!frame->snap_valid)
		{
			unsigned int dir_count;
			unsigned char batch_more;

			batch_more = 0;
			if (!copy_collect_dir(frame->src, frame->skip, &batch_more) || g_fileop_abort)
			{
				if (g_fileop_abort)
					break;
				g_copy_tree_failed = 1;
				g_copy_sp--;
				continue;
			}
			copy_take_dir_snapshot();
			SETPG32KHIGH(g_copy_snap_page);
			dir_count = *copy_cache_count_ptr();
			copy_stack_map();
			frame = copy_stack_frame_ptr(g_copy_sp - 1u);
			frame->n = dir_count;
			frame->dir_more = batch_more;
			frame->snap_valid = 1;
		}

		if (frame->i >= frame->n)
		{
			if (frame->dir_more)
			{
				frame->skip += frame->n;
				frame->i = 0;
				frame->n = 0;
				frame->snap_valid = 0;
				frame->dir_more = 0;
				continue;
			}
			if (g_move_active && g_copy_sp > 1u)
				move_delete_dir_path(frame->src);
			g_copy_sp--;
			continue;
		}

		snap_idx = frame->i;
		frame->i = snap_idx + 1u;

		copy_stack_map();
		frame = copy_stack_frame_ptr(g_copy_sp - 1u);
		strncpy(r_src_full, frame->src, sizeof(r_src_full) - 1u);
		r_src_full[sizeof(r_src_full) - 1u] = 0;
		strncpy(r_dst_full, frame->dst, sizeof(r_dst_full) - 1u);
		r_dst_full[sizeof(r_dst_full) - 1u] = 0;

		SETPG32KHIGH(g_copy_snap_page);
		name_ptr = copy_cache_name_ptr(snap_idx);
		if (name_ptr[0] == 0)
			continue;

		is_dir = copy_cache_flags_ptr()[snap_idx];
		path_append_name(r_src_full, name_ptr);
		path_append_name(r_dst_full, name_ptr);

		if (is_dir)
		{
			copy_progress_file_begin(name_ptr, 1);
			SETPG32KHIGH(residentPg);
			if ((unsigned char)OS_MKDIR((unsigned char *)r_dst_full) != 0u)
			{
				if (!copy_dir_exists(r_dst_full))
				{
					g_copy_tree_failed = 1;
					g_copy_overwrite_mode = COPY_OW_ABORT;
					break;
				}
				/* Existing subdir: merge contents without prompting. */
			}
			copy_stack_map();
			frame = copy_stack_frame_ptr(g_copy_sp - 1u);
			frame->snap_valid = 0;
			if (g_copy_sp >= COPY_DIR_STACK_MAX)
			{
				g_copy_tree_failed = 1;
				g_copy_overwrite_mode = COPY_OW_ABORT;
				break;
			}
			child = copy_stack_frame_ptr(g_copy_sp);
			child->src[0] = 0;
			child->dst[0] = 0;
			strncpy(child->src, r_src_full, sizeof(child->src) - 1u);
			child->src[sizeof(child->src) - 1u] = 0;
			strncpy(child->dst, r_dst_full, sizeof(child->dst) - 1u);
			child->dst[sizeof(child->dst) - 1u] = 0;
			child->i = 0;
			child->n = 0;
			child->skip = 0;
			child->snap_valid = 0;
			child->dir_more = 0;
			g_copy_sp++;
		}
		else
		{
			copy_progress_file_begin(name_ptr, 0);
			copy_stack_map();
			snap_fdate = copy_stack_dates_ptr(COPY_STACK_SNAPDATE_OFF)[snap_idx];
			snap_ftime = copy_stack_dates_ptr(COPY_STACK_SNAPTIME_OFF)[snap_idx];
			SETPG32KHIGH(residentPg);
			copy_res = copy_single_file_core(r_src_full, r_dst_full, snap_fdate, snap_ftime);
			if (copy_res == COPY_FILE_ABORT || copy_res == COPY_FILE_ERR || g_fileop_abort)
			{
				if (copy_res == COPY_FILE_ABORT || copy_res == COPY_FILE_ERR)
					g_copy_tree_failed = 1;
				break;
			}
			if (g_move_active && copy_res == COPY_FILE_OK)
				move_delete_path(r_src_full);
		}

		fileop_poll_abort();
	}

	if (g_move_active && !g_copy_tree_failed && !g_fileop_abort)
		move_delete_dir_path(base_src);

	g_copy_sp = 0;
}

static unsigned char nc_mkdir_name_valid(const char *name)
{
	unsigned int i;

	if (name[0] == 0)
		return 0;
	for (i = 0; name[i] != 0; i++)
	{
		if (name[i] == '/' || name[i] == '\\' || name[i] == ':')
			return 0;
	}
	return 1;
}

static unsigned char copy_do_one_item_res(PanelState *src_panel, const char *filename, unsigned char is_directory,
										  unsigned int page_offset, unsigned char *ws_active, unsigned char *io_active)
{
	char full_src_path[200];
	char full_dst_path[200];
	unsigned char copy_res;

	build_full_path(full_src_path, src_panel->current_path, filename);
	build_full_path(full_dst_path, set.temp_path, filename);

	if (is_directory)
	{
		if (!*ws_active)
		{
			if (*io_active)
				*io_active = 0; /* I/O page absorbed into workspace, not copy_io_release */
			if (!copy_workspace_begin())
				return COPY_ITEM_NOMEM;
			*ws_active = 1;
		}
		if ((unsigned char)OS_MKDIR((unsigned char *)full_dst_path) != 0u)
		{
			unsigned char merge;

			if (!copy_dir_exists(full_dst_path))
			{
				g_copy_tree_failed = 1;
				return COPY_FILE_ERR;
			}
			merge = copy_check_dir_merge(full_dst_path);
			if (merge == COPY_FILE_SKIP)
				return COPY_FILE_SKIP;
			if (merge == COPY_FILE_ABORT)
			{
				g_fileop_abort = 1;
				return COPY_FILE_ABORT;
			}
		}
		copy_progress_file_begin(filename, 1);
		copy_tree_iter(full_src_path, full_dst_path);
		if (g_fileop_abort)
			return COPY_FILE_ABORT;
		if (g_copy_tree_failed)
			return COPY_FILE_ERR;
		return COPY_FILE_OK;
	}

	if (!*io_active)
	{
		if (!copy_io_ensure())
			return COPY_ITEM_NOMEM;
		*io_active = 1;
	}
	copy_progress_file_begin(filename, 0);
	copy_res = copy_single_file_core(full_src_path, full_dst_path, set.bank_array[page_offset].fdate,
									 set.bank_array[page_offset].ftime);
	if (g_move_active && copy_res == COPY_FILE_OK)
		move_delete_path(full_src_path);
	return copy_res;
}

/* 1=continue batch, 0=stop (no memory) */
static unsigned char action_copy_try_one(PanelState *src_panel, const char *filename, unsigned char is_directory,
										 unsigned int page_offset, unsigned char *ws_active, unsigned char *io_active)
{
	unsigned char res;

	res = copy_do_one_item_res(src_panel, filename, is_directory, page_offset, ws_active, io_active);
	if (res == COPY_ITEM_NOMEM)
	{
		copy_progress_draw_name("No memory page");
		return 0;
	}
	return 1;
}

/* 1=continue batch, 0=stop (no memory) */
static unsigned char action_move_try_one(PanelState *src_panel, const char *filename, unsigned char is_directory,
										 unsigned int page_offset, unsigned char *ws_active, unsigned char *io_active)
{
	return action_copy_try_one(src_panel, filename, is_directory, page_offset, ws_active, io_active);
}

static void action_move_common_finish(PanelState *src_panel, PanelState *dst_panel, const char *snap_left,
									  const char *snap_right)
{
	copy_prog.drawn = 0;
	if (g_copy_tree_failed && !g_fileop_abort)
		ui_error_dialog("Move", "Cannot write to destination");
	panel_path_normalize(&left_panel, snap_left);
	panel_path_normalize(&right_panel, snap_right);
	if (copy_dest_path_ok())
		panel_path_normalize(dst_panel, set.temp_path);
	OS_CHDIR((unsigned char *)src_panel->current_path);
	panel_mark_clear_all(src_panel);
	panels_refresh_after_copy_snaps(src_panel, dst_panel, snap_left, snap_right, NULL);
}

/* Same-volume move: OS_RENAME with full paths; folder merge falls back to copy+delete. */
static unsigned char move_samedrive_one_item(PanelState *src_panel, const char *filename, unsigned char is_directory,
											 unsigned int page_offset, unsigned char *ws_active,
											 unsigned char *io_active)
{
	char full_src_path[200];
	char full_dst_path[200];
	unsigned char ow;
	unsigned char saved;

	build_full_path(full_src_path, src_panel->current_path, filename);
	build_full_path(full_dst_path, set.temp_path, filename);

	if (strcmp(full_src_path, full_dst_path) == 0)
		return COPY_FILE_OK;

	if (!is_directory)
	{
		saved = resident_bank_push();
		ow = copy_check_overwrite(full_dst_path);
		if (ow == COPY_FILE_SKIP || ow == COPY_FILE_ABORT)
		{
			resident_bank_pop(saved);
			return ow;
		}
		if (copy_dest_exists(full_dst_path))
			(void)OS_DELETE((unsigned char *)full_dst_path);
		copy_progress_file_begin(filename, 0);
		if ((unsigned char)OS_RENAME((unsigned char *)full_src_path, (unsigned char *)full_dst_path) != 0u)
		{
			resident_bank_pop(saved);
			g_copy_tree_failed = 1;
			return COPY_FILE_ERR;
		}
		resident_bank_pop(saved);
		return COPY_FILE_OK;
	}

	if (!copy_dir_exists(full_dst_path))
	{
		saved = resident_bank_push();
		copy_progress_file_begin(filename, 1);
		if ((unsigned char)OS_RENAME((unsigned char *)full_src_path, (unsigned char *)full_dst_path) != 0u)
		{
			resident_bank_pop(saved);
			g_copy_tree_failed = 1;
			return COPY_FILE_ERR;
		}
		resident_bank_pop(saved);
		return COPY_FILE_OK;
	}

	return copy_do_one_item_res(src_panel, filename, 1, page_offset, ws_active, io_active);
}

/* 1=continue batch, 0=stop (no memory) */
static unsigned char action_move_samedrive_try_one(PanelState *src_panel, const char *filename,
												   unsigned char is_directory, unsigned int page_offset,
												   unsigned char *ws_active, unsigned char *io_active)
{
	unsigned char res;

	res = move_samedrive_one_item(src_panel, filename, is_directory, page_offset, ws_active, io_active);
	if (res == COPY_ITEM_NOMEM)
	{
		copy_progress_draw_name("No memory page");
		return 0;
	}
	if (res == COPY_FILE_ABORT)
		g_fileop_abort = 1;
	return 1;
}

static void action_move_samedrive_run(PanelState *src_panel, PanelState *dst_panel, const char *snap_left,
									  const char *snap_right, unsigned char n_marked)
{
	unsigned int real_idx;
	unsigned int page_offset;
	unsigned int list_pos;
	unsigned char is_directory;
	unsigned char ws_active;
	unsigned char io_active;
	unsigned char res;
	static char saved_filename[64];

	fileop_abort_clear();
	g_copy_tree_failed = 0;
	g_move_active = 1;
	g_copy_overwrite_mode = COPY_OW_ASK_EACH;
	fileop_progress_begin_title(0, "Moving");
	ws_active = 0;
	io_active = 0;

	if (n_marked == 0u)
	{
		real_idx = panel_meta_get_index(src_panel, src_panel->cursor_idx);
		switch_file_page(src_panel, real_idx);
		page_offset = real_idx % FILES_PER_PAGE;
		set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
		is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;
		if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
		{
			g_move_active = 0;
			copy_prog.drawn = 0;
			goto move_sd_finish;
		}
		copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);
		(void)action_move_samedrive_try_one(src_panel, saved_filename, is_directory, page_offset, &ws_active,
											&io_active);
	}
	else
	{
		for (list_pos = 0; list_pos < src_panel->file_count; list_pos++)
		{
			if (g_fileop_abort)
				break;
			if (!copy_panel_item_at(src_panel, list_pos, saved_filename, &is_directory))
				continue;
			real_idx = panel_meta_get_index(src_panel, list_pos);
			switch_file_page(src_panel, real_idx);
			page_offset = real_idx % FILES_PER_PAGE;
			set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
			if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
				continue;
			copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);
			res = action_move_samedrive_try_one(src_panel, saved_filename, is_directory, page_offset, &ws_active,
												&io_active);
			if (res == 0)
				break;
			fileop_poll_abort();
		}
	}

	if (g_fileop_abort)
		copy_progress_draw_name("Cancelled");

move_sd_finish:
	g_move_active = 0;
	if (ws_active)
		copy_workspace_end();
	if (io_active)
		copy_io_release();
	action_move_common_finish(src_panel, dst_panel, snap_left, snap_right);
}

static void action_copy_run(PanelState *src_panel, PanelState *dst_panel, const char *snap_left, const char *snap_right,
							unsigned char n_marked)
{
	unsigned int real_idx;
	unsigned int page_offset;
	unsigned int list_pos;
	unsigned char is_directory;
	unsigned char ws_active;
	unsigned char io_active;
	unsigned char res;
	static char saved_filename[64];

	fileop_abort_clear();
	g_copy_tree_failed = 0;
	fileop_progress_begin(0);
	ws_active = 0;
	io_active = 0;

	if (n_marked == 0u)
	{
		real_idx = panel_meta_get_index(src_panel, src_panel->cursor_idx);
		switch_file_page(src_panel, real_idx);
		page_offset = real_idx % FILES_PER_PAGE;
		set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
		is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;
		if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
		{
			copy_prog.drawn = 0;
			goto copy_finish;
		}
		copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);
		(void)action_copy_try_one(src_panel, saved_filename, is_directory, page_offset, &ws_active, &io_active);
	}
	else
	{
		for (list_pos = 0; list_pos < src_panel->file_count; list_pos++)
		{
			if (g_fileop_abort)
				break;
			if (!copy_panel_item_at(src_panel, list_pos, saved_filename, &is_directory))
				continue;
			real_idx = panel_meta_get_index(src_panel, list_pos);
			switch_file_page(src_panel, real_idx);
			page_offset = real_idx % FILES_PER_PAGE;
			set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
			if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
				continue;
			copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);
			res = action_copy_try_one(src_panel, saved_filename, is_directory, page_offset, &ws_active, &io_active);
			if (res == 0)
				break;
			fileop_poll_abort();
		}
	}

	if (g_fileop_abort)
		copy_progress_draw_name("Cancelled");

copy_finish:
	if (ws_active)
		copy_workspace_end();
	if (io_active)
		copy_io_release();

	copy_prog.drawn = 0;
	if (g_copy_tree_failed && !g_fileop_abort)
		ui_error_dialog("Copy", "Cannot write to destination");
	panel_path_normalize(&left_panel, snap_left);
	panel_path_normalize(&right_panel, snap_right);
	if (copy_dest_path_ok())
		panel_path_normalize(dst_panel, set.temp_path);
	OS_CHDIR((unsigned char *)src_panel->current_path);
	panel_mark_clear_all(src_panel);
	panels_refresh_after_copy_snaps(src_panel, dst_panel, snap_left, snap_right, NULL);
}

static void action_move_run(PanelState *src_panel, PanelState *dst_panel, const char *snap_left, const char *snap_right,
							unsigned char n_marked)
{
	unsigned int real_idx;
	unsigned int page_offset;
	unsigned int list_pos;
	unsigned char is_directory;
	unsigned char ws_active;
	unsigned char io_active;
	unsigned char res;
	static char saved_filename[64];

	fileop_abort_clear();
	g_copy_tree_failed = 0;
	g_move_active = 1;
	fileop_progress_begin_title(0, "Moving");
	ws_active = 0;
	io_active = 0;

	if (n_marked == 0u)
	{
		real_idx = panel_meta_get_index(src_panel, src_panel->cursor_idx);
		switch_file_page(src_panel, real_idx);
		page_offset = real_idx % FILES_PER_PAGE;
		set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
		is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;
		if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
		{
			copy_prog.drawn = 0;
			goto move_finish;
		}
		copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);
		(void)action_move_try_one(src_panel, saved_filename, is_directory, page_offset, &ws_active, &io_active);
	}
	else
	{
		for (list_pos = 0; list_pos < src_panel->file_count; list_pos++)
		{
			if (g_fileop_abort)
				break;
			if (!copy_panel_item_at(src_panel, list_pos, saved_filename, &is_directory))
				continue;
			real_idx = panel_meta_get_index(src_panel, list_pos);
			switch_file_page(src_panel, real_idx);
			page_offset = real_idx % FILES_PER_PAGE;
			set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
			if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
				continue;
			copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);
			res = action_move_try_one(src_panel, saved_filename, is_directory, page_offset, &ws_active, &io_active);
			if (res == 0)
				break;
			fileop_poll_abort();
		}
	}

	if (g_fileop_abort)
		copy_progress_draw_name("Cancelled");

move_finish:
	g_move_active = 0;
	if (ws_active)
		copy_workspace_end();
	if (io_active)
		copy_io_release();
	action_move_common_finish(src_panel, dst_panel, snap_left, snap_right);
}

void Action_Copy(void)
{
	PanelState *src_panel;
	PanelState *dst_panel;
	unsigned int real_idx;
	unsigned int page_offset;
	unsigned char dialog_result;
	unsigned int len;
	unsigned char is_directory;
	unsigned char n_marked;
	const char *dlg_title;

	static char snap_left[64];
	static char snap_right[64];

	src_panel = (left_panel.is_active) ? &left_panel : &right_panel;
	dst_panel = (left_panel.is_active) ? &right_panel : &left_panel;

	strncpy(snap_left, left_panel.current_path, sizeof(snap_left) - 1u);
	snap_left[sizeof(snap_left) - 1u] = 0;
	strncpy(snap_right, right_panel.current_path, sizeof(snap_right) - 1u);
	snap_right[sizeof(snap_right) - 1u] = 0;

	if (src_panel->file_count == 0)
		return;

	n_marked = copy_get_marked_count(src_panel);
	if (n_marked > 1u)
		dlg_title = "Copy selection";
	else
	{
		real_idx = panel_meta_get_index(src_panel, src_panel->cursor_idx);
		switch_file_page(src_panel, real_idx);
		page_offset = real_idx % FILES_PER_PAGE;
		set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
		is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;
		if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
			return;
		dlg_title = is_directory ? "Copy directory" : "Copy file";
	}

	strncpy(set.temp_path, dst_panel->current_path, sizeof(set.temp_path) - 1);
	set.temp_path[sizeof(set.temp_path) - 1] = '\0';

	len = strlen(set.temp_path);
	if (len > 0 && set.temp_path[len - 1] != '/' && set.temp_path[len - 1] != '\\')
		strcat(set.temp_path, "/");

	g_copy_overwrite_mode = COPY_OW_ASK_EACH;

	dialog_result = ui_dialog_input(dlg_title, "Copy to:");
	if (dialog_result == D_RES_CANCEL)
	{
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)src_panel->current_path);
		panels_refresh_after_copy_snaps(src_panel, dst_panel, snap_left, snap_right, NULL);
		return;
	}

	if (!copy_dest_path_ok())
	{
		ui_error_dialog("Copy", "Destination path not found");
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)src_panel->current_path);
		panels_refresh_after_copy_snaps(src_panel, dst_panel, snap_left, snap_right, NULL);
		return;
	}

	action_copy_run(src_panel, dst_panel, snap_left, snap_right, n_marked);
}

static unsigned char move_path_drive_letter(const char *path)
{
	if (path[0] >= 'A' && path[0] <= 'Z')
		return (unsigned char)path[0];
	if (path[0] >= 'a' && path[0] <= 'z')
		return (unsigned char)(path[0] - 'a' + 'A');
	return 0;
}

static void move_restore_ui(PanelState *src_panel, const char *snap_left, const char *snap_right)
{
	panel_path_normalize(&left_panel, snap_left);
	panel_path_normalize(&right_panel, snap_right);
	OS_CHDIR((unsigned char *)src_panel->current_path);
	panels_redraw_current(src_panel);
}

void Action_Move(void)
{
	PanelState *src_panel;
	PanelState *dst_panel;
	unsigned int real_idx;
	unsigned int page_offset;
	unsigned char dialog_result;
	unsigned int len;
	unsigned char src_drv;
	unsigned char dst_drv;
	unsigned char n_marked;
	unsigned char is_directory;
	const char *dlg_title;
	static char snap_left[64];
	static char snap_right[64];

	src_panel = (left_panel.is_active) ? &left_panel : &right_panel;
	dst_panel = (left_panel.is_active) ? &right_panel : &left_panel;

	strncpy(snap_left, left_panel.current_path, sizeof(snap_left) - 1u);
	snap_left[sizeof(snap_left) - 1u] = 0;
	strncpy(snap_right, right_panel.current_path, sizeof(snap_right) - 1u);
	snap_right[sizeof(snap_right) - 1u] = 0;

	if (src_panel->file_count == 0)
		return;

	n_marked = copy_get_marked_count(src_panel);
	if (n_marked > 1u)
		dlg_title = "Move selection";
	else
	{
		real_idx = panel_meta_get_index(src_panel, src_panel->cursor_idx);
		switch_file_page(src_panel, real_idx);
		page_offset = real_idx % FILES_PER_PAGE;
		set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
		is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;
		if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
			return;
		dlg_title = is_directory ? "Move directory" : "Move file";
	}

	strncpy(set.temp_path, dst_panel->current_path, sizeof(set.temp_path) - 1);
	set.temp_path[sizeof(set.temp_path) - 1] = '\0';

	len = strlen(set.temp_path);
	if (len > 0 && set.temp_path[len - 1] != '/' && set.temp_path[len - 1] != '\\')
		strcat(set.temp_path, "/");

	dialog_result = ui_dialog_input(dlg_title, "Move to:");
	if (dialog_result == D_RES_CANCEL)
	{
		move_restore_ui(src_panel, snap_left, snap_right);
		return;
	}

	if (!copy_dest_path_ok())
	{
		ui_error_dialog("Move", "Destination path not found");
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)src_panel->current_path);
		panels_refresh_after_copy_snaps(src_panel, dst_panel, snap_left, snap_right, NULL);
		return;
	}

	src_drv = move_path_drive_letter(src_panel->current_path);
	dst_drv = move_path_drive_letter(set.temp_path);
	if (dst_drv == 0)
		dst_drv = move_path_drive_letter(dst_panel->current_path);

	if (src_drv == dst_drv)
		action_move_samedrive_run(src_panel, dst_panel, snap_left, snap_right, n_marked);
	else
	{
		g_copy_overwrite_mode = COPY_OW_ASK_EACH;
		action_move_run(src_panel, dst_panel, snap_left, snap_right, n_marked);
	}
}

void Action_Rename(void)
{
	PanelState *active_p;
	unsigned int real_idx;
	unsigned int page_offset;
	unsigned char dialog_result;
	unsigned char is_directory;
	char snap_left[64];
	char snap_right[64];
	static char saved_filename[64];

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	strncpy(snap_left, left_panel.current_path, sizeof(snap_left) - 1u);
	snap_left[sizeof(snap_left) - 1u] = 0;
	strncpy(snap_right, right_panel.current_path, sizeof(snap_right) - 1u);
	snap_right[sizeof(snap_right) - 1u] = 0;

	if (active_p->file_count == 0)
		return;

	real_idx = panel_meta_get_index(active_p, active_p->cursor_idx);
	switch_file_page(active_p, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;

	is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;

	if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
		return;

	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);

	strncpy(set.temp_path, saved_filename, sizeof(set.temp_path) - 1u);
	set.temp_path[sizeof(set.temp_path) - 1u] = 0;

	dialog_result = ui_dialog_input(is_directory ? "Rename directory" : "Rename file", "Rename to:");
	if (dialog_result == D_RES_CANCEL)
	{
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)active_p->current_path);
		panels_redraw_current(active_p);
		return;
	}

	nc_ini_rtrim(set.temp_path);
	if (!nc_mkdir_name_valid(set.temp_path))
	{
		ui_alert_dialog("Rename", "Invalid name");
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)active_p->current_path);
		panels_redraw_current(active_p);
		return;
	}

	if (strcmp(set.temp_path, saved_filename) == 0)
	{
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)active_p->current_path);
		panels_redraw_current(active_p);
		return;
	}

	if (!panel_chdir_only(active_p->current_path))
	{
		ui_alert_dialog("Rename failed", "Cannot enter directory");
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)active_p->current_path);
		panels_redraw_current(active_p);
		return;
	}

	SETPG32KHIGH(residentPg);

	/* cmd ren: bare names in current panel directory */
	if ((unsigned char)OS_RENAME((unsigned char *)saved_filename, (unsigned char *)set.temp_path) != 0u)
		ui_alert_dialog("Rename failed", "Name in use or invalid");

	panel_path_normalize(&left_panel, snap_left);
	panel_path_normalize(&right_panel, snap_right);
	OS_CHDIR((unsigned char *)active_p->current_path);
	panels_refresh_all(set.temp_path);
}

static void panels_redraw_current(PanelState *active_p)
{
	panels_remap_bank_window();
	redraw_panels_full();
	draw_bottom_info(active_p);
}

void Action_MkDir(void)
{
	PanelState *active_p;
	unsigned char dialog_result;
	char fullpath[200];
	char snap_left[64];
	char snap_right[64];

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	strncpy(snap_left, left_panel.current_path, sizeof(snap_left) - 1u);
	snap_left[sizeof(snap_left) - 1u] = 0;
	strncpy(snap_right, right_panel.current_path, sizeof(snap_right) - 1u);
	snap_right[sizeof(snap_right) - 1u] = 0;

	set.temp_path[0] = 0;
	panel_chdir_only(active_p->current_path);

	dialog_result = ui_dialog_input("Create directory", "Name:");
	if (dialog_result == D_RES_CANCEL)
	{
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)active_p->current_path);
		panels_redraw_current(active_p);
		return;
	}

	nc_ini_rtrim(set.temp_path);
	if (!nc_mkdir_name_valid(set.temp_path))
	{
		ui_alert_dialog("MkDir", "Invalid name");
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)active_p->current_path);
		panels_redraw_current(active_p);
		return;
	}

	build_full_path(fullpath, active_p->current_path, set.temp_path);
	if (OS_MKDIR((unsigned char *)fullpath) != 0u)
		ui_alert_dialog("MkDir failed", fullpath);

	panel_path_normalize(&left_panel, snap_left);
	panel_path_normalize(&right_panel, snap_right);
	panels_refresh_all(set.temp_path);
}

/* Build "Delete file/folder <name>?" into set.temp_path. */
static void delete_build_prompt_one(const char *item_name, unsigned char is_dir)
{
	unsigned char i;
	unsigned char j;
	const char *pfx;
	unsigned char max_name;

	i = 0;
	pfx = is_dir ? "Delete folder " : "Delete file ";
	while (pfx[0] != 0 && i < 48u)
	{
		set.temp_path[i] = pfx[0];
		pfx++;
		i++;
	}
	max_name = (unsigned char)(sizeof(set.temp_path) - (size_t)i - 2u);
	j = 0;
	while (item_name[j] != 0 && j < max_name)
	{
		set.temp_path[i] = item_name[j];
		i++;
		j++;
	}
	set.temp_path[i++] = '?';
	set.temp_path[i] = 0;
}

/* "Delete N items?" ? N = marked count only, not tree contents. */
static void delete_build_prompt_multi(unsigned char count)
{
	unsigned char i;

	i = 0;
	set.temp_path[i++] = 'D';
	set.temp_path[i++] = 'e';
	set.temp_path[i++] = 'l';
	set.temp_path[i++] = 'e';
	set.temp_path[i++] = 't';
	set.temp_path[i++] = 'e';
	set.temp_path[i++] = ' ';
	ui_str_append_uint(set.temp_path, &i, count);
	set.temp_path[i++] = ' ';
	set.temp_path[i++] = 'i';
	set.temp_path[i++] = 't';
	set.temp_path[i++] = 'e';
	set.temp_path[i++] = 'm';
	if (count != 1u)
		set.temp_path[i++] = 's';
	set.temp_path[i++] = '?';
	set.temp_path[i] = 0;
}

/* True if panel cwd is inside dir (or equals dir), case-insensitive drive letter. */
static unsigned char panel_path_under_dir(const char *path, const char *dir)
{
	unsigned int lp;
	unsigned int ld;
	unsigned int i;

	ld = 0;
	while (dir[ld] != 0 && ld < 63u)
		ld++;
	while (ld > 0 && dir[ld - 1u] == '/')
		ld--;

	lp = 0;
	while (path[lp] != 0 && lp < 63u)
		lp++;

	for (i = 0; i < ld; i++)
	{
		unsigned char a;
		unsigned char b;

		a = (unsigned char)path[i];
		b = (unsigned char)dir[i];
		if (a >= 'a' && a <= 'z')
			a = (unsigned char)(a - 'a' + 'A');
		if (b >= 'a' && b <= 'z')
			b = (unsigned char)(b - 'a' + 'A');
		if (a != b)
			return 0;
	}
	if (lp == ld)
		return 1;
	if (lp > ld && path[ld] == '/')
		return 1;
	return 0;
}

/* Move path to parent of deleted tree (keeps "M:/" root form). */
static void panel_path_to_parent_of(char *path, const char *dir_path)
{
	unsigned int len;
	unsigned int i;

	strncpy(path, dir_path, 63u);
	path[63] = 0;
	len = 0;
	while (path[len] != 0)
		len++;
	while (len > 0 && path[len - 1u] == '/')
		len--;
	if (len <= 3u)
		return;
	for (i = len; i > 0; i--)
	{
		if (path[i - 1u] == '/')
		{
			if (i == 3u && path[1] == ':')
			{
				path[3] = '/';
				path[4] = 0;
			}
			else
			{
				path[i] = 0;
			}
			return;
		}
	}
}

/* If a panel was inside the removed folder, chdir it to the parent path. */
static void panels_fixup_after_dir_delete(const char *deleted_dir)
{
	if (panel_path_under_dir(left_panel.current_path, deleted_dir))
	{
		panel_path_to_parent_of(left_panel.current_path, deleted_dir);
		panel_path_normalize(&left_panel, left_panel.current_path);
	}
	if (panel_path_under_dir(right_panel.current_path, deleted_dir))
	{
		panel_path_to_parent_of(right_panel.current_path, deleted_dir);
		panel_path_normalize(&right_panel, right_panel.current_path);
	}
}

/* --- Iterative directory purge (deltree-style path stack on bank page) --- */

static void deldir_stack_clear(void)
{
	g_deldir_sp = 0;
}

/* Push absolute path; returns 0 if stack overflow (too deep). */
static unsigned char deldir_stack_push(const char *path)
{
	char *slot;
	unsigned char i;

	if (g_deldir_sp >= DELETE_DIR_STACK_MAX)
		return 0;
	slot = delete_stack_slot(g_deldir_sp);
	i = 0;
	while (path[i] != 0 && i < 63u)
	{
		slot[i] = path[i];
		i++;
	}
	slot[i] = 0;
	g_deldir_sp++;
	return 1;
}

static void deldir_stack_pop(void)
{
	if (g_deldir_sp > 0u)
		g_deldir_sp--;
}

static void deldir_stack_top(char *out)
{
	const char *slot;
	unsigned char i;

	if (g_deldir_sp == 0u)
	{
		out[0] = 0;
		return;
	}
	slot = delete_stack_slot((unsigned char)(g_deldir_sp - 1u));
	i = 0;
	while (slot[i] != 0 && i < 63u)
	{
		out[i] = slot[i];
		i++;
	}
	out[i] = 0;
}

/* First non-dot entry in already opened directory; uses global r_global_info. */
static unsigned char delete_find_first(char *name_out, unsigned char *is_dir_out)
{
	unsigned char res;

	for (;;)
	{
		panel_clear_finfo(&r_global_info);
		res = OS_READDIR(&r_global_info);
		if (res == 4 || res != 0)
			return 0;
		if (copy_is_dot_entry(&r_global_info))
			continue;
		copy_name_preserve_case(&r_global_info, name_out);
		*is_dir_out = (unsigned char)((r_global_info.fattrib & 0x10) ? 1u : 0u);
		return 1;
	}
}

/* After OS_CHDIR(".."), re-enter parent so OS directory cache stays valid (deltree). */
static unsigned char delete_chdir_parent(void)
{
	char parent[64];

	deldir_stack_top(parent);
	if (parent[0] == 0)
		return 0;
	return (unsigned char)(OS_CHDIR((unsigned char *)parent) == 0);
}

/*
 * Empty a directory tree under root_path (relative names inside each level).
 * Algorithm: loop { OPENDIR; take first entry; DELETE file or CHDIR subdir }.
 * When a folder has no entries left: CHDIR "..", restore parent path, DELETE folder, pop stack.
 * Does not delete root_path itself ? caller deletes the selected folder after purge.
 */
static void delete_tree_purge(const char *root_path)
{
	char local_name[64];
	char sub_path[64];
	char cur_dir[64];
	char folder_comp[64];
	unsigned char is_dir;
	unsigned char found;

	if (g_fileop_abort)
		return;

	if (OS_CHDIR((unsigned char *)root_path) != 0)
		return;

	deldir_stack_clear();
	if (!deldir_stack_push(root_path))
		return;

	for (;;)
	{
		if (g_fileop_abort)
			return;
		OS_OPENDIR("");
		found = delete_find_first(local_name, &is_dir);

		if (!found)
		{
			if (g_deldir_sp <= 1u)
			{
				OS_CHDIR((unsigned char *)"..");
				deldir_stack_pop();
				return;
			}

			deldir_stack_top(cur_dir);
			path_basename_from(cur_dir, folder_comp);
			deldir_stack_pop();
			OS_CHDIR((unsigned char *)"..");
			if (!delete_chdir_parent())
				return;

			delete_progress_show_name(folder_comp);
			(void)OS_DELETE((unsigned char *)folder_comp);
			fileop_poll_abort();
			continue;
		}

		delete_progress_show_name(local_name);

		if (is_dir)
		{
			deldir_stack_top(cur_dir);
			build_full_path(sub_path, cur_dir, local_name);
			if (!deldir_stack_push(sub_path))
				return;
			if (OS_CHDIR((unsigned char *)local_name) != 0)
			{
				deldir_stack_pop();
				continue;
			}
		}
		else
		{
			(void)OS_DELETE((unsigned char *)local_name);
		}
		fileop_poll_abort();
	}
}

static void delete_one_item(const char *saved_filename, const char *full_path, unsigned char is_directory)
{
	if (is_directory)
	{
		delete_progress_show_name(saved_filename);
		delete_tree_purge(full_path);
		if (!g_fileop_abort)
		{
			(void)OS_DELETE((unsigned char *)full_path);
			panels_fixup_after_dir_delete(full_path);
		}
	}
	else
	{
		delete_progress_show_name(saved_filename);
		(void)OS_DELETE((unsigned char *)full_path);
	}
}

/* Key 8: delete marked files or cursor entry; one Yes/No, then silent purge. */
void Action_Delete(void)
{
	PanelState *panel;
	unsigned int real_idx;
	unsigned int page_offset;
	unsigned int list_pos;
	unsigned char n_marked;
	unsigned char res;
	static char saved_filename[64];
	static char full_path[200];
	unsigned char is_directory;

	panel = (left_panel.is_active) ? &left_panel : &right_panel;

	if (panel->file_count == 0u)
		return;

	n_marked = copy_get_marked_count(panel);

	if (n_marked == 0u)
	{
		real_idx = panel_meta_get_index(panel, panel->cursor_idx);
		switch_file_page(panel, real_idx);
		page_offset = real_idx % FILES_PER_PAGE;
		is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1u : 0u;
		if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
			return;
		copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);
		delete_build_prompt_one(saved_filename, is_directory);
	}
	else
		delete_build_prompt_multi(n_marked);

	res = ui_dialog_delete_confirm("Delete", set.temp_path);
	if (res != D_RES_YES)
	{
		panels_redraw_current(panel);
		return;
	}

	if (!delete_workspace_begin())
	{
		ui_alert_dialog("Delete", "No memory page");
		panels_redraw_current(panel);
		return;
	}

	fileop_abort_clear();
	delete_progress_ensure();

	if (n_marked == 0u)
	{
		build_full_path(full_path, panel->current_path, saved_filename);
		delete_one_item(saved_filename, full_path, is_directory);
	}
	else
	{
		for (list_pos = 0; list_pos < panel->file_count; list_pos++)
		{
			if (g_fileop_abort)
				break;
			if (!copy_panel_item_at(panel, list_pos, saved_filename, &is_directory))
				continue;
			real_idx = panel_meta_get_index(panel, list_pos);
			switch_file_page(panel, real_idx);
			page_offset = real_idx % FILES_PER_PAGE;
			if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
				continue;
			build_full_path(full_path, panel->current_path, saved_filename);
			panel_chdir_only(panel->current_path);
			delete_one_item(saved_filename, full_path, is_directory);
			fileop_poll_abort();
		}
	}

	if (g_fileop_abort)
		copy_progress_draw_name("Cancelled");

	delete_workspace_end();
	copy_prog.drawn = 0;
	g_delete_progress = 0;
	if (left_panel.is_active)
		panel_chdir_only(left_panel.current_path);
	else
		panel_chdir_only(right_panel.current_path);
	panel_mark_clear_all(panel);
	g_focus_pending = 0;
	if (g_fileop_abort)
		panels_redraw_both();
	else
		panels_refresh_after_delete(panel);
}
C_task main(void)
{
	OS_HIDEFROMPARENT();
	OS_SETGFX(0x86);
	OS_CLS(0);
	OS_SETSYSDRV();

	nc_capture_startup_path();

	init();
	print_cstr("Build: ");
	print_cstr(__DATE__);
	print_cstr(" ");
	print_cstr(__TIME__);
	print_cstr(" '");
	print_cstr(uVer);
	print_cstr("' ");
	print_crlf();

	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;

	init_panels();
	nc_ini_load();
	nc_nvext_load();
	panel_fixup_startup_path(&left_panel);
	panel_fixup_startup_path(&right_panel);

	panels_reload_both(left_panel.current_path, right_panel.current_path);
	OS_CLS(0);
	panels_draw_all(&left_panel);

	while (1)
	{
		unsigned char key;
		PanelState *active_p;
		active_p = (left_panel.is_active) ? &left_panel : &right_panel;

		key = OS_GETKEY();

		if (key == NC_KEY_FOCUS)
		{
			nc_on_focus_refresh();
			continue;
		}

		if (g_focus_pending)
		{
			nc_on_focus_refresh();
			continue;
		}

		if (g_menu_active)
		{
			if (key == 0)
			{
				YIELD();
				nc_clock_draw(0);
				continue;
			}
			menu_handle_key(key);
			continue;
		}

		if (g_drive_active)
		{
			if (key == 0)
			{
				YIELD();
				nc_clock_draw(0);
				continue;
			}
			panel_drive_handle_key(key);
			continue;
		}

		/* F10..F1 (176..185) -> '0'..'9' */
		if (key >= NC_KEY_F10 && key <= NC_KEY_F9)
			key = (unsigned char)('0' + (key - NC_KEY_F10));

		switch (key)
		{
		case 0:
			YIELD();
			nc_clock_draw(0);
			continue;
		case '0':
			nc_ini_save();
			exit(0);
			continue;
		case '1':
			panel_drive_open(&left_panel);
			continue;
		case '2':
			panel_drive_open(&right_panel);
			continue;
		case '3':
			nc_action_view(active_p);
			continue;
		case '4':
			nc_action_edit(active_p);
			continue;
		case '9':
			menu_open();
			continue;
		case '8':
			Action_Delete();
			break;
		case '5':
			Action_Copy();
			break;
		case '6':
			Action_Rename();
			break;
		case NC_KEY_SHIFT_6:
			Action_Move();
			break;
		case '7':
			Action_MkDir();
			break;
		}

		if (key == NC_KEY_MARK_INS || key == NC_KEY_MARK_STAR)
		{
			panel_mark_toggle_cursor(active_p);
			continue;
		}

		if (key == 9)
		{
			left_panel.is_active = !left_panel.is_active;
			right_panel.is_active = !right_panel.is_active;
			active_p = (left_panel.is_active) ? &left_panel : &right_panel;
			draw_file_line(&left_panel, 0, left_panel.cursor_idx);
			draw_file_line(&right_panel, 40, right_panel.cursor_idx);
			draw_bottom_info(active_p);
			continue;
		}

		if (key == 250)
		{
			if (active_p->cursor_idx > 0)
			{
				unsigned int old_idx = active_p->cursor_idx;
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				active_p->cursor_idx--;
				if (active_p->cursor_idx < active_p->scroll_offset)
				{
					active_p->scroll_offset = active_p->cursor_idx;
				}
				if (active_p->scroll_offset + 1u == old_scroll)
				{
					panel_files_scroll_down(start_x);
					panel_draw_vis_row(active_p, start_x, 0, active_p->scroll_offset);
					if (active_p->scroll_offset + 1u < active_p->file_count)
						panel_draw_vis_row(active_p, start_x, 1, active_p->scroll_offset + 1u);
				}
				else if (active_p->scroll_offset != old_scroll)
				{
					draw_panel(active_p, start_x, 18);
				}
				else
				{
					draw_file_line(active_p, start_x, old_idx);
					draw_file_line(active_p, start_x, active_p->cursor_idx);
				}

				draw_bottom_info(active_p);
			}
			continue;
		}

		if (key == 249)
		{
			if (active_p->cursor_idx + 1 < active_p->file_count)
			{
				unsigned int old_idx = active_p->cursor_idx;
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				active_p->cursor_idx++;
				if (active_p->cursor_idx >= active_p->scroll_offset + 18)
				{
					active_p->scroll_offset = active_p->cursor_idx - 18 + 1;
				}
				if (active_p->scroll_offset == old_scroll + 1u)
				{
					panel_files_scroll_up(start_x);
					panel_draw_vis_row(active_p, start_x, 17, active_p->scroll_offset + 17u);
					panel_draw_vis_row(active_p, start_x, 16, active_p->scroll_offset + 16u);
				}
				else if (active_p->scroll_offset != old_scroll)
				{
					draw_panel(active_p, start_x, 18);
				}
				else
				{
					draw_file_line(active_p, start_x, old_idx);
					draw_file_line(active_p, start_x, active_p->cursor_idx);
				}

				draw_bottom_info(active_p);
			}
			continue;
		}

		if (key == 248)
		{
			if (active_p->cursor_idx > 0)
			{
				unsigned int old_idx = active_p->cursor_idx;
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				if (active_p->cursor_idx >= 18)
					active_p->cursor_idx -= 18;
				else
					active_p->cursor_idx = 0;
				if (active_p->cursor_idx < active_p->scroll_offset)
					active_p->scroll_offset = active_p->cursor_idx;

				if (active_p->scroll_offset != old_scroll)
					draw_panel(active_p, start_x, 18);
				else
				{
					draw_file_line(active_p, start_x, old_idx);
					draw_file_line(active_p, start_x, active_p->cursor_idx);
				}

				draw_bottom_info(active_p);
			}
			continue;
		}

		if (key == 251)
		{
			if (active_p->cursor_idx + 1 < active_p->file_count)
			{
				unsigned int old_idx = active_p->cursor_idx;
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				active_p->cursor_idx += 18;
				if (active_p->cursor_idx >= active_p->file_count)
					active_p->cursor_idx = active_p->file_count - 1;
				if (active_p->cursor_idx >= active_p->scroll_offset + 18)
					active_p->scroll_offset = active_p->cursor_idx - 18 + 1;

				if (active_p->scroll_offset != old_scroll)
					draw_panel(active_p, start_x, 18);
				else
				{
					draw_file_line(active_p, start_x, old_idx);
					draw_file_line(active_p, start_x, active_p->cursor_idx);
				}

				draw_bottom_info(active_p);
			}
			continue;
		}

		if (key == 13)
		{
			handle_enter(active_p);

			draw_bottom_info(active_p);
			continue;
		}
	}
}
