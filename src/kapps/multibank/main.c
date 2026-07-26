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

/* bank_nr ? 1-based overlay number printed by printf. */
void mb_report_bank(unsigned int bank_nr)
{
	printf(g_bank_fmt, bank_nr);
}

/* page ? OS page to map at 8000 (0 = no-op). */
void mb_code_select_page(unsigned char page)
{
	if (page != 0u)
		mb_code_map(page);
}

/* Map g_dataPg @C000; netbuf -> data+MB_NETBUF_OFF. */
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

/* idx0 - 0-based bank index; name - out buf >=13 for "codeB_NN.bin". */
static void mb_fmt_bank_name(unsigned char idx0, char *name)
{
	sprintf(name, "codeB_%02u.bin", (unsigned int)(idx0 + 1u));
}

/* idx - 0-based; page_out - OS page of loaded .bin.
 * Tries multibank/ then bin/multibank/. Return: 1 ok, 0 fail. */
static unsigned char mb_try_load(unsigned char idx, unsigned char *page_out)
{
	char path[40];
	char name[16];

	mb_fmt_bank_name(idx, name);

	strcpy(path, "multibank/");
	strcat(path, name);
	if (mb_load_bank_bin(path, page_out))
		return 1u;

	strcpy(path, "bin/multibank/");
	strcat(path, name);
	return mb_load_bank_bin(path, page_out);
}

/* Alloc g_dataPg, force-link puts for overlays. */
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

/* Free all g_bankPg[] and g_dataPg. */
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
	char name[16];

	ok = 1u;
	printf("--- load overlays ---\r\n");
	for (i = 0u; i < MB_BANK_COUNT; i++)
	{
		mb_fmt_bank_name(i, name);
		if (!mb_try_load(i, &g_bankPg[i]))
		{
			printf("  FAIL %s\r\n", name);
			ok = 0u;
		}
		else
			printf("  OK   %s -> page %u\r\n",
				   name, (unsigned int)g_bankPg[i]);
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
	getchar();
	exit(0);
}
