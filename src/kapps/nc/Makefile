#название запускаемого файла
BIN		:= nc.com

#поддиректория инсталляции в release
INSTDIR := bin

#тип вводавывода TTY или BDOS
CONSOLE := BDOS

#файлы .с
SRCC	:= main.c nc_resident.c
#файлы .h
SRCH	:=
#файлы .asm
SRCA	:=
#линковочный файл-скрипт. можно не указывать, тогда будет использоватся стандартный
XCLFILE	:= lnk.xcl


include ../../kapps/iarlib/iar.mk

nc_mem.h: $(OBJ)/cout.html
	python gen_nc_mem.py $(OBJ)/cout.html nc_mem.h

all: nc_mem.h
