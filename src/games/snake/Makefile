NAME		= snake.com
OBJECTS		=
SOURCES		= main.asm fontgfx zx.fnt
SJASMPLUS	= ../../../tools/sjasmplus
INSTALLDIR	= ../../../release/nedogame

all: ${NAME} ${SOURCES}

snake.com: main.asm
	${SJASMPLUS} --nologo main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
