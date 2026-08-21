#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include <stdlib.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet_plug.h"
#include "netglue.h"

static unsigned char dnsPkt[512];

static void delayLong(unsigned long counter)
{
  unsigned long finish;

  counter = counter / 20;
  if (counter < 1)
  {
    counter = 1;
  }
  finish = time() + counter;
  while (time() < finish)
  {
    YIELD();
  }
}

static char OpenSock(unsigned char family, unsigned char protocol)
{
  unsigned int todo;

  todo = OS_NETSOCKET((family << 8) + protocol);
  if (!OS_CALL_OK(todo))
  {
    return 0 - OS_CALL_ERR(todo);
  }
  return OS_CALL_SOCKET(todo);
}

char netShutDown(signed char socket, unsigned char type)
{
  unsigned int todo;
  unsigned char err;

  if (socket < 0)
  {
    return socket;
  }

  for (;;)
  {
    todo = OS_NETSHUTDOWN(socket, type);
    if (OS_CALL_OK(todo))
    {
      return socket;
    }

    err = OS_CALL_ERR(todo);
    if (type == 1 && err == ERR_EAGAIN)
    {
      YIELD();
      continue;
    }
    return 0 - err;
  }
}

static char netConnect(signed char socket, unsigned char retry)
{
  unsigned int todo;

  todo = 0;
  while (retry != 0)
  {
    todo = OS_NETCONNECT(socket, &targetadr);
    if (OS_CALL_OK(todo))
    {
      return socket;
    }

    retry--;
    if (retry == 0)
    {
      break;
    }

    delayLong(150);
    netShutDown(socket, 0);
    socket = OpenSock(AF_INET, SOCK_STREAM);
    if (socket < 0)
    {
      return socket;
    }
  }

  netShutDown(socket, 0);
  return 0 - OS_CALL_ERR(todo);
}

int tcpSend(signed char socket, unsigned int messageadr, unsigned int size, unsigned char retry)
{
  unsigned int todo;

  todo = 0;
  readStruct.socket = socket;
  readStruct.BufAdr = messageadr;
  readStruct.bufsize = size;
  readStruct.protocol = SOCK_STREAM;
  while (retry != 0)
  {
    todo = OS_WIZNETWRITE(&readStruct);
    if (OS_CALL_OK(todo))
    {
      return todo;
    }

    retry--;
    if (retry != 0)
    {
      delayLong(100);
    }
  }
  return 0 - OS_CALL_ERR(todo);
}

static unsigned char dnsResolve(const char *domainName)
{
  int socket;
  unsigned char retry;
  unsigned int todo, queryPos, queryType, domainLng, comaCount, reqSize;
  unsigned int loop;
  unsigned char buf[128];
  static unsigned char dnsQuery1[] = {0x11, 0x22, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  static unsigned char dnsQuery2[] = {0x00, 0x00, 0x01, 0x00, 0x01};

  domainLng = strlen(domainName);
  if (domainLng == 0 || domainLng > 126)
  {
    return 0;
  }

  comaCount = 0;
  loop = domainLng;
  buf[loop + 1] = 0;

  do
  {
    if (domainName[loop - 1] == '.')
    {
      buf[loop] = comaCount;
      comaCount = 0;
    }
    else
    {
      buf[loop] = domainName[loop - 1];
      comaCount++;
    }
    loop--;
  } while (loop != 0);
  buf[0] = comaCount;

  memcpy(dnsPkt, dnsQuery1, sizeof(dnsQuery1));
  memcpy(dnsPkt + sizeof(dnsQuery1), buf, domainLng + 1);
  memcpy(dnsPkt + domainLng + sizeof(dnsQuery1) + 1, dnsQuery2, sizeof(dnsQuery2));
  reqSize = sizeof(dnsQuery1) + sizeof(dnsQuery2) + domainLng + 1;

  socket = OpenSock(AF_INET, SOCK_DGRAM);
  if (socket < 0)
  {
    return 0;
  }

  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&dnsPkt;
  readStruct.bufsize = (unsigned int)reqSize;
  readStruct.protocol = SOCK_DGRAM;

  todo = OS_WIZNETWRITE_UDP(&readStruct, &dnsaddress);
  if (!OS_CALL_OK(todo))
  {
    netShutDown(socket, 0);
    return 0;
  }

  readStruct.BufAdr = (unsigned int)&dnsPkt;
  readStruct.bufsize = (unsigned int)sizeof(dnsPkt);
  retry = 10;
  do
  {
    todo = OS_WIZNETREAD_UDP(&readStruct, &dnsaddress);
    if (!OS_CALL_OK(todo))
    {
      if (retry == 0)
      {
        netShutDown(socket, 0);
        return 0;
      }
      retry--;
      delayLong(80);
    }
  } while (!OS_CALL_OK(todo));

  netShutDown(socket, 0);

  if ((dnsPkt[2] & 0x80) == 0 || (dnsPkt[3] & 0x0f) != 0)
  {
    return 0;
  }

  queryPos = 11;
  do
  {
    queryPos++;
  } while (dnsPkt[queryPos] != 0);

  queryPos = queryPos + 7;
  do
  {
    unsigned int queryLng;
    if (queryPos > sizeof(dnsPkt) - 11)
    {
      return 0;
    }
    queryType = dnsPkt[queryPos] * 256 + dnsPkt[queryPos + 1];

    queryPos = queryPos + 8;

    queryLng = dnsPkt[queryPos] * 256 + dnsPkt[queryPos + 1];
    queryPos = queryPos + queryLng + 4;
  } while (queryType != 1);

  targetadr.b1 = dnsPkt[queryPos - 6];
  targetadr.b2 = dnsPkt[queryPos - 5];
  targetadr.b3 = dnsPkt[queryPos - 4];
  targetadr.b4 = dnsPkt[queryPos - 3];

  return 1;
}

static void get_dns(void)
{
  unsigned char ipaddress[4];
  OS_GETDNS(ipaddress);
  dnsaddress.family = AF_INET;
  dnsaddress.porth = 00;
  dnsaddress.portl = 53;
  dnsaddress.b1 = ipaddress[0];
  dnsaddress.b2 = ipaddress[1];
  dnsaddress.b3 = ipaddress[2];
  dnsaddress.b4 = ipaddress[3];
}

static unsigned char read_netdriver(void)
{
  FILE *fp;
  unsigned int n;
  unsigned char drv;
  char *p;
  static unsigned char saved[80];

  drv = 0u;
  at_path_to_ini(saved);
  fp = OS_OPENHANDLE((unsigned char *)"network.ini", 0x80u);
  if ((((int)fp) & 0xff) == 0)
  {
    n = OS_READHANDLE(netbuf, fp, (unsigned int)(sizeof(netbuf) - 1u));
    OS_CLOSEHANDLE(fp);
    if (n >= sizeof(netbuf))
    {
      n = (unsigned int)(sizeof(netbuf) - 1u);
    }
    netbuf[n] = 0;
    p = strstr((char *)netbuf, "currentNetwork");
    if (p != 0)
    {
      while (*p != 0 && *p != '=' && *p != '\r' && *p != '\n')
      {
        p++;
      }
      if (*p == '=')
      {
        p++;
        while (*p == ' ' || *p == '\t')
        {
          p++;
        }
        drv = (unsigned char)atoi(p);
      }
    }
  }
  OS_CHDIR(saved);
  return drv;
}

unsigned char net_init(void)
{
  unsigned char drv;

  drv = read_netdriver();
  if (drv == 1u || drv == 2u)
  {
    return drv;
  }

  get_dns();
  targetadr.family = AF_INET;
  targetadr.porth = 0u;
  targetadr.portl = 0u;
  targetadr.b1 = 0u;
  targetadr.b2 = 0u;
  targetadr.b3 = 0u;
  targetadr.b4 = 0u;
  return 0u;
}

static int net_parse_ipv4(const char *host, unsigned char *out4)
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
