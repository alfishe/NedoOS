#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <oscalls.h>
#include "netglue.h"

unsigned char netbuf[ATELNET_NETBUF_SIZE];
struct sockaddr_in targetadr;
struct sockaddr_in dnsaddress;
struct readstructure readStruct;


#include "../common/network.c"

void net_init(void)
{
  get_dns();
  targetadr.family = AF_INET;
  targetadr.porth = 0u;
  targetadr.portl = 0u;
  targetadr.b1 = 0u;
  targetadr.b2 = 0u;
  targetadr.b3 = 0u;
  targetadr.b4 = 0u;
}

int net_parse_ipv4(const char *host, unsigned char *out4)
{
  unsigned int octet;
  unsigned char idx;
  const char *p;

  p = host;
  for (idx = 0u; idx < 4u; idx++)
  {
    if (*p < '0' || *p > '9')
    {
      return 0;
    }
    octet = 0u;
    while (*p >= '0' && *p <= '9')
    {
      octet = octet * 10u + (unsigned int)(*p - '0');
      p++;
    }
    if (octet > 255u)
    {
      return 0;
    }
    out4[idx] = (unsigned char)octet;
    if (idx < 3u)
    {
      if (*p != '.')
      {
        return 0;
      }
      p++;
    }
  }
  if (*p != 0)
  {
    return 0;
  }
  return 1;
}

int net_resolve_host(const char *host)
{
  unsigned char ip4[4];

  if (net_parse_ipv4(host, ip4))
  {
    targetadr.b1 = ip4[0];
    targetadr.b2 = ip4[1];
    targetadr.b3 = ip4[2];
    targetadr.b4 = ip4[3];
    return 1;
  }
  return dnsResolve(host) != 0u;
}

signed char net_connect_tcp(unsigned int port, unsigned char retry)
{
  signed char socket;

  targetadr.porth = (unsigned char)((port >> 8) & 0xFFu);
  targetadr.portl = (unsigned char)(port & 0xFFu);

  socket = OpenSock(AF_INET, SOCK_STREAM);
  if (socket < 0)
  {
    return socket;
  }
  return netConnect(socket, retry);
}

/* Non-blocking read for telnet: never steals ESC (tcpRead aborts on ESC). */
int telnet_tcp_read(signed char socket)
{
  unsigned int todo;

  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = sizeof(netbuf);
  readStruct.protocol = SOCK_STREAM;
  todo = OS_WIZNETREAD(&readStruct);
  if (OS_CALL_OK(todo))
  {
    return (int)todo;
  }
  if (OS_CALL_ERR(todo) == ERR_EAGAIN)
  {
    return 0;
  }
  return -(int)OS_CALL_ERR(todo);
}
