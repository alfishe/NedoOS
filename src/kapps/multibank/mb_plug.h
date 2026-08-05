#ifndef MB_PLUG_H
#define MB_PLUG_H

#include <oscalls.h>
#include <osfs.h>
#include "mb_banks.h" /* MB_BANK_COUNT from Makefile BANKS via mbovl gen-h */

/*
 * Two bank windows:
 *   CODE @ 0x8000  ? overlay pages (codeB_XX.bin)
 *   DATA @ 0xC000  ? optional heap-like buffers
 */

#define MB_CODE_ADDR   0x8000u
#define MB_DATA_ADDR   0xC000u
#define MB_PAGE_SIZE   16384u

#define MB_DATA_SIG_OFF     0u
#define MB_DATA_COUNTER_OFF 4u
#define MB_NETBUF_OFF       16u
#define MB_NETBUF_SIZE      512u
#define MB_DATA_SIG_MAGIC   0x4D42444Bul /* 'MBDK' */

/* Physical pages (OS page numbers). */
extern unsigned char g_bankPg[MB_BANK_COUNT]; /* overlays @ 8000 */
extern unsigned char g_dataPg;                /* optional data @ C000 */
extern union APP_PAGES g_main_pg;
extern unsigned char *netbuf;

/* ---- page map / alloc ---- */
unsigned char mb_code_current(void);
void mb_code_map(unsigned char page);
unsigned char mb_data_current(void);
void mb_data_map(unsigned char page);
unsigned char mb_os_new_page(unsigned char *page_out);
void mb_os_release_page(unsigned char page);
unsigned char mb_code_push(unsigned char page);
void mb_code_pop(unsigned char saved);
unsigned char mb_data_push(unsigned char page);
void mb_data_pop(unsigned char saved);

/* ---- datapage helpers ---- */
void mb_data_poke_u32(unsigned char page, unsigned int off, unsigned long val);
unsigned long mb_data_peek_u32(unsigned char page, unsigned int off);
void mb_data_fill(unsigned char page, unsigned char fill_byte);

/* ---- root lifecycle / load ---- */
void mb_init(void);
void mb_shutdown(void);
void mb_data_select(void);
void mb_report_bank(unsigned int bank_nr);
unsigned char mb_load_bank_bin(const char *path, unsigned char *page_out);

/* Plan JT: map g_bankPg[idx0], CALL slot0, restore previous @8000 (MB_BANK_*). */
void mb_run_bank(unsigned char idx0);
/* mbgen:banks-begin */
void bank1(void);
void bank2(void);
void bank3(void);
/* mbgen:banks-end */

typedef void (*bank_entry_fn)(void);

#endif
