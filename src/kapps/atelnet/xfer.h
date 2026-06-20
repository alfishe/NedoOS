#ifndef ATELNET_XFER_H
#define ATELNET_XFER_H

#define XFER_PROTO_XMODEM 0u
#define XFER_PROTO_YMODEM 1u
#define XFER_PROTO_ZMODEM 2u
#define XFER_PROTO_AUTO 3u

#define XFER_STATUS_Y 22u

#define XFER_KEY_F6 182u
#define XFER_KEY_F7 183u
#define XFER_KEY_F8 184u

typedef struct XferIO XferIO;

struct XferIO
{
  signed char socket;
  unsigned char cancelled;
  unsigned char (*read_byte)(XferIO *io, unsigned char *out);
  void (*write_byte)(XferIO *io, unsigned char b);
  void (*write_buf)(XferIO *io, const unsigned char *buf, unsigned int len);
  void (*flush)(XferIO *io);
  void (*pump)(XferIO *io);
  void (*status)(XferIO *io, const char *msg);
};

void xfer_io_init(XferIO *io, signed char socket,
                  unsigned char (*read_byte)(XferIO *io, unsigned char *out),
                  void (*write_byte)(XferIO *io, unsigned char b),
                  void (*write_buf)(XferIO *io, const unsigned char *buf, unsigned int len),
                  void (*flush)(XferIO *io),
                  void (*pump)(XferIO *io),
                  void (*status)(XferIO *io, const char *msg));

unsigned char xfer_sniff_byte(unsigned char b);
void xfer_sniff_reset(void);
void xfer_sniff_begin_manual(void);
unsigned char xfer_sniff_is_pending(void);
void xfer_preflight(unsigned char proto);
unsigned char xfer_take_auto(void);
unsigned char xfer_is_prefilled(void);
void xfer_capture_pending(unsigned char proto);

int xfer_receive(unsigned char proto, XferIO *io);
int xfer_rx_byte(unsigned char b);
int xfer_zmodem_receive(XferIO *io);
unsigned char xfer_queue_pop_for_io(unsigned char *out);
unsigned char xfer_queue_depth(void);
unsigned char xfer_queue_copy(unsigned char *buf, unsigned char max);
unsigned char xfer_is_active(void);
extern unsigned char g_xfer_block[1024];

void xfer_dbg_zmodem_begin(void);
void xfer_dbg_zmodem_end(void);
void xfer_zmodem_mode(unsigned char on);
void xfer_zmodem_unlock(void);

#endif
