#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <terminal.c>
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

unsigned char buffer[8500];

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

void loadEspConfig(void)
{
  unsigned char curParam[256];
  unsigned char res;
  FILE *espcom;
  OS_SETSYSDRV();
  OS_CHDIR("browser");
  espcom = OS_OPENHANDLE("espcom.ini", 0x80);
  if (((int)espcom) & 0xff)
  {
    printf("mrfesp.ini opening error\r\n");
    return;
  }

  OS_READHANDLE(curParam, espcom, 256);
  
  res = sscanf(curParam, "%x %x %x %x %x %x %x %x %u %u %u", &RBR_THR, &IER, &IIR_FCR, &LCR, &MCR, &LSR, &MSR, &SR, &divider, &comType, &espType);

  if (comType == 1)
  {
    puts("     Controller base port: 0x55fe");
  }
  else
  {
    printf("     RBR_THR:0x%4x\r\n     IER    :0x%4x\r\n     IIR_FCR:0x%4x\r\n     LCR    :0x%4x\r\n", RBR_THR, IER, IIR_FCR, LCR);
    printf("     MCR    :0x%4x\r\n     LSR    :0x%4x\r\n     MSR    :0x%4x\r\n     SR     :0x%4x\r\n", MCR, LSR, MSR, SR);
  }
  printf("     DIVIDER:%u  ESP:%u  TYPE:%u", divider, espType, comType);

  switch (comType)
  {
  case 0:
    puts("(16550 like w/o AFC)");
    break;
  case 1:
    puts("(ATM Turbo 2+)");
    break;
  case 2:
    puts("(16550 like with AFC)");
  default:
    puts("(Unknown type)");
    break;
  }
}

void uart_init(unsigned char divisor)
{
  switch (comType)
  {
  case 0:
  case 2:
    output(MCR, 0x00);        // Disable input
    output(IIR_FCR, 0x87);    // Enable fifo 8 level, and clear it
    output(LCR, 0x83);        // 8n1, DLAB=1
    output(RBR_THR, divisor); // 115200 (divider 1-115200, 3 - 38400)
    output(IER, 0x00);        // (divider 0). Divider is 16 bit, so we get (#0002 divider)
    output(LCR, 0x03);        // 8n1, DLAB=0
    output(IER, 0x00);        // Disable int
    output(MCR, 0x2f);        // Enable AFE
    break;
  case 1:
    disable_interrupt();
    input(0x55fe);
    input(0xc3fe);
    input((divisor << 8) | 0x00fe);
    enable_interrupt();
    break;
  }
}

void uart_write(unsigned char data)
{
  unsigned char status;
  switch (comType)
  {
  case 0:
  case 2:
    while ((input(LSR) & 64) == 0)
    {
    }
    output(RBR_THR, data);
    break;
  case 1:
    disable_interrupt();
    do
    {
      input(0x55fe);          // Переход в режим команд
      status = input(0x42fe); // Команда прочесть статус
    } while ((status & 64) == 0); // Проверяем 6 бит

    input(0x55fe);               // Переход в режим команд
    input(0x03fe);               // Команда записать в порт
    input((data << 8) | 0x00fe); // Записываем data в порт
    enable_interrupt();
    break;
  }
}

void uart_setrts(unsigned char mode)
{
  switch (comType)
  {
  case 0:
    switch (mode)
    {
    case 1:
      output(MCR, 2);
      break;
    case 0:
      output(MCR, 0);
      break;
    default:
      disable_interrupt();
      output(MCR, 2);
      output(MCR, 0);
      enable_interrupt();
      break;
    }
  case 1:
    switch (mode)
    {
    case 1:
      disable_interrupt();
      input(0x55fe); // Переход в режим команд
      input(0x43fe); // Команда установить статус
      input(0x03fe); // Устанавливаем готовность DTR и RTS
      enable_interrupt();
      break;
    case 0:
      disable_interrupt();
      input(0x55fe); // Переход в режим команд
      input(0x43fe); // Команда установить статус
      input(0x00fe); // Снимаем готовность DTR и RTS
      enable_interrupt();
      break;
    default:
      disable_interrupt();
      input(0x55fe); // Переход в режим команд
      input(0x43fe); // Команда установить статус
      input(0x03fe); // Устанавливаем готовность DTR и RTS
      input(0x55fe); // Переход в режим команд
      input(0x43fe); // Команда установить статус
      input(0x00fe); // Снимаем готовность DTR и RTS
      enable_interrupt();
      break;
    }
  case 2:
    break;
  }
}
unsigned char uart_hasByte(void)
{
  unsigned char queue;
  switch (comType)
  {
  case 0:
  case 2:
    return (1 & input(LSR));
  case 1:
    disable_interrupt();
    input(0x55fe);         // Переход в режим команд
    queue = input(0xc2fe); // Получаем количество байт в приемном буфере
    enable_interrupt();
    return queue;
  }
  return 255;
}

unsigned char uart_readBlock(void)
{
  unsigned char data;
  switch (comType)
  {
  case 0:
    while (uart_hasByte() == 0)
    {
      uart_setrts(2);
    }
    return input(RBR_THR);
  case 1:
    while (uart_hasByte == 0)
    {
      uart_setrts(2);
    }
    disable_interrupt();
    input(0x55fe);        // Переход в режим команд
    data = input(0x02fe); // Команда прочесть из порта
    enable_interrupt();
    return data;
  case 2:
    while (uart_hasByte() == 0)
    {
    }
    return input(RBR_THR);
  }
  return 255;
}

unsigned char uart_read(void)
{
  unsigned char data;
  switch (comType)
  {
  case 0:
  case 2:
    return input(RBR_THR);
  case 1:
    disable_interrupt();
    input(0x55fe);        // Переход в режим команд
    data = input(0x02fe); // Команда прочесть из порта
    enable_interrupt();
    return data;
  }
  return 255;
}

void getdata(void)
{
  uart_setrts(2);
  while (uart_hasByte() != 0)
  {
    buffer[bufferPos] = uart_read();
    bufferPos++;
    uart_setrts(2);
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

void sendcommand(char *commandline)
{
  unsigned int count, cmdLen;
  cmdLen = strlen(commandline);
  for (count = 0; count < cmdLen; count++)
  {
    uart_write(commandline[count]);
  }
  uart_write('\r');
  uart_write('\n');
  // printf("Sended:[%s] \r\n", commandline);
  YIELD();
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

void testQueue(void)
{
  sendcommand("AT+CIPMUX=0");

  sendcommand("AT+CIPSERVER=0");
  sendcommand("AT+CIPDINFO=0");
  sendcommand("AT+CIPRECVMODE=1");
  sendcommand("AT+CIPSTART=\"TCP\",\"ti6.nedopc.com\",80");
  delay(1000);
  sendcommand("AT+CIPSEND=132");
  sendcommand("GET /attachments/pages/your_game6_160.png HTTP/1.1\r\nHost: ti6.nedopc.com\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n");
  delay(1000);
  sendcommand("AT+CIPRECVDATA=5000");
}
C_task main(void)
{
  unsigned char cmd[512];
  unsigned char cmdpos;
  os_initstdio();
  BOX(1, 1, 80, 25, 40);
  AT(25, 1);
  ATRIB(92);
  puts("[UART COMMUNICATION PROGRAMM]");
  loadEspConfig();

  uart_init(divider);
  printf("\r\nUart inited. Divider (%u)\r\n", divider);
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
        // sendcommand("AT+CIUPDATE");
        sendcommand("AT+CIPSNTPTIME?");
        delay(1000);
        sendcommand("AT+CIPSNTPCFG=1,300,\"0.pool.ntp.org\",\"time.google.com\"");
        delay(1000);
        sendcommand("AT+CIPSNTPTIME?");
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
