#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include "atelnet.h"

static const char ver[] = "atelnet 1.82";

static void r_wait_key(void)
{
  do
  {
    YIELD();
  } while ((OS_GETKEY() & 0xFFL) == 0L);
}

void r_show_ansiview_hint(const char *path)
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
  r_wait_key();
}

int r_host_looks_like_file(const char *host)
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

void r_show_usage(void)
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
  printf("  F10=exit  F2=address book (in session)\r\n");
#ifndef ATELNET_NO_ZMODEM
  term_set_xy(2u, 10u);
  printf("  F6=ZMODEM receive (after sz on host)\r\n");
  term_set_xy(2u, 11u);
#else
  term_set_xy(2u, 10u);
#endif
  printf("  ESC=send to host\r\n");
  term_set_xy(0u, TERM_LAST_ROW);
  printf("Press any key...");
  r_wait_key();
}

int r_parse_host_port(char *arg, char *host, unsigned int host_sz, unsigned int *port)
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

void r_show_bad_host(void)
{
  term_cls(0x4Fu);
  term_set_xy(0u, 0u);
  printf("atelnet: bad host argument\r\n");
  term_set_xy(0u, 2u);
  printf("Press any key...");
  r_wait_key();
}
