NAME		= setfont.com
OBJECTS		=
SOURCES		= setfont.asm 1125code.fnt 866_code.fnt atmucode.fnt
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release

all: ${NAME} ${SOURCES}

setfont.com: ${SOURCES}
	${SJASMPLUS} --nologo setfont.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
