#ifndef OSCALLS_H
#define OSCALLS_H
void YIELD(void);
void OS_SETGFX(unsigned char mode);
void OS_CLS(unsigned char color);
void OS_SETXY(unsigned char x,unsigned char y);
void OS_SCROLLUP(unsigned int xy, unsigned int wh);
unsigned int _low_level_get(void);
unsigned int OS_GETXY(void);
void conv1251to866(unsigned char * bufer);
extern unsigned char t1251to866[128];
unsigned int OS_CREATEHANDLE(unsigned char * path, unsigned char flags);
#endif