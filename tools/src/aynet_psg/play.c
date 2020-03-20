#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "net.h"
#include "psg.h"
#include "play.h"
#include "global.h"
#include "rnd.h"
#include "ififo.h"


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
	return (int)( ((ctx->out_ptr - ctx->in_ptr - 1)&(NET_BUF_SIZE-1)) );
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
	int used_size = get_out_used_size(ctx);

	int up_to_end = NET_BUF_SIZE-ctx->out_ptr;

	if( up_to_end > used_size ) up_to_end = used_size;

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
			net_disconnect(ctx->sock);
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
	int was_framesync;

	struct frame_list * curr_frame = frames;

	// buffer for dump packet and (if needed) syncreq packet.
	uint8_t txbuf[sizeof(struct tx_packet_syncreq)+sizeof(struct tx_packet_dump)];

	struct tx_packet_dump    * const dump    = (struct tx_packet_dump    *) ( txbuf+sizeof(struct tx_packet_syncreq) );
	struct tx_packet_syncreq * const syncreq = (struct tx_packet_syncreq *) txbuf;

	struct packet * pkt;


	const size_t size_dump    = sizeof(struct tx_packet_dump);
	const size_t size_syncreq = sizeof(struct tx_packet_syncreq);
	const size_t size_both    = size_dump + size_syncreq;

	size_t actual_size;


	int frames_in_flight = 0;

	uint32_t framesync_val, framesync_old, framesync_init;


	// inits

	dump->base.type    = TOZX_DUMP;
	syncreq->base.type = TOZX_SYNCREQ;

	init_ctx(&from_zx,sock);
	init_ctx(&to_zx,sock);

	was_hello = 0;
	was_syncrply = 0;
	was_framesync = 0;




	actual_size = g.syncchk ? size_both : size_dump;
	pkt         = g.syncchk ? syncreq   : dump;


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
					net_disconnect(sock);
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
				if( !g.syncchk )
				{
					fprintf(stderr,"%s: protocol error: received ZX>> SYNCRPLY while it was not requested!\n",__PRETTY_FUNCTION__);
					exit(1);
				}
				else if( was_syncrply ) // TODO: more checks for whether syncrply was requested and whether it carries correct data
				{
					fprintf(stderr,"%s: protocol error: received multiple ZX>> SYNCRPLY!\n",__PRETTY_FUNCTION__);
					exit(1);
				}

				was_syncrply=1;

				uint32_t from_ififo = ififo_get();
				
				struct rx_packet_syncrply * syncrply = (struct rx_packet_syncrply *)rcvd;

				if( syncrply->value != from_ififo )
				{
					fprintf(stderr,"%s: protocol error: wrong data in ZX>> SYNCRPLY!\n",__PRETTY_FUNCTION__);
					exit(1);
				}
			}
		} while( rcvd->type!=FROMZX_FRAMESYNC );
#ifdef DEBUG
printf("%s: FRAMESYNC received: %08x!\n",__PRETTY_FUNCTION__,((struct rx_packet_framesync *)rcvd)->value);
#endif
		// FRAMESYNC was finally received

		if( !was_framesync )
		{ // first framesync
			was_framesync = 1;

			framesync_init = framesync_val = ((struct rx_packet_framesync *)rcvd)->value;

			if( g.framechk )
			{
				printf("FRAMECHK: initial framesync received, value = %d\n",framesync_init);
			}
		}
		else
		{ // normal sequential framesyncs
			framesync_old = framesync_val;

			framesync_val = ((struct rx_packet_framesync *)rcvd)->value;

			if( g.framechk & (framesync_val-framesync_old)!=1 )
			{
				printf("FRAMECHK: framesync skipped %d counts, total counts from initial: %d\n", framesync_val-framesync_old, framesync_val-framesync_init);
			}
		}



		was_syncrply=0;

		// assume we have (framesync_val-framesync_old) frames less
		if( frames_in_flight >= (framesync_val-framesync_old) ) frames_in_flight -= (framesync_val - framesync_old);



		if( g.prebuf >= 0 )
		{
			// put many (or required number of) ZX<< DUMP (and, if needed, ZX<< SYNCREQ) packets in tx fifo
			while( get_in_free_size(&to_zx) >= actual_size )
			{
				// make ZX<< SYNCREQ packet, if needed
				if( g.syncchk )
				{
					uint32_t rnd_val = get_rnd();
					memcpy(&syncreq->value, &rnd_val, sizeof(uint32_t));
					ififo_put(rnd_val);
				}

				// make ZX<< DUMP packet
				memcpy(dump->data, ((struct frame_ay *)curr_frame->frame)->regs, 14);
        
				int remaining_size = actual_size;
				int max_size;
        
				while( remaining_size )
				{
					max_size = get_in_cont_size(&to_zx);
        
					if( max_size > remaining_size ) max_size = remaining_size;
        
					memcpy(get_in_ptr(&to_zx), ((uint8_t *)pkt)+(actual_size-remaining_size), max_size);
					set_write_size(&to_zx,max_size);
					remaining_size -= max_size;
				}

				// next frame
				curr_frame = curr_frame->next;
				if( !curr_frame ) curr_frame = frames;

				frames_in_flight++;

				// control how many frames must be pre-buffered
				if( g.prebuf > 0 && frames_in_flight >= g.prebuf ) break;
			}
		}
		else
		{
			fprintf(stderr,"%s: g.buf_num < 0!\n",__PRETTY_FUNCTION__);
			exit(1);
		}

		
		// try to send the whole fifo. stop if actual len<requested or EAGAIN/EWOULDBLOCK
		int send_size;
		while( (send_size=get_out_cont_size(&to_zx))>0 )
		{
			ssize_t sent = send(to_zx.sock, get_out_ptr(&to_zx), send_size, MSG_DONTWAIT|MSG_NOSIGNAL);
			if( sent<0 )
			{
#ifdef _WIN32
				switch (errno=WSAGetLastError()){
#else
				switch (errno){
					case EPIPE:
					printf("Connection dropped!\n");
					return;
#if EAGAIN != EWOULDBLOCK
					case EAGAIN:
					break;
#endif
#endif
					case EWOULDBLOCK:
					break;
					case ECONNRESET:
					printf("Connection dropped!\n");
					return;
					default:
					fprintf(stderr,"%s: send() returned (-1), strerror() gave: %s!\n",__PRETTY_FUNCTION__,strerror(errno));
					exit(1);
					break;
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

