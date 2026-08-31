#имя запускаемого файла
BIN		:= zifi.com

#поддиректория инсталляции в release
INSTDIR := bin

#тип ввода/вывода TTY или BDOS
CONSOLE := BDOS

#файлы .c
SRCC	:= main.c
#файлы .h
SRCH	:= ../common/esp-com.c ../common/network.c ../common/espnet.c ../common/espnet-net.c ../iarlib/espnet.h
#файлы .asm
SRCA	:=
#линковочный файл-скрипт. можно не указывать, тогда будет использоваться стандартный
XCLFILE	:= lnk.xcl


include ../iarlib/iar.mk
