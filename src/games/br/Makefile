NAME		= br.com
OBJECTS		= 
SOURCES		= main.asm brfinal.asm
SJASMPLUS	= ../../../tools/sjasmplus --nologo --msg=war
NEDORES		= ../../_sdk/nedores.bin
INSTALLDIR	= ../../../release/nedogame/br

all: ${NAME} ${SOURCES}

br.com: ${SOURCES} resources modules level
	${SJASMPLUS} brfinal.asm
	${SJASMPLUS} main.asm

level: ${SOURCES}
	${SJASMPLUS} levels/w~104.a80
	${SJASMPLUS} levels/w~107.a80
	${SJASMPLUS} levels/w~112.a80
	${SJASMPLUS} levels/w~117end.a80
	${SJASMPLUS} levels/w~205.a80
	${SJASMPLUS} levels/w~213.a80
	${SJASMPLUS} levels/w~217end.a80

modules: ${SOURCES}
	${SJASMPLUS} W1LAND.ast --raw=br/W1LAND.bin
	${SJASMPLUS} W2LAND.ast --raw=br/W2LAND.bin
	${SJASMPLUS} W3LAND.ast --raw=br/W3LAND.bin
	${SJASMPLUS} W4LAND.ast --raw=br/W4LAND.bin
	${SJASMPLUS} WBAR.ast --raw=br/WBAR.bin
	${SJASMPLUS} WHUMBUTT.ast --raw=br/W0BUT.bin
	${SJASMPLUS} WORCBUTT.ast --raw=br/W1BUT.bin
	${SJASMPLUS} WHUM1.asm
	${SJASMPLUS} WHUM1b.asm
	${SJASMPLUS} WHUM1c.asm
	${SJASMPLUS} WHUMCAT.asm
	${SJASMPLUS} WHUMHOR.asm
	${SJASMPLUS} WORC1.asm
	${SJASMPLUS} WORC1b.asm
	${SJASMPLUS} WORC1c.asm
	${SJASMPLUS} WORCCAT.asm
	${SJASMPLUS} WORCHOR.asm
	${SJASMPLUS} WCREAT1.asm
	${SJASMPLUS} WCREAT1b.asm
	${SJASMPLUS} WCREAT1c.asm
	${SJASMPLUS} WCREAT2.asm
	${SJASMPLUS} WCREAT2b.asm
	${SJASMPLUS} WCREAT2c.asm
#	${SJASMPLUS} WBODY.asm
	${SJASMPLUS} WBULLET.asm

resources: 
	${NEDORES} images/W1LAND.bmp images/W1LAND.dat W1LAND.ast
	${NEDORES} images/W2LAND.bmp images/W2LAND.dat W2LAND.ast
	${NEDORES} images/W3LAND.bmp images/W3LAND.dat W3LAND.ast
	${NEDORES} images/W4LAND.bmp images/W4LAND.dat W4LAND.ast
	${NEDORES} images/WBAR.bmp images/WBAR.dat WBAR.ast
	${NEDORES} images/WHUMBUTT.bmp images/WHUMBUTT.dat WHUMBUTT.ast
	${NEDORES} images/WORCBUTT.bmp images/WORCBUTT.dat WORCBUTT.ast
	${NEDORES} images/WHUM1.bmp images/WHUM1.dat WHUM1.ast
	${NEDORES} images/WHUM1.bmp images/WHUM1b.dat WHUM1b.ast
	${NEDORES} images/WHUM1.bmp images/WHUM1c.dat WHUM1c.ast
	${NEDORES} images/WHUM2.bmp images/WHUMCAT.dat WHUMCAT.ast
	${NEDORES} images/WHUM2.bmp images/WHUMHOR.dat WHUMHOR.ast
	${NEDORES} images/WORC1.bmp images/WORC1.dat WORC1.ast
	${NEDORES} images/WORC1.bmp images/WORC1b.dat WORC1b.ast
	${NEDORES} images/WORC1.bmp images/WORC1c.dat WORC1c.ast
	${NEDORES} images/WORC2.bmp images/WORCCAT.dat WORCCAT.ast
	${NEDORES} images/WORC2.bmp images/WORCHOR.dat WORCHOR.ast
	${NEDORES} images/WCREAT1.bmp images/WCREAT1.dat WCREAT1.ast
	${NEDORES} images/WCREAT1.bmp images/WCREAT1b.dat WCREAT1b.ast
	${NEDORES} images/WCREAT1.bmp images/WCREAT1c.dat WCREAT1c.ast
	${NEDORES} images/WCREAT2.bmp images/WCREAT2.dat WCREAT2.ast
	${NEDORES} images/WCREAT2.bmp images/WCREAT2b.dat WCREAT2b.ast
	${NEDORES} images/WCREAT2.bmp images/WCREAT2c.dat WCREAT2c.ast
	${NEDORES} images/WMISC.bmp images/WBODY.dat WBODY.ast
	${NEDORES} images/WMISC.bmp images/WBULLET.dat WBULLET.ast

clean: 
	rm -f ${NAME} ${OBJECTS}
install: all
	mkdir -p ${INSTALLDIR} || echo
	cp br/* ${INSTALLDIR}
	cp ${NAME} ${INSTALLDIR}
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

