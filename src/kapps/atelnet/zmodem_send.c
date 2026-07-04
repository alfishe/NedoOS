/*
 * zmodem_send.c - ZMODEM/XMODEM/YMODEM transmit path (sz side)
 *
 * Not linked in atelnet.com by default (receive-only telnet client).
 * Add zmodem_send.c to ATELNET_C in Makefile when send is needed again.
 *
 * Split from zmodem.c; shares zmodem.h globals with zmodem.c.
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <setjmp.h>

#include "zmodem.h"

jmp_buf jb_stop;
long Lastsync;

void xmchout(char c);
void testrxc(short timeout);

static int protocol(int for_send)
{
static int c;
static char *buffer;

buffer = Pathname;
sprintf(buffer,"\n%sXmodem, %sYmodem, or Zmodem? (%sX,%sY,Z) <Z>  ",
for_send ? "ASCII, " : "",
for_send ? "Xmodem-1k, " : "",
for_send ? "A," : "",
for_send ? "K," : "" );

printf(buffer);
flush();
c = chrin();
c = toupper(c);
if (c == CR) {
c = 'Z';
}
return c;
}

int ovmain(char a)
{
Sending = QuitFlag = StopFlag = FALSE;
if (a == 'S') {
sendout(0);
} else {
bringin(0);
}
return 0;
}


int sendout(int prot)
{
static int kbdata, count, result;

result = NERROR;
if (!prot) {
kbdata = protocol(TRUE);
} else {
kbdata = prot;
}
flush();

count = getpathname("(s) for Transmit");
if (count) {
switch(kbdata) {
case 'K':
Blklen = KSIZE;
Xmodem = TRUE;
Zmodem = FALSE;
result = wcsend(1,Pathlist);
break;
case 'X':
Blklen = 128;
Xmodem = TRUE;
Zmodem = FALSE;
result = wcsend(1,Pathlist);
break;
case 'Y':
Zmodem = Xmodem = FALSE;
result = wcsend(count,Pathlist);
break;
case 'Z':
Zmodem = TRUE;
Xmodem = FALSE;
XonXoffOk = XonXoff;   /* maybe allow xon-xoff */
result = wcsend(count,Pathlist);
break;
case 'A':
XonXoffOk = XonXoff;
result = asciisend(Pathlist[0]);
break;
default:
result = NOT_OK;
break;
}
}
endstat(result,count);
return result;
}
int asciisend(char *file)  /* send ascii file with xon/xoff protocol */
{
static int fd, status, bytes, c;
static char *inbuf;
static unsigned j, bufsize;

status = NERROR;
inbuf = grabmem(&bufsize);
if (allocerror(inbuf)) {
return NERROR;
}

fd = zm_open(file,0);
if (openerror(fd,file,UBIOT,"send/open")) {
free(inbuf);
return NERROR;
}

#ifdef   DEBUG
printf("\nbufsize = %d\n",bufsize);
#endif

sprintf(Buf,"Sending %s, ASCII Transfer",file);
putlabel(Buf);
j = 0;

while ((bytes = zm_read(fd,inbuf,bufsize)) > 0) {
c = inbuf[0];
for (j = 0; (j < bytes) && (c != CTRLZ); c = inbuf[++j]) {
xmchout(c);
opabort();
if (QuitFlag || StopFlag) { /* xmchout tests for xoff */
goto cleanup;   /* abort */
}
putchar(c);
if ((c & 0x7f) == CR) {
if (Linedelay) {
mswait(Linedelay);
}
} else {
if (Chardelay) {
mswait(Chardelay);
}
}
if (QuitFlag == TRUE) {
goto cleanup;
}
}
}
status = OK;

cleanup:

zm_close(fd);
free(inbuf);
return status;
}
int wcsend(int argc, char *argp[])                   /* list of file names */
{
int n, status;

slabel();
Zctlesc = 0;
Incnt = 0;
Baudrate = Baudtable[Current.cbaudindex];
Filcnt = Errors = 0;

Fd = -1;

Txbuf = alloc(KSIZE);
if (allocerror(Txbuf)) {
return NERROR;
}
Cpmbuf = grabmem(&Cpbufsize);
if (allocerror(Cpmbuf)) {
return NERROR;
}
Cpindex = 0;                 /* just in case */
Crcflag  = FALSE;
Firstsec = TRUE;
Bytcnt = -1;
Rxtimeout = 600;   
savecurs();
hidecurs();
box();
status = NERROR;
report(PROTOCOL,Xmodem?"XMODEM Send":Zmodem?"ZMODEM Send":"YMODEM Send");
if (Zmodem) {
stohdr(0L);
zshhdr(ZRQINIT, Txhdr);
if (getzrxinit()==NERROR)
goto badreturn;
}
for (n=0; n<argc; ++n) {
clrreports();
Totsecs = 0;
if (opabort() || wcs(argp[n]) == NERROR) {
goto badreturn;
}
tfclose();
}
Totsecs = 0;
if (Filcnt==0) {             /* we couldn't open ANY files */
canit();
goto badreturn;
}
zperr("Complete",FALSE);
if (Zmodem) {
saybibi();
} else if (!Xmodem) {
wctxpn("");
}
status = OK;

badreturn:
zm_memfree(Cpmbuf);
zm_memfree(Txbuf);
showcurs();
restcurs();
if (status == NERROR) {
tfclose();
}
return status;
}
int wcs(char *oname)
{
unsigned length;
long flen;

if ((Fd=zm_open(oname,0))==UBIOT) {
zperr("Can't open file",TRUE);
wait(2);
return OK;                /* pass over it, there may be others */
}
++Noeofseen;  
Lastread = 0L;  
Lastn = -1; 
Dontread = FALSE;
++Filcnt;
fstat(oname,&Fs);
switch (wctxpn(oname)) {     /* transmit path name */
case NERROR:
if (Zmodem) {
canit();            /* Send CAN */
}
return NERROR;

case ZSKIP:
return OK;
}
length = Fs.records;
flen = (long)length * 128;
if (!Zmodem && wctx(flen)==NERROR)
return NERROR;
return 0;
}
int wctxpn(char *name)
{
static char *p;
static unsigned length;
static long nrbytes;

memset(Txbuf,'\0',KSIZE);
p = Txbuf;
if (*name) {
length = Fs.records;
nrbytes = (long)length * 128;
report(PATHNAME,name);
lreport(FILESIZE,nrbytes);
dreport(FBLOCKS,length);
report(SENDTIME,ttime(nrbytes));   
if (Xmodem) {                 /* xmodem, don't send path name */
return OK;
}
if (!Zmodem) {
Blklen = KSIZE;
if (getnak()) {
return NERROR;
}
}
strcpy(Txbuf,name);
deldrive(Txbuf);      /* remove drive ind if any */
p = Txbuf + strlen(Txbuf);
++p;
sprintf(p,"%lu %lo 100644",nrbytes,Fs.modtime);
}
if (Zmodem) {
return zsendfile(Txbuf, 1+strlen(p)+(p-Txbuf));
}
if (wcputsec(Txbuf, 0, SECSIZ)==NERROR) {
return NERROR;
}
return OK;
}
int getnak(void)
{
static int firstch;

Lastrx = 0;
for (;;) {
if (opabort()) {
return NERROR;
}
firstch = readock(800,1);
if (firstch==ZPAD) {
if (getzrxinit()) {
return NERROR;
}
break;
} else if (firstch==TIMEOUT) {
zperr("Timeout on PName",TRUE);
return TRUE;
} else if (firstch==WANTCRC) {
Crcflag = TRUE;
break;
} else if (firstch==NAK) {
break;
} else if (firstch==CAN) {
if ((firstch = readock(20,1)) == CAN && Lastrx == CAN) {
return TRUE;
}
}
Lastrx = firstch;
}
report(BLKCHECK,Crcflag?"CRC":"Checksum");
return FALSE;
}
int wctx(long flen)
{
static int thisblklen, i;
static unsigned sectnum, attempts, firstch;
static long charssent;

charssent = 0L;  
Firstsec = TRUE;  
thisblklen = Blklen;
i = 0;

while ((firstch=readock(1,2)) != NAK 
&& firstch != WANTCRC
&& firstch != CAN
&& !opabort()
&& ++i < Rxtimeout) {
;
}
if (QuitFlag) {
return NERROR;
}
if (firstch==CAN) {
zperr("Rcvr CANcelled",TRUE);
return NERROR;
}
if (firstch==WANTCRC) {
Crcflag=TRUE;
}
report(BLKCHECK,Crcflag?"CRC":"Checksum");
sectnum=0;
for (;;) {
if (opabort()) {
return NERROR;
}
if (flen <= (charssent + 896L)) {
Blklen = thisblklen = 128;
}
if ( !filbuf(Txbuf, thisblklen)) {
break;
}
purgeline();   /* ignore anything got while loading */
if (wcputsec(Txbuf, ++sectnum, thisblklen)==NERROR) {
return NERROR;
}
charssent += thisblklen;
sreport(sectnum,charssent);
}
attempts=0;
do {
dreport(ERRORS,attempts);
purgeline();
mcharout(EOT);
++attempts;
} while ((firstch=(readock(Rxtimeout, 1)) != ACK) 
&& attempts < RETRYMAX
&& !opabort() );
if (attempts == RETRYMAX) {
zperr("No ACK on EOT",TRUE);
return NERROR;
} else if (QuitFlag) {  /* from opabort */
return NERROR;
} else {
return OK;
}
}
int wcputsec(char *buf, int sectnum, int cseclen)   /* data length of this sector to send */
{
static unsigned checksum;
static char *cp;
static unsigned oldcrc;
static int wcj;
static int firstch;
static int attempts;

firstch=0;   /* part of logic to detect CAN CAN */

dreport(ERRORS,0);
for (attempts=0; attempts <= RETRYMAX; attempts++) {
if (opabort()) {
return NERROR;
}
if (attempts) {
dreport(ERRORS,attempts);
}
Lastrx= firstch;
mcharout(cseclen==KSIZE?STX:SOH);
mcharout(sectnum);
mcharout(0xFF & ~sectnum);
oldcrc=checksum=0;
for (wcj=cseclen,cp=buf; --wcj>=0; ) {
mcharout(*cp);
oldcrc=updcrc((0377& *cp), oldcrc);
checksum += *cp++;
}
if (Crcflag) {
oldcrc=updcrc(0,updcrc(0,oldcrc));
mcharout((int)oldcrc>>8);
mcharout((int)oldcrc);
} else {
mcharout(checksum);
}

firstch = readock(Rxtimeout, (Noeofseen&&sectnum) ? 2:1);
gotnak:
switch (firstch) {
case CAN:
if(Lastrx == CAN) {
cancan:
zperr("Rcvr CANcelled",TRUE);  
return NERROR;
}
break;
case TIMEOUT:
zperr("Timeout on ACK",TRUE); 
continue;
case WANTCRC:
if (Firstsec) {
Crcflag = TRUE;
}
report(BLKCHECK,Crcflag?"CRC":"Checksum");
case NAK:
zperr("NAK on sector",TRUE); 
continue;
case ACK: 
Firstsec=FALSE;
Totsecs += (cseclen>>7);
return OK;
case NERROR:
zperr("Got burst",TRUE); 
break;
default:
zperr("Bad sector ACK",TRUE);
break;
}
for (;;) {
if (opabort()) {
return NERROR;
}
Lastrx = firstch;
if ((firstch = readock(Rxtimeout, 2)) == TIMEOUT) {
break;
}
if (firstch == NAK || firstch == WANTCRC) {
goto gotnak;
}
if (firstch == CAN && Lastrx == CAN) {
goto cancan;
}
}
}
zperr("Retry Exceeded",TRUE);
return NERROR;
}
int filbuf(char *buf, int count)
{
static int c, m;

c = m = newload(buf, count);
if (m <= 0) {
return 0;
}
while (m < count) {
buf[m++] = CTRLZ;
}
return c;
}
int newload(char *buf, int count)
{
static int j;

j = 0;
while (count--) {
if (Incnt <= 0) {
Incnt = zm_read( Fd, Cpmbuf, Cpbufsize );
Cpindex = 0;      
if (Incnt <= 0) {
break;
}
}
buf[j++] = Cpmbuf[Cpindex++];
--Incnt;
}
return (j ? j : -1);
}
int getzrxinit(void)
{
int n,hdr;
int Rxflags;

for (n=10; --n>=0; ) {
if (opabort()) {
return NERROR;
}
hdr = zgethdr(Rxhdr, 1);
if (hdr==ZCHALLENGE) {   /* Echo receiver's challenge numbr */
stohdr(Rxpos);
zshhdr(ZACK, Txhdr);
continue;
} else if (hdr==ZCOMMAND) {      /* They didn't see out ZRQINIT */
stohdr(0L);
zshhdr(ZRQINIT, Txhdr);
continue;
} else if (hdr==ZRINIT) {
Rxflags = 0377 & Rxhdr[ZF0];
Txfcs32 = (Wantfcs32 && (Rxflags & CANFC32));
Zctlesc |= Rxflags & TESCCTL;
Rxbuflen = (0377 & Rxhdr[ZP0])+((0377 & Rxhdr[ZP1])<<8);
return (sendzsinit());
} else if (hdr==ZCAN || hdr==TIMEOUT) {
return NERROR;
} else if (hdr==ZRQINIT) {
if (Rxhdr[ZF0] == ZCOMMAND) {
continue;
}
} else {
zshhdr(ZNAK, Txhdr);
continue;
}
}
return NERROR;
}
#define SLEEP 0336
static char Myattn[] = { CTRLC,SLEEP,0 };

/* Send send-init information */

int sendzsinit(void)
{
int tries;

stohdr(0L);      /* All flags are undefined */
strcpy(Txbuf,Myattn);   /* Copy Attn string */
for (tries = 0; tries < 20; tries++) {
if (opabort()) {
return NERROR;
}
zsbhdr(ZSINIT,Txhdr);   /* Send binary header */
zsdata(Txbuf,strlen(Txbuf) + 1,ZCRCW);   /* Send string */
if (zgethdr(Rxhdr,0) == ZACK) {
return OK;
}
zperr("Bad ACK: ZSINIT",FALSE);
}
return NERROR;
}
int zsendfile(char *buf, int blen)
{
static int c;

for (;;) {
if (opabort()) {
return NERROR;
}
Txhdr[ZF0] = 0;   /* file conversion request */
Txhdr[ZF1] = 0;   /* file management request */
Txhdr[ZF2] = 0;   /* file transport request */
Txhdr[ZF3] = 0;
zsbhdr(ZFILE, Txhdr);
zsdata(buf, blen, ZCRCW);
again:
c = zgethdr(Rxhdr, 1);
if (c==ZRINIT) {
while ((c = readline(INTRATIME)) > 0) {
if (c == ZPAD) {
goto again;
}
}
} else if (c==ZCAN || c==TIMEOUT || c==ZABORT || c==ZFIN) {
return NERROR;
} else if (c==ZSKIP) {
return c;
} else if (c==ZRPOS) {
/*
* Suppress zcrcw request otherwise triggered by
* lastyunc==Bytcnt
*/
Lastsync = (Bytcnt = Txpos = Rxpos) -1L;

zm_lseek(Fd, Rxpos, 0);   /* absolute offset */

clrline(KBYTES);
Incnt = 0;
Dontread = FALSE;
c = zsndfdata();
Sending = FALSE;
return c;
}
}
}
static int Txwindow;
static int Txwspac;
static int Txwcnt;

/* Send the data in the file */

int zsndfdata(void)
{
static int c, e, n;
static int newcnt;
static long tcount;
static int junkcount;      /* Counts garbage chars received by TX */
static int nullv = 0;

tcount = 0L;
Blklen = 128;
if (Baudrate > 30) {
Blklen = 256;
}
if (Baudrate > 120) {
Blklen = 512;
}
if (Baudrate > 240) {
Blklen = KSIZE;
}
if (Rxbuflen && Blklen>Rxbuflen) {
Blklen = Rxbuflen;
}
Lrxpos = 0L;
junkcount = 0;
Beenhereb4 = FALSE;
Sending = Firstsec = TRUE;
somemore:
if (nullv) {
waitack:
junkcount = 0;
c = getinsync(0);
if (QuitFlag) {
return NERROR;
}
gotack:
if (setjmp(jb_stop)) {   /* come here if rx stops us */
rxint:
c = getinsync(1);
}

switch (c) {
case ZSKIP:
return c;
case ZACK:
case ZRPOS:
break;
case ZRINIT:
return OK;
case ZCAN:
default:
return NERROR;
}
/*
* If the reverse channel can be tested for data,
*  this logic may be used to detect error packets
*  sent by the receiver, in place of setjmp/longjmp
*  minprdy() returns non 0 if a character is available
*/
while (minprdy()) {
if (QuitFlag) {
return NERROR;
}
switch (readline(1)) {
case CTRLC:
case CAN:
case ZPAD:
goto rxint;
case XOFF:      /* Wait a while for an XON */
case XOFF|0200:
readline(100);
}
}
}

if (setjmp(jb_stop)) {   /* rx interrupt */
c = getinsync(1);
if (c == ZACK) {
goto gotanother;
}
purgeline();
/* zcrce - dinna wanna starta ping-pong game */
zsdata(Txbuf, 0, ZCRCE);
goto gotack;
}

newcnt = Rxbuflen;
Txwcnt = 0;
stohdr(Txpos);
zsbhdr(ZDATA, Txhdr);
do {
if (QuitFlag) {
return NERROR;
}
if (Dontread) {
n = Lastn;
} else {
n = filbuf(Txbuf, Blklen);
Lastread = Txpos;  
Lastn = n;
}
Dontread = FALSE;
if (n < Blklen) {
e = ZCRCE;
} else if (junkcount > 3) {
e = ZCRCW;
} else if (Bytcnt == Lastsync) {
e = ZCRCW;
} else if (Rxbuflen && (newcnt -= n) <= 0) {
e = ZCRCW;
} else if (Txwindow && (Txwcnt += n) >= Txwspac) {
Txwcnt = 0;  
e = ZCRCQ;
} else {
e = ZCRCG;
}
zsdata(Txbuf, n, e);
Txpos += (long)n;
Bytcnt = Txpos;
crcrept(Crc32t);   /* praps report crc mode */
lreport(KBYTES,Bytcnt);
if (e == ZCRCW) {
goto waitack;
}

/*
* If the reverse channel can be tested for data,
*  this logic may be used to detect error packets
*  sent by the receiver, in place of setjmp/longjmp
*  minprdy() returns non 0 if a character is available
*/

while (minprdy()) {
if (QuitFlag) {
return NERROR;
}
switch (readline(1)) {
case CAN:
case CTRLC:
case ZPAD:
c = getinsync(1);
if (c == ZACK) {
break;
}
purgeline();
/* zcrce - dinna wanna starta ping-pong game */
zsdata(Txbuf, 0, ZCRCE);
goto gotack;
case XOFF:    /* Wait a while for an XON */
case XOFF|0200:
readline(100);
default:
++junkcount;

}
gotanother:;
}
if (Txwindow) {
while ((tcount = Txpos - Lrxpos) >= Txwindow) {
if (QuitFlag) {
return NERROR;
}
if (e != ZCRCQ) {
zsdata(Txbuf, 0, e = ZCRCQ);
}
c = getinsync(1);
if (c != ZACK) {
purgeline();
zsdata(Txbuf, 0, ZCRCE);
goto gotack;
}
}
}
} while (n == Blklen);

for (;;) {
if (QuitFlag) {
return NERROR;
}
stohdr(Txpos);
zsbhdr(ZEOF, Txhdr);
switch (getinsync(0)) {
case ZACK:
continue;
case ZRPOS:
goto somemore;
case ZRINIT:
return OK;
case ZSKIP:
return c;
default:
return NERROR;
}
}
}

/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer3e.c ========== */

/************************* START OF XFER MODULE 3 ***************************/


extern int zgethdr(char *hdr, int eflag);
extern char Rxhdr[4];
extern char Txhdr[4];
extern int Beenhereb4;
extern long Rxpos;
extern long Txpos;
extern long Lrxpos;
extern long Bytcnt;
extern long Lastsync;
extern long Lastread;
extern int Incnt;
extern int Fd;
extern int Dontread;
extern int Lastn;
extern char *frametypes[FRTYPES + FTOFFSET];

/*
* Respond to receiver's complaint, get back in sync with receiver
*/
int getinsync(int flag)      /* flag means that there was an error */
{
static int c;
unsigned u;

for (;;) {
if (opabort()) {
return NERROR;
}
c = zgethdr(Rxhdr, 0);
c = c < FRTYPES ? c : FRTYPES-1;
sprintf(Buf,"Got %s", frametypes[c+FTOFFSET]);
zperr(Buf,flag);
switch (c) {

case ZCAN:
case ZABORT:
case ZFIN:
case TIMEOUT:
return NERROR;

case ZRPOS:
/* ************************************* */
/*  If sending to a modem buffer, you    */
/*   might send a break at this point to */
/*   dump the modem's buffer.            */
/* ************************************* */
if (Lastn >= 0 && Lastread == Rxpos) {
Dontread = TRUE;
} else {
u = zm_lseek(Fd, Rxpos, 0);   /* absolute offset */
clrline(KBYTES);
Incnt = 0;
}
Bytcnt = Lrxpos = Txpos = Rxpos;
if (Lastsync == Rxpos) {
if (++Beenhereb4 > 4) {
if (Blklen > 256) {
Blklen /= 2;
}
}
}
Lastsync = Rxpos;
return c;

case ZACK:
Lrxpos = Rxpos;
if (flag || Txpos == Rxpos) {
return ZACK;
}
continue;

case ZRINIT:
case ZSKIP:
return c;

case NERROR:
default:
zsbhdr(ZNAK, Txhdr);
continue;
}
}
}
void saybibi(void)
{
for (;;) {
stohdr(0L);      /* CAF Was zsbhdr - minor change */
zshhdr(ZFIN, Txhdr);   /*  to make debugging easier */
switch (zgethdr(Rxhdr, 0)) {
case ZFIN:
mcharout('O'); 
mcharout('O'); 
case ZCAN:
case TIMEOUT:
return;
}
}
}
void tfclose(void)          /* close file if still open */
{
if (Fd >= 0) {
zm_close(Fd);
}
Fd = -1;
}
void slabel(void) /*print send mode labels on the 25th line*/
{
sprintf(Buf,"SEND FILE Mode:  Press ESC to Abort...");
putlabel(Buf);
}
void zsbhdr(int type, char *hdr)
{
static int n;
static unsigned crc;
#ifdef DEBUG
printf("\nSending BINARY header Type %d:",type);
for (n = 0; n < 4; n++) {
prhex( *(hdr + n));
}
printf("\n");
#endif

xmchout(ZPAD); 
xmchout(ZDLE);

if (Crc32t=Txfcs32) {
zsbh32(hdr, type);
} else {
xmchout(ZBIN); 
zsendline(type); 
crc = updcrc(type, 0);

for (n=4; --n >= 0; ++hdr) {
zsendline(*hdr);
crc = updcrc((0377& *hdr), crc);
}
crc = updcrc(0,updcrc(0,crc));
zsendline(crc>>8);
zsendline(crc);
}
if (type != ZDATA) {
purgeline();
}
}
void zsbh32(char *hdr, int type)
{
static int n;
static long crc;

xmchout(ZBIN32);  
zsendline(type);
crc = 0xFFFFFFFFL; 
crc = updc32(type, crc);

for (n=4; --n >= 0; ++hdr) {
crc = updc32((0377 & *hdr), crc);
zsendline(*hdr);
}
crc = ~crc;
for (n=4; --n >= 0;) {
zsendline((int)crc);
crc >>= 8;
}
}
void zsdata(char *buf, int length, int frameend)
{
static unsigned crc;

if (Crc32t) {
zsda32(buf, length, frameend);
} else {
crc = 0;
for (;--length >= 0; ++buf) {
zsendline(*buf); 
crc = updcrc((0377 & *buf), crc);
}
xmchout(ZDLE); 
xmchout(frameend);
crc = updcrc(frameend, crc);

crc = updcrc(0,updcrc(0,crc));
zsendline(crc>>8); 
zsendline(crc);
}
if (frameend == ZCRCW) {
xmchout(XON);  
purgeline();
}
}

int zsda32(char *buf, int length, int frameend)
{
static long crc;

crc = 0xFFFFFFFFL;
for (;--length >= 0;++buf) {
crc = updc32((0377 & *buf), crc);
zsendline(*buf);
}
xmchout(ZDLE); 
xmchout(frameend);
crc = updc32(frameend, crc);

crc = ~crc;
for (length=4; --length >= 0;) {
zsendline((int)crc);  
crc >>= 8;
}
return OK;
}
void zsendline(int c)
{
static int lastsent;

switch (c &= 0377) {
case ZDLE:
xmchout(ZDLE);
xmchout (lastsent = (c ^= 0100));
break;
case 015:
case 0215:
if (!Zctlesc && (lastsent & 0177) != '@') {
goto sendit;
}
/* **** FALL THRU TO **** */
case 020:
case 021:
case 023:
case 0220:
case 0221:
case 0223:
xmchout(ZDLE);
c ^= 0100;
sendit:
xmchout(lastsent = c);
break;
default:
if (Zctlesc && ! (c & 0140)) {
xmchout(ZDLE);
c ^= 0100;
}
xmchout(lastsent = c);
}
}


void xmchout(char c)
{
   testrxc(200);
   mcharout(c);
}

void testrxc(short timeout)
{
   static char c;

   c = minprdy() ? mcharinp() : '\0';
   if (c) {
      if (XonXoffOk && (c == CTRLS)) {
         while (((c = readline(10)) != CTRLQ) && timeout--);
         if (c < 1) {
            c = CTRLC;
         }
      }
      StopFlag = ((c == CTRLC) || (c == CTRLX) || (c == '*'));
      if (StopFlag && Zmodem && Sending) {
         longjmp(jb_stop, c);
      }
   }
}
