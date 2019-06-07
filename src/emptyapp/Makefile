INSTALLDIR	= ../../release
NAME		= emptyapp.com
OBJECTS		=
SOURCES		= emptyapp.asm 
SJASMPLUS	= ../../tools/sjasmplus

all: ${NAME} ${SOURCES}

${NAME}: ${SOURCES}
	${SJASMPLUS} --nologo emptyapp.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin

install-doc: ${DOC}
	cp ${DOC} ${INSTALLDIR}/doc
