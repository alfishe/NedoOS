#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet_plug.h"

unsigned char residentPg;
unsigned char g_dataPg;

void at_init_banks(void)
{
  union APP_PAGES pg;
  unsigned int np;

  pg.l = OS_GETMAINPAGES();
  residentPg = pg.pgs.window_3;
  g_dataPg = 0u;
  np = OS_NEWPAGE();
  if (np <= 255u)
  {
    g_dataPg = (unsigned char)np;
  }
}

void at_path_to_ini(unsigned char *saved_path)
{
  OS_GETPATH(saved_path);
  OS_SETSYSDRV();
  OS_CHDIR("/");
  OS_CHDIR("ini");
}

void at_path_to_downloads(unsigned char *saved_path)
{
  OS_GETPATH(saved_path);
  OS_SETSYSDRV();
  (void)OS_MKDIR((unsigned char *)"../downloads");
  (void)OS_CHDIR((unsigned char *)"../downloads");
}
