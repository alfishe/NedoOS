TOOLINSTALLDIR	= ../_sdk
TOOL		= nedoexp.bin
TOOL_SOURCES	= expmain.c export.c exporttg.c
NAME		= exp
OBJECTS		= export.ast export.var exporttg.ast exporttg.var export.A_ export.V_ exporttg.A_ exporttg.V_
SOURCES		= expmain.c export.c exporttg.c exp.s
NEDOASM		= ../_sdk/nedoasm.bin
NEDOLANG	= ../_sdk/nedolang.bin
NEDOTOK		= ../_sdk/nedotok.bin
NEDOTRD		= ../../_sdk/nedotrd.bin
INSTALLDIR	= ../../../release/bin

GCC		= gcc
CFLAGS		= -m32

all: ${NAME}
	

tools: ${TOOL}
	

${NAME}: ${OBJECTS} ${SOURCES}
	${NEDOASM} exp.S_
	cat asmerr.f
	cp exp.bin ${NAME}

%.ast %.var: ${SOURCES}
	${NEDOLANG} export.c ../_sdk/fmttg.h exporttg.c ../_sdk/io.c
	cat err.f

%.V_ %.A_: %.ast %.var ${SOURCES}
	${NEDOTOK} exp.s ../_sdk/fmttg.var export.ast export.var exporttg.ast exporttg.var ../_sdk/lib.i ../_sdk/str.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/print.i
	cp export.A_ tok.f

${TOOL}: ${TOOL_SOURCES}
	${GCC} ${CFLAGS} expmain.c -o ${TOOL}

clean-tools:
	rm -f ${TOOL}

clean:
	rm -f ${OBJECTS} ${NAME} asmerr.f err.f *.D_ *.bin *.org *.pst *.S_ *.f

install: all
#	cp ${NAME} ${INSTALLDIR}

install-tools: tools
	cp ${TOOL} ${TOOLINSTALLDIR}

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc


trd: all
	${NEDOTRD} ../batch/basics.trd -eh exp.b
	${NEDOTRD} test.trd -n
	${NEDOTRD} test.trd -ah exp.b
	${NEDOTRD} test.trd -ac exp
	${NEDOTRD} test.trd -a tok.f

