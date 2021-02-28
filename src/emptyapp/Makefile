# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

emptyapp.com: emptyapp.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)emptyapp.com

$(BIN_INSTALLDIR)emptyapp.com: emptyapp.com
	$(CP) $< $@

clean:
	$(RM) emptyapp.com
