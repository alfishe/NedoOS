# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

modplay.com: modplay.asm \
 ../_sdk/file.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 gsports.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)modplay.com

$(BIN_INSTALLDIR)modplay.com: modplay.com
	$(CP) $< $@

clean:
	$(RM) modplay.com
