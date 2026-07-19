#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>

#include "zip.h"
#include "crc32.h"
#include "deflate.h"
#include "winmem.h"

/* Below this size, skip deflate (temp+CPU overhead dominates). */
#define STORE_ONLY_MAX 512UL

#define FS_FLAGS 0x80u
#define FS_ERR(fp) ((unsigned int)(fp) & 0xffu)
#define FS_HND(fp) ((FILE *)(unsigned int)(fp))

#define SIG_LOCAL 0x04034b50UL
#define SIG_CENTRAL 0x02014b50UL
#define SIG_EOCD 0x06054b50UL

#define METH_STORE 0
#define METH_DEFLATE 8
#define ATTR_DIR 0x10u

#define PATH_MAX 180
#define IO_CHUNK 1024

/* CD / deflate temps on disk ? no RAM entry cap (EOCD still max 65535). */
#define CD_TEMP "pkzip2.cd$"
#define DF_TEMP "pkzip2.df$"

static unsigned char g_buf[IO_CHUNK];
static unsigned char g_hdr[46];
static unsigned char g_prefix[PATH_MAX];
static unsigned char g_zipname[PATH_MAX];
static unsigned char g_pathbuf[PATH_MAX];
static unsigned char g_localname[64];

static fileInfo g_fi; /* global: keep recursion stack tiny */

static unsigned int g_preflen;
static unsigned int g_nent;
static unsigned long g_pos;	  /* archive write offset */
static unsigned long g_cd_size; /* bytes in CD temp */
static FILE *g_cdh;
static FILE g_cdhold;

static void wr16(unsigned char *p, unsigned int v)
{
	p[0] = (unsigned char)v;
	p[1] = (unsigned char)(v >> 8);
}

static void wr32(unsigned char *p, unsigned long v)
{
	p[0] = (unsigned char)v;
	p[1] = (unsigned char)(v >> 8);
	p[2] = (unsigned char)(v >> 16);
	p[3] = (unsigned char)(v >> 24);
}

static int write_fully(FILE *h, const unsigned char *buf, unsigned int n)
{
	unsigned int got;

	while (n)
	{
		got = OS_WRITEHANDLE((unsigned char *)buf, h, n);
		if (got == 0)
			return -1;
		buf += got;
		n = (unsigned int)(n - got);
		g_pos += got;
	}
	return 0;
}

static int cd_write(const unsigned char *buf, unsigned int n)
{
	unsigned int got;

	while (n)
	{
		got = OS_WRITEHANDLE((unsigned char *)buf, g_cdh, n);
		if (got == 0)
			return -1;
		buf += got;
		n = (unsigned int)(n - got);
		g_cd_size += got;
	}
	return 0;
}

static void slash_fix(unsigned char *s)
{
	while (*s)
	{
		if (*s == '\\')
			*s = '/';
		s++;
	}
}

static int is_dot_entry(const unsigned char *name)
{
	if (name[0] != '.')
		return 0;
	if (name[1] == 0)
		return 1;
	if (name[1] == '.' && name[2] == 0)
		return 1;
	return 0;
}

static void fi_name(fileInfo *fi, unsigned char *out)
{
	if (fi->lfname[0] != 0)
		strcpy((char *)out, (char *)fi->lfname);
	else
		strcpy((char *)out, (char *)fi->fname);
}

/*
 * Re-open cwd and return the n-th real entry (skip . / ..).
 * Safe across CHDIR into children (enumeration state is not kept).
 */
static int get_nth_entry(unsigned int n, fileInfo *fi)
{
	unsigned int idx;
	unsigned char res;

	OS_OPENDIR((unsigned char *)"");
	idx = 0;
	for (;;)
	{
		res = OS_READDIR(fi);
		if (res != 0)
			return -1;
		if (is_dot_entry(fi->fname))
			continue;
		if (fi->lfname[0] != 0 && is_dot_entry(fi->lfname))
			continue;
		if (idx == n)
			return 0;
		idx++;
	}
}

static int prefix_push(const unsigned char *name)
{
	unsigned int i;
	unsigned int n;

	n = (unsigned int)strlen((const char *)name);
	if (g_preflen + n + 2u >= PATH_MAX)
	{
		printf("Path too long\r\n");
		return -1;
	}
	i = 0;
	while (i < n)
	{
		g_prefix[g_preflen++] = name[i++];
	}
	g_prefix[g_preflen++] = '/';
	g_prefix[g_preflen] = 0;
	return 0;
}

static void prefix_pop(unsigned int oldlen)
{
	g_preflen = oldlen;
	g_prefix[g_preflen] = 0;
}

static int make_zip_name(const unsigned char *leaf, unsigned char *out, unsigned int *olen, int as_dir)
{
	unsigned int i;
	unsigned int n;

	i = 0;
	while (i < g_preflen)
	{
		out[i] = g_prefix[i];
		i++;
	}
	n = 0;
	while (leaf[n] != 0 && i < (PATH_MAX - 2u))
	{
		out[i++] = leaf[n++];
	}
	if (as_dir)
	{
		if (i == 0 || out[i - 1] != '/')
			out[i++] = '/';
	}
	out[i] = 0;
	slash_fix(out);
	*olen = i;
	if (*olen == 0 || *olen >= PATH_MAX)
		return -1;
	return 0;
}

static int cd_append_record(
	unsigned long local_off,
	unsigned long usize,
	unsigned long csize,
	unsigned long crc,
	unsigned int namelen,
	const unsigned char *name,
	unsigned int method,
	int is_dir)
{
	if (g_nent == 0xffffu)
	{
		printf("Too many entries (ZIP limit 65535)\r\n");
		return -1;
	}

	wr32(g_hdr, SIG_CENTRAL);
	wr16(g_hdr + 4, 20);
	wr16(g_hdr + 6, 20);
	wr16(g_hdr + 8, 0);
	wr16(g_hdr + 10, method);
	wr16(g_hdr + 12, 0);
	wr16(g_hdr + 14, 0);
	wr32(g_hdr + 16, crc);
	wr32(g_hdr + 20, csize);
	wr32(g_hdr + 24, usize);
	wr16(g_hdr + 28, namelen);
	wr16(g_hdr + 30, 0);
	wr16(g_hdr + 32, 0);
	wr16(g_hdr + 34, 0);
	wr16(g_hdr + 36, 0);
	/* MS-DOS attribute byte in low byte of external attrs. */
	wr32(g_hdr + 38, is_dir ? 0x10UL : 0UL);
	wr32(g_hdr + 42, local_off);

	if (cd_write(g_hdr, 46) != 0)
		return -1;
	if (cd_write(name, namelen) != 0)
		return -1;
	g_nent++;
	return 0;
}

static int copy_n(FILE *dst, FILE *src, unsigned long nbytes)
{
	unsigned long left;
	unsigned int got;
	unsigned int n;

	left = nbytes;
	while (left)
	{
		n = IO_CHUNK;
		if ((unsigned long)n > left)
			n = (unsigned int)left;
		got = OS_READHANDLE(g_buf, src, n);
		if (got == 0u)
			return -1;
		if (write_fully(dst, g_buf, got) != 0)
			return -1;
		left -= got;
	}
	return 0;
}

/* One-pass CRC of whole file (src left at EOF). */
static int crc_whole(FILE *src, unsigned long nbytes, unsigned long *crc_out)
{
	unsigned long left;
	unsigned int got;
	unsigned int n;

	crc32_reset();
	left = nbytes;
	while (left)
	{
		n = IO_CHUNK;
		if ((unsigned long)n > left)
			n = (unsigned int)left;
		got = OS_READHANDLE(g_buf, src, n);
		if (got == 0u)
			return -1;
		crc32_update(g_buf, got);
		left -= got;
	}
	*crc_out = crc32_get();
	return 0;
}

static int add_dir_entry(FILE *zh, const unsigned char *zip_name, unsigned int namelen)
{
	unsigned long local_off;

	printf("%s\r\n", zip_name);

	local_off = g_pos;
	wr32(g_hdr, SIG_LOCAL);
	wr16(g_hdr + 4, 20);
	wr16(g_hdr + 6, 0);
	wr16(g_hdr + 8, METH_STORE);
	wr16(g_hdr + 10, 0);
	wr16(g_hdr + 12, 0);
	wr32(g_hdr + 14, 0UL);
	wr32(g_hdr + 18, 0UL);
	wr32(g_hdr + 22, 0UL);
	wr16(g_hdr + 26, namelen);
	wr16(g_hdr + 28, 0);

	if (write_fully(zh, g_hdr, 30) != 0)
		return -1;
	if (write_fully(zh, zip_name, namelen) != 0)
		return -1;

	return cd_append_record(local_off, 0UL, 0UL, 0UL, namelen, zip_name, METH_STORE, 1);
}

static int add_file(FILE *zh, const char *fs_path, const unsigned char *zip_name, unsigned int namelen)
{
	FILE *fh;
	FILE fhold;
	FILE *df;
	FILE dfhold;
	unsigned long fsize;
	unsigned long csize;
	unsigned long local_off;
	unsigned long crc;
	unsigned int method;
	int use_deflate;

	df = 0;
	dfhold = 0;

	fh = OS_OPENHANDLE((unsigned char *)fs_path, FS_FLAGS);
	if (FS_ERR(fh) != 0)
	{
		printf("Cannot open %s\r\n", fs_path);
		return -1;
	}
	fhold = (FILE)(unsigned int)fh;
	fsize = OS_GETFILESIZE(FS_HND(fhold));

	printf("%s", zip_name);

	crc = 0UL;
	csize = fsize;
	method = METH_STORE;
	use_deflate = 0;

	if (fsize > 0UL && fsize < STORE_ONLY_MAX)
	{
		/* Tiny file: store only (deflate temp overhead not worth it). */
		OS_SEEKHANDLE(FS_HND(fhold), 0UL);
		if (crc_whole(FS_HND(fhold), fsize, &crc) != 0)
		{
			OS_CLOSEHANDLE(FS_HND(fhold));
			printf("\r\nRead error: %s\r\n", fs_path);
			return -1;
		}
	}
	else if (fsize >= STORE_ONLY_MAX)
	{
		df = OS_CREATEHANDLE((unsigned char *)DF_TEMP, FS_FLAGS);
		if (FS_ERR(df) != 0)
		{
			OS_CLOSEHANDLE(FS_HND(fhold));
			printf("\r\nCannot create temp %s\r\n", DF_TEMP);
			return -1;
		}
		dfhold = (FILE)(unsigned int)df;

		OS_SEEKHANDLE(FS_HND(fhold), 0UL);
		if (deflate_to_handle(FS_HND(fhold), FS_HND(dfhold), fsize, &csize, &crc) != 0)
		{
			OS_CLOSEHANDLE(FS_HND(dfhold));
			OS_DELETE((unsigned char *)DF_TEMP);
			OS_CLOSEHANDLE(FS_HND(fhold));
			printf("\r\nDeflate error: %s\r\n", fs_path);
			return -1;
		}

		if (csize < fsize)
		{
			use_deflate = 1;
			method = METH_DEFLATE;
		}
		else
		{
			csize = fsize;
			method = METH_STORE;
		}
	}
	printf("\r\n");

	local_off = g_pos;
	wr32(g_hdr, SIG_LOCAL);
	wr16(g_hdr + 4, 20);
	wr16(g_hdr + 6, 0);
	wr16(g_hdr + 8, method);
	wr16(g_hdr + 10, 0);
	wr16(g_hdr + 12, 0);
	wr32(g_hdr + 14, crc);
	wr32(g_hdr + 18, csize);
	wr32(g_hdr + 22, fsize);
	wr16(g_hdr + 26, namelen);
	wr16(g_hdr + 28, 0);

	if (write_fully(zh, g_hdr, 30) != 0)
		goto fail;
	if (write_fully(zh, zip_name, namelen) != 0)
		goto fail;

	if (fsize == 0UL)
	{
		OS_CLOSEHANDLE(FS_HND(fhold));
		return cd_append_record(local_off, 0UL, 0UL, 0UL, namelen, zip_name, METH_STORE, 0);
	}

	if (use_deflate)
	{
		OS_SEEKHANDLE(FS_HND(dfhold), 0UL);
		if (copy_n(zh, FS_HND(dfhold), csize) != 0)
			goto fail;
	}
	else
	{
		OS_SEEKHANDLE(FS_HND(fhold), 0UL);
		if (copy_n(zh, FS_HND(fhold), fsize) != 0)
			goto fail;
	}

	if (df != 0)
	{
		OS_CLOSEHANDLE(FS_HND(dfhold));
		OS_DELETE((unsigned char *)DF_TEMP);
	}
	OS_CLOSEHANDLE(FS_HND(fhold));

	return cd_append_record(local_off, fsize, csize, crc, namelen, zip_name, method, 0);

fail:
	if (df != 0)
	{
		OS_CLOSEHANDLE(FS_HND(dfhold));
		OS_DELETE((unsigned char *)DF_TEMP);
	}
	OS_CLOSEHANDLE(FS_HND(fhold));
	return -1;
}

/* cwd is the directory to pack; g_prefix is zip path prefix ("" or "dir/"). */
static int scan_cwd(FILE *zh)
{
	unsigned int n;
	unsigned int namelen;
	unsigned int oldpref;
	int is_dir;

	n = 0;
	for (;;)
	{
		if (get_nth_entry(n, &g_fi) != 0)
			break;

		fi_name(&g_fi, g_localname);
		is_dir = (g_fi.fattrib & ATTR_DIR) ? 1 : 0;

		if (make_zip_name(g_localname, g_zipname, &namelen, is_dir) != 0)
			return -1;

		if (is_dir)
		{
			if (add_dir_entry(zh, g_zipname, namelen) != 0)
				return -1;

			oldpref = g_preflen;
			if (prefix_push(g_localname) != 0)
				return -1;
			if (OS_CHDIR(g_localname) != 0)
			{
				printf("Cannot enter %s\r\n", g_localname);
				prefix_pop(oldpref);
				return -1;
			}
			if (scan_cwd(zh) != 0)
			{
				OS_CHDIR((unsigned char *)"..");
				prefix_pop(oldpref);
				return -1;
			}
			OS_CHDIR((unsigned char *)"..");
			prefix_pop(oldpref);
		}
		else
		{
			if (add_file(zh, (char *)g_localname, g_zipname, namelen) != 0)
				return -1;
		}
		n++;
	}
	return 0;
}

static int add_path(FILE *zh, const char *path)
{
	FILE *fh;
	unsigned int namelen;
	unsigned int n;
	unsigned int i;

	/* Try as file first. */
	fh = OS_OPENHANDLE((unsigned char *)path, FS_FLAGS);
	if (FS_ERR(fh) == 0)
	{
		OS_CLOSEHANDLE(FS_HND((FILE)(unsigned int)fh));

		n = 0;
		while (path[n] != 0 && n < (PATH_MAX - 1u))
		{
			g_pathbuf[n] = (unsigned char)path[n];
			n++;
		}
		g_pathbuf[n] = 0;
		slash_fix(g_pathbuf);
		if (g_pathbuf[0] == '.' && g_pathbuf[1] == '/')
		{
			namelen = 0;
			i = 2;
			while (g_pathbuf[i] != 0)
				g_pathbuf[namelen++] = g_pathbuf[i++];
			g_pathbuf[namelen] = 0;
		}
		else
			namelen = n;
		if (namelen == 0)
			return -1;
		return add_file(zh, path, g_pathbuf, namelen);
	}

	/* Directory: chdir in, prefix = "name/", scan. */
	n = 0;
	while (path[n] != 0 && n < (PATH_MAX - 2u))
	{
		g_pathbuf[n] = (unsigned char)path[n];
		n++;
	}
	g_pathbuf[n] = 0;
	slash_fix(g_pathbuf);
	while (n > 0 && g_pathbuf[n - 1] == '/')
	{
		n--;
		g_pathbuf[n] = 0;
	}
	if (n == 0)
	{
		printf("Bad path: %s\r\n", path);
		return -1;
	}

	if (OS_CHDIR(g_pathbuf) != 0)
	{
		printf("Cannot open %s\r\n", path);
		return -1;
	}

	g_preflen = 0;
	g_prefix[0] = 0;
	if (prefix_push(g_pathbuf) != 0)
	{
		OS_CHDIR((unsigned char *)"..");
		return -1;
	}

	/* Directory node itself: "dir/" */
	namelen = g_preflen;
	for (i = 0; i < namelen; i++)
		g_zipname[i] = g_prefix[i];
	g_zipname[namelen] = 0;

	if (add_dir_entry(zh, g_zipname, namelen) != 0)
	{
		OS_CHDIR((unsigned char *)"..");
		return -1;
	}

	if (scan_cwd(zh) != 0)
	{
		OS_CHDIR((unsigned char *)"..");
		return -1;
	}

	OS_CHDIR((unsigned char *)"..");
	g_preflen = 0;
	g_prefix[0] = 0;
	return 0;
}

static int write_central(FILE *zh)
{
	unsigned long cd_off;
	unsigned long left;
	unsigned int got;

	cd_off = g_pos;

	OS_SEEKHANDLE(FS_HND(g_cdhold), 0UL);
	left = g_cd_size;
	while (left)
	{
		got = IO_CHUNK;
		if ((unsigned long)got > left)
			got = (unsigned int)left;
		got = OS_READHANDLE(g_buf, FS_HND(g_cdhold), got);
		if (got == 0)
			return -1;
		if (write_fully(zh, g_buf, got) != 0)
			return -1;
		left -= got;
	}

	wr32(g_hdr, SIG_EOCD);
	wr16(g_hdr + 4, 0);
	wr16(g_hdr + 6, 0);
	wr16(g_hdr + 8, g_nent);
	wr16(g_hdr + 10, g_nent);
	wr32(g_hdr + 12, g_cd_size);
	wr32(g_hdr + 16, cd_off);
	wr16(g_hdr + 20, 0);

	if (write_fully(zh, g_hdr, 22) != 0)
		return -1;
	return 0;
}

int zip_create(const char *archive, int level, int file_count, char *files[])
{
	FILE *zh;
	FILE zhold;
	int i;
	int err;

	if (file_count <= 0)
	{
		printf("No input files\r\n");
		return 1;
	}

	deflate_set_level(level);

	g_nent = 0;
	g_pos = 0;
	g_cd_size = 0;
	g_preflen = 0;
	g_prefix[0] = 0;

	if (win_alloc() != 0)
	{
		printf("Out of memory (window)\r\n");
		return 1;
	}

	g_cdh = OS_CREATEHANDLE((unsigned char *)CD_TEMP, FS_FLAGS);
	if (FS_ERR(g_cdh) != 0)
	{
		win_free();
		printf("Cannot create temp %s\r\n", CD_TEMP);
		return 1;
	}
	g_cdhold = (FILE)(unsigned int)g_cdh;

	zh = OS_CREATEHANDLE((unsigned char *)archive, FS_FLAGS);
	if (FS_ERR(zh) != 0)
	{
		OS_CLOSEHANDLE(FS_HND(g_cdhold));
		OS_DELETE((unsigned char *)CD_TEMP);
		win_free();
		printf("Cannot create %s\r\n", archive);
		return 1;
	}
	zhold = (FILE)(unsigned int)zh;

	err = 0;
	for (i = 0; i < file_count; i++)
	{
		if (add_path(FS_HND(zhold), files[i]) != 0)
		{
			err = 1;
			break;
		}
	}

	if (err == 0)
	{
		if (write_central(FS_HND(zhold)) != 0)
		{
			printf("Central directory write failed\r\n");
			err = 1;
		}
	}

	OS_CLOSEHANDLE(FS_HND(zhold));
	OS_CLOSEHANDLE(FS_HND(g_cdhold));
	OS_DELETE((unsigned char *)CD_TEMP);
	OS_DELETE((unsigned char *)DF_TEMP);
	win_free();

	if (err)
		return 1;

	printf("OK: %u entr(y/ies) -> %s\r\n", g_nent, archive);
	return 0;
}
