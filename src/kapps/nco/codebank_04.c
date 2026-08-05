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