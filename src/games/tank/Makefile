NAME		= tank.com
OBJECTS		= sprset.ast tileset.ast
SOURCES		= collisio.asm collisio.asm input.asm macro.asm main.asm math.asm sprite.asm tankdata.asm tankgfx.asm sprset.bmp tileset.bmp tileset.da sprset.da zx.fnt
SJASMPLUS	= ../../../tools/sjasmplus
NEDORES		= ../../_sdk/nedores.bin
INSTALLDIR	= ../../../release/games

all: ${NAME} ${SOURCES}

tank.com: ${SOURCES} ${OBJECTS}
	${SJASMPLUS} --nologo main.asm

sprset.ast: sprset.bmp
	${NEDORES} sprset.bmp sprset.da sprset.ast

tileset.ast: tileset.bmp
	${NEDORES} tileset.bmp tileset.da tileset.ast

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	cp ${NAME} ${INSTALLDIR}
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
