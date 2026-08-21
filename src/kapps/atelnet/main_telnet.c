#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include "term.h"
#include "telnet_sess.h"
#include "atelnet_plug.h"
#include "netglue.h"

C_task main(int argc, char *argv[])
{
  int i;
  unsigned char debug;
  unsigned char cp866;
  char *host_arg;
  char *a;

  OS_HIDEFROMPARENT();
  OS_SETGFX(6u);
  term_init();
  at_init_banks();
  {
    unsigned char drv;

    drv = net_init();
    if (drv == 1u || drv == 2u)
    {
      r_show_need_wiznet(drv);
      return 0;
    }
  }

  debug = 0u;
  cp866 = 0u;
  host_arg = 0;

  if (argc < 2)
  {
    char host[128];
    unsigned int port;

    if (r_telbook_run(host, sizeof(host), &port, &cp866, &debug))
    {
      telnet_session(host, port, debug, cp866);
    }
    return 0;
  }

  for (i = 1; i < argc; i++)
  {
    a = argv[i];
    if (a[0] != '-')
    {
      host_arg = a;
      continue;
    }
    if (a[1] == 'd' && a[2] == 0)
    {
      debug = 1u;
      continue;
    }
    if (strcmp(a, "-866") == 0)
    {
      cp866 = 1u;
      continue;
    }
    if ((a[1] == 'h' || a[1] == '?') && a[2] == 0)
    {
      r_show_usage();
      return 0;
    }
    if (a[1] == 'f' && a[2] == 0)
    {
      r_show_ansiview_hint((i + 1 < argc) ? argv[i + 1] : 0);
      return 0;
    }
  }

  if (host_arg == 0)
  {
    r_show_usage();
    return 0;
  }

  if (r_host_looks_like_file(host_arg))
  {
    r_show_ansiview_hint(host_arg);
    return 0;
  }

  {
    char host[128];
    unsigned int port;

    if (r_parse_host_port(host_arg, host, sizeof(host), &port))
    {
      telnet_session(host, port, debug, cp866);
      return 0;
    }
  }

  r_show_bad_host();
  return 0;
}
