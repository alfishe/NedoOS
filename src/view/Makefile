# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

view.com: view.asm \
 ../_sdk/file.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 888.asm \
 chr.asm \
 deblc.asm \
 grf.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)view.com

$(BIN_INSTALLDIR)view.com: view.com
	$(CP) $< $@

clean:
	$(RM) view.com
