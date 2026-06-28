INSTDIR := bin/
CONSOLE := BDOS
XCLFILE := lnk.xcl

ATELNET_BIN := atelnet.com
ANSIVIEW_BIN := ansiview.com

ATELNET_C := main_telnet.c term.c cp437toatm.c netglue.c telnet_sess.c telbook.c term_doc_stub.c zmodem.c zmodem_os.c
ANSIVIEW_C := main_ansiview.c term.c term_doc.c cp437toatm.c ansi_file.c
SRCA := termscr.asm

SRCH := atelnet.h term_doc.h netglue.h telnet_sess.h ansi_file.h telbook.h zmodem.h

LIBDIR	:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))../iarlib/
ROOTDIR := $(abspath $(LIBDIR)../../..)

TOOL	:= $(abspath $(ROOTDIR)/tools)
OSSDK	:= $(abspath $(ROOTDIR)/src/_sdk)
IAR		:= $(abspath $(ROOTDIR)/iar)

IARINC	:= "$(IAR)/inc/"
IARLIB	:= "$(IAR)/lib/clz80.r01"
LIBH	:= $(wildcard $(LIBDIR)*.h)

OBJ		:= ./obj
ATELNET_OBJ := $(patsubst %.c,$(OBJ)/%.r01,$(ATELNET_C)) $(patsubst %.asm,$(OBJ)/%.r01,$(SRCA))
ANSIVIEW_OBJ := $(patsubst %.c,$(OBJ)/%.r01,$(ANSIVIEW_C)) $(patsubst %.asm,$(OBJ)/%.r01,$(SRCA))

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

all: oslib $(ATELNET_BIN) $(ANSIVIEW_BIN) install

$(ATELNET_BIN): $(LIBDIR)iar.lib $(ATELNET_OBJ) lnk.xcl | $(OBJ)
	$(XLINK) $(LNK_CONS) $(ATELNET_OBJ) $(LINK_OPTIONS) -o $(ATELNET_BIN) -l $(OBJ)/cout_atelnet.html $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCLFILE)

$(ANSIVIEW_BIN): $(LIBDIR)iar.lib $(ANSIVIEW_OBJ) lnk.xcl | $(OBJ)
	$(XLINK) $(LNK_CONS) $(ANSIVIEW_OBJ) $(LINK_OPTIONS) -o $(ANSIVIEW_BIN) -l $(OBJ)/cout_ansiview.html $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCLFILE)

install: $(ATELNET_BIN) $(ANSIVIEW_BIN)
	$(CP) $(ATELNET_BIN) $(ROOTDIR)/release/$(INSTDIR)
	$(CP) $(ANSIVIEW_BIN) $(ROOTDIR)/release/$(INSTDIR)

$(OBJ)/%.r01: %.c $(SRCH) $(LIBH) | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) $<

$(OBJ)/%.r01: %.asm $(OSSDK)/sysdefs.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) $<

$(OBJ):
	$(MKDIR) $@

oslib:
	@$(MAKE) -s -C $(LIBDIR) -f $(LIBDIR)Makefile

clean:
	$(RM) $(OBJ) $(ATELNET_BIN) $(ANSIVIEW_BIN)

.PHONY: all install oslib clean
