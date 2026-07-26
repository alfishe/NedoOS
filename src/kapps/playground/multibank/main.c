#include "mb_inc.h"
#include "mb_plug.h"
#include "mb_bank.h"

unsigned char g_codePg;
unsigned char g_dataPg;
union APP_PAGES g_main_pg;

/* Points into data page @ C000 + MB_NETBUF_OFF (valid while data page mapped). */
unsigned char *netbuf;

void mb_code_select(void)
{
	if (g_codePg != 0u)
		mb_code_map(g_codePg);
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
	g_main_pg.l = OS_GETMAINPAGES();

	/* Code page already loaded into window_2 by .com (CODE_RESIDENT @ 8000). */
	g_codePg = g_main_pg.pgs.window_2;
	mb_code_select();

	/* Data page: allocate and map permanently at C000 for this demo. */
	g_dataPg = 0u;
	netbuf = 0;
	if (mb_os_new_page(&g_dataPg))
	{
		mb_data_fill(g_dataPg, 0u);
		mb_data_select();
		mb_data_poke_u32(g_dataPg, MB_DATA_SIG_OFF, MB_DATA_SIG_MAGIC);
		mb_data_poke_u32(g_dataPg, MB_DATA_COUNTER_OFF, 1ul);
		/* After poke helpers, re-select so netbuf mapping is current. */
		mb_data_select();
	}
}

void mb_shutdown(void)
{
	if (g_dataPg != 0u)
	{
		mb_os_release_page(g_dataPg);
		g_dataPg = 0u;
		netbuf = 0;
	}
}

unsigned short ui_mock_magic(void)
{
	unsigned char saved;
	unsigned short v;

	saved = mb_code_push(g_codePg);
	v = r_mock_magic();
	mb_code_pop(saved);
	return v;
}

unsigned char ui_mock_transform(unsigned char tag)
{
	unsigned char saved;
	unsigned char v;

	saved = mb_code_push(g_codePg);
	v = r_mock_transform(tag);
	mb_code_pop(saved);
	return v;
}

void ui_mock_message(char *buf, unsigned char buf_sz, const char *prefix)
{
	unsigned char saved;

	saved = mb_code_push(g_codePg);
	r_mock_message(buf, buf_sz, prefix);
	mb_code_pop(saved);
}

unsigned int ui_fill_netbuf(unsigned char seed, unsigned int n)
{
	unsigned char saved_code;
	unsigned int got;

	/* Data stays @ C000; only code window is switched if needed. */
	mb_data_select();
	saved_code = mb_code_push(g_codePg);
	got = r_fill_netbuf(seed, n);
	mb_code_pop(saved_code);
	return got;
}

void blit_mark_data(unsigned char tag)
{
	/* Root-side "blitter": write a marker into data page without resident. */
	mb_data_select();
	if (netbuf != 0)
		netbuf[0] = tag;
	mb_data_poke_u8(g_dataPg, MB_DATA_COUNTER_OFF, tag);
}

static void demo_map(void)
{
	printf("map: root 0100-7FFF, code pg %u @8000, data pg %u @C000\r\n",
		   (unsigned int)g_codePg, (unsigned int)g_dataPg);
	printf("  cur code window pg=%u data window pg=%u\r\n",
		   (unsigned int)mb_code_current(), (unsigned int)mb_data_current());
	printf("  netbuf=%p (expect C000+%u)\r\n",
		   (void *)netbuf, (unsigned int)MB_NETBUF_OFF);
}

static void demo_data(void)
{
	unsigned long sig;
	unsigned char b0;

	printf("--- data page @ C000 ---\r\n");
	if (g_dataPg == 0u)
	{
		printf("  OS_NEWPAGE failed\r\n");
		return;
	}

	sig = mb_data_peek_u32(g_dataPg, MB_DATA_SIG_OFF);
	printf("  sig=0x%lX (expect 0x%lX)\r\n", sig, MB_DATA_SIG_MAGIC);

	blit_mark_data(0x5Au);
	mb_data_select();
	b0 = (netbuf != 0) ? netbuf[0] : 0u;
	printf("  blit netbuf[0]=0x%02X\r\n", b0);
}

static void demo_code(void)
{
	unsigned short magic;
	unsigned char out;
	char msg[48];
	unsigned int n;
	unsigned char i;

	printf("--- code page @ 8000 ---\r\n");

	magic = ui_mock_magic();
	printf("  r_mock_magic=0x%04X\r\n", magic);

	out = ui_mock_transform(0x42u);
	printf("  r_mock_transform(0x42)=0x%02X\r\n", out);

	ui_mock_message(msg, (unsigned char)sizeof(msg), "hello");
	printf("  r_mock_message: %s\r\n", msg);

	/* Resident fills netbuf while data page remains mapped @ C000. */
	n = ui_fill_netbuf(0x10u, 8u);
	printf("  r_fill_netbuf n=%u:", n);
	mb_data_select();
	for (i = 0u; i < n && i < 8u; i++)
		printf(" %02X", (unsigned int)netbuf[i]);
	printf("\r\n");
}

static void demo_both_windows(void)
{
	unsigned short magic;

	printf("--- both windows at once ---\r\n");
	/* Keep data @ C000 and code @ 8000; call resident that uses netbuf. */
	mb_data_select();
	mb_code_select();
	magic = r_mock_magic(); /* direct call: both pages already selected */
	(void)r_fill_netbuf(0xA0u, 4u);
	printf("  direct r_mock_magic=0x%04X netbuf:", magic);
	printf(" %02X %02X %02X %02X\r\n",
		   (unsigned int)netbuf[0], (unsigned int)netbuf[1],
		   (unsigned int)netbuf[2], (unsigned int)netbuf[3]);
}

C_task main(void)
{
	os_initstdio();

	/* Init before printf (same reason as emptyres: avoid prompt glue). */
	mb_init();

	printf("multibank skeleton\r\n");
	demo_map();
	printf("\r\n");
	demo_data();
	printf("\r\n");
	demo_code();
	printf("\r\n");
	demo_both_windows();

	mb_shutdown();
	exit(0);
}
