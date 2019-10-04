NAME		= wolf3d.com
OBJECTS		= wolftex.0 wolftex.1 wolftex.2 wolftex.3 wolftex.4
SOURCES		= main.asm genscale.asm WREND.asm WCTRL.asm WATM2.asm WSCAN10.asm
SJASMPLUS	= ../../../tools/sjasmplus
INSTALLDIR	= ../../../release/games

all: ${NAME} ${SOURCES}

wolf3d.com: ${SOURCES}
	${SJASMPLUS} --nologo main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	mkdir -p ${INSTALLDIR}/wolf3d
	mkdir -p ${INSTALLDIR}/wolf3d/wolf3d
	cp ${OBJECTS} ${NAME} ${INSTALLDIR}/wolf3d/wolf3d
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
