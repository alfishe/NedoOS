NAME		= texted.com
OBJECTS		=
SOURCES		= texted.asm text_mem.asm textview.asm winto866
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release

all: ${NAME} ${SOURCES}

texted.com: ${SOURCES}
	${SJASMPLUS} --nologo texted.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
