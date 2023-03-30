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

unsigned char netbuf[1452];
unsigned char dataBuffer[8192];
unsigned char crlf[2] = {13, 10};
unsigned long bytecount;
unsigned char status, key;
struct sockaddr_in targetadr;
struct readstructure readStruct;
unsigned long contLen;
long count;
unsigned char saveFlag, shuffleFlag;
union APP_PAGES main_pg;
extern void dns_resolve(void);

struct fileStruct
{
  long picId;
  unsigned long fileSize;
  unsigned int picYear;
  unsigned long totalAmount;
  unsigned char picRating[8];
  unsigned char picName[255];
  unsigned char fileName[64];
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
  //    do {key = _low_level_get();} while (key == 0);
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

unsigned int tcpRead(unsigned char socket)
{
  unsigned char retry = 150;
  unsigned int err, todo;

  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = sizeof(netbuf);
  readStruct.protocol = SOCK_STREAM;
wizread:
  todo = OS_WIZNETREAD(&readStruct);
  err = todo & 255;
  if (todo > 32767)
  {
    if (bytecount == 0)
      return 0;
    if (retry == 0)
    {
      printf("OS_WIZNETREAD: ");
      errorPrint(err);
      exit(0);
    }
    retry--;
    YIELD();
    delay(100);
    goto wizread;
  }
  // printf("OS_WIZNETREAD: %u bytes read. \n\r", todo);
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
    // printf ("Socket #%u closed.\n\r", socket);
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
unsigned int cutHeader(unsigned int todo)
{
  unsigned int q, headlng;
  unsigned char *count;
  count = strstr(netbuf, "Content-Length:");
  if (count == NULL)
  {
    printf("Content-Length:  not found \r\n");
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
  unsigned char fileName[32];
  unsigned char buffer[] = "0000000000";
  unsigned long fileSize;
  strcpy(fileName, "pt3/za");
  sprintf(buffer, "%lu", fileId);
  strcat(fileName, buffer);
  strcat(fileName, ".pt3");
  if (saveFlag == 0)
  {
    strcpy(fileName, "pt3/temp.pt3");
  }

  strcpy(curFileStruct.fileName, fileName);

  if (operation == 00)
  {
    fp2 = OS_CREATEHANDLE(fileName, 0x80);
    if (((int)fp2) & 0xff)
    {
      printf(fileName);
      printf(" creating error\r\n");
      exit(0);
    }
    OS_CLOSEHANDLE(fp2);
    return 0;
  }

  if (operation == 01)
  {
    fp2 = OS_OPENHANDLE(fileName, 0x80);
    if (((int)fp2) & 0xff)
    {
      printf(fileName);
      printf(" opening error\r\n");
      exit(0);
    }
    fileSize = OS_GETFILESIZE(fp2);
    OS_SEEKHANDLE(fp2, fileSize);
    OS_WRITEHANDLE(dataBuffer, fp2, sizeOfBuf);
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

// Процедура получения данных от сервера
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
      printf("dataBuffer overrun... \n\r");
      break;
    }

    for (w = 0; w < bytes2read; w++)
    {
      dataBuffer[w + bPos] = netbuf[w];
    }
    bytecount = bytecount - bytes2read;
    bPos = bPos + bytes2read;
  }
  netShutDown(socket);
}

// Процедура отправки TCP запроса серверу
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
    printf("OS_WIZNETWRITE: ");
    errorPrint(todo & 255);
    if (retry == 0)
    {
      exit(0);
    }
    retry--;
    YIELD();
    delay(100);
    goto wizwrite;
  }
  else
  {
    //  printf("OS_WIZNETWRITE: %u bytes written. \n\r", todo);
  }
  return todo;
}

// Процедура парсинга JSON от zxart.ee от полученя до заполнения структуры трека, возвращает ID работы.
unsigned long processJson(unsigned long startPos, unsigned char limit)
{
  unsigned int retry;
  unsigned int todo;
  unsigned char cmdlist1[] = "GET /api/export:zxMusic/filter:zxMusicFormat=pt3/limit:";
  unsigned char cmdlist2[] = "\/start:";
  unsigned char cmdlist3[] = "\/order:date,desc HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0";
  unsigned char buffer[] = "000000000";
  unsigned char *count, socket;
  retry = 20;

  netbuf[0] = '\0';
  strcat(netbuf, cmdlist1);
  sprintf(buffer, "%u", limit);
  strcat(netbuf, buffer);
  strcat(netbuf, cmdlist2);
  sprintf(buffer, "%lu", startPos);
  strcat(netbuf, buffer);
  strcat(netbuf, cmdlist3);
rejson: //  GetPic upd
  socket = OpenSock(AF_INET, SOCK_STREAM);
  netConnect(socket);

  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));

  getData(socket);
  count = strstr(dataBuffer, "responseStatus\":\"success");
  if (count == NULL)
  {
    printf("BAD JSON, NO responseStatus: success. %u\r\n", retry);
    retry--;
    YIELD();
    if (retry > 0)
      goto rejson;
    return -1;
  }
  count = strstr(dataBuffer, "\"id\":");
  if (count == NULL)
  {
    printf("BAD JSON: ID not found \r\n");
    return -2;
  }
  netbuf[0] = '\0';

  parseJson("\"id\":");
  curFileStruct.picId = atol(netbuf);

  parseJson(",\"title\":\"");
  convert866();
  strcpy(curFileStruct.picName, netbuf);

  parseJson("\"rating\":\"");
  strcpy(curFileStruct.picRating, netbuf);

  parseJson("\"year\":\"");
  curFileStruct.picYear = atoi(netbuf);
  parseJson("\"totalAmount\":");
  curFileStruct.totalAmount = atol(netbuf);

  return curFileStruct.picId;
}

void getData2(unsigned char socket)
{
  unsigned int todo, w, bPos, bytes2read, headskip;

  headskip = 0;
  bPos = 0;
  bytecount = 255;

  saveBuf(curFileStruct.picId, 00, 0);

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
    /*
        if (bPos + bytes2read > sizeof(dataBuffer))
        {
          printf("dataBuffer overrun... \n\r");
          break;
        }
    */
    for (w = 0; w < bytes2read; w++)
    {
      dataBuffer[w + bPos] = netbuf[w];
    }
    bytecount = bytecount - bytes2read;
    // bPos = bPos + bytes2read;
    bPos = 0;
    saveBuf(curFileStruct.picId, 01, bytes2read);
  }
  // saveBuf(curFileStruct.picId, 02, 0);
  netShutDown(socket);
}

unsigned char getPic(unsigned long fileId)
{
  unsigned int todo;
  unsigned char cmdlist1[] = "GET \/file\/id:";
  unsigned char cmdlist2[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0";
  unsigned char buffer[] = "0000000000";
  unsigned char socket;
  socket = OpenSock(AF_INET, SOCK_STREAM);
  todo = netConnect(socket);
  netbuf[0] = '\0';
  sprintf(buffer, "%lu", fileId);
  strcat(netbuf, cmdlist1);
  strcat(netbuf, buffer);
  strcat(netbuf, cmdlist2);
  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
  getData2(socket);
  return 0;
}

unsigned char runPlayer(void)
{
  FILE *fp2;
  unsigned char fileName[] = "player.ovl";
  unsigned char appCmd[128] = "player.com ";
  unsigned char curPath[128];
  union APP_PAGES player_pg;
  unsigned long playerSize, loaded, loop;
  unsigned char pgbak;
  unsigned int waitRet;
  strcat(appCmd, curFileStruct.fileName);
  player_pg.l = OS_GETMAINPAGES();
  pgbak = main_pg.pgs.window_3;
  loaded = 0;
  OS_GETPATH((unsigned int)&curPath);
  // OS_SETSYSDRV();
  fp2 = OS_OPENHANDLE(fileName, 0x80);
  if (((int)fp2) & 0xff)
  {
    printf(fileName);
    printf(" not found.\r\n");
    exit(0);
  }
  playerSize = OS_GETFILESIZE(fp2);
  OS_CHDIR((unsigned int)&curPath);
  OS_NEWAPP((unsigned int)&player_pg);
  SETPG32KHIGH(player_pg.pgs.window_3);
  memcpy((char *)(0xc080), &appCmd, sizeof(appCmd));
  for (loop = 0; loop < playerSize; loop = loop + loaded)
  {
    loaded = OS_READHANDLE(dataBuffer, fp2, sizeof(dataBuffer));
    memcpy((char *)(0xc100 + loop), &dataBuffer, loaded);
  }
  OS_CLOSEHANDLE(fp2);
  SETPG32KHIGH(pgbak);

  OS_RUNAPP(player_pg.pgs.pId);
  waitRet = OS_WAITPID(player_pg.pgs.pId);
  return waitRet;
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
  case 2: // shuffle
    count = rand() % curFileStruct.totalAmount + 1;
    break;
  }
  if (shuffleFlag == 1)
  {
    count = rand() % curFileStruct.totalAmount + 1;
  }
  return count;
}

C_task main(void)
{
  unsigned char errno, keypress;
  long iddqd, ipadress;
  // unsigned int newPage;
  os_initstdio();
  srand(time());
  count = 0;
  saveFlag = 0;

  BOX(1, 1, 80, 25, 40);
  AT(1, 1);
  ATRIB(97);
  ATRIB(40);
  printf("              ZXART.EE RADIO 1.0 pt3 radio for nedoNET\n\r");
  ATRIB(33);
  ATRIB(40);

  /*
    ipadress = OS_DNSRESOLVE("zxart.ee");
    printf("\n\r  OS_DNSRESOLVE =  %lu \n\r", ipadress);
    printf("------------------------\n\r");
    printf("OS_GETPATH = %s\r\n", curPath);
  */

start:
  iddqd = processJson(count, 1);
  if (iddqd < 0)
  {
    exit(0);
  }

  BOX(1, 1, 80, 2, 40);
  AT(1, 1);

  ATRIB(97);
  printf(" #:%lu ID:%lu	\r\n", count, curFileStruct.picId);
  ATRIB(96);
  printf(" TITLE:%s\r\n", curFileStruct.picName);
  ATRIB(93);
  printf(" RATING:%s  YEAR:%u \r\n", curFileStruct.picRating, curFileStruct.picYear);
  ATRIB(97);
  printf("\r\n [K]Keep files: %u [S]Shuffle: %u\r\n", saveFlag, shuffleFlag);

  curFileStruct.fileSize = 0;
  errno = getPic(iddqd);
  keypress = runPlayer();
  // printf(" keypress =  %u\r\n", keypress);

  if (keypress == 27)
  {
    printf("Good bye...\r\n");
    ATRIB(37);
    ATRIB(40);
    exit(0);
  }
  if (keypress == 248 || keypress == 'b' || keypress == 'B')
  {
    count = trackSelector(1);
    goto start;
  }

  if (keypress == 251 || keypress == 32 || keypress == 'n' || keypress == 'N')
  {
    count = trackSelector(0);
    goto start;
  }

  if (keypress == 's' || keypress == 'S')
  {
    count = trackSelector(2);
    shuffleFlag = !shuffleFlag;
    goto start;
  }

  if (keypress == 'k' || keypress == 'K')
  {
    saveFlag = !saveFlag;
    goto start;
  }

  if (keypress == 'j' || keypress == 'J')
  {
    printf("Jump to track:");
    scanf("%lu", &count);
    goto start;
  }
  count = trackSelector(0);
  goto start;
  /*
    main_pg.l = OS_GETMAINPAGES();
    printf("window_3 = %u\r\n", main_pg.pgs.window_3);

    newPage = OS_NEWPAGE();
    printf("newPage = %u\r\n", newPage);

    SETPG32KHIGH(newPage);

    main_pg.l = OS_GETMAINPAGES();
    printf("window_3 = %u\r\n", main_pg.pgs.window_3);

    OS_GETPATH((unsigned int)&dataBuffer);
    printf("OS_GETPATH = %s\r\n", dataBuffer);
    strcpy(dataBuffer, "");

    OS_SETSYSDRV();

    OS_GETPATH((unsigned int)&dataBuffer);
    printf("OS_GETPATH = %s\r\n", dataBuffer);

    OS_CHDIR((unsigned int)&"kapps");

    OS_GETPATH((unsigned int)&dataBuffer);
    printf("OS_GETPATH = %s\r\n", dataBuffer);

    OS_NEWAPP((unsigned int)&main_pg);

    printf("window_3 = %u\r\n", main_pg.pgs.window_3);
    printf("window_2 = %u\r\n", main_pg.pgs.window_2);
    printf("window_1 = %u\r\n", main_pg.pgs.window_1);
    printf("window_0 = %u\r\n", main_pg.pgs.window_0);
    printf("pId = %u\r\n", main_pg.pgs.pId);
    printf("error = %u\r\n", main_pg.pgs.error);

    memcpy((char *)(0xc000 + COMMANDLINE), &main_pg, 6);

    // OS_RUNAPP(main_pg.pgs.pId);

    printf("%u started...\r\n", main_pg.pgs.pId);
  */
}
