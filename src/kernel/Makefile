NAME		= code.c
OBJECTS		= initcode.c syscode.c syscode.c.mlz
SOURCES		= bdospg2.asm fatfsdrv.asm fatfs_h.asm idle.asm main.asm unmegalz.asm sysbdos.asm sysiofast.asm syskey2.asm syskrnl.asm trdosfs.asm trdosio.asm unmegalz.asm userkrnl.asm userkrnl.asm w5300.asm 866toatm ../fatfs4os/fatfs.raw ps2drv.asm

SJASMPLUS	= ../../tools/sjasmplus
MHMT		=../../tools/mhmt

all: ${NAME} ${SOURCES}

code.c: initcode.c syscode.c.mlz
	cat initcode.c syscode.c.mlz > code.c

syscode.c.mlz: syscode.c
	${MHMT} -mlz syscode.c

initcode.c: syscode.c

syscode.c: ${SOURCES}
	${SJASMPLUS} --nologo main.asm

clean: 
	rm -f ${NAME} ${OBJECTS}

install: all

install-doc: ${DOC} 
#	cp ${DOC} ${INSTALLDIR}/doc
