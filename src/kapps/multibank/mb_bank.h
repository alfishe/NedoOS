#ifndef MB_BANK_H
#define MB_BANK_H

/*
 * Two bank windows:
 *   CODE window @ 0x8000  ? overlay code pages (codeB_XX.bin)
 *   DATA window @ 0xC000  ? optional heap-like buffers
 */

#define MB_CODE_ADDR   0x8000u
#define MB_DATA_ADDR   0xC000u
#define MB_PAGE_SIZE   16384u

#define MB_DATA_SIG_OFF     0u
#define MB_DATA_COUNTER_OFF 4u
#define MB_NETBUF_OFF       16u
#define MB_NETBUF_SIZE      512u
#define MB_DATA_SIG_MAGIC   0x4D42444Bul /* 'MBDK' */

/* Return: OS page currently mapped at 8000. */
unsigned char mb_code_current(void);

/* page ? OS page to map at 8000. */
void mb_code_map(unsigned char page);

/* Return: OS page currently mapped at C000. */
unsigned char mb_data_current(void);

/* page ? OS page to map at C000. */
void mb_data_map(unsigned char page);

/* page_out ? receives allocated OS page number.
 * Return: 1 ok, 0 fail. */
unsigned char mb_os_new_page(unsigned char *page_out);

/* page ? OS page to free (0 = no-op). */
void mb_os_release_page(unsigned char page);

/* page ? new code page at 8000.
 * Return: previous code page (for mb_code_pop). */
unsigned char mb_code_push(unsigned char page);

/* saved ? page from mb_code_push; restore it at 8000. */
void mb_code_pop(unsigned char saved);

/* page ? new data page at C000.
 * Return: previous data page (for mb_data_pop). */
unsigned char mb_data_push(unsigned char page);

/* saved ? page from mb_data_push; restore it at C000. */
void mb_data_pop(unsigned char saved);

/* page ? data page; off ? offset 0..16383 in C000 window; val ? byte. */
void mb_data_poke_u8(unsigned char page, unsigned int off, unsigned char val);

/* page ? data page; off ? offset in C000 window. Return: byte. */
unsigned char mb_data_peek_u8(unsigned char page, unsigned int off);

/* page ? data page; off ? offset; val ? little-endian u32. */
void mb_data_poke_u32(unsigned char page, unsigned int off, unsigned long val);

/* page ? data page; off ? offset. Return: little-endian u32. */
unsigned long mb_data_peek_u32(unsigned char page, unsigned int off);

/* page ? data page; fill_byte ? value written to all 16K. */
void mb_data_fill(unsigned char page, unsigned char fill_byte);

#endif
