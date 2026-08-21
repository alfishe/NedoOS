#ifndef ESPNET_WEBUI_H
#define ESPNET_WEBUI_H

void webui_begin_log(void);
void webui_poll(void);
void webui_http_enable(void);
/* 1 while ArduinoOTA is flashing ? loop must not touch UART/TCP. */
int webui_ota_active(void);

#endif
