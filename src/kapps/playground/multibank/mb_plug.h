#ifndef MB_PLUG_H
#define MB_PLUG_H

#include <oscalls.h>

/* Physical pages (OS page numbers). */
extern unsigned char g_codePg;   /* CODE_RESIDENT, window @ 8000 */
extern unsigned char g_dataPg;   /* data page, window @ C000 */
extern union APP_PAGES g_main_pg;

/*
 * netbuf-style pointer: always 0xC000 + offset, valid only while g_dataPg
 * is mapped at C000. Prefer keeping data page mapped after mb_init().
 */
extern unsigned char *netbuf;

void mb_init(void);
void mb_shutdown(void);

/* Ensure data page is mapped; netbuf points into it. */
void mb_data_select(void);

/* Ensure code page is mapped at 8000. */
void mb_code_select(void);

/* CODE_RESIDENT @ 8000 — call only while g_codePg is mapped there. */
unsigned short r_mock_magic(void);
unsigned char r_mock_transform(unsigned char tag);
void r_mock_message(char *buf, unsigned char buf_sz, const char *prefix);
/* Resident reads/writes netbuf while data page stays @ C000. */
unsigned int r_fill_netbuf(unsigned char seed, unsigned int n);

/* Root wrappers: map code page, call, restore (data window untouched). */
unsigned short ui_mock_magic(void);
unsigned char ui_mock_transform(unsigned char tag);
void ui_mock_message(char *buf, unsigned char buf_sz, const char *prefix);
unsigned int ui_fill_netbuf(unsigned char seed, unsigned int n);

/* Root "blitter": touches data page @ C000 (demo fill). */
void blit_mark_data(unsigned char tag);

#endif
