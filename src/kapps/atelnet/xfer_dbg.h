#ifndef ATELNET_XFER_DBG_H
#define ATELNET_XFER_DBG_H

void xfer_dbg_zmodem_begin(void);
void xfer_dbg_zmodem_end(void);
void xfer_dbg_capture_begin(void);
void xfer_dbg_capture_end(void);
unsigned char xfer_dbg_capturing(void);
void xfer_dbg_log_rx(unsigned char b);
void xfer_dbg_log_q(unsigned char b);
void xfer_dbg_log_tx(unsigned char b);
void xfer_dbg_tx(const unsigned char *buf, unsigned int len);
void xfer_dbg_rx(unsigned char b);
void xfer_dbg_draw(unsigned char qdepth);
void xfer_dbg_note(const char *msg);
void xfer_dbg_frame(unsigned char rc, unsigned char typ, unsigned char idle);
void xfer_dbg_dump_session(unsigned char qdepth);
void xfer_dbg_queue_snap(void);

#endif
