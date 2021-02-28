NAME		= loyd.com
OBJECTS		=
SOURCES		= main.asm zx.fnt
SJASMPLUS	= ../../../tools/sjasmplus
INSTALLDIR	= ../../../release/nedogame

all: ${NAME} ${SOURCES}

tetris.com: ${SOURCES}
	${SJASMPLUS} --nologo main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
