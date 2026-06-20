#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet.h"
#include "term_doc.h"
#include "ansi_file.h"

#define ANSI_READ_CHUNK 512u

/* BDOS extended key codes (sysdefs.asm cs5..cs8). */
#define TERM_KEY_UP    250u
#define TERM_KEY_DOWN  249u

static unsigned char file_chunk[ANSI_READ_CHUNK];

static unsigned char poll_key(void)
{
  signed long k;

  YIELD();
  k = OS_GETKEY();
  return (unsigned char)(k & 0xFFL);
}

static unsigned char read_key(void)
{
  unsigned char k;

  do
  {
    k = poll_key();
  } while (k == 0u);
  return k;
}

static void show_error(const char *msg)
{
  term_cls(0x4Fu);
  term_set_xy(0u, 0u);
  printf("ansiview: %s\r\n", msg);
  term_set_xy(0u, 2u);
  printf("Press any key...");
  read_key();
}

static void scroll_interactive(void)
{
  unsigned char key;

  term_doc_paint();

  for (;;)
  {
    key = read_key();
    if (key == TERM_KEY_UP)
    {
      (void)term_doc_scroll_view(-1);
    }
    else if (key == TERM_KEY_DOWN)
    {
      (void)term_doc_scroll_view(1);
    }
    else
    {
      break;
    }
  }
}

int ansi_show_file(const char *path)
{
  FILE *fp;
  unsigned int n;
  unsigned int i;
  unsigned char stop;

  fp = OS_OPENHANDLE((unsigned char *)path, 0x80u);
  if (((int)fp) & 0xFF)
  {
    show_error("cannot open file");
    return 0;
  }

  term_cls(0x07u);
  term_init();
  term_palette_begin();
  term_doc_begin();
  term_doc_set_defer_paint(1u);
  stop = 0u;

  for (;;)
  {
    n = OS_READHANDLE(file_chunk, fp, ANSI_READ_CHUNK);
    if (n == 0u)
    {
      break;
    }
    for (i = 0u; i < n && stop == 0u; i++)
    {
      if (term_feed(file_chunk[i]) == 0)
      {
        stop = 1u;
      }
    }
    if (stop != 0u)
    {
      break;
    }
    YIELD();
  }

  OS_CLOSEHANDLE(fp);
  term_doc_set_defer_paint(0u);
  term_doc_goto_top();
  scroll_interactive();
  term_doc_end();
  term_palette_restore();
  return 1;
}
