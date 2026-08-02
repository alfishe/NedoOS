#include "mb_inc.h"
#include "mb_plug.h"
#include "mb_bank.h"

unsigned char g_bankPg[MB_BANK_COUNT];
unsigned char g_dataPg;
union APP_PAGES g_main_pg;
unsigned char *netbuf;

extern void force_helpers(void);

/*
 * Overlays CALL root/libc by absolute address (ovl-link time).
 * Root must reference any libc symbol banks use (puts/printf below).
 * Banks are entered via JT @8000 (bank_call.c), not a raw CALL 8000.
 */
static const char g_bank_fmt[] = "JT slot0 from codebank %u\r\n";

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

static void mb_fmt_bank_name(unsigned char idx0, char *name)
{
	sprintf(name, "codeB_%02u.bin", (unsigned int)(idx0 + 1u));
}

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
	printf("--- JT call bank1/2/3 ---\r\n");
	bank1();
	bank2();
	bank3();
}

C_task main(void)
{
	os_initstdio();
	mb_init();

	printf("multibank JT: root 0100-7FFF, code @8000, data @C000\r\n");
	printf("  data pg %u, cold window_2=%u\r\n",
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
