# Local pack:
#   bin/multibank.com
#   bin/multibank/codeB_XX.bin
#
# Plan JT: JP table @8000, CSTR/CONST -> *_RESIDENT in bank.
# --- edit this list when adding/removing overlays (codebank_XX.c) ---
BANKS := 01 02 03
OVL_SYMS := mb_report_bank ttyputs printf ttyputchar
# --------------------------------------------------------------------

OUTDIR  := bin
BANKDIR := $(OUTDIR)/multibank
BIN		:= $(OUTDIR)/multibank.com
INSTDIR :=
CONSOLE := TTY

SRCC	:= main.c mb_bank.c mb_load.c bank_call.c
SRCH	:= mb_inc.h mb_plug.h mb_bank.h mb_banks.h bank_jt.h
SRCA	:= force_helpers.asm
XCLFILE	:= lnk.xcl
XCL_OVL	:= lnk_ovl.xcl

include ../iarlib/iar.mk

MBOVL		:= $(TOOL)/mbovl.exe
ROOT_HASH	:= $(OBJ)/root_fp.txt
REL_BIN		:= $(ROOTDIR)/release/bin
REL_BANK	:= $(REL_BIN)/multibank
FIRST_BANK	:= $(firstword $(BANKS))
BANK_BINS	:= $(foreach b,$(BANKS),$(BANKDIR)/codeB_$(b).bin)

all: mb_banks.h oslib $(BIN) $(BANK_BINS) check-addrs install
	@echo multibank: $(BIN) + $(BANKDIR)/*.bin  (banks: $(BANKS))

$(OUTDIR) $(BANKDIR) $(REL_BIN) $(REL_BANK) $(OBJ):
	$(MKDIR) -p $@

mb_banks.h: Makefile $(MBOVL)
	$(MBOVL) gen-h $(words $(BANKS)) $@

$(OBJ)/bank_jt.r01: bank_jt.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) bank_jt.asm

define BANK_template
$$(OBJ)/codebank_$(1).r01: codebank_$(1).c $$(SRCH) $$(LIBH) | $$(OBJ)
	$$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$$(OBJ)/ -L$$(OBJ)/ -A$$(OBJ)/ -I$$(IARINC) -I$$(LIBDIR) codebank_$(1).c
	powershell -NoProfile -Command "(Get-Content -Raw '$$(OBJ)/codebank_$(1).s01') -replace 'RSEG[ \t]+CSTR\b','RSEG CSTR_RESIDENT' -replace 'RSEG[ \t]+CCSTR\b','RSEG CCSTR_RESIDENT' -replace 'RSEG[ \t]+CONST\b','RSEG CONST_RESIDENT' | Set-Content -NoNewline '$$(OBJ)/codebank_$(1)_b.s01'"
	@powershell -NoProfile -Command "if (Select-String -Path '$$(OBJ)/codebank_$(1)_b.s01' -Pattern 'RSEG[ \t]+(IDATA0|UDATA0|DATA0|CONST|CSTR)\b' -Quiet) { Write-Error 'BANK emits low DATA/CONST/CSTR'; exit 1 }"
	$$(AZ80) -uu -S -v0 -O$$(OBJ)/ -I$$(OSSDK) $$(OBJ)/codebank_$(1)_b.s01
	$$(CP) $$(OBJ)/codebank_$(1)_b.r01 $$(OBJ)/codebank_$(1).r01

$$(OBJ)/mb_ovl$(1).com: $$(LIBDIR)iar.lib $$(OBJC) $$(OBJA) $$(OBJ)/bank_jt.r01 $$(OBJ)/codebank_$(1).r01 $$(XCL_OVL) | $$(OBJ)
	$$(XLINK) $$(LNK_CONS) -gbank_jt -gforce_helpers $$(OBJC) $$(OBJA) $$(OBJ)/bank_jt.r01 $$(OBJ)/codebank_$(1).r01 -FRAW-BINARY -S -o $$@ -l $$(OBJ)/cout_ovl$(1).html -xehinms -Z\(CODE\)DBGMON=FFFF-FFFF $$(LIBDIR)iar.lib -C $$(IARLIB) -f $$(XCL_OVL)

$$(BANKDIR)/codeB_$(1).bin: $$(OBJ)/mb_ovl$(1).com $$(MBOVL) | $$(BANKDIR)
ifeq ($(1),$$(FIRST_BANK))
	$$(RM) $$(ROOT_HASH)
endif
	$$(MBOVL) extract $$< $$@ --root-hash $$(ROOT_HASH)
endef

$(foreach b,$(BANKS),$(eval $(call BANK_template,$(b))))

PREV_BIN :=
$(foreach b,$(BANKS),\
	$(if $(PREV_BIN),$(eval $(BANKDIR)/codeB_$(b).bin: $(PREV_BIN)))\
	$(eval PREV_BIN := $(BANKDIR)/codeB_$(b).bin))

$(BIN): $(LIBDIR)iar.lib $(OBJC) $(OBJA) lnk.xcl mb_banks.h | $(OBJ) $(OUTDIR)
	$(XLINK) $(LNK_CONS) $(OBJC) $(OBJA) $(LINK_OPTIONS) $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCLFILE)

check-addrs: $(BIN) $(BANK_BINS) $(MBOVL)
	$(foreach b,$(BANKS),$(MBOVL) check $(OBJ)/cout.html $(OBJ)/cout_ovl$(b).html $(OVL_SYMS) &&) echo check-addrs OK

install: $(BIN) $(BANK_BINS) | $(REL_BIN) $(REL_BANK)
	$(CP) $(BIN) $(REL_BIN)/
	$(foreach b,$(BANKS),$(CP) $(BANKDIR)/codeB_$(b).bin $(REL_BANK)/ &&) echo install OK

clean:
	$(RM) $(OBJ) $(OUTDIR) $(ROOT_HASH) mb_banks.h
