#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <ctype.h>
#include <tcp.h>
unsigned char netbuf[8192];
unsigned char picture[7000];
unsigned char piclist[3072];
unsigned char crlf[2] = {13, 10};
unsigned int bytecount;
unsigned char status, key;
struct sockaddr_in   targetadr;
struct readstructure   readStruct;

void putdec(int c)
{
  int div;
  int hassent = 0;
  for (div = 100; div > 0; div /= 10) {
    int disp = c / div;
    c %= div;
    if ((disp != 0) || (hassent) || (div == 1)) {
      hassent = 1;
      putchar('0' + disp);
    }
  }
}

void errorPrint(unsigned int error)
{
  switch (error)
  {
    case 2:
      printf ("02 SHUT_RDWR\n\r");
      break;
    case 4:
      printf ("04 ERR_INTR\n\r");
      break;
    case 23:
      printf ("23 ERR_NFILE\n\r");
      break;
    case 35:
      printf ("35 ERR_EAGAIN or ERR_EWOULDBLOCK\n\r");
      break;
    case 37:
      printf ("37 ERR_ALREADY\n\r");
      break;
    case 38:
      printf ("38 ERR_NOTSOCK\n\r");
      break;
    case 40:
      printf ("40 ERR_EMSGSIZE\n\r");
      break;
    case 41:
      printf ("41 ERR_PROTOTYPE\n\r");
      break;
    case 47:
      printf ("47 ERR_AFNOSUPPORT\n\r");
      break;
    case 53:
      printf ("53 ERR_ECONNABORTED\n\r");
      break;
    case 54:
      printf ("54 ERR_CONNRESET\n\r");
      break;
    case 57:
      printf ("57 ERR_NOTCONN\n\r");
      break;
    case 65:
      printf ("65 ERR_HOSTUNREACH\n\r");
      break;
    default:
      printf ("%u UNKNOWN ERROR\n\r", error);
      break;
  }
  YIELD();
  //    do {key = _low_level_get();} while (key == 0);
}

unsigned char OpenSock(unsigned char family, unsigned char protocol)
{
  unsigned char socket, retry = 100;
  unsigned int todo;
  todo = OS_NETSOCKET ((family << 8) + protocol);
  if (todo > 32767) {
    printf("OS_NETSOCKET: ");
    errorPrint(todo & 255);
    exit(0);

  }
  else {
    socket = ( (todo & 65280) >> 8);
    //printf ("OS_NETSOCKET: Socket #%d created\n\r", socket);
  }
  return socket;
}

unsigned char netConnect (unsigned char socket)
{
  unsigned int todo;

  targetadr.family  = AF_INET;
  targetadr.porth   = 00;
  targetadr.portl   = 80;
  targetadr.b1      = 217;
  targetadr.b2      = 146;
  targetadr.b3      = 69;
  targetadr.b4      = 13;

  todo = OS_NETCONNECT (socket, &targetadr);
  if (todo > 32767)
  {
    printf("OS_NETCONNECT: ");
    errorPrint(todo & 255);
    exit(0);
  } else {
    //printf("OS_NETCONNECT: connection successful, %u\n\r", (todo & 255));
  }
  return 0;
}  


unsigned int tcpSend (unsigned char socket, unsigned int messageadr, unsigned int size)
{
  unsigned char retry = 100;
  unsigned int todo;
  readStruct.socket  = socket;
  readStruct.BufAdr  = messageadr;
  readStruct.bufsize = size;
  readStruct.protocol = SOCK_STREAM;



wizwrite:
  todo = OS_WIZNETWRITE (&readStruct);
  if (todo > 32767)
  {
    printf("OS_WIZNETWRITE: ");
    errorPrint(todo & 255);
    if (retry == 0) {
      exit(0);
    }
    retry--;
    goto wizwrite;
  }
  else
  {
    //printf("OS_WIZNETWRITE: %u bytes written. \n\r", todo);
  }
  return todo;
}

unsigned int tcpRead (unsigned char socket)
{
  unsigned char retry = 80;
  unsigned int err, todo;

  readStruct.socket  = socket;
  readStruct.BufAdr  = (unsigned int)&netbuf;
  readStruct.bufsize = sizeof (netbuf);
  readStruct.protocol = SOCK_STREAM;

wizread:
  todo = OS_WIZNETREAD (&readStruct);
  err = todo & 255;
  if (todo > 32767)
  {
	YIELD();
	retry--;
    if (retry == 0) 
	{
	if (err == ERR_EAGAIN) {todo = 0; return todo;}
    printf("OS_WIZNETREAD: ");
    errorPrint(err);
	exit(0);
    }
    goto wizread;
  }
  printf("OS_WIZNETREAD: %u bytes read. \n\r", todo);
 return todo;
}

unsigned int cutHeader(unsigned int todo)
{
  unsigned int q, headlng;
  unsigned char *count;

  count = strstr (netbuf, "\r\n\r\n");
  if ( count == NULL)
  {
    printf ("header not found\r\n");
  }
  else
  {
    headlng = ((unsigned int)count - (unsigned int)netbuf + 4);
    q = todo - headlng;
    memcpy (&netbuf, count + 4, q);
    //printf ("header removed. %u bytes\r\n", headlng);
  }
  return q;
}

unsigned int netShutDown(unsigned char socket)
{
  unsigned int todo;
  todo = OS_NETSHUTDOWN (socket);
  if (todo > 32767) {
    printf("OS_NETSHUTDOWN: ");
    errorPrint(todo & 255);
    return 255;
  }  else {
    //printf ("Socket #%u closed.\n\r", socket);
  }
  return 0;
}

void fillPicture(unsigned char socket)
{
  unsigned int todo, w, pPos, q, headskip;
  
	  headskip = 0;
  pPos = 0;
   while (1)
   {
  	todo =  tcpRead (socket);
	if (todo == 0) {break;}
    q = todo;
    if (headskip == 0)
    {
      headskip = 1;
      q = cutHeader(todo);
    }
    for (w = 0; w < q; w++)
    {
      picture [w + pPos]  = netbuf[w];
    }
    pPos = pPos + q;
  }
    netShutDown(socket);
}



unsigned char getPic(unsigned long fileId)
{
  unsigned int todo;
  unsigned char cmdlist1[] = "GET \/file\/id:";
  unsigned char cmdlist2[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0";
  unsigned char buffer  [] = "0000000000";
  unsigned char socket;
  socket = OpenSock(AF_INET, SOCK_STREAM);
    todo = netConnect (socket);
		netbuf[0] = '\0';
		sprintf(buffer, "%lu", fileId);
		strcat (netbuf, cmdlist1);
		strcat (netbuf, buffer);
		strcat (netbuf, cmdlist2);
  todo = tcpSend (socket, (unsigned int)&netbuf, strlen(netbuf));
  fillPicture(socket);
  return 0;
}
unsigned char savePic(unsigned long fileId)
{
  FILE *fp2;
  unsigned char fileName[32]; 
  unsigned char buffer  [] = "0000000000";
  strcpy(fileName, "zxart_");
  sprintf(buffer, "%lu", fileId);
  strcat (fileName, buffer);
  strcat (fileName, ".scr");

 fp2 = OS_CREATEHANDLE(fileName, 0x80);
  if (((int)fp2) & 0xff)
  {
    printf (fileName);
    printf(" creating error\r\n");
    exit(0);
  }
  OS_WRITEHANDLE(picture, fp2, 6912);
  OS_CLOSEHANDLE(fp2);
  return 0;
}

const char* parseJson(unsigned char *property)
{
  unsigned char *count, lng, *start, test;
  int q;
  netbuf[0] = '\0';
  lng = strlen(property);
  count = strstr (picture, property);
  if ( count == NULL)
  {
    printf ("not found\r\n");
	exit(0);
    return "*not found*";
  }
  start = count + lng;
  test  = *start;
  q = -1;
while (((unsigned char)test !='\"') && ((unsigned char)test !=',') && ((unsigned char)test !=']'))
// Нужно более универальное  решениен чтоб запятые в текте не мешались
  {
  q++;
  test  = *start;
  start++;
  }
strncat(netbuf, count + lng, q);  
return netbuf;  
}

void convert866(void)
{
  unsigned int lng, targetPos, w, q = 0;
  unsigned char buffer[8], one, two;
  unsigned int decVal;
  lng = strlen(netbuf);	
  targetPos = lng + 1;

 while (q < lng)
  {
	one = netbuf [q];
	two = netbuf [q + 1];
	if ( one == 92 && two == 117) 
	{
	q = q + 2;
	for (w = 0; w < 4; w++)  {buffer [w] = netbuf [q + w];}
	q = q + 4;
	buffer[4] = '\0';
	decVal= (unsigned int)strtol(buffer, NULL, 16);
													//printf("hex %s\n\r",buffer);
													//printf("dec %u\n\r",decVal);
	
	
	  if (decVal < 1088) {decVal = decVal - 912;}
	  if (decVal > 1087) {decVal = decVal - 864;}
	  if (decVal == 1025) {decVal = 240;}
	  if (decVal == 1105) {decVal = 241;}
	  netbuf [targetPos] = decVal;
	}
		else {netbuf [targetPos] = netbuf [q]; q++;}
	targetPos++;
	}
	netbuf [targetPos] = '\0';

  for (w = lng + 1; w < targetPos + 1; w++)
  {
  netbuf [w - lng -1] = netbuf [w];
   }
}	





unsigned long processJson(unsigned long startPos)
{
  unsigned int todo, pPos, headskip;
  unsigned char cmdlist1[] = "GET /api/export:zxPicture\/filter:zxPicture\/limit:1\/start:";
  unsigned char cmdlist2[] = "\/order:date,desc HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0";
  unsigned char buffer  [] = "000000000";
  unsigned char *count, socket;
  const char *titleptr;
  unsigned long idpic, bytecount;

 
  socket = OpenSock(AF_INET, SOCK_STREAM);
  netConnect (socket);
    
	  netbuf[0] = '\0';
      strcat (netbuf, cmdlist1);
	  sprintf(buffer, "%lu", startPos);
	  strcat (netbuf, buffer);
	  strcat (netbuf, cmdlist2);
 	     
	  todo = tcpSend (socket, (unsigned int)&netbuf, strlen(netbuf));
	  

	  
  headskip = 0;
  pPos = 0;
  fillPicture(socket);
  netShutDown(socket);
  count = strstr (picture, "responseStatus\":\"success");
  if ( count == NULL)
  {
    printf ("BAD JSON no(responseStatus"":""success)\r\n");

	exit(0);
  }
  
  count = strstr (picture, "\"id\":");
  if ( count == NULL)
  {
    printf ("BAD JSON: ID not found \r\n");
	exit(0);
  }

 
	
  netbuf[0] = '\0';
  strcat (piclist, parseJson("\"id\":"));
  idpic = atol (netbuf);
  strcat (piclist, "\n\r");
  
  parseJson(",\"title\":\"");
  convert866(); 
 printf("Title: ");
 printf(netbuf);
 printf("\n\r");
 
 strcat (piclist, netbuf) ;
  strcat (piclist, "\n\r");
  strcat (piclist, parseJson ("\"dateCreated\":"));
  strcat (piclist, "\n\r");
  strcat (piclist, parseJson("\"authorIds\":["));
  strcat (piclist, "\n\r");
  strcat (piclist, parseJson("\"rating\":\""));
  strcat (piclist, "\n\r");
  strcat (piclist, parseJson("\"views\":\""));
  strcat (piclist, "\n\r");
  strcat (piclist, parseJson("\"year\":\""));
  strcat (piclist, "\n\r");
//convert866();

return idpic;
}




C_task main (void)
{
  unsigned char errno;
  unsigned long iddqd, count;
  os_initstdio();

 piclist[0] = '\0';
 
 
for (count = 0; count < 20;count++)
{
  iddqd = processJson(count);
 // printf ("\n\rProcess %lu json \n\r", iddqd);
 
 errno = getPic(iddqd);
  printf ("PicDownloaded %lu,  %u\n\r",iddqd, errno);
 savePic(iddqd);
}
}

