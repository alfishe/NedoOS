# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

term.com: term.asm \
 ../_sdk/codepage/866toatm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)term.com

$(BIN_INSTALLDIR)term.com: term.com
	$(CP) $< $@

clean:
	$(RM) term.com
