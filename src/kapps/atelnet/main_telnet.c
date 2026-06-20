#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet.h"
#include "netglue.h"
#include "telnet_sess.h"
#include "telbook.h"

static const unsigned char ver[] = "atelnet 1.51";

static void wait_key(void)
{
  do
  {
    YIELD();
  } while ((OS_GETKEY() & 0xFFL) == 0L);
}

static void show_ansiview_hint(const char *path)
{
  term_cls(0x4Fu);
  term_set_xy(0u, 0u);
  printf("ANSI files: use ansiview.com\r\n");
  if (path != 0 && path[0] != 0)
  {
    term_set_xy(0u, 2u);
    printf("ansiview %s\r\n", path);
  }
  term_set_xy(0u, TERM_LAST_ROW);
  printf("Press any key...");
  wait_key();
}

static int host_looks_like_file(const char *host)
{
  const char *dot;

  if (strchr(host, '\\') != 0 || strchr(host, '/') != 0)
  {
    return 1;
  }
  dot = strrchr(host, '.');
  if (dot == 0)
  {
    return 0;
  }
  if (strcmp(dot, ".ans") == 0 || strcmp(dot, ".ANS") == 0)
  {
    return 1;
  }
  if (strcmp(dot, ".asc") == 0 || strcmp(dot, ".ASC") == 0)
  {
    return 1;
  }
  return 0;
}

static void show_usage(void)
{
  term_cls(0x07u);
  term_set_xy(0u, 0u);
  printf("%s\r\n", ver);
  term_set_xy(0u, 2u);
  printf("Usage:\r\n");
  term_set_xy(2u, 3u);
  printf("atelnet host[:port]\r\n");
  term_set_xy(2u, 5u);
  printf("  host[:port]  telnet session (port 23)\r\n");
  term_set_xy(2u, 6u);
  printf("  -d          debug status (RX/TX line)\r\n");
  term_set_xy(2u, 7u);
  printf("  -866        CP866 wire (default CP437)\r\n");
  term_set_xy(2u, 8u);
  printf("  (no args)    address book\r\n");
  term_set_xy(2u, 9u);
  printf("  F6=Zmodem  F7=Ymodem  F8=dump log on fail\r\n");
  term_set_xy(2u, 10u);
  printf("  On BBS: start download, then press F6 here\r\n");
  term_set_xy(2u, 11u);
  printf("  ANSI files: use ansiview.com\r\n");
  term_set_xy(2u, 12u);
  printf("  ESC=send to host\r\n");
  term_set_xy(0u, TERM_LAST_ROW);
  printf("Press any key...");
  do
  {
    YIELD();
  } while ((OS_GETKEY() & 0xFFL) == 0L);
}

static int parse_host_port(char *arg, char *host, unsigned int host_sz, unsigned int *port)
{
  char *colon;
  unsigned long p;

  strncpy(host, arg, host_sz - 1u);
  host[host_sz - 1u] = 0;

  colon = strchr(host, ':');
  if (colon != NULL)
  {
    *colon = 0;
    p = strtoul(colon + 1, NULL, 10);
    if (p == 0ul || p > 65535ul)
    {
      return 0;
    }
    *port = (unsigned int)p;
  }
  else
  {
    *port = 23u;
  }

  return host[0] != 0;
}

static int run_telnet_arg(char *arg, unsigned char debug, unsigned char cp866)
{
  char host[128];
  unsigned int port;

  if (!parse_host_port(arg, host, sizeof(host), &port))
  {
    return 0;
  }
  return telnet_session(host, port, debug, cp866);
}

C_task main(int argc, char *argv[])
{
  int i;
  unsigned char debug;
  unsigned char cp866;
  char *host_arg;

  OS_HIDEFROMPARENT();
  OS_SETGFX(6u);
  term_init();
  net_init();

  debug = 0u;
  cp866 = 0u;
  host_arg = 0;

  if (argc < 2)
  {
    char host[128];
    unsigned int port;

    if (telbook_run(host, sizeof(host), &port, &cp866, &debug))
    {
      telnet_session(host, port, debug, cp866);
    }
    return 0;
  }

  for (i = 1; i < argc; i++)
  {
    if (argv[i][0] == '-' && argv[i][1] == 'd' && argv[i][2] == 0)
    {
      debug = 1u;
      continue;
    }
    if (argv[i][0] == '-' && strcmp(argv[i], "-866") == 0)
    {
      cp866 = 1u;
      continue;
    }
    if (argv[i][0] == '-' && (argv[i][1] == 'h' || argv[i][1] == '?') && argv[i][2] == 0)
    {
      show_usage();
      return 0;
    }
    if (argv[i][0] == '-' && argv[i][1] == 'f' && argv[i][2] == 0)
    {
      show_ansiview_hint((i + 1 < argc) ? argv[i + 1] : 0);
      return 0;
    }
    if (argv[i][0] != '-')
    {
      host_arg = argv[i];
    }
  }

  if (host_arg == 0)
  {
    show_usage();
    return 0;
  }

  if (host_looks_like_file(host_arg))
  {
    show_ansiview_hint(host_arg);
    return 0;
  }

  if (run_telnet_arg(host_arg, debug, cp866))
  {
    return 0;
  }

  term_cls(0x4Fu);
  term_set_xy(0u, 0u);
  printf("atelnet: bad host argument\r\n");
  term_set_xy(0u, 2u);
  printf("Press any key...");
  do
  {
    YIELD();
  } while ((OS_GETKEY() & 0xFFL) == 0L);
  return 0;
}
