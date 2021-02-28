INSTALLDIR	= ../../../release/bin
EXE		= nedodel
NAME		= del
OBJECTS		= del.ast del.var del.A_ del.S_ del.V_
SOURCES		= del.c del.s
NEDOLANG	= ../_sdk/nedolang.bin
NEDOASM		= ../_sdk/nedoasm.bin
NEDOTOK		= ../_sdk/nedotok.bin
NEDOTRD		= ../../_sdk/nedotrd.bin

all: ${EXE}

${EXE}: ${SOURCES} ${OBJECTS}
	${NEDOASM} ${NAME}.S_
	cat asmerr.f
	cp -f ${NAME}.bin ${NAME}

%.ast %.var:
	${NEDOLANG} ${NAME}.c ../_sdk/io.c
	cat err.f

%.A_ %.S_ %.V_: %.ast
	${NEDOTOK} ${NAME}.s ${NAME}.ast ${NAME}.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i


clean: 
	rm -f ${NAME} ${OBJECTS}
	rm -f *.f *.D_ *.V_ *.bin *.var *.org *.pst

install: all
	cp ${NAME} ${INSTALLDIR}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

trd: all
	${NEDOTRD} ../test.trd -a ../modedisk/movedisk
	${NEDOTRD} ../test.trd -a nedodel

