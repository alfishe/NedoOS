# Supported environments:
#   GNU/Linux.
#
# Used tools:
#   GNU core utilities, tools/aspp, tools/sjasmplus, tools/mhmt.

include ../_sdk/common.mk

NAME		= code.c
OBJECTS		=
SOURCES		= main.asm
MHMT		= ../../tools/mhmt
DEPS		= ${patsubst %.asm,%.${DEPEXT},${filter %.asm,${SOURCES}}}

# All targets
.PHONY: empty hobeta clean-hobeta all install install-doc clean

.DEFAULT_GOAL=all

empty:
	@echo 'Usage: make [ hobeta | clean-hobeta | all | install | install-doc | clean ]'

# Clear lists
DEPS=
BINS=

# External dependencies
../fatfs4os/fatfs.raw ffsfunc.asm:
	${MAKE} -w -C ../fatfs4os

############
## hobeta ##
############

HOBETA_BINS=

# Dependency generation rule for .asm file:
hobeta.${DEPEXT}: hobeta.asm
	${RM} $@ && ${DEPAS} ${DEPAFLAGS} -MT nedoos.\$$C -MT $@ -MF $@ $<
DEPS+=hobeta.${DEPEXT}
# FIXME: No output file specified here (we must check sources manually):
nedoos.$$C: hobeta.asm
	${SJASMPLUS} ${SJASMPLUSFLAGS} $<
HOBETA_BINS+=nedoos.\$$C

hobeta: nedoos.$$C

clean-hobeta:
	${RM} ${HOBETA_BINS}

BINS+=${HOBETA_BINS}

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
