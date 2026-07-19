INSTDIR := bin/
CONSOLE := BDOS
XCLFILE := lnk.xcl

ATELNET_BIN := atelnet.com

# Shared ANSI terminal engine lives in ../ansiview (term + CP437 + screen asm).
TERMDIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))../ansiview)
TERMINC := "$(TERMDIR)/"

ATELNET_C := main_telnet.c net_data.c net_resident.c atelnet_net.c telnet_sess.c app_bank.c atelnet_bank.c telbook.c telbook_resident.c cli_resident.c boot_resident.c atelnet_cli.c atelnet_boot.c term_doc_stub.c zmodem_recv.c zmodem_send.c zmodem_os.c
TERM_C := term.c cp437toatm.c
ATELNET_DEFS := -DMALLOC_BUFSIZE=0 -DTERM_NO_DOC=1
TERM_A := termscr.asm

SRCH := $(TERMDIR)/term.h $(TERMDIR)/term_doc.h netglue.h telnet_sess.h telbook.h app_bank.h atelnet_plug.h atelnet_cli.h atelnet_boot.h atelnet_net.h zmodem.h zmodem_datapage.h

LIBDIR	:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))../iarlib/
ROOTDIR := $(abspath $(LIBDIR)../../..)

TOOL	:= $(abspath $(ROOTDIR)/tools)
OSSDK	:= $(abspath $(ROOTDIR)/src/_sdk)
IAR		:= $(abspath $(ROOTDIR)/iar)

IARINC	:= "$(IAR)/inc/"
IARLIB	:= "$(IAR)/lib/clz80.r01"
LIBH	:= $(wildcard $(LIBDIR)*.h)

OBJ		:= ./obj
ATELNET_OBJ := $(patsubst %.c,$(OBJ)/%.r01,$(ATELNET_C)) \
	$(patsubst %.c,$(OBJ)/%.r01,$(TERM_C)) \
	$(patsubst %.asm,$(OBJ)/%.r01,$(TERM_A))

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
ICC_COMMON := $(ATELNET_DEFS) -C -v0 -ml -s7 -S -uu -e -K -gA -I$(IARINC) -I$(LIBDIR) -I$(TERMINC)

all: $(OBJ) oslib $(ATELNET_BIN) install

$(ATELNET_BIN): $(LIBDIR)iar.lib $(ATELNET_OBJ) lnk.xcl | $(OBJ)
	$(XLINK) $(LNK_CONS) $(ATELNET_OBJ) $(LINK_OPTIONS) -o $(ATELNET_BIN) -l $(OBJ)/cout_atelnet.html $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCLFILE)

install: $(ATELNET_BIN)
	$(CP) $(ATELNET_BIN) $(ROOTDIR)/release/$(INSTDIR)

# Local sources
$(OBJ)/%.r01: %.c $(SRCH) $(LIBH) | $(OBJ)
	$(ICCZ80) $(ICC_COMMON) -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ $<

# Shared term sources: compile from TERMDIR so IAR output names stay flat.
OBJABS := $(abspath $(OBJ))
$(OBJ)/%.r01: $(TERMDIR)/%.c $(SRCH) $(LIBH) | $(OBJ)
	cd $(TERMDIR) && $(ICCZ80) $(ICC_COMMON) -O$(OBJABS)/ -L$(OBJABS)/ -A$(OBJABS)/ $(notdir $<)

$(OBJ)/%.r01: $(TERMDIR)/%.asm $(OSSDK)/sysdefs.asm | $(OBJ)
	cd $(TERMDIR) && $(AZ80) -uu -S -v0 -O$(OBJABS)/ -I$(OSSDK) $(notdir $<)

$(OBJ):
	$(MKDIR) $@

oslib:
	@$(MAKE) -s -C $(LIBDIR) -f $(LIBDIR)Makefile

clean:
	$(RM) $(OBJ) $(ATELNET_BIN)

.PHONY: all install oslib clean
