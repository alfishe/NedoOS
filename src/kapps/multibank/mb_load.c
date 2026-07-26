#include "mb_inc.h"
#include "mb_bank.h"
#include "mb_plug.h"

/* fp ? OS_OPENHANDLE result (HL packed). Return: 1 if errno==0. */
static unsigned char mb_open_ok(FILE *fp)
{
	return (((unsigned int)fp) & 0xffu) == 0u;
}

/* path ? overlay .bin path; page_out ? allocated OS page @8000. Return: 1/0. */
unsigned char mb_load_bank_bin(const char *path, unsigned char *page_out)
{
	FILE *fp;
	unsigned char page;
	unsigned char saved;
	unsigned long sz;
	unsigned int nread;
	unsigned int i;

	if (page_out == 0 || path == 0)
		return 0u;

	if (!mb_os_new_page(&page))
		return 0u;

	fp = OS_OPENHANDLE((unsigned char *)path, 0x80u);
	if (!mb_open_ok(fp))
	{
		mb_os_release_page(page);
		return 0u;
	}

	sz = OS_GETFILESIZE(fp);
	if (sz == 0ul || sz > (unsigned long)MB_PAGE_SIZE)
	{
		OS_CLOSEHANDLE(fp);
		mb_os_release_page(page);
		return 0u;
	}

	saved = mb_code_push(page);

	/* Clear page then read overlay image at 0x8000. */
	for (i = 0u; i < MB_PAGE_SIZE; i++)
		((unsigned char *)MB_CODE_ADDR)[i] = 0u;

	nread = OS_READHANDLE((unsigned char *)MB_CODE_ADDR, fp, (unsigned int)sz);
	OS_CLOSEHANDLE(fp);
	mb_code_pop(saved);

	if (nread != (unsigned int)sz)
	{
		mb_os_release_page(page);
		return 0u;
	}

	*page_out = page;
	return 1u;
}

/* page ? OS page with overlay; maps @8000, CALL 0x8000, restores prior. */
void mb_call_bank(unsigned char page)
{
	unsigned char saved;
	bank_entry_fn entry;

	saved = mb_code_push(page);
	entry = (bank_entry_fn)MB_CODE_ADDR;
	entry();
	mb_code_pop(saved);
}
