#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "nc_inc.h"
#include "nc_plug.h"

/*
 * Resident code at C000 (window_3 / residentPg).
 * Callable while panel pages are mapped on 0xC000; uses globals in 0100-BFFF only.
 *
 * === ������ CODE_RESIDENT (C000-FFFF) ===
 *   ����� ...... NC_RES_CODE_USED B (C000..NC_RES_CODE_END)
 *   ᢮����� .... NC_RES_CODE_FREE B
 *
 * === ������ main (0100-BFFF), globals resident ===
 *   code ........ NC_MAIN_CODE_BYTES B
 *   data+stack .. NC_MAIN_USED_END, ᢮����� NC_MAIN_FREE B
 */

void init(void)
{
	main_pg.l = OS_GETMAINPAGES();
	residentPg = main_pg.pgs.window_3;
}

void init_panels(void)
{
	unsigned char p;

	memset(g_panel_page_used, 0, sizeof(g_panel_page_used));

	for (p = 0; p < NC_PAGES_PER_PANEL; p++)
	{
		left_panel.bank_ids[p] = 0;
		if (!panel_request_unique_page(&left_panel.bank_ids[p]))
			left_panel.bank_ids[p] = 0;
	}
	left_panel.file_count = 0;
	left_panel.files_only_count = 0;
	left_panel.total_bytes = 0;
	left_panel.cursor_idx = 0;
	left_panel.scroll_offset = 0;
	left_panel.is_active = 1;
	left_panel.sort_mode = NC_PANEL_SORT_NAME;
	left_panel.sort_desc = 0;
	left_panel.sort_lfn = 0;
	left_panel.marked_count = 0;
	left_panel.marked_bytes = 0UL;
	left_panel.current_path[0] = 0;

	for (p = 0; p < NC_PAGES_PER_PANEL; p++)
	{
		right_panel.bank_ids[p] = 0;
		if (!panel_request_unique_page(&right_panel.bank_ids[p]))
			right_panel.bank_ids[p] = 0;
	}
	right_panel.file_count = 0;
	right_panel.files_only_count = 0;
	right_panel.total_bytes = 0;
	right_panel.cursor_idx = 0;
	right_panel.scroll_offset = 0;
	right_panel.is_active = 0;
	right_panel.sort_mode = NC_PANEL_SORT_NAME;
	right_panel.sort_desc = 0;
	right_panel.sort_lfn = 0;
	right_panel.marked_count = 0;
	right_panel.marked_bytes = 0UL;
	right_panel.current_path[0] = 0;

	g_menu_active = 0;
	g_menu_level = NC_MENU_LEVEL_TOP;
	g_menu_sel = 0;
	g_menu_panel = NULL;
	g_drive_active = 0;
	g_drive_panel = NULL;
	g_drive_sel = 0;
	g_drive_count = 0;
}

#define NC_INI_DEFAULT_LEFT "M:/bin/"
#define NC_INI_DEFAULT_RIGHT "M:/test/"
#define NC_INI_DEFAULT_VIEWER "texted.com"
#define NC_INI_DEFAULT_EDITOR "texted.com"

static void ini_panel_path_normalize(PanelState *panel, const char *path)
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

static unsigned char ini_panel_chdir_only(const char *path)
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

static void ini_rtrim(char *s)
{
	unsigned int n;

	n = 0;
	while (s[n] != 0)
		n++;
	while (n > 0u && (s[n - 1u] == ' ' || s[n - 1u] == '\t' || s[n - 1u] == '\r' || s[n - 1u] == '\n'))
	{
		n--;
		s[n] = 0;
	}
}

static unsigned char ini_parse_sort_mode(const char *v)
{
	if (strcmp(v, "ext") == 0)
		return NC_PANEL_SORT_EXT;
	if (strcmp(v, "size") == 0)
		return NC_PANEL_SORT_SIZE;
	if (strcmp(v, "time") == 0)
		return NC_PANEL_SORT_TIME;
	return NC_PANEL_SORT_NAME;
}

static unsigned char ini_parse_sort_dir(const char *v)
{
	if (v[0] == 'd' || v[0] == 'D' || v[0] == '1')
		return 1;
	return 0;
}

static unsigned char ini_parse_bool(const char *v)
{
	if (v[0] == '1' || v[0] == 'y' || v[0] == 'Y' || v[0] == 't' || v[0] == 'T')
		return 1;
	return 0;
}

static unsigned char ini_parse_cmd_flag(const char *v)
{
	if (v[0] == 'k' || v[0] == 'K')
		return NC_CMD_FLAG_K;
	if (v[0] == 'p' || v[0] == 'P')
		return NC_CMD_FLAG_P;
	return NC_CMD_FLAG_NONE;
}

static const char *ini_cmd_flag_name(unsigned char f)
{
	if (f == NC_CMD_FLAG_K)
		return "k";
	if (f == NC_CMD_FLAG_P)
		return "p";
	return "none";
}

static const char *menu_cmd_flag_label(void)
{
	if (g_ini_cmd_flag == NC_CMD_FLAG_K)
		return "Cmd: /k";
	if (g_ini_cmd_flag == NC_CMD_FLAG_P)
		return "Cmd: /p";
	return "Cmd: none";
}

static unsigned char ini_set_location(void)
{
	unsigned int res;

	res = OS_SETSYSDRV();
	if ((res & 0xff00u) != 0u)
		return 0;
	return (unsigned char)(OS_CHDIR((unsigned char *)NC_INI_DIR) == 0);
}

static void ini_restore_cwd(void)
{
	PanelState *active;

	active = left_panel.is_active ? &left_panel : &right_panel;
	ini_panel_chdir_only(active->current_path);
}

static void ini_apply_defaults(void)
{
	if (!g_ini_has_left_path)
		ini_panel_path_normalize(&left_panel, NC_INI_DEFAULT_LEFT);
	if (!g_ini_has_right_path)
		ini_panel_path_normalize(&right_panel, NC_INI_DEFAULT_RIGHT);
	if (g_ini_viewer[0] == 0)
		strcpy(g_ini_viewer, NC_INI_DEFAULT_VIEWER);
	if (g_ini_editor[0] == 0)
		strcpy(g_ini_editor, NC_INI_DEFAULT_EDITOR);
}

static void ini_apply_key(const char *key, const char *val)
{
	if (strcmp(key, "LeftPath") == 0 || strcmp(key, "left_path") == 0)
	{
		ini_panel_path_normalize(&left_panel, val);
		g_ini_has_left_path = 1;
	}
	else if (strcmp(key, "RightPath") == 0 || strcmp(key, "right_path") == 0)
	{
		ini_panel_path_normalize(&right_panel, val);
		g_ini_has_right_path = 1;
	}
	else if (strcmp(key, "LeftSort") == 0 || strcmp(key, "left_sort") == 0)
		left_panel.sort_mode = ini_parse_sort_mode(val);
	else if (strcmp(key, "RightSort") == 0 || strcmp(key, "right_sort") == 0)
		right_panel.sort_mode = ini_parse_sort_mode(val);
	else if (strcmp(key, "LeftSortDir") == 0 || strcmp(key, "left_sort_dir") == 0)
		left_panel.sort_desc = ini_parse_sort_dir(val);
	else if (strcmp(key, "RightSortDir") == 0 || strcmp(key, "right_sort_dir") == 0)
		right_panel.sort_desc = ini_parse_sort_dir(val);
	else if (strcmp(key, "LeftSortLfn") == 0 || strcmp(key, "left_sort_lfn") == 0)
		left_panel.sort_lfn = ini_parse_bool(val);
	else if (strcmp(key, "RightSortLfn") == 0 || strcmp(key, "right_sort_lfn") == 0)
		right_panel.sort_lfn = ini_parse_bool(val);
	else if (strcmp(key, "LeftActive") == 0 || strcmp(key, "left_active") == 0)
	{
		if (ini_parse_bool(val))
		{
			left_panel.is_active = 1;
			right_panel.is_active = 0;
		}
		else
		{
			left_panel.is_active = 0;
			right_panel.is_active = 1;
		}
	}
	else if (strcmp(key, "HideDrives") == 0 || strcmp(key, "hide_drives") == 0)
	{
		strncpy(g_ini_hide_drives, val, sizeof(g_ini_hide_drives) - 1u);
		g_ini_hide_drives[sizeof(g_ini_hide_drives) - 1u] = 0;
	}
	else if (strcmp(key, "Viewer") == 0 || strcmp(key, "viewer") == 0)
	{
		strncpy(g_ini_viewer, val, sizeof(g_ini_viewer) - 1u);
		g_ini_viewer[sizeof(g_ini_viewer) - 1u] = 0;
	}
	else if (strcmp(key, "Editor") == 0 || strcmp(key, "editor") == 0)
	{
		strncpy(g_ini_editor, val, sizeof(g_ini_editor) - 1u);
		g_ini_editor[sizeof(g_ini_editor) - 1u] = 0;
	}
	else if (strcmp(key, "ReadOnFocus") == 0 || strcmp(key, "read_on_focus") == 0)
		g_ini_read_on_focus = ini_parse_bool(val);
	else if (strcmp(key, "BriefView") == 0 || strcmp(key, "brief_view") == 0)
		g_ini_panel_brief = ini_parse_bool(val);
	else if (strcmp(key, "CmdFlag") == 0 || strcmp(key, "cmd_flag") == 0)
		g_ini_cmd_flag = ini_parse_cmd_flag(val);
}

void nc_ini_load(void)
{
	FILE *fp;
	int n;
	unsigned int i;
	char buf[NC_INI_BUF_SIZE];
	char line[64];
	char key[32];
	char val[64];

	g_ini_hide_drives[0] = 0;
	g_ini_viewer[0] = 0;
	g_ini_editor[0] = 0;
	g_ini_has_left_path = 0;
	g_ini_has_right_path = 0;
	g_ini_read_on_focus = 0;
	g_ini_panel_brief = 0;
	g_ini_cmd_flag = NC_CMD_FLAG_NONE;

	if (!ini_set_location())
	{
		ini_apply_defaults();
		ini_restore_cwd();
		return;
	}
	fp = OS_OPENHANDLE((unsigned char *)NC_INI_NAME, 0x80);
	if (((int)fp) & 0xff)
	{
		ini_apply_defaults();
		ini_restore_cwd();
		return;
	}

	n = (int)OS_READHANDLE((unsigned char *)buf, fp, NC_INI_BUF_SIZE - 1u);
	OS_CLOSEHANDLE(fp);
	if (n <= 0)
	{
		ini_apply_defaults();
		ini_restore_cwd();
		return;
	}

	buf[n] = 0;
	i = 0;
	while (buf[i] != 0)
	{
		char *eq;
		unsigned int j;
		unsigned int k;

		j = 0;
		while (buf[i] != 0 && buf[i] != '\r' && buf[i] != '\n' && j < sizeof(line) - 1u)
			line[j++] = buf[i++];
		line[j] = 0;
		if (buf[i] == '\r')
			i++;
		if (buf[i] == '\n')
			i++;

		ini_rtrim(line);
		j = 0;
		while (line[j] == ' ' || line[j] == '\t')
			j++;
		if (line[j] == 0 || line[j] == '#' || line[j] == ';')
			continue;

		eq = line + j;
		while (*eq != 0 && *eq != '=')
			eq++;
		if (*eq != '=')
			continue;
		*eq = 0;
		strncpy(key, line + j, sizeof(key) - 1u);
		key[sizeof(key) - 1u] = 0;
		ini_rtrim(key);
		strncpy(val, eq + 1, sizeof(val) - 1u);
		val[sizeof(val) - 1u] = 0;
		j = 0;
		while (val[j] == ' ' || val[j] == '\t')
			j++;
		if (j > 0)
		{
			k = 0;
			while (val[j] != 0 && k < sizeof(val) - 1u)
				val[k++] = val[j++];
			val[k] = 0;
		}
		ini_rtrim(val);
		ini_apply_key(key, val);
	}
	ini_apply_defaults();
	ini_restore_cwd();
}

static const char *ini_sort_mode_name(unsigned char mode)
{
	switch (mode)
	{
	case NC_PANEL_SORT_EXT:
		return "ext";
	case NC_PANEL_SORT_SIZE:
		return "size";
	case NC_PANEL_SORT_TIME:
		return "time";
	default:
		return "name";
	}
}

static unsigned char ini_append(char *buf, unsigned int *pos, const char *text)
{
	unsigned int n;
	unsigned int new_pos;

	n = 0;
	while (text[n] != 0)
		n++;
	new_pos = *pos + n;
	if (new_pos >= NC_INI_BUF_SIZE - 1u)
		return 0;
	memcpy(buf + *pos, text, n);
	*pos = new_pos;
	buf[*pos] = 0;
	return 1;
}

static unsigned char ini_append_u8(char *buf, unsigned int *pos, unsigned char v)
{
	char tmp[4];
	unsigned char n;

	n = 0;
	if (v >= 100u)
	{
		tmp[n++] = (char)('0' + (v / 100u));
		v = (unsigned char)(v % 100u);
	}
	if (n > 0u || v >= 10u)
	{
		tmp[n++] = (char)('0' + (v / 10u));
		v = (unsigned char)(v % 10u);
	}
	tmp[n++] = (char)('0' + v);
	tmp[n] = 0;
	return ini_append(buf, pos, tmp);
}

static unsigned char ini_append_kv(char *buf, unsigned int *pos, const char *key, const char *val)
{
	unsigned int saved;

	saved = *pos;
	if (!ini_append(buf, pos, key))
		goto fail;
	if (!ini_append(buf, pos, "="))
		goto fail;
	if (!ini_append(buf, pos, val))
		goto fail;
	if (!ini_append(buf, pos, "\r\n"))
		goto fail;
	return 1;
fail:
	*pos = saved;
	buf[saved] = 0;
	return 0;
}

static unsigned char ini_append_kv_u8(char *buf, unsigned int *pos, const char *key, unsigned char val)
{
	unsigned int saved;

	saved = *pos;
	if (!ini_append(buf, pos, key))
		goto fail;
	if (!ini_append(buf, pos, "="))
		goto fail;
	if (!ini_append_u8(buf, pos, val))
		goto fail;
	if (!ini_append(buf, pos, "\r\n"))
		goto fail;
	return 1;
fail:
	*pos = saved;
	buf[saved] = 0;
	return 0;
}

extern char g_ini_save_buf[NC_INI_BUF_SIZE];

void nc_ini_save(void)
{
	FILE *fp;
	unsigned int pos;

	pos = 0;
	g_ini_save_buf[0] = 0;
	ini_append(g_ini_save_buf, &pos, "# NC settings\r\n");
	ini_append(g_ini_save_buf, &pos, "# Console cmd line: none / k / p (F9 menu)\r\n");
	ini_append_kv(g_ini_save_buf, &pos, "CmdFlag", ini_cmd_flag_name(g_ini_cmd_flag));
	ini_append(g_ini_save_buf, &pos, "# 1 = re-read both panels when app regains focus (key 31)\r\n");
	ini_append_kv_u8(g_ini_save_buf, &pos, "ReadOnFocus", g_ini_read_on_focus);
	ini_append(g_ini_save_buf, &pos, "# 1 = brief panel view (name + size only)\r\n");
	ini_append_kv_u8(g_ini_save_buf, &pos, "BriefView", g_ini_panel_brief);
	ini_append_kv_u8(g_ini_save_buf, &pos, "LeftActive", left_panel.is_active);
	ini_append_kv(g_ini_save_buf, &pos, "LeftPath", left_panel.current_path);
	ini_append_kv(g_ini_save_buf, &pos, "RightPath", right_panel.current_path);
	ini_append_kv(g_ini_save_buf, &pos, "LeftSort", ini_sort_mode_name(left_panel.sort_mode));
	ini_append_kv(g_ini_save_buf, &pos, "RightSort", ini_sort_mode_name(right_panel.sort_mode));
	ini_append_kv(g_ini_save_buf, &pos, "LeftSortDir", left_panel.sort_desc ? "desc" : "asc");
	ini_append_kv(g_ini_save_buf, &pos, "RightSortDir", right_panel.sort_desc ? "desc" : "asc");
	ini_append_kv_u8(g_ini_save_buf, &pos, "LeftSortLfn", left_panel.sort_lfn);
	ini_append_kv_u8(g_ini_save_buf, &pos, "RightSortLfn", right_panel.sort_lfn);
	ini_append(g_ini_save_buf, &pos, "# Comma-separated letters to hide in drive menu (e.g. J,K,L)\r\n");
	ini_append_kv(g_ini_save_buf, &pos, "HideDrives", g_ini_hide_drives);
	ini_append(g_ini_save_buf, &pos, "# F3 viewer / F4 editor: .com launched with file path as argument\r\n");
	ini_append_kv(g_ini_save_buf, &pos, "Viewer", g_ini_viewer);
	ini_append_kv(g_ini_save_buf, &pos, "Editor", g_ini_editor);

	if (!ini_set_location())
	{
		ini_restore_cwd();
		return;
	}
	fp = OS_CREATEHANDLE((unsigned char *)NC_INI_NAME, 0x80);
	if (((int)fp) & 0xff)
	{
		ini_restore_cwd();
		return;
	}
	(void)OS_WRITEHANDLE((unsigned char *)g_ini_save_buf, fp, pos);
	OS_CLOSEHANDLE(fp);
	ini_restore_cwd();
}

void nc_capture_startup_path(void)
{
	char path_buf[64];
	unsigned int len;
	unsigned int i;

	path_buf[0] = 0;
	OS_GETPATH(path_buf);
	len = 0;
	while (path_buf[len] != 0 && len < 63u)
		len++;
	for (i = 0; i < len; i++)
		g_nc_startup_path[i] = path_buf[i];
	g_nc_startup_path[len] = 0;
	if (len > 0 && g_nc_startup_path[len - 1u] != '/' && len < 62u)
	{
		g_nc_startup_path[len] = '/';
		g_nc_startup_path[len + 1u] = 0;
	}
}

/* --- menu overlay (no SETPG32 / panel banking) --- */

static void ui_print_cstr(const char *s)
{
	unsigned char i;

	i = 0;
	while (s[i] != 0)
	{
		putchar(s[i]);
		i++;
	}
}

static void ui_fast_print_str_width(const char *str, unsigned char width)
{
	unsigned char i;

	i = 0;
	while (str[i] != 0 && i < width)
	{
		putchar(str[i]);
		i++;
	}
}

static void ui_fast_print_str_pad(const char *str, unsigned char width)
{
	unsigned char i;

	ui_fast_print_str_width(str, width);
	for (i = 0; str[i] != 0 && i < width; i++)
		;
	while (i < width)
	{
		putchar(' ');
		i++;
	}
}

void ui_fill_chars(unsigned char x, unsigned char y, unsigned char sym, unsigned char count, unsigned char color)
{
	unsigned char i;

	if (count == 0u)
		return;
	OS_SETXY(x, y);
	OS_SETCOLOR(color);
	for (i = 0; i < count; i++)
		putchar(sym);
}

/* --- status bar, panel chrome, progress, drive (moved from main.c) --- */

#define NC_COPY_CH_BAR_FILL 219
#define NC_COPY_CH_BAR_EMPTY 176

#define NC_PANEL_COL_WIDTH 40u
#define NC_PANEL_COL_LEFT 0u
#define NC_PANEL_COL_RIGHT 40u
#define NC_PANEL_DRIVE_MAX 15u
#define NC_DRIVE_POPUP_Y 1u
#define NC_DRIVE_POPUP_INNER_W 26u
#define NC_DRIVE_ITEM_W NC_DRIVE_POPUP_INNER_W
#define NC_DRVF_NONE 0u
#define NC_DRVF_NEOGS 1u
#define NC_DRVF_ZXNET 2u
#define NC_DRVF_TRDOS 4u
#define NC_PANEL_PORT_NEOGS_GSCFG 0x0Fu
#define NC_PANEL_PORT_SL811_SEL 0xABu
#define NC_PANEL_SORT_NOTICE_FILES 50u
#define NC_SZ_1MB 1048576UL
#define NC_SZ_100MB 104857600UL

static void ui_bdbox(unsigned char xbox, unsigned char ybox, unsigned char wbox, unsigned char hbox,
					 unsigned char cbox, unsigned char character);
static void ui_draw_frame(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char color,
						  const char *title);
void r_fileop_progress_begin_title(unsigned char is_delete, const char *title);

extern unsigned char g_clock_old_minutes;
extern unsigned char g_drive_popup_x;
extern unsigned char g_menu_popup_x;

static unsigned char menu_popup_x_for(const PanelState *panel)
{
	unsigned char start;

	start = (panel == &right_panel) ? NC_PANEL_COL_RIGHT : NC_PANEL_COL_LEFT;
	return (unsigned char)(start + (NC_PANEL_COL_WIDTH - NC_MENU_POPUP_INNER_W - 2u) / 2u);
}

static unsigned char menu_item_x(void)
{
	return (unsigned char)(g_menu_popup_x + 1u);
}
extern char g_drive_labels[NC_PANEL_DRIVE_MAX][26];
extern unsigned char g_drive_letters[NC_PANEL_DRIVE_MAX];

static void ui_print_hint_bar(unsigned char y, const char *s, unsigned char pad_width)
{
	unsigned char si;
	unsigned char col;
	unsigned char hint_color;

	OS_SETXY(0, y);
	si = 0;
	col = 0;
	hint_color = NC_COLOR_HINT;
	while (s[si] != 0 && col < pad_width)
	{
		if (s[si] == '{')
			hint_color = NC_COLOR_HINT_KEY;
		else if (s[si] == '}')
			hint_color = NC_COLOR_HINT;
		else
		{
			OS_SETCOLOR(hint_color);
			putchar((unsigned char)s[si]);
			col++;
		}
		si++;
	}
	while (col < pad_width)
	{
		OS_SETCOLOR(NC_COLOR_HINT);
		putchar(' ');
		col++;
	}
}

static void ui_res_fast_print_size(unsigned long size)
{
	unsigned int total_mb;
	unsigned int whole;
	unsigned int frac;
	unsigned char d[6];
	unsigned char i;
	unsigned char lead;

	if (size >= NC_SZ_100MB)
	{
		total_mb = (unsigned int)(size / NC_SZ_1MB);
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

	if (size >= NC_SZ_1MB)
	{
		whole = (unsigned int)(size / NC_SZ_1MB);
		frac = (unsigned int)(((size % NC_SZ_1MB) * 100UL) / NC_SZ_1MB);
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

void r_ui_begin_full_redraw(void)
{
	OS_CLS(0);
}

static void ui_res_clock_draw(unsigned char force)
{
	unsigned long dos_time;
	unsigned char hours;
	unsigned char minutes;
	char buf[6];

	dos_time = OS_GETTIME();
	hours = (unsigned char)((dos_time >> 11) & 31u);
	minutes = (unsigned char)((dos_time >> 5) & 63u);
	if (!force && minutes == g_clock_old_minutes)
		return;
	g_clock_old_minutes = minutes;
	buf[0] = (char)('0' + hours / 10u);
	buf[1] = (char)('0' + hours % 10u);
	buf[2] = ':';
	buf[3] = (char)('0' + minutes / 10u);
	buf[4] = (char)('0' + minutes % 10u);
	buf[5] = 0;
	OS_SETCOLOR(NC_COLOR_HINT);
	OS_SETXY(NC_CLOCK_X, NC_CLOCK_Y);
	ui_fast_print_str_width(buf, NC_CLOCK_LEN);
}

void r_ui_clock_redraw(void)
{
	ui_res_clock_draw(1);
}

void r_ui_nc_clock_draw(unsigned char force)
{
	ui_res_clock_draw(force);
}

void r_ui_draw_status_bar(void)
{
	ui_print_hint_bar(NC_HINT_ROW, (const char *)botMenu, NC_HINT_WIDTH);
}

void r_draw_panel_background(PanelState *panel, unsigned char start_x)
{
	int i;

	draw_panel_frame(start_x, NC_COLOR_PANEL);
	ui_bdbox((unsigned char)(start_x + 1u), 3u, 38u, 18u, NC_COLOR_PANEL, ' ');

	OS_SETCOLOR(NC_COLOR_PANEL);
	OS_SETXY((unsigned char)(start_x + 2), 0);
	putchar('[');
	i = 0;
	while (panel->current_path[i] != 0)
	{
		putchar((unsigned char)panel->current_path[i]);
		i++;
	}
	putchar(']');

	OS_SETXY((unsigned char)(start_x + 1), 1);
	OS_SETCOLOR(NC_COLOR_PANEL);

	if (g_ini_panel_brief)
	{
		unsigned char hdr_used;

		ui_fast_print_str_pad("Name", NC_PANEL_BRIEF_NAME_W);
		putchar(179);
		ui_fast_print_str_pad("Size", NC_PANEL_BRIEF_SIZE_W);
		hdr_used = (unsigned char)(NC_PANEL_BRIEF_NAME_W + 1u + NC_PANEL_BRIEF_SIZE_W);
		while (hdr_used < NC_PANEL_ROW_WIDTH)
		{
			putchar(' ');
			hdr_used++;
		}
	}
	else
	{
		ui_fast_print_str_pad("Name", 18);
		putchar(179);
		ui_fast_print_str_pad("Size", 6);
		putchar(179);
		ui_fast_print_str_pad(" Date/Time", 12);
	}

	OS_SETXY((unsigned char)(start_x + 1), 2);
	OS_SETCOLOR(NC_COLOR_PANEL);
	for (i = 0; i < 38; i++)
		putchar(196);

	panel_draw_footer(panel, start_x);
	if (start_x == 40u)
		r_ui_clock_redraw();
}

static unsigned char ui_invert_attr(unsigned char attr)
{
	return (unsigned char)(((attr & 0x40) << 1) |
						   ((attr & 0x07) << 3) |
						   ((attr & 0x80) >> 1) |
						   ((attr & 0x38) >> 3));
}

void r_draw_bottom_info(const NCBottomInfo *snap)
{
	/* FILE/EMPTY cover all 80 cols (3+10+3+64); CMD writes '>' + 79. No full-line clear. */
	OS_SETCOLOR(NC_COLOR_CMDLINE);
	OS_SETXY(0, NC_STATUS_ROW);

	if (snap->mode == NC_BOTTOM_CMD)
	{
		unsigned char i;
		unsigned char len;
		unsigned char ch;
		unsigned char cursor_x;
		const unsigned char base_color = NC_COLOR_CMDLINE;
		const unsigned char cursor_color = ui_invert_attr(base_color);

		len = 0;
		while (snap->cmd_line[len] != 0 && len < 79u)
			len++;

		cursor_x = snap->cmd_cursor;
		if (cursor_x > 79u)
			cursor_x = 79u;

		OS_SETCOLOR(base_color);
		putchar('>');
		for (i = 0; i < 79u; i++)
		{
			OS_SETXY((unsigned char)(1u + i), NC_STATUS_ROW);
			if (i == cursor_x)
			{
				OS_SETCOLOR(cursor_color);
				ch = (i < len) ? (unsigned char)snap->cmd_line[i] : (unsigned char)' ';
			}
			else
			{
				OS_SETCOLOR(base_color);
				ch = (i < len) ? (unsigned char)snap->cmd_line[i] : (unsigned char)' ';
			}
			putchar(ch);
		}
		return;
	}

	if (snap->mode == NC_BOTTOM_EMPTY)
	{
		ui_fast_print_str_pad("Sz:", 3);
		ui_fast_print_str_pad("<DIR>", 10);
		ui_fast_print_str_pad("Nm:", 3);
		ui_fast_print_str_pad("", 64);
		return;
	}

	ui_fast_print_str_pad("Sz:", 3);
	if (snap->is_dir)
		ui_fast_print_str_pad("<DIR>", 10);
	else
	{
		/* ui_res_fast_print_size writes 6 chars; pad to 10 for fixed layout. */
		ui_res_fast_print_size(snap->f_size);
		putchar(' ');
		putchar(' ');
		putchar(' ');
		putchar(' ');
	}
	ui_fast_print_str_pad("Nm:", 3);
	ui_fast_print_str_pad(snap->name, 64);
}

static void ui_res_print_centered(unsigned char x, unsigned char y, unsigned char width, const char *str)
{
	unsigned char len;
	unsigned char pad;
	unsigned char i;
	const char *show;

	show = str;
	if (show == NULL)
		show = "";
	len = 0;
	while (show[len] != 0)
		len++;
	if (len > width)
	{
		show = show + len - width;
		len = width;
	}
	pad = (unsigned char)((width - len) / 2u);
	OS_SETXY(x, y);
	for (i = 0; i < width; i++)
		putchar(' ');
	if (len != 0u)
	{
		OS_SETXY((unsigned char)(x + pad), y);
		for (i = 0; i < len; i++)
			putchar(show[i]);
	}
}

void r_panel_sort_notice_show(PanelState *panel)
{
	unsigned char col_x;
	unsigned char frame_x;
	unsigned char frame_y;
	unsigned char inner_y;
	const char *msg = "Sorting catalog...";
	const unsigned char box_w = 24u;
	const unsigned char box_h = 4u;

	col_x = (panel == &right_panel) ? NC_PANEL_COL_RIGHT : NC_PANEL_COL_LEFT;
	frame_x = (unsigned char)(col_x + (NC_PANEL_COL_WIDTH - (box_w + 2u)) / 2u);
	frame_y = (unsigned char)(3u + (18u - (box_h + 1u)) / 2u);
	ui_draw_frame(frame_x, frame_y, box_w, box_h, NC_COLOR_HINT, "NC");
	OS_SETCOLOR(NC_COLOR_HINT);
	inner_y = (unsigned char)(frame_y + 1u + (box_h - 1u) / 2u);
	ui_res_print_centered((unsigned char)(frame_x + 1u), inner_y, box_w, msg);
	YIELD();
}

static void fileop_progress_layout(unsigned char with_bar)
{
	if (with_bar)
	{
		copy_prog.w = UI_DLG_INPUT_W;
		copy_prog.h = UI_DLG_INPUT_H;
		copy_prog.x = (unsigned char)((NC_SCREEN_WIDTH - copy_prog.w - 2u) / 2u);
		copy_prog.y = UI_DLG_INPUT_Y;
		copy_prog.name_y = (unsigned char)(copy_prog.y + 4u);
		copy_prog.bar_w = (unsigned char)(copy_prog.w - 10u);
		copy_prog.bar_x = (unsigned char)(copy_prog.x + 5u);
		copy_prog.bar_y = (unsigned char)(copy_prog.y + 2u);
	}
	else
	{
		copy_prog.w = UI_DLG_PROGRESS_W;
		copy_prog.h = UI_DLG_PROGRESS_H;
		copy_prog.x = (unsigned char)((NC_SCREEN_WIDTH - copy_prog.w - 2u) / 2u);
		copy_prog.y = UI_DLG_PROGRESS_Y;
		copy_prog.name_y = (unsigned char)(copy_prog.y + 2u);
	}
}

static void fileop_progress_fill_bg(unsigned char color)
{
	unsigned char row;
	unsigned char col;

	OS_SETCOLOR(color);
	for (row = 1; row < copy_prog.h; row++)
	{
		OS_SETXY((unsigned char)(copy_prog.x + 1), (unsigned char)(copy_prog.y + row));
		for (col = 0; col < copy_prog.w; col++)
			putchar(' ');
	}
}

void r_copy_progress_draw_name(const char *name)
{
	const char *show;

	if (!copy_prog.drawn)
		r_fileop_progress_begin_title(g_delete_progress, g_fileop_title);

	show = name;
	if (show == NULL)
		show = "";

	OS_SETCOLOR(g_delete_progress ? NC_COLOR_OVERWRITE_UI : NC_COLOR_COPY_UI);
	ui_res_print_centered((unsigned char)(copy_prog.x + 1u), copy_prog.name_y, copy_prog.w, show);
}

void r_fileop_progress_store_name(const char *name)
{
	const char *show;

	show = name;
	if (show == NULL)
		show = "";
	strncpy(copy_prog_current_name, show, sizeof(copy_prog_current_name) - 1u);
	copy_prog_current_name[sizeof(copy_prog_current_name) - 1u] = 0;
	copy_prog.last_pct = 255u;
	r_copy_progress_draw_name(copy_prog_current_name);
}

void r_copy_progress_draw_bar(unsigned char pct)
{
	unsigned char i;
	unsigned char filled;

	if (g_delete_progress)
		return;

	if (pct > 100)
		pct = 100;
	if (copy_prog.drawn && pct == copy_prog.last_pct)
		return;
	copy_prog.last_pct = pct;

	if (!copy_prog.drawn)
		r_fileop_progress_begin_title(g_delete_progress, g_fileop_title);

	filled = (unsigned char)(((unsigned int)copy_prog.bar_w * pct) / 100u);

	OS_SETXY(copy_prog.bar_x, copy_prog.bar_y);
	OS_SETCOLOR(NC_COLOR_COPY_UI);
	putchar('[');
	for (i = 0; i < copy_prog.bar_w; i++)
	{
		if (i < filled)
		{
			OS_SETCOLOR(NC_COLOR_COPY_BAR);
			putchar((char)NC_COPY_CH_BAR_FILL);
		}
		else
		{
			OS_SETCOLOR(NC_COLOR_COPY_UI);
			putchar((char)NC_COPY_CH_BAR_EMPTY);
		}
	}
	OS_SETCOLOR(NC_COLOR_COPY_UI);
	putchar(']');
}

static void fileop_progress_repaint(unsigned char color, const char *title, unsigned char restore_bar)
{
	unsigned char pct;

	if (!copy_prog.drawn)
		return;

	pct = 0u;
	if (restore_bar)
	{
		pct = copy_prog.last_pct;
		if (pct > 100u)
			pct = 0u;
	}

	ui_draw_frame(copy_prog.x, copy_prog.y, copy_prog.w, copy_prog.h, color, title);
	fileop_progress_fill_bg(color);
	copy_prog.last_pct = 255u;
	r_copy_progress_draw_name(copy_prog_current_name);
	if (restore_bar && !g_delete_progress)
		r_copy_progress_draw_bar(pct);
}

static void fileop_progress_open(unsigned char color, const char *title, unsigned char with_bar)
{
	fileop_progress_layout(with_bar);
	copy_prog.last_pct = 255;
	copy_prog.drawn = 0;
	ui_draw_frame(copy_prog.x, copy_prog.y, copy_prog.w, copy_prog.h, color, title);
	fileop_progress_fill_bg(color);
	copy_prog.drawn = 1;
	if (with_bar)
		r_copy_progress_draw_bar(0);
	r_fileop_progress_store_name("");
}

void r_fileop_progress_begin_title(unsigned char is_delete, const char *title)
{
	const char *show;

	show = title;
	if (show == NULL || show[0] == 0)
		show = is_delete ? "Deleting" : "Copying";
	strncpy(g_fileop_title, show, sizeof(g_fileop_title) - 1u);
	g_fileop_title[sizeof(g_fileop_title) - 1u] = 0;
	g_delete_progress = is_delete;
	fileop_progress_open(is_delete ? NC_COLOR_OVERWRITE_UI : NC_COLOR_COPY_UI, g_fileop_title, !is_delete);
}

void r_fileop_progress_begin(unsigned char is_delete)
{
	r_fileop_progress_begin_title(is_delete, is_delete ? "Deleting" : "Copying");
}

void r_fileop_progress_restore(void)
{
	fileop_progress_repaint(g_delete_progress ? NC_COLOR_OVERWRITE_UI : NC_COLOR_COPY_UI, g_fileop_title,
							g_delete_progress ? 0u : 1u);
}

static unsigned char nc_ini_drive_hidden(unsigned char letter)
{
	const char *p;
	unsigned char u;

	u = letter;
	if (u >= 'a' && u <= 'z')
		u = (unsigned char)(u - 'a' + 'A');
	p = g_ini_hide_drives;
	while (*p != 0)
	{
		unsigned char c;

		c = (unsigned char)*p;
		if (c == ',' || c == ' ' || c == '\t')
		{
			p++;
			continue;
		}
		if (c >= 'a' && c <= 'z')
			c = (unsigned char)(c - 'a' + 'A');
		if (c == u)
		{
			p++;
			if (*p == 0 || *p == ',' || *p == ' ' || *p == '\t')
				return 1;
		}
		p++;
	}
	return 0;
}

static unsigned char panel_hw_neogs_sd_present(void)
{
	return (unsigned char)(input(NC_PANEL_PORT_NEOGS_GSCFG) != 0xFFu);
}

static unsigned char panel_hw_zxnet_present(void)
{
	unsigned char v;

	v = input(NC_PANEL_PORT_SL811_SEL);
	v = (unsigned char)(v & 0xAFu);
	output(NC_PANEL_PORT_SL811_SEL, v);
	output(NC_PANEL_PORT_SL811_SEL, 0x0Du);
	v = input(NC_PANEL_PORT_SL811_SEL);
	if (v == 0u)
		return 0u;
	if ((v & 0x40u) == 0u)
		return 0u;
	return 1u;
}

typedef struct
{
	unsigned char letter;
	const char *caption;
	unsigned char filter;
} PanelDriveDef;

static const PanelDriveDef g_drive_table[] = {
	{'A', "1st Floppy", NC_DRVF_TRDOS},
	{'B', "2nd Floppy", NC_DRVF_TRDOS},
	{'C', "3rd Floppy", NC_DRVF_TRDOS},
	{'D', "4th Floppy", NC_DRVF_TRDOS},
	{'E', "IDE Master p.1", NC_DRVF_NONE},
	{'F', "IDE Master p.2", NC_DRVF_NONE},
	{'G', "IDE Master p.3", NC_DRVF_NONE},
	{'H', "IDE Master p.4", NC_DRVF_NONE},
	{'I', "IDE Slave p.1", NC_DRVF_NONE},
	{'J', "IDE Slave p.2", NC_DRVF_NONE},
	{'K', "IDE Slave p.3", NC_DRVF_NONE},
	{'L', "IDE Slave p.4", NC_DRVF_NONE},
	{'M', "SD Z-controller", NC_DRVF_NONE},
	{'N', "SD NeoGS", NC_DRVF_NEOGS},
	{'O', "USB flash zx-net", NC_DRVF_ZXNET},
};

#define NC_PANEL_DRIVE_TABLE_LEN (sizeof(g_drive_table) / sizeof(g_drive_table[0]))

static unsigned char panel_drive_chdrv_ok(unsigned char letter)
{
	return (unsigned char)(OS_CHDRV(letter) == 0u);
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

	for (i = 0; i < NC_PANEL_DRIVE_TABLE_LEN; i++)
	{
		const PanelDriveDef *def = &g_drive_table[i];

		if (def->filter == NC_DRVF_NEOGS && neogs == 0u)
			continue;
		if (def->filter == NC_DRVF_ZXNET && zxnet == 0u)
			continue;
		if ((def->filter & (NC_DRVF_TRDOS | NC_DRVF_ZXNET)) == 0u && !panel_drive_chdrv_ok(def->letter))
			continue;
		if (nc_ini_drive_hidden(def->letter))
			continue;
		g_drive_letters[g_drive_count] = def->letter;
		panel_drive_format_line(g_drive_labels[g_drive_count], def->letter, def->caption);
		g_drive_count++;
		if (g_drive_count >= NC_PANEL_DRIVE_MAX)
			break;
	}

	OS_CHDRV(saved);
	m_panel_chdir_only(saved_path);
}

static unsigned char panel_drive_popup_x_for(const PanelState *panel)
{
	unsigned char start;

	start = (panel == &right_panel) ? NC_PANEL_COL_RIGHT : NC_PANEL_COL_LEFT;
	return (unsigned char)(start + (NC_PANEL_COL_WIDTH - NC_DRIVE_POPUP_INNER_W - 2u) / 2u);
}

static unsigned char panel_drive_popup_inner_h(void)
{
	unsigned char n;

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
	y = (unsigned char)(NC_DRIVE_POPUP_Y + 1u + idx);
	menu_draw_item((unsigned char)(g_drive_popup_x + 1u), y, NC_DRIVE_ITEM_W, selected, g_drive_labels[idx], 0);
}

static void panel_drive_redraw(void)
{
	unsigned char i;
	unsigned char inner_h;

	inner_h = panel_drive_popup_inner_h();
	ui_draw_frame(g_drive_popup_x, NC_DRIVE_POPUP_Y, NC_DRIVE_POPUP_INNER_W, inner_h, NC_COLOR_MENU_NORM, "Drive");
	for (i = 0; i < g_drive_count; i++)
		panel_drive_draw_row(i, (unsigned char)(i == g_drive_sel));
}

void r_panel_drive_redraw(void)
{
	panel_drive_redraw();
}

static void panel_drive_dismiss(PanelState *panel, unsigned char redraw_panel)
{
	g_drive_active = 0;
	g_drive_panel = NULL;
	g_drive_sel = 0;
	m_panels_remap_bank_window();
	if (redraw_panel && panel != NULL)
	{
		unsigned char start_x;

		start_x = (panel == &right_panel) ? 40u : 0u;
		r_draw_panel_background(panel, start_x);
		m_draw_panel(panel, start_x, 18);
	}
	draw_bottom_info((left_panel.is_active) ? &left_panel : &right_panel);
}

static void panel_drive_msg(unsigned char letter, const char *text)
{
	unsigned char i;

	i = 0;
	nc_set.temp_path[i++] = (char)letter;
	nc_set.temp_path[i++] = ':';
	nc_set.temp_path[i++] = ' ';
	while (text[0] != 0 && i < sizeof(nc_set.temp_path) - 1u)
	{
		nc_set.temp_path[i++] = text[0];
		text++;
	}
	nc_set.temp_path[i] = 0;
	r_ui_alert_dialog("Drive error", nc_set.temp_path);
	m_panels_redraw_both();
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
	start_x = (panel == &left_panel) ? 0u : 40u;
	if (!m_read_panel_dir_at(panel, path, 0))
	{
		OS_CHDRV(saved_letter);
		m_read_panel_dir_at(panel, saved_path, 1);
		m_panel_chdir_only(saved_path);
		panel_drive_msg(letter, "cannot read");
		return 0;
	}

	m_panel_chdir_only(panel->current_path);
	m_panels_remap_bank_window();
	r_draw_panel_background(panel, start_x);
	m_draw_panel(panel, start_x, 18);
	return 0;
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

void r_panel_drive_open(PanelState *panel)
{
	unsigned char i;
	unsigned char saved;

	panel_drive_build_list(panel);
	g_drive_popup_x = panel_drive_popup_x_for(panel);
	g_drive_panel = panel;
	g_drive_active = 1;
	g_drive_sel = 0;
	saved = panel_drive_saved_letter(panel);
	for (i = 0; i < g_drive_count; i++)
	{
		if (g_drive_letters[i] == saved)
		{
			g_drive_sel = i;
			break;
		}
	}
	panel_drive_redraw();
}

unsigned char r_panel_drive_handle_key(unsigned char key)
{
	PanelState *panel;

	panel = g_drive_panel;
	if (panel == NULL)
		return 1;

	if (key == 27)
	{
		panel_drive_dismiss(panel, 1);
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
		unsigned char redraw_panel;

		redraw_panel = panel_drive_apply(panel, g_drive_letters[g_drive_sel]);
		panel_drive_dismiss(panel, redraw_panel);
		return 1;
	}
	return 1;
}

static unsigned char panel_ul_to_buf(unsigned long n, char *dst, unsigned char cap)
{
	unsigned char len;
	unsigned char out;
	unsigned char i;
	char tmp[11];

	if (cap == 0u)
		return 0;
	len = 0;
	if (n == 0UL)
	{
		dst[0] = '0';
		dst[1] = 0;
		return 1;
	}
	while (n > 0UL && len < (unsigned char)sizeof(tmp))
	{
		tmp[len++] = (char)('0' + (n % 10UL));
		n /= 10UL;
	}
	out = 0;
	for (i = len; i > 0u; i--)
	{
		if (out + 1u >= cap)
			break;
		dst[out++] = tmp[i - 1u];
	}
	dst[out] = 0;
	return out;
}

static void panel_footer_count_box(char *box, unsigned int count, unsigned char marked_active)
{
	char num[11];
	unsigned char i;
	unsigned char pos;

	pos = 0;
	box[pos++] = '[';
	panel_ul_to_buf((unsigned long)count, num, (unsigned char)sizeof(num));
	for (i = 0; num[i] != 0; i++)
		box[pos++] = num[i];
	box[pos++] = ' ';
	if (marked_active)
	{
		if (count == 1u)
		{
			box[pos++] = 'i';
			box[pos++] = 't';
			box[pos++] = 'e';
			box[pos++] = 'm';
		}
		else
		{
			box[pos++] = 'i';
			box[pos++] = 't';
			box[pos++] = 'e';
			box[pos++] = 'm';
			box[pos++] = 's';
		}
	}
	else if (count == 1u)
	{
		box[pos++] = 'f';
		box[pos++] = 'i';
		box[pos++] = 'l';
		box[pos++] = 'e';
	}
	else
	{
		box[pos++] = 'f';
		box[pos++] = 'i';
		box[pos++] = 'l';
		box[pos++] = 'e';
		box[pos++] = 's';
	}
	box[pos++] = ']';
	box[pos] = 0;
}

static void panel_footer_bytes_box(char *box, unsigned long bytes)
{
	char num[11];
	unsigned char i;
	unsigned char pos;

	pos = 0;
	box[pos++] = '[';
	panel_ul_to_buf(bytes, num, (unsigned char)sizeof(num));
	for (i = 0; num[i] != 0; i++)
		box[pos++] = num[i];
	box[pos++] = ' ';
	box[pos++] = 'b';
	box[pos++] = 'y';
	box[pos++] = 't';
	box[pos++] = 'e';
	box[pos++] = 's';
	box[pos++] = ']';
	box[pos] = 0;
}

void panel_draw_footer(PanelState *panel, unsigned char start_x)
{
	char line[NC_PANEL_ROW_WIDTH + 1u];
	char left_box[18];
	char right_box[24];
	unsigned char i;
	unsigned char left_w;
	unsigned char right_w;
	unsigned char right_start;
	unsigned char inset;
	unsigned int count_val;
	unsigned long bytes_val;
	unsigned char marked_active;

	for (i = 0; i < NC_PANEL_ROW_WIDTH; i++)
		line[i] = (char)205;
	line[NC_PANEL_ROW_WIDTH] = 0;

	marked_active = (panel->marked_count > 0u) ? 1u : 0u;
	if (marked_active)
	{
		count_val = panel->marked_count;
		bytes_val = panel->marked_bytes;
	}
	else
	{
		count_val = panel->files_only_count;
		bytes_val = panel->total_bytes;
	}

	inset = 3u;
	panel_footer_count_box(left_box, count_val, marked_active);
	left_w = (unsigned char)strlen(left_box);
	panel_footer_bytes_box(right_box, bytes_val);
	right_w = (unsigned char)strlen(right_box);

	if (inset + left_w + 2u + right_w + inset <= NC_PANEL_ROW_WIDTH)
		right_start = (unsigned char)(NC_PANEL_ROW_WIDTH - inset - right_w);
	else
		right_start = (unsigned char)(inset + left_w + 2u);
	if (right_start + right_w > NC_PANEL_ROW_WIDTH)
		right_start = (unsigned char)(NC_PANEL_ROW_WIDTH - right_w);

	for (i = 0; i < left_w; i++)
		line[inset + i] = left_box[i];
	for (i = 0; i < right_w; i++)
		line[right_start + i] = right_box[i];

	OS_SETXY((unsigned char)(start_x + 1u), 21);
	OS_SETCOLOR(marked_active ? NC_COLOR_PANEL_MARK : NC_COLOR_PANEL);
	for (i = 0; i < NC_PANEL_ROW_WIDTH; i++)
		putchar((unsigned char)line[i]);
}

static void ui_bdbox(unsigned char xbox, unsigned char ybox, unsigned char wbox, unsigned char hbox,
					 unsigned char cbox, unsigned char character)
{
	unsigned char x;
	unsigned char y;

	OS_SETCOLOR(cbox);
	for (y = 0; y < hbox; y++)
	{
		OS_SETXY(xbox, (unsigned char)(ybox + y));
		for (x = 0; x < wbox; x++)
			putchar(character);
	}
}

static void ui_draw_frame(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char color,
						  const char *title)
{
	unsigned char wcount;
	unsigned char tempx;
	unsigned char title_start;

	ui_bdbox(x, y, (unsigned char)(w + 2), (unsigned char)(h + 1), color, 32);

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
		title_start = (unsigned char)(x + (w / 2));
		if (strlen(title) < w)
			title_start -= (unsigned char)(strlen(title) / 2);
		OS_SETXY(title_start, y);
		OS_SETCOLOR(color);
		putchar('[');
		ui_print_cstr(title);
		putchar(']');
	}
}

static void ui_dlg_print_centered(unsigned char x, unsigned char y, unsigned char width, const char *str)
{
	unsigned char len;
	unsigned char pad;
	unsigned char i;
	const char *show;

	show = str;
	if (show == NULL)
		show = "";
	len = 0;
	while (show[len] != 0)
		len++;
	if (len > width)
	{
		show = show + len - width;
		len = width;
	}
	pad = (unsigned char)((width - len) / 2u);
	OS_SETXY(x, y);
	for (i = 0; i < width; i++)
		putchar(' ');
	if (len != 0u)
	{
		OS_SETXY((unsigned char)(x + pad), y);
		for (i = 0; i < len; i++)
			putchar(show[i]);
	}
}

static unsigned char show_dialog(DialogWindow *dlg, char *buffer, unsigned char max_len, unsigned char btn_mask)
{
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
	if (btn_mask & D_BTN_TO_MOVE)
	{
		if (btn_mask & D_BTN_CANCEL)
			btn_types[numButtons++] = D_RES_CANCEL;
		btn_types[numButtons++] = D_RES_TO_MOVE;
		if (btn_mask & D_BTN_OK)
			btn_types[numButtons++] = D_RES_OK;
	}
	else
	{
		if (btn_mask & D_BTN_YES)
			btn_types[numButtons++] = D_RES_YES;
		if (btn_mask & D_BTN_NO)
			btn_types[numButtons++] = D_RES_NO;
		if (btn_mask & D_BTN_OK)
			btn_types[numButtons++] = D_RES_OK;
		if (btn_mask & D_BTN_SKIP)
			btn_types[numButtons++] = D_RES_SKIP;
		if (btn_mask & D_BTN_SKIP_ALL)
			btn_types[numButtons++] = D_RES_SKIP_ALL;
		if (btn_mask & D_BTN_REPLACE_ALL)
			btn_types[numButtons++] = D_RES_REPLACE_ALL;
		if (btn_mask & D_BTN_CANCEL)
			btn_types[numButtons++] = D_RES_CANCEL;
	}

	activeBtn = 0;

	ui_draw_frame(dlg->x, dlg->y, dlg->w, dlg->h, dlg->color, dlg->title);

	if (dlg->prompt != NULL)
	{
		OS_SETCOLOR(dlg->color);
		if (buffer == NULL)
			ui_dlg_print_centered((unsigned char)(dlg->x + 1u), (unsigned char)(dlg->y + 1u), dlg->w, dlg->prompt);
		else
		{
			OS_SETXY(dlg->x + 2, dlg->y + 1);
			ui_fast_print_str_width(dlg->prompt, dlg->w - 2);
		}
	}

	for (;;)
	{
		if (buffer != NULL)
		{
			if (cursorPos < viewOffset)
				viewOffset = cursorPos;
			else if (cursorPos - viewOffset >= visibleLen)
				viewOffset = cursorPos - visibleLen + 1;

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
					OS_SETCOLOR(inputColor);

				if (printPos < cmdLen)
					putchar(buffer[printPos]);
				else
					putchar(' ');
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
						OS_SETCOLOR(dlg->color);

					{
						static const char *const btn_labels[] = {
							"[ Cancel ]", "[   OK   ]", "[  Yes   ]", "[   No   ]",
							"[  Skip  ]", "[Skip All]", "[Yes  All]", "[ to Move]"};
						unsigned char bid;

						bid = btn_types[global_idx];
						if (bid <= D_RES_TO_MOVE)
							ui_fast_print_str_width(btn_labels[bid], 10);
					}

					btnX = (unsigned char)(btnX + 11u);
				}
			}
			OS_SETCOLOR(dlg->color);
		}

		byte = OS_GETKEY();
		if (byte != 0)
		{
			switch (byte)
			{
			case 250:
				if (buffer != NULL && focusOnButtons == 1)
					focusOnButtons = 0;
				break;

			case 249:
				if (numButtons > 0 && focusOnButtons == 0)
					focusOnButtons = 1;
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
					cursorPos--;
				break;

			case 251:
				if (focusOnButtons == 1)
					activeBtn = (activeBtn + 1) % numButtons;
				else if (buffer != NULL && cursorPos < cmdLen)
					cursorPos++;
				break;

			case 0x08:
				if (focusOnButtons == 0 && buffer != NULL && cursorPos > 0 && cmdLen > 0)
				{
					for (i = cursorPos - 1; i < cmdLen; i++)
						buffer[i] = buffer[i + 1];
					cursorPos--;
					cmdLen--;
				}
				break;

			case 252:
				if (focusOnButtons == 0 && buffer != NULL && cursorPos < cmdLen && cmdLen > 0)
				{
					for (i = cursorPos; i < cmdLen; i++)
						buffer[i] = buffer[i + 1];
					cmdLen--;
				}
				break;

			case 0x0d:
				if (focusOnButtons == 1 && numButtons > 0)
					return btn_types[activeBtn];
				return (buffer != NULL) ? D_RES_OK : btn_types[activeBtn];

			case 27:
				return D_RES_CANCEL;

			case 'y':
			case 'Y':
				if (focusOnButtons == 1 && (btn_mask & D_BTN_YES))
					return D_RES_YES;
				goto dialog_type_char;
			case 'n':
			case 'N':
				if (focusOnButtons == 1 && (btn_mask & D_BTN_NO))
					return D_RES_NO;
				goto dialog_type_char;
			case 's':
			case 'S':
				if (focusOnButtons == 1 && (btn_mask & D_BTN_SKIP_ALL))
					return D_RES_SKIP_ALL;
				if (focusOnButtons == 1 && (btn_mask & D_BTN_SKIP))
					return D_RES_SKIP;
				goto dialog_type_char;
			case 'r':
			case 'R':
				if (focusOnButtons == 1 && (btn_mask & D_BTN_REPLACE_ALL))
					return D_RES_REPLACE_ALL;
				goto dialog_type_char;
			case 'c':
			case 'C':
				if (focusOnButtons == 1 && (btn_mask & D_BTN_CANCEL))
					return D_RES_CANCEL;
				goto dialog_type_char;
			case 'm':
			case 'M':
				if (focusOnButtons == 1 && (btn_mask & D_BTN_TO_MOVE))
					return D_RES_TO_MOVE;
				goto dialog_type_char;

			default:
			dialog_type_char:
				if (focusOnButtons == 0 && buffer != NULL && cmdLen < (max_len - 2) && byte >= 32)
				{
					for (i = cmdLen; i > cursorPos; i--)
						buffer[i] = buffer[i - 1];
					buffer[cursorPos] = byte;
					cursorPos++;
					cmdLen++;
					buffer[cmdLen] = 0;
				}
				break;
			}
		}
		YIELD();
	}
}

#define NC_SCREEN_WIDTH 80u

static void ui_dlg_preset(DialogWindow *dlg, unsigned char x, unsigned char y, unsigned char w, unsigned char h,
						  unsigned char color, const char *title, const char *prompt)
{
	dlg->x = x;
	dlg->y = y;
	dlg->w = w;
	dlg->h = h;
	dlg->color = color;
	dlg->title = title;
	dlg->prompt = prompt;
}

static void ui_dlg_centered(DialogWindow *dlg, unsigned char w, unsigned char h, unsigned char y,
							unsigned char color, const char *title, const char *prompt)
{
	ui_dlg_preset(dlg, (unsigned char)((NC_SCREEN_WIDTH - w - 2u) / 2u), y, w, h, color, title, prompt);
}

unsigned char r_ui_dialog_input(const char *title, const char *prompt)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_INPUT_W, UI_DLG_INPUT_H, UI_DLG_INPUT_Y, NC_COLOR_COPY_UI, title, prompt);
	return show_dialog(&dlg, nc_set.temp_path, sizeof(nc_set.temp_path), D_MASK_OK_CANCEL);
}

unsigned char r_ui_dialog_rename_input(const char *title, const char *prompt)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_INPUT_W, UI_DLG_INPUT_H, UI_DLG_INPUT_Y, NC_COLOR_COPY_UI, title, prompt);
	return show_dialog(&dlg, nc_set.temp_path, sizeof(nc_set.temp_path), D_MASK_RENAME);
}

static unsigned char r_ui_dialog_confirm(const char *title, const char *prompt, unsigned char btn_mask)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_CONFIRM_W, UI_DLG_CONFIRM_H, UI_DLG_CONFIRM_Y, NC_COLOR_OVERWRITE_UI, title,
					prompt);
	return show_dialog(&dlg, NULL, 0, btn_mask);
}

unsigned char r_ui_dialog_delete_confirm(const char *title, const char *prompt)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_PROGRESS_W, UI_DLG_PROGRESS_H, UI_DLG_PROGRESS_Y, NC_COLOR_OVERWRITE_UI, title,
					prompt);
	return show_dialog(&dlg, NULL, 0, D_MASK_DELETE);
}

void r_ui_alert_dialog(const char *title, const char *prompt)
{
	DialogWindow dlg;

	ui_dlg_preset(&dlg, UI_DLG_ALERT_X, UI_DLG_ALERT_Y, UI_DLG_CONFIRM_W, UI_DLG_ALERT_H, NC_COLOR_OVERWRITE_UI,
				  title, prompt);
	(void)show_dialog(&dlg, NULL, 0, D_BTN_OK);
}

void r_ui_error_dialog(const char *title, const char *msg)
{
	DialogWindow dlg;

	ui_dlg_centered(&dlg, UI_DLG_INPUT_W, UI_DLG_ALERT_H, UI_DLG_INPUT_Y, NC_COLOR_OVERWRITE_UI, title, msg);
	(void)show_dialog(&dlg, NULL, 0, D_BTN_OK);
}

/* BDOS: residentPg must already be mapped at C000. */
unsigned char r_copy_dest_exists(const char *path)
{
	FILE *h;
	unsigned char exists;

	h = OS_OPENHANDLE((unsigned char *)path, 0x80);
	if (((int)h) & 0xff)
		exists = 0;
	else
	{
		OS_CLOSEHANDLE(h);
		exists = 1;
	}
	return exists;
}

unsigned char r_copy_dir_exists(const char *path)
{
	FILINFO finfo;

	if ((unsigned char)OS_GETFILINFO((unsigned char *)path, &finfo) != 0u)
		return 0;
	return (unsigned char)((finfo.fattrib & 0x10) ? 1u : 0u);
}

unsigned char r_copy_overwrite_resolve(unsigned char exists, const char *dialog_msg)
{
	unsigned char res;

	if (!exists)
		return NC_COPY_FILE_OK;
	if (g_copy_overwrite_mode == NC_COPY_OW_SKIP_ALL)
		return NC_COPY_FILE_SKIP;
	if (g_copy_overwrite_mode == NC_COPY_OW_REPLACE_ALL)
		return NC_COPY_FILE_OK;
	if (g_copy_overwrite_mode == NC_COPY_OW_ABORT)
		return NC_COPY_FILE_ABORT;

	res = r_ui_dialog_confirm(g_move_active ? "Move" : "Copy", dialog_msg, D_MASK_OVERWRITE);
	r_fileop_progress_restore();

	switch (res)
	{
	case D_RES_YES:
		return NC_COPY_FILE_OK;
	case D_RES_NO:
	case D_RES_SKIP:
		return NC_COPY_FILE_SKIP;
	case D_RES_SKIP_ALL:
		g_copy_overwrite_mode = NC_COPY_OW_SKIP_ALL;
		return NC_COPY_FILE_SKIP;
	case D_RES_REPLACE_ALL:
		g_copy_overwrite_mode = NC_COPY_OW_REPLACE_ALL;
		return NC_COPY_FILE_OK;
	case D_RES_CANCEL:
	default:
		g_copy_overwrite_mode = NC_COPY_OW_ABORT;
		return NC_COPY_FILE_ABORT;
	}
}

void menu_draw_item(unsigned char x0, unsigned char y, unsigned char width, unsigned char selected,
					const char *label, unsigned char current)
{
	unsigned char fill_color;

	fill_color = selected ? NC_COLOR_MENU_HILITE : NC_COLOR_MENU_NORM;
	ui_fill_chars(x0, y, ' ', width, fill_color);
	OS_SETXY((unsigned char)(x0 + 1), y);
	ui_fast_print_str_pad(label, (unsigned char)(width - 2));
	if (current)
		putchar('*');
}

static void menu_draw_files_row(PanelState *active_p, unsigned char idx, unsigned char cursor_on)
{
	unsigned char y;

	y = (unsigned char)(NC_MENU_POPUP_Y + 1u + idx);
	switch (idx)
	{
	case NC_MFI_NAME:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "Name",
					   (unsigned char)(active_p->sort_mode == NC_PANEL_SORT_NAME));
		break;
	case NC_MFI_EXT:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "Extension",
					   (unsigned char)(active_p->sort_mode == NC_PANEL_SORT_EXT));
		break;
	case NC_MFI_SIZE:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "Size",
					   (unsigned char)(active_p->sort_mode == NC_PANEL_SORT_SIZE));
		break;
	case NC_MFI_TIME:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "Time",
					   (unsigned char)(active_p->sort_mode == NC_PANEL_SORT_TIME));
		break;
	case NC_MFI_AZ:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "A-Z",
					   (unsigned char)(active_p->sort_desc == 0));
		break;
	case NC_MFI_ZA:
		menu_draw_item(menu_item_x(), y, NC_MENU_POPUP_INNER_W, cursor_on, "Z-A",
					   (unsigned char)(active_p->sort_desc != 0));
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
	}
}

static void menu_files_open(PanelState *active_p)
{
	unsigned char i;

	ui_draw_frame(g_menu_popup_x, NC_MENU_POPUP_Y, NC_MENU_POPUP_INNER_W,
				  (unsigned char)(NC_MENU_FILES_ITEMS + 1u), NC_COLOR_MENU_NORM, "Files");
	for (i = 0; i < NC_MENU_FILES_ITEMS; i++)
		menu_draw_files_row(active_p, i, (unsigned char)(i == g_menu_sel));
}

static void menu_top_open(void)
{
	ui_draw_frame(g_menu_popup_x, NC_MENU_POPUP_Y, NC_MENU_POPUP_INNER_W, 2u, NC_COLOR_MENU_NORM, "Menu");
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

static void menu_redraw_sort_rows(PanelState *active_p, unsigned char cursor_idx)
{
	menu_draw_files_row(active_p, NC_MFI_NAME, (unsigned char)(cursor_idx == NC_MFI_NAME));
	menu_draw_files_row(active_p, NC_MFI_EXT, (unsigned char)(cursor_idx == NC_MFI_EXT));
	menu_draw_files_row(active_p, NC_MFI_SIZE, (unsigned char)(cursor_idx == NC_MFI_SIZE));
	menu_draw_files_row(active_p, NC_MFI_TIME, (unsigned char)(cursor_idx == NC_MFI_TIME));
}

static void menu_redraw_sort_dir_rows(PanelState *active_p, unsigned char cursor_idx)
{
	menu_draw_files_row(active_p, NC_MFI_AZ, (unsigned char)(cursor_idx == NC_MFI_AZ));
	menu_draw_files_row(active_p, NC_MFI_ZA, (unsigned char)(cursor_idx == NC_MFI_ZA));
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
	if (idx <= NC_MFI_TIME)
	{
		active_p->sort_mode = menu_cycle_val(active_p->sort_mode, 4u, delta);
		menu_redraw_sort_rows(active_p, idx);
		return;
	}
	if (idx == NC_MFI_AZ || idx == NC_MFI_ZA)
	{
		active_p->sort_desc = menu_cycle_val(active_p->sort_desc, 2u, delta);
		menu_redraw_sort_dir_rows(active_p, idx);
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
		nc_ini_save();
	}
}

void draw_menu_overlay(void)
{
	if (!g_menu_active || g_menu_panel == NULL)
		return;

	if (g_menu_level == NC_MENU_LEVEL_TOP)
		menu_top_open();
	else
		menu_files_open(g_menu_panel);
}

void menu_open(void)
{
	g_menu_panel = (left_panel.is_active) ? &left_panel : &right_panel;
	g_menu_popup_x = menu_popup_x_for(g_menu_panel);
	g_menu_active = 1;
	g_menu_level = NC_MENU_LEVEL_TOP;
	g_menu_sel = 0;
	draw_menu_overlay();
}

unsigned char menu_handle_key(unsigned char key)
{
	if (g_menu_panel == NULL)
		g_menu_panel = (left_panel.is_active) ? &left_panel : &right_panel;

	if (key == 27)
	{
		menu_close_and_redraw();
		return 1;
	}

	if (g_menu_level == NC_MENU_LEVEL_TOP)
	{
		if (key == 13)
		{
			g_menu_level = NC_MENU_LEVEL_FILES;
			g_menu_sel = g_menu_panel->sort_mode;
			if (g_menu_sel > NC_MFI_TIME)
				g_menu_sel = NC_MFI_NAME;
			menu_files_open(g_menu_panel);
		}
		return 1;
	}

	if (key == 250)
	{
		if (g_menu_sel > 0)
			menu_sel_move(g_menu_panel, (unsigned char)(g_menu_sel - 1u));
		return 1;
	}
	if (key == 249)
	{
		if (g_menu_sel < NC_MENU_FILES_ITEMS - 1u)
			menu_sel_move(g_menu_panel, (unsigned char)(g_menu_sel + 1u));
		return 1;
	}
	if (key == 248)
	{
		menu_adjust_item(g_menu_panel, -1);
		return 1;
	}
	if (key == 251)
	{
		menu_adjust_item(g_menu_panel, 1);
		return 1;
	}
	if (key == 13)
	{
		menu_apply_choice(g_menu_sel);
		return 1;
	}

	return 1;
}

unsigned char panel_drive_saved_letter(const PanelState *panel)
{
	if (panel->current_path[0] >= 'A' && panel->current_path[0] <= 'Z')
		return (unsigned char)panel->current_path[0];
	if (panel->current_path[0] >= 'a' && panel->current_path[0] <= 'z')
		return (unsigned char)(panel->current_path[0] - 'a' + 'A');
	return 'M';
}

void panel_drive_format_line(char *buf, unsigned char letter, const char *cap)
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

