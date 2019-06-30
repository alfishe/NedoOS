INSTALLDIR	= ../../release
NAME		= telnet.com
OBJECTS		=
SOURCES		= telnet.asm
SJASMPLUS	= ../../tools/sjasmplus

all: ${NAME} ${SOURCES}

${NAME}: ${SOURCES}
	${SJASMPLUS} --nologo --nofakes telnet.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin

install-doc: ${DOC}
#	cp ${DOC} ${INSTALLDIR}/doc
