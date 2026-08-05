#include "nc_inc.h"
#include "nc_plug.h"
#include "mb_plug.h"

unsigned char botMenu[] =
	"{1}Left { 2}Right { 3}View  { 4}Edit  { 5}Copy  { 6}Rename{ 7}MkDir { 8}Delete{ 9}Menu  { 0}Quit  ";

NCCopyProg copy_prog;
char copy_prog_current_name[64];
unsigned char g_delete_progress;
char g_fileop_title[16];

PanelState left_panel;
PanelState right_panel;
unsigned char g_panel_page_used[256];
NCBottomInfo g_bottom_snap;
char g_panel_enter_path[200];

unsigned char g_menu_active;
unsigned char g_menu_level;
unsigned char g_menu_sel;
PanelState *g_menu_panel;
unsigned char g_drive_active;
PanelState *g_drive_panel;
unsigned char g_drive_sel;
unsigned char g_drive_count;

char g_ini_hide_drives[64];
char g_ini_viewer[NC_INI_APP_LEN];
char g_ini_editor[NC_INI_APP_LEN];
unsigned char g_ini_has_left_path;
unsigned char g_ini_has_right_path;
unsigned char g_ini_read_on_focus;
unsigned char g_ini_panel_brief;
unsigned char g_ini_cmd_flag;

unsigned char g_copy_overwrite_mode;
char g_copy_ow_msg[80];
unsigned char g_move_active;
char g_nc_startup_path[64];

/* Bank 03 file-operation workspaces.  Overlay banks are code-only. */
unsigned char g_copy_temp_page;
unsigned char g_copy_snap_page;
unsigned char g_copy_io_page;
unsigned char g_copy_stack_page;
unsigned char g_copy_page_active;
unsigned char g_delete_stack_page;
unsigned char g_delete_page_active;
unsigned char g_fileop_abort;
unsigned char g_focus_pending;
unsigned char g_copy_tree_failed;
unsigned char g_copy_sp;
unsigned char g_deldir_sp;
char r_src_full[200];
char r_dst_full[200];
fileInfo r_global_info;
char r_action_name[64];
char r_action_path[200];
char r_action_left[64];
char r_action_right[64];
char g_snap_left[64];
char g_snap_right[64];

unsigned char residentPg;
union APP_PAGES main_pg;
struct setup nc_set;

/* Mutable state formerly private to nc_resident.c must remain in root. */
char g_ini_save_buf[NC_INI_BUF_SIZE];
unsigned char g_clock_old_minutes = 255u;
unsigned char g_drive_popup_x;
unsigned char g_menu_popup_x;
char g_drive_labels[15][26];
unsigned char g_drive_letters[15];

/* Bank 02 panel workspace.  Keep it in root DATA: overlays are code-only. */
char g_panel_row[PANEL_ROW_WIDTH];
char g_panel_rows[PANEL_VIEW_ROWS][PANEL_ROW_WIDTH];
unsigned char g_panel_row_colors[PANEL_VIEW_ROWS];
unsigned char g_panel_row_marked_row[PANEL_VIEW_ROWS];
unsigned int g_panel_row_phys[PANEL_VIEW_ROWS];
fileInfo g_panel_fi;
fileInfo g_panel_stage[PANEL_READ_STAGE];
unsigned char g_panel_stage_n;
unsigned int g_panel_scan_vis[FILES_PER_PAGE];
unsigned int g_panel_scan_phys[FILES_PER_PAGE];
const char g_month_abbr[12][2] = {
	{'j', 'a'}, {'f', 'b'}, {'m', 'r'}, {'a', 'p'}, {'m', 'y'}, {'j', 'n'},
	{'j', 'l'}, {'a', 'g'}, {'s', 'p'}, {'o', 'c'}, {'n', 'v'}, {'d', 'c'}};
char g_lfn_tie_a[64];
char g_lfn_tie_b[64];
unsigned char *s_kind;
unsigned char *s_name4;
unsigned char *s_ext4;
unsigned char *s_cpm4;
unsigned char *s_lfn4;
unsigned char *s_lfnext4;
unsigned long *s_sizes;
unsigned short *s_dates;
unsigned short *s_times;
unsigned short *s_idx;
unsigned char s_mode;
unsigned char s_desc;
PanelState *s_lfn_panel;

/* UI strings for overlays: bank CSTR lives @8000 and vanishes on mb_* ENTER. */
const char g_ui_copy[] = "Copy";
const char g_ui_copy_to[] = "Copy to:";
const char g_ui_copy_bad_dest[] = "Destination path not found";
const char g_ui_copy_nomem[] = "No memory page";
const char g_ui_copy_write_fail[] = "Cannot write to destination";
const char g_ui_cancelled[] = "Cancelled";
const char g_ui_file_pfx[] = "file ";
const char g_ui_folder_pfx[] = "folder ";
const char g_ui_exist_sfx[] = " exist";
const char g_ui_delete[] = "Delete";
const char g_ui_delete_file[] = "Delete file?";
const char g_ui_delete_folder[] = "Delete folder?";
const char g_ui_delete_marked[] = "Delete marked items?";
const char g_ui_rename[] = "Rename";
const char g_ui_rename_to[] = "Rename to:";
const char g_ui_invalid_name[] = "Invalid name";
const char g_ui_rename_fail[] = "Rename failed";
const char g_ui_rename_fail_msg[] = "Name in use or invalid";
const char g_ui_mkdir[] = "Create directory";
const char g_ui_mkdir_name[] = "Name:";
const char g_ui_mkdir_short[] = "MkDir";
const char g_ui_mkdir_fail[] = "MkDir failed";
const char g_ui_move[] = "Move";
const char g_ui_move_to[] = "Move to:";
const char g_ui_move_bad_dest[] = "Destination path not found";
const char g_ui_move_fail[] = "Cannot move to destination";
const char g_ui_moving[] = "Moving";

char g_run_saved_cwd[64];
char g_run_cmdline[128];
char g_run_inner[96];
char g_run_name[64];
const char g_ui_term_cmd[] = "term.com cmd.com ";
const char g_ui_term_cmd_k[] = "term.com cmd.com /k ";
const char g_ui_term_cmd_p[] = "term.com cmd.com /p ";
const char g_ui_term_com[] = "term.com";
const char g_ui_nv_ext[] = "nv.ext";

unsigned int g_nvext_size;
unsigned int g_ncext_off;
unsigned int g_ncext_size;
char g_run_handler[NC_EXT_HANDLER_MAX];
unsigned char g_nvext_io[128];
unsigned char g_cmd_active;
unsigned char g_cmd_len;
unsigned char g_cmd_cursor;
char g_cmd_line[NC_CMDLINE_LEN];
