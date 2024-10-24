#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <graphic.h>
#include <../common/terminal.c>
#include <tcp.h>

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

unsigned char picture[16384];
unsigned char netbuf[2048];
unsigned char minRating[] = "0000000000";

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

unsigned char ver[] = "3.3";
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

void spaces(unsigned char number)
{
  while (number > 0)
  {
    putchar(' ');
    number--;
  }
}

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
  printf(" 'M' Установить минимальный рейтинг для случайного выбора\n\r");
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

///////////////////////////
#include <../common/esp-com.c>
#include <../common/network.c>
//////////////////////////

int cutHeader(unsigned int todo)
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
    printf("end of header not found\r\n");
  }
  else
  {
    headlng = ((unsigned int)count1 - (unsigned int)netbuf + 4);
    // printf("header %u bytes\r\n", headlng);
  }
  return todo - headlng;
}

unsigned int fillPictureEsp(void)
{
  unsigned char sizeLink = 0;
  unsigned long downloaded = 0;
  unsigned char byte, count = 0;
  unsigned int todo = 0;
  unsigned char *count1;

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
  downloaded = 0;
  do
  {
    headlng = 0;
    todo = recvHead();
    getdataEsp(todo); // Requested size
    if (downloaded == 0)
    {
      todo = cutHeader(todo);
    }
    memcpy(picture + downloaded, netbuf + headlng, todo);
    downloaded = downloaded + todo;
  } while (downloaded < contLen);
  sendcommand("AT+CIPCLOSE");
  getAnswer2(); // CLOSED
  getAnswer2(); // OK
  return 0;
}

unsigned char getPicEsp(unsigned long fileId)
{
  sprintf(netbuf, "GET /file/id:%lu%s", fileId, userAgent);
  fillPictureEsp();
  return 0;
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

void fillPicture(signed char socket)
{
  int todo;
  unsigned int downloaded = 0;
  do
  {
    headlng = 0;
    todo = tcpRead(socket, 10);
    testOperation("OS_WIZNETREAD", todo); // Quit if too many retries

    if (downloaded == 0)
    {
      todo = cutHeader(todo);
    }

    if (downloaded + todo > sizeof(picture))
    {
      printf("dataBuffer overrun... %u reached \n\r", downloaded + todo);
      break;
    }
    memcpy(picture + downloaded, netbuf + headlng, todo);
    downloaded = downloaded + todo;
  } while (downloaded != contLen);
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
  int todo;
  char socket;
  socket = OpenSock(AF_INET, SOCK_STREAM);
  testOperation("OS_NETSOCKET", socket);

  todo = netConnect(socket, 10);
  testOperation("OS_NETCONNECT", todo);

  sprintf(netbuf, "GET /file/id:%lu%s", fileId, userAgent);
  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf), 10);
  testOperation("OS_WIZNETWRITE", todo);
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
  int todo;
  unsigned char *count1, socket;
  switch (queryNum)
  {
  case 0:
    sprintf(netbuf, "GET /api/export:zxPicture/filter:zxPictureType=standard/limit:%u/start:%lu/order:date,desc%s", limit, startPos, userAgent);
    break;
  case 1:
    sprintf(netbuf, "GET /api/types:zxPicture/export:zxPicture/language:eng/start:0/limit:1/order:rand/filter:zxPictureMinRating=%s;zxPictureType=standard%s", minRating, userAgent);
    break;
  case 3: // /api/export:author/filter:authorId=2202
    sprintf(netbuf, "GET /api/export:author/filter:authorId=%lu%s", startPos, userAgent);
    break;
  case 99: // GET /jsonElementData/elementId:182798
    sprintf(netbuf, "GET /jsonElementData/elementId:%lu%s", startPos, userAgent);
    break;
  }
  retry = 10;
  while (42)
  {
    if (netDriver == 0)
    {
      socket = OpenSock(AF_INET, SOCK_STREAM);
      testOperation("OS_NETSOCKET", socket);

      todo = netConnect(socket, 10);
      testOperation("OS_NETCONNECT", todo);

      todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf), 10);
      testOperation("OS_WIZNETWRITE", todo);

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
  YIELD();
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
      BOX(1, 1, 80, 25, 40, ' ');
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
        count = 0;
      }
      else
      {
        printf("    Sequental mode enabled...\r\n");
        count = 0;
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
      slideShowTime = 150;
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

unsigned char inputBox(struct window w, unsigned char *prefilled)
{
  unsigned char wcount, tempx, tittleStart;
  unsigned char byte, counter;
  w.h++;
  AT(w.x, w.y - 1);
  BOX(w.x, w.y, w.w + 1, w.h, w.back, 32);
  AT(w.x, w.y);
  ATRIB(w.text);
  putchar(201);
  for (wcount = 0; wcount < w.w; wcount++)
  {
    putchar(205);
  }
  putchar(187);
  AT(w.x, w.y + w.h);
  putchar(200);
  for (wcount = 0; wcount < w.w; wcount++)
  {
    putchar(205);
  }
  putchar(188);

  tempx = w.x + w.w + 1;
  for (wcount = 1; wcount < w.h; wcount++)
  {
    AT(w.x, w.y + wcount);
    putchar(186);
    AT(tempx, w.y + wcount);
    putchar(186);
  }
  tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2);
  AT(tittleStart, w.y);
  printf("[%s]", w.tittle);
  AT(w.x + 1, w.y + 1);
  ATRIB(w.back);
  // putchar(219);

  cmd[0] = 0;

  counter = strlen(prefilled);
  if (counter != 0)
  {
    strcpy(cmd, prefilled);
    goto skipKeys;
  }

  do
  {
    byte = getchar();
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
        AT(w.x + 1, w.y + 1);
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
      AT(w.x + 1, w.y + 1);
      printf("%s", cmd);
      // putchar(219);
      if (byte == 0x08)
      {
        putchar(' ');
      }
    }
    YIELD();
  } while (42);
  return false;
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
  strcpy(minRating, "4.0");

  targetadr.family = AF_INET;
  targetadr.porth = 00;
  targetadr.portl = 80;
  targetadr.b1 = 217; // D9
  targetadr.b2 = 146; // 92
  targetadr.b3 = 69;  // 45
  targetadr.b4 = 13;  // 0D

  BOX(1, 1, 80, 25, 40, ' ');
  AT(1, 1);
  printHelp();
  safeKeys(keypress);

  if (netDriver == 0)
  {

    get_dns();
    dnsResolve("zxart.ee");
    printf("\r\n");
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
    goto review;
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
  else if (keypress == 248 || keypress == 'b' || keypress == 'B')
  {
    if (count > 0)
    {
      count--;
    }
  }
  else if (keypress == 251 || keypress == 32)
  {
    count++;
    goto start;
  }
  else if (keypress == 'i' || keypress == 'I')
  {
    delay(100);
    getchar();
    goto review;
  }
  else if (keypress == 'm' || keypress == 'M')
  {
    curWin.w = 22;
    curWin.x = 80 / 2 - curWin.w / 2 - 2;
    curWin.y = 1;
    curWin.h = 1;
    curWin.text = 97;
    curWin.back = 42;
    strcpy(curWin.tittle, "Минимальная оценка:");

    if (inputBox(curWin, ""))
    {
      char counter;
      for (counter = 0; counter < strlen(cmd); counter++)
      {
        if ((((cmd[counter] < '0') || (cmd[counter] > '9'))) && cmd[counter] != '.')
        {
          AT(1, 25);
          ATRIB(96);
          ATRIB(40);
          printf("    Wrong input.[%s]", cmd);
          counter = 0;
          break;
        }
      }
      if (counter != 0)
      {
        strncpy(minRating, cmd, 5);
        AT(1, 25);
        ATRIB(96);
        ATRIB(40);
        printf("    Minimal rating for random play is set to %s+\r\n\r\n", minRating);
        count = 0;
      }
    }
  }
  safeKeys(keypress);
  YIELD();
  goto start;
}
