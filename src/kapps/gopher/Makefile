#название запускаемого файла
BIN		:= gopher.com

#поддиректория инсталляции в release
INSTDIR := bin

#тип вводавывода TTY или BDOS
CONSOLE := BDOS

#файлы .с
SRCC	:= main.c
#файлы .h
SRCH	:= ../iarlib/espnet.h ../common/espnet/protocol.h ../common/espnet.c ../common/espnet-net.c ../common/esp-com.c ../common/ini.c
#файлы .asm
SRCA	:=
#линковочный файл-скрипт. можно не указывать, тогда будет использоватся стандартный
XCLFILE	:= lnk.xcl


include ../../kapps/iarlib/iar.mk
