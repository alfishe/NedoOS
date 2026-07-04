#ifndef ATELNET_LOG_H
#define ATELNET_LOG_H

/* Writes one line to telnet.log on system volume root. */
void at_log_write(const char *logline, const char *place);

#endif
