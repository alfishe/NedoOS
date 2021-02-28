# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

more.com: more.asm \
 ../_sdk/codepage/winto866 \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 prdword.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)more.com

$(BIN_INSTALLDIR)more.com: more.com
	$(CP) $< $@

clean:
	$(RM) more.com
