NAME		= browser.com
OBJECTS		=
SOURCES		= browser.asm
RESOURCE	=
ASPP		= ../../tools/aspp.sh
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release
DEPAS		= ${ASPP}
DEPAFLAGS	= -E -MM -I .
DEPEXT		= d
DEPS		= ${patsubst %.asm,%.${DEPEXT},${filter %.asm,${SOURCES}}}

.PHONY: all clean install install-doc

# Dependency generation rule (.com from .asm):
%.${DEPEXT}: %.asm
	set -e; ${RM} $@; \
	${DEPAS} ${DEPAFLAGS} -MT $*.com -MF $@.tmp $<; \
	sed -e 's,\($*\.com\) *:,\1 $@ :,g' < $@.tmp > $@; \
	${RM} $@.tmp

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

all: ${NAME}

${NAME}: ${SOURCES}
	${SJASMPLUS} --nologo $<

clean:
	${RM} ${NAME} ${OBJECTS} ${DEPS}

install: all
	cp ${NAME} ${INSTALLDIR}/bin

install-doc: ${DOC}
#	cp ${DOC} ${INSTALLDIR}/doc
