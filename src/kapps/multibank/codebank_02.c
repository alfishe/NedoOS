#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "mb_inc.h"

/* Overlay bank 2 ? call root/libc directly; see codebank_01.c */

extern void mb_report_bank(unsigned int bank_nr); /* bank_nr: 1-based index */

void r_bank_entry(void)
{
	mb_report_bank(2u);
	puts("\r\nThis code amazing independent in codebank_02");
}
