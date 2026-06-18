#define OS_CALL_OK(todo) ((todo) <= 32767)
#define OS_CALL_ERR(todo) ((unsigned char)((todo) & 255))
#define OS_CALL_SOCKET(todo) ((signed char)(((todo) >> 8) & 255))

static unsigned char dnsPkt[512];

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

  if (httpRes != NULL)
  {
    httpErr = atol(httpRes + 9);
  }
  else
  {
    writeLog(netbuf, "cutHeader[0]  ");
    httpErr = 0;
  }
  return httpErr;
}

void getErrorText(unsigned int error, char *buf)
{
  error = error & 0xff;
  switch (error)
  {
  case 2:
    strcpy(buf, "02 SHUT_RDWR");
    break;
  case 4:
    strcpy(buf, "04 ERR_INTR");
    break;
  case 23:
    strcpy(buf, "23 ERR_NFILE");
    break;
  case 35:
    strcpy(buf, "35 ERR_EAGAIN");
    break;
  case 37:
    strcpy(buf, "37 ERR_ALREADY");
    break;
  case 38:
    strcpy(buf, "38 ERR_NOTSOCK");
    break;
  case 40:
    strcpy(buf, "40 ERR_EMSGSIZE");
    break;
  case 41:
    strcpy(buf, "41 ERR_PROTOTYPE");
    break;
  case 47:
    strcpy(buf, "47 ERR_AFNOSUPPORT");
    break;
  case 53:
    strcpy(buf, "53 ERR_ECONNABORTED");
    break;
  case 54:
    strcpy(buf, "54 ERR_CONNRESET");
    break;
  case 57:
    strcpy(buf, "57 ERR_NOTCONN");
    break;
  case 65:
    strcpy(buf, "65 ERR_HOSTUNREACH");
    break;
  default:
    sprintf(buf, "%u UNKNOWN ERROR", error);
    break;
  }
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

char netConnect(signed char socket, unsigned char retry)
{
  unsigned int todo = 0;

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
  readStruct.bufsize = sizeof(netbuf);
  readStruct.protocol = SOCK_STREAM;

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

unsigned char dnsResolve(const char *domainName)
{
  unsigned char socket, retry;
  unsigned int todo, queryPos, queryType, domainLng, comaCount, reqSize;
  unsigned int loop;
  unsigned char buf[128];
  unsigned char dnsQuery1[] = {0x11, 0x22, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  unsigned char dnsQuery2[] = {0x00, 0x00, 0x01, 0x00, 0x01};

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
    putchar('\r');
    errorPrint(OS_CALL_ERR(todo));
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
