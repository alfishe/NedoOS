unsigned char spdFactor;
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <terminal.c>
#include <auart.h>
#include <esp32.c>
unsigned char key;
unsigned char buffer[8500] = "";
int bufferPos;
int endPos;
int curpos;
int oldpos;
unsigned char cursorX;
unsigned char cursorY;

void getdata (void)
{
  unsigned char readbyte;
  uart_startrts();
  uart_stoprts();

  while (uart_queue() != 0)
  {
    readbyte = uart_read();
    buffer[bufferPos] = readbyte;
    bufferPos++;

  }
  if (bufferPos > 8191)
  {
    endPos   = bufferPos;
    bufferPos = 0;
  }
}


void renderWin(void)
{
  for (curpos = oldpos; curpos < bufferPos; curpos++)
  {
    putchar (buffer[curpos]);
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
  OS_WRITEHANDLE(buffer, fp1, len);
  OS_CLOSEHANDLE(fp1);
  puts("buffer.log saved.");
}

void flushbuf(void)
{
  while (uart_queue() != 0)
  {
    uart_read();
  }
}

C_task main(void)
{
  unsigned  char cmd[256];
  unsigned char cmdpos;
  os_initstdio();
  puts("ATM2+ UART TESTER. SEND AND RECIEVE BYTES.");
  uart_init(3);
  spdFactor = 45;
  puts("Uart inited @ 38400");
  flushbuf();
  cmd[0] = '\0';
  cmdpos = 0;
  while (1)
  {
    unsigned char count;
   getdata();
   renderWin();

    key = _low_level_get();
    if (key != 0)
    {
      switch (key)
      {
        case 177:
          uart_init(1);
          puts("Uart inited @ 115200");
		  spdFactor = 13;
          key = 0;
          break;

        case 178:
          uart_init(2);
          puts("Uart inited @ 57600");
          spdFactor = 28;
		  key = 2;
          break;

        case 179:
          uart_init(3);
          puts("Uart inited @ 38400");
		  spdFactor = 44;
          key = 0;
          break;

        case 180:
          uart_init(4);
          puts("Uart inited @ 28800");
          spdFactor = 55;
		  key = 0;
		  break;

        case 181:
          uart_init(6);
          puts("Uart inited @ 19200");
		  spdFactor = 20;
          key = 0;
          break;

        case 182:
          uart_init(8);
          puts("Uart inited @ 14400");
		  spdFactor = 90;
          key = 0;
          break;

        case 183:
          uart_init(12);
          puts("Uart inited @ 9600");
		  spdFactor = 100;
          key = 0;
          break;

        case 184:
          uart_init(24);
          puts("Uart inited @ 4800");
		  spdFactor = 100;
          key = 0;
          break;

        case 185:
          uart_init(48);
          puts("Uart inited @ 2400");
		  spdFactor = 100;
          key = 0;
          break;

        case 176:
          uart_init(96);
          puts("Uart inited @ 1200");
		  spdFactor =  150;
          key = 0;
          break;

        case 13:
          cmd[cmdpos] = '\0';
          sendcommand(cmd);
          cmdpos = 0;
          cmd[cmdpos] = '\0';
          putchar ('\r');
          putchar ('\n');
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
          cmd[cmdpos] = '\0';
          putchar ('\r');
          for ( count = 0; count < cmdpos + 1; count++)
          {
            putchar (' ');
          }
          putchar ('\r');
          count = 0;
          while (cmd[count] != '\0')
          {
            putchar(cmd[count]);
            count++;
          }
        }
			key = 0;
			break;
	  }
    }

    if (key != 0)
    {
      cmd[cmdpos] = key;
      cmdpos++;
      putchar (key);
    }
  }
return 0;
}