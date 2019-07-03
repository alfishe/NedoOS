PROGS		= snake tank tetris smb untangle

all: ${PROGS}

.PHONY: ${PROGS}

${PROGS}:
	${MAKE} -w -C $@

clean:
	for d in ${PROGS}; do ${MAKE} -w -C $$d clean; done

install:
	for d in ${PROGS}; do ${MAKE} -w -C $$d install; done

install-doc:
	for d in ${PROGS}; do ${MAKE} -w -C $$d install-doc; done

