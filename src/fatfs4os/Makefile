# Supported environments:
#   GNU/Linux.
#
# Used tools:
#   GNU core utilities, GNU grep, GNU sed, tools/aspp.sh, Wine, IAR.

include ../_sdk/common.mk
include ../_sdk/iar.mk

NAME		= fatfs.raw
SOURCES		= mylib.asm ff.asm
EXPORTS_FILE	= ../kernel/ffsfunc.asm
TMPDIR		= tmp
ASPP		= ../../tools/aspp.sh
IARDIR		= ../../iar
IAR_LIBDIR	= ${IARDIR}/lib
IAR_AZ80	= ${IARDIR}/bin/az80.exe
IAR_XLINK	= ${IARDIR}/bin/xlink.exe
IAR_AZ80FLAGS	= -S -uu
IAR_XLINKFLAGS	= -S
ifeq "${OS}" "Windows_NT"
WINE		=
else
WINE		= wine cmd /c
endif
DEPAS		= env LC_CTYPE=C ${ASPP}
DEPAFLAGS	= -E -MM -I .
DEPEXT		= d

# All targets
.PHONY: empty all install install-doc clean

.DEFAULT_GOAL=all

empty:
	@echo 'Usage: make [ all | install | install-doc | clean ]'

# Clear lists
DEPS=
OBJECTS=
TMPS=

# Create directories
${sort \
${TMPDIR} \
}:
	mkdir -p $@

####################
## Common targets ##
####################

fatfs_XCL=${TMPDIR}/fatfs.xcl
fatfs_LST=${TMPDIR}/fatfs.lst

# mylib.asm
${TMPDIR}/mylib.r01: | ${TMPDIR}
${eval ${call iar_az80_rule,${TMPDIR}/mylib.r01,mylib.asm,-O${TMPDIR}/ -L${TMPDIR}/,DEPS,OBJECTS}}
TMPS+=${TMPDIR}/mylib.lst

# ff.asm
${TMPDIR}/ff.r01: | ${TMPDIR}
${eval ${call iar_az80_rule,${TMPDIR}/ff.r01,ff.asm,-O${TMPDIR}/ -L${TMPDIR}/,DEPS,OBJECTS}}
TMPS+=${TMPDIR}/ff.lst

${fatfs_XCL}: ${OBJECTS} | ${TMPDIR}
	echo '$^ ' > $@
	echo '-cZ80 -FRAW-BINARY -C ${IAR_LIBDIR}/clz80 -o ${NAME} -l ${fatfs_LST} -xe ' >> $@
	echo '-Z(CODE)TRST,RCODE,CODE,CDATA0,CONST,CSTR,CCSTR,DATA0,IDATA0,UDATA0,ECSTR,NO_INIT,TEMP=4000-7FFF ' >> $@

${NAME} ${fatfs_LST}: ${fatfs_XCL} | ${TMPDIR}
	${WINE} ${IAR_XLINK} ${IAR_XLINKFLAGS} -f $<

${EXPORTS_FILE}: ${fatfs_LST}
	echo '; ${@F} - FatFS calls.' > $@
	echo '; This file is a part of NedoOS project.' >> $@
	echo '; Compatible compiler: sjasmplus.' >> $@
	echo '; This file was generated automatically while building FatFS.' >> $@
	echo 'ffsfunc' >> $@
	grep -Ee '^[[:space:]]+f_' $< | \
	sed -re 's/^[[:space:]]+(f_[^ ]+)[[:space:]]+([[:xdigit:]]{4})/.\1 EQU 0x\2/' >> $@

all: ${NAME} ${EXPORTS_FILE}

install: all

install-doc:

clean:
	${RM} ${DEPS} ${OBJECTS} ${TMPS} ${fatfs_XCL} ${fatfs_LST} ${NAME} ${EXPORTS_FILE}
	${RM} -r ${TMPDIR}

##################
## Dependencies ##
##################

ifneq "${sort \
${filter empty,${MAKECMDGOALS}} \
${filter clean,${MAKECMDGOALS}} \
}" ""
else
# FIXME: Triggered when multiple targets specified.
include ${DEPS}
endif
