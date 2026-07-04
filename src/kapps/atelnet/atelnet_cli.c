#include "app_bank.h"
#include "atelnet_plug.h"

void at_show_ansiview_hint(const char *path)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  r_show_ansiview_hint(path);
  bank_pop(saved);
}

int at_host_looks_like_file(const char *host)
{
  unsigned char saved;
  int rc;

  saved = bank_push(residentPg);
  rc = r_host_looks_like_file(host);
  bank_pop(saved);
  return rc;
}

void at_show_usage(void)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  r_show_usage();
  bank_pop(saved);
}

int at_parse_host_port(char *arg, char *host, unsigned int host_sz, unsigned int *port)
{
  unsigned char saved;
  int rc;

  saved = bank_push(residentPg);
  rc = r_parse_host_port(arg, host, host_sz, port);
  bank_pop(saved);
  return rc;
}

void at_show_bad_host(void)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  r_show_bad_host();
  bank_pop(saved);
}
