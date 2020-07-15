INSTALLDIR	= ../../../release/bin
EXE		= code
NAME		= demo
OBJECTS		= demo.ast demo.var demo.V_ demo.A_ demo.S_ demoproc.S_ font.bin net35.bin nettort.bin
SOURCES		= demo.c demo.s demoproc.s logo lvnt_1 net1.s net-35.s net-lvd.s net-nop.s net.s net-tort.s testmusi.pt3
NEDOLANG	= ../_sdk/nedolang.bin
NEDOASM		= ../_sdk/nedoasm.bin
NEDOTOK		= ../_sdk/nedotok.bin
NEDOTRD		= ../../_sdk/nedotrd.bin
NEDOPAD		= ../../_sdk/nedopad.bin

all: ${NAME}.bin

${NAME}.bin: ${SOURCES} ${OBJECTS}
	${NEDOASM} ${NAME}.S_
	cat asmerr.f
	cp -f ${NAME}.bin ${EXE}

%.ast %.var:
	${NEDOLANG} ${NAME}.c 
	cat err.f

%.A_ %.S_ %.V_: %.ast
	${NEDOTOK} ${NAME}.s demoproc.s ${NAME}.ast ${NAME}.var ../_sdk/pt3play.i ../_sdk/lib.i

font.bin net35.bin nettort.bin:
	${NEDOPAD} lvnt_1 font.bin 0 2048
	${NEDOPAD} net-35.s net35.bin 6144 768
	${NEDOPAD} net-tort.s nettort.bin 6144 768

clean: 
	rm -f ${NAME} ${OBJECTS} ${EXE}
	rm -f *.f *.D_ *.V_ *.S_ *.bin *.var *.org *.pst *.b test.trd

install:
	cp ${EXE} ${INSTALLDIR}/${NAME}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc

trd: all
	${NEDOTRD} basics.trd -eb net-35.s
	${NEDOTRD} basics.trd -eb net-tort.s
	${NEDOTRD} basics.trd -eh NedoGift.b
	${NEDOTRD} test.trd -n 
	${NEDOTRD} test.trd -ah NedoGift.b
	${NEDOTRD} test.trd -ac code
