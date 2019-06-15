NAME		= tank.com
OBJECTS		= sprset.ast tileset.ast
SOURCES		= collisio.asm input.asm macro.asm main.asm math.asm sprite.asm tankdata.asm tankgfx.asm sprset.bmp tileset.bmp zx.fnt
SJASMPLUS	= ../../../tools/sjasmplus
NEDORES		= ../../_sdk/nedores.bin
INSTALLDIR	= ../../../release

all: ${NAME} ${SOURCES}

tank.com: ${SOURCES} ${OBJECTS}
	${SJASMPLUS} --nologo main.asm

sprset.ast: sprset.bmp
	${NEDORES} sprset.bmp spriteset.txt sprset.ast

tileset.ast: tileset.bmp
	${NEDORES} tileset.bmp tileset.txt tileset.ast

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
