NAME		= cmd.com
OBJECTS		=
SOURCES		= cmd.asm
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release

all: ${NAME} ${SOURCES}

cmd.com: ${SOURCES}
	${SJASMPLUS} --nologo cmd.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install:
	cp ${NAME} ${INSTALLDIR}/bin

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
