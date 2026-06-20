#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include "atelnet.h"
#include "ansi_file.h"

static const unsigned char ver[] = "ansiview 1.01";

static char g_path_buf[128];

static void wait_key(void)
{
  do
  {
    YIELD();
  } while ((OS_GETKEY() & 0xFFL) == 0L);
}

static void show_usage(void)
{
  term_cls(0x07u);
  term_set_xy(0u, 0u);
  printf("%s\r\n", ver);
  term_set_xy(0u, 2u);
  printf("Usage:\r\n");
  term_set_xy(2u, 3u);
  printf("ansiview file.ans\r\n");
  term_set_xy(2u, 4u);
  printf("ansiview -f file.ans\r\n");
  term_set_xy(2u, 5u);
  printf("ansiview          (type path at prompt)\r\n");
  term_set_xy(2u, 7u);
  printf("  Up/Down  scroll  any key  exit\r\n");
  term_set_xy(0u, TERM_LAST_ROW);
  printf("Press any key...");
  wait_key();
}

static unsigned char read_path_line(void)
{
  unsigned int pos;
  unsigned char key;

  memset(g_path_buf, 0, sizeof(g_path_buf));
  pos = 0u;

  term_cls(0x07u);
  term_set_xy(0u, 0u);
  printf("%s\r\n", ver);
  term_set_xy(0u, 2u);
  printf("Enter ANSI file path:\r\n");
  term_set_xy(0u, 4u);
  printf("> ");

  for (;;)
  {
    YIELD();
    key = (unsigned char)(OS_GETKEY() & 0xFFL);
    if (key == 0u)
    {
      continue;
    }
    if (key == 13u || key == 10u)
    {
      break;
    }
    if (key == 27u)
    {
      return 0u;
    }
    if (key == 8u || key == 127u)
    {
      if (pos > 0u)
      {
        pos--;
        g_path_buf[pos] = 0;
        printf("\b \b");
      }
      continue;
    }
    if (key >= 32u && key < 127u && pos < sizeof(g_path_buf) - 1u)
    {
      g_path_buf[pos++] = (char)key;
      g_path_buf[pos] = 0;
      putchar((int)key);
    }
  }

  return g_path_buf[0] != 0;
}

static const char *resolve_path(int argc, char *argv[])
{
  int i;
  const char *path;

  path = 0;
  for (i = 1; i < argc; i++)
  {
    if (strcmp(argv[i], "-f") == 0)
    {
      if (i + 1 < argc)
      {
        path = argv[++i];
      }
      continue;
    }
    if (argv[i][0] == '-' && (argv[i][1] == 'h' || argv[i][1] == '?') && argv[i][2] == 0)
    {
      return 0;
    }
    if (argv[i][0] != '-')
    {
      path = argv[i];
    }
  }

  if (path != 0 && path[0] != 0)
  {
    return path;
  }

  if (read_path_line())
  {
    return g_path_buf;
  }

  return 0;
}

C_task main(int argc, char *argv[])
{
  const char *path;

  OS_HIDEFROMPARENT();
  OS_SETGFX(6u);

  path = resolve_path(argc, argv);
  if (path == 0)
  {
    show_usage();
    return 0;
  }

  ansi_show_file(path);
  return 0;
}
