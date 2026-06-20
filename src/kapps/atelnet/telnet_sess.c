#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include "atelnet.h"
#include "netglue.h"
#include "telnet_sess.h"
#include "xfer.h"
#include "xfer_dbg.h"

#define TN_IAC     255u
#define TN_DONT    254u
#define TN_DO      253u
#define TN_WONT    252u
#define TN_WILL    251u
#define TN_SB      250u
#define TN_SE      240u
#define TN_ECHO    1u
#define TN_BIN     0u
#define TN_SGA     3u
#define TN_TTYPE   24u
#define TN_NAWS    31u
#define TN_GA      249u

#define RX_DATA    0u
#define RX_IAC     1u
#define RX_CMD     2u
#define RX_SB      3u
#define RX_SB_IAC  4u

#define TXBUF_SIZE 256u
#define IDLE_HINT_LOOPS 120000ul

/* BDOS key codes (sysdefs.asm cs5..cs8, ext5=F5). */
#define KEY_LEFT   248u
#define KEY_DOWN   249u
#define KEY_UP     250u
#define KEY_RIGHT  251u
#define KEY_F5     181u
#define KEY_F6     182u
#define KEY_F7     183u
#define KEY_F8     184u
#define KEY_ENTER  13u
#define KEY_CSENTER 253u

static signed char g_socket = -1;
static unsigned char g_rx_state;
static unsigned char g_rx_cmd;
static unsigned char g_sb_opt;
static unsigned char g_txbuf[TXBUF_SIZE];
static unsigned char g_txlen;
static unsigned char g_echo_remote;
static unsigned char g_debug;
static unsigned char g_sock_err;
static unsigned char g_tn_sga;
static unsigned char g_cpr_ga_debt;
static unsigned char g_wait_hint;
static unsigned int g_rx_total;
static unsigned int g_tx_total;
static unsigned int g_cpr_tx;
static unsigned int g_ga_tx;
static unsigned long g_idle_loops;

static void telnet_flush_ga_debt(void);

static int telnet_poll_rx(void);
static XferIO *telnet_xfer_io(void);
static void telnet_after_xfer(int rc);
static void telnet_start_receive(unsigned char proto);

static void telnet_count_tx(unsigned int n)
{
  g_tx_total += n;
}

static void telnet_flush_tx(void)
{
  int sent;
  unsigned int done;

  while (g_txlen > 0u)
  {
    sent = tcpSend(g_socket, (unsigned int)g_txbuf, g_txlen, 3u);
    if (sent <= 0)
    {
      return;
    }
    done = (unsigned int)sent;
    telnet_count_tx(done);
    if (done >= g_txlen)
    {
      g_txlen = 0u;
      return;
    }
    memmove(g_txbuf, g_txbuf + done, g_txlen - done);
    g_txlen = (unsigned char)(g_txlen - done);
  }
}

static void telnet_send_byte(unsigned char b)
{
  if (g_txlen >= TXBUF_SIZE)
  {
    telnet_flush_tx();
  }
  g_txbuf[g_txlen++] = b;
}

static void telnet_send_iac(unsigned char cmd, unsigned char opt)
{
  telnet_send_byte(TN_IAC);
  telnet_send_byte(cmd);
  telnet_send_byte(opt);
}

static void telnet_send_naws(void)
{
  telnet_send_byte(TN_IAC);
  telnet_send_byte(TN_SB);
  telnet_send_byte(TN_NAWS);
  telnet_send_byte(0u);
  telnet_send_byte(80u);
  telnet_send_byte(0u);
  telnet_send_byte(25u);
  telnet_send_byte(TN_IAC);
  telnet_send_byte(TN_SE);
}

static void telnet_send_ttype(void)
{
  /* MSX UNAPI TELNET 1.34: TTYPE IS "ANSI" (see Telnet.h ucTTYPE2). */
  telnet_send_byte(TN_IAC);
  telnet_send_byte(TN_SB);
  telnet_send_byte(TN_TTYPE);
  telnet_send_byte(0u);
  telnet_send_byte('A');
  telnet_send_byte('N');
  telnet_send_byte('S');
  telnet_send_byte('I');
  telnet_send_byte(TN_IAC);
  telnet_send_byte(TN_SE);
}

static void telnet_handle_do(unsigned char opt)
{
  switch (opt)
  {
  case TN_NAWS:
    telnet_send_iac(TN_WILL, opt);
    telnet_send_naws();
    telnet_flush_tx();
    break;
  case TN_TTYPE:
  case TN_BIN:
    telnet_send_iac(TN_WILL, opt);
    telnet_flush_tx();
    break;
  default:
    telnet_send_iac(TN_WONT, opt);
    telnet_flush_tx();
    break;
  }
}

static void telnet_handle_cmd(unsigned char cmd, unsigned char opt)
{
  switch (cmd)
  {
  case TN_DO:
    telnet_handle_do(opt);
    break;
  case TN_DONT:
    if (opt == TN_ECHO)
    {
      g_echo_remote = 0u;
    }
    telnet_send_iac(TN_WONT, opt);
    telnet_flush_tx();
    break;
  case TN_WILL:
    /* MSX UNAPI TELNET 1.34: host WILL -> we DO (incl. SGA, ECHO). */
    if (opt == TN_ECHO)
    {
      g_echo_remote = 1u;
    }
    else if (opt == TN_SGA)
    {
      g_tn_sga = 1u;
      telnet_flush_ga_debt();
    }
    telnet_send_iac(TN_DO, opt);
    telnet_flush_tx();
    break;
  case TN_WONT:
    if (opt == TN_ECHO)
    {
      g_echo_remote = 0u;
    }
    else if (opt == TN_SGA)
    {
      g_tn_sga = 0u;
    }
    telnet_send_iac(TN_DONT, opt);
    telnet_flush_tx();
    break;
  default:
    break;
  }
}

static void telnet_emit_reply(unsigned char b)
{
  telnet_send_byte(b);
}

static void telnet_send_ga(void)
{
  telnet_send_byte(TN_IAC);
  telnet_send_byte(TN_GA);
  g_ga_tx++;
}

static void telnet_flush_replies(void)
{
  unsigned char before;

  before = g_txlen;
  term_drain_replies(telnet_emit_reply);
  if (g_txlen > before)
  {
    g_cpr_tx++;
    /* Synchronet may block until IAC GA after CPR even with SGA (CPR before SGA). */
    telnet_send_ga();
    if (g_tn_sga == 0u)
    {
      g_cpr_ga_debt++;
    }
  }
  if (g_txlen > 0u)
  {
    telnet_flush_tx();
  }
}

static void telnet_flush_ga_debt(void)
{
  while (g_cpr_ga_debt > 0u)
  {
    telnet_send_ga();
    g_cpr_ga_debt--;
  }
  if (g_txlen > 0u)
  {
    telnet_flush_tx();
  }
}

static void telnet_feed_term(unsigned char b)
{
  if (term_feed(b) == 0)
  {
    return;
  }
  if (term_has_replies() != 0u)
  {
    telnet_flush_replies();
  }
}

static XferIO g_xfer_io;

static void telnet_zmodem_abort_host(void)
{
  unsigned char i;

  for (i = 0u; i < 8u; i++)
  {
    telnet_send_byte(0x18u);
  }
  telnet_flush_tx();
}

static unsigned char telnet_xfer_read_byte(XferIO *io, unsigned char *out)
{
  unsigned char key;
  unsigned char i;

  (void)io;
  if (xfer_queue_pop_for_io(out) != 0u)
  {
    return 1u;
  }
  for (i = 0u; i < 128u; i++)
  {
    if (telnet_poll_rx() < 0)
    {
      return 0u;
    }
    if (xfer_queue_pop_for_io(out) != 0u)
    {
      return 1u;
    }
  }
  key = (unsigned char)(OS_GETKEY() & 0xFFL);
  if (key == KEY_F5)
  {
    g_xfer_io.cancelled = 1u;
  }
  return 0u;
}

static void telnet_xfer_write_byte(XferIO *io, unsigned char b)
{
  (void)io;
  telnet_send_byte(b);
  if (b == TN_IAC)
  {
    telnet_send_byte(TN_IAC);
  }
  xfer_dbg_log_tx(b);
}

static void telnet_xfer_pump(XferIO *io)
{
  unsigned char i;

  (void)io;
  for (i = 0u; i < 128u; i++)
  {
    if (telnet_poll_rx() <= 0)
    {
      break;
    }
  }
}

static void telnet_xfer_flush(XferIO *io)
{
  (void)io;
  telnet_flush_tx();
}

static void telnet_xfer_write_buf(XferIO *io, const unsigned char *buf, unsigned int len)
{
  unsigned int i;

  (void)io;
  for (i = 0u; i < len; i++)
  {
    telnet_xfer_write_byte(io, buf[i]);
  }
  xfer_dbg_tx(buf, len);
  telnet_flush_tx();
}

static void telnet_xfer_status(XferIO *io, const char *msg)
{
  (void)io;
  term_set_xy(0u, 23u);
  term_set_color(0x4Eu);
  printf("%-78s", msg);
  term_set_color(0x07u);
}

static void telnet_after_xfer(int rc)
{
  unsigned char k;

  term_set_xy(0u, 23u);
  term_set_color(0x07u);
  printf("%-78s", "");
  if (rc != 0)
  {
    term_set_xy(0u, XFER_STATUS_Y);
    term_set_color(0x70u);
    printf("Download OK                                              ");
    term_set_color(0x07u);
  }
  else
  {
    term_set_xy(0u, XFER_STATUS_Y);
    term_set_color(0x4Eu);
    printf("Download failed - F8=dump log  Enter=back              ");
    term_set_color(0x07u);
    telnet_zmodem_abort_host();
    for (;;)
    {
      YIELD();
      k = (unsigned char)(OS_GETKEY() & 0xFFL);
      if (k == KEY_F8)
      {
        xfer_dbg_dump_session(xfer_queue_depth());
        term_set_xy(0u, XFER_STATUS_Y);
        term_set_color(0x4Eu);
        printf("Download failed - F8=dump log  Enter=back              ");
        term_set_color(0x07u);
      }
      else if (k == KEY_ENTER || k == KEY_CSENTER)
      {
        break;
      }
    }
    term_set_xy(0u, XFER_STATUS_Y);
    printf("%-78s", "");
    xfer_sniff_reset();
    telnet_send_byte(13u);
    telnet_send_byte(10u);
    telnet_flush_tx();
  }
  while ((OS_GETKEY() & 0xFFL) != 0L)
  {
    YIELD();
  }
}

static XferIO *telnet_xfer_io(void)
{
  xfer_io_init(&g_xfer_io, g_socket,
                 telnet_xfer_read_byte,
                 telnet_xfer_write_byte,
                 telnet_xfer_write_buf,
                 telnet_xfer_flush,
                 telnet_xfer_pump,
                 telnet_xfer_status);
  return &g_xfer_io;
}

static void telnet_start_receive(unsigned char proto)
{
  int rc;
  unsigned int i;

  if (xfer_dbg_capturing() == 0u)
  {
    xfer_dbg_capture_begin();
  }
  if (proto != XFER_PROTO_AUTO && xfer_is_prefilled() == 0u)
  {
    xfer_sniff_begin_manual();
  }
  if (xfer_is_active() == 0u)
  {
    xfer_capture_pending(proto);
  }
  telnet_send_iac(TN_WILL, TN_BIN);
  telnet_send_iac(TN_DO, TN_BIN);
  telnet_flush_tx();
  for (i = 0u; i < 120u; i++)
  {
    if (telnet_poll_rx() < 0)
    {
      break;
    }
    if ((i & 0x0Fu) == 0u)
    {
      YIELD();
    }
  }
  rc = xfer_receive(proto, telnet_xfer_io());
  telnet_after_xfer(rc);
}

static void telnet_data_byte(unsigned char b)
{
  if (xfer_dbg_capturing() != 0u)
  {
    xfer_dbg_log_rx(b);
  }
  if (xfer_is_active() != 0u)
  {
    (void)xfer_rx_byte(b);
    return;
  }
  /* Keep RX path minimal: no auto-sniff in normal telnet rendering. */
  telnet_feed_term(b);
}

static void telnet_process(unsigned char b)
{
  switch (g_rx_state)
  {
  case RX_DATA:
    if (b == TN_IAC)
    {
      g_rx_state = RX_IAC;
    }
    else
    {
      telnet_data_byte(b);
    }
    break;

  case RX_IAC:
    if (b == TN_IAC)
    {
      g_rx_state = RX_DATA;
      telnet_data_byte(TN_IAC);
    }
    else if (b == TN_SB)
    {
      g_rx_state = RX_SB;
      g_sb_opt = 0u;
    }
    else if (b == TN_WILL || b == TN_WONT || b == TN_DO || b == TN_DONT)
    {
      g_rx_cmd = b;
      g_rx_state = RX_CMD;
    }
    else
    {
      g_rx_state = RX_DATA;
    }
    break;

  case RX_CMD:
    telnet_handle_cmd(g_rx_cmd, b);
    g_rx_state = RX_DATA;
    break;

  case RX_SB:
    if (b == TN_IAC)
    {
      g_rx_state = RX_SB_IAC;
    }
    else if (g_sb_opt == 0u)
    {
      g_sb_opt = b;
    }
    else if (g_sb_opt == TN_TTYPE && b == 1u)
    {
      telnet_send_ttype();
      telnet_flush_tx();
    }
    break;

  case RX_SB_IAC:
    if (b == TN_SE)
    {
      g_rx_state = RX_DATA;
      g_sb_opt = 0u;
    }
    else
    {
      g_rx_state = RX_SB;
      if (b != TN_IAC)
      {
        telnet_process(b);
      }
    }
    break;

  default:
    g_rx_state = RX_DATA;
    break;
  }
}

static int telnet_poll_rx(void)
{
  unsigned int i;
  int n;
  int got;

  got = 0;
  for (;;)
  {
    n = telnet_tcp_read(g_socket);
    if (n < 0)
    {
      g_sock_err = (unsigned char)(-n);
      return -1;
    }
    if (n == 0)
    {
      break;
    }
    got = 1;
    g_rx_total += (unsigned int)n;
    g_idle_loops = 0ul;
    for (i = 0u; i < (unsigned int)n; i++)
    {
      telnet_process(netbuf[i]);
    }
    if (g_txlen > 0u)
    {
      telnet_flush_tx();
    }
  }
  return got;
}

static void telnet_status_draw(void)
{
  unsigned char col;
  unsigned char row;

  if (g_debug == 0u)
  {
    return;
  }
  term_get_xy(&col, &row);
  term_set_xy(0u, TERM_LAST_ROW);
  term_set_color(0x70u);
  printf("RX:%u TX:%u cpr:%u ga:%u sga:%u echo:%s err:%u ",
         g_rx_total,
         g_tx_total,
         g_cpr_tx,
         g_ga_tx,
         (unsigned int)g_tn_sga,
         g_echo_remote != 0u ? "srv" : "loc",
         (unsigned int)g_sock_err);
  term_set_color(0x07u);
  term_set_xy(col, row);
}

static void telnet_waiting_hint(void)
{
  if (g_rx_total > 0u || g_wait_hint != 0u)
  {
    return;
  }
  if (g_idle_loops < IDLE_HINT_LOOPS)
  {
    return;
  }
  g_wait_hint = 1u;
  term_set_xy(0u, 0u);
  term_set_color(0x4Eu);
  printf("Connected. Waiting for host data... (retry if BBS busy)");
  term_set_color(0x07u);
}

static void telnet_send_text(const char *s)
{
  while (*s)
  {
    telnet_send_byte((unsigned char)*s);
    s++;
  }
  telnet_flush_tx();
}

static void telnet_send_esc(void)
{
  telnet_send_byte(27u);
  telnet_flush_tx();
}

static void telnet_send_key(unsigned char key)
{
  switch (key)
  {
  case 8:
  case 127:
    telnet_send_byte(8u);
    break;
  case KEY_ENTER:
  case KEY_CSENTER:
  case 10:
    telnet_send_byte(13u);
    telnet_send_byte(10u);
    break;
  default:
    if (key >= 32 && key < 127)
    {
      telnet_send_byte(key);
    }
    else if (key >= 1u && key < 32u)
    {
      telnet_send_byte(key);
    }
    else if (term_wire_is_cp866() != 0u && key >= 0x80u)
    {
      telnet_send_byte(key);
    }
    break;
  }
  telnet_flush_tx();
}

static void telnet_send_arrow(unsigned char key)
{
  switch (key)
  {
  case KEY_LEFT:
    telnet_send_text("\x1b[D");
    break;
  case KEY_RIGHT:
    telnet_send_text("\x1b[C");
    break;
  case KEY_UP:
    telnet_send_text("\x1b[A");
    break;
  case KEY_DOWN:
    telnet_send_text("\x1b[B");
    break;
  default:
    break;
  }
}

static void show_connecting(const char *host, unsigned int port)
{
  term_cls(0x07u);
  term_set_xy(0u, 0u);
  printf("Connecting %s:%u ...", host, port);
}

static void show_net_error(const char *msg)
{
  term_cls(0x4Fu);
  term_set_xy(0u, 0u);
  printf("atelnet: %s\r\n", msg);
  term_set_xy(0u, 2u);
  printf("Press any key...");
  do
  {
    YIELD();
  } while ((OS_GETKEY() & 0xFFL) == 0L);
}

static void show_session_end(unsigned char user_quit)
{
  if (g_sock_err != 0u)
  {
    term_cls(0x4Fu);
    term_set_xy(0u, 0u);
    printf("atelnet: connection lost (err %u)\r\n", (unsigned int)g_sock_err);
    term_set_xy(0u, 2u);
    printf("Press any key...");
    do
    {
      YIELD();
    } while ((OS_GETKEY() & 0xFFL) == 0L);
    return;
  }
  if (g_rx_total == 0u)
  {
    term_cls(0x4Fu);
    term_set_xy(0u, 0u);
    if (user_quit != 0u)
    {
      printf("atelnet: host sent no data\r\n");
    }
    else
    {
      printf("atelnet: host closed without data\r\n");
    }
    term_set_xy(0u, 2u);
    printf("BBS may rate-limit. Wait and retry.\r\n");
    term_set_xy(0u, 4u);
    printf("Press any key...");
    do
    {
      YIELD();
    } while ((OS_GETKEY() & 0xFFL) == 0L);
  }
}

int telnet_session(const char *host, unsigned int port, unsigned char debug, unsigned char cp866)
{
  unsigned char running;
  unsigned char user_quit;
  unsigned char kick;
  int poll_rc;

  g_socket = -1;
  g_rx_state = RX_DATA;
  g_sb_opt = 0u;
  g_txlen = 0u;
  /* BBS echo typed chars; never mirror locally (avoids doubled letters). */
  g_echo_remote = 1u;
  g_debug = debug;
  g_sock_err = 0u;
  g_tn_sga = 0u;
  g_cpr_ga_debt = 0u;
  g_wait_hint = 0u;
  g_rx_total = 0u;
  g_tx_total = 0u;
  g_cpr_tx = 0u;
  g_ga_tx = 0u;
  g_idle_loops = 0ul;

  show_connecting(host, port);
  if (!net_resolve_host(host))
  {
    show_net_error("DNS failed");
    return 0;
  }

  g_socket = net_connect_tcp(port, 5u);
  if (g_socket < 0)
  {
    show_net_error("connect failed");
    return 0;
  }

  term_cls(0x07u);
  term_init();
  term_set_color(0x07u);
  if (cp866 != 0u)
  {
    term_set_wire_cp866();
  }
  else
  {
    term_set_wire_cp437();
  }
  term_palette_begin();

  for (kick = 0u; kick < 64u; kick++)
  {
    poll_rc = telnet_poll_rx();
    if (poll_rc < 0)
    {
      break;
    }
    if (g_rx_total > 0u)
    {
      break;
    }
    YIELD();
  }

  running = 1u;
  user_quit = 0u;
  while (running)
  {
    unsigned char key;

    do
    {
      poll_rc = telnet_poll_rx();
      if (poll_rc < 0)
      {
        running = 0u;
        break;
      }
    } while (poll_rc > 0);
    if (running == 0u)
    {
      break;
    }
    if (poll_rc == 0)
    {
      g_idle_loops++;
    }
    telnet_waiting_hint();
    telnet_status_draw();
    if (g_txlen > 0u)
    {
      telnet_flush_tx();
    }
    key = (unsigned char)(OS_GETKEY() & 0xFFL);
    if (key != 0u)
    {
      if (key == KEY_F5)
      {
        running = 0u;
        user_quit = 1u;
      }
      else if (key == 27)
      {
        telnet_send_esc();
      }
      else if (key == KEY_F6)
      {
        telnet_start_receive(XFER_PROTO_ZMODEM);
      }
      else if (key == KEY_F7)
      {
        telnet_start_receive(XFER_PROTO_YMODEM);
      }
      else if (key == KEY_F8)
      {
        telnet_start_receive(XFER_PROTO_XMODEM);
      }
      else if (key == KEY_LEFT || key == KEY_RIGHT || key == KEY_UP || key == KEY_DOWN)
      {
        telnet_send_arrow((unsigned char)key);
      }
      else
      {
        telnet_send_key((unsigned char)key);
      }
    }
    else
    {
      YIELD();
    }
  }

  telnet_flush_tx();
  netShutDown(g_socket, 0u);
  g_socket = -1;
  term_palette_restore();
  show_session_end(user_quit);
  return 1;
}
