#ifndef OSCALLS_H
#define OSCALLS_H

void OS_DROPAPP(unsigned char id);
unsigned long OS_GETAPPMAINPAGES(unsigned char id);
unsigned char OS_GETPAGEOWNER(unsigned char id);
void YIELD(void);
unsigned char OS_SETGFX(unsigned char mode);
void OS_CLS(unsigned char color);
void OS_SETCOLOR(unsigned char color);
void OS_PRATTR(unsigned char attribute);
void OS_SETXY(unsigned char x, unsigned char y);
void OS_SETXYW(unsigned int w);
/* BDOS text scroll: xy=(y<<8)|x, wh=(height<<8)|width; x and width must be even. */
void OS_SCROLLUP(unsigned int xy, unsigned int wh);
void OS_SCROLLDOWN(unsigned int xy, unsigned int wh);
#define OS_SCROLL_XY(y, x) (((unsigned int)(y) << 8) | (unsigned int)(x))
#define OS_SCROLL_WH(h, w) (((unsigned int)(h) << 8) | (unsigned int)(w))
#define OS_SCROLL_SCREEN_H 25u
#define OS_SCROLL_SCREEN_W 80u
void OS_SCROLL_SCREEN_UP(unsigned char count);
void OS_SCROLL_SCREEN_DOWN(unsigned char count);
void OS_SETMUSIC(void (*play)(void), unsigned char pg);

typedef struct
{
	void *data;
	void *pagetable;
	unsigned char delay; /* BDOS reads HX via ld ixh,d (DD 62) */
} OS_COVOX_PLAY;

/* Legacy: struct pointer (no C000 page restore). Prefer OS_PLAYCOVOX_PLAY. */
void OS_PLAYCOVOX(const OS_COVOX_PLAY *args);

/* Play Covox sample; restores C000 page mapping on return. */
void OS_PLAYCOVOX_PLAY(unsigned char hx, void *data, void *pagetable);
void os_initstdio(void);
void print(unsigned char *);
unsigned int OS_GETXY(void);
unsigned char OS_GETATTR(void);
long time(void); // Alone Coder

struct diskOp
{
	unsigned char drive;
	void *BufAdr;
	unsigned long sector;
	unsigned char count;
};

typedef struct
{
	unsigned long int fsize;  /* File size */
	unsigned int fdate;		  /* Last modified date */
	unsigned int ftime;		  /* Last modified time */
	unsigned char fattrib;	  /* Attribute */
	unsigned char fname[13];  /* Short file name (8.3 format) */
	unsigned char lfname[64]; /* Pointer to the LFN buffer */
} fileInfo;

signed long OS_GETKEY(void);	 // BC HL; also fills mouse_x/y/btns/yx
unsigned long OS_GETMOUSE(void); // BC HL

unsigned int OS_READSECTORS(struct diskOp *);
unsigned int OS_WRITESECTORS(struct diskOp *);
unsigned long OS_GETTIME(void); // out: bc=date, hl=time
unsigned int OS_NEWPAGE(void); /* iarlib: HL=(err<<8)|page, err=0 ok */
unsigned char OS_DELPAGE(char pageNumber);
unsigned int OS_GETSCR0(void); // return user_scr0_high, user_scr0_low
unsigned int OS_GETSCR1(void); // return user_scr1_high, user_scr1_low
void OS_SETBORDER(unsigned char color);
unsigned int OS_CHDIR(unsigned char *trgPathPtr);
unsigned int OS_GETPATH(unsigned int curPathPtr); // in: de = ptr to buffer out: hl = ptr to last symbol of path
unsigned int OS_SETSYSDRV(void);				  // out: H: H!=0 -- ????? ??? ?? ????????. L: -- ??? ??????? ??????????? ????.
unsigned int OS_CHDRV(unsigned char drive);	  // e=0..25 or 'A'..'Z', out: L=error (0=ok)
unsigned int OS_MOUNT(unsigned char drive);	  // e='A'..'Z', out: H=error (0=ok)
unsigned int OS_NEWAPP(unsigned int trgPathPtr);
unsigned int OS_RUNAPP(unsigned char pId); // e=id ;ACTIVATE DISABLED APP
unsigned int OS_WAITPID(unsigned char pId);
unsigned int OS_HIDEFROMPARENT(void);
unsigned long OS_STARTAPP(unsigned long appParamsPtr);
unsigned char OS_RENAME(unsigned char *oldName, unsigned char *newName);
unsigned int OS_DELETE(unsigned char *fileName);
void OS_DIHALT(void);
void OS_SETPG8000(unsigned char page);
void OS_SETPGC000(unsigned char page);
void OS_SETSCREEN(unsigned char screen); // e=screen=0..1
unsigned char OS_READDIR(fileInfo *finfo);
unsigned char	OS_OPENDIR(unsigned char * path);
/* IAR: DE=path, BC=&date, time* на стеке. BDOS out IX/HL -> *date,*time. */
unsigned char OS_GETFILETIME(unsigned char *path, unsigned int *date, unsigned int *time);
/* IAR: DE=path, BC=date, time на стеке. BDOS: DE=path, IX=date, HL=time (как nv.asm). */
unsigned char OS_SETFILETIME(unsigned char *path, unsigned int date, unsigned int time);

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
void panel_files_scroll_up(unsigned char start_x);
void panel_files_scroll_down(unsigned char start_x);
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