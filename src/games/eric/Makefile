NAME		= eric.com
OBJECTS		=
SOURCES		= main.asm eric1.asm
SJASMPLUS	= ../../../tools/sjasmplus --nologo
INSTALLDIR	= ../../../release/games

all: ${NAME} ${SOURCES}

eric.com: ${SOURCES}
	${SJASMPLUS} main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
