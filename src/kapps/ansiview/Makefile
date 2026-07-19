INSTDIR := bin/
CONSOLE := BDOS
XCLFILE := lnk.xcl

BIN := ansiview.com

SRCC := main_ansiview.c term.c term_doc.c cp437toatm.c ansi_file.c
SRCA := termscr.asm
SRCH := term.h term_doc.h ansi_file.h

LIBDIR	:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))../iarlib/
ROOTDIR := $(abspath $(LIBDIR)../../..)

TOOL	:= $(abspath $(ROOTDIR)/tools)
OSSDK	:= $(abspath $(ROOTDIR)/src/_sdk)
IAR		:= $(abspath $(ROOTDIR)/iar)

IARINC	:= "$(IAR)/inc/"
IARLIB	:= "$(IAR)/lib/clz80.r01"
LIBH	:= $(wildcard $(LIBDIR)*.h)

OBJ		:= ./obj
OBJC	:= $(patsubst %.c,$(OBJ)/%.r01,$(SRCC))
OBJA	:= $(patsubst %.asm,$(OBJ)/%.r01,$(SRCA))
OBJS	:= $(OBJC) $(OBJA)

ifeq ($(OS),Windows_NT)
RM	:= $(TOOL)/msys/rm.exe -r -f
MKDIR	:= $(TOOL)/msys/mkdir.exe
MAKE	:= $(TOOL)/mingw/make.exe
CP	:= $(TOOL)/msys/cp.exe
WINE	:=
else
RM		:= rm -r -f
MKDIR	:= mkdir
MAKE	:= make
CP		:= cp
WINE	:= wine
endif

AZ80	:= $(WINE)$(IAR)/bin/az80.exe
ICCZ80	:= $(WINE)$(IAR)/bin/iccz80.exe
XLINK	:= $(WINE)$(IAR)/bin/xlink.exe

LINK_OPTIONS=-FRAW-BINARY -S -xehinms -Z\(CODE\)DBGMON=FFFF-FFFF
LNK_CONS:= -ebdosgets=gets -ebdosputs=puts -ebdosputchar=putchar -ebdosgetkey=_low_level_get

all: oslib $(BIN) install

$(BIN): $(LIBDIR)iar.lib $(OBJS) lnk.xcl | $(OBJ)
	$(XLINK) $(LNK_CONS) $(OBJS) $(LINK_OPTIONS) -o $(BIN) -l $(OBJ)/cout.html $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCLFILE)

install: $(BIN)
	$(CP) $(BIN) $(ROOTDIR)/release/$(INSTDIR)

$(OBJ)/%.r01: %.c $(SRCH) $(LIBH) | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) $<

$(OBJ)/%.r01: %.asm $(OSSDK)/sysdefs.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) $<

$(OBJ):
	$(MKDIR) $@

oslib:
	@$(MAKE) -s -C $(LIBDIR) -f $(LIBDIR)Makefile

clean:
	$(RM) $(OBJ) $(BIN)

.PHONY: all install oslib clean
