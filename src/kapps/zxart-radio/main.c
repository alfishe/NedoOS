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
unsigned char ver[] = "1.7";
unsigned char queryType[64];
unsigned char netbuf[1452];
unsigned char dataBuffer[6096];
unsigned char crlf[2] = {13, 10};
unsigned char formats[4][4] = {"pt3", "pt2", "tfc", "ts"};
unsigned long bytecount;
unsigned char status, key, curFormat;
struct sockaddr_in targetadr;
struct readstructure readStruct;
unsigned long contLen;
long count;
unsigned char saveFlag, saveBak, logFlag, rptFlag;
union APP_PAGES main_pg;
union APP_PAGES player_pg;
extern void dns_resolve(void);

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
    YIELD();
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
  AT(1, 25);
  switch (error)
  {
  case 2:
    printf("02 SHUT_RDWR         ");
    break;
  case 4:
    printf("04 ERR_INTR          ");
    break;
  case 23:
    printf("23 ERR_NFILE         ");
    break;
  case 35:
    printf("35 ERR_EAGAIN        ");
    break;
  case 37:
    printf("37 ERR_ALREADY       ");
    break;
  case 38:
    printf("38 ERR_NOTSOCK       ");
    break;
  case 40:
    printf("40 ERR_EMSGSIZE      ");
    break;
  case 41:
    printf("41 ERR_PROTOTYPE     ");
    break;
  case 47:
    printf("47 ERR_AFNOSUPPORT   ");
    break;
  case 53:
    printf("53 ERR_ECONNABORTED  ");
    break;
  case 54:
    printf("54 ERR_CONNRESET     ");
    break;
  case 57:
    printf("57 ERR_NOTCONN       ");
    break;
  case 65:
    printf("65 ERR_HOSTUNREACH   ");
    break;
  default:
    printf("%u UNKNOWN ERROR     ", error);
    break;
  }
  YIELD();
  //    do {key = _low_level_get();} while (key == 0);
}

unsigned char OpenSock(unsigned char family, unsigned char protocol)
{
  unsigned char socket;
  unsigned int todo;
  todo = OS_NETSOCKET((family << 8) + protocol);
  if (todo > 32767)
  {
    AT(1, 25);
    printf("OS_NETSOCKET: ");
    errorPrint(todo & 255);
    printf("                                  ");
    exit(0);
  }
  else
  {
    socket = ((todo & 65280) >> 8);
    if (logFlag)
    {
      AT(1, 25);
      printf("OS_NETSOCKET: Socket #%d created               ", socket);
    }
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
    AT(1, 25);
    printf("OS_NETCONNECT: ");
    errorPrint(todo & 255);
    printf("                        ");
    exit(0);
  }
  else
  {
    if (logFlag)
    {
      AT(1, 25);
      printf("OS_NETCONNECT: connected , %u            ", (todo & 255));
    }
  }
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
      AT(1, 25);
      printf("OS_WIZNETREAD: ");
      errorPrint(err);
      if (err == 35)
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
    AT(1, 25);
    printf("OS_WIZNETREAD: %u bytes read.            ", todo);
  }
  return todo;
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
    if (logFlag)
    {
      AT(1, 25);
      printf("OS_NETSHUTDOWN: Socket #%u closed.                 ", socket);
    }
  }
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

unsigned int cutHeader(unsigned int todo)
{
  unsigned int q, headlng;
  unsigned char *count;
  count = strstr(netbuf, "Content-Length:");
  if (count == NULL)
  {
    AT(1, 25);
    printf("Content-Length:  not found          ");
    contLen = 0;
  }
  else
  {
    contLen = atol(count + 15);
    bytecount = contLen;
    curFileStruct.fileSize = bytecount;
    //  printf("=> Dlinna  soderzhimogo = %lu \n\r", curFileStruct.fileSize);
  }

  count = strstr(netbuf, "\r\n\r\n");
  headlng = ((unsigned int)count - (unsigned int)netbuf + 4);
  q = todo - headlng;
  memcpy(&netbuf, count + 4, q);
  // printf ("header removed. %u bytes\r\n", headlng);
  return q;
}

unsigned char saveBuf(unsigned long fileId, unsigned char operation, unsigned int sizeOfBuf)
{
  FILE *fp2;
  unsigned long fileSize;
  unsigned char afnSize, tfnSize;

  if (saveFlag == 0)
  {
    sprintf(curFileStruct.fileName, "../downloads/radio/temp.%s", formats[curFormat]);
  }
  else
  {
    afnSize = sizeof(curFileStruct.afn) - 1;
    tfnSize = sizeof(curFileStruct.tfn) - 1;

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
    str_replace(curFileStruct.afn, tfnSize, curFileStruct.afn, "&#039;", "'");
    str_replace(curFileStruct.afn, tfnSize, curFileStruct.afn, "&amp;", "&");
    str_replace(curFileStruct.afn, tfnSize, curFileStruct.afn, "&quot;", "'");
    str_replace(curFileStruct.afn, tfnSize, curFileStruct.afn, "&gt;", ")");
    str_replace(curFileStruct.afn, tfnSize, curFileStruct.afn, "&lt;", "(");
    str_replace(curFileStruct.afn, tfnSize, curFileStruct.afn, "\"", "'");

    strcpy(curFileStruct.tfn, curFileStruct.trackName);

    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "\\", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "/", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, ":", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "*", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "?", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "<", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, ">", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "|", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, " ", "_");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "&#039;", "'");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "&amp;", "&");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "&quot;", "'");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "&gt;", ")");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "&lt;", "(");
    str_replace(curFileStruct.tfn, tfnSize, curFileStruct.tfn, "\"", "'");

    sprintf(curFileStruct.fileName, "../downloads/radio/%s-%s.%s", curFileStruct.afn, curFileStruct.tfn, formats[curFormat]);
  }

  if (operation == 00)
  {
    fp2 = OS_CREATEHANDLE(curFileStruct.fileName, 0x80);
    if (((int)fp2) & 0xff)
    {
      AT(1, 25);
      printf(curFileStruct.fileName);
      printf(" creating error. Check for  downloads\\radio folder     ");
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

      AT(1, 25);
      printf(curFileStruct.fileName);
      printf(" opening error               ");
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
  unsigned int todo, w, bPos, bytes2read, headskip;

  headskip = 0;
  bPos = 0;
  bytecount = 255;
  while (1)
  {
    todo = tcpRead(socket);
    if (todo == 0)
    {
      break;
    }
    bytes2read = todo;
    if (headskip == 0)
    {
      headskip = 1;
      bytes2read = cutHeader(todo);
    }

    if (bPos + bytes2read > sizeof(dataBuffer))
    {
      AT(1, 25);
      printf("dataBuffer overrun...               ");
      break;
    }

    for (w = 0; w < bytes2read; w++)
    {
      dataBuffer[w + bPos] = netbuf[w];
    }
    bytecount = bytecount - bytes2read;
    bPos = bPos + bytes2read;
    if (bytecount == 0)
    {
      dataBuffer[bytes2read + bPos + 1] = '\0';
      break;
    }
  }
  netShutDown(socket);
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
    AT(1, 25);
    printf("OS_WIZNETWRITE: ");
    errorPrint(todo & 255);
    printf("                       ");
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
      AT(1, 25);
      printf("OS_WIZNETWRITE: %u bytes written.           ", todo);
    }
  }
  return todo;
}

unsigned long processJson(unsigned long startPos, unsigned char limit, unsigned char queryNum)
{
  FILE *fp3;
  unsigned int retry, tnSize;
  unsigned int todo;
  unsigned char buffer[] = "000000000";
  unsigned char *count, socket;
  unsigned char userAgent[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; Radio)\r\n\r\n\0";
  unsigned char userQuery[256] = "/api/export:zxMusic/limit:10/filter:zxMusicId=44816";
  AT(1, 25);
  printf("Getting data(%u)...                                   ", queryNum);

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
rejson:
  socket = OpenSock(AF_INET, SOCK_STREAM);
  netConnect(socket);

  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));

  getData(socket);

  AT(1, 25);
  printf("Processing data (%u)...                  ", queryNum);

  count = strstr(dataBuffer, "responseStatus\":\"success");
  if (count == NULL)
  {
    AT(1, 25);
    printf("BAD JSON, NO responseStatus: success. (%u)                    ", retry);
    retry--;
    YIELD();
    if (retry > 0)
    {
      netShutDown(socket);
      goto rejson;
    }
    // AT(1, 1);
    // printf("BAD JSON, NO responseStatus: success. JSON: %s \r\n", dataBuffer);
    // getchar();
    return -1;
  }

  count = strstr(dataBuffer, "\"id\":");
  if (count == NULL)
  {
    AT(1, 25);
    printf("BAD JSON: not ID query = %u startPos = %lu          ", queryNum, startPos);
    // AT(1, 10);
    // printf("BAD JSON: ID not found JSON:\r\n %s \r\n", dataBuffer);
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

    tnSize = sizeof(curFileStruct.trackName);
    str_replace(curFileStruct.trackName, tnSize, curFileStruct.trackName, "&#039;", "'");
    str_replace(curFileStruct.trackName, tnSize, curFileStruct.trackName, "&amp;", "&");
    str_replace(curFileStruct.trackName, tnSize, curFileStruct.trackName, "&gt;", ">");
    str_replace(curFileStruct.trackName, tnSize, curFileStruct.trackName, "&lt;", "<");
    str_replace(curFileStruct.trackName, tnSize, curFileStruct.trackName, "&quot;", "\"");
    str_replace(curFileStruct.trackName, tnSize, curFileStruct.trackName, "\\/", "/");

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

unsigned char getTrack(unsigned long fileId)
{
  unsigned int todo;
  unsigned char cmdlist1[] = "GET /file/id:";
  unsigned char cmdlist2[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; Radio)\r\n\r\n\0";
  unsigned char buffer[] = "0000000000";
  unsigned char socket;
  unsigned int bytes2read, headskip;
  AT(1, 25);
  printf("Getting track...                      ");

  socket = OpenSock(AF_INET, SOCK_STREAM);
  todo = netConnect(socket);
  netbuf[0] = '\0';
  sprintf(buffer, "%lu", fileId);
  strcat(netbuf, cmdlist1);
  strcat(netbuf, buffer);
  strcat(netbuf, cmdlist2);
  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));

  headskip = 0;
  bytecount = 255;
  saveBuf(curFileStruct.picId, 00, 0);
  while (bytecount != 0)
  {
    todo = tcpRead(socket);
    if (todo == 0)
    {
      break;
    }
    bytes2read = todo;
    if (headskip == 0)
    {
      headskip = 1;
      bytes2read = cutHeader(todo);
    }
    saveBuf(curFileStruct.picId, 01, bytes2read);
    bytecount = bytecount - bytes2read;
  }
  netShutDown(socket);
  return 0;
}

unsigned char runPlayer(void)
{
  FILE *fp2;
  unsigned char fileName[] = "radio/player.ovl";
  unsigned char appCmd[128] = "player.com ";
  unsigned char curPath[128];
  unsigned long playerSize, loaded, loop;
  unsigned char pgbak;

  AT(1, 25);
  printf("Running player...                   ");

  strcat(appCmd, curFileStruct.fileName);
  player_pg.l = OS_GETMAINPAGES();
  pgbak = main_pg.pgs.window_3;
  loaded = 0;
  OS_GETPATH((unsigned int)&curPath);
  // OS_SETSYSDRV();
  fp2 = OS_OPENHANDLE(fileName, 0x80);
  if (((int)fp2) & 0xff)
  {
    AT(1, 25);
    printf(fileName);
    printf(" not found.               ");
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
  printf(" [E]Exit        [%s]\r\n", ver);

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

void printHelp(void)
{
  AT(1, 13);
  ATRIB(97);
  printf(" [E] or [ESC] Exit to OS           \r\n");
  printf(" [B] or [<--] Previous track       \r\n");
  printf(" [ ] or [-->] Next track    \r\n");
  printf(" [S]          Stop player          \r\n");
  printf(" [K]          Toggle saving tracks \r\n");
  printf(" [Q]          Select Query type    \r\n");
  printf(" [D]          Download track       \r\n");
  printf(" [R]          Repeat track mode    \r\n");
  printf(" [J]          Jump to NNNN file from newest  \r\n");
  printf(" [F]          Change tracks format to play   \r\n");
  printf(" [L]          Toggle operation logging       \r\n");
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

C_task main(void)
{
  unsigned char errn, keypress, queryNum, pId, alive, changedFormat;
  long iddqd, idkfa, ipadress;
  unsigned long curTimer, startTimer, oldTimer;
  os_initstdio();
  srand(time());
  count = 0;
  saveFlag = 0;
  queryNum = 0;
  curFormat = 0;
  changedFormat = 0;
  rptFlag = 0;
  strcpy(queryType, "from newest to oldest");

  BOX(1, 1, 80, 25, 40);
  AT(1, 1);
  ATRIB(97);
  ATRIB(45);
  printf("                           ZXART.EE radio for nedoNET                           \n\r");
  AT(1, 24);
  printf("  [L]Enable logging(press on startup)                                          ");

  ATRIB(33);
  ATRIB(40);

  /*
    ipadress = OS_DNSRESOLVE("zxart.ee");
    printf("\n\r  OS_DNSRESOLVE =  %lu \n\r", ipadress);
    printf("------------------------\n\r");
    printf("OS_GETPATH = %s\r\n", curPath);
  */

  keypress = _low_level_get();
  if (keypress == 'l' || keypress == 'L')
  {
    logFlag = 1;
    AT(1, 25);
    printf("Logging enabled   ");
    getchar();
  }

start:
  OS_SETSYSDRV();
  printHelp();
  curFileStruct.fileSize = 0;

  iddqd = processJson(count, 1, queryNum); // Query for track info
  if (iddqd < 0)
  {
    {
      AT(1, 25);
      printf("Error getting track info, next please(%ld)...     ", iddqd);
      count = trackSelector(0);
      goto start;
    }
  }

  idkfa = processJson(atol(curFileStruct.authorIds), 0, 99); // Query for AuthorID

  if (idkfa < 0)
  {
    AT(1, 25);
    printf("Error getting author %lu                  ", atol(curFileStruct.authorIds));
    strcpy(curFileStruct.authorTitle, " Error getting Tittle ");
    strcpy(curFileStruct.authorRealName, " \0");
  }
replay:
  errn = getTrack(iddqd); // Downloading the track
resume:
  startTimer = time();
  printProgress(0);
  pId = runPlayer(); // Start thr Player!
  printStatus();
  printInfo();
rekey:
  YIELD();
  keypress = _low_level_get();
  if (keypress != 0)
  {
    if (keypress == 27 || keypress == 'e' || keypress == 'E')
    {
      OS_DROPAPP(pId);
      printf("Good bye... %u \r\n", pId);
      ATRIB(37);
      ATRIB(40);
      exit(0);
    }
    if (keypress == 248 || keypress == 'b' || keypress == 'B')
    {
      changedFormat = 0;
      OS_DROPAPP(pId);
      AT(1, 25);
      printf("Player stopped...                     ");
      count = trackSelector(1);
      goto start;
    }

    if (keypress == 251 || keypress == 32 || keypress == 'n' || keypress == 'N')
    {
      changedFormat = 0;
      OS_DROPAPP(pId);
      AT(1, 25);
      printf("Player stopped...                      ");
      count = trackSelector(0);
      goto start;
    }

    if (keypress == 'k' || keypress == 'K')
    {
      OS_DROPAPP(pId);
      AT(1, 25);
      printf("Player stopped...                   ");
      saveFlag = !saveFlag;
      printStatus();
      goto replay;
    }

    if (keypress == 'q' || keypress == 'Q')
    {
      OS_DROPAPP(pId);
      AT(1, 25);
      printf("Player stopped...                   ");
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
      goto start;
    }

    if (keypress == 'f' || keypress == 'F')
    {
      OS_DROPAPP(pId);
      AT(1, 25);
      printf("Player stopped...                   ");
      curFormat++;
      count = -1;
      if (curFormat > 3)
      {
        curFormat = 0;
      }
      changedFormat = 1;
      curFileStruct.totalAmount = 1;
      printStatus();
      printProgress(0);
      BOX(1, 2, 80, 6, 40);
      goto rekey;
    }

    if (keypress == 'l' || keypress == 'L')
    {
      logFlag = !logFlag;
      AT(1, 25);
      printf("Logging: %u                                                                     ", logFlag);
    }

    if (keypress == 's' || keypress == 'S')
    {
      OS_DROPAPP(pId);
      AT(1, 25);
      printf("Player stopped...                   ");
      printProgress(0);
      getchar();
      goto resume;
    }
    if (keypress == 'r' || keypress == 'R')
    {
      rptFlag = !rptFlag;
      AT(1, 25);
      printStatus();
    }
    if (keypress == 'd' || keypress == 'D')
    {
      saveBak = saveFlag;
      saveFlag = 1;
      errn = getTrack(iddqd); // Downloading the track
      saveFlag = saveBak;
      clearStatus();
      printf("Saving file %s...", curFileStruct.fileName);
    }
  }

  curTimer = time();
  curFileStruct.curPos = (curTimer - startTimer) / 50;
  alive = testPlayer();

  if (alive == 0 && !changedFormat)
  {
    if (rptFlag == 1)
    {
      goto resume;
    }
    printProgress(2);
    count = trackSelector(0);
    goto start;
  }

  if (alive == 1 && ((curTimer - oldTimer) > 49))
  {
    printProgress(1);
    oldTimer = curTimer;
  }

  YIELD();

  goto rekey;
}
