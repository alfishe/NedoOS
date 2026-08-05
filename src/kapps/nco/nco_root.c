#include "nc_inc.h"
#include "nc_plug.h"
#include "mb_req.h"
#include "mb_plug.h"

#define SHELL_LOAD_TAIL (0x10000u - 0xC100u)
#define SHELL_LOAD_FULL 0x4000u

unsigned char panel_request_unique_page(unsigned char *page_out)
{
	unsigned int page;
	unsigned char attempt;

	for (attempt = 0u; attempt < 64u; attempt++)
	{
		page = OS_NEWPAGE();
		if (page > 255u)
			return 0u;
		if (g_panel_page_used[(unsigned char)page])
		{
			OS_DELPAGE((unsigned char)page);
			continue;
		}
		g_panel_page_used[(unsigned char)page] = 1u;
		*page_out = (unsigned char)page;
		return 1u;
	}
	return 0u;
}

void panel_fmt_size(char *dst, unsigned long size, unsigned char is_dir)
{
	unsigned char d[6];
	unsigned char i;
	unsigned char lead;

	if (is_dir)
	{
		dst[0] = ' '; dst[1] = ' '; dst[2] = '<';
		dst[3] = 'D'; dst[4] = 'I'; dst[5] = 'R';
		return;
	}
	for (i = 6u; i > 0u; i--)
	{
		d[i - 1u] = (unsigned char)(size % 10UL);
		size /= 10UL;
	}
	lead = 0u;
	for (i = 0u; i < 6u; i++)
	{
		if (d[i] != 0u || lead || i == 5u) { dst[i] = (char)('0' + d[i]); lead = 1u; }
		else dst[i] = ' ';
	}
}

void panel_fmt_size_brief(char *dst, unsigned long size, unsigned char is_dir)
{
	unsigned char i;
	unsigned char digits[NC_PANEL_BRIEF_SIZE_W];
	unsigned char n = 0u;
	if (is_dir)
	{
		for (i = 0u; i < NC_PANEL_BRIEF_SIZE_W; i++) dst[i] = ' ';
		dst[3] = '<'; dst[4] = 'D'; dst[5] = 'I'; dst[6] = 'R'; dst[7] = '>';
		return;
	}
	if (size > 99999999UL) size = 99999999UL;
	do { digits[n++] = (unsigned char)(size % 10UL); size /= 10UL; } while (size != 0UL && n < NC_PANEL_BRIEF_SIZE_W);
	for (i = 0u; i < NC_PANEL_BRIEF_SIZE_W; i++) dst[i] = ' ';
	for (i = 0u; i < n; i++) dst[NC_PANEL_BRIEF_SIZE_W - 1u - i] = (char)('0' + digits[i]);
}

void draw_panel_frame(unsigned char start_x, unsigned char color)
{
	unsigned char q;
	unsigned char width = 39u;

	OS_SETCOLOR(color);
	OS_SETXY(start_x, 0u);
	putchar(201);
	for (q = 1u; q < width; q++)
		putchar(205);
	putchar(187);

	for (q = 1u; q <= 21u; q++)
	{
		OS_SETXY(start_x, q);
		putchar(186);
		OS_SETXY((unsigned char)(start_x + width), q);
		putchar(186);
	}

	OS_SETXY(start_x, 21u);
	putchar(200);
	for (q = 1u; q < width; q++)
		putchar(205);
	putchar(188);
}

void draw_panel_background(PanelState *panel, unsigned char start_x)
{
	mb_draw_panel_background(panel, start_x);
}

void draw_panel_footer(PanelState *panel, unsigned char start_x)
{
	mb_panel_draw_footer(panel, start_x);
}

void draw_bottom_info(PanelState *panel)
{
	(void)panel;
	if (g_cmd_active)
		m_cmd_fill_bottom_snap();
	else
		mb_fill_bottom_snap(&g_bottom_snap);
	mb_draw_bottom_info(&g_bottom_snap);
}

void menu_close_and_redraw(void)
{
	g_menu_active = 0u;
	m_redraw_panels_full();
}

void menu_apply_choice(unsigned char choice)
{
	g_menu_active = 0u;
	g_menu_level = NC_MENU_LEVEL_TOP;
	g_menu_sel = 0u;
	g_menu_panel = NULL;
	mb_panel_menu_apply(choice);
	if (choice == NC_MFI_CMD_FLAG)
		mb_nc_ini_save();
	m_redraw_panels_full();
}

void m_run_restore_ui(PanelState *panel)
{
	m_panel_chdir_only(panel->current_path);
	mb_panels_remap_bank_window();
	m_redraw_panels_full();
}

void m_run_save_cwd(void)
{
	OS_GETPATH(g_run_saved_cwd);
}

void m_run_restore_cwd(void)
{
	if (g_run_saved_cwd[0] != 0)
		(void)OS_CHDIR((unsigned char *)g_run_saved_cwd);
}

void m_run_restore_session_bank(void)
{
	OS_SETPG8000(g_bankPg[0]);
}

unsigned char m_run_resident_page(void)
{
	return residentPg;
}

PanelState *m_run_active_panel(void)
{
	return left_panel.is_active ? &left_panel : &right_panel;
}

void m_run_build_cmdline(unsigned char with_cmd_flags, const char *handler, const char *arg)
{
	unsigned int n;
	const char *prefix;

	strncpy(g_run_inner, handler, sizeof(g_run_inner) - 1u);
	g_run_inner[sizeof(g_run_inner) - 1u] = 0;
	if (arg != NULL && arg[0] != 0)
	{
		n = strlen(g_run_inner);
		if (n + 1u < sizeof(g_run_inner))
		{
			g_run_inner[n++] = ' ';
			g_run_inner[n] = 0;
			strncat(g_run_inner, arg, sizeof(g_run_inner) - n - 1u);
			g_run_inner[sizeof(g_run_inner) - 1u] = 0;
		}
	}
	if (with_cmd_flags && g_ini_cmd_flag == NC_CMD_FLAG_K)
		prefix = g_ui_term_cmd_k;
	else if (with_cmd_flags && g_ini_cmd_flag == NC_CMD_FLAG_P)
		prefix = g_ui_term_cmd_p;
	else
		prefix = g_ui_term_cmd;
	strncpy(g_run_cmdline, prefix, sizeof(g_run_cmdline) - 1u);
	g_run_cmdline[sizeof(g_run_cmdline) - 1u] = 0;
	n = strlen(g_run_cmdline);
	strncat(g_run_cmdline, g_run_inner, sizeof(g_run_cmdline) - n - 1u);
	g_run_cmdline[sizeof(g_run_cmdline) - 1u] = 0;
}

static unsigned char run_shell_loadpage(unsigned char page, unsigned char *addr, unsigned int max_sz, FILE *fp,
										unsigned char required)
{
	unsigned int n;

	OS_SETPGC000(page);
	n = OS_READHANDLE(addr, fp, max_sz);
	if (required)
		return (n > 0u) ? 1u : 0u;
	return 1u;
}

static unsigned char run_readfile_pages(const union APP_PAGES *pg, FILE *fp)
{
	if (!run_shell_loadpage(pg->pgs.window_0, (unsigned char *)0xC100, SHELL_LOAD_TAIL, fp, 1))
		return 0u;
	if (!run_shell_loadpage(pg->pgs.window_1, (unsigned char *)0xC000, SHELL_LOAD_FULL, fp, 0))
		return 0u;
	if (!run_shell_loadpage(pg->pgs.window_2, (unsigned char *)0xC000, SHELL_LOAD_FULL, fp, 0))
		return 0u;
	if (!run_shell_loadpage(pg->pgs.window_3, (unsigned char *)0xC000, SHELL_LOAD_FULL, fp, 0))
		return 0u;
	return 1u;
}

static unsigned char run_bin_direct(PanelState *panel, const char *exe, const char *cmdline)
{
	unsigned char savedResidentPg;
	unsigned char childId;
	union APP_PAGES app_pg;
	union APP_PAGES main_pg;
	FILE *fp;
	unsigned int cmdLen;

	if (exe == NULL || exe[0] == 0 || cmdline == NULL)
		return 0u;
	if (!m_panel_chdir_only(panel->current_path))
		return 0u;

	m_run_save_cwd();
	OS_SETSYSDRV();
	fp = OS_OPENHANDLE((unsigned char *)exe, 0x80);
	if (((int)fp) & 0xff)
	{
		printf("Cannot open: %s\r\n", exe);
		m_run_restore_cwd();
		return 0u;
	}
	if (!m_panel_chdir_only(panel->current_path))
	{
		OS_CLOSEHANDLE(fp);
		m_run_restore_cwd();
		return 0u;
	}

	main_pg.l = OS_GETMAINPAGES();
	savedResidentPg = main_pg.pgs.window_3;
	OS_SETPGC000(m_run_resident_page());

	OS_NEWAPP((unsigned int)&app_pg);
	if (app_pg.pgs.error != 0u)
	{
		OS_CLOSEHANDLE(fp);
		OS_SETPGC000(savedResidentPg);
		puts("No free app slot.\r\n");
		m_run_restore_cwd();
		return 0u;
	}
	childId = app_pg.pgs.pId;
	app_pg.l = OS_GETAPPMAINPAGES(childId);

	OS_SETPGC000(app_pg.pgs.window_0);
	cmdLen = strlen(cmdline) + 1u;
	memcpy((unsigned char *)(0xC080), cmdline, cmdLen);

	if (!run_readfile_pages(&app_pg, fp))
	{
		OS_CLOSEHANDLE(fp);
		if (childId != 0u)
			OS_DROPAPP(childId);
		OS_SETPGC000(savedResidentPg);
		printf("Load failed: %s\r\n", exe);
		m_run_restore_cwd();
		return 0u;
	}

	OS_CLOSEHANDLE(fp);
	OS_SETPGC000(savedResidentPg);
	OS_RUNAPP(childId);
	(void)OS_WAITPID(childId);
	m_run_restore_session_bank();
	m_run_restore_cwd();
	return 1u;
}

static unsigned char run_cmd_direct(PanelState *panel, const char *handler, const char *arg,
									  unsigned char with_cmd_flags)
{
	m_run_build_cmdline(with_cmd_flags, handler, arg);
	return run_bin_direct(panel, g_ui_term_com, g_run_cmdline);
}

static unsigned int run_panel_phys(PanelState *p, unsigned int vis)
{
	unsigned char *b;
	OS_SETPGC000(p->bank_ids[PANEL_META_PAGE]);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	return (unsigned int)b[PANEL_META_OFF_IDX + vis * 2u] |
		((unsigned int)b[PANEL_META_OFF_IDX + vis * 2u + 1u] << 8);
}

static unsigned char run_panel_kind(PanelState *p, unsigned int phys)
{
	unsigned char *b;
	OS_SETPGC000(p->bank_ids[PANEL_META_PAGE]);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	return b[PANEL_META_OFF_KIND + phys];
}

static char *run_entry_name(const fileInfo *fi)
{
	if (fi->lfname[0] != 0) return (char *)fi->lfname;
	return (char *)fi->fname;
}

static unsigned char run_get_file(PanelState *panel, unsigned char *is_dir_out)
{
	unsigned int phys, off;
	fileInfo *fi;

	if (panel->file_count == 0u)
		return 0u;
	if (!m_panel_chdir_only(panel->current_path))
		return 0u;
	phys = run_panel_phys(panel, panel->cursor_idx);
	OS_SETPGC000(panel->bank_ids[(unsigned char)(phys / FILES_PER_PAGE)]);
	off = phys % FILES_PER_PAGE;
	fi = &((fileInfo *)BANK_WINDOW_ADDRESS)[off];
	if (fi->fattrib & 0x10)
	{
		*is_dir_out = 1u;
		return 1u;
	}
	*is_dir_out = 0u;
	if (fi->fname[0] != 0)
		strcpy(g_run_name, (char *)fi->fname);
	else
		strcpy(g_run_name, run_entry_name(fi));
	return 1u;
}

static int run_ext_cmp(const char *a, const char *b)
{
	unsigned char i, ca, cb;
	for (i = 0u; i < 63u; i++)
	{
		ca = (unsigned char)((a[i] >= 'a' && a[i] <= 'z') ? a[i] - ('a' - 'A') : a[i]);
		cb = (unsigned char)((b[i] >= 'a' && b[i] <= 'z') ? b[i] - ('a' - 'A') : b[i]);
		if (ca != cb) return (int)ca - (int)cb;
		if (a[i] == 0) return 0;
	}
	return 0;
}

static unsigned char run_blocked(PanelState *panel)
{
	unsigned int phys;
	if (panel->file_count == 0u)
		return 1u;
	phys = run_panel_phys(panel, panel->cursor_idx);
	return (unsigned char)(run_panel_kind(panel, phys) == PANEL_KIND_DOTDOT);
}

void m_run_action_view(PanelState *panel)
{
	unsigned char is_dir;
	if (run_blocked(panel))
		return;
	if (!run_get_file(panel, &is_dir) || is_dir)
		return;
	(void)run_cmd_direct(panel, g_ini_viewer, g_run_name, 0u);
	m_run_restore_ui(panel);
}

void m_run_action_edit(PanelState *panel)
{
	unsigned char is_dir;
	if (run_blocked(panel))
		return;
	if (!run_get_file(panel, &is_dir) || is_dir)
		return;
	(void)run_cmd_direct(panel, g_ini_editor, g_run_name, 0u);
	m_run_restore_ui(panel);
}

void m_run_action_selected(PanelState *panel)
{
	const char *ext;
	unsigned char is_dir;

	if (!run_get_file(panel, &is_dir) || is_dir)
		return;
	m_panel_chdir_only(panel->current_path);
	ext = strrchr(g_run_name, '.');
	if (ext == NULL)
	{
		printf("No extension: %s\r\n", g_run_name);
		m_run_restore_ui(panel);
		return;
	}
	ext++;
	if (run_ext_cmp(ext, "bat") == 0)
	{
		(void)run_cmd_direct(panel, g_run_name, NULL, 1u);
		m_run_restore_ui(panel);
	}
	else if (mb_nvext_find_handler(ext))
	{
		(void)run_cmd_direct(panel, g_run_handler, g_run_name, 1u);
		m_run_restore_ui(panel);
	}
	else if (run_ext_cmp(ext, "com") == 0 || run_ext_cmp(ext, "bin") == 0)
	{
		(void)run_cmd_direct(panel, g_run_name, NULL, 1u);
		m_run_restore_ui(panel);
	}
	else
		return;
}

void m_cmd_clear(void)
{
	g_cmd_active = 0u;
	g_cmd_len = 0u;
	g_cmd_cursor = 0u;
	g_cmd_line[0] = 0;
}

static void m_cmd_insert_char(unsigned char ch)
{
	unsigned char i;

	if (g_cmd_len >= NC_CMDLINE_LEN - 1u || ch < 32 || ch >= 127)
		return;
	for (i = g_cmd_len; i > g_cmd_cursor; i--)
		g_cmd_line[i] = g_cmd_line[i - 1u];
	g_cmd_line[g_cmd_cursor] = (char)ch;
	g_cmd_cursor++;
	g_cmd_len++;
	g_cmd_line[g_cmd_len] = 0;
}

void m_cmd_begin(unsigned char ch)
{
	g_cmd_active = 1u;
	g_cmd_len = 0u;
	g_cmd_cursor = 0u;
	g_cmd_line[0] = 0;
	m_cmd_insert_char(ch);
}

static void m_cmd_backspace(void)
{
	unsigned char i;

	if (g_cmd_cursor == 0u || g_cmd_len == 0u)
		return;
	for (i = (unsigned char)(g_cmd_cursor - 1u); i < g_cmd_len; i++)
		g_cmd_line[i] = g_cmd_line[i + 1u];
	g_cmd_cursor--;
	g_cmd_len--;
	g_cmd_line[g_cmd_len] = 0;
}

static void m_cmd_delete_fwd(void)
{
	unsigned char i;

	if (g_cmd_cursor >= g_cmd_len)
		return;
	for (i = g_cmd_cursor; i < g_cmd_len; i++)
		g_cmd_line[i] = g_cmd_line[i + 1u];
	g_cmd_len--;
	g_cmd_line[g_cmd_len] = 0;
}

static void m_cmd_insert_text(const char *text)
{
	while (text[0] != 0 && g_cmd_len < NC_CMDLINE_LEN - 1u)
	{
		m_cmd_insert_char((unsigned char)text[0]);
		text++;
	}
}

static void m_cmd_paste_name(PanelState *panel)
{
	unsigned char is_dir;

	if (!run_get_file(panel, &is_dir))
		return;
	if (is_dir)
		return;
	if (g_cmd_len > 0u && g_cmd_cursor > 0u && g_cmd_line[g_cmd_cursor - 1u] != ' ')
		m_cmd_insert_char(' ');
	m_cmd_insert_text(g_run_name);
}

void m_cmd_execute(PanelState *panel)
{
	unsigned int n;
	const char *prefix;

	if (!g_cmd_active || g_cmd_len == 0u)
		return;
	if (g_ini_cmd_flag == NC_CMD_FLAG_K)
		prefix = g_ui_term_cmd_k;
	else if (g_ini_cmd_flag == NC_CMD_FLAG_P)
		prefix = g_ui_term_cmd_p;
	else
		prefix = g_ui_term_cmd;
	strncpy(g_run_cmdline, prefix, sizeof(g_run_cmdline) - 1u);
	g_run_cmdline[sizeof(g_run_cmdline) - 1u] = 0;
	n = strlen(g_run_cmdline);
	strncat(g_run_cmdline, g_cmd_line, sizeof(g_run_cmdline) - n - 1u);
	g_run_cmdline[sizeof(g_run_cmdline) - 1u] = 0;
	(void)run_bin_direct(panel, g_ui_term_com, g_run_cmdline);
	m_run_restore_ui(panel);
	m_cmd_clear();
}

unsigned char m_cmd_handle_key(unsigned char key, PanelState *panel)
{
	if (!g_cmd_active)
	{
		if (key >= 32 && key < 127)
		{
			m_cmd_begin(key);
			return 1u;
		}
		return 0u;
	}

	switch (key)
	{
	case 27u:
		m_cmd_clear();
		return 1u;
	case NC_KEY_CSENTER:
		m_cmd_paste_name(panel);
		return 1u;
	case NC_KEY_PGUP:
		if (g_cmd_cursor > 0u)
			g_cmd_cursor--;
		return 1u;
	case NC_KEY_PGDN:
		if (g_cmd_cursor < g_cmd_len)
			g_cmd_cursor++;
		return 1u;
	case 8u:
		m_cmd_backspace();
		return 1u;
	case NC_KEY_DEL_FWD:
		m_cmd_delete_fwd();
		return 1u;
	default:
		if (key >= 32 && key < 127)
		{
			m_cmd_insert_char(key);
			return 1u;
		}
		return 0u;
	}
}

void m_cmd_fill_bottom_snap(void)
{
	g_bottom_snap.mode = NC_BOTTOM_CMD;
	g_bottom_snap.cmd_cursor = g_cmd_cursor;
	strncpy(g_bottom_snap.cmd_line, g_cmd_line, sizeof(g_bottom_snap.cmd_line) - 1u);
	g_bottom_snap.cmd_line[sizeof(g_bottom_snap.cmd_line) - 1u] = 0;
}

unsigned char m_panel_chdir_only(const char *path)
{
	char try_path[64];
	unsigned int len;

	if (OS_CHDIR((unsigned char *)path) == 0)
		return 1u;

	strncpy(try_path, path, sizeof(try_path) - 1u);
	try_path[sizeof(try_path) - 1u] = 0;
	len = 0u;
	while (try_path[len] != 0)
		len++;
	if (len > 0u && try_path[len - 1u] == '/')
	{
		try_path[len - 1u] = 0;
		if (OS_CHDIR((unsigned char *)try_path) == 0)
			return 1u;
	}
	return 0u;
}

unsigned char m_read_panel_dir_at(PanelState *panel, const char *path,
								  unsigned char preserve_cursor)
{
	return mb_read_panel_dir_at(panel, path, preserve_cursor);
}

void m_panels_remap_bank_window(void)
{
	mb_panels_remap_bank_window();
}

void m_redraw_panels_full(void)
{
	mb_ui_begin_full_redraw();
	mb_draw_panel_background(&left_panel, 0u);
	mb_draw_panel_background(&right_panel, 40u);
	mb_panels_draw_all();
	mb_ui_draw_status_bar();
	mb_ui_nc_clock_draw(1u);
	draw_bottom_info(left_panel.is_active ? &left_panel : &right_panel);
}

void m_panels_redraw_both(void)
{
	m_redraw_panels_full();
}

void m_draw_panel(PanelState *panel, unsigned char start_x, unsigned char height)
{
	mb_draw_panel(panel, start_x, height);
}

/* Bank 02 may enter bank 01 through this root trampoline; the wrapper restores
 * the currently mapped bank 02 before its caller resumes. */
void m_panel_sort_notice_show(PanelState *panel)
{
	mb_panel_sort_notice_show(panel);
}
