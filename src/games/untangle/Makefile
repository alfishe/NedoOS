NAME		= untangle.com
OBJECTS		=
SOURCES		= main.asm control.asm prarrow.asm
SJASMPLUS	= ../../../tools/sjasmplus
INSTALLDIR	= ../../../release/games

all: ${NAME} ${SOURCES}

untangle.com: ${SOURCES}
	${SJASMPLUS} --nologo main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
