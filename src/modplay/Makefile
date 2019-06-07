NAME		= modplay.com
OBJECTS		=
SOURCES		= gsports.asm modplay.asm
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release

all: ${NAME} ${SOURCES}

modplay.com: ${SOURCES}
	${SJASMPLUS} --nologo modplay.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
