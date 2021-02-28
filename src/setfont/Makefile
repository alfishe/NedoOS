# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

setfont.com: setfont.asm \
 atmucode.fnt
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)setfont.com

$(BIN_INSTALLDIR)setfont.com: setfont.com
	$(CP) $< $@

clean:
	$(RM) setfont.com
