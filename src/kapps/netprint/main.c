#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <tcp.h>
#include <terminal.c>


FILE *fp1;

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

unsigned char netbuf[1024];
unsigned char tempbuf[128];

unsigned char ver[] = "0.2";
const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char buffer[] = "0000000000";
unsigned char userAgent[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; GetPic)\r\n\r\n\0";
unsigned char zxart[] = "zxart.ee";
unsigned char keypress, verbose, randomPic, slideShow, netDriver;

unsigned long contLen;
unsigned long count = 0;
unsigned int headlng;
unsigned int slideShowTime = 0;
unsigned int loaded;

unsigned char crlf[2] = {13, 10};
unsigned char cmd[512];
unsigned char link[512];
unsigned char fileIdChar[10];

struct sockaddr_in targetadr;
struct readstructure readStruct;
struct packetStruct
{
  unsigned long contLen;
  unsigned int headlng;
} pack;

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

void errorPrint(unsigned int error)
{
  switch (error)
  {
  case 2:
    printf("02 SHUT_RDWR");
    break;
  case 4:
    printf("04 ERR_INTR");
    break;
  case 23:
    printf("23 ERR_NFILE");
    break;
  case 35:
    printf("35 ERR_EAGAIN");
    break;
  case 37:
    printf("37 ERR_ALREADY");
    break;
  case 38:
    printf("38 ERR_NOTSOCK");
    break;
  case 40:
    printf("40 ERR_EMSGSIZE");
    break;
  case 41:
    printf("41 ERR_PROTOTYPE");
    break;
  case 47:
    printf("47 ERR_AFNOSUPPORT");
    break;
  case 53:
    printf("53 ERR_ECONNABORTED");
    break;
  case 54:
    printf("54 ERR_CONNRESET");
    break;
  case 57:
    printf("57 ERR_NOTCONN");
    break;
  case 65:
    printf("65 ERR_HOSTUNREACH");
    break;
  default:
    printf("%u UNKNOWN ERROR", error);
    break;
  }
}

signed char OpenSock(unsigned char family, unsigned char protocol)
{
  signed char socket;
  unsigned int todo;
  todo = OS_NETSOCKET((family << 8) + protocol);
  if (todo > 32767)
  {
    printf("OS_NETSOCKET: [ERROR:");
    errorPrint(todo & 255);
    printf("] Press any key.");
    getchar();
    exit(0);
  }
  else
  {
    socket = ((todo & 65280) >> 8);
    // printf("OS_NETSOCKET: Socket #%d created\n\r", socket);
  }
  return socket;
}

signed char netShutDown(signed char socket, unsigned char type)
{
  unsigned int todo;
  todo = OS_NETSHUTDOWN(socket, type);
  if (todo > 32767)
  {
    printf("OS_NETSHUTDOWN: [ERROR:");
    errorPrint(todo & 255);
    return -1;
  }
  else
  {
    // printf("Socket #%d closed.\n\r", socket);
  }
  return 1;
}

unsigned char netConnect(signed char socket)
{
  unsigned int todo;

  todo = OS_NETCONNECT(socket, &targetadr);

  if (todo > 32767)
  {
    printf("OS_NETCONNECT ERROR:");
    errorPrint(todo & 255);
    puts("]");
    YIELD();
    netShutDown(socket, 0);
    exit(0);
  }
  else
  {
    //  puts("Connected to printer.");
  }
  return 1;
}

unsigned int tcpSend(signed char socket, unsigned int messageadr, unsigned int size)
{
  unsigned char retry = 10;
  unsigned int todo;
  readStruct.socket = socket;
  readStruct.BufAdr = messageadr;
  readStruct.bufsize = size;
  readStruct.protocol = SOCK_STREAM;
  while (retry > 0)
  {
    todo = OS_WIZNETWRITE(&readStruct);
    if (todo > 32767)
    {
      printf("OS_WIZNETWRITE: [ERROR:");
      errorPrint(todo & 255);
      printf("] [Retry:%u] [Pic:%lu]\r\n", retry, count);
      YIELD();
      retry--;
    }
    else
    {
      // printf("OS_WIZNETWRITE: %u bytes written. \n\r", todo);
      return todo;
    }
  }

  getchar();
  exit(0);
  return todo;
}

unsigned int tcpRead(signed char socket)
{
  unsigned char retry = 10;
  unsigned int todo;

  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = sizeof(netbuf);
  readStruct.protocol = SOCK_STREAM;

  while (retry > 0)
  {
    todo = OS_WIZNETREAD(&readStruct);

    if (todo > 32767)
    {
      if ((todo & 255) != ERR_EAGAIN)
      {
        printf("OS_WIZNETREAD: [ERROR:");
        errorPrint(todo & 255);
        printf("] [Retry:%u] [Pic:%lu]\r\n", retry, count);
        YIELD();
        retry--;
      }
    }
    else
    {
      // printf("OS_WIZNETREAD: %u bytes read. \n\r", todo);
      return todo;
    }
  }
  getchar();
  exit(0);
  return todo;
}
/*
////////////////////////ESP32 PROCEDURES//////////////////////
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
    while (uart_hasByte() == 0)
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

void uart_flush(void)
{
  unsigned int count;
  for (count = 0; count < 6000; count++)
  {
    disable_interrupt();
    uart_setrts(1);
    enable_interrupt();
    uart_read();
  }
  printf("\r\nBuffer cleared.\r\n");
}
void getdataEsp(unsigned int counted)
{
  unsigned int counter;
  for (counter = 0; counter < counted; counter++)
  {
    netbuf[counter] = uart_readBlock();
  }
  netbuf[counter] = 0;
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
}

unsigned char getAnswer2(void)
{
  unsigned char readbyte;
  unsigned int curPos = 0;
  do
  {
    readbyte = uart_readBlock();
    // putdec(readbyte);
  } while (((readbyte == 0x0a) || (readbyte == 0x0d)));

  netbuf[curPos] = readbyte;
  curPos++;
  do
  {
    readbyte = uart_readBlock();
    netbuf[curPos] = readbyte;
    curPos++;
  } while (readbyte != 0x0d);
  netbuf[curPos - 1] = 0;
  uart_readBlock(); // 0xa
  // printf("Answer:[%s]\r\n", netbuf);
  //   getchar();
  return curPos;
}

void espReBoot(void)
{
  unsigned char byte, count;
  uart_flush();
  sendcommand("AT+RST");
  printf("Resetting ESP...");
  count = 0;
  do
  {
    byte = uart_readBlock();
    if (byte == gotWiFi[count])
    {
      count++;
    }
    else
    {
      count = 0;
    }
  } while (count < strlen(gotWiFi));
  uart_readBlock(); // CR
  uart_readBlock(); // LF
  puts("Reset complete.");

  sendcommand("ATE0");
  do
  {
    byte = uart_readBlock();
  } while (byte != 'K'); // OK
  // puts("Answer:[OK]");
  uart_readBlock(); // CR
  uart_readBlock(); // LN

  sendcommand("AT+CIPCLOSE");
  getAnswer2();
  sendcommand("AT+CIPDINFO=0");
  getAnswer2();
  sendcommand("AT+CIPMUX=0");
  getAnswer2();
  sendcommand("AT+CIPSERVER=0");
  getAnswer2();
  sendcommand("AT+CIPRECVMODE=0");
  getAnswer2();
}
unsigned int recvHead(void)
{
  unsigned char byte, dataRead = 0;
  do
  {
    byte = uart_readBlock();
  } while (byte != ',');

  dataRead = 0;
  do
  {
    byte = uart_readBlock();
    netbuf[dataRead] = byte;
    dataRead++;
  } while (byte != ':');
  netbuf[dataRead] = 0;
  loaded = atoi(netbuf); // <actual_len>
  // printf("\r\n loaded %u\r\n", loaded);
  return loaded;
}

// in netbuf data to send
unsigned int fillPictureEsp(void)
{
  unsigned char sizeLink = 0;
  unsigned long downloaded = 0;
  unsigned char byte, count = 0, try = 0;
  unsigned int dataSize = 0;
  unsigned char skipHeader = 0;
  unsigned char *count1;

  strcpy(link, netbuf);
  sizeLink = strlen(link);
  try = 0;
  do
  {
    try++;
    if (try > 1)
    {
      printf("----->Retry:%u\r\n", try);
      delay(1000);
    }
    sendcommand("AT+CIPSTART=\"TCP\",\"zxart.ee\",80");
    getAnswer2(); // CONNECT or ERROR or link is not valid
    count1 = strstr(netbuf, "CONNECT");
  } while (count1 == NULL);

  getAnswer2(); // OK

  strcpy(cmd, "AT+CIPSEND=");
  sprintf(netbuf, "%u", sizeLink + 2); // second CRLF in send command

  strcat(cmd, netbuf);
  sendcommand(cmd);
  getAnswer2();
  do
  {
    byte = uart_readBlock();
    // putchar(byte);
  } while (byte != '>');
  sendcommand(link);

  count = 0;

  do
  {
    byte = uart_readBlock();
    if (byte == sendOk[count])
    {
      count++;
    }
    else
    {
      count = 0;
    }
  } while (count < strlen(sendOk));
  uart_readBlock(); // CR
  uart_readBlock(); // LF
  skipHeader = 0;
  downloaded = 0;
  do
  {
    headlng = 0;
    dataSize = recvHead();
    getdataEsp(dataSize); // Requested size
    if (skipHeader == 0)
    {
      dataSize = cutHeader(dataSize);
      skipHeader = 1;
    }
    downloaded = downloaded + dataSize;
    memcpy(picture + downloaded - dataSize, netbuf + headlng, dataSize);
  } while (downloaded < contLen);
  sendcommand("AT+CIPCLOSE");
  getAnswer2(); // CLOSED
  getAnswer2(); // OK
  return 0;
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
  puts("Config loaded:");
  if (comType == 1)
  {
    puts("     Controller base port: 0x55fe");
  }
  else
  {
    printf("     RBR_THR:0x%4x\r\n     IER    :0x%4x\r\n     IIR_FCR:0x%4x\r\n     LCR    :0x%4x\r\n", RBR_THR, IER, IIR_FCR, LCR);
    printf("     MCR    :0x%4x\r\n     LSR    :0x%4x\r\n     MSR    :0x%4x\r\n     SR     :0x%4x\r\n", MCR, LSR, MSR, SR);
  }
  printf("     DIVIDER:  %4u\r\n     TYPE   :  %4u\r\n     ESP    : %u\r\n", divider, comType, espType);

  switch (comType)
  {
  case 0:
    puts("     (16550 like w/o AFC)");
    break;
  case 1:
    puts("     (ATM Turbo 2+)");
    break;
  case 2:
    puts("     (16550 with AFC)");
  default:
    puts("     (Unknown type)");
    break;
  }
}

////////////////////////ESP32 PROCEDURES//////////////////////
*/
void convert866(void)
{
  unsigned int lng, targetPos, w, q = 0;
  unsigned char buffer[8], one, two;
  unsigned int decVal;
  lng = strlen(netbuf);
  targetPos = lng + 1;

  while (q < lng)
  {
    one = netbuf[q];
    two = netbuf[q + 1];
    if (one == 92 && two == 117)
    {
      q = q + 2;
      for (w = 0; w < 4; w++)
      {
        buffer[w] = netbuf[q + w];
      }
      q = q + 4;
      buffer[4] = '\0';
      decVal = (unsigned int)strtol(buffer, NULL, 16);

      if (decVal < 1088)
      {
        decVal = decVal - 912;
      }
      if (decVal > 1087)
      {
        decVal = decVal - 864;
      }
      if (decVal == 1025)
      {
        decVal = 240;
      }
      if (decVal == 1105)
      {
        decVal = 241;
      }

      netbuf[targetPos] = decVal;
    }
    else
    {
      netbuf[targetPos] = netbuf[q];
      q++;
    }
    targetPos++;
  }
  netbuf[targetPos] = 0;

  for (w = lng + 1; w < targetPos + 1; w++)
  {
    netbuf[w - lng - 1] = netbuf[w];
  }
}

void loadParm(void)
{
  FILE *params;
  unsigned char param[256];
  unsigned int ip16[5];
  unsigned int porthl;

  OS_GETPATH((unsigned int)&tempbuf);
  OS_SETSYSDRV();
  OS_CHDIR("../ini");
  params = OS_OPENHANDLE("netprint.ini", 0x80);
  if (((int)params) & 0xff)
  {
    printf("ini/netprint.ini opening error\r\n");
    exit(0);
  }

  OS_READHANDLE(param, params, 256);

  if (sscanf(param, "%d.%d.%d.%d:%d", ip16, ip16 + 1, ip16 + 2, ip16 + 3, ip16 + 4) == 5)
  {
    targetadr.b1 = ip16[0];
    targetadr.b2 = ip16[1];
    targetadr.b3 = ip16[2];
    targetadr.b4 = ip16[3];
    porthl = ip16[4];
    targetadr.porth = porthl >> 8;
    targetadr.portl = porthl;
  }
  else
  {
    printf("Wrong parameter\r\n");
    exit(0);
  }
  targetadr.family = AF_INET;
  ATRIB(97);
  printf("Printer afress: %d.%d.%d.%d:%d\r\n", targetadr.b1, targetadr.b2, targetadr.b3, targetadr.b4, porthl);
  ATRIB(37);

  OS_CLOSEHANDLE(params);
  OS_CHDIR(tempbuf);
}

C_task main(int argc, char *argv[])
{
  unsigned char socket;
  unsigned int todo;
  unsigned long progress = 0;

  os_initstdio();
  ATRIB(93);
  printf("Network RAW printing utillity version:%s\r\n", ver);
  ATRIB(37);

  if (argc < 2)
  {
    puts("Error: File name required.");
    exit(0);
  }

  loadParm();

  fp1 = OS_OPENHANDLE(argv[1], 0x80);

  if (((int)fp1) & 0xff)
  {
    printf("Error: %s opening error\r\n", argv[1]);
    exit(0);
  }

  socket = OpenSock(AF_INET, SOCK_STREAM);
  netConnect(socket);
  ATRIB(93);
  do
  {
    todo = OS_READHANDLE(netbuf, fp1, sizeof(netbuf));
    progress = progress + todo;
    printf("Bytes sended: %lu...     \r", progress);
    tcpSend(socket, (unsigned int)&netbuf, todo);
  } while (todo != 0 && errno == 0);

  ATRIB(37);
  ATRIB(40);

  OS_CLOSEHANDLE(fp1);
  netShutDown(socket, 0);
  printf("\r\n");
  exit(0);
}
