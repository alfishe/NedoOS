#include "mb_inc.h"
#include "mb_plug.h"
#include "mb_req.h"

/*
 * nco ? NC on Plan JT multibank.
 * Root 0100-7FFF, code overlays @8000, datapage @C000.
 */

/* Remember which overlay dir worked (avoid failed OPEN on every bank). */
static char g_bank_dir[12];

static void nco_fmt_bank_name(unsigned char idx0, char *name)
{
	sprintf(name, "codeB_%02u.bin", (unsigned int)(idx0 + 1u));
}

static unsigned char nco_try_load(unsigned char idx, unsigned char *page_out)
{
	char path[40];
	char name[16];

	nco_fmt_bank_name(idx, name);

	if (g_bank_dir[0] != 0)
	{
		strcpy(path, g_bank_dir);
		strcat(path, name);
		return mb_load_bank_bin(path, page_out);
	}

	strcpy(path, "nco/");
	strcat(path, name);
	if (mb_load_bank_bin(path, page_out))
	{
		strcpy(g_bank_dir, "nco/");
		return 1u;
	}

	strcpy(path, "bin/nco/");
	strcat(path, name);
	if (mb_load_bank_bin(path, page_out))
	{
		strcpy(g_bank_dir, "bin/nco/");
		return 1u;
	}
	return 0u;
}

static unsigned char nco_load_banks(void)
{
	unsigned char i;
	unsigned char ok;
	char name[16];

	ok = 1u;
	g_bank_dir[0] = 0;
	printf("Loading banks...\r\n");
	for (i = 0u; i < MB_BANK_COUNT; i++)
	{
		nco_fmt_bank_name(i, name);
		printf("  Loading %s\r\n", name);
		if (!nco_try_load(i, &g_bankPg[i]))
		{
			printf("    FAIL\r\n");
			ok = 0u;
		}
		else
			printf("    OK\r\n");
	}
	return ok;
}

static void nco_run_banks(void)
{
	mb_init_resident();
	mb_init_panels();
	mb_nc_capture_startup_path();
	mb_nc_ini_load();
	mb_nvext_load();
	if (left_panel.current_path[0] == 0)
		strcpy(left_panel.current_path, "M:/bin/");
	if (right_panel.current_path[0] == 0)
		strcpy(right_panel.current_path, "M:/");
	mb_panels_reload_both(left_panel.current_path, right_panel.current_path);
	mb_ui_begin_full_redraw();
	mb_draw_panel_background(&left_panel, 0u);
	mb_draw_panel_background(&right_panel, 40u);
	mb_draw_panel(&left_panel, 0u, PANEL_VIEW_ROWS);
	mb_draw_panel(&right_panel, 40u, PANEL_VIEW_ROWS);
	mb_ui_draw_status_bar();
	mb_ui_nc_clock_draw(1u);
	mb_fill_bottom_snap(&g_bottom_snap);
	mb_draw_bottom_info(&g_bottom_snap);
}

/* Match nc_on_focus_refresh: optional dir reload, then restore drive/menu. */
static void nco_on_focus_refresh(void)
{
	g_focus_pending = 0u;
	mb_panels_remap_bank_window();
	if (g_ini_read_on_focus)
	{
		mb_panels_reload_both(left_panel.current_path, right_panel.current_path);
		mb_ui_begin_full_redraw();
		mb_draw_panel_background(&left_panel, 0u);
		mb_draw_panel_background(&right_panel, 40u);
		mb_draw_panel(&left_panel, 0u, PANEL_VIEW_ROWS);
		mb_draw_panel(&right_panel, 40u, PANEL_VIEW_ROWS);
		mb_ui_draw_status_bar();
		mb_ui_nc_clock_draw(1u);
	}
	else
		m_redraw_panels_full();
	if (g_ini_read_on_focus)
		draw_bottom_info(left_panel.is_active ? &left_panel : &right_panel);
	if (g_drive_active)
		mb_panel_drive_redraw();
	else if (g_menu_active)
		mb_draw_menu_overlay();
}

static unsigned char nc_normalize_action_key(unsigned char key)
{
	if (key == NC_KEY_F1) return NC_KEY_SS1;
	if (key == NC_KEY_F2) return NC_KEY_SS2;
	if (key == NC_KEY_F3) return NC_KEY_SS3;
	if (key == NC_KEY_F4) return NC_KEY_SS4;
	if (key == NC_KEY_F5) return NC_KEY_SS5;
	if (key == NC_KEY_F6) return NC_KEY_SS6;
	if (key == NC_KEY_F7) return NC_KEY_SS7;
	if (key == NC_KEY_F8) return NC_KEY_SS8;
	if (key == NC_KEY_F9) return NC_KEY_SS9;
	if (key == NC_KEY_F10) return NC_KEY_SS0;
	return key;
}

C_task main(void)
{
	unsigned char key;

	/* BDOS console: no os_initstdio (nc style). */
	OS_HIDEFROMPARENT();
	OS_SETGFX(6);
	OS_SETSYSDRV();

	mb_init();

	if (!nco_load_banks())
	{
		printf("Load failed. Need /bin/nco/codeB_0N.bin\r\n");
		mb_shutdown();
		exit(1);
	}

	nco_run_banks();
	g_focus_pending = 0u;

	for (;;)
	{
		PanelState *active;

		key = (unsigned char)OS_GETKEY();
		if (key == NC_KEY_FOCUS)
		{
			nco_on_focus_refresh();
			continue;
		}
		if (g_focus_pending)
		{
			nco_on_focus_refresh();
			continue;
		}
		if (key == 0u) { YIELD(); mb_ui_nc_clock_draw(0u); continue; }

		if (g_menu_active)
		{
			(void)mb_menu_handle_key(key);
			continue;
		}
		if (g_drive_active)
		{
			(void)mb_panel_drive_handle_key(key);
			continue;
		}

		active = left_panel.is_active ? &left_panel : &right_panel;
		key = nc_normalize_action_key(key);
		/* nc: action keys (SS*) before cmdline ? SS3..SS8 are also ASCII # $ % & ' ( */
		if (key == NC_KEY_SS0)
		{
			mb_nc_ini_save();
			break;
		}
		if (key == NC_KEY_SS1)
			mb_panel_drive_open(&left_panel);
		else if (key == NC_KEY_SS2)
			mb_panel_drive_open(&right_panel);
		else if (key == NC_KEY_SS3)
			mb_action_view();
		else if (key == NC_KEY_SS4)
			mb_action_edit();
		else if (key == NC_KEY_SS5)
			mb_action_copy();
		else if (key == NC_KEY_SS6)
			mb_action_rename();
		else if (key == NC_KEY_SS7)
			mb_action_mkdir();
		else if (key == NC_KEY_SS8)
			mb_action_delete();
		else if (key == NC_KEY_MOVE)
			mb_action_move();
		else if (key == NC_KEY_SS9)
			mb_menu_open();
		else if (g_cmd_active && (key == NC_KEY_PGUP || key == NC_KEY_PGDN))
		{
			(void)m_cmd_handle_key(key, active);
			m_cmd_fill_bottom_snap();
			mb_draw_bottom_info(&g_bottom_snap);
		}
		else if (key == NC_KEY_CSENTER)
		{
			if (!g_cmd_active)
			{
				g_cmd_active = 1u;
				g_cmd_len = 0u;
				g_cmd_cursor = 0u;
				g_cmd_line[0] = 0;
			}
			(void)m_cmd_handle_key(key, active);
			m_cmd_fill_bottom_snap();
			mb_draw_bottom_info(&g_bottom_snap);
		}
		else if (key == NC_KEY_ENTER)
		{
			if (g_cmd_active)
			{
				if (g_cmd_len == 0u)
					m_cmd_clear();
				else
					m_cmd_execute(active);
				m_cmd_fill_bottom_snap();
				mb_draw_bottom_info(&g_bottom_snap);
			}
			else if (mb_panel_nav_key(key))
			{
				mb_fill_bottom_snap(&g_bottom_snap);
				mb_draw_bottom_info(&g_bottom_snap);
			}
			else
				mb_run_selected_file();
		}
		else if (m_cmd_handle_key(key, active))
		{
			m_cmd_fill_bottom_snap();
			mb_draw_bottom_info(&g_bottom_snap);
		}
		else if (mb_panel_nav_key(key))
		{
			if (g_cmd_active)
				m_cmd_fill_bottom_snap();
			else
				mb_fill_bottom_snap(&g_bottom_snap);
			mb_draw_bottom_info(&g_bottom_snap);
		}
	}
	mb_shutdown();
	exit(0);
}
