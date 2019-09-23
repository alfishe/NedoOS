NAME		= br.com
OBJECTS		= 
SOURCES		= main.asm brfinal.asm 
SJASMPLUS	= ../../../tools/sjasmplus --nologo
INSTALLDIR	= ../../../release/games

all: ${NAME} ${SOURCES}

br.com: ${SOURCES}
	${SJASMPLUS} levels/w~104.a80
	${SJASMPLUS} levels/w~107.a80
	${SJASMPLUS} levels/w~112.a80
	${SJASMPLUS} levels/w~117end.a80
	${SJASMPLUS} levels/w~205.a80
	${SJASMPLUS} levels/w~213.a80
	${SJASMPLUS} levels/w~217end.a80
	${SJASMPLUS} brfinal.asm
	${SJASMPLUS} main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	mkdir -p ${INSTALLDIR}/br
	cp ${NAME} *.dat ${INSTALLDIR}/br
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
