#include "emptyres_inc.h"
#include "emptyres_plug.h"
#include "app_bank.h"

unsigned char residentPg;
unsigned char g_dataPg;
union APP_PAGES main_pg;

static unsigned char resident_call_push(void)
{
	return bank_push(residentPg);
}

static void resident_call_pop(unsigned char saved)
{
	bank_pop(saved);
}

unsigned short ui_mock_magic(void)
{
	unsigned char saved;
	unsigned short v;

	saved = resident_call_push();
	v = r_mock_magic();
	resident_call_pop(saved);
	return v;
}

unsigned char ui_mock_transform(unsigned char tag)
{
	unsigned char saved;
	unsigned char v;

	saved = resident_call_push();
	v = r_mock_transform(tag);
	resident_call_pop(saved);
	return v;
}

void ui_mock_message(char *buf, unsigned char buf_sz, const char *prefix)
{
	unsigned char saved;

	saved = resident_call_push();
	r_mock_message(buf, buf_sz, prefix);
	resident_call_pop(saved);
}

void er_init_banks(void)
{
	main_pg.l = OS_GETMAINPAGES();
	residentPg = main_pg.pgs.window_3;
	bank_slot_set(ER_BANK_SLOT_RESIDENT, residentPg);

	g_dataPg = 0u;
	if (bank_os_new_page(&g_dataPg))
	{
		bank_slot_set(ER_BANK_SLOT_DATA, g_dataPg);
		bank_data_poke_u32(g_dataPg, ER_DATA_SIG_OFF, ER_DATA_SIG_MAGIC);
		bank_data_poke_u32(g_dataPg, ER_DATA_COUNTER_OFF, 1ul);
		bank_data_poke_u8(g_dataPg, ER_DATA_PAYLOAD_OFF, 0xBEu);
	}
}

static void demo_data_bank(void)
{
	unsigned long sig;
	unsigned char payload;
	unsigned char map_now;

	printf("--- data bank (page %u @ C000) ---\r\n", (unsigned int)g_dataPg);
	if (g_dataPg == 0u)
	{
		printf("  OS_NEWPAGE failed\r\n");
		return;
	}

	sig = bank_data_peek_u32(g_dataPg, ER_DATA_SIG_OFF);
	payload = bank_data_peek_u8(g_dataPg, ER_DATA_PAYLOAD_OFF);
	printf("  sig=0x%lX payload=0x%02X\r\n", sig, payload);

	bank_data_poke_u8(g_dataPg, ER_DATA_PAYLOAD_OFF, 0xEFu);
	payload = bank_data_peek_u8(g_dataPg, ER_DATA_PAYLOAD_OFF);
	printf("  after poke payload=0x%02X\r\n", payload);

	map_now = bank_window_current();
	printf("  C000 maps page %u (resident=%u data=%u)\r\n",
		   (unsigned int)map_now, (unsigned int)residentPg, (unsigned int)g_dataPg);
}

static void demo_resident_bank(void)
{
	unsigned short magic;
	unsigned char tag;
	unsigned char out;
	char msg[48];

	printf("--- resident bank (page %u @ C000) ---\r\n", (unsigned int)residentPg);

	magic = ui_mock_magic();
	printf("  r_mock_magic()=0x%04X (expect 0x%04X)\r\n", magic, ER_R_MOCK_MAGIC);

	tag = 0x42u;
	out = ui_mock_transform(tag);
	printf("  r_mock_transform(0x%02X)=0x%02X (expect 0x%02X)\r\n", tag, out, (unsigned char)(tag ^ 0xA5u));

	ui_mock_message(msg, (unsigned char)sizeof(msg), "hello");
	printf("  r_mock_message: %s\r\n", msg);
}

static void demo_nested_map(void)
{
	unsigned char saved;
	unsigned long sig;

	printf("--- nested map: resident -> data ---\r\n");
	saved = bank_push_slot(ER_BANK_SLOT_RESIDENT);
	(void)ui_mock_magic();
	sig = bank_data_peek_u32(g_dataPg, ER_DATA_SIG_OFF);
	printf("  read data sig while resident mapped: 0x%lX\r\n", sig);
	bank_pop(saved);
	sig = bank_data_peek_u32(g_dataPg, ER_DATA_SIG_OFF);
	printf("  read data sig after restore: 0x%lX\r\n", sig);
}

C_task main(void)
{
	os_initstdio();

	/* Bank init can take a while (OS_NEWPAGE, fill @ C000). Do it before any
	 * printf ? otherwise cmd redraws "M:/path>" on the idle line and the next
	 * print appends to that prompt. */
	er_init_banks();

	printf("emptyres: bank window toolkit demo\r\n");
	printf("main @ 0100-BFFF, bank @ C000\r\n\r\n");

	demo_data_bank();
	printf("\r\n");
	demo_resident_bank();
	printf("\r\n");
	demo_nested_map();
	
	if (g_dataPg != 0u)
		bank_os_release_page(g_dataPg);
	exit(0);
}
