# Supported environments:
#   GNU/Linux.
#
# Used tools:
#   GNU core utilities, GNU sed, tools/aspp, tools/sjasmplus.

include ../_sdk/common.mk

NAME		= fatfs.raw
#SOURCES		= ff_sj.asm
EXPORTS_FILE	= ../kernel/ffsfunc.asm

# All targets
.PHONY: empty all install install-doc clean

.DEFAULT_GOAL=all

empty:
	@echo 'Usage: make [ all | install | install-doc | clean ]'

# Clear lists
DEPS=
OBJECTS=

####################
## Common targets ##
####################

fatfs_EXP=ff_sj.exp

#{eval ${call sjasmplus_odd_rule,${NAME} ${fatfs_EXP},${SOURCES},--exp=${fatfs_EXP},DEPS,}}

${EXPORTS_FILE}: ${fatfs_EXP}
	echo '; ${@F} - FatFS calls.' > $@
	echo '; This file is a part of NedoOS project.' >> $@
	echo '; Compatible compiler: sjasmplus.' >> $@
	echo '; This file was generated automatically while building FatFS.' >> $@
	echo 'ffsfunc' >> $@
	sed -re 's/^.+/.&/' $< >> $@

#all: ${NAME} ${EXPORTS_FILE}
all: ${NAME}

install: all

install-doc:

clean:
	${RM} ${DEPS} ${OBJECTS} ${fatfs_EXP}
#	${RM} ${DEPS} ${OBJECTS} ${fatfs_EXP} ${NAME} ${EXPORTS_FILE}

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
