# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

basic.com: basic.asm \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 bascmds.asm
	$(AS) $(AFLAGS) $<

install: \
 $(BIN_INSTALLDIR)basic.com \
 $(RES_INSTALLDIR)example.bas \
 $(RES_INSTALLDIR)example.thk

$(BIN_INSTALLDIR)basic.com: basic.com
	$(CP) $< $@

$(RES_INSTALLDIR)example.bas: example.bas
	$(CP) $< $@

$(RES_INSTALLDIR)example.thk: example.thk
	$(CP) $< $@

clean:
	$(RM) basic.com
