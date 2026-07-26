#include "mb_inc.h"
#include "mb_plug.h"
#include "mb_bank.h"

unsigned char g_bankPg[MB_BANK_COUNT];
unsigned char g_dataPg;
union APP_PAGES g_main_pg;
unsigned char *netbuf;

/*
 * Overlays CALL root/libc by absolute address (resolved at ovl-link time).
 * Those must match multibank.com ? banks call puts/printf directly.
 * Root must reference any libc symbol banks use (see puts("") in mb_init).
 */
static const char g_bank_fmt[] = "This procedure run from codebank %u\r\n";

void mb_report_bank(unsigned int bank_nr)
{
	printf(g_bank_fmt, bank_nr);
}

void mb_code_select_page(unsigned char page)
{
	if (page != 0u)
		mb_code_map(page);
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

static const char *mb_bank_name(unsigned char idx)
{
	/* 8.3 names under /bin/multibank/ */
	if (idx == 0u)
		return "codeB_01.bin";
	if (idx == 1u)
		return "codeB_02.bin";
	return "codeB_03.bin";
}

/* cwd=/bin ? multibank/codeB_0N.bin ; also try bin/multibank/ from volume root */
static unsigned char mb_try_load(unsigned char idx, unsigned char *page_out)
{
	char path[40];
	const char *name;
	unsigned char i;

	name = mb_bank_name(idx);

	/* multibank/codeB_0N.bin */
	path[0] = 'm';
	path[1] = 'u';
	path[2] = 'l';
	path[3] = 't';
	path[4] = 'i';
	path[5] = 'b';
	path[6] = 'a';
	path[7] = 'n';
	path[8] = 'k';
	path[9] = '/';
	for (i = 0u; name[i] != 0 && (unsigned char)(10u + i) < (unsigned char)(sizeof(path) - 1u); i++)
		path[10u + i] = name[i];
	path[10u + i] = 0;
	if (mb_load_bank_bin(path, page_out))
		return 1u;

	/* bin/multibank/codeB_0N.bin */
	path[0] = 'b';
	path[1] = 'i';
	path[2] = 'n';
	path[3] = '/';
	path[4] = 'm';
	path[5] = 'u';
	path[6] = 'l';
	path[7] = 't';
	path[8] = 'i';
	path[9] = 'b';
	path[10] = 'a';
	path[11] = 'n';
	path[12] = 'k';
	path[13] = '/';
	for (i = 0u; name[i] != 0 && (unsigned char)(14u + i) < (unsigned char)(sizeof(path) - 1u); i++)
		path[14u + i] = name[i];
	path[14u + i] = 0;
	return mb_load_bank_bin(path, page_out);
}

void mb_init(void)
{
	unsigned char i;

	g_main_pg.l = OS_GETMAINPAGES();

	/*
	 * Force-link puts into multibank.com. Overlays CALL puts by absolute
	 * address ? if root never references puts, xlink omits it and the
	 * bank jumps to the wrong routine (that was the hang).
	 */
	puts("");

	for (i = 0u; i < MB_BANK_COUNT; i++)
		g_bankPg[i] = 0u;

	g_dataPg = 0u;
	netbuf = 0;
	if (mb_os_new_page(&g_dataPg))
	{
		mb_data_fill(g_dataPg, 0u);
		mb_data_select();
		mb_data_poke_u32(g_dataPg, MB_DATA_SIG_OFF, MB_DATA_SIG_MAGIC);
		mb_data_select();
	}
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

static unsigned char demo_load_banks(void)
{
	unsigned char i;
	unsigned char ok;

	ok = 1u;
	printf("--- load overlays ---\r\n");
	for (i = 0u; i < MB_BANK_COUNT; i++)
	{
		if (!mb_try_load(i, &g_bankPg[i]))
		{
			printf("  FAIL %s\r\n", mb_bank_name(i));
			ok = 0u;
		}
		else
			printf("  OK   %s -> page %u\r\n",
				   mb_bank_name(i), (unsigned int)g_bankPg[i]);
	}
	return ok;
}

static void demo_run_banks(void)
{
	unsigned char i;

	printf("--- call overlays @8000 ---\r\n");
	for (i = 0u; i < MB_BANK_COUNT; i++)
	{
		if (g_bankPg[i] == 0u)
		{
			printf("  skip bank %u (not loaded)\r\n", (unsigned int)(i + 1u));
			continue;
		}
		mb_call_bank(g_bankPg[i]);
	}
}

C_task main(void)
{
	os_initstdio();
	mb_init();

	printf("multibank: root 0100-7FFF, overlays @8000\r\n");
	printf("  data pg %u @C000, com window_2 was %u\r\n",
		   (unsigned int)g_dataPg, (unsigned int)g_main_pg.pgs.window_2);

	if (!demo_load_banks())
	{
		printf("Load failed. Need /bin/multibank/codeB_0N.bin\r\n");
		mb_shutdown();
		exit(1);
	}

	printf("\r\n");
	demo_run_banks();

	mb_shutdown();
	exit(0);
}
