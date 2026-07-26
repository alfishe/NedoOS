#ifndef TDESK_BANK_H
#define TDESK_BANK_H

/*
 * Memory map (tdesk):
 *   0100-7FFF  main CODE + DATA + stack
 *   8000-BFFF  reserved for future code banks (not used yet)
 *   C000-FFFF  16K data window (window records / heaps)
 *
 * Remap only via bank_push / bank_pop. Keep code below 8000 so
 * banking never hides the running program.
 */

#define BANK_WIN_C000   0xC000u
#define BANK_PAGE_SIZE  16384u

unsigned char bank_cur_c000(void);
unsigned char bank_cur_8000(void);

void bank_map_c000(unsigned char page);
void bank_map_8000(unsigned char page);

/* Map page at C000, return previous page (restore with bank_pop). */
unsigned char bank_push(unsigned char page);
void bank_pop(unsigned char saved);

unsigned char bank_new_page(unsigned char *page_out);
void bank_del_page(unsigned char page);

#endif
