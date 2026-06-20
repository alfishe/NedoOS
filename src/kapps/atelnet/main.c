#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet.h"
#include "netglue.h"
#include "telnet_sess.h"
#include "ansi_file.h"

static const unsigned char ver[] = "atelnet 1.10";

static void show_usage(void)
{
  term_cls(0x07u);
  term_set_xy(0u, 0u);
  printf("%s\r\n", ver);
  term_set_xy(0u, 2u);
  printf("Usage:\r\n");
  term_set_xy(2u, 3u);
  printf("atelnet host[:port]\r\n");
  term_set_xy(2u, 4u);
  printf("atelnet -f file.ans\r\n");
  term_set_xy(2u, 6u);
  printf("  host[:port]  telnet session (port 23)\r\n");
  term_set_xy(2u, 7u);
  printf("  -f file     show ANSI art from disk\r\n");
  term_set_xy(2u, 8u);
  printf("  -d          debug status (RX/TX line)\r\n");
  term_set_xy(2u, 9u);
  printf("  -866        CP866 wire (default CP437)\r\n");
  term_set_xy(2u, 10u);
  printf("  F5=quit  ESC=send to host\r\n");
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

  if (argc < 2)
  {
    show_usage();
    return 0;
  }

  debug = 0u;
  cp866 = 0u;
  host_arg = 0;

  for (i = 1; i < argc; i++)
  {
    if (argv[i][0] == '-' && argv[i][1] == 'f' && argv[i][2] == 0)
    {
      if (i + 1 >= argc)
      {
        show_usage();
        return 0;
      }
      ansi_show_file(argv[i + 1]);
      return 0;
    }
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
