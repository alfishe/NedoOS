INSTALLDIR	= ../../../release/bin
NAME		= movedisk
OBJECTS		= movedisk.ast movedisk.var movedisk.A_ movedisk.S_ movedisk.V_
SOURCES		= movedisk.c movedisk.s
NEDOLANG	= ../_sdk/nedolang.bin
NEDOASM		= ../_sdk/nedoasm.bin
NEDOTOK		= ../_sdk/nedotok.bin
NEDOTRD		= ../../_sdk/nedotrd.bin

all: ${NAME} 

${NAME}: ${SOURCES} ${OBJECTS}
	${NEDOASM} movedisk.S_
	cat asmerr.f
	mv -f movedisk.bin ${NAME}

%.ast %.var:
	${NEDOLANG} movedisk.c ../_sdk/io.c
	cat err.f

%.A_ %.S_ %.V_: %.ast
	${NEDOTOK} movedisk.s movedisk.ast movedisk.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i


clean: 
	rm -f ${NAME} ${OBJECTS}
	rm -f *.f *.D_ *.V_ *.bin *.var *.org *.pst

install: all
#	cp ${NAME} ${INSTALLDIR}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

trd: all
	${NEDOTRD} ../test.trd -a movedisk
	${NEDOTRD} ../test.trd -a ../nedodel/nedodel

