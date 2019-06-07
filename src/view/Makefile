NAME		= view.com
OBJECTS		=
SOURCES		= 888.asm chr.asm deblc.asm grf.asm view.asm
INSTALLDIR	= ../../release

SJASMPLUS	= ../../tools/sjasmplus

all: ${NAME} ${SOURCES}

view.com: ${SOURCES}
	${SJASMPLUS} --nologo view.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
