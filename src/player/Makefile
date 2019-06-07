NAME		= player.com
OBJECTS		=
SOURCES		= player.asm ptsplay.asm
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release

all: ${NAME} ${SOURCES}

player.com: ${SOURCES}
	${SJASMPLUS} --nologo player.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
