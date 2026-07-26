#include "mb_inc.h"
#include "mb_bank.h"

/* Return: OS page at 8000. */
unsigned char mb_code_current(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_2; /* 8000 */
}

/* page ? OS page to map at 8000. */
void mb_code_map(unsigned char page)
{
	OS_SETPG8000(page);
}

/* Return: OS page at C000. */
unsigned char mb_data_current(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_3; /* C000 */
}

/* page ? OS page to map at C000. */
void mb_data_map(unsigned char page)
{
	OS_SETPGC000(page);
}

/* page_out ? allocated OS page. Return: 1 ok, 0 fail. */
unsigned char mb_os_new_page(unsigned char *page_out)
{
	unsigned int pg;

	pg = OS_NEWPAGE();
	if (pg > 255u)
		return 0u;
	*page_out = (unsigned char)pg;
	return 1u;
}

/* page ? OS page to free (0 = no-op). */
void mb_os_release_page(unsigned char page)
{
	if (page != 0u)
		OS_DELPAGE(page);
}

/* page ? map at 8000. Return: previous page (for pop). */
unsigned char mb_code_push(unsigned char page)
{
	unsigned char saved;

	saved = mb_code_current();
	mb_code_map(page);
	return saved;
}

/* saved ? restore this page at 8000. */
void mb_code_pop(unsigned char saved)
{
	mb_code_map(saved);
}

/* page ? map at C000. Return: previous page (for pop). */
unsigned char mb_data_push(unsigned char page)
{
	unsigned char saved;

	saved = mb_data_current();
	mb_data_map(page);
	return saved;
}

/* saved ? restore this page at C000. */
void mb_data_pop(unsigned char saved)
{
	mb_data_map(saved);
}

/* page, off ? target in C000 window; val ? byte to write. */
void mb_data_poke_u8(unsigned char page, unsigned int off, unsigned char val)
{
	unsigned char saved;

	saved = mb_data_push(page);
	*(unsigned char *)(MB_DATA_ADDR + off) = val;
	mb_data_pop(saved);
}

/* page, off ? source in C000 window. Return: byte. */
unsigned char mb_data_peek_u8(unsigned char page, unsigned int off)
{
	unsigned char saved;
	unsigned char v;

	saved = mb_data_push(page);
	v = *(unsigned char *)(MB_DATA_ADDR + off);
	mb_data_pop(saved);
	return v;
}

/* page, off ? target; val ? u32 LE. */
void mb_data_poke_u32(unsigned char page, unsigned int off, unsigned long val)
{
	unsigned char saved;

	saved = mb_data_push(page);
	*(unsigned long *)(MB_DATA_ADDR + off) = val;
	mb_data_pop(saved);
}

/* page, off ? source. Return: u32 LE. */
unsigned long mb_data_peek_u32(unsigned char page, unsigned int off)
{
	unsigned char saved;
	unsigned long v;

	saved = mb_data_push(page);
	v = *(unsigned long *)(MB_DATA_ADDR + off);
	mb_data_pop(saved);
	return v;
}

/* page ? data page; fill_byte ? fill all 16K. */
void mb_data_fill(unsigned char page, unsigned char fill_byte)
{
	unsigned char saved;
	unsigned int i;

	saved = mb_data_push(page);
	for (i = 0u; i < MB_PAGE_SIZE; i++)
		((unsigned char *)MB_DATA_ADDR)[i] = fill_byte;
	mb_data_pop(saved);
}
