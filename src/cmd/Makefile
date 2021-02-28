# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

cmd.com: cmd.asm \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 cmdpr.asm \
 prdword.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)cmd.com

$(BIN_INSTALLDIR)cmd.com: cmd.com
	$(CP) $< $@

clean:
	$(RM) cmd.com
