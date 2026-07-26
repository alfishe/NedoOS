#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "mb_inc.h"

/*
 * Overlay bank 1 @ 8000-BFFF.
 *
 * Call root/libc directly (puts, printf, mb_report_bank, ?).
 * Absolute CALL targets must match multibank.com (check_addrs.py).
 * String literals OK: lnk_ovl.xcl places CSTR at 8000 inside .bin.
 */

extern void mb_report_bank(unsigned int bank_nr); /* bank_nr: 1-based index */

void r_bank_entry(void){
	mb_report_bank(1u);
	puts("\r\nThis code amazing independent in codebank_01");
}
