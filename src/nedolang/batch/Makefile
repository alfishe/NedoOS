INSTALLDIR	= 
NAME		= batch
OBJECTS		= batch.ast batch.var batch.A_ batch.S_ batch.V_
SOURCES		= batch.c batch.s
NEDOLANG	= ../_sdk/nedolang.bin
NEDOASM		= ../_sdk/nedoasm.bin
NEDOTOK		= ../_sdk/nedotok.bin
NEDOTRD		= ../../_sdk/nedotrd.bin

all: ${NAME} 

${NAME}: ${SOURCES} ${OBJECTS}
	${NEDOASM} ${NAME}.S_
	cat asmerr.f
	cp -f ${NAME}.bin ${NAME}

%.ast %.var:
	${NEDOLANG} ${NAME}.c
	cat err.f

%.A_ %.S_ %.V_: %.ast
	${NEDOTOK} ${NAME}.s ${NAME}.ast ${NAME}.var ../_sdk/lib.i ../_sdk/iofast.i


clean: 
	rm -f ${NAME} ${OBJECTS}
	rm -f *.f *.D_ *.V_ *.bin *.var *.org *.pst

install: all
#	cp ${NAME} ${INSTALLDIR}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

trd: ${NAME}
