#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include <stdio.h>
#include <intrz80.h>
#include <oscalls.h>
#include "term.h"

extern void term_palette_begin(void);
extern void term_palette_restore(void);
extern void r_wait_key(void);

void r_show_connecting(const char *host, unsigned int port)
{
  term_cls(0x07u);
  term_set_xy(0u, 0u);
  term_set_color(0x07u);
  printf("Connecting %s:%u ...", host, port);
}

void r_show_net_error(const char *msg)
{
  term_cls(0x4Fu);
  term_set_xy(0u, 0u);
  printf("atelnet: %s\r\n", msg);
  term_set_xy(0u, 2u);
  printf("Press any key...");
  r_wait_key();
}

void r_show_session_end(unsigned char user_quit, unsigned char sock_err, unsigned int rx_total)
{
  if (sock_err != 0u)
  {
    term_cls(0x4Fu);
    term_set_xy(0u, 0u);
    printf("atelnet: connection lost (err %u)\r\n", (unsigned int)sock_err);
    term_set_xy(0u, 2u);
    printf("Press any key...");
    r_wait_key();
    return;
  }
  if (rx_total == 0u)
  {
    term_cls(0x4Fu);
    term_set_xy(0u, 0u);
    if (user_quit != 0u)
    {
      printf("atelnet: host sent no data\r\n");
    }
    else
    {
      printf("atelnet: host closed without data\r\n");
    }
    term_set_xy(0u, 2u);
    printf("BBS may rate-limit. Wait and retry.\r\n");
    term_set_xy(0u, 4u);
    printf("Press any key...");
    r_wait_key();
  }
}

void r_telnet_display_prep(unsigned char cp866)
{
  term_init();
  term_cls(0x07u);
  if (cp866 != 0u)
  {
    term_set_wire_cp866();
  }
  else
  {
    term_set_wire_cp437();
  }
  term_palette_begin();
}
