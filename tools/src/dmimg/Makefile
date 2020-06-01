# makfile configuration
INSTALLDIR	= ../
NAME            = dmimg
SRC		= diskio.c diskio.h ff.c ffconf.h ff.h ffsystem.c ffunicod.c main.c 

CFLAGS          = -m32 -march=i386
CC              = gcc

all: ${NAME} strip

strip: ${NAME}
	strip ${NAME}

#additional rules for files
${NAME}: ${SRC}
	${CC} ${CFLAGS} ff.c diskio.c main.c ffunicod.c ffsystem.c -Xlinker -o$@

install: all
	cp ${NAME} ${INSTALLDIR}

install-docs:
	
clean:
	rm -f ${NAME} 

