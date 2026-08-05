#ifndef MB_REQ_H
#define MB_REQ_H

#include "nc_plug.h"

void mb_init_resident(void);
void mb_init_panels(void);
void mb_nc_ini_load(void);
void mb_nc_ini_save(void);
void mb_nc_capture_startup_path(void);
void mb_ui_begin_full_redraw(void);
void mb_ui_draw_status_bar(void);
void mb_ui_clock_redraw(void);
void mb_ui_nc_clock_draw(unsigned char force);
void mb_draw_panel_background(PanelState *panel, unsigned char start_x);
void mb_panel_draw_footer(PanelState *panel, unsigned char start_x);
void mb_draw_bottom_info(const NCBottomInfo *snap);
void mb_panel_sort_notice_show(PanelState *panel);
void mb_fileop_progress_begin(unsigned char is_delete);
void mb_fileop_progress_begin_title(unsigned char is_delete, const char *title);
void mb_fileop_progress_restore(void);
void mb_fileop_progress_store_name(const char *name);
void mb_copy_progress_draw_bar(unsigned char pct);
void mb_copy_progress_draw_name(const char *name);
void mb_panel_drive_open(PanelState *panel);
void mb_panel_drive_redraw(void);
unsigned char mb_panel_drive_handle_key(unsigned char key);
unsigned char mb_ui_dialog_input(const char *title, const char *prompt);
unsigned char mb_ui_dialog_rename_input(const char *title, const char *prompt);
unsigned char mb_ui_dialog_delete_confirm(const char *title, const char *prompt);
void mb_ui_alert_dialog(const char *title, const char *prompt);
void mb_ui_error_dialog(const char *title, const char *msg);
unsigned char mb_copy_dest_exists(const char *path);
unsigned char mb_copy_dir_exists(const char *path);
unsigned char mb_copy_overwrite_resolve(unsigned char exists, const char *dialog_msg);
void mb_menu_open(void);
unsigned char mb_menu_handle_key(unsigned char key);
void mb_draw_menu_overlay(void);

unsigned char mb_read_panel_dir_at(PanelState *panel, const char *path, unsigned char preserve_cursor);
void mb_draw_panel(PanelState *panel, unsigned char start_x, unsigned char height);
void mb_panels_remap_bank_window(void);
void mb_panels_reload_both(const char *left, const char *right);
void mb_panels_paint_both(void);
void mb_panels_draw_all(void);
void mb_switch_file_page(PanelState *panel, unsigned int file_idx);
void mb_fill_bottom_snap(NCBottomInfo *snap);
unsigned char mb_panel_nav_key(unsigned char key);

unsigned char mb_panel_chdir_only(const char *path);
void mb_redraw_panels_full(void);

void mb_action_copy(void);
void mb_action_delete(void);
void mb_action_rename(void);
void mb_action_mkdir(void);
void mb_action_move(void);

void mb_panel_menu_apply(unsigned char choice);
void mb_action_view(void);
void mb_action_edit(void);
void mb_run_selected_file(void);
void mb_nvext_load(void);
unsigned char mb_nvext_find_handler(const char *ext);

#endif
