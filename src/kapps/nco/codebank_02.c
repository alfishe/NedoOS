#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "nc_inc.h"
#include "nc_plug.h"

/*
 * Panel data is always mapped in the C000 window.  This overlay contains no
 * mutable data: the sort and row workspaces are root BSS in nco_data.c.
 */

static void panel_meta_map(PanelState *p) { OS_SETPGC000(p->bank_ids[PANEL_META_PAGE]); }
static void panel_file_map(PanelState *p, unsigned char pg) { OS_SETPGC000(p->bank_ids[pg]); }

static unsigned int panel_meta_idx_get(const unsigned char *b, unsigned int n)
{
	const unsigned char *q = b + PANEL_META_OFF_IDX + n * 2u;
	return (unsigned int)q[0] | ((unsigned int)q[1] << 8);
}

static void panel_meta_idx_set(unsigned char *b, unsigned int n, unsigned int v)
{
	unsigned char *q = b + PANEL_META_OFF_IDX + n * 2u;
	q[0] = (unsigned char)v;
	q[1] = (unsigned char)(v >> 8);
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

void r_switch_file_page(PanelState *p, unsigned int n)
{
	unsigned char pg = (unsigned char)(n / FILES_PER_PAGE);
	if (pg >= PANEL_FILE_PAGES) pg = PANEL_FILE_PAGES - 1u;
	panel_file_map(p, pg);
}

static void panel_clear_finfo(fileInfo *fi)
{
	unsigned int i;
	unsigned char *q = (unsigned char *)fi;
	for (i = 0u; i < FILINFO_RECORD_SIZE; i++) q[i] = 0u;
}

static void panel_trim_fname(fileInfo *fi)
{
	unsigned int i;
	for (i = 0u; i < 12u && fi->fname[i] != 0 && fi->fname[i] != ' '; i++) ;
	fi->fname[i] = 0;
}

static void panel_normalize_fname(fileInfo *fi)
{
	unsigned int i;
	if (fi->fname[0] == '.')
	{
		if (fi->fname[1] == '.')
		{
			fi->fname[0] = '.'; fi->fname[1] = '.'; fi->fname[2] = 0;
			strcpy((char *)fi->lfname, ".."); return;
		}
		if (fi->fname[1] == 0)
		{
			fi->fname[0] = '.'; fi->fname[1] = 0; strcpy((char *)fi->lfname, "."); return;
		}
	}
	panel_trim_fname(fi);
	if (fi->lfname[0] != 0)
	{
		for (i = 0u; i < 63u && fi->lfname[i] != 0; i++) ;
		fi->lfname[i] = 0;
	}
}

static char *panel_entry_name(const fileInfo *fi)
{
	if (fi->lfname[0] != 0) return (char *)fi->lfname;
	return (char *)fi->fname;
}

static unsigned char panel_fold_char(unsigned char c)
{
	if (c >= 'a' && c <= 'z') return (unsigned char)(c - ('a' - 'A'));
	return c;
}

static int panel_cmp_fold(const char *a, const char *b)
{
	unsigned char i, ca, cb;
	for (i = 0u; i < 63u; i++)
	{
		ca = panel_fold_char((unsigned char)a[i]);
		cb = panel_fold_char((unsigned char)b[i]);
		if (ca != cb) return (int)ca - (int)cb;
		if (a[i] == 0) return 0;
	}
	return 0;
}

static int panel_cmp_str_fold_n(const char *a, const char *b, unsigned char n)
{
	unsigned char i, ca, cb;
	for (i = 0u; i < n; i++)
	{
		ca = panel_fold_char((unsigned char)a[i]);
		cb = panel_fold_char((unsigned char)b[i]);
		if (ca != cb) return (int)ca - (int)cb;
		if (a[i] == 0) return 0;
	}
	return 0;
}

static void panel_copy_entry_name(const fileInfo *fi, char *dst, unsigned char dst_sz)
{
	unsigned char i;
	const char *src;
	if (dst_sz == 0u) return;
	dst[0] = 0;
	src = panel_entry_name(fi);
	if (src[0] == 0) return;
	for (i = 0u; i < (unsigned char)(dst_sz - 1u) && src[i] != 0; i++)
		dst[i] = src[i];
	dst[i] = 0;
}

static void panel_name_to_key4_at(const char *name, unsigned int skip, unsigned char *k4)
{
	unsigned int i;
	for (i = 0u; i < PANEL_SORT_KEY_LEN; i++) k4[i] = 0;
	while (skip > 0u && name[0] != 0) { name++; skip--; }
	for (i = 0u; i < PANEL_SORT_KEY_LEN && name[i] != 0; i++)
		k4[i] = panel_fold_char((unsigned char)name[i]);
}

static void panel_name_to_ext4(const char *name, unsigned char *e4)
{
	unsigned int i, dot = 0u, j;
	for (i = 0u; i < PANEL_SORT_KEY_LEN; i++) e4[i] = 0;
	for (i = 0u; name[i] != 0; i++)
		if (name[i] == '.') dot = i;
	if (dot == 0u) return;
	j = 0u;
	for (i = dot + 1u; name[i] != 0 && j < PANEL_SORT_KEY_LEN - 1u; i++)
		e4[j++] = panel_fold_char((unsigned char)name[i]);
	e4[j] = 0;
}

static void panel_path_normalize(PanelState *p, const char *path)
{
	unsigned int n = 0u;
	while (path[n] != 0 && n < 63u) { p->current_path[n] = path[n]; n++; }
	p->current_path[n] = 0;
	if (n != 0u && p->current_path[n - 1u] != '/' && n < 62u)
	{
		p->current_path[n++] = '/'; p->current_path[n] = 0;
	}
}

static unsigned char panel_chdir_for_read(const char *path)
{
	char try_path[64];
	unsigned int n;
	if (OS_CHDIR((unsigned char *)path) == 0u) { OS_OPENDIR(""); return 1u; }
	strncpy(try_path, path, 63u); try_path[63] = 0;
	n = 0u; while (try_path[n] != 0) n++;
	if (n != 0u && try_path[n - 1u] == '/')
	{
		try_path[n - 1u] = 0;
		if (OS_CHDIR((unsigned char *)try_path) == 0u) { OS_OPENDIR(""); return 1u; }
	}
	return 0u;
}

static void panel_sync_path(PanelState *p)
{
	char path[64];
	OS_GETPATH(path);
	panel_path_normalize(p, path);
}

static void panel_path_basename(PanelState *p, char *out)
{
	unsigned int n = 0u, start = 0u, i;
	while (p->current_path[n] != 0 && n < 63u) n++;
	while (n != 0u && p->current_path[n - 1u] == '/') n--;
	for (i = 0u; i < n; i++)
		if (p->current_path[i] == '/') start = i + 1u;
	for (i = 0u; start < n && i < 63u; i++, start++)
		out[i] = p->current_path[start];
	out[i] = 0;
}

static void build_full_path(char *dest, const char *path, const char *name)
{
	unsigned int n = 0u, i = 0u;
	while (path[n] != 0 && n < 198u) { dest[n] = path[n]; n++; }
	if (n != 0u && dest[n - 1u] != '/' && n < 198u) dest[n++] = '/';
	while (name[i] != 0 && n < 199u) dest[n++] = name[i++];
	dest[n] = 0;
}

static unsigned char panel_entry_is_dotdot(const fileInfo *fi)
{
	return (unsigned char)(fi->fname[0] == '.' && fi->fname[1] == '.' &&
		fi->fname[2] == 0);
}

static void panel_fname_key(const unsigned char *name, unsigned char *out)
{
	unsigned char i, n = 0u;
	const unsigned char *q = name;
	for (i = 0u; i < 11u; i++) out[i] = ' ';
	while (*q != 0 && *q != '.' && n < 8u) out[n++] = panel_fold_char(*q++);
	if (*q == '.') { q++; for (i = 0u; *q != 0 && i < 3u; i++) out[8u + i] = panel_fold_char(*q++); }
}

static void panel_fi_copy(fileInfo *dst, const fileInfo *src)
{
	unsigned int i;
	unsigned char *d = (unsigned char *)dst;
	const unsigned char *s = (const unsigned char *)src;
	for (i = 0u; i < FILINFO_RECORD_SIZE; i++)
		d[i] = s[i];
}

/* Meta page must already be mapped. fi must not live in the C000 window. */
static void panel_cache_entry_meta(PanelState *p, unsigned int idx, const fileInfo *fi)
{
	unsigned char *b, key[11], kind, i;
	unsigned int off = idx * 4u;
	unsigned long fsize;
	unsigned int fdate, ftime;

	(void)p;
	fsize = fi->fsize;
	fdate = fi->fdate;
	ftime = fi->ftime;
	if (fi->fname[0] == '.' && fi->fname[1] == '.') kind = PANEL_KIND_DOTDOT;
	else if (fi->fattrib & 0x10) kind = PANEL_KIND_DIR;
	else kind = PANEL_KIND_FILE;
	panel_fname_key(fi->fname, key);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	panel_meta_idx_set(b, idx, idx);
	b[PANEL_META_OFF_KIND + idx] = kind;
	for (i = 0u; i < 4u; i++) b[PANEL_META_OFF_NAME4 + off + i] = key[i];
	for (i = 0u; i < 4u; i++) b[PANEL_META_OFF_LFN4 + off + i] = key[4u + i];
	b[PANEL_META_OFF_EXT4 + off] = key[8]; b[PANEL_META_OFF_EXT4 + off + 1u] = key[9];
	b[PANEL_META_OFF_EXT4 + off + 2u] = key[10]; b[PANEL_META_OFF_EXT4 + off + 3u] = ' ';
	*(unsigned long *)(b + PANEL_META_OFF_SIZE + idx * 4u) = fsize;
	*(unsigned short *)(b + PANEL_META_OFF_DATE + idx * 2u) = (unsigned short)fdate;
	*(unsigned short *)(b + PANEL_META_OFF_TIME + idx * 2u) = (unsigned short)ftime;
}

/* Meta page must already be mapped. fi must not live in the C000 window. */
static void panel_cache_entry_lfn_fi(PanelState *p, unsigned int idx, const fileInfo *fi)
{
	const char *disp;
	unsigned char lfn4[PANEL_SORT_KEY_LEN];
	unsigned char lfnext4[PANEL_SORT_KEY_LEN];
	unsigned char name4[PANEL_SORT_KEY_LEN];
	unsigned char ext4[PANEL_SORT_KEY_LEN];
	unsigned char *b;
	unsigned char kind;
	unsigned long fsize;
	unsigned int fdate, ftime;

	(void)p;
	if (fi->fname[0] == '.' && fi->fname[1] == '.') kind = PANEL_KIND_DOTDOT;
	else if (fi->fattrib & 0x10) kind = PANEL_KIND_DIR;
	else kind = PANEL_KIND_FILE;
	disp = panel_entry_name(fi);
	panel_name_to_key4_at(disp, 0u, lfn4);
	panel_name_to_ext4(disp, lfnext4);
	panel_name_to_key4_at(disp, 4u, name4);
	panel_name_to_key4_at(disp, 8u, ext4);
	fsize = fi->fsize;
	fdate = fi->fdate;
	ftime = fi->ftime;
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	panel_meta_idx_set(b, idx, idx);
	b[PANEL_META_OFF_KIND + idx] = kind;
	memcpy(b + PANEL_META_OFF_LFN4 + idx * PANEL_SORT_KEY_LEN, lfn4, PANEL_SORT_KEY_LEN);
	memcpy(b + PANEL_META_OFF_LFNEXT4 + idx * PANEL_SORT_KEY_LEN, lfnext4, PANEL_SORT_KEY_LEN);
	memcpy(b + PANEL_META_OFF_NAME4 + idx * PANEL_SORT_KEY_LEN, name4, PANEL_SORT_KEY_LEN);
	memcpy(b + PANEL_META_OFF_EXT4 + idx * PANEL_SORT_KEY_LEN, ext4, PANEL_SORT_KEY_LEN);
	*(unsigned long *)(b + PANEL_META_OFF_SIZE + idx * 4u) = fsize;
	*(unsigned short *)(b + PANEL_META_OFF_DATE + idx * 2u) = (unsigned short)fdate;
	*(unsigned short *)(b + PANEL_META_OFF_TIME + idx * 2u) = (unsigned short)ftime;
}

static void panel_flush_stage(PanelState *p, unsigned char page, unsigned int first_idx)
{
	unsigned char i;
	unsigned int off;

	if (g_panel_stage_n == 0u)
		return;
	panel_file_map(p, page);
	nc_set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	for (i = 0u; i < g_panel_stage_n; i++)
	{
		off = (first_idx + (unsigned int)i) % FILES_PER_PAGE;
		panel_fi_copy(&nc_set.bank_array[off], &g_panel_stage[i]);
	}
	panel_meta_map(p);
	g_panel_stage_n = 0u;
}

static int s_cmp_key4_off(unsigned char *base, unsigned int off_a, unsigned int off_b)
{
	unsigned char *a = base + off_a;
	unsigned char *b = base + off_b;
	if (a[0] != b[0]) return (int)a[0] - (int)b[0];
	if (a[1] != b[1]) return (int)a[1] - (int)b[1];
	if (a[2] != b[2]) return (int)a[2] - (int)b[2];
	if (a[3] != b[3]) return (int)a[3] - (int)b[3];
	return 0;
}

static int panel_cmp_lfn_tie_bank(PanelState *p, unsigned int pa, unsigned int pb)
{
	unsigned char page_a, page_b;
	unsigned int off_a, off_b;
	int cmp;

	page_a = (unsigned char)(pa / FILES_PER_PAGE);
	page_b = (unsigned char)(pb / FILES_PER_PAGE);
	off_a = pa % FILES_PER_PAGE;
	off_b = pb % FILES_PER_PAGE;
	nc_set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	panel_file_map(p, page_a);
	if (page_a == page_b)
		cmp = panel_cmp_str_fold_n(panel_entry_name(&nc_set.bank_array[off_a]),
								   panel_entry_name(&nc_set.bank_array[off_b]), 63u);
	else
	{
		panel_copy_entry_name(&nc_set.bank_array[off_a], g_lfn_tie_a, 64u);
		panel_file_map(p, page_b);
		panel_copy_entry_name(&nc_set.bank_array[off_b], g_lfn_tie_b, 64u);
		cmp = panel_cmp_str_fold_n(g_lfn_tie_a, g_lfn_tie_b, 63u);
	}
	panel_meta_map(p);
	return cmp;
}

static int sort_cmp_lfn(unsigned int va, unsigned int vb)
{
	unsigned int pa = s_idx[va], pb = s_idx[vb], oa = pa * 4u, ob = pb * 4u;
	unsigned char ka = s_kind[pa], kb = s_kind[pb];
	int c = 0;

	if (ka != kb)
	{
		if (ka == PANEL_KIND_DOTDOT) return -1;
		if (kb == PANEL_KIND_DOTDOT) return 1;
		if (ka == PANEL_KIND_DIR) return -1;
		if (kb == PANEL_KIND_DIR) return 1;
	}
	switch (s_mode)
	{
	case NC_PANEL_SORT_EXT:
		c = s_cmp_key4_off(s_lfnext4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_lfn4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_name4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_ext4, oa, ob);
		if (c == 0) c = panel_cmp_lfn_tie_bank(s_lfn_panel, pa, pb);
		break;
	case NC_PANEL_SORT_SIZE:
		c = s_sizes[pa] < s_sizes[pb] ? -1 : (s_sizes[pa] > s_sizes[pb] ? 1 : 0);
		if (c == 0) c = s_cmp_key4_off(s_lfn4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_name4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_ext4, oa, ob);
		if (c == 0) c = panel_cmp_lfn_tie_bank(s_lfn_panel, pa, pb);
		break;
	case NC_PANEL_SORT_TIME:
		c = s_dates[pa] < s_dates[pb] ? -1 : (s_dates[pa] > s_dates[pb] ? 1 :
			(s_times[pa] < s_times[pb] ? -1 : (s_times[pa] > s_times[pb] ? 1 : 0)));
		if (c == 0) c = s_cmp_key4_off(s_lfn4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_name4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_ext4, oa, ob);
		if (c == 0) c = panel_cmp_lfn_tie_bank(s_lfn_panel, pa, pb);
		break;
	default:
		c = s_cmp_key4_off(s_lfn4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_name4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_ext4, oa, ob);
		if (c == 0) c = panel_cmp_lfn_tie_bank(s_lfn_panel, pa, pb);
		break;
	}
	if (s_desc && c != 0) c = -c;
	return c;
}

static void heap_sift_lfn(unsigned int size, unsigned int root)
{
	unsigned int l, r, largest; unsigned short t;
	for (;;)
	{
		largest = root; l = root * 2u + 1u; r = l + 1u;
		if (l < size && sort_cmp_lfn(l, largest) > 0) largest = l;
		if (r < size && sort_cmp_lfn(r, largest) > 0) largest = r;
		if (largest == root) return;
		t = s_idx[root]; s_idx[root] = s_idx[largest]; s_idx[largest] = t; root = largest;
	}
}

static int s_cmp_cpm_tail_off(unsigned int oa, unsigned int ob)
{
	int c;

	c = s_cmp_key4_off(s_cpm4, oa, ob);
	if (c != 0)
		return c;
	/* Match nc: after CPM mid-name, compare 3-char ext (pad byte ignored). */
	if (s_ext4[oa] != s_ext4[ob]) return (int)s_ext4[oa] - (int)s_ext4[ob];
	if (s_ext4[oa + 1u] != s_ext4[ob + 1u]) return (int)s_ext4[oa + 1u] - (int)s_ext4[ob + 1u];
	if (s_ext4[oa + 2u] != s_ext4[ob + 2u]) return (int)s_ext4[oa + 2u] - (int)s_ext4[ob + 2u];
	return 0;
}

static int sort_cmp(unsigned int va, unsigned int vb)
{
	unsigned int pa = s_idx[va], pb = s_idx[vb], oa = pa * 4u, ob = pb * 4u;
	unsigned char ka = s_kind[pa], kb = s_kind[pb];
	int c = 0;

	if (ka != kb)
	{
		if (ka == PANEL_KIND_DOTDOT) return -1;
		if (kb == PANEL_KIND_DOTDOT) return 1;
		if (ka == PANEL_KIND_DIR) return -1;
		if (kb == PANEL_KIND_DIR) return 1;
	}
	switch (s_mode)
	{
	case NC_PANEL_SORT_EXT:
		/* Same ext (e.g. all dirs): must fall through to name4, not only cpm mid. */
		c = s_cmp_key4_off(s_ext4, oa, ob);
		if (c == 0) c = s_cmp_key4_off(s_name4, oa, ob);
		if (c == 0) c = s_cmp_cpm_tail_off(oa, ob);
		break;
	case NC_PANEL_SORT_SIZE:
		c = s_sizes[pa] < s_sizes[pb] ? -1 : (s_sizes[pa] > s_sizes[pb] ? 1 : 0);
		if (c == 0) c = s_cmp_key4_off(s_name4, oa, ob);
		if (c == 0) c = s_cmp_cpm_tail_off(oa, ob);
		break;
	case NC_PANEL_SORT_TIME:
		c = s_dates[pa] < s_dates[pb] ? -1 : (s_dates[pa] > s_dates[pb] ? 1 :
			(s_times[pa] < s_times[pb] ? -1 : (s_times[pa] > s_times[pb] ? 1 : 0)));
		if (c == 0) c = s_cmp_key4_off(s_name4, oa, ob);
		if (c == 0) c = s_cmp_cpm_tail_off(oa, ob);
		break;
	default:
		c = s_cmp_key4_off(s_name4, oa, ob);
		if (c == 0) c = s_cmp_cpm_tail_off(oa, ob);
		break;
	}
	if (s_desc && c != 0) c = -c;
	return c;
}

static void heap_sift(unsigned int size, unsigned int root)
{
	unsigned int l, r, largest; unsigned short t;
	for (;;)
	{
		largest = root; l = root * 2u + 1u; r = l + 1u;
		if (l < size && sort_cmp(l, largest) > 0) largest = l;
		if (r < size && sort_cmp(r, largest) > 0) largest = r;
		if (largest == root) return;
		t = s_idx[root]; s_idx[root] = s_idx[largest]; s_idx[largest] = t; root = largest;
	}
}

static void panel_heap_sort_fn83(PanelState *p)
{
	unsigned char *b; unsigned int n, i; unsigned short t;
	if (p->file_count < 2u) return;
	panel_meta_map(p); b = (unsigned char *)BANK_WINDOW_ADDRESS;
	s_kind = b + PANEL_META_OFF_KIND; s_name4 = b + PANEL_META_OFF_NAME4;
	s_ext4 = b + PANEL_META_OFF_EXT4; s_cpm4 = b + PANEL_META_OFF_LFN4;
	s_sizes = (unsigned long *)(b + PANEL_META_OFF_SIZE); s_dates = (unsigned short *)(b + PANEL_META_OFF_DATE);
	s_times = (unsigned short *)(b + PANEL_META_OFF_TIME); s_idx = (unsigned short *)(b + PANEL_META_OFF_IDX);
	s_mode = p->sort_mode; s_desc = p->sort_desc; n = p->file_count;
	for (i = n / 2u; i > 0u; i--) heap_sift(n, i - 1u);
	for (i = n; i > 1u; i--) { t = s_idx[0]; s_idx[0] = s_idx[i - 1u]; s_idx[i - 1u] = t; heap_sift(i - 1u, 0u); }
	panel_file_map(p, 0u);
}

static void panel_heap_sort_lfn(PanelState *p)
{
	unsigned char *b; unsigned int n, i; unsigned short t;
	if (p->file_count < 2u) return;
	panel_meta_map(p); b = (unsigned char *)BANK_WINDOW_ADDRESS;
	s_lfn_panel = p;
	s_kind = b + PANEL_META_OFF_KIND;
	s_lfn4 = b + PANEL_META_OFF_LFN4;
	s_lfnext4 = b + PANEL_META_OFF_LFNEXT4;
	s_name4 = b + PANEL_META_OFF_NAME4;
	s_ext4 = b + PANEL_META_OFF_EXT4;
	s_sizes = (unsigned long *)(b + PANEL_META_OFF_SIZE);
	s_dates = (unsigned short *)(b + PANEL_META_OFF_DATE);
	s_times = (unsigned short *)(b + PANEL_META_OFF_TIME);
	s_idx = (unsigned short *)(b + PANEL_META_OFF_IDX);
	s_mode = p->sort_mode; s_desc = p->sort_desc; n = p->file_count;
	for (i = n / 2u; i > 0u; i--) heap_sift_lfn(n, i - 1u);
	for (i = n; i > 1u; i--) { t = s_idx[0]; s_idx[0] = s_idx[i - 1u]; s_idx[i - 1u] = t; heap_sift_lfn(i - 1u, 0u); }
	panel_file_map(p, 0u);
}

static void panel_refresh_sort_cache(PanelState *p)
{
	unsigned int phys, off;
	unsigned char page;

	for (phys = 0u; phys < p->file_count; phys++)
	{
		page = (unsigned char)(phys / FILES_PER_PAGE);
		off = phys % FILES_PER_PAGE;
		panel_file_map(p, page);
		panel_fi_copy(&g_panel_fi, &((fileInfo *)BANK_WINDOW_ADDRESS)[off]);
		panel_meta_map(p);
		if (p->sort_lfn)
			panel_cache_entry_lfn_fi(p, phys, &g_panel_fi);
		else
			panel_cache_entry_meta(p, phys, &g_panel_fi);
	}
}

static unsigned int panel_meta_get_index(PanelState *p, unsigned int vis_idx)
{
	panel_meta_map(p);
	return panel_meta_idx_get((unsigned char *)BANK_WINDOW_ADDRESS, vis_idx);
}

static void panel_sort_indices(PanelState *p)
{
	if (!p->sort_lfn)
		panel_heap_sort_fn83(p);
	else
		panel_heap_sort_lfn(p);
}

static void panel_clamp_scroll(PanelState *p)
{
	if (p->file_count == 0u) { p->cursor_idx = 0u; p->scroll_offset = 0u; return; }
	if (p->cursor_idx >= p->file_count) p->cursor_idx = p->file_count - 1u;
	if (p->cursor_idx < p->scroll_offset) p->scroll_offset = p->cursor_idx;
	else if (p->cursor_idx >= p->scroll_offset + PANEL_VIEW_ROWS) p->scroll_offset = p->cursor_idx - PANEL_VIEW_ROWS + 1u;
}

static void panel_resort_keep_cursor(PanelState *p)
{
	unsigned int real_at_cursor, i;

	if (p->file_count == 0u) return;
	real_at_cursor = panel_meta_get_index(p, p->cursor_idx);
	panel_sort_indices(p);
	for (i = 0u; i < p->file_count; i++)
	{
		if (panel_meta_get_index(p, i) == real_at_cursor)
		{
			p->cursor_idx = i;
			break;
		}
	}
	panel_clamp_scroll(p);
}

static void panel_place_cursor_on_dotdot(PanelState *p)
{
	unsigned int i, phys; unsigned char *b;
	if (p->file_count == 0u) { panel_clamp_scroll(p); return; }
	panel_meta_map(p); b = (unsigned char *)BANK_WINDOW_ADDRESS;
	for (i = 0u; i < p->file_count; i++)
	{
		phys = panel_meta_idx_get(b, i);
		if (b[PANEL_META_OFF_KIND + phys] == PANEL_KIND_DOTDOT) { p->cursor_idx = i; p->scroll_offset = 0u; r_switch_file_page(p, phys); return; }
	}
	p->cursor_idx = p->scroll_offset = 0u; panel_file_map(p, 0u);
}

static void panel_place_cursor_on_last(PanelState *p)
{
	unsigned int phys;
	if (p->file_count == 0u) { panel_clamp_scroll(p); return; }
	p->cursor_idx = p->file_count - 1u;
	p->scroll_offset = p->file_count > PANEL_VIEW_ROWS ?
		p->file_count - PANEL_VIEW_ROWS : 0u;
	panel_clamp_scroll(p);
	panel_meta_map(p);
	phys = panel_meta_idx_get((unsigned char *)BANK_WINDOW_ADDRESS, p->cursor_idx);
	r_switch_file_page(p, phys);
}

static unsigned char panel_find_by_name(PanelState *p, const char *name, unsigned int *out)
{
	unsigned int i, n, phys;
	unsigned char *b;
	unsigned char page, scan_n;

	if (name == 0 || name[0] == 0) return 0u;
	nc_set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	for (page = 0u; page < PANEL_FILE_PAGES; page++)
	{
		panel_meta_map(p);
		b = (unsigned char *)BANK_WINDOW_ADDRESS;
		scan_n = 0u;
		for (i = 0u; i < p->file_count; i++)
		{
			phys = panel_meta_idx_get(b, i);
			if ((unsigned char)(phys / FILES_PER_PAGE) != page)
				continue;
			g_panel_scan_vis[scan_n] = i;
			g_panel_scan_phys[scan_n] = phys;
			scan_n++;
		}
		if (scan_n == 0u)
			continue;
		panel_file_map(p, page);
		for (n = 0u; n < scan_n; n++)
		{
			phys = g_panel_scan_phys[n];
			if (panel_cmp_fold(panel_entry_name(&nc_set.bank_array[phys % FILES_PER_PAGE]), name) == 0)
			{
				*out = g_panel_scan_vis[n];
				return 1u;
			}
		}
	}
	return 0u;
}

unsigned char r_read_panel_dir_at(PanelState *p, const char *path, unsigned char preserve)
{
	unsigned int idx, off, old_cursor = 0u, old_scroll = 0u, restore, phys, stage_first;
	unsigned char page = 0u, res, saved = 0u, is_dir;
	char req[64], saved_name[64];

	if (!panel_banks_ok(p)) { p->file_count = 0u; p->files_only_count = 0u; p->total_bytes = 0UL; panel_clamp_scroll(p); return 0u; }
	panel_path_normalize(p, path); strncpy(req, p->current_path, 63u); req[63] = 0;
	if (preserve && p->file_count != 0u && p->cursor_idx < p->file_count)
	{
		panel_meta_map(p);
		phys = panel_meta_idx_get((unsigned char *)BANK_WINDOW_ADDRESS, p->cursor_idx);
		r_switch_file_page(p, phys);
		off = phys % FILES_PER_PAGE;
		strncpy(saved_name, panel_entry_name(&nc_set.bank_array[off]), 63u); saved_name[63] = 0;
		old_cursor = p->cursor_idx; old_scroll = p->scroll_offset; saved = 1u;
	}
	if (!panel_chdir_for_read(req)) { p->file_count = p->files_only_count = 0u; p->total_bytes = 0UL; panel_clamp_scroll(p); panel_file_map(p, 0u); return 0u; }

	idx = 0u; p->files_only_count = 0u; p->total_bytes = 0UL; g_panel_stage_n = 0u; stage_first = 0u;
	panel_meta_map(p); memset((void *)(BANK_WINDOW_ADDRESS + PANEL_META_OFF_MARK), 0, PANEL_META_MARK_BYTES);
	p->marked_count = 0u; p->marked_bytes = 0UL;

	while (idx < MAX_FILES_PER_PANEL)
	{
		off = idx % FILES_PER_PAGE;
		if (idx != 0u && off == 0u)
		{
			panel_flush_stage(p, page, stage_first);
			if (++page >= PANEL_FILE_PAGES) break;
			stage_first = idx;
		}

		g_panel_fi.lfname[0] = 0;
		res = OS_READDIR(&g_panel_fi);
		if (res != 0u) break;
		panel_normalize_fname(&g_panel_fi);
		if ((g_panel_fi.fname[0] == '.' && g_panel_fi.fname[1] == 0) || g_panel_fi.fname[0] == 0) continue;

		is_dir = (g_panel_fi.fattrib & 0x10) ? 1u : 0u;
		panel_meta_map(p);
		if (p->sort_lfn)
			panel_cache_entry_lfn_fi(p, idx, &g_panel_fi);
		else
			panel_cache_entry_meta(p, idx, &g_panel_fi);
		if (!is_dir) { p->files_only_count++; p->total_bytes += g_panel_fi.fsize; }

		if (g_panel_stage_n == 0u)
			stage_first = idx;
		panel_fi_copy(&g_panel_stage[g_panel_stage_n], &g_panel_fi);
		g_panel_stage_n++;
		if (g_panel_stage_n >= PANEL_READ_STAGE || off + 1u >= FILES_PER_PAGE)
			panel_flush_stage(p, page, stage_first);

		idx++;
	}
	panel_flush_stage(p, page, stage_first);

	p->file_count = idx;
	if (idx >= 2u)
	{
		if (idx > PANEL_SORT_NOTICE_FILES) m_panel_sort_notice_show(p);
		panel_sort_indices(p);
	}
	else
		panel_file_map(p, 0u);

	if (saved && panel_find_by_name(p, saved_name, &restore)) { p->cursor_idx = restore; p->scroll_offset = old_scroll; panel_clamp_scroll(p); }
	else if (saved) { p->cursor_idx = old_cursor; p->scroll_offset = old_scroll; panel_clamp_scroll(p); }
	else panel_place_cursor_on_dotdot(p);
	panel_path_normalize(p, req);
	return 1u;
}

void r_panels_remap_bank_window(void)
{
	PanelState *p = left_panel.file_count != 0u ? &left_panel : &right_panel;
	unsigned int vis = p->scroll_offset, phys;
	if (p->file_count == 0u) { panel_file_map(p, 0u); return; }
	if (vis >= p->file_count) vis = 0u;
	panel_meta_map(p); phys = panel_meta_idx_get((unsigned char *)BANK_WINDOW_ADDRESS, vis); r_switch_file_page(p, phys);
}

static unsigned char panel_exec(const fileInfo *fi)
{
	const unsigned char *n = fi->fname; unsigned char i, dot = 255u;
	if (fi->fattrib & 0x10) return 0u;
	for (i = 0u; i < 12u && n[i] != 0; i++) if (n[i] == '.') dot = i;
	return dot != 255u && panel_fold_char(n[dot + 1u]) == 'c' && panel_fold_char(n[dot + 2u]) == 'o' && panel_fold_char(n[dot + 3u]) == 'm' && n[dot + 4u] == 0;
}

static void fmt_pad(char *d, const char *s, unsigned char w)
{
	unsigned char i = 0u; while (i < w && s[i] != 0) { d[i] = s[i]; i++; } while (i < w) d[i++] = ' ';
}

static void fmt_datetime(char *d, unsigned int date, unsigned int time)
{
	unsigned char m = (unsigned char)((date >> 5) & 15u);
	d[0] = '0' + (date & 31u) / 10u; d[1] = '0' + (date & 31u) % 10u;
	d[2] = m >= 1u && m <= 12u ? g_month_abbr[m - 1u][0] : '?'; d[3] = m >= 1u && m <= 12u ? g_month_abbr[m - 1u][1] : '?';
	d[4] = '0' + (((date >> 9) + 80u) % 100u) / 10u; d[5] = '0' + (((date >> 9) + 80u) % 100u) % 10u;
	d[6] = ' '; d[7] = '0' + ((time >> 11) & 31u) / 10u; d[8] = '0' + ((time >> 11) & 31u) % 10u;
	d[9] = ':'; d[10] = '0' + ((time >> 5) & 63u) / 10u; d[11] = '0' + ((time >> 5) & 63u) % 10u;
}

static void row_format(const fileInfo *fi, char *d, unsigned char *color)
{
	unsigned char i, is_dir = (fi->fattrib & 0x10) ? 1u : 0u;
	*color = is_dir ? NC_COLOR_PANEL : (panel_exec(fi) ? NC_COLOR_PANEL_EXEC : NC_COLOR_PANEL_FILE);
	for (i = 0u; i < PANEL_ROW_WIDTH; i++) d[i] = ' ';
	if (g_ini_panel_brief) { fmt_pad(d, panel_entry_name(fi), NC_PANEL_BRIEF_NAME_W); d[28] = 179; panel_fmt_size_brief(d + 29, fi->fsize, is_dir); }
	else { fmt_pad(d, panel_entry_name(fi), 18u); d[18] = 179; panel_fmt_size(d + 19, fi->fsize, is_dir); d[25] = 179; fmt_datetime(d + 26, fi->fdate, fi->ftime); }
}

static void row_out(unsigned char x, unsigned char y, unsigned int vis, PanelState *p, const char *row, unsigned char color, unsigned char marked)
{
	unsigned char i; OS_SETXY((unsigned char)(x + 1u), (unsigned char)(y + 3u));
	if (vis == p->cursor_idx && p->is_active) OS_SETCOLOR(marked ? NC_COLOR_CURSOR : NC_COLOR_CURSOR);
	else OS_SETCOLOR(marked ? NC_COLOR_PANEL_MARK : color);
	for (i = 0u; i < PANEL_ROW_WIDTH; i++) putchar((unsigned char)row[i]);
}

static void row_format_empty(char *d, unsigned char *color)
{
	unsigned char i;

	*color = NC_COLOR_PANEL;
	for (i = 0u; i < PANEL_ROW_WIDTH; i++)
		d[i] = ' ';
	if (g_ini_panel_brief)
		d[NC_PANEL_BRIEF_NAME_W] = (char)179;
	else
	{
		d[18] = (char)179;
		d[25] = (char)179;
	}
}

static void panel_draw_vis_row(PanelState *p, unsigned char x, unsigned char row_y, unsigned int vis)
{
	unsigned char *b;
	unsigned int phys;
	unsigned char color;
	unsigned char marked;
	fileInfo *fi;

	if (vis >= p->file_count)
	{
		row_format_empty(g_panel_row, &color);
		row_out(x, row_y, vis, p, g_panel_row, color, 0u);
		return;
	}
	panel_meta_map(p);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	phys = panel_meta_idx_get(b, vis);
	marked = b[PANEL_META_OFF_MARK + phys];
	r_switch_file_page(p, phys);
	fi = &((fileInfo *)BANK_WINDOW_ADDRESS)[phys % FILES_PER_PAGE];
	row_format(fi, g_panel_row, &color);
	row_out(x, row_y, vis, p, g_panel_row, color, marked);
}

static void panel_draw_file_line(PanelState *p, unsigned char x, unsigned int file_idx)
{
	unsigned char row_y;

	if (file_idx < p->scroll_offset || file_idx >= p->scroll_offset + PANEL_VIEW_ROWS)
		return;
	row_y = (unsigned char)(file_idx - p->scroll_offset);
	panel_draw_vis_row(p, x, row_y, file_idx);
}

/* Draw cursor row and fill g_bottom_snap from the same mapped fileInfo. */
static void panel_draw_cursor_bottom(PanelState *p, unsigned char x, unsigned int file_idx)
{
	unsigned char *b;
	unsigned int phys;
	unsigned char color;
	unsigned char marked;
	unsigned char row_y;
	unsigned char i;
	fileInfo *fi;
	const char *name;

	g_bottom_snap.mode = NC_BOTTOM_EMPTY;
	g_bottom_snap.cmd_cursor = 0u;
	g_bottom_snap.cmd_line[0] = 0;
	g_bottom_snap.name[0] = 0;
	g_bottom_snap.f_size = 0UL;
	g_bottom_snap.is_dir = 1u;

	if (file_idx < p->scroll_offset || file_idx >= p->scroll_offset + PANEL_VIEW_ROWS)
		return;
	row_y = (unsigned char)(file_idx - p->scroll_offset);
	if (file_idx >= p->file_count)
	{
		panel_draw_vis_row(p, x, row_y, file_idx);
		return;
	}

	panel_meta_map(p);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	phys = panel_meta_idx_get(b, file_idx);
	marked = b[PANEL_META_OFF_MARK + phys];
	r_switch_file_page(p, phys);
	fi = &((fileInfo *)BANK_WINDOW_ADDRESS)[phys % FILES_PER_PAGE];
	row_format(fi, g_panel_row, &color);
	row_out(x, row_y, file_idx, p, g_panel_row, color, marked);

	if (file_idx == p->cursor_idx && p->is_active)
	{
		name = panel_entry_name(fi);
		for (i = 0u; i < 64u && name[i] != 0; i++)
			g_bottom_snap.name[i] = name[i];
		g_bottom_snap.name[i] = 0;
		g_bottom_snap.f_size = fi->fsize;
		g_bottom_snap.is_dir = (fi->fattrib & 0x10) ? 1u : 0u;
		g_bottom_snap.mode = NC_BOTTOM_FILE;
	}
}

static void panel_nav_redraw(PanelState *p, unsigned char x,
							 unsigned int old_idx, unsigned int old_scroll);

static void panel_mark_toggle(PanelState *p, unsigned char start_x)
{
	unsigned char *b;
	unsigned int phys, old_idx, old_scroll;
	unsigned char kind, on;
	unsigned long fsize;

	if (p->file_count == 0u)
		return;
	panel_meta_map(p);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	phys = panel_meta_idx_get(b, p->cursor_idx);
	kind = b[PANEL_META_OFF_KIND + phys];
	if (kind == PANEL_KIND_DOTDOT)
		return;
	on = b[PANEL_META_OFF_MARK + phys];
	b[PANEL_META_OFF_MARK + phys] = (unsigned char)(on ? 0u : 1u);
	fsize = *(unsigned long *)(b + PANEL_META_OFF_SIZE + phys * 4u);
	if (on == 0u)
	{
		p->marked_count++;
		if (kind == PANEL_KIND_FILE)
			p->marked_bytes += fsize;
	}
	else
	{
		if (p->marked_count != 0u)
			p->marked_count--;
		if (kind == PANEL_KIND_FILE)
		{
			if (p->marked_bytes >= fsize)
				p->marked_bytes -= fsize;
			else
				p->marked_bytes = 0UL;
		}
	}
	/* nc: redraw marked line + footer only (not full background ?
	 * r_draw_panel_background clears the file area with spaces). */
	old_idx = p->cursor_idx;
	old_scroll = p->scroll_offset;
	panel_draw_file_line(p, start_x, old_idx);
	draw_panel_footer(p, start_x);
	if (old_idx + 1u >= p->file_count)
	{
		r_fill_bottom_snap(&g_bottom_snap);
		return;
	}
	p->cursor_idx = old_idx + 1u;
	if (p->cursor_idx >= p->scroll_offset + PANEL_VIEW_ROWS)
		p->scroll_offset = p->cursor_idx - PANEL_VIEW_ROWS + 1u;
	panel_nav_redraw(p, start_x, old_idx, old_scroll);
	draw_panel_footer(p, start_x);
}

static void panel_nav_redraw(PanelState *p, unsigned char x,
							 unsigned int old_idx, unsigned int old_scroll)
{
	if (p->scroll_offset == old_scroll + 1u)
	{
		panel_files_scroll_up(x);
		panel_draw_vis_row(p, x, 16u, p->scroll_offset + 16u);
		panel_draw_cursor_bottom(p, x, p->cursor_idx);
	}
	else if (p->scroll_offset + 1u == old_scroll)
	{
		panel_files_scroll_down(x);
		if (p->scroll_offset + 1u < p->file_count)
			panel_draw_vis_row(p, x, 1u, p->scroll_offset + 1u);
		panel_draw_cursor_bottom(p, x, p->cursor_idx);
	}
	else if (p->scroll_offset != old_scroll)
	{
		r_draw_panel(p, x, PANEL_VIEW_ROWS);
		r_fill_bottom_snap(&g_bottom_snap);
	}
	else
	{
		panel_draw_file_line(p, x, old_idx);
		panel_draw_cursor_bottom(p, x, p->cursor_idx);
	}
}

void r_draw_panel(PanelState *p, unsigned char x, unsigned char height)
{
	unsigned char i, last = 255u, pg, color, *b; unsigned int vis, phys;
	if (height > PANEL_VIEW_ROWS) height = PANEL_VIEW_ROWS;
	for (i = 0u; i < height; i++) { g_panel_row_marked_row[i] = 0u; g_panel_row_phys[i] = 0xffffu; }
	if (p->file_count != 0u)
	{
		panel_meta_map(p); b = (unsigned char *)BANK_WINDOW_ADDRESS;
		for (i = 0u; i < height; i++) { vis = p->scroll_offset + i; if (vis < p->file_count) { phys = panel_meta_idx_get(b, vis); g_panel_row_phys[i] = phys; g_panel_row_marked_row[i] = b[PANEL_META_OFF_MARK + phys]; } }
	}
	nc_set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;
	for (i = 0u; i < height; i++)
	{
		phys = g_panel_row_phys[i]; vis = p->scroll_offset + i;
		if (phys == 0xffffu)
			row_format_empty(g_panel_rows[i], &color);
		else { pg = (unsigned char)(phys / FILES_PER_PAGE); if (pg != last) { panel_file_map(p, pg); last = pg; } row_format(&nc_set.bank_array[phys % FILES_PER_PAGE], g_panel_rows[i], &color); }
		g_panel_row_colors[i] = color; row_out(x, i, vis, p, g_panel_rows[i], color, g_panel_row_marked_row[i]);
	}
}

void r_panels_reload_both(const char *l, const char *r)
{
	if (left_panel.is_active) { r_read_panel_dir_at(&left_panel, l, 1u); r_read_panel_dir_at(&right_panel, r, 1u); }
	else { r_read_panel_dir_at(&right_panel, r, 1u); r_read_panel_dir_at(&left_panel, l, 1u); }
	if (left_panel.is_active) OS_CHDIR((unsigned char *)left_panel.current_path); else OS_CHDIR((unsigned char *)right_panel.current_path);
}

void r_panels_paint_both(void) { r_draw_panel(&left_panel, 0u, PANEL_VIEW_ROWS); r_draw_panel(&right_panel, 40u, PANEL_VIEW_ROWS); }
void r_panels_draw_all(void) { r_panels_paint_both(); }

void r_fill_bottom_snap(NCBottomInfo *snap)
{
	PanelState *p = left_panel.is_active ? &left_panel : &right_panel;
	unsigned char *b;
	unsigned int phys, i;
	fileInfo *fi;
	const char *name;

	snap->mode = NC_BOTTOM_EMPTY;
	snap->cmd_cursor = 0u;
	snap->cmd_line[0] = 0;
	snap->name[0] = 0;
	snap->f_size = 0UL;
	snap->is_dir = 1u;
	if (p->file_count == 0u) return;

	panel_clamp_scroll(p);
	panel_meta_map(p);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	phys = panel_meta_idx_get(b, p->cursor_idx);
	r_switch_file_page(p, phys);
	fi = &((fileInfo *)BANK_WINDOW_ADDRESS)[phys % FILES_PER_PAGE];
	name = panel_entry_name(fi);
	for (i = 0u; i < 64u && name[i] != 0; i++)
		snap->name[i] = name[i];
	snap->name[i] = 0;
	snap->f_size = fi->fsize;
	snap->is_dir = (fi->fattrib & 0x10) ? 1u : 0u;
	snap->mode = NC_BOTTOM_FILE;
}

static void panel_enter_dir(PanelState *p, unsigned char start_x)
{
	unsigned char *b;
	unsigned int phys, i;
	fileInfo *fi;

	if (p->file_count == 0u || !panel_chdir_for_read(p->current_path)) return;
	panel_meta_map(p);
	b = (unsigned char *)BANK_WINDOW_ADDRESS;
	phys = panel_meta_idx_get(b, p->cursor_idx);
	r_switch_file_page(p, phys);
	fi = &((fileInfo *)BANK_WINDOW_ADDRESS)[phys % FILES_PER_PAGE];
	if ((fi->fattrib & 0x10) == 0u) return;

	if (panel_entry_is_dotdot(fi))
	{
		panel_path_basename(p, nc_set.exited_dir_name);
		OS_CHDIR((unsigned char *)"..");
		panel_sync_path(p);
		r_read_panel_dir_at(p, p->current_path, 1u);
		if (nc_set.exited_dir_name[0] != 0)
		{
			for (i = 0u; i < p->file_count; i++)
			{
				panel_meta_map(p);
				phys = panel_meta_idx_get((unsigned char *)BANK_WINDOW_ADDRESS, i);
				r_switch_file_page(p, phys);
				fi = &((fileInfo *)BANK_WINDOW_ADDRESS)[phys % FILES_PER_PAGE];
				if (strcmp(panel_entry_name(fi), nc_set.exited_dir_name) == 0)
				{
					p->cursor_idx = i;
					panel_clamp_scroll(p);
					break;
				}
			}
		}
	}
	else
	{
		build_full_path(g_panel_enter_path, p->current_path, panel_entry_name(fi));
		r_read_panel_dir_at(p, g_panel_enter_path, 0u);
	}
	draw_panel_background(p, start_x);
	r_draw_panel(p, start_x, PANEL_VIEW_ROWS);
	r_fill_bottom_snap(&g_bottom_snap);
}

unsigned char r_panel_nav_key(unsigned char key)
{
	PanelState *p = left_panel.is_active ? &left_panel : &right_panel;
	unsigned char start_x = left_panel.is_active ? 0u : 40u;
	unsigned int old_idx;
	unsigned int old_scroll;

	if (key == NC_KEY_TAB)
	{
		left_panel.is_active = !left_panel.is_active;
		right_panel.is_active = !right_panel.is_active;
		panel_draw_file_line(&left_panel, 0u, left_panel.cursor_idx);
		panel_draw_file_line(&right_panel, 40u, right_panel.cursor_idx);
		r_fill_bottom_snap(&g_bottom_snap);
		return 1u;
	}

	old_idx = p->cursor_idx;
	old_scroll = p->scroll_offset;

	if (key == NC_KEY_HOME)
	{
		panel_place_cursor_on_dotdot(p);
		r_draw_panel(p, start_x, PANEL_VIEW_ROWS);
		r_fill_bottom_snap(&g_bottom_snap);
		return 1u;
	}
	if (key == NC_KEY_END)
	{
		panel_place_cursor_on_last(p);
		r_draw_panel(p, start_x, PANEL_VIEW_ROWS);
		r_fill_bottom_snap(&g_bottom_snap);
		return 1u;
	}
	if (key == NC_KEY_UP)
	{
		if (p->cursor_idx == 0u) return 1u;
		p->cursor_idx--;
		if (p->cursor_idx < p->scroll_offset)
			p->scroll_offset = p->cursor_idx;
		panel_nav_redraw(p, start_x, old_idx, old_scroll);
		return 1u;
	}
	if (key == NC_KEY_DOWN)
	{
		if (p->cursor_idx + 1u >= p->file_count) return 1u;
		p->cursor_idx++;
		if (p->cursor_idx >= p->scroll_offset + PANEL_VIEW_ROWS)
			p->scroll_offset = p->cursor_idx - PANEL_VIEW_ROWS + 1u;
		panel_nav_redraw(p, start_x, old_idx, old_scroll);
		return 1u;
	}
	if (key == NC_KEY_PGUP)
	{
		if (p->cursor_idx > PANEL_VIEW_ROWS) p->cursor_idx -= PANEL_VIEW_ROWS;
		else p->cursor_idx = 0u;
		if (p->cursor_idx < p->scroll_offset)
			p->scroll_offset = p->cursor_idx;
		panel_nav_redraw(p, start_x, old_idx, old_scroll);
		return 1u;
	}
	if (key == NC_KEY_PGDN)
	{
		if (p->file_count == 0u) return 1u;
		if (p->cursor_idx + PANEL_VIEW_ROWS < p->file_count)
			p->cursor_idx += PANEL_VIEW_ROWS;
		else
			p->cursor_idx = p->file_count - 1u;
		if (p->cursor_idx >= p->scroll_offset + PANEL_VIEW_ROWS)
			p->scroll_offset = p->cursor_idx - PANEL_VIEW_ROWS + 1u;
		panel_nav_redraw(p, start_x, old_idx, old_scroll);
		return 1u;
	}
	if (key == NC_KEY_ENTER)
	{
		unsigned char *b;
		unsigned int phys;
		fileInfo *fi;

		if (p->file_count == 0u) return 0u;
		panel_meta_map(p);
		b = (unsigned char *)BANK_WINDOW_ADDRESS;
		phys = panel_meta_idx_get(b, p->cursor_idx);
		r_switch_file_page(p, phys);
		fi = &((fileInfo *)BANK_WINDOW_ADDRESS)[phys % FILES_PER_PAGE];
		if ((fi->fattrib & 0x10) == 0u) return 0u;
		panel_enter_dir(p, start_x);
		return 1u;
	}
	if (key == NC_KEY_MARK_INS || key == NC_KEY_MARK_STAR)
	{
		panel_mark_toggle(p, start_x);
		return 1u;
	}
	return 0u;
}

void r_panel_menu_apply(unsigned char choice)
{
	PanelState *panel = g_menu_panel;

	(void)choice;
	if (panel == NULL)
		panel = left_panel.is_active ? &left_panel : &right_panel;
	if (panel->file_count == 0u)
		return;
	/* After in-menu toggles (arrows / Enter cycle): refresh LFN keys if needed, then resort. */
	if (panel->sort_lfn)
		panel_refresh_sort_cache(panel);
	if (panel->file_count >= 2u)
		panel_resort_keep_cursor(panel);
}
