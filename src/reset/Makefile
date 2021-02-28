# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

reset.com: reset.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)reset.com

$(BIN_INSTALLDIR)reset.com: reset.com
	$(CP) $< $@

clean:
	$(RM) reset.com
