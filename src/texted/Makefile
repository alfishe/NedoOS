# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

texted.com: texted.asm \
 ../_sdk/codepage/winto866 \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 prdword.asm \
 text_mem.asm \
 textview.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)texted.com

$(BIN_INSTALLDIR)texted.com: texted.com
	$(CP) $< $@

clean:
	$(RM) texted.com
