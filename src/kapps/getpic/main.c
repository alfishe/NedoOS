#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <tcp.h>




unsigned char netbuf[128];
unsigned char cmdlist[] = "GET https:\/\/zxart.ee\/file\/id:385482\/filename:Lobo_-_Moritz_The_Striker_(Game_Over)_(2020).scr/\n";
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
	unsigned char key = 0, clientID;
	os_initstdio();
	opensocket = OS_NETSOCKET ((AF_INET << 8) + SOCK_STREAM);
	if (opensocket > 32767) {printf("OS_NETSOCKET "); errorPrint(opensocket & 255);}
	else {socket = ( (opensocket & 65280) >> 8); printf ("OS_NETSOCKET: Socket #%d created\n\r", socket);}



    targetadr.family		= AF_INET;
    targetadr.porth			= 00;
	targetadr.portl			= 80;
    targetadr.b1 			= 217;
	targetadr.b2			= 146;
	targetadr.b3			= 69; 
	targetadr.b4			= 13;

	todo = OS_BIND(socket, &targetadr);	// номер порта для сокета
	if (todo > 32767) {printf("OS_BIND: "); errorPrint(todo & 255);}  else {printf ("OS_BIND: Socket #%u Binded to port %u%u\n\r", socket,targetadr.porth, targetadr.portl);}


//	todo = OS_LISTEN(socket);
//	if (todo > 32767) {printf("OS_LISTEN: "); errorPrint(todo & 255);}  else {printf ("OS_LISTEN: Socket #%u now listening\n\r", socket);}


//	todo = OS_ACCEPT(socket); //after OS_BIND 
//	if (todo > 32767) {printf("OS_ACCEPT: "); errorPrint(todo & 255);}  else {clientID = (opensocket & 65280) >> 8 ; printf ("OS_NETSHUTDOWN: Socket #%u now accept client #%u\n\r", socket, clientID);}


//	todo = OS_NETSHUTDOWN (socket);
//	if (todo > 32767) {printf("OS_NETSHUTDOWN: "); errorPrint(todo & 255);}  else {printf ("Socket #%u closed.\n\r", socket);}



	opensocket = OS_NETCONNECT (socket, &targetadr);

	if (opensocket > 32767) {printf("OS_NETCONNECT: "); errorPrint(opensocket & 255);} else {printf("OS_NETCONNECT: connection successful, %u\n\r", (opensocket & 255));}

	
	strcpy (netbuf, cmdlist);
	readStruct.socket  = socket; 
	readStruct.BufAdr  = &netbuf;
	readStruct.bufsize = sizeof (cmdlist); 	
	readStruct.protocol = SOCK_STREAM;
	todo = OS_WIZNETWRITE (&readStruct);
	if (todo > 32767) {printf("OS_WIZNETWRITE: "); errorPrint(todo & 255);} else {printf("OS_WIZNETWRITE: %u bytes written. \n\r", todo & 255);} 

	
	readStruct.socket  = socket; 
	readStruct.BufAdr  = &netbuf;
	readStruct.bufsize = sizeof (netbuf); 	
	readStruct.protocol = SOCK_STREAM; 

do {
	do 
	{
	todo = OS_WIZNETREAD (&readStruct);
	if (todo > 32767) {printf("OS_WIZNETREAD: "); errorPrint(todo & 255);} else {printf("OS_WIZNETREAD: %u bytes read. \n\r", todo & 255);} 
	YIELD();
	}
	while ((todo & 255) == ERR_EAGAIN);

	

	key = 0;
	while (key == 0)
	{key = _low_level_get();}


	for (q = 0;q < todo;q++)
	{
	if (netbuf[q] == 0){putchar ('.');} else {putchar(netbuf[q]);}
	}	
}
	while (todo == sizeof (netbuf));
	printf ("\n\r");	
return 0;
}   
