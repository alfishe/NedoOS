# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: all install clean

all: vera.com

icons.ast: icons-day.bmp icons.dat
	$(NEDORES) $^ $@
vera/icons.bin: icons.ast
	$(AS) $(AFLAGS) $< --raw=$@

tiles0.ast: tiles.bmp tiles0.dat
	$(NEDORES) $^ $@
vera/tiles0.bin: tiles0.ast
	$(AS) $(AFLAGS) $< --raw=$@

tiles1.ast: tiles.bmp tiles1.dat
	$(NEDORES) $^ $@
vera/tiles1.bin: tiles1.ast
	$(AS) $(AFLAGS) $< --raw=$@

tiles2.ast: tiles.bmp tiles2.dat
	$(NEDORES) $^ $@
vera/tiles2.bin: tiles2.ast
	$(AS) $(AFLAGS) $< --raw=$@

tiles3.ast: tiles.bmp tiles3.dat
	$(NEDORES) $^ $@
vera/tiles3.bin: tiles3.ast
	$(AS) $(AFLAGS) $< --raw=$@

sprites0.ast: herospr.bmp sprites0.dat
	$(NEDORES) $^ $@
vera/sprites0.bin: spr0.asm sprites0.ast
	$(AS) $(AFLAGS) $<

sprites1.ast: herospr.bmp sprites1.dat
	$(NEDORES) $^ $@
vera/sprites1.bin: spr1.asm sprites1.ast
	$(AS) $(AFLAGS) $<

sprtran0.ast: herospr.bmp sprtran0.dat
	$(NEDORES) $^ $@
vera/sprtran0.bin: sprtran0.asm sprtran0.ast
	$(AS) $(AFLAGS) $<

sprtran1.ast: herospr.bmp sprtran1.dat
	$(NEDORES) $^ $@
vera/sprtran1.bin: sprtran1.asm sprtran1.ast
	$(AS) $(AFLAGS) $<

cursors.ast: cursors.bmp cursors.dat
	$(NEDORES) $^ $@
daynight.ast: day_night.bmp daynight.dat
	$(NEDORES) $^ $@
hud.ast: hud.bmp hud.dat
	$(NEDORES) $^ $@
hudmenu.ast: hud.bmp hudmenu.dat
	$(NEDORES) $^ $@
paldawn.ast: icons-dawn.bmp paldawn.dat
	$(NEDORES) $^ $@
palday.ast: icons-day.bmp palday.dat
	$(NEDORES) $^ $@
palev.ast: icons-evening.bmp palev.dat
	$(NEDORES) $^ $@
palnight.ast: icons-night.bmp palnight.dat
	$(NEDORES) $^ $@
vera.com \
 vera/0_page.bin \
 vera/1_page.bin \
 vera/3_page.bin \
 vera/4_page.bin \
 vera/6_page.bin \
 vera/7_page.bin \
 vera/daynight.bin \
 vera/hud.bin \
 vera/vars.bin: VERA.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 4AXORFIX.F \
 ABOUT.asm \
 ABOUTY.p \
 B1_otrez.m-- \
 BELLKEY4.plc \
 BVssVMft.p \
 Day_nght.p \
 GAMEMEN4.C \
 HeroSprX.C \
 IFACE.plc \
 IM2.asm \
 KeyScr4.plc \
 MapMass.p \
 Menu.p \
 Ngh_arr3.C \
 PATH-48H.asm \
 PLAYERX.C \
 PRINT.asm \
 SCRIPTS.asm \
 SPRITEMh.C \
 TALK.asm \
 VIDEO.p \
 WIN_SPR.C \
 cursors.ast \
 daynight.ast \
 hud.ast \
 hudmenu.ast \
 int.asm \
 map.dat \
 map6912.dat \
 mapflags.dat \
 paldawn.ast \
 palday.ast \
 palev.ast \
 palnight.ast \
 prspr.asm \
 russia80.p \
 saveload.asm \
 spr2x2x.C \
 spr3x3.C \
 vera_00.p \
 vera_01.p \
 vera_02.p \
 vera_03.p
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/vera.com \
 $(INSTALLDIR)/vera \
 $(INSTALLDIR)/vera/0_page.bin \
 $(INSTALLDIR)/vera/1_page.bin \
 $(INSTALLDIR)/vera/3_page.bin \
 $(INSTALLDIR)/vera/4_page.bin \
 $(INSTALLDIR)/vera/6_page.bin \
 $(INSTALLDIR)/vera/7_page.bin \
 $(INSTALLDIR)/vera/daynight.bin \
 $(INSTALLDIR)/vera/hud.bin \
 $(INSTALLDIR)/vera/icons.bin \
 $(INSTALLDIR)/vera/sprites0.bin \
 $(INSTALLDIR)/vera/sprites1.bin \
 $(INSTALLDIR)/vera/sprtran0.bin \
 $(INSTALLDIR)/vera/sprtran1.bin \
 $(INSTALLDIR)/vera/tiles0.bin \
 $(INSTALLDIR)/vera/tiles1.bin \
 $(INSTALLDIR)/vera/tiles2.bin \
 $(INSTALLDIR)/vera/tiles3.bin \
 $(INSTALLDIR)/vera/vars.bin

$(INSTALLDIR) \
 $(INSTALLDIR)/vera:
	$(MKDIR) $@

$(INSTALLDIR)/vera.com: vera.com
	$(CP) $< $@
$(INSTALLDIR)/vera/0_page.bin: vera/0_page.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/1_page.bin: vera/1_page.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/3_page.bin: vera/3_page.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/4_page.bin: vera/4_page.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/6_page.bin: vera/6_page.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/7_page.bin: vera/7_page.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/daynight.bin: vera/daynight.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/hud.bin: vera/hud.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/icons.bin: vera/icons.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/sprites0.bin: vera/sprites0.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/sprites1.bin: vera/sprites1.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/sprtran0.bin: vera/sprtran0.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/sprtran1.bin: vera/sprtran1.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/tiles0.bin: vera/tiles0.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/tiles1.bin: vera/tiles1.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/tiles2.bin: vera/tiles2.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/tiles3.bin: vera/tiles3.bin
	$(CP) $< $@
$(INSTALLDIR)/vera/vars.bin: vera/vars.bin
	$(CP) $< $@

clean:
	$(RM) \
 cursors.ast \
 daynight.ast \
 hud.ast \
 hudmenu.ast \
 icons.ast \
 paldawn.ast \
 palday.ast \
 palev.ast \
 palnight.ast \
 sprites0.ast \
 sprites1.ast \
 sprtran0.ast \
 sprtran1.ast \
 tiles0.ast \
 tiles1.ast \
 tiles2.ast \
 tiles3.ast \
 vera.com \
 vera/0_page.bin \
 vera/1_page.bin \
 vera/3_page.bin \
 vera/4_page.bin \
 vera/6_page.bin \
 vera/7_page.bin \
 vera/daynight.bin \
 vera/hud.bin \
 vera/icons.bin \
 vera/sprites0.bin \
 vera/sprites1.bin \
 vera/sprtran0.bin \
 vera/sprtran1.bin \
 vera/tiles0.bin \
 vera/tiles1.bin \
 vera/tiles2.bin \
 vera/tiles3.bin \
 vera/vars.bin
