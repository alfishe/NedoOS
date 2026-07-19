# имя запускаемого файла
BIN		:= pkzip.com

# поддиректория инсталляции в release
INSTDIR := bin

# тип ввода/вывода TTY или BDOS
CONSOLE := TTY

# файлы .c
SRCC	:= main.c zip.c deflate.c winmem.c
# файлы .h
SRCH	:= zip.h crc32.h deflate.h winmem.h
# файлы .asm
SRCA	:= crc32.asm
# линковочный файл-скрипт
XCLFILE	:= lnk.xcl


include ../iarlib/iar.mk

# Prefer speed for CRC/copy loops.
$(OBJ)/%.r01: %.c $(SRCH) $(LIBH) | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s0 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) $<
