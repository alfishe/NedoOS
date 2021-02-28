# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

pkunzip.com: pkunzip.asm \
 ../_sdk/file.asm \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 depk.asm \
 zipfile.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)pkunzip.com

$(BIN_INSTALLDIR)pkunzip.com: pkunzip.com
	$(CP) $< $@

clean:
	$(RM) pkunzip.com
