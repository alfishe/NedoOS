# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

loyd.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 loydgfx.ast \
 zx.fnt
	$(AS) $(AFLAGS) $<

loydgfx.ast: loyd.bmp loyd.dat
	$(NEDORES) $^ $@

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/loyd.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/loyd.com: loyd.com
	$(CP) $< $@

clean:
	$(RM) loyd.com loydgfx.ast
