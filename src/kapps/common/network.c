#define OS_CALL_OK(todo) ((todo) <= 32767)
#define OS_CALL_ERR(todo) ((unsigned char)((todo) & 255))
#define OS_CALL_SOCKET(todo) ((signed char)(((todo) >> 8) & 255))

#ifndef NETBUF_BYTES
#define NETBUF_BYTES sizeof(netbuf)
#endif

#ifndef NET_NO_UDP
/* WIZNET DNS. Packet built in netbuf[0..]; labels at netbuf[256..].
 * #define NET_NO_UDP before include to drop dnsResolve (EspDnsResolve-only apps).
 * Do not gate this on ESPNET_NO_UDP: dual-stack apps still need WIZNET DNS. */
#define DNS_PKT_MAX 512
/* One UDP query + 10*80ms (~0.8s) was too short: 8.8.4.4 often arrives
 * later or the datagram is lost, and a SERVFAIL/empty read looked instant. */
#ifndef DNS_SEND_TRIES
#define DNS_SEND_TRIES 4
#endif
#ifndef DNS_RECV_TRIES
#define DNS_RECV_TRIES 25
#endif
#ifndef DNS_RECV_MS
#define DNS_RECV_MS 100
#endif
static const unsigned char dns_query_hdr[12] =
    {0x11, 0x22, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
static const unsigned char dns_query_tail[5] = {0x00, 0x00, 0x01, 0x00, 0x01};

static unsigned char dns_parse_ipv4(const char *host, unsigned char ip[4])
{
  unsigned int octet;
  unsigned char idx;
  const char *p;

  p = host;
  for (idx = 0; idx < 4; idx++)
  {
    if (*p < '0' || *p > '9')
      return 0;
    octet = 0;
    while (*p >= '0' && *p <= '9')
    {
      octet = octet * 10u + (unsigned int)(*p - '0');
      p++;
    }
    if (octet > 255)
      return 0;
    ip[idx] = (unsigned char)octet;
    if (idx < 3)
    {
      if (*p != '.')
        return 0;
      p++;
    }
  }
  return (*p == 0) ? 1 : 0;
}

static unsigned int dns_build_query(const char *domainName, unsigned int domainLng)
{
  unsigned char *enc;
  unsigned int comaCount;
  unsigned int loop;

  enc = netbuf + 256;
  comaCount = 0;
  loop = domainLng;
  enc[loop + 1] = 0;
  do
  {
    if (domainName[loop - 1] == '.')
    {
      enc[loop] = (unsigned char)comaCount;
      comaCount = 0;
    }
    else
    {
      enc[loop] = domainName[loop - 1];
      comaCount++;
    }
    loop--;
  } while (loop != 0);
  enc[0] = (unsigned char)comaCount;
  memcpy(netbuf, dns_query_hdr, sizeof(dns_query_hdr));
  memcpy(netbuf + sizeof(dns_query_hdr), enc, domainLng + 1);
  memcpy(netbuf + domainLng + sizeof(dns_query_hdr) + 1, dns_query_tail,
         sizeof(dns_query_tail));
  return sizeof(dns_query_hdr) + sizeof(dns_query_tail) + domainLng + 1;
}

/* QR + RCODE + first A (type 1). Compression in answers as before. */
static unsigned char dns_take_a(unsigned int n)
{
  unsigned int queryPos;
  unsigned int queryType;
  unsigned int queryLng;

  if (n < 12)
    return 0;
  if ((netbuf[2] & 0x80) == 0 || (netbuf[3] & 0x0f) != 0)
    return 0;
  queryPos = 11;
  do
  {
    queryPos++;
    if (queryPos >= n)
      return 0;
  } while (netbuf[queryPos] != 0);
  queryPos = queryPos + 7;
  do
  {
    if (queryPos > n - 12 || queryPos > DNS_PKT_MAX - 11)
      return 0;
    queryType = (unsigned int)netbuf[queryPos] * 256u + netbuf[queryPos + 1];
    queryPos = queryPos + 8;
    if (queryPos + 1 >= n)
      return 0;
    queryLng = (unsigned int)netbuf[queryPos] * 256u + netbuf[queryPos + 1];
    queryPos = queryPos + queryLng + 4;
  } while (queryType != 1);
  if (queryPos < 6 || queryPos - 3 >= n)
    return 0;
  targetadr.b1 = netbuf[queryPos - 6];
  targetadr.b2 = netbuf[queryPos - 5];
  targetadr.b3 = netbuf[queryPos - 4];
  targetadr.b4 = netbuf[queryPos - 3];
  return 1;
}
#endif

void delayLong(unsigned long counter)
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

int httpError(void)
{
  const char *httpRes;
  unsigned int httpErr;
  httpRes = strstr(netbuf, "HTTP/1.1 ");
  if (httpRes == NULL)
    httpRes = strstr(netbuf, "HTTP/1.0 ");

  if (httpRes != NULL)
  {
    httpErr = atol(httpRes + 9);
  }
  else
  {
    httpErr = 0;
  }
  return httpErr;
}

void errorPrint(unsigned int error)
{
  switch (error)
  {
  case 2:
    printf("02 SHUT_RDWR");
    break;
  case 4:
    printf("04 ERR_INTR");
    break;
  case 23:
    printf("23 ERR_NFILE");
    break;
  case 35:
    printf("35 ERR_EAGAIN");
    break;
  case 37:
    printf("37 ERR_ALREADY");
    break;
  case 38:
    printf("38 ERR_NOTSOCK");
    break;
  case 40:
    printf("40 ERR_EMSGSIZE");
    break;
  case 41:
    printf("41 ERR_PROTOTYPE");
    break;
  case 47:
    printf("47 ERR_AFNOSUPPORT");
    break;
  case 53:
    printf("53 ERR_ECONNABORTED");
    break;
  case 54:
    printf("54 ERR_CONNRESET");
    break;
  case 57:
    printf("57 ERR_NOTCONN");
    break;
  case 65:
    printf("65 ERR_HOSTUNREACH");
    break;
  default:
    printf("%u UNKNOWN ERROR", error);
    break;
  }
}

void testOperation(const char *process, int socket)
{
  if (socket < 0)
  {
    printf("%s: [ERROR:", process);
    errorPrint(-socket);
    printf("]\r\n");
    YIELD();
    exit(0);
  }
}

char OpenSock(unsigned char family, unsigned char protocol)
{
  unsigned int todo;
  unsigned char retry;

  retry = 50;
  for (;;)
  {
    todo = OS_NETSOCKET((family << 8) + protocol);
    if (OS_CALL_OK(todo))
      return OS_CALL_SOCKET(todo);
    if (OS_CALL_ERR(todo) != ERR_EAGAIN || retry == 0)
      return 0 - OS_CALL_ERR(todo);
    retry--;
    YIELD();
  }
}

char netShutDown(signed char socket, unsigned char type)
{
  unsigned int todo;
  todo = OS_NETSHUTDOWN(socket, type);
  if (OS_CALL_OK(todo))
  {
    // printf("Socket #%d closed.\n\r", socket);
    return socket;
  }
  return 0 - OS_CALL_ERR(todo);
}

char netConnect(signed char socket, unsigned char retry)
{
  unsigned int todo = 0;
  while (retry != 0)
  {
    retry--;
    todo = OS_NETCONNECT(socket, &targetadr);
    if (OS_CALL_OK(todo))
    {
      return socket;
    }
    delayLong(150);
    netShutDown(socket, 0);
    socket = OpenSock(AF_INET, SOCK_STREAM);
    testOperation("OS_NETSOCKET", socket);
  }

  netShutDown(socket, 0);
  return 0 - OS_CALL_ERR(todo);
}

int tcpSend(signed char socket, unsigned int messageadr, unsigned int size, unsigned char retry)
{
  unsigned int todo = 0;

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

int tcpRead(signed char socket, unsigned char retry)
{
  unsigned int todo = 0;
  char key;

  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = NETBUF_BYTES;
  readStruct.protocol = SOCK_STREAM;

  /* retry==0: single non-blocking poll (IRC / UI main loops). */
  if (retry == 0)
  {
    todo = OS_WIZNETREAD(&readStruct);
    if (OS_CALL_OK(todo))
      return (int)todo;
    if (OS_CALL_ERR(todo) == ERR_EAGAIN)
      return 0;
    return 0 - (int)OS_CALL_ERR(todo);
  }

  while (retry != 0)
  {
    todo = OS_WIZNETREAD(&readStruct);

    if (OS_CALL_OK(todo))
    {
      return todo;
    }

    if (OS_CALL_ERR(todo) != ERR_EAGAIN)
    {
      retry--;
      if (retry != 0)
      {
        delayLong(100);
      }
    }
    else
    {
      YIELD();
      key = _low_level_get();
      if (key == 27)
      {
        break;
      }
    }
  }
  return 0 - OS_CALL_ERR(todo);
}

/* Accumulate into netbuf until HTTP header ends with \r\n\r\n.
 * Kernel ESPNET READ is 192 bytes; zxart headers are often ~340. */
int tcpReadHeader(signed char socket, unsigned char retry)
{
  unsigned int got;
  unsigned int todo;
  unsigned int room;
  unsigned char tries;
  char key;

  got = 0;
  netbuf[0] = 0;
  tries = retry;
  if (tries == 0)
    tries = 1;
  for (;;)
  {
    if (strstr((char *)netbuf, "\r\n\r\n") != 0)
      return (int)got;
    room = NETBUF_BYTES - 1 - got;
    if (room == 0)
      return 0 - (int)ERR_EMSGSIZE;
    readStruct.socket = socket;
    readStruct.BufAdr = (unsigned int)(netbuf + got);
    readStruct.bufsize = room;
    readStruct.protocol = SOCK_STREAM;
    todo = OS_WIZNETREAD(&readStruct);
    if (OS_CALL_OK(todo))
    {
      got += todo;
      netbuf[got] = 0;
      tries = retry;
      if (tries == 0)
        tries = 1;
      continue;
    }
    if (OS_CALL_ERR(todo) == ERR_EAGAIN)
    {
      YIELD();
      key = _low_level_get();
      if (key == 27)
        return 0 - (int)ERR_INTR;
      continue;
    }
    tries--;
    if (tries == 0)
      return 0 - (int)OS_CALL_ERR(todo);
    delayLong(100);
  }
}

#ifndef NET_NO_UDP
unsigned char dnsResolve(const char *domainName)
{
  int socket;
  unsigned char retry;
  unsigned char send_try;
  unsigned char recv_try;
  unsigned int todo;
  unsigned int domainLng;
  unsigned int reqSize;
  unsigned char ip4[4];
  struct sockaddr_in from;
  char key;

  domainLng = strlen(domainName);
  if (domainLng == 0 || domainLng > 126)
    return 0;
  if (dns_parse_ipv4(domainName, ip4))
  {
    targetadr.b1 = ip4[0];
    targetadr.b2 = ip4[1];
    targetadr.b3 = ip4[2];
    targetadr.b4 = ip4[3];
    return 1;
  }

  socket = OpenSock(AF_INET, SOCK_DGRAM);
  if (socket < 0)
    return 0;

  for (send_try = 0; send_try < DNS_SEND_TRIES; send_try++)
  {
    reqSize = dns_build_query(domainName, domainLng);
    readStruct.socket = socket;
    readStruct.BufAdr = (unsigned int)netbuf;
    readStruct.bufsize = reqSize;
    readStruct.protocol = SOCK_DGRAM;
    retry = 50;
    for (;;)
    {
      todo = OS_WIZNETWRITE_UDP(&readStruct, &dnsaddress);
      if (OS_CALL_OK(todo))
        break;
      /* 35 = UART/lwIP busy. 40 = old firmware used EMSGSIZE for UDP send fail. */
      if ((OS_CALL_ERR(todo) != ERR_EAGAIN && OS_CALL_ERR(todo) != ERR_EMSGSIZE) ||
          retry == 0)
      {
        putchar('\r');
        errorPrint(OS_CALL_ERR(todo));
        netShutDown(socket, 0);
        return 0;
      }
      retry--;
      YIELD();
    }

    readStruct.BufAdr = (unsigned int)netbuf;
    readStruct.bufsize = DNS_PKT_MAX;
    for (recv_try = 0; recv_try < DNS_RECV_TRIES; recv_try++)
    {
      /* from, not dnsaddress: READ fills sender and must not clobber the NS. */
      todo = OS_WIZNETREAD_UDP(&readStruct, &from);
      if (OS_CALL_OK(todo) && todo >= 12)
      {
        if (dns_take_a(todo))
        {
          netShutDown(socket, 0);
          return 1;
        }
        /* SERVFAIL/REFUSED/truncated: resend, do not treat as a final miss. */
        delayLong(200);
        break;
      }
      key = _low_level_get();
      if (key == 27)
      {
        netShutDown(socket, 0);
        return 0;
      }
      delayLong(DNS_RECV_MS);
    }
  }

  netShutDown(socket, 0);
  return 0;
}
#endif

void get_dns(void)
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
