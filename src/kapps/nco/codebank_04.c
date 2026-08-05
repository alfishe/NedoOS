#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "nc_inc.h"
#include "nc_plug.h"

static unsigned char r_fold_lower(unsigned char c)
{
	if (c >= 'A' && c <= 'Z')
		return (unsigned char)(c - ('A' - 'a'));
	return c;
}

static unsigned char *r_nvext_base(void)
{
	return (unsigned char *)(BANK_WINDOW_ADDRESS + NC_NVEXT_OFF);
}

static void r_nvext_map(void)
{
	OS_SETPGC000(left_panel.bank_ids[PANEL_META_PAGE]);
}

static void r_nvext_unmap(void)
{
	OS_SETPGC000(m_run_resident_page());
	m_panels_remap_bank_window();
}

static void r_nvext_copy_chunk(unsigned char *dst, const unsigned char *src, unsigned int n)
{
	unsigned int i;
	for (i = 0u; i < n; i++)
		dst[i] = src[i];
}

static unsigned char r_nvext_panel_ok(void)
{
	unsigned char i;
	for (i = 0u; i < NC_PAGES_PER_PANEL; i++)
	{
		if (left_panel.bank_ids[i] == 0u)
			return 0u;
	}
	return 1u;
}

void r_nvext_load(void)
{
	FILE *fp;
	unsigned int fileSize;
	unsigned int loop;
	unsigned int loaded;
	unsigned int toRead;
	unsigned char *dst;
	unsigned char resident;

	g_nvext_size = 0u;
	g_ncext_off = 0u;
	g_ncext_size = 0u;
	if (!r_nvext_panel_ok())
		return;

	resident = m_run_resident_page();
	OS_SETPGC000(resident);
	OS_SETSYSDRV();
	fp = OS_OPENHANDLE((unsigned char *)g_ui_nv_ext, 0x80);
	if (((int)fp) & 0xff)
		return;

	OS_SETPGC000(resident);
	fileSize = OS_GETFILESIZE(fp);
	if (fileSize >= NC_NVEXT_MAX)
		fileSize = NC_NVEXT_MAX - 1u;

	r_nvext_map();
	dst = r_nvext_base();
	loop = 0u;
	while (loop < fileSize)
	{
		toRead = fileSize - loop;
		if (toRead > sizeof(g_nvext_io))
			toRead = (unsigned int)sizeof(g_nvext_io);
		OS_SETPGC000(resident);
		loaded = OS_READHANDLE(g_nvext_io, fp, toRead);
		if (loaded == 0u)
			break;
		r_nvext_map();
		r_nvext_copy_chunk(dst + loop, g_nvext_io, loaded);
		loop += loaded;
	}
	OS_SETPGC000(resident);
	OS_CLOSEHANDLE(fp);
	g_nvext_size = loop;
	r_nvext_map();
	dst[loop] = 0;
	OS_SETPGC000(resident);

	if (loop + 2u >= NC_NVEXT_MAX)
		return;

	fp = OS_OPENHANDLE((unsigned char *)NC_EXT_NAME, 0x80);
	if (((int)fp) & 0xff)
		return;

	OS_SETPGC000(resident);
	fileSize = OS_GETFILESIZE(fp);
	if (fileSize + loop + 1u >= NC_NVEXT_MAX)
		fileSize = NC_NVEXT_MAX - loop - 2u;

	g_ncext_off = loop + 1u;
	r_nvext_map();
	dst = r_nvext_base() + g_ncext_off;
	loop = 0u;
	while (loop < fileSize)
	{
		toRead = fileSize - loop;
		if (toRead > sizeof(g_nvext_io))
			toRead = (unsigned int)sizeof(g_nvext_io);
		OS_SETPGC000(resident);
		loaded = OS_READHANDLE(g_nvext_io, fp, toRead);
		if (loaded == 0u)
			break;
		r_nvext_map();
		r_nvext_copy_chunk(dst + loop, g_nvext_io, loaded);
		loop += loaded;
	}
	OS_SETPGC000(resident);
	OS_CLOSEHANDLE(fp);
	g_ncext_size = loop;
	r_nvext_map();
	dst[loop] = 0;
	OS_SETPGC000(resident);
}

static unsigned char r_ext_db_find_handler(const unsigned char *pDb, unsigned int dbSize, const char *ext)
{
	const unsigned char *pEnd;
	const unsigned char *pLineStart;
	unsigned char extLow[4];
	unsigned char found;
	unsigned int i;

	found = 0u;
	if (dbSize == 0u)
		return 0u;

	for (i = 0u; i < 3u && ext[i] != 0 && ext[i] != ' '; i++)
		extLow[i] = r_fold_lower((unsigned char)ext[i]);
	extLow[i] = 0;
	if (extLow[0] == 0)
		return 0u;

	pEnd = pDb + dbSize;

	while (pDb < pEnd && *pDb != 0)
	{
		pLineStart = pDb;
		while (pDb < pEnd && *pDb != 0x0d && *pDb != 0x0a && *pDb != 0)
		{
			i = 0u;
			while (extLow[i] != 0 && extLow[i] == r_fold_lower(pDb[i]))
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
					i = 0u;
					while (pDb < pEnd && *pDb != 0x0d && *pDb != 0x0a && *pDb != 0 &&
						   i + 1u < (unsigned int)NC_EXT_HANDLER_MAX)
						g_run_handler[i++] = (char)*pDb++;
					g_run_handler[i] = 0;
					found = 1u;
					goto r_ext_db_find_done;
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

r_ext_db_find_done:
	return found;
}

unsigned char r_nvext_find_handler(const char *ext)
{
	unsigned char found;

	found = 0u;
	if (g_ncext_size != 0u)
	{
		r_nvext_map();
		found = r_ext_db_find_handler((const unsigned char *)r_nvext_base() + g_ncext_off, g_ncext_size, ext);
	}
	if (!found && g_nvext_size != 0u)
	{
		r_nvext_map();
		found = r_ext_db_find_handler((const unsigned char *)r_nvext_base(), g_nvext_size, ext);
	}
	r_nvext_unmap();
	return found;
}

void r_action_view(void)
{
	m_run_action_view(m_run_active_panel());
}

void r_action_edit(void)
{
	m_run_action_edit(m_run_active_panel());
}

void r_run_selected_file(void)
{
	m_run_action_selected(m_run_active_panel());
}
/* --- F9 Menu / Files (lives in bank04 free space) --- */

/*
 * Menu has its own draw helpers - do not call bank01 UI.
 */

static void menu_print_cstr(const char *s)
{
	unsigned char i;

	i = 0u;
	while (s[i] != 0)
	{
		putchar(s[i]);
		i++;
	}
}

static void menu_print_pad(const char *str, unsigned char width)
{
	unsigned char i;

	i = 0u;
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

static void menu_fill_chars(unsigned char x, unsigned char y, unsigned char sym,
							unsigned char count, unsigned char color)
{
	unsigned char i;

	if (count == 0u)
		return;
	OS_SETXY(x, y);
	OS_SETCOLOR(color);
	for (i = 0u; i < count; i++)
		putchar(sym);
}

static void menu_bdbox(unsigned char xbox, unsigned char ybox, unsigned char wbox,
					   unsigned char hbox, unsigned char cbox, unsigned char character)
{
	unsigned char x;
	unsigned char y;

	OS_SETCOLOR(cbox);
	for (y = 0u; y < hbox; y++)
	{
		OS_SETXY(xbox, (unsigned char)(ybox + y));
		for (x = 0u; x < wbox; x++)
			putchar(character);
	}
}

static void menu_draw_frame(unsigned char x, unsigned char y, unsigned char w, unsigned char h,
							unsigned char color, const char *title)
{
	unsigned char wcount;
	unsigned char tempx;
	unsigned char title_start;
	unsigned char tlen;

	menu_bdbox(x, y, (unsigned char)(w + 2u), (unsigned char)(h + 1u), color, 32);

	OS_SETXY(x, y);
	OS_SETCOLOR(color);
	putchar(201);
	for (wcount = 0u; wcount < w; wcount++)
		putchar(205);
	putchar(187);

	OS_SETXY(x, (unsigned char)(y + h));
	putchar(200);
	for (wcount = 0u; wcount < w; wcount++)
		putchar(205);
	putchar(188);

	tempx = (unsigned char)(x + w + 1u);
	for (wcount = 1u; wcount < h; wcount++)
	{
		OS_SETXY(x, (unsigned char)(y + wcount));
		putchar(186);
		OS_SETXY(tempx, (unsigned char)(y + wcount));
		putchar(186);
	}

	if (title != NULL)
	{
		tlen = 0u;
		while (title[tlen] != 0)
			tlen++;
		title_start = (unsigned char)(x + (w / 2u));
		if (tlen < w)
			title_start = (unsigned char)(title_start - (tlen / 2u));
		OS_SETXY(title_start, y);
		OS_SETCOLOR(color);
		putchar('[');
		menu_print_cstr(title);
		putchar(']');
	}
}

static void menu_draw_item(unsigned char x0, unsigned char y, unsigned char width,
						   unsigned char selected, const char *label, unsigned char current)
{
	unsigned char fill_color;

	fill_color = selected ? NC_COLOR_MENU_HILITE : NC_COLOR_MENU_NORM;
	menu_fill_chars(x0, y, ' ', width, fill_color);
	OS_SETXY((unsigned char)(x0 + 1u), y);
	menu_print_pad(label, (unsigned char)(width - 2u));
	if (current)
		putchar('*');
}

static unsigned char menu_popup_x_for(const PanelState *panel)
{
	unsigned char start;

	start = (panel == &right_panel) ? 40u : 0u;
	return (unsigned char)(start + (40u - NC_MENU_POPUP_INNER_W - 2u) / 2u);
}

static unsigned char menu_item_x(void)
{
	return (unsigned char)(g_menu_popup_x + 1u);
}

static const char *menu_cmd_flag_label(void)
{
	if (g_ini_cmd_flag == NC_CMD_FLAG_K)
		return "Cmd: /k";
	if (g_ini_cmd_flag == NC_CMD_FLAG_P)
		return "Cmd: /p";
	return "Cmd: none";
}

/* Display cycle: Name -> Ext -> Date -> Size (internal TIME before SIZE). */
static unsigned char menu_cycle_sort_mode(unsigned char mode, signed char delta)
{
	unsigned char d;

	if (mode == NC_PANEL_SORT_EXT)
		d = 1u;
	else if (mode == NC_PANEL_SORT_TIME)
		d = 2u;
	else if (mode == NC_PANEL_SORT_SIZE)
		d = 3u;
	else
		d = 0u;
	if (delta > 0)
		d = (unsigned char)((d + 1u) % 4u);
	else
		d = (unsigned char)((d + 3u) % 4u);
	if (d == 1u)
		return NC_PANEL_SORT_EXT;
	if (d == 2u)
		return NC_PANEL_SORT_TIME;
	if (d == 3u)
		return NC_PANEL_SORT_SIZE;
	return NC_PANEL_SORT_NAME;
}

static const char *menu_sort_by_label(unsigned char mode)
{
	if (mode == NC_PANEL_SORT_EXT)
		return "Sort by: Ext";
	if (mode == NC_PANEL_SORT_SIZE)
		return "Sort by: Size";
	if (mode == NC_PANEL_SORT_TIME)
		return "Sort by: Date";
	return "Sort by: Name";
}

static const char *menu_sort_dir_label(unsigned char desc)
{
	return desc ? "Sort dir: desc" : "Sort dir: asc";
}

static void menu_draw_files_row(PanelState *active_p, unsigned char idx, unsigned char cursor_on)
{
	unsigned char y;

	y = (unsigned char)(NC_MENU_POPUP_Y + 1u + idx);
	switch (idx)
	{
	case NC_MFI_SORT_BY:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on,
					   menu_sort_by_label(active_p->sort_mode), 0);
		break;
	case NC_MFI_SORT_DIR:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on,
					   menu_sort_dir_label(active_p->sort_desc), 0);
		break;
	case NC_MFI_LFN_SORT:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "LFN sort", active_p->sort_lfn);
		break;
	case NC_MFI_READ_ON_FOCUS:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "Read on focus", g_ini_read_on_focus);
		break;
	case NC_MFI_BRIEF:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "Brief view", g_ini_panel_brief);
		break;
	case NC_MFI_CMD_FLAG:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, menu_cmd_flag_label(), 0);
		break;
	case NC_MFI_SAVE:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "Save settings", 0);
		break;
	}
}

static void menu_files_open(PanelState *active_p)
{
	unsigned char i;

	menu_draw_frame(g_menu_popup_x, NC_MENU_POPUP_Y, NC_MENU_POPUP_INNER_W,
					(unsigned char)(NC_MENU_FILES_ITEMS + 1u), NC_COLOR_MENU_NORM, "Files");
	for (i = 0u; i < NC_MENU_FILES_ITEMS; i++)
		menu_draw_files_row(active_p, i, (unsigned char)(i == g_menu_sel));
}

static void menu_top_open(void)
{
	menu_draw_frame(g_menu_popup_x, NC_MENU_POPUP_Y, NC_MENU_POPUP_INNER_W, 2u, NC_COLOR_MENU_NORM, "Menu");
	menu_draw_item(menu_item_x(), (unsigned char)(NC_MENU_POPUP_Y + 1u), NC_MENU_POPUP_INNER_W,
				   (unsigned char)(g_menu_sel == 0), "Files", 0);
}

static void menu_sel_move(PanelState *active_p, unsigned char new_sel)
{
	unsigned char old_sel;

	if (new_sel >= NC_MENU_FILES_ITEMS)
		new_sel = NC_MENU_FILES_ITEMS - 1u;
	old_sel = g_menu_sel;
	if (new_sel == old_sel)
		return;

	g_menu_sel = new_sel;
	if (g_menu_level == NC_MENU_LEVEL_TOP)
	{
		menu_top_open();
		return;
	}

	menu_draw_files_row(active_p, old_sel, 0);
	menu_draw_files_row(active_p, new_sel, 1);
}

static unsigned char menu_cycle_val(unsigned char val, unsigned char count, signed char delta)
{
	if (delta > 0)
		return (unsigned char)((val + 1u) % count);
	return (unsigned char)((val + count - 1u) % count);
}

static void menu_adjust_item(PanelState *active_p, signed char delta)
{
	unsigned char idx;

	idx = g_menu_sel;
	if (idx == NC_MFI_SORT_BY)
	{
		active_p->sort_mode = menu_cycle_sort_mode(active_p->sort_mode, delta);
		menu_draw_files_row(active_p, idx, 1);
		return;
	}
	if (idx == NC_MFI_SORT_DIR)
	{
		active_p->sort_desc = menu_cycle_val(active_p->sort_desc, 2u, delta);
		menu_draw_files_row(active_p, idx, 1);
		return;
	}
	if (idx == NC_MFI_LFN_SORT)
	{
		active_p->sort_lfn = menu_cycle_val(active_p->sort_lfn, 2u, delta);
		menu_draw_files_row(active_p, idx, 1);
		return;
	}
	if (idx == NC_MFI_READ_ON_FOCUS)
	{
		g_ini_read_on_focus = menu_cycle_val(g_ini_read_on_focus, 2u, delta);
		menu_draw_files_row(active_p, idx, 1);
		return;
	}
	if (idx == NC_MFI_BRIEF)
	{
		g_ini_panel_brief = menu_cycle_val(g_ini_panel_brief, 2u, delta);
		menu_draw_files_row(active_p, idx, 1);
		return;
	}
	if (idx == NC_MFI_CMD_FLAG)
	{
		g_ini_cmd_flag = menu_cycle_val(g_ini_cmd_flag, 3u, delta);
		menu_draw_files_row(active_p, idx, 1);
	}
}

void r_draw_menu_overlay(void)
{
	if (!g_menu_active || g_menu_panel == NULL)
		return;

	if (g_menu_level == NC_MENU_LEVEL_TOP)
		menu_top_open();
	else
		menu_files_open(g_menu_panel);
}

void r_menu_open(void)
{
	g_menu_panel = left_panel.is_active ? &left_panel : &right_panel;
	g_menu_popup_x = menu_popup_x_for(g_menu_panel);
	g_menu_active = 1u;
	g_menu_level = NC_MENU_LEVEL_TOP;
	g_menu_sel = 0u;
	r_draw_menu_overlay();
}

unsigned char r_menu_handle_key(unsigned char key)
{
	if (g_menu_panel == NULL)
		g_menu_panel = left_panel.is_active ? &left_panel : &right_panel;

	if (key == 27u)
	{
		menu_close_and_redraw();
		return 1u;
	}

	if (g_menu_level == NC_MENU_LEVEL_TOP)
	{
		if (key == 13u)
		{
			g_menu_level = NC_MENU_LEVEL_FILES;
			g_menu_sel = NC_MFI_SORT_BY;
			menu_files_open(g_menu_panel);
		}
		return 1u;
	}

	if (key == 250u)
	{
		if (g_menu_sel > 0u)
			menu_sel_move(g_menu_panel, (unsigned char)(g_menu_sel - 1u));
		return 1u;
	}
	if (key == 249u)
	{
		if (g_menu_sel < NC_MENU_FILES_ITEMS - 1u)
			menu_sel_move(g_menu_panel, (unsigned char)(g_menu_sel + 1u));
		return 1u;
	}
	if (key == 248u)
	{
		menu_adjust_item(g_menu_panel, -1);
		return 1u;
	}
	if (key == 251u)
	{
		menu_adjust_item(g_menu_panel, 1);
		return 1u;
	}
	if (key == 13u)
	{
		if (g_menu_sel == NC_MFI_SAVE)
			menu_apply_choice(NC_MFI_SAVE);
		else
			menu_adjust_item(g_menu_panel, 1);
		return 1u;
	}

	return 1u;
}
