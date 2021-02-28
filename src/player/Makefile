# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

player.com: player.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 ptsplay.asm \
 tfmplay.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)player.com

$(BIN_INSTALLDIR)player.com: player.com
	$(CP) $< $@

clean:
	$(RM) player.com
