#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "nc_inc.h"
#include "nc_plug.h"
#include "mb_req.h"

#define COPY_IO_ADDR ((unsigned char *)BANK_WINDOW_ADDRESS)
#define COPY_IO_CHUNK 16384u
#define FILEOP_STACK_MAX 100u
#define FILEOP_STACK_BYTES 130u

typedef struct
{
	char src[64];
	char dst[64];
	unsigned int skip;
} CopyFrame;

static void path_join(char *out, const char *path, const char *name)
{
	unsigned int n, i;
	n = 0u;
	while (path[n] != 0 && n < 198u) { out[n] = path[n]; n++; }
	if (n != 0u && out[n - 1u] != '/' && out[n - 1u] != '\\') out[n++] = '/';
	i = 0u;
	while (name[i] != 0 && n < 199u) out[n++] = name[i++];
	out[n] = 0;
}

static unsigned char is_dot(const fileInfo *fi)
{
	return (unsigned char)(fi->fname[0] == '.' &&
		(fi->fname[1] == 0 || (fi->fname[1] == '.' &&
		(fi->fname[2] == 0 || fi->fname[2] == ' '))));
}

static void fi_name(const fileInfo *fi, char *out)
{
	unsigned int i;
	const unsigned char *s;
	s = fi->lfname[0] != 0 ? fi->lfname : fi->fname;
	for (i = 0u; i < 63u && s[i] != 0 && s[i] != ' '; i++) out[i] = (char)s[i];
	out[i] = 0;
}

static unsigned int panel_phys(PanelState *p, unsigned int visible)
{
	unsigned char *b;
	OS_SETPGC000(p->bank_ids[PANEL_META_PAGE]);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	return (unsigned int)b[PANEL_META_OFF_IDX + visible * 2u] |
		((unsigned int)b[PANEL_META_OFF_IDX + visible * 2u + 1u] << 8);
}

static unsigned char panel_marked(PanelState *p, unsigned int visible)
{
	unsigned int phys;
	unsigned char *b;
	if (visible >= p->file_count) return 0u;
	OS_SETPGC000(p->bank_ids[PANEL_META_PAGE]);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	phys = (unsigned int)b[PANEL_META_OFF_IDX + visible * 2u] |
		((unsigned int)b[PANEL_META_OFF_IDX + visible * 2u + 1u] << 8);
	return b[PANEL_META_OFF_MARK + phys];
}

static unsigned int marked_count(PanelState *p)
{
	unsigned int i, n;
	n = 0u;
	for (i = 0u; i < p->file_count; i++) if (panel_marked(p, i)) n++;
	return n;
}

static unsigned char panel_item(PanelState *p, unsigned int visible, unsigned char require_mark,
								char *name, unsigned char *is_dir, unsigned int *date, unsigned int *time)
{
	unsigned int phys, off;
	fileInfo *fi;
	if (visible >= p->file_count || (require_mark && !panel_marked(p, visible))) return 0u;
	phys = panel_phys(p, visible);
	OS_SETPGC000(p->bank_ids[phys / FILES_PER_PAGE]);
	off = phys % FILES_PER_PAGE;
	fi = &((fileInfo *)BANK_WINDOW_ADDRESS)[off];
	fi_name(fi, name);
	*is_dir = (fi->fattrib & 0x10) ? 1u : 0u;
	*date = fi->fdate;
	*time = fi->ftime;
	return 1u;
}

static void poll_abort(void)
{
	unsigned char k;
	k = (unsigned char)OS_GETKEY();
	if (k == NC_KEY_FOCUS) g_focus_pending = 1u;
	else if (k == 27u || k == NC_KEY_F10) g_fileop_abort = 1u;
}

static unsigned char panel_banks_ok(const PanelState *p)
{
	unsigned char a, b;
	for (a = 0u; a < NC_PAGES_PER_PANEL; a++)
	{
		if (p->bank_ids[a] == 0u) return 0u;
		for (b = (unsigned char)(a + 1u); b < NC_PAGES_PER_PANEL; b++)
			if (p->bank_ids[a] == p->bank_ids[b]) return 0u;
	}
	return 1u;
}

static void snap_panels(void)
{
	strncpy(g_snap_left, left_panel.current_path, 63u); g_snap_left[63] = 0;
	strncpy(g_snap_right, right_panel.current_path, 63u); g_snap_right[63] = 0;
}

static void path_normalize_into(char *dst, const char *path)
{
	unsigned int len, i;
	len = 0u;
	while (path[len] != 0 && len < 63u) len++;
	for (i = 0u; i < len; i++) dst[i] = path[i];
	dst[len] = 0;
	if (len > 0u && dst[len - 1u] != '/' && len < 62u)
	{
		dst[len] = '/';
		dst[len + 1u] = 0;
	}
}

static void panel_set_path(PanelState *p, const char *path)
{
	path_normalize_into(p->current_path, path);
}

static void mark_clear(PanelState *p)
{
	if (!panel_banks_ok(p)) return;
	OS_SETPGC000(p->bank_ids[PANEL_META_PAGE]);
	memset((void *)(BANK_WINDOW_ADDRESS + PANEL_META_OFF_MARK), 0, (size_t)PANEL_META_MARK_BYTES);
	p->marked_count = 0u;
	p->marked_bytes = 0UL;
}

static void redraw_after_dialog_cancel(void)
{
	g_focus_pending = 0u;
	copy_prog.drawn = 0u;
	mb_redraw_panels_full();
}

static unsigned char dest_path_ok(void)
{
	unsigned int len;
	if (OS_CHDIR((unsigned char *)nc_set.temp_path) == 0u) { OS_OPENDIR((unsigned char *)""); return 1u; }
	len = 0u;
	while (nc_set.temp_path[len] != 0) len++;
	if (len > 0u && nc_set.temp_path[len - 1u] == '/')
	{
		nc_set.temp_path[len - 1u] = 0;
		if (OS_CHDIR((unsigned char *)nc_set.temp_path) == 0u) { OS_OPENDIR((unsigned char *)""); return 1u; }
		nc_set.temp_path[len - 1u] = '/';
	}
	return 0u;
}

static void path_basename_from(const char *path, char *out)
{
	unsigned int len, i, start;
	out[0] = 0;
	len = 0u;
	while (path[len] != 0 && len < 63u) len++;
	while (len > 0u && path[len - 1u] == '/') len--;
	start = 0u;
	for (i = 0u; i < len; i++)
		if (path[i] == '/') start = i + 1u;
	for (i = 0u; start < len && i < 63u; i++)
	{
		out[i] = path[start];
		start++;
	}
	out[i] = 0;
}

static unsigned char copy_check_dir_merge(const char *dst)
{
	strcpy(g_copy_ow_msg, g_ui_folder_pfx);
	path_basename_from(dst, r_action_name);
	strcat(g_copy_ow_msg, r_action_name);
	strcat(g_copy_ow_msg, g_ui_exist_sfx);
	return mb_copy_overwrite_resolve(mb_copy_dir_exists(dst), g_copy_ow_msg);
}

static void name_rtrim(char *s)
{
	unsigned int n;
	n = 0u;
	while (s[n] != 0) n++;
	while (n > 0u && s[n - 1u] == ' ')
	{
		n--;
		s[n] = 0;
	}
}

static void delete_prompt_append_uint(char *buf, unsigned char *pi, unsigned int val)
{
	char tmp[6];
	unsigned char n, j;
	n = 0u;
	if (val == 0u) { buf[(*pi)++] = '0'; return; }
	while (val > 0u && n < 6u) { tmp[n++] = (char)('0' + (val % 10u)); val /= 10u; }
	j = n;
	while (j > 0u) buf[(*pi)++] = tmp[--j];
}

static void delete_build_prompt_one(const char *item_name, unsigned char is_dir)
{
	unsigned char i, j, max_name;
	const char *pfx;
	i = 0u;
	pfx = is_dir ? "Delete folder " : "Delete file ";
	while (*pfx != 0 && i < 48u) nc_set.temp_path[i++] = *pfx++;
	max_name = (unsigned char)(64u - (unsigned int)i - 2u);
	j = 0u;
	while (item_name[j] != 0 && j < max_name)
		nc_set.temp_path[i++] = item_name[j++];
	nc_set.temp_path[i++] = '?';
	nc_set.temp_path[i] = 0;
}

static void delete_build_prompt_multi(unsigned char count)
{
	unsigned char i;
	i = 0u;
	nc_set.temp_path[i++] = 'D'; nc_set.temp_path[i++] = 'e'; nc_set.temp_path[i++] = 'l';
	nc_set.temp_path[i++] = 'e'; nc_set.temp_path[i++] = 't'; nc_set.temp_path[i++] = 'e';
	nc_set.temp_path[i++] = ' ';
	delete_prompt_append_uint(nc_set.temp_path, &i, count);
	nc_set.temp_path[i++] = ' '; nc_set.temp_path[i++] = 'i'; nc_set.temp_path[i++] = 't';
	nc_set.temp_path[i++] = 'e'; nc_set.temp_path[i++] = 'm';
	if (count != 1u) nc_set.temp_path[i++] = 's';
	nc_set.temp_path[i++] = '?';
	nc_set.temp_path[i] = 0;
}

static unsigned char panel_path_under_dir(const char *path, const char *dir)
{
	unsigned int lp, ld, i;
	ld = 0u;
	while (dir[ld] != 0 && ld < 63u) ld++;
	while (ld > 0u && dir[ld - 1u] == '/') ld--;
	lp = 0u;
	while (path[lp] != 0 && lp < 63u) lp++;
	for (i = 0u; i < ld; i++)
	{
		unsigned char a, b;
		a = (unsigned char)path[i];
		b = (unsigned char)dir[i];
		if (a >= 'a' && a <= 'z') a = (unsigned char)(a - 'a' + 'A');
		if (b >= 'a' && b <= 'z') b = (unsigned char)(b - 'a' + 'A');
		if (a != b) return 0u;
	}
	if (lp == ld) return 1u;
	if (lp > ld && path[ld] == '/') return 1u;
	return 0u;
}

static void panel_path_to_parent_of(char *path, const char *dir_path)
{
	unsigned int len, i;
	strncpy(path, dir_path, 63u); path[63] = 0;
	len = 0u;
	while (path[len] != 0) len++;
	while (len > 0u && path[len - 1u] == '/') len--;
	if (len <= 3u) return;
	for (i = len; i > 0u; i--)
	{
		if (path[i - 1u] == '/')
		{
			if (i == 3u && path[1] == ':') { path[3] = '/'; path[4] = 0; }
			else path[i] = 0;
			return;
		}
	}
}

static void panels_fixup_after_dir_delete(const char *deleted_dir)
{
	if (panel_path_under_dir(left_panel.current_path, deleted_dir))
	{
		panel_path_to_parent_of(left_panel.current_path, deleted_dir);
		panel_set_path(&left_panel, left_panel.current_path);
	}
	if (panel_path_under_dir(right_panel.current_path, deleted_dir))
	{
		panel_path_to_parent_of(right_panel.current_path, deleted_dir);
		panel_set_path(&right_panel, right_panel.current_path);
	}
}

static void finish_copy_success(PanelState *src, PanelState *dst)
{
	g_focus_pending = 0u;
	copy_prog.drawn = 0u;
	panel_set_path(&left_panel, g_snap_left);
	panel_set_path(&right_panel, g_snap_right);
	if (dest_path_ok())
		panel_set_path(dst, nc_set.temp_path);
	mark_clear(src);
	mb_read_panel_dir_at(dst, dst->current_path, 1u);
	mb_panel_chdir_only(left_panel.is_active ? left_panel.current_path : right_panel.current_path);
	mb_redraw_panels_full();
}

static void finish_move_success(PanelState *src, PanelState *dst)
{
	g_focus_pending = 0u;
	copy_prog.drawn = 0u;
	panel_set_path(&left_panel, g_snap_left);
	panel_set_path(&right_panel, g_snap_right);
	if (dest_path_ok())
		panel_set_path(dst, nc_set.temp_path);
	mark_clear(src);
	if (left_panel.is_active)
	{
		mb_read_panel_dir_at(&left_panel, left_panel.current_path, 1u);
		mb_read_panel_dir_at(&right_panel, right_panel.current_path, 1u);
	}
	else
	{
		mb_read_panel_dir_at(&right_panel, right_panel.current_path, 1u);
		mb_read_panel_dir_at(&left_panel, left_panel.current_path, 1u);
	}
	mb_panel_chdir_only(left_panel.is_active ? left_panel.current_path : right_panel.current_path);
	mb_redraw_panels_full();
}

static void finish_one_panel_success(PanelState *p)
{
	g_focus_pending = 0u;
	copy_prog.drawn = 0u;
	panel_set_path(&left_panel, g_snap_left);
	panel_set_path(&right_panel, g_snap_right);
	mb_read_panel_dir_at(p, p->current_path, 1u);
	mb_panel_chdir_only(p->current_path);
	mb_redraw_panels_full();
}

static void finish_delete_success(PanelState *p)
{
	PanelState *other;
	const char *other_snap;
	g_focus_pending = 0u;
	copy_prog.drawn = 0u;
	g_delete_progress = 0u;
	mark_clear(p);
	mb_read_panel_dir_at(p, p->current_path, 1u);
	other = (p == &left_panel) ? &right_panel : &left_panel;
	other_snap = (p == &left_panel) ? g_snap_right : g_snap_left;
	if (strcmp(other->current_path, other_snap) != 0)
		mb_read_panel_dir_at(other, other->current_path, 1u);
	mb_panel_chdir_only(left_panel.is_active ? left_panel.current_path : right_panel.current_path);
	mb_redraw_panels_full();
}

static void progress_name(const char *name, unsigned char dir)
{
	mb_fileop_progress_store_name(name);
	mb_copy_progress_draw_bar(dir ? 100u : 0u);
}

static unsigned char copy_overwrite(const char *dst)
{
	unsigned int i, start, n;
	start = 0u;
	for (i = 0u; dst[i] != 0; i++) if (dst[i] == '/' || dst[i] == '\\') start = i + 1u;
	strcpy(g_copy_ow_msg, g_ui_file_pfx);
	n = 5u;
	for (i = start; dst[i] != 0 && n < 67u; i++) g_copy_ow_msg[n++] = dst[i];
	g_copy_ow_msg[n] = 0;
	strcat(g_copy_ow_msg, g_ui_exist_sfx);
	return mb_copy_overwrite_resolve(mb_copy_dest_exists(dst), g_copy_ow_msg);
}

static unsigned char copy_file(const char *src, const char *dst, unsigned int date, unsigned int time)
{
	FILE *in, *out;
	unsigned long total, left;
	unsigned int got, put, chunk;
	unsigned char tick, res;

	res = copy_overwrite(dst);
	if (res == NC_COPY_FILE_SKIP || res == NC_COPY_FILE_ABORT) return res;
	if (date == 0u && time == 0u)
		OS_GETFILETIME((unsigned char *)src, &date, &time);
	in = OS_OPENHANDLE((unsigned char *)src, 0x80u);
	if (((int)in) & 0xff) return NC_COPY_FILE_ERR;
	total = OS_GETFILESIZE(in);
	left = total;
	out = OS_CREATEHANDLE((unsigned char *)dst, 0x80u);
	if (((int)out) & 0xff) { OS_CLOSEHANDLE(in); return NC_COPY_FILE_ERR; }
	tick = 0u;
	while (left != 0UL)
	{
		if (g_fileop_abort) { OS_CLOSEHANDLE(out); OS_CLOSEHANDLE(in); OS_DELETE((unsigned char *)dst); return NC_COPY_FILE_ABORT; }
		OS_SETPGC000(g_copy_io_page);
		chunk = left > COPY_IO_CHUNK ? COPY_IO_CHUNK : (unsigned int)left;
		got = OS_READHANDLE(COPY_IO_ADDR, in, chunk);
		put = OS_WRITEHANDLE(COPY_IO_ADDR, out, got);
		if (got == 0u || put != got) { OS_CLOSEHANDLE(out); OS_CLOSEHANDLE(in); OS_DELETE((unsigned char *)dst); return NC_COPY_FILE_ERR; }
		left -= got;
		tick++;
		if ((tick & 3u) == 0u || left == 0UL)
			mb_copy_progress_draw_bar(total == 0UL ? 100u : (unsigned char)(((total - left) * 100UL) / total));
		poll_abort();
		YIELD();
	}
	OS_SEEKHANDLE(out, total);
	OS_CLOSEHANDLE(out);
	OS_CLOSEHANDLE(in);
	OS_SETFILETIME((unsigned char *)dst, date, time);
	if (g_move_active)
		(void)OS_DELETE((unsigned char *)src);
	return NC_COPY_FILE_OK;
}

static CopyFrame *copy_frame(unsigned char n)
{
	OS_SETPGC000(g_copy_stack_page);
	return (CopyFrame *)((unsigned char *)BANK_WINDOW_ADDRESS + (unsigned int)n * FILEOP_STACK_BYTES);
}

static void path_parent_base(const char *full, char *parent_out, char *base_out)
{
	unsigned int len, i, slash;

	len = 0u;
	while (full[len] != 0 && len < 199u) len++;
	while (len > 0u && (full[len - 1u] == '/' || full[len - 1u] == '\\')) len--;
	slash = 0u;
	for (i = 0u; i < len; i++)
		if (full[i] == '/' || full[i] == '\\') slash = i;
	for (i = 0u; slash + 1u + i < len && i < 63u; i++)
		base_out[i] = full[slash + 1u + i];
	base_out[i] = 0;
	if (slash == 0u && !(full[0] != 0 && full[1] == ':'))
	{
		parent_out[0] = 0;
		return;
	}
	for (i = 0u; i < slash && i < 198u; i++)
		parent_out[i] = full[i];
	parent_out[i] = 0;
	if (i == 2u && parent_out[1] == ':')
	{
		parent_out[2] = '/';
		parent_out[3] = 0;
	}
}

static void move_delete_dir_path(const char *full_dir)
{
	path_parent_base(full_dir, r_action_path, r_action_name);
	if (r_action_path[0] == 0 || r_action_name[0] == 0)
		return;
	if (!mb_panel_chdir_only(r_action_path))
		return;
	(void)OS_DELETE((unsigned char *)r_action_name);
}

/* Copy a directory without recursion: stack frames persist in a C000 page. */
static unsigned char copy_tree(const char *src, const char *dst)
{
	CopyFrame *f;
	unsigned int skipped, date, time;
	unsigned char found, is_dir, result, ok;
	if (g_copy_stack_page == 0u && !panel_request_unique_page(&g_copy_stack_page)) return 0u;
	g_copy_sp = 1u;
	f = copy_frame(0u);
	strncpy(f->src, src, 63u); f->src[63] = 0;
	strncpy(f->dst, dst, 63u); f->dst[63] = 0;
	f->skip = 0u;
	g_copy_tree_failed = 0u;
	while (g_copy_sp != 0u && !g_fileop_abort)
	{
		f = copy_frame((unsigned char)(g_copy_sp - 1u));
		strncpy(r_src_full, f->src, 199u); r_src_full[199] = 0;
		strncpy(r_dst_full, f->dst, 199u); r_dst_full[199] = 0;
		skipped = f->skip;
		if (OS_CHDIR((unsigned char *)r_src_full) != 0u) { g_copy_tree_failed = 1u; break; }
		OS_OPENDIR((unsigned char *)"");
		found = 0u;
		while (skipped != 0u)
		{
			if (OS_READDIR(&r_global_info) != 0u) break;
			if (!is_dot(&r_global_info)) skipped--;
		}
		while (OS_READDIR(&r_global_info) == 0u)
		{
			if (!is_dot(&r_global_info)) { found = 1u; break; }
		}
		if (!found)
		{
			if (g_move_active && g_copy_sp > 1u)
			{
				f = copy_frame((unsigned char)(g_copy_sp - 1u));
				strncpy(r_action_path, f->src, 199u); r_action_path[199] = 0;
				move_delete_dir_path(r_action_path);
			}
			g_copy_sp--;
			continue;
		}
		fi_name(&r_global_info, r_action_name);
		is_dir = (r_global_info.fattrib & 0x10) ? 1u : 0u;
		date = r_global_info.fdate; time = r_global_info.ftime;
		f = copy_frame((unsigned char)(g_copy_sp - 1u));
		f->skip++;
		path_join(r_action_path, r_src_full, r_action_name);
		path_join(r_dst_full, r_dst_full, r_action_name);
		progress_name(r_action_name, is_dir);
		if (is_dir)
		{
			if (OS_MKDIR((unsigned char *)r_dst_full) != 0u && !mb_copy_dir_exists(r_dst_full)) { g_copy_tree_failed = 1u; break; }
			if (g_copy_sp >= FILEOP_STACK_MAX) { g_copy_tree_failed = 1u; break; }
			f = copy_frame(g_copy_sp);
			strncpy(f->src, r_action_path, 63u); f->src[63] = 0;
			strncpy(f->dst, r_dst_full, 63u); f->dst[63] = 0;
			f->skip = 0u;
			g_copy_sp++;
		}
		else
		{
			result = copy_file(r_action_path, r_dst_full, date, time);
			if (result == NC_COPY_FILE_ABORT || result == NC_COPY_FILE_ERR) { g_copy_tree_failed = 1u; break; }
		}
		poll_abort();
	}
	ok = (unsigned char)(!g_copy_tree_failed && !g_fileop_abort);
	if (g_copy_stack_page != 0u)
	{
		OS_DELPAGE(g_copy_stack_page);
		g_panel_page_used[g_copy_stack_page] = 0u;
		g_copy_stack_page = 0u;
	}
	g_copy_sp = 0u;
	if (g_move_active && ok)
		move_delete_dir_path(src);
	return ok;
}

void r_action_copy(void)
{
	PanelState *src, *dst;
	unsigned int marks, i, date, time, len;
	unsigned char is_dir, result;
	src = left_panel.is_active ? &left_panel : &right_panel;
	dst = left_panel.is_active ? &right_panel : &left_panel;
	if (src->file_count == 0u) return;
	snap_panels();
	strncpy(nc_set.temp_path, dst->current_path, 63u); nc_set.temp_path[63] = 0;
	len = 0u;
	while (nc_set.temp_path[len] != 0) len++;
	if (len > 0u && nc_set.temp_path[len - 1u] != '/' && nc_set.temp_path[len - 1u] != '\\' && len < 63u)
	{
		nc_set.temp_path[len] = '/';
		nc_set.temp_path[len + 1u] = 0;
	}
	if (mb_ui_dialog_input(g_ui_copy, g_ui_copy_to) == D_RES_CANCEL) { redraw_after_dialog_cancel(); return; }
	if (!mb_panel_chdir_only(nc_set.temp_path)) { mb_ui_error_dialog(g_ui_copy, g_ui_copy_bad_dest); redraw_after_dialog_cancel(); return; }
	g_fileop_abort = 0u; g_copy_tree_failed = 0u; g_copy_overwrite_mode = NC_COPY_OW_ASK_EACH;
	if (!panel_request_unique_page(&g_copy_io_page)) { mb_ui_alert_dialog(g_ui_copy, g_ui_copy_nomem); redraw_after_dialog_cancel(); return; }
	mb_fileop_progress_begin(0u);
	marks = marked_count(src);
	for (i = 0u; i < src->file_count; i++)
	{
		if (marks == 0u && i != src->cursor_idx) continue;
		if (!panel_item(src, i, marks != 0u, r_action_name, &is_dir, &date, &time)) continue;
		if (is_dir && strcmp(r_action_name, "..") == 0) continue;
		path_join(r_src_full, src->current_path, r_action_name);
		path_join(r_dst_full, nc_set.temp_path, r_action_name);
		progress_name(r_action_name, is_dir);
		if (is_dir)
		{
			if (OS_MKDIR((unsigned char *)r_dst_full) != 0u)
			{
				if (!mb_copy_dir_exists(r_dst_full)) { g_copy_tree_failed = 1u; break; }
				result = copy_check_dir_merge(r_dst_full);
				if (result == NC_COPY_FILE_SKIP) continue;
				if (result == NC_COPY_FILE_ABORT) { g_fileop_abort = 1u; break; }
			}
			if (!copy_tree(r_src_full, r_dst_full)) { g_copy_tree_failed = 1u; break; }
		}
		else
		{
			result = copy_file(r_src_full, r_dst_full, date, time);
			if (result == NC_COPY_FILE_SKIP) continue;
			if (result == NC_COPY_FILE_ABORT || result == NC_COPY_FILE_ERR) { g_copy_tree_failed = 1u; break; }
		}
		if (marks == 0u) break;
		poll_abort();
	}
	OS_DELPAGE(g_copy_io_page); g_panel_page_used[g_copy_io_page] = 0u; g_copy_io_page = 0u;
	if (g_fileop_abort) mb_copy_progress_draw_name(g_ui_cancelled);
	else if (g_copy_tree_failed) mb_ui_error_dialog(g_ui_copy, g_ui_copy_write_fail);
	mb_fileop_progress_restore();
	if (g_fileop_abort)
		redraw_after_dialog_cancel();
	else
		finish_copy_success(src, dst);
}

static void delete_tree(const char *root)
{
	char *slot;
	unsigned char found, is_dir;
	if (g_delete_stack_page == 0u)
	{
		if (!panel_request_unique_page(&g_delete_stack_page))
		{
			g_copy_tree_failed = 1u;
			mb_ui_alert_dialog(g_ui_delete, g_ui_copy_nomem);
			return;
		}
	}
	g_deldir_sp = 1u;
	OS_SETPGC000(g_delete_stack_page);
	strncpy((char *)BANK_WINDOW_ADDRESS, root, 63u);
	((char *)BANK_WINDOW_ADDRESS)[63] = 0;
	while (g_deldir_sp != 0u && !g_fileop_abort)
	{
		OS_SETPGC000(g_delete_stack_page);
		slot = (char *)BANK_WINDOW_ADDRESS + (unsigned int)(g_deldir_sp - 1u) * 64u;
		strncpy(r_action_path, slot, 63u); r_action_path[63] = 0;
		if (OS_CHDIR((unsigned char *)r_action_path) != 0u) break;
		OS_OPENDIR((unsigned char *)"");
		found = 0u;
		while (OS_READDIR(&r_global_info) == 0u)
			if (!is_dot(&r_global_info)) { found = 1u; break; }
		if (!found)
		{
			OS_CHDIR((unsigned char *)"..");
			g_deldir_sp--;
			if (g_deldir_sp != 0u) OS_DELETE((unsigned char *)r_action_path);
			continue;
		}
		fi_name(&r_global_info, r_action_name);
		is_dir = (r_global_info.fattrib & 0x10) ? 1u : 0u;
		progress_name(r_action_name, 1u);
		if (is_dir)
		{
			if (g_deldir_sp >= 255u) { g_copy_tree_failed = 1u; break; }
			path_join(r_dst_full, r_action_path, r_action_name);
			OS_SETPGC000(g_delete_stack_page);
			slot = (char *)BANK_WINDOW_ADDRESS + (unsigned int)g_deldir_sp * 64u;
			strncpy(slot, r_dst_full, 63u); slot[63] = 0;
			g_deldir_sp++;
		}
		else OS_DELETE((unsigned char *)r_action_name);
		poll_abort();
	}
}

void r_action_delete(void)
{
	PanelState *p;
	unsigned int marks, i, date, time;
	unsigned char is_dir;
	p = left_panel.is_active ? &left_panel : &right_panel;
	if (p->file_count == 0u) return;
	snap_panels();
	marks = marked_count(p);
	if (!panel_request_unique_page(&g_delete_stack_page))
	{
		mb_ui_alert_dialog(g_ui_delete, g_ui_copy_nomem);
		redraw_after_dialog_cancel();
		return;
	}
	if (marks == 0u)
	{
		if (!panel_item(p, p->cursor_idx, 0u, r_action_name, &is_dir, &date, &time) ||
			(is_dir && strcmp(r_action_name, "..") == 0))
		{
			OS_DELPAGE(g_delete_stack_page); g_panel_page_used[g_delete_stack_page] = 0u; g_delete_stack_page = 0u;
			return;
		}
		delete_build_prompt_one(r_action_name, is_dir);
	}
	else delete_build_prompt_multi((unsigned char)marks);
	if (mb_ui_dialog_delete_confirm(g_ui_delete, nc_set.temp_path) != D_RES_YES)
	{
		OS_DELPAGE(g_delete_stack_page); g_panel_page_used[g_delete_stack_page] = 0u; g_delete_stack_page = 0u;
		redraw_after_dialog_cancel();
		return;
	}
	g_fileop_abort = 0u; g_copy_tree_failed = 0u; mb_fileop_progress_begin(1u);
	for (i = 0u; i < p->file_count; i++)
	{
		if (marks == 0u && i != p->cursor_idx) continue;
		if (!panel_item(p, i, marks != 0u, r_action_name, &is_dir, &date, &time)) continue;
		if (is_dir && strcmp(r_action_name, "..") == 0) continue;
		path_join(r_action_path, p->current_path, r_action_name);
		progress_name(r_action_name, 1u);
		if (is_dir)
		{
			delete_tree(r_action_path);
			if (!g_fileop_abort)
			{
				(void)OS_DELETE((unsigned char *)r_action_path);
				panels_fixup_after_dir_delete(r_action_path);
			}
		}
		else OS_DELETE((unsigned char *)r_action_path);
		if (marks == 0u || g_fileop_abort) break;
		poll_abort();
	}
	mb_fileop_progress_restore();
	if (g_delete_stack_page != 0u)
	{
		OS_DELPAGE(g_delete_stack_page);
		g_panel_page_used[g_delete_stack_page] = 0u;
		g_delete_stack_page = 0u;
	}
	if (g_fileop_abort)
		redraw_after_dialog_cancel();
	else
		finish_delete_success(p);
}

void r_action_rename(void)
{
	PanelState *p;
	unsigned int date, time;
	unsigned char dir, res;
	char saved_name[64];

	p = left_panel.is_active ? &left_panel : &right_panel;
	if (!panel_item(p, p->cursor_idx, 0u, r_action_name, &dir, &date, &time) ||
		(dir && strcmp(r_action_name, "..") == 0))
		return;
	snap_panels();
	strncpy(saved_name, r_action_name, sizeof(saved_name) - 1u);
	saved_name[sizeof(saved_name) - 1u] = 0;
	strncpy(nc_set.temp_path, saved_name, sizeof(nc_set.temp_path) - 1u);
	nc_set.temp_path[sizeof(nc_set.temp_path) - 1u] = 0;
	res = mb_ui_dialog_rename_input(g_ui_rename, g_ui_rename_to);
	if (res == D_RES_CANCEL) { redraw_after_dialog_cancel(); return; }
	if (res == D_RES_TO_MOVE) { r_action_move(); return; }
	name_rtrim(nc_set.temp_path);
	if (strcmp(nc_set.temp_path, saved_name) == 0) { redraw_after_dialog_cancel(); return; }
	if (nc_set.temp_path[0] == 0 || strchr(nc_set.temp_path, '/') || strchr(nc_set.temp_path, '\\') || strchr(nc_set.temp_path, ':'))
	{
		mb_ui_alert_dialog(g_ui_rename, g_ui_invalid_name);
		redraw_after_dialog_cancel();
		return;
	}
	if (!mb_panel_chdir_only(p->current_path))
	{
		mb_ui_alert_dialog(g_ui_rename_fail, g_ui_chdir_fail);
		redraw_after_dialog_cancel();
		return;
	}
	OS_SETPGC000(m_run_resident_page());
	if (OS_RENAME((unsigned char *)saved_name, (unsigned char *)nc_set.temp_path) != 0u)
	{
		mb_ui_alert_dialog(g_ui_rename_fail, g_ui_rename_fail_msg);
		redraw_after_dialog_cancel();
		return;
	}
	finish_one_panel_success(p);
}

void r_action_mkdir(void)
{
	PanelState *p;
	p = left_panel.is_active ? &left_panel : &right_panel;
	snap_panels();
	nc_set.temp_path[0] = 0;
	if (mb_ui_dialog_input(g_ui_mkdir, g_ui_mkdir_name) == D_RES_CANCEL) { redraw_after_dialog_cancel(); return; }
	name_rtrim(nc_set.temp_path);
	if (nc_set.temp_path[0] == 0 || strchr(nc_set.temp_path, '/') || strchr(nc_set.temp_path, '\\') || strchr(nc_set.temp_path, ':'))
	{
		mb_ui_alert_dialog(g_ui_mkdir_short, g_ui_invalid_name);
		redraw_after_dialog_cancel();
	}
	else
	{
		path_join(r_action_path, p->current_path, nc_set.temp_path);
		if (OS_MKDIR((unsigned char *)r_action_path) != 0u)
		{
			mb_ui_alert_dialog(g_ui_mkdir_fail, r_action_path);
			redraw_after_dialog_cancel();
		}
		else
			finish_one_panel_success(p);
	}
}

static unsigned char path_drive_letter(const char *path)
{
	if (path[0] >= 'A' && path[0] <= 'Z') return (unsigned char)path[0];
	if (path[0] >= 'a' && path[0] <= 'z') return (unsigned char)(path[0] - 'a' + 'A');
	return 0u;
}

static void path_on_volume(const char *full, char *out)
{
	const char *p;
	unsigned int i;
	p = full;
	if (p[0] != 0 && p[1] == ':') p += 2;
	while (*p == '/' || *p == '\\') p++;
	for (i = 0u; p[i] != 0 && i < 63u; i++)
		out[i] = (p[i] == '\\') ? '/' : (char)p[i];
	out[i] = 0;
}

static unsigned char move_samedrive_rename(const char *src_full, const char *dst_full)
{
	char root[8];
	path_on_volume(src_full, r_action_left);
	path_on_volume(dst_full, r_action_right);
	if (r_action_left[0] == 0 || r_action_right[0] == 0) return NC_COPY_FILE_ERR;
	root[0] = src_full[0]; root[1] = ':'; root[2] = '/'; root[3] = 0;
	if (!mb_panel_chdir_only(root)) return NC_COPY_FILE_ERR;
	if (OS_RENAME((unsigned char *)r_action_left, (unsigned char *)r_action_right) != 0u)
		return NC_COPY_FILE_ERR;
	return NC_COPY_FILE_OK;
}

static unsigned char move_samedrive_one(PanelState *src, const char *name, unsigned char is_dir,
										unsigned int date, unsigned int time)
{
	unsigned char ow, res;
	path_join(r_src_full, src->current_path, name);
	path_join(r_dst_full, nc_set.temp_path, name);
	if (strcmp(r_src_full, r_dst_full) == 0) return NC_COPY_FILE_OK;
	if (!is_dir)
	{
		ow = copy_overwrite(r_dst_full);
		if (ow == NC_COPY_FILE_SKIP || ow == NC_COPY_FILE_ABORT) return ow;
		if (mb_copy_dest_exists(r_dst_full)) (void)OS_DELETE((unsigned char *)r_dst_full);
		progress_name(name, 0u);
		res = move_samedrive_rename(r_src_full, r_dst_full);
		if (res != NC_COPY_FILE_OK) { g_copy_tree_failed = 1u; return NC_COPY_FILE_ERR; }
		return NC_COPY_FILE_OK;
	}
	if (!mb_copy_dir_exists(r_dst_full))
	{
		progress_name(name, 1u);
		res = move_samedrive_rename(r_src_full, r_dst_full);
		if (res != NC_COPY_FILE_OK) { g_copy_tree_failed = 1u; return NC_COPY_FILE_ERR; }
		return NC_COPY_FILE_OK;
	}
	ow = copy_check_dir_merge(r_dst_full);
	if (ow == NC_COPY_FILE_SKIP) return NC_COPY_FILE_SKIP;
	if (ow == NC_COPY_FILE_ABORT) return NC_COPY_FILE_ABORT;
	progress_name(name, 1u);
	if (!copy_tree(r_src_full, r_dst_full)) return NC_COPY_FILE_ERR;
	return NC_COPY_FILE_OK;
}

static void move_ensure_temp_slash(void)
{
	unsigned int len;
	len = 0u;
	while (nc_set.temp_path[len] != 0) len++;
	if (len > 0u && nc_set.temp_path[len - 1u] != '/' && nc_set.temp_path[len - 1u] != '\\' && len < 63u)
	{
		nc_set.temp_path[len] = '/';
		nc_set.temp_path[len + 1u] = 0;
	}
}

void r_action_move(void)
{
	PanelState *src, *dst;
	unsigned int marks, i, date, time;
	unsigned char is_dir, result, src_drv, dst_drv;
	src = left_panel.is_active ? &left_panel : &right_panel;
	dst = left_panel.is_active ? &right_panel : &left_panel;
	if (src->file_count == 0u) return;
	snap_panels();
	strncpy(nc_set.temp_path, dst->current_path, 63u); nc_set.temp_path[63] = 0;
	move_ensure_temp_slash();
	if (mb_ui_dialog_input(g_ui_move, g_ui_move_to) == D_RES_CANCEL) { redraw_after_dialog_cancel(); return; }
	if (!mb_panel_chdir_only(nc_set.temp_path)) { mb_ui_error_dialog(g_ui_move, g_ui_move_bad_dest); redraw_after_dialog_cancel(); return; }
	g_fileop_abort = 0u; g_copy_tree_failed = 0u; g_copy_overwrite_mode = NC_COPY_OW_ASK_EACH;
	g_move_active = 1u;
	src_drv = path_drive_letter(src->current_path);
	dst_drv = path_drive_letter(nc_set.temp_path);
	if (dst_drv == 0u) dst_drv = path_drive_letter(dst->current_path);
	mb_fileop_progress_begin_title(0u, g_ui_moving);
	marks = marked_count(src);
	if (src_drv != 0u && src_drv == dst_drv)
	{
		for (i = 0u; i < src->file_count; i++)
		{
			if (marks == 0u && i != src->cursor_idx) continue;
			if (!panel_item(src, i, marks != 0u, r_action_name, &is_dir, &date, &time)) continue;
			if (is_dir && strcmp(r_action_name, "..") == 0) continue;
			result = move_samedrive_one(src, r_action_name, is_dir, date, time);
			if (result == NC_COPY_FILE_SKIP) continue;
			if (result == NC_COPY_FILE_ABORT || result == NC_COPY_FILE_ERR) { g_copy_tree_failed = 1u; break; }
			if (marks == 0u) break;
			poll_abort();
			if (g_fileop_abort) break;
		}
	}
	else
	{
		if (!panel_request_unique_page(&g_copy_io_page))
		{
			g_move_active = 0u;
			mb_ui_alert_dialog(g_ui_move, g_ui_copy_nomem);
			mb_fileop_progress_restore();
			redraw_after_dialog_cancel();
			return;
		}
		for (i = 0u; i < src->file_count; i++)
		{
			if (marks == 0u && i != src->cursor_idx) continue;
			if (!panel_item(src, i, marks != 0u, r_action_name, &is_dir, &date, &time)) continue;
			if (is_dir && strcmp(r_action_name, "..") == 0) continue;
			path_join(r_src_full, src->current_path, r_action_name);
			path_join(r_dst_full, nc_set.temp_path, r_action_name);
			progress_name(r_action_name, is_dir);
			if (is_dir)
			{
				if (OS_MKDIR((unsigned char *)r_dst_full) != 0u)
				{
					if (!mb_copy_dir_exists(r_dst_full)) { g_copy_tree_failed = 1u; break; }
					result = copy_check_dir_merge(r_dst_full);
					if (result == NC_COPY_FILE_SKIP) continue;
					if (result == NC_COPY_FILE_ABORT) { g_fileop_abort = 1u; break; }
				}
				if (!copy_tree(r_src_full, r_dst_full)) { g_copy_tree_failed = 1u; break; }
			}
			else
			{
				result = copy_file(r_src_full, r_dst_full, date, time);
				if (result == NC_COPY_FILE_SKIP) continue;
				if (result == NC_COPY_FILE_ABORT || result == NC_COPY_FILE_ERR) { g_copy_tree_failed = 1u; break; }
			}
			if (marks == 0u) break;
			poll_abort();
			if (g_fileop_abort) break;
		}
		OS_DELPAGE(g_copy_io_page); g_panel_page_used[g_copy_io_page] = 0u; g_copy_io_page = 0u;
	}
	g_move_active = 0u;
	if (g_fileop_abort) mb_copy_progress_draw_name(g_ui_cancelled);
	else if (g_copy_tree_failed) mb_ui_error_dialog(g_ui_move, g_ui_move_fail);
	mb_fileop_progress_restore();
	if (g_fileop_abort)
		redraw_after_dialog_cancel();
	else
		finish_move_success(src, dst);
}
