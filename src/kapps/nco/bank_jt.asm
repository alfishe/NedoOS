; Jump table @8000 ? bank 01.
; Linked BEFORE codebank_01. Each bank has its own bank_jtN.asm.

	MODULE bank_jt
	PUBLIC bank_jt

	EXTERN init
	EXTERN init_panels
	EXTERN nc_ini_load
	EXTERN nc_ini_save
	EXTERN nc_capture_startup_path
	EXTERN r_ui_begin_full_redraw
	EXTERN r_ui_draw_status_bar
	EXTERN r_ui_clock_redraw
	EXTERN r_ui_nc_clock_draw
	EXTERN r_draw_panel_background
	EXTERN r_draw_bottom_info
	EXTERN r_panel_sort_notice_show
	EXTERN r_fileop_progress_begin
	EXTERN r_fileop_progress_begin_title
	EXTERN r_fileop_progress_restore
	EXTERN r_fileop_progress_store_name
	EXTERN r_copy_progress_draw_bar
	EXTERN r_copy_progress_draw_name
	EXTERN r_panel_drive_open
	EXTERN r_panel_drive_redraw
	EXTERN r_panel_drive_handle_key
	EXTERN r_ui_dialog_input
	EXTERN r_ui_dialog_rename_input
	EXTERN r_ui_dialog_delete_confirm
	EXTERN r_ui_alert_dialog
	EXTERN r_ui_error_dialog
	EXTERN r_copy_dest_exists
	EXTERN r_copy_dir_exists
	EXTERN r_copy_overwrite_resolve
	EXTERN panel_draw_footer

	RSEG CODE_RESIDENT
bank_jt:
	JP	init
	JP	init_panels
	JP	nc_ini_load
	JP	nc_ini_save
	JP	nc_capture_startup_path
	JP	r_ui_begin_full_redraw
	JP	r_ui_draw_status_bar
	JP	r_ui_clock_redraw
	JP	r_ui_nc_clock_draw
	JP	r_draw_panel_background
	JP	r_draw_bottom_info
	JP	r_panel_sort_notice_show
	JP	r_fileop_progress_begin
	JP	r_fileop_progress_begin_title
	JP	r_fileop_progress_restore
	JP	r_fileop_progress_store_name
	JP	r_copy_progress_draw_bar
	JP	r_copy_progress_draw_name
	JP	r_panel_drive_open
	JP	r_panel_drive_redraw
	JP	r_panel_drive_handle_key
	JP	r_ui_dialog_input
	JP	r_ui_dialog_rename_input
	JP	r_ui_dialog_delete_confirm
	JP	r_ui_alert_dialog
	JP	r_ui_error_dialog
	JP	r_copy_dest_exists
	JP	r_copy_dir_exists
	JP	r_copy_overwrite_resolve
	JP	panel_draw_footer

	END
