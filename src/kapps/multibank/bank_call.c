#include "mb_inc.h"
#include "mb_plug.h"
#include "bank_jt.h"

/*
 * Plan JT wrappers: map bank @8000, CALL slot, restore previous @8000.
 *
 * Override the trio together (before #ifndef below), e.g.:
 *
 *   Always return to a session bank (e.g. bank01):
 *     #define MB_BANK_SAVE()
 *     #define MB_BANK_ENTER(idx) OS_SETPG8000(g_bankPg[(idx)])
 *     #define MB_BANK_LEAVE()    OS_SETPG8000(g_bankPg[0])
 *
 *   Full no-op (page already correct):
 *     #define MB_BANK_SAVE()
 *     #define MB_BANK_ENTER(idx) ((void)0)
 *     #define MB_BANK_LEAVE()    ((void)0)
 *
 * Empty SAVE = "#define MB_BANK_SAVE()" ? true no-op (no tokens).
 * Do not put ';' after MB_BANK_SAVE() in wrappers (C89 declaration rules).
 * Default SAVE includes its own trailing ';'.
 */

#ifndef MB_BANK_SAVE
#define MB_BANK_SAVE() \
	unsigned char _mb_saved8000 = mb_code_current();
#define MB_BANK_ENTER(idx) OS_SETPG8000(g_bankPg[(idx)])
#define MB_BANK_LEAVE()    OS_SETPG8000(_mb_saved8000)
#endif

void mb_run_bank(unsigned char idx0)
{
	void (*fn)(void);
	MB_BANK_SAVE()

	if (idx0 >= MB_BANK_COUNT || g_bankPg[idx0] == 0u)
	{
		MB_BANK_LEAVE();
		return;
	}

	OS_SETPG8000(g_bankPg[idx0]);
	fn = (void (*)(void))MB_JT_ADDR(MB_JT_ENTRY);
	fn();
	MB_BANK_LEAVE();
}

/* mbgen:banks-begin */
void bank1(void)
{
	mb_run_bank(0u);
}

void bank2(void)
{
	mb_run_bank(1u);
}

void bank3(void)
{
	mb_run_bank(2u);
}
/* mbgen:banks-end */
