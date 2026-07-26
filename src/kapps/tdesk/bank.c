#include <oscalls.h>
#include "bank.h"

unsigned char bank_cur_c000(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_3;
}

unsigned char bank_cur_8000(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_2;
}

void bank_map_c000(unsigned char page)
{
	SETPG32KHIGH(page);
}

void bank_map_8000(unsigned char page)
{
	OS_SETPG8000(page);
}

unsigned char bank_push(unsigned char page)
{
	unsigned char saved;

	saved = bank_cur_c000();
	bank_map_c000(page);
	return saved;
}

void bank_pop(unsigned char saved)
{
	bank_map_c000(saved);
}

unsigned char bank_new_page(unsigned char *page_out)
{
	unsigned int pg;

	pg = OS_NEWPAGE();
	if (pg > 255u)
		return 0u;
	*page_out = (unsigned char)pg;
	return 1u;
}

void bank_del_page(unsigned char page)
{
	if (page != 0u)
		OS_DELPAGE((char)page);
}
