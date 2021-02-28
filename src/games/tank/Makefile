# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

tank.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 collisio.asm \
 input.asm \
 macro.asm \
 math.asm \
 sprite.asm \
 sprset.ast \
 tankdata.asm \
 tankgfx.asm \
 tileset.ast \
 zx.fnt
	$(AS) $(AFLAGS) $<

sprset.ast: sprset.bmp sprset.da
	$(NEDORES) $^ $@

tileset.ast: tileset.bmp tileset.da
	$(NEDORES) $^ $@

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/tank.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/tank.com: tank.com
	$(CP) $< $@

clean:
	$(RM) sprset.ast tank.com tileset.ast
