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
  unsigned int headerSize;
} header;

unsigned char buf[25000];

unsigned char ver[] = "0.1";
unsigned char buffer[] = "0000000000";
unsigned char crlf[2] = {13, 10};

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

C_task main(int argc, char *argv[])
{
  unsigned int todo, curFrame, curFrameAdr, curBufAdr;
  unsigned char frameDelay;
  unsigned long bufIntBrd;
  OS_HIDEFROMPARENT();
  OS_SETGFX(0x86);
  OS_CLS(0);

  OS_SETCOLOR(67);
  printf("SCA viewer version:%s\r\n", ver);
  OS_SETCOLOR(6);

  if (argc < 2)
  {
    OS_SETCOLOR(67);
    puts("Error: File name required.");
    OS_SETCOLOR(6);
    while (OS_GETKEY() == 0)
    {
    }
    exit(0);
  }

  fp1 = OS_OPENHANDLE(argv[1], 0x80);

  if (((int)fp1) & 0xff)
  {
    printf("Error: %s opening error\r\n", argv[1]);
    exit(0);
  }

  todo = OS_READHANDLE(buf, fp1, sizeof(buf));
  printf("Readed:%u\r\n", todo);

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
  header.headerSize = 14;



  printf("Size: %lu\r\n", header.filesize);
  printf("Pages needed : %u\r\n", header.pagesNeeded);
  printf("Marker: %s\r\n", header.marker);
  printf("Width: %u\r\n", header.width);
  printf("Height: %u\r\n", header.height);
  printf("Border: %u\r\n", header.border);
  printf("Frames: %u\r\n", header.frames);
  printf("Payload type: %u\r\n", header.ptype);
  printf("payload offset: %u\r\n", header.poffset);
  printf("data offset: %u\r\n", header.doffset);
  waitKey();
  OS_SETGFX(0x83);
label:
  curFrame = 0;
  //frameDelay = 4;
  do
  {
    frameDelay = buf[header.headerSize + curFrame];
    curFrameAdr = header.doffset + curFrame * 6912;
    curBufAdr = (unsigned int)&buf + curFrameAdr;
    bufIntBrd = curBufAdr * 65536;
    bufIntBrd = bufIntBrd + frameDelay * 256;
    bufIntBrd = bufIntBrd + header.border;
    // viewScreen6912NoKeyGraph(curBufAdr, frameDelay, header.border);
    viewScreen6912NoKeyGraph(bufIntBrd);
    curFrame++;
    if (OS_GETKEY() != 0)
    {
      OS_SETGFX(0x86);
      exit(0);
    }
  } while (curFrame < header.frames);
  goto label;
}
