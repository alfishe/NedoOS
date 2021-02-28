# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

tar.com: tar.asm \
 ../_sdk/file.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)tar.com

$(BIN_INSTALLDIR)tar.com: tar.com
	$(CP) $< $@

clean:
	$(RM) tar.com
