# Supported environments:
#   GNU/Linux.
#
# Used tools:
#   GNU core utilities, tools/aspp.sh, tools/sjasmplus, tools/mhmt.

include ../_sdk/common.mk

NAME		= code.c
OBJECTS		=
SOURCES		= main.asm
ASPP		= ../../tools/aspp.sh
SJASMPLUS	= ../../tools/sjasmplus
SJASMPLUSFLAGS	= --nologo --msg=war
MHMT		= ../../tools/mhmt
DEPAS		= env LC_CTYPE=C ${ASPP}
DEPAFLAGS	= -E -MM -I .
DEPEXT		= d
DEPS		= ${patsubst %.asm,%.${DEPEXT},${filter %.asm,${SOURCES}}}

# All targets
.PHONY: empty all install install-doc clean

.DEFAULT_GOAL=all

empty:
	@echo 'Usage: make [ all | install | install-doc | clean ]'

# Clear lists
DEPS=
BINS=

# External dependencies
../fatfs4os/fatfs.raw ffsfunc.asm:
	${MAKE} -w -C ../fatfs4os

####################
## Common targets ##
####################

${eval ${call sjasmplus_odd_rule,initcode.c syscode.c user.l,${SOURCES},,DEPS,BINS}}

syscode.c.mlz: syscode.c
	${MHMT} -mlz $<
BINS+=syscode.c.mlz

# The order of files does matter!
${NAME}: initcode.c syscode.c.mlz
	cat $^ > $@
BINS+=${NAME}

all: ${NAME}

install: all

install-doc:

clean:
	${RM} ${DEPS} ${BINS}

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
