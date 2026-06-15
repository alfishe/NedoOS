#ifndef NC_PLUG_H
#define NC_PLUG_H

#include <osfs.h>
#include <oscalls.h>

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
extern struct setup set;

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
void panel_fmt_size(char *dst, unsigned long size, unsigned char is_dir);
void panel_fmt_size_brief(char *dst, unsigned long size, unsigned char is_dir);

void draw_panel_frame(unsigned char start_x, unsigned char color);
void draw_panel_background(PanelState *panel, unsigned char start_x);
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
