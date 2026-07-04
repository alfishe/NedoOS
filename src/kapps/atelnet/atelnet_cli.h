#ifndef ATELNET_CLI_H
#define ATELNET_CLI_H

void at_show_ansiview_hint(const char *path);
int at_host_looks_like_file(const char *host);
void at_show_usage(void);
int at_parse_host_port(char *arg, char *host, unsigned int host_sz, unsigned int *port);
void at_show_bad_host(void);

#endif
