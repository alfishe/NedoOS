#ifndef TDESK_VTXT_H
#define TDESK_VTXT_H

/*
 * Soft text framebuffer + fast present into ATM/NedoOS text VRAM.
 *
 * Backbuffer is linear 80x25 char + attr in low RAM (0100-7FFF).
 * Present maps user_scr0 pages at C000 and writes with ATM addressing
 * (same scheme as BDOS_paint_row). App uses CP866 codes; vtxt converts
 * via 866toatm (BDOS trecode) so glyphs match NC on ATM font.
 */

#define VTXT_W  80
#define VTXT_H  25
#define VTXT_CELLS (VTXT_W * VTXT_H)

unsigned char vtxt_init(void);
void vtxt_shutdown(void);

void vtxt_clear(unsigned char ch, unsigned char attr);
void vtxt_putc(unsigned char x, unsigned char y,
	       unsigned char ch, unsigned char attr);
void vtxt_puts(unsigned char x, unsigned char y,
	       const char *s, unsigned char attr);
void vtxt_fill(unsigned char x, unsigned char y,
	       unsigned char w, unsigned char h,
	       unsigned char ch, unsigned char attr);
void vtxt_hline(unsigned char x, unsigned char y,
		unsigned char n, unsigned char ch, unsigned char attr);

/* Compose done ? blast backbuffer to video pages. */
void vtxt_present(void);

unsigned char *vtxt_chars(void);
unsigned char *vtxt_attrs(void);

#endif
