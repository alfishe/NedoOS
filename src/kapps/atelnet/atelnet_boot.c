#include "app_bank.h"
#include "atelnet_plug.h"
#include "netglue.h"

void at_show_connecting(const char *host, unsigned int port)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  r_show_connecting(host, port);
  bank_pop(saved);
}

void at_show_net_error(const char *msg)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  r_show_net_error(msg);
  bank_pop(saved);
}

void at_show_session_end(unsigned char user_quit, unsigned char sock_err, unsigned int rx_total)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  r_show_session_end(user_quit, sock_err, rx_total);
  bank_pop(saved);
}

void at_telnet_display_prep(unsigned char cp866)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  r_telnet_display_prep(cp866);
  bank_pop(saved);
}

signed char at_net_session_connect(const char *host, unsigned int port)
{
  unsigned char saved;
  signed char sock;

  saved = bank_push(residentPg);
  r_show_connecting(host, port);
  if (!net_resolve_host(host))
  {
    r_show_net_error("DNS failed");
    bank_pop(saved);
    return -1;
  }
  sock = net_connect_tcp(port, 5u);
  if (sock < 0)
  {
    r_show_net_error("connect failed");
    bank_pop(saved);
    return -1;
  }
  bank_pop(saved);
  return sock;
}
