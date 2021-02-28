# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

hello.com: hello.asm \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)hello.com

$(BIN_INSTALLDIR)hello.com: hello.com
	$(CP) $< $@

clean:
	$(RM) hello.com
