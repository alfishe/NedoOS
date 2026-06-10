#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "nc_inc.h"
#include "nc_plug.h"

/*
 * Resident code at C000 (window_3 / residentPg).
 * Callable while panel pages are mapped on 0xC000; uses globals in 0100-BFFF only.
 */

unsigned char getFreeMem(void)
{
	unsigned char freeMem = 0;
	unsigned char counter;

	for (counter = 0; counter < set.totalMem; counter++)
	{
		unsigned char owner;

		owner = OS_GETPAGEOWNER(~counter);
		if (owner == 0)
			freeMem++;
	}
	return (unsigned char)(freeMem - 8u);
}

void init(void)
{
	main_pg.l = OS_GETMAINPAGES();
	residentPg = main_pg.pgs.window_3;
	set.totalMem = 255;
	set.freeMem = getFreeMem();
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
	right_panel.current_path[0] = 0;

	g_menu_active = 0;
	g_menu_level = NC_MENU_LEVEL_TOP;
	g_menu_sel = 0;
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

void nc_capture_startup_path(void)
{
	char path_buf[64];
	unsigned int len;
	unsigned int i;

	path_buf[0] = 0;
	OS_GETPATH((unsigned int)path_buf);
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

/* --- status bar, clock, menu overlay (no SETPG32 / panel banking) --- */

#define UI_BLACK 0
#define UI_CYAN 5
#define UI_BR_BOTH 0xC0
#define UI_MAKE_COLOR(bright, paper, ink) ((unsigned char)((bright) | ((paper) << 3) | (ink)))
#define UI_COLOR_STATUS_BAR UI_MAKE_COLOR(UI_BR_BOTH, UI_CYAN, UI_BLACK)
#define UI_COLOR_MENU_NORM UI_COLOR_STATUS_BAR
#define UI_COLOR_MENU_HILITE UI_MAKE_COLOR(UI_BR_BOTH, UI_BLACK, UI_CYAN)

static unsigned char g_clock_old_minutes = 255u;

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

void ui_put_char_at(unsigned char x, unsigned char y, unsigned char sym)
{
	OS_SETXY(x, y);
	putchar(sym);
}

void ui_put_char_color(unsigned char x, unsigned char y, unsigned char sym, unsigned char color)
{
	OS_SETXY(x, y);
	OS_SETCOLOR(color);
	putchar(sym);
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

#define UI_BLUE 1
#define UI_WHITE 7
#define UI_COLOR_PANEL_MAIN UI_MAKE_COLOR(UI_BR_BOTH, UI_BLUE, UI_WHITE)

#define NC_SZ_1MB 1048576UL
#define NC_SZ_100MB 104857600UL

void panel_fmt_size(char *dst, unsigned long size, unsigned char is_dir)
{
	unsigned char out[6];
	unsigned int total_mb;
	unsigned int whole;
	unsigned int frac;
	unsigned char d[6];
	unsigned char i;
	unsigned char lead;
	unsigned char n;

	if (is_dir)
	{
		dst[0] = ' ';
		dst[1] = ' ';
		dst[2] = '<';
		dst[3] = 'D';
		dst[4] = 'I';
		dst[5] = 'R';
		return;
	}

	n = 0;
	if (size >= NC_SZ_100MB)
	{
		total_mb = (unsigned int)(size / NC_SZ_1MB);
		whole = total_mb / 1024u;
		frac = (total_mb % 1024u) * 100u / 1024u;
		out[n++] = (unsigned char)('0' + whole);
		out[n++] = '.';
		out[n++] = (unsigned char)('0' + frac / 10u);
		out[n++] = (unsigned char)('0' + frac % 10u);
		out[n++] = 'G';
	}
	else if (size >= NC_SZ_1MB)
	{
		whole = (unsigned int)(size / NC_SZ_1MB);
		frac = (unsigned int)(((size % NC_SZ_1MB) * 100UL) / NC_SZ_1MB);
		if (whole >= 10u)
			out[n++] = (unsigned char)('0' + whole / 10u);
		else
			out[n++] = ' ';
		out[n++] = (unsigned char)('0' + whole % 10u);
		out[n++] = '.';
		out[n++] = (unsigned char)('0' + frac / 10u);
		out[n++] = (unsigned char)('0' + frac % 10u);
		out[n++] = 'M';
	}
	else
	{
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
				out[n++] = (unsigned char)('0' + d[i]);
				lead = 1;
			}
			else
				out[n++] = ' ';
		}
		out[n++] = (unsigned char)('0' + d[5]);
	}
	while (n < 6u)
		out[n++] = ' ';
	for (i = 0; i < 6u; i++)
		dst[i] = out[i];
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

void panel_draw_footer(PanelState *panel, unsigned char start_x)
{
	char line[NC_PANEL_ROW_WIDTH + 1u];
	char num[11];
	char left_box[18];
	char right_box[24];
	unsigned char i;
	unsigned char pos;
	unsigned char left_w;
	unsigned char right_w;
	unsigned char right_start;
	unsigned char inset;

	for (i = 0; i < NC_PANEL_ROW_WIDTH; i++)
		line[i] = (char)205;
	line[NC_PANEL_ROW_WIDTH] = 0;

	inset = 3u;
	pos = 0;
	left_box[pos++] = '[';
	panel_ul_to_buf((unsigned long)panel->files_only_count, num, (unsigned char)sizeof(num));
	for (i = 0; num[i] != 0; i++)
		left_box[pos++] = num[i];
	if (panel->files_only_count == 1u)
	{
		left_box[pos++] = ' ';
		left_box[pos++] = 'f';
		left_box[pos++] = 'i';
		left_box[pos++] = 'l';
		left_box[pos++] = 'e';
	}
	else
	{
		left_box[pos++] = ' ';
		left_box[pos++] = 'f';
		left_box[pos++] = 'i';
		left_box[pos++] = 'l';
		left_box[pos++] = 'e';
		left_box[pos++] = 's';
	}
	left_box[pos++] = ']';
	left_box[pos] = 0;
	left_w = pos;

	pos = 0;
	right_box[pos++] = '[';
	panel_ul_to_buf(panel->total_bytes, num, (unsigned char)sizeof(num));
	for (i = 0; num[i] != 0; i++)
		right_box[pos++] = num[i];
	right_box[pos++] = ' ';
	right_box[pos++] = 'b';
	right_box[pos++] = 'y';
	right_box[pos++] = 't';
	right_box[pos++] = 'e';
	right_box[pos++] = 's';
	right_box[pos++] = ']';
	right_box[pos] = 0;
	right_w = pos;

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
	OS_SETCOLOR(UI_COLOR_PANEL_MAIN);
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

unsigned char show_dialog(DialogWindow *dlg, char *buffer, unsigned char max_len, unsigned char btn_mask)
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
							"[  Skip  ]", "[Skip All]", "[Yes  All]"};
						unsigned char bid;

						bid = btn_types[global_idx];
						if (bid <= D_RES_REPLACE_ALL)
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

static void nc_clock_format(unsigned char hours, unsigned char minutes, char *buf)
{
	buf[0] = '[';
	buf[1] = (char)('0' + hours / 10u);
	buf[2] = (char)('0' + hours % 10u);
	buf[3] = ':';
	buf[4] = (char)('0' + minutes / 10u);
	buf[5] = (char)('0' + minutes % 10u);
	buf[6] = ']';
	buf[7] = 0;
}

void nc_clock_draw(unsigned char force)
{
	unsigned long dos_time;
	unsigned char hours;
	unsigned char minutes;
	char buf[8];

	dos_time = OS_GETTIME();
	hours = (unsigned char)((dos_time >> 11) & 31u);
	minutes = (unsigned char)((dos_time >> 5) & 63u);

	if (!force && minutes == g_clock_old_minutes)
		return;

	g_clock_old_minutes = minutes;
	nc_clock_format(hours, minutes, buf);
	OS_SETCOLOR(UI_COLOR_STATUS_BAR);
	OS_SETXY(NC_CLOCK_X, NC_CLOCK_Y);
	ui_print_cstr(buf);
}

void draw_status_bar(void)
{
	OS_SETCOLOR(UI_COLOR_STATUS_BAR);
	OS_SETXY(0, 23);
	ui_fast_print_str_pad((const char *)botMenu, 80);
	nc_clock_draw(1);
}

void menu_draw_item(unsigned char x0, unsigned char y, unsigned char width, unsigned char selected,
					const char *label, unsigned char current)
{
	unsigned char fill_color;

	fill_color = selected ? UI_COLOR_MENU_HILITE : UI_COLOR_MENU_NORM;
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
menu_draw_item(NC_MENU_ITEM_X, y, NC_MENU_POPUP_INNER_W, cursor_on, "Name",
					   (unsigned char)(active_p->sort_mode == NC_PANEL_SORT_NAME));
		break;
	case NC_MFI_EXT:
menu_draw_item(NC_MENU_ITEM_X, y, NC_MENU_POPUP_INNER_W, cursor_on, "Extension",
					   (unsigned char)(active_p->sort_mode == NC_PANEL_SORT_EXT));
		break;
	case NC_MFI_SIZE:
menu_draw_item(NC_MENU_ITEM_X, y, NC_MENU_POPUP_INNER_W, cursor_on, "Size",
					   (unsigned char)(active_p->sort_mode == NC_PANEL_SORT_SIZE));
		break;
	case NC_MFI_TIME:
menu_draw_item(NC_MENU_ITEM_X, y, NC_MENU_POPUP_INNER_W, cursor_on, "Time",
					   (unsigned char)(active_p->sort_mode == NC_PANEL_SORT_TIME));
		break;
	case NC_MFI_AZ:
menu_draw_item(NC_MENU_ITEM_X, y, NC_MENU_POPUP_INNER_W, cursor_on, "A-Z",
					   (unsigned char)(active_p->sort_desc == 0));
		break;
	case NC_MFI_ZA:
menu_draw_item(NC_MENU_ITEM_X, y, NC_MENU_POPUP_INNER_W, cursor_on, "Z-A",
					   (unsigned char)(active_p->sort_desc != 0));
		break;
	case NC_MFI_LFN_SORT:
menu_draw_item(NC_MENU_ITEM_X, y, NC_MENU_POPUP_INNER_W, cursor_on, "LFN sort", active_p->sort_lfn);
		break;
	case NC_MFI_READ_ON_FOCUS:
menu_draw_item(NC_MENU_ITEM_X, y, NC_MENU_POPUP_INNER_W, cursor_on, "Read on focus", g_ini_read_on_focus);
		break;
	}
}

static void menu_files_open(PanelState *active_p)
{
	unsigned char i;

	ui_draw_frame(NC_MENU_POPUP_X, NC_MENU_POPUP_Y, NC_MENU_POPUP_INNER_W,
				  (unsigned char)(NC_MENU_FILES_ITEMS + 1u), UI_COLOR_MENU_NORM, "Files");
	for (i = 0; i < NC_MENU_FILES_ITEMS; i++)
		menu_draw_files_row(active_p, i, (unsigned char)(i == g_menu_sel));
}

static void menu_top_open(void)
{
	ui_draw_frame(NC_MENU_POPUP_X, NC_MENU_POPUP_Y, NC_MENU_POPUP_INNER_W, 2u, UI_COLOR_MENU_NORM, "Menu");
menu_draw_item(NC_MENU_ITEM_X, (unsigned char)(NC_MENU_POPUP_Y + 1u), NC_MENU_POPUP_INNER_W,
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

void draw_menu_overlay(void)
{
	PanelState *active_p;

	if (!g_menu_active)
		return;

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	if (g_menu_level == NC_MENU_LEVEL_TOP)
		menu_top_open();
	else
		menu_files_open(active_p);
}

void menu_open(void)
{
	g_menu_active = 1;
	g_menu_level = NC_MENU_LEVEL_TOP;
	g_menu_sel = 0;
draw_menu_overlay();
}

unsigned char menu_handle_key(unsigned char key)
{
	PanelState *active_p;

	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

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
			g_menu_sel = active_p->sort_mode;
			if (g_menu_sel > NC_MFI_TIME)
				g_menu_sel = NC_MFI_NAME;
			menu_files_open(active_p);
		}
		return 1;
	}

	if (key == 250 || key == 248)
	{
		if (g_menu_sel > 0)
			menu_sel_move(active_p, (unsigned char)(g_menu_sel - 1u));
		return 1;
	}
	if (key == 249 || key == 251)
	{
		if (g_menu_sel < NC_MENU_FILES_ITEMS - 1u)
			menu_sel_move(active_p, (unsigned char)(g_menu_sel + 1u));
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
