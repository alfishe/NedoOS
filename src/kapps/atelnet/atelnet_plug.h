#ifndef ATELNET_PLUG_H
#define ATELNET_PLUG_H

#include <oscalls.h>

#define AT_BANK_SLOT_RESIDENT 0u
#define AT_BANK_SLOT_DATA     1u

extern unsigned char residentPg;
extern unsigned char g_dataPg;
extern union APP_PAGES main_pg;

void at_init_banks(void);
void at_resident_map(void);
unsigned char at_zmodem_bank_enter(void);
void at_zmodem_bank_leave(unsigned char saved);

void at_path_to_ini(unsigned char *saved_path);

void at_path_to_downloads(unsigned char *saved_path);

int r_telbook_run(char *host, unsigned int host_sz, unsigned int *port,
                  unsigned char *cp866, unsigned char *debug);
void r_show_ansiview_hint(const char *path);
int r_host_looks_like_file(const char *host);
void r_show_usage(void);
int r_parse_host_port(char *arg, char *host, unsigned int host_sz, unsigned int *port);
void r_show_bad_host(void);

void r_show_connecting(const char *host, unsigned int port);
void r_show_net_error(const char *msg);
void r_show_session_end(unsigned char user_quit, unsigned char sock_err, unsigned int rx_total);
void r_telnet_display_prep(unsigned char cp866);

#endif
