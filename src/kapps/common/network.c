void delayLong(unsigned long counter)
{
  unsigned long start, finish;
  counter = counter / 20;
  if (counter < 1)
  {
    counter = 1;
  }
  start = time();
  finish = start + counter;

  while (start < finish)
  {
    start = time();
    YIELD();
  }
}
int httpError(void)
{
  const char *httpRes;
  unsigned int httpErr;
  httpRes = strstr(netbuf, "HTTP/1.1 ");

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
  signed char socket;
  unsigned int todo;
  todo = OS_NETSOCKET((family << 8) + protocol);
  if (todo > 32767)
  {
    return 0 - (todo & 255);
  }
  else
  {
    socket = ((todo & 65280) >> 8);
    // printf("OS_NETSOCKET: Socket #%d created\n\r", socket);
  }
  return socket;
}

char netShutDown(signed char socket, unsigned char type)
{
  unsigned int todo;
  todo = OS_NETSHUTDOWN(socket, type);
  if (todo > 32767)
  {
    return 0 - (todo & 255);
  }
  else
  {
    // printf("Socket #%d closed.\n\r", socket);
  }
  return socket;
}

char netConnect(signed char socket, unsigned char retry)
{
  unsigned int todo = 0;

  while (retry != 0)
  {
    todo = OS_NETCONNECT(socket, &targetadr);

    if (todo > 32767)
    {
      retry--;
      delayLong(500);
      netShutDown(socket, 0);
      socket = OpenSock(AF_INET, SOCK_STREAM);
      testOperation("OS_NETSOCKET", socket);
    }
    else
    {
      // printf("OS_NETCONNECT: connection successful, %u\n\r", (todo & 255));
      return socket;
    }
  }
  return 0 - (todo & 255);
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
    if (todo > 32767)
    {
      retry--;
      delayLong(500);
    }
    else
    {
      // printf("OS_WIZNETWRITE: %u bytes written. \n\r", todo);
      return todo;
    }
  }
  return 0 - (todo & 255);
}

int tcpRead(signed char socket, unsigned char retry)
{
  unsigned int todo = 0;

  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = sizeof(netbuf);
  readStruct.protocol = SOCK_STREAM;

  while (retry != 0)
  {
    todo = OS_WIZNETREAD(&readStruct);

    if (todo > 32767)
    {
      if ((todo & 255) != ERR_EAGAIN) // nodata
      {
        retry--;
        delayLong(500);
      }
    }
    else
    {
      // printf("OS_WIZNETREAD: %u bytes read. \n\r", todo);
      return todo; // succes
    }
  }
  return 0 - (todo & 255); // timeout
}

unsigned char dnsResolve(const char *domainName)
{
  unsigned char socket, retry;
  unsigned int todo, queryPos, queryType, domainLng, comaCount, reqSize;
  unsigned int loop;
  unsigned char buf[128];
  unsigned char dnsQuery1[] = {0x11, 0x22, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  unsigned char dnsQuery2[] = {0x00, 0x00, 0x01, 0x00, 0x01};

  domainLng = strlen(domainName);
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

  memcpy(netbuf, dnsQuery1, sizeof(dnsQuery1));
  memcpy(netbuf + sizeof(dnsQuery1), buf, domainLng + 1);
  memcpy(netbuf + domainLng + sizeof(dnsQuery1) + 1, dnsQuery2, sizeof(dnsQuery2));
  reqSize = sizeof(dnsQuery1) + sizeof(dnsQuery2) + domainLng + 1;

  socket = OpenSock(AF_INET, SOCK_DGRAM);
  readStruct.socket = socket;
  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = (unsigned int)reqSize;
  readStruct.protocol = SOCK_DGRAM;

  todo = OS_WIZNETWRITE_UDP(&readStruct, &dnsaddress);
  if (todo > 32767)
  {
    errorPrint(todo & 255);
    return 0;
  }
  else
  {
    // printf("OS_WIZNETWRITE_UDP: %u bytes written. \n\r", todo);
  }

  readStruct.BufAdr = (unsigned int)&netbuf;
  readStruct.bufsize = (unsigned int)sizeof(netbuf);
  retry = 10;
  do
  {
    todo = OS_WIZNETREAD_UDP(&readStruct, &dnsaddress);
    if (todo > 32767)
    {
      // errorPrint(todo & 255);
      if (retry == 0)
      {
        // clearStatus();
        // printf(" Error quering[Response] DNS server.");
        netShutDown(socket, 0);
        return 0;
      }
      retry--;
      delayLong(200);
      // printf(" Retry [%d]\r\n", retryInv - retry);
    }
  } while (todo > 32767);

  netShutDown(socket, 0);

  if (!(netbuf[2] && 0x0f))
  {
    // clearStatus();
    // printf(" Error quering[Parsing] DNS server.");
    return 0;
  }

  queryPos = 11;
  do
  {
    queryPos++;
  } while (netbuf[queryPos] != 0);

  queryPos = queryPos + 7; // Skip to answer data
  do
  {
    unsigned int queryLng;
    if (queryPos > sizeof(netbuf) - 11)
    {
      // clearStatus();
      // printf(" Error quering DNS server[Buffer overrun]. ");
      return 0;
    }
    queryType = netbuf[queryPos] * 256 + netbuf[queryPos + 1];
    // printf("Query type (0x0001): %d\r\n", queryType);

    queryPos = queryPos + 8; // Skip to answer lenght

    queryLng = netbuf[queryPos] * 256 + netbuf[queryPos + 1];
    // printf("Query data lenght: %d\r\n", queryLng);
    queryPos = queryPos + queryLng + 4;
  } while (queryType != 1);

  targetadr.b1 = netbuf[queryPos - 6];
  targetadr.b2 = netbuf[queryPos - 5];
  targetadr.b3 = netbuf[queryPos - 4];
  targetadr.b4 = netbuf[queryPos - 3];

  // printf("\r\nAddress:%u.%u.%u.%u:%u\r\n", targetadr.b1, targetadr.b2, targetadr.b3, targetadr.b4, targetadr.porth * 256 + targetadr.portl);
  return 1;
}

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