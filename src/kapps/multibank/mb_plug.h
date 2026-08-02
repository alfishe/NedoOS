#ifndef MB_PLUG_H
#define MB_PLUG_H

#include <oscalls.h>
#include <osfs.h>
#include "mb_banks.h" /* MB_BANK_COUNT from Makefile BANKS via mbovl gen-h */

/* Physical pages (OS page numbers). */
extern unsigned char g_bankPg[MB_BANK_COUNT]; /* overlays @ 8000 */
extern unsigned char g_dataPg;                /* optional data @ C000 */
extern union APP_PAGES g_main_pg;

extern unsigned char *netbuf;

void mb_init(void);
void mb_shutdown(void);
void mb_data_select(void);
void mb_code_select_page(unsigned char page);
void mb_report_bank(unsigned int bank_nr);

unsigned char mb_load_bank_bin(const char *path, unsigned char *page_out);

/* Plan JT: map g_bankPg[idx0], CALL slot0, restore window_2. */
void mb_run_bank(unsigned char idx0);
void bank1(void);
void bank2(void);
void bank3(void);

/* Legacy raw CALL 8000 (works while JT starts with JP). Prefer mb_run_bank. */
void mb_call_bank(unsigned char page);

typedef void (*bank_entry_fn)(void);

#endif
