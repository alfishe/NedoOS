INSTALLDIR	= ../../release
NAME		= ping.com
OBJECTS		=
SOURCES		= ping.asm
SJASMPLUS	= ../../tools/sjasmplus

all: ${NAME} ${SOURCES}

${NAME}: ${SOURCES}
	${SJASMPLUS} --nologo ping.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin

install-doc: ${DOC}
#	cp ${DOC} ${INSTALLDIR}/doc
