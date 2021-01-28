# Supported environments:
#   GNU/Linux.
#
# Tools used:
#   GNU core utilities, tools/aspp, tools/sjasmplus, _sdk/nedores.bin.

# TODO: Pack data files (author used `xlpz' tool).
# TODO: Missing file "barkov/hellfire.scr", used in "levels/w~214.a80".

include ../../_sdk/common.mk

NAME		= br.com brintro.com
SOURCES		= main.asm WSTART1.asm brfinal.asm
RESOURCES	=
DOCS		=
LOCALDIR	= br
INSTALLDIR	?= ../../../release/nedogame
BIN_INSTALLDIR	= ${INSTALLDIR}
RES_INSTALLDIR	= ${INSTALLDIR}/br
DOC_INSTALLDIR	= ${INSTALLDIR}/doc
NEDORES		= ../../_sdk/nedores.bin

# All targets
TARGETS=executables flicks modules levels resources
.PHONY: empty ${foreach t,${TARGETS},${t} install-${t} clean-${t}} all install install-doc clean

.DEFAULT_GOAL=all

empty:
	@echo 'Usage: make [ TARGET | ACTION-TARGET | all | install | install-doc | clean ]'
	@echo 'where ACTION is one of: install clean'
	@echo '      TARGET is one of: ${TARGETS}'

# Clear lists
DEPS=

# Create directories
${sort \
${LOCALDIR} \
${BIN_INSTALLDIR} \
${RES_INSTALLDIR} \
${DOC_INSTALLDIR} \
}:
	mkdir -p $@

##########################
## Target "executables" ##
##########################

EXEC_DEPS=
EXEC_BINS=
EXEC_DATS=

# main

EXEC_MAIN_BINS=br.com
EXEC_MAIN_DATS=\
${LOCALDIR}/br0.dat \
${LOCALDIR}/br1.dat \
${LOCALDIR}/br3.dat \
${LOCALDIR}/br4.dat \
${LOCALDIR}/br6.dat \
${LOCALDIR}/br7.dat

${eval ${call sjasmplus_odd_rule,${EXEC_MAIN_BINS} ${EXEC_MAIN_DATS},main.asm,,EXEC_DEPS,}}

EXEC_BINS+=${EXEC_MAIN_BINS}
EXEC_DATS+=${EXEC_MAIN_DATS}

# intro

EXEC_INTRO_BINS=brintro.com
EXEC_INTRO_DATS=\
${LOCALDIR}/bri3.dat \
${LOCALDIR}/bri4.dat \
${LOCALDIR}/bri7.dat

${eval ${call sjasmplus_odd_rule,${EXEC_INTRO_BINS} ${EXEC_INTRO_DATS},WSTART1.asm,,EXEC_DEPS,}}

EXEC_BINS+=${EXEC_INTRO_BINS}
EXEC_DATS+=${EXEC_INTRO_DATS}

# final

EXEC_FINAL_DATS=${LOCALDIR}/brfinal.dat

${eval ${call sjasmplus_rule,${EXEC_FINAL_DATS},brfinal.asm,,EXEC_DEPS,}}

EXEC_DATS+=${EXEC_FINAL_DATS}

executables: ${EXEC_BINS} ${EXEC_DATS} | ${LOCALDIR}

install-executables: executables | ${sort ${BIN_INSTALLDIR} ${RES_INSTALLDIR}}
	cp ${EXEC_BINS} ${BIN_INSTALLDIR}
	cp ${EXEC_DATS} ${RES_INSTALLDIR}

clean-executables:
	${RM} ${EXEC_DEPS} ${EXEC_BINS} ${EXEC_DATS}

DEPS+=${EXEC_DEPS}

#####################
## Target "flicks" ##
#####################

FLICKS_LPZS=${wildcard intro/flick.lpz/*.lpz}
FLICKS_BINS=

define flick_rule =
# No pack rule
# Copy rule
${eval ${call copy_file_rule,${1},${2},FLICKS_BINS}}
endef

${foreach f,${FLICKS_LPZS},${eval ${call flick_rule,${LOCALDIR}/${notdir ${f}},${f}}}}

flicks: ${FLICKS_BINS} | ${LOCALDIR}

install-flicks: flicks | ${RES_INSTALLDIR}
	cp ${FLICKS_BINS} $|

clean-flicks:
	${RM} ${FLICKS_BINS}

######################
## Target "modules" ##
######################

MODULES_DEPS=
MODULES_ASTS=
MODULES_BINS=

# ${1} = single output file
# ${2} = single input file 1
# ${3} = single input file 2
define nedores_rule =
# File order does matter!
${1}: ${2} ${3}
	${NEDORES} $$^ $$@
MODULES_ASTS+=${1}
endef

${eval ${call nedores_rule,W1LAND.ast,images/W1LAND.bmp,images/W1LAND.dat}}
${eval ${call nedores_rule,W2LAND.ast,images/W2LAND.bmp,images/W2LAND.dat}}
${eval ${call nedores_rule,W3LAND.ast,images/W3LAND.bmp,images/W3LAND.dat}}
${eval ${call nedores_rule,W4LAND.ast,images/W4LAND.bmp,images/W4LAND.dat}}
${eval ${call nedores_rule,WBAR.ast,images/WBAR.bmp,images/WBAR.dat}}
${eval ${call nedores_rule,WHUMBUTT.ast,images/WHUMBUTT.bmp,images/WHUMBUTT.dat}}
${eval ${call nedores_rule,WORCBUTT.ast,images/WORCBUTT.bmp,images/WORCBUTT.dat}}
${eval ${call nedores_rule,WHUM1.ast,images/WHUM1.bmp,images/WHUM1.dat}}
${eval ${call nedores_rule,WHUM1b.ast,images/WHUM1.bmp,images/WHUM1b.dat}}
${eval ${call nedores_rule,WHUM1c.ast,images/WHUM1.bmp,images/WHUM1c.dat}}
${eval ${call nedores_rule,WHUMCAT.ast,images/WHUM2.bmp,images/WHUMCAT.dat}}
${eval ${call nedores_rule,WHUMHOR.ast,images/WHUM2.bmp,images/WHUMHOR.dat}}
${eval ${call nedores_rule,WORC1.ast,images/WORC1.bmp,images/WORC1.dat}}
${eval ${call nedores_rule,WORC1b.ast,images/WORC1.bmp,images/WORC1b.dat}}
${eval ${call nedores_rule,WORC1c.ast,images/WORC1.bmp,images/WORC1c.dat}}
${eval ${call nedores_rule,WORCCAT.ast,images/WORC2.bmp,images/WORCCAT.dat}}
${eval ${call nedores_rule,WORCHOR.ast,images/WORC2.bmp,images/WORCHOR.dat}}
${eval ${call nedores_rule,WCREAT1.ast,images/WCREAT1.bmp,images/WCREAT1.dat}}
${eval ${call nedores_rule,WCREAT1b.ast,images/WCREAT1.bmp,images/WCREAT1b.dat}}
${eval ${call nedores_rule,WCREAT1c.ast,images/WCREAT1.bmp,images/WCREAT1c.dat}}
${eval ${call nedores_rule,WCREAT2.ast,images/WCREAT2.bmp,images/WCREAT2.dat}}
${eval ${call nedores_rule,WCREAT2b.ast,images/WCREAT2.bmp,images/WCREAT2b.dat}}
${eval ${call nedores_rule,WCREAT2c.ast,images/WCREAT2.bmp,images/WCREAT2c.dat}}
${eval ${call nedores_rule,WBODY.ast,images/WMISC.bmp,images/WBODY.dat}}
${eval ${call nedores_rule,WBULLET.ast,images/WMISC.bmp,images/WBULLET.dat}}
${eval ${call nedores_rule,demobar.ast,images/demobar.bmp,images/demobar.dat}}

define compile_module_rule =
${eval ${call sjasmplus_rule,${1},${2},${3},MODULES_DEPS,MODULES_BINS}}
endef

define compile_module_odd_rule =
${eval ${call sjasmplus_odd_rule,${1},${2},${3},MODULES_DEPS,MODULES_BINS}}
endef

${eval ${call compile_module_rule,${LOCALDIR}/W1LAND.bin,W1LAND.ast,}}
${eval ${call compile_module_rule,${LOCALDIR}/W2LAND.bin,W2LAND.ast,}}
${eval ${call compile_module_rule,${LOCALDIR}/W3LAND.bin,W3LAND.ast,}}
${eval ${call compile_module_rule,${LOCALDIR}/W4LAND.bin,W4LAND.ast,}}
${eval ${call compile_module_rule,${LOCALDIR}/WBAR.bin,WBAR.ast,}}
${eval ${call compile_module_rule,${LOCALDIR}/W0BUT.bin,WHUMBUTT.ast,}}	# renamed
${eval ${call compile_module_rule,${LOCALDIR}/W1BUT.bin,WORCBUTT.ast,}}	# renamed
${eval ${call compile_module_rule,${LOCALDIR}/WHUM1.bin,WHUM1.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WHUM1b.bin,WHUM1b.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WHUM1c.bin,WHUM1c.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WHUMCAT.bin,WHUMCAT.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WHUMHOR.bin,WHUMHOR.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WORC1.bin,WORC1.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WORC1b.bin,WORC1b.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WORC1c.bin,WORC1c.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WORCCAT.bin,WORCCAT.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WORCHOR.bin,WORCHOR.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WCREAT1.bin,WCREAT1.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WCREAT1b.bin,WCREAT1b.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WCREAT1c.bin,WCREAT1c.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WCREAT2.bin,WCREAT2.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WCREAT2b.bin,WCREAT2b.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WCREAT2c.bin,WCREAT2c.asm,}}
#${eval ${call compile_module_odd_rule,${LOCALDIR}/WBODY.bin,WBODY.asm,}}
${eval ${call compile_module_rule,${LOCALDIR}/WBULLET.bin,WBULLET.asm,}}

modules: ${MODULES_BINS} | ${LOCALDIR}

install-modules: modules | ${RES_INSTALLDIR}
	cp ${MODULES_BINS} $|

clean-modules:
	${RM} ${MODULES_DEPS} ${MODULES_ASTS} ${MODULES_BINS}

DEPS+=${MODULES_DEPS}

#####################
## Target "levels" ##
#####################

LEVELS_DEPS=
LEVELS_DATS=
LEVELS_LPZS=
LEVELS_BINS=

define compile_level_rule =
# Compile rule
${eval ${call sjasmplus_rule,${patsubst %${suffix ${2}},%.dat,${2}},${2},${3},LEVELS_DEPS,LEVELS_DATS}}
# Fake pack rule
${eval ${call copy_file_rule,${patsubst %${suffix ${2}},%.lpz,${2}},${patsubst %${suffix ${2}},%.dat,${2}},LEVELS_LPZS}}
# Copy rule
${eval ${call copy_file_rule,${1},${patsubst %${suffix ${2}},%.lpz,${2}},LEVELS_BINS}}
endef

define fake_compile_level_rule =
# Copy rule
${eval ${call copy_file_rule,${1},${patsubst %${suffix ${2}},%.lpz,${2}},LEVELS_BINS}}
# No pack rule
# No compile rule
endef

define compile_level_odd_rule =
# Compile rule
${eval ${call sjasmplus_rule,${patsubst %${suffix ${2}},%.dat,${2}},${2},${3},LEVELS_DEPS,LEVELS_DATS}}
# Fake pack rule
${eval ${call copy_file_rule,${patsubst %${suffix ${2}},%.lpz,${2}},${patsubst %${suffix ${2}},%.dat,${2}},LEVELS_LPZS}}
# Copy rule
${eval ${call copy_file_rule,${1},${patsubst %${suffix ${2}},%.lpz,${2}},LEVELS_BINS}}
endef

${eval ${call fake_compile_level_rule,${LOCALDIR}/br101.dat,levels/w~101.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br102.dat,levels/w~102.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br103.dat,levels/w~103.a80,}}
${eval ${call compile_level_odd_rule,${LOCALDIR}/br104.dat,levels/w~104.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br105.dat,levels/w~105.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br106.dat,levels/w~106.a80,}}
${eval ${call compile_level_odd_rule,${LOCALDIR}/br107.dat,levels/w~107.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br108.dat,levels/w~108.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br109.dat,levels/w~109.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br110.dat,levels/w~110.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br111.dat,levels/w~111.a80,}}
${eval ${call compile_level_odd_rule,${LOCALDIR}/br112.dat,levels/w~112.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br113.dat,levels/w~113.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br114.dat,levels/w~114.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br115.dat,levels/w~115.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br116.dat,levels/w~116.a80,}}
${eval ${call compile_level_odd_rule,${LOCALDIR}/br117.dat,levels/w~117end.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br201.dat,levels/w~201.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br202.dat,levels/w~202.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br203.dat,levels/w~203.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br204.dat,levels/w~204.a80,}}
${eval ${call compile_level_odd_rule,${LOCALDIR}/br205.dat,levels/w~205.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br206.dat,levels/w~206.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br207.dat,levels/w~207.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br208.dat,levels/w~208.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br209.dat,levels/w~209.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br210.dat,levels/w~210.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br211.dat,levels/w~211.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br212.dat,levels/w~212.a80,}}
${eval ${call compile_level_odd_rule,${LOCALDIR}/br213.dat,levels/w~213.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br214.dat,levels/w~214.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br215.dat,levels/w~215.a80,}}
${eval ${call fake_compile_level_rule,${LOCALDIR}/br216.dat,levels/w~216.a80,}}
${eval ${call compile_level_odd_rule,${LOCALDIR}/br217.dat,levels/w~217end.a80,}}

levels: ${LEVELS_BINS} | ${LOCALDIR}

install-levels: levels | ${RES_INSTALLDIR}
	cp ${LEVELS_BINS} $|

clean-levels:
	${RM} ${LEVELS_DEPS} ${LEVELS_DATS} ${LEVELS_LPZS} ${LEVELS_BINS}

DEPS+=${LEVELS_DEPS}

########################
## Target "resources" ##
########################

RES_DATS=\
${LOCALDIR}/br0.dat \
${LOCALDIR}/br1.dat \
${LOCALDIR}/br3.dat \
${LOCALDIR}/br4.dat \
${LOCALDIR}/br6.dat \
${LOCALDIR}/br7.dat \
${LOCALDIR}/braniu_0.dat \
${LOCALDIR}/braniu_1.dat \
${LOCALDIR}/braniv_0.dat \
${LOCALDIR}/braniv_1.dat \
${LOCALDIR}/braniw_0.dat \
${LOCALDIR}/braniw_1.dat \
${LOCALDIR}/branix_0.dat \
${LOCALDIR}/branix_1.dat \
${LOCALDIR}/braniy_0.dat \
${LOCALDIR}/braniy_1.dat \
${LOCALDIR}/braniz_0.dat \
${LOCALDIR}/braniz_1.dat \
${LOCALDIR}/brbar.dat \
${LOCALDIR}/brbut0.dat \
${LOCALDIR}/brbut1.dat \
${LOCALDIR}/brmuz0.dat \
${LOCALDIR}/brmuz1.dat \
${LOCALDIR}/brmuz2.dat \
${LOCALDIR}/brmuz3.dat \
${LOCALDIR}/brmuz4.dat \
${LOCALDIR}/brmuz5.dat \
${LOCALDIR}/brmuz6.dat \
${LOCALDIR}/brmuz7.dat \
${LOCALDIR}/brspr1.dat \
${LOCALDIR}/brspr2.dat \
${LOCALDIR}/brspr3.dat \
${LOCALDIR}/brspr4.dat

resources: flicks modules levels ${RES_DATS}

install-resources: install-flicks install-modules install-levels ${RES_DATS} | ${RES_INSTALLDIR}
ifneq "${sort ${RESOURCES}}" ""
	cp ${RESOURCES} $|
endif
	cp ${RES_DATS} $|

clean-resources: clean-flicks clean-modules clean-levels

####################
## Common targets ##
####################

all: executables resources

install: install-executables install-resources

ifeq "${sort ${DOCS}}" ""
install-doc:
else
install-doc: ${DOCS} | ${DOC_INSTALLDIR}
	cp $^ $|
endif

clean: clean-executables clean-resources

##################
## Dependencies ##
##################

ifneq "${sort \
${filter empty,${MAKECMDGOALS}} \
${filter clean,${MAKECMDGOALS}} \
${filter clean-%,${MAKECMDGOALS}} \
}" ""
else
# FIXME: Triggered when multiple targets specified.
include ${DEPS}
endif
