#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "term.h"
#include "telnet_sess.h"
#include "telbook.h"
#include "atelnet_plug.h"
#include "atelnet_cli.h"
#include "atelnet_net.h"

static int run_telnet_arg(char *arg, unsigned char debug, unsigned char cp866)
{
  char host[128];
  unsigned int port;

  if (!at_parse_host_port(arg, host, sizeof(host), &port))
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
  at_init_banks();
  at_net_init();

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
      at_show_usage();
      return 0;
    }
    if (argv[i][0] == '-' && argv[i][1] == 'f' && argv[i][2] == 0)
    {
      at_show_ansiview_hint((i + 1 < argc) ? argv[i + 1] : 0);
      return 0;
    }
    if (argv[i][0] != '-')
    {
      host_arg = argv[i];
    }
  }

  if (host_arg == 0)
  {
    at_show_usage();
    return 0;
  }

  if (at_host_looks_like_file(host_arg))
  {
    at_show_ansiview_hint(host_arg);
    return 0;
  }

  if (run_telnet_arg(host_arg, debug, cp866))
  {
    return 0;
  }

  at_show_bad_host();
  return 0;
}
