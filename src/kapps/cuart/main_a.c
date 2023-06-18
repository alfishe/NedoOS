unsigned char spdFactor;
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <terminal.c>

#define RBR_THR 0xF8EF
#define IER 0xF9EF
#define IIR_FCR 0xFAEF
#define LCR 0xFBEF
#define MCR 0xFCEF
#define LSR 0xFDEF
#define MSR 0xFEEF
#define SR 0xFFEF

unsigned char key, machine;
unsigned char buffer[8500] = "";
int bufferPos;
int endPos;
int curpos;
int oldpos;
machine = 1;

void uart_init(unsigned char divisor)
{
  disable_interrupt();
  if (machine == 0)
  {
    input(0x55FE);
    input((0xC3 << 8) | 0x00fe);
    input((divisor << 8) | 0x00fe);
  }
  if (machine == 1)
  {
    output(MCR, 0x0d);     // Assert RTS
    output(IIR_FCR, 0x87); // Enable fifo 8 level, and clear it
    output(LCR, 0x83);     // 8n1, DLAB=1
    output(RBR_THR, 0x03); // 115200 (divider 1-115200, 3 - 38400)
    output(IER, 0x00);     // (divider 0). Divider is 16 bit, so we get (#0002 divider)
    output(LCR, 0x03);     // 8n1, DLAB=0
    output(IER, 0x00);     // Disable int
    output(MCR, 0x2f);     // Enable AFE
  }
  enable_interrupt();
}

unsigned char uart_CTS(void)
{
  unsigned char cts;
  disable_interrupt();
  if (machine == 0)
  {
    input(0x55FE);
    cts = input((0x82 << 8) | 0x00fe);
    cts = cts && 16;
  }
  if (machine == 1)
  {
    cts = input(MSR);
    cts = cts && 16 >> 4;
  }
  enable_interrupt();
  return cts;
}

void uart_write(unsigned char data)
{
  unsigned char status;
  disable_interrupt();
  input(0x55FE);
  status = input((0x42 << 8) | 0x00fe);
  // while (((status && 64)) == 0 || (uart_CTS() == 1))
  while ((status & 64) == 0)
  {
    input(0x55FE);
    status = input((0x42 << 8) | 0x00fe);
  }

  while (uart_CTS() == 1)
  {
  }

  input(0x55FE);
  input((0x03 << 8) | 0x00fe);
  input((data << 8) | 0x00fe);
  enable_interrupt();
}

void uart_startrts(void)
{
  disable_interrupt();
  input(0x55FE);
  input((0x43 << 8) | 0x00fe);
  input((0x03 << 8) | 0x00fe);
  enable_interrupt();
}

void uart_stoprts(void)
{
  disable_interrupt();
  input(0x55FE);
  input((0x43 << 8) | 0x00fe);
  input((0x00 << 8) | 0x00fe);
  enable_interrupt();
}

void uart_flashrts(void)
{
  disable_interrupt();
  input(0x55FE);
  input((0x43 << 8) | 0x00fe);
  input((0x03 << 8) | 0x00fe);
  input(0x55FE);
  input((0x43 << 8) | 0x00fe);
  input((0x00 << 8) | 0x00fe);
  enable_interrupt();
}

unsigned char uart_read(void)
{
  unsigned char queue, data;
  disable_interrupt();
  input(0x55FE);
  queue = input((0xC2 << 8) | 0x00fe);

  while (queue == 0)
  {
    input(0x55FE);
    queue = input((0xC2 << 8) | 0x00fe);
  }
  input(0x55FE);
  data = input((0x02 << 8) | 0x00fe);
  enable_interrupt();
  return data;
}

unsigned char uart_queue(void)
{
  unsigned char queue;
  disable_interrupt();
  input(0x55FE);
  queue = input((0xC2 << 8) | 0x00fe);
  enable_interrupt();
  return queue;
}

void sendcommand(char commandline[])
{
  int pos = 0;
  while (commandline[pos] != '\0')
  {
    uart_write(commandline[pos]);
    pos++;
  }
  uart_write('\r');
  uart_write('\n');
}

void getdata(void)
{
  unsigned char readbyte;
  uart_startrts();
  uart_delayXk(spdFactor);
  uart_stoprts();

  while (uart_queue() != 0)
  {
    readbyte = uart_read();
    buffer[bufferPos] = readbyte;
    bufferPos++;
  }
  if (bufferPos > 8191)
  {
    endPos = bufferPos;
    bufferPos = 0;
  }
}

void renderWin(void)
{
  for (curpos = oldpos; curpos < bufferPos; curpos++)
  {
    putchar(buffer[curpos]);
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
  unsigned char cmd[256];
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
        spdFactor = 15;
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
        spdFactor = 150;
        key = 0;
        break;

      case 13:
        cmd[cmdpos] = '\0';
        sendcommand(cmd);
        cmdpos = 0;
        cmd[cmdpos] = '\0';
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
          cmd[cmdpos] = '\0';
          putchar('\r');
          for (count = 0; count < cmdpos + 1; count++)
          {
            putchar(' ');
          }
          putchar('\r');
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
      putchar(key);
    }
  }
  return 0;
}