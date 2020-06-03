# Supported environments:
#   GNU/Linux.
#
# Tools used:
#   GNU core utilities, tools/aspp.sh, tools/sjasmplus.

NAME		= unrar.com
OBJECTS		=
SOURCES		= unrar.asm
DOC		=
ASPP		= ../../tools/aspp.sh
SJASMPLUS	= ../../tools/sjasmplus
SJASMPLUSFLAGS	= --nologo --msg=war
INSTALLDIR	= ../../release
DEPAS		= ${ASPP}
DEPAFLAGS	= -E -MM -I .
DEPEXT		= d
DEPS		= ${patsubst %.asm,%.${DEPEXT},${filter %.asm,${SOURCES}}}

.DEFAULT_GOAL = all

.PHONY: empty all clean install install-doc

empty:
	@echo 'Usage: make [ all | clean | install | install-doc ]'

# Dependency generation rule (.com from .asm):
%.${DEPEXT}: %.asm
	${RM} $@ && ${DEPAS} ${DEPAFLAGS} -MT $*.com -MT $@ -MF $@ $<

ifeq "${MAKECMDGOALS}" "empty"
else ifeq "${MAKECMDGOALS}" "clean"
else
include ${DEPS}
endif

${NAME}: ${SOURCES}
	${SJASMPLUS} ${SJASMPLUSFLAGS} $<

all: ${NAME}

clean:
	${RM} ${NAME} ${OBJECTS} ${DEPS}

install: ${NAME}
	cp $^ ${INSTALLDIR}/bin

install-doc: ${DOC}
#	cp $^ ${INSTALLDIR}/doc
