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
  unsigned char afn[64];
  unsigned char pfn[64];
  unsigned char fileName[128];
} curFileStruct;
unsigned char ver[] = "1.7";
unsigned char netbuf[2048];
unsigned char picture[16384];
unsigned char crlf[2] = {13, 10};
unsigned long bytecount;
unsigned char status, key;
struct sockaddr_in targetadr;
struct readstructure readStruct;
unsigned long contLen;
unsigned long count;
extern void dns_resolve(void);

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
    printf("02 SHUT_RDWR\n\r");
    break;
  case 4:
    printf("04 ERR_INTR\n\r");
    break;
  case 23:
    printf("23 ERR_NFILE\n\r");
    break;
  case 35:
    printf("35 ERR_EAGAIN or ERR_EWOULDBLOCK\n\r");
    break;
  case 37:
    printf("37 ERR_ALREADY\n\r");
    break;
  case 38:
    printf("38 ERR_NOTSOCK\n\r");
    break;
  case 40:
    printf("40 ERR_EMSGSIZE\n\r");
    break;
  case 41:
    printf("41 ERR_PROTOTYPE\n\r");
    break;
  case 47:
    printf("47 ERR_AFNOSUPPORT\n\r");
    break;
  case 53:
    printf("53 ERR_ECONNABORTED\n\r");
    break;
  case 54:
    printf("54 ERR_CONNRESET\n\r");
    break;
  case 57:
    printf("57 ERR_NOTCONN\n\r");
    break;
  case 65:
    printf("65 ERR_HOSTUNREACH\n\r");
    break;
  default:
    printf("%u UNKNOWN ERROR\n\r", error);
    break;
  }
  YIELD();
  do
  {
    key = _low_level_get();
  } while (key == 0);
}

unsigned char OpenSock(unsigned char family, unsigned char protocol)
{
  unsigned char socket, retry = 150;
  unsigned int todo;
  todo = OS_NETSOCKET((family << 8) + protocol);
  if (todo > 32767)
  {
    printf("OS_NETSOCKET: ");
    errorPrint(todo & 255);
    exit(0);
  }
  else
  {
    socket = ((todo & 65280) >> 8);
    // printf ("OS_NETSOCKET: Socket #%d created\n\r", socket);
  }
  return socket;
}

unsigned char netConnect(unsigned char socket)
{
  unsigned int todo;

  targetadr.family = AF_INET;
  targetadr.porth = 00;
  targetadr.portl = 80;
  targetadr.b1 = 217;
  targetadr.b2 = 146;
  targetadr.b3 = 69;
  targetadr.b4 = 13;

  todo = OS_NETCONNECT(socket, &targetadr);
  if (todo > 32767)
  {
    printf("OS_NETCONNECT: ");
    errorPrint(todo & 255);
    exit(0);
  }
  else
  {
    // printf("OS_NETCONNECT: connection successful, %u\n\r", (todo & 255));
  }
  return 0;
}

unsigned int tcpSend(unsigned char socket, unsigned int messageadr, unsigned int size)
{
  unsigned char retry = 150;
  unsigned int todo;
  readStruct.socket = socket;
  readStruct.BufAdr = messageadr;
  readStruct.bufsize = size;
  readStruct.protocol = SOCK_STREAM;

wizwrite:
  todo = OS_WIZNETWRITE(&readStruct);
  if (todo > 32767)
  {

    if (retry == 0)
    {
      printf("OS_WIZNETWRITE: ");
      errorPrint(todo & 255);
      exit(0);
    }
    retry--;
    YIELD();
    delay(250);
    goto wizwrite;
  }
  else
  {
    //  printf("OS_WIZNETWRITE: %u bytes written. \n\r", todo);
  }
  return todo;
}

unsigned int tcpRead(unsigned char socket)
{
  unsigned char retry = 50;
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
      printf("OS_WIZNETREAD: ");
      errorPrint(err);
      if (err == 35)
      {
        return 0;
      }
      exit(0);
    }
    retry--;
    // printf("OS_WIZNETREAD: %u \n\r", retry);
    YIELD();
    YIELD();
    delay(100);
    goto wizread;
  }
  // printf("OS_WIZNETREAD: %u bytes read. \n\r", todo);
  return todo;
}

unsigned int cutHeader(unsigned int todo)
{
  unsigned int q, headlng;
  unsigned char *count;
  count = strstr(netbuf, "Content-Length:");
  if (count == NULL)
  {
    printf("contLen  not found \r\n");
    contLen = 0;
  }
  else
  {

    contLen = atol(count + 15);
    bytecount = contLen;
    // printf ("Dlinna  soderzhimogo = %lu \n\r", bytecount);
  }

  count = strstr(netbuf, "\r\n\r\n");
  if (count == NULL)
  {
    printf("header not found\r\n");
  }
  else
  {
    headlng = ((unsigned int)count - (unsigned int)netbuf + 4);
    q = todo - headlng;
    memcpy(&netbuf, count + 4, q);
    // printf ("header removed. %u bytes\r\n", headlng);
  }

  return q;
}

unsigned int netShutDown(unsigned char socket)
{
  unsigned int todo;
  todo = OS_NETSHUTDOWN(socket);
  if (todo > 32767)
  {
    printf("OS_NETSHUTDOWN: ");
    errorPrint(todo & 255);
    return 255;
  }
  else
  {
    // printf ("Socket #%u closed.\n\r", socket);
  }
  return 0;
}

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

void fillPicture(unsigned char socket)
{
  unsigned int todo, w, pPos, headskip;

  headskip = 0;
  pPos = 0;
  bytecount = 255;
  while (1)
  {
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
      picture[w + pPos] = netbuf[w];
    }
    bytecount = bytecount - todo;
    pPos = pPos + todo;
    if (bytecount == 0)
    {
      break;
    }
  }
  netShutDown(socket);
}

unsigned char getPic(unsigned long fileId)
{
  unsigned int todo;
  unsigned char buffer[] = "0000000000";
  unsigned char socket;
  socket = OpenSock(AF_INET, SOCK_STREAM);
  todo = netConnect(socket);
  netbuf[0] = '\0';
  sprintf(buffer, "%lu", fileId);
  strcat(netbuf, "GET /file/id:");
  strcat(netbuf, buffer);
  strcat(netbuf, " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0");
  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
  fillPicture(socket);
  return 0;
}
unsigned char savePic(unsigned long fileId)
{
  FILE *fp2;
  unsigned char afnSize, tfnSize;

  afnSize = sizeof(curFileStruct.afn) - 1;
  tfnSize = sizeof(curFileStruct.pfn) - 1;

  strcpy(curFileStruct.afn, curFileStruct.authorTitle);
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "\\", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "/", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, ":", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "*", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "?", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "<", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, ">", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "|", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, " ", "_");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "&#039;", "'");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "&amp;", "&");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "&quot;", "'");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "&gt;", ")");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "&lt;", "(");
  str_replace(curFileStruct.afn, afnSize, curFileStruct.afn, "\"", "'");

  strcpy(curFileStruct.pfn, curFileStruct.picName);

  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "\\", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "/", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, ":", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "*", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "?", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "<", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, ">", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "|", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, " ", "_");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "&#039;", "'");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "&amp;", "&");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "&quot;", "'");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "&gt;", ")");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "&lt;", "(");
  str_replace(curFileStruct.pfn, tfnSize, curFileStruct.pfn, "\"", "'");

  sprintf(curFileStruct.fileName, "%s-%s.scr", curFileStruct.afn, curFileStruct.pfn);

  fp2 = OS_CREATEHANDLE(curFileStruct.fileName, 0x80);
  if (((int)fp2) & 0xff)
  {
    printf(curFileStruct.fileName);
    printf(" creating error\r\n");
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
  netbuf[0] = '\0';
  n = pos(picture, property, 1, 0);
  if (n == -1)
  {
    strcpy(netbuf, "Not Found");
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
  netbuf[targetPos] = '\0';

  for (w = lng + 1; w < targetPos + 1; w++)
  {
    netbuf[w - lng - 1] = netbuf[w];
  }
}

unsigned long processJson(unsigned long startPos, unsigned char limit, unsigned char queryNum)
{
  unsigned int retry, tSize;
  unsigned int todo, pPos, headskip;
  unsigned char buffer[] = "000000000";
  unsigned char *count, socket;
  unsigned char userAgent[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; GetPic)\r\n\r\n\0";
  retry = 10;
  netbuf[0] = '\0';
  switch (queryNum)
  {
  case 0:
    strcat(netbuf, "GET /api/export:zxPicture/filter:zxPictureType=standard/limit:");
    sprintf(buffer, "%u", limit);
    strcat(netbuf, buffer);
    strcat(netbuf, "/start:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, "/order:date,desc");
    strcat(netbuf, userAgent);
    break;
  case 3: // /api/export:author/filter:authorId=2202
    strcat(netbuf, "GET /api/export:author/filter:authorId=");
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

rejson:
  socket = OpenSock(AF_INET, SOCK_STREAM);
  netConnect(socket);

  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));

  headskip = 0;
  pPos = 0;
  fillPicture(socket);

  count = strstr(picture, "responseStatus\":\"success");
  if (count == NULL)
  {
    ATRIB(91);
    printf("BAD JSON, NO responseStatus: success. %u   \r\n", retry);
    retry--;
    YIELD();
    if (retry > 0)
      goto rejson;
    return -1;
  }

  count = strstr(picture, "\"id\":");
  if (count == NULL)
  {
    ATRIB(91);
    printf("BAD JSON: ID not found.\r\n");
    return -2;
  }

  netbuf[0] = '\0';
  if (queryNum < 3)
  {
    parseJson("\"id\":");
    curFileStruct.picId = atol(netbuf);
    parseJson(",\"title\":\"");
    convert866();
    strcpy(curFileStruct.picName, netbuf);

    tSize = sizeof(curFileStruct.picName);
    str_replace(curFileStruct.picName, tSize, curFileStruct.picName, "&#039;", "'");
    str_replace(curFileStruct.picName, tSize, curFileStruct.picName, "&amp;", "&");
    str_replace(curFileStruct.picName, tSize, curFileStruct.picName, "&gt;", ">");
    str_replace(curFileStruct.picName, tSize, curFileStruct.picName, "&lt;", "<");
    str_replace(curFileStruct.picName, tSize, curFileStruct.picName, "&quot;", "\"");
    str_replace(curFileStruct.picName, tSize, curFileStruct.picName, "\\/", "/");

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
  printf("%lu \r\n", curFileStruct.totalAmount);
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
  printf("%u", curFileStruct.picYear);
  printf(" \r\n");
  ATRIB(93);
  printf(" AuthorsIDs ");
  ATRIB(97);
  printf("%s", curFileStruct.authorIds);
  ATRIB(93);
  printf(" Real name: ");
  ATRIB(97);
  printf("%s", curFileStruct.authorRealName);
  printf(" \r\n");
  ATRIB(96);
  printf(" \r\n");
}

C_task main(void)
{
  unsigned char errno, keypress, verbose;
  unsigned long ipadress;
  long iddqd, idkfa;
  os_initstdio();

  count = 0;
  verbose = 1;

  BOX(1, 1, 80, 25, 40);
  AT(1, 1);
  ATRIB(97);
  ATRIB(40);
  printf("              GETPIC [%s] zxart.ee picture viewer for nedoNET\n\r", ver);
  ATRIB(33);
  ATRIB(40);
  printf(" Управление:\n\r");
  printf("	'ESC' - выход из программы;\n\r");
  printf("	'<-' или 'B' к последним картинкам;\n\r");
  printf("	'->' или 'Пробел' к более старым картинкам\n\r");
  printf("	'J' Прыжок на  указанную по счету картинку\n\r");
  printf("	'I' Просмотр экрана информации о картинках\n\r");
  printf("	'S' Сохранить картинку на диск в текущую папку\n\r");
  printf("	'V' не выводить информацию об авторах\n\r");
  printf("	----------------Нажмите любую кнопку----------------\n\r");
  /*
    ipadress = OS_DNSRESOLVE("zxart.ee");
    printf("\n\r  OS_DNSRESOLVE =  %lu \n\r", ipadress);
    printf("------------------------\n\r");
  */
  AT(1, 11);
  do
  {
    key = _low_level_get();
  } while (key == 0);

start:
  iddqd = processJson(count, 1, 0);
  if (iddqd < 0)
  {
    exit(0);
  }
  idkfa = processJson(atol(curFileStruct.authorIds), 0, 99);
  if (idkfa < 0)
  {
    printf("curFileStruct.authorIds = %s \r\n", curFileStruct.authorIds);
    // exit(0);
  }

  if (verbose == 1)
  {
    printData();
  }
  else
  {
    ATRIB(97);
    printf(" Getting picture...\r\n");
  }
  if (!strcmp(curFileStruct.picType, "standard"))

  {
    errno = getPic(iddqd);
  review:
    keypress = viewScreen6912((unsigned int)&picture);
  }
  else
  {
    printf("  >>Format %s not supported, skipped \n\r", curFileStruct.picType);
    count++;
    goto start;
  }

  if (keypress == 's' || keypress == 'S')
  {
    savePic(iddqd);
    printf("        ID:%lu    TITLE:%s  SAVED\r\n\r\n", curFileStruct.picId, curFileStruct.picName);
    count++;
  }

  if (keypress == 27)
  {
    printf("Good bye...\r\n");
    ATRIB(37);
    ATRIB(40);
    exit(0);
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

  if (keypress == 'i' || keypress == 'I')
  {
    do
    {
      key = _low_level_get();
    } while (key == 0);
    goto review;
  }

  if (keypress == 'v' || keypress == 'V')
  {
    verbose = !verbose;
  }
  goto start;
}
