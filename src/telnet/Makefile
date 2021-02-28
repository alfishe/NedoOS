# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

telnet.com: telnet.asm \
 ../_sdk/string.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)telnet.com

$(BIN_INSTALLDIR)telnet.com: telnet.com
	$(CP) $< $@

clean:
	$(RM) telnet.com
