# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

montana2.com: 1.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 MJ2.ASM \
 montana2.scr \
 pal.ast \
 prspr.asm \
 sprites.ast \
 tiles.ast
	$(AS) $(AFLAGS) $<

tiles.ast: tiles.bmp tiles.dat
	$(NEDORES) $^ $@

sprites.ast: sprites.bmp sprites.dat
	$(NEDORES) $^ $@

pal.ast: sprites.bmp pal.dat
	$(NEDORES) $^ $@

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/montana2.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/montana2.com: montana2.com
	$(CP) $< $@

clean:
	$(RM) montana2.com pal.ast sprites.ast tiles.ast
