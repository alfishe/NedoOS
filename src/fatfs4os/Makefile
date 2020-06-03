# Supported environments:
#   GNU/Linux.
#
# Used tools:
#   GNU core utilities, GNU grep, GNU sed, tools/aspp.sh, GCC, unix2dos, Wine, IAR.

NAME		= fatfs.raw
SOURCES		= mylib.asm ff.c
TMPDIR		= tmp
OBJECTS		= \
 ${patsubst %.asm,${TMPDIR}/%.r01,${filter %.asm,${SOURCES}}} \
 ${patsubst %.c,${TMPDIR}/%.r01,${filter %.c,${SOURCES}}}
LINKER_FLAGS_FILE = ${TMPDIR}/fatfs.lnk
LISTING		= ${TMPDIR}/fatfs.lst
EXPORTS_FILE	= ../kernel/ffsfunc.asm
ASPP		= ../../tools/aspp.sh
IARDIR		= ../../iar
ICCZ80		= ${IARDIR}/bin/iccz80.exe
AZ80		= ${IARDIR}/bin/az80.exe
XLINK		= ${IARDIR}/bin/xlink.exe
IARINC		= ${IARDIR}/inc
IARLIB		= ${IARDIR}/lib
ifeq "${OS}" "Windows_NT"
WINE		=
else
UNIX2DOS	= unix2dos -q
WINE		= wine cmd /c
endif
ICCZ80FLAGS	= -S -v0 -ml -uua -q -e -K -gA -z9 -t4 -T -I${IARINC}/
DEPAS		= ${ASPP}
DEPAFLAGS	= -E -MM -I .
DEPCC		= gcc
DEPCFLAGS	= -E -MM -I .
DEPEXT		= d
DEPS		= \
 ${patsubst %.asm,%.${DEPEXT},${filter %.asm,${SOURCES}}} \
 ${patsubst %.c,%.${DEPEXT},${filter %.c,${SOURCES}}}

.DEFAULT_GOAL = all

.PHONY: empty all clean install install-doc

empty:
	@echo 'Usage: make [ all | clean | install | install-doc ]'

# Dependency generation rule (.r01 from .asm):
%.${DEPEXT}: %.asm
	${RM} $@ && ${DEPAS} ${DEPAFLAGS} -MT ${TMPDIR}/$*.r01 -MT $@ -MF $@ $<

# Dependency generation rule (.r01 from .c):
%.${DEPEXT}: %.c
	${RM} $@ && ${DEPCC} ${DEPCFLAGS} -MT ${TMPDIR}/$*.r01 -MT $@ -MF $@ $< || true

ifeq "${MAKECMDGOALS}" "empty"
else ifeq "${MAKECMDGOALS}" "clean"
else
include ${DEPS}
endif

${TMPDIR}:
	mkdir -p $@

${TMPDIR}/%.r01: %.asm | ${AZ80} ${TMPDIR}
	${WINE} ${AZ80} -S -O${@D}/ -uu $<

${TMPDIR}/%.r01 ${TMPDIR}/%.lst ${TMPDIR}/%.s01: %.c | ${ICCZ80} ${TMPDIR}
	${WINE} ${ICCZ80} ${ICCZ80FLAGS} -L${@D}/ -O${@D}/ -A${@D}/ $<

${LINKER_FLAGS_FILE}: | ${TMPDIR}
	echo '${OBJECTS}' > $@
	echo '-S -cZ80 -FRAW-BINARY -C ${IARLIB}/clz80 -o ${NAME} -l ${LISTING} -xe' >> $@
	echo '-Z(CODE)TRST,RCODE,CODE,CDATA0,CONST,CSTR,CCSTR,DATA0,IDATA0,UDATA0,ECSTR,NO_INIT,TEMP=4000-7FFF' >> $@
ifeq "${OS}" "Windows_NT"
else
	${UNIX2DOS} $@
endif

${NAME} ${LISTING}: ${LINKER_FLAGS_FILE} ${OBJECTS}
	${WINE} ${XLINK} -f $<

${EXPORTS_FILE}: ${LISTING}
	echo '; ${@F} - FatFS calls.' > $@
	echo '; This file is a part of NedoOS project.' >> $@
	echo '; Compatible compiler: sjasmplus.' >> $@
	echo '; This file was generated automatically while building FatFS.' >> $@
	echo 'ffsfunc' >> $@
	grep -Ee '^[[:space:]]+f_' $< | \
	sed -re 's/^[[:space:]]+(f_[^ ]+)[[:space:]]+([[:xdigit:]]{4})/.\1 EQU 0x\2/' >> $@
ifeq "${OS}" "Windows_NT"
else
	${UNIX2DOS} $@
endif

all: ${NAME} ${EXPORTS_FILE}

clean:
	${RM} -r ${TMPDIR}
	${RM} ${NAME} ${EXPORTS_FILE} ${DEPS}

install:

install-doc:
