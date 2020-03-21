#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
#include <alloca.h>
#include <unistd.h>

#include "../net.h"



int sock_listen;

int sock;
int sock_valid;

unsigned int tick=123456;


//void signal_handler(int);


int send_bytes(char * ptr, int len);
int send_hello(void);
int send_tick(int was_syncreq, uint32_t sync_value);

int recv_bytes(char * ptr, int len);


int main(int argc, char ** argv)
{
	sock_valid = 0;

	struct sockaddr_in addr;

	int was_syncreq = 0;
	uint32_t sync_value;


	// init network (required for nedoVindOvS)
	net_init();




	// listening socket create
	sock_listen = socket(AF_INET,SOCK_STREAM,0);
	if( sock_listen==(-1) )
	{
		fprintf(stderr,"%s: socket() failed! strerror() says: %s\n",__PRETTY_FUNCTION__,strerror(errno));
		exit(1);
	}

	// bind it
	memset(&addr,0,sizeof(addr));
	addr.sin_family      = AF_INET;
	addr.sin_port        = htons(AY_PORT);
	addr.sin_addr.s_addr = INADDR_ANY;

	if( bind(sock_listen, (const struct sockaddr *)&addr, sizeof(addr))==(-1) )
	{
		fprintf(stderr,"%s: bind() failed! strerror() says: %s\n",__PRETTY_FUNCTION__,strerror(errno));
		exit(1);
	}

	// listen on it
	if( listen(sock_listen,1)==(-1) )
	{
		fprintf(stderr,"%s: listen() failed! strerror() says: %s\n",__PRETTY_FUNCTION__,strerror(errno));
		exit(1);
	}


	// accept/work loop
	for(;;)
	{
		sock = accept(sock_listen, NULL, NULL);
		if( sock==(-1) )
		{
			if( errno==EAGAIN       ||
			    errno==EWOULDBLOCK  ||
			    errno==ECONNABORTED )
			{
				continue; // try again
			}
			else
			{
				fprintf(stderr,"%s: accept() failed! strerror() says: %s\n",__PRETTY_FUNCTION__,strerror(errno));
				exit(1);
			}
		}

		sock_valid = 1;
		
		// set TCP_NODELAY to the socket
		int dummy = 1;
		setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &dummy, sizeof(dummy));


		if( !send_hello() ) continue;
printf("Hello sent!\n");

		was_syncreq = 0;

		// send ticks, accept dumps
		for(;;)
		{
			usleep(20000); // 20ms
			tick++;
			if( !send_tick(was_syncreq,sync_value) ) goto STOPTICKS;
printf("Tick=%08x sent!\n",tick);
if( was_syncreq ) printf("Syncrply=%08x sent!\n",sync_value);
			was_syncreq = 0;

			uint8_t buf[15];

			while(1)
			{
				if( !recv_bytes(&buf[0],1) ) goto STOPTICKS;

				if( buf[0]==0x00 )
				{
printf("SHUTUP received!\n");
					break;
				}
				else if( buf[0]==0x01 )
				{
					if( !recv_bytes(&buf[1],14) ) goto STOPTICKS;
printf("DUMP received!\n");
for(int i=0;i<14;i++)
printf("DUMP: [reg %02x] = %02x\n",i,buf[i+1]);
					break;
				}
				else if( buf[0]==0x02 )
				{
					if( !recv_bytes(&buf[1],4) ) goto STOPTICKS;

					was_syncreq = 1;
					sync_value = *((uint32_t *) &buf[1]);
printf("SYNCREQ received!\n");
printf("SYNCREQ: value = %08x\n",sync_value);
				}
				else
				{
					fprintf(stderr,"%s: unknown incoming pkt type = %02x\n",__PRETTY_FUNCTION__,buf[0]);
					exit(1);
				}
			}
		}
STOPTICKS:
printf("Connection closed, waiting for another...\n");
	}










	net_dispose();

	return 0;
}


/*
void signal_handler(int num)
{
	if( sock_set )
	{ // try shut up remote AY by sending lots of ZX<< SHUTUP
		uint8_t a[100]; // must be greater than any other packet size
		memset(a,0,sizeof(a));
		send(sock, (void*)&a, sizeof(a), 0);

		net_disconnect(sock);
	}

	if( frames ) free_psg_frames(frames);

	if( psg ) free_psg_file(psg);

	net_dispose();
	exit(1);
}
*/


int send_bytes(char * ptr, int len)
{
	while(len>0)
	{
		int curr_len = send(sock,ptr,len,MSG_NOSIGNAL);
		if( curr_len==(-1) )
		{
			if( errno==EAGAIN || errno==EWOULDBLOCK )
				continue;
			else if( errno==ECONNRESET || errno==EPIPE )
				return 0; // connection lost
			else
			{
				fprintf(stderr,"%s: send() failed! strerror() says: %s\n",__PRETTY_FUNCTION__,strerror(errno));
				exit(1);
			}
		}

		len -= curr_len;
		ptr += curr_len;
	}

	return 1;
}

int recv_bytes(char * ptr, int len)
{
	char bigbuf[1024];

	if( len>sizeof(bigbuf) )
	{
		fprintf(stderr,"%s: len=%d is greater than buffer size %ld\n",__PRETTY_FUNCTION__,len,sizeof(bigbuf));
		exit(1);
	}

	
	while(len>0)
	{
		int curr_len = recv(sock,ptr,len,0);
		if( curr_len==(-1) )
		{
			if( errno==EAGAIN || errno==EWOULDBLOCK )
				continue;

			else if( errno==ECONNREFUSED )
				return 0;
			else
			{
				fprintf(stderr,"%s: recv() failed! strerror() says: %s\n",__PRETTY_FUNCTION__,strerror(errno));
				exit(1);
			}
		}

		len -= curr_len;
		ptr += curr_len;
	}
}



int send_hello(void)
{
	char hello_str[] = "Hello Shitty";
	char * hello_pkt = alloca(2+sizeof(hello_str));

	hello_pkt[0] = 0;
	hello_pkt[1] = strlen(hello_str);
	strcpy(&hello_pkt[2], hello_str);

	return send_bytes(hello_pkt,2+hello_pkt[1]);
}

int send_tick(int was_syncreq, uint32_t sync_value)
{
	char buf[10];

	buf[0] = 0x01;
	memcpy(&buf[1],&tick,4);

	if( was_syncreq )
	{
		buf[5] = 0x02;
		memcpy(&buf[6],&sync_value,4);

		return send_bytes(buf,10);
	}
	else
	{
		return send_bytes(buf,5);
	}
}


