#ifndef TEXTVIEW_VTXT_H
#define TEXTVIEW_VTXT_H

#define VTXT_W  80
#define VTXT_H  25
#define VTXT_CELLS (VTXT_W * VTXT_H)

unsigned char vtxt_init(void);
void vtxt_shutdown(void);
void vtxt_clear(unsigned char ch, unsigned char attr);
void vtxt_puts_row(unsigned char y, const unsigned char *s, unsigned char attr);
/* Write n chars at (x,y); leaves the rest of the row unchanged. */
void vtxt_puts_span(unsigned char y, unsigned char x, const unsigned char *s,
	unsigned char n, unsigned char attr);
void vtxt_present(void);
void vtxt_present_row(unsigned char y);
void vtxt_present_rows(unsigned char y0, unsigned char y1);

#endif
