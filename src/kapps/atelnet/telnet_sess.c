#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include "term.h"
#include "netglue.h"
#include "atelnet_plug.h"
#include "app_bank.h"
#include "telnet_sess.h"
#include "zmodem.h"

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

#define KEY_LEFT   248u
#define KEY_DOWN   249u
#define KEY_UP     250u
#define KEY_RIGHT  251u
#define KEY_F2     178u
#define KEY_F5     181u
#define KEY_F6     182u
#define KEY_F7     183u
#define KEY_F8     184u
#define KEY_F10    176u
#define KEY_ENTER  13u
#define KEY_CSENTER 253u

#define XFER_ZSEND 0u
#define XFER_ZRECV 1u
#define XFER_YRECV 2u
#define XFER_XRECV 3u

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
static unsigned char g_tn_binary;
static unsigned char g_cpr_ga_debt;
static unsigned char g_wait_hint;
static unsigned int g_rx_total;
static unsigned int g_tx_total;
static unsigned int g_cpr_tx;
static unsigned int g_ga_tx;
static unsigned long g_idle_loops;

static void telnet_flush_ga_debt(void);
static int telnet_poll_rx(void);
static void telnet_ui_redraw(void);
static void telnet_drain_keys(unsigned char do_redraw);
static char g_cur_host[128];

static void telnet_flush_tx(void)
{
  int sent;
  unsigned int done;
  unsigned char zm;
  unsigned char saved;

  if (g_txlen == 0u)
  {
    return;
  }

  zm = zm_io_active();
  if (zm != 0u)
  {
    saved = bank_push(residentPg);
  }
  else
  {
    saved = 0u;
  }

  while (g_txlen > 0u)
  {
    sent = tcpSend(g_socket, (unsigned int)g_txbuf, g_txlen, 3u);
    if (sent <= 0)
    {
      break;
    }
    done = (unsigned int)sent;
    g_tx_total += done;
    if (done >= g_txlen)
    {
      g_txlen = 0u;
      break;
    }
    memmove(g_txbuf, g_txbuf + done, g_txlen - done);
    g_txlen = (unsigned char)(g_txlen - done);
  }

  if (zm != 0u)
  {
    SETPG32KHIGH(saved);
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

static void telnet_handle_cmd(unsigned char cmd, unsigned char opt)
{
  switch (cmd)
  {
  case TN_DO:
    switch (opt)
    {
    case TN_NAWS:
      telnet_send_iac(TN_WILL, opt);
      telnet_send_naws();
      break;
    case TN_TTYPE:
      telnet_send_iac(TN_WILL, opt);
      break;
    case TN_BIN:
      g_tn_binary = 1u;
      telnet_send_iac(TN_WILL, opt);
      break;
    default:
      telnet_send_iac(TN_WONT, opt);
      break;
    }
    telnet_flush_tx();
    break;
  case TN_DONT:
    if (opt == TN_ECHO)
    {
      g_echo_remote = 0u;
    }
    else if (opt == TN_BIN)
    {
      g_tn_binary = 0u;
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
    else if (opt == TN_BIN)
    {
      g_tn_binary = 1u;
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
    else if (opt == TN_BIN)
    {
      g_tn_binary = 0u;
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

static void telnet_flush_replies(void)
{
  unsigned char before;

  before = g_txlen;
  term_drain_replies(telnet_emit_reply);
  if (g_txlen > before)
  {
    g_cpr_tx++;
    /* Synchronet may block until IAC GA after CPR even with SGA (CPR before SGA). */
    telnet_send_byte(TN_IAC);
    telnet_send_byte(TN_GA);
    g_ga_tx++;
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
    telnet_send_byte(TN_IAC);
    telnet_send_byte(TN_GA);
    g_ga_tx++;
    g_cpr_ga_debt--;
  }
  if (g_txlen > 0u)
  {
    telnet_flush_tx();
  }
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
      (void)term_feed(b);
    }
    break;

  case RX_IAC:
    if (b == TN_IAC)
    {
      g_rx_state = RX_DATA;
      (void)term_feed(TN_IAC);
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

static void telnet_zm_tx(unsigned char b)
{
  telnet_send_byte(b);
  if (b == TN_IAC)
  {
    telnet_send_byte(TN_IAC);
  }
}

static void telnet_zm_flush(void)
{
  telnet_flush_tx();
}

static void telnet_zm_discard_rx(unsigned int max_reads)
{
  unsigned int i;
  int n;

  for (i = 0u; i < max_reads; i++)
  {
    n = telnet_tcp_read(g_socket);
    if (n <= 0)
    {
      break;
    }
    g_rx_total += (unsigned int)n;
  }
  g_rx_state = RX_DATA;
}

static void telnet_zm_after_common(int rc, char *ok_msg, char *fail_msg)
{
  zm_io_end();
  telnet_send_iac(TN_WONT, TN_BIN);
  telnet_send_iac(TN_DONT, TN_BIN);
  telnet_flush_tx();
  g_tn_binary = 0u;
  telnet_zm_discard_rx(512u);

  zm_status_line(rc == OK ? ok_msg : fail_msg);
  telnet_zm_discard_rx(16u);
  zm_status_clear();
  telnet_zm_discard_rx(128u);
  telnet_drain_keys(1u);
}

static void telnet_zm_bin_prep(void)
{
  unsigned int i;

  telnet_send_iac(TN_WILL, TN_BIN);
  telnet_send_iac(TN_DO, TN_BIN);
  telnet_flush_tx();

  for (i = 0u; i < 256u; i++)
  {
    if (telnet_poll_rx() < 0)
    {
      break;
    }
    YIELD();
  }

  g_rx_state = RX_DATA;
}

static void telnet_start_xfer(unsigned char kind)
{
  unsigned char saved;
  int rc;
  char *ok_msg;
  char *fail_msg;

  if (g_dataPg == 0u)
  {
    zm_status_line("ZMODEM: no data page");
    return;
  }

  if (kind == XFER_XRECV && getpathname("") == 0)
  {
    zm_status_clear();
    return;
  }

  switch (kind)
  {
  case XFER_ZSEND:
    zm_status_line("ZMODEM send: name file, run rz on host");
    ok_msg = "ZMODEM send OK";
    fail_msg = "ZMODEM send failed";
    break;
  case XFER_ZRECV:
    zm_status_line("ZMODEM: F6 ok, run sz on host...");
    ok_msg = "ZMODEM OK";
    fail_msg = "ZMODEM failed";
    break;
  case XFER_YRECV:
    zm_status_line("YMODEM: sb -g file, then F7 (large: F6+sz)");
    ok_msg = "YMODEM OK";
    fail_msg = "YMODEM failed";
    break;
  default:
    zm_status_line("XMODEM: sx on host, waiting...");
    ok_msg = "XMODEM OK";
    fail_msg = "XMODEM failed";
    break;
  }

  /* Negotiate BINARY and drain host data while resident is still mapped. */
  telnet_zm_bin_prep();
  if (kind >= XFER_YRECV)
  {
    telnet_zm_discard_rx(512u);
  }

  saved = bank_push(g_dataPg);
  zm_io_begin(telnet_zm_tx, telnet_poll_rx, telnet_zm_flush);
  if (kind < XFER_YRECV)
  {
    zm_io_drain_input();
  }

  if (kind == XFER_ZSEND)
  {
    rc = zmodem_session_send();
  }
  else if (kind == XFER_ZRECV)
  {
    rc = zmodem_session_receive();
  }
  else if (kind == XFER_YRECV)
  {
    rc = ymodem_session_receive();
  }
  else
  {
    rc = xmodem_session_receive();
  }

  SETPG32KHIGH(saved);
  telnet_zm_after_common(rc, ok_msg, fail_msg);
}

static void telnet_zm_feed_chunk(unsigned char *buf, unsigned int n)
{
  unsigned int i;
  unsigned int out;

  i = 0u;
  out = 0u;
  while (i < n)
  {
    switch (g_rx_state)
    {
    case RX_DATA:
      if (buf[i] == TN_IAC)
      {
        g_rx_state = RX_IAC;
        i++;
      }
      else
      {
        buf[out++] = buf[i++];
      }
      break;

    case RX_IAC:
      g_rx_state = RX_DATA;
      if (buf[i] == TN_IAC)
      {
        buf[out++] = TN_IAC;
      }
      i++;
      break;

    default:
      g_rx_state = RX_DATA;
      i++;
      break;
    }
  }
  if (out > 0u)
  {
    zm_io_nb_supply(out);
  }
}

static int telnet_poll_rx(void)
{
  unsigned int i;
  int n;
  unsigned char zm;
  unsigned char saved;

  zm = zm_io_active();
  if (zm != 0u && zm_io_nb_pending() != 0u)
  {
    return 1;
  }

  if (zm != 0u)
  {
    saved = bank_push(residentPg);
    n = telnet_tcp_read(g_socket);
    SETPG32KHIGH(saved);
  }
  else
  {
    n = telnet_tcp_read(g_socket);
  }

  if (n < 0)
  {
    g_sock_err = (unsigned char)(-n);
    return -1;
  }
  if (n == 0)
  {
    return 0;
  }
  g_rx_total += (unsigned int)n;
  g_idle_loops = 0ul;
  if (zm != 0u)
  {
    telnet_zm_feed_chunk(netbuf, (unsigned int)n);
  }
  else
  {
    term_cursor_hold_or(TERM_CURS_HOLD_RX);
    i = 0u;
    while (i < (unsigned int)n)
    {
      unsigned int start;

      if (g_rx_state != RX_DATA)
      {
        telnet_process(netbuf[i]);
        i++;
        continue;
      }
      start = i;
      while (i < (unsigned int)n && netbuf[i] != TN_IAC)
      {
        i++;
      }
      if (i > start)
      {
        (void)term_feed_buf(netbuf + start, i - start);
      }
      if (i < (unsigned int)n)
      {
        telnet_process(netbuf[i]);
        i++;
      }
    }
    if (term_has_replies() != 0u)
    {
      telnet_flush_replies();
    }
    term_cursor_hold_and_not(TERM_CURS_HOLD_RX);
  }
  if (g_txlen > 0u)
  {
    telnet_flush_tx();
  }
  return 1;
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
  printf("RX:%u TX:%u cpr:%u ga:%u sga:%u bin:%u echo:%s err:%u ",
         g_rx_total,
         g_tx_total,
         g_cpr_tx,
         g_ga_tx,
         (unsigned int)g_tn_sga,
         (unsigned int)g_tn_binary,
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

static void telnet_ui_redraw(void)
{
  term_set_ansi_palette();
  term_cursor_hide();
  if (g_wait_hint != 0u)
  {
    OS_SETXY(0u, 0u);
    OS_SETCOLOR(0x4Eu);
    printf("Connected. Waiting for host data... (retry if BBS busy)");
    OS_SETCOLOR(0x07u);
  }
  term_focus_redraw();
  telnet_status_draw();
}

static void telnet_drain_keys(unsigned char do_redraw)
{
  unsigned char key;

  for (;;)
  {
    key = (unsigned char)(OS_GETKEY() & 0xFFL);
    if (key == 0u)
    {
      break;
    }
    if (key == KEY_REDRAW && do_redraw != 0u)
    {
      telnet_ui_redraw();
    }
    YIELD();
  }
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
    break;
  default:
    if ((key >= 1u && key < 127u)
        || (term_wire_is_cp866() != 0u && key >= 0x80u))
    {
      telnet_send_byte(key);
    }
    break;
  }
  telnet_flush_tx();
}

static void telnet_send_arrow(unsigned char key)
{
  unsigned char ch;

  if (key == KEY_LEFT)
  {
    ch = 'D';
  }
  else if (key == KEY_RIGHT)
  {
    ch = 'C';
  }
  else if (key == KEY_UP)
  {
    ch = 'A';
  }
  else if (key == KEY_DOWN)
  {
    ch = 'B';
  }
  else
  {
    return;
  }
  telnet_send_byte(27u);
  telnet_send_byte('[');
  telnet_send_byte(ch);
  telnet_flush_tx();
}

int telnet_session(const char *host, unsigned int port, unsigned char debug, unsigned char cp866)
{
  unsigned int cur_port;
  unsigned char cur_debug;
  unsigned char cur_cp866;
  unsigned char running;
  unsigned char user_quit;
  unsigned char do_reconnect;
  unsigned char kick;
  int poll_rc;

  strncpy(g_cur_host, host, sizeof(g_cur_host) - 1u);
  g_cur_host[sizeof(g_cur_host) - 1u] = 0;
  cur_port = port;
  cur_debug = debug;
  cur_cp866 = cp866;

  for (;;)
  {
    g_socket = -1;
    g_rx_state = RX_DATA;
    g_sb_opt = 0u;
    g_txlen = 0u;
    /* BBS echo typed chars; never mirror locally (avoids doubled letters). */
    g_echo_remote = 1u;
    g_debug = cur_debug;
    g_sock_err = 0u;
    g_tn_sga = 0u;
    g_tn_binary = 0u;
    g_cpr_ga_debt = 0u;
    g_wait_hint = 0u;
    g_rx_total = 0u;
    g_tx_total = 0u;
    g_cpr_tx = 0u;
    g_ga_tx = 0u;
    g_idle_loops = 0ul;

    r_show_connecting(g_cur_host, cur_port);
    if (!net_resolve_host(g_cur_host))
    {
      r_show_net_error("DNS failed");
      return 0;
    }
    g_socket = net_connect_tcp(cur_port, 5u);
    if (g_socket < 0)
    {
      r_show_net_error("connect failed");
      return 0;
    }

    r_telnet_display_prep(cur_cp866);

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
    do_reconnect = 0u;
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
      if (term_take_ed2_needs_cr() != 0u && zm_io_active() == 0u)
      {
        telnet_send_byte(13u);
        telnet_flush_tx();
        continue;
      }
      if (poll_rc == 0)
      {
        g_idle_loops++;
        term_cursor_show();
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
        if (key == KEY_REDRAW)
        {
          telnet_ui_redraw();
        }
        else if (key == KEY_F10)
        {
          running = 0u;
          user_quit = 1u;
        }
        else if (key == KEY_F2)
        {
          unsigned int book_port;
          unsigned char book_cp866;
          unsigned char book_debug;

          book_cp866 = cur_cp866;
          book_debug = cur_debug;

          telnet_flush_tx();
          term_palette_restore();
          netShutDown(g_socket, 0u);
          g_socket = -1;
          telnet_drain_keys(0u);

          if (r_telbook_run(g_cur_host, sizeof(g_cur_host), &book_port, &book_cp866, &book_debug))
          {
            cur_port = book_port;
            cur_cp866 = book_cp866;
            cur_debug = book_debug;
          }
          do_reconnect = 1u;
          running = 0u;
        }
        else if (key == KEY_F5)
        {
          telnet_start_xfer(XFER_ZSEND);
        }
        else if (key == KEY_F6)
        {
          telnet_start_xfer(XFER_ZRECV);
        }
        else if (key == KEY_F7)
        {
          telnet_start_xfer(XFER_YRECV);
        }
        else if (key == KEY_F8)
        {
          telnet_start_xfer(XFER_XRECV);
        }
        else if (key == 27)
        {
          telnet_send_byte(27u);
          telnet_flush_tx();
        }
        else if (key == KEY_LEFT || key == KEY_RIGHT || key == KEY_UP || key == KEY_DOWN)
        {
          telnet_send_arrow(key);
        }
        else
        {
          telnet_send_key(key);
        }
      }
      else
      {
        YIELD();
      }
    }

    telnet_flush_tx();
    if (g_socket >= 0)
    {
      netShutDown(g_socket, 0u);
      g_socket = -1;
    }
    if (do_reconnect != 0u)
    {
      continue;
    }
    term_palette_restore();
    r_show_session_end(user_quit, g_sock_err, g_rx_total);
    return 1;
  }
}
