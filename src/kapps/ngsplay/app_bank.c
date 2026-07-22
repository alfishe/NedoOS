#include <oscalls.h>
#include "app_bank.h"

static unsigned char g_bank_slots[BANK_SLOT_COUNT];
static unsigned char g_bank_stack[BANK_STACK_MAX];
static unsigned char g_bank_sp;

unsigned char bank_window_current(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_3;
}

void bank_window_map(unsigned char page)
{
	SETPG32KHIGH(page);
}

unsigned char bank_os_new_page(unsigned char *page_out)
{
	unsigned int pg;

	pg = OS_NEWPAGE();
	if (pg > 255u)
		return 0u;
	*page_out = (unsigned char)pg;
	return 1u;
}

void bank_os_release_page(unsigned char page)
{
	if (page != 0u)
		OS_DELPAGE(page);
}

unsigned char bank_push(unsigned char page)
{
	unsigned char saved;

	saved = bank_window_current();
	bank_window_map(page);
	return saved;
}

void bank_pop(unsigned char saved)
{
	bank_window_map(saved);
}

unsigned char bank_push_stack(unsigned char page)
{
	unsigned char saved;

	saved = bank_window_current();
	if (g_bank_sp < BANK_STACK_MAX)
		g_bank_stack[g_bank_sp++] = saved;
	bank_window_map(page);
	return saved;
}

void bank_pop_stack(void)
{
	unsigned char saved;

	if (g_bank_sp == 0u)
		return;
	saved = g_bank_stack[--g_bank_sp];
	bank_window_map(saved);
}

void bank_slot_set(unsigned char slot, unsigned char page)
{
	if (slot < BANK_SLOT_COUNT)
		g_bank_slots[slot] = page;
}

unsigned char bank_slot_get(unsigned char slot)
{
	if (slot >= BANK_SLOT_COUNT)
		return 0u;
	return g_bank_slots[slot];
}

unsigned char bank_push_slot(unsigned char slot)
{
	return bank_push(bank_slot_get(slot));
}

void bank_data_poke_u8(unsigned char page, unsigned int off, unsigned char val)
{
	unsigned char saved;

	saved = bank_push(page);
	*(unsigned char *)(BANK_WINDOW_ADDR + off) = val;
	bank_pop(saved);
}

unsigned char bank_data_peek_u8(unsigned char page, unsigned int off)
{
	unsigned char saved;
	unsigned char v;

	saved = bank_push(page);
	v = *(unsigned char *)(BANK_WINDOW_ADDR + off);
	bank_pop(saved);
	return v;
}

void bank_data_poke_u32(unsigned char page, unsigned int off, unsigned long val)
{
	unsigned char saved;

	saved = bank_push(page);
	*(unsigned long *)(BANK_WINDOW_ADDR + off) = val;
	bank_pop(saved);
}

unsigned long bank_data_peek_u32(unsigned char page, unsigned int off)
{
	unsigned char saved;
	unsigned long v;

	saved = bank_push(page);
	v = *(unsigned long *)(BANK_WINDOW_ADDR + off);
	bank_pop(saved);
	return v;
}

void bank_data_fill(unsigned char page, unsigned char fill_byte)
{
	unsigned char saved;
	unsigned int i;

	saved = bank_push(page);
	for (i = 0u; i < BANK_PAGE_SIZE; i++)
		((unsigned char *)BANK_WINDOW_ADDR)[i] = fill_byte;
	bank_pop(saved);
}
