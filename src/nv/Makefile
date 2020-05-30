NAME		= nv.com
OBJECTS		=
SOURCES		= nv.asm
RESOURCES	= nv.ext
ASPP		= ../../tools/aspp.sh
SJASMPLUS	= ../../tools/sjasmplus
SJASMPLUSFLAGS	= --nologo --msg=war
INSTALLDIR	= ../../release
DEPAS		= ${ASPP}
DEPAFLAGS	= -E -MM -I .
DEPEXT		= d
DEPS		= ${patsubst %.asm,%.${DEPEXT},${filter %.asm,${SOURCES}}}

.DEFAULT_GOAL =

.PHONY: all clean install install-doc

# Dependency generation rule (.com from .asm):
%.${DEPEXT}: %.asm
	${RM} $@ && ${DEPAS} ${DEPAFLAGS} -MT $*.com -MT $@ -MF $@ $<

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

${NAME}: ${SOURCES}
	${SJASMPLUS} ${SJASMPLUSFLAGS} $<

all: ${NAME}

clean:
	${RM} ${NAME} ${OBJECTS} ${DEPS}

install: ${NAME} ${RESOURCES}
	cp $^ ${INSTALLDIR}/bin

install-doc: ${DOC}
#	cp $^ ${INSTALLDIR}/doc
