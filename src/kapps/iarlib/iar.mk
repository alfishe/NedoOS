
LIBDIR	:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ROOTDIR := $(abspath $(LIBDIR)../../..)

TOOL	:= $(abspath $(ROOTDIR)/tools)
OSSDK	:= $(abspath $(ROOTDIR)/src/_sdk)
IAR		:= $(abspath $(ROOTDIR)/iar)

IARINC	:= "$(IAR)/inc/"
IARLIB	:= "$(IAR)/lib/clz80.r01"
LIBH	:= $(wildcard $(LIBDIR)*.h)

OBJ		:= ./obj
OBJC	:= $(patsubst  %.c, $(OBJ)/%.r01,$(SRCC))
OBJA	:= $(patsubst  %.asm, $(OBJ)/%.r01,$(SRCA))

ifneq ("$(INSTDIR)","")
INSTBIN	:= $(ROOTDIR)/release/$(INSTDIR)/$(BIN)
else
INSTBIN	:= INSTNULL
endif
	
ifeq ("$(XCLFILE)","")
XCLFILE	:= $(LIBDIR)lnk.xcl
endif	

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
XLIB	:= $(WINE)$(IAR)/bin/xlib.exe
XLINK	:= $(WINE)$(IAR)/bin/xlink.exe



LINK_OPTIONS=-FRAW-BINARY -S -o $(BIN) -l $(OBJ)/cout.html -xehinms -Z\(CODE\)DBGMON=FFFF-FFFF

ifeq ($(CONSOLE),TTY_NE)
LNK_CONS:= -ettygets=gets -ettyputs=puts -ettyputchar=putchar -ettygetkey_ne=_low_level_get
endif

ifeq ($(CONSOLE),TTY)
LNK_CONS:= -ettygets=gets -ettyputs=puts -ettyputchar=putchar -ettygetkey=_low_level_get
endif
ifeq ($(CONSOLE),BDOS)
LNK_CONS:= -ebdosgets=gets -ebdosputs=puts -ebdosputchar=putchar -ebdosgetkey=_low_level_get
endif
ifeq ($(CONSOLE),BDOSMOUSE)
LNK_CONS:= -ebdosgets=gets -ebdosputs=puts -ebdosputchar=putchar -ebdosgetkeyms=_low_level_get
endif


all: oslib $(INSTBIN)
	
$(BIN): $(LIBDIR)iar.lib $(OBJC) $(OBJA) lnk.xcl | $(OBJ)
	$(XLINK) $(LNK_CONS) $(OBJC) $(OBJA) $(LINK_OPTIONS) $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCLFILE)

$(OBJ)/%.r01: %.asm  $(OSSDK)/sysdefs.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) $<

$(OBJ)/%.r01: %.c  $(SRCH) $(LIBH) | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) $<

$(OBJ):
	$(MKDIR) $@

clean: 
	$(RM) $(OBJ) $(BIN)
	
oslib:
	@$(MAKE) -s -C $(LIBDIR) -f $(LIBDIR)Makefile
	
$(INSTBIN): $(BIN)
ifneq ("$(INSTDIR)","")
	$(CP) $(BIN) $(ROOTDIR)/release/$(INSTDIR)/
endif
