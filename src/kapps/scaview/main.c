#include <tcp.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <graphic.h>
#include <../common/terminal.c>

#define true 1
#define false 0
//
FILE *fp1;

struct headers
{
  unsigned char marker[4]; // SCA
  unsigned char version;   // 01
  unsigned int width;      // 00 01
  unsigned int height;     // C0 00
  unsigned char border;    // 00
  unsigned int frames;     // 03 00
  unsigned char ptype;     // 00
  unsigned int poffset;    // 0E 00
  unsigned int doffset;
  unsigned long filesize;
  unsigned char pagesNeeded;
  unsigned char isAtm;
  unsigned char totalMem;
  unsigned char freeMem;
  unsigned char scr0high;
  unsigned char scr1high;
  unsigned char curScreen;
  unsigned char curPage;
  unsigned char curFrame;
  unsigned int headerSize;
} header;

unsigned char buf[4096];
unsigned char framesDelays[1024];
unsigned char mem[256]; // reserved pages
void quit(void)
{
  OS_SETGFX(-1);
  exit(0);
}
char waitKey(void)
{
  char key;
  do
  {
    key = OS_GETKEY();
  } while (key == 0);
  return key;
}

void delay(unsigned long counter)
{
  unsigned long start, finish;
  counter = counter / 20;
  if (counter < 1)
  {
    counter = 1;
  }
  start = time();
  finish = start + counter;

  while (start < finish)
  {
    start = time();
  }
}

void delayLong(unsigned long counter)
{
  unsigned long start, finish;
  counter = counter / 20;
  if (counter < 1)
  {
    counter = 1;
  }
  start = time();
  finish = start + counter;

  while (start < finish)
  {
    start = time();
    YIELD();
  }
}

unsigned char getFreeMem(void)
{
  unsigned char freeMem = 0, counter;
  for (counter = 0; counter < header.totalMem; counter++)
  {
    unsigned char owner;
    owner = OS_GETPAGEOWNER(~counter);
    if (owner == 0)
    {
      freeMem++;
    }
  }
  return freeMem;
}

char getMem(char numOfPages)
{
  char result, pageCount;
  result = true;
  for (pageCount = 0; pageCount < numOfPages; pageCount++)
  {
    unsigned int newPage;
    newPage = OS_NEWPAGE();
    if (newPage > 255)
    {
      result = false;
      break;
    }
    mem[pageCount] = newPage;
  }
  return result;
}

void loadFile(void)
{
  const char *marker;
  unsigned int counter;

  OS_READHANDLE(buf, fp1, header.headerSize);

  header.marker[0] = buf[0];
  header.marker[1] = buf[1];
  header.marker[2] = buf[2];
  header.marker[3] = 0;
  header.version = buf[3];
  header.width = buf[4] + buf[5] * 256;
  header.height = buf[6] + (buf[7] * 256);
  header.border = buf[8];
  header.frames = buf[9] + (buf[10] * 256);
  header.ptype = buf[11];
  header.poffset = buf[12] + (buf[13] * 256);
  header.doffset = header.poffset + header.frames;
  header.filesize = OS_GETFILESIZE(fp1);
  header.pagesNeeded = header.filesize / 16384 + 1;
  header.curScreen = 1;
  header.curPage = 0;
  /*
    printf("Size : %lu bytes\r\n", header.filesize);
    printf("Total pages  : %u\r\n", header.totalMem);
    printf("Pages needed : %u\r\n", header.pagesNeeded);
    printf("Free pages   : %u\r\n", header.freeMem);
    printf("Marker: %s\r\n", header.marker);
    printf("Width: %u\r\n", header.width);
    printf("Height: %u\r\n", header.height);
    printf("Border: %u\r\n", header.border);
    printf("Frames: %u\r\n", header.frames);
    printf("Payload type: %u\r\n", header.ptype);
    printf("payload offset: %u\r\n", header.poffset);
    printf("data offset: %u\r\n", header.doffset);
  */
  marker = strstr(header.marker, "SCA");
  if (marker == NULL)
  {
    printf("File is not a SCA animation [%s] \r\n", header.marker);
    waitKey();
    quit();
  }

  if (header.pagesNeeded > header.freeMem)
  {
    printf("Not enough memory. Needed %u pages more  \r\n", header.pagesNeeded - header.freeMem);
    waitKey();
    quit();
  }
  if (!getMem(header.pagesNeeded))
  {
    printf("Memory allocarion error\r\n");
    waitKey();
    quit();
  }

  OS_READHANDLE(framesDelays, fp1, header.frames);

  ///////////////////////LOADER///////////////////////
  for (counter = 0; counter < header.pagesNeeded; counter++)
  {
    OS_SETPG8000(mem[counter]);
    OS_READHANDLEMEM(0x8000, fp1, 16384);
    //printf("Page %02u loaded   \r", counter);
    //printf("%02u [%u]", counter, mem[counter]);
    ///////////////////////LOADER///////////////////////
  }
}
void init(void)
{
  unsigned char pgbak;
  union APP_PAGES main_pg;
  header.scr0high = OS_GETSCR0() >> 8;
  header.scr1high = OS_GETSCR1() >> 8;
  header.isAtm = (unsigned char)OS_GETCONFIG(); // 1-Evo 2-ATM2 3-ATM3 6-p2.666
  header.headerSize = 14;
  header.totalMem = 255;
  main_pg.l = OS_GETMAINPAGES();

  pgbak = main_pg.pgs.window_2;
  OS_DELPAGE(pgbak);
  pgbak = main_pg.pgs.window_3;
  OS_DELPAGE(pgbak);
  header.freeMem = getFreeMem();
}

void clearScreens(void)
{
  SETPG32KHIGH(header.scr1high);
  CLEARC000();
  SETPG32KHIGH(header.scr0high);
  CLEARC000();
}

unsigned int viewScreen6912NoKeyGraph_c(unsigned int bufAdr, unsigned int bufOffset)
{
  OS_SETBORDER(header.border);
  OS_SETPG8000(mem[header.curPage]);

  if (header.curScreen == 1)
  {
    SETPG32KHIGH(header.scr0high);
    header.curScreen = 0;
  }
  else
  {
    SETPG32KHIGH(header.scr1high);
    header.curScreen = 1;
  }

  if (bufOffset < 9473)
  {
    memcpy((unsigned char *)(0xc000), (unsigned char *)(bufAdr + bufOffset), 6912);
    bufOffset = bufOffset + 6912;
  }
  else
  {
    unsigned int shiftAdr, shift;
    shift = 16384 - bufOffset;
    shiftAdr = 49152 + shift;
    memcpy((unsigned char *)(0xc000), (unsigned char *)(bufAdr + bufOffset), shift);
    header.curPage++;
    OS_SETPG8000(mem[header.curPage]);
    bufOffset = bufOffset + shift;
    memcpy((unsigned char *)(shiftAdr), (unsigned char *)(bufAdr), 6912 - shift);
    bufOffset = 6912 - shift;
  }
  OS_SETSCREEN(header.curScreen);

  if (header.curScreen == 0)
  {
    SETPG32KHIGH(header.scr1high);
  }

  if (header.curScreen == 1)
  {
    SETPG32KHIGH(header.scr0high);
  }
  CLEARC000();
  return bufOffset;
}

C_task main(int argc, char *argv[])
{
  unsigned int bufOffset;
  OS_HIDEFROMPARENT();
  OS_SETGFX(0x86);
  OS_CLS(0);
  init();

  if (argc < 2)
  {
    OS_SETCOLOR(67);
    printf("Error: File name required.[argc=%d]", argc);
    OS_SETCOLOR(6);
    waitKey();
    quit();
  }

  fp1 = OS_OPENHANDLE(argv[1], 0x80);

  if (((int)fp1) & 0xff)
  {
    printf("Error: %s opening error\r\n", argv[1]);
    waitKey();
    quit();
  }

  loadFile();
  clearScreens();
  OS_SETGFX(0x83);
  delayLong(1000);
label:
  header.curFrame = 0;
  bufOffset = 0;
  header.curPage = 0;
  do
  {
    bufOffset = viewScreen6912NoKeyGraph_c(0x8000, bufOffset);
    delay((framesDelays[header.curFrame] - 1) * 20);
    header.curFrame++;
    if (OS_GETKEY() != 0)
    {
      quit();
    }
  } while (header.curFrame < header.frames);
  goto label;
}
