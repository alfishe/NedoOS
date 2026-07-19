#название запускаемого файла
BIN		:=playwav.com

#поддиректория инсталляции в release
INSTDIR := bin

#тип ввода/вывода TTY или BDOS
CONSOLE := BDOS

#файлы .c
SRCC	:= main.c wav.c
#файлы .h
SRCH	:= wav.h
#файлы .asm
SRCA	:= covoxplay.asm ima_decode.asm
#линковочный файл-скрипт. можно не указывать, тогда будет использоваться стандартный
XCLFILE	:= lnk.xcl

include ../iarlib/iar.mk
