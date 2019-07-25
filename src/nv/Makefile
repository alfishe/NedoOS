NAME		= nv.com
OBJECTS		=
SOURCES		= heapsort.asm nv.asm nveditln.asm nvhexed.asm nvjptbl.asm nvsort.asm nvunit.asm nvview.asm winto866 nv.ext
SJASMPLUS	= ../../tools/sjasmplus
INSTALLDIR	= ../../release

all: ${NAME} ${SOURCES}

nv.com: ${SOURCES}
	${SJASMPLUS} --nologo --nofakes nv.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all
	cp nv.ext ${NAME} ${INSTALLDIR}/bin
install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
