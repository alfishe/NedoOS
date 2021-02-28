# common.mk - common definitions for Makefiles.
#
# Supported environments:
#   GNU/Linux
#   Windows NT

# GNU Make
MFLAGS		:= -w

# Paths
ROOTDIR		:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))../../../))
SRCDIR		:= $(dir $(ROOTDIR)src/)
SDKDIR		:= $(dir $(SRCDIR)_sdk/)
TOOLSDIR	:= $(dir $(ROOTDIR)tools/)
INSTALLDIR	:= $(dir $(ROOTDIR)release/)
BIN_INSTALLDIR	= $(INSTALLDIR)bin/
RES_INSTALLDIR	= $(INSTALLDIR)bin/
DOC_INSTALLDIR	= $(INSTALLDIR)doc/
EMULDIR		:= $(dir $(ROOTDIR)us/)

ifeq ($(OS),Windows_NT)
 # FLags
 ISWIN		:= 1

 # Shell hacks
 COMMENT	:= @rem
 NUL		:= nul

 # GNU core utilities
 CAT		= $(TOOLSDIR)msys/cat.exe
 CP		= $(TOOLSDIR)msys/cp.exe
 MKDIR		= $(TOOLSDIR)msys/mkdir.exe -p
 MV		= $(TOOLSDIR)msys/mv.exe
 RM		= $(TOOLSDIR)msys/rm.exe -f
 RMDIR		= $(TOOLSDIR)msys/rmdir.exe

 # print lines matching a pattern
 GREP		= $(TOOLSDIR)msys/grep.exe

 # GNU Stream Editor
 SED		= $(TOOLSDIR)msys/sed.exe

 # XZ utilities
 XZ		= $(TOOLSDIR)msys/xz.exe
else
 # Shell hacks
 COMMENT	:= \#
 NUL		:= /dev/null

 # GNU core utilities
 CAT		:= cat
 CP		:= cp
 MKDIR		:= mkdir -p
 MV		:= mv
 RM		:= rm -f
 RMDIR		:= rmdir

 # print lines matching a pattern
 GREP		:= grep

 # GNU Stream Editor
 SED		:= sed

 # XZ utilities
 XZ		:= xz
endif

# Dependency generator
DEPAS		= $(TOOLSDIR)aspp
DEPAFLAGS	= --syntax sjasm -E -MM -I . -I $(SDKDIR)
DEPEXT		:= d

# SjAsmPlus compiler
AS		= $(TOOLSDIR)sjasmplus
AFLAGS		:= --nologo --msg=war
SJASMPLUS	= $(AS)
SJASMPLUSFLAGS	= $(AFLAGS)

# GNU patch utility
PATCH		= patch

# GNU C compiler
CC		:= gcc
CFLAGS		:= -m32

# Free Pascal compiler
FPC		:= fpc

# SDK tools
MHMT		= $(TOOLSDIR)mhmt
DMIMG		= $(TOOLSDIR)dmimg
ifeq ($(OS),Windows_NT)
 DMIMG_ADDDIR	= $(TOOLSDIR)dmimg-adddir.bat
 CONVEGA	= $(SDKDIR)bin/convega.exe
 NEDOPAD	= $(SDKDIR)bin/nedopad.exe
 NEDORES	= $(SDKDIR)bin/nedores.exe
 NEDOTRD	= $(SDKDIR)bin/nedotrd.exe
else
 DMIMG_ADDDIR	= $(TOOLSDIR)dmimg-adddir.sh
 CONVEGA	= $(SDKDIR)bin/convega.bin
 NEDOPAD	= $(SDKDIR)bin/nedopad.bin
 NEDORES	= $(SDKDIR)bin/nedores.bin
 NEDOTRD	= $(SDKDIR)bin/nedotrd.bin
endif

# Emulator
ifeq ($(OS),Windows_NT)
 EMUL		= $(EMULDIR)emul.exe
endif
EMULIMG		= $(EMULDIR)sd_nedo.vhd
