# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

netterm.com: term.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)netterm.com

$(BIN_INSTALLDIR)netterm.com: netterm.com
	$(CP) $< $@

clean:
	$(RM) netterm.com
