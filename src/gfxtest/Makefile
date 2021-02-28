# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

gfxtest.com: gfxtest.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)gfxtest.com

$(BIN_INSTALLDIR)gfxtest.com: gfxtest.com
	$(CP) $< $@

clean:
	$(RM) gfxtest.com
