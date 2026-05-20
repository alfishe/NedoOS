#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <../common/terminal.c>
#include <tcp.h>
#include <osfs.h>
// #include <ctype.h>
#include <math.h> // floor
//
#define true 1
#define false 0
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
unsigned int comType = 0;
unsigned int espType = 32;
unsigned int espRetry = 1;
unsigned long factor, timerok;
unsigned int magic = 11;

const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char minRating[] = "0000000000";
const unsigned char userAgent[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; Radio)\r\n\r\n\0";
const unsigned char cmdlist1[] = "GET /file/id:";
unsigned char userQuery[256] = "/export:zxMusic/filter:zxMusicId=44816";
unsigned char defQuery[] = "/export:zxMusic/filter:zxMusicId=44816";
unsigned char fileName[] = "radio/player.ovl";
unsigned char appCmd[128] = "player.com ";
unsigned char curPath[128];
unsigned char ver[] = "4.2";

unsigned char queryType[50];
unsigned char netbuf[4096];
unsigned char dataBuffer[8192];
unsigned char crlf[2] = {13, 10};
unsigned char formats[4][4] = {"pt3", "pt2", "tfc", "ts"};
unsigned char interfaces[2][8] = {"NedoNET", "ESP-COM"};
unsigned char cmd[256];
unsigned char link[512];
unsigned char queryNum;

/* Массив строк для нашего меню (всего 6 вариантов) */
/* 0, 1, 2 ? системные, 3, 4, 5 ? из файла user.que */
unsigned char menuQueries[6][64];
unsigned char totalMenuLines;
/* Сколько всего строк доступно для выбора (от 3 до 6) */

struct sockaddr_in targetadr;
struct readstructure readStruct;
struct sockaddr_in dnsaddress;

unsigned long contLen;
long count;
unsigned char saveFlag, saveBak, rptFlag, netDriver, changedFormat, showDesc;
unsigned char status, key, curFormat;
union APP_PAGES main_pg;
union APP_PAGES player_pg;
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
  unsigned int httpErr;
  unsigned char time[16];
  unsigned char picRating[8];
  unsigned char trackName[256];
  unsigned char fileName[256];
  unsigned char authorIds[64];
  unsigned char authorTitle[64];
  unsigned char authorRealName[64];
  unsigned char afn[64];
  unsigned char tfn[64];
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

/*
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
*/

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
  return 0;
}

void spaces(unsigned char number)
{
  while (number > 0)
  {
    putchar(' ');
    number--;
  }
}

void clearStatus(void)
{
  OS_SETCOLOR(5);
  OS_SETXY(0, 24);
  spaces(79);
  putchar('\r');
}
/*
void clearNetbuf(void)
{
  int counter = 0;
  for (counter = 0; counter < sizeof(netbuf); counter++)
  {
    netbuf[counter] = 0;
  }
}
*/
void printProgress(const char type)
{
  unsigned char bar, minutes, seconds;
  const unsigned char *position;
  long barLenght;
  int timer;
  switch (type)
  {
  case 0: // print empty bar
    OS_SETXY(5, 10);
    OS_SETCOLOR(70);
    printf("%02d:%02d", 0, 0);
    OS_SETXY(14, 10);
    OS_SETCOLOR(71);
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

    OS_SETXY(5, 10);
    OS_SETCOLOR(70);
    timer = floor(curFileStruct.curPos / 60);
    printf("%02d:%02u", timer, (curFileStruct.curPos - (timer * 60)));

    barLenght = (curFileStruct.curPos * 50 / curFileStruct.trackInSeconds);
    if (barLenght > 49)
    {
      barLenght = 50;
    }
    OS_SETXY(14 + curFileStruct.startBar, 10);
    OS_SETCOLOR(71);
    for (bar = 0; bar < barLenght - curFileStruct.startBar; bar++)
    {
      putchar(178);
    }
    OS_SETXY(0, 0);
    curFileStruct.startBar = bar;
    break;
  case 2: // print full bar
    OS_SETXY(14, 10);
    OS_SETCOLOR(71);
    for (bar = 0; bar < 50; bar++)
    {
      putchar(178);
    }
    break;
  }
}

void printHelp(void)
{
  OS_SETXY(0, 12);
  OS_SETCOLOR(71);
  spaces(80);
  printf("\r\n");
  printf(" [<-] [B] Previous track          [->] [ ] Next track      \r\n");
  printf(" [S]  Stop player                 [R]  Repeat track mode   \r\n");
  printf(" [K]  Toggle saving tracks        [D]  Download track      \r\n");
  printf(" [Q]  Select Query type           [F]  Select tracks format\r\n");
  printf(" [I]  Interface ZXNETUSB/ESP32    [J]  Jump to NNNN file   \r\n");
  printf(" [O]  Show description            [M]  Minimal Rating(Q:2,3)\r\n");
}

void printStatus(void)
{
  OS_SETXY(0, 8);
  OS_SETCOLOR(70);
  printf(" [Q]Query : ");
  OS_SETCOLOR(71);
  printf("%s", queryType);
  printf("  ");
  OS_SETXY(0, 23);
  OS_SETCOLOR(95);
  printf("                                                                                ");
  OS_SETXY(1, 23);
  printf(" [F]Format: ");
  OS_SETCOLOR(94);
  printf("%s", formats[curFormat]);
  OS_SETCOLOR(95);
  printf(" [K]Keep files: ");
  OS_SETCOLOR(94);
  printf("%u", saveFlag);
  OS_SETCOLOR(95);
  printf(" [R]Repeat: ");
  OS_SETCOLOR(94);
  printf("%u", rptFlag);
  OS_SETCOLOR(95);
  printf(" [J]Jump to ");
  printf(" [E]Exit        [%s]", ver);

  OS_SETCOLOR(71);
  YIELD();
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

///////////////////////////
#include <../common/esp-com.c>
#include <../common/network.c>
//////////////////////////

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
        // Меняем местами биты 0-2 (INK) и 3-5 (PAPER), сохраняя биты 6-7 (Bright/Flash)
        OS_SETCOLOR((unsigned char)((w.text & 0xC0) |        // Сохраняем BRIGHT и FLASH
                                    ((w.text & 0x07) << 3) | // Сдвигаем старый INK на место PAPER
                                    ((w.text & 0x38) >> 3)   // Сдвигаем старый PAPER на место INK
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

const char *parseJson(unsigned char *property)
{
  unsigned int w, lng, lngp1, findEnd, listPos;
  unsigned int maxSafeLimit; /* Объявление строго до исполняемого кода */
  unsigned char terminator;
  int n;

  netbuf[0] = 0;
  n = pos(dataBuffer, property, 1, 0);
  if (n == -1)
  {
    strcpy(netbuf, "-");
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

  /* Вычисляем предел безопасности на основе размера dataBuffer (8192 байта) */
  maxSafeLimit = sizeof(dataBuffer) - lngp1 - 1;

  while (42)
  {
    /* Защитный барьер: если буфер битый или усечен, выходим до зависания */
    if (findEnd >= maxSafeLimit)
    {
      break;
    }

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
    netbuf[listPos] = dataBuffer[w];
    listPos++;
  }
  netbuf[listPos] = 0;
  return netbuf;
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

  for (len = 0; len < strlen(curFileStruct.tfn); len++)
  {
    if ((curFileStruct.tfn[len] < ' ') || (curFileStruct.tfn[len] > 0xef) || (curFileStruct.tfn[len] > 0xb0 && curFileStruct.tfn[len] < 0xdf))
    {
      curFileStruct.tfn[len] = '_';
    }
  }
}

void convert866(void)
{
  unsigned int lng, targetPos, w, q = 0;
  unsigned char one, two;
  unsigned int decVal;
  lng = strlen(netbuf);
  targetPos = lng + 1;

  while (q < lng)
  {
    one = netbuf[q];
    two = netbuf[q + 1];
    if (one == 92 && two == 117) // "\u"
    {
      q = q + 2;

      decVal = (unsigned int)strtol(netbuf + q, NULL, 16);
      q = q + 4;
      if (decVal < 1088)
      {
        decVal = decVal - 912;
      }
      else
      {
        decVal = decVal - 864;
      }

      if (decVal == 1025)
      {
        decVal = 240; // "Ё"
      }

      if (decVal == 1105)
      {
        decVal = 241; // "ё"
      }

      netbuf[targetPos] = decVal;
    }
    else
    {
      netbuf[targetPos] = netbuf[q];

      q++;
    }
    targetPos++;

    if (targetPos == sizeof(netbuf))
    {
      break;
    }
  }

  netbuf[targetPos] = 0;
  for (w = lng + 1; w < targetPos + 1; w++)
  {
    netbuf[w - lng - 1] = netbuf[w];
  }
  stringRepair(netbuf, w);
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
        sprintf(fileIdChar, "-%lu", fileId);
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
    OS_WRITEHANDLE(netbuf + headlng, fp2, sizeOfBuf);
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

char getFileNet(void)
{
  unsigned int todo, downloaded;
  unsigned char socket, firstPacket;
  clearStatus();
  socket = OpenSock(AF_INET, SOCK_STREAM);
  testOperation("OS_NETSOCKET", socket);

  todo = netConnect(socket, 2);
  testOperation("OS_NETCONNECT", todo);

  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf), 2);
  testOperation("OS_WIZNETWRITE", todo);

  downloaded = 0;
  firstPacket = true;
  do
  {
    headlng = 0;
    todo = tcpRead(socket, 2);
    clearStatus();
    testOperation("OS_WIZNETREAD", todo);
    if (todo == 0)
    {
      break;
    }
    if (firstPacket)
    {
      todo = cutHeader(todo);
      firstPacket = false;
      if (curFileStruct.httpErr != 200)
      {
        netShutDown(socket, 1);
        return false;
      }
    }

    if ((downloaded + todo) > (sizeof(dataBuffer) - 1))
    {
      clearStatus();
      printf("dataBuffer overrun...");
      getchar();
      break;
    }
    memcpy(dataBuffer + downloaded, netbuf + headlng, todo);
    downloaded = downloaded + todo;
  } while (downloaded < contLen);
  netShutDown(socket, 1);
  return true;
}

unsigned int getFileEsp(void)
{
  unsigned char firstPacket;
  unsigned long downloaded;
  unsigned char byte, countl = 0;
  unsigned int todo, sizeLink;
  const unsigned char *count1;

  strcpy(link, netbuf);
  sizeLink = strlen(link);
  do
  {
    sendcommand("AT+CIPSTART=\"TCP\",\"zxart.ee\",80");
    getAnswer3(); // CONNECT or ERROR or link is not valid
    count1 = strstr(netbuf, "CONNECT");
  } while (count1 == NULL);

  getAnswer3();                                   // OK
  sprintf(netbuf, "AT+CIPSEND=%u", sizeLink + 2); // second CRLF in send command
  sendcommand(netbuf);
  getAnswer3();
  do
  {
    byte = uartReadBlock();
    // putchar(byte);
  } while (byte != '>');
  sendcommand(link);
  countl = 0;
  do
  {
    byte = uartReadBlock();
    if (byte == sendOk[countl])
    {
      countl++;
    }
    else
    {
      countl = 0;
    }
  } while (countl < strlen(sendOk));
  uartReadBlock(); // CR
  uartReadBlock(); // LF
  downloaded = 0;
  firstPacket = true;
  do
  {
    headlng = 0;
    todo = recvHead();

    if (!getdataEsp(todo))
    {
      OS_CLS(0);
      puts("[getdataEsp]Downloading timeout. Exit!");
      delayLongKey(5000);
      exit(0);
    }

    if (firstPacket)
    {
      todo = cutHeader(todo);
      firstPacket = false;
      if (curFileStruct.httpErr != 200)
      {
        sendcommand("AT+CIPCLOSE");
        getAnswer3(); // CLOSED
        getAnswer3(); // OK
        return false;
      }
    }
    memcpy(dataBuffer + downloaded, netbuf + headlng, todo);
    downloaded = downloaded + todo;
  } while (downloaded < contLen);
  sendcommand("AT+CIPCLOSE");
  getAnswer3(); // CLOSED
  getAnswer3(); // OK
  return true;
}

long processJson(unsigned long startPos, unsigned char limit, unsigned char queryNum)
{
  unsigned int tSize;
  const unsigned char *countl;
  unsigned char result;
  clearStatus();
  printf("Getting data(%u)...", queryNum);

  switch (queryNum)
  {
  case 0:
    sprintf(netbuf, "GET /api/export:zxMusic/limit:%u/start:%lu/filter:zxMusicFormat=%s/order:date,desc%s", limit, startPos, formats[curFormat], userAgent);
    break;
  case 1:
    startPos = 0;
    sprintf(netbuf, "GET /api/types:zxMusic/export:zxMusic/language:eng/limit:%u/start:%lu/order:votes,rand/filter:zxMusicMinRating=%s;zxMusicFormat=%s%s", limit, startPos, minRating, formats[curFormat], userAgent);
    break;
  case 2:
    startPos = 0;
    sprintf(netbuf, "GET /api/types:zxMusic/export:zxMusic/language:eng/limit:%u/start:%lu/order:rand/filter:zxMusicMinRating=%s;zxMusicFormat=%s%s", limit, startPos, minRating, formats[curFormat], userAgent);
    break;

  case 3:
    sprintf(netbuf, "GET /api/limit:%u/start:%lu%s%s", limit, startPos, userQuery, userAgent);
    break;
  case 98: // http://zxart.ee/api/export:zxMusic/limit:10/filter:zxMusicId=19717
    sprintf(netbuf, "GET /api/export:zxMusic/limit:%u/filter:zxMusicId=%lu%s", limit, startPos, userAgent);
    break;
  case 99:
    sprintf(netbuf, "GET /jsonElementData/elementId:%lu%s", startPos, userAgent);
    break;
  }

  switch (netDriver)
  {
  case 0:
    result = getFileNet();
    break;
  case 1:
    result = getFileEsp();
    break;
  }

  if (!result)
  {
    return -1;
  }

  clearStatus();
  printf("Processing data (%u)...", queryNum);

  countl = strstr(dataBuffer, "responseStatus\":\"success");
  if (countl == NULL)
  {
    OS_CLS(0);
    OS_SETCOLOR(66);
    puts("Bad responseStatus - dataBuffer[]:");
    puts(dataBuffer);
    puts("---------------");
    printf("PROCESS JSON: [ERROR: Bad responseStatus.] [Query:%u] [Track:%lu]\r\n", queryNum, startPos);
    YIELD();
    getchar();
    return -1;
  }
  countl = strstr(dataBuffer, "\"id\":");
  if (countl == NULL)
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
    puts("ID not found - dataBuffer[]:");
    puts(dataBuffer);
    puts("---------------");
    printf("PROCESS JSON: [ERROR: ID not found] [Query:%u] [Track:%lu]", queryNum, startPos);
    YIELD();
    getchar();
    return -2;
  }

  switch (queryNum)
  {
  case 0:
  case 1:
  case 2:
  case 3:
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
    parseJson("\"year\":");
    curFileStruct.picYear = atoi(netbuf);
    parseJson("\"totalAmount\":");
    curFileStruct.totalAmount = atol(netbuf);
    parseJson("\"time\":\"");
    strcpy(curFileStruct.time, netbuf);
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

void printInfo(void)
{
  BDBOX(30, 2, 50, 6, 71, ' ');
  OS_SETXY(0, 1);
  OS_SETCOLOR(70);
  printf(" #: ");
  OS_SETCOLOR(71);
  printf("%ld", count);
  OS_SETCOLOR(70);
  printf(" ID: ");
  OS_SETCOLOR(71);
  printf("%ld", curFileStruct.picId);
  OS_SETCOLOR(70);
  printf(" Total Tracks: ");
  OS_SETCOLOR(71);
  printf("%lu               \r\n", curFileStruct.totalAmount);
  OS_SETCOLOR(70);
  printf(" RATING: ");
  OS_SETCOLOR(71);
  printf("%s", curFileStruct.picRating);
  OS_SETCOLOR(70);
  printf(" YEAR: ");
  OS_SETCOLOR(71);
  printf("%u", curFileStruct.picYear);
  OS_SETCOLOR(70);
  printf(" DURATION: ");
  OS_SETCOLOR(71);
  printf("%s", curFileStruct.time);
  printf(" \r\n\r\n");
  OS_SETCOLOR(70);
  printf(" AuthorsIDs ");
  OS_SETCOLOR(71);
  printf("%s", curFileStruct.authorIds);
  OS_SETCOLOR(70);
  printf(" Author: ");
  OS_SETCOLOR(71);
  printf("%s", curFileStruct.authorTitle);
  OS_SETCOLOR(70);
  printf(" Real name: ");
  OS_SETCOLOR(71);
  printf("%s", curFileStruct.authorRealName);
  printf(" \r\n\r\n");
  OS_SETCOLOR(69);
  printf("                                                                           \r");
  printf("   TITLE: %s\r\n", curFileStruct.trackName);

  if (showDesc)
  {
    if (curFileStruct.hasDescription == true)
    {
      showDescription(curFileStruct.picId, 12, 10);
    }
  }
  OS_SETCOLOR(69);
}

void refreshScreen(void)
{
  OS_CLS(0);
  OS_SETCOLOR(71);
  OS_SETCOLOR(95);
  printf("                           ZXART.EE radio for %s                           ", interfaces[netDriver]);
  OS_SETCOLOR(6);
  printInfo();
  printProgress(0);
  printProgress(1);
  printHelp();
  printStatus();
}

unsigned char getTrack2Net(unsigned long fileId)
{
  int todo;
  char socket;
  unsigned long downloaded, firstPacket;
  clearStatus();
  printf("Getting track...");
  sprintf(netbuf, "GET /file/id:%lu%s", fileId, userAgent);
  socket = OpenSock(AF_INET, SOCK_STREAM);
  clearStatus();
  testOperation("OS_NETSOCKET", socket);

  todo = netConnect(socket, 10);
  testOperation("OS_NETCONNECT", todo);

  todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf), 10);
  testOperation("OS_WIZNETWRITE", todo);
  saveBuf(curFileStruct.picId, 00, 0);
  downloaded = 0;
  firstPacket = true;
  do
  {
    headlng = 0;
    // clearNetbuf();
    todo = tcpRead(socket, 10);
    testOperation("OS_WIZNETREAD", todo);

    if (todo == 0)
    {
      break;
    }

    if (firstPacket)
    {
      todo = cutHeader(todo);
      firstPacket = false;
      if (curFileStruct.httpErr != 200)
      {
        netShutDown(socket, 1);
        return false;
      }
    }
    saveBuf(curFileStruct.picId, 01, todo);
    downloaded = downloaded + todo;
  } while (downloaded < contLen);
  netShutDown(socket, 0);
  return true;
}

unsigned char getTrack2Esp(unsigned long fileId)
{
  int todo;
  unsigned long downloaded, firstPacket;
  unsigned char byte;
  unsigned int countl;
  const unsigned char *count1;
  clearStatus();
  printf("Getting track...");
  sprintf(netbuf, "GET /file/id:%lu%s", fileId, userAgent);
  strcpy(link, netbuf);
  saveBuf(curFileStruct.picId, 00, 0);
  do
  {
    sendcommand("AT+CIPSTART=\"TCP\",\"zxart.ee\",80");
    getAnswer3(); // CONNECT or ERROR or link is not valid
    count1 = strstr(netbuf, "CONNECT");
  } while (count1 == NULL);

  getAnswer3(); // OK

  sprintf(cmd, "AT+CIPSEND=%d", strlen(link) + 2); // second CRLF in send command
  sendcommand(cmd);
  getAnswer3();

  do
  {
    byte = uartReadBlock();
    // putchar(byte);
  } while (byte != '>');
  sendcommand(link);
  countl = 0;

  do
  {
    byte = uartReadBlock();
    if (byte == sendOk[countl])
    {
      countl++;
    }
    else
    {
      countl = 0;
    }
  } while (countl < strlen(sendOk));
  uartReadBlock(); // CR
  uartReadBlock(); // LF
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
        getAnswer3(); // CLOSED
        getAnswer3(); // OK
        return false;
      }
    }
    downloaded = downloaded + todo;
    saveBuf(curFileStruct.picId, 01, todo);
  } while (downloaded < contLen);
  sendcommand("AT+CIPCLOSE");
  getAnswer3(); // CLOSED
  getAnswer3(); // OK
  saveBuf(curFileStruct.picId, 02, 0);
  return true;
}

int getTrack3(long iddqd)
{
  int errn;
  switch (netDriver)
  {
  case 0:
    errn = getTrack2Net(iddqd);
    break;
  case 1:
    errn = getTrack2Esp(iddqd);
    break;
  }

  if (errn < 0)
  {
    clearStatus();
    printf("[%u]Error getting track, next please(%d)...", curFileStruct.httpErr, errn);
  }
  return errn;
}

unsigned char runPlayer(void)
{
  FILE *fp2;
  unsigned long playerSize, loaded, loop;
  unsigned char pgbak;
  clearStatus();
  printf("Running player...");
  sprintf(appCmd, "player.com %s", curFileStruct.fileName);
  player_pg.l = OS_GETMAINPAGES();
  pgbak = main_pg.pgs.window_3;
  loop = 0;
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

  do
  {
    loaded = OS_READHANDLE(dataBuffer, fp2, sizeof(dataBuffer));
    memcpy((char *)(0xC100 + loop), &dataBuffer, loaded);
    loop = loop + loaded;
  } while (loop < playerSize);

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

void refreshQueryNames(int queryNum)
{
  switch (queryNum)
  {
  case 0:
    strcpy(queryType, "from newest to oldest                   ");
    break;
  case 1:
    sprintf(queryType, "Random most voted tracks with rating %s+    ", minRating);
    break;
  case 2:
    sprintf(queryType, "Random play with rating %s+                  ", minRating);
    break;
  case 3:
    strcpy(queryType, "User defined query from \"user.que\"     ");
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

void initQueryMenu(void)
{
  FILE *fp3;
  unsigned int i, j, bytesRead;
  unsigned char fileBuf[256]; /* Временный буфер для чтения всего файла */

  /* 1. Заполняем первые 3 захардкоженных имени */
  strcpy((char *)menuQueries[0], "From newest to oldest");
  strcpy((char *)menuQueries[1], "Random most voted tracks");
  strcpy((char *)menuQueries[2], "Random play");

  /* По умолчанию доступно только 3 системных пункта */
  totalMenuLines = 3;

  /* 2. Работа с файловой системой NedoOS по вашему паттерну */
  fp3 = OS_OPENHANDLE("../ini/user.que", 0x80);

  /* Проверка ошибки открытия в стиле NedoOS */
  if (((int)fp3) & 0xff)
  {
    /* Если файла нет, создаем его и записываем дефолтный запрос */
    fp3 = OS_CREATEHANDLE("../ini/user.que", 0x80);

    /* Записываем дефолтную строку. Добавим \r\n, чтобы файл был готов к многострочности */
    strcpy((char *)fileBuf, defQuery);
    OS_WRITEHANDLE(fileBuf, fp3, strlen((const char *)fileBuf));
    OS_CLOSEHANDLE(fp3);
    /* Переоткрываем для последующего чтения */
    fp3 = OS_OPENHANDLE("../ini/user.que", 0x80);
  }

  /* Обнуляем буфер перед чтением */
  memset(fileBuf, 0, sizeof(fileBuf));

  /* Читаем содержимое файла в буфер */
  bytesRead = OS_READHANDLE(fileBuf, fp3, sizeof(fileBuf) - 1);
  OS_CLOSEHANDLE(fp3);

  /* 3. Парсим буфер файла на отдельные строки */
  i = 0;
  while (i < bytesRead && totalMenuLines < 6)
  {
    /* Пропускаем пустые символы и мусор между строками */
    if (fileBuf[i] == '\r' || fileBuf[i] == '\n' || fileBuf[i] == ' ')
    {
      i++;
      continue;
    }

    /* Копируем очередную строку в массив menuQueries */
    j = 0;
    while (i < bytesRead && fileBuf[i] != '\r' && fileBuf[i] != '\n' && j < 63)
    {
      menuQueries[totalMenuLines][j] = fileBuf[i];
      i++;
      j++;
    }
    menuQueries[totalMenuLines][j] = '\0'; /* Закрываем Си-строку */

    /* Если строка получилась не пустой, добавляем пункт в меню */
    if (strlen((const char *)menuQueries[totalMenuLines]) > 0)
    {
      totalMenuLines++;
    }
  }
}

int showQueryMenu(int currentSelect)
{
  unsigned char q, key, needRedraw;
  unsigned char winW = 71; /* Расширили окно до 71 символа */
  unsigned char winH = totalMenuLines;
  unsigned char winX = (80 - winW) / 2; /* Чистое математическое центрирование */
  unsigned char winY = 12 - winH / 2;

  /* Коды символов рамки */
  unsigned char sym_tl = 201;
  unsigned char sym_tr = 187;
  unsigned char sym_bl = 200;
  unsigned char sym_br = 188;
  unsigned char sym_h = 205;
  unsigned char sym_v = 186;

  if (currentSelect >= totalMenuLines)
  {
    currentSelect = 0;
  }

  /* --- ОДНОКРАТНАЯ ОТРИСОВКА ФОНА И РАМКИ ПРИ ОТКРЫТИИ --- */
  OS_SETCOLOR(103);

  /* 1. Верхняя линия рамки */
  OS_SETXY(winX - 1, winY - 1);
  putchar(sym_tl);
  for (q = 0; q < winW; q++)
    putchar(sym_h);
  putchar(sym_tr);

  /* 2. Тело окна: боковые грани рамки и заливка фона */
  for (q = 0; q < winH; q++)
  {
    OS_SETXY(winX - 1, winY + q);
    putchar(sym_v);

    spaces(winW);

    OS_SETXY(winX + winW, winY + q);
    putchar(sym_v);
  }

  /* 3. Нижняя линия рамки */
  OS_SETXY(winX - 1, winY + winH);
  putchar(sym_bl);
  for (q = 0; q < winW; q++)
    putchar(sym_h);
  putchar(sym_br);
  /* ------------------------------------------------------ */

  needRedraw = 1;

  while (42)
  {
    if (needRedraw)
    {
      for (q = 0; q < winH; q++)
      {
        /* Оставляем 1 символ отступа слева */
        OS_SETXY(winX + 1, winY + q);

        if (q == currentSelect)
        {
          OS_SETCOLOR(188);
        }
        else
        {
          OS_SETCOLOR(103);
        }

        /* Печатаем строку шириной 68 символов. Теперь справа останется ровно 2 символа запаса! */
        printf("%-68s", menuQueries[q]);
      }

      needRedraw = 0;
    }

    key = OS_GETKEY();

    if (key == 250 || key == 'A' || key == 'a')
    {
      if (currentSelect > 0)
      {
        currentSelect--;
        needRedraw = 1;
      }
    }
    else if (key == 249 || key == 'B' || key == 'b')
    {
      if (currentSelect < totalMenuLines - 1)
      {
        currentSelect++;
        needRedraw = 1;
      }
    }
    else if (key == 13)
    {
      return currentSelect;
    }
    else if (key == 27)
    {
      return -1;
    }
  }

  return -1;
}

C_task main(int argc, const char *argv[])
{
  unsigned char errn, keypress, pId;
  long iddqd, idkfa;
  unsigned long curTimer, startTimer, oldTimer;
  srand(time());

  //  OS_HIDEFROMPARENT();
  OS_SETGFX(0x86);
  OS_CLS(0);

  count = 0;
  saveFlag = 0;
  queryNum = 0;
  curFormat = 0;
  changedFormat = 0;
  rptFlag = 0;
  showDesc = false;
  strcpy(minRating, "4.0");

  targetadr.family = AF_INET;
  targetadr.porth = 00;
  targetadr.portl = 80;
  targetadr.b1 = 217; // D9
  targetadr.b2 = 146; // 92
  targetadr.b3 = 69;  // 45
  targetadr.b4 = 13;  // 0D

  printf("[Build:%s  %s]\r\n", __DATE__, __TIME__);

  netDriver = readParamFromIni();

  if (argc > 1)
  {
    if ((argv[1][0] == 'e') || (argv[1][0] == 'E'))
    {
      netDriver = 1;
      loadEspConfig();
      uart_init(divider);
      espReBoot();
    }
  }
  else if (netDriver == 0)
  {
    get_dns();
    clearStatus();
    dnsResolve("zxart.ee");
  }
  else if (netDriver == 1)
  {
    netDriver = 1;
    loadEspConfig();
    uart_init(divider);
    espReBoot();
  }

  OS_HIDEFROMPARENT();

  strcpy(queryType, "from newest to oldest");

  initQueryMenu();

start:
  OS_SETSYSDRV();
  refreshScreen();
  curFileStruct.fileSize = 0;

  iddqd = processJson(count, 1, queryNum); // Query for track info

  switch (iddqd)
  {
  case -3: // return 0 pictures
    strcpy(minRating, "1.0");
    refreshQueryNames(queryNum);
    clearStatus();
    refreshScreen();
    printf("No picture is returned in query. Minimal rating is set to %s", minRating);
    goto start;
  case -4: // return xxxx picture, but empty body.
    clearStatus();
    refreshScreen();
    printf("Empty body is returned for %ld. Next picture, please.", count);
    count++;
    goto start;
  case -1: // return HTTP error != 200
    clearStatus();
    printf("[%u]Error getting track info, next please(%ld)...", curFileStruct.httpErr, iddqd);

    OS_DROPAPP(pId);
    changedFormat = 1;
    goto rekey;
  }

  idkfa = processJson(atol(curFileStruct.authorIds), 0, 99); // Query for AuthorID

  if (idkfa < 0)
  {
    clearStatus();
    printf("Error getting author info %ld", atol(curFileStruct.authorIds));
    strcpy(curFileStruct.authorTitle, "-");
    strcpy(curFileStruct.authorRealName, "-");
  }

replay:

  // errn = getTrack2(iddqd); // Downloading the track

  errn = getTrack3(iddqd);

  if (errn == 0)
  {
    /*
      count = trackSelector(0);
      goto start;
    */
    OS_DROPAPP(pId);
    changedFormat = 1;
    goto rekey;
  }
resume:
  startTimer = time();
  printProgress(0);
  pId = runPlayer(); // Start the Player!
  printStatus();
  printInfo();
rekey:
  keypress = OS_GETKEY();

  switch (keypress) // & 0xdf сменить 251 и пр.
  {
  case 27:
  case 'e':
  case 'E':
    OS_DROPAPP(pId);
    OS_CLS(0);
    printf("Good bye...\r\n");
    OS_SETCOLOR(7);
    exit(0);
  case 248:
  case 'b':
  case 'B':
    changedFormat = 0;
    OS_DROPAPP(pId);
    clearStatus();
    printf("Player stopped...");
    count = trackSelector(1);
    goto start;
  case 251:
  case 32:
  case 'n':
  case 'N':
    changedFormat = 0;
    OS_DROPAPP(pId);
    clearStatus();
    printf("Player stopped...");
    count = trackSelector(0);
    goto start;
  case 'k':
  case 'K':
    OS_DROPAPP(pId);
    clearStatus();
    printf("Player stopped...");
    saveFlag = !saveFlag;
    printStatus();
    changedFormat = 0;
    goto replay;
  case 'q':
  case 'Q':
  {
    int selectedIndex;
    OS_DROPAPP(pId);
    clearStatus();
    printf("Player stopped...");

    /* 1. Открываем наше новое меню и получаем индекс выбранной строки (0..5) */
    /* В качестве начальной позиции передаем queryNum, но если выбран кастомный, */
    /* курсор встанет на первую кастомную строку (индекс 3) */
    selectedIndex = showQueryMenu(queryNum > 2 ? 3 : queryNum);
    OS_SETCOLOR(71); /* Сразу восстанавливаем стандартный цвет интерфейса плеера */
    /* 2. Если пользователь подтвердил выбор нажатием Enter (а не отменил через ESC) */
    if (selectedIndex != -1)
    {

      /* 3. Распределяем queryNum по вашей логике */
      if (selectedIndex <= 2)
      {
        /* Выбраны системные строки 0, 1 или 2 */
        queryNum = selectedIndex;
      }
      else
      {
        /* Выбрана любая кастомная строка (3, 4 или 5) -> взводим признак пользовательского запроса */
        queryNum = 3;
      }

      /* 4. Бесшовно копируем текст выбранной строки в буфер userQuery */
      /* Теперь плеер при формировании URL запроса возьмет именно актуальный текст */
      strncpy((char *)userQuery, (const char *)menuQueries[selectedIndex], sizeof(userQuery) - 1);
      userQuery[sizeof(userQuery) - 1] = '\0'; /* Гарантируем нуль-терминатор в конце */
      /* 5. Обновляем текстовую строку названия запроса на главном экране */
      refreshQueryNames(queryNum);

      /* 6. Перезапускаем плеер: сбрасываем счетчики и прыгаем на инициализацию соединения */
      OS_DROPAPP(pId);
      count = 0; /* Начинаем проигрывание с первого трека новой выборки */
      changedFormat = 0;
      goto start;
    }

    /* Если пользователь нажал ESC ? просто аккуратно перерисовываем главный экран */
    /* и продолжаем играть текущий трек, как будто ничего не произошло */
    goto start;
  }
  case 'j':
  case 'J':
    /* Инициализируем структуру напрямую без математики и strcpy */
    curWin.w = 22;
    curWin.x = 27; /* Заранее посчитано: 80 / 2 - 22 / 2 - 2 */
    curWin.y = 14;
    curWin.h = 1;
    curWin.text = 103;
    curWin.back = 103;

    /* Вместо тяжелой strcpy просто перенаправляем указатель на статическую строку */
    /* (Если в вашей структуре tittle объявлен как массив, например char tittle[32], */
    /* то возвращаем strcpy(curWin.tittle, "Track number:"); иначе ? пишем как ниже) */
    strcpy(curWin.tittle, "Track number:");

    if (inputBox(curWin, ""))
    {
      OS_SETCOLOR(71);

      /* Железная оптимизация размера: выкидываем sscanf, используем быстрый atol */
      count = atol((const char *)cmd);

      OS_DROPAPP(pId);

      if (count >= curFileStruct.totalAmount)
      {
        count = curFileStruct.totalAmount - 1;
      }

      changedFormat = 0;
      goto start;
    }
    break;
  case 'm':
  case 'M':
    curWin.w = 22;
    curWin.x = 80 / 2 - curWin.w / 2 - 2;
    curWin.y = 14;
    curWin.h = 1;
    curWin.text = 103;
    curWin.back = 103;
    strcpy(curWin.tittle, "Minimal rating:");

    if (inputBox(curWin, ""))
    {
      char counter;
      OS_SETCOLOR(71);
      for (counter = 0; counter < strlen(cmd); counter++)
      {
        if ((((cmd[counter] < '0') || (cmd[counter] > '9'))) && cmd[counter] != '.')
        {
          clearStatus();
          printf("Wrong input.[%s]", cmd);
          counter = 0;
          break;
        }
      }

      if (counter != 0)
      {
        strncpy(minRating, cmd, 5);
        refreshQueryNames(queryNum);
        count = 0;
      }
      refreshScreen();
    }
    OS_SETCOLOR(71);
    break;
  case 'f':
  case 'F':
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
    /*
        if (strstr(formats[curFormat], "tfc") != NULL)
        {
          cutOff = 0;
        }
        else
        {
          cutOff = 0;
        }
    */
    printStatus();
    printProgress(0);
    BDBOX(1, 2, 80, 6, 71, ' ');
    goto rekey;
  case 's':
  case 'S':
    OS_DROPAPP(pId);
    clearStatus();
    printf("Player stopped...");
    printProgress(0);
    changedFormat = 0;
    getchar();
    goto resume;
  case 'r':
  case 'R':
    rptFlag = !rptFlag;
    clearStatus();
    printStatus();
    goto rekey;
  case 'O':
  case 'o':
    showDesc = !showDesc;
    clearStatus();
    printf("Show Description = %u", showDesc);
    goto rekey;

  case 'd':
  case 'D':
    saveBak = saveFlag;
    saveFlag = 1;

    // errn = getTrack2(iddqd); // Downloading the track

    errn = getTrack3(iddqd);

    if (errn == 0)
    {
      /*
        count = trackSelector(0);
        goto start;
      */
      OS_DROPAPP(pId);
      changedFormat = 1;
      goto rekey;
    }

    saveFlag = saveBak;
    clearStatus();
    printf("File saved: [%s]...", curFileStruct.fileName);
    goto rekey;
  case 'i':
  case 'I':
    netDriver = !netDriver;
    if (netDriver == 1)
    {
      unsigned char q;
      clearStatus();
      printf("    ESP-COM mode enabled...");
      BDBOX(1, 14, 80, 8, 71, ' ');
      OS_SETXY(0, 14);
      loadEspConfig();
      uart_init(divider);
      espReBoot();

      for (q = 13; q < 23; q++)
      {
        OS_SETXY(0, q);
        spaces(80);
      }

      printHelp();
    }
    else
    {
      clearStatus();
      printf("    ZXNETUSB mode enabled...");
    }
    OS_SETXY(0, 0);
    OS_SETCOLOR(71);
    OS_SETCOLOR(95);
    printf("                           ZXART.EE radio for %s                    ", interfaces[netDriver]);
    OS_SETCOLOR(6);
    break;
  case 31:
    refreshScreen();
    break;
  default:
    break;
  }
  curTimer = time();
  curFileStruct.curPos = (curTimer - startTimer) / 50;
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
    printProgress(2);
    count = trackSelector(0);
    goto start;
  }
  if ((curTimer - oldTimer) > 49 && !changedFormat)
  {
    printProgress(1);
    oldTimer = curTimer;
  }
  YIELD();
  goto rekey;
}
