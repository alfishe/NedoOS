#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <../common/terminal.c>
#include <osfs.h>
#include <ctype.h>
#include <math.h>

#define true 1
#define false 0
#define screenHeight 23
#define screenWidth 80

#define BLACK 0
#define BLUE 1
#define RED 2
#define MAGENTA 3
#define GREEN 4
#define CYAN 5
#define YELLOW 6
#define WHITE 7
#define BR_NORMAL 0x00
#define BR_INK 0x40
#define BR_PAPER 0x80
#define BR_BOTH 0xC0
#define MAKE_COLOR(bright, paper, ink) ((unsigned char)((bright) | ((paper) << 3) | (ink)))
#define COLOR_PANEL_MAIN MAKE_COLOR(BR_BOTH, BLUE, WHITE)
#define COLOR_PANEL_CURSOR MAKE_COLOR(BR_BOTH, CYAN, BLACK)
#define COLOR_STATUS_BAR MAKE_COLOR(BR_BOTH, CYAN, BLACK)
#define COLOR_PANEL_BORDER_ACT MAKE_COLOR(BR_BOTH, BLUE, CYAN)
#define COLOR_PANEL_BORDER_PAS MAKE_COLOR(BR_BOTH, BLUE, CYAN)
#define COLOR_COPY_UI MAKE_COLOR(BR_BOTH, YELLOW, BLACK)
#define COLOR_COPY_BAR_FILL MAKE_COLOR(BR_BOTH, BLACK, YELLOW)
#define COLOR_OVERWRITE_UI MAKE_COLOR(BR_BOTH, RED, WHITE)
#define COLOR_MENU_NORM COLOR_STATUS_BAR
#define COLOR_MENU_HILITE MAKE_COLOR(BR_BOTH, BLACK, CYAN)
#define COPY_CH_BAR_FILL 219
#define COPY_CH_BAR_EMPTY 176


#define D_BTN_OK 0x01
#define D_BTN_CANCEL 0x02
#define D_BTN_YES 0x04
#define D_BTN_NO 0x08
#define D_BTN_SKIP 0x10
#define D_BTN_SKIP_ALL 0x20
#define D_BTN_REPLACE_ALL 0x40

#define D_MASK_OK_CANCEL (D_BTN_OK | D_BTN_CANCEL)
#define D_MASK_OVERWRITE                                                                       \
	(D_BTN_YES | D_BTN_NO | D_BTN_SKIP | D_BTN_SKIP_ALL | D_BTN_REPLACE_ALL | D_BTN_CANCEL)


#define COPY_OW_SKIP_ALL 0u
#define COPY_OW_ASK_EACH 1u
#define COPY_OW_REPLACE_ALL 2u
#define COPY_OW_ABORT 3u

#define COPY_FILE_OK 0u
#define COPY_FILE_ERR 1u
#define COPY_FILE_SKIP 2u
#define COPY_FILE_ABORT 3u


#define D_RES_CANCEL 0
#define D_RES_OK 1
#define D_RES_YES 2
#define D_RES_NO 3
#define D_RES_SKIP 4
#define D_RES_SKIP_ALL 5
#define D_RES_REPLACE_ALL 6


#define BANK_WINDOW_ADDRESS 0xC000
#define BANK_PAGE_SIZE 16384u
#define FILINFO_RECORD_SIZE 86u
#define FILES_PER_PAGE 180u
#define PANEL_PAGE_FILES_BYTES (FILES_PER_PAGE * FILINFO_RECORD_SIZE)
#define PANEL_PAGE_EXTRA_OFF PANEL_PAGE_FILES_BYTES
#define PANEL_PAGE_EXTRA_SIZE (BANK_PAGE_SIZE - PANEL_PAGE_EXTRA_OFF)
#define PAGE_EXTRA_FIRSTCHAR_OFF 0u
#define PAGE_EXTRA_RSVD_OFF FILES_PER_PAGE
#define PAGE_EXTRA_CPM4_OFF PAGE_EXTRA_RSVD_OFF
#define PAGE_EXTRA_CPM4_STRIDE 4u
#define PANEL_META_IDX_SIZE 2u
#define PANEL_FILE_PAGES 3
#define PANEL_META_PAGE 3
#define PAGES_PER_PANEL 4
#define MAX_FILES_PER_PANEL (FILES_PER_PAGE * PANEL_FILE_PAGES)
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
#define PANEL_META_USED_BYTES (PANEL_META_OFF_TIME + MAX_FILES_PER_PANEL * 2u)
#define PANEL_META_CLEAR_BYTES (PANEL_META_USED_BYTES <= BANK_PAGE_SIZE ? PANEL_META_USED_BYTES : BANK_PAGE_SIZE)

#define PANEL_KIND_FILE 0u
#define PANEL_KIND_DIR 1u
#define PANEL_KIND_DOTDOT 2u

#define PANEL_SORT_NAME 0u
#define PANEL_SORT_EXT 1u
#define PANEL_SORT_SIZE 2u
#define PANEL_SORT_TIME 3u

#define COPY_TEMP_PAGE_ENTRIES 251

#define MENU_LEVEL_TOP 0u
#define MENU_LEVEL_FILES 1u
#define MENU_FILES_ITEMS 7u
#define MFI_NAME 0u
#define MFI_EXT 1u
#define MFI_SIZE 2u
#define MFI_TIME 3u
#define MFI_AZ 4u
#define MFI_ZA 5u
#define MFI_LFN_SORT 6u
#define MENU_POPUP_X 0u
#define MENU_POPUP_Y 1u
#define MENU_POPUP_INNER_W 20u
#define MENU_ITEM_X 1u

#define PANEL_DRIVE_MAX 15u
#define DRIVE_POPUP_X 0u
#define DRIVE_POPUP_Y 1u
#define DRIVE_POPUP_INNER_W 34u
#define DRIVE_ITEM_X 1u
#define DRIVE_ITEM_W 34u
#define DRVF_NONE 0u
#define DRVF_NEOGS 1u
#define DRVF_ZXNET 2u
#define DRVF_TRDOS 4u /* A..D: always in menu, no CHDRV probe (floppy timeouts) */

#define COPY_CACHE_COUNT_OFF 0u
#define COPY_CACHE_FLAGS_OFF 4u
#define COPY_CACHE_NAMES_OFF (4u + COPY_TEMP_PAGE_ENTRIES)


#define COPY_IO_CHUNK 16384u

typedef struct
{
	unsigned char bank_ids[PAGES_PER_PANEL];
	unsigned char bank_id;
	unsigned int file_count;
	unsigned int cursor_idx;
	unsigned int scroll_offset;
	unsigned char is_active;
	unsigned char sort_mode;
	unsigned char sort_desc;
	unsigned char sort_lfn;
	char current_path[64];
} PanelState;

struct setup
{
	unsigned char freeMem;
	unsigned char totalMem;

	fileInfo current_file;
	char local_dir_name[64];
	char exited_dir_name[64];
	char temp_path[64];
	fileInfo *bank_array;
} set;

void switch_file_page(PanelState *panel, unsigned int file_idx);
int ext_cmp(const char *s1, const char *s2);
void redraw_all(void);
void draw_status_bar(void);
void build_full_path(char *dest, const char *path, const char *filename);

unsigned char uVer[] = "0.1";
unsigned char botMenu[] = "1Drive 2Find 3View 4Edit 5Copy 6Rename 7MkDir 8Delete 9Menu 0Quit";


static char r_src_full[200];
static char r_dst_full[200];
static fileInfo r_global_info;

static unsigned char g_copy_temp_page;
static unsigned char g_copy_snap_page;
static unsigned char g_copy_io_page;
static unsigned char g_copy_page_active;
static unsigned char g_panel_page_used[256];

static unsigned short copy_tmp_date[COPY_TEMP_PAGE_ENTRIES];
static unsigned short copy_tmp_time[COPY_TEMP_PAGE_ENTRIES];
static unsigned short copy_snap_date[COPY_TEMP_PAGE_ENTRIES];
static unsigned short copy_snap_time[COPY_TEMP_PAGE_ENTRIES];

static void panels_remap_bank_window(void);
static void ui_draw_frame(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char color,
						  const char *title);
static void menu_draw_item(unsigned char x, unsigned char y, unsigned char width, unsigned char selected,
						   const char *label, unsigned char current);
static unsigned char g_copy_overwrite_mode;
#define COPY_IO_ADDR ((unsigned char *)0x8000)


static unsigned char g_menu_active;
static unsigned char g_menu_level;
static unsigned char g_menu_sel;

static unsigned char g_drive_active;
static unsigned char g_drive_sel;
static unsigned char g_drive_count;
static unsigned char g_drive_letters[PANEL_DRIVE_MAX];
static char g_drive_labels[PANEL_DRIVE_MAX][26];

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


static unsigned char panel_request_unique_page(unsigned char *page_out)
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


static unsigned char copy_workspace_begin(void)
{
	if (g_copy_page_active)
		return 1;
	if (!panel_request_unique_page(&g_copy_temp_page))
		return 0;
	if (!panel_request_unique_page(&g_copy_snap_page))
	{
		OS_DELPAGE(g_copy_temp_page);
		g_panel_page_used[g_copy_temp_page] = 0;
		g_copy_temp_page = 0;
		return 0;
	}
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
	g_copy_page_active = 1;
	return 1;
}

static void copy_workspace_end(void)
{
	if (!g_copy_page_active)
		return;
	panels_remap_bank_window();
	OS_DELPAGE(g_copy_io_page);
	g_panel_page_used[g_copy_io_page] = 0;
	OS_DELPAGE(g_copy_snap_page);
	g_panel_page_used[g_copy_snap_page] = 0;
	OS_DELPAGE(g_copy_temp_page);
	g_panel_page_used[g_copy_temp_page] = 0;
	g_copy_io_page = 0;
	g_copy_snap_page = 0;
	g_copy_temp_page = 0;
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
	OS_DELPAGE(g_copy_io_page);
	g_panel_page_used[g_copy_io_page] = 0;
	g_copy_io_page = 0;
}

static void copy_cache_map(void)
{
	SETPG32KHIGH(g_copy_temp_page);
}

static void copy_snap_map(void)
{
	SETPG32KHIGH(g_copy_snap_page);
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

static void panel_short_fname_str(const fileInfo *fi, char *out)
{
	unsigned int i;

	for (i = 0; i < 12u && fi->fname[i] != 0 && fi->fname[i] != ' '; i++)
		out[i] = (char)fi->fname[i];
	out[i] = 0;
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

static int panel_cmp_key4(const unsigned char *a, const unsigned char *b)
{
	unsigned int i;
	int cmp;

	for (i = 0; i < PANEL_SORT_KEY_LEN; i++)
	{
		cmp = (int)panel_fold_char(a[i]) - (int)panel_fold_char(b[i]);
		if (cmp != 0)
			return cmp;
	}
	return 0;
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

static void panel_path_basename(PanelState *panel, char *out)
{
	unsigned int len;
	unsigned int i;
	unsigned int start;

	out[0] = 0;
	len = 0;
	while (panel->current_path[len] != 0 && len < 63u)
		len++;
	while (len > 0 && panel->current_path[len - 1u] == '/')
		len--;

	start = 0;
	for (i = 0; i < len; i++)
	{
		if (panel->current_path[i] == '/')
			start = i + 1u;
	}
	for (i = start; i < len && (i - start) < 63u; i++)
		out[i - start] = panel->current_path[i];
	out[i - start] = 0;
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

static void panel_get_entry_name(PanelState *panel, unsigned int real_idx, char *buf)
{
	unsigned int page_offset;
	unsigned int i;
	const char *src;

	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	switch_file_page(panel, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;
	src = panel_entry_name(&set.bank_array[page_offset]);
	for (i = 0; i < 63u && src[i] != 0; i++)
		buf[i] = src[i];
	buf[i] = 0;
	panel_meta_map(panel);
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

/* Short sort: CPM11 keys + cpm[4..7] in LFN4 slot; no LFN keys / page-extra / SETPG in sort. */
static void panel_cache_entry_short(PanelState *panel, unsigned int real_idx, unsigned int page_offset,
									unsigned char file_page)
{
	fileInfo *fi;
	unsigned char kind;
	unsigned char cpm11[11];
	unsigned char *base;

	panel_file_map(panel, file_page);
	fi = &set.bank_array[page_offset];
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

/* Short-name compare helpers (panel_heap_sort_fn83). */
#define SORTFN_REC_BYTES 86u
#define SORTFN_PER_PAGE 180u
#define SORTFN_KEY_LEN 4u
#define SORTFN_MODE_NAME 0u
#define SORTFN_MODE_EXT 1u
#define SORTFN_MODE_SIZE 2u
#define SORTFN_MODE_TIME 3u
#define SORTFN_KIND_FILE 0u
#define SORTFN_KIND_DIR 1u
#define SORTFN_KIND_DOTDOT 2u

static int sortfn_cmp_byte(unsigned char a, unsigned char b)
{
	unsigned char ca;
	unsigned char cb;

	if (a == b)
		return 0;
	ca = a;
	cb = b;
	if (ca >= 'a' && ca <= 'z')
		ca = (unsigned char)(ca - ('a' - 'A'));
	if (cb >= 'a' && cb <= 'z')
		cb = (unsigned char)(cb - ('a' - 'A'));
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
	{
		if (ka == PANEL_KIND_DOTDOT)
			return -1;
		if (kb == PANEL_KIND_DOTDOT)
			return 1;
		if (ka == PANEL_KIND_DIR)
			return -1;
		if (kb == PANEL_KIND_DIR)
			return 1;
		return 0;
	}

	na = ctx->name4 + pa * PANEL_SORT_KEY_LEN;
	nb = ctx->name4 + pb * PANEL_SORT_KEY_LEN;
	ea = ctx->ext4 + pa * PANEL_SORT_KEY_LEN;
	eb = ctx->ext4 + pb * PANEL_SORT_KEY_LEN;
	ma = ctx->cpm4 + pa * PANEL_SORT_KEY_LEN;
	mb = ctx->cpm4 + pb * PANEL_SORT_KEY_LEN;

	switch (ctx->sort_mode)
	{
	case PANEL_SORT_EXT:
		cmp = sortfn_cmp_key4(ea, eb);
		if (cmp == 0)
			cmp = sortfn_cmp_key4(na, nb);
		if (cmp == 0)
			cmp = sortfn_cmp_cpm11_tail_meta(ma, mb, ea, eb);
		break;

	case PANEL_SORT_SIZE:
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

	case PANEL_SORT_TIME:
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

	case PANEL_SORT_NAME:
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
	{
		if (ka == PANEL_KIND_DOTDOT)
			return -1;
		if (kb == PANEL_KIND_DOTDOT)
			return 1;
		if (ka == PANEL_KIND_DIR)
			return -1;
		if (kb == PANEL_KIND_DIR)
			return 1;
		return 0;
	}

	na = ctx->lfn4 + pa * PANEL_SORT_KEY_LEN;
	nb = ctx->lfn4 + pb * PANEL_SORT_KEY_LEN;
	ea = ctx->lfnext4 + pa * PANEL_SORT_KEY_LEN;
	eb = ctx->lfnext4 + pb * PANEL_SORT_KEY_LEN;

	switch (ctx->sort_mode)
	{
	case PANEL_SORT_EXT:
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

	case PANEL_SORT_SIZE:
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

	case PANEL_SORT_TIME:
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

	case PANEL_SORT_NAME:
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


static unsigned char copy_collect_dir(const char *base_src)
{
	unsigned char res;
	unsigned int n;
	unsigned int *pcount;
	unsigned char *pflags;

	if (!g_copy_page_active)
		return 0;

	if (OS_CHDIR((unsigned char *)base_src) != 0)
		return 0;

	OS_OPENDIR("");
	copy_cache_map();

	pcount = copy_cache_count_ptr();
	pflags = copy_cache_flags_ptr();
	n = 0;

	while (n < COPY_TEMP_PAGE_ENTRIES)
	{
		panel_clear_finfo(&r_global_info);
		res = OS_READDIR(&r_global_info);
		if (res == 4)
			break;
		if (res != 0)
			break;

		if (copy_is_dot_entry(&r_global_info))
			continue;

		copy_store_name(n, &r_global_info);
		copy_tmp_date[n] = r_global_info.fdate;
		copy_tmp_time[n] = r_global_info.ftime;
		panel_normalize_fname(&r_global_info);
		pflags[n] = (r_global_info.fattrib & 0x10) ? 1 : 0;
		n++;
	}

	*pcount = n;
	return 1;
}

static void copy_take_dir_snapshot(void)
{
	unsigned int i;
	unsigned int n;
	unsigned char fl;
	char tmp[64];

	copy_cache_map();
	n = *copy_cache_count_ptr();

	copy_snap_map();
	*copy_cache_count_ptr() = n;

	for (i = 0; i < n; i++)
	{
		tmp[0] = 0;
		copy_cache_map();
		fl = copy_cache_flags_ptr()[i];
		strcpy(tmp, copy_cache_name_ptr(i));
		copy_snap_map();
		copy_cache_flags_ptr()[i] = fl;
		strcpy(copy_cache_name_ptr(i), tmp);
		copy_snap_date[i] = copy_tmp_date[i];
		copy_snap_time[i] = copy_tmp_time[i];
	}
}


static unsigned char panel_entry_marked(PanelState *panel, unsigned int list_pos)
{

	return (list_pos == panel->cursor_idx) ? 1 : 0;
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


static unsigned char copy_panel_item_at(PanelState *panel, unsigned int list_pos, char *name_out, unsigned char *is_dir_out)
{
	unsigned int real_idx;
	unsigned int page_offset;
	char *src;
	unsigned int i;

	if (list_pos >= panel->file_count)
		return 0;
	if (!panel_entry_marked(panel, list_pos))
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

PanelState left_panel;
PanelState right_panel;

unsigned char pgbak;
union APP_PAGES main_pg;

struct coordinates
{
	unsigned char winX;
	unsigned char winY;
	unsigned char winW;
	unsigned char winH;
	unsigned char color;
};

void spaces(unsigned char number)
{
	while (number > 0)
	{
		putchar(' ');
		number--;
	}
}

struct DialogWindow
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char color;
	const char *title;
	const char *prompt;
};


void init_panels(void)
{
	unsigned char p;

	panel_pages_mark_clear();


	for (p = 0; p < PAGES_PER_PANEL; p++)
	{
		left_panel.bank_ids[p] = 0;
		if (!panel_request_unique_page(&left_panel.bank_ids[p]))
			left_panel.bank_ids[p] = 0;
	}
	left_panel.file_count = 0;
	left_panel.cursor_idx = 0;
	left_panel.scroll_offset = 0;
	left_panel.is_active = 1;
	left_panel.sort_mode = PANEL_SORT_NAME;
	left_panel.sort_desc = 0;
	left_panel.sort_lfn = 0;
	strcpy(left_panel.current_path, "M:/bin/");


	for (p = 0; p < PAGES_PER_PANEL; p++)
	{
		right_panel.bank_ids[p] = 0;
		if (!panel_request_unique_page(&right_panel.bank_ids[p]))
			right_panel.bank_ids[p] = 0;
	}
	right_panel.file_count = 0;
	right_panel.cursor_idx = 0;
	right_panel.scroll_offset = 0;
	right_panel.is_active = 0;
	right_panel.sort_mode = PANEL_SORT_NAME;
	right_panel.sort_desc = 0;
	right_panel.sort_lfn = 0;
	strcpy(right_panel.current_path, "M:/test/");

	g_menu_active = 0;
	g_menu_level = MENU_LEVEL_TOP;
	g_menu_sel = 0;
	g_drive_active = 0;
	g_drive_sel = 0;
	g_drive_count = 0;
}

void clearStatus(void)
{
	OS_SETCOLOR(5);
	OS_SETXY(0, 24);
	spaces(79);
	putchar('\r');
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


unsigned char show_dialog(struct DialogWindow *dlg, char *buffer, unsigned char max_len, unsigned char btn_mask)
{
	unsigned char wcount, tempx, titleStart;
	unsigned char byte;


	unsigned char cmdLen;
	unsigned char cursorPos;
	unsigned char viewOffset;
	unsigned char visibleLen;
	unsigned char i;
	unsigned char printPos;


	unsigned char activeBtn;
	unsigned char numButtons;
	unsigned char btn_types[6];
	unsigned char focusOnButtons;


	unsigned char totalButtonsWidth;
	unsigned char btnX;
	unsigned char btnY;
	unsigned char inputColor;

	cmdLen = 0;
	cursorPos = 0;
	viewOffset = 0;


	visibleLen = dlg->w - 4;


	inputColor = (unsigned char)(((dlg->color & 0x07) << 3) |
								 ((dlg->color & 0x38) >> 3) |
								 (dlg->color & 0xC0));

	if (buffer != NULL)
	{
		cmdLen = strlen(buffer);
		cursorPos = cmdLen;
		focusOnButtons = 0;
	}
	else
	{
		focusOnButtons = 1;
	}


	numButtons = 0;
	if (btn_mask & D_BTN_YES)
	{
		btn_types[numButtons++] = D_RES_YES;
	}
	if (btn_mask & D_BTN_NO)
	{
		btn_types[numButtons++] = D_RES_NO;
	}
	if (btn_mask & D_BTN_OK)
	{
		btn_types[numButtons++] = D_RES_OK;
	}
	if (btn_mask & D_BTN_SKIP)
	{
		btn_types[numButtons++] = D_RES_SKIP;
	}
	if (btn_mask & D_BTN_SKIP_ALL)
	{
		btn_types[numButtons++] = D_RES_SKIP_ALL;
	}
	if (btn_mask & D_BTN_REPLACE_ALL)
	{
		btn_types[numButtons++] = D_RES_REPLACE_ALL;
	}
	if (btn_mask & D_BTN_CANCEL)
	{
		btn_types[numButtons++] = D_RES_CANCEL;
	}

	activeBtn = 0;


	OS_SETXY(dlg->x, dlg->y - 1);
	BDBOX(dlg->x, dlg->y, dlg->w + 1, dlg->h + 1, dlg->color, 32);


	OS_SETXY(dlg->x, dlg->y);
	OS_SETCOLOR(dlg->color);
	putchar(201);
	for (wcount = 0; wcount < dlg->w; wcount++)
	{
		putchar(205);
	}
	putchar(187);


	OS_SETXY(dlg->x, dlg->y + dlg->h);
	putchar(200);
	for (wcount = 0; wcount < dlg->w; wcount++)
	{
		putchar(205);
	}
	putchar(188);


	tempx = dlg->x + dlg->w + 1;
	for (wcount = 1; wcount < dlg->h; wcount++)
	{
		OS_SETXY(dlg->x, dlg->y + wcount);
		putchar(186);
		OS_SETXY(tempx, dlg->y + wcount);
		putchar(186);
	}


	if (dlg->title != NULL)
	{
		titleStart = dlg->x + (dlg->w / 2) - (strlen(dlg->title) / 2);
		OS_SETXY(titleStart, dlg->y);
		printf("[%s]", dlg->title);
	}


	if (dlg->prompt != NULL)
	{
		OS_SETXY(dlg->x + 2, dlg->y + 1);
		OS_SETCOLOR(dlg->color);
		fast_print_str_width(dlg->prompt, dlg->w - 2);
	}


	for (;;)
	{

		if (buffer != NULL)
		{
			if (cursorPos < viewOffset)
			{
				viewOffset = cursorPos;
			}
			else if (cursorPos - viewOffset >= visibleLen)
			{
				viewOffset = cursorPos - visibleLen + 1;
			}


			OS_SETXY(dlg->x + 2, dlg->y + 3);

			for (i = 0; i < visibleLen; i++)
			{
				printPos = viewOffset + i;

				if (focusOnButtons == 0 && printPos == cursorPos)
				{
					OS_SETCOLOR((unsigned char)(((inputColor & 0x40) << 1) |
												((inputColor & 0x07) << 3) |
												((inputColor & 0x80) >> 1) |
												((inputColor & 0x38) >> 3)));
				}
				else
				{
					OS_SETCOLOR(inputColor);
				}

				if (printPos < cmdLen)
				{
					putchar(buffer[printPos]);
				}
				else
				{
					putchar(' ');
				}
			}
			OS_SETCOLOR(dlg->color);
		}


		if (numButtons > 0)
		{
			unsigned char row;
			unsigned char row_count;
			unsigned char row_start;
			unsigned char rows;
			unsigned char global_idx;

			rows = (numButtons > 4u) ? 2u : 1u;
			for (row = 0; row < rows; row++)
			{
				if (rows == 2u)
				{
					if (row == 0u)
					{
						row_start = 0u;
						row_count = (unsigned char)((numButtons + 1u) / 2u);
						btnY = (unsigned char)(dlg->y + dlg->h - 2u);
					}
					else
					{
						row_start = (unsigned char)((numButtons + 1u) / 2u);
						row_count = (unsigned char)(numButtons - row_start);
						btnY = (unsigned char)(dlg->y + dlg->h - 1u);
					}
				}
				else
				{
					row_start = 0u;
					row_count = numButtons;
					btnY = (unsigned char)(dlg->y + dlg->h - 1u);
				}

				totalButtonsWidth = (unsigned char)((row_count * 11u) - 1u);
				btnX = (unsigned char)(dlg->x + 1u + ((dlg->w - totalButtonsWidth) / 2u));

				for (i = 0; i < row_count; i++)
				{
					global_idx = (unsigned char)(row_start + i);
					OS_SETXY(btnX, btnY);

					if (focusOnButtons == 1 && global_idx == activeBtn)
					{
						OS_SETCOLOR((unsigned char)(((dlg->color & 0x40) << 1) |
													((dlg->color & 0x07) << 3) |
													((dlg->color & 0x80) >> 1) |
													((dlg->color & 0x38) >> 3)));
					}
					else
					{
						OS_SETCOLOR(dlg->color);
					}

					switch (btn_types[global_idx])
					{
					case D_RES_OK:
						printf("[   OK   ]");
						break;
					case D_RES_CANCEL:
						printf("[ Cancel ]");
						break;
					case D_RES_YES:
						printf("[  Yes   ]");
						break;
					case D_RES_NO:
						printf("[   No   ]");
						break;
					case D_RES_SKIP:
						printf("[  Skip  ]");
						break;
					case D_RES_SKIP_ALL:
						printf("[Skip All]");
						break;
					case D_RES_REPLACE_ALL:
						printf("[Yes  All]");
						break;
					}

					btnX = (unsigned char)(btnX + 11u);
				}
			}
			OS_SETCOLOR(dlg->color);
		}

		YIELD();


		byte = OS_GETKEY();
		if (byte != 0)
		{
			switch (byte)
			{
			case 250:
				if (buffer != NULL && focusOnButtons == 1)
				{
					focusOnButtons = 0;
				}
				break;

			case 249:
				if (numButtons > 0 && focusOnButtons == 0)
				{
					focusOnButtons = 1;
				}
				break;

			case 9:
				if (numButtons > 0)
				{
					if (focusOnButtons == 0)
					{
						focusOnButtons = 1;
						activeBtn = 0;
					}
					else
					{
						activeBtn++;
						if (activeBtn >= numButtons)
						{
							if (buffer != NULL)
								focusOnButtons = 0;
							else
								activeBtn = 0;
						}
					}
				}
				break;

			case 248:
				if (focusOnButtons == 1)
				{
					if (activeBtn > 0)
						activeBtn--;
					else
						activeBtn = numButtons - 1;
				}
				else if (buffer != NULL && cursorPos > 0)
				{
					cursorPos--;
				}
				break;

			case 251:
				if (focusOnButtons == 1)
				{
					activeBtn = (activeBtn + 1) % numButtons;
				}
				else if (buffer != NULL && cursorPos < cmdLen)
				{
					cursorPos++;
				}
				break;

			case 0x08:
				if (focusOnButtons == 0 && buffer != NULL && cursorPos > 0 && cmdLen > 0)
				{
					for (i = cursorPos - 1; i < cmdLen; i++)
					{
						buffer[i] = buffer[i + 1];
					}
					cursorPos--;
					cmdLen--;
				}
				break;

			case 252:
				if (focusOnButtons == 0 && buffer != NULL && cursorPos < cmdLen && cmdLen > 0)
				{
					for (i = cursorPos; i < cmdLen; i++)
					{
						buffer[i] = buffer[i + 1];
					}
					cmdLen--;
				}
				break;

			case 0x0d:
				if (focusOnButtons == 1 && numButtons > 0)
				{
					return btn_types[activeBtn];
				}
				return (buffer != NULL) ? D_RES_OK : btn_types[activeBtn];

			case 27:
				return D_RES_CANCEL;

			case 'y':
			case 'Y':
				if (btn_mask & D_BTN_YES)
					return D_RES_YES;
				break;
			case 'n':
			case 'N':
				if (btn_mask & D_BTN_NO)
					return D_RES_NO;
				break;
			case 's':
			case 'S':
				if (btn_mask & D_BTN_SKIP_ALL)
					return D_RES_SKIP_ALL;
				if (btn_mask & D_BTN_SKIP)
					return D_RES_SKIP;
				break;
			case 'r':
			case 'R':
				if (btn_mask & D_BTN_REPLACE_ALL)
					return D_RES_REPLACE_ALL;
				break;
			case 'c':
			case 'C':
				if (btn_mask & D_BTN_CANCEL)
					return D_RES_CANCEL;
				break;

			default:
				if (focusOnButtons == 0 && buffer != NULL && cmdLen < (max_len - 2) && byte >= 32)
				{
					for (i = cmdLen; i > cursorPos; i--)
					{
						buffer[i] = buffer[i - 1];
					}
					buffer[cursorPos] = byte;
					cursorPos++;
					cmdLen++;
					buffer[cmdLen] = 0;
				}
				break;
			}
		}
	}
}

void Action_Delete(void)
{
	struct DialogWindow dlg;
	unsigned char result;

	dlg.x = 20;
	dlg.y = 8;
	dlg.w = 40;
	dlg.h = 5;
	dlg.color = MAKE_COLOR(BR_BOTH, RED, WHITE);
	dlg.title = "Delete File";
	dlg.prompt = "Are you sure you want to delete?";


	result = show_dialog(&dlg, NULL, 0, D_BTN_YES | D_BTN_CANCEL);

	if (result == D_RES_YES)
	{

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


static void panel_place_cursor_after_read(PanelState *panel)
{
	unsigned int i;
	unsigned int phys;
	unsigned char *base;
	unsigned char k;

	panel->scroll_offset = 0;
	if (panel->file_count == 0u)
	{
		panel->cursor_idx = 0;
		return;
	}

	panel_meta_map(panel);
	base = (unsigned char *)BANK_WINDOW_ADDRESS;
	for (i = 0; i < panel->file_count; i++)
	{
		phys = panel_meta_idx_get(base, i);
		k = base[PANEL_META_OFF_KIND + phys];
		if (k != PANEL_KIND_DOTDOT)
		{
			panel->cursor_idx = i;
			panel_file_map(panel, (unsigned char)(phys / FILES_PER_PAGE));
			return;
		}
	}
	panel->cursor_idx = 0;
	panel_file_map(panel, 0);
}


static unsigned char read_panel_dir_at(PanelState *panel, const char *dir_path)
{
	unsigned char result;
	unsigned int idx;

	unsigned int page_offset;
	unsigned char current_page;
	char req_path[64];

	if (!panel_banks_ok(panel))
	{
		panel->file_count = 0;
		panel->cursor_idx = 0;
		panel->scroll_offset = 0;
		return 0;
	}

	panel_path_normalize(panel, dir_path);
	strncpy(req_path, panel->current_path, sizeof(req_path) - 1u);
	req_path[sizeof(req_path) - 1u] = 0;

	current_page = 0;
	panel_file_map(panel, current_page);
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;

	if (!panel_chdir_for_read(req_path))
	{
		panel->file_count = 0;
		panel->cursor_idx = 0;
		panel->scroll_offset = 0;
		panel_file_map(panel, 0);
		return 0;
	}

	idx = 0;
	panel->file_count = 0;
	panel_meta_map(panel);
	panel_page_extra_clear(panel, 0);

	while (idx < MAX_FILES_PER_PANEL)
	{
		page_offset = idx % FILES_PER_PAGE;

		if (idx > 0 && page_offset == 0)
		{
			current_page++;
			if (current_page >= PANEL_FILE_PAGES)
				break;
			panel_page_extra_clear(panel, current_page);
		}
		else
			panel_file_map(panel, current_page);

		panel_clear_finfo(&set.bank_array[page_offset]);
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

		if (panel->sort_lfn)
			panel_cache_entry_lfn(panel, idx, page_offset, current_page);
		else
			panel_cache_entry_short(panel, idx, page_offset, current_page);
		idx++;
	}

	panel->file_count = idx;

	if (panel->file_count >= 2u)
		panel_sort_indices(panel);

	panel_place_cursor_after_read(panel);
	panel_path_normalize(panel, req_path);
	return 1;
}

void read_panel_dir(PanelState *panel)
{
	read_panel_dir_at(panel, panel->current_path);
}


void fast_print_str_pad(const char *str, unsigned char width)
{
	unsigned char i;
	i = 0;

	while (str[i] != 0 && i < width)
	{
		putchar(str[i]);
		i++;
	}

	while (i < width)
	{
		putchar(' ');
		i++;
	}
}

void fast_print_datetime(unsigned int fdate, unsigned int ftime)
{

	unsigned char day, month, year_short;
	unsigned char hour, minute;


	day = (unsigned char)(fdate & 0x1F);
	month = (unsigned char)((fdate >> 5) & 0x0F);

	year_short = (unsigned char)((((fdate >> 9) & 0x7F) + 1980) % 100);


	minute = (unsigned char)((ftime >> 5) & 0x3F);
	hour = (unsigned char)((ftime >> 11) & 0x1F);


	putchar('0' + (day / 10));
	putchar('0' + (day % 10));


	switch (month)
	{
	case 1:
		putchar('j');
		putchar('a');
		break;
	case 2:
		putchar('f');
		putchar('b');
		break;
	case 3:
		putchar('m');
		putchar('r');
		break;
	case 4:
		putchar('a');
		putchar('p');
		break;
	case 5:
		putchar('m');
		putchar('y');
		break;
	case 6:
		putchar('j');
		putchar('n');
		break;
	case 7:
		putchar('j');
		putchar('l');
		break;
	case 8:
		putchar('a');
		putchar('g');
		break;
	case 9:
		putchar('s');
		putchar('p');
		break;
	case 10:
		putchar('o');
		putchar('c');
		break;
	case 11:
		putchar('n');
		putchar('v');
		break;
	case 12:
		putchar('d');
		putchar('c');
		break;
	default:
		putchar('?');
		putchar('?');
		break;
	}


	putchar('0' + (year_short / 10));
	putchar('0' + (year_short % 10));


	putchar(' ');


	putchar('0' + (hour / 10));
	putchar('0' + (hour % 10));
	putchar(':');
	putchar('0' + (minute / 10));
	putchar('0' + (minute % 10));
}


#define SZ_1MB 1048576UL
#define SZ_100MB 104857600UL

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

void fast_put_char_color(unsigned char x, unsigned char y, unsigned char sym, unsigned char color)
{

	OS_SETXY(x, y);
	OS_SETCOLOR(color);
	putchar(sym);
}

void draw_single_line(PanelState *panel, unsigned int file_idx, unsigned char start_x, unsigned char row_y)
{
	unsigned int real_bank_idx;
	unsigned int page_offset;
	char *display_name;
	unsigned char current_color;
	unsigned char sym_v_single = 179;

	if (file_idx < panel->file_count)
	{
		real_bank_idx = panel_meta_get_index(panel, file_idx);


		switch_file_page(panel, real_bank_idx);
		page_offset = real_bank_idx % FILES_PER_PAGE;

		display_name = panel_entry_name(&set.bank_array[page_offset]);


		OS_SETXY(start_x + 1, 3 + row_y);

		current_color = (file_idx == panel->cursor_idx && panel->is_active) ? COLOR_PANEL_CURSOR : COLOR_PANEL_MAIN;
		OS_SETCOLOR(current_color);


		fast_print_str_pad(display_name, 18);


		if (file_idx == panel->cursor_idx && panel->is_active)
		{
			putchar(sym_v_single);
		}
		else
		{
			OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));
			putchar(sym_v_single);
			OS_SETCOLOR(COLOR_PANEL_MAIN);
		}


		if (set.bank_array[page_offset].fattrib & 0x10)
		{
			fast_print_str_pad(" <DIR>", 6);
		}
		else
		{
			fast_print_size(set.bank_array[page_offset].fsize);
		}


		if (file_idx == panel->cursor_idx && panel->is_active)
		{
			putchar(sym_v_single);
		}
		else
		{
			OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));
			putchar(sym_v_single);
			OS_SETCOLOR(COLOR_PANEL_MAIN);
		}


		fast_print_datetime(set.bank_array[page_offset].fdate, set.bank_array[page_offset].ftime);

		OS_SETCOLOR(COLOR_PANEL_MAIN);
	}
	else
	{

		OS_SETXY(start_x + 1, 3 + row_y);

		OS_SETCOLOR(COLOR_PANEL_MAIN);
		fast_print_str_pad("", 18);
		OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));
		putchar(sym_v_single);
		OS_SETCOLOR(COLOR_PANEL_MAIN);
		fast_print_str_pad("", 6);
		OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));
		putchar(sym_v_single);
		OS_SETCOLOR(COLOR_PANEL_MAIN);
		fast_print_str_pad("", 12);
	}
}

void draw_bottom_info(PanelState *active_p)
{
	unsigned int real_idx;
	unsigned int page_offset;
	char *full_name;
	unsigned long f_size;
	unsigned char is_dir;

	real_idx = panel_meta_get_index(active_p, active_p->cursor_idx);


	switch_file_page(active_p, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;

	full_name = panel_entry_name(&set.bank_array[page_offset]);

	f_size = set.bank_array[page_offset].fsize;
	is_dir = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;

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
	fast_print_str_pad(full_name, 64);
}

void draw_panel_frame(unsigned char start_x, unsigned char color)
{
	unsigned char q;
	unsigned char sym_tl = 201;
	unsigned char sym_tr = 187;
	unsigned char sym_bl = 200;
	unsigned char sym_br = 188;
	unsigned char sym_h = 205;
	unsigned char sym_v = 186;

	unsigned char width = 39;


	fast_put_char_color(start_x, 0, sym_tl, color);
	for (q = 1; q < width; q++)
	{
		fast_put_char_color(start_x + q, 0, sym_h, color);
	}
	fast_put_char_color(start_x + width, 0, sym_tr, color);


	for (q = 1; q <= 21; q++)
	{
		fast_put_char_color(start_x, q, sym_v, color);
		fast_put_char_color(start_x + width, q, sym_v, color);
	}


	fast_put_char_color(start_x, 21, sym_bl, color);
	for (q = 1; q < width; q++)
	{
		fast_put_char_color(start_x + q, 21, sym_h, color);
	}
	fast_put_char_color(start_x + width, 21, sym_br, color);
}

void draw_panel_background(PanelState *panel, unsigned char start_x)
{
	int i;

	draw_panel_frame(start_x, COLOR_PANEL_MAIN);


	OS_SETCOLOR(COLOR_PANEL_MAIN);
	OS_SETXY(start_x + 2, 0);
	putchar('[');
	putchar(' ');
	i = 0;
	while (panel->current_path[i] != 0)
	{
		putchar(panel->current_path[i]);
		i++;
	}
	putchar(' ');
	putchar(']');


	OS_SETXY(start_x + 1, 1);
	OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));


	fast_print_str_pad("Name", 18);
	putchar(179);
	fast_print_str_pad("Size", 6);
	putchar(179);
	fast_print_str_pad(" Date/Time", 12);


	OS_SETXY(start_x + 1, 2);
	OS_SETCOLOR(COLOR_PANEL_MAIN);
	for (i = 0; i < 38; i++)
	{
		putchar(196);
	}
}

void draw_panel(PanelState *panel, unsigned char start_x, unsigned char height)
{
	unsigned char i;
	for (i = 0; i < height; i++)
	{

		draw_single_line(panel, panel->scroll_offset + i, start_x, i);
	}
}

static void redraw_panels_full(void)
{
	PanelState *active_p;

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

static unsigned char panel_drive_saved_letter(const PanelState *panel)
{
	if (panel->current_path[0] >= 'A' && panel->current_path[0] <= 'Z')
		return (unsigned char)panel->current_path[0];
	if (panel->current_path[0] >= 'a' && panel->current_path[0] <= 'z')
		return (unsigned char)(panel->current_path[0] - 'a' + 'A');
	return 'M';
}

static void panel_drive_format_line(char *buf, unsigned char letter, const char *cap)
{
	unsigned char i;

	buf[0] = ' ';
	buf[1] = ' ';
	buf[2] = letter;
	buf[3] = ':';
	buf[4] = ' ';
	buf[5] = '-';
	buf[6] = ' ';
	i = 7;
	while (cap[0] != 0 && i < 25u)
	{
		buf[i] = cap[0];
		cap++;
		i++;
	}
	buf[i] = 0;
}

static void panel_drive_build_list(const PanelState *panel)
{
	unsigned char i;
	unsigned char saved;
	unsigned char neogs;
	unsigned char zxnet;
	char saved_path[64];

	strncpy(saved_path, panel->current_path, sizeof(saved_path) - 1u);
	saved_path[sizeof(saved_path) - 1u] = 0;
	saved = panel_drive_saved_letter(panel);
	neogs = panel_hw_neogs_sd_present();
	zxnet = panel_hw_zxnet_present();
	g_drive_count = 0;

	for (i = 0; i < PANEL_DRIVE_TABLE_LEN; i++)
	{
		const PanelDriveDef *def = &g_drive_table[i];

		if (def->filter == DRVF_NEOGS && neogs == 0u)
			continue;
		if (def->filter == DRVF_ZXNET && zxnet == 0u)
			continue;
		if ((def->filter & DRVF_TRDOS) == 0u && !panel_drive_chdrv_ok(def->letter))
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
	menu_draw_item(DRIVE_ITEM_X, y, DRIVE_ITEM_W, selected, g_drive_labels[idx], 0);
}

static void panel_drive_redraw(void)
{
	unsigned char i;
	unsigned char inner_h;

	inner_h = panel_drive_popup_inner_h();
	ui_draw_frame(DRIVE_POPUP_X, DRIVE_POPUP_Y, DRIVE_POPUP_INNER_W, inner_h, COLOR_MENU_NORM, "Drive");
	for (i = 0; i < g_drive_count; i++)
		panel_drive_draw_row(i, (unsigned char)(i == g_drive_sel));
}

static void panel_drive_open(PanelState *panel)
{
	panel_drive_build_list(panel);
	g_drive_active = 1;
	g_drive_sel = 0;
	panel_drive_redraw();
}

static void panel_drive_close(PanelState *active_p)
{
	g_drive_active = 0;
	g_drive_sel = 0;
	panels_remap_bank_window();
	redraw_panels_full();
	draw_bottom_info(active_p);
}

static void panel_drive_msg(unsigned char letter, const char *text)
{
	struct DialogWindow dlg;
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

	dlg.x = 14;
	dlg.y = 10;
	dlg.w = 52;
	dlg.h = 4;
	dlg.color = COLOR_OVERWRITE_UI;
	dlg.title = "Drive error";
	dlg.prompt = set.temp_path;
	show_dialog(&dlg, NULL, 0, D_BTN_OK);
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
	if (!read_panel_dir_at(panel, path))
	{
		OS_CHDRV(saved_letter);
		read_panel_dir_at(panel, saved_path);
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

static unsigned char panel_drive_handle_key(unsigned char key, PanelState *panel)
{
	if (key == 27)
	{
		panel_drive_close(panel);
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
		panel_drive_close(panel);
		return 1;
	}
	return 1;
}

static void menu_draw_item(unsigned char x0, unsigned char y, unsigned char width, unsigned char selected, const char *label, unsigned char current)
{
	unsigned char x;
	unsigned char fill_color;

	fill_color = selected ? COLOR_MENU_HILITE : COLOR_MENU_NORM;
	for (x = 0; x < width; x++)
		fast_put_char_color((unsigned char)(x0 + x), y, ' ', fill_color);
	OS_SETXY((unsigned char)(x0 + 1), y);
	if (selected)
		OS_SETCOLOR(COLOR_MENU_HILITE);
	else
		OS_SETCOLOR(COLOR_MENU_NORM);
	fast_print_str_pad(label, (unsigned char)(width - 2));
	if (current)
		putchar('*');
}

static void menu_draw_files_row(PanelState *active_p, unsigned char idx, unsigned char cursor_on)
{
	unsigned char y;

	y = (unsigned char)(MENU_POPUP_Y + 1u + idx);
	switch (idx)
	{
	case MFI_NAME:
		menu_draw_item(MENU_ITEM_X, y, MENU_POPUP_INNER_W, cursor_on, "Name",
					   (unsigned char)(active_p->sort_mode == PANEL_SORT_NAME));
		break;
	case MFI_EXT:
		menu_draw_item(MENU_ITEM_X, y, MENU_POPUP_INNER_W, cursor_on, "Extension",
					   (unsigned char)(active_p->sort_mode == PANEL_SORT_EXT));
		break;
	case MFI_SIZE:
		menu_draw_item(MENU_ITEM_X, y, MENU_POPUP_INNER_W, cursor_on, "Size",
					   (unsigned char)(active_p->sort_mode == PANEL_SORT_SIZE));
		break;
	case MFI_TIME:
		menu_draw_item(MENU_ITEM_X, y, MENU_POPUP_INNER_W, cursor_on, "Time",
					   (unsigned char)(active_p->sort_mode == PANEL_SORT_TIME));
		break;
	case MFI_AZ:
		menu_draw_item(MENU_ITEM_X, y, MENU_POPUP_INNER_W, cursor_on, "A-Z", (unsigned char)(active_p->sort_desc == 0));
		break;
	case MFI_ZA:
		menu_draw_item(MENU_ITEM_X, y, MENU_POPUP_INNER_W, cursor_on, "Z-A", (unsigned char)(active_p->sort_desc != 0));
		break;
	case MFI_LFN_SORT:
		menu_draw_item(MENU_ITEM_X, y, MENU_POPUP_INNER_W, cursor_on, "LFN sort", active_p->sort_lfn);
		break;
	}
}

static void menu_files_open(PanelState *active_p)
{
	unsigned char i;

	ui_draw_frame(MENU_POPUP_X, MENU_POPUP_Y, MENU_POPUP_INNER_W, (unsigned char)(MENU_FILES_ITEMS + 1u),
				  COLOR_MENU_NORM, "Files");
	for (i = 0; i < MENU_FILES_ITEMS; i++)
		menu_draw_files_row(active_p, i, (unsigned char)(i == g_menu_sel));
}

static void menu_top_open(void)
{
	ui_draw_frame(MENU_POPUP_X, MENU_POPUP_Y, MENU_POPUP_INNER_W, 2u, COLOR_MENU_NORM, "Menu");
	menu_draw_item(MENU_ITEM_X, (unsigned char)(MENU_POPUP_Y + 1u), MENU_POPUP_INNER_W,
				   (unsigned char)(g_menu_sel == 0), "Files", 0);
}

static void menu_sel_move(PanelState *active_p, unsigned char new_sel)
{
	unsigned char old_sel;

	if (new_sel >= MENU_FILES_ITEMS)
		new_sel = MENU_FILES_ITEMS - 1u;
	old_sel = g_menu_sel;
	if (new_sel == old_sel)
		return;

	g_menu_sel = new_sel;
	if (g_menu_level == MENU_LEVEL_TOP)
	{
		menu_top_open();
		return;
	}

	menu_draw_files_row(active_p, old_sel, 0);
	menu_draw_files_row(active_p, new_sel, 1);
}

static void draw_menu_overlay(void)
{
	PanelState *active_p;

	if (!g_menu_active)
		return;

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	if (g_menu_level == MENU_LEVEL_TOP)
		menu_top_open();
	else
		menu_files_open(active_p);
}

static void menu_open(void)
{
	g_menu_active = 1;
	g_menu_level = MENU_LEVEL_TOP;
	g_menu_sel = 0;
	draw_menu_overlay();
}

static void menu_close_and_redraw(void)
{
	g_menu_active = 0;
	g_menu_level = MENU_LEVEL_TOP;
	g_menu_sel = 0;
	panels_remap_bank_window();
	redraw_panels_full();
}

static void menu_apply_choice(unsigned char choice)
{
	PanelState *active_p;

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	if (choice <= MFI_TIME)
		active_p->sort_mode = choice;
	else if (choice == MFI_AZ)
		active_p->sort_desc = 0;
	else if (choice == MFI_ZA)
		active_p->sort_desc = 1;
	else if (choice == MFI_LFN_SORT)
	{
		active_p->sort_lfn = (unsigned char)(active_p->sort_lfn ? 0u : 1u);
		if (active_p->file_count > 0u)
			panel_refresh_sort_cache(active_p);
	}

	g_menu_active = 0;
	g_menu_level = MENU_LEVEL_TOP;
	g_menu_sel = 0;

	if (active_p->file_count >= 2u)
		panel_resort_keep_cursor(active_p);

	redraw_panels_full();
}

static unsigned char menu_handle_key(unsigned char key)
{
	PanelState *active_p;

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	if (key == 27)
	{
		menu_close_and_redraw();
		return 1;
	}

	if (g_menu_level == MENU_LEVEL_TOP)
	{
		if (key == 13)
		{
			g_menu_level = MENU_LEVEL_FILES;
			g_menu_sel = active_p->sort_mode;
			if (g_menu_sel > MFI_TIME)
				g_menu_sel = MFI_NAME;
			menu_files_open(active_p);
		}
		return 1;
	}

	if (key == 250 || key == 248)
	{
		if (g_menu_sel > 0)
			menu_sel_move(active_p, (unsigned char)(g_menu_sel - 1u));
		return 1;
	}
	if (key == 249 || key == 251)
	{
		if (g_menu_sel < MENU_FILES_ITEMS - 1u)
			menu_sel_move(active_p, (unsigned char)(g_menu_sel + 1u));
		return 1;
	}
	if (key == 13)
	{
		menu_apply_choice(g_menu_sel);
		return 1;
	}

	return 1;
}

void draw_status_bar(void)
{
	OS_SETCOLOR(COLOR_STATUS_BAR);
	OS_SETXY(0, 23);
	fast_print_str_pad(botMenu, 80);
}

void redraw_all(void)
{
	draw_panel(&left_panel, 0, 18);
	draw_panel(&right_panel, 40, 18);
	draw_status_bar();
}

void draw_file_line(PanelState *panel, unsigned char start_x, unsigned int file_idx)
{

	unsigned char row_y = (unsigned char)(file_idx - panel->scroll_offset);


	draw_single_line(panel, file_idx, start_x, row_y);
}

unsigned char getFreeMem(void)
{
	unsigned char freeMem = 0, counter;
	for (counter = 0; counter < set.totalMem; counter++)
	{
		unsigned char owner;
		owner = OS_GETPAGEOWNER(~counter);
		if (owner == 0)
		{
			freeMem++;
		}
	}
	return freeMem - 8;
}

int ext_cmp(const char *s1, const char *s2)
{
	while (*s1 && (tolower((unsigned char)*s1) == tolower((unsigned char)*s2)))
	{
		s1++;
		s2++;
	}
	return tolower((unsigned char)*s1) - tolower((unsigned char)*s2);
}

void handle_enter(PanelState *active_p)
{
	unsigned int real_idx;
	char *ext;
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
			read_panel_dir(active_p);

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
			read_panel_dir_at(active_p, enter_path);
		}


		if (active_p->file_count > 0)
		{
			switch_file_page(active_p, panel_meta_get_index(active_p, active_p->scroll_offset));
		}

		draw_panel_background(active_p, (left_panel.is_active) ? 0 : 40);
		draw_panel(active_p, (left_panel.is_active) ? 0 : 40, 18);
		return;
	}


	strcpy(set.temp_path, panel_entry_name(&set.current_file));
	ext = strrchr(set.temp_path, '.');
	if (ext != NULL)
	{
		ext++;
		if (ext_cmp(ext, "com") == 0 || ext_cmp(ext, "bin") == 0)
		{
		}
		else if (ext_cmp(ext, "txt") == 0 || ext_cmp(ext, "c") == 0)
		{
		}
	}
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


static void panels_reload_both(const char *snap_left, const char *snap_right)
{
	panel_path_normalize(&left_panel, snap_left);
	panel_path_normalize(&right_panel, snap_right);
	if (left_panel.is_active)
	{
		read_panel_dir_at(&left_panel, snap_left);
		read_panel_dir_at(&right_panel, snap_right);
	}
	else
	{
		read_panel_dir_at(&right_panel, snap_right);
		read_panel_dir_at(&left_panel, snap_left);
	}

	if (left_panel.is_active)
		panel_chdir_only(left_panel.current_path);
	else
		panel_chdir_only(right_panel.current_path);
}

static void panels_draw_all(PanelState *active_p)
{
	if (left_panel.file_count > 0u)
		switch_file_page(&left_panel, panel_meta_get_index(&left_panel, left_panel.scroll_offset));
	if (right_panel.file_count > 0u)
		switch_file_page(&right_panel, panel_meta_get_index(&right_panel, right_panel.scroll_offset));

	draw_panel_background(&left_panel, 0);
	draw_panel_background(&right_panel, 40);
	draw_panel(&left_panel, 0, 18);
	draw_panel(&right_panel, 40, 18);
	draw_bottom_info(active_p);
	draw_status_bar();
}


static void panels_refresh_after_copy(PanelState *src_panel, PanelState *dst_panel, const char *hint)
{
	PanelState *active_p;
	unsigned int save_src_c;
	unsigned int save_src_s;
	unsigned int save_dst_c;
	unsigned int save_dst_s;
	unsigned int idx;
	char snap_left[64];
	char snap_right[64];

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;
	if (src_panel == NULL)
		src_panel = active_p;
	if (dst_panel == NULL)
		dst_panel = (src_panel == &left_panel) ? &right_panel : &left_panel;

	save_src_c = src_panel->cursor_idx;
	save_src_s = src_panel->scroll_offset;
	save_dst_c = dst_panel->cursor_idx;
	save_dst_s = dst_panel->scroll_offset;

	strncpy(snap_left, left_panel.current_path, sizeof(snap_left) - 1u);
	snap_left[sizeof(snap_left) - 1u] = 0;
	strncpy(snap_right, right_panel.current_path, sizeof(snap_right) - 1u);
	snap_right[sizeof(snap_right) - 1u] = 0;

	panels_reload_both(snap_left, snap_right);

	if (hint != NULL && hint[0] != 0)
	{
		if (!panel_find_by_name(src_panel, hint, &idx))
			src_panel->cursor_idx = save_src_c;
		else
			src_panel->cursor_idx = idx;
		dst_panel->cursor_idx = save_dst_c;
	}
	else
	{
		src_panel->cursor_idx = save_src_c;
		dst_panel->cursor_idx = save_dst_c;
	}

	src_panel->scroll_offset = save_src_s;
	dst_panel->scroll_offset = save_dst_s;
	panel_clamp_scroll(src_panel);
	panel_clamp_scroll(dst_panel);

	copy_prog.drawn = 0;
	panels_draw_all(active_p);
}


void panels_refresh_all(const char *next_file_hint)
{
	PanelState *active_p;
	unsigned int idx;
	char snap_left[64];
	char snap_right[64];

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	strncpy(snap_left, left_panel.current_path, sizeof(snap_left) - 1u);
	snap_left[sizeof(snap_left) - 1u] = 0;
	strncpy(snap_right, right_panel.current_path, sizeof(snap_right) - 1u);
	snap_right[sizeof(snap_right) - 1u] = 0;

	panels_reload_both(snap_left, snap_right);

	if (next_file_hint != NULL && panel_find_by_name(active_p, next_file_hint, &idx))
		active_p->cursor_idx = idx;
	panel_clamp_scroll(active_p);
	panels_draw_all(active_p);
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
		printf("[%s]", title);
	}
}

static void copy_progress_layout(void)
{
	copy_prog.w = 58;
	copy_prog.h = 6;
	copy_prog.x = (unsigned char)((screenWidth - copy_prog.w - 2) / 2);
	copy_prog.y = 10;
	copy_prog.bar_w = (unsigned char)(copy_prog.w - 10);
	copy_prog.bar_x = (unsigned char)(copy_prog.x + 5);
	copy_prog.bar_y = (unsigned char)(copy_prog.y + 2);
	copy_prog.name_y = (unsigned char)(copy_prog.y + 4);
}

static void copy_progress_fill_bg(void)
{
	unsigned char row;
	unsigned char col;

	OS_SETCOLOR(COLOR_COPY_UI);
	for (row = 1; row < copy_prog.h; row++)
	{
		OS_SETXY((unsigned char)(copy_prog.x + 1), (unsigned char)(copy_prog.y + row));
		for (col = 0; col < copy_prog.w; col++)
			putchar(' ');
	}
}

static void copy_progress_draw_bar(unsigned char pct);
static void copy_progress_draw_name(const char *name);

static void copy_progress_open(void)
{
	copy_progress_layout();
	copy_prog.last_pct = 255;
	copy_prog.drawn = 0;
	ui_draw_frame(copy_prog.x, copy_prog.y, copy_prog.w, copy_prog.h, COLOR_COPY_UI, "Copying");
	copy_progress_fill_bg();
	copy_prog.drawn = 1;
	copy_progress_draw_bar(0);
	copy_progress_draw_name("");
}

static void copy_progress_draw_bar(unsigned char pct)
{
	unsigned char i;
	unsigned char filled;

	if (pct > 100)
		pct = 100;
	if (copy_prog.drawn && pct == copy_prog.last_pct)
		return;
	copy_prog.last_pct = pct;

	if (!copy_prog.drawn)
		copy_progress_open();

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
	unsigned char inner_w;
	unsigned char nlen;
	unsigned char pad_left;
	unsigned char i;
	const char *show_name;

	if (!copy_prog.drawn)
		copy_progress_open();

	inner_w = copy_prog.w;
	show_name = name;
	if (show_name == NULL)
		show_name = "";

	nlen = (unsigned char)strlen(show_name);
	if (nlen > inner_w)
	{
		show_name = show_name + nlen - inner_w;
		nlen = inner_w;
	}

	pad_left = (unsigned char)((inner_w - nlen) / 2);

	OS_SETXY((unsigned char)(copy_prog.x + 1), copy_prog.name_y);
	OS_SETCOLOR(COLOR_COPY_UI);
	for (i = 0; i < pad_left; i++)
		putchar(' ');
	for (i = 0; i < nlen; i++)
		putchar(show_name[i]);
	for (i = (unsigned char)(pad_left + nlen); i < inner_w; i++)
		putchar(' ');
}

static void copy_progress_file_begin(const char *name, unsigned char is_dir)
{
	const char *show;

	show = name;
	if (show == NULL)
		show = "";
	strncpy(copy_prog_current_name, show, sizeof(copy_prog_current_name) - 1u);
	copy_prog_current_name[sizeof(copy_prog_current_name) - 1u] = 0;

	copy_prog.last_pct = 255;
	copy_progress_draw_name(copy_prog_current_name);
	if (is_dir)
		copy_progress_draw_bar(100);
	else
		copy_progress_draw_bar(0);
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

void build_full_path(char *dest, const char *path, const char *filename)
{
	unsigned int len;
	strcpy(dest, path);
	len = strlen(dest);


	if (len > 0 && dest[len - 1] != '/' && dest[len - 1] != '\\')
	{
		strcat(dest, "/");
	}
	strcat(dest, filename);
}

static unsigned char copy_dest_exists(const char *path)
{
	FILE *h;

	h = OS_OPENHANDLE((unsigned char *)path, 0x80);
	if (((int)h) & 0xff)
		return 0;
	OS_CLOSEHANDLE(h);
	return 1;
}


static void copy_progress_restore_after_dialog(void)
{
	unsigned char pct;

	if (!copy_prog.drawn)
		return;

	pct = copy_prog.last_pct;
	if (pct > 100u)
		pct = 0u;

	ui_draw_frame(copy_prog.x, copy_prog.y, copy_prog.w, copy_prog.h, COLOR_COPY_UI, "Copying");
	copy_progress_fill_bg();
	copy_prog.last_pct = 255u;
	copy_progress_draw_name(copy_prog_current_name);
	copy_progress_draw_bar(pct);
}


static unsigned char copy_overwrite_dialog(void)
{
	struct DialogWindow dlg;
	unsigned char res;

	dlg.w = 52;
	dlg.h = 6;
	dlg.x = (unsigned char)((screenWidth - dlg.w - 2) / 2);
	dlg.y = 11;
	dlg.color = COLOR_OVERWRITE_UI;
	dlg.title = "Copy";
	dlg.prompt = "File exists. Replace?";

	res = show_dialog(&dlg, NULL, 0, D_MASK_OVERWRITE);
	copy_progress_restore_after_dialog();

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

static unsigned char copy_check_overwrite(const char *dst_path)
{
	unsigned char r;

	if (!copy_dest_exists(dst_path))
		return COPY_FILE_OK;

	if (g_copy_overwrite_mode == COPY_OW_SKIP_ALL)
		return COPY_FILE_SKIP;
	if (g_copy_overwrite_mode == COPY_OW_REPLACE_ALL)
		return COPY_FILE_OK;
	if (g_copy_overwrite_mode == COPY_OW_ABORT)
		return COPY_FILE_ABORT;

	r = copy_overwrite_dialog();
	if (r == COPY_FILE_OK)
		return COPY_FILE_OK;
	return r;
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

	fdate = src_fdate;
	ftime = src_ftime;

	ow = copy_check_overwrite(dst_path);
	if (ow == COPY_FILE_SKIP)
		return COPY_FILE_SKIP;
	if (ow == COPY_FILE_ABORT)
		return COPY_FILE_ABORT;

	h_src = OS_OPENHANDLE((unsigned char *)src_path, 0x80);
	if (((int)h_src) & 0xff)
		return COPY_FILE_ERR;


	if (fdate == 0 && ftime == 0)
		OS_GETFILETIME((unsigned char *)src_path, &fdate, &ftime);

	file_size = OS_GETFILESIZE(h_src);
	remaining = file_size;
	ui_tick = 0;

	h_dst = OS_CREATEHANDLE((unsigned char *)dst_path, 0x80);
	if (((int)h_dst) & 0xff)
	{
		OS_CLOSEHANDLE(h_src);
		return COPY_FILE_ERR;
	}

	OS_SETPG8000(g_copy_io_page);

	while (remaining > 0)
	{
		chunk = (remaining > COPY_IO_CHUNK) ? COPY_IO_CHUNK : (unsigned int)remaining;
		bytes_read = OS_READHANDLE(COPY_IO_ADDR, h_src, chunk);
		if (bytes_read == 0 || (((int)bytes_read) & 0xff))
			break;

		bytes_written = OS_WRITEHANDLE(COPY_IO_ADDR, h_dst, bytes_read);
		if (bytes_written != bytes_read || (((int)bytes_written) & 0xff))
			break;

		if (bytes_read >= remaining)
			remaining = 0;
		else
			remaining -= bytes_read;


		ui_tick++;
		if ((ui_tick & 3u) == 0u || remaining == 0)
			copy_progress_file_bytes(file_size - remaining, file_size);
	}

	copy_progress_file_bytes(file_size, file_size);
	OS_SEEKHANDLE(h_dst, file_size);
	OS_CLOSEHANDLE(h_dst);
	OS_CLOSEHANDLE(h_src);

	OS_SETFILETIME((unsigned char *)dst_path, fdate, ftime);
	return COPY_FILE_OK;
}


void copy_tree_recursive(const char *base_src, const char *base_dst)
{
	unsigned int i;
	unsigned int n;
	unsigned char is_dir;
	unsigned char copy_res;
	const char *name_ptr;

	if (!g_copy_page_active)
		return;
	if (g_copy_overwrite_mode == COPY_OW_ABORT)
		return;

	if (!copy_collect_dir(base_src))
		return;

	copy_take_dir_snapshot();

	copy_snap_map();
	n = *copy_cache_count_ptr();

	for (i = 0; i < n; i++)
	{
		copy_snap_map();
		name_ptr = copy_cache_name_ptr(i);
		if (name_ptr[0] == 0)
			continue;

		is_dir = copy_cache_flags_ptr()[i];
		build_full_path(r_src_full, base_src, name_ptr);
		build_full_path(r_dst_full, base_dst, name_ptr);

		if (is_dir)
		{
			copy_progress_file_begin(name_ptr, 1);
			OS_MKDIR((unsigned char *)r_dst_full);
			copy_tree_recursive(r_src_full, r_dst_full);
		}
		else
		{
			copy_progress_file_begin(name_ptr, 0);
			copy_res = copy_single_file_core(r_src_full, r_dst_full, copy_snap_date[i],
											 copy_snap_time[i]);
			if (copy_res == COPY_FILE_ABORT)
				break;
		}
		panels_remap_bank_window();
		YIELD();
	}

	OS_CHDIR((unsigned char *)"..");
}


void Action_Copy(void)
{

	struct DialogWindow dlg;
	PanelState *src_panel;
	PanelState *dst_panel;
	unsigned int real_idx;
	unsigned int page_offset;
	unsigned char dialog_result;
	unsigned int len;
	unsigned char is_directory;
	unsigned char copy_res;


	static char saved_filename[64];
	static char full_src_path[200];
	static char full_dst_path[200];
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


	real_idx = panel_meta_get_index(src_panel, src_panel->cursor_idx);
	switch_file_page(src_panel, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;

	is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;

	if (is_directory && panel_entry_is_dotdot(&set.bank_array[page_offset]))
		return;

	copy_name_preserve_case(&set.bank_array[page_offset], saved_filename);


	dlg.w = 62;
	dlg.h = 6;
	dlg.x = (unsigned char)((screenWidth - dlg.w - 2) / 2);
	dlg.y = 8;
	dlg.color = COLOR_COPY_UI;
	dlg.title = is_directory ? "Copy directory" : "Copy file";
	dlg.prompt = "Copy to:";

	strncpy(set.temp_path, dst_panel->current_path, sizeof(set.temp_path) - 1);
	set.temp_path[sizeof(set.temp_path) - 1] = '\0';

	len = strlen(set.temp_path);
	if (len > 0 && set.temp_path[len - 1] != '/' && set.temp_path[len - 1] != '\\')
	{
		strcat(set.temp_path, "/");
	}

	g_copy_overwrite_mode = COPY_OW_ASK_EACH;

	dialog_result = show_dialog(&dlg, set.temp_path, sizeof(set.temp_path), D_MASK_OK_CANCEL);
	if (dialog_result == D_RES_CANCEL)
	{
		panel_path_normalize(&left_panel, snap_left);
		panel_path_normalize(&right_panel, snap_right);
		OS_CHDIR((unsigned char *)src_panel->current_path);
		panels_refresh_after_copy(src_panel, dst_panel, saved_filename);
		return;
	}


	build_full_path(full_src_path, src_panel->current_path, saved_filename);
	build_full_path(full_dst_path, set.temp_path, saved_filename);


	copy_progress_open();

	if (is_directory)
	{
		if (!copy_workspace_begin())
		{
			copy_progress_draw_name("No memory page");
			panel_path_normalize(&left_panel, snap_left);
			panel_path_normalize(&right_panel, snap_right);
			OS_CHDIR((unsigned char *)src_panel->current_path);
			panels_refresh_after_copy(src_panel, dst_panel, saved_filename);
			return;
		}

		OS_MKDIR((unsigned char *)full_dst_path);
		copy_progress_file_begin(saved_filename, 1);
		copy_tree_recursive(full_src_path, full_dst_path);
		copy_workspace_end();
	}
	else
	{
		if (!copy_io_ensure())
		{
			copy_progress_draw_name("No memory page");
			panel_path_normalize(&left_panel, snap_left);
			panel_path_normalize(&right_panel, snap_right);
			OS_CHDIR((unsigned char *)src_panel->current_path);
			panels_refresh_after_copy(src_panel, dst_panel, saved_filename);
			return;
		}
		copy_progress_file_begin(saved_filename, 0);
		copy_res = copy_single_file_core(full_src_path, full_dst_path, set.bank_array[page_offset].fdate,
										 set.bank_array[page_offset].ftime);
		copy_io_release();
		(void)copy_res;
	}


	panel_path_normalize(&left_panel, snap_left);
	panel_path_normalize(&right_panel, snap_right);
	panel_path_normalize(dst_panel, set.temp_path);
	OS_CHDIR((unsigned char *)src_panel->current_path);
	panels_refresh_after_copy(src_panel, dst_panel, saved_filename);
}

void init(void)
{
	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_3;
	OS_DELPAGE(pgbak);
	set.totalMem = 255;
	set.freeMem = getFreeMem();
}

C_task main(int argc, const char *argv[])
{
	OS_HIDEFROMPARENT();
	OS_SETGFX(0x86);
	OS_CLS(0);
	OS_SETSYSDRV();
	printf("[Build:%s %s]\r\n", __DATE__, __TIME__);
	os_initstdio();


	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;

	init_panels();

	panels_reload_both(left_panel.current_path, right_panel.current_path);
	OS_CLS(0);


	panels_draw_all(&left_panel);

	while (1)
	{
		unsigned char key;
		PanelState *active_p;
		active_p = (left_panel.is_active) ? &left_panel : &right_panel;

		key = OS_GETKEY();

		if (g_menu_active)
		{
			if (key == 0)
			{
				YIELD();
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
				continue;
			}
			panel_drive_handle_key(key, active_p);
			continue;
		}

		switch (key)
		{
		case 0:
			YIELD();
			continue;
		case 27:
		case 176:
			exit(0);
			continue;
		case '1':
			panel_drive_open(active_p);
			continue;
		case '9':
			menu_open();
			continue;
		case '8':
			Action_Delete();
			panels_refresh_all(NULL);
			break;
		case '5':
			Action_Copy();
			break;
		}


		if (key == 9)
		{
			left_panel.is_active = !left_panel.is_active;
			right_panel.is_active = !right_panel.is_active;
			redraw_all();

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
				if (active_p->scroll_offset != old_scroll)
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
				if (active_p->scroll_offset != old_scroll)
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
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				if (active_p->cursor_idx >= 18)
				{
					active_p->cursor_idx -= 18;
				}
				else
				{
					active_p->cursor_idx = 0;
				}
				if (active_p->cursor_idx < active_p->scroll_offset)
				{
					active_p->scroll_offset = active_p->cursor_idx;
				}
				OS_CHDIR((unsigned char *)active_p->current_path);
				if (active_p->scroll_offset != old_scroll)
				{
					draw_panel(active_p, start_x, 18);
				}
				else
				{
					switch_file_page(active_p, panel_meta_get_index(active_p, active_p->cursor_idx));
					redraw_all();
				}

				draw_bottom_info(active_p);
			}
			continue;
		}


		if (key == 251)
		{
			if (active_p->cursor_idx + 1 < active_p->file_count)
			{
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				active_p->cursor_idx += 18;
				if (active_p->cursor_idx >= active_p->file_count)
				{
					active_p->cursor_idx = active_p->file_count - 1;
				}
				if (active_p->cursor_idx >= active_p->scroll_offset + 18)
				{
					active_p->scroll_offset = active_p->cursor_idx - 18 + 1;
				}
				OS_CHDIR((unsigned char *)active_p->current_path);
				draw_panel(active_p, start_x, 18);


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
