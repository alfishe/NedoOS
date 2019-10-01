NAME		= eric.com
OBJECTS		=
SOURCES		= main.asm ERIC1.ASM
SJASMPLUS	= sjasmplus
INSTALLDIR	= ../../../release

all: ${NAME} ${SOURCES}

eric.com: ${SOURCES}
	${SJASMPLUS} --nologo main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
