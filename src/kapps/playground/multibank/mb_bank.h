#ifndef MB_BANK_H
#define MB_BANK_H

/*
 * Two bank windows:
 *   CODE window @ 0x8000  ? overlay code pages (codeBank_XX.bin)
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

void mb_data_poke_u8(unsigned char page, unsigned int off, unsigned char val);
unsigned char mb_data_peek_u8(unsigned char page, unsigned int off);
void mb_data_poke_u32(unsigned char page, unsigned int off, unsigned long val);
unsigned long mb_data_peek_u32(unsigned char page, unsigned int off);
void mb_data_fill(unsigned char page, unsigned char fill_byte);

#endif
