#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "app_bank.h"
#include "atelnet_plug.h"

unsigned char residentPg;
unsigned char g_dataPg;
union APP_PAGES main_pg;

void at_init_banks(void)
{
  main_pg.l = OS_GETMAINPAGES();
  residentPg = main_pg.pgs.window_3;
  bank_slot_set(AT_BANK_SLOT_RESIDENT, residentPg);

  g_dataPg = 0u;
  if (bank_os_new_page(&g_dataPg))
  {
    bank_slot_set(AT_BANK_SLOT_DATA, g_dataPg);
    bank_data_fill(g_dataPg, 0u);
  }
}

void at_resident_map(void)
{
  bank_window_map(residentPg);
}

unsigned char at_zmodem_bank_enter(void)
{
  if (g_dataPg == 0u)
  {
    return 0u;
  }
  return bank_push(g_dataPg);
}

void at_zmodem_bank_leave(unsigned char saved)
{
  if (g_dataPg != 0u)
  {
    bank_pop(saved);
  }
}

void at_path_to_ini(unsigned char *saved_path)
{
  OS_GETPATH((unsigned int)saved_path);
  OS_SETSYSDRV();
  OS_CHDIR("/");
  OS_CHDIR("ini");
}

void at_path_to_downloads(unsigned char *saved_path)
{
  OS_GETPATH((unsigned int)saved_path);
  OS_SETSYSDRV();
  (void)OS_MKDIR((unsigned char *)"../downloads");
  (void)OS_CHDIR((unsigned char *)"../downloads");
}
