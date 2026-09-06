ESPNET
======

Прошивка ESP32 / ESP32-C3 / ESP8266 и драйвер NedoOS: модуль работает как
сокет-сопроцессор по UART (как W5300), без текстовых AT+CIP* на линии к ZX.

Кадры протокола - PROTOCOL.md. Ниже - как прошить и чем пользоваться.


How to: прошивка из Arduino IDE 2
---------------------------------

Первый раз всегда по USB (или TTL-адаптеру). OTA - когда модуль уже в Wi-Fi.


1. Ядра плат и библиотеки
~~~~~~~~~~~~~~~~~~~~~~~~~

File -> Preferences -> Additional boards manager URLs
(строки через запятую или каждую с новой строки):

  https://espressif.github.io/arduino-esp32/package_esp32_index.json
  https://arduino.esp8266.com/stable/package_esp8266com_index.json

В IDE 2 эти URL часто уже есть. Если в Boards Manager пакетов нет - добавьте.

Tools -> Board -> Boards Manager, поставьте нужное ядро:

  Chip              Package
  ----------------  --------------------------------
  ESP32, ESP32-C3   esp32 by Espressif Systems
  ESP8266           esp8266 by ESP8266 Community

Версия: свежий стабильный релиз ядра. Не ставьте "Arduino AVR Boards"
вместо ESP - тогда не найдётся WiFi.h.

Library Manager: ничего дополнительно ставить не нужно.
ArduinoOTA / WiFi / WebServer / mDNS / EEPROM / Preferences идут
в комплекте с ядром. Сторонний ArduinoOTA из Library Manager
может конфликтовать - не устанавливайте.

Что подтягивается из ядра (для справки, руками не качать):

  ESP32 / C3     WiFi, WebServer, ESPmDNS, ArduinoOTA,
                 Update, Preferences, WiFiClient, WiFiServer,
                 WiFiUdp, driver/uart.h

  ESP8266        ESP8266WiFi, ESP8266WebServer, ESP8266mDNS,
                 ArduinoOTA, EEPROM, WiFiClient, WiFiServer,
                 WiFiUdp


2. Открыть скетч
~~~~~~~~~~~~~~~~

File -> Open -> папка src/kapps/common/espnet/  (файл espnet.ino).

Открывать нужно папку, не один .ino.


3. pins.h - плата и логин
~~~~~~~~~~~~~~~~~~~~~~~~~

Файл pins.h в той же папке. Перед Upload:

  #define ESPNET_BAUD 115200          /* UART к ZX, 8N1 + RTS/CTS */
  #define ESPNET_WEB_USER "espnet"    /* веб и пароль OTA */
  #define ESPNET_WEB_PASS "espnet"

Только ESP8266 - раскомментируйте ОДНУ строку под разводку
(чип один, пины разные; само не угадывается):

  //#define ESPNET_BOARD_ZXWIFI   /* ZX-WiFi / ESP-12F, UART0 без swap */
  #define ESPNET_BOARD_D1MINI      /* D1 mini / ESP-AT, Serial.swap() */

ESP32 и C3 пины берутся по выбранной плате, эти #define не трогайте.
Не прошивайте образ WROOM на C3 и наоборот.


4. Tools -> Board
~~~~~~~~~~~~~~~~~

ESP32 D1 mini / WROOM
  Board:     WEMOS D1 MINI ESP32   (или ESP32 Dev Module)
  USB:       CH340 / CP2102
  USB CDC On Boot: Disabled

ESP32-C3 Super Mini (ATM-COM, как стоковый AT)
  Board:     ESP32C3 Dev Module
  USB CDC On Boot: Enabled     <-- без этого порт не тот
  Не выбирайте "ESP32 Dev Module": GPIO 16/17 на C3 нет.

ESP8266 ZX-WiFi (ESP-12F)
  Board:     Generic ESP8266 Module
  pins.h:    ESPNET_BOARD_ZXWIFI
  Flash Size: 4MB (FS:2MB OTA:~1019KB)   <-- без OTA-раздела
                                             вторая прошивка по сети не влезет
  Flash Mode: DOUT
  CPU:        80 MHz
  Upload:     115200
  lwIP:       v2 Lower Memory

ESP8266 D1 mini / WROOM-02 (ESP-AT разводка)
  Board:     LOLIN(WEMOS) D1 R2 & mini
  pins.h:    ESPNET_BOARD_D1MINI
  Flash Size: 4MB (FS:2MB OTA:~1019KB)
  lwIP:       v2 Lower Memory


5. UART к Спектруму
~~~~~~~~~~~~~~~~~~~

115200 8N1, обязателен hardware RTS/CTS. Без RTS/CTS кадры рвутся.

  Module                 TX   RX  CTS  RTS   USB debug
  ---------------------  ---  --  ---  ---   ----------------
  ESP32 WROOM             17  16   15   14   UART0 (GPIO 1/3)
  ESP32-C3 Super Mini      7   6    5    4   USB CDC
  ESP8266 D1 mini (swap)  15  13    3    1   лог GPIO2
  ESP8266 ZX-WiFi native   1   3   13   15   GPIO2, без разъёма

ZX RTS -> ESP CTS  (на YIELD Спектрум снимает RTS, ESP стопит TX)
ESP RTS -> ZX CTS

ZX-WiFi v1.6: прошивка через X2 (TTL 3.3 V), SW1 = ESP.
На время Upload разомкните X5/X6 (16550 не должен драться с адаптером),
потом замкните обратно. На хосте comType=2 (Kondratyev AFC), divider=1.


6. Upload
~~~~~~~~~

1. Port - COM модуля.
2. Sketch -> Upload.
3. Serial Monitor 115200. Команда AT+GMR - версия, чип, строка uart: ...
   Если uart: не ваша плата - pins.h / Board.

AT только на USB. На UART к ZX их слать нельзя.

USB: AT+GMR  AT+STATUS  AT+SOCKS  AT+UART  AT+UART=115200  AT+WEB  AT+HELP

На NedoOS: /ini/network.ini -> currentNetwork=2, утилита enet
(скан Wi-Fi, AP пишется в NVS модуля).


Arduino OTA
-----------

После STA+IP OTA поднимается сама. Веб по умолчанию выключен
(экономит сокеты); включить: USB AT+WEB.

  mDNS     espnet-32 / espnet-c3 / espnet-8266   (AT+GMR -> ota:)
  OTA pass espnet                                (ESPNET_WEB_PASS)
  Web      http://espnet-32.local/  или IP
           логин espnet / espnet

Как прошить по воздуху:

1. Модуль в той же Wi-Fi, что ПК. Первый образ - только USB.
2. Закройте вкладку веба, если открывали.
3. Тот же скетч, та же плата. Port = "espnet-8266 at <ip>"
   (имя зависит от чипа).
4. Upload. Пока идёт OTA, UART/TCP со Спектрума стоят.
5. ESP8266: Flash Size с OTA-partition, иначе по сети не влезет.

HTTP не крутится, пока по ZX UART недавно были байты (~300 мс).
Качается gopher - закройте браузер к модулю.


Что делает прошивка ESP
-----------------------

- TCP/UDP-сокеты (8 на ESP32, 4 на ESP8266), DNS, bind/listen/accept.
- Wi-Fi: scan / connect (SSID+пароль в NVS, автоreconnect) / disc / status.
- Смена скорости UART к ZX (CMD_UART; debug USB всегда 115200).
- Хост - master: нет незапрошенных +IPD; входящий TCP копится до READ.
- Payload до 2048 байт, RTS/CTS, keepalive вместо вечного зависания.
- Веб-статус и ArduinoOTA.

ICMP нет.


Что есть в NedoOS
-----------------

Драйвер в userland, не сисколл ядра. Один раз OS_ESPINIT
(читает /ini/espcom.ini, настраивает UART).

Сеть в приложениях: /ini/network.ini -> currentNetwork=2
  0 = WIZNET/ZXNETUSB
  1 = AT-Firmware / ESP-COM
  2 = ESPNET

Wi-Fi и COM-порт: утилита enet.

Сисколлы C (espnet.h):
  OS_ESPINIT  OS_ESPSOCKET  OS_ESPCONNECT
  OS_ESPREAD / OS_ESPWRITE  (и UDP-варианты)
  OS_ESPBIND  OS_ESPLISTEN  OS_ESPACCEPT  OS_ESPSHUTDOWN
  OS_ESPGETDNS  OS_ESPDNSRESOLVE  OS_ESPINFO  OS_ESPECHO
  OS_ESPWIFI_SCAN / _CONNECT / _DISC / _STATUS
  OS_ESPUART / OS_ESPGETUART

Обёртки как у AT-стека: EspOpenSock, EspConnect, EspSend, EspRead, ...

Ассемблер при DEFINE ESPNET - те же регистры, что у WIZNET:
  OS_NETSOCKET  OS_NETCONNECT  OS_ACCEPT  OS_BIND  OS_LISTEN
  OS_WIZNETREAD / WRITE / CLOSE
  плюс OS_ESPINFO, OS_ESPWIFI_*


Отличия от AT Firmware
----------------------

  Тема          AT Firmware                 ESPNET
  ------------  --------------------------  -----------------------------
  Линия к ZX    текст AT+CIPSTART,          бинарные кадры 0xA5,
                +IPD прилетает сам          хост спрашивает сам
  Драйвер C     esp-com.c + network.c       esp-com.c + espnet.c
                                            + espnet-net.c
  Смешивать     (нельзя)                    AT-текст на ZX UART нельзя
  Зомби-TCP     часто только AT+RST         keepalive -> NOTCONN,
                                            без ребута модуля
  Прошивка      Espressif AT                этот скетч;
                                            USB AT+GMR только отладка
  OTA / веб     нет в нашем стеке           ArduinoOTA + опц. веб

Приложения с currentNetwork 0/1/2 подключают оба стека и выбирают
драйвер из ini. AT-only приложение espnet.c не включает.


Подключаемые файлы
------------------

C (IAR), новое TCP-приложение (как zxdb / gopher):

  #include <tcp.h>
  #include <espnet.h>
  #include <../common/esp-com.c>      /* UART, espcom.ini */
  #include <../common/network.c>      /* если нужен AT/WIZNET fallback */
  #define ESPNET_CLIENT_ONLY 1
  #include <../common/espnet.c>       /* OS_ESP* */
  #include <../common/espnet-net.c>   /* EspOpenSock / EspSend / ... */

Перед работой: OS_ESPINIT(). UDP: ещё #define ESPNET_UDP 1.

enet (только ESPNET, Wi-Fi UI): esp-com.c + espnet.c
без CLIENT_ONLY и без espnet-net.c.

Заголовки: src/kapps/iarlib/espnet.h (тянет espnet/protocol.h).
В Makefile эти .c/.h укажите в SRCH.

Ассемблер (sjasmplus):

          DEFINE ESPNET                   ; до sys_h.asm
          include "../_sdk/sys_h.asm"
          include "../_sdk/espnet_h.asm"  ; OS_ESPINFO, OS_ESPWIFI_*, ...
          ; ... код ...
          OS_ESPINIT
          include "../_sdk/espnet.asm"    ; драйвер, один раз в бинарник

Пример: src/esptest/esptest.asm.
