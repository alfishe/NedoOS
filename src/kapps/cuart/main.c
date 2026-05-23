#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <../common/terminal.c>

#define true 1
#define false 0

#define WIN_TOP 1
#define WIN_BOTTOM 22
#define WIN_LEFT 1
#define WIN_RIGHT 80
#define STATUS_ROW 23
#define INPUT_ROW 24

#define SCREEN_HEIGHT 22

// --- ПЕРЕМЕННЫЕ ДЛЯ СТРОКИ ВВОДА КОМАНДЫ ---
int cmdpos = 0;
int cmd_cur = 0;
unsigned char cmd[128];
const unsigned char prefix[] = "CMD:> ";

// --- НАСТРОЙКИ ЭМУЛЯЦИИ UART ---
unsigned char loopback_enabled = 0;
unsigned char sim_uart_buf[256];
int sim_uart_wptr = 0;
int sim_uart_rptr = 0;

// --- БУФЕР ДАННЫХ UART ---
unsigned char netbuf[24000];
unsigned char uVer[] = "2.0";
int bufferPos = 0;
int endPos = 0;
int curpos = 0;

// --- УПРАВЛЕНИЕ ПОСТРАНИЧНОЙ НАВИГАЦИЕЙ ---
#define MAX_PAGES 200
unsigned int page_offsets[MAX_PAGES];
int current_page = 0;
int total_pages = 1;

// --- ВИРТУАЛЬНЫЙ КУРСОР ДЛЯ ИНКРЕМЕНТАЛЬНОЙ ДОПЕЧАТКИ ---
unsigned char live_line = 0;
unsigned char live_col = 0;

// --- ФЛАГИ ОБНОВЛЕНИЯ ЭКРАНА ---
unsigned char need_screen_redraw = 1;
unsigned char input_needs_redraw = 1;
unsigned char live_append_triggered = 0;
unsigned int screen_pos = 0; // Точка, до которой экран уже напечатан
unsigned int oldpos = 0;
unsigned char key;

// --- ПЕРЕМЕННЫЕ ДЛЯ ПОДДЕРЖКИ ЖЕЛЕЗНОГО UART И esp-com.c ---
const unsigned char gotWiFi[] = "WIFI GOT IP";
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
unsigned long factor, timerok, count = 0;
const unsigned int magic = 15;
unsigned char curPath[128];
unsigned char directMode = 0;

void clearStatus(void)
{
}

void delay(unsigned long counter)
{
  unsigned long start, finish;
  counter = counter / 20;
  if (counter < 1)
    counter = 1;
  start = time();
  finish = start + counter;
  while (start < finish)
  {
    start = time();
  }
}

void spaces(unsigned char number)
{
  while (number > 0)
  {
    putchar(' ');
    number--;
  }
}

// Подключаем низкоуровневую работу с ESP32
#include <../common/esp-com.c>

void getdata(void)
{
  if (loopback_enabled)
  {
    while (sim_uart_rptr != sim_uart_wptr)
    {
      netbuf[bufferPos] = sim_uart_buf[sim_uart_rptr];
      sim_uart_rptr = (sim_uart_rptr + 1) % 256;
      bufferPos++;
      if (bufferPos > 8191)
      {
        endPos = bufferPos;
        bufferPos = 0;
      }
    }
    return;
  }

  if (uart_hasByte() == 0)
  {
    uart_setrts(2);
  }
  while (uart_hasByte() != 0)
  {
    netbuf[bufferPos] = uart_read();
    bufferPos++;
    if (bufferPos > 8191)
    {
      endPos = bufferPos;
      bufferPos = 0;
    }
  }
}

void saveBuff(void)
{
  int len;
  unsigned long size;
  FILE *fp1;
  unsigned char crlf[2] = {13, 10};
  fp1 = OS_OPENHANDLE("buffer.log", 0x80);
  if (((int)fp1) & 0xff)
  {
    fp1 = OS_CREATEHANDLE("buffer.log", 0x80);
    if (((int)fp1) & 0xff)
      return;
    OS_CLOSEHANDLE(fp1);
    fp1 = OS_OPENHANDLE("buffer.log", 0x80);
    if (((int)fp1) & 0xff)
      return;
  }
  size = OS_GETFILESIZE(fp1);
  len = curpos;
  OS_SEEKHANDLE(fp1, size);
  OS_WRITEHANDLE(crlf, fp1, 2);
  OS_WRITEHANDLE("********************************************************************************", fp1, 80);
  OS_WRITEHANDLE(crlf, fp1, 2);
  OS_WRITEHANDLE(netbuf, fp1, len);
  OS_CLOSEHANDLE(fp1);
}

void testQueue(void)
{
  sendcommand("AT+CIPSNTPTIME?");
  getdata();
  delay(500);
  sendcommand("AT+CIPSNTPCFG=1,300,\"0.pool.ntp.org\",\"://google.com\"");
  getdata();
  delay(500);
  sendcommand("AT+CIPSNTPTIME?");
  getdata();
}

void redrawInputLine(void)
{
  int i;
  int printed_chars;
  OS_SETXY(1, INPUT_ROW);
  OS_SETCOLOR(70);

  printed_chars = 0;
  while (prefix[printed_chars] != '\0')
  {
    putchar(prefix[printed_chars]);
    printed_chars++;
  }

  for (i = 0; i < cmdpos; i++)
  {
    if (i == cmd_cur)
    {
      putchar('_');
      printed_chars++;
    }
    putchar(cmd[i]);
    printed_chars++;
  }

  if (cmd_cur == cmdpos)
  {
    putchar('_');
    printed_chars++;
  }

  while (printed_chars < 78)
  {
    putchar(' ');
    printed_chars++;
  }
  OS_SETXY(7 + cmd_cur, INPUT_ROW);
}

void updateStatus(unsigned int currentDivider, unsigned char isDirect)
{
  unsigned long baud = 115200 / currentDivider;
  OS_SETXY(0, STATUS_ROW);
  OS_SETCOLOR(103);
  spaces(80);
  OS_SETXY(1, STATUS_ROW);
  printf(" SPEED: %lu bps [Div:%u] | MODE: %s | PAGE: %d/%d ",
         baud, currentDivider, isDirect ? "DIRECT" : "COMMAND", current_page + 1, total_pages);
  OS_SETCOLOR(70);
  OS_SETXY(7 + cmd_cur, INPUT_ROW);
}

void screenRedraw(void)
{
  OS_CLS(0);
  OS_SETXY(0, 0);
  OS_SETCOLOR(103);
  spaces(80);
  OS_SETXY(0, 0);
  printf(" UART TERMINAL FOR NedoOS %s [Build:%s %s]", uVer, __DATE__, __TIME__);
  updateStatus(divider, directMode);
  redrawInputLine();
}

void renderWin(void)
{
  oldpos = curpos; // Запоминаем, где начали

  while (curpos < bufferPos)
  {
    curpos++;
  }

  // Если пришли новые данные И мы на последней живой странице
  if (curpos != oldpos && current_page == total_pages - 1)
  {
    live_append_triggered = 1;
  }
}

unsigned int renderLogPage(unsigned int startPos)
{
  unsigned int bufPos = startPos;
  char justWrapped = 0;
  unsigned char row;

  // Сброс виртуального курсора
  live_line = 0;
  live_col = 0;

  for (row = WIN_TOP; row <= WIN_BOTTOM; row++)
  {
    OS_SETXY(WIN_LEFT, row);
    spaces(WIN_RIGHT);
  }

  OS_SETXY(WIN_LEFT, WIN_TOP);
  OS_SETCOLOR(70);

  while (live_line < SCREEN_HEIGHT && bufPos < bufferPos)
  {
    unsigned char byte = netbuf[bufPos];

    // 1. Сразу отбрасываем \r, просто двигая указатель вперед
    if (byte == 0xd)
    {
      bufPos++;
      continue;
    }

    // 2. Перенос строки делаем ТОЛЬКО по \n
    if (byte == 0xa)
    {
      if (!justWrapped)
      {
        live_line++;
        if (live_line < SCREEN_HEIGHT)
        {
          OS_SETXY(WIN_LEFT, WIN_TOP + live_line);
        }
      }
      live_col = 0;
      justWrapped = 0; // Сбрасываем для следующей строки
      bufPos++;
      continue;
    }

    putchar(byte);
    live_col++;
    bufPos++;
    justWrapped = 0;

    if (live_col >= WIN_RIGHT)
    {
      live_line++;
      live_col = 0;
      justWrapped = 1;
      if (live_line < SCREEN_HEIGHT)
      {
        OS_SETXY(WIN_LEFT, WIN_TOP + live_line);
      }
    }
  }
  return bufPos;
}

void appendLiveLogs(unsigned int from_pos)
{
  char justWrapped = 0;

  // Встаем точно туда, где закончили печать в прошлый раз
  if (live_line < SCREEN_HEIGHT)
  {
    OS_SETXY(WIN_LEFT + live_col, WIN_TOP + live_line);
  }

  while (from_pos < bufferPos)
  {
    unsigned char byte = netbuf[from_pos];

    // 1. Игнорируем \r
    if (byte == 0xd)
    {
      from_pos++;
      continue;
    }

    // 2. Переносим строго по \n
    if (byte == 0xa)
    {
      if (!justWrapped)
      {
        live_line++;
        if (live_line < SCREEN_HEIGHT)
        {
          OS_SETXY(WIN_LEFT, WIN_TOP + live_line);
        }
      }
      live_col = 0;
      justWrapped = 0;
      from_pos++;

      if (live_line >= SCREEN_HEIGHT)
        break;
      continue;
    }

    putchar(byte);
    live_col++;
    from_pos++;
    justWrapped = 0;

    if (live_col >= WIN_RIGHT)
    {
      live_line++;
      live_col = 0;
      justWrapped = 1;
      if (live_line < SCREEN_HEIGHT)
      {
        OS_SETXY(WIN_LEFT, WIN_TOP + live_line);
      }
      if (live_line >= SCREEN_HEIGHT)
        break;
    }
  }

  // Страница заполнилась под завязку!
  if (live_line >= SCREEN_HEIGHT && total_pages < MAX_PAGES)
  {
    // Было: while (from_pos < bufferPos && (netbuf[from_pos] == 0xd || netbuf[from_pos] == 0xa))
    // Меняем на проверку только \n и \r:
    while (from_pos < bufferPos && (netbuf[from_pos] == 0xd || netbuf[from_pos] == 0xa))
    {
      from_pos++;
    }

    page_offsets[total_pages] = from_pos; // Теперь здесь лежит чистая позиция старта!
    total_pages++;
    current_page = total_pages - 1;

    live_line = 0;
    live_col = 0;
    need_screen_redraw = 1; // Запрашиваем полную очистку под новую чистую страницу
  }
  else
  {
    OS_SETXY(7 + cmd_cur, INPUT_ROW); // Возвращаем курсор в строку ввода
  }
}

void handleKey(unsigned char key)
{
  if (key == 0)
    return;

  switch (key)
  {
  case 30:
    directMode = !directMode;
    updateStatus(divider, directMode);
    return; // Выходим, чтобы этот байт не улетел в UART
  case 246: // PgUp
    if (current_page > 0)
    {
      current_page--;
      need_screen_redraw = 1;
    }
    break;
  case 247: // PgDn
    if (current_page < total_pages - 1)
    {
      current_page++;
      need_screen_redraw = 1;
    }
    break;
  }

  if (directMode == 1)
  {
    uart_write(key);
    if (key == 13)
    {
      uart_write(10);
    }

    return;
  }

  switch (key)
  {
  case 177:
    divider = 1;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 178:
    divider = 2;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 179:
    divider = 3;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 180:
    divider = 4;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 181:
    divider = 6;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 182:
    divider = 8;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 183:
    divider = 12;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 184:
    divider = 24;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 185:
    divider = 48;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 176:
    divider = 96;
    uart_init(divider);
    updateStatus(divider, directMode);
    break;
  case 13:
    if (cmdpos > 0)
    {
      if (loopback_enabled)
      {
        unsigned int i;
        for (i = 0; i < cmdpos; i++)
        {
          sim_uart_buf[sim_uart_wptr] = cmd[i];
          sim_uart_wptr = (sim_uart_wptr + 1) % 256;
        }
        sim_uart_buf[sim_uart_wptr] = '\r';
        sim_uart_wptr = (sim_uart_wptr + 1) % 256;
        sim_uart_buf[sim_uart_wptr] = '\n';
        sim_uart_wptr = (sim_uart_wptr + 1) % 256;
        sim_uart_buf[sim_uart_wptr] = 'O';
        sim_uart_wptr = (sim_uart_wptr + 1) % 256;
        sim_uart_buf[sim_uart_wptr] = 'K';
        sim_uart_wptr = (sim_uart_wptr + 1) % 256;
        sim_uart_buf[sim_uart_wptr] = '\r';
        sim_uart_wptr = (sim_uart_wptr + 1) % 256;
        sim_uart_buf[sim_uart_wptr] = '\n';
        sim_uart_wptr = (sim_uart_wptr + 1) % 256;
      }
      else
      {
        sendcommand(cmd);
      }
      cmdpos = 0;
      cmd_cur = 0;
      input_needs_redraw = 1;
    }
    break;
  case 19:
    saveBuff();
    break;
  case 27:
    exit(0);
    break;
  case 8:
    if (cmd_cur > 0)
    {
      int i;
      for (i = cmd_cur - 1; i < cmdpos; i++)
      {
        cmd[i] = cmd[i + 1];
      }
      cmdpos--;
      cmd_cur--;
      input_needs_redraw = 1;
    }
    break;
  case 248:
    if (cmd_cur > 0)
    {
      cmd_cur--;
      input_needs_redraw = 1;
    }
    break;
  case 251:
    if (cmd_cur < cmdpos)
    {
      cmd_cur++;
      input_needs_redraw = 1;
    }
    break;
  case 28:
    testQueue();
    break;
  case 21:
    sendcommand("AT+CIUPDATE");
    break;
  default:
    if (key >= 32 && cmdpos < 70)
    {
      int i;
      for (i = cmdpos; i >= cmd_cur; i--)
      {
        cmd[i + 1] = cmd[i];
      }
      cmd[cmd_cur] = key;
      cmdpos++;
      cmd_cur++;
      cmd[cmdpos] = 0;
      input_needs_redraw = 1;
    }
    break;
  }
}
C_task main(void)
{
  OS_SETGFX(0x86);
  OS_CLS(0);
  if (!loopback_enabled)
  {
    loadEspConfig();
    uart_init(divider);
  }
  screenRedraw();
  page_offsets[0] = 0;
  current_page = 0;
  total_pages = 1;
  cmd[0] = 0;
  cmdpos = 0;
  while (1)
  {
    key = OS_GETKEY();
    if (key != 0)
    {
      handleKey(key);
    }
    getdata();
    renderWin();
    // А. ПОЛНАЯ ТЯЖЕЛАЯ ПЕРЕРИСОВКА
    if (need_screen_redraw)
    {
      unsigned int next_page_start;
      next_page_start = renderLogPage(page_offsets[current_page]);
      if (current_page == total_pages - 1 && next_page_start < bufferPos && total_pages < MAX_PAGES)
      {
        page_offsets[total_pages] = next_page_start;
        total_pages++;
      }
      updateStatus(divider, directMode);
      input_needs_redraw = 1;
      need_screen_redraw = 0;
      live_append_triggered = 0;
    }

    // Б. БЫСТРАЯ ЛЕГКАЯ ДОПЕЧАТКА СИМВОЛОВ
    if (live_append_triggered && !need_screen_redraw)
    {
      if (current_page == total_pages - 1)
      {
        appendLiveLogs(oldpos);
      }
      live_append_triggered = 0;
    }

    // В. ОБНОВЛЕНИЕ СТРОКИ ВВОДА КОМАНДЫ
    if (input_needs_redraw)
    {
      redrawInputLine();
      input_needs_redraw = 0;
    }
  }
  return 0;
}
