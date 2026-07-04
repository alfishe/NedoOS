#include "telbook.h"
#include "app_bank.h"
#include "atelnet_plug.h"

int telbook_run(char *host, unsigned int host_sz, unsigned int *port,
                unsigned char *cp866, unsigned char *debug)
{
  unsigned char saved;
  int rc;

  saved = bank_push(residentPg);
  rc = r_telbook_run(host, host_sz, port, cp866, debug);
  bank_pop(saved);
  return rc;
}
