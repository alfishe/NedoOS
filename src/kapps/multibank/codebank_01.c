#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "mb_inc.h"

/*
 * Overlay bank 1 @8000 ? JT slot 0 -> r_bank_entry.
 * Strings OK: Makefile rewrites CSTR -> CSTR_RESIDENT.
 * Call root libc directly (puts/printf/mb_report_bank).
 */

extern void mb_report_bank(unsigned int bank_nr);

void r_bank_entry(void)
{
	mb_report_bank(1u);
	puts("bank01 ok\r\n");
}
