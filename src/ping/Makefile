# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

ping.com: ping.asm \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 string.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)ping.com

$(BIN_INSTALLDIR)ping.com: ping.com
	$(CP) $< $@

clean:
	$(RM) ping.com
