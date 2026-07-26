#ifndef MB_PLUG_H
#define MB_PLUG_H

#include <oscalls.h>
#include <osfs.h>

#define MB_BANK_COUNT 3u

/* Physical pages (OS page numbers). */
extern unsigned char g_bankPg[MB_BANK_COUNT]; /* overlays @ 8000 */
extern unsigned char g_dataPg;                /* optional data @ C000 */
extern union APP_PAGES g_main_pg;

extern unsigned char *netbuf;

void mb_init(void);
void mb_shutdown(void);

void mb_data_select(void);
void mb_code_select_page(unsigned char page);

/* Root helpers overlays may CALL (same absolute addr as in .com). */
void mb_report_bank(unsigned int bank_nr);
/* puts/printf/putchar: call directly from banks; kept in .com via root refs. */

/* Load codeBank_XX.bin into a fresh OS page; returns 1 on success. */
unsigned char mb_load_bank_bin(const char *path, unsigned char *page_out);

/* Map page @8000, call entry at 0x8000, restore. */
void mb_call_bank(unsigned char page);

typedef void (*bank_entry_fn)(void);

#endif
