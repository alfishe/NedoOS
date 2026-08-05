#include "mb_inc.h"
#include "mb_plug.h"

unsigned char g_bankPg[MB_BANK_COUNT];
unsigned char g_dataPg;
union APP_PAGES g_main_pg;
unsigned char *netbuf;

extern void force_helpers(void);

static const char g_bank_fmt[] = "JT slot0 from codebank %u\r\n";

/* ---- CODE / DATA window ---- */

unsigned char mb_code_current(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_2;
}

void mb_code_map(unsigned char page)
{
	OS_SETPG8000(page);
}

unsigned char mb_data_current(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_3;
}

void mb_data_map(unsigned char page)
{
	OS_SETPGC000(page);
}

unsigned char mb_os_new_page(unsigned char *page_out)
{
	unsigned int pg;

	pg = OS_NEWPAGE();
	if (pg > 255u)
		return 0u;
	*page_out = (unsigned char)pg;
	return 1u;
}

void mb_os_release_page(unsigned char page)
{
	if (page != 0u)
		OS_DELPAGE(page);
}

unsigned char mb_code_push(unsigned char page)
{
	unsigned char saved;

	saved = mb_code_current();
	mb_code_map(page);
	return saved;
}

void mb_code_pop(unsigned char saved)
{
	mb_code_map(saved);
}

unsigned char mb_data_push(unsigned char page)
{
	unsigned char saved;

	saved = mb_data_current();
	mb_data_map(page);
	return saved;
}

void mb_data_pop(unsigned char saved)
{
	mb_data_map(saved);
}

void mb_data_poke_u32(unsigned char page, unsigned int off, unsigned long val)
{
	unsigned char saved;

	saved = mb_data_push(page);
	*(unsigned long *)(MB_DATA_ADDR + off) = val;
	mb_data_pop(saved);
}

unsigned long mb_data_peek_u32(unsigned char page, unsigned int off)
{
	unsigned char saved;
	unsigned long v;

	saved = mb_data_push(page);
	v = *(unsigned long *)(MB_DATA_ADDR + off);
	mb_data_pop(saved);
	return v;
}

void mb_data_fill(unsigned char page, unsigned char fill_byte)
{
	unsigned char saved;
	unsigned int i;

	saved = mb_data_push(page);
	for (i = 0u; i < MB_PAGE_SIZE; i++)
		((unsigned char *)MB_DATA_ADDR)[i] = fill_byte;
	mb_data_pop(saved);
}

/* ---- lifecycle ---- */

void mb_report_bank(unsigned int bank_nr)
{
	printf(g_bank_fmt, bank_nr);
}

void mb_data_select(void)
{
	if (g_dataPg != 0u)
	{
		mb_data_map(g_dataPg);
		netbuf = (unsigned char *)(MB_DATA_ADDR + MB_NETBUF_OFF);
	}
	else
		netbuf = 0;
}

void mb_init(void)
{
	unsigned char i;

	g_main_pg.l = OS_GETMAINPAGES();

	/* Force-link symbols banks CALL by absolute address. */
	puts("");
	printf("");
	force_helpers();

	for (i = 0u; i < MB_BANK_COUNT; i++)
		g_bankPg[i] = 0u;

	/*
	 * Do NOT allocate/map a private page at C000 here.
	 * BDOS file I/O (loading codeB_*.bin, ini, nv.ext) must keep the
	 * cold/system window_3 ? remapping C000 to an empty app page corrupts
	 * FAT/disk when launched from autoexec/cmd.
	 * Panel/fileops map their own pages only for the duration of work.
	 */
	g_dataPg = 0u;
	netbuf = 0;
	OS_SETPGC000(g_main_pg.pgs.window_3);
}

void mb_shutdown(void)
{
	unsigned char i;

	for (i = 0u; i < MB_BANK_COUNT; i++)
	{
		if (g_bankPg[i] != 0u)
		{
			mb_os_release_page(g_bankPg[i]);
			g_bankPg[i] = 0u;
		}
	}
	if (g_dataPg != 0u)
	{
		mb_os_release_page(g_dataPg);
		g_dataPg = 0u;
		netbuf = 0;
	}
}

/* ---- overlay load (NedoOS: never test fp==0) ---- */

static unsigned char mb_open_ok(FILE *fp)
{
	return (((unsigned int)fp) & 0xffu) == 0u;
}

unsigned char mb_load_bank_bin(const char *path, unsigned char *page_out)
{
	FILE *fp;
	unsigned char page;
	unsigned char saved;
	unsigned long sz;
	unsigned int nread;
	unsigned int i;

	if (page_out == 0 || path == 0)
		return 0u;

	if (!mb_os_new_page(&page))
		return 0u;

	fp = OS_OPENHANDLE((unsigned char *)path, 0x80u);
	if (!mb_open_ok(fp))
	{
		mb_os_release_page(page);
		return 0u;
	}

	sz = OS_GETFILESIZE(fp);
	if (sz == 0ul || sz > (unsigned long)MB_PAGE_SIZE)
	{
		OS_CLOSEHANDLE(fp);
		mb_os_release_page(page);
		return 0u;
	}

	/* Keep system C000; only swap CODE window for the read. */
	saved = mb_code_current();
	OS_SETPG8000(page);
	/* Clear page so unused tail is not leftover garbage from OS_NEWPAGE. */
	for (i = 0u; i < MB_PAGE_SIZE; i++)
		((unsigned char *)MB_CODE_ADDR)[i] = 0u;
	nread = OS_READHANDLE((unsigned char *)MB_CODE_ADDR, fp, (unsigned int)sz);
	OS_CLOSEHANDLE(fp);
	OS_SETPG8000(saved);

	if (nread != (unsigned int)sz)
	{
		mb_os_release_page(page);
		return 0u;
	}

	*page_out = page;
	return 1u;
}
