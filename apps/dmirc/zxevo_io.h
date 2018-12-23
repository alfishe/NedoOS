
#include <intrz80.h>
#define EVO_KEYB_REG    0x0f
#define set_evo_rtc(rtc_ad,rtc_val)     {output((unsigned short)0xdef7,rtc_ad); output((unsigned short)0xbef7,rtc_val);}
//#define get_evo_rtc(rtc_ad)             {output((unsigned short)0xdef7,rtc_ad); input((unsigned short)0xbef7);}
//#define putchar(_ch) (((int (*)(int,unsigned char))0x0005)(_ch,0x05))
//#define getchar() (((int (*)(void))0x0008)())

void initMCU(void);
void mcu_soft_reset(void);
unsigned char get_evo_rtc(unsigned char addr);
void kbd_read(void);
void wiz_reset(void);   
void flash_cursor(void);
extern unsigned char * SCR_XY2PTR(void);
extern unsigned char * ATTR_XY2PTR(void);
struct _window
{
	unsigned char x,y,w,h,cx,cy;
};
#define KBD_BUF_SIZE
struct keybuffer{
	unsigned char * ptr;
	unsigned char buf[256];
};
#define WINDOW struct _window
//extern WINDOW * _cur_win;
//extern WINDOW * _edit_win;
extern unsigned long int_count;   
//#define CUR_WIN(_cw) _cur_win=&(_cw)
//#define EDIT_WIN(_cw) _edit_win=&(_cw)

#define FLS_CURS 0x01
#define FLS_KBD 0x02
#define FLS_STR 0x04
#define FLS_LGN 0x08
extern unsigned char fls;


void delayms(unsigned char ms);
#define DELAYMS(tick_) delayms((tick_+20)/20)