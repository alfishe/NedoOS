NAME		= browser.com
OBJECTS		= 
SOURCES		= browser.asm drawmc.asm dynmem.asm editline.asm file.asm gif.asm html.asm htmlview.asm http.asm jpeg.asm mempgs.asm nu.asm png.asm prmc.asm prvirt.asm
RESOURCE	= 
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release

all: ${NAME} ${SOURCES}

browser.com: ${SOURCES}
	${SJASMPLUS} --nologo browser.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
