# Supported environments:
#   GNU/Linux.

SJASM = ../../tools/sjasmplus
SJASM_EXTRA_ARGS = --nologo --msg=war --lst



ZEXDOC_SRC = ./zexdoc/zexdoc.asm
ZEXALL_SRC = ./zexall/zexall.asm

Z801SRC = ./z80test/src/z80ccf.asm
Z802SRC = ./z80test/src/z80doc.asm
Z803SRC = ./z80test/src/z80docflags.asm
Z804SRC = ./z80test/src/z80flags.asm
Z805SRC = ./z80test/src/z80full.asm
Z806SRC = ./z80test/src/z80memptr.asm
Z80TST_SRC = ./z80test/src/crctab.asm ./z80test/src/idea.asm ./z80test/src/main.asm ./z80test/src/nedowrap.asm ./z80test/src/print.asm ./z80test/src/testmacros.asm ./z80test/src/tests.asm


ZEXDOC_TARGET = zexdoc.com
ZEXALL_TARGET = zexall.com

Z801TGT = z80ccf.com
Z802TGT = z80doc.com
Z803TGT = z80docflags.com
Z804TGT = z80flags.com
Z805TGT = z80full.com
Z806TGT = z80memptr.com

.PHONY: all

all: $(ZEXDOC_TARGET) $(ZEXALL_TARGET) $(Z801TGT) $(Z802TGT) $(Z803TGT) $(Z804TGT) $(Z805TGT) $(Z806TGT)

$(ZEXDOC_TARGET): $(ZEXDOC_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

$(ZEXALL_TARGET): $(ZEXALL_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

$(Z801TGT): $(Z801SRC) $(Z80TST_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

$(Z802TGT): $(Z802SRC) $(Z80TST_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

$(Z803TGT): $(Z803SRC) $(Z80TST_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

$(Z804TGT): $(Z804SRC) $(Z80TST_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

$(Z805TGT): $(Z805SRC) $(Z80TST_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

$(Z806TGT): $(Z806SRC) $(Z80TST_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

clean:
	rm -f *.com


