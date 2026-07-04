#ifndef ATELNET_BOOT_H
#define ATELNET_BOOT_H

void at_show_connecting(const char *host, unsigned int port);
void at_show_net_error(const char *msg);
void at_show_session_end(unsigned char user_quit, unsigned char sock_err, unsigned int rx_total);
void at_telnet_display_prep(unsigned char cp866);
signed char at_net_session_connect(const char *host, unsigned int port);

#endif
