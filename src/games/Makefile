# Supported environments:
#   GNU/Linux.
#
# Used tools:
#   GNU core utilities.

PROGS		= snake tank tetris untangle wolf3d br eric 
DOC		=
INSTALLDIR	:= $(shell pwd)/../../release/nedogame
DOC_INSTALLDIR	= ${INSTALLDIR}/doc

.PHONY: ${PROGS} empty all install install-doc clean

.DEFAULT_GOAL=all

empty:
	@echo 'Usage: make [ TARGET | all | clean | install | install-doc ]'
	@echo '(TARGET is one of: ${PROGS})'

${PROGS}:
	${MAKE} -w -C $@

${sort \
${INSTALLDIR} \
${DOC_INSTALLDIR} \
}:
	mkdir -p $@ || echo

all: ${PROGS}

install: ${INSTALLDIR}
	for d in ${PROGS}; do ${MAKE} INSTALLDIR=${INSTALLDIR} -w -C $$d install ; done

ifeq "${DOC}" ""
install-doc:
else
install-doc: ${DOC} | ${DOC_INSTALLDIR}
	cp $^ $|
endif
	for d in ${PROGS}; do ${MAKE} -w -C $$d $@; done

clean:
	for d in ${PROGS}; do ${MAKE} -w -C $$d $@; done
