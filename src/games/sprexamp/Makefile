# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean


sprexamp.com: main.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 bgpush.asm \
 bgpushxy.asm \
 bmp.asm \
 camera.asm \
 cls.asm \
 fontgfx \
 init.asm \
 int.asm \
 logic.asm \
 mem.asm \
 pal.ast \
 prspr.asm \
 sprdata.asm
	$(AS) $(AFLAGS) $<

sprexamp:
	$(MKDIR) $@

pal.ast: images/WHUM1.bmp images/pal.dat
	$(NEDORES) $^ $@

tiles.ast: images/tiles1.bmp images/tiles.dat
	$(NEDORES) $^ $@

sprexamp/tiles.bin: tiles.ast | sprexamp
	$(AS) $(AFLAGS) $< --raw=$@

WBAR.ast: images/WBAR.bmp images/WBAR.dat
	$(NEDORES) $^ $@

sprexamp/WBAR.bin: WBAR.ast | sprexamp
	$(AS) $(AFLAGS) $< --raw=$@

WHUM1.ast: images/WHUM1.bmp images/WHUM1.dat
	$(NEDORES) $^ $@

sprexamp/WHUM1.bin: WHUM1.asm WHUM1.ast | sprexamp
	$(AS) $(AFLAGS) $<

sprexamp/music.bin: music.asm ptsplay.asm everlast.pt3 | sprexamp
	$(AS) $(AFLAGS) $<

sprexamp/sfx.bin: sfx.asm ayfxplay.asm sfx.afb | sprexamp
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/sprexamp.com \
 $(INSTALLDIR)/sprexamp \
 $(INSTALLDIR)/sprexamp/WBAR.bin \
 $(INSTALLDIR)/sprexamp/WHUM1.bin \
 $(INSTALLDIR)/sprexamp/bg6-16c.bmp \
 $(INSTALLDIR)/sprexamp/bg8-16d.bmp \
 $(INSTALLDIR)/sprexamp/map1.enm \
 $(INSTALLDIR)/sprexamp/map1.map \
 $(INSTALLDIR)/sprexamp/tiles.bin \
 $(INSTALLDIR)/sprexamp/tiles1.bmp \
 $(INSTALLDIR)/sprexamp/music.bin \
 $(INSTALLDIR)/sprexamp/sfx.bin

$(INSTALLDIR) \
 $(INSTALLDIR)/sprexamp:
	$(MKDIR) $@

$(INSTALLDIR)/sprexamp.com: sprexamp.com
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/WBAR.bin: sprexamp/WBAR.bin
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/WHUM1.bin: sprexamp/WHUM1.bin
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/bg6-16c.bmp: images/bg6-16c.bmp
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/bg8-16d.bmp: images/bg8-16d.bmp
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/map1.enm: map1.enm
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/map1.map: map1.map
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/music.bin: sprexamp/music.bin
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/sfx.bin: sprexamp/sfx.bin
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/tiles.bin: sprexamp/tiles.bin
	$(CP) $< $@

$(INSTALLDIR)/sprexamp/tiles1.bmp: images/tiles1.bmp
	$(CP) $< $@

clean:
	$(RM) \
 WBAR.ast \
 WHUM1.ast \
 pal.ast \
 sprexamp.com \
 sprexamp/WBAR.bin \
 sprexamp/WHUM1.bin \
 sprexamp/music.bin \
 sprexamp/sfx.bin \
 sprexamp/tiles.bin \
 tiles.ast
