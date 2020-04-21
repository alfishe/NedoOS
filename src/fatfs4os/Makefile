NAME		= fatfs.raw
SOURCES		= ff.c ff.h diskio.h integer.h ffconf.h mylib.asm

all: ${NAME} ${SOURCES}

ifeq ($(OS),Windows_NT)
wget.com: ${SOURCES}
	build.bat
else
wget.com: ${SOURCES}
	wine cmd /c build.bat /nogui
endif

clean: 
	rm -f -r ${NAME} list

install: all

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
