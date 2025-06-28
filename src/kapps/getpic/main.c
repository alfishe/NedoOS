#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
// #include <graphic.h>
#include <../common/terminal.c>
#include <tcp.h>
//
#define true 1
#define false 0

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

unsigned char picture[15000];
unsigned char netbuf[6912];
unsigned char curPath[128];

unsigned char minRating[] = "0000000000";
struct fileStruct
{
  long picId;
  unsigned int picYear;
  unsigned long totalAmount;
  unsigned int httpErr;
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

struct window
{
  unsigned char x;
  unsigned char y;
  unsigned char w;
  unsigned char h;
  unsigned char text;
  unsigned char back;
  unsigned char tittle[80];
} curWin;

struct sockaddr_in dnsaddress;
struct sockaddr_in targetadr;
struct readstructure readStruct;

unsigned char ver[] = "4.3";
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

void clearStatus(void)
{
}

void emptyKeys(void)
{
  unsigned char loop = 0, key;
  do
  {
    key = OS_GETKEY();
    if (loop > 64)
    {
      break;
    }
    loop++;
  } while (key != 0);
}

unsigned char delayLongKey(unsigned long counter)
{
  unsigned long start, finish, key;
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
    key = OS_GETKEY();
    if (key != 0)
    {
      return key;
    }
    YIELD();
  }
  return 32;
}

void spaces(unsigned char number)
{
  while (number > 0)
  {
    putchar(' ');
    number--;
  }
}
void quit(void)
{
  OS_CLS(0);
  OS_SETGFX(-1);
  exit(0);
}
/*
void infoBox(struct window w, const char *message)
{
  unsigned char wcount, tempx, tittleStart;

  w.h++;
  OS_SETXY(w.x, w.y - 1);
  BDBOX(w.x, w.y, w.w + 1, w.h, w.back, 32);
  OS_SETXY(w.x, w.y);
  OS_SETCOLOR(w.text);
  putchar(201);
  for (wcount = 0; wcount < w.w; wcount++)
  {
    putchar(205);
  }
  putchar(187);
  OS_SETXY(w.x, w.y + w.h);
  putchar(200);
  for (wcount = 0; wcount < w.w; wcount++)
  {
    putchar(205);
  }
  putchar(188);

  tempx = w.x + w.w + 1;
  for (wcount = 1; wcount < w.h; wcount++)
  {
    OS_SETXY(w.x, w.y + wcount);
    putchar(186);
    OS_SETXY(tempx, w.y + wcount);
    putchar(186);
  }
  tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2);
  OS_SETXY(tittleStart, w.y);
  printf("[%s]", w.tittle);

  OS_SETXY(w.x + 1, w.y + 1);
  OS_SETCOLOR(w.back);
  tittleStart = w.x + (w.w / 2) - (strlen(message) / 2);
  OS_SETXY(tittleStart, w.y + 1);
  printf("%s", message);
}
*/
void printHelp(void)
{
  OS_SETCOLOR(67);
  printf("   GETPIC [%s] zxart.ee picture viewer for nedoNET\n\r", ver);
  OS_SETCOLOR(6);
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
  printf(" 'D' Переключение режима ZXNETUSB/ESP-COM\n\r");
  printf(" 'T' Продолжительность одного слайда в int-ах \n\r");
  printf(" 'M' Минимальный рейтинг для случайного воспроизведения. \n\r");
  printf(" 'H' Данная справочная информация\n\r");
  printf("-----------------Нажмите любую кнопку------------------\n\r");
  OS_SETCOLOR(70);
  keypress = getchar();
  OS_CLS(0);
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
#include <../common/network.c>
//////////////////////////

int testOperation2(const char *process, int socket)
{
  if (socket < 0)
  {
    printf("%s: [ERROR:", process);
    errorPrint(-socket);
    printf("]\r\n");
    YIELD();
    return -socket;
  }
  return 1;
}

int cutHeader(unsigned int todo)
{
  unsigned char *count1;

  curFileStruct.httpErr = httpError();
  if (curFileStruct.httpErr != 200)
  {
    clearStatus();
    printf("HTTP response:[%u]", curFileStruct.httpErr);
    return 0;
  }
  count1 = strstr(netbuf, "Content-Length:");
  if (count1 == NULL)
  {
    clearStatus();
    printf("contLen not found");
    contLen = 0;
    curFileStruct.httpErr = 999; // bad kostil
    return 0;
  }
  contLen = atol(count1 + 15);
  // printf("Content-Length: %lu \n\r", contLen);

  count1 = strstr(netbuf, "\r\n\r\n");
  if (count1 == NULL)
  {
    clearStatus();
    printf("end of header not found\r\n");
  }
  else
  {
    headlng = ((unsigned int)count1 - (unsigned int)netbuf + 4);
    // printf("header %u bytes\r\n", headlng);
  }
  return todo - headlng;
}

char *str_replace(char *dst, int num, const char *str, const char *orig, const char *rep)
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

char fillPictureEsp(void)
{
  unsigned char sizeLink;
  unsigned long downloaded;
  unsigned char byte, countl;
  unsigned int todo;
  const unsigned char *count1;
  unsigned char firstPacket;
  strcpy(link, netbuf);
  sizeLink = strlen(link);
  do
  {
    sendcommand("AT+CIPSTART=\"TCP\",\"zxart.ee\",80");
    getAnswer2(); // CONNECT or ERROR or link is not valid
    count1 = strstr(netbuf, "CONNECT");
  } while (count1 == NULL);

  getAnswer2();                                   // OK
  sprintf(netbuf, "AT+CIPSEND=%u", sizeLink + 2); // second CRLF in send command
  sendcommand(netbuf);
  getAnswer2();
  do
  {
    byte = uart_readBlock();
    // putchar(byte);
  } while (byte != '>');
  sendcommand(link);
  countl = 0;
  do
  {
    byte = uart_readBlock();
    if (byte == sendOk[countl])
    {
      countl++;
    }
    else
    {
      countl = 0;
    }
  } while (countl < strlen(sendOk));
  uart_readBlock(); // CR
  uart_readBlock(); // LF
  downloaded = 0;
  firstPacket = true;
  do
  {
    headlng = 0;
    todo = recvHead();
    getdataEsp(todo); // Requested size
    if (firstPacket)
    {
      todo = cutHeader(todo);
      firstPacket = false;
      if (curFileStruct.httpErr != 200)
      {
        sendcommand("AT+CIPCLOSE");
        getAnswer2(); // CLOSED
        getAnswer2(); // OK
        return false;
      }
    }

    if (downloaded + todo > sizeof(picture))
    {
      printf("dataBuffer overrun... %u reached \n\r", downloaded + todo);
      return false;
    }
    memcpy(picture + downloaded, netbuf + headlng, todo);
    downloaded = downloaded + todo;
  } while (downloaded < contLen);
  sendcommand("AT+CIPCLOSE");
  getAnswer2(); // CLOSED or ERROR
  count1 = strstr(netbuf, "CLOSED");
  if (count1 != NULL)
  {
    getAnswer2(); // OK
  }
  return true;
}

char fillPictureNet(void)
{
  int todo;
  unsigned int downloaded = 0;
  unsigned char firstPacket;
  char socket, retry;
  picture[0] = 0;
  retry = 3;
  socket = OpenSock(AF_INET, SOCK_STREAM);
  if (testOperation2("OS_NETSOCKET", socket) != 1)
  {
    getchar();
    quit();
  }
  todo = netConnect(socket, retry);
  if (testOperation2("OS_NETCONNECT", todo) != 1)
  {
    getchar();
    quit();
  }
  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf), retry);
  if (testOperation2("OS_WIZNETWRITE", todo) != 1)
  {
    getchar();
    quit();
  }
  firstPacket = true;
  do
  {
    headlng = 0;
    todo = tcpRead(socket, retry);
    testOperation("OS_WIZNETREAD", todo); // Quit if too many retries

    if (firstPacket)
    {
      todo = cutHeader(todo);
      firstPacket = false;
      if (curFileStruct.httpErr != 200)
      {
        netShutDown(socket, 0);
        return false;
      }
    }

    if (downloaded + todo > sizeof(picture))
    {
      printf("dataBuffer overrun... %u reached \n\r", downloaded + todo);
      return false;
    }
    memcpy(picture + downloaded, netbuf + headlng, todo);
    downloaded = downloaded + todo;
  } while (downloaded != contLen);

  netShutDown(socket, 0);
  picture[downloaded + 1] = 0;
  return true;
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
    quit();
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
  // n = -1;
  //  netbuf[0] = '\0';
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
    terminator = 0;
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
      if (terminator == 0)
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
  netbuf[listPos] = 0;
  return netbuf;
}

void convert866(void)
{
  unsigned int lng, targetPos, w, q = 0;
  unsigned char bufferl[8], one, two;
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
        bufferl[w] = netbuf[q + w];
      }
      q = q + 4;
      bufferl[4] = '\0';
      decVal = (unsigned int)strtol(bufferl, NULL, 16);

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
  unsigned int tSize;
  const unsigned char *count1;
  unsigned char result;
  switch (queryNum)
  {
  case 0:
    sprintf(netbuf, "GET /api/export:zxPicture/filter:zxPictureType=standard/limit:%u/start:%lu/order:date,desc%s", limit, startPos, userAgent);
    break;
  case 1:
    sprintf(netbuf, "GET /api/types:zxPicture/export:zxPicture/language:eng/start:0/limit:1/order:rand/filter:zxPictureMinRating=%s;zxPictureType=standard%s", minRating, userAgent);
    break;
  case 99: // GET /jsonElementData/elementId:182798
    sprintf(netbuf, "GET /jsonElementData/elementId:%lu%s", startPos, userAgent);
    break;
  }

  switch (netDriver)
  {
  case 0:
    result = fillPictureNet();
    break;
  case 1:
    result = fillPictureEsp();
    break;
  }

  if (!result)
  {
    return -1;
  }

  count1 = strstr(picture, "responseStatus\":\"success");
  if (count1 == NULL)
  {
    OS_CLS(0);
    OS_SETCOLOR(66);
    puts("Picture[]:");
    puts(picture);
    puts("---------------");
    printf("PROCESS JSON: [ERROR: Bad responseStatus.] [Query:%u][Pic:%lu]\r\n", queryNum, startPos);
    YIELD();
    getchar();
    return -1;
  }

  count1 = strstr(picture, "\"id\":");
  if (count1 == NULL)
  {
    parseJson("\"totalAmount\":");

    if (atol(netbuf) == 0)
    {
      return -3;
    }

    if (netbuf[0] != '-')
    {
      return -4;
    }
    OS_CLS(0);
    OS_SETCOLOR(66);
    puts("Picture[]:");
    puts(picture);
    puts("---------------");
    printf("PROCESS JSON: [ERROR: ID not found.] [Query:%u][Pic:%lu]\r\n", queryNum, startPos);
    YIELD();
    return -2;
  }
  netbuf[0] = 0;

  switch (queryNum)
  {
  case 0:
  case 1:
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
    break;
  case 99:
    parseJson(",\"title\":\"");
    convert866();
    strcpy(curFileStruct.authorTitle, netbuf);
    parseJson(",\"realName\":\"");
    convert866();
    strcpy(curFileStruct.authorRealName, netbuf);
    break;
  }
  return curFileStruct.picId;
}

void printData(void)
{
  OS_SETCOLOR(70);
  printf(" #: ");
  OS_SETCOLOR(71);
  printf("%lu", count);
  OS_SETCOLOR(70);
  printf(" ID: ");
  OS_SETCOLOR(71);
  printf("%lu ", curFileStruct.picId);
  OS_SETCOLOR(70);
  printf(" Total Pics: ");
  OS_SETCOLOR(71);
  printf("%lu\r\n", curFileStruct.totalAmount);
  OS_SETCOLOR(70);
  printf(" Author: ");
  OS_SETCOLOR(69);
  printf("%s\r\n", curFileStruct.authorTitle);
  OS_SETCOLOR(70);
  printf(" TITLE: ");
  OS_SETCOLOR(67);
  printf("%s\r\n", curFileStruct.picName);
  OS_SETCOLOR(70);
  printf(" RATING: ");
  OS_SETCOLOR(71);
  printf("%s", curFileStruct.picRating);
  OS_SETCOLOR(70);
  printf(" YEAR: ");
  OS_SETCOLOR(71);
  printf("%u\r\n", curFileStruct.picYear);
  OS_SETCOLOR(70);
  printf(" AuthorsIDs ");
  OS_SETCOLOR(71);
  printf("%s", curFileStruct.authorIds);
  OS_SETCOLOR(70);
  printf(" Real name: ");
  OS_SETCOLOR(71);
  printf("%s\r\n", curFileStruct.authorRealName);
  OS_SETCOLOR(69);
  printf("\r\n");
  printf("\r\n");

  OS_SETCOLOR(70);

  OS_SETCOLOR(70);
  printf(" Query: ");
  OS_SETCOLOR(71);
  if (randomPic)
  {
    printf("Random pic with %s+ rating\r\n", minRating);
  }
  else
  {
    puts("Sequental from newest");
  }
  OS_SETCOLOR(70);
  printf(" Mode : ");
  OS_SETCOLOR(71);

  if (slideShow)
  {
    printf("Slide-show, %u ints \r\n", slideShowTime);
  }
  else
  {
    puts("Manual show");
  }

  // YIELD();
}

unsigned char inputBox(struct window w, const char *prefilled)
{
  unsigned char wcount, tempx, tittleStart;
  unsigned char byte, counter;
  w.h++;
  OS_SETXY(w.x, w.y - 1);
  BDBOX(w.x, w.y, w.w + 1, w.h, w.back, 32);
  OS_SETXY(w.x, w.y);
  OS_SETCOLOR(w.text);
  putchar(201);
  for (wcount = 0; wcount < w.w; wcount++)
  {
    putchar(205);
  }
  putchar(187);
  OS_SETXY(w.x, w.y + w.h);
  putchar(200);
  for (wcount = 0; wcount < w.w; wcount++)
  {
    putchar(205);
  }
  putchar(188);

  tempx = w.x + w.w + 1;
  for (wcount = 1; wcount < w.h; wcount++)
  {
    OS_SETXY(w.x, w.y + wcount);
    putchar(186);
    OS_SETXY(tempx, w.y + wcount);
    putchar(186);
  }
  tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2);
  OS_SETXY(tittleStart, w.y);
  printf("[%s]", w.tittle);
  OS_SETXY(w.x + 1, w.y + 1);
  OS_SETCOLOR(w.back);
  putchar(219);

  cmd[0] = 0;

  counter = strlen(prefilled);
  if (counter != 0)
  {
    strcpy(cmd, prefilled);
    goto skipKeys;
  }

  do
  {
    byte = OS_GETKEY();
    if (byte != 0)
    {
      switch (byte)
      {
      case 0x08:
        if (counter > 0)
        {
          counter--;
          cmd[counter] = 0;
        }
        break;
      case 0x0d:

        if (counter == 0)
        {
          return false;
        }
        else
        {
          return true;
        }

      case 31:
        break;
      case 250:
        break;
      case 249:
        break;
      case 248:
        break;
      case 251: // Right
        break;
      case 252: // Del
        OS_SETXY(w.x + 1, w.y + 1);
        spaces(counter + 1);
        cmd[0] = 0;
        counter = 0;
        break;
      case 27:
        cmd[0] = 0;
        return false;
      default:
        if (counter < w.w - 1)
        {
          cmd[counter] = byte;
          counter++;
          cmd[counter] = 0;
        }
        break;
      }
    skipKeys:
      OS_SETXY(w.x + 1, w.y + 1);
      printf("%s", cmd);
      putchar(219);
      if (byte == 0x08)
      {
        putchar(' ');
      }
    }
    YIELD();
  } while (42);
  return false;
}

void safeKeys(unsigned char keypress)
{
  switch (keypress)
  {
  case 27:
    OS_SETCOLOR(70);
    printf("Good bye...\r\n");
    delayLong(500);
    quit();
    break;
  case 'j':
  case 'J':
    curWin.w = 13;
    curWin.x = 80 / 2 - curWin.w / 2 - 2;
    curWin.y = 11;
    curWin.h = 1;
    curWin.text = 103;
    curWin.back = 103;
    strcpy(curWin.tittle, "# of pic:");
    if (inputBox(curWin, ""))
    {
      sscanf(cmd, "%lu", &count);
      if (count > curFileStruct.totalAmount - 1)
      {
        count = curFileStruct.totalAmount - 1;
      }
    }
    break;
  case 't':
  case 'T':
    curWin.w = 20;
    curWin.x = 80 / 2 - curWin.w / 2 - 2;
    curWin.y = 11;
    curWin.h = 1;
    curWin.text = 103;
    curWin.back = 103;
    strcpy(curWin.tittle, "Slide time(ints)");
    if (inputBox(curWin, ""))
    {
      sscanf(cmd, "%u", &slideShowTime);
      OS_CLS(0);
      OS_SETCOLOR(70);
      printf("Slide duration set to %u ints.", slideShowTime);
      delayLong(500);
    }
    break;
  case 'v':
  case 'V':
    verbose = !verbose;

    if (verbose == 0)
    {
      BOX(1, 1, 80, 25, 40, ' ');
      AT(1, 1);
    }
    break;
  case 'h':
  case 'H':
    printHelp();
    break;
  case 'r':
  case 'R':
    randomPic = !randomPic;
    OS_SETCOLOR(70);
    if (verbose == 1)
    {
      if (randomPic == 1)
      {
        printf("    Random mode enabled...\r\n");
        count = 0;
        delayLong(500);
      }
      else
      {
        printf("    Sequental mode enabled...\r\n");
        count = 0;
        delayLong(500);
      }
    }
    break;
  case 'a':
  case 'A':
    slideShow = !slideShow;
    OS_SETCOLOR(70);
    if (slideShow == 1)
    {
      if (verbose == 1)
        printf("    SlideShow mode enabled...\r\n\r\n");
      slideShowTime = 150;
      delayLong(500);
    }
    else
    {
      if (verbose == 1)
        printf("    Manual mode enabled...\r\n\r\n");
      slideShowTime = 0;
      delayLong(500);
    }
    break;
  case 'd':
  case 'D':
    netDriver = !netDriver;
    OS_SETCOLOR(70);
    if (netDriver == 1)
    {
      printf("    ESP-COM mode enabled...\r\n");
      loadEspConfig();
      uart_init(divider);
      espReBoot();
      printf("    ESP-COM inited...\r\n");
      delayLong(500);
    }
    else
    {
      if (verbose == 1)
        printf("    NedoNET mode enabled...");
      delayLong(500);
    }
    break;
  case 'm':
  case 'M':
    curWin.w = 22;
    curWin.x = 80 / 2 - curWin.w / 2 - 2;
    curWin.y = 1;
    curWin.h = 1;
    curWin.text = 103;
    curWin.back = 103;
    strcpy(curWin.tittle, "Минимальная оценка:");

    if (inputBox(curWin, ""))
    {
      char counter;
      for (counter = 0; counter < strlen(cmd); counter++)
      {
        if ((((cmd[counter] < '0') || (cmd[counter] > '9'))) && cmd[counter] != '.')
        {
          counter = 0;
          break;
        }
      }
      if (counter != 0)
      {
        strncpy(minRating, cmd, 5);
        count = 0;
      }
    }
  default:
    break;
  }
}

char readParamFromIni(void)
{
  FILE *fpini;
  unsigned char *count1;
  const char currentNetwork[] = "currentNetwork";
  unsigned char curNet = 0;

  OS_GETPATH((unsigned int)&curPath);
  OS_SETSYSDRV();
  OS_CHDIR("/");
  OS_CHDIR("ini");

  fpini = OS_OPENHANDLE("network.ini", 0x80);
  if (((int)fpini) & 0xff)
  {
    clearStatus();
    printf("network.ini not found.\r\n");
    getchar();
    return false;
  }

  OS_READHANDLE(netbuf, fpini, sizeof(netbuf) - 1);
  OS_CLOSEHANDLE(fpini);

  count1 = strstr(netbuf, currentNetwork);
  if (count1 != NULL)
  {
    sscanf(count1 + strlen(currentNetwork) + 1, "%u", &curNet);
  }

  OS_CHDIR(curPath);
  return curNet;
}

void init(void)
{
  OS_SETSYSDRV();
  OS_MKDIR("../downloads");        // Create if not exist
  OS_MKDIR("../downloads/getpic"); // Create if not exist
  OS_CHDIR("../downloads/getpic");

  count = 0;
  verbose = 1;
  randomPic = 0;
  slideShow = 0;
  strcpy(minRating, "4.0");

  targetadr.family = AF_INET;
  targetadr.porth = 00;
  targetadr.portl = 80;
  targetadr.b1 = 217; // D9
  targetadr.b2 = 146; // 92
  targetadr.b3 = 69;  // 45
  targetadr.b4 = 13;  // 0D

  netDriver = readParamFromIni();

  if (netDriver == 0)
  {
    get_dns();
    clearStatus();
    dnsResolve("zxart.ee");
  }

  if (netDriver == 1)
  {
    loadEspConfig();
    uart_init(divider);
    espReBoot();
  }
}

unsigned char viewScreen6912c(unsigned int bufAdr)
{
  unsigned char key;
  OS_SETBORDER(0);
  OS_SETGFX(0x83);
  SETPG32KHIGH(OS_GETSCR0() >> 8);
  memcpy((unsigned char *)(0xc000), (unsigned char *)(bufAdr), 6912);

  if (slideShowTime != 0)
  {
    key = delayLongKey(slideShowTime * 20);
  }
  else
  {
    key = getchar();
  }
  OS_SETGFX(0x86);
  return key;
}

C_task main(void)
{
  long iddqd, idkfa;
  char result;

  OS_HIDEFROMPARENT();
  OS_SETGFX(0x86);
  OS_CLS(0);

  init();

  printHelp();
  safeKeys(keypress);

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

  OS_SETCOLOR(70);

  switch (iddqd)
  {
  case -3: // return 0 pictures
    strcpy(minRating, "1.0");
    printf("[%u]No picture is returned in query. Minimal rating is set to %s\r\n", curFileStruct.httpErr, minRating);
    delayLong(500);
    goto start;
  case -4: // return xxxx picture, but empty body.
    printf("[%u]Empty body is returned. Next picture, please.(%ld)...\r\n", curFileStruct.httpErr, iddqd);
    delayLong(500);
    count++;
    goto start;
  case -1: // return HTTP error != 200
    printf("[%u]Error getting pic info. Next picture, please(%ld)...\r\n", curFileStruct.httpErr, iddqd);
    count++;
    delayLong(500);
    goto start;
  }

  if (verbose == 1)
  {
    idkfa = processJson(atol(curFileStruct.authorIds), 0, 99);
    if (idkfa < 0)
    {
      printf("[%u]Error can't parse authorIds(%s). Next picture, please...\r\n", curFileStruct.httpErr, curFileStruct.authorIds);
      count++;
      delayLong(500);
      goto start;
    }
  }
  if (strcmp(curFileStruct.picType, "standard") != 0)
  {
    printf("[%u]Error format '%s' not supported. Next picture, please.\n\r", curFileStruct.httpErr, curFileStruct.picType);
    delayLong(500);
    count++;
    goto start;
  }
  sprintf(netbuf, "GET /file/id:%ld%s", iddqd, userAgent);
  switch (netDriver)
  {
  case 0:
    result = fillPictureNet();
    break;
  case 1:
    result = fillPictureEsp();
    break;
  }

  if (result == -1) // return HTTP error != 200
  {
    printf("[%u]Error getting pic. Next picture, please...\r\n", curFileStruct.httpErr);
    count++;
    delayLong(500);
    goto start;
  }

review:
  OS_CLS(0);
  YIELD();
  // keypress = viewScreen6912((unsigned int)&picture, slideShowTime);
  keypress = viewScreen6912c((unsigned int)&picture);
  emptyKeys();

  ///// Keys only for pictures
  if (keypress == 's' || keypress == 'S')
  {
    savePic(iddqd);
    printf("%s saved.", curFileStruct.fileName);
    delayLong(500);
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
    printData();
    while (OS_GETKEY() == 0)
    {
    }
    goto review;
  }
  safeKeys(keypress);
  goto start;
}
