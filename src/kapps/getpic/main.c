#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include <../common/terminal.c>
#include <tcp.h>
//////////////////
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
unsigned int comType = 0;
unsigned int espType = 32;
unsigned int espRetry = 5;
unsigned long factor, timerok;
const unsigned int magic = 11;

struct fileStruct
{
  long picId;
  unsigned int picYear;
  unsigned long totalAmount;
  unsigned int httpErr;
  unsigned int extStatus;
  unsigned char picRating[8];
  unsigned char picName[256];
  unsigned char picType[32];
  unsigned char authorIds[64];
  unsigned char authorTitle[64];
  unsigned char authorRealName[64];
  unsigned char afn[120];
  unsigned char pfn[120];
  unsigned char fileName[128];
  unsigned char hasDescription;
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

unsigned char ver[] = "5.0";
// const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char buffer[] = "0000000000";
unsigned char userAgent[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; GetPic)\r\n\r\n\0";
unsigned char zxart[] = "zxart.ee";
unsigned char minRating[] = "0000000000";
unsigned char keypress, verbose, infoPressed, showDesc, randomPic, netDriver;

unsigned long contLen;
unsigned long count = 0;
unsigned int headlng;
unsigned int slideShowTime = 0;
unsigned int userInts;
unsigned int loaded;

unsigned char crlf[2] = {13, 10};
unsigned char cmd[512];
unsigned char fileIdChar[10];
unsigned char picture[14000];
unsigned char netbuf[4000];
unsigned char curPath[128];

void quit(void)
{
  OS_CLS(0);
  OS_SETGFX(-1);
  exit(0);
}

void clearStatus(void)
{
}

void waitKey(void)
{
  do
  {
    YIELD();
  } while (OS_GETKEY() == 0);
}

unsigned char delayLongKey(unsigned long counter)
{
  unsigned long curTime, finish;
  char key;
  counter = counter / 20;
  if (counter < 1)
  {
    counter = 1;
  }
  curTime = time();
  finish = curTime + counter;

  while (curTime < finish)
  {
    curTime = time();
    key = OS_GETKEY();
    if (key != 0)
    {
      if (key == 27)
      {
        quit();
      }
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

void printHelp(void)
{
  OS_CLS(0);
  OS_SETCOLOR(67);
  printf("   GETPIC [%s] zxart.ee picture viewer for NedoNET\n\r", ver);
  OS_SETCOLOR(6);
  printf("----------------------------------------------------------\n\r");
  printf("-----------GETPIC [Build:%s  %s]-----------\r\n", __DATE__, __TIME__);
  printf("----------------------------------------------------------\n\r");
  printf(" Управление:\n\r");
  printf("   'ESC' - выход из программы;\n\r");
  printf("   '<-' или 'B' к последним картинкам;\n\r");
  printf("   '->' или 'Пробел' к более старым картинкам\n\r");
  printf("   'J' Прыжок на  указанную по счету картинку\n\r");
  printf("   'I' Просмотр экрана информации о картинках\n\r");
  printf("   'S' Сохранить картинку на диск в текущую папку\n\r");
  printf("   'V' не выводить информацию об авторах\n\r");
  printf("   'R' переход в режим  случайная картинка с рейтингом 4+\n\r");
  printf("   'A' переход в режим  слайд-шоу\n\r");
  printf("   'D' Переключение режима ZXNETUSB/ESP-COM\n\r");
  printf("   'T' Продолжительность одного слайда в int-ах \n\r");
  printf("   'M' Минимальный рейтинг для случайного воспроизведения. \n\r");
  printf("   'O' Описание картинки. \n\r");
  printf("   'H' Данная справочная информация\n\r");
  printf("------------------Нажмите любую кнопку--------------------\n\r");
  OS_SETCOLOR(70);
  keypress = getchar();
  OS_CLS(0);
}

///////////////////////////
#include <../common/esp-com.c>
#include <../common/network.c>
//////////////////////////

int testOperation2(const char *process, int socket)
{
  if (socket < 0)
  {
    OS_SETGFX(0x86);
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
    sprintf(picture, "HTTP Error %u @ %lu(%ld)", curFileStruct.httpErr, count, curFileStruct.picId);
    writeLog(picture, "cutHeader      ");
    return 0;
  }
  count1 = strstr(netbuf, "Content-Length:");
  if (count1 == NULL)
  {
    writeLog("contLen not found", "cutHeader      ");
    contLen = 0;
    curFileStruct.httpErr = 999; // bad kostil
    return 0;
  }
  contLen = atol(count1 + 15);
  // printf("Content-Length: %lu \n\r", contLen);

  count1 = strstr(netbuf, "\r\n\r\n");
  if (count1 == NULL)
  {
    writeLog("end of header not found", "cutHeader      ");
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
  unsigned int sizeLink;
  unsigned int downloaded = 0;
  int todo;
  const unsigned char *count1;
  unsigned char firstPacket = true;
  unsigned int byte;
  strcpy(picture, netbuf);
  sizeLink = strlen(picture);

  do
  {
    sendcommand("AT+CIPSTART=\"TCP\",\"zxart.ee\",80");

    if (!getAnswer3()) // "CONNECT"
    {
      writeLog("Timeout 'AT+CIPSTART' return false", "fillPictureEsp ");
      return false;
    }
    count1 = strstr(netbuf, "CONNECT");
    if (count1 == NULL)
    {
      OS_SETGFX(0x86);
      writeLog("Error in AT+CIPSTART. Not 'CONNECT'.", "fillPictureEsp ");
      espReBoot();

      delayLongKey(1000);
    }
    else
    {
      break;
    }
  } while (42);

  if (!getAnswer3()) // OK
  {
    writeLog("Timeout waiting 'OK'", "fillPictureEsp ");
    return false;
  }

  sprintf(netbuf, "AT+CIPSEND=%u", sizeLink + 2); // second CRLF in send command
  sendcommand(netbuf);

  do
  {
    byte = uartReadBlock();
    if (byte > 255)
    {
      writeLog("Timeout when waiting '>' ", "fillPictureEsp ");
      return false;
    }

    // putchar(byte);
  } while (byte != '>');

  sendcommand(picture);

  downloaded = 0;
  firstPacket = true;
  do
  {
    headlng = 0;
    todo = recvHead();

    if (todo == 0)
    {
      writeLog("Error parsing packet size, todo = 0", "fillPictureEsp ");
      writeLog(netbuf, "fillPictureEsp ");
      return false;
    }

    if (!getdataEsp(todo))
    {
      OS_CLS(0);
      printf("[getdataEsp] Downloading timeout. Exit![%lu]\r\n", count);
      writeLog("Downloading timeout in getdataEsp. Exit!", "fillPictureEsp ");
      waitKey();
      exit(0);
    }

    if (firstPacket)
    {
      todo = cutHeader(todo);
      firstPacket = false;
      if (curFileStruct.httpErr != 200)
      {
        sendcommand("AT+CIPCLOSE");
        uartFlush(200);
        return false;
      }
    }

    if (downloaded + todo > sizeof(picture))
    {
      printf("dataBuffer overrun... %lu reached \n\r", downloaded + todo);
      getchar();
      return false;
    }

    memcpy(picture + downloaded, netbuf + headlng, todo);
    downloaded = downloaded + todo;
  } while (downloaded < contLen);
  sendcommand("AT+CIPCLOSE");

  if (!getAnswer3()) // CLOSED or ERROR
  {
    writeLog("Timeout  waiting CLOSED or ERROR continue", "fillPictureEsp ");
  }

  count1 = strstr(netbuf, "CLOSED");
  if (count1 != NULL)
  {
    if (!getAnswer3()) // OK
    {
      writeLog("Timeout  waiting OK after CLOSED continue", "fillPictureEsp ");
    }
  }
  // writeLog("Data downloaded", "fillPictureEsp ");
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
    testOperation2("OS_WIZNETREAD", todo); // Quit if too many retries

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
      OS_SETGFX(0x86);
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
  unsigned int i;
  unsigned int j;
  unsigned char c;

  i = 0;
  /* Цикл по всей строке, пока не встретим конец Си-строки или не упремся в лимит размера */
  while (pfn[i] != '\0' && i < tfnSize)
  {
    c = pfn[i];

    /* 1. Быстрая замена запрещенных в именах файлов символов (в один проход) */
    if (c == '\\' || c == '/' || c == ':' || c == '*' || c == '?' ||
        c == '<' || c == '>' || c == '|' || c == ' ' || c == '\"')
    {
      pfn[i] = '_';
      i++;
      continue;
    }

    /* 2. Обработка HTML-сущностей, специфичных для имен файлов */
    if (c == '&')
    {
      /* Замена &#039; на одиночную кавычку ' */
      if (strncmp((const char *)(pfn + i), "&#039;", 6) == 0)
      {
        pfn[i] = '\'';
        /* Сдвигаем хвост строки влево на 5 символов */
        j = i + 1;
        while ((pfn[j] = pfn[j + 5]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
      /* Замена &quot; на одиночную кавычку ' */
      if (strncmp((const char *)(pfn + i), "&quot;", 6) == 0)
      {
        pfn[i] = '\'';
        j = i + 1;
        while ((pfn[j] = pfn[j + 5]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
      /* Замена &amp; на значок & */
      if (strncmp((const char *)(pfn + i), "&amp;", 5) == 0)
      {
        pfn[i] = '&';
        j = i + 1;
        while ((pfn[j] = pfn[j + 4]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
      /* Замена &gt; на закрывающую скобку ) */
      if (strncmp((const char *)(pfn + i), "&gt;", 4) == 0)
      {
        pfn[i] = ')';
        j = i + 1;
        while ((pfn[j] = pfn[j + 3]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
      /* Замена &lt; на открывающую скобку ( */
      if (strncmp((const char *)(pfn + i), "&lt;", 4) == 0)
      {
        pfn[i] = '(';
        j = i + 1;
        while ((pfn[j] = pfn[j + 3]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
    }

    i++;
  }
}

void stringRepair(unsigned char *pfn, unsigned int tSize)
{
  unsigned int i;
  unsigned int j;
  unsigned char c;

  i = 0;
  while (pfn[i] != '\0' && i < tSize)
  {
    c = pfn[i];

    if (c == '&')
    {
      /* Замена &#039; на ' */
      if (strncmp((const char *)(pfn + i), "&#039;", 6) == 0)
      {
        pfn[i] = '\'';
        j = i + 1;
        while ((pfn[j] = pfn[j + 5]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
      /* Замена &quot; на " */
      if (strncmp((const char *)(pfn + i), "&quot;", 6) == 0)
      {
        pfn[i] = '\"';
        j = i + 1;
        while ((pfn[j] = pfn[j + 5]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
      /* Замена &amp; на & */
      if (strncmp((const char *)(pfn + i), "&amp;", 5) == 0)
      {
        pfn[i] = '&';
        j = i + 1;
        while ((pfn[j] = pfn[j + 4]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
      /* Замена &gt; на > */
      if (strncmp((const char *)(pfn + i), "&gt;", 4) == 0)
      {
        pfn[i] = '>';
        j = i + 1;
        while ((pfn[j] = pfn[j + 3]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
      /* Замена &lt; на < */
      if (strncmp((const char *)(pfn + i), "&lt;", 4) == 0)
      {
        pfn[i] = '<';
        j = i + 1;
        while ((pfn[j] = pfn[j + 3]) != '\0')
        {
          j++;
        }
        i++;
        continue;
      }
    }

    /* Замена экранированного слеша \/ на обычный / */
    if (c == '\\' && pfn[i + 1] == '/')
    {
      pfn[i] = '/';
      j = i + 1;
      while ((pfn[j] = pfn[j + 1]) != '\0')
      {
        j++;
      }
      i++;
      continue;
    }

    i++;
  }
}

void ncReplace(void)
{
  unsigned char len;
  for (len = 0; len < strlen(curFileStruct.afn); len++)
  {
    if ((curFileStruct.afn[len] < ' ') || (curFileStruct.afn[len] > 0xf1) || (curFileStruct.afn[len] > 0xb0 && curFileStruct.afn[len] < 0xdf))
    {
      curFileStruct.afn[len] = '_';
    }
  }

  for (len = 0; len < strlen(curFileStruct.pfn); len++)
  {
    if ((curFileStruct.pfn[len] < ' ') || (curFileStruct.pfn[len] > 0xef) || (curFileStruct.pfn[len] > 0xb0 && curFileStruct.pfn[len] < 0xdf))
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

  sprintf(curFileStruct.fileName, "%s-%s-%lu.scr", curFileStruct.afn, curFileStruct.pfn, fileId);
  if (strlen(curFileStruct.fileName) > 62)
  {
    sprintf(fileIdChar, "-%lu", fileId);
    str_replace(curFileStruct.fileName, sizeof(curFileStruct.fileName) - 1, curFileStruct.fileName, fileIdChar, "");
    curFileStruct.fileName[50] = '\0';
    strcat(curFileStruct.fileName, fileIdChar);
    strcat(curFileStruct.fileName, ".scr");
  }

  printf("%s  ", curFileStruct.fileName);

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
  unsigned int maxSafeLimit; /* Объявление строго до исполняемого кода */
  unsigned char terminator;
  int n;

  netbuf[0] = 0;
  n = pos(picture, property, 1, 0);
  if (n == -1)
  {
    strcpy(netbuf, "-");
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

  /* Вычисляем предел безопасности на основе размера picture (8192 байта) */
  maxSafeLimit = sizeof(picture) - lngp1 - 1;

  while (42)
  {
    /* Защитный барьер: если буфер битый или усечен, выходим до зависания */
    if (findEnd >= maxSafeLimit)
    {
      break;
    }

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

  /* Если вышли по аварийному лимиту ? отдаем маркер ошибки */
  if (findEnd >= maxSafeLimit)
  {
    strcpy(netbuf, "-");
    return netbuf;
  }

  listPos = 0;
  for (w = lngp1; w < findEnd + lngp1; w++)
  {
    /* Защищаем netbuf (4096 байт) от случайного переполнения */
    if (listPos >= sizeof(netbuf) - 1)
    {
      break;
    }
    netbuf[listPos] = picture[w];
    listPos++;
  }
  netbuf[listPos] = 0;
  return netbuf;
}

// Сверхбыстрый парсинг одной HEX-цифры без библиотек
unsigned char hex2val(unsigned char c)
{
  if (c >= '0' && c <= '9')
    return c - '0';
  if (c >= 'a' && c <= 'f')
    return c - 'a' + 10;
  if (c >= 'A' && c <= 'F')
    return c - 'A' + 10;
  return 0;
}

void convert866(void)
{
  unsigned int src = 0; // Индекс чтения
  unsigned int dst = 0; // Индекс записи (работаем в одном буфере!)
  unsigned int decVal;

  while (netbuf[src] != 0)
  {
    // Проверяем маркер "\u" (92 ? это '\', 117 ? это 'u')
    if (netbuf[src] == 92 && netbuf[src + 1] == 117)
    {
      src += 2; // Пропускаем "\u"

      // Быстро собираем 16-битное число из 4 HEX-символов вместо strtol
      decVal = ((unsigned int)hex2val(netbuf[src]) << 12) |
               ((unsigned int)hex2val(netbuf[src + 1]) << 8) |
               ((unsigned int)hex2val(netbuf[src + 2]) << 4) |
               (unsigned int)hex2val(netbuf[src + 3]);
      src += 4; // Пропускаем 4 HEX-цифры

      // Конвертация Юникода кириллицы (0x0400-0x04FF) в CP866
      if (decVal == 0x0401)
      { // Буква 'Ё'
        netbuf[dst++] = 240;
      }
      else if (decVal == 0x0451)
      { // Буква 'ё'
        netbuf[dst++] = 241;
      }
      else if (decVal >= 0x0410 && decVal <= 0x043F)
      {
        // А..Я и а..п (Юникод 1040..1087) -> CP866 (128..175)
        netbuf[dst++] = (unsigned char)(decVal - 912);
      }
      else if (decVal >= 0x0440 && decVal <= 0x044F)
      {
        // р..я (Юникод 1088..1103) -> CP866 (224..239)
        netbuf[dst++] = (unsigned char)(decVal - 864);
      }
      else if (decVal < 128)
      {
        // На случай, если в \u закодирована базовая латиница
        netbuf[dst++] = (unsigned char)decVal;
      }
      else
      {
        netbuf[dst++] = '?'; // Неподдерживаемый символ
      }
    }
    else
    {
      // Обычные ASCII символы просто копируем на месте
      netbuf[dst++] = netbuf[src++];
    }
  }

  netbuf[dst] = 0;           // Корректно закрываем строку нуля-терминатором
  stringRepair(netbuf, dst); // Если функция stringRepair еще нужна, вызываем её здесь
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
  case 98: // https://zxart.ee/api/export:zxPicture/limit:1/filter:zxPictureId=589855
    sprintf(netbuf, "GET /api/export:zxPicture/limit:%u/filter:zxPictureId=%lu%s", limit, startPos, userAgent);
    break;
  case 99: // GET /jsonElementData/elementId:182797
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
    parseJson("\"year\":");
    curFileStruct.picYear = atoi(netbuf);
    parseJson("\"totalAmount\":");
    curFileStruct.totalAmount = atol(netbuf);
    parseJson("\"authorIds\":[");
    strcpy(curFileStruct.authorIds, netbuf);
    parseJson(",\"description\":\"");

    if (netbuf[0] != '-')
    {
      curFileStruct.hasDescription = true;
    }
    else
    {
      curFileStruct.hasDescription = false;
    }
    break;

  case 98:
    parseJson(",\"description\":\"");
    convert866();
    break;

  case 99: // Author info
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

void showDescription(unsigned long counter, int atLine, unsigned char showLines)
{
  unsigned char byte, q, lineCount = 1, rowCount = 0;
  unsigned char insideTag = 0; /* 1 - если мы внутри HTML-тега */
  unsigned int position = 0;

  /* Запрос данных с сервера */
  processJson(counter, 1, 98);

  if (atLine != -1)
  {
    clearStatus();
    for (q = atLine; q < atLine + showLines; q++)
    {
      OS_SETXY(0, q);
      spaces(80);
    }

    OS_SETXY(0, atLine);
    OS_SETCOLOR(69);
    printf(" Description:\r\n");
    OS_SETCOLOR(71);
  }

  /* Читаем netbuf (4096 байт) */
  while (position < 4096)
  {
    byte = netbuf[position];
    if (byte == 0x00)
    {
      return;
    }

    /* Логика фильтрации HTML-тегов (<pre>, </pre> или <\/pre>) */
    if (byte == '<')
    {
      insideTag = 1;
      position++;
      continue;
    }

    if (insideTag == 1)
    {
      if (byte == '>')
      {
        insideTag = 0;
      }
      position++;
      continue; /* Пропускаем внутренности тега целиком */
    }

    /* Обработка JSON-экранирования управляющих символов */
    if (byte == '\\')
    {
      position++;
      if (position >= 4096)
        return;

      byte = netbuf[position];
      switch (byte)
      {
      case 0x00:
        return;
      case '\\':
        putchar('\\');
        rowCount++;
        break;
      case 'r':
        putchar('\r');
        rowCount = 0;
        break;
      case 'n':
        putchar('\n');
        lineCount++;
        rowCount = 0;
        if (lineCount > showLines)
        {
          return;
        }
        break;
      default:
        /* Если это просто экранированный символ (например, \/ в <\/pre>) */
        putchar(byte);
        rowCount++;
        break;
      }
    }
    else
    {
      putchar(byte);
      rowCount++;
    }

    position++;

    /* Перенос строки по достижению края экрана NedoOS (80 символов) */
    if (rowCount >= 80)
    {
      putchar('\n');
      lineCount++;
      rowCount = 0;
      if (lineCount > showLines)
      {
        return;
      }
    }
  }
}

void printData(void)
{
  long idkfa;
  if (!verbose && !infoPressed)
  {
    return;
  }
  OS_SETGFX(0x86);
  OS_CLS(0);

  idkfa = processJson(atol(curFileStruct.authorIds), 0, 99);
  if (idkfa < 0)
  {
    printf("[%u]Error can't parse authorIds(%s).\r\n", curFileStruct.httpErr, curFileStruct.authorIds);
    strcpy(curFileStruct.authorTitle, "ErrorGet");
    strcpy(curFileStruct.authorRealName, "Error Getting Name");
  }

  OS_SETCOLOR(70);
  printf(" #: ");
  OS_SETCOLOR(71);
  printf("%lu", count);
  OS_SETCOLOR(70);
  printf(" ID: ");
  OS_SETCOLOR(71);
  printf("%ld ", curFileStruct.picId);
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
  OS_SETCOLOR(70);
  printf(" Description: ");
  OS_SETCOLOR(71);

  if (showDesc)
  {
    if (curFileStruct.hasDescription == true)
    {
      putchar('\r');
      putchar('\n');
      showDescription(curFileStruct.picId, -1, 15);
    }
    else
    {
      printf("none");
    }
  }
  else
  {
    printf("disabled");
  }

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

  if (slideShowTime != 0)
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
  unsigned char byte;

  // Переменные редактора (объявлены строго в начале функции для IAR)
  unsigned char cmdLen;     // Полная текущая длина строки cmd
  unsigned char cursorPos;  // Позиция курсора в строке (от 0 до cmdLen)
  unsigned char viewOffset; // Смещение просмотра для скроллинга длинного текста
  unsigned char visibleLen; // Сколько символов строки физически влезает в окно
  unsigned char i;          // Индекс для циклов отрисовки
  unsigned char printPos;   // Текущий индекс символа для вывода на экран

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

  // Инициализация строки cmd
  cmd[0] = 0;
  cmdLen = strlen(prefilled);
  if (cmdLen != 0)
  {
    strncpy(cmd, prefilled, sizeof(cmd) - 1);
    cmd[sizeof(cmd) - 1] = 0; // Гарантированный ноль на конце
  }

  // Настройка начального состояния курсора и скроллинга
  cursorPos = cmdLen;
  viewOffset = 0;
  visibleLen = w.w - 1; // Доступная ширина внутри рамки под текст и курсор

  for (;;)
  {
    // 1. АВТОСКРОЛЛИНГ: Корректируем окно видимости текста относительно курсора
    if (cursorPos < viewOffset)
    {
      viewOffset = cursorPos;
    }
    else if (cursorPos - viewOffset >= visibleLen)
    {
      viewOffset = cursorPos - visibleLen + 1;
    }

    // 2. ОТРИСОВКА СТРОКИ С ПОБИТОВОЙ ИНВЕРСИЕЙ ЦВЕТА КУРСOРА (Для NedoOS)
    OS_SETXY(w.x + 1, w.y + 1);

    for (i = 0; i < visibleLen; i++)
    {
      printPos = viewOffset + i;

      // Если в этой позиции находится курсор ? считаем инверсный байт атрибута
      if (printPos == cursorPos)
      {
        // 1. Формируем новый PAPER (из старого INK)
        OS_SETCOLOR((unsigned char)(
            // 1. Формируем новый PAPER (из старого INK)
            ((w.text & 0x40) << 1) | // Старый BRIGHT_INK (6) двигаем на место BRIGHT_PAPER (7)
            ((w.text & 0x07) << 3) | // Старый INK (2-0) двигаем на место PAPER (5-3)

            // 2. Формируем новый INK (из старого PAPER)
            ((w.text & 0x80) >> 1) | // Старый BRIGHT_PAPER (7) двигаем на место BRIGHT_INK (6)
            ((w.text & 0x38) >> 3)   // Старый PAPER (5-3) двигаем на место INK (2-0)
            ));
      }
      else
      {
        OS_SETCOLOR(w.text); // Стандартный цвет окна (например, тот самый 207)
      }

      // Выводим символ или пробел на месте курсора
      if (printPos < cmdLen)
      {
        putchar(cmd[printPos]);
      }
      else
      {
        putchar(' '); // Зачищаем хвост строки или рисуем инверсный курсор-пробел в конце
      }
    }
    // Восстанавливаем цвет по умолчанию после завершения строки
    OS_SETCOLOR(w.text);

    YIELD(); // Обязательно уступаем квант времени ОС NedoOS

    byte = OS_GETKEY();
    if (byte != 0)
    {
      switch (byte)
      {
      case 248: // Left (Стрелка влево)
        if (cursorPos > 0)
        {
          cursorPos--;
        }
        break;
      case 251: // Right (Стрелка вправо)
        if (cursorPos < cmdLen)
        {
          cursorPos++;
        }
        break;

      case 0x08: // Backspace (Удаление символа СЛЕВА от курсора)
        if (cursorPos > 0 && cmdLen > 0)
        {
          // Сдвигаем хвост строки влево на 1 символ
          for (i = cursorPos - 1; i < cmdLen; i++)
          {
            cmd[i] = cmd[i + 1];
          }
          cursorPos--;
          cmdLen--;
        }
        break;

      case 252: // Delete (Удаление символа В ПОЗИЦИИ курсора)
        if (cursorPos < cmdLen && cmdLen > 0)
        {
          // Сдвигаем хвост строки начиная от курсора
          for (i = cursorPos; i < cmdLen; i++)
          {
            cmd[i] = cmd[i + 1];
          }
          cmdLen--;
        }
        break;

      case 0x0d: // Enter (Подтверждение ввода)

        if (cmdLen == 0)
        {
          return false;
        }
        return true;

      case 27: // Esc (Полная очистка и выход)
        cmd[0] = 0;
        return false;

      case 31:  // Игнорируем служебные клавиши навигации основного экрана
      case 250: // Up
      case 249: // Down
        break;

      default: // ВВОД СИМВОЛА (С поддержкой вставки в середину строки)
        // Проверяем, есть ли место в массиве cmd и влезает ли символ
        if (cmdLen < (sizeof(cmd) - 2) && byte >= 32)
        {
          // Раздвигаем строку вправо, освобождая место под символ
          for (i = cmdLen; i > cursorPos; i--)
          {
            cmd[i] = cmd[i - 1];
          }
          // Вставляем символ в позицию курсора
          cmd[cursorPos] = byte;
          cursorPos++;
          cmdLen++;
          cmd[cmdLen] = 0; // Корректно закрываем строку нулем
        }
        break;
      }
    }
  }
}

void safeKeys(unsigned char keypress)
{
  switch (keypress & 0xdf)
  {
  case 27:
    quit();
    break;
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
    }
    break;
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
      sscanf(cmd, "%u", &userInts);

      if (userInts == 0)
      {
        userInts = 250;
      }
      OS_CLS(0);
      OS_SETCOLOR(70);
      
      if (slideShowTime != 0)
      {
        slideShowTime = userInts;
      }

      printf("Slide duration set to %u ints.", userInts);
      delayLong(500);
      OS_CLS(0);
    }
    break;
  case 'V':
    verbose = !verbose;
    break;
  case 'H':
    printHelp();
    break;
  case 'R':
    randomPic = !randomPic;
    OS_SETCOLOR(70);
    if (verbose)
    {
      if (randomPic == 1)
      {
        printf("    Random mode enabled...\r\n");
        count = 0;
        // delayLong(500);
      }
      else
      {
        printf("    Sequental mode enabled...\r\n");
        count = 0;
        // delayLong(500);
      }
    }
    break;
  case 'A':
    OS_SETCOLOR(70);

    if (slideShowTime == 0)
    {
      slideShowTime = userInts;
      if (verbose == 1)
        printf("    SlideShow mode enabled...\r\n\r\n");
    }
    else
    {
      printf("    Manual mode enabled...\r\n\r\n");
      slideShowTime = 0;
    }
    delayLong(500);
    break;
  case 'D':
    netDriver = !netDriver;
    OS_SETCOLOR(70);
    if (netDriver == 1)
    {
      printf("    ESP-COM mode enabled...\r\n");
      OS_GETPATH((unsigned int)&curPath);
      loadEspConfig();
      OS_CHDIR(curPath);
      uart_init(divider);

      espReBoot();
    }
    else
    {
      if (verbose == 1)
        printf("    NedoNET mode enabled...");
      delayLong(500);
    }
    break;
  case 'M':
    curWin.w = 22;
    curWin.x = 80 / 2 - curWin.w / 2 - 2;
    curWin.y = 1;
    curWin.h = 1;
    curWin.text = 103;
    curWin.back = 103;
    strcpy(curWin.tittle, "Minimal rating:");

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
    OS_CHDIR(curPath);
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
  count = 0;
  verbose = 1;
  showDesc = false;
  randomPic = 0;
  userInts = 250;
  infoPressed = false;
  strcpy(minRating, "4.1");
  targetadr.family = AF_INET;
  targetadr.porth = 00;
  targetadr.portl = 80;
  targetadr.b1 = 217; // D9
  targetadr.b2 = 146; // 92
  targetadr.b3 = 69;  // 45
  targetadr.b4 = 13;  // 0D

  OS_SETSYSDRV();
  OS_MKDIR("../downloads");        // Create if not exist
  OS_MKDIR("../downloads/getpic"); // Create if not exist
  OS_CHDIR("../downloads/getpic");

  netDriver = readParamFromIni();

  if (netDriver == 0)
  {
    verbose = 0;
    get_dns();
    clearStatus();
    dnsResolve("zxart.ee");
  }

  if (netDriver == 1)
  {
    OS_GETPATH((unsigned int)&curPath);
    loadEspConfig();
    OS_CHDIR(curPath);
    uart_init(divider);
    if (!espReBoot())
    {
      puts("Error rebooting ESP!. Press any key to continue.");
      writeLog("Error rebooting ESP!. Continue.", "main           ");
      getchar();
    }
    writeLog("GetPic Started & Inited.", "main           ");
  }
}

void viewScreen6912c(unsigned int bufAdr)
{
  OS_CLS(0);
  OS_SETBORDER(0);
  SETPG32KHIGH(OS_GETSCR0() >> 8);
  memcpy((unsigned char *)(0xc000), (unsigned char *)(bufAdr), 6912);
  OS_SETGFX(0x83);
  return;
}

C_task main(void)
{
  long iddqd, idkfa;
  char result;
  OS_SETGFX(0x86);
  OS_CLS(0);

  init();

  OS_HIDEFROMPARENT();

  printHelp();
  safeKeys(keypress);

start:

  keypress = 0;

  if (count > curFileStruct.totalAmount - 1)
  {
    count = 0;
  }

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
    OS_SETGFX(0x86);
    strcpy(minRating, "1.0");
    printf("[%u]No picture is returned in query. Minimal rating is set to %s\r\n", curFileStruct.httpErr, minRating);
    writeLog("[-3]No picture is returned in query. minRating=1.0", "main           ");
    delayLongKey(2000);

    goto start;
  case -4: // return xxxx picture, but empty body.
    OS_SETGFX(0x86);
    printf("[%u]Empty body is returned. Next picture(%lu)...\r\n", curFileStruct.httpErr, count);
    writeLog("[-4]Empty body is returned. Next picture.", "main           ");
    count++;
    delayLongKey(2000);
    goto start;
  case -1: // return HTTP error != 200
    OS_SETGFX(0x86);
    printf("[%u]Error getting pic info. Next picture(%lu)...\r\n", curFileStruct.httpErr, count);
    writeLog("[-1]Error getting pic info. Next picture.", "main           ");
    count++;
    delayLongKey(2000);
    goto start;
  }

  printData();

  if (strcmp(curFileStruct.picType, "standard") != 0)
  {
    OS_SETGFX(0x86);
    printf("[%u]Error format '%s' not supported. Next picture.\n\r", curFileStruct.httpErr, curFileStruct.picType);
    count++;
    delayLongKey(2000);
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

  if (!result) // return HTTP error != 200
  {
    OS_SETGFX(0x86);
    printf("[%u]Error getting pic. Next picture. Incorrect format?\r\n", curFileStruct.httpErr);
    count++;
    delayLongKey(2000);
    goto start;
  }

  viewScreen6912c((unsigned int)&picture);

  if (slideShowTime != 0)
  {
    keypress = delayLongKey(slideShowTime * 20);
  }
  else
  {
    do
    {
      YIELD();
      keypress = OS_GETKEY();
    } while (keypress == 0);
  }

  // OS_SETGFX(0x86);

  ////// Keys for pictures

  switch (keypress & 0xdf)
  {
  case 'S':
    OS_SETGFX(0x86);
    if (!verbose)
    {
      idkfa = processJson(atol(curFileStruct.authorIds), 0, 99);
      if (idkfa < 0)
      {
        printf("[%u]Error can't parse authorIds(%s). Next picture.\r\n", curFileStruct.httpErr, curFileStruct.authorIds);
        strcpy(curFileStruct.authorTitle, "ErrorGet");
        strcpy(curFileStruct.authorRealName, "Error Getting Name");
      }
    }

    printf("Saving ");

    savePic(iddqd);
    puts("O.K.");
    count++;
    break;
  case 'B':
  case 216:
    if (count > 0)
    {
      count--;
    }
    break;
  case 0: //' '
  case 219:
    count++;
    break;
  case 'I':
    infoPressed = true;
    printData();
    infoPressed = false;
    while (OS_GETKEY() == 0)
    {
      YIELD();
    }
    break;
  case 'O':
    showDesc = !showDesc;
    break;

  default:
    OS_SETGFX(0x86);
    safeKeys(keypress);
    break;
  }
  goto start;
}
