TOOLS		= asm comp exp tok
PROGS		= asm batch comp diff exp movedisk nedodel nedogift sprtest tok
TRDSOURCES	= batch/basics.trd
NEDOTRD		= ../_sdk/nedotrd.bin

all: tools install-tools ${PROGS}

.PHONY: ${PROGS}

${PROGS}:
	${MAKE} -w -C $@

tools:
	for d in ${TOOLS}; do ${MAKE} -w -C $$d tools; done

clean-tools:
	for d in ${TOOLS}; do ${MAKE} -w -C $$d clean-tools; done

install-tools:
	for d in ${TOOLS}; do ${MAKE} -w -C $$d install-tools; done

install-doc:
	for d in ${PROGS}; do ${MAKE} -w -C $$d install-doc; done

clean: clean-tools
	for d in ${PROGS}; do ${MAKE} -w -C $$d clean; done
	rm -f test.trd

install: all
	for d in ${PROGS}; do ${MAKE} -w -C $$d install; done

trd: ${TRDSOURCES} all
	for d in ${PROGS}; do ${MAKE} -w -C $$d trd; done
	${NEDOTRD} batch/basics.trd -eh batch/batch.b
	${NEDOTRD} test.trd -n
	${NEDOTRD} test.trd -ah batch/batch.b
	${NEDOTRD} test.trd -s 64000 -ac batch/batch
	${NEDOTRD} test.trd -a asm/compile.bat
	${NEDOTRD} test.trd -a comp/nedotok
	${NEDOTRD} test.trd -a tok/nedotok
	${NEDOTRD} test.trd -a asm/nedoasm
	${NEDOTRD} test.trd -a diff/diff
	${NEDOTRD} test.trd -a _sdk/str.h
	${NEDOTRD} test.trd -a _sdk/io.h
	${NEDOTRD} test.trd -a _sdk/emit.h
	${NEDOTRD} test.trd -a _sdk/emit.c
	${NEDOTRD} test.trd -a _sdk/fmttg.h
	${NEDOTRD} test.trd -a _sdk/fmtz80.h
	${NEDOTRD} test.trd -a asm/asm.c
	${NEDOTRD} test.trd -a asm/asmloop.c
	${NEDOTRD} test.trd -a asm/asmf_z80.c
	${NEDOTRD} test.trd -a asm/asmj.c
	${NEDOTRD} test.trd -a asm/asmj_z80.c
	${NEDOTRD} test.trd -a asm/asm.s
	${NEDOTRD} test.trd -a _sdk/lib.i
	${NEDOTRD} test.trd -a _sdk/str.i
	${NEDOTRD} test.trd -a _sdk/iofast.i
	${NEDOTRD} test.trd -a _sdk/io.c

