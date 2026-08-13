#include <intrz80.h>
#include <oscalls.h>
#include "app_bank.h"

unsigned char bank_window_current(void)
{
  union APP_PAGES cur;

  cur.l = OS_GETMAINPAGES();
  return cur.pgs.window_3;
}

unsigned char bank_push(unsigned char page)
{
  unsigned char saved;

  saved = bank_window_current();
  SETPG32KHIGH(page);
  return saved;
}
