#ifndef _PLAY_H_
#define _PLAY_H_




// packet types
#define FROMZX_HELLO     (0x00)
#define FROMZX_FRAMESYNC (0x01)
#define FROMZX_SYNCRPLY  (0x02)
//
#define TOZX_SHUTUP      (0x00)
#define TOZX_DUMP        (0x01)
#define TOZX_SYNCREQ     (0x02)



// format-related structures. WARNING: they depend both on unaligned access capability and little-endian property of the CPU

struct packet
{
	uint8_t type;
} __attribute__((packed));



struct rx_packet_framesync
{
	struct packet base;
	uint32_t value; // only valid for little-endian! TODO: upgrade code to support big endian
} __attribute__((packed)); // another nasty hack to simplify code. only valid for architectures that support unaligned access

struct rx_packet_syncrply
{
	struct packet base;
	uint32_t value;
} __attribute__((packed));

struct rx_packet_hello
{
	struct packet base;
	uint8_t len;
	char text[255];
} __attribute__((packed));



struct tx_packet_shutup
{
	struct packet base;
	uint8_t type;
} __attribute__((packed));

struct tx_packet_dump
{
	struct packet base;
	uint8_t data[14];
} __attribute__((packed));

struct tx_packet_syncreq
{
	struct packet base;
	uint32_t value;
} __attribute__((packed));





#define NET_BUF_SIZE (4096) /* must be 2^n */

struct net_context
{
	int sock;

	unsigned int in_ptr;   // 'input' to the local buffer
	unsigned int out_ptr;  // 'output' from the buffer

	uint8_t buf[NET_BUF_SIZE];
};

void init_ctx(struct net_context * ctx, int sock);

int       get_in_free_size(struct net_context * ctx);           // get total free size in context's fifo
int       get_in_cont_size(struct net_context * ctx);           // get max continuous size in fifo (might be smaller that free_size)
uint8_t * get_in_ptr      (struct net_context * ctx);           // get ptr where data could be 'in' to the context's fifo -- no more than cont_size
void      set_write_size  (struct net_context * ctx, int len);  // set how many bytes were just written to the ptr given by get_in_ptr()

int       get_out_used_size(struct net_context * ctx);          // total used bytes in context's fifo
int       get_out_cont_size(struct net_context * ctx);          // continuous bytes
uint8_t * get_out_ptr      (struct net_context * ctx);          // ptr to data
void      set_read_size    (struct net_context * ctx, int len); // set how many bytes were consumed



void play_tune(int sock, struct frame_list * frames);



struct packet * rcv_packet(struct net_context * ctx);







#endif // _PLAY_H_

