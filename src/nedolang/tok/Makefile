TOOLINSTALLDIR	= ../_sdk
INSTALLDIR	= ../../../release
TOOL		= nedotok.bin
TOOL_SOURCES	= armmain.c tokenarm.c token.c tokenz80.c tokmain.c z80main.c
NAMEOS		= tok.com
NAME		= nedotok
OBJECTS		= token.ast token.var tokenz80.ast tokenz80.var token.A_ token.V_ tokenz80.A_ tokenz80.V_
SOURCES		= armmain.c tokenarm.c token.c tokenz80.c tokmain.c z80main.c tok.s tok_os.s _tokarm.s
NEDOLANG	= ../_sdk/nedolang.bin
NEDOTOK		= ../_sdk/nedotok.bin
NEDOASM		= ../_sdk/nedoasm.bin

GCC		= gcc
CFLAGS		= -m32 

all: ${NAMEOS}

${NAME}: lang tok ${SOURCES}
	${NEDOASM} tok.S_
	cat asmerr.f
	cp tok.bin ${NAME}

${NAMEOS}: lang.os tok.os ${SOURCES}
	${NEDOASM} tok_os.S_
	cat asmerr.f
	cp tok_os.bin ${NAMEOS}

lang: ${SOURCES}
	${NEDOLANG} ../_sdk/read.c ../_sdk/fmttg.h token.c tokenz80.c ../_sdk/io.c
	cat err.f

lang.os: ${SOURCES}
	${NEDOLANG} ../_sdk/read.c ../_sdk/fmttg.h token.c tokenz80.c 
	cat err.f

tok: lang ${SOURCES}
	${NEDOTOK} tok.s ../_sdk/read.ast ../_sdk/read.var ../_sdk/fmttg.var token.ast token.var tokenz80.ast tokenz80.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i

tok.os: lang.os ${SOURCES} 
	${NEDOTOK} tok_os.s ../_sdk/read.ast ../_sdk/read.var ../_sdk/fmttg.var token.ast token.var tokenz80.ast tokenz80.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm

tools: ${TOOL} 

${TOOL}: ${TOOL_SOURCES}
	${GCC} ${CFLAGS} z80main.c -o ${TOOL}

clean-tools: 
	rm -f ${TOOL}

clean: 
	rm -f ${NAME} ${OBJECTS} ${NAMEOS}
	rm -f *.f *.D_ *.V_ *.bin *.var *.org *.pst *.S_

install: ${NAMEOS}
	cp ${NAMEOS} ${INSTALLDIR}/bin

install-tools: tools
	cp ${TOOL} ${TOOLINSTALLDIR}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

trd: ${NAME}

#diff nedotok tok.bin