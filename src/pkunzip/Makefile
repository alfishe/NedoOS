NAME		= pkunzip.com
OBJECTS		=
SOURCES		= depk.asm file.asm nu.asm pkunzip.asm zipfile.asm
INSTALLDIR	= ../../release

SJASMPLUS	= ../../tools/sjasmplus

all: ${NAME} ${SOURCES}

pkunzip.com: ${SOURCES}
	${SJASMPLUS} --nologo pkunzip.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
