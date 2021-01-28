# Supported environments:
#   GNU/Linux.
#
# Tools used:
#   GNU core utilities, tools/aspp, tools/sjasmplus.

include ../_sdk/common.mk

NAME		= reset.com
OBJECTS		=
SOURCES		= reset.asm
RESOURCES	=
DOCS		=
INSTALLDIR	?= ../../release
BIN_INSTALLDIR	= ${INSTALLDIR}/bin
RES_INSTALLDIR	= ${INSTALLDIR}/bin
DOC_INSTALLDIR	= ${INSTALLDIR}/doc

# All targets
TARGETS=executables resources
.PHONY: empty ${foreach t,${TARGETS},${t} install-${t} clean-${t}} all install install-doc clean

.DEFAULT_GOAL=all

empty:
	@echo 'Usage: make [ TARGET | ACTION-TARGET | all | install | install-doc | clean ]'
	@echo 'where ACTION is one of: install clean'
	@echo '      TARGET is one of: ${TARGETS}'

# Clear lists
DEPS=

# Create directories
${sort \
${BIN_INSTALLDIR} \
${RES_INSTALLDIR} \
${DOC_INSTALLDIR} \
}:
	mkdir -p $@

##########################
## Target "executables" ##
##########################

EXEC_DEPS=
EXEC_BINS=

${eval ${call sjasmplus_odd_rule,${NAME},${SOURCES},,EXEC_DEPS,EXEC_BINS}}

executables: ${EXEC_BINS}

install-executables: executables | ${BIN_INSTALLDIR}
	cp ${EXEC_BINS} $|

clean-executables:
	${RM} ${EXEC_DEPS} ${EXEC_BINS}

DEPS+=${EXEC_DEPS}

########################
## Target "resources" ##
########################

resources: ${RESOURCES}

install-resources: resources | ${RES_INSTALLDIR}
ifneq "${sort ${RESOURCES}}" ""
	cp ${RESOURCES} $|
endif

clean-resources:

####################
## Common targets ##
####################

all: executables resources

install: install-executables install-resources

ifeq "${sort ${DOCS}}" ""
install-doc:
else
install-doc: ${DOCS} | ${DOC_INSTALLDIR}
	cp $^ $|
endif

clean: clean-executables clean-resources

##################
## Dependencies ##
##################

ifneq "${sort \
${filter empty,${MAKECMDGOALS}} \
${filter clean,${MAKECMDGOALS}} \
${filter clean-%,${MAKECMDGOALS}} \
}" ""
else
# FIXME: Triggered when multiple targets specified.
include ${DEPS}
endif
