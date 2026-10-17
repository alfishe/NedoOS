#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

/*
 * NCO bank05: ATAPI + ISO9660 Level 1 (read-only PoC).
 * All buffers/state live in root BSS (nco_data.c) ? overlays are code-only.
 */
#include "nc_inc.h"
#include "nc_plug.h"
#include <intrz80.h>
#include <string.h>

#define CD_MASTER NC_CD_MASTER
#define CD_SLAVE  NC_CD_SLAVE
#define CD_SEC    2048u

/* ---- IDE ports (set by cdfs_ports_init) ---- */


static void ports_nemo(void)
{
	g_cd_stat = 0xF0u;
	g_cd_cmd = 0xF0u;
	g_cd_head = 0xD0u;
	g_cd_cylhi = 0xB0u;
	g_cd_cyllo = 0x90u;
	g_cd_datlo = 0x10u;
	g_cd_dathi = 0x11u;
	g_cd_err = 0x30u;
}

static void ports_atm(void)
{
	g_cd_stat = 0xFEEFu;
	g_cd_cmd = 0xFEEFu;
	g_cd_head = 0xFECFu;
	g_cd_cylhi = 0xFEAFu;
	g_cd_cyllo = 0xFE8Fu;
	g_cd_datlo = 0xFE0Fu;
	g_cd_dathi = 0xFF0Fu;
	g_cd_err = 0xFE2Fu;
}

static unsigned char bus_alive(void)
{
	output(g_cd_head, CD_SLAVE);
	return (unsigned char)(input(g_cd_stat) != 0xFFu);
}

static void cdfs_ports_init(void)
{
	unsigned char cfg;

	if (g_cd_ports_ok)
		return;
	cfg = (unsigned char)OS_GETCONFIG();
	if (cfg == 2u)
		ports_atm();
	else if (cfg == 1u || cfg == 3u || cfg == 6u)
		ports_nemo();
	else
	{
		ports_nemo();
		if (!bus_alive())
			ports_atm();
	}
	g_cd_ports_ok = 1u;
}

static unsigned char wait_bsy(void)
{
	unsigned int t;
	unsigned char st;

	output(g_cd_head, g_cd_channel);
	t = 0xFFFFu;
	do
	{
		st = input(g_cd_stat);
		if ((st & 0x80u) == 0u)
			return st;
	} while (--t != 0u);
	return 0xFFu;
}

static unsigned char wait_drq(void)
{
	unsigned int t;
	unsigned char st;

	output(g_cd_head, g_cd_channel);
	t = 0xFFFFu;
	do
	{
		st = input(g_cd_stat);
		if ((st & 0x88u) == 0x08u)
			return st;
	} while (--t != 0u);
	return 0xFFu;
}

/* nbytes = expected PIO transfer size (usually count*2048). */
static unsigned char atapi_packet_bc(const unsigned char *pkt, unsigned int nbytes)
{
	unsigned char i;

	disable_interrupt();
	if (wait_bsy() == 0xFFu)
	{
		enable_interrupt();
		return 0u;
	}
	output(g_cd_cyllo, (unsigned char)nbytes);
	output(g_cd_cylhi, (unsigned char)(nbytes >> 8));
	output(g_cd_head, g_cd_channel);
	output(g_cd_cmd, 0xA0u);
	if (wait_drq() == 0xFFu)
	{
		enable_interrupt();
		return 0u;
	}
	for (i = 0u; i < 12u; i += 2u)
	{
		output(g_cd_dathi, pkt[i + 1u]);
		output(g_cd_datlo, pkt[i]);
	}
	enable_interrupt();
	return 1u;
}

/* READ(10) count sectors (1..8) straight into dst. */
static unsigned char atapi_read_n(unsigned long lba, unsigned char count, unsigned char *dst)
{
	unsigned char pkt[12];
	unsigned int i, words;

	if (count == 0u || count > 8u || dst == 0)
		return 0u;

	pkt[0] = 0x28u;
	pkt[1] = 0u;
	pkt[2] = (unsigned char)(lba >> 24);
	pkt[3] = (unsigned char)(lba >> 16);
	pkt[4] = (unsigned char)(lba >> 8);
	pkt[5] = (unsigned char)lba;
	pkt[6] = 0u;
	pkt[7] = 0u;
	pkt[8] = count;
	pkt[9] = 0u;
	pkt[10] = 0u;
	pkt[11] = 0u;

	if (!atapi_packet_bc(pkt, (unsigned int)count * CD_SEC))
		return 0u;
	if (wait_drq() == 0xFFu)
		return 0u;

	words = ((unsigned int)count * CD_SEC) / 2u;
	disable_interrupt();
	for (i = 0u; i < words; i++)
	{
		dst[0] = input(g_cd_datlo);
		dst[1] = input(g_cd_dathi);
		dst += 2;
	}
	enable_interrupt();
	/* Last sector of the burst sits in g_cd_sec only for single-sector path. */
	if (count == 1u)
	{
		memcpy(g_cd_sec, dst - CD_SEC, CD_SEC);
		g_cd_sec_lba = lba;
	}
	else
		g_cd_sec_lba = 0xFFFFFFFFUL; /* invalidate single-sec cache */
	return 1u;
}

static unsigned char atapi_read_sector(unsigned long lba)
{
	if (g_cd_sec_lba == lba)
		return 1u;
	return atapi_read_n(lba, 1u, g_cd_sec);
}

static void cdfs_drop_mount(void)
{
	g_cd_mounted = 0u;
	g_cd_file_open = 0u;
	g_cd_sec_lba = 0xFFFFFFFFUL;
}

/* TEST UNIT READY. 0 = no disc, 1 = ready, 2 = UNIT ATTENTION (changed). */
static unsigned char cdfs_tur_state(void)
{
	unsigned char pkt[12];
	unsigned char st, err, i;

	for (i = 0u; i < 12u; i++)
		pkt[i] = 0u;
	if (!atapi_packet_bc(pkt, 0u))
		return 0u;
	st = wait_bsy();
	if (st == 0xFFu || (st & 0x01u) == 0u)
		return (st == 0xFFu) ? 0u : 1u;
	err = (unsigned char)(input(g_cd_err) >> 4); /* sense key */
	if (err == 6u)
		return 2u;
	return 0u;
}

/*
 * GET MEDIA STATUS (ATA 0xDA). Error register:
 *   bit1 NM no media, bit5 MC media changed, bit2 ABRT unsupported.
 * 0 = no disc, 1 = same disc, 2 = disc changed (caller must remount).
 */
static unsigned char cdfs_media_state(void)
{
	unsigned char st, err;

	output(g_cd_head, g_cd_channel);
	if (wait_bsy() == 0xFFu)
		return 0u;
	output(g_cd_head, g_cd_channel);
	output(g_cd_cmd, 0xDAu);
	st = wait_bsy();
	if (st == 0xFFu)
		return 0u;
	err = input(g_cd_err);
	if ((err & 0x04u) != 0u)
		return cdfs_tur_state();
	if ((err & 0x02u) != 0u)
		return 0u;
	if ((err & 0x20u) != 0u)
		return 2u;
	return 1u;
}

/* Short ATAPI DATA IN (e.g. READ TOC). Invalidates g_cd_sec cache. */
static unsigned char atapi_packet_in(const unsigned char *pkt, unsigned char *dst, unsigned int nbytes)
{
	unsigned int i, words;

	if (dst == 0 || nbytes < 2u)
		return 0u;
	if (!atapi_packet_bc(pkt, nbytes))
		return 0u;
	if (wait_drq() == 0xFFu)
		return 0u;
	words = nbytes / 2u;
	disable_interrupt();
	for (i = 0u; i < words; i++)
	{
		dst[0] = input(g_cd_datlo);
		dst[1] = input(g_cd_dathi);
		dst += 2;
	}
	enable_interrupt();
	g_cd_sec_lba = 0xFFFFFFFFUL;
	return 1u;
}

/*
 * READ TOC Format=1 (Session Info), LBA addressing.
 * Returns start LBA of first track in last complete session (0 if single-session / fail).
 * PVD for that session is at returned_lba + 16.
 */
static unsigned long cdfs_last_session_lba(void)
{
	unsigned char pkt[12];
	unsigned char buf[12];
	unsigned char i;

	for (i = 0u; i < 12u; i++)
		pkt[i] = 0u;
	pkt[0] = 0x43u; /* READ TOC/PMA/ATIP */
	pkt[2] = 0x01u; /* Format: Session info */
	pkt[8] = 12u;   /* Allocation length */

	if (!atapi_packet_in(pkt, buf, 12u))
		return 0UL;
	/* bytes 8..11: track start address, big-endian LBA */
	return ((unsigned long)buf[8] << 24)
		| ((unsigned long)buf[9] << 16)
		| ((unsigned long)buf[10] << 8)
		| (unsigned long)buf[11];
}

static unsigned char detect_cd(unsigned char channel)
{
	unsigned char st;
	unsigned int id;
	unsigned int i;

	g_cd_channel = channel;
	output(g_cd_head, channel);
	if (wait_bsy() == 0xFFu)
		return 0u;
	output(g_cd_cylhi, 0u);
	output(g_cd_cyllo, 0u);
	output(g_cd_head, channel);
	output(g_cd_cmd, 0xECu); /* IDENTIFY */
	st = wait_bsy();
	if (st == 0xFFu)
		return 0u;
	id = (unsigned int)input(g_cd_cyllo) + ((unsigned int)input(g_cd_cylhi) << 8);
	if (id != 0xEB14u)
		return 0u;
	output(g_cd_head, channel);
	output(g_cd_cmd, 0xA1u); /* IDENTIFY PACKET */
	if (wait_drq() == 0xFFu)
		return 0u;
	/* drain 512 words of identify */
	disable_interrupt();
	for (i = 0u; i < 256u; i++)
	{
		(void)input(g_cd_datlo);
		(void)input(g_cd_dathi);
	}
	enable_interrupt();
	return 1u;
}

static unsigned long rd_u32le(const unsigned char *p)
{
	return (unsigned long)p[0]
		| ((unsigned long)p[1] << 8)
		| ((unsigned long)p[2] << 16)
		| ((unsigned long)p[3] << 24);
}

/* ISO9660 recording time @+18 (7 bytes) -> FatFs/MS-DOS fdate/ftime. */
static void iso_rec_to_fat_dt(const unsigned char *rec, unsigned int *odate, unsigned int *otime)
{
	unsigned char yy, mo, dd, hh, mm, ss;
	unsigned int y1980;

	yy = rec[18]; /* years since 1900 */
	mo = rec[19];
	dd = rec[20];
	hh = rec[21];
	mm = rec[22];
	ss = rec[23];
	/* GMT offset rec[24] ignored for panel display */
	if (mo < 1u || mo > 12u || dd < 1u || dd > 31u)
	{
		*odate = 0u;
		*otime = 0u;
		return;
	}
	/* FAT year = years since 1980; ISO yy is since 1900 */
	if (yy < 80u)
		y1980 = 0u;
	else
		y1980 = (unsigned int)(yy - 80u);
	if (y1980 > 127u)
		y1980 = 127u;
	if (hh > 23u)
		hh = 0u;
	if (mm > 59u)
		mm = 0u;
	if (ss > 59u)
		ss = 0u;
	*odate = (unsigned int)dd | ((unsigned int)mo << 5) | (y1980 << 9);
	*otime = (unsigned int)(ss >> 1) | ((unsigned int)mm << 5) | ((unsigned int)hh << 11);
}

/* UCS-2 BE code unit -> CP866 (ASCII + Cyrillic block). */
static unsigned char ucs2_to_cp866(unsigned char hi, unsigned char lo)
{
	if (hi == 0u)
	{
		if (lo < 0x80u)
			return lo;
		return (unsigned char)'?';
	}
	if (hi == 0x04u)
	{
		if (lo == 0x01u)
			return 0xF0u; /* YO */
		if (lo == 0x51u)
			return 0xF1u; /* yo */
		if (lo >= 0x10u && lo <= 0x2Fu)
			return (unsigned char)(0x80u + (lo - 0x10u)); /* A..Ya */
		if (lo >= 0x30u && lo <= 0x3Fu)
			return (unsigned char)(0xA0u + (lo - 0x30u)); /* a..p */
		if (lo >= 0x40u && lo <= 0x4Fu)
			return (unsigned char)(0xE0u + (lo - 0x40u)); /* r..ya */
	}
	return (unsigned char)'?';
}

static void lfn_to_sfn(const unsigned char *lfn, unsigned char *fname)
{
	unsigned char i, j, dot, nlen;

	for (i = 0u; i < 13u; i++)
		fname[i] = 0;
	nlen = 0u;
	while (lfn[nlen] != 0 && nlen < 63u)
		nlen++;
	dot = 255u;
	for (i = 0u; i < nlen; i++)
		if (lfn[i] == (unsigned char)'.')
			dot = i;
	j = 0u;
	if (dot == 255u)
	{
		for (i = 0u; i < nlen && j < 8u; i++)
			fname[j++] = lfn[i];
	}
	else
	{
		for (i = 0u; i < dot && j < 8u; i++)
			fname[j++] = lfn[i];
		if (dot + 1u < nlen)
		{
			fname[j++] = '.';
			for (i = (unsigned char)(dot + 1u); i < nlen && j < 12u; i++)
				fname[j++] = lfn[i];
		}
	}
}

static void iso_name_to_sfn(const unsigned char *n, unsigned char nlen, unsigned char *fname)
{
	unsigned char i, j, dot;

	for (i = 0u; i < 13u; i++)
		fname[i] = 0;
	if (nlen == 1u && n[0] == 0u)
	{
		fname[0] = '.';
		return;
	}
	if (nlen == 1u && n[0] == 1u)
	{
		fname[0] = '.';
		fname[1] = '.';
		return;
	}
	/* strip ;version */
	for (i = 0u; i < nlen; i++)
		if (n[i] == (unsigned char)';')
		{
			nlen = i;
			break;
		}
	dot = 255u;
	for (i = 0u; i < nlen; i++)
		if (n[i] == (unsigned char)'.')
			dot = i;
	j = 0u;
	if (dot == 255u)
	{
		for (i = 0u; i < nlen && j < 8u; i++)
			fname[j++] = n[i];
	}
	else
	{
		for (i = 0u; i < dot && j < 8u; i++)
			fname[j++] = n[i];
		if (dot + 1u < nlen)
		{
			fname[j++] = '.';
			for (i = (unsigned char)(dot + 1u); i < nlen && j < 12u; i++)
				fname[j++] = n[i];
		}
	}
}

/* Joliet file id is UCS-2 BE; '.'/'..' stay 1-byte 0/1. Out: lfname + 8.3 fname. */
static void joliet_name_decode(const unsigned char *n, unsigned char nlen,
	unsigned char *fname, unsigned char *lfname)
{
	unsigned char i, j, c;

	fname[0] = 0;
	lfname[0] = 0;
	if (nlen == 1u && n[0] == 0u)
	{
		fname[0] = '.';
		lfname[0] = '.';
		lfname[1] = 0;
		return;
	}
	if (nlen == 1u && n[0] == 1u)
	{
		fname[0] = '.';
		fname[1] = '.';
		lfname[0] = '.';
		lfname[1] = '.';
		lfname[2] = 0;
		return;
	}
	j = 0u;
	for (i = 0u; (unsigned char)(i + 1u) < nlen && j < 63u; i = (unsigned char)(i + 2u))
	{
		/* big-endian UCS-2; stop at ';' version */
		if (n[i] == 0u && n[i + 1u] == (unsigned char)';')
			break;
		c = ucs2_to_cp866(n[i], n[i + 1u]);
		lfname[j++] = c;
	}
	lfname[j] = 0;
	lfn_to_sfn(lfname, fname);
}

static void iso_rec_names(const unsigned char *rec, unsigned char *fname, unsigned char *lfname)
{
	unsigned char nlen;

	nlen = rec[32];
	if (g_cd_joliet)
		joliet_name_decode(rec + 33, nlen, fname, lfname);
	else
	{
		iso_name_to_sfn(rec + 33, nlen, fname);
		lfname[0] = 0;
	}
}

static unsigned char name_eq_ci_n(const unsigned char *a, const unsigned char *b, unsigned char maxn)
{
	unsigned char i, ca, cb;

	for (i = 0u; i < maxn; i++)
	{
		ca = a[i];
		cb = b[i];
		if (ca >= 'a' && ca <= 'z')
			ca = (unsigned char)(ca - 'a' + 'A');
		if (cb >= 'a' && cb <= 'z')
			cb = (unsigned char)(cb - 'a' + 'A');
		if (ca != cb)
			return 0u;
		if (ca == 0)
			return 1u;
	}
	return 1u;
}

static unsigned char vd_is_joliet(const unsigned char *p)
{
	const unsigned char *e;

	/* escape sequences at offset 88 (32 bytes) */
	e = p + 88;
	if (e[0] == 0x25u && e[1] == 0x2Fu && (e[2] == 0x40u || e[2] == 0x43u || e[2] == 0x45u))
		return 1u;
	return 0u;
}

unsigned char r_cdfs_present(void)
{
	cdfs_ports_init();
	if (detect_cd(CD_SLAVE))
	{
		g_cd_channel = CD_SLAVE;
		return 1u;
	}
	if (detect_cd(CD_MASTER))
	{
		g_cd_channel = CD_MASTER;
		return 1u;
	}
	return 0u;
}

/* Mount ISO at volume descriptors starting at base+16 (base = last session LBA). */
static unsigned char cdfs_mount_at(unsigned long base)
{
	const unsigned char *p;
	unsigned long lba;
	unsigned char i;

	g_cd_joliet = 0u;
	if (!atapi_read_sector(base + 16UL))
		return 0u;
	p = g_cd_sec;
	if (p[0] != 1u || p[1] != 'C' || p[2] != 'D' || p[3] != '0'
		|| p[4] != '0' || p[5] != '1')
		return 0u;
	/* Root extents in VD are absolute LBAs ? do not add base. */
	lba = rd_u32le(p + 156u + 2u);
	g_cd_root_size = rd_u32le(p + 156u + 10u);
	g_cd_root_lba = lba;

	/* Prefer Joliet SVD in this session's VD set. */
	for (i = 17u; i < 32u; i++)
	{
		if (!atapi_read_sector(base + (unsigned long)i))
			break;
		p = g_cd_sec;
		if (p[0] == 255u)
			break;
		if (p[0] == 2u && p[1] == 'C' && p[2] == 'D' && p[3] == '0'
			&& p[4] == '0' && p[5] == '1' && vd_is_joliet(p))
		{
			lba = rd_u32le(p + 156u + 2u);
			g_cd_root_size = rd_u32le(p + 156u + 10u);
			g_cd_root_lba = lba;
			g_cd_joliet = 1u;
			break;
		}
	}
	return 1u;
}

static unsigned char cdfs_mount_pvd(void)
{
	unsigned long session;

	if (!r_cdfs_present())
		return 0u;
	g_cd_file_open = 0u;

	/* Multisession: last complete session start; single-session usually 0. */
	session = cdfs_last_session_lba();
	if (!cdfs_mount_at(session))
	{
		if (session == 0UL || !cdfs_mount_at(0UL))
			return 0u;
	}

	g_cd_dir_lba = g_cd_root_lba;
	g_cd_dir_size = g_cd_root_size;
	g_cd_dir_off = 0UL;
	g_cd_at_root = 1u;
	g_cd_mounted = 1u;
	return 1u;
}

/* path like "P:/" or "P:/DIR/SUB/" ? skip drive, walk components (LFN ok). */
static unsigned char cdfs_resolve_dir(const char *path)
{
	unsigned char ni;
	const char *s;
	unsigned long off, rem;
	const unsigned char *rec;
	unsigned char reclen, flags;
	unsigned long extent, esize;
	unsigned char match;
	unsigned char *want;
	unsigned char media;

	if (g_cd_mounted)
	{
		media = cdfs_media_state();
		if (media != 1u)
		{
			cdfs_drop_mount();
			if (media == 0u)
				return 0u; /* tray empty: do not replay the cached image */
		}
	}
	if (!g_cd_mounted && !cdfs_mount_pvd())
		return 0u;

	g_cd_dir_lba = g_cd_root_lba;
	g_cd_dir_size = g_cd_root_size;
	g_cd_dir_off = 0UL;
	g_cd_at_root = 1u;

	s = path;
	if (s[0] != 0 && s[1] == ':')
		s += 2;
	while (*s == '/' || *s == '\\')
		s++;

	want = g_cd_tmpname;
	while (*s != 0)
	{
		ni = 0u;
		while (*s != 0 && *s != '/' && *s != '\\' && ni < 63u)
			want[ni++] = (unsigned char)*s++;
		want[ni] = 0;
		while (*s == '/' || *s == '\\')
			s++;
		if (ni == 0u)
			continue;
		if (ni == 1u && want[0] == '.')
			continue;

		/* find name in current directory */
		off = 0UL;
		rem = g_cd_dir_size;
		match = 0u;
		while (off < rem)
		{
			unsigned long sec_off;
			unsigned long lba;

			sec_off = off & (CD_SEC - 1u);
			if (sec_off == 0UL || g_cd_sec_lba != (g_cd_dir_lba + (off / CD_SEC)))
			{
				lba = g_cd_dir_lba + (off / CD_SEC);
				if (!atapi_read_sector(lba))
					return 0u;
			}
			rec = g_cd_sec + (unsigned int)sec_off;
			reclen = rec[0];
			if (reclen == 0u)
			{
				off = (off + CD_SEC) & ~(unsigned long)(CD_SEC - 1u);
				continue;
			}
			flags = rec[25];
			extent = rd_u32le(rec + 2);
			esize = rd_u32le(rec + 10);
			if ((flags & 0x02u) != 0u && rec[32] >= 1u)
			{
				/* want in g_cd_tmpname; decode LFN into g_cd_file_path scratch. */
				g_cd_file_open = 0u;
				{
					unsigned char sf[13];
					unsigned char *have;

					have = (unsigned char *)g_cd_file_path;
					iso_rec_names(rec, sf, have);
					if (have[0] == 0)
						have = sf;
					if (name_eq_ci_n(have, want, 64u))
					{
						g_cd_dir_lba = extent;
						g_cd_dir_size = esize;
						g_cd_dir_off = 0UL;
						g_cd_at_root = 0u;
						match = 1u;
						break;
					}
				}
			}
			off += reclen;
		}
		if (!match)
			return 0u;
	}
	g_cd_dir_off = 0UL;
	return 1u;
}

unsigned char r_cdfs_opendir(const char *path)
{
	if (path == 0 || path[0] == 0)
		return 0u;
	return cdfs_resolve_dir(path);
}

unsigned char r_cdfs_readdir(fileInfo *fi)
{
	unsigned long off, rem, sec_off, lba;
	const unsigned char *rec;
	unsigned char reclen, flags;

	if (!g_cd_mounted || fi == 0)
		return 1u;

	off = g_cd_dir_off;
	rem = g_cd_dir_size;
	while (off < rem)
	{
		sec_off = off & (CD_SEC - 1u);
		if (sec_off == 0UL || g_cd_sec_lba != (g_cd_dir_lba + (off / CD_SEC)))
		{
			lba = g_cd_dir_lba + (off / CD_SEC);
			if (!atapi_read_sector(lba))
			{
				g_cd_dir_off = rem;
				return 1u;
			}
		}
		rec = g_cd_sec + (unsigned int)sec_off;
		reclen = rec[0];
		if (reclen == 0u)
		{
			off = (off + CD_SEC) & ~(unsigned long)(CD_SEC - 1u);
			g_cd_dir_off = off;
			continue;
		}
		flags = rec[25];
		off += reclen;
		g_cd_dir_off = off;
		/* ISO/Joliet special ids: 1-byte 0 = ".", 1 = ".." ? filter before decode. */
		if (rec[32] == 1u && rec[33] == 0u)
			continue; /* hide "." everywhere */
		if (rec[32] == 1u && rec[33] == 1u && g_cd_at_root)
			continue; /* hide ".." at volume root */
		fi->fsize = rd_u32le(rec + 10);
		iso_rec_to_fat_dt(rec, &fi->fdate, &fi->ftime);
		fi->fattrib = ((flags & 0x02u) != 0u) ? 0x10u : 0u;
		iso_rec_names(rec, fi->fname, fi->lfname);
		if (fi->fname[0] == 0 && fi->lfname[0] == 0)
			continue;
		/* Decoded-name backup (UCS-2 "." / ".." on odd discs). */
		if ((fi->fname[0] == '.' && fi->fname[1] == 0)
			|| (fi->lfname[0] == '.' && fi->lfname[1] == 0))
			continue;
		if (((fi->fname[0] == '.' && fi->fname[1] == '.' && fi->fname[2] == 0)
			|| (fi->lfname[0] == '.' && fi->lfname[1] == '.' && fi->lfname[2] == 0))
			&& g_cd_at_root)
			continue;
		return 0u; /* one entry */
	}
	g_cd_dir_off = rem;
	return 1u; /* end */
}

static unsigned char cdfs_find_in_dir(const char *base, unsigned long *olba, unsigned long *osize)
{
	unsigned long off, rem;
	const unsigned char *rec;
	unsigned char reclen;
	unsigned char sf[13];
	unsigned char *have;

	off = 0UL;
	rem = g_cd_dir_size;
	while (off < rem)
	{
		unsigned long sec_off, lba;

		sec_off = off & (CD_SEC - 1u);
		if (sec_off == 0UL || g_cd_sec_lba != (g_cd_dir_lba + (off / CD_SEC)))
		{
			lba = g_cd_dir_lba + (off / CD_SEC);
			if (!atapi_read_sector(lba))
				return 0u;
		}
		rec = g_cd_sec + (unsigned int)sec_off;
		reclen = rec[0];
		if (reclen == 0u)
		{
			off = (off + CD_SEC) & ~(unsigned long)(CD_SEC - 1u);
			continue;
		}
		if ((rec[25] & 0x02u) == 0u)
		{
			/* base lives in g_cd_tmpname ? decode into file-path scratch */
			g_cd_file_open = 0u;
			iso_rec_names(rec, sf, (unsigned char *)g_cd_file_path);
			have = (unsigned char *)g_cd_file_path;
			if (have[0] == 0)
				have = sf;
			if (name_eq_ci_n(have, (const unsigned char *)base, 64u))
			{
				*olba = rd_u32le(rec + 2);
				*osize = rd_u32le(rec + 10);
				return 1u;
			}
		}
		off += reclen;
	}
	return 0u;
}

static unsigned char cdfs_resolve_file(const char *path, unsigned long *olba, unsigned long *osize)
{
	char dir[64];
	unsigned int i, slash, len;
	unsigned char *base;

	len = 0u;
	while (path[len] != 0 && len < 63u)
		len++;
	while (len > 0u && (path[len - 1u] == '/' || path[len - 1u] == '\\'))
		len--;
	slash = 0u;
	for (i = 0u; i < len; i++)
		if (path[i] == '/' || path[i] == '\\')
			slash = i;
	for (i = 0u; i < slash && i < 62u; i++)
		dir[i] = path[i];
	if (slash == 0u)
	{
		dir[0] = (char)NC_CD_LETTER;
		dir[1] = ':';
		dir[2] = '/';
		dir[3] = 0;
	}
	else
	{
		dir[i++] = '/';
		dir[i] = 0;
	}
	/* base name in g_cd_tmpname (after opendir finishes using it) */
	base = g_cd_tmpname;
	for (i = 0u; slash + 1u + i < len && i < 63u; i++)
		base[i] = (unsigned char)path[slash + 1u + i];
	base[i] = 0;
	if (!r_cdfs_opendir(dir))
		return 0u;
	/* opendir may overwrite g_cd_tmpname ? re-copy base after open */
	for (i = 0u; slash + 1u + i < len && i < 63u; i++)
		base[i] = (unsigned char)path[slash + 1u + i];
	base[i] = 0;
	return cdfs_find_in_dir((const char *)base, olba, osize);
}

static unsigned char path_eq(const char *a, const char *b)
{
	unsigned char i, ca, cb;

	for (i = 0u; i < 64u; i++)
	{
		ca = (unsigned char)a[i];
		cb = (unsigned char)b[i];
		if (ca >= 'a' && ca <= 'z')
			ca = (unsigned char)(ca - 'a' + 'A');
		if (cb >= 'a' && cb <= 'z')
			cb = (unsigned char)(cb - 'a' + 'A');
		if (ca != cb)
			return 0u;
		if (ca == 0)
			return 1u;
	}
	return 1u;
}

static unsigned char cdfs_open_cached(const char *path)
{
	unsigned int i;

	if (g_cd_file_open && path_eq(path, g_cd_file_path))
	{
		if (cdfs_media_state() != 1u)
		{
			cdfs_drop_mount();
			return 0u;
		}
		return 1u;
	}
	if (!cdfs_resolve_file(path, &g_cd_file_lba, &g_cd_file_size))
	{
		g_cd_file_open = 0u;
		return 0u;
	}
	for (i = 0u; i < 63u && path[i] != 0; i++)
		g_cd_file_path[i] = path[i];
	g_cd_file_path[i] = 0;
	g_cd_file_open = 1u;
	return 1u;
}

unsigned int r_cdfs_read(const char *path, unsigned long off, unsigned char *buf, unsigned int len)
{
	unsigned long lba, fsize, pos, got_total, sec_lba, left_bytes;
	unsigned int sec_off, n, chunk;
	unsigned char *d;
	unsigned char nsec;

	if (buf == 0 || len == 0u)
		return 0u;
	if (!cdfs_open_cached(path))
		return 0u;
	lba = g_cd_file_lba;
	fsize = g_cd_file_size;
	if (off >= fsize)
		return 0u;
	if (off + (unsigned long)len > fsize)
		len = (unsigned int)(fsize - off);

	got_total = 0UL;
	pos = off;
	d = buf;
	while (got_total < (unsigned long)len)
	{
		sec_lba = lba + (pos / CD_SEC);
		sec_off = (unsigned int)(pos & (CD_SEC - 1u));
		left_bytes = (unsigned long)len - got_total;

		/* Aligned multi-sector burst into caller buffer (copy uses 16K page). */
		if (sec_off == 0u && left_bytes >= CD_SEC)
		{
			nsec = (unsigned char)(left_bytes / CD_SEC);
			if (nsec > 8u)
				nsec = 8u;
			if (!atapi_read_n(sec_lba, nsec, d))
				break;
			chunk = (unsigned int)nsec * CD_SEC;
			d += chunk;
			pos += chunk;
			got_total += chunk;
			continue;
		}

		if (!atapi_read_sector(sec_lba))
			break;
		chunk = (unsigned int)(CD_SEC - sec_off);
		n = (unsigned int)left_bytes;
		if (chunk > n)
			chunk = n;
		memcpy(d, g_cd_sec + sec_off, chunk);
		d += chunk;
		pos += chunk;
		got_total += chunk;
	}
	return (unsigned int)got_total;
}

