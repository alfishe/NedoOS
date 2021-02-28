# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

wrtrd.com: wrtrd.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)wrtrd.com

$(BIN_INSTALLDIR)wrtrd.com: wrtrd.com
	$(CP) $< $@

clean:
	$(RM) wrtrd.com
