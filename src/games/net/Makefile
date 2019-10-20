NAME		= master.com slave.com
OBJECTS		=
SOURCES		= main.asm fontgfx zx.fnt
SJASMPLUS	= ../../../tools/sjasmplus
INSTALLDIR	= ../../../release/nedogame/netsnake

all: ${NAME} ${SOURCES}

snake.com: main.asm
	${SJASMPLUS} --nologo master.asm
	${SJASMPLUS} --nologo slave.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
