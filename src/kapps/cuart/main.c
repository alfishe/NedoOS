#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <../common/terminal.c>
//
//const unsigned char ready[] = "ready";
const unsigned char gotWiFi[] = "WIFI GOT IP";

unsigned int RBR_THR = 0xf8ef;
unsigned int IER = 0xf9ef;
unsigned int IIR_FCR = 0xfaef;
unsigned int LCR = 0xfbef;
unsigned int MCR = 0xfcef;
unsigned int LSR = 0xfdef;
unsigned int MSR = 0xfeef;
unsigned int SR = 0xffef;
unsigned int divider = 1;
unsigned char comType = 0;
unsigned int espType = 32;
unsigned char directMode = 0;

unsigned char key;
int bufferPos = 0;
int endPos = 0;
int curpos = 0;
int oldpos = 0;

unsigned char netbuf[8500];

void clearStatus(void)
{
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

///////////////////////////
#include <../common/esp-com.c>
//////////////////////////

void getdata(void)
{
  uart_setrts(2);
  while (uart_hasByte() != 0)
  {
    netbuf[bufferPos] = uart_read();
    bufferPos++;
    uart_setrts(2);

    if (bufferPos > 8191)
    {
      endPos = bufferPos;
      bufferPos = 0;
    }
  }
}

void renderWin(void)
{
  for (curpos = oldpos; curpos < bufferPos; curpos++)
  {
    putchar(netbuf[curpos]);
  }
  oldpos = curpos;
}

void saveBuff(void)
{
  int len;
  unsigned long size;
  FILE *fp1;
  unsigned char crlf[2] = {13, 10};
  fp1 = OS_OPENHANDLE("buffer.log", 0x80);
  if (((int)fp1) & 0xff)
  {
    puts("Open buffer.log error");
    puts("Creating buffer.log file");
    fp1 = OS_CREATEHANDLE("buffer.log", 0x80);
    if (((int)fp1) & 0xff)
    {
      puts("Create buffer.log error");
      return;
    }
    OS_CLOSEHANDLE(fp1);
    fp1 = OS_OPENHANDLE("buffer.log", 0x80);
    if (((int)fp1) & 0xff)
    {
      puts("Open buffer.log error");
      return;
    }
  }
  size = OS_GETFILESIZE(fp1);
  len = curpos;
  OS_SEEKHANDLE(fp1, size);
  OS_WRITEHANDLE(crlf, fp1, 2);
  OS_WRITEHANDLE("********************************************************************************", fp1, 80);
  OS_WRITEHANDLE(crlf, fp1, 2);
  OS_WRITEHANDLE(netbuf, fp1, len);
  OS_CLOSEHANDLE(fp1);
  puts("buffer.log saved.");
}

void testQueue(void)
{
  sendcommand("AT+CIPSNTPTIME?");
  getdata();
  renderWin();
  delay(500);
  sendcommand("AT+CIPSNTPCFG=1,300,\"0.pool.ntp.org\",\"time.google.com\"");
  getdata();
  renderWin();
  delay(500);
  sendcommand("AT+CIPSNTPTIME?");
  getdata();
  renderWin();
}
C_task main(void)
{
  unsigned char cmd[512];
  unsigned char cmdpos;
  os_initstdio();
  BOX(1, 1, 80, 25, 40, ' ');
  AT(25, 1);
  ATRIB(92);
  puts("[UART COMMUNICATION PROGRAMM]");
  loadEspConfig();
  uart_init(divider);
  ATRIB(93);
  puts("    <ext+U> AT+CIUPDATE <End> Direct mode <PgUp> AT+GMR  <Home> testQueue()    ");
  puts("             <PgDn> '+++' <ext+1...0> baudrate <ext+S> save buffer             ");
  ATRIB(92);
  puts("===============================================================================");

  delay(250);
  cmd[0] = 0;
  cmdpos = 0;
  while (1)
  {
    unsigned char count;
    getdata();
    renderWin();
    key = _low_level_get();
    if (key != 0)
    {
      if (directMode == 1 && key != 0)
      {
        if (key == 30)
        {
          directMode = 0;
          key = 0;
          puts("\r\nDirect mode disabled.");
        }
        else
        {
          uart_write(key);
          if (key == 13)
          {
            uart_write(10);
            putchar('\r');
            putchar('\n');
          }
        }
      }
      if (key != 0 && directMode == 0)
      {
        // printf("key = %u   ", key);
        switch (key)
        {
        case 177:
          uart_init(1);
          puts("Uart inited @ 115200 [Div:1]");
          key = 0;
          break;

        case 178:
          uart_init(2);
          puts("Uart inited @ 57600 [Div:2]");
          key = 0;
          break;

        case 179:
          uart_init(3);
          puts("Uart inited @ 38400 [Div:3]");
          key = 0;
          break;

        case 180:
          uart_init(4);
          puts("Uart inited @ 28800 [Div:4]");
          key = 0;
          break;

        case 181:
          uart_init(6);
          puts("Uart inited @ 19200 [Div:6]");
          key = 0;
          break;

        case 182:
          uart_init(8);
          puts("Uart inited @ 14400 [Div:8]");
          key = 0;
          break;

        case 183:
          uart_init(12);
          puts("Uart inited @ 9600 [Div:12]");
          key = 0;
          break;

        case 184:
          uart_init(24);
          puts("Uart inited @ 4800 [Div:24]");
          key = 0;
          break;

        case 185:
          uart_init(48);
          puts("Uart inited @ 2400 [Div:48]");
          key = 0;
          break;

        case 176:
          uart_init(96);
          puts("Uart inited @ 1200 [Div:96]");
          key = 0;
          break;

        case 13:
          cmd[cmdpos] = 0;
          sendcommand(cmd);
          cmdpos = 0;
          cmd[cmdpos] = 0;
          putchar('\r');
          putchar('\n');
          key = 0;
          break;

        case 19:
          saveBuff();
          key = 0;
          break;

        case 27:
          exit(0);

        case 8:
          if (cmdpos != 0)
          {
            cmdpos--;
            cmd[cmdpos] = 0;
            putchar('\r');
            for (count = 0; count < cmdpos + 1; count++)
            {
              putchar(' ');
            }
            putchar('\r');
            count = 0;
            while (cmd[count] != 0)
            {
              putchar(cmd[count]);
              count++;
            }
          }
          key = 0;
          break;

        case 246: // PgUp
          sendcommand("AT+GMR");
          key = 0;
          break;

        case 247: // PgDn
          sendcommand("+++");
          key = 0;
          break;

        case 30: // End
          directMode = 1;
          puts("\r\nDirect mode enabled.");

          key = 0;
          break;

        case 28: // home
          testQueue();
          key = 0;
          break;

        case 21: // <ext> + <U>
          sendcommand("AT+CIUPDATE");
          key = 0;
          break;
        }
      }

      if (key != 0)
      {
        cmd[cmdpos] = key;
        cmdpos++;
        putchar(key);
      }
    }
  }
  return 0;
}
