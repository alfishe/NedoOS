#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "net.h"
#include "psg.h"
#include "play.h"


// init net_context
void init_ctx(struct net_context * ctx, int sock)
{
	if( ctx )
	{
		ctx->sock = sock;
		ctx->in_ptr = ctx->out_ptr = 0;
	}
	else
	{
		fprintf(stderr,"%s: ctx pointer is NULL!\n",__PRETTY_FUNCTION__);
		exit(1);
	}
}






int get_in_free_size(struct net_context * ctx)
{
	return (int)( NET_BUF_SIZE-1 - ((ctx->out_ptr - ctx->in_ptr)&(NET_BUF_SIZE-1)) );
}


int get_in_cont_size(struct net_context * ctx)
{
	int free_size = get_in_free_size(ctx);

	int up_to_end = NET_BUF_SIZE-ctx->in_ptr;

	if( up_to_end > free_size ) up_to_end = free_size;

	return up_to_end;
}


uint8_t * get_in_ptr(struct net_context * ctx)
{
	return &ctx->buf[ctx->in_ptr];
}


void set_write_size(struct net_context * ctx, int len)
{
	ctx->in_ptr += len;
	ctx->in_ptr &= (NET_BUF_SIZE-1);
}



int get_out_used_size(struct net_context * ctx)
{
	return (int)((ctx->in_ptr - ctx->out_ptr)&(NET_BUF_SIZE-1));
}


int get_out_cont_size(struct net_context * ctx)
{
	int free_size = get_in_free_size(ctx);

	int up_to_end = NET_BUF_SIZE-ctx->out_ptr;

	if( up_to_end > free_size ) up_to_end = free_size;

	return up_to_end;
}


uint8_t * get_out_ptr(struct net_context * ctx)
{
	return &ctx->buf[ctx->out_ptr];
}


void set_read_size(struct net_context * ctx, int len)
{
	ctx->out_ptr += len;
	ctx->out_ptr &= (NET_BUF_SIZE-1);
}










struct packet * rcv_packet(struct net_context * ctx)
{
	static uint8_t buf[NET_BUF_SIZE];

	uint8_t type;
	uint8_t hello_size;


	// receive packet type
	if( !net_recv_bytes(ctx->sock, &buf[0], 1) )
	{
		return NULL; // if connection is closed
	}

	switch( type=buf[0] )
	{
		case FROMZX_HELLO:
			if( !net_recv_bytes(ctx->sock, &buf[1], 1) ) return NULL;

			if( (hello_size=buf[1])>0 )
			{
				if( !net_recv_bytes(ctx->sock, &buf[2], hello_size) ) return NULL;
			}
		break;

		case FROMZX_FRAMESYNC:
		case FROMZX_SYNCRPLY:
			if( !net_recv_bytes(ctx->sock, &buf[1], 4) ) return NULL;
		break;

		default:
			fprintf(stderr,"%s: invalid packet type (0x%02x) received!\n",__PRETTY_FUNCTION__,type);
			exit(1);
		break;
	}

	return (struct packet *)buf;
}







void play_tune(int sock, struct frame_list * frames)
{
	struct net_context from_zx;
	struct net_context to_zx;

	struct packet * rcvd;

	int was_hello;
	int was_syncrply;

	struct frame_list * curr_frame = frames;

	struct tx_packet_dump dump;




	// inits

	dump.base.type = TOZX_DUMP;

	init_ctx(&from_zx,sock);
	init_ctx(&to_zx,sock);

	was_hello = 0;
	was_syncrply = 0;


	// play loop

	for(;;)
	{
		// wait for frame sync
		do
		{
			if( !(rcvd=rcv_packet(&from_zx)) ) return;

			if( rcvd->type==FROMZX_HELLO )
			{
				if( was_hello )
				{
					fprintf(stderr,"%s: protocol error: received multiple ZX>> HELLO!\n",__PRETTY_FUNCTION__);
					exit(1);
				}

				was_hello=1;

				struct rx_packet_hello * hello = (struct rx_packet_hello *)rcvd;

				char hell_str[256];
				memset(hell_str,0,sizeof(hell_str));
				if( hello->len > 0 )
				{
					strncpy(hell_str, hello->text, hello->len);
				}
				printf("Hello from ZX: %s\n",hell_str);
			}
			else if( rcvd->type==FROMZX_SYNCRPLY )
			{
				if( was_syncrply ) // TODO: more checks for whether syncrply was requested and whether it carries correct data
				{
					fprintf(stderr,"%s: protocol error: received multiple ZX>> SYNCRPLY!\n",__PRETTY_FUNCTION__);
					exit(1);
				}

				was_syncrply=1;
			}
		} while( rcvd->type!=FROMZX_FRAMESYNC );

		// FRAMESYNC was finally received
		was_syncrply=0;



		// put many ZX<< DUMP packets in tx fifo
		while( get_in_free_size(&to_zx) >= sizeof(dump) )
		{
			memcpy(dump.data, ((struct frame_ay *)curr_frame->frame)->regs, 14);

			int remaining_size = sizeof(dump);
			int max_size;

			while( remaining_size )
			{
				max_size = get_in_cont_size(&to_zx);

				if( max_size > remaining_size ) max_size = remaining_size;

				memcpy(get_in_ptr(&to_zx), ((uint8_t *)&dump)+(sizeof(dump)-remaining_size), max_size);
				set_write_size(&to_zx,max_size);
				remaining_size -= max_size;
			}

			// next frame
			curr_frame = curr_frame->next;
			if( !curr_frame ) curr_frame = frames;
		}

		
		// try to send the whole fifo. stop if actual len<requested or EAGAIN/EWOULDBLOCK
		int send_size;
		while( (send_size=get_out_cont_size(&to_zx))>0 )
		{
			ssize_t sent = send(to_zx.sock, get_out_ptr(&to_zx), send_size, MSG_DONTWAIT|MSG_NOSIGNAL);
			if( sent<0 )
			{
				if( errno==EAGAIN || errno==EWOULDBLOCK )
				{
					break;
				}
				else if( errno==ECONNRESET || errno==EPIPE )
				{
					printf("Connection dropped!\n");
					return;
				}
				else
				{
					fprintf(stderr,"%s: send() returned (-1), strerror() gave: %s!\n",__PRETTY_FUNCTION__,strerror(errno));
					exit(1);
				}
			}
			else if( sent>0 )
			{
				set_read_size(&to_zx, sent);
			}

			if( sent < send_size )
				break;
		}
	}
}

