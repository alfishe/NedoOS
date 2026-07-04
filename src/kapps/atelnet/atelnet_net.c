#include "app_bank.h"
#include "atelnet_plug.h"
#include "netglue.h"

void at_net_init(void)
{
  unsigned char saved;

  saved = bank_push(residentPg);
  net_init();
  bank_pop(saved);
}

int at_net_resolve_host(const char *host)
{
  unsigned char saved;
  int rc;

  saved = bank_push(residentPg);
  rc = net_resolve_host(host);
  bank_pop(saved);
  return rc;
}

signed char at_net_connect_tcp(unsigned int port, unsigned char retry)
{
  unsigned char saved;
  signed char rc;

  saved = bank_push(residentPg);
  rc = net_connect_tcp(port, retry);
  bank_pop(saved);
  return rc;
}

int at_telnet_tcp_read(signed char socket)
{
  unsigned char saved;
  int rc;

  saved = bank_push(residentPg);
  rc = telnet_tcp_read(socket);
  bank_pop(saved);
  return rc;
}

int at_tcpSend(signed char socket, unsigned int messageadr, unsigned int size, unsigned char retry)
{
  unsigned char saved;
  int rc;

  saved = bank_push(residentPg);
  rc = tcpSend(socket, messageadr, size, retry);
  bank_pop(saved);
  return rc;
}

char at_netShutDown(signed char socket, unsigned char type)
{
  unsigned char saved;
  char rc;

  saved = bank_push(residentPg);
  rc = netShutDown(socket, type);
  bank_pop(saved);
  return rc;
}
