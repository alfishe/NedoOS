PROGS		= snake tank tetris smb untangle wolf3d br eric

all: ${PROGS}

.PHONY: ${PROGS}

${PROGS}:
	${MAKE} -w -C $@

clean:
	for d in ${PROGS}; do ${MAKE} -w -C $$d clean; done

install:
	mkdir -p ../../release/nedogame || echo
	for d in ${PROGS}; do ${MAKE} -w -C $$d install; done

install-doc:
	for d in ${PROGS}; do ${MAKE} -w -C $$d install-doc; done

