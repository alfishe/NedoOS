# Supported environments:
#   GNU/Linux.
#
# Tools used:
#   * GNU core utilities
#   * _sdk/nedotrd.bin
#   * tools/sjasmplus

INSTALLDIR	= ../release
BIN_INSTALLDIR	= ${INSTALLDIR}/bin
DOC_INSTALLDIR	= ${INSTALLDIR}/doc

SUBDIRS		=	basic browser cmd emptyapp games fatfs4os kernel modplay nedolang nv pkunzip player reset scratch setfont tar texted view ping telnet term
SUBDIRS		+=	zxrar wrtrd winto866 zxzvm z80 x86 print playtap nmisvc mktrd unrar rdtrd pt ngsdec netterm myip more menu man hello gettrd
SUBDIRS		+=	bk untr dmapps/settime dmapps/3ws dmapps/dmftp dmapps/dmirc dmapps/dmm dmapps/helloworld

# Problem subdirs
# SUBDIRS		+= untr moon-rabbit-zx games bdsc

OBJECTS		=
DOCS		= nedoos.txt nedoos.new
SOURCES		= _sdk/syssets.asm

# Tools
SDK_DIR		= _sdk
NEDOTRD		= ${SDK_DIR}/nedotrd.bin
NEDORES		= ${SDK_DIR}/nedores.bin
NEDOPAD		= ${SDK_DIR}/nedopad.bin
TOOLS_DIR	= ../tools
MHMT		= ${TOOLS_DIR}/mhmt
DMIMG		= ${TOOLS_DIR}/dmimg
TOOLS		= ${NEDOTRD} ${NEDORES} ${NEDOPAD} ${MHMT} ${SJASMPLUS} ${DMIMG}

# All targets
TARGETS=atm2 atm2hd atm3 atm3hd atm3sd evolution pe26
.PHONY: empty ${SUBDIRS} tools clean-tools subdirs clean-subdirs system install install-doc hobeta trd ${foreach t,${TARGETS},${t} syssets-${t}} all clean-syssets clean-release clean

.DEFAULT_GOAL=empty

empty:
	@echo 'Usage: make [ tools | clean-tools | subdirs | clean-subdirs | system | install'
	@echo '            | install-doc | hobeta | trd | TARGET | all | clean-release'
	@echo '            | clean ]'
	@echo 'where TARGET is one of: ${TARGETS}'
	@echo 'Example:'
	@echo '	make clean'
	@echo '	make TARGET'

# Create directories
${sort \
${INSTALLDIR} \
${BIN_INSTALLDIR} \
${DOC_INSTALLDIR} \
}:
	mkdir -p $@

###########
## tools ##
###########

${TOOLS}:
	${MAKE} -w -C ${@D} ${@F}

tools: ${TOOLS}

clean-tools:
	${MAKE} -w -C ${SDK_DIR} clean
	${MAKE} -w -C ${TOOLS_DIR} clean

#############
## subdirs ##
#############

${SUBDIRS}: ${SOURCES}
	${MAKE} -w -C $@

subdirs: ${SUBDIRS}

clean-subdirs:
	${RM} _sdk/syssets.asm
	for d in ${SUBDIRS}; do ${MAKE} -w -C $$d clean; done

############
## system ##
############

system: tools subdirs

#############
## install ##
#############

install: autoexec.bat | ${BIN_INSTALLDIR}
	for d in ${SUBDIRS}; do ${MAKE} -w -C $$d install; done
	cp $^ $|

#################
## install-doc ##
#################

install-doc: ${DOCS} | ${DOC_INSTALLDIR}
	for d in ${SUBDIRS}; do ${MAKE} -w -C $$d install-doc; done
	cp $^ $|

############
## hobeta ##
############

kernel/nedoos.$$C:
	${MAKE} -w -C ${@D} hobeta

hobeta: system install install-doc kernel/nedoos.$$C

#########
## trd ##
#########

trd: system install install-doc
	${NEDOTRD} test.trd -n
	${NEDOTRD} test.trd -ah BOOT6000.\$$B
	${NEDOTRD} test.trd -s 24576 -ac kernel/code.c
	for d in `find ${BIN_INSTALLDIR} -type f`; do ${NEDOTRD} test.trd -a $$d; done
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

##########
## atm2 ##
##########

syssets-atm2:
	echo atm=2 > _sdk/syssets.asm
	echo sys_npages=64 >> _sdk/syssets.asm
	echo NEMOIDE=0 >> _sdk/syssets.asm
	echo SYSDRV=0 >> _sdk/syssets.asm
	echo INETDRV EQU 0x00 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	echo atm2clock=1 >> _sdk/syssets.asm

atm2: syssets-atm2 trd | ${INSTALLDIR}
	mv -f test.trd $|/osatm2.trd

############
## atm2hd ##
############

syssets-atm2hd:
	echo atm=2 > _sdk/syssets.asm
	echo sys_npages=64 >> _sdk/syssets.asm
	echo NEMOIDE=0 >> _sdk/syssets.asm
	echo SYSDRV=4 >> _sdk/syssets.asm
	echo INETDRV EQU 0x00 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	echo atm2clock=1 >> _sdk/syssets.asm

atm2hd: syssets-atm2hd hobeta | ${INSTALLDIR}
#	cp kernel/nedoos.\$$C $|/osatm2hd.\$$C
#	${MAKE} trd
#	${NEDOTRD} test.trd -eh code.c
#	${NEDOTRD} test.trd -a code.c
#	cp kernel/code.c $|/osatm2hd.\$$C
#	mv -f test.trd $|/osatm2hd.trd

##########
## atm3 ##
##########

syssets-atm3:
	echo atm=3 > _sdk/syssets.asm
	echo sys_npages=192 >> _sdk/syssets.asm
	echo NEMOIDE=1 >> _sdk/syssets.asm
	echo SYSDRV=0 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	echo atm2clock=1 >> _sdk/syssets.asm

atm3: syssets-atm3 trd | ${INSTALLDIR}
	mv -f test.trd $|/osatm3.trd

############
## atm3hd ##
############

syssets-atm3hd:
	echo atm=3 > _sdk/syssets.asm
	echo sys_npages=192 >> _sdk/syssets.asm
	echo NEMOIDE=1 >> _sdk/syssets.asm
	echo SYSDRV=4 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	echo atm2clock=1 >> _sdk/syssets.asm

#atm3hd: syssets-atm3hd hobeta trd | ${INSTALLDIR}
atm3hd: syssets-atm3hd hobeta | ${INSTALLDIR}
	cp kernel/nedoos.\$$C $|/osatm3hd.\$$C
#	mv -f test.trd $|/osatm3hd.trd

############
## atm3sd ##
############

syssets-atm3sd:
	echo atm=3 > _sdk/syssets.asm
	echo sys_npages=192 >> _sdk/syssets.asm
	echo NEMOIDE=1 >> _sdk/syssets.asm
	echo SYSDRV=12 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	echo atm2clock=1 >> _sdk/syssets.asm

#atm3sd: syssets-atm3sd hobeta trd | ${INSTALLDIR}
atm3sd: syssets-atm3sd hobeta | ${INSTALLDIR}
	cp kernel/nedoos.\$$C $|/osatm3sd.\$$C
#	mv -f test.trd $|/osatm3sd.trd

###############
## evolution ##
###############

syssets-evolution:
	echo atm=1 > _sdk/syssets.asm
	echo sys_npages=192 >> _sdk/syssets.asm
	echo NEMOIDE=1 >> _sdk/syssets.asm
	echo SYSDRV=12 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x01 >> _sdk/syssets.asm

#evolution: syssets-evolution hobeta trd | ${INSTALLDIR}
evolution: syssets-evolution hobeta | ${INSTALLDIR}
	cp kernel/nedoos.\$$C $|/osevo.\$$C
#	mv -f test.trd $|/osevo.trd

##########
## pe26 ##
##########

syssets-pe26:
	echo atm=2 > _sdk/syssets.asm
	echo sys_npages=64 >> _sdk/syssets.asm
	echo NEMOIDE=0 >> _sdk/syssets.asm
	echo SYSDRV=0 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	echo atm2clock=1 >> _sdk/syssets.asm

pe26: syssets-pe26 trd | ${INSTALLDIR}
	mv -f test.trd $|/ospe26.trd

############
## pe26sd ##
############

syssets-pe26sd:
	echo atm=2 > _sdk/syssets.asm
	echo sys_npages=64 >> _sdk/syssets.asm
	echo NEMOIDE=0 >> _sdk/syssets.asm
	echo SYSDRV=0 >> _sdk/syssets.asm
	echo INETDRV EQU 0x01 >> _sdk/syssets.asm
	echo PS2KBD EQU 0x00 >> _sdk/syssets.asm
	echo atm2clock=1 >> _sdk/syssets.asm

pe26sd: syssets-pe26sd hobeta | ${INSTALLDIR}
	cp kernel/nedoos.\$$C $|/ospe26sd.\$$C

#########
## all ##
#########

all: ${TARGETS}

###########
## clean ##
###########

clean-release:
	${RM} -r ${INSTALLDIR}/*

clean: clean-subdirs
