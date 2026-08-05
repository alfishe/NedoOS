#include "mb_inc.h"
#include "mb_plug.h"
#include "nc_plug.h"
#include "bank_jt.h"

/*
 * Plan JT wrappers: map bank @8000, CALL slot, restore previous @8000.
 *
 * Override the trio together (before #ifndef below), e.g.:
 *
 *   Always return to session bank01 (future UI):
 *     #define MB_BANK_SAVE()
 *     #define MB_BANK_ENTER(idx) OS_SETPG8000(g_bankPg[(idx)])
 *     #define MB_BANK_LEAVE()    OS_SETPG8000(g_bankPg[0])
 *
 * Empty SAVE = "#define MB_BANK_SAVE()" ? true no-op (no tokens).
 * Do not put ';' after MB_BANK_SAVE() in wrappers (C89 declaration rules).
 */

#ifndef MB_BANK_SAVE
#define MB_BANK_SAVE() \
	unsigned char _mb_saved8000 = mb_code_current();
#define MB_BANK_ENTER(idx) OS_SETPG8000(g_bankPg[(idx)])
#define MB_BANK_LEAVE()    OS_SETPG8000(_mb_saved8000)
#endif

typedef void (*mb_void_fn)(void);
typedef void (*mb_u8_fn)(unsigned char);
typedef void (*mb_panel_fn)(PanelState *);
typedef void (*mb_panel_x_fn)(PanelState *, unsigned char);
typedef void (*mb_snap_fn)(const NCBottomInfo *);
typedef void (*mb_title_fn)(unsigned char, const char *);
typedef void (*mb_text_fn)(const char *);
typedef void (*mb_two_text_fn)(const char *, const char *);
typedef unsigned char (*mb_u8_ret_fn)(unsigned char);
typedef unsigned char (*mb_text_ret_fn)(const char *);
typedef unsigned char (*mb_two_text_ret_fn)(const char *, const char *);
typedef unsigned char (*mb_overwrite_ret_fn)(unsigned char, const char *);
typedef unsigned char (*mb_panel_path_fn)(PanelState *, const char *, unsigned char);
typedef void (*mb_panel_draw_fn)(PanelState *, unsigned char, unsigned char);
typedef void (*mb_two_path_fn)(const char *, const char *);
typedef void (*mb_switch_file_fn)(PanelState *, unsigned int);
typedef void (*mb_fill_snap_fn)(NCBottomInfo *);

#define MB_CALL_VOID(slot, type, args) \
	do { type fn; MB_BANK_SAVE() MB_BANK_ENTER(0u); \
		fn = (type)MB_JT_ADDR(slot); fn args; MB_BANK_LEAVE(); } while (0)

#define MB_CALL_U8(slot, type, args) \
	do { type fn; unsigned char ret; MB_BANK_SAVE() MB_BANK_ENTER(0u); \
		fn = (type)MB_JT_ADDR(slot); ret = fn args; MB_BANK_LEAVE(); return ret; } while (0)

void mb_init_resident(void) { MB_CALL_VOID(MB_JT_INIT, mb_void_fn, ()); }
void mb_init_panels(void) { MB_CALL_VOID(MB_JT_INIT_PANELS, mb_void_fn, ()); }
void mb_nc_ini_load(void) { MB_CALL_VOID(MB_JT_NC_INI_LOAD, mb_void_fn, ()); }
void mb_nc_ini_save(void) { MB_CALL_VOID(MB_JT_NC_INI_SAVE, mb_void_fn, ()); }
void mb_nc_capture_startup_path(void) { MB_CALL_VOID(MB_JT_NC_CAPTURE_STARTUP_PATH, mb_void_fn, ()); }
void mb_ui_begin_full_redraw(void) { MB_CALL_VOID(MB_JT_UI_BEGIN_FULL_REDRAW, mb_void_fn, ()); }
void mb_ui_draw_status_bar(void) { MB_CALL_VOID(MB_JT_UI_DRAW_STATUS_BAR, mb_void_fn, ()); }
void mb_ui_clock_redraw(void) { MB_CALL_VOID(MB_JT_UI_CLOCK_REDRAW, mb_void_fn, ()); }
void mb_ui_nc_clock_draw(unsigned char f) { MB_CALL_VOID(MB_JT_UI_NC_CLOCK_DRAW, mb_u8_fn, (f)); }
void mb_draw_panel_background(PanelState *p, unsigned char x) { MB_CALL_VOID(MB_JT_DRAW_PANEL_BACKGROUND, mb_panel_x_fn, (p, x)); }
void mb_panel_draw_footer(PanelState *p, unsigned char x) { MB_CALL_VOID(MB_JT_PANEL_DRAW_FOOTER, mb_panel_x_fn, (p, x)); }
void mb_draw_bottom_info(const NCBottomInfo *s) { MB_CALL_VOID(MB_JT_DRAW_BOTTOM_INFO, mb_snap_fn, (s)); }
void mb_panel_sort_notice_show(PanelState *p) { MB_CALL_VOID(MB_JT_PANEL_SORT_NOTICE_SHOW, mb_panel_fn, (p)); }
void mb_fileop_progress_begin(unsigned char d) { MB_CALL_VOID(MB_JT_FILEOP_PROGRESS_BEGIN, mb_u8_fn, (d)); }
void mb_fileop_progress_begin_title(unsigned char d, const char *t) { MB_CALL_VOID(MB_JT_FILEOP_PROGRESS_TITLE, mb_title_fn, (d, t)); }
void mb_fileop_progress_restore(void) { MB_CALL_VOID(MB_JT_FILEOP_PROGRESS_RESTORE, mb_void_fn, ()); }
void mb_fileop_progress_store_name(const char *n) { MB_CALL_VOID(MB_JT_FILEOP_PROGRESS_NAME, mb_text_fn, (n)); }
void mb_copy_progress_draw_bar(unsigned char p) { MB_CALL_VOID(MB_JT_COPY_PROGRESS_BAR, mb_u8_fn, (p)); }
void mb_copy_progress_draw_name(const char *n) { MB_CALL_VOID(MB_JT_COPY_PROGRESS_NAME, mb_text_fn, (n)); }
void mb_panel_drive_open(PanelState *p) { MB_CALL_VOID(MB_JT_PANEL_DRIVE_OPEN, mb_panel_fn, (p)); }
void mb_panel_drive_redraw(void) { MB_CALL_VOID(MB_JT_PANEL_DRIVE_REDRAW, mb_void_fn, ()); }
unsigned char mb_panel_drive_handle_key(unsigned char k) { MB_CALL_U8(MB_JT_PANEL_DRIVE_HANDLE_KEY, mb_u8_ret_fn, (k)); }
unsigned char mb_ui_dialog_input(const char *t, const char *p) { MB_CALL_U8(MB_JT_UI_DIALOG_INPUT, mb_two_text_ret_fn, (t, p)); }
unsigned char mb_ui_dialog_rename_input(const char *t, const char *p) { MB_CALL_U8(MB_JT_UI_DIALOG_RENAME, mb_two_text_ret_fn, (t, p)); }
unsigned char mb_ui_dialog_delete_confirm(const char *t, const char *p) { MB_CALL_U8(MB_JT_UI_DIALOG_DELETE, mb_two_text_ret_fn, (t, p)); }
void mb_ui_alert_dialog(const char *t, const char *p) { MB_CALL_VOID(MB_JT_UI_ALERT_DIALOG, mb_two_text_fn, (t, p)); }
void mb_ui_error_dialog(const char *t, const char *p) { MB_CALL_VOID(MB_JT_UI_ERROR_DIALOG, mb_two_text_fn, (t, p)); }
unsigned char mb_copy_dest_exists(const char *p) { MB_CALL_U8(MB_JT_COPY_DEST_EXISTS, mb_text_ret_fn, (p)); }
unsigned char mb_copy_dir_exists(const char *p) { MB_CALL_U8(MB_JT_COPY_DIR_EXISTS, mb_text_ret_fn, (p)); }
unsigned char mb_copy_overwrite_resolve(unsigned char e, const char *m) { MB_CALL_U8(MB_JT_COPY_OVERWRITE_RESOLVE, mb_overwrite_ret_fn, (e, m)); }
void mb_menu_open(void)
{
	mb_void_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(3u);
	fn = (mb_void_fn)MB_JT_ADDR(MB_JT4_MENU_OPEN); fn(); MB_BANK_LEAVE();
}
unsigned char mb_menu_handle_key(unsigned char k)
{
	mb_u8_ret_fn fn; unsigned char ret; MB_BANK_SAVE() MB_BANK_ENTER(3u);
	fn = (mb_u8_ret_fn)MB_JT_ADDR(MB_JT4_MENU_HANDLE_KEY); ret = fn(k); MB_BANK_LEAVE(); return ret;
}
void mb_draw_menu_overlay(void)
{
	mb_void_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(3u);
	fn = (mb_void_fn)MB_JT_ADDR(MB_JT4_MENU_DRAW_OVERLAY); fn(); MB_BANK_LEAVE();
}

/* Bank 02 is independent from the bank 01 UI jump table. */
unsigned char mb_read_panel_dir_at(PanelState *p, const char *path, unsigned char preserve)
{
	mb_panel_path_fn fn; unsigned char ret; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_panel_path_fn)MB_JT_ADDR(MB_JT2_READ_PANEL_DIR_AT); ret = fn(p, path, preserve); MB_BANK_LEAVE(); return ret;
}
void mb_draw_panel(PanelState *p, unsigned char x, unsigned char h)
{
	mb_panel_draw_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_panel_draw_fn)MB_JT_ADDR(MB_JT2_DRAW_PANEL); fn(p, x, h); MB_BANK_LEAVE();
}
void mb_panels_remap_bank_window(void)
{
	mb_void_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_void_fn)MB_JT_ADDR(MB_JT2_PANELS_REMAP_WINDOW); fn(); MB_BANK_LEAVE();
}
void mb_panels_reload_both(const char *left, const char *right)
{
	mb_two_path_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_two_path_fn)MB_JT_ADDR(MB_JT2_PANELS_RELOAD_BOTH); fn(left, right); MB_BANK_LEAVE();
}
void mb_panels_paint_both(void)
{
	mb_void_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_void_fn)MB_JT_ADDR(MB_JT2_PANELS_PAINT_BOTH); fn(); MB_BANK_LEAVE();
}
void mb_panels_draw_all(void)
{
	mb_void_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_void_fn)MB_JT_ADDR(MB_JT2_PANELS_DRAW_ALL); fn(); MB_BANK_LEAVE();
}
void mb_switch_file_page(PanelState *p, unsigned int n)
{
	mb_switch_file_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_switch_file_fn)MB_JT_ADDR(MB_JT2_SWITCH_FILE_PAGE); fn(p, n); MB_BANK_LEAVE();
}
void mb_fill_bottom_snap(NCBottomInfo *s)
{
	mb_fill_snap_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_fill_snap_fn)MB_JT_ADDR(MB_JT2_FILL_BOTTOM_SNAP); fn(s); MB_BANK_LEAVE();
}
unsigned char mb_panel_nav_key(unsigned char k)
{
	mb_u8_ret_fn fn; unsigned char ret; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_u8_ret_fn)MB_JT_ADDR(MB_JT2_PANEL_NAV_KEY); ret = fn(k); MB_BANK_LEAVE(); return ret;
}

void mb_panel_menu_apply(unsigned char choice)
{
	mb_u8_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(1u);
	fn = (mb_u8_fn)MB_JT_ADDR(MB_JT2_PANEL_MENU_APPLY); fn(choice); MB_BANK_LEAVE();
}

unsigned char mb_panel_chdir_only(const char *path)
{
	unsigned char ret;
	ret = m_panel_chdir_only(path);
	return ret;
}

void mb_redraw_panels_full(void)
{
	m_redraw_panels_full();
}

/* Bank 03 is the file-operation overlay.  SAVE/LEAVE preserves callers that
 * are themselves executing from an overlay. */
#define MB_CALL_BANK3_VOID(slot) \
	do { mb_void_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(2u); \
		fn = (mb_void_fn)MB_JT_ADDR(slot); fn(); MB_BANK_LEAVE(); } while (0)

void mb_action_copy(void) { MB_CALL_BANK3_VOID(MB_JT3_ACTION_COPY); }
void mb_action_delete(void) { MB_CALL_BANK3_VOID(MB_JT3_ACTION_DELETE); }
void mb_action_rename(void) { MB_CALL_BANK3_VOID(MB_JT3_ACTION_RENAME); }
void mb_action_mkdir(void) { MB_CALL_BANK3_VOID(MB_JT3_ACTION_MKDIR); }
void mb_action_move(void) { MB_CALL_BANK3_VOID(MB_JT3_ACTION_MOVE); }

#define MB_CALL_BANK4_VOID(slot) \
	do { mb_void_fn fn; MB_BANK_SAVE() MB_BANK_ENTER(3u); \
		fn = (mb_void_fn)MB_JT_ADDR(slot); fn(); MB_BANK_LEAVE(); } while (0)

void mb_action_view(void) { MB_CALL_BANK4_VOID(MB_JT4_ACTION_VIEW); }
void mb_action_edit(void) { MB_CALL_BANK4_VOID(MB_JT4_ACTION_EDIT); }
void mb_run_selected_file(void) { MB_CALL_BANK4_VOID(MB_JT4_RUN_SELECTED); }
void mb_nvext_load(void) { MB_CALL_BANK4_VOID(MB_JT4_NVEXT_LOAD); }
unsigned char mb_nvext_find_handler(const char *ext)
{
	mb_text_ret_fn fn; unsigned char ret; MB_BANK_SAVE() MB_BANK_ENTER(3u);
	fn = (mb_text_ret_fn)MB_JT_ADDR(MB_JT4_NVEXT_FIND); ret = fn(ext); MB_BANK_LEAVE(); return ret;
}

void mb_run_bank(unsigned char idx0)
{
	if (idx0 == 0u)
		mb_ui_draw_status_bar();
}

/* mbgen:banks-begin */
void bank1(void)
{
	mb_run_bank(0u);
}

void bank2(void)
{
	mb_run_bank(1u);
}

void bank3(void)
{
	mb_run_bank(2u);
}

void bank4(void)
{
	mb_run_bank(3u);
}
/* mbgen:banks-end */
