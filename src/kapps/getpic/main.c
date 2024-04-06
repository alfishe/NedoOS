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
  unsigned char afn[128];
  unsigned char pfn[128];
  unsigned char fileName[128];
} curFileStruct;
unsigned char ver[] = "2.4";
unsigned char netbuf[2048];
unsigned char picture[16384];
unsigned char crlf[2] = {13, 10};
unsigned char status, keypress, verbose, randomPic, slideShow;
struct sockaddr_in targetadr;
struct readstructure readStruct;
unsigned long contLen;
unsigned long count;
unsigned int headlng;
unsigned int slideShowTime = 0;

struct packetStruct
{
  unsigned long contLen;
  unsigned int headlng;
} pack;

void emptyKeys(void)
{
  unsigned char loop, key = 1;
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
    printf("] Press any key.");
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

  targetadr.family = AF_INET;
  targetadr.porth = 00;
  targetadr.portl = 80;
  targetadr.b1 = 217;
  targetadr.b2 = 146;
  targetadr.b3 = 69;
  targetadr.b4 = 13;
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
      socket = OpenSock(AF_INET, SOCK_STREAM);
    }
    else
    {
      // printf("OS_NETCONNECT: connection successful, %u\n\r", (todo & 255));
      return 1;
    }
  }
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
  unsigned int q;
  unsigned char *count1;
  count1 = strstr(netbuf, "Content-Length:");
  if (count1 == NULL)
  {
    printf("contLen  not found \r\n");
    contLen = 0;
  }
  else
  {
    contLen = atol(count1 + 15);
    // printf ("Dlinna  soderzhimogo = %lu \n\r", contLen);
  }

  count1 = strstr(netbuf, "\r\n\r\n");
  if (count1 == NULL)
  {
    printf("header not found\r\n");
  }
  else
  {
    headlng = ((unsigned int)count1 - (unsigned int)netbuf + 4);
    q = todo - headlng;
    // printf("header removed. %u bytes\r\n", headlng);
  }

  return q;
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

void fillPicture(signed char socket)
{
  unsigned int todo, w, pPos, headskip;
  headskip = 0;
  pPos = 0;
  while (1)
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
    // memcpy(&picture + pPos, &netbuf + headlng, todo );

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
  unsigned char buffer[] = "0000000000";
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
    if (curFileStruct.afn[len] < ' ')
    {
      curFileStruct.afn[len] = '_';
    }
  }

  for (len = 0; len < strlen(curFileStruct.pfn); len++)
  {
    if (curFileStruct.pfn[len] < ' ')
    {
      curFileStruct.pfn[len] = '_';
    }
  }
}

unsigned char savePic(unsigned long fileId)
{
  FILE *fp2;
  unsigned char afnSize, tfnSize;
  unsigned char fileIdChar[10];

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
  unsigned char buffer[] = "000000000";
  unsigned char *count1, socket;
  unsigned char userAgent[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; GetPic)\r\n\r\n\0";

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
    socket = OpenSock(AF_INET, SOCK_STREAM);
    netConnect(socket);
    todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
    fillPicture(socket);

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

  netbuf[0] = '\0';
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
}

C_task main(void)
{
  unsigned char errno;
  unsigned long ipadress;
  long iddqd, idkfa;
  os_initstdio();

  count = 0;
  verbose = 1;
  randomPic = 0;
  slideShow = 0;

  BOX(1, 1, 80, 25, 40);
  AT(1, 1);
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

  errno = getPic(iddqd);
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
