NAME		= tetris.com
OBJECTS		=
SOURCES		= main.asm zx.fnt
SJASMPLUS	= ../../../tools/sjasmplus
INSTALLDIR	= ../../../release

all: ${NAME} ${SOURCES}

tetris.com: ${SOURCES}
	${SJASMPLUS} --nologo main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
