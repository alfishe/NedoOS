# Local pack + release/emulator layout:
#   bin/multibank.com
#   bin/multibank/codeB_0N.bin
OUTDIR  := bin
BANKDIR := $(OUTDIR)/multibank

BIN		:= $(OUTDIR)/multibank.com
INSTDIR :=
CONSOLE := TTY

# --- Root (0100-7FFF): always in multibank.com ---
SRCC	:= main.c mb_bank.c mb_load.c
SRCH	:= mb_inc.h mb_plug.h mb_bank.h
SRCA	:=
XCLFILE	:= lnk.xcl
XCL_OVL	:= lnk_ovl.xcl

include ../iarlib/iar.mk

PYTHON	:= python
EXTRACT	:= $(PYTHON) extract_bank.py

BANK1_SRC := codebank_01.c
BANK2_SRC := codebank_02.c
BANK3_SRC := codebank_03.c

BANK1_OBJ := $(OBJ)/codebank_01.r01
BANK2_OBJ := $(OBJ)/codebank_02.r01
BANK3_OBJ := $(OBJ)/codebank_03.r01

BANK1_COM := $(OBJ)/mb_ovl01.com
BANK2_COM := $(OBJ)/mb_ovl02.com
BANK3_COM := $(OBJ)/mb_ovl03.com

BANK1_BIN := $(BANKDIR)/codeB_01.bin
BANK2_BIN := $(BANKDIR)/codeB_02.bin
BANK3_BIN := $(BANKDIR)/codeB_03.bin
BANK_BINS := $(BANK1_BIN) $(BANK2_BIN) $(BANK3_BIN)

ROOT_HASH := $(OBJ)/root_sha256.txt

REL_BIN   := $(ROOTDIR)/release/bin
REL_BANK  := $(REL_BIN)/multibank

# Override iar.mk "all"
all: oslib $(BIN) $(BANK_BINS) install
	@echo multibank: $(BIN) + $(BANKDIR)/*.bin

$(OUTDIR) $(BANKDIR) $(REL_BIN) $(REL_BANK):
	$(MKDIR) -p $@

$(BANK1_OBJ): $(BANK1_SRC) $(SRCH) $(LIBH) | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) $(BANK1_SRC)

$(BANK2_OBJ): $(BANK2_SRC) $(SRCH) $(LIBH) | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) $(BANK2_SRC)

$(BANK3_OBJ): $(BANK3_SRC) $(SRCH) $(LIBH) | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) $(BANK3_SRC)

# 1) Root-only image ? bin/multibank.com
$(BIN): $(LIBDIR)iar.lib $(OBJC) $(OBJA) lnk.xcl | $(OBJ) $(OUTDIR)
	$(XLINK) $(LNK_CONS) $(OBJC) $(OBJA) $(LINK_OPTIONS) $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCLFILE)

$(BANK1_COM): $(LIBDIR)iar.lib $(OBJC) $(BANK1_OBJ) $(XCL_OVL) | $(OBJ)
	$(XLINK) $(LNK_CONS) $(OBJC) $(BANK1_OBJ) -FRAW-BINARY -S -o $@ -l $(OBJ)/cout_ovl01.html -xehinms -Z\(CODE\)DBGMON=FFFF-FFFF $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCL_OVL)

$(BANK2_COM): $(LIBDIR)iar.lib $(OBJC) $(BANK2_OBJ) $(XCL_OVL) | $(OBJ)
	$(XLINK) $(LNK_CONS) $(OBJC) $(BANK2_OBJ) -FRAW-BINARY -S -o $@ -l $(OBJ)/cout_ovl02.html -xehinms -Z\(CODE\)DBGMON=FFFF-FFFF $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCL_OVL)

$(BANK3_COM): $(LIBDIR)iar.lib $(OBJC) $(BANK3_OBJ) $(XCL_OVL) | $(OBJ)
	$(XLINK) $(LNK_CONS) $(OBJC) $(BANK3_OBJ) -FRAW-BINARY -S -o $@ -l $(OBJ)/cout_ovl03.html -xehinms -Z\(CODE\)DBGMON=FFFF-FFFF $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCL_OVL)

$(BANK1_BIN): $(BANK1_COM) extract_bank.py | $(BANKDIR)
	$(RM) $(ROOT_HASH)
	$(EXTRACT) $(BANK1_COM) $@ --root-hash $(ROOT_HASH)

$(BANK2_BIN): $(BANK2_COM) extract_bank.py $(BANK1_BIN) | $(BANKDIR)
	$(EXTRACT) $(BANK2_COM) $@ --root-hash $(ROOT_HASH)

$(BANK3_BIN): $(BANK3_COM) extract_bank.py $(BANK2_BIN) | $(BANKDIR)
	$(EXTRACT) $(BANK3_COM) $@ --root-hash $(ROOT_HASH)
	$(PYTHON) check_addrs.py $(OBJ)/cout.html $(OBJ)/cout_ovl01.html
	$(PYTHON) check_addrs.py $(OBJ)/cout.html $(OBJ)/cout_ovl02.html
	$(PYTHON) check_addrs.py $(OBJ)/cout.html $(OBJ)/cout_ovl03.html

# Mirror pack into release/bin/ (same as emulator: com in bin/, bins in bin/multibank/)
install: $(BIN) $(BANK_BINS) | $(REL_BIN) $(REL_BANK)
	$(CP) $(BIN) $(REL_BIN)/
	$(CP) $(BANK1_BIN) $(REL_BANK)/
	$(CP) $(BANK2_BIN) $(REL_BANK)/
	$(CP) $(BANK3_BIN) $(REL_BANK)/

clean:
	$(RM) $(OBJ) $(OUTDIR) $(ROOT_HASH)
	$(RM) multibank.com codeB_01.bin codeB_02.bin codeB_03.bin
