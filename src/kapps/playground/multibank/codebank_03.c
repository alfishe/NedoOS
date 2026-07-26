#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "mb_inc.h"

/* Overlay bank 3 ? call root/libc directly; see codebank_01.c */

extern void mb_report_bank(unsigned int bank_nr);

void r_bank_entry(void)
{
	mb_report_bank(3u);
	puts("\r\nThis code amazing independent in codebank_03");
}
