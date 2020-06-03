# Supported environments:
#   GNU/Linux.
#
# Used tools:
#   GNU core utilities, tools/aspp.sh, tools/sjasmplus, tools/mhmt.

NAME		= code.c
OBJECTS		=
SOURCES		= main.asm
DOC		=
BINS		= initcode.c syscode.c
TMPS		= user.l syscode.c.mlz
ASPP		= ../../tools/aspp.sh
SJASMPLUS	= ../../tools/sjasmplus
SJASMPLUSFLAGS	= --nologo --msg=war
MHMT		= ../../tools/mhmt
DEPAS		= ${ASPP}
DEPAFLAGS	= -E -MM -I .
DEPCC		= gcc
DEPCFLAGS	= -E -MM -I .
DEPEXT		= d
DEPS		= ${patsubst %.asm,%.${DEPEXT},${filter %.asm,${SOURCES}}}

.DEFAULT_GOAL = all

.PHONY: empty all clean install install-doc

empty:
	@echo 'Usage: make [ all | clean | install | install-doc ]'

# Dependency generation rule (${BINS} from .asm):
%.${DEPEXT}: %.asm
ifeq "${OS}" "Windows_NT"
	${RM} $@ && ${DEPAS} ${DEPAFLAGS} ${addprefix -MT ,${BINS}} -MT $@ -MF $@ $<
else
	${RM} $@ && env LC_CTYPE=C ${DEPAS} ${DEPAFLAGS} ${addprefix -MT ,${BINS}} -MT $@ -MF $@ $<
endif

ifeq "${MAKECMDGOALS}" "empty"
else ifeq "${MAKECMDGOALS}" "clean"
else
include ${DEPS}
endif

../fatfs4os/fatfs.raw:
	${MAKE} -C ${@D}

${BINS} user.l: ${SOURCES}
	${SJASMPLUS} ${SJASMPLUSFLAGS} $<

%.mlz: %
	${MHMT} -mlz $<

# The order of files does matter!
${NAME}: initcode.c syscode.c.mlz
	cat $^ > $@

all: ${NAME}

clean:
	${RM} ${NAME} ${OBJECTS} ${BINS} ${TMPS} ${DEPS}

install: all

install-doc: ${DOC}
#	cp ${DOC} ${INSTALLDIR}/doc
