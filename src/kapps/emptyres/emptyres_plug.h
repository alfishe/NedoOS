#ifndef EMPTYRES_PLUG_H
#define EMPTYRES_PLUG_H

#include <oscalls.h>

/* Bank window: one physical 16K page mapped at 0xC000 (see app_bank.h). */
#define ER_BANK_SLOT_RESIDENT 0u
#define ER_BANK_SLOT_DATA     1u
#define ER_BANK_SLOTS         4u

/* Demo data page layout @ BANK_WINDOW_ADDR. */
#define ER_DATA_SIG_OFF     0u
#define ER_DATA_COUNTER_OFF 4u
#define ER_DATA_PAYLOAD_OFF 8u
#define ER_DATA_SIG_MAGIC   0xEDA7A7EDul

/* Resident mock: return tag if code really runs from mapped resident page. */
#define ER_R_MOCK_MAGIC     0x524Eu /* 'NR' little-endian in 16-bit */

extern unsigned char residentPg;
extern unsigned char g_dataPg;
extern union APP_PAGES main_pg;

void er_init_banks(void);

/* CODE_RESIDENT @ C000 ? call only while residentPg is mapped. */
unsigned short r_mock_magic(void);
unsigned char r_mock_transform(unsigned char tag);
void r_mock_message(char *buf, unsigned char buf_sz, const char *prefix);

/* Main-segment wrappers (map resident, call, restore). */
unsigned short ui_mock_magic(void);
unsigned char ui_mock_transform(unsigned char tag);
void ui_mock_message(char *buf, unsigned char buf_sz, const char *prefix);

#endif
