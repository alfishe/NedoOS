TOOLINSTALLDIR	= ../_sdk
INSTALLDIR	= ../../../release
TOOL		= nedolang.bin
TOOL_SOURCES	= armmain.c codearm.c codez80.c commands.c compile.c compmain.c regs.c z80main.c
NAMEOS		= comp.com
NAME		= nedolang
OBJECTS		= commands.ast commands.var commands.V_ commands.A_ compcode.S_ compcode.bin compile.ast compile.var compile._V compile.A_ comp.bin label.f
SOURCES		= comp.s comp_os.s compc_os.s armmain.c codearm.c codez80.c commands.c compile.c compmain.c regs.c z80main.c
GCC		= gcc
CFLAGS		= -m32 
NEDOLANG	= ../_sdk/nedolang.bin
NEDOASM		= ../_sdk/nedoasm.bin
NEDOTOK		= ../_sdk/nedotok.bin

GCC		= gcc
CFLAGS		= -m32

all: ${NAMEOS}

lang: ${SOURCES} 
	${NEDOLANG} ../_sdk/emit.c ../_sdk/io.c commands.c
	cat err.f

tok: lang ${SOURCES}
	${NEDOTOK} compcode.s ../_sdk/emit.ast ../_sdk/emit.var commands.ast commands.var ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i

${NAME}: lang tok ${SOURCES}
	${NEDOASM} compcode.S_
	cat asmerr.f
	cp compcode.bin ${NAME}

compcode.bin: compcode.S_
	${NEDOASM} compcode.S_
	cat asmerr.f

lang.1: ${SOURCES}
	${NEDOLANG} ../_sdk/emit.c commands.c
	cat err.f

tok.1: lang.1 ${SOURCES}
	${NEDOTOK} nedotok compc_os.s ../_sdk/emit.ast ../_sdk/emit.var commands.ast commands.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm

compc_os.bin: lang.1 tok.1 ${SOURCES}
	${NEDOASM} compc_os.S_
	cat asmerr.f

lang.2: compc_os.bin ${SOURCES}
	${NEDOLANG} ../_sdk/read.c compile.c
	cat err.f

tok.2: lang.2 ${SOURCES}
	${NEDOTOK} comp_os.s ../_sdk/read.ast ../_sdk/read.var compile.ast compile.var

${NAMEOS}: lang.2 tok.2 ${SOURCES}
	${NEDOASM} comp_os.S_
	cat asmerr.f
	cp comp_os.bin ${NAMEOS}

tools: ${TOOL}

${TOOL}: ${TOOL_SOURCES}
	${GCC} ${CFLAGS} z80main.c -o ${TOOL}

clean: 
	rm -f ${NAME} ${OBJECTS} ${NAMEOS}
	rm -f *.f *.D_ *.V_ *.A_ *.S_ *.bin *.var *.org *.pst

clean-tools: 
	rm -f ${TOOL}

install: ${NAMEOS}
	cp ${NAMEOS} ${INSTALLDIR}/bin

install-tools: tools
	cp ${TOOL} ${TOOLINSTALLDIR}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

trd: ${NAME}

