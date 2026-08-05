#include "mb_inc.h"
#include "mb_plug.h"

/*
 * Multibank demo: load codeB_01..NN, call via Plan JT (bank1/2/3).
 * Banking core lives in mb_core.c; JT wrappers in bank_call.c.
 */

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
