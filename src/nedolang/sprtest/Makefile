INSTALLDIR	=
EXE		= main.bin
NAME		= spr
OBJECTS		= testpic.ast spr.ast spr.var spr.A_ spr.V_
SOURCES		= spr.c main.s logo testmusic.pt3 testpic.bmp testpic.da lvnt_1 bqiwo.afb
NEDOLANG	= ../_sdk/nedolang.bin
NEDOASM		= ../_sdk/nedoasm.bin
NEDOTOK		= ../_sdk/nedotok.bin
NEDOTRD		= ../../_sdk/nedotrd.bin
NEDOPAD		= ../../_sdk/nedopad.bin
NEDORES		= ../../_sdk/nedores.bin

all: ${EXE}

${EXE}: ${SOURCES} ${OBJECTS}
	${NEDOASM} main.S_
	cat asmerr.f

testpic.ast:
	${NEDORES} testpic.bmp testpic.da testpic.ast

%ast: testpic.ast
	${NEDOLANG} ${NAME}.c
	cat err.f

%.A_ %.V_: %.ast 
	${NEDOTOK} main.s  ../_sdk/sprite.i spr.ast spr.var ../_sdk/pt3play.i ../_sdk/ayfxplay.i ../_sdk/lib.i ../_sdk/runtime.i testpic.ast

clean: 
	rm -f ${NAME} ${OBJECTS} ${EXE}
	rm -f *.f *.D_ *.V_ *.S_ *.bin *.var *.org *.pst test.trd *.b *.A_

install: all
#	cp ${NAME} ${INSTALLDIR}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

trd: all
	${NEDOTRD} test.trd -n
	${NEDOTRD} ../batch/basics.trd -eh boot.b
	${NEDOTRD} test.trd -ah boot.b
	${NEDOTRD} test.trd -s 24576 -ac main.bin
