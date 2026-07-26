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

/* Alloc data page, force-link libc used by banks. */
void mb_init(void);

/* Release all overlay and data pages. */
void mb_shutdown(void);

/* Map g_dataPg at C000; set netbuf to data+MB_NETBUF_OFF (or 0). */
void mb_data_select(void);

/* page ? OS overlay page (0 = leave current). Map at 8000. */
void mb_code_select_page(unsigned char page);

/* bank_nr ? 1-based bank index for demo printf from overlay. */
void mb_report_bank(unsigned int bank_nr);

/* path ? file name (e.g. multibank/codeB_01.bin);
 * page_out ? receives allocated OS page with image at 8000.
 * Return: 1 ok, 0 fail. */
unsigned char mb_load_bank_bin(const char *path, unsigned char *page_out);

/* page ? loaded overlay OS page; CALL entry at 0x8000 then restore. */
void mb_call_bank(unsigned char page);

typedef void (*bank_entry_fn)(void);

#endif
