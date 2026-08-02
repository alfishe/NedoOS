BIN		:= girc.com
INSTDIR := bin
CONSOLE := BDOS
SRCC	:= main.c
# #include'd .c are not tracked via main.c mtime ? list them here (iar.mk uses SRCH).
SRCH	:= ../common/esp-com.c ../common/esp-com2.c ../common/network.c
SRCA	:=
XCLFILE	:= lnk.xcl
include ../iarlib/iar.mk
