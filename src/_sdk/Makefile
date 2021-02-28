NAME		= nedopad.bin nedores.bin nedotrd.bin
OBJECTS		=
SOURCES		= nedopad/main.c nedores/main.c nedotrd/main.c
SJASMPLUS	= ../../tools/sjasmplus
CC		= gcc
CFLAGS 		= -m32

all: ${NAME} ${SOURCES}

nedopad.bin: nedopad/main.c
	patch -N -p6 -i nedopad.diff; echo
	${CC} ${CFLAGS} nedopad/main.c -o nedopad.bin

nedores.bin: nedores/main.c
	patch -N -p6 -i nedores.diff; echo
	${CC} ${CFLAGS} nedores/main.c -o nedores.bin

nedotrd.bin: nedotrd/main.c
	patch -N -p6 -i nedotrd.diff; echo
	${CC} ${CFLAGS} nedotrd/main.c -o nedotrd.bin

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
