# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

tetris.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 zx.fnt
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/tetris.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/tetris.com: tetris.com
	$(CP) $< $@

clean:
	$(RM) tetris.com
