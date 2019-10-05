INSTALLDIR	= ../../release/games/evsummer
GAMEINSTALLDIR	= ../../../sd/evsummer
NAME		= evsummer.com
OBJECTS		= game.o
TOOLS		= convert convfont
SOURCES		= main.asm game.asm graphics.asm music.asm font.asm
SJASMPLUS	= ../../tools/sjasmplus
GCC		= gcc -m32

all: ${NAME} ${SOURCES}

${NAME}: ${SOURCES}
	${SJASMPLUS} --nologo --nofakes main.asm

tools: convert convfont
	

convert: convert.c
	${GCC} convert.c -o convert

convfont: convfont.c
	${GCC} convfont.c -o convfont

clean: 
	rm -f ${NAME} ${OBJECTS}

clean-tools:
	rm -f ${NAME} ${TOOLS}

arc:
	zip summer.zip -r txt pic evsummer.com game.o
	sudo cp summer.zip /var/www

install: all
	mkdir -p ${INSTALLDIR}
	cp -r txt pic evsummer.com game.o ${INSTALLDIR}

install-doc: ${DOC}
#	cp ${DOC} ${INSTALLDIR}/doc
