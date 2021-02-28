INSTALLDIR	= ../../../release/bin
NAME		= diff
OBJECTS		= diff.ast diff.var diff.A_ diff.S_ diff.V_
SOURCES		= diff.c diff.s diff_os.s
NEDOLANG	= ../_sdk/nedolang.bin
NEDOASM		= ../_sdk/nedoasm.bin
NEDOTOK		= ../_sdk/nedotok.bin

all: ${NAME} 

${NAME}: ${SOURCES} ${OBJECTS}
	${NEDOASM} ${NAME}.S_
	cat asmerr.f
	cp -f diff.bin ${NAME}

%.ast %.var:
	${NEDOLANG} ${NAME}.c ../_sdk/io.c
	cat err.f

%.A_ %.S_ %.V_: %.ast
	${NEDOTOK} ${NAME}.s ${NAME}.ast ${NAME}.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/print.i ../_sdk/str.i


clean: 
	rm -f ${NAME} ${OBJECTS}
	rm -f *.f *.D_ *.V_ *.bin *.var *.org *.pst

install: all
#	cp ${NAME} ${INSTALLDIR}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

trd: ${NAME}
