#ifndef APP_BANK_H
#define APP_BANK_H

/*
 * 16K bank window @ 0xC000 for atelnet (see emptyres / nc).
 * Resident code stays mapped here except while zmodem uses g_dataPg.
 */

#define BANK_WINDOW_ADDR 0xC000u
#define BANK_PAGE_SIZE   16384u

unsigned char bank_window_current(void);
unsigned char bank_push(unsigned char page);

#endif
