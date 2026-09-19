/*
 * svnesp.com - SVN client (ra_svn / svnserve) for NedoOS.
 * ZXNETUSB / ESP-COM / ESPNET, port 3690, no SSL.
 */
#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <ctype.h>
#include <oscalls.h>
#include <tcp.h>
#include <osfs.h>
#include "crc32.h"

#define true 1
#define false 0
#define SVN_PORT 3690
#define NETBUF_BYTES 5120
#define RA_BUF_SIZE 2048
#define RA_OUT_SIZE 512
#define RA_FILE_IO 8000
#define RA_CHUNK_MAX 65536
#define RA_FILL_MAX 2000
#define PROG_DOT_BYTES 16384UL

static unsigned long prog_bytes;
static unsigned long prog_next;

static void prog_start(const char *name)
{
	printf("%s.", name);
	prog_bytes = 0;
	prog_next = PROG_DOT_BYTES;
}

static void prog_add(unsigned int n)
{
	prog_bytes += n;
	while (prog_bytes >= prog_next)
	{
		putchar('.');
		prog_next += PROG_DOT_BYTES;
	}
}

static void prog_end(void)
{
	printf("\r\n");
}

unsigned int RBR_THR = 0xf8ef;
unsigned int IER = 0xf9ef;
unsigned int IIR_FCR = 0xfaef;
unsigned int LCR = 0xfbef;
unsigned int MCR = 0xfcef;
unsigned int LSR = 0xfdef;
unsigned int MSR = 0xfeef;
unsigned int SR = 0xffef;
unsigned int divider = 1;
unsigned int comType = 0;
unsigned int espType = 32;
static unsigned int netDriver = 0;
unsigned int espRetry = 5;
unsigned long factor, timerok, count = 0;
unsigned int magic = 15;

static unsigned char curPath[128];
static unsigned char forceEsp = 0;
static unsigned char forceUpd = 0;
static unsigned char useCrc = 0;
static unsigned char verbose = 0;
unsigned char debugRa = 0;
static unsigned char excludePath[128];
static unsigned char exclude_buf[1024];
static unsigned char exclude_loaded = 0;
static unsigned int revEnd = 0;
unsigned int revStart = 0;
static unsigned int svnPort = SVN_PORT;

static unsigned char netbuf[NETBUF_BYTES];
static unsigned char ra_txbuf[512];
static unsigned char cmd[256];
static unsigned char svnHost[64];
static unsigned char greetingUrl[96];
static unsigned char svnPath[128];
static unsigned char localBase[128];
static unsigned char tmpPath[128];
static unsigned char upd_q_path[128];

static unsigned char ra_buf[RA_BUF_SIZE];
static unsigned char ra_out[RA_OUT_SIZE];
static unsigned char ra_token[] = "YW5vbnltb3VzQE5lZG9PUw==";
static const char ra_agent[] = "SVN/1.14.1 (x86_64-pc-linux-gnu)";
static unsigned char ra_diag = 0;
static char ra_last_cmd[192];
static char ra_list_line[192];
static char ra_list_name[64];
static char ra_list_date[20];
static char ra_get_line[192];
static unsigned char ra_file_buf[RA_FILE_IO];
static unsigned int ra_file_pos;
static unsigned char ra_pb;
static unsigned char ra_pb_ok;

static void path_basename(const char *path, char *name);
static unsigned char str_ieq(const char *a, const char *b);

#define PATH_MAXN 127
static unsigned char dstk_path[128];
static unsigned int dstk_n;
static FILE *dstk_fp;

static void path_copy_n(char *dst, const char *src, unsigned int max)
{
	unsigned int n = 0;

	if (max == 0)
		return;
	max--;
	while (src[n] && n < max)
	{
		dst[n] = src[n];
		n++;
	}
	dst[n] = 0;
}

static void path_copy(char *dst, const char *src)
{
	path_copy_n(dst, src, PATH_MAXN + 1);
}

static void join_path(char *dst, const char *base, const char *name)
{
	unsigned int n = 0;

	while (base[n] && n < PATH_MAXN)
	{
		dst[n] = base[n];
		n++;
	}
	if (n > 0 && dst[n - 1] != '/' && n < PATH_MAXN)
		dst[n++] = '/';
	while (*name && n < PATH_MAXN)
		dst[n++] = *name++;
	dst[n] = 0;
}

static struct sockaddr_in targetadr;
static struct readstructure readStruct;
static struct sockaddr_in dnsaddress;

static signed char svnSocket = -1;
static unsigned char svn_sess_open = 0;
static unsigned int esp_ra_pos;
static unsigned int esp_ra_len;
static unsigned int ra_rx_pos;
static unsigned int ra_rx_len;

static unsigned char args_ok = 1;
static unsigned int dbg_skip = 0;

static void ra_tcp_close(void);

static const unsigned char gotWiFi[] = "WIFI GOT IP";

static char subcmd[8];

static void fatal(const char *msg)
{
	printf("%s\r\n", msg);
	ra_tcp_close();
}

static void clearStatus(void)
{
	putchar('\r');
}

static void clearNetBuf(unsigned int size)
{
	unsigned int i;
	if (size > NETBUF_BYTES)
		size = NETBUF_BYTES;
	for (i = 0; i < size; i++)
		netbuf[i] = 0;
}

#include <../common/esp-com.c>
#include <../common/network.c>
#define ESPNET_CLIENT_ONLY 1
#include <../common/espnet.c>
#include <../common/espnet-net.c>

#define DBG_FD_MAX 6

static unsigned int dbg_nfile = 0;
static unsigned int dbg_nfile_max = 0;
static unsigned int dbg_nsock = 0;
static unsigned int dbg_nsock_max = 0;
static unsigned int dbg_filen = 0;

static unsigned char fs_hok(FILE *fp)
{
	return (((int)fp) & 0xff) == 0;
}

/* Handles are encoded with low byte 0, so NULL also looks "ok" to fs_hok. */
static unsigned char fs_isopen(FILE *fp)
{
	return fp != 0 && fs_hok(fp);
}

static unsigned int fs_hid(FILE *fp)
{
	return ((unsigned int)fp) >> 8;
}

static FILE *fs_create(unsigned char *path)
{
	FILE *fp;

	fp = OS_CREATEHANDLE(path, 0x80);
	if (fs_hok(fp))
	{
		dbg_nfile++;
		if (dbg_nfile > dbg_nfile_max)
			dbg_nfile_max = dbg_nfile;
		if (dbg_nfile > DBG_FD_MAX)
			printf("FD OVER %u h=%u %s\r\n", dbg_nfile, fs_hid(fp), path);
	}
	return fp;
}

static FILE *fs_open(unsigned char *path)
{
	FILE *fp;

	fp = OS_OPENHANDLE(path, 0x80);
	if (fs_hok(fp))
	{
		dbg_nfile++;
		if (dbg_nfile > dbg_nfile_max)
			dbg_nfile_max = dbg_nfile;
		if (dbg_nfile > DBG_FD_MAX)
			printf("FD OVER %u h=%u %s\r\n", dbg_nfile, fs_hid(fp), path);
	}
	return fp;
}

static void fs_close(FILE *fp)
{
	if (!fp)
		return;
	if (fs_hok(fp))
	{
		if (dbg_nfile > 0)
			dbg_nfile--;
	}
	OS_CLOSEHANDLE(fp);
}

static void dbg_sock_open(signed char s)
{
	if (s >= 0)
	{
		dbg_nsock++;
		if (dbg_nsock > dbg_nsock_max)
			dbg_nsock_max = dbg_nsock;
		if (dbg_nsock > 2)
			printf("SOCK OVER %u s=%d\r\n", dbg_nsock, s);
	}
}

static void dbg_sock_close(signed char s)
{
	if (s >= 0 && dbg_nsock > 0)
		dbg_nsock--;
}

/* --- TCP transport for ra_svn --- */

static void ra_rx_discard(void)
{
	ra_rx_pos = 0;
	ra_rx_len = 0;
	esp_ra_pos = 0;
	esp_ra_len = 0;
}

static unsigned char ra_wiz_refill(void)
{
	unsigned int todo;
	unsigned int left;
	unsigned int i;
	unsigned char err;
	unsigned int stall = 0;

	left = 0;
	if (ra_rx_pos < ra_rx_len && ra_rx_len <= NETBUF_BYTES)
	{
		left = ra_rx_len - ra_rx_pos;
		if (left > NETBUF_BYTES)
			left = 0;
		for (i = 0; i < left; i++)
			netbuf[i] = netbuf[ra_rx_pos + i];
	}
	else
	{
		ra_rx_pos = 0;
		ra_rx_len = 0;
	}

	for (;;)
	{
		readStruct.socket = svnSocket;
		readStruct.BufAdr = (unsigned int)(netbuf + left);
		readStruct.bufsize = NETBUF_BYTES - left;
		readStruct.protocol = SOCK_STREAM;
		todo = (netDriver == 2) ? OS_ESPREAD(&readStruct) : OS_WIZNETREAD(&readStruct);
		if (OS_CALL_OK(todo))
		{
			if (todo > 0)
			{
				ra_rx_pos = 0;
				ra_rx_len = left + (unsigned int)todo;
				return 1;
			}
			stall++;
			if (stall > RA_FILL_MAX)
				return 0;
			YIELD();
			continue;
		}
		err = OS_CALL_ERR(todo);
		if (err == ERR_EAGAIN)
		{
			stall++;
			if (stall > RA_FILL_MAX)
				return 0;
			YIELD();
			continue;
		}
		return 0;
	}
}

static unsigned char ra_wiz_try_byte(unsigned char *byte)
{
	if (svnSocket < 0)
		return 0;
	if (ra_rx_pos >= ra_rx_len)
		return 0;
	*byte = netbuf[ra_rx_pos++];
	return 1;
}

static unsigned char ra_esp_try_byte(unsigned char *byte)
{
	if (esp_ra_pos >= esp_ra_len)
		return 0;
	*byte = netbuf[esp_ra_pos++];
	return 1;
}

static unsigned char ra_wiz_recv_byte(unsigned char *byte)
{
	if (svnSocket < 0)
		return 0;
	if (ra_rx_pos >= ra_rx_len)
	{
		if (!ra_wiz_refill())
			return 0;
	}
	*byte = netbuf[ra_rx_pos++];
	return 1;
}

static unsigned char ra_esp_fill(void)
{
	int todo;
	if (esp_ra_pos < esp_ra_len)
		return 1;
	esp_ra_pos = 0;
	esp_ra_len = 0;
	clearNetBuf(255);
	todo = recvHead();
	if (todo == 0)
		return 0;
	if (!getdataEsp(todo))
		return 0;
	esp_ra_len = todo;
	return 1;
}

static unsigned char ra_esp_recv_byte(unsigned char *byte)
{
	if (!ra_esp_fill())
		return 0;
	*byte = netbuf[esp_ra_pos++];
	return 1;
}

static unsigned char ra_tcp_send(const unsigned char *data, unsigned int len)
{
	unsigned int todo;
	unsigned int i;
	unsigned int sent;
	unsigned char err;

	if (len == 0)
		return 1;
	if (len > NETBUF_BYTES)
		return 0;

	switch (netDriver)
	{
	case 0:
	case 2:
		if (svnSocket < 0)
			return 0;
		/* Wiznet/ESPNET is a TCP stream: never flush RX before TX. */
		memcpy(ra_txbuf, data, len);
		sent = 0;
		while (sent < len)
		{
			readStruct.socket = svnSocket;
			readStruct.BufAdr = (unsigned int)(ra_txbuf + sent);
			readStruct.bufsize = len - sent;
			readStruct.protocol = SOCK_STREAM;
			todo = (netDriver == 2) ? OS_ESPWRITE(&readStruct) : OS_WIZNETWRITE(&readStruct);
			if (OS_CALL_OK(todo) && todo > 0)
			{
				sent += todo;
				continue;
			}
			err = OS_CALL_ERR(todo);
			if (err == ERR_EAGAIN || err == ERR_EMSGSIZE)
			{
				YIELD();
				continue;
			}
			return 0;
		}
		return 1;
	case 1:
		sprintf(cmd, "AT+CIPSEND=%u", len);
		ra_rx_discard();
		sendcommand(cmd);
		for (i = 0; i < 200; i++)
		{
			if (uartReadBlock() == '>')
				break;
		}
		for (i = 0; i < len; i++)
			uart_write(data[i]);
		ra_rx_discard();
		return 1;
	default:
		return 0;
	}
}

static unsigned char ra_tcp_recv_byte(unsigned char *byte)
{
	if (netDriver != 1)
		return ra_wiz_recv_byte(byte);
	return ra_esp_recv_byte(byte);
}

static unsigned char ra_tcp_try_byte(unsigned char *byte)
{
	if (netDriver != 1)
		return ra_wiz_try_byte(byte);
	return ra_esp_try_byte(byte);
}

static unsigned char ra_tcp_connect(const char *host)
{
	int todo;
	unsigned char attempt;
	static unsigned char dns_ok = 0;

	ra_rx_pos = 0;
	ra_rx_len = 0;
	esp_ra_pos = 0;
	esp_ra_len = 0;

	for (attempt = 0; attempt < 3; attempt++)
	{
		if (netDriver == 0)
		{
			if (!dns_ok)
			{
				if (!dnsResolve(host))
				{
					delayLong(100);
					continue;
				}
				dns_ok = 1;
			}
			targetadr.portl = (unsigned char)(svnPort & 255);
			targetadr.porth = (unsigned char)((svnPort >> 8) & 255);
			svnSocket = OpenSock(AF_INET, SOCK_STREAM);
			if (svnSocket < 0)
			{
				delayLong(100);
				continue;
			}
			dbg_sock_open(svnSocket);
			todo = netConnect(svnSocket, 5);
			if (todo < 0)
			{
				dbg_sock_close(svnSocket);
				netShutDown(svnSocket, 0);
				svnSocket = -1;
				dns_ok = 0;
				delayLong(100);
				continue;
			}
			delayLong(50);
			return 1;
		}
		if (netDriver == 2)
		{
			if (!dns_ok)
			{
				if (!EspDnsResolve(host))
				{
					delayLong(100);
					continue;
				}
				dns_ok = 1;
			}
			targetadr.portl = (unsigned char)(svnPort & 255);
			targetadr.porth = (unsigned char)((svnPort >> 8) & 255);
			svnSocket = (signed char)EspOpenSock(AF_INET, SOCK_STREAM);
			if (svnSocket < 0)
			{
				delayLong(100);
				continue;
			}
			dbg_sock_open(svnSocket);
			todo = EspConnect(svnSocket);
			if (todo < 0)
			{
				dbg_sock_close(svnSocket);
				EspShutDown(svnSocket, 0);
				svnSocket = -1;
				dns_ok = 0;
				delayLong(100);
				continue;
			}
			delayLong(50);
			return 1;
		}
		sprintf(cmd, "AT+CIPSTART=\"TCP\",\"%s\",%u", host, svnPort);
		sendcommand(cmd);
		if (!getAnswer3())
		{
			delayLong(100);
			continue;
		}
		if (strstr(netbuf, "CONNECT") == 0)
		{
			delayLong(100);
			continue;
		}
		esp_ra_pos = 0;
		esp_ra_len = 0;
		return 1;
	}
	return 0;
}

static void ra_tcp_close(void)
{
	svn_sess_open = 0;
	ra_rx_pos = 0;
	ra_rx_len = 0;
	esp_ra_pos = 0;
	esp_ra_len = 0;
	ra_pb_ok = 0;
	if (netDriver == 0)
	{
		if (svnSocket < 0)
			return;
		dbg_sock_close(svnSocket);
		netShutDown(svnSocket, 0);
		svnSocket = -1;
	}
	else if (netDriver == 2)
	{
		if (svnSocket < 0)
			return;
		dbg_sock_close(svnSocket);
		EspShutDown(svnSocket, 0);
		svnSocket = -1;
	}
	else
	{
		sendcommand("AT+CIPCLOSE");
	}
}

/* --- ra_svn protocol --- */

static unsigned char ra_get_byte(unsigned char *c)
{
	if (ra_pb_ok)
	{
		*c = ra_pb;
		ra_pb_ok = 0;
		return 1;
	}
	return ra_tcp_recv_byte(c);
}

static unsigned char ra_try_byte(unsigned char *c)
{
	if (ra_pb_ok)
	{
		*c = ra_pb;
		ra_pb_ok = 0;
		return 1;
	}
	return ra_tcp_try_byte(c);
}

static unsigned char ra_svn_get_diag(void)
{
	return ra_diag;
}

static const char *ra_svn_last_cmd(void)
{
	return ra_last_cmd;
}

static const char *ra_svn_get_message(void)
{
	return (char *)ra_buf;
}

static void ra_copy_cmd(const char *cmdline)
{
	unsigned int i;

	for (i = 0; i < 191 && cmdline[i]; i++)
		ra_last_cmd[i] = cmdline[i];
	ra_last_cmd[i] = 0;
}

static void ra_send_raw(const char *msg)
{
	if (!ra_tcp_send((const unsigned char *)msg, strlen(msg)))
		ra_diag = 5;
}

static void ra_trim_buf(void)
{
	unsigned int len;

	len = (unsigned int)strlen((char *)ra_buf);
	while (len > 0 && (ra_buf[len - 1] == ' ' || ra_buf[len - 1] == '\r' ||
					   ra_buf[len - 1] == '\n'))
	{
		len--;
		ra_buf[len] = 0;
	}
}

static unsigned char ra_read_message(void)
{
	unsigned int i = 0;
	unsigned int depth = 0;
	unsigned char c;
	unsigned char started = 0;
	unsigned int str_left = 0;

	while (i < RA_BUF_SIZE - 1)
	{
		if (!ra_get_byte(&c))
			return 0;
		if (!started && str_left == 0 &&
			(c == ' ' || c == '\n' || c == '\r' || c == '\t'))
			continue;

		if (str_left > 0)
		{
			/* Discard bytes that would not fit; never write past ra_buf. */
			if (i < RA_BUF_SIZE - 1)
				ra_buf[i++] = c;
			str_left--;
			continue;
		}

		if (i >= RA_BUF_SIZE - 1)
			return 0;
		ra_buf[i++] = c;

		if (c >= '0' && c <= '9')
		{
			unsigned int len = (unsigned int)(c - '0');
			unsigned char c2 = 0;

			while (i < RA_BUF_SIZE - 1)
			{
				if (!ra_get_byte(&c2))
					return 0;
				ra_buf[i++] = c2;
				if (c2 >= '0' && c2 <= '9')
				{
					if (len > 6553)
						len = 65535;
					else
						len = len * 10 + (unsigned int)(c2 - '0');
				}
				else
					break;
			}
			if (c2 == ':')
			{
				str_left = len;
				continue;
			}
		}

		if (c == '(')
		{
			depth++;
			started = 1;
		}
		else if (c == ')')
		{
			if (depth > 0)
				depth--;
			if (started && depth == 0)
			{
				if (ra_try_byte(&c))
				{
					if (c == ' ' || c == '\n' || c == '\r' || c == '\t')
					{
						if (i < RA_BUF_SIZE - 1)
							ra_buf[i++] = c;
					}
					else
					{
						ra_pb = c;
						ra_pb_ok = 1;
					}
				}
				ra_buf[i] = 0;
				ra_trim_buf();
				return 1;
			}
		}
	}
	ra_buf[RA_BUF_SIZE - 1] = 0;
	return 0;
}

static unsigned char ra_is_success(void)
{
	ra_trim_buf();
	return strstr((char *)ra_buf, "( success") != 0;
}

static unsigned char ra_is_failure(void)
{
	return strstr((char *)ra_buf, "( failure") != 0;
}

static unsigned char ra_copy_to_file(FILE *fp, unsigned int n);
static unsigned char ra_copy_to_file_esp(FILE *fp, unsigned int n);

static void ra_file_wr_reset(void)
{
	ra_file_pos = 0;
}

static unsigned char ra_file_wr_flush(FILE *fp)
{
	if (ra_file_pos == 0)
		return 1;
	if (OS_WRITEHANDLE(ra_file_buf, fp, ra_file_pos) != ra_file_pos)
		return 0;
	ra_file_pos = 0;
	return 1;
}

static unsigned char ra_file_wr_put(FILE *fp, const unsigned char *data, unsigned int n)
{
	unsigned int take;
	unsigned int space;

	while (n > 0)
	{
		space = RA_FILE_IO - ra_file_pos;
		take = n;
		if (take > space)
			take = space;
		memcpy(ra_file_buf + ra_file_pos, data, take);
		ra_file_pos += take;
		data += take;
		n -= take;
		if (ra_file_pos >= RA_FILE_IO)
		{
			if (!ra_file_wr_flush(fp))
				return 0;
		}
	}
	return 1;
}

static unsigned char ra_copy_to_file(FILE *fp, unsigned int n)
{
	unsigned int avail;
	unsigned int take;

	while (n > 0)
	{
		if (ra_rx_pos >= ra_rx_len)
		{
			if (!ra_wiz_refill())
				return 0;
		}
		avail = ra_rx_len - ra_rx_pos;
		take = n;
		if (take > avail)
			take = avail;
		if (!ra_file_wr_put(fp, netbuf + ra_rx_pos, take))
			return 0;
		ra_rx_pos += take;
		n -= take;
		prog_add(take);
	}
	return 1;
}

static unsigned char ra_copy_to_file_esp(FILE *fp, unsigned int n)
{
	unsigned int avail;
	unsigned int take;

	while (n > 0)
	{
		if (esp_ra_pos >= esp_ra_len)
		{
			if (!ra_esp_fill())
				return 0;
		}
		avail = esp_ra_len - esp_ra_pos;
		take = n;
		if (take > avail)
			take = avail;
		if (!ra_file_wr_put(fp, netbuf + esp_ra_pos, take))
			return 0;
		esp_ra_pos += take;
		n -= take;
		prog_add(take);
	}
	return 1;
}

static unsigned char ra_read_svn_chunk(FILE *fp, unsigned int *out_len)
{
	unsigned long count = 0;
	unsigned int n;
	unsigned char c;
	unsigned char started = 0;

	*out_len = 0;
	while (1)
	{
		if (!ra_get_byte(&c))
			return 0;
		if (c == ' ' || c == '\n' || c == '\r' || c == '\t')
			continue;
		if (c == '(')
		{
			ra_pb = c;
			ra_pb_ok = 1;
			return 1;
		}
		if (c >= '0' && c <= '9')
		{
			count = (unsigned long)(c - '0');
			started = 1;
			break;
		}
		return 0;
	}
	while (started)
	{
		if (!ra_get_byte(&c))
			return 0;
		if (c == ':')
			break;
		if (c < '0' || c > '9')
			return 0;
		count = count * 10 + (unsigned long)(c - '0');
		if (count > RA_CHUNK_MAX)
			return 0;
	}
	if (count == 0)
	{
		if (!ra_get_byte(&c))
			return 0;
		if (c != ' ' && c != '\n' && c != '\r' && c != '\t')
		{
			ra_pb = c;
			ra_pb_ok = 1;
		}
		return 1;
	}
	while (count > 0)
	{
		n = (count > 65535UL) ? 65535U : (unsigned int)count;
		if (netDriver == 1)
		{
			if (!ra_copy_to_file_esp(fp, n))
				return 0;
		}
		else
		{
			if (!ra_copy_to_file(fp, n))
				return 0;
		}
		*out_len += n;
		count -= n;
	}
	/* One optional whitespace after the string. Do not eat the next
	 * length digit or the '(' of the following tuple. */
	if (!ra_get_byte(&c))
		return 0;
	if (c != ' ' && c != '\n' && c != '\r' && c != '\t')
	{
		ra_pb = c;
		ra_pb_ok = 1;
	}
	return 1;
}

/* 0=need repos, 1=repos already in ra_buf, 2=error */
static unsigned char ra_handle_auth_request(void)
{
	if (strstr((char *)ra_buf, "svn://") != 0)
		return 1;
	if (ra_is_failure())
	{
		ra_diag = 12;
		return 2;
	}
	if (strstr((char *)ra_buf, "ANONYMOUS") == 0 &&
		strstr((char *)ra_buf, "CRAM-MD5") == 0)
	{
		if (ra_is_success())
			return 0;
		ra_diag = 10;
		return 2;
	}
	sprintf((char *)ra_out, "( ANONYMOUS ( 24:%s ) ) ", ra_token);
	ra_send_raw((char *)ra_out);
	if (ra_diag == 5)
		return 2;
	if (!ra_read_message())
	{
		ra_diag = 11;
		return 2;
	}
	if (ra_is_failure())
	{
		ra_diag = 12;
		return 2;
	}
	return 0;
}

static unsigned char ra_cmd_preamble(const char *cmdline)
{
	unsigned char auth;

	ra_copy_cmd(cmdline);
	ra_send_raw(cmdline);
	if (ra_diag == 5)
		return 0;
	if (!ra_read_message())
	{
		ra_diag = 20;
		if (debugRa)
			printf("dbg cmd fail (%u): %s\r\n", ra_diag, ra_last_cmd);
		return 0;
	}
	auth = ra_handle_auth_request();
	if (auth == 2)
		return 0;
	if (auth == 0 && strstr((char *)ra_buf, "svn://") == 0 &&
		strstr((char *)ra_buf, "( success") == 0)
	{
		if (!ra_read_message())
		{
			ra_diag = 21;
			return 0;
		}
	}
	return 1;
}

static unsigned long ra_parse_rev_from_success(void)
{
	const char *p;
	unsigned long rev = 0;

	p = strstr((char *)ra_buf, "( success ( ");
	if (p == 0)
		p = strstr((char *)ra_buf, "( success (");
	if (p == 0)
		return 0;
	p = strchr(p, '(');
	while (p && *p != 0)
	{
		p++;
		while (*p == ' ')
			p++;
		if (*p >= '0' && *p <= '9')
		{
			rev = (unsigned long)atol(p);
			if (rev != 0)
				return rev;
		}
		p = strchr(p, '(');
	}
	return rev;
}

static unsigned char ra_svn_open(const char *greeting_url)
{
	const char *caps = "edit-pipeline svndiff1 accepts-svndiff2 absent-entries depth mergeinfo log-revprops";
	unsigned char auth;

	ra_diag = 0;
	ra_pb_ok = 0;
	if (!ra_read_message())
	{
		ra_diag = 1;
		return 0;
	}
	sprintf((char *)ra_out,
			"( 2 ( %s ) %u:%s 32:%s ( ) ) ",
			caps,
			(unsigned int)strlen(greeting_url), greeting_url,
			ra_agent);
	ra_send_raw((char *)ra_out);
	if (ra_diag == 5)
		return 0;
	if (!ra_read_message())
	{
		ra_diag = 2;
		return 0;
	}
	auth = ra_handle_auth_request();
	if (auth == 2)
		return 0;
	if (auth == 0)
	{
		if (!ra_read_message())
		{
			ra_diag = 3;
			return 0;
		}
	}
	if (!ra_is_success())
	{
		ra_diag = 4;
		return 0;
	}
	return 1;
}

static unsigned long ra_svn_get_latest_rev(void)
{
	if (!ra_cmd_preamble("( get-latest-rev ( ) ) "))
		return 0;
	if (!ra_read_message())
	{
		ra_diag = 21;
		return 0;
	}
	return ra_parse_rev_from_success();
}

static unsigned char ra_is_cmd_ack(void)
{
	const char *p;

	ra_trim_buf();
	if (strstr((char *)ra_buf, "( failure") != 0)
		return 0;
	if (strstr((char *)ra_buf, "( success ( ( ) 0: ) )") != 0)
		return 1;
	p = strstr((char *)ra_buf, "( success ( ");
	if (p == 0)
		return 0;
	p += 12;
	while (*p == ' ')
		p++;
	if (*p < '0' || *p > '9')
		return 0;
	while (*p >= '0' && *p <= '9')
		p++;
	while (*p == ' ')
		p++;
	return *p == ')';
}

static unsigned char ra_drain_getfile_tail(void)
{
	unsigned char n = 0;

	while (n < 12)
	{
		if (!ra_read_message())
			return 0;
		if (ra_is_success())
			return 1;
		if (ra_is_failure())
			return 0;
		if (ra_is_cmd_ack())
			continue;
		n++;
	}
	return 0;
}

static unsigned char ra_is_file_meta(void)
{
	ra_trim_buf();
	return strstr((char *)ra_buf, "( 32:") != 0 ||
		   strstr((char *)ra_buf, "( 16:") != 0;
}

static unsigned char ra_is_dirent_msg(void)
{
	ra_trim_buf();
	return strchr((char *)ra_buf, '/') != 0;
}

static unsigned char ra_drain_cmd_acks(void)
{
	unsigned char n = 0;

	while (ra_is_cmd_ack())
	{
		if (!ra_read_message())
			return 0;
		if (++n > 8)
			return 0;
	}
	return 1;
}

static unsigned char ra_drain_until_file_meta(void)
{
	unsigned char n = 0;

	while (!ra_is_file_meta())
	{
		if (ra_is_failure())
			return 0;
		if (!ra_read_message())
			return 0;
		if (++n > 8)
			return 0;
	}
	return ra_is_success();
}

static unsigned char ra_drain_until_dirent(void)
{
	unsigned char n = 0;

	while (!ra_is_dirent_msg() && strstr((char *)ra_buf, "done") == 0)
	{
		if (ra_is_failure())
			return 0;
		if (!ra_read_message())
			return 0;
		if (++n > 8)
			return 0;
	}
	return 1;
}

static void ra_parse_dirent(
	const char *msg,
	char *name,
	unsigned char *is_dir,
	char *date_str,
	unsigned long *size)
{
	const char *p;
	const char *slash;
	const char *q;
	unsigned int i;
	unsigned char c;

	name[0] = 0;
	date_str[0] = 0;
	*size = 0;
	*is_dir = 0;
	p = strchr(msg, '/');
	if (p == 0)
		return;
	slash = strrchr(p, '/');
	if (slash == 0)
		return;
	slash++;
	q = strstr(slash, " dir");
	if (q == 0)
		q = strstr(slash, " file");
	if (q == 0)
		return;
	i = 0;
	while (slash < q && i < 63)
		name[i++] = *slash++;
	name[i] = 0;
	*is_dir = (q[1] == 'd') ? 1 : 0;
	/* Search AFTER " file"/" dir" — strstr(msg,"20") hits names like vic20.com */
	p = q;
	while ((p = strstr(p, "20")) != 0)
	{
		if (p[2] >= '0' && p[2] <= '9' && p[3] >= '0' && p[3] <= '9' && p[4] == '-')
			break;
		p++;
	}
	if (p)
	{
		i = 0;
		while (p[i] && p[i] != ')' && p[i] != '<' && i < 19)
		{
			c = p[i];
			if (c == 'T')
				c = ' ';
			if (c == '.' || c == 'Z')
				break;
			date_str[i] = c;
			i++;
		}
		date_str[i] = 0;
	}
}

typedef void (*ra_list_fn)(const char *name, unsigned char is_dir, const char *date_str);

static unsigned char ra_svn_list(
	const char *path,
	ra_list_fn print_fn)
{
	unsigned char is_dir;
	unsigned long size;
	unsigned int item_n;

	item_n = 0;
	if ((unsigned int)strlen(path) > 100)
		return 0;
	if (revStart == 0)
		sprintf(ra_list_line, "( list ( %u:%s ( ) immediates ( kind time ) ) ) ",
				(unsigned int)strlen(path), path);
	else
		sprintf(ra_list_line, "( list ( %u:%s ( %lu ) immediates ( kind time ) ) ) ",
				(unsigned int)strlen(path), path, (unsigned long)revStart);
	if (!ra_cmd_preamble(ra_list_line))
		return 0;
	if (!ra_drain_cmd_acks())
	{
		ra_diag = 22;
		return 0;
	}
	if (!ra_drain_until_dirent())
	{
		ra_diag = 22;
		return 0;
	}
	if (ra_is_failure())
		return 0;
	while (1)
	{
		if (strstr((char *)ra_buf, "done") != 0)
			break;
		if (ra_is_failure())
			return 0;
		ra_parse_dirent((char *)ra_buf, ra_list_name, &is_dir, ra_list_date, &size);
		if (ra_list_name[0] != 0)
		{
			item_n++;
			if (print_fn)
				print_fn(ra_list_name, is_dir, ra_list_date);
		}
		if (!ra_read_message())
		{
			ra_diag = 22;
			return 0;
		}
	}
	if (strstr((char *)ra_buf, "( success") == 0)
	{
		if (!ra_read_message())
		{
			ra_diag = 22;
			return 0;
		}
	}
	if (debugRa)
		printf("dbg list raw %u\r\n", item_n);
	return 1;
}

static char ra_mtime_date[20];
static char ra_mtime_want[64];

static void ra_mtime_cb(const char *name, unsigned char is_dir, const char *date_str)
{
	if (is_dir || date_str[0] == 0 || ra_mtime_date[0])
		return;
	if (ra_mtime_want[0] && !str_ieq(name, ra_mtime_want))
		return;
	path_copy_n(ra_mtime_date, date_str, 20);
}

static unsigned char ra_svn_fetch_mtime(const char *path, char *date_out)
{
	static char parent[128];
	char *slash;

	ra_mtime_date[0] = 0;
	path_basename(path, ra_mtime_want);
	/* list(file) is unreliable — list parent and match basename */
	path_copy(parent, path);
	slash = strrchr(parent, '/');
	if (slash == 0)
		return 0;
	if (slash == parent)
		parent[1] = 0;
	else
		*slash = 0;
	if (!ra_svn_list(parent, ra_mtime_cb) || ra_mtime_date[0] == 0)
	{
		ra_mtime_want[0] = 0;
		ra_mtime_date[0] = 0;
		if (!ra_svn_list(path, ra_mtime_cb) || ra_mtime_date[0] == 0)
			return 0;
	}
	path_copy_n(date_out, ra_mtime_date, 20);
	return 1;
}

static unsigned char ra_svn_log(const char *path, unsigned long rev_start, unsigned long rev_end)
{
	static char line[192];
	static char date[24];
	const char *p;
	const char *q;
	unsigned long rev;
	unsigned int plen;

	plen = (unsigned int)strlen(path);
	if (plen > 80)
		return 0;
	if (rev_end != 0 && rev_end != rev_start)
		sprintf(line,
				"( log ( ( 0: ) ( %u:%s ) ( %lu:%lu ) false false 0 false revprops ( 10:svn:author 8:svn:date 7:svn:log ) ) ) ) ",
				plen, path, rev_start, rev_end);
	else if (rev_start != 0)
		sprintf(line,
				"( log ( ( 0: ) ( %u:%s ) ( %lu ) false false 0 false revprops ( 10:svn:author 8:svn:date 7:svn:log ) ) ) ) ",
				plen, path, rev_start);
	else
		sprintf(line,
				"( log ( ( 0: ) ( %u:%s ) ( 0: ) false false 0 false revprops ( 10:svn:author 8:svn:date 7:svn:log ) ) ) ) ",
				plen, path);

	if (!ra_cmd_preamble(line))
		return 0;
	while (1)
	{
		if (!ra_read_message())
			break;
		if (strstr((char *)ra_buf, "done") != 0)
			break;
		p = strstr((char *)ra_buf, "( ( ");
		if (p == 0)
			continue;
		rev = 0;
		q = p;
		while (*q && *q != '|' && *q != ')')
		{
			if (*q >= '0' && *q <= '9')
				rev = rev * 10 + (*q - '0');
			q++;
		}
		date[0] = 0;
		p = strstr((char *)ra_buf, "20");
		if (p)
		{
			unsigned int i = 0;
			while (p[i] && p[i] != ')' && i < 19)
			{
				date[i] = p[i];
				i++;
			}
			date[i] = 0;
		}
		printf("r%lu  %s\r\n", rev, date);
	}
	return 1;
}

static unsigned char ra_svn_get_file(
	const char *path,
	const char *local_path)
{
	unsigned int chunk_len;
	unsigned long total_len;
	FILE *fp;

	ra_diag = 0;
	if ((unsigned int)strlen(path) > 100)
		return 0;
	if (revStart == 0)
		sprintf(ra_get_line, "( get-file ( %u:%s ( ) false true false ) ) ",
				(unsigned int)strlen(path), path);
	else
		sprintf(ra_get_line, "( get-file ( %u:%s ( %lu ) false true false ) ) ",
				(unsigned int)strlen(path), path, (unsigned long)revStart);

	if (!ra_cmd_preamble(ra_get_line))
	{
		ra_diag = 27;
		return 0;
	}
	if (!ra_drain_cmd_acks())
	{
		ra_diag = 27;
		return 0;
	}
	if (!ra_drain_until_file_meta())
	{
		ra_diag = 27;
		return 0;
	}
	if (!ra_is_success())
	{
		ra_diag = 27;
		return 0;
	}

	fp = fs_create((unsigned char *)local_path);
	if (!fs_hok(fp))
	{
		ra_diag = 30;
		return 0;
	}
	ra_file_wr_reset();

	total_len = 0;
	while (1)
	{
		if (!ra_read_svn_chunk(fp, &chunk_len))
		{
			ra_diag = 25;
			fs_close(fp);
			OS_DELETE((unsigned char *)local_path);
			return 0;
		}
		if (chunk_len == 0)
			break;
		total_len += chunk_len;
	}
	if (!ra_file_wr_flush(fp))
	{
		ra_diag = 25;
		fs_close(fp);
		OS_DELETE((unsigned char *)local_path);
		return 0;
	}
	fs_close(fp);
	if (total_len == 0)
	{
		ra_diag = 26;
		OS_DELETE((unsigned char *)local_path);
		return 0;
	}
	if (!ra_drain_getfile_tail())
	{
		ra_diag = 29;
		svn_sess_open = 0;
		OS_DELETE((unsigned char *)local_path);
		return 0;
	}
	return 1;
}

static void parse_cli_url(const char *url)
{
	static char work[160];
	char *slash;
	char *rest;
	char *s1;
	char *s2;
	unsigned int n;

	n = 0;
	while (url[n] && n < 159)
	{
		work[n] = url[n];
		n++;
	}
	work[n] = 0;
	slash = strchr(work, '/');
	if (slash == 0)
		fatal("Bad url");
	*slash = 0;
	n = 0;
	while (work[n] && n < 63)
	{
		svnHost[n] = work[n];
		n++;
	}
	svnHost[n] = 0;
	rest = slash + 1;
	s1 = strchr(rest, '/');
	if (s1 == 0)
		fatal("need host/repo/...");
	s2 = strchr(s1 + 1, '/');
	{
		unsigned int g = 0;
		const char *pfx = "svn://";
		while (pfx[g] && g < 95)
		{
			greetingUrl[g] = pfx[g];
			g++;
		}
		n = 0;
		while (svnHost[n] && g < 95)
			greetingUrl[g++] = svnHost[n++];
		if (g < 95)
			greetingUrl[g++] = '/';
		if (s2)
		{
			while (rest < s2 && g < 95)
				greetingUrl[g++] = *rest++;
			greetingUrl[g] = 0;
			path_copy((char *)svnPath, "/");
			path_copy_n((char *)(svnPath + 1), s2 + 1, 127);
		}
		else
		{
			while (*rest && g < 95)
				greetingUrl[g++] = *rest++;
			greetingUrl[g] = 0;
			path_copy((char *)svnPath, "/");
		}
	}
}

static void fat_from_datetime(unsigned int y, unsigned int mo, unsigned int d,
							  unsigned int h, unsigned int mi, unsigned int s,
							  unsigned int *fdate, unsigned int *ftime)
{
	if (y < 1980)
		y = 1980;
	*fdate = ((y - 1980) << 9) | (mo << 5) | d;
	*ftime = (h << 11) | (mi << 5) | (s >> 1);
}

static unsigned char parse_iso_num(const char **pp, unsigned int *out)
{
	const char *p;
	unsigned int v;

	p = *pp;
	if (*p < '0' || *p > '9')
		return 0;
	v = 0;
	while (*p >= '0' && *p <= '9')
	{
		v = v * 10 + (unsigned int)(*p - '0');
		p++;
	}
	*pp = p;
	*out = v;
	return 1;
}

static unsigned char parse_http_date(const char *p, unsigned int *fdate, unsigned int *ftime)
{
	unsigned int y, mo, d, h, mi, s;

	if (p == 0 || p[0] == 0)
		return 0;
	if (!parse_iso_num(&p, &y) || *p != '-')
		return 0;
	p++;
	if (!parse_iso_num(&p, &mo) || *p != '-')
		return 0;
	p++;
	if (!parse_iso_num(&p, &d))
		return 0;
	if (*p != 'T' && *p != ' ')
		return 0;
	p++;
	if (!parse_iso_num(&p, &h) || *p != ':')
		return 0;
	p++;
	if (!parse_iso_num(&p, &mi) || *p != ':')
		return 0;
	p++;
	if (!parse_iso_num(&p, &s))
		return 0;
	if (y < 1980)
		y = 1980;
	if (mo < 1 || mo > 12 || d < 1 || d > 31)
		return 0;
	fat_from_datetime(y, mo, d, h, mi, s, fdate, ftime);
	return 1;
}

static unsigned long crc_file(const char *path)
{
	FILE *fp;
	unsigned int chunk;
	unsigned long crc;
	fp = fs_open((unsigned char *)path);
	if (!fs_hok(fp))
		return 0;
	crc32_reset();
	do
	{
		chunk = OS_READHANDLE(netbuf, fp, 512);
		if (chunk == 0)
			break;
		crc32_update(netbuf, chunk);
	} while (chunk == 512);
	fs_close(fp);
	crc = crc32_get();
	return crc;
}

static void make_tmp_path(const char *local)
{
	const char *slash;
	unsigned int n;

	slash = strrchr(local, '/');
	if (slash == 0)
	{
		path_copy((char *)tmpPath, "_svnesp_tmp");
		return;
	}
	n = (unsigned int)(slash - local);
	if (n > 114)
		n = 114;
	memcpy(tmpPath, local, n);
	tmpPath[n] = 0;
	path_copy_n((char *)(tmpPath + n), "/_svnesp_tmp", 128 - n);
}

/* svn.com checks offline against the list via CHDIR+READDIR (no GETFILETIME).
 * Index lives in ra_file_buf (packed: len, name[len], date, time) so check
 * and download are separate passes - get-file reuses that buffer. */
#define LOCIDX_SIZE RA_FILE_IO

static unsigned int locidx_n;
static unsigned char locidx_ok;
static unsigned char locidx_full;
static unsigned int dirpack_off;
static unsigned int dirpack_n;
static unsigned char files_prechecked;
static unsigned char need_any;
static unsigned int qbuf_n;
static unsigned int qbuf_i;
static FILE *upd_qf;
static unsigned int upd_q_count;
static unsigned long upd_q_pos;

static unsigned char str_ieq_n(const char *a, const char *b, unsigned char n)
{
	unsigned char i;

	for (i = 0; i < n; i++)
	{
		if (a[i] == 0)
			return 0;
		if (tolower((unsigned char)a[i]) != tolower((unsigned char)b[i]))
			return 0;
	}
	return a[n] == 0;
}

static unsigned char locidx_add(const char *name, unsigned int date, unsigned int time)
{
	unsigned int n = 0;

	while (name[n])
		n++;
	if (n > 255)
		n = 255;
	if (locidx_n + n + 5 > LOCIDX_SIZE)
		return 0;
	ra_file_buf[locidx_n++] = (unsigned char)n;
	memcpy(ra_file_buf + locidx_n, name, n);
	locidx_n += n;
	ra_file_buf[locidx_n++] = (unsigned char)date;
	ra_file_buf[locidx_n++] = (unsigned char)(date >> 8);
	ra_file_buf[locidx_n++] = (unsigned char)time;
	ra_file_buf[locidx_n++] = (unsigned char)(time >> 8);
	return 1;
}

static unsigned char locidx_find(const char *name, unsigned int *date, unsigned int *time)
{
	unsigned int i = 0;
	unsigned char n;

	if (!name || name[0] == 0)
		return 0;
	while (i < locidx_n)
	{
		n = ra_file_buf[i++];
		if (i + n + 4 > locidx_n)
			return 0;
		if (str_ieq_n(name, (char *)(ra_file_buf + i), n))
		{
			i += n;
			*date = (unsigned int)ra_file_buf[i] | ((unsigned int)ra_file_buf[i + 1] << 8);
			*time = (unsigned int)ra_file_buf[i + 2] | ((unsigned int)ra_file_buf[i + 3] << 8);
			return 1;
		}
		i += n + 4;
	}
	return 0;
}

static void locidx_build(void)
{
	unsigned char r;
	fileInfo *fi;
	static char nm[64];
	unsigned int nlen;

	locidx_ok = 0;
	locidx_full = 0;
	locidx_n = 0;
	OS_GETPATH((unsigned char *)ra_get_line);
	if (OS_CHDIR(localBase) != 0)
		return;
	OS_OPENDIR("");
	fi = (fileInfo *)ra_out;
	for (;;)
	{
		r = OS_READDIR(fi);
		if (r == 4 || r != 0)
			break;
		if (fi->fname[0] == 0)
			break;
		if (fi->fname[0] == '.' &&
			(fi->fname[1] == 0 ||
			 (fi->fname[1] == '.' && fi->fname[2] == 0)))
			continue;
		if (fi->fattrib & 0x10)
			continue;
		if (fi->lfname[0])
			path_copy_n(nm, (char *)fi->lfname, 64);
		else
			path_copy_n(nm, (char *)fi->fname, 13);
		nlen = (unsigned int)strlen(nm);
		while (nlen && nm[nlen - 1] == ' ')
			nm[--nlen] = 0;
		if (nm[0] == 0)
			continue;
		if (!locidx_add(nm, fi->fdate, fi->ftime))
		{
			locidx_full = 1;
			break;
		}
	}
	OS_CHDIR((unsigned char *)ra_get_line);
	locidx_ok = 1;
}

static void qbuf_reset(void)
{
	qbuf_n = 0;
	qbuf_i = 0;
}

static void qbuf_sync(void)
{
	OS_SEEKHANDLE(upd_qf, upd_q_pos);
	qbuf_reset();
}

static unsigned char q_getc(unsigned char *c)
{
	if (qbuf_i >= qbuf_n)
	{
		qbuf_n = OS_READHANDLE(ra_txbuf, upd_qf, sizeof(ra_txbuf));
		qbuf_i = 0;
		if (qbuf_n == 0)
			return 0;
	}
	*c = ra_txbuf[qbuf_i++];
	upd_q_pos++;
	return 1;
}

static unsigned char local_needs_update(const char *local, const char *name, const char *remote, const char *date_str)
{
	unsigned int lfdate, lftime;
	unsigned int rfdate, rftime;
	if (forceUpd)
		return 1;
	if (!parse_http_date(date_str, &rfdate, &rftime))
		return 1;
	if (locidx_ok)
	{
		if (!locidx_find(name, &lfdate, &lftime))
		{
			if (!locidx_full)
				return 1;
			if (!local || OS_GETFILETIME((unsigned char *)local, &lfdate, &lftime) != 0)
				return 1;
		}
	}
	else if (!local || OS_GETFILETIME((unsigned char *)local, &lfdate, &lftime) != 0)
		return 1;
	if (rfdate != lfdate || rftime != lftime)
		return 1;
	if (useCrc)
	{
		unsigned long rcrc, lcrc;
		make_tmp_path(local);
		if (!ra_svn_get_file(remote, tmpPath))
			return 1;
		rcrc = crc_file(tmpPath);
		lcrc = crc_file(local);
		OS_DELETE(tmpPath);
		return rcrc != lcrc;
	}
	return 0;
}

static unsigned char is_remote_dir(void)
{
	unsigned int n = strlen(svnPath);
	const char *p;
	if (n > 0 && svnPath[n - 1] == '/')
		return 1;
	p = svnPath + n;
	while (p > svnPath && *(p - 1) != '/')
		p--;
	if (strchr(p, '.') == 0 && strchr(p, '$') == 0)
		return 1;
	return 0;
}

static unsigned char svn_ensure_open(void)
{
	if (svn_sess_open)
		return 1;
	if (!ra_tcp_connect(svnHost))
		return 0;
	if (!ra_svn_open(greetingUrl))
	{
		ra_tcp_close();
		return 0;
	}
	svn_sess_open = 1;
	return 1;
}

static unsigned char svn_reopen(void)
{
	ra_tcp_close();
	return svn_ensure_open();
}

static unsigned char str_ieq(const char *a, const char *b)
{
	while (*a && *b)
	{
		if (tolower((unsigned char)*a) != tolower((unsigned char)*b))
			return 0;
		a++;
		b++;
	}
	return *a == 0 && *b == 0;
}

static void exclude_load(void)
{
	FILE *fp;
	unsigned int n;
	unsigned int i;

	exclude_loaded = 0;
	exclude_buf[0] = 0;
	if (excludePath[0] == 0)
		return;
	fp = fs_open(excludePath);
	if (!fs_hok(fp))
	{
		printf("-X: cannot open %s\r\n", excludePath);
		return;
	}
	n = OS_READHANDLE(exclude_buf, fp, sizeof(exclude_buf) - 1);
	fs_close(fp);
	exclude_buf[n] = 0;
	for (i = 0; i < n; i++)
	{
		if (exclude_buf[i] == '\r' || exclude_buf[i] == '\n')
			exclude_buf[i] = 0;
	}
	exclude_loaded = 1;
	if (verbose)
		printf("-X loaded %s\r\n", excludePath);
}

static unsigned char exclude_match(const char *name)
{
	unsigned int i;
	const char *p;

	if (!exclude_loaded || name[0] == 0)
		return 0;
	i = 0;
	while (i < sizeof(exclude_buf))
	{
		while (i < sizeof(exclude_buf) && exclude_buf[i] == 0)
			i++;
		if (i >= sizeof(exclude_buf) || exclude_buf[i] == 0)
			break;
		p = (const char *)(exclude_buf + i);
		if (str_ieq(p, name))
			return 1;
		while (i < sizeof(exclude_buf) && exclude_buf[i] != 0)
			i++;
	}
	return 0;
}

static unsigned char upd_one_file(const char *remote, const char *name, const char *date_str)
{
	static char path[128];
	static char local[128];
	static char eff_date[20];
	unsigned int fdate, ftime;
	unsigned char tries;

	fdate = 0;
	ftime = 0;
	eff_date[0] = 0;
	if (date_str[0])
		path_copy_n(eff_date, date_str, 20);
	if (remote && remote[0])
		path_copy(path, remote);
	else
		join_path(path, (char *)svnPath, name);
	while (path[0] == '/' && path[1] == '/')
		path_copy(path, path + 1);

	if (name[0] == 0)
		return 0;
	join_path(local, localBase, name);

	if (exclude_match(name))
	{
		printf("%s... Skipped\r\n", name);
		return 1;
	}

	/* Date needed before skip check (single-file upd passes "") */
	if (!eff_date[0])
		ra_svn_fetch_mtime(path, eff_date);

	if (!files_prechecked && !local_needs_update(local, name, path, eff_date))
	{
		if (verbose)
			printf("skip %s\r\n", local);
		return 1;
	}
	if (debugRa && eff_date[0])
		printf("dbg date %s\r\n", eff_date);
	dbg_filen++;
	if (verbose || debugRa)
		printf("[%u] %s fd=%u/%u sk=%u/%u s=%d\r\n",
			   dbg_filen, name, dbg_nfile, dbg_nfile_max,
			   dbg_nsock, dbg_nsock_max, svnSocket);
	prog_start(name);
	if (!svn_ensure_open())
	{
		prog_end();
		printf("session open failed\r\n");
		return 0;
	}
	OS_DELETE((unsigned char *)local);
	tries = 0;
	while (tries < 3)
	{
		if (ra_svn_get_file(path, local))
			break;
		OS_DELETE((unsigned char *)local);
		tries++;
		if (tries >= 3)
		{
			prog_end();
			printf("skip %s get (%u)\r\n", local, ra_svn_get_diag());
			dbg_skip++;
			svn_reopen();
			return 1;
		}
		if (!svn_reopen())
		{
			prog_end();
			printf("session open failed\r\n");
			return 0;
		}
	}
	prog_end();
	if (eff_date[0] && parse_http_date(eff_date, &fdate, &ftime))
	{
		OS_SETFILETIME((unsigned char *)local, fdate, ftime);
		if (verbose)
			printf("date %s\r\n", eff_date);
	}
	return 1;
}

static void upd_cleanup_temps(void)
{
	join_path(upd_q_path, (char *)localBase, "_svnesp.q");
	OS_DELETE(upd_q_path);
	join_path(tmpPath, (char *)localBase, "_svnesp.n");
	OS_DELETE(tmpPath);
	join_path(tmpPath, (char *)localBase, "_svnesp_tmp");
	OS_DELETE(tmpPath);
	if (dstk_fp)
	{
		fs_close(dstk_fp);
		dstk_fp = 0;
	}
	join_path(dstk_path, (char *)localBase, "_svnesp.d");
	OS_DELETE(dstk_path);
	dstk_n = 0;
}

static void upd_q_open(void)
{
	join_path(upd_q_path, (char *)localBase, "_svnesp.q");
	OS_DELETE(upd_q_path);
	upd_qf = fs_create(upd_q_path);
	if (!fs_hok(upd_qf))
		return;
	fs_close(upd_qf);
	upd_qf = fs_open(upd_q_path);
}

static void upd_q_close(void)
{
	if (fs_isopen(upd_qf))
		fs_close(upd_qf);
	upd_qf = 0;
}

static void upd_q_write(const char *line)
{
	unsigned int n;

	if (!fs_isopen(upd_qf))
		return;
	n = strlen(line);
	OS_WRITEHANDLE((unsigned char *)line, upd_qf, n);
}

static void path_basename(const char *path, char *name)
{
	const char *slash;

	slash = strrchr(path, '/');
	if (slash && slash[1])
		path_copy_n(name, slash + 1, 32);
	else
		path_copy_n(name, path, 32);
}

static unsigned char upd_stk_push(const char *sp, const char *lb);
static unsigned char upd_q_process_files(void);
static unsigned char upd_q_push_subdirs(void);
static unsigned char upd_directory_level(void);
static unsigned char upd_download_tree(void);

static unsigned char dirpack_add(const char *name)
{
	unsigned int n = 0;
	unsigned int off;

	while (name[n])
		n++;
	if (n == 0 || n > 90)
		return 0;
	if (dirpack_off < locidx_n + n + 1)
		return 0;
	off = dirpack_off - (n + 1);
	ra_file_buf[off] = (unsigned char)n;
	memcpy(ra_file_buf + off + 1, name, n);
	dirpack_off = off;
	dirpack_n++;
	return 1;
}

static void upd_need_open(void)
{
	if (fs_isopen(upd_qf))
		return;
	join_path(upd_q_path, (char *)localBase, "_svnesp.q");
	OS_DELETE(upd_q_path);
	upd_qf = fs_create(upd_q_path);
	if (!fs_hok(upd_qf))
		return;
	fs_close(upd_qf);
	upd_qf = fs_open(upd_q_path);
}

static void upd_collect(const char *name, unsigned char is_dir, const char *date_str)
{
	static char base[32];
	static char line[96];

	if (is_dir)
	{
		path_basename((char *)svnPath, base);
		if (strcmp(name, base) == 0)
			return;
		if ((unsigned int)strlen(name) > 90)
			return;
		if (useCrc)
		{
			sprintf(line, "D %s\r\n", name);
			upd_q_write(line);
		}
		else if (!dirpack_add(name))
		{
			join_path((char *)ra_out, (char *)svnPath, name);
			join_path((char *)tmpPath, (char *)localBase, name);
			OS_MKDIR(tmpPath);
			upd_stk_push((char *)ra_out, (char *)tmpPath);
		}
	}
	else
	{
		if ((unsigned int)strlen(name) > 90)
			return;
		if (useCrc)
		{
			sprintf(line, "F %s\r\n", name);
			upd_q_write(line);
			if (date_str[0] && (unsigned int)strlen(date_str) < 90)
				sprintf(line, "T %s\r\n", date_str);
			else
				path_copy_n(line, "T\r\n", 96);
			upd_q_write(line);
		}
		else
		{
			if (exclude_match(name))
			{
				printf("%s... Skipped\r\n", name);
				upd_q_count++;
				return;
			}
			if (!local_needs_update(0, name, 0, date_str))
			{
				upd_q_count++;
				return;
			}
			upd_need_open();
			if (!fs_isopen(upd_qf))
			{
				printf("queue create failed\r\n");
				upd_q_count++;
				return;
			}
			sprintf(line, "F %s\r\n", name);
			upd_q_write(line);
			if (date_str[0] && (unsigned int)strlen(date_str) < 90)
				sprintf(line, "T %s\r\n", date_str);
			else
				path_copy_n(line, "T\r\n", 96);
			upd_q_write(line);
			need_any = 1;
		}
	}
	upd_q_count++;
}

static unsigned char upd_q_readline(char *line, unsigned int max)
{
	unsigned int i = 0;
	unsigned char c;

	while (i < max - 1)
	{
		if (!q_getc(&c))
		{
			line[i] = 0;
			return i > 0;
		}
		if (c == '\r')
			continue;
		if (c == '\n')
		{
			line[i] = 0;
			return 1;
		}
		line[i++] = (char)c;
	}
	line[i] = 0;
	return 0;
}

static unsigned char upd_stk_push(const char *sp, const char *lb)
{
	static unsigned char rec[256];
	FILE *fp;
	unsigned int i;
	unsigned long off;

	for (i = 0; i < 256; i++)
		rec[i] = 0;
	path_copy((char *)rec, sp);
	path_copy((char *)(rec + 128), lb);
	if (dstk_fp == 0)
	{
		if (dstk_n == 0)
		{
			OS_DELETE(dstk_path);
			fp = fs_create(dstk_path);
			if (!fs_hok(fp))
				return 0;
			fs_close(fp);
		}
		fp = fs_open(dstk_path);
		if (!fs_hok(fp))
			return 0;
		dstk_fp = fp;
	}
	off = (unsigned long)dstk_n;
	off = off << 8;
	OS_SEEKHANDLE(dstk_fp, off);
	if (OS_WRITEHANDLE(rec, dstk_fp, 256) != 256)
		return 0;
	dstk_n++;
	return 1;
}

static unsigned char upd_stk_pop(char *sp, char *lb)
{
	static unsigned char rec[256];
	FILE *fp;
	unsigned long off;

	if (dstk_n == 0)
		return 0;
	dstk_n--;
	if (dstk_fp == 0)
	{
		fp = fs_open(dstk_path);
		if (!fs_hok(fp))
			return 0;
		dstk_fp = fp;
	}
	off = (unsigned long)dstk_n;
	off = off << 8;
	OS_SEEKHANDLE(dstk_fp, off);
	if (OS_READHANDLE(rec, dstk_fp, 256) != 256)
		return 0;
	path_copy(sp, (char *)rec);
	path_copy(lb, (char *)(rec + 128));
	return 1;
}

static unsigned char upd_q_process_files(void)
{
	static char line[96];
	static char name[64];
	static char date[20];

	upd_q_close();
	if (!need_any && !useCrc)
		return 1;
	upd_q_pos = 0;
	qbuf_reset();
	upd_qf = fs_open(upd_q_path);
	if (!fs_hok(upd_qf))
	{
		printf("need queue open failed\r\n");
		return 0;
	}
	files_prechecked = (unsigned char)(!useCrc);
	while (upd_q_readline(line, 96))
	{
		if (line[0] == 'F' && line[1] == ' ')
		{
			strncpy(name, line + 2, 63);
			name[63] = 0;
			date[0] = 0;
			if (!upd_q_readline(line, 96))
			{
				files_prechecked = 0;
				upd_q_close();
				return 0;
			}
			if (line[0] == 'T' && line[1] == ' ' && line[2])
			{
				strncpy(date, line + 2, 19);
				date[19] = 0;
			}
			qbuf_sync();
			if (!upd_one_file(0, name, date))
			{
				files_prechecked = 0;
				upd_q_close();
				return 0;
			}
		}
	}
	files_prechecked = 0;
	upd_q_close();
	return 1;
}

static unsigned char upd_q_push_subdirs(void)
{
	static char name[92];
	static char sub[128];
	static char ldir[128];
	unsigned int off;
	unsigned char n;

	if (useCrc)
	{
		static char line[96];

		upd_qf = fs_open(upd_q_path);
		if (((int)upd_qf) & 0xff)
			return 0;
		qbuf_reset();
		while (upd_q_readline(line, 96))
		{
			if (line[0] == 'D' && line[1] == ' ')
			{
				path_copy(name, line + 2);
				join_path(sub, (char *)svnPath, name);
				join_path(ldir, (char *)localBase, name);
				OS_MKDIR((unsigned char *)ldir);
				if (!upd_stk_push(sub, ldir))
				{
					upd_q_close();
					printf("dir stack write failed\r\n");
					return 0;
				}
			}
		}
		upd_q_close();
		OS_DELETE(upd_q_path);
		return 1;
	}

	off = dirpack_off;
	while (off < RA_FILE_IO)
	{
		n = ra_file_buf[off];
		if (n == 0 || off + 1 + n > RA_FILE_IO)
			break;
		if (n > 91)
			n = 91;
		memcpy(name, ra_file_buf + off + 1, n);
		name[n] = 0;
		off += 1 + (unsigned int)ra_file_buf[off];
		join_path(sub, (char *)svnPath, name);
		join_path(ldir, (char *)localBase, name);
		OS_MKDIR((unsigned char *)ldir);
		if (!upd_stk_push(sub, ldir))
		{
			printf("dir stack write failed\r\n");
			return 0;
		}
	}
	return 1;
}

static unsigned char upd_directory_level(void)
{
	const char *bn;

	upd_q_count = 0;
	need_any = 0;
	dirpack_n = 0;
	dirpack_off = RA_FILE_IO;
	files_prechecked = 0;
	/* Keep one TCP/SVN session for the whole tree - do not close/DNS/reopen
	 * per directory (that ate stack via dnsResolve buf[128] and desynced). */
	if (!svn_ensure_open())
	{
		printf("session open failed\r\n");
		return 0;
	}
	bn = (const char *)localBase + strlen((char *)localBase);
	while (bn > (const char *)localBase && *(bn - 1) != '/')
		bn--;
	if (useCrc)
	{
		upd_q_open();
		if (((int)upd_qf) & 0xff)
		{
			printf("queue open failed\r\n");
			return 0;
		}
	}
	else
		locidx_build();
	if (!ra_svn_list(svnPath, upd_collect))
	{
		upd_q_close();
		OS_DELETE(upd_q_path);
		if (debugRa)
		{
			printf("dbg list (%u): %s\r\n", ra_svn_get_diag(), ra_svn_last_cmd());
			printf("dbg: %s\r\n", ra_svn_get_message());
		}
		return 0;
	}
	upd_q_close();
	locidx_ok = 0;
	if (*bn)
		printf("Checking dir %s (%u items)...\r\n", bn, upd_q_count);
	else
		printf("Checking dir %s (%u items)...\r\n", localBase, upd_q_count);
	if (upd_q_count == 0)
	{
		OS_DELETE(upd_q_path);
		return 1;
	}
	if (useCrc)
	{
		if (!upd_q_process_files())
			return 0;
		return upd_q_push_subdirs();
	}
	/* Push subdirs first: get-file reuses ra_file_buf (dir pack lives there). */
	if (!upd_q_push_subdirs())
		return 0;
	if (!upd_q_process_files())
		return 0;
	OS_DELETE(upd_q_path);
	return 1;
}

static unsigned char upd_download_tree(void)
{
	dstk_n = 0;
	join_path(dstk_path, (char *)localBase, "_svnesp.d");
	OS_DELETE(dstk_path);
	if (!upd_stk_push((char *)svnPath, (char *)localBase))
		return 0;
	while (upd_stk_pop((char *)svnPath, (char *)localBase))
	{
		if (!upd_directory_level())
			return 0;
	}
	if (dstk_fp)
	{
		fs_close(dstk_fp);
		dstk_fp = 0;
	}
	OS_DELETE(dstk_path);
	return 1;
}

static void lst_print(const char *name, unsigned char is_dir, const char *date_str)
{
	printf("%s", name);
	if (is_dir)
		putchar('/');
	if (verbose && date_str[0])
		printf("  %s", date_str);
	printf("\r\n");
}

static void cmd_lst(void)
{
	if (!ra_svn_list(svnPath, lst_print))
	{
		if (debugRa)
		{
			printf("dbg list (%u): %s\r\n", ra_svn_get_diag(), ra_svn_last_cmd());
			printf("dbg: %s\r\n", ra_svn_get_message());
		}
		fatal("list failed");
	}
}

static void cmd_log(void)
{
	if (!ra_svn_log(svnPath, revStart, revEnd))
		fatal("log failed");
}

static void cmd_rev(void)
{
	unsigned long rev;
	rev = ra_svn_get_latest_rev();
	if (rev == 0)
		fatal("revision not found");
	printf("%lu\r\n", rev);
}

static void cmd_upd(void)
{
	if (localBase[0] != '/' || localBase[1] != 0)
		OS_MKDIR((unsigned char *)localBase);
	upd_cleanup_temps();
	/* exclude list already loaded in main() before ESP CHDIR */
	if (verbose || debugRa)
		printf("upd start fd=%u sk=%u\r\n", dbg_nfile, dbg_nsock);
	if (is_remote_dir())
	{
		if (!upd_download_tree())
		{
			printf("upd stopped (local step, not svn). fd=%u/%u sk=%u/%u\r\n",
				   dbg_nfile, dbg_nfile_max,
				   dbg_nsock, dbg_nsock_max);
		}
	}
	else
	{
		const char *fname;

		fname = svnPath + strlen(svnPath);
		while (fname > svnPath && *(fname - 1) != '/')
			fname--;
		if (!upd_one_file(svnPath, fname, ""))
			printf("upd file failed\r\n");
	}
}

static void usage(void)
{
	printf("svnesp.com lst|log|rev|upd <host/path> [local] [opts]\r\n");
	printf("  svn:// port %u (ra_svn)  -v -f -c -d -e ESP -r N -r N:M -X file\r\n", SVN_PORT);
	args_ok = 0;
}

static void run_command(void)
{
	if (debugRa)
		printf("dbg on\r\n");
	if (!ra_tcp_connect(svnHost))
	{
		fatal("connect failed");
		return;
	}
	if (!ra_svn_open(greetingUrl))
	{
		ra_tcp_close();
		if (debugRa)
			printf("dbg: %s\r\n", ra_svn_get_message());
		switch (ra_svn_get_diag())
		{
		case 1:
			printf("svn handshake failed: no server greeting\r\n");
			break;
		case 2:
			printf("svn handshake failed: no auth challenge\r\n");
			break;
		case 3:
			printf("svn handshake failed: no repos info\r\n");
			break;
		case 4:
			printf("svn handshake failed: repos rejected\r\n");
			break;
		case 5:
			printf("svn handshake failed: tcp send\r\n");
			break;
		case 10:
			printf("svn handshake failed: bad auth challenge\r\n");
			break;
		case 11:
			printf("svn handshake failed: no auth response\r\n");
			break;
		case 12:
			printf("svn handshake failed: auth denied\r\n");
			break;
		default:
			printf("svn handshake failed (%u)\r\n", ra_svn_get_diag());
			break;
		}
		fatal("svn open");
		return;
	}
	svn_sess_open = 1;
	if (strcmp(subcmd, "lst") == 0)
		cmd_lst();
	else if (strcmp(subcmd, "log") == 0)
		cmd_log();
	else if (strcmp(subcmd, "rev") == 0)
		cmd_rev();
	else if (strcmp(subcmd, "upd") == 0)
	{
		if (localBase[0] == 0)
			fatal("upd needs local path");
		cmd_upd();
	}
	else
		usage();
	ra_tcp_close();
}

static void parse_args(int argc, char *argv[])
{
	int i;
	const char *a;
	unsigned char pos = 0;

	subcmd[0] = 0;
	excludePath[0] = 0;
	revStart = 0;
	revEnd = 0;
	for (i = 1; i < argc; i++)
	{
		a = argv[i];
		if (a[0] == '-')
		{
			a++;
			while (*a)
			{
				switch (*a)
				{
				case 'e':
					forceEsp = 1;
					break;
				case 'f':
					forceUpd = 1;
					break;
				case 'c':
					useCrc = 1;
					break;
				case 'v':
					verbose = 1;
					break;
				case 'd':
					debugRa = 1;
					break;
				case 'r':
					if (i + 1 < argc)
					{
						const char *rs = argv[++i];
						const char *colon = strchr(rs, ':');
						revStart = (unsigned int)atol(rs);
						if (colon)
							revEnd = (unsigned int)atol(colon + 1);
						else
							revEnd = revStart;
					}
					break;
				case 'X':
					if (i + 1 < argc)
						path_copy((char *)excludePath, argv[++i]);
					break;
				default:
					break;
				}
				a++;
			}
		}
		else
		{
			if (pos == 0)
			{
				strncpy(subcmd, a, 7);
				subcmd[7] = 0;
			}
			else if (pos == 1)
				parse_cli_url(a);
			else if (pos == 2)
				path_copy((char *)localBase, a);
			pos++;
		}
	}
	if (pos < 2 || svnPath[0] == 0)
		usage();
}

static char read_param_from_ini(void)
{
	FILE *fpini;
	unsigned char *count1;
	const char currentNetwork[] = "currentNetwork";
	unsigned char curNet = 0;

	OS_GETPATH(curPath);
	OS_SETSYSDRV();
	OS_CHDIR("/");
	OS_CHDIR("ini");
	fpini = fs_open("network.ini");
	if (!fs_hok(fpini))
	{
		OS_CHDIR(curPath);
		return 0;
	}
	OS_READHANDLE(netbuf, fpini, sizeof(netbuf) - 1);
	fs_close(fpini);
	count1 = strstr(netbuf, currentNetwork);
	if (count1 != NULL)
		sscanf(count1 + strlen(currentNetwork) + 1, "%u", &curNet);
	OS_CHDIR(curPath);
	return curNet;
}

C_task main(int argc, char *argv[])
{
	unsigned char test;
	os_initstdio();
	parse_args(argc, argv);
	if (!args_ok)
		return 0;
	/* Load -X before loadEspConfig: it does SETSYSDRV+CHDIR("../ini")
	 * and never restores, so relative exclude.txt would silently fail. */
	exclude_load();
	OS_GETPATH(curPath);
	netDriver = read_param_from_ini();
	if (forceEsp)
		netDriver = 1;
	switch (netDriver)
	{
	case 0:
		targetadr.family = AF_INET;
		get_dns();
		test = 0;
		{
			unsigned char t;

			for (t = 0; t < 4; t++)
			{
				test = dnsResolve(svnHost);
				if (test)
					break;
				delayLong(100);
			}
		}
		if (!test)
		{
			printf("DNS failed\r\n");
			return 0;
		}
		break;
	case 1:
		loadEspConfig();
		OS_CHDIR(curPath);
		uart_init(divider);
		espReBoot();
		break;
	case 2:
		OS_ESPINIT();
		EspGetDns();
		break;
	default:
		printf("unknown netDriver %u\r\n", netDriver);
		return 0;
	}
	run_command();
	puts("Update completed.");
	exit(0x00);
	return 0;
}
