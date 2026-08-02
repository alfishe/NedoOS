#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "mb_inc.h"

/* Overlay bank 2 ? JT slot 0 -> r_bank_entry */

extern void mb_report_bank(unsigned int bank_nr);

void r_bank_entry(void)
{
	mb_report_bank(2u);
	puts("bank02 ok\r\n");
}
