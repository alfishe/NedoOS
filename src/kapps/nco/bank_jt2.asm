; Jump table @8000 -- bank 02 panel service.

	MODULE bank_jt2
	PUBLIC bank_jt2

	EXTERN r_read_panel_dir_at
	EXTERN r_draw_panel
	EXTERN r_panels_remap_bank_window
	EXTERN r_panels_reload_both
	EXTERN r_panels_paint_both
	EXTERN r_panels_draw_all
	EXTERN r_switch_file_page
	EXTERN r_fill_bottom_snap
	EXTERN r_panel_nav_key
	EXTERN r_panel_menu_apply

	RSEG CODE_RESIDENT
bank_jt2:
	JP	r_read_panel_dir_at
	JP	r_draw_panel
	JP	r_panels_remap_bank_window
	JP	r_panels_reload_both
	JP	r_panels_paint_both
	JP	r_panels_draw_all
	JP	r_switch_file_page
	JP	r_fill_bottom_snap
	JP	r_panel_nav_key
	JP	r_panel_menu_apply

	END
