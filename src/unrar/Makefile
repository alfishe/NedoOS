NAME		= unrar.com
OBJECTS		=
SOURCES		= rardepk.asm rarfile.asm unrar.asm
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release

all: ${NAME} ${SOURCES}

unrar.com: ${SOURCES}
	${SJASMPLUS} --nologo unrar.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
