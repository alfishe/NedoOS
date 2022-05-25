#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <tcp.h>


unsigned char netbuf[2*1024];
unsigned char cmdlist[] = "CONNECT\r\n";
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

C_task main (void) 
{
	unsigned int opensocket, todo;
	unsigned int q;
	unsigned char key = 0;
	os_initstdio();
	opensocket = OS_NETSOCKET ((AF_INET << 8) + SOCK_STREAM);
	errno  = opensocket >> 8 ;
	socket = opensocket;
	if (errno !=0) {printf("Socket creation error %d\n\r",errno);}
	else {printf ("Socket #%d created\n\r", socket);}

    targetadr.family		= AF_INET;
    targetadr.porth			= 00;
	targetadr.portl			= 80;
    targetadr.b1 			= 217;
	targetadr.b2			= 146;
	targetadr.b3			= 69; 
	targetadr.b4			= 13;


	opensocket = OS_NETCONNECT (socket, &targetadr);

	errno  = opensocket >> 8 ;
	status = opensocket;
	if (status !=0) {printf("connection unsuccessful  %d %d \n\r", status, errno);}
	else {printf ("Connection successful\n\r");}

	
	strcpy (netbuf, cmdlist);
	readStruct.socket  = socket; 
	readStruct.BufAdr  = &netbuf;
	readStruct.bufsize = sizeof (cmdlist); 	
	readStruct.protocol = SOCK_STREAM;
	todo = OS_WIZNETWRITE (&readStruct);
	printf ("CONNECT, bytes sended = %u \n\r",todo);

	while (key == 0)
	{key = _low_level_get();}

	readStruct.socket  = socket; 
	readStruct.BufAdr  = &netbuf;
	readStruct.bufsize = sizeof (netbuf); 	
	readStruct.protocol = SOCK_STREAM; 

	todo = OS_WIZNETREAD (&readStruct);
	printf ("ANSWER from server bytes: %u \n\r",todo);

	for (q = 0;q < todo;q++)
	{
	if (netbuf[q] == 0){putchar ('.');} else {putchar(netbuf[q]);}
	}	

	while (key == 0)
	{key = _low_level_get();}
	printf ("\n\r");	
return 0;
}   
