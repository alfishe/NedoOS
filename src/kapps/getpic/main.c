#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <tcp.h>
#include <graphic.h>
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

unsigned char picture[16384];
unsigned char netbuf[8000];

struct fileStruct
{
  long picId;
  unsigned int picYear;
  unsigned long totalAmount;
  unsigned char picRating[8];
  unsigned char picName[256];
  unsigned char picType[64];
  unsigned char authorIds[64];
  unsigned char authorTitle[64];
  unsigned char authorRealName[64];
  unsigned char afn[128];
  unsigned char pfn[128];
  unsigned char fileName[128];
} curFileStruct;

struct sockaddr_in dnsaddress;
struct sockaddr_in targetadr;
struct readstructure readStruct;

unsigned char ver[] = "3.0";
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

void emptyKeys(void)
{
  unsigned char loop, key;
  do
  {
    key = _low_level_get();
    if (loop > 64)
    {
      break;
    }
    loop++;
  } while (key != 0);
}

void printHelp(void)
{
  ATRIB(95);
  printf("   GETPIC [%s] zxart.ee picture viewer for nedoNET\n\r", ver);
  ATRIB(33);
  ATRIB(40);
  printf("-------------------------------------------------------\n\r");
  printf(" Управление:\n\r");
  printf(" 'ESC' - выход из программы;\n\r");
  printf(" '<-' или 'B' к последним картинкам;\n\r");
  printf(" '->' или 'Пробел' к более старым картинкам\n\r");
  printf(" 'J' Прыжок на  указанную по счету картинку\n\r");
  printf(" 'I' Просмотр экрана информации о картинках\n\r");
  printf(" 'S' Сохранить картинку на диск в текущую папку\n\r");
  printf(" 'V' не выводить информацию об авторах\n\r");
  printf(" 'R' переход в режим  случайная картинка с рейтингом 4+\n\r");
  printf(" 'A' переход в режим  слайд-шоу\n\r");
  printf(" 'D' Переключение режима ZXNETUSB/ESP-AT\n\r");
  printf(" 'H' Данная справочная информация\n\r");
  printf("-----------------Нажмите любую кнопку------------------\n\r");
  ATRIB(93);
  keypress = getchar();
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

unsigned int httpError(void)
{
  unsigned char *httpRes;
  unsigned int httpErr;
  httpRes = strstr(netbuf, "HTTP/1.1 ");

  if (httpRes != NULL)
  {
    httpErr = atol(httpRes + 9);
  }
  else
  {
    httpErr = 0;
  }
  return httpErr;
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
  unsigned int todo, retry = 10;

  while (retry != 0)
  {
    todo = OS_NETCONNECT(socket, &targetadr);

    if (todo > 32767)
    {
      retry--;
      printf("OS_NETCONNECT [ERROR:");
      errorPrint(todo & 255);
      printf("] [Retry:%u] [Pic:%lu]\r\n", retry, count);
      YIELD();
      netShutDown(socket, 0);
      puts("before socket");
      socket = OpenSock(AF_INET, SOCK_STREAM);
      puts("after socket");
    }
    else
    {
      // printf("OS_NETCONNECT: connection successful, %u\n\r", (todo & 255));
      return 1;
    }
  }
  puts("try to exit");
  getchar();
  exit(0);
  return 0;
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
unsigned int cutHeader(unsigned int todo)
{
  unsigned int err;
  unsigned char *count1;

  err = httpError();
  if (err != 200)
  {
    printf("\r\nHTTP response:[%u]\r\n", err);
    printf("^^^^^^^^^^^^^^^^^^^^^\r\n");
    puts(netbuf);
    getchar();
  }
  count1 = strstr(netbuf, "Content-Length:");
  if (count1 == NULL)
  {
    printf("contLen  not found \r\n");
    contLen = 0;
  }
  else
  {
    contLen = atol(count1 + 15);
    // printf("Content-Length: %lu \n\r", contLen);
  }

  count1 = strstr(netbuf, "\r\n\r\n");
  if (count1 == NULL)
  {
    printf("header not found\r\n");
  }
  else
  {
    headlng = ((unsigned int)count1 - (unsigned int)netbuf + 4);
    // printf("header %u bytes\r\n", headlng);
  }
  return todo - headlng;
}

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
unsigned char getPicEsp(unsigned long fileId)
{
  netbuf[0] = 0;
  sprintf(buffer, "%lu", fileId);
  strcat(netbuf, "GET /file/id:");
  strcat(netbuf, buffer);
  strcat(netbuf, " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0");
  fillPictureEsp();
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

char *str_replace(char *dst, int num, const char *str,
                  const char *orig, const char *rep)
{
  const char *ptr;
  size_t len1 = strlen(orig);
  size_t len2 = strlen(rep);
  char *tmp = dst;

  num -= 1;
  while ((ptr = strstr(str, orig)) != NULL)
  {
    num -= (ptr - str) + len2;
    if (num < 1)
      break;

    strncpy(dst, str, (size_t)(ptr - str));
    dst += ptr - str;
    strncpy(dst, rep, len2);
    dst += len2;
    str = ptr + len1;
  }

  for (; (*dst = *str) && (num > 0); --num)
  {
    ++dst;
    ++str;
  }
  return tmp;
}

void fillPicture(signed char socket)
{
  unsigned int todo, w, pPos, headskip;
  headskip = 0;
  pPos = 0;
  while (42)
  {
    headlng = 0;
    todo = tcpRead(socket);
    if (todo == 0)
    {
      break;
    }
    if (headskip == 0)
    {
      headskip = 1;
      todo = cutHeader(todo);
    }

    if (pPos + todo > sizeof(picture))
    {
      printf("dataBuffer overrun... %u reached \n\r", pPos + todo);
      break;
    }
    for (w = 0; w < todo; w++)
    {
      picture[w + pPos] = netbuf[w + headlng];
    }

    pPos = pPos + todo;
    if (pPos == contLen)
    {
      break;
    }
  }
  netShutDown(socket, 0);
}
void nameRepair(unsigned char *pfn, unsigned int tfnSize)
{

  str_replace(pfn, tfnSize, pfn, "\\", "_");
  str_replace(pfn, tfnSize, pfn, "/", "_");
  str_replace(pfn, tfnSize, pfn, ":", "_");
  str_replace(pfn, tfnSize, pfn, "*", "_");
  str_replace(pfn, tfnSize, pfn, "?", "_");
  str_replace(pfn, tfnSize, pfn, "<", "_");
  str_replace(pfn, tfnSize, pfn, ">", "_");
  str_replace(pfn, tfnSize, pfn, "|", "_");
  str_replace(pfn, tfnSize, pfn, " ", "_");
  str_replace(pfn, tfnSize, pfn, "&#039;", "'");
  str_replace(pfn, tfnSize, pfn, "&amp;", "&");
  str_replace(pfn, tfnSize, pfn, "&quot;", "'");
  str_replace(pfn, tfnSize, pfn, "&gt;", ")");
  str_replace(pfn, tfnSize, pfn, "&lt;", "(");
  str_replace(pfn, tfnSize, pfn, "\"", "'");
}

void stringRepair(unsigned char *pfn, unsigned int tSize)
{
  str_replace(pfn, tSize, pfn, "&#039;", "'");
  str_replace(pfn, tSize, pfn, "&amp;", "&");
  str_replace(pfn, tSize, pfn, "&gt;", ">");
  str_replace(pfn, tSize, pfn, "&lt;", "<");
  str_replace(pfn, tSize, pfn, "&quot;", "\"");
  str_replace(pfn, tSize, pfn, "\\/", "/");
}

unsigned char getPic(unsigned long fileId)
{
  unsigned int todo;
  signed char socket;
  socket = OpenSock(AF_INET, SOCK_STREAM);
  todo = netConnect(socket);
  sprintf(buffer, "%lu", fileId);
  strcpy(netbuf, "GET /file/id:");
  strcat(netbuf, buffer);
  strcat(netbuf, " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0");
  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
  fillPicture(socket);
  return 0;
}

void ncReplace(void)
{
  unsigned char len;
  for (len = 0; len < strlen(curFileStruct.afn); len++)
  {
    if ((curFileStruct.afn[len] < ' ') || (curFileStruct.afn[len] > 0xef) || (curFileStruct.afn[len] > 0x7e && curFileStruct.afn[len] < 0xb0))
    {
      curFileStruct.afn[len] = '_';
    }
  }

  for (len = 0; len < strlen(curFileStruct.pfn); len++)
  {
    if ((curFileStruct.pfn[len] < ' ') || (curFileStruct.pfn[len] > 0xef) || (curFileStruct.pfn[len] > 0x7e && curFileStruct.pfn[len] < 0xb0))
    {
      curFileStruct.pfn[len] = '_';
    }
  }
}

unsigned char savePic(unsigned long fileId)
{
  FILE *fp2;
  unsigned char afnSize, tfnSize;

  afnSize = sizeof(curFileStruct.afn) - 1;
  tfnSize = sizeof(curFileStruct.pfn) - 1;

  strcpy(curFileStruct.afn, curFileStruct.authorTitle);
  nameRepair(curFileStruct.afn, afnSize);

  strcpy(curFileStruct.pfn, curFileStruct.picName);
  nameRepair(curFileStruct.pfn, tfnSize);
  ncReplace();

  sprintf(curFileStruct.fileName, "%s-%s-%ld.scr", curFileStruct.afn, curFileStruct.pfn, fileId);
  if (strlen(curFileStruct.fileName) > 62)
  {
    sprintf(fileIdChar, "-%ld", fileId);
    str_replace(curFileStruct.fileName, sizeof(curFileStruct.fileName) - 1, curFileStruct.fileName, fileIdChar, "");
    curFileStruct.fileName[50] = '\0';
    strcat(curFileStruct.fileName, fileIdChar);
    strcat(curFileStruct.fileName, ".scr");
  }
  OS_SETSYSDRV();
  OS_MKDIR("../downloads");        // Create if not exist
  OS_MKDIR("../downloads/getpic"); // Create if not exist
  OS_CHDIR("../downloads/getpic");
  fp2 = OS_CREATEHANDLE(curFileStruct.fileName, 0x80);
  if (((int)fp2) & 0xff)
  {
    printf("%s creating error\r\n", curFileStruct.fileName);
    getchar();
    exit(0);
  }
  OS_WRITEHANDLE(picture, fp2, 6912);
  OS_CLOSEHANDLE(fp2);
  return 0;
}

int pos(unsigned char *s, unsigned char *c, unsigned int n, unsigned int startPos)
{
  unsigned int i, j;
  unsigned int lenC, lenS;

  for (lenC = 0; c[lenC]; lenC++)
    ;
  for (lenS = 0; s[lenS]; lenS++)
    ;

  for (i = startPos; i <= lenS - lenC; i++)
  {
    for (j = 0; s[i + j] == c[j]; j++)
      ;

    if (j - lenC == 1 && i == lenS - lenC && !(n - 1))
      return i;
    if (j == lenC)
      if (n - 1)
        n--;
      else
        return i;
  }
  return -1;
}

const char *parseJson(unsigned char *property)
{
  unsigned int w, lng, lngp1, findEnd, listPos;
  unsigned char terminator;
  int n;
  n = -1;
  // netbuf[0] = '\0';
  n = pos(picture, property, 1, 0);
  if (n == -1)
  {
    strcpy(netbuf, "-");
    // printf("Property %s not found", property);
    return netbuf;
  }
  lng = n - 1 + strlen(property);
  if (picture[lng] == ':')
  {
    terminator = '\0';
  }
  if (picture[lng] == '\"')
  {
    terminator = '\"';
  }
  if (picture[lng] == '[')
  {
    terminator = ']';
  }

  findEnd = 1;
  lngp1 = lng + 1;

  while (42)
  {

    if ((picture[lngp1 + findEnd] == ','))
    {
      if (terminator == '\0')
      {
        break;
      }
      if ((picture[lng + findEnd] == terminator))
      {
        findEnd--;
        break;
      }
    }
    findEnd++;
  }
  listPos = 0;
  for (w = lngp1; w < findEnd + lngp1; w++)
  {
    netbuf[listPos] = picture[w];
    listPos++;
  }
  netbuf[listPos] = '\0';
  return netbuf;
}
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

long processJson(unsigned long startPos, unsigned char limit, unsigned char queryNum)
{
  unsigned int retry, tSize;
  unsigned int todo;
  unsigned char *count1, socket;
  switch (queryNum)
  {
  case 0:
    strcpy(netbuf, "GET /api/export:zxPicture/filter:zxPictureType=standard/limit:");
    sprintf(buffer, "%u", limit);
    strcat(netbuf, buffer);
    strcat(netbuf, "/start:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, "/order:date,desc");
    strcat(netbuf, userAgent);
    break;
  case 1:
    strcpy(netbuf, "GET /api/types:zxPicture/export:zxPicture/language:eng/start:0/limit:1/order:rand/filter:zxPictureMinRating=4;zxPictureType=standard");
    strcat(netbuf, userAgent);
    break;

  case 3: // /api/export:author/filter:authorId=2202
    strcpy(netbuf, "GET /api/export:author/filter:authorId=");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, userAgent);
    break;

  case 99: // GET /jsonElementData/elementId:182798
    strcpy(netbuf, "GET /jsonElementData/elementId:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, userAgent);
    break;
  }
  retry = 10;
  while (42)
  {
    if (netDriver == 0)
    {
      socket = OpenSock(AF_INET, SOCK_STREAM);
      netConnect(socket);
      todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
      fillPicture(socket);
    }
    else
    {
      fillPictureEsp();
    }
    count1 = strstr(picture, "responseStatus\":\"success");
    if (count1 == NULL)
    {
      retry--;
      ATRIB(91);
      printf("PROCESS JSON: [ERROR: Bad responseStatus.] [Query:%u][Retry:%u] [Pic:%lu]\r\n", queryNum, retry, startPos);
      YIELD();
      puts(netbuf);
      getchar();
      if (retry < 1)
      {
        return -1;
      }
    }
    else
    {
      break;
    }
  }

  count1 = strstr(picture, "\"id\":");
  if (count1 == NULL)
  {
    ATRIB(91);
    printf("PROCESS JSON: [ERROR: ID not found.] [Query:%u][Pic:%lu]\r\n", queryNum, startPos);
    YIELD();
    return -2;
  }

  netbuf[0] = 0;
  if (queryNum < 3)
  {
    parseJson("\"id\":");
    curFileStruct.picId = atol(netbuf);
    parseJson(",\"title\":\"");
    convert866();
    strcpy(curFileStruct.picName, netbuf);

    tSize = sizeof(curFileStruct.picName);
    stringRepair(curFileStruct.picName, tSize);

    parseJson(",\"type\":\"");
    strcpy(curFileStruct.picType, netbuf);
    parseJson("\"rating\":\"");
    strcpy(curFileStruct.picRating, netbuf);
    parseJson("\"year\":\"");
    curFileStruct.picYear = atoi(netbuf);
    parseJson("\"totalAmount\":");
    curFileStruct.totalAmount = atol(netbuf);
    parseJson("\"authorIds\":[");
    strcpy(curFileStruct.authorIds, netbuf);
  }
  if (queryNum == 99)
  {
    parseJson(",\"title\":\"");
    convert866();
    strcpy(curFileStruct.authorTitle, netbuf);
    parseJson(",\"realName\":\"");
    convert866();
    strcpy(curFileStruct.authorRealName, netbuf);
  }
  return curFileStruct.picId;
}

void printData(void)
{
  ATRIB(93);
  printf(" #: ");
  ATRIB(97);
  printf("%lu", count);
  ATRIB(93);
  printf(" ID: ");
  ATRIB(97);
  printf("%lu ", curFileStruct.picId);
  ATRIB(93);
  printf(" Total Pics: ");
  ATRIB(97);
  printf("%lu\r\n", curFileStruct.totalAmount);
  ATRIB(93);
  printf(" Author: ");
  ATRIB(96);
  printf("%s\r\n", curFileStruct.authorTitle);
  ATRIB(93);
  printf(" TITLE: ");
  ATRIB(95);
  printf("%s\r\n", curFileStruct.picName);
  ATRIB(93);
  printf(" RATING: ");
  ATRIB(97);
  printf("%s", curFileStruct.picRating);
  ATRIB(93);
  printf(" YEAR: ");
  ATRIB(97);
  printf("%u\r\n", curFileStruct.picYear);
  ATRIB(93);
  printf(" AuthorsIDs ");
  ATRIB(97);
  printf("%s", curFileStruct.authorIds);
  ATRIB(93);
  printf(" Real name: ");
  ATRIB(97);
  printf("%s\r\n", curFileStruct.authorRealName);
  ATRIB(96);
  printf("\r\n");
  // YIELD();
}
void safeKeys(unsigned char keypress)
{
  if (keypress == 27)
  {
    printf("Good bye...\r\n");
    ATRIB(37);
    ATRIB(40);
    exit(0);
  }

  if (keypress == 'j' || keypress == 'J')
  {
    printf("Jump to picture:");
    scanf("%lu", &count);
    if (count > curFileStruct.totalAmount - 1)
    {
      count = curFileStruct.totalAmount - 1;
    }
  }

  if (keypress == 'v' || keypress == 'V')
  {
    verbose = !verbose;

    if (verbose == 0)
    {
      BOX(1, 1, 80, 25, 40);
      AT(1, 1);
    }
  }

  if (keypress == 'h' || keypress == 'H')
  {
    printHelp();
  }

  if (keypress == 'r' || keypress == 'R')
  {
    randomPic = !randomPic;

    if (verbose == 1)
    {
      if (randomPic == 1)
      {
        printf("    Random mode enabled...\r\n");
      }
      else
      {
        printf("    Sequental mode enabled...\r\n");
      }
    }
  }
  if (keypress == 'a' || keypress == 'A')
  {
    slideShow = !slideShow;
    if (slideShow == 1)
    {
      if (verbose == 1)
        printf("    SlideShow mode enabled...\r\n\r\n");
      slideShowTime = 250;
    }
    else
    {
      if (verbose == 1)
        printf("    Manual mode enabled...\r\n\r\n");
      slideShowTime = 0;
    }
  }

  if (keypress == 'd' || keypress == 'D')
  {
    netDriver = !netDriver;
    if (netDriver == 1)
    {
      printf("    ESP-AT mode enabled...\r\n");
      loadEspConfig();
      uart_init(divider);
      espReBoot();
      printf("    ESP-AT inited...\r\n");
    }

    else
    {
      if (verbose == 1)
        printf("    ZXNETUSB mode enabled...\r\n\r\n");
    }
  }
}
void dnsResolve(void)
{
  unsigned char socket, retry, retryInv;
  unsigned int todo, queryPos, queryType, queryLng;
  // unsigned int loop;
  unsigned char dnsQuery[] = {
      0x11, 0x22, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x05, 0x7a, 0x78, 0x61, 0x72, 0x74, 0x02, 0x65, 0x65, 0x00,
      0x00, 0x01, 0x00, 0x01};

  socket = OpenSock(AF_INET, SOCK_DGRAM);
  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&dnsQuery;
  readStruct.bufsize = (unsigned int)sizeof(dnsQuery);
  readStruct.protocol = SOCK_DGRAM;

  targetadr.family = AF_INET;
  targetadr.porth = 00;
  targetadr.portl = 80;
  targetadr.b1 = 217; // D9
  targetadr.b2 = 146; // 92
  targetadr.b3 = 69;  // 45
  targetadr.b4 = 13;  // 0D

  todo = OS_WIZNETWRITE_UDP(&readStruct, &dnsaddress);
  if (todo > 32767)
  {
    errorPrint(todo & 255);
    puts("Error quering DNS server[Query], using address:217.146.69.13");
    return;
  }
  else
  {
    // printf("OS_WIZNETWRITE_UDP: %u bytes written. \n\r", todo);
  }

  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = (unsigned int)sizeof(netbuf);
  retry = 20;
  retryInv = retry;

  do
  {
    todo = OS_WIZNETREAD_UDP(&readStruct, &dnsaddress);
    if (todo > 32767)
    {
      //errorPrint(todo & 255);
      if (retry == 0)
      {
        puts(" Error quering[Response] DNS server, using address:217.146.69.13");
        return;
      }
      retry--;
      delayLong(200);
      //printf(" Retry [%d]\r\n", retryInv - retry);
    }
    else
    {
      // printf("OS_WIZNETREAD_UDP: %u bytes read. \n\r", todo);
      break;
    }
  } while (todo > 32767);

  netShutDown(socket, 0);
  /*
    puts("--------------------------ANSWER-----------------------------");

    for (loop = 0; loop < todo; loop++)
    {
      printf("%02X ", (int)netbuf[loop]);
      if ((loop + 1) % 16 == 0)
      {
        printf("\r\n");
      }
    }
    puts("\r\n--------------------------ANSWER-----------------------------");
  */

  if (!(netbuf[2] && 0x0f))
  {
    puts("Error quering[Parsing] DNS server, using address:217.146.69.13");
    return;
  }

  queryPos = 11;
  queryLng = 0;
  do
  {
    queryPos++;
  } while (netbuf[queryPos] != 0);

  queryPos = queryPos + 7; // Skip to answer data
  do
  {
    if (queryPos > sizeof(netbuf) - 11)
    {
      puts("Error quering DNS server[Buffer overrun], using address: 217.146.69.13");
      return;
    }
    queryType = netbuf[queryPos] * 256 + netbuf[queryPos + 1];
    // printf("Query type (0x0001): %d\r\n", queryType);

    queryPos = queryPos + 8; // Skip to answer lenght

    queryLng = netbuf[queryPos] * 256 + netbuf[queryPos + 1];
    // printf("Query data lenght: %d\r\n", queryLng);
    queryPos = queryPos + queryLng + 4;
  } while (queryType != 1);

  targetadr.b1 = netbuf[queryPos - 6];
  targetadr.b2 = netbuf[queryPos - 5];
  targetadr.b3 = netbuf[queryPos - 4];
  targetadr.b4 = netbuf[queryPos - 3];

  printf("Address:%u.%u.%u.%u:80\r\n", targetadr.b1, targetadr.b2, targetadr.b3, targetadr.b4);
}

void get_dns(void)
{
  unsigned char ipaddress[4];
  OS_GETDNS(ipaddress);
  dnsaddress.family = AF_INET;
  dnsaddress.porth = 00;
  dnsaddress.portl = 53;
  dnsaddress.b1 = ipaddress[0];
  dnsaddress.b2 = ipaddress[1];
  dnsaddress.b3 = ipaddress[2];
  dnsaddress.b4 = ipaddress[3];
}

C_task main(void)
{
  unsigned char errno;
  long iddqd, idkfa;

  os_initstdio();

  count = 0;
  verbose = 1;
  randomPic = 0;
  slideShow = 0;
  netDriver = 0;

  BOX(1, 1, 80, 25, 40);
  AT(1, 1);
  printHelp();
  safeKeys(keypress);

  if (netDriver == 0)
  {
    get_dns();
    dnsResolve();
  }

start:
  keypress = 0;
  switch (randomPic)
  {
  case 0:

    iddqd = processJson(count, 1, 0);
    break;
  case 1:
    iddqd = processJson(0, 1, 1);
    break;
  }

  if (iddqd < 0)
  {
    count++;
    goto start;
  }

  if (verbose == 1)
  {
    idkfa = processJson(atol(curFileStruct.authorIds), 0, 99);
    if (idkfa < 0)
    {
      printf(" Cant parse curFileStruct.authorIds = %s \r\n\r\n", curFileStruct.authorIds);
      count++;
      goto start;
    }

    printData();
  }
  else
  {
    // ATRIB(97);
    // printf(" Getting picture...\r\n");
  }

  if (strcmp(curFileStruct.picType, "standard") != 0)
  {
    printf("  >>Format '%s' not supported, skipped \n\r", curFileStruct.picType);
    count++;
    goto start;
  }

  if (netDriver == 0)
  {
    errno = getPic(iddqd);
  }
  else
  {
    errno = getPicEsp(iddqd);
  }

review:
  keypress = viewScreen6912((unsigned int)&picture, slideShowTime);
  emptyKeys();

  ///// Keys only for pictures
  if (keypress == 's' || keypress == 'S')
  {
    savePic(iddqd);
    if (verbose == 1)
      printf("        ID:%lu    TITLE:%s  SAVED\r\n\r\n", curFileStruct.picId, curFileStruct.picName);
    count++;
  }

  if (keypress == 248 || keypress == 'b' || keypress == 'B')
  {
    if (count > 0)
    {
      count--;
    }
  }
  if (keypress == 251 || keypress == 32)
  {
    count++;
    goto start;
  }
  if (keypress == 'i' || keypress == 'I')
  {
    delay(100);
    getchar();
    goto review;
  }
  safeKeys(keypress);
  goto start;
}
