# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

rdtrd.com: rdtrd.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)rdtrd.com

$(BIN_INSTALLDIR)rdtrd.com: rdtrd.com
	$(CP) $< $@

clean:
	$(RM) rdtrd.com
