#ifndef APP_BANK_H
#define APP_BANK_H

/*
 * Universal 16K bank window @ 0xC000 for NedoOS kapps.
 *
 * Main code/data live in 0100-BFFF. Code (CODE_RESIDENT) and extra data pages
 * are accessed through SETPG32KHIGH(page). Never call resident functions without
 * mapping residentPg first ? use bank_push/bank_pop or ui_* wrappers.
 */

#define BANK_WINDOW_ADDR 0xC000u
#define BANK_PAGE_SIZE   16384u
#define BANK_SLOT_COUNT  4u
#define BANK_STACK_MAX   4u

unsigned char bank_window_current(void);
void bank_window_map(unsigned char page);

unsigned char bank_os_new_page(unsigned char *page_out);
void bank_os_release_page(unsigned char page);

unsigned char bank_push(unsigned char page);
void bank_pop(unsigned char saved);

unsigned char bank_push_stack(unsigned char page);
void bank_pop_stack(void);

void bank_slot_set(unsigned char slot, unsigned char page);
unsigned char bank_slot_get(unsigned char slot);
unsigned char bank_push_slot(unsigned char slot);

void bank_data_poke_u8(unsigned char page, unsigned int off, unsigned char val);
unsigned char bank_data_peek_u8(unsigned char page, unsigned int off);
void bank_data_poke_u32(unsigned char page, unsigned int off, unsigned long val);
unsigned long bank_data_peek_u32(unsigned char page, unsigned int off);
void bank_data_fill(unsigned char page, unsigned char fill_byte);

#endif
