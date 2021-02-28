# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

unrar.com: unrar.asm \
 ../_sdk/file.asm \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 rardepk.asm \
 rarfile.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)unrar.com

$(BIN_INSTALLDIR)unrar.com: unrar.com
	$(CP) $< $@

clean:
	$(RM) unrar.com
