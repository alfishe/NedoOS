# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

eric.com: main.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 eric1.asm \
 ericmuz.bin
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/eric.com \
 $(INSTALLDIR)/eric \
 $(INSTALLDIR)/eric/ericgfx.bmp

$(INSTALLDIR) \
 $(INSTALLDIR)/eric:
	$(MKDIR) $@

$(INSTALLDIR)/eric.com: eric.com
	$(CP) $< $@

$(INSTALLDIR)/eric/ericgfx.bmp: eric/ericgfx.bmp
	$(CP) $< $@

clean:
	$(RM) eric.com
