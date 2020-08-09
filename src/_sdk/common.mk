
SJASMPLUSFLAGS	= --nologo --msg=war
BIN_INSTALLDIR	= $(INSTALLDIR)/bin
RES_INSTALLDIR	= $(INSTALLDIR)/bin
DOC_INSTALLDIR	= $(INSTALLDIR)/doc
WINTOP 			:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))../../../))
INSTALLDIR		:= $(dir $(WINTOP)release/)
EMULIMG			= $(WINTOP)us/sd_nedo.vhd
SJASMPLUS		= $(WINTOP)tools/sjasmplus
DMIMG			= $(WINTOP)tools/dmimg

ifeq ($(OS),Windows_NT)
	WINSDK := $(dir $(WINTOP)src/_sdk/)
	ISWIN = 1
	ASPP = "../../tools/parsasm.bat"
	DEPAS = ${ASPP}
	DEPAFLAGS	= -E -MM -I $(WINSDK)
	RM = @del /Q
	COPY = @copy /Y
	MKDIR = @mkdir
	MOVE = @move
	IMGUNPACK = $(WINTOP)tools/images.exe
else
	ASPP = ../../tools/aspp.sh
	DEPAS = env LC_CTYPE=C ${ASPP}
	DEPAFLAGS	= -E -MM -I .
	MKDIR = @mkdir -p
	MOVE = @mv
#	DEL = @rm -f
	COPY = cp
#	BINEXT =
endif

# common.mk - common definitions for Makefiles.
#
# Supported environments:
#   GNU/Linux.
#
# Tools used:
#   GNU core utilities, tools/aspp.sh, tools/sjasmplus.
#
# Variables used:
#   DEPAS - tools/aspp.sh name
#   DEPAFLAGS - flags for ${DEPAS}
#   DEPEXT - dependency file's extension (no leading dot)
#   SJASMPLUS - tools/sjasmplus name
#   SJASMPLUSFLAGS - flags for ${SJASMPLUS}

# sjasmplus_rule - rule to compile assembler source file using tools ${DEPAS} and ${SJASMPLUS}
#
# Parameters:
# ${1} = output file(s)
# ${2} = single input file
# ${3} = extra parameters for "sjasmplus"
# ${4} = variable's name for output dependencies files list (or empty)
# ${5} = variable's name for output binaries files list (or empty)
#
# Usage:
# ${eval ${call sjasmplus_rule,${RELEASE}/program.com ${RELEASE}/intro.com,main.asm,,DEPS,BINS}}

define sjasmplus_rule =
# Dependency generation rule for .asm file:
${patsubst %${suffix ${2}},%.d,${2}}: ${2}
	$${RM} $$@ && $${DEPAS} $${DEPAFLAGS} ${addprefix -MT ,${1}} -MT $$@ -MF $$@ $$<
${1}: ${2}
	$${SJASMPLUS} $${SJASMPLUSFLAGS} ${3} $$< --raw=$$@
ifneq "${4}" ""
${4}+=${patsubst %${suffix ${2}},%.d,${2}}
endif
ifneq "${5}" ""
${5}+=${1}
endif
endef

# sjasmplus_odd_rule - rule to compile assembler source file using tools ${DEPAS} and ${SJASMPLUS}
#
# Parameters:
# ${1} = output file(s) - must be the same as specified in the source file!
# ${2} = single input file
# ${3} = extra parameters
# ${4} = variable's name for output dependencies files list (or empty)
# ${5} = variable's name for output binaries files list (or empty)
#
# Usage:
# ${eval ${call sjasmplus_odd_rule,${RELEASE}/program.com ${RELEASE}/intro.com,main.asm,,DEPS,BINS}}

define sjasmplus_odd_rule =
# Dependency generation rule for .asm file:
# FIXME: No output file specified here (we must check sources manually):
${patsubst %${suffix ${2}},%.d,${2}}: ${2}
	$${RM} $$@ && $${DEPAS} $${DEPAFLAGS} ${addprefix -MT ,${1}} -MT $$@ -MF $$@ $$<
${1}: ${2}
	$${SJASMPLUS} $${SJASMPLUSFLAGS} ${3} $$<
ifneq "${4}" ""
${4}+=${patsubst %${suffix ${2}},%.d,${2}}
endif
ifneq "${5}" ""
${5}+=${1}
endif
endef

# copy_file_rule - rule to copy single file
#
# Parameters:
# ${1} = single output file
# ${2} = single input file
# ${3} = variable's name for output files list (or empty)
#
# Usage:
# ${eval ${call copy_file_rule,${RELEASE}/program.spr,sprites.bin,ALL_BINS}}

define copy_file_rule =
${1}: ${2}
	$(MKDIR) $${@D}
	$(COPY) $$< $$@
ifneq "${3}" ""
${3}+=${1}
endif
endef

# copy_to_dir_rule - rule to copy file(s) to a directory
#
# Parameters:
# ${1} = output directory (no trailing '/')
# ${2} = input file(s)
# ${3} = variable's name for output files list (or empty)
#
# Usage:
# ${eval ${call copy_to_dir_rule,${RELEASE}/data,gfx.bin music.bin,ALL_BINS}}

define copy_to_dir_rule =
${foreach f,${2},${eval ${call copy_file_rule,${1}/${notdir ${f}},${f},${3}}}}
endef
# All targets
TARGETS=executables resources
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
${BIN_INSTALLDIR} \
${RES_INSTALLDIR} \
${DOC_INSTALLDIR} \
}:
	$(MKDIR) $@

##########################
## Target "executables" ##
##########################

EXEC_DEPS=
EXEC_BINS=

${eval ${call sjasmplus_odd_rule,${NAME},${SOURCES},,EXEC_DEPS,EXEC_BINS}}

executables: ${EXEC_BINS}

install-executables: executables | ${BIN_INSTALLDIR}
	$(COPY) ${EXEC_BINS} "$|"

clean-executables:
	${RM} ${EXEC_DEPS} ${EXEC_BINS}

$(EMULIMG): 
	$(RM) b.bat *.vhd
	$(IMGUNPACK)
	$(MOVE) $(notdir $@) "$@"
	$(RM) b.bat *.vhd

DEPS+=${EXEC_DEPS}

########################
## Target "resources" ##
########################

resources: ${RESOURCES}

install-resources: resources | ${RES_INSTALLDIR}
ifneq "${sort ${RESOURCES}}" ""
	$(COPY) ${RESOURCES} "$|"
endif

clean-resources:

####################
## Common targets ##
####################

all: executables resources

install: install-executables install-resources

ifeq "${sort ${DOCS}}" ""
install-doc:
else
install-doc: ${DOCS} | ${DOC_INSTALLDIR}
	$(COPY) $^ $|
endif


install-unreal: ${EMULIMG}

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
