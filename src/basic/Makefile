NAME		= basic.com
OBJECTS		=
SOURCES		= basic.asm bascmds.asm
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release


all: ${NAME} ${SOURCES}

${NAME}: ${SOURCES}
	${SJASMPLUS} --nologo basic.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
