#название запускаемого файла
BIN		:=getpic.com

#поддиректория инсталляции в release
INSTDIR := bin

#тип вводавывода TTY или BDOS
CONSOLE := BDOS

#файлы .с
SRCC	:= main.c
#файлы .h
SRCH	:= ../common/esp-com.c ../common/network.c ../common/espnet.c ../common/espnet-net.c ../iarlib/espnet.h ../common/ini.c
#файлы .asm
SRCA	:=
#линковочный файл-скрипт. можно не указывать, тогда будет использоватся стандартный
XCLFILE	:= lnk.xcl


include ../iarlib/iar.mk
