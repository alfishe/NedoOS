/*
 * zmodem.h - ZMODEM file transfer module
 *
 * Consolidated header for the ZMP transfer overlay (zmxfer* + zzm*).
 * Protocol constants from zmodmdef.h; platform glue from zmp.h (xfer subset).
 *
 * Host I/O, screen, pathname and memory helpers are declared here and must
 * be supplied by the platform layer (CP/M stubs today, NedoOS/iarlib later).
 */

#ifndef ZMODEM_H
#define ZMODEM_H

#include <setjmp.h>

/*
 *   Z M O D E M . H     Manifest constants for ZMODEM
 *    application to application file transfer protocol
 *    05-23-87  Chuck Forsberg Omen Technology Inc
 *    12-10-87  Modified by HM for cpm
 */

/* Leave most of this file alone. If your system can buffer incoming
 * characters, and/or can receive data during disk i/o, and/or send
 * a break signal, you can try changing the ZRINIT bit masks.
 */

#define     ZPAD        '*'	/* 052 Padding character begins frames */
#define     ZDLE        030	/* Ctrl-X Zmodem escape - `ala BISYNC DLE */
#define     ZDLEE       (ZDLE^0100)	/* Escaped ZDLE as transmitted */
#define     ZBIN        'A'	/* Binary frame indicator */
#define     ZHEX        'B'	/* HEX frame indicator */
#define     ZBIN32      'C'	/* Binary frame with 32 bit FCS */

#define     ZRQINIT	   0	/* Request receive init */
#define     ZRINIT	   1	/* Receive init */
#define     ZSINIT      2	/* Send init sequence (optional) */
#define     ZACK        3		/* ACK to above */
#define     ZFILE       4		/* File name from sender */
#define     ZSKIP       5		/* To sender: skip this file */
#define     ZNAK        6		/* Last packet was garbled */
#define     ZABORT      7	/* Abort batch transfers */
#define     ZFIN        8		/* Finish session */
#define     ZRPOS       9		/* Resume data trans at this position */
#define     ZDATA       10	/* Data packet(s) follow */
#define     ZEOF        11		/* End of file */
#define     ZFERR       12	/* Fatal Read or Write error Detected */
#define     ZCRC        13		/* Request for file CRC and response */
#define     ZCHALLENGE  14	/* Receiver's Challenge */
#define     ZCOMPL      15	/* Request is complete */
#define     ZCAN        16	  /* Other end canned session with CAN*5 */
#define     ZFREECNT    17	/* Request for free bytes on filesystem */
#define     ZCOMMAND    18	/* Command from sending program */
#define     ZSTDERR     19	/* Output to standard error, data follows */

#define     ZCRCE       'h'	/* CRC next, frame ends, header packet follows */
#define     ZCRCG       'i'	/* CRC next, frame continues nonstop */
#define     ZCRCQ       'j'	/* CRC next, frame continues, ZACK expected */
#define     ZCRCW       'k'	/* CRC next, ZACK expected, end of frame */
#define     ZRUB0       'l'	/* Translate to rubout 0177 */
#define     ZRUB1       'm'	/* Translate to rubout 0377 */

#define     GOTOR       0400
#define     GOTCRCE     (ZCRCE|GOTOR)
#define     GOTCRCG     (ZCRCG|GOTOR)
#define     GOTCRCQ     (ZCRCQ|GOTOR)
#define     GOTCRCW     (ZCRCW|GOTOR)
#define     GOTCAN	   (GOTOR|030)

#define     ZF0	      3
#define     ZF1	      2
#define     ZF2	      1
#define     ZF3	      0
#define     ZP0	      0
#define     ZP1	      1
#define     ZP2	      2
#define     ZP3	      3

#define     CANFDX	   0
#define     CANOVIO	   0
#define     CANBRK	   0
#define     CANCRY	   010
#define     CANLZW	   020
#define     CANFC32	   040
#define     ESCCTL      0100
#define     ESC8        0200

#define     ZATTNLEN    32

#define     TESCCTL     0100
#define     TESC8       0200

#define     ZCBIN	      1
#define     ZCNL	      2
#define     ZCRESUM	   3

#define     ZMSKNOLOC	0200

#define     ZMMASK	   037
#define     ZMNEWL	   1
#define     ZMCRC	      2
#define     ZMAPND	   3
#define     ZMCLOB	   4
#define     ZMNEW	      5
#define     ZMDIFF	   6
#define     ZMPROT	   7

#define     ZTLZW	      1
#define     ZTCRYPT	   2
#define     ZTRLE	      3

#define     ZXSPARS	   64

#define     ZCACK1	   1

#define     INTRATIME   50

#define  FRTYPES     21
#define  FTOFFSET    3

#define ZM_STATUS_ROW  24u   /* TERM_LAST_ROW: single status line, no overlay */

/* ---- platform / transfer constants (from zmp.h, xfer subset) ---- */

#define	FALSE	0
#define	TRUE	1

#ifndef	MAIN
#define	EXTERN	extern
#else
#define	EXTERN
#endif

#define	PROTOCOL	3
#define	PATHNAME	4
#define	FILESIZE	5
#define	BLKCHECK	6
#define	SENDTIME	7
#define	KBYTES		8
#define	BLOCKS		9
#define	FBLOCKS		10
#define	ERRORS		11
#define	MESSAGE		12

#define	BUFSTART	16384
#define	OK		0
#define NOT_OK          (-1)
#define	NERROR		(-1)
#define	MAXFILES	255
#define	FNSIZE		17
#define	BUFIOT		0
#define	UBIOT		-1

#define	NUL		0
#define	SOH		1
#define	STX		2
#define	CTRLC		3
#define	EOT		4
#define	CTRLE		5
#define	ENQ		5
#define	ACK		6
#define	BELL		7
#define	BS		8
#define	LF		10
#define	CTRLK		11
#define	CR		13
#define	CTRLQ		17
#define	XON		('q'&037)
#define	CTRLS		19
#define	XOFF		('s'&037)
#define	NAK		21
#define	CAN		('X'&037)
#define	CTRLX		24
#define	CPMEOF		26
#define	CTRLZ		26
#define	ESC		27
#define	DEL		127

#define	TIMEOUT		-2
#define	RCDO		(-3)
#define	ERRORMAX	5
#define	RETRYMAX	10
#define	WCEOT		(-10)
#define	SECSIZ		128
#define	PATHLEN		257
#define	KSIZE		1024
#define	WANTCRC		'C'
#define	ORIGIN		0x0100
#define	COMPSIZ		35
#define	CPMBUF		0x80
#define	DONE		0xff
#define	RET		'!'
#define	WAITASEC	'~'

struct stat {
	char fname[9];
	char fext[4];
	unsigned long modtime;
	int records;
};

EXTERN struct settings {
	int cbaudindex;
	char cparity;
	int cdatabits;
	int cstopbits;
} Current;

EXTERN unsigned Baudtable[14]
#ifdef MAIN
 = { 11,30,45,60,71,120,240,480,960,1920,3840,5760,7680 }
#endif
;

EXTERN int QuitFlag
#ifdef	MAIN
= FALSE
#endif
;
EXTERN int StopFlag
#ifdef	MAIN
= FALSE
#endif
;
EXTERN int Crcflag
#ifdef	MAIN
= TRUE
#endif
;
EXTERN int XonXoff
#ifdef	MAIN
= FALSE
#endif
;
EXTERN int XonXoffOk
#ifdef	MAIN
= FALSE
#endif
;
EXTERN int Sending
#ifdef	MAIN
= FALSE
#endif
;
EXTERN int Zmodem
#ifdef MAIN
 = FALSE
#endif
;
EXTERN int Nozmodem
#ifdef MAIN
 = FALSE
#endif
;
EXTERN int Blklen
#ifdef MAIN
 = SECSIZ
#endif
;
EXTERN int Xmodem
#ifdef MAIN
 = FALSE
#endif
;
EXTERN int Zrwindow
#ifdef MAIN
 = 1400
#endif
;
EXTERN unsigned Bufsize
#ifdef	MAIN
= BUFSTART
#endif
;

EXTERN char Pathname[128];
EXTERN char Buf[128];
EXTERN int Stopped
#ifdef MAIN
 = FALSE
#endif
;
EXTERN int Wantfcs32
#ifdef MAIN
 = TRUE
#endif
;
EXTERN int ZsDos
#ifdef MAIN
 = TRUE
#endif
;
EXTERN unsigned long FileModTime;
EXTERN char **Pathlist;

EXTERN int Chardelay
#ifdef	MAIN
= 0
#endif
;
EXTERN int Linedelay
#ifdef	MAIN
= 0
#endif
;

/* ---- module globals (defined in zmodem.c) ---- */

extern char *Rxptr;
extern int Tryzhdrtype;
extern int Beenhereb4;
extern unsigned Rxbuflen;
extern int Noeofseen;
extern int Totsecs;
extern char *Txbuf;
extern int Filcnt;
extern long Bytcnt;
extern long Lastread;
extern int Lastn;
extern int Dontread;
extern int Incnt;
extern struct stat Fs;
extern long Lrxpos;
extern int Errors;
extern int Lastrx;
extern int Firstsec;
extern int Eofseen;
extern int Fd;
extern char *Cpmbuf;
extern unsigned Cpbufsize;
extern unsigned Cpindex;
extern char *Secbuf;
extern int Zctlesc;
extern int Rxtimeout;
extern int Rxtype;
extern int Rxcount;
extern char Rxhdr[4];
extern char Txhdr[4];
extern long Rxpos;
extern long Txpos;
extern int Txfcs32;
extern int Crc32t;
extern int Crc32;
extern char Attn[ZATTNLEN+1];
extern int Baudrate;
extern long Lastsync;
extern int Wcsmask;

extern char *frametypes[FRTYPES + FTOFFSET];
extern jmp_buf jb_stop;

/* ---- ZMP platform hooks (zmodem_os.c, ANSI prototypes) ---- */

extern char *alloc(int n);
extern char *grabmem(unsigned *size);
extern int allocerror(char *p);
extern int readline(int timeout);
extern int readock(int timeout, int flag);
extern int minprdy(void);
extern int mcharinp(void);
extern void mcharout(char c);
extern int openerror(int fd, char *name, int mode);
extern int chrin(void);
extern int getpathname(char *prompt);
extern void freepath(int count);
extern void purgeline(void);
extern int opabort(void);
extern void flush(void);
extern void wait(int sec);
extern void mswait(int ms);
extern void sendbrk(void);
extern void mstrout(char *s, int crlf);
extern void fstat(char *name, struct stat *st);
extern void deldrive(char *name);
extern void setmodtime(void);
extern int roundup(int n, int r);
extern void locate(int line, int col);
extern void putlabel(char *msg);
extern void box(void);
extern void savecurs(void);
extern void hidecurs(void);
extern void showcurs(void);
extern void restcurs(void);
extern void report(int row, char *msg);
extern void clrline(int line);
extern void zperr(char *string, int incrflag);
extern int bringin(int prot);
/* protocol() is static in zmodem_recv.c; zmodem_send.c has its own when linked */

/* ---- NedoOS file layer (zmodem_os.c, direct OS_* calls) ---- */

int zm_creat(char *path, int mode);
int zm_open(char *path, int mode);
int zm_close(int fd);
int zm_read(int fd, char *buf, int count);
int zm_write(int fd, char *buf, int count);
int zm_unlink(char *path);
int zm_rename(char *oldpath, char *newpath);
long zm_lseek(int fd, long offset, int whence);

void zm_memfree(char *p);

/* ---- telnet I/O bridge ---- */

typedef void (*zm_tx_fn)(unsigned char b);
typedef int (*zm_poll_fn)(void);
typedef void (*zm_flush_fn)(void);

void zm_io_begin(zm_tx_fn tx, zm_poll_fn poll, zm_flush_fn flush);
void zm_io_end(void);
void zm_io_drain_input(void);
unsigned char zm_io_active(void);
void zm_io_rx(unsigned char b);
unsigned char zm_io_nb_pending(void);
void zm_io_nb_supply(unsigned int len);
unsigned zm_rx_take_plain(char *dst, unsigned max, int zctlesc);
int zmodem_session_receive(void);

extern unsigned char g_zm_skip_purge;

void zm_status_line(char *msg);
void zm_status_clear(void);

/* Debug log to telnet.log ? enable with -DATELNET_ZMODEM_LOG (Makefile). */
#ifdef ATELNET_ZMODEM_LOG
void zm_log(const char *line);
#define ZM_LOG(line) zm_log(line)
#else
#define zm_log(line) ((void)0)
#define ZM_LOG(line) ((void)0)
#endif

#endif /* ZMODEM_H */
