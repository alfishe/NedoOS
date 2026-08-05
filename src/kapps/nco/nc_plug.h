#ifndef NC_PLUG_H
#define NC_PLUG_H

#include <osfs.h>
#include <oscalls.h>
#include "nc_panel.h"

#define NC_PAGES_PER_PANEL 4u
#define NC_PANEL_SORT_NAME 0u
#define NC_PANEL_SORT_EXT 1u
#define NC_PANEL_SORT_SIZE 2u
#define NC_PANEL_SORT_TIME 3u
#define NC_MENU_LEVEL_TOP 0u
#define NC_MENU_LEVEL_FILES 1u
#define NC_MENU_FILES_ITEMS 10u
#define NC_MFI_NAME 0u
#define NC_MFI_EXT 1u
#define NC_MFI_SIZE 2u
#define NC_MFI_TIME 3u
#define NC_MFI_AZ 4u
#define NC_MFI_ZA 5u
#define NC_MFI_LFN_SORT 6u
#define NC_MFI_READ_ON_FOCUS 7u
#define NC_MFI_BRIEF 8u
#define NC_MFI_CMD_FLAG 9u

#define NC_CMD_FLAG_NONE 0u
#define NC_CMD_FLAG_K    1u
#define NC_CMD_FLAG_P    2u
#define NC_PANEL_ROW_WIDTH 38u
#define NC_PANEL_BRIEF_SIZE_W 8u
/* Name 28 + sep + size 8 + 1 pad = 38 */
#define NC_PANEL_BRIEF_NAME_W 28u
#define NC_PANEL_BRIEF_SIZE_OFF 29u
#define NC_MENU_POPUP_Y 1u
#define NC_MENU_POPUP_INNER_W 20u
#define NC_SCREEN_WIDTH 80u
#define NC_STATUS_ROW 22u
#define NC_HINT_ROW 23u
#define NC_HINT_WIDTH (NC_SCREEN_WIDTH - 1u) /* col 79 stays black, like nv thint */
#define NC_CLOCK_LEN 5u /* "HH:MM" like nv */
#define NC_CLOCK_X (NC_SCREEN_WIDTH - 1u - NC_CLOCK_LEN)
#define NC_CLOCK_Y 0u

#define NC_CMDLINE_LEN 80u
#define NC_BOTTOM_CMD 0u
#define NC_BOTTOM_EMPTY 1u
#define NC_BOTTOM_FILE 2u

#define NC_INI_APP_LEN 128u
#define NC_INI_DIR "../ini"
#define NC_INI_NAME "nc.ini"
#define NC_EXT_NAME NC_INI_DIR "/nc.ext"
#define NC_INI_BUF_SIZE 1024u

#define D_BTN_OK 0x01
#define D_BTN_CANCEL 0x02
#define D_BTN_YES 0x04
#define D_BTN_NO 0x08
#define D_BTN_SKIP 0x10
#define D_BTN_SKIP_ALL 0x20
#define D_BTN_REPLACE_ALL 0x40
#define D_BTN_TO_MOVE 0x80

#define D_MASK_OK_CANCEL (D_BTN_OK | D_BTN_CANCEL)
#define D_MASK_RENAME (D_BTN_CANCEL | D_BTN_TO_MOVE | D_BTN_OK)
#define D_MASK_OVERWRITE \
	(D_BTN_YES | D_BTN_NO | D_BTN_SKIP | D_BTN_SKIP_ALL | D_BTN_REPLACE_ALL | D_BTN_CANCEL)
#define D_MASK_DELETE (D_BTN_YES | D_BTN_NO)

#define D_RES_CANCEL 0
#define D_RES_OK 1
#define D_RES_YES 2
#define D_RES_NO 3
#define D_RES_SKIP 4
#define D_RES_SKIP_ALL 5
#define D_RES_REPLACE_ALL 6
#define D_RES_TO_MOVE 7

#define NC_COPY_OW_SKIP_ALL 0u
#define NC_COPY_OW_ASK_EACH 1u
#define NC_COPY_OW_REPLACE_ALL 2u
#define NC_COPY_OW_ABORT 3u

#define NC_COPY_FILE_OK 0u
#define NC_COPY_FILE_ERR 1u
#define NC_COPY_FILE_SKIP 2u
#define NC_COPY_FILE_ABORT 3u

#define UI_DLG_INPUT_W 62u
#define UI_DLG_CONFIRM_W 52u
#define UI_DLG_INPUT_H 6u
#define UI_DLG_CONFIRM_H 6u
#define UI_DLG_ALERT_H 4u
#define UI_DLG_INPUT_Y 8u
#define UI_DLG_CONFIRM_Y 11u
#define UI_DLG_PROGRESS_W 58u
#define UI_DLG_PROGRESS_H 4u
#define UI_DLG_PROGRESS_Y 11u
#define UI_DLG_COPY_PROGRESS_Y 10u
#define UI_DLG_ALERT_X 14u
#define UI_DLG_ALERT_Y 10u

typedef struct
{
	unsigned char bank_ids[NC_PAGES_PER_PANEL];
	unsigned char bank_id;
	unsigned int file_count;
	unsigned int files_only_count;
	unsigned long total_bytes;
	unsigned int cursor_idx;
	unsigned int scroll_offset;
	unsigned char is_active;
	unsigned char sort_mode;
	unsigned char sort_desc;
	unsigned char sort_lfn;
	unsigned int marked_count;
	unsigned long marked_bytes;
	char current_path[64];
} PanelState;

typedef struct
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char color;
	const char *title;
	const char *prompt;
} DialogWindow;

typedef struct
{
	unsigned char mode;
	unsigned char cmd_cursor;
	char cmd_line[NC_CMDLINE_LEN];
	char name[65];
	unsigned long f_size;
	unsigned char is_dir;
} NCBottomInfo;

typedef struct
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
} NCCopyProg;

extern unsigned char botMenu[];
extern NCCopyProg copy_prog;
extern char copy_prog_current_name[64];
extern unsigned char g_delete_progress;
extern char g_fileop_title[16];

extern PanelState left_panel;
extern PanelState right_panel;
extern unsigned char g_panel_page_used[256];
extern NCBottomInfo g_bottom_snap;
extern char g_panel_enter_path[200];

extern unsigned char g_menu_active;
extern unsigned char g_menu_level;
extern unsigned char g_menu_sel;
extern PanelState *g_menu_panel;
extern unsigned char g_drive_active;
extern PanelState *g_drive_panel;
extern unsigned char g_drive_sel;
extern unsigned char g_drive_count;

extern char g_ini_hide_drives[64];
extern char g_ini_viewer[NC_INI_APP_LEN];
extern char g_ini_editor[NC_INI_APP_LEN];
extern unsigned char g_ini_has_left_path;
extern unsigned char g_ini_has_right_path;
extern unsigned char g_ini_read_on_focus;
extern unsigned char g_ini_panel_brief;
extern unsigned char g_ini_cmd_flag;

extern unsigned char g_copy_overwrite_mode;
extern char g_copy_ow_msg[80];
extern unsigned char g_move_active;
extern unsigned char g_copy_temp_page;
extern unsigned char g_copy_snap_page;
extern unsigned char g_copy_io_page;
extern unsigned char g_copy_stack_page;
extern unsigned char g_copy_page_active;
extern unsigned char g_delete_stack_page;
extern unsigned char g_delete_page_active;
extern unsigned char g_fileop_abort;
extern unsigned char g_focus_pending;
extern unsigned char g_copy_tree_failed;
extern unsigned char g_copy_sp;
extern unsigned char g_deldir_sp;
extern char r_src_full[200];
extern char r_dst_full[200];
extern fileInfo r_global_info;
extern char r_action_name[64];
extern char r_action_path[200];
extern char r_action_left[64];
extern char r_action_right[64];
extern char g_snap_left[64];
extern char g_snap_right[64];

extern char g_nc_startup_path[64];

extern unsigned char residentPg;
extern union APP_PAGES main_pg;

struct setup
{
	fileInfo current_file;
	char local_dir_name[64];
	char exited_dir_name[64];
	char temp_path[64];
	fileInfo *bank_array;
};
extern struct setup nc_set;

/* Panel-bank mutable workspaces live in root BSS, never an overlay. */
extern char g_panel_row[PANEL_ROW_WIDTH];
extern char g_panel_rows[PANEL_VIEW_ROWS][PANEL_ROW_WIDTH];
extern unsigned char g_panel_row_colors[PANEL_VIEW_ROWS];
extern unsigned char g_panel_row_marked_row[PANEL_VIEW_ROWS];
extern unsigned int g_panel_row_phys[PANEL_VIEW_ROWS];
extern fileInfo g_panel_fi;
extern fileInfo g_panel_stage[PANEL_READ_STAGE];
extern unsigned char g_panel_stage_n;
extern unsigned int g_panel_scan_vis[FILES_PER_PAGE];
extern unsigned int g_panel_scan_phys[FILES_PER_PAGE];
extern const char g_month_abbr[12][2];
extern unsigned char *s_kind;
extern unsigned char *s_name4;
extern unsigned char *s_ext4;
extern unsigned char *s_cpm4;
extern unsigned char *s_lfn4;
extern unsigned char *s_lfnext4;
extern char g_lfn_tie_a[64];
extern char g_lfn_tie_b[64];
extern unsigned long *s_sizes;
extern unsigned short *s_dates;
extern unsigned short *s_times;
extern unsigned short *s_idx;
extern unsigned char s_mode;
extern unsigned char s_desc;
extern PanelState *s_lfn_panel;

/* Root-resident UI strings (overlays must not pass their own literals to mb_*). */
extern const char g_ui_copy[];
extern const char g_ui_copy_to[];
extern const char g_ui_copy_bad_dest[];
extern const char g_ui_copy_nomem[];
extern const char g_ui_copy_write_fail[];
extern const char g_ui_cancelled[];
extern const char g_ui_file_pfx[];
extern const char g_ui_folder_pfx[];
extern const char g_ui_exist_sfx[];
extern const char g_ui_delete[];
extern const char g_ui_delete_file[];
extern const char g_ui_delete_folder[];
extern const char g_ui_delete_marked[];
extern const char g_ui_rename[];
extern const char g_ui_rename_to[];
extern const char g_ui_invalid_name[];
extern const char g_ui_rename_fail[];
extern const char g_ui_rename_fail_msg[];
extern const char g_ui_mkdir[];
extern const char g_ui_mkdir_name[];
extern const char g_ui_mkdir_short[];
extern const char g_ui_mkdir_fail[];
extern const char g_ui_move[];
extern const char g_ui_move_to[];
extern const char g_ui_move_bad_dest[];
extern const char g_ui_move_fail[];
extern const char g_ui_moving[];

extern char g_run_saved_cwd[64];
extern char g_run_cmdline[128];
extern char g_run_inner[96];
extern char g_run_name[64];
extern const char g_ui_term_cmd[];
extern const char g_ui_term_cmd_k[];
extern const char g_ui_term_cmd_p[];
extern const char g_ui_term_com[];
extern const char g_ui_nv_ext[];

extern unsigned int g_nvext_size;
extern unsigned int g_ncext_off;
extern unsigned int g_ncext_size;
extern char g_run_handler[NC_EXT_HANDLER_MAX];
extern unsigned char g_nvext_io[128];
extern unsigned char g_cmd_active;
extern unsigned char g_cmd_len;
extern unsigned char g_cmd_cursor;
extern char g_cmd_line[NC_CMDLINE_LEN];

void init(void);
void init_panels(void);
void nc_ini_load(void);
void nc_ini_save(void);
void nc_capture_startup_path(void);
unsigned char panel_request_unique_page(unsigned char *page_out);

void menu_draw_item(unsigned char x0, unsigned char y, unsigned char width, unsigned char selected,
					const char *label, unsigned char current);
void menu_open(void);
void draw_menu_overlay(void);
unsigned char menu_handle_key(unsigned char key);

unsigned char panel_drive_saved_letter(const PanelState *panel);
void panel_drive_format_line(char *buf, unsigned char letter, const char *cap);

void menu_close_and_redraw(void);
void menu_apply_choice(unsigned char choice);

void ui_fill_chars(unsigned char x, unsigned char y, unsigned char sym, unsigned char count, unsigned char color);

void panel_draw_footer(PanelState *panel, unsigned char start_x);
/* Size formatters live in main (0100): callable while panel file page is mapped. */
void panel_fmt_size(char *dst, unsigned long size, unsigned char is_dir);
void panel_fmt_size_brief(char *dst, unsigned long size, unsigned char is_dir);

void draw_panel_frame(unsigned char start_x, unsigned char color);
void draw_panel_background(PanelState *panel, unsigned char start_x);
void draw_panel_footer(PanelState *panel, unsigned char start_x);
void draw_bottom_info(PanelState *active_p);

/* CODE_RESIDENT: caller maps residentPg (or use ui_* wrappers in main). */
void r_ui_begin_full_redraw(void);
void r_ui_draw_status_bar(void);
void r_ui_clock_redraw(void);
void r_ui_nc_clock_draw(unsigned char force);
void r_draw_panel_background(PanelState *panel, unsigned char start_x);
void r_draw_bottom_info(const NCBottomInfo *snap);
void r_panel_sort_notice_show(PanelState *panel);
void r_fileop_progress_begin(unsigned char is_delete);
void r_fileop_progress_begin_title(unsigned char is_delete, const char *title);
void r_fileop_progress_restore(void);
void r_fileop_progress_store_name(const char *name);
void r_copy_progress_draw_bar(unsigned char pct);
void r_copy_progress_draw_name(const char *name);
void r_panel_drive_open(PanelState *panel);
void r_panel_drive_redraw(void);
unsigned char r_panel_drive_handle_key(unsigned char key);

/* Main bank callbacks (0100-BFFF CODE) for resident drive popup. */
unsigned char m_panel_chdir_only(const char *path);
unsigned char m_read_panel_dir_at(PanelState *panel, const char *dir_path, unsigned char preserve_cursor);
void m_panels_remap_bank_window(void);
void m_redraw_panels_full(void);
void m_panels_redraw_both(void);
void m_draw_panel(PanelState *panel, unsigned char start_x, unsigned char height);
void m_panel_sort_notice_show(PanelState *panel);
void m_run_restore_ui(PanelState *panel);
void m_run_save_cwd(void);
void m_run_restore_cwd(void);
void m_run_restore_session_bank(void);
unsigned char m_run_resident_page(void);
PanelState *m_run_active_panel(void);
void m_run_build_cmdline(unsigned char with_cmd_flags, const char *handler, const char *arg);
void m_run_action_view(PanelState *panel);
void m_run_action_edit(PanelState *panel);
void m_run_action_selected(PanelState *panel);
void m_cmd_clear(void);
void m_cmd_begin(unsigned char ch);
unsigned char m_cmd_handle_key(unsigned char key, PanelState *panel);
void m_cmd_fill_bottom_snap(void);
void m_cmd_execute(PanelState *panel);

/* Bank 02 panel service entry points. */
unsigned char r_read_panel_dir_at(PanelState *panel, const char *path, unsigned char preserve_cursor);
void r_draw_panel(PanelState *panel, unsigned char start_x, unsigned char height);
void r_panels_remap_bank_window(void);
void r_panels_reload_both(const char *left, const char *right);
void r_panels_paint_both(void);
void r_panels_draw_all(void);
void r_switch_file_page(PanelState *panel, unsigned int file_idx);
void r_fill_bottom_snap(NCBottomInfo *snap);
unsigned char r_panel_nav_key(unsigned char key);
void r_panel_menu_apply(unsigned char choice);

/* Bank 03 file operation service entry points. */
void r_action_copy(void);
void r_action_delete(void);
void r_action_rename(void);
void r_action_mkdir(void);
void r_action_move(void);

void r_action_view(void);
void r_action_edit(void);
void r_run_selected_file(void);

/* Resident (C000): caller must map residentPg before r_* ? use ui_* wrappers from main. */
unsigned char r_ui_dialog_input(const char *title, const char *prompt);
unsigned char r_ui_dialog_rename_input(const char *title, const char *prompt);
unsigned char r_ui_dialog_delete_confirm(const char *title, const char *prompt);
void r_ui_alert_dialog(const char *title, const char *prompt);
void r_ui_error_dialog(const char *title, const char *msg);
unsigned char r_copy_dest_exists(const char *path);
unsigned char r_copy_dir_exists(const char *path);
unsigned char r_copy_overwrite_resolve(unsigned char exists, const char *dialog_msg);

unsigned char ui_dialog_input(const char *title, const char *prompt);
unsigned char ui_dialog_rename_input(const char *title, const char *prompt);
unsigned char ui_dialog_delete_confirm(const char *title, const char *prompt);
void ui_alert_dialog(const char *title, const char *prompt);
void ui_error_dialog(const char *title, const char *msg);

void fileop_progress_restore(void);

#endif
