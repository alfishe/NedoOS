# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

wolf3d.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 DOOM-MUS \
 WATM2.asm \
 WCTRL.asm \
 WREND.asm \
 WSCAN10.asm \
 corlogd_ \
 cos \
 da \
 demorec9 \
 genscale.asm \
 logd \
 logd2sc3 \
 map48.E \
 mapatm.E \
 plusctg \
 pluslcos \
 scalesw3 \
 sin \
 sqr2int \
 tscale3
	$(AS) $(AFLAGS) $<

wolf3d:
	$(MKDIR) $@

mapatm.E: WOLF484.TRD
	$(NEDOTRD) $< -e $@

wolf3d/sfx.bin: sfx.asm \
 ayfxplay.asm \
 sfx.afb \
 | wolf3d
	$(AS) $(AFLAGS) $<

wolf3d/music.bin: music.asm \
 ptsplay.asm \
 testmusi.pt3 \
 | wolf3d
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/wolf3d.com \
 $(INSTALLDIR)/wolf3d \
 $(INSTALLDIR)/wolf3d/music.bin \
 $(INSTALLDIR)/wolf3d/sfx.bin \
 $(INSTALLDIR)/wolf3d/wolftex.bmp \
 $(INSTALLDIR)/wolf3d/wolfspr.bmp

$(INSTALLDIR) \
 $(INSTALLDIR)/wolf3d:
	$(MKDIR) $@

$(INSTALLDIR)/wolf3d.com: wolf3d.com
	$(CP) $< $@

$(INSTALLDIR)/wolf3d/music.bin: wolf3d/music.bin
	$(CP) $< $@

$(INSTALLDIR)/wolf3d/sfx.bin: wolf3d/sfx.bin
	$(CP) $< $@

$(INSTALLDIR)/wolf3d/wolftex.bmp: wolftex.bmp
	$(CP) $< $@

$(INSTALLDIR)/wolf3d/wolfspr.bmp: wolfspr.bmp
	$(CP) $< $@

clean:
	$(RM) \
 mapatm.E \
 wolf3d.com \
 wolf3d/music.bin \
 wolf3d/sfx.bin
