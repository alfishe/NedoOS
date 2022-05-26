#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <tcp.h>




unsigned char netbuf[512];
unsigned char cmdlist[] = "GET https://zxart.ee/\r\n";
unsigned char socket;
unsigned char errno;
unsigned char status;
struct sockaddr_in 	targetadr;
struct readstructure   readStruct;

void putdec(int c)
{
  int div;
  int hassent = 0;
  for(div = 100; div > 0; div /= 10) {
    int disp = c / div;
    c %= div;
    if((disp != 0) || (hassent) || (div == 1)) {
      hassent = 1;
      putchar('0'+disp);
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
		}
		
}	

C_task main (void) 
{
	unsigned int opensocket, todo;
	unsigned int q;
	unsigned char key = 0;
	os_initstdio();
	opensocket = OS_NETSOCKET ((AF_INET << 8) + SOCK_STREAM);
	if (opensocket > 32767) {errorPrint(opensocket & 255);}
	else {socket = (opensocket >> 8); printf ("Socket #%d created\n\r", socket);}



    targetadr.family		= AF_INET;
    targetadr.porth			= 00;
	targetadr.portl			= 80;
    targetadr.b1 			= 217;
	targetadr.b2			= 146;
	targetadr.b3			= 69; 
	targetadr.b4			= 13;


	opensocket = OS_NETCONNECT (socket, &targetadr);

	if (opensocket > 32767) {errorPrint(opensocket & 255);}
	else {printf("connection successful, %u\n\r", (opensocket & 255));}

	
	strcpy (netbuf, cmdlist);
	readStruct.socket  = socket; 
	readStruct.BufAdr  = &netbuf;
	readStruct.bufsize = sizeof (cmdlist); 	
	readStruct.protocol = SOCK_STREAM;
	todo = OS_WIZNETWRITE (&readStruct);
	printf ("CONNECT, bytes sended = %u \n\r",todo);

	
	readStruct.socket  = socket; 
	readStruct.BufAdr  = &netbuf;
	readStruct.bufsize = sizeof (netbuf); 	
	readStruct.protocol = SOCK_STREAM; 

do {
	do 
	{
	todo = OS_WIZNETREAD (&readStruct);
	if (todo > 32767) {errorPrint(todo & 255);} 
	YIELD();
	}
	while ((todo & 255) == ERR_EAGAIN);

	//todo = 0;

	for (q = 0;q < todo;q++)
	{
	if (netbuf[q] == 0){putchar ('.');} else {putchar(netbuf[q]);}
	}	

	key = 0;
	while (key == 0)
	{key = _low_level_get();}


}
	while (todo == sizeof (netbuf));



//	todo = OS_BIND(unsigned char socket,struct sockaddr_in *);





	printf ("\n\r");	
return 0;
}   
