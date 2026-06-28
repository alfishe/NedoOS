/*
 * zmodem.c - ZMODEM/XMODEM/YMODEM file transfer module (monolithic)
 *
 * Consolidated from ZMP overlay sources:
 *   zmxfer.c, zmxfer2a..5p.c, zzm.c, zzm2.c
 * Original: Chuck Forsberg / Hal Maney (CP/M, Hi-Tech C)
 *
 * Terminal overlay (zmterm*) and main program (zmp*) are NOT included.
 * Source order preserved from zmxfer.lnk link list.
 */

#define MAIN
#define ZM

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <setjmp.h>

#include "zmodem.h"

/* same-file forwards */
extern int sendout(int prot);
extern int bringin(int prot);
extern int wctxpn(char *name);
extern void sreport(int sct, long bytes);
extern void crcrept(int flag);
extern void testexist(char *filename);
extern void checkpath(char *name);
extern void testrxc(short timeout);
extern int wcsend(int argc, char *argp[]);
extern int wcreceive(char *filename);
extern int asciisend(char *filename);
extern int wcputsec(char *buf, int sectnum, int cseclen);
extern int wcrxpn(char *rpn);
extern int endstat(int result, int count);
extern int closeit(void);
extern int zsda32(char *buf, int length, int frameend);
void xmchout(char c);
/* ========== from zmxfer.c ========== */

/***************************** Transfer Module ******************************/

char *frametypes[FRTYPES + FTOFFSET] = {
   "Carrier Lost",      /* -3 */
   "TIMEOUT",           /* -2 */
   "ERROR",             /* -1 */
   "ZRQINIT",
   "ZRINIT",
   "ZSINIT",
   "ZACK",
   "ZFILE",
   "ZSKIP",
   "ZNAK",
   "ZABORT",
   "ZFIN",
   "ZRPOS",
   "ZDATA",
   "ZEOF",
   "ZFERR",
   "ZCRC",
   "ZCHALLENGE",
   "ZCOMPL",
   "ZCAN",
   "ZFREECNT",
   "ZCOMMAND",
   "ZSTDERR",
   "xxxxx"
};

static int protocol(int);

extern char *ltoa(long n, char *s);

/* Set after rzfile ZEOF+close ok; host may drop TCP before ZFIN. */
static int g_zm_recv_ok;

static void zm_log_pos(const char *tag, long a, long b)
{
   char line[32];
   char sa[12];
   char sb[12];

   strcpy(line, tag);
   strcat(line, ltoa(a, sa));
   strcat(line, "/");
   strcat(line, ltoa(b, sb));
   zm_log(line);
}

static void zm_log_val(const char *tag, long a)
{
   char line[24];
   char sa[12];

   strcpy(line, tag);
   strcat(line, ltoa(a, sa));
   zm_log(line);
}

static void zm_log_rx(int rc)
{
   if (rc >= 0 && rc < FRTYPES)
   {
      zm_log(frametypes[rc + FTOFFSET]);
   }
   else if (rc == TIMEOUT)
   {
      zm_log("TIMEOUT");
   }
   else if (rc == RCDO)
   {
      zm_log("RCDO");
   }
   else if (rc == NERROR)
   {
      zm_log("ERROR");
   }
   else
   {
      zm_log("RX unknown");
   }
}

static void zm_log_zdata(int rc)
{
   if (rc == GOTCRCW)
   {
      zm_log("zrdata GOTCRCW");
   }
   else if (rc == GOTCRCG)
   {
      zm_log("zrdata GOTCRCG");
   }
   else if (rc == GOTCRCQ)
   {
      zm_log("zrdata GOTCRCQ");
   }
   else if (rc == GOTCRCE)
   {
      zm_log("zrdata GOTCRCE");
   }
   else if (rc == TIMEOUT)
   {
      zm_log("zrdata TIMEOUT");
   }
   else if (rc == NERROR)
   {
      zm_log("zrdata NERROR");
   }
   else if (rc == ZCAN)
   {
      zm_log("zrdata ZCAN");
   }
   else
   {
      zm_log("zrdata other");
   }
}

jmp_buf jb_stop;

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

int bringin(int prot)
{
   static int kbdata, count, result;

   count = 0;
   result = NERROR;
   if (Zmodem) {
      kbdata = 'Z';   /* auto receive from TERM */
   } else {
      if (!prot) {
         kbdata = protocol(FALSE);
      } else {
         kbdata = prot;
      }
   }
   flush();
   switch(kbdata) {
      case 'X':
         count = getpathname(" to Receive");
         if (!count) {
            break;
         }
         Zmodem = FALSE;
         Nozmodem = Xmodem = TRUE;
         result = wcreceive(Pathlist[0]);      /* just one file */
         break;
      case 'Y':
         Zmodem = Xmodem = FALSE;
         Nozmodem = TRUE;
         result = wcreceive(NULL);
         break;
      case 'Z':
         Zmodem = TRUE;
         Nozmodem = Xmodem = FALSE;
         result = wcreceive(NULL);
         break;
      default:
         break;
   }
   endstat(result,count);
   return result;
}

/* Clean up at end and report */
int endstat(int result, int count)
{
   XonXoffOk = FALSE;   /* disable xon-xoff */
   freepath(count);
   return result;
}

static int protocol(int for_send)        /* select block size in transmit only */
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


/* crctab calculated by Mark G. Mendel, Network Systems Corporation */
static unsigned crctab[256] = {
   0x0000,  0x1021,  0x2042,  0x3063,  0x4084,  0x50a5,  0x60c6,  0x70e7,
   0x8108,  0x9129,  0xa14a,  0xb16b,  0xc18c,  0xd1ad,  0xe1ce,  0xf1ef,
   0x1231,  0x0210,  0x3273,  0x2252,  0x52b5,  0x4294,  0x72f7,  0x62d6,
   0x9339,  0x8318,  0xb37b,  0xa35a,  0xd3bd,  0xc39c,  0xf3ff,  0xe3de,
   0x2462,  0x3443,  0x0420,  0x1401,  0x64e6,  0x74c7,  0x44a4,  0x5485,
   0xa56a,  0xb54b,  0x8528,  0x9509,  0xe5ee,  0xf5cf,  0xc5ac,  0xd58d,
   0x3653,  0x2672,  0x1611,  0x0630,  0x76d7,  0x66f6,  0x5695,  0x46b4,
   0xb75b,  0xa77a,  0x9719,  0x8738,  0xf7df,  0xe7fe,  0xd79d,  0xc7bc,
   0x48c4,  0x58e5,  0x6886,  0x78a7,  0x0840,  0x1861,  0x2802,  0x3823,
   0xc9cc,  0xd9ed,  0xe98e,  0xf9af,  0x8948,  0x9969,  0xa90a,  0xb92b,
   0x5af5,  0x4ad4,  0x7ab7,  0x6a96,  0x1a71,  0x0a50,  0x3a33,  0x2a12,
   0xdbfd,  0xcbdc,  0xfbbf,  0xeb9e,  0x9b79,  0x8b58,  0xbb3b,  0xab1a,
   0x6ca6,  0x7c87,  0x4ce4,  0x5cc5,  0x2c22,  0x3c03,  0x0c60,  0x1c41,
   0xedae,  0xfd8f,  0xcdec,  0xddcd,  0xad2a,  0xbd0b,  0x8d68,  0x9d49,
   0x7e97,  0x6eb6,  0x5ed5,  0x4ef4,  0x3e13,  0x2e32,  0x1e51,  0x0e70,
   0xff9f,  0xefbe,  0xdfdd,  0xcffc,  0xbf1b,  0xaf3a,  0x9f59,  0x8f78,
   0x9188,  0x81a9,  0xb1ca,  0xa1eb,  0xd10c,  0xc12d,  0xf14e,  0xe16f,
   0x1080,  0x00a1,  0x30c2,  0x20e3,  0x5004,  0x4025,  0x7046,  0x6067,
   0x83b9,  0x9398,  0xa3fb,  0xb3da,  0xc33d,  0xd31c,  0xe37f,  0xf35e,
   0x02b1,  0x1290,  0x22f3,  0x32d2,  0x4235,  0x5214,  0x6277,  0x7256,
   0xb5ea,  0xa5cb,  0x95a8,  0x8589,  0xf56e,  0xe54f,  0xd52c,  0xc50d,
   0x34e2,  0x24c3,  0x14a0,  0x0481,  0x7466,  0x6447,  0x5424,  0x4405,
   0xa7db,  0xb7fa,  0x8799,  0x97b8,  0xe75f,  0xf77e,  0xc71d,  0xd73c,
   0x26d3,  0x36f2,  0x0691,  0x16b0,  0x6657,  0x7676,  0x4615,  0x5634,
   0xd94c,  0xc96d,  0xf90e,  0xe92f,  0x99c8,  0x89e9,  0xb98a,  0xa9ab,
   0x5844,  0x4865,  0x7806,  0x6827,  0x18c0,  0x08e1,  0x3882,  0x28a3,
   0xcb7d,  0xdb5c,  0xeb3f,  0xfb1e,  0x8bf9,  0x9bd8,  0xabbb,  0xbb9a,
   0x4a75,  0x5a54,  0x6a37,  0x7a16,  0x0af1,  0x1ad0,  0x2ab3,  0x3a92,
   0xfd2e,  0xed0f,  0xdd6c,  0xcd4d,  0xbdaa,  0xad8b,  0x9de8,  0x8dc9,
   0x7c26,  0x6c07,  0x5c64,  0x4c45,  0x3ca2,  0x2c83,  0x1ce0,  0x0cc1,
   0xef1f,  0xff3e,  0xcf5d,  0xdf7c,  0xaf9b,  0xbfba,  0x8fd9,  0x9ff8,
   0x6e17,  0x7e36,  0x4e55,  0x5e74,  0x2e93,  0x3eb2,  0x0ed1,  0x1ef0
};

/*
 * updcrc macro derived from article Copyright (C) 1986 Stephen Satchell. 
 *  NOTE: First argument must be in range 0 to 255.
 *        Second argument is referenced twice.
 * 
 * Programmers may incorporate any or all code into their programs, 
 * giving proper credit within the source. Publication of the 
 * source routines is permitted so long as proper credit is given 
 * to Stephen Satchell, Satchell Evaluations and Chuck Forsberg, 
 * Omen Technology.
 */

unsigned updcrc(unsigned cp, unsigned crc)
{
   return ( crctab[((crc >> 8) & 255)] ^ (crc << 8) ^ cp);
}

/*
 * Copyright (C) 1986 Gary S. Brown.  You may use this program, or
 * code or tables extracted from it, as desired without restriction.
 */

/* First, the polynomial itself and its table of feedback terms.  The  */
/* polynomial is                                                       */
/* X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0 */
/* Note that we take it "backwards" and put the highest-order term in  */
/* the lowest-order bit.  The X^32 term is "implied"; the LSB is the   */
/* X^31 term, etc.  The X^0 term (usually shown as "+1") results in    */
/* the MSB being 1.                                                    */

/* Note that the usual hardware shift register implementation, which   */
/* is what we're using (we're merely optimizing it by doing eight-bit  */
/* chunks at a time) shifts bits into the lowest-order term.  In our   */
/* implementation, that means shifting towards the right.  Why do we   */
/* do it this way?  Because the calculated CRC must be transmitted in  */
/* order from highest-order term to lowest-order term.  UARTs transmit */
/* characters in order from LSB to MSB.  By storing the CRC this way,  */
/* we hand it to the UART in the order low-byte to high-byte; the UART */
/* sends each low-bit to hight-bit; and the result is transmission bit */
/* by bit from highest- to lowest-order term without requiring any bit */
/* shuffling on our part.  Reception works similarly.                  */

/* The feedback terms table consists of 256, 32-bit entries.  Notes:   */
/*                                                                     */
/*     The table can be generated at runtime if desired; code to do so */
/*     is shown later.  It might not be obvious, but the feedback      */
/*     terms simply represent the results of eight shift/xor opera-    */
/*     tions for all combinations of data and CRC register values.     */
/*                                                                     */
/*     The values must be right-shifted by eight bits by the "updcrc"  */
/*     logic; the shift must be unsigned (bring in zeroes).  On some   */
/*     hardware you could probably optimize the shift in assembler by  */
/*     using byte-swap instructions.                                   */

static long cr3tab[] = { /* CRC polynomial 0xedb88320 */

   0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
   0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988, 0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
   0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de, 0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
   0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec, 0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
   0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172, 0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
   0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940, 0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
   0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
   0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924, 0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
   0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
   0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
   0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e, 0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
   0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
   0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
   0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0, 0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
   0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
   0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
   0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a, 0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
   0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
   0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
   0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc, 0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
   0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
   0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
   0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236, 0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
   0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
   0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
   0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38, 0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
   0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
   0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
   0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2, 0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
   0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
   0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
   0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94, 0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
};

long updc32(int b, long c)
{
   return (cr3tab[((int)c ^ b) & 0xff] ^ ((c >> 8) & 0x00FFFFFF));
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
   if (openerror(fd,file,UBIOT)) {
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

void checkpath(char *name)  /* eliminate bad paths in receive */
{
   char *p, *dot, c;
   static char badchar[] = ",;:_[]=<>/";   /* disallowed f/n characters */

   for (p=name; *p; p++) {             /* dump strange characters */

      if (!(((c = *p) > '!') && (c < 0x7f) && !strchr(badchar,c))) {
         *p = '\0';
         strcat(name,p+1);
      }
   }
   dot = strchr(name, '.');
   if (dot != 0) {
      if ((dot - name) > 8) {
         p = dot + 1;
         name[8] = '.';
         name[9] = '\0';
         p[3] = '\0';
         strcat(name,p);
      }
   } else if (strlen(name) > 8u) {
      name[8] = '\0';
   }
   name[12] = '\0';
   report(PATHNAME,name);
}

/* output a character to the modem and test the receive channel */
void xmchout(char c)
{
   testrxc(200);   /* test receive channel */
   mcharout(c);   /* then send it */
}

/* Test receive channel for xon/xoff and interrupt while sending */
void testrxc(short timeout)      /* timeout in seconds */
{
   static char c;

   c = minprdy() ? mcharinp() : '\0';   /* get a character if any */
   if (c) {
      if (XonXoffOk && (c == CTRLS)) {
         while (((c = readline(10)) != CTRLQ) && timeout--);
         if (c < 1) {
            c = CTRLC;   /* timeout */
         }
      }
      StopFlag = ((c == CTRLC) || (c == CTRLX) || (c == '*'));
      if (StopFlag && Zmodem && Sending) {
         longjmp(jb_stop,c);   /* zmodem transmit interrupt */
      }
   }
}

/*      End of Transfer Overlay File #1 */

/* ========== from zmxfer2a.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern void slabel(void);
extern void stohdr(long pos);
extern void zshhdr(int type, char *hdr);
extern int getzrxinit(void);
extern void clrreports(void);
extern int wcs(char *oname);
extern void tfclose(void);
extern void canit(void);
extern void saybibi(void);
char *Rxptr;
int Tryzhdrtype;
int Beenhereb4;
unsigned Rxbuflen = 16384;      /* Receiver's max buffer length */
int Noeofseen = 0;
int Totsecs;                    /* total number of sectors this file */
char *Txbuf;
int Filcnt;                     /* count of number of files opened */
long Bytcnt;
long Lastread;                  /* Beginning offset of last buffer read */
int Lastn;                      /* Count of last buffer read or -1 */
int Dontread;                   /* Don't read the buffer, it's still there */
int Incnt;                      /* count for chars not read from the Cpmbuf */
struct stat Fs;

long Lrxpos;		/* Receiver's last reported offset */
int Errors;
int Lastrx;
int Firstsec;
int Eofseen;		/* indicates cpm eof (^Z) has been received */
int Fd;
char *Cpmbuf;             /* buffer bytes for writing to disk */
unsigned Cpbufsize;       /* size of Cpmbuf */
unsigned Cpindex = 0;          /* index for Cpmbuf */
char *Secbuf;       /* sector buffer receiving */
int Zctlesc;		   /* Encode control characters */
int Rxtimeout = 100;		   /* Tenths of seconds to wait for something */
int Rxtype;		/* Type of header received */
int Rxcount;		/* Count of data bytes received */
char Rxhdr[4];		/* Received header */
char Txhdr[4];		/* Transmitted header */
long Rxpos;		/* Received file position */
long Txpos;		/* Transmitted file position */
int Txfcs32;		/* TRUE means send binary frames with 32 bit FCS */
int Crc32t;		/* Display flag indicating 32 bit CRC being sent */
int Crc32;		/* Display flag indicating 32 bit CRC being received */
char Attn[ZATTNLEN+1];	/* Attention string rx sends to tx on err */
int Baudrate;

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

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2b.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern void canit(void);
extern int wctx(long flen);
extern int Fd;
extern int Noeofseen;
extern long Lastread;
extern int Lastn;
extern int Dontread;
extern int Filcnt;
extern struct stat Fs;

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

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2c.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern void lreport(int row, long value);
extern void dreport(int row, int value);
extern int getnak(void);
extern int zsendfile(char *buf, int blen);
extern int wcputsec(char *buf, int sectnum, int cseclen);
extern char * ttime(long fsize);
extern char *Txbuf;
extern struct stat Fs;

/*
 * generate and transmit pathname block consisting of
 *  pathname (null terminated),
 *  file length, modification time and file mode
 *  in octal.
 *  N.B.: modifies the passed name, may extend it!
 */
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

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2d.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


/* itoa - convert n to characters in s. */
char * itoa(short n, char *s)
{
   static short c, k;
   static char *p, *q;

   if ((k = n) < 0) {   /* record sign */
      n = -n;    /* make n positive */
   }
   q = p = s;
   do {                         /* generate digits in reverse order */
      *p++ = n % 10 + '0';      /* get next digit */
   } while ((n /= 10) > 0);     /* delete it */
   if (k < 0) {
      *p++ = '-';
   }
   *p = 0;
   /* reverse string in place */
   while (q < --p) {
      c = *q; *q++ = *p; *p = c;
   }
   return s;
}

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2e.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


/* ltoa - convert n to characters in s. */
char * ltoa(long n, char *s)
{
   static long c, k;
   static char *p, *q;

   if ((k = n) < 0) {           /* record sign */
      n = -n;                   /* make n positive */
   }
   q = p = s;
   do {                         /* generate digits in reverse order */
      *p++ = n % 10 + '0';      /* get next digit */
   } while ((n /= 10) > 0);     /* delete it */
   if (k < 0) {
      *p++ = '-';
   }
   *p = 0;
   /* reverse string in place */
   while (q < --p) {
      c = *q; 
      *q++ = *p; 
      *p = c;
   }
   return s;
}

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2f.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern int getzrxinit(void);
extern int Lastrx;

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

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2g.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern int filbuf(char *buf, int count);
extern int wcputsec(char *buf, int sectnum, int cseclen);

extern int Firstsec;
extern int Rxtimeout;
extern char *Txbuf;

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

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2h.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern void dreport(int row, int value);
extern unsigned updcrc(unsigned cp, unsigned crc);
extern int Lastrx;
extern int Rxtimeout;
extern int Firstsec;
extern int Crcflag;
extern int Totsecs;
extern int Noeofseen;

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

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2i.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern int newload(char *buf, int count);
/* fill buf with count chars padding with ^Z for CPM */

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

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer2j.c ========== */

/************************ START OF XFER MODULE 2 ****************************/

/* sz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern int Fd;
extern char *Cpmbuf;
extern unsigned Cpbufsize;
extern unsigned Cpindex;
extern int Incnt;

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

/************************** END OF MODULE 7 *********************************/

/* ========== from zmxfer3a.c ========== */

/************************* START OF XFER MODULE 3 ***************************/


extern int zgethdr(char *hdr, int eflag);
extern void stohdr(long pos);
extern void zshhdr(int type, char *hdr);
extern int sendzsinit(void);
extern unsigned Rxbuflen;
extern long Rxpos;
extern char Rxhdr[4];
extern char Txhdr[4];
extern int Txfcs32;
extern int Zctlesc;

/*
 * Get the receiver's init parameters
 */

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
/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer3b.c ========== */

/************************* START OF XFER MODULE 3 ***************************/


extern void stohdr(long pos);
extern void zsbhdr(int type, char *hdr);
extern void zsdata(char *buf, int length, int frameend);
extern int zgethdr(char *hdr, int eflag);
extern char *Txbuf;
extern char Rxhdr[4];
extern char Txhdr[4];

/*
 * Attention string to be executed by receiver to interrupt streaming data
 *  when an error is detected.  A pause (0336) may be needed before the
 *  ^C (03) or after it. 0337 causes a break to be sent.
 */
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

/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer3c.c ========== */

/************************* START OF XFER MODULE 3 ***************************/


extern void zsbhdr(int type, char *hdr);
extern int zsndfdata(void);
extern int zgethdr(char *hdr, int eflag);
extern char Rxhdr[4];
extern char Txhdr[4];
extern long Lastsync;
extern long Bytcnt;
extern long Rxpos;
extern long Txpos;
extern int Incnt;
extern int Dontread;
extern int Sending;
extern int Fd;

long Lastsync;

/* Send file name and related info */

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

/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer3d.c ========== */

/************************* START OF XFER MODULE 3 ***************************/



extern int getinsync(int flag);
extern int filbuf(char *buf, int count);
extern int Blklen;
extern int Baudrate;
extern long Lrxpos;
extern int Beenhereb4;
extern unsigned Rxbuflen;
extern int Sending;
extern int Firstsec;
extern long Bytcnt;
extern int Crc32t;
extern long Lastsync;
extern long Lastread;
extern char *Txbuf;
extern long Txpos;
extern int Lastn;
extern int Dontread;
extern char Txhdr[4];

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

/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer3f.c ========== */

/************************* START OF XFER MODULE 3 ***************************/


extern void stohdr(long pos);
extern void zshhdr(int type, char *hdr);
extern char Txhdr[4];
extern char Rxhdr[4];

/* Say "bibi" to the receiver, try to do it cleanly */

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

/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer3g.c ========== */

/************************* START OF XFER MODULE 3 ***************************/


extern int Zmodem;
extern int Baudrate;

char * ttime(long fsize)
{
   static unsigned efficiency, cps, seconds;
   static char buffer[10];

   efficiency = Zmodem ? 9 : 8;
   cps = (Baudrate/10) * efficiency;   
   seconds = (unsigned)(fsize/cps);     
   sprintf(buffer,"%u:%02u",seconds/60,seconds%60);
   return buffer;
}

/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer3h.c ========== */

/************************* START OF XFER MODULE 3 ***************************/


extern int Fd;

void tfclose(void)          /* close file if still open */
{
   if (Fd >= 0) {
      zm_close(Fd);
   }
   Fd = -1;
}

/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer3i.c ========== */

/************************* START OF XFER MODULE 3 ***************************/


extern char Buf[128];

void slabel(void) /*print send mode labels on the 25th line*/
{
   sprintf(Buf,"SEND FILE Mode:  Press ESC to Abort...");
   putlabel(Buf);
}

/************************** END OF MODULE 7A *********************************/

/* ========== from zmxfer4a.c ========== */

/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern int wcrx(void);
extern int procheader(char *name);
extern int wcrxpn(char *rpn);
extern int rzmfile(void);
extern void rlabel(void);
extern int tryz(void);
extern int Fd;
extern int Errors;
extern int Zctlesc;
extern int Baudrate;
extern int Tryzhdrtype;
extern char *Secbuf;
extern char *Cpmbuf;
extern unsigned Cpbufsize;
extern unsigned Cpindex;
extern char *Rxptr;
extern int Rxtimeout;

int Wcsmask = 0377;

int wcreceive(char *filename)
{
   static int c;

   rlabel();
   QuitFlag = FALSE;
   Zctlesc = 0;
   Baudrate = Baudtable[Current.cbaudindex];
   Tryzhdrtype = ZRINIT;
   Secbuf = alloc(KSIZE + 1);
   if (allocerror(Secbuf)) {
      return NERROR;
   }
   Cpmbuf = grabmem(&Cpbufsize);
   if (allocerror(Cpmbuf)) {
      return NERROR;
   }
   Cpindex = 0;                 /* just in case */
   Rxptr = Cpmbuf;              /* ditto */
   Rxtimeout = 100;             /* 10 seconds */
   Errors = 0;
   g_zm_recv_ok = 0;
   zm_log("wcreceive start");

#ifdef   DEBUG
   printf("\nbuffer size = %u\n",Cpbufsize);
   wait(5);
#endif

   savecurs();
   hidecurs();
   box();
   if (filename == (char *) 0) {/* batch transfer */
      Crcflag=(Wcsmask==0377);
      if (c=tryz()) {           /* zmodem transfer */
         report(PROTOCOL,"ZMODEM Receive");
         if (c == ZCOMPL) {
            goto good;
         }
         if (c == NERROR) {
            goto fubar;
         }
         c = rzmfile();
         if (c) {
            goto fubar;
         }
      } else {                  /* ymodem batch transfer */
         report(PROTOCOL,"YMODEM Receive");
         report(BLKCHECK,Crcflag?"CRC":"Checksum");
         for (;;) {
            if (opabort()) {
               goto fubar;
            }
            if (wcrxpn(Secbuf)== NERROR) {
               goto fubar;
            }
            if (Secbuf[0]==0) {
               goto good;
            }
            if (procheader(Secbuf) == NERROR) {
               goto fubar;
            }
            if (wcrx()==NERROR) {
               goto fubar;
            }
         }
      }
   } else {
      report(PROTOCOL,"XMODEM Receive");
      strcpy(Pathname,filename);
      checkpath(Pathname);

      testexist(Pathname);
      Fd = zm_creat(Pathname, 0);
      if (openerror(Fd,Pathname,UBIOT)) {
         goto fubar1;
      }
      if (wcrx()==NERROR) {     /* xmodem */
         goto fubar;
      }
   }
good:
   zm_memfree(Cpmbuf);
   zm_memfree(Secbuf);
   showcurs();
   restcurs();
   return OK;

fubar:
   canit();
   if (Fd >= 0) {
      closeit();
      zm_unlink(Pathname);         /* File incomplete: erase it */
   }
fubar1:
   zm_memfree(Cpmbuf);
   zm_memfree(Secbuf);
   showcurs();
   restcurs();
   return NERROR;
}
/************************** END OF MODULE 8 *********************************/

/* ========== from zmxfer4b.c ========== */

/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern int wcgetsec(char *rxbuf, int maxtime);
extern int Firstsec;
/*
 * Fetch a pathname from the other end as a C ctyle ASCIZ string.
 * Length is indeterminate as long as less than Blklen
 * A null string represents no more files (YMODEM)
 */

int wcrxpn(char *rpn)   /* receive a pathname */
{
   static int c;

   purgeline();

et_tu:
   Firstsec=TRUE;  
   mcharout(Crcflag?WANTCRC:NAK);
   while ((c = wcgetsec(rpn, 100)) != 0) {
      if (QuitFlag)
         return NERROR;
      if (c == WCEOT) {
         mcharout(ACK);
         readline(INTRATIME);
         goto et_tu;
      }
      return NERROR;
   }
   mcharout(ACK);
   return OK;
}

/************************** END OF MODULE 8 *********************************/

/* ========== from zmxfer4c.c ========== */

/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern int wcgetsec(char *rxbuf, int maxtime);
extern int putsec(int count, int flag);
extern int closeit(void);
extern int Firstsec;
extern int Crcflag;
extern char *Rxptr;
extern int Wcsmask;

/*
 * Adapted from CMODEM13.C, written by
 * Jack M. Wierda and Roderick W. Hart
 */

int wcrx(void)
{
   static int sectnum, sectcurr;
   static char sendchar;
   static int cblklen;         /* bytes to dump this block */
   long charsgot;

   Firstsec=TRUE;
   sectnum=0; 
   charsgot = 0L;
   sendchar=Crcflag?WANTCRC:NAK;
   report(BLKCHECK,Crcflag?"CRC":"Checksum");

   for (;;) {
      if (opabort()) {
         return NERROR;
      }
      mcharout(sendchar);               /* send it now, we're ready! */
      sectcurr = wcgetsec(Rxptr,Firstsec||(sectnum&0177)?50:130);
      if (sectcurr==(sectnum+1 &Wcsmask)) {
         charsgot += Blklen;
         sreport(++sectnum,charsgot);
         cblklen = Blklen;
         if (putsec(cblklen,FALSE)==NERROR) {
            return NERROR;
         }
         sendchar=ACK;
      } else if (sectcurr==(sectnum&Wcsmask)) {
         zperr("Duplicate Sector",TRUE);
         sendchar=ACK;
      } else if (sectcurr==WCEOT) {
         if (closeit()) {
            return NERROR;
         } else {
            setmodtime();
         }
         mcharout(ACK);
         return OK;
      } else if (sectcurr==NERROR) {
         return NERROR;
      } else {
         zperr( "Sync Error",TRUE);
         return NERROR;
      }
   }
}

/************************** END OF MODULE 8 *********************************/

/* ========== from zmxfer4d.c ========== */

/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern unsigned updcrc(unsigned cp, unsigned crc);
extern int Errors;
extern int Xmodem;
extern int Lastrx;
extern int Firstsec;

/*
 * Wcgetsec fetches a Ward Christensen type sector.
 * Returns sector number encountered or NERROR if valid sector not received,
 * or CAN CAN received
 * or WCEOT if eot sector
 * time is timeout for first char, set to 4 seconds thereafter
 ***************** NO ACK IS SENT IF SECTOR IS RECEIVED OK **************
 *    (Caller must do that when he is good and ready to get next sector)
 */

int wcgetsec(char *rxbuf, int maxtime)
{
   static int checksum, wcj, firstch;
   static unsigned oldcrc;
   static char *p;
   static int sectcurr;

   for (Lastrx=Errors=0; Errors < RETRYMAX; ) {  /* errors incr by zperr */
      if (opabort()) {
         return NERROR;
      }
      if ((firstch=readline(maxtime))==STX) {
         Blklen=KSIZE; 
         goto get2;
      }
      if (firstch==SOH) {
         Blklen=SECSIZ;
get2:
         sectcurr=readline(INTRATIME);
         if ((sectcurr+readline(INTRATIME))==0xFF) {
            oldcrc=checksum=0;
            for (p=rxbuf,wcj=Blklen; --wcj>=0; ) {
               if ((firstch=readline(INTRATIME)) < 0) {
                  goto bilge;
               }
               oldcrc=updcrc(firstch, oldcrc);
               checksum += (*p++ = firstch);
            }
            if ((firstch=readline(INTRATIME)) < 0) {
               goto bilge;
            }
            if (Crcflag) {
               oldcrc=updcrc(firstch, oldcrc);
               if ((firstch=readline(INTRATIME)) < 0) {
                  goto bilge;
               }
               oldcrc=updcrc(firstch, oldcrc);
               if (oldcrc & 0xFFFF) {
                  zperr( "CRC Error",TRUE);
               } else {
                  Firstsec=FALSE;
                  return sectcurr;
               }
            } else if (((checksum-firstch)&0xFF)==0) {
               Firstsec=FALSE;
               return sectcurr;
            } else {
               zperr("Checksum error",TRUE);
            }
         } else {
            zperr("Block nr garbled",TRUE);
         }
      } else if (firstch==EOT && readline(10)==TIMEOUT) {
         /* make sure eot really is eot and not just mixmash */
         return WCEOT;
      } else if (firstch==CAN) {
         if (Lastrx==CAN) {
            zperr( "Sender CANcelled",TRUE);
            return NERROR;
         } else {
            Lastrx=CAN;
            continue;
         }
      } else if (firstch==TIMEOUT) {
         if (Firstsec) {
            zperr( "TIMEOUT",TRUE);
            goto humbug;
         }
bilge:
         zperr( "TIMEOUT",TRUE);
      } else if (firstch==0x0D && Firstsec) {
         continue;
      } else {
         zperr( "Bad header",TRUE);
      }

humbug:
      Lastrx=0;
      while(readline(50) != TIMEOUT)
         if (QuitFlag) {
            return NERROR;
         }
      if (Firstsec) {
         if (Xmodem && (Errors == RETRYMAX/2)) {
            Crcflag = !Crcflag;
         }
         report(BLKCHECK,Crcflag?"CRC":"Checksum");
         mcharout(Crcflag?WANTCRC:NAK);
      } else {
         maxtime=40; 
         mcharout(NAK);
      }
   }
   /* try to stop the bubble machine. */
   canit();
   return NERROR;
}

/************************** END OF MODULE 8 *********************************/

/* ========== from zmxfer4e.c ========== */

/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */


extern void clrreports(void);
extern char * ttime(long fsize);
extern void checkpath(char *name);
extern int Fd;

/*
 * Process incoming file information header
 */
int procheader(char *name)
{
   static char *p, *ap, c;
   
   /*
    *  Process YMODEM,ZMODEM remote file management requests
    */

   clrreports();
   p = name + 1 + strlen(name);
   FileModTime = 0;
   if (*p) {   /* file coming from Unix or DOS system */
      ap = p;
      while ((c = *p) && (c != ' ')) /* find first space or null */
         ++p;
      if (c)
         *p = '\0';
      /* ap now points to a long integer in ascii */
      report(FILESIZE,ap);
      report(SENDTIME,ttime(atol(ap)));
      while (*ap && *ap != ' ') { /* skip over filesize */
         ++ap;
      }
      ++ap; /* if *ap is non zero, ap is pointing at the file mod timestamp */
      if( *ap ) {
         while (*ap >= '0' && *ap <= '7') {
            FileModTime <<= 3;
            FileModTime += *ap -'0';
            ++ap;
         }
      }
   }
   
   strcpy(Pathname, name);
   report(PATHNAME, name);
   checkpath(Pathname);

   testexist(Pathname);
   Fd = zm_creat(Pathname, 0);
   if (openerror(Fd,Pathname,UBIOT))
      return NERROR;
   zm_log("procheader ok");
   return OK;
}

/************************** END OF MODULE 8 *********************************/

/* ========== from zmxfer4f.c ========== */

/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */


/* send cancel string to get the other end to shut up */
void canit(void)
{
   static char canistr[] = {
      24,24,24,24,24,24,24,24,24,24,8,8,8,8,8,8,8,8,8,8,0
   };

   mstrout(canistr,FALSE);
   purgeline();
}

/************************** END OF MODULE 8 *********************************/

/* ========== from zmxfer4g.c ========== */

/********************** START OF XFER MODULE 4 ******************************/

/* rz.c By Chuck Forsberg modified for cp/m by Hal Maney */


void clrreports(void)
{
}
/************************** END OF MODULE 8 *********************************/

/* ========== from zmxfer5a.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern void dreport(int row, int value);
extern int Errors;

void zperr(char *string, int incrflag)
{
   clrline(MESSAGE);
   report(MESSAGE,string);
   if (incrflag) {
      dreport(ERRORS,++Errors);
   }
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5b.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern char * itoa(short n, char *s);
void dreport(int row, int value)
{
   static char buf[7];

   report(row,itoa(value,buf));
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5c.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern char * ltoa(long n, char *s);
void lreport(int row, long value)
{
   static char buf[20];

   report(row,ltoa(value,buf));
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5d.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern void dreport(int row, int value);
extern void lreport(int row, long value);
void sreport(int sct, long bytes)
{  
   dreport(BLOCKS,sct);
   lreport(KBYTES,bytes);
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5e.c ========== */

/********************** START OF XFER MODULE 5 ******************************/



/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5f.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern void stohdr(long pos);
extern void zshhdr(int type, char *hdr);
extern int zgethdr(char *hdr, int eflag);
extern int zrdata(char *buf, int length);
extern void ackbibi(void);
extern char Rxhdr[4];
extern char Txhdr[4];
extern char *Secbuf;
extern int Errors;
extern char Attn[ZATTNLEN+1];
extern int Tryzhdrtype;
extern unsigned Cpbufsize;
extern int Zctlesc;

/*
 * Initialize for Zmodem receive attempt, try to activate Zmodem sender
 *  Handles ZSINIT frame
 *  Return ZFILE if Zmodem filename received, -1 on error,
 *   ZCOMPL if transaction finished,  else 0
 */
int tryz(void)
{
   static int c, n, *ip;
   static int cmdzack1flg;

   if (Nozmodem) {              /* ymodem has been forced */
      return 0;
   }

   for (n=Zmodem?15:5; --n>=0; ) {
      if (opabort()) {
         return NERROR;
      }
      /* Set buffer length (0) and capability flags */
      stohdr(0L);
      Txhdr[ZF0] = (Wantfcs32 ? CANFC32 : 0) | CANFDX;
      if (Zctlesc) {
         Txhdr[ZF0] |= TESCCTL;
      }
      ip = (int *)&Txhdr[ZP0];
      *ip = Cpbufsize;
      zm_log("TX tryz hdr");
      zshhdr(Tryzhdrtype, Txhdr);
      if (Tryzhdrtype == ZSKIP) {  /* Don't skip too far */
         Tryzhdrtype = ZRINIT;     /* CAF 8-21-87 */
      }
again:
      switch (zgethdr(Rxhdr, 0)) {
         case ZRQINIT:
            continue;
         case ZEOF:
            continue;
         case TIMEOUT:
            continue;
         case ZFILE:
            zm_log("tryz ZFILE");
            Tryzhdrtype = ZRINIT;
            c = zrdata(Secbuf, KSIZE);
            zm_log_zdata(c);
            if (c == GOTCRCW) {
               zm_log("tryz ZFILE data ok -> ZFILE");
               return ZFILE;
            }
            zm_log("TX ZNAK");
            zshhdr(ZNAK, Txhdr);
            goto again;
         case ZSINIT:
            Zctlesc = TESCCTL & Rxhdr[ZF0];
            if (zrdata(Attn, ZATTNLEN) == GOTCRCW) {
               zshhdr(ZACK, Txhdr);
               goto again;
            }
            zshhdr(ZNAK, Txhdr);
            goto again;
         case ZFREECNT:
            stohdr(0L);
            zshhdr(ZACK, Txhdr);
            goto again;
         case ZCOMMAND:
            cmdzack1flg = Rxhdr[ZF0];
            if (zrdata(Secbuf, KSIZE) == GOTCRCW) {
               stohdr(0L);
               purgeline();   /* dump impatient questions */
               do {
                  zshhdr(ZCOMPL, Txhdr);
                  zperr("Waiting for ZFIN",FALSE);
                  if (opabort()) {
                     return NERROR;
                  }
               } while (++Errors<20 && zgethdr(Rxhdr,1) != ZFIN);
               ackbibi();
               return ZCOMPL;
            }
            zshhdr(ZNAK, Txhdr); 
            goto again;
         case ZCOMPL:
            goto again;
         default:
            continue;
         case ZFIN:
            ackbibi(); 
            return ZCOMPL;
         case RCDO:
            if (g_zm_recv_ok) {
               zm_log("tryz RCDO after recv ok");
               ackbibi();
               return ZCOMPL;
            }
            continue;
         case ZCAN:
            return NERROR;
      }
   }
   return 0;
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5g.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern int rzfile(void);
extern int tryz(void);
/*
 * Receive 1 or more files with ZMODEM protocol
 */

int rzmfile(void)
{
   static int c;
   static int tz;

   for (;;) {
      if (opabort()) {
         return NERROR;
      }
      c = rzfile();
      zm_log("rzmfile rzfile ret");
      closeit();
      zm_log("rzmfile closeit done");
      switch (c) {
         case ZEOF:
         case ZSKIP:
            zm_log("rzmfile tryz next");
            tz = tryz();
            switch (tz) {
               case ZCOMPL:
               case 0:
                  return OK;
               default:
                  if (g_zm_recv_ok) {
                     return OK;
                  }
                  return NERROR;
               case ZFILE:
                  break;
            }
            continue;
         default:
            return c;
         case NERROR:
            return NERROR;
      }
   }
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5h.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern int procheader(char *name);
extern void stohdr(long pos);
extern void zshhdr(int type, char *hdr);
extern int zgethdr(char *hdr, int eflag);
extern int zrdata(char *buf, int length);
extern long rclhdr(char *hdr);
extern int closeit(void);
extern int zmputs(char *s);
extern void statrep(long rxbytes);
extern int putsec(int count, int flag);
extern int Tryzhdrtype;
extern int Firstsec;
extern char *Secbuf;
extern int Errors;
extern int Crc32;
extern unsigned Cpindex;
extern unsigned Cpbufsize;
extern char *Rxptr;
extern char Attn[ZATTNLEN+1];
extern int Rxcount;
extern char Rxhdr[4];
extern char Txhdr[4];

#define MAX_ZERRORS 10
/*
 * Receive a file with ZMODEM protocol
 *  Assumes file name frame is in Secbuf
 */
int rzfile(void)
{
   static int c, n;
   static unsigned bufleft;
   static long rxbytes;

   if (procheader(Secbuf) == NERROR) {
      zm_log("rzfile procheader fail");
      return (Tryzhdrtype = ZSKIP);
   }

   zm_log("rzfile data loop start");
   n = MAX_ZERRORS; 
   rxbytes = 0L;
   Firstsec = TRUE;

   for (;;) {
      if (opabort()) {
         return NERROR;
      }
      stohdr(rxbytes);
      zm_log("TX ZRPOS");
      g_zm_skip_purge = 1u;
      zshhdr(ZRPOS, Txhdr);
      g_zm_skip_purge = 0u;
nxthdr:
      if (opabort()) {
         return NERROR;
      }
      switch (c = zgethdr(Rxhdr, 0)) {

         default:
            return NERROR;

         case ZNAK:
         case TIMEOUT:
            if ( --n < 0) {
               return NERROR;
            }

         case ZFILE:
            zrdata(Secbuf, KSIZE);
            continue;

         case ZEOF:
            {
               long zpos;

               zpos = rclhdr(Rxhdr);
               zm_log_pos("ZEOF rx/hdr ", rxbytes, zpos);
               if (zpos != rxbytes) {
              /*
               * Ignore eof if it's at wrong place - force
               *  a timeout because the eof might have gone
               *  out before we sent our zrpos.
               */
               zm_log("ZEOF pos skip");
               Errors = 0;  
               goto nxthdr;
            }
            zm_log("ZEOF closeit");
            if (closeit()) {
               zm_log("ZEOF close fail");
               Tryzhdrtype = ZFERR;
               return NERROR;
            } else {
               zm_log("ZEOF close ok");
               g_zm_recv_ok = 1;
               setmodtime();
            }
               lreport(KBYTES,rxbytes);
               crcrept(Crc32);
               return c;
            }

         case NERROR:   /* Too much garbage in header search error */
            if ( --n < 0) {
               return NERROR;
            }
            zmputs(Attn);
            continue;

         case ZDATA:
            zm_log("rzfile got ZDATA");
            if (rclhdr(Rxhdr) != rxbytes) {
               if ( --n < 0) {
                  return NERROR;
               }
               zmputs(Attn);  
               continue;
            }
moredata:
            if (opabort()) {
               return NERROR;
            }
            bufleft = Cpbufsize - Cpindex;
            c = zrdata(Rxptr, (bufleft > KSIZE) ? KSIZE : bufleft);
            zm_log_zdata(c);
            switch (c) {

               case ZCAN:
                  return NERROR;

               case NERROR:   /* CRC error */
                  statrep(rxbytes);
                  if ( --n < 0) {
                     return NERROR;
                  }
                  zmputs(Attn);
                  continue;

               case TIMEOUT:
                  statrep(rxbytes);
                  if ( --n < 0) {
                     return NERROR;
                  }
                  continue;

               case GOTCRCW:
                  n = MAX_ZERRORS;
                  if (putsec(Rxcount,TRUE) == NERROR) {
                     zm_log("putsec fail");
                     return NERROR; /* Write to disk! */
                  }
                  rxbytes += Rxcount;
                  stohdr(rxbytes);
                  statrep(rxbytes);
                  zm_log("TX ZACK");
                  zshhdr(ZACK, Txhdr);
                  mcharout(XON);
                  goto nxthdr;

               case GOTCRCQ:
                  n = MAX_ZERRORS;
                  if (putsec(Rxcount,TRUE) == NERROR) {
                     return NERROR; /* Write to disk! */
                  }
                  rxbytes += Rxcount;
                  stohdr(rxbytes);
                  statrep(rxbytes);
                  zshhdr(ZACK, Txhdr);
                  goto moredata;

               case GOTCRCG:
                  n = MAX_ZERRORS;
                  if (putsec(Rxcount,FALSE) == NERROR) {
                     return NERROR; /* Don't write to disk */
                  }
                  rxbytes += Rxcount;
                  statrep(rxbytes);
                  goto moredata;

               case GOTCRCE:
                  n = MAX_ZERRORS;
                  if (putsec(Rxcount,FALSE) == NERROR) {
                     zm_log("putsec fail CRCE");
                     return NERROR; /* Don't write to disk */
                  }
                  rxbytes += Rxcount;
                  zm_log_val("CRCE rx ", rxbytes);
                  goto nxthdr;
            }
      }
   }
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5i.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern void lreport(int row, long value);
extern int Crc32;

/* Status report: don't do unless after error or ZCRCW since characters */
/*   will be lost unless rx has interrupt-driven I/O         */
void statrep(long rxbytes)
{
   lreport(KBYTES,rxbytes);
   crcrept(Crc32);
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5j.c ========== */

/********************** START OF XFER MODULE 5 ******************************/



extern int Firstsec;

/* Report CRC mode in use, but only if first sector */
void crcrept(int flag)
{
   if (Firstsec)
      report(BLKCHECK, flag ? "CRC-32" : "CRC-16");
   Firstsec = FALSE;   /* clear the flag */
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5k.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern int Fd;
extern char *Rxptr;
extern char *Cpmbuf;
extern unsigned Cpindex;
extern unsigned Cpbufsize;

/* Add a block to the main buffer pointer and write to disk if full */
/* or if flag set */
int putsec(int count, int flag)
{
   short status;
   unsigned size;

   status = 0;
   Rxptr += count;
   Cpindex += count;
   if ((Cpindex >= Cpbufsize) || flag)
   {
      size = (Cpindex > Cpbufsize) ? Cpbufsize : Cpindex;

      status = zm_write(Fd,Cpmbuf,size);
      if (status != size)
      {
         zperr("Disk write error",TRUE);
         status = NERROR;
      }
      Cpindex = 0;
      Rxptr = Cpmbuf;
   }
   return status;
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5l.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


/*
 * Send a string to the modem, processing for \336 (sleep 1 sec)
 *   and \335 (break signal)
 */
int zmputs(char *s)
{
   static int c;

   while (*s) {
      if (opabort())
         return NERROR;
      switch (c = *s++) {
      case '\336':
         wait(1); 
         continue;
      case '\335':
         sendbrk(); 
         continue;
      default:
         mcharout(c);
      }
   }
   return OK;
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5m.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


/* Test if file exists, rename to .BAK if so */
void testexist(char *filename)
{
   int fd;
   char *p, newfile[20];

   if ((fd = zm_open(filename,0)) != UBIOT) {
      zm_close(fd);
      strcpy(newfile,filename);
      if (p = strchr(newfile,'.'))
         *p = '\0';   /* stop at dot */
      strcat(newfile,".bak");
      zm_unlink(newfile);   /* remove any .bak already there */
      zm_rename(filename,newfile);
   }
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5n.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern unsigned Cpindex;
extern int Fd;
extern char *Cpmbuf;
extern char *Rxptr;

/*
 * Close the receive dataset, return OK or NERROR
 */
int closeit(void)
{  
   static int status;
   int length;

   status = OK;
   if (Fd != -1) {
      if (Cpindex) {
         length = (int)Cpindex;
         zm_log_pos("close flush ", (long)Cpindex, (long)length);

         status = ((zm_write(Fd,Cpmbuf,length) == length) ? OK : NERROR);
         if (status == NERROR) {
            zm_log("close flush wr fail");
         } else {
            zm_log("close flush wr ok");
         }

         Cpindex = 0;
         Rxptr = Cpmbuf;
      } else {
         zm_log("close no pending");
      }
      if (status == NERROR) {
         zperr("Disk write error",TRUE);
      }

      if (zm_close(Fd)==NERROR) {
         Fd = -1;

         zperr("File close error",TRUE);
         return NERROR;
      }
   }
   return status;
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5o.c ========== */

/********************** START OF XFER MODULE 5 ******************************/


extern void stohdr(long pos);
extern void zshhdr(int type, char *hdr);
extern char Txhdr[4];
/*
 * Ack a ZFIN packet, let byegones be byegones
 */

void ackbibi(void)
{
   static int n;

   stohdr(0L);
   for (n=3; --n>=0; ) {
      purgeline();
      zshhdr(ZFIN, Txhdr);
      switch (readline(100)) {
      case 'O':
         readline(INTRATIME);   /* Discard 2nd 'O' */
         return;
      case RCDO:
         return;
      case TIMEOUT:
      default:
         break;
      }
   }
}
   
/************************** END OF MODULE 5 *********************************/

/* ========== from zmxfer5p.c ========== */

/********************** START OF XFER MODULE 5 ******************************/



void rlabel(void) /*print receive mode labels on the 25th line*/
{
   putlabel("RECEIVE FILE Mode:  Press ESC to Abort...");
}

/************************** END OF MODULE 5 *********************************/

/* ========== from zzm.c ========== */

/*
 *   Z M . C
 *    ZMODEM protocol primitives
 *    07-28-87  Chuck Forsberg Omen Technology Inc
 *
 * Entry point Functions:
 *   zsbhdr(type, hdr) send binary header
 *   zshhdr(type, hdr) send hex header
 *   zgethdr(hdr, eflag) receive header - binary or hex
 *   zsdata(buf, len, frameend) send data
 *   zrdata(buf, len) receive data
 *   stohdr(pos) store position data in Txhdr
 *   long rclhdr(hdr) recover position offset from header
 */




extern long updc32(int b, long c);
extern int zdlread(void);
extern int noxrd7(void);
extern int zrb32hdr(char *hdr);
extern int zrbhdr(char *hdr);
extern int zrhhdr(char *hdr);
extern void xmchout(char c);
extern void zsendline(int c);
extern unsigned updcrc(unsigned cp, unsigned crc);
extern void zputhex(int c);
void zsbh32(char *,int);
int zrdat32(char *,int);

extern int Txfcs32;
extern int Rxcount;
extern int Baudrate;
extern int Rxtype;
extern int Rxtimeout;
extern long Rxpos;
extern int Crc32;
extern int Crc32t;
extern char *frametypes[FRTYPES + FTOFFSET];

static int Rxframeind;      /* ZBIN ZBIN32, or ZHEX type of frame received */

/* Send ZMODEM binary header hdr of type type */
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


/* Send ZMODEM binary header hdr of type type */

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

/* Send ZMODEM HEX header hdr of type type */

void zshhdr(int type, char *hdr)
{
   static int n;
   static unsigned crc;
#ifdef DEBUG
   printf("\nSending HEX header Type %d:",type);
   for (n = 0; n < 4; n++) {
      prhex( *(hdr + n));
   }
   printf("\n");
#endif

   xmchout(ZPAD); 
   xmchout(ZPAD); 
   xmchout(ZDLE); 
   xmchout(ZHEX);
   zputhex(type);
   Crc32t = 0;

   crc = updcrc(type, 0);
   for (n=4; --n >= 0; ++hdr) {
      zputhex(*hdr); 
      crc = updcrc((0377 & *hdr), crc);
   }
   crc = updcrc(0,updcrc(0,crc));
   zputhex(crc>>8); 
   zputhex(crc);

   /* Make it printable on remote machine */
   xmchout(CR); 
   xmchout(LF);
   /*
    * Uncork the remote in case a fake XOFF has stopped data flow
    */
   if (type != ZFIN && type != ZACK) {
      xmchout(CTRLQ);
   }
   purgeline();
}

/*
 * Send binary array buf of length length, with ending ZDLE sequence frameend
 */
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

/*
 * Receive array buf of max length with ending ZDLE sequence
 *  and CRC.  Returns the ending character or error code.
 *  NB: On errors may store length+1 bytes!
 */
int zrdata(char *buf, int length)
{
   static int c;
   static unsigned crc;
   static char *end;
   static int d;

   if (Rxframeind == ZBIN32)
      return zrdat32(buf, length);

   crc = Rxcount = 0;  
   end = buf + length;
   while (buf <= end) {
      {
         static unsigned got;
         static char *p;

         while (buf <= end) {
            got = zm_rx_take_plain(buf, (unsigned)(end - buf + 1), Zctlesc);
            if (got == 0u)
               break;
            p = buf;
            while (got-- != 0u) {
               crc = updcrc((unsigned char)*p, crc);
               p++;
            }
            buf += (unsigned)(p - buf);
         }
      }
      if ((c = zdlread()) & ~0377) {
crcfoo:
         switch (c) {
            case GOTCRCE:
            case GOTCRCG:
            case GOTCRCQ:
            case GOTCRCW:
               crc = updcrc((d=c)&0377, crc);
               if ((c = zdlread()) & ~0377)
                  goto crcfoo;
               crc = updcrc(c, crc);
               if ((c = zdlread()) & ~0377)
                  goto crcfoo;
               crc = updcrc(c, crc);
               if (crc & 0xFFFF) {
                  zperr("Bad data CRC",TRUE);

#ifdef   DEBUG
                  printf("\nCRC = %u\n",crc);
#endif

                  return NERROR;
               }
               Rxcount = length - (end - buf);
               return d;
            case GOTCAN:
               zperr("Sender CANceled",TRUE);
               return ZCAN;
            case TIMEOUT:
               zperr("TIMEOUT",TRUE);
               return c;
            default:
               zperr("Bad data subpkt",TRUE);
               return c;
         }
      }
      *buf++ = c;
      crc = updcrc(c, crc);
   }
   zperr("Subpkt too long",TRUE);
   return NERROR;
}

int zrdat32(char *buf, int length)
{
   static int c, d;
   static long crc;
   static char *end;

#ifdef DEBUG
   printf("\n(32)\n");
#endif

   crc = 0xFFFFFFFFL;  
   Rxcount = 0;  
   end = buf + length;
   while (buf <= end) {
      {
         static unsigned got;
         static char *p;

         while (buf <= end) {
            got = zm_rx_take_plain(buf, (unsigned)(end - buf + 1), Zctlesc);
            if (got == 0u)
               break;
            p = buf;
            while (got-- != 0u) {
               crc = updc32((unsigned char)*p, crc);
               p++;
            }
            buf += (unsigned)(p - buf);
         }
      }
      if ((c = zdlread()) & ~0377) {
crcfoo:
         switch (c) {
            case GOTCRCE:
            case GOTCRCG:
            case GOTCRCQ:
            case GOTCRCW:
               d = c;  
               c &= 0377;
               crc = updc32(c, crc);
               if ((c = zdlread()) & ~0377)
                  goto crcfoo;
               crc = updc32(c, crc);
               if ((c = zdlread()) & ~0377)
                  goto crcfoo;
               crc = updc32(c, crc);
               if ((c = zdlread()) & ~0377)
                  goto crcfoo;
               crc = updc32(c, crc);
               if ((c = zdlread()) & ~0377)
                  goto crcfoo;
               crc = updc32(c, crc);
               if (crc != 0xDEBB20E3) {
                  zperr("Bad data CRC",TRUE);
                  return NERROR;
               }
               Rxcount = length - (end - buf);
               return d;
            case GOTCAN:
               zperr("Sender CANceled",TRUE);
               return ZCAN;
            case TIMEOUT:
               zperr("TIMEOUT",TRUE);
               return c;
            default:
               zperr("Bad data subpkt",TRUE);
               return c;
         }
      }
      *buf++ = c;
      crc = updc32(c, crc);
   }
   zperr("Subpkt too long",TRUE);
   return NERROR;
}


/*
 * Read a ZMODEM header to hdr, either binary or hex.
 *  eflag controls local display of non zmodem characters:
 *   0:  no display
 *   1:  display printing characters only
 *   2:  display all non ZMODEM characters
 *  On success, set Zmodem to 1, set Rxpos and return type of header.
 *   Otherwise return negative on error.
 *   Return NERROR instantly if ZCRCW sequence, for fast error recovery.
 */
int zgethdr(char *hdr, int eflag)
{
   int c, cancount;
   unsigned long n;

   eflag = eflag;   n = Zrwindow + Baudrate * 10;      /* Max bytes before start of frame */
   Rxframeind = Rxtype = 0;

startover:
   cancount = 5;
again:
   /* Return immediate NERROR if ZCRCW sequence seen */
   switch (c = readline(Rxtimeout)) {
      case RCDO:
      case TIMEOUT:
         goto fifi;
      case CAN:
gotcan:
         if (--cancount <= 0) {
            c = ZCAN; 
            goto fifi;
         }
         switch (c = readline(INTRATIME)) {
            case TIMEOUT:
               goto again;
            case ZCRCW:
               c = NERROR;
               /* **** FALL THRU TO **** */
            case RCDO:
               goto fifi;
            default:
               break;
            case CAN:
               if (--cancount <= 0) {
                  c = ZCAN; 
                  goto fifi;
               }
               goto again;
         }
         /* **** FALL THRU TO **** */
      default:
agn2:
         if ( --n == 0) {
            zperr("Grbg ct exceeded",TRUE);
            zm_log_rx(NERROR);
            return(NERROR);
         }
         goto startover;
      case ZPAD|0200:      /* This is what we want. */
      case ZPAD:      /* This is what we want. */
         break;
   }
   cancount = 5;
splat:
   switch (c = noxrd7()) {
      case ZPAD:
         goto splat;
      case RCDO:
      case TIMEOUT:
         goto fifi;
      default:
         goto agn2;
      case ZDLE:      /* This is what we want. */
         break;
   }

   switch (c = noxrd7()) {
      case RCDO:
      case TIMEOUT:
         goto fifi;
      case ZBIN:
         Rxframeind = ZBIN;  
         Crc32 = FALSE;
         c =  zrbhdr(hdr);
         break;
      case ZBIN32:
         Crc32 = Rxframeind = ZBIN32;
         c =  zrb32hdr(hdr);
         break;
      case ZHEX:
         Rxframeind = ZHEX;  
         Crc32 = FALSE;
         c =  zrhhdr(hdr);
         break;
      case CAN:
         goto gotcan;
      default:
         goto agn2;
   }
   Rxpos = (unsigned)(hdr[ZP3] & 0377);
   Rxpos = (Rxpos<<8) + (unsigned)(hdr[ZP2] & 0377);
   Rxpos = (Rxpos<<8) + (unsigned)(hdr[ZP1] & 0377);
   Rxpos = (Rxpos<<8) + (unsigned)(hdr[ZP0] & 0377);
fifi:
   switch (c) {
      case GOTCAN:
         c = ZCAN;
         /* **** FALL THRU TO **** */
      case ZNAK:
      case ZCAN:
      case NERROR:
      case TIMEOUT:
      case RCDO:
         if (c == RCDO && g_zm_recv_ok) {
            break;
         }
         sprintf(Buf,"Got %s", frametypes[c+FTOFFSET]);
         zperr(Buf,TRUE);
         /* **** FALL THRU TO **** */
      default:
         break;
   }
   zm_log_rx(c);
   return c;
}

#ifdef DEBUG

/* Print a byte in hex on the console */

int prhex(char byte)
{
   static char digits[] = "0123456789abcdef";
   char hi, lo;

   hi = digits[(byte & 0xf0) >> 4];
   lo = digits[byte & 0x0f];
   printf(" %c%c",hi,lo);
}

#endif

/***************************** End of hzm.c *********************************/

/* ========== from zzm2.c ========== */

/* ZZM.C Part 2 */



extern long updc32(int b, long c);
extern unsigned updcrc(unsigned cp, unsigned crc);
int zdlread(void);
int zrb32hdr(char *hdr);
int zrhhdr(char *hdr);
int zgethex(void);
void zputhex(int c);
void zsendline(int c);
int zgeth1(void);
int noxrd7(void);
void stohdr(long pos);
long rclhdr(char *hdr);

extern int Zctlesc;
extern char Txhdr[4];
extern int Rxtimeout;
extern int Rxtype;

/* Receive a binary style header (type and position) */
int zrbhdr(char *hdr)
{
   static int c, n;
   static unsigned crc;

   if ((c = zdlread()) & ~0377) {
      return c;
   }
   Rxtype = c;
   crc = updcrc(c, 0);

   for (n=4; --n >= 0; ++hdr) {
      if ((c = zdlread()) & ~0377) {
         return c;
      }
      crc = updcrc(c, crc);
      *hdr = c;
   }
   if ((c = zdlread()) & ~0377) {
      return c;
   }
   crc = updcrc(c, crc);
   if ((c = zdlread()) & ~0377) {
      return c;
   }
   crc = updcrc(c, crc);
   if (crc & 0xFFFF) {
      zperr("Bad Header CRC",TRUE); 
      return NERROR;
   }
   Zmodem = 1;

#ifdef DEBUG
   printf("\nReceived BINARY header type %d: ",Rxtype);
   for (n = -4; n < 0; n++) {
      prhex( *(hdr + n));
   }
   printf("\n");
#endif

   return Rxtype;
}

/* Receive a binary style header (type and position) with 32 bit FCS */
int zrb32hdr(char *hdr)
{
   static int c, n;
   static long crc;

   if ((c = zdlread()) & ~0377) {
      return c;
   }
   Rxtype = c;
   crc = 0xFFFFFFFFL; 
   crc = updc32(c, crc);

   for (n=4; --n >= 0; ++hdr) {
      if ((c = zdlread()) & ~0377) {
         return c;
      }
      crc = updc32(c, crc);
      *hdr = c;
   }
   for (n=4; --n >= 0;) {
      if ((c = zdlread()) & ~0377) {
         return c;
      }
      crc = updc32(c, crc);
   }
   if (crc != 0xDEBB20E3) {
      zperr("Bad Header CRC",TRUE); 
      return NERROR;
   }
   Zmodem = 1;

#ifdef DEBUG
   printf("\nReceived 32-bit FCS BINARY header type %d: ",Rxtype);
   for (n = -4; n < 0; n++)
      prhex( *(hdr + n));
   printf("\n");
#endif

   return Rxtype;
}


/* Receive a hex style header (type and position) */
int zrhhdr(char *hdr)
{
   static int c;
   static unsigned crc;
   static int n;

   if ((c = zgethex()) < 0) {
      return c;
   }
   Rxtype = c;
   crc = updcrc(c, 0);

   for (n=4; --n >= 0; ++hdr) {
      if ((c = zgethex()) < 0) {
         return c;
      }
      crc = updcrc(c, crc);
      *hdr = c;
   }
   if ((c = zgethex()) < 0) {
      return c;
   }
   crc = updcrc(c, crc);
   if ((c = zgethex()) < 0) {
      return c;
   }
   crc = updcrc(c, crc);
   if (crc & 0xFFFF) {
      zperr("Bad Header CRC",TRUE); 
      return NERROR;
   }
   if (readline(INTRATIME) == '\r') {   /* Throw away possible cr/lf */
      readline(INTRATIME);
   }
   Zmodem = 1; 

#ifdef DEBUG
   printf("\nReceived HEX header type %d: ",Rxtype);
   for (n = -4; n < 0; n++) {
      prhex( *(hdr + n));
   }
   printf("\n");
#endif

   return Rxtype;
}

/* Send a byte as two hex digits */
void zputhex(int c)
{
   static char digits[] = "0123456789abcdef";

   xmchout(digits[(c&0xF0)>>4]);
   xmchout(digits[(c)&0xF]);
}

/*
 * Send character c with ZMODEM escape sequence encoding.
 *  Escape XON, XOFF. Escape CR following @ (Telenet net escape)
 */
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

/* Decode two lower case hex digits into an 8 bit byte value */
int zgethex(void)
{
   int c;

   c = zgeth1();
   return c;
}

int zgeth1(void)
{
   static int c, n;

   if ((c = noxrd7()) < 0)
      return c;
   n = c - '0';
   if (n > 9) {
      n -= ('a' - ':');
   }
   if (n & ~0xF) {
      return NERROR;
   }
   if ((c = noxrd7()) < 0) {
      return c;
   }
   c -= '0';
   if (c > 9) {
      c -= ('a' - ':');
   }
   if (c & ~0xF) {
      return NERROR;
   }
   c += (n<<4);
   return c;
}

/*
 * Read a byte, checking for ZMODEM escape encoding
 *  including CAN*5 which represents a quick abort
 */

int zdlread(void)
{
   static int c;

again:
   switch (c = readline(Rxtimeout)) {
   case ZDLE:
      break;
   case 023:
   case 0223:
   case 021:
   case 0221:
      goto again;
   default:
      if (Zctlesc && !(c & 0140)) {
         goto again;
      }
      return c;
   }
again2:
   if ((c = readline(Rxtimeout)) < 0) {
      return c;
   }
   if (c == CAN && (c = readline(Rxtimeout)) < 0) {
      return c;
   }
   if (c == CAN && (c = readline(Rxtimeout)) < 0) {
      return c;
   }
   if (c == CAN && (c = readline(Rxtimeout)) < 0) {
      return c;
   }
   switch (c) {
      case CAN:
         return GOTCAN;
      case ZCRCE:
      case ZCRCG:
      case ZCRCQ:
      case ZCRCW:
         return (c | GOTOR);
      case ZRUB0:
         return 0177;
      case ZRUB1:
         return 0377;
      case 023:
      case 0223:
      case 021:
      case 0221:
         goto again2;
      default:
         if (Zctlesc && ! (c & 0140)) {
            goto again2;
         }
         if ((c & 0140) ==  0100) {
            return (c ^ 0100);
         }
         break;
   }
   sprintf(Buf,"Bad escape %x", c);
   zperr(Buf,TRUE);
   return NERROR;
}

/*
 * Read a character from the modem line with timeout.
 *  Eat parity, XON and XOFF characters.
 */
int noxrd7(void)
{
   static int c;

   for (;;) {
      if ((c = readline(Rxtimeout)) < 0) {
         return c;
      }
      switch (c &= 0177) {
         case XON:
         case XOFF:
            continue;
         default:
            if (Zctlesc && !(c & 0140)) {
               continue;
            }
         case '\r':
         case '\n':
         case ZDLE:
            return c;
      }
   }
}

/* Store long integer pos in Txhdr */
void stohdr(long pos)
{
   Txhdr[ZP0] = pos;
   Txhdr[ZP1] = (pos>>8);
   Txhdr[ZP2] = (pos>>16);
   Txhdr[ZP3] = (pos>>24);
}

/* Recover a long integer from a header */
long rclhdr(char *hdr)
{
   static long l;

   l = (unsigned)(hdr[ZP3] & 0377);
   l = (l << 8) | (unsigned)(hdr[ZP2] & 0377);
   l = (l << 8) | (unsigned)(hdr[ZP1] & 0377);
   l = (l << 8) | (unsigned)(hdr[ZP0] & 0377);
#ifdef DEBUG
   lreport(FBLOCKS,l);
#endif
   return l;
}

/***************************** End of hzm2.c *********************************/

