# Supported environments:
#   GNU/Linux.

ZEXDOC_SRC = ./zexdoc/zexdoc.asm
ZEXALL_SRC = ./zexall/zexall.asm

SJASM = ../../tools/sjasmplus
SJASM_EXTRA_ARGS = --nologo --msg=war

ZEXDOC_TARGET = zexdoc.com
ZEXALL_TARGET = zexall.com

.PHONY: all

all: $(ZEXDOC_TARGET) $(ZEXALL_TARGET)

$(ZEXDOC_TARGET): $(ZEXDOC_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

$(ZEXALL_TARGET): $(ZEXALL_SRC)
	$(SJASM) $(SJASM_EXTRA_ARGS) $<

clean:
	rm -f $(ZEXDOC_TARGET) $(ZEXALL_TARGET)

