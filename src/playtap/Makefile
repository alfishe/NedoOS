# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

playtap.com: playtap.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)playtap.com 

$(BIN_INSTALLDIR)playtap.com: playtap.com
	$(CP) $< $@

clean:
	$(RM) playtap.com
