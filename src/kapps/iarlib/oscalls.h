#ifndef OSCALLS_H
#define OSCALLS_H

void OS_DROPAPP(unsigned char id);
unsigned long OS_GETAPPMAINPAGES(unsigned char id);
unsigned char OS_GETPAGEOWNER(unsigned char id);
void YIELD(void);
void OS_SETGFX(unsigned char mode);
void OS_CLS(unsigned char color);
void OS_SETCOLOR(unsigned char color);
void OS_PRATTR(unsigned char attribute);
void OS_SETXY(unsigned char x, unsigned char y);
void OS_SETXYW(unsigned int w);
void OS_SETMUSIC(void (*play)(void), unsigned char pg);
void os_initstdio(void);
void print(unsigned char *);
unsigned int OS_GETXY(void);
unsigned char OS_GETATTR(void);
long time(void); // Alone Coder

// Kulich Area

struct diskOp
{
	unsigned char drive;
	void *BufAdr;
	unsigned long sector;
	unsigned char count;
};

unsigned int OS_READSECTORS(struct diskOp *);
unsigned int OS_WRITESECTORS(struct diskOp *);
unsigned long OS_GETTIME(void); // out: bc=date, hl=time
unsigned int OS_NEWPAGE(void);
unsigned int OS_CHDIR(unsigned char *trgPathPtr);
unsigned int OS_GETPATH(unsigned int curPathPtr); // in: de = ptr to buffer out: hl = ptr to last symbol of path
unsigned int OS_SETSYSDRV(void);				  // out: H: H!=0 -- ��⥬�� ��� �� �ਬ���஢��. L: -- ��饥 ������⢮ �ਬ���஢����� ��᪮�.
unsigned int OS_NEWAPP(unsigned int trgPathPtr);
unsigned int OS_RUNAPP(unsigned char pId); // e=id ;ACTIVATE DISABLED APP
unsigned int OS_WAITPID(unsigned char pId);
unsigned int OS_HIDEFROMPARENT(void);
unsigned long OS_STARTAPP(unsigned long appParamsPtr);					// out: b=id, a=error, dehl=newapp pages in 0000,4000,8000,c000 ;MAKE NEW DISABLED APP
unsigned int OS_RENAME(unsigned char *oldName, unsigned char *newName); // DE - ��஥ ���, �������� � ����� ��� �⭮�⥫�� ���� (ASCIIZ). HL - ����� ���, ���� �� �ॡ���� ⠪�� �� ����, ��� � DE. // out HL - 㪠��⥫� �� ��᫥���� ������� ��� � �⮬ ���� (NOT MSXDOS compatible! with Drive/path!)
unsigned int OS_DELETE(unsigned char *fileName);						// DE - ��� 䠩��, �������� � ����� ��� �⭮�⥫�� ���� (ASCIIZ).; � - �訡��. �᫨ 0x00, � �訡�� ���.
void OS_DIHALT(void);
// End of Kulich area

void SETPG32KHIGH(unsigned char page);

unsigned int putf(const char *str);
void putcsi(unsigned char);
void printn(unsigned char *, unsigned int size);
#define PUTCSI(_a) putcsi(_a)
void putcsi2(unsigned int);
#define PUTCSI2(_a, _b) putcsi(_a | (_b << 8))

union APP_PAGES
{
	unsigned long l;
	struct
	{
		unsigned char window_3;
		unsigned char window_2;
		unsigned char window_1;
		unsigned char window_0;
		unsigned char pId;
		unsigned char error;
		unsigned char f;
	} pgs;
};
unsigned long OS_GETMAINPAGES(void);
unsigned int OS_GETCONFIG(void);
unsigned int os_reserv_1(void *);
void OS_SCROLLUP(unsigned int xy, unsigned int wh);
unsigned int _low_level_get(void);
char *cgets(char *str);
void conv1251to866(unsigned char *bufer);

void exit(int e);
unsigned char scrredraw(void);

#define MOUSE_BUTTON_BIT_LMB 0x01
#define MOUSE_BUTTON_BIT_RMB 0x02

extern unsigned char errno;
extern unsigned int mouse_yx;
extern unsigned char mouse_x;
extern unsigned char mouse_y;
extern unsigned char mouse_btns;
extern unsigned char t1251to866[128];

#define INK_BLACK 0x00
#define INK_BLUE 0x01
#define INK_RED 0x02
#define INK_MAGENTA 0x03
#define INK_GREEN 0x04
#define INK_CYAN 0x05
#define INK_YELLOW 0x06
#define INK_WHITE 0x07
#define INK_WHITE_BRIGHT 0x47

#define PAPER_BLACK 0x00
#define PAPER_BLUE 0x08
#define PAPER_RED 0x10
#define PAPER_MAGENTA 0x18
#define PAPER_GREEN 0x20
#define PAPER_CYAN 0x28
#define PAPER_YELLOW 0x30
#define PAPER_WHITE 0x38

#endif