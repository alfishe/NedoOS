#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <ctype.h>
#include <tcp.h>
#include <graphic.h>
#include <terminal.c>
#define COMMANDLINE 0x0080

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

const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char buffer[] = "0000000000";
const unsigned char userAgent[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; Radio)\r\n\r\n\0";
const unsigned char cmdlist1[] = "GET /file/id:";
unsigned char userQuery[256] = "/api/export:zxMusic/limit:10/filter:zxMusicId=44816";
unsigned char fileName[] = "radio/player.ovl";
unsigned char appCmd[128] = "player.com ";
unsigned char curPath[128];

unsigned char ver[] = "2.3";

unsigned char queryType[64];
unsigned char netbuf[4096];
unsigned char dataBuffer[4096];
unsigned char crlf[2] = {13, 10};
unsigned char formats[4][4] = {"pt3", "pt2", "tfc", "ts"};
unsigned char interfaces[2][8] = {"nedoNET\0", "ESP-COM\0"};
unsigned char cmd[256];
unsigned char link[512];
unsigned char toLog[256];

unsigned char status, key, curFormat;
struct sockaddr_in targetadr;
struct readstructure readStruct;
unsigned long contLen;
long count;
unsigned char saveFlag, saveBak, logFlag, rptFlag, netDriver;
union APP_PAGES main_pg;
union APP_PAGES player_pg;
unsigned int loaded;
unsigned int headlng;
unsigned char cutOff = 1;
int remainTime;

struct fileStruct
{
  long picId;
  unsigned long fileSize;
  unsigned int picYear;
  unsigned long totalAmount;
  unsigned int curPos;
  unsigned int startBar;
  unsigned int trackInSeconds;
  unsigned char time[16];
  unsigned char picRating[8];
  unsigned char trackName[256];
  unsigned char fileName[256];
  unsigned char authorIds[64];
  unsigned char authorTitle[64];
  unsigned char authorRealName[64];
  unsigned char afn[64];
  unsigned char tfn[64];
  unsigned char fileName2[256];
} curFileStruct;

void writeLog(char *logline)
{
  FILE *LogFile;
  unsigned long fileSize;

  LogFile = OS_OPENHANDLE("m:/bin/radio/radio.log", 0x80);
  if (((int)LogFile) & 0xff)
  {
    LogFile = OS_CREATEHANDLE("m:/bin/radio/radio.log", 0x80);
    OS_CLOSEHANDLE(LogFile);
    LogFile = OS_OPENHANDLE("m:/bin/radio/radio.log", 0x80);
  }

  fileSize = OS_GETFILESIZE(LogFile);
  OS_SEEKHANDLE(LogFile, fileSize);
  OS_WRITEHANDLE(logline, LogFile, strlen(logline));
  OS_CLOSEHANDLE(LogFile);
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

void clearStatus(void)
{
  AT(1, 25);
  printf("                                                                               \r");
}

void printProgress(unsigned char type)
{
  unsigned char bar, minutes, seconds;
  unsigned char *position;
  long barLenght;
  int timer;
  switch (type)
  {
  case 0: // print empty bar
    AT(6, 11);
    ATRIB(93);
    printf("%02u:%02u", 0, 0);
    AT(15, 11);
    ATRIB(97);
    for (bar = 0; bar < 50; bar++)
    {
      putchar(176);
    }
    putchar(' ');
    putchar(' ');
    minutes = atoi(curFileStruct.time);
    position = (strstr(curFileStruct.time, ":")) + 1;
    seconds = atoi(position);
    curFileStruct.trackInSeconds = minutes * 60 + seconds;
    curFileStruct.curPos = 0;
    curFileStruct.startBar = 0;
    break;
  case 1: // print progress bar

    AT(6, 11);
    ATRIB(93);
    timer = floor(curFileStruct.curPos / 60);
    printf("%02u:%02u", timer, (curFileStruct.curPos - (timer * 60)));

    barLenght = (curFileStruct.curPos * 50 / curFileStruct.trackInSeconds);
    if (barLenght > 49)
    {
      barLenght = 50;
    }
    AT(15 + curFileStruct.startBar, 11);
    ATRIB(97);
    for (bar = 0; bar < barLenght - curFileStruct.startBar; bar++)
    {
      putchar(178);
    }
    AT(1, 1);
    curFileStruct.startBar = bar;
    break;
  case 2: // print full bar
    AT(15, 11);
    ATRIB(97);
    for (bar = 0; bar < 50; bar++)
    {
      putchar(178);
    }
    break;
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
  YIELD();
}

void printHelp(void)
{
  AT(1, 15);
  ATRIB(97);
  printf(" [<-] [B] Previous track          [->] [ ] Next track      \r\n");
  printf(" [S]  Stop player                 [R]  Repeat track mode   \r\n");
  printf(" [K]  Toggle saving tracks        [D]  Download track      \r\n");
  printf(" [Q]  Select Query type           [F]  Select tracks format\r\n");
  printf(" [I]  Interface ZXNETUSB/ESP32    [J]  Jump to NNNN file   \r\n");
  printf(" [L]  Toggle operation logging    [ESC] Exit to OS         \r\n");
  printf("                                                           \r\n");
}

unsigned char OpenSock(unsigned char family, unsigned char protocol)
{
  unsigned char socket;
  unsigned int todo;
  todo = OS_NETSOCKET((family << 8) + protocol);
  if (todo > 32767)
  {
    clearStatus();
    printf("OS_NETSOCKET: ");
    errorPrint(todo & 255);
    exit(0);
  }
  else
  {
    socket = ((todo & 65280) >> 8);
    if (logFlag)
    {
      clearStatus();
      printf("OS_NETSOCKET: Socket #%d created.", socket);
    }
  }
  return socket;
}

unsigned int netShutDown(unsigned char socket, unsigned char type)
{
  unsigned int todo;
  todo = OS_NETSHUTDOWN(socket, type);
  if (todo > 32767)
  {
    clearStatus();
    printf("OS_NETSHUTDOWN: ");
    errorPrint(todo & 255);
    return 255;
  }
  else
  {
    if (logFlag)
    {
      clearStatus();
      printf("OS_NETSHUTDOWN: Socket #%u closed.", socket);
    }
  }
  return 0;
}

unsigned char netConnect(unsigned char socket)
{
  unsigned int todo, retry = 10;

  targetadr.family = AF_INET;
  targetadr.porth = 00;
  targetadr.portl = 80;
  targetadr.b1 = 217;
  targetadr.b2 = 146;
  targetadr.b3 = 69;
  targetadr.b4 = 13;
  while (retry > 0)
  {
    todo = OS_NETCONNECT(socket, &targetadr);

    if (todo > 32767)
    {
      retry--;
      clearStatus();
      printf("OS_NETCONNECT [ERROR:");
      errorPrint(todo & 255);
      printf("] [Retry:%u]", retry);
      YIELD();
      netShutDown(socket, 0);
      socket = OpenSock(AF_INET, SOCK_STREAM);
    }
    else
    {
      if (logFlag)
      {
        clearStatus();
        printf("OS_NETCONNECT: connected , %u", (todo & 255));
      }
      return 1;
    }
  }
  getchar();
  exit(0);
  return 0;
}

unsigned int tcpRead(unsigned char socket)
{
  unsigned char retry = 20;
  unsigned int err, todo;
  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = sizeof(netbuf);
  readStruct.protocol = SOCK_STREAM;

wizread:
  todo = OS_WIZNETREAD(&readStruct);
  if (todo > 32767)
  {
    if (retry == 0)
    {
      err = todo & 255;
      clearStatus();
      printf("OS_WIZNETREAD: ");
      errorPrint(err);
      if (err == ERR_EAGAIN)
      {
        return 0;
      }
      exit(0);
    }
    retry--;
    if (logFlag)
    {
      AT(54, 25);
      printf("OS_WIZNETREAD: retry %u   ", retry);
    }
    delay(200);
    goto wizread;
  }
  if (logFlag)
  {
    clearStatus();
    printf("OS_WIZNETREAD: %u bytes read.", todo);
  }
  return todo;
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

unsigned int cutHeader(unsigned int todo)
{
  unsigned int q, headlng;
  unsigned char *count;
  count = strstr(netbuf, "Content-Length:");
  if (count == NULL)
  {
    clearStatus();
    printf("Content-Length:  not found.");
    contLen = 0;
  }
  else
  {
    contLen = atol(count + 15);
    curFileStruct.fileSize = contLen;
    //  printf("=> Dlinna  soderzhimogo = %lu \n\r", curFileStruct.fileSize);
  }

  count = strstr(netbuf, "\r\n\r\n");
  headlng = ((unsigned int)count - (unsigned int)netbuf + 4);
  q = todo - headlng;
  memcpy(&netbuf, count + 4, q);
  return q;
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
      output(MCR, 2);
      output(MCR, 0);
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
    uart_setrts(1);
    uart_read();
  }
  clearStatus();
  printf("Buffer cleared.");
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
  } while (((readbyte == 0x0a) || (readbyte == 0x0d)));
  netbuf[curPos] = readbyte;
  curPos = 1;
  do
  {
    readbyte = uart_readBlock();
    netbuf[curPos] = readbyte;
    curPos++;
  } while (readbyte != 0x0d);
  netbuf[curPos - 1] = 0;
  uart_readBlock(); // 0xa
  // printf("Answer:[%s]\r\n", netbuf);
  // getchar();
  return curPos;
}

void espReBoot(void)
{
  unsigned char byte, count;
  uart_flush();
  sendcommand("AT+RST");
  clearStatus();
  printf("Resetting ESP...");
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
  clearStatus();
  printf("Reset complete.");

  sendcommand("ATE0");
  do
  {
    byte = uart_readBlock();
  } while (byte != 'K'); // OK
  //clearStatus();
  //puts("ATE0 Answer:[OK]");
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
unsigned int fillDataBufferEsp(void)
{
  unsigned char sizeLink;
  unsigned long toDownload, downloaded;
  unsigned char byte, count = 0, try = 0;
  unsigned int dataSize;
  unsigned char skipHeader;
  unsigned char *count1;

  strcpy(link, netbuf);
  sizeLink = strlen(link);
  try = 0;
  do
  {
    try++;
    if (try > 1)
    {
      clearStatus();
      printf("----->Retry:%u\r\n", try);
      delay(500);
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
      toDownload = contLen;
      skipHeader = 1;
    }
    downloaded = downloaded + dataSize;
    memcpy(dataBuffer + downloaded - dataSize, netbuf + headlng, dataSize);
    toDownload = toDownload - dataSize;
  } while (toDownload > 0);
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
  BOX(1, 15, 80, 8, 40);
  AT(1, 15);
  puts("Config loaded:");
  if (comType == 1)
  {
    puts("     Controller base port: 0x55fe");
  }
  else
  {
    printf("     RBR_THR:0x%4x     IER    :0x%4x\r\n     IIR_FCR:0x%4x     LCR    :0x%4x\r\n", RBR_THR, IER, IIR_FCR, LCR);
    printf("     MCR    :0x%4x     LSR    :0x%4x\r\n     MSR    :0x%4x     SR     :0x%4x\r\n", MCR, LSR, MSR, SR);
  }
  printf("     DIV    :%4u       TYPE   :%4u  \r\n     ESP    : %u ", divider, comType, espType);
  switch (comType)
  {
  case 0:
    puts("(16550 like w/o AFC)");
    break;
  case 1:
    puts("(ATM Turbo 2+)");
    break;
  case 2:
    puts("(16550 with AFC)");
  default:
    puts("(Unknown type)");
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

const char *parseJson(unsigned char *property)
{
  unsigned int w, lng, lngp1, findEnd, listPos;
  unsigned char terminator;
  int n;
  n = -1;
  netbuf[0] = '\0';
  n = pos(dataBuffer, property, 1, 0);
  if (n == -1)
  {
    strcpy(netbuf, "0\0");
    return netbuf;
  }
  lng = n - 1 + strlen(property);
  if (dataBuffer[lng] == ':')
  {
    terminator = '\0';
  }
  if (dataBuffer[lng] == '\"')
  {
    terminator = '\"';
  }
  if (dataBuffer[lng] == '[')
  {
    terminator = ']';
  }

  findEnd = 1;
  lngp1 = lng + 1;

  while (42)
  {

    if ((dataBuffer[lngp1 + findEnd] == ','))
    {
      if (terminator == '\0')
      {
        break;
      }
      if ((dataBuffer[lng + findEnd] == terminator))
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
    netbuf[listPos] = dataBuffer[w];
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
  netbuf[targetPos] = '\0';

  for (w = lng + 1; w < targetPos + 1; w++)
  {
    netbuf[w - lng - 1] = netbuf[w];
  }
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

void ncReplace(void)
{
  unsigned char len;
  for (len = 0; len < strlen(curFileStruct.afn); len++)
  {
    if (curFileStruct.afn[len] < ' ')
    {
      curFileStruct.afn[len] = '_';
    }
  }

  for (len = 0; len < strlen(curFileStruct.tfn); len++)
  {
    if (curFileStruct.tfn[len] < ' ')
    {
      curFileStruct.tfn[len] = '_';
    }
  }
}

unsigned char saveBuf(unsigned long fileId, unsigned char operation, unsigned int sizeOfBuf)
{
  FILE *fp2;
  unsigned long fileSize;
  unsigned char afnSize, tfnSize;
  unsigned char fileIdChar[10];

  if (operation == 00)
  {

    if (saveFlag == 0)
    {
      sprintf(curFileStruct.fileName, "temp.%s", formats[curFormat]);
    }
    else
    {
      afnSize = sizeof(curFileStruct.afn) - 1;
      tfnSize = sizeof(curFileStruct.tfn) - 1;

      strcpy(curFileStruct.afn, curFileStruct.authorTitle);
      nameRepair(curFileStruct.afn, afnSize);
      strcpy(curFileStruct.tfn, curFileStruct.trackName);
      nameRepair(curFileStruct.tfn, tfnSize);
      sprintf(curFileStruct.fileName, "%s-%s.%s", curFileStruct.afn, curFileStruct.tfn, formats[curFormat]);
      ncReplace();

      if (strlen(curFileStruct.fileName) > 63)
      {
        sprintf(fileIdChar, "-%ld", fileId);
        str_replace(curFileStruct.fileName, sizeof(curFileStruct.fileName) - 1, curFileStruct.fileName, fileIdChar, "");
        curFileStruct.fileName[50] = '\0';
        strcat(curFileStruct.fileName, fileIdChar);
        strcat(curFileStruct.fileName, formats[curFormat]);
      }
    }
    OS_SETSYSDRV();
    OS_MKDIR("../downloads/radio"); // Create if not exist
    OS_CHDIR("../downloads/radio");
    fp2 = OS_CREATEHANDLE(curFileStruct.fileName, 0x80);
    if (((int)fp2) & 0xff)
    {
      clearStatus();
      printf("%s creating error. Check for  downloads\\radio folder.", curFileStruct.fileName);
      getchar();
      exit(0);
    }
    OS_CLOSEHANDLE(fp2);
    return 0;
  }

  if (operation == 01)
  {
    fp2 = OS_OPENHANDLE(curFileStruct.fileName, 0x80);
    if (((int)fp2) & 0xff)
    {

      clearStatus();
      printf("%s opening error.", curFileStruct.fileName);
      exit(0);
    }
    fileSize = OS_GETFILESIZE(fp2);
    OS_SEEKHANDLE(fp2, fileSize);
    OS_WRITEHANDLE(netbuf, fp2, sizeOfBuf);
    OS_CLOSEHANDLE(fp2);
    return 0;
  }

  if (operation == 02)
  {
    OS_CLOSEHANDLE(fp2);
    return 0;
  }

  return 0;
}

void getData(unsigned char socket)
{
  unsigned int todo, w, bPos, skipHeader;

  skipHeader = 0;
  bPos = 0;
  while (1)
  {
    todo = tcpRead(socket);
    if (todo == 0)
    {
      break;
    }
    if (skipHeader == 0)
    {
      skipHeader = 1;
      todo = cutHeader(todo);
    }

    if (bPos + todo > sizeof(dataBuffer))
    {
      clearStatus();
      printf("dataBuffer overrun...");
      break;
    }

    for (w = 0; w < todo; w++)
    {
      dataBuffer[w + bPos] = netbuf[w];
    }
    bPos = bPos + todo;
    if (bPos == contLen)
    {
      // dataBuffer[todo + bPos + 1] = '\0';
      break;
    }
  }
  netShutDown(socket, 1);
}

unsigned int tcpSend(unsigned char socket, unsigned int messageadr, unsigned int size)
{
  unsigned char retry = 20;
  unsigned int todo;
  readStruct.socket = socket;
  readStruct.BufAdr = messageadr;
  readStruct.bufsize = size;
  readStruct.protocol = SOCK_STREAM;

wizwrite:
  todo = OS_WIZNETWRITE(&readStruct);
  if (todo > 32767)
  {
    clearStatus();
    printf("OS_WIZNETWRITE: ");
    errorPrint(todo & 255);
    if (retry == 0)
    {
      exit(0);
    }
    retry--;
    delay(150);
    goto wizwrite;
  }
  else
  {
    if (logFlag)
    {
      clearStatus();
      printf("OS_WIZNETWRITE: %u bytes written.", todo);
    }
  }
  return todo;
}

unsigned long processJson(unsigned long startPos, unsigned char limit, unsigned char queryNum)
{
  FILE *fp3;
  unsigned int retry, tSize;
  unsigned int todo;
  unsigned char *count, socket;
  clearStatus();
  printf("Getting data(%u)...", queryNum);

  switch (queryNum)
  {
  case 0: // GET /api/export:zxMusic/limit:1/start:1/filter:zxMusicFormat=pt3/order:date,desc HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)
    strcpy(netbuf, "GET /api/export:zxMusic/limit:");
    sprintf(buffer, "%u", limit);
    strcat(netbuf, buffer);
    strcat(netbuf, "/start:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, "/filter:zxMusicFormat=");
    strcat(netbuf, formats[curFormat]);
    strcat(netbuf, "/order:date,desc");
    strcat(netbuf, userAgent);
    break;
  case 1: // GET /api/types:zxMusic/export:zxMusic/language:eng/limit:1/start:0/order:votes,rand/filter:zxMusicMinRating=4;
    startPos = 0;
    strcpy(netbuf, "GET /api/types:zxMusic/export:zxMusic/language:eng/limit:");
    sprintf(buffer, "%u", limit);
    strcat(netbuf, buffer);
    strcat(netbuf, "/start:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, "/order:votes,rand/filter:zxMusicMinRating=4;zxMusicFormat=");
    strcat(netbuf, formats[curFormat]);
    strcat(netbuf, userAgent);
    break;
  case 2: // GET /api/types:zxMusic/export:zxMusic/language:eng/limit:1/start:0/order:rand/filter:zxMusicFormat=PT3 HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)
    startPos = 0;
    strcpy(netbuf, "GET /api/types:zxMusic/export:zxMusic/language:eng/limit:");
    sprintf(buffer, "%u", limit);
    strcat(netbuf, buffer);
    strcat(netbuf, "/start:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, "/order:rand/filter:zxMusicFormat=");
    strcat(netbuf, formats[curFormat]);
    strcat(netbuf, userAgent);
    break;

  case 3: // GET /api/export:zxMusic/limit:1/start:1/filter:zxMusicFormat=pt3;authorId=7744/order:date,desc HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)

    fp3 = OS_OPENHANDLE("radio/user.que", 0x80);
    if (((int)fp3) & 0xff)
    {
      fp3 = OS_CREATEHANDLE("radio/user.que", 0x80);
      OS_WRITEHANDLE(userQuery, fp3, sizeof(userQuery));
      OS_CLOSEHANDLE(fp3);
      fp3 = OS_OPENHANDLE("radio/user.que", 0x80);
    }
    OS_READHANDLE(userQuery, fp3, sizeof(userQuery));
    OS_CLOSEHANDLE(fp3);

    strcpy(netbuf, "GET /api/limit:");
    sprintf(buffer, "%u", limit);
    strcat(netbuf, buffer);
    strcat(netbuf, "/start:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, userQuery);
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
      getData(socket);
      clearStatus();
      printf("Processing data (%u)...", queryNum);
    }
    else
    {
      fillDataBufferEsp();
    }

    count = strstr(dataBuffer, "responseStatus\":\"success");
    if (count == NULL)
    {
      retry--;
      clearStatus();
      printf("PROCESS JSON: [ERROR: Bad responseStatus.] [Query:%u][Retry:%u] [Track:%lu]\r\n", queryNum, retry, startPos);
      YIELD();
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
  count = strstr(dataBuffer, "\"id\":");
  if (count == NULL)
  {
    clearStatus();
    printf("BAD JSON: not ID query = %u startPos = %lu", queryNum, startPos);
    return -2;
  }
  if (queryNum < 4)
  {
    netbuf[0] = '\0';
    parseJson("\"id\":");
    curFileStruct.picId = atol(netbuf);
    parseJson(",\"title\":\"");
    convert866();
    strcpy(curFileStruct.trackName, netbuf);

    tSize = sizeof(curFileStruct.trackName);
    stringRepair(curFileStruct.trackName, tSize);

    parseJson("\"rating\":\"");
    strcpy(curFileStruct.picRating, netbuf);
    parseJson("\"year\":\"");
    curFileStruct.picYear = atoi(netbuf);
    parseJson("\"totalAmount\":");
    curFileStruct.totalAmount = atol(netbuf);
    parseJson("\"time\":\"");
    strcpy(curFileStruct.time, netbuf);
    parseJson("\"authorIds\":[");
    strcpy(curFileStruct.authorIds, netbuf);
    parseJson("\"authorIds\":[");
    strcpy(curFileStruct.fileName2, netbuf);
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

unsigned char getTrack2(unsigned long fileId)
{
  unsigned int todo;
  unsigned char socket;
  unsigned int skipHeader = 0;
  unsigned long bytecount;
  unsigned int packSize = 2000;
  unsigned char sizeLink;
  unsigned long toDownload, downloaded;
  unsigned char try = 0, byte = 0;
  unsigned int dataSize, count;
  unsigned char *count1;
  clearStatus();
  printf("Getting track...");

  if (netDriver == 0)
  {
    strcpy(netbuf, cmdlist1);
    sprintf(buffer, "%lu", fileId);
    strcat(netbuf, buffer);
    strcat(netbuf, userAgent);

    socket = OpenSock(AF_INET, SOCK_STREAM);
    todo = netConnect(socket);
    todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
    saveBuf(curFileStruct.picId, 00, 0);
    do
    {
      todo = tcpRead(socket);
      if (todo == 0)
      {
        break;
      }
      if (skipHeader == 0)
      {
        skipHeader = 1;
        todo = cutHeader(todo);
        bytecount = contLen;
      }
      saveBuf(curFileStruct.picId, 01, todo);
      bytecount = bytecount - todo;
    } while (bytecount != 0);
    netShutDown(socket, 0);
  }
  else
  {
    sprintf(buffer, "%lu", fileId);
    strcpy(netbuf, cmdlist1);
    strcat(netbuf, buffer);
    strcat(netbuf, userAgent);
    saveBuf(curFileStruct.picId, 00, 0);

    strcpy(link, netbuf);
    sizeLink = strlen(link);
    try = 0;
    do
    {
      try++;
      if (try > 1)
      {
        clearStatus();
        printf("----->Retry:%u\r\n", try);
        delay(500);
      }
      sendcommand("AT+CIPSTART=\"TCP\",\"zxart.ee\",80");
      getAnswer2(); // CONNECT or ERROR or link is not valid
      count1 = strstr(netbuf, "CONNECT");
    } while (count1 == NULL);

    getAnswer2(); // OK

    strcpy(netbuf, cmdlist1);
    sprintf(buffer, "%lu", fileId);
    strcat(netbuf, buffer);
    strcat(netbuf, userAgent);
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
        toDownload = contLen;
        skipHeader = 1;
      }
      downloaded = downloaded + dataSize;
      saveBuf(curFileStruct.picId, 01, dataSize);
      toDownload = toDownload - dataSize;
    } while (toDownload > 0);
    sendcommand("AT+CIPCLOSE");
    getAnswer2(); // CLOSED
    getAnswer2(); // OK
  }
  return 0;
}
unsigned char runPlayer(void)
{
  FILE *fp2;
  unsigned long playerSize, loaded, loop;
  unsigned char pgbak;
  // writeLog("runPlayer() entry.\r\n");
  clearStatus();
  printf("Running player...");
  strcpy(appCmd, "player.com ");
  strcat(appCmd, curFileStruct.fileName);
  player_pg.l = OS_GETMAINPAGES();
  pgbak = main_pg.pgs.window_3;
  loaded = 0;
  OS_GETPATH((unsigned int)&curPath);
  OS_SETSYSDRV();
  fp2 = OS_OPENHANDLE(fileName, 0x80);
  if (((int)fp2) & 0xff)
  {
    clearStatus();
    printf("%s", fileName);
    printf(" not found.");
    exit(0);
  }
  playerSize = OS_GETFILESIZE(fp2);
  OS_CHDIR(curPath);
  OS_NEWAPP((unsigned int)&player_pg);
  SETPG32KHIGH(player_pg.pgs.window_3);
  memcpy((char *)(0xC080), &appCmd, sizeof(appCmd));
  for (loop = 0; loop < playerSize; loop = loop + loaded)
  {
    loaded = OS_READHANDLE(dataBuffer, fp2, sizeof(dataBuffer));
    memcpy((char *)(0xC100 + loop), &dataBuffer, loaded);
  }
  OS_CLOSEHANDLE(fp2);
  SETPG32KHIGH(pgbak);
  OS_RUNAPP(player_pg.pgs.pId);

  sprintf(toLog, "runPlayer() return [PID:%u]\r\n", player_pg.pgs.pId);
  // writeLog(toLog);

  return player_pg.pgs.pId;
}

long trackSelector(unsigned char mode)
{
  switch (mode)
  {
  case 0: // Next track
    count++;
    if (count > curFileStruct.totalAmount - 1)
    {
      count = 0;
    }
    break;
  case 1: // Prev. track
    count--;
    if (count < 0)
    {
      count = curFileStruct.totalAmount - 1;
    }
    break;
  }
  return count;
}

void printStatus(void)
{
  AT(1, 9);
  ATRIB(93);
  printf(" [Q]Query : ");
  ATRIB(97);
  printf("%s", queryType);
  printf("  ");
  AT(1, 24);
  ATRIB(45);
  printf("                                                                                ");
  AT(2, 24);
  ATRIB(93);
  printf(" [F]Format: ");
  ATRIB(97);
  printf("%s", formats[curFormat]);
  ATRIB(93);
  printf(" [K]Keep files: ");
  ATRIB(97);
  printf("%u", saveFlag);
  ATRIB(93);
  printf(" [R]Repeat: ");
  ATRIB(97);
  printf("%u", rptFlag);
  ATRIB(93);
  printf(" [J]Jump to ");
  printf(" [E]Exit        [%s]", ver);

  ATRIB(97);
  ATRIB(40);
}

void printInfo(void)
{
  BOX(30, 2, 50, 6, 40);
  AT(1, 2);
  ATRIB(97);
  ATRIB(93);
  printf(" #: ");
  ATRIB(97);
  printf("%lu", count);
  ATRIB(93);
  printf(" ID: ");
  ATRIB(97);
  printf("%lu", curFileStruct.picId);
  ATRIB(93);
  printf(" Total Tracks: ");
  ATRIB(97);
  printf("%lu", curFileStruct.totalAmount);
  printf(" \r\n");
  ATRIB(93);
  printf(" RATING: ");
  ATRIB(97);
  printf("%s", curFileStruct.picRating);
  ATRIB(93);
  printf(" YEAR: ");
  ATRIB(97);
  printf("%u", curFileStruct.picYear);
  ATRIB(93);
  printf(" DURATION: ");
  ATRIB(97);
  printf("%s", curFileStruct.time);
  printf(" \r\n\r\n");
  ATRIB(93);
  printf(" AuthorsIDs ");
  ATRIB(97);
  printf("%s", curFileStruct.authorIds);
  ATRIB(93);
  printf(" Author: ");
  ATRIB(97);
  printf("%s", curFileStruct.authorTitle);
  ATRIB(93);
  printf(" Real name: ");
  ATRIB(97);
  printf("%s", curFileStruct.authorRealName);
  printf(" \r\n\r\n");
  ATRIB(96);
  printf("                                                                           \r");
  printf("   TITLE: %s\r\n", curFileStruct.trackName);
}

unsigned char testPlayer(void)
{
  union APP_PAGES player2_pg;
  player2_pg.l = OS_GETAPPMAINPAGES(player_pg.pgs.pId);
  if (errno == 0)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

C_task main(int argc, char *argv[])
{
  unsigned char errn, keypress, queryNum, pId, alive, changedFormat;
  long iddqd, idkfa, ipadress;
  unsigned long curTimer, startTimer, oldTimer;
  os_initstdio();
  srand(time());

  count = 0;
  saveFlag = 0;
  logFlag = 0;
  queryNum = 0;
  curFormat = 0;
  changedFormat = 0;
  rptFlag = 0;
  netDriver = 0;

  if (argc > 1)
  {
    if ((argv[1][0] == 'e') || (argv[1][0] == 'E'))
    {
      netDriver = 1;
      clearStatus();
      printf("    ESP32 mode enabled...");
      loadEspConfig();
      uart_init(divider);
      espReBoot();
      printHelp();
    }
  }

  strcpy(queryType, "from newest to oldest");
  BOX(1, 1, 80, 25, 40);
  AT(1, 1);
  ATRIB(97);
  ATRIB(45);
  printf("                           ZXART.EE radio for %s                           ", interfaces[netDriver]);
  AT(1, 24);
  printf("  [L]Enable logging(press on startup)                                          ");

  ATRIB(33);
  ATRIB(40);

  keypress = _low_level_get();
  if (keypress == 'l' || keypress == 'L')
  {
    logFlag = 1;
    clearStatus();
    printf("Logging enabled");
    getchar();
  }

start:
  // writeLog("\r\n**********[Start new track]**********\r\n");
  OS_SETSYSDRV();
  printHelp();
  curFileStruct.fileSize = 0;

  iddqd = processJson(count, 1, queryNum); // Query for track info
  if (iddqd < 0)
  {
    {
      clearStatus();
      printf("Error getting track info, next please(%ld)...", iddqd);
      count = trackSelector(0);
      goto start;
    }
  }

  idkfa = processJson(atol(curFileStruct.authorIds), 0, 99); // Query for AuthorID

  if (idkfa < 0)
  {
    clearStatus();
    printf("Error getting author %lu", atol(curFileStruct.authorIds));
    strcpy(curFileStruct.authorTitle, "-");
    strcpy(curFileStruct.authorRealName, "-");
  }

  sprintf(toLog, "Playing[%u][", curFileStruct.picId);
  // writeLog(toLog);
  // writeLog(curFileStruct.trackName);
  // writeLog("]\r\n");

replay:

  errn = getTrack2(iddqd); // Downloading the track

resume:
  startTimer = time();
  printProgress(0);
  // writeLog("runPlayer() before.\r\n");
  pId = runPlayer(); // Start the Player!
  // writeLog("runPlayer() after.\r\n");
  printStatus();
  printInfo();
rekey:
  keypress = _low_level_get();
  if (keypress != 0)
  {
    if (keypress == 27 || keypress == 'e' || keypress == 'E')
    {
      OS_DROPAPP(pId);
      BOX(1, 1, 80, 25, 40);
      AT(1, 1);
      printf("Good bye...\r\n");
      ATRIB(37);
      ATRIB(40);
      exit(0);
    }
    if (keypress == 248 || keypress == 'b' || keypress == 'B')
    {
      changedFormat = 0;
      OS_DROPAPP(pId);
      clearStatus();
      printf("Player stopped...");
      count = trackSelector(1);
      goto start;
    }

    if (keypress == 251 || keypress == 32 || keypress == 'n' || keypress == 'N')
    {
      changedFormat = 0;
      OS_DROPAPP(pId);
      clearStatus();
      printf("Player stopped...");
      count = trackSelector(0);
      goto start;
    }

    if (keypress == 'k' || keypress == 'K')
    {
      OS_DROPAPP(pId);
      clearStatus();
      printf("Player stopped...");
      saveFlag = !saveFlag;
      printStatus();
      changedFormat = 0;
      goto replay;
    }

    if (keypress == 'q' || keypress == 'Q')
    {
      OS_DROPAPP(pId);
      clearStatus();
      printf("Player stopped...");
      queryNum++;
      if (queryNum > 3)
      {
        queryNum = 0;
      }
      switch (queryNum)
      {
      case 0:
        strcpy(queryType, "from newest to oldest                   ");
        break;
      case 1:
        strcpy(queryType, "Random best and most voted tracks       ");
        break;
      case 2:
        strcpy(queryType, "Random play                             ");
        break;
      case 3:
        strcpy(queryType, "User defined query from \"user.que\"     ");
        break;
      }
      count = 0;
      changedFormat = 0;
      printStatus();
      goto start;
    }

    if (keypress == 'j' || keypress == 'J')
    {
      AT(1, 7);
      printf("                                                                      \r");
      printf("Jump to track:");
      scanf("%lu", &count);
      OS_DROPAPP(pId);
      if (count > curFileStruct.totalAmount - 1)
      {
        count = curFileStruct.totalAmount - 1;
      }
      changedFormat = 0;
      goto start;
    }

    if (keypress == 'f' || keypress == 'F')
    {
      OS_DROPAPP(pId);
      clearStatus();
      printf("Player stopped...");
      curFormat++;
      count = -1;
      if (curFormat > 3)
      {
        curFormat = 0;
      }
      changedFormat = 1;
      curFileStruct.totalAmount = 1;
      if (strstr(formats[curFormat], "tfc") != NULL)
      {
        cutOff = 5;
      }
      else
      {
        cutOff = 0;
      }

      printStatus();
      printProgress(0);
      BOX(1, 2, 80, 6, 40);
      goto rekey;
    }

    if (keypress == 'l' || keypress == 'L')
    {
      logFlag = !logFlag;
      clearStatus();
      printf("Logging: %u", logFlag);
    }

    if (keypress == 's' || keypress == 'S')
    {
      OS_DROPAPP(pId);
      clearStatus();
      printf("Player stopped...");
      printProgress(0);
      changedFormat = 1;
      getchar();
      goto resume;
    }
    if (keypress == 'r' || keypress == 'R')
    {
      rptFlag = !rptFlag;
      clearStatus();
      printStatus();
      goto rekey;
    }
    if (keypress == 'd' || keypress == 'D')
    {
      saveBak = saveFlag;
      saveFlag = 1;

      errn = getTrack2(iddqd); // Downloading the track

      saveFlag = saveBak;
      clearStatus();
      printf("File saved: [%s]...", curFileStruct.fileName);
      goto rekey;
    }

    if (keypress == 'i' || keypress == 'I')
    {
      netDriver = !netDriver;
      if (netDriver == 1)
      {
        clearStatus();
        printf("    ESP32 mode enabled...");
        loadEspConfig();
        uart_init(divider);
        espReBoot();
        printHelp();
      }
      else
      {
        clearStatus();
        printf("    ZXNETUSB mode enabled...");
      }
      AT(1, 1);
      ATRIB(97);
      ATRIB(45);
      printf("                           ZXART.EE radio for %s                    ", interfaces[netDriver]);
      ATRIB(33);
      ATRIB(40);
    }
  }

  curTimer = time();
  curFileStruct.curPos = (curTimer - startTimer) / 50;
  /*
    if ((curTimer - oldTimer) > 49)
    {
      alive = testPlayer();
      sprintf(toLog, ",%u", alive);
      //writeLog(toLog);
    }
    if (alive == 0 && !changedFormat)
    {
      if (rptFlag == 1)
      {
        goto resume;
      }
      //writeLog("\r\nalive == 0. Next track please.\r\n");
      printProgress(2);
      count = trackSelector(0);
      goto start;
    }

    if (alive == 1 && ((curTimer - oldTimer) > 49))
    {
      sprintf(toLog, ".%u", curFileStruct.trackInSeconds - curFileStruct.curPos);
      //writeLog(toLog);
      printProgress(1);
      oldTimer = curTimer;
    }
  */

  remainTime = curFileStruct.trackInSeconds - curFileStruct.curPos;

  if ((remainTime < cutOff) && !changedFormat)
  {

    OS_DROPAPP(pId);
    clearStatus();
    printf("Player stopped...");

    if (rptFlag == 1)
    {
      goto resume;
    }
    // writeLog("\r\nalive == 0. Next track please.\r\n");
    printProgress(2);
    count = trackSelector(0);
    goto start;
  }
  if ((curTimer - oldTimer) > 49 && !changedFormat)
  {
    sprintf(toLog, ".%u", remainTime);
    // writeLog(toLog);
    printProgress(1);
    oldTimer = curTimer;
  }

  YIELD();
  goto rekey;
}
