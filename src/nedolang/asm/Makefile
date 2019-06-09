TOOLINSTALLDIR	= ../_sdk
TOOL		= nedoasm.bin
TOOL_SOURCES	= asm.c asmf_arm.c asmf_z80.c asmj_arm.c asmj.c asmj_z80.c asmloop.c asmmain.c z80main.c
INSTALLDIR	= ../../../release
NAMEOS		= asm.com
NAME		= nedoasm
OBJECTS		= asm.ast asm.var asmloop.ast asmloop.var asm.A_ asm.S_ asmloop.A_ asmloop.S_ asmloop.V_
SOURCES	= asm.s asm_os.s asm.c asmf_arm.c asmf_z80.c asmj_arm.c asmj.c asmj_z80.c asmloop.c asmmain.c z80main.c 
GCC		= gcc
CFLAGS		= -m32 
NEDOLANG	= ../_sdk/nedolang.bin
NEDOASM		= ../_sdk/nedoasm.bin
NEDOTOK		= ../_sdk/nedotok.bin
NEDOTRD		= ../../_sdk/nedotrd.bin

all: ${NAMEOS}

tools: ${TOOL}

${NAME}: lang tok ${SOURCES}
	${NEDOASM} asm.S_
	cat asmerr.f
	cp -f asm.bin ${NAME}

lang: ${SOURCES}
	${NEDOLANG} ../_sdk/emit.c ../_sdk/fmttg.h asm.c asmloop.c ../_sdk/io.c
	cat err.f

tok: lang ${SOURCES}
	${NEDOTOK} asm.s ../_sdk/emit.ast ../_sdk/emit.var ../_sdk/fmttg.var asm.ast asm.var asmloop.ast asmloop.var ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i

lang.os: ${SOURCES}
	${NEDOLANG} ../_sdk/emit.c ../_sdk/fmttg.h asm.c asmloop.c
	cat err.f

tok.os: lang.os ${SOURCES}
	${NEDOTOK} asm_os.s ../_sdk/emit.ast ../_sdk/emit.var ../_sdk/fmttg.var asm.ast asm.var asmloop.ast asmloop.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm

${NAMEOS}: lang.os tok.os ${SOURCES}
	${NEDOASM} asm_os.S_
	cat asmerr.f
	cp asm_os.bin ${NAMEOS}

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

