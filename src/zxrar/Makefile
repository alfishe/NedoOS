# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

zxrar.com: zxrar.asm \
 ../_sdk/file.asm \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 rarhuff.asm \
 rarlz.asm \
 rarpack.asm \
 zxrfile.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)zxrar.com

$(BIN_INSTALLDIR)zxrar.com: zxrar.com
	$(CP) $< $@

clean:
	$(RM) zxrar.com
