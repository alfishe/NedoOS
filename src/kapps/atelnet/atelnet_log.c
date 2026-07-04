#include "app_bank.h"
#include "atelnet_plug.h"
#include "atelnet_log.h"

void at_log_write(const char *logline, const char *place)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  r_at_log_write(logline, place);
  bank_pop(saved);
}
