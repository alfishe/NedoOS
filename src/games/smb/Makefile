NAME		= smb.com
OBJECTS		=
SOURCES		= main.asm 6502.asm 6502fast.asm main.asm nesconst.asm nu.asm smbconst.asm smbmusic.asm smbsound.asm tileattr.asm smb.nes
SJASMPLUS	= ../../../tools/sjasmplus
INSTALLDIR	= ../../../release


all: ${NAME} ${SOURCES}

${NAME}: ${SOURCES}
	${SJASMPLUS} --nologo main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

