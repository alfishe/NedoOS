INSTALLDIR	= ../release
SUBDIRS		= basic browser cmd emptyapp games kernel modplay nedolang nv pkunzip player reset scratch setfont tar texted view
OBJECTS		= 
TOOLS		= _sdk/nedotrd.bin _sdk/nedores.bin _sdk/nedopad.bin ../tools/mhmt ../tools/sjasmplus ../tools/dmimg
SOURCES		= basic.asm bascmds.asm
SJASMPLUS	= ../tools/sjasmplus
DOCS		= nedoos.txt nedoos.new
NEDOTRD		= _sdk/nedotrd.bin

all:
	echo "Use make atm2|atm2hd|atm3|atm3hd|atm3sd|pe26"

tools: ${TOOLS}

system: ${TOOLS} ${SUBDIRS}

.PHONY: ${SUBDIRS} clean

${SUBDIRS}:
	${MAKE} -w -C $@

_sdk/nedotrd.bin _sdk/nedores.bin _sdk/nedopad.bin:
	${MAKE} -w -C _sdk

../tools/mhmt:
	cd ../tools/src && cd mhmt/linux && make && cp mhmt ../../..
../tools/sjasmplus:
	cd ../tools/src && cd sjasmplus && make && cp sjasmplus ../..
../tools/dmimg:
	cd ../tools/src && cd dmimg && make && cp dmimg ../..

clean-tools:
	${MAKE} -w -C _sdk clean
	${MAKE} -w -C ../tools/src/dmimg clean
	${MAKE} -w -C ../tools/src/sjasmplus clean
	${MAKE} -w -C ../tools/src/mhmt/linux clean
	#cd ../tools && rm sjasmplus mhmt

clean: clean-tools
	for d in ${SUBDIRS}; do ${MAKE} -w -C $$d clean; done
clean-release:
	cd ${INSTALLDIR} && rm -f bin/* doc/*

install: all
	for d in ${SUBDIRS}; do ${MAKE} -w -C $$d install; done
	cp autoexec.bat ${INSTALLDIR}/bin

install-doc: 
	for d in ${SUBDIRS}; do ${MAKE} -w -C $$d install-doc; done
	cp ${DOCS} ${INSTALLDIR}/doc

trd: system install install-doc
	${NEDOTRD} test.trd -n
	${NEDOTRD} test.trd -ah BOOT6000.\$$B
	${NEDOTRD} test.trd -s 24576 -ac kernel/code.c
	for d in `find ${INSTALLDIR}/bin -type f`; do ${NEDOTRD} test.trd -a $$d; done
#	${NEDOTRD} test.trd -a nedolang/comp/sizesz80.h
#	${NEDOTRD} test.trd -a nedolang/comp/comp_os.s
#	${NEDOTRD} test.trd -a nedolang/comp/compc_os.s
#	${NEDOTRD} test.trd -a nedolang/comp/compile.c
#	${NEDOTRD} test.trd -a nedolang/comp/codez80.c
#	${NEDOTRD} test.trd -a nedolang/comp/commands.c
#	${NEDOTRD} test.trd -a nedolang/comp/regs.c
#	${NEDOTRD} test.trd -a nedolang/comp/test.bat
#	${NEDOTRD} test.trd -a nedolang/_sdk/str.h
#	${NEDOTRD} test.trd -a nedolang/_sdk/io.h
#	${NEDOTRD} test.trd -a nedolang/_sdk/emit.h
#	${NEDOTRD} test.trd -a nedolang/_sdk/emit.c
#	${NEDOTRD} test.trd -a nedolang/_sdk/read.c
#	${NEDOTRD} test.trd -a nedolang/_sdk/typecode.h
#	${NEDOTRD} test.trd -a nedolang/_sdk/lib.i
#	${NEDOTRD} test.trd -a nedolang/_sdk/str.i
#	${NEDOTRD} test.trd -a nedolang/_sdk/io_os.i
#	${NEDOTRD} test.trd -a _sdk/sysdefs.asm
#	${NEDOTRD} test.trd -a basic/example.bas
#	${NEDOTRD} test.trd -a nedolang/nedogift/testmusi.pt3
#	${NEDOTRD} test.trd -a player/coco.pt2
#	${NEDOTRD} test.trd -a modplay/scalsfjy.mod
#	for d in `find ${INSTALLDIR}/doc -type f`; do ${NEDOTRD} test.trd -a $$d; done

atm2:
	echo atm=2 > _sdk/syssets.asm
	echo sys_npages=64 >> _sdk/syssets.asm
	echo NEMOIDE=0 >> _sdk/syssets.asm
	echo SYSDRV=0 >> _sdk/syssets.asm
	echo INETDRV EQU 0x00 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	${MAKE} trd
	mv -f test.trd ${INSTALLDIR}/osatm2.trd

atm2hd:
	echo atm=2 > _sdk\syssets.asm
	echo sys_npages=64 >> _sdk\syssets.asm
	echo NEMOIDE=0 >> _sdk\syssets.asm
	echo SYSDRV=8 >> _sdk\syssets.asm
	echo INETDRV EQU 0x00 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	${MAKE} trd
	${NEDOTRD} test.trd -eh code.c
	${NEDOTRD} test.trd -a code.c
	cp code.c ${INSTALLDIR}/osatm2hd.\$$C
	mv -f test.trd ${INSTALLDIR}/osatm2hd.trd

atm3:
	echo atm=3 > _sdk/syssets.asm
	echo sys_npages=192 >> _sdk/syssets.asm
	echo NEMOIDE=1 >> _sdk/syssets.asm
	echo SYSDRV=0 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	${MAKE} trd
	mv -f test.trd ${INSTALLDIR}/osatm3.trd
atm3hd:
	echo atm=3 > _sdk/syssets.asm
	echo sys_npages=192 >> _sdk/syssets.asm
	echo NEMOIDE=1 >> _sdk/syssets.asm
	echo SYSDRV=8 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	${MAKE} trd
	${SJASMPLUS} kernel/hobeta.asm
	cp nedoos.\$$C ${INSTALLDIR}/osatm3sd.\$$C
	mv -f test.trd ${INSTALLDIR}/osatm3hd.trd

atm3sd: system install install-doc
	echo atm=3 > _sdk/syssets.asm
	echo sys_npages=192 >> _sdk/syssets.asm
	echo NEMOIDE=1 >> _sdk/syssets.asm
	echo SYSDRV=4 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	${MAKE} trd
	${SJASMPLUS} kernel/hobeta.asm
	cp nedoos.\$$C ${INSTALLDIR}/osatm3sd.\$$C
	mv -f test.trd ${INSTALLDIR}/osatm3sd.trd
pe26:
	echo atm=3 > _sdk/syssets.asm
	echo sys_npages=64 >> _sdk/syssets.asm
	echo NEMOIDE=1 >> _sdk/syssets.asm
	echo SYSDRV=0 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	mv -f test.trd ${INSTALLDIR}/osatm3.trd
