NAME		= scratch.com
OBJECTS		=
SOURCES		= bitmap.asm control.asm files.asm math.asm navigator.asm pal.asm prarrow.asm prbitmap.asm prshapes.asm prtext.asm scratch.asm window.asm tarcsin tsin200 tsqrt_max2 64qua.fnt
INSTALLDIR	= ../../release
DOC		= scratch.txt scratch.new

SJASMPLUS	= ../../tools/sjasmplus

all: ${NAME} ${SOURCES}

scratch.com: ${SOURCES}
	${SJASMPLUS} --nologo scratch.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
	cp ${DOC} ${INSTALLDIR}/doc
