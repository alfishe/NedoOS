# Used tools:
#   GNU core utilities, aspp.sh, GCC, IAR, Wine, GNU grep, GNU sed, unix2dos.

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
WINE		= wine
ICCZ80FLAGS	= -S -v0 -ml -uua -q -e -K -gA -z9 -t4 -T -I${IARINC}/
DEPAS		= ${ASPP}
DEPAFLAGS	= -E -MM -I .
DEPCC		= gcc
DEPCFLAGS	= -E -MM -I .
DEPEXT		= d
DEPS		= \
 ${patsubst %.asm,%.${DEPEXT},${filter %.asm,${SOURCES}}} \
 ${patsubst %.c,%.${DEPEXT},${filter %.c,${SOURCES}}}

.DEFAULT_GOAL =

.PHONY: all clean install install-doc

# Dependency generation rule (.r01 from .asm):
%.${DEPEXT}: %.asm
	${RM} $@ && ${DEPAS} ${DEPAFLAGS} -MT ${TMPDIR}/$*.r01 -MT $@ -MF $@ $<

# Dependency generation rule (.r01 from .c):
%.${DEPEXT}: %.c
	${RM} $@ && ${DEPCC} ${DEPCFLAGS} -MT ${TMPDIR}/$*.r01 -MT $@ -MF $@ $< || true

IncludeDeps = 0
ifeq "${MAKECMDGOALS}" ""
IncludeDeps = 1
endif
ifeq "${MAKECMDGOALS}" "all"
IncludeDeps = 1
endif

ifeq "${IncludeDeps}" "1"
include ${DEPS}
endif

${TMPDIR}:
	mkdir -p $@

${TMPDIR}/%.r01: %.asm | ${AZ80} ${TMPDIR}
	${WINE} cmd /c ${AZ80} -S -O${@D}/ -uu $<

${TMPDIR}/%.r01 ${TMPDIR}/%.lst ${TMPDIR}/%.s01: %.c | ${ICCZ80} ${TMPDIR}
	${WINE} cmd /c ${ICCZ80} ${ICCZ80FLAGS} -L${@D}/ -O${@D}/ -A${@D}/ $<

${LINKER_FLAGS_FILE}: | ${TMPDIR}
	echo '${OBJECTS}' | unix2dos > $@ && \
	echo '-S -cZ80 -FRAW-BINARY -C ${IARLIB}/clz80 -o ${NAME} -l ${LISTING} -xe' | unix2dos >> $@ && \
	echo '-Z(CODE)TRST,RCODE,CODE,CDATA0,CONST,CSTR,CCSTR,DATA0,IDATA0,UDATA0,ECSTR,NO_INIT,TEMP=4000-7FFF' | unix2dos >> $@

${NAME} ${LISTING}: ${LINKER_FLAGS_FILE} ${OBJECTS}
	${WINE} cmd /c ${XLINK} -f $<

${EXPORTS_FILE}: ${LISTING}
	echo '; ${@F} - FatFS calls.' | unix2dos > $@ && \
	echo '; This file is a part of NedoOS project.' | unix2dos >> $@ && \
	echo '; Compatible compiler: sjasmplus.' | unix2dos >> $@ && \
	echo '; This file was generated automatically while building FatFS.' | unix2dos >> $@ && \
	echo 'ffsfunc' | unix2dos >> $@ && \
	grep -Ee '^[[:space:]]+f_' $< | \
	sed -re 's/^[[:space:]]+(f_[^ ]+)[[:space:]]+([[:xdigit:]]{4})/.\1 EQU 0x\2/' | unix2dos >> $@

all: ${NAME} ${EXPORTS_FILE}

clean:
	${RM} -r ${TMPDIR}
	${RM} ${NAME} ${EXPORTS_FILE} ${DEPS}

install:

install-doc:
