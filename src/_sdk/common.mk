# common.mk - common definitions for Makefiles.
#
# Supported environments:
#   GNU/Linux
#   Microsoft Windows (partly)
#
# Tools used:
#   GNU core utilities
#   tools/aspp
#   tools/sjasmplus
#   tools/dmimg
#
# Variables used:
#   WINTOP - project's base path
#   WINSDK - project's SDK path
#   INSTALLDIR - installation path
#   DEPAS - "tools/aspp" name
#   DEPAFLAGS - flags for ${DEPAS}
#   DEPEXT - dependency file's extension (no leading dot)
#   SJASMPLUS - "tools/sjasmplus" name
#   SJASMPLUSFLAGS - flags for ${SJASMPLUS}
#   DMIMG - "tools/dmimg" name

WINTOP 		:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))../../../))
WINSDK		:= $(dir $(WINTOP)src/_sdk/)
INSTALLDIR	:= $(dir $(WINTOP)release/)
BIN_INSTALLDIR	= $(INSTALLDIR)/bin
RES_INSTALLDIR	= $(INSTALLDIR)/bin
DOC_INSTALLDIR	= $(INSTALLDIR)/doc
DEPAS		= $(WINTOP)tools/aspp
DEPAFLAGS	= -E -MM -I . -I $(WINSDK)
DEPEXT		= d
SVNREVISION := $(firstword $(subst :, ,$(shell svnversion -n)))
SVNREVISION := $(subst M,,${SVNREVISION})
SVNREVISION := $(subst P,,${SVNREVISION})
SVNREVISION := $(subst S,,${SVNREVISION})
SVNREVISION := $(subst Unversioned,0,${SVNREVISION})
SJASMPLUS	= $(WINTOP)tools/sjasmplus
SJASMPLUSFLAGS	= --nologo --lst --msg=war -DSVNREVISION=${SVNREVISION}
DMIMG		= $(WINTOP)tools/dmimg
EMULIMG		= $(WINTOP)us/sd_nedo.vhd

ifeq ($(OS),Windows_NT)
	ISWIN = 1
#	DEPAS = "$(WINTOP)tools/parsasm.bat"
	RM = @del /Q
	COPY = @copy /Y
	MKDIR = @mkdir
	MOVE = @move
	IMGUNPACK = $(WINTOP)tools/images.exe
else
	MKDIR = @mkdir -p
	MOVE = @mv
#	DEL = @rm -f
	COPY = cp
#	BINEXT =
endif

# Clear lists
DEPS=

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
	$${SJASMPLUS} $${SJASMPLUSFLAGS} ${SJASMOPTS} ${3} $$<
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
