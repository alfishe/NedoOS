# Supported environments:
#   GNU/Linux.

srcdir		= src
ASPP		= aspp
ASPP_DIR	= ${srcdir}/aspp
MHMT		= mhmt
MHMT_DIR	= ${srcdir}/mhmt/linux
SJASMPLUS	= sjasmplus
SJASMPLUS_DIR	= ${srcdir}/sjasmplus
DMIMG		= dmimg
DMIMG_DIR	= ${srcdir}/dmimg

# All targets
TARGETS=${ASPP} ${MHMT} ${SJASMPLUS} ${DMIMG}
.PHONY: empty ${foreach t,${TARGETS},clean-${t}} all clean

.DEFAULT_GOAL=empty

empty:
	@echo 'Usage: make [ TARGET | clean-TARGET | all | clean ]'
	@echo 'where TARGET is one of: ${TARGETS}'

##########
## aspp ##
##########

${ASPP}: ${ASPP_DIR}/build/release/linux/${ASPP} | ${ASPP_DIR}
	cp $< $@

${ASPP_DIR}/build/release/linux/${ASPP}: | ${ASPP_DIR}
	${MAKE} -w -C $| all

clean-${ASPP}:
	${MAKE} -w -C ${ASPP_DIR} clean
	${RM} ${ASPP}

##########
## mhmt ##
##########

${MHMT}: | ${MHMT_DIR}
	${MAKE} -w -C $| && cp $|/$@ $@

clean-${MHMT}:
	${MAKE} -w -C ${MHMT_DIR} clean
	${RM} ${MHMT}

###############
## sjasmplus ##
###############

${SJASMPLUS}: | ${SJASMPLUS_DIR}
	${MAKE} -w -C $| && cp $|/$@ $@

clean-${SJASMPLUS}:
	${MAKE} -w -C ${SJASMPLUS_DIR} clean
	${RM} ${SJASMPLUS}

###########
## dmimg ##
###########

${DMIMG}: | ${DMIMG_DIR}
	${MAKE} -w -C $| && cp $|/$@ $@

clean-${DMIMG}:
	${MAKE} -w -C ${DMIMG_DIR} clean
	${RM} ${DMIMG}

#########
## all ##
#########

all: ${TARGETS}

###########
## clean ##
###########

clean: ${foreach t,${TARGETS},clean-${t}}
