# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

zxbattle.com: main.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 BC1.a80 \
 BC2.a80 \
 BC3.a80 \
 BC4.a80 \
 XASASM1.a80 \
 bgpush.asm \
 bmp.asm \
 int.asm \
 mem.asm \
 pal.ast \
 prspr.asm \
 units.asm
	$(AS) $(AFLAGS) $<

font.ast: image.bmp font.dat
	$(NEDORES) $^ $@

zxbattle/font.bin: font.ast
	$(AS) $(AFLAGS) $< --raw=$@

pal.ast: image.bmp pal.dat
	$(NEDORES) $^ $@

sprites.ast: image.bmp sprites.dat
	$(NEDORES) $^ $@

zxbattle/spr0.dat: spr0.asm sprites.ast
	$(AS) $(AFLAGS) $<

spr1.ast: image.bmp spr1.dat
	$(NEDORES) $^ $@

zxbattle/spr1.dat: spr1.asm spr1.ast
	$(AS) $(AFLAGS) $<

spr2.ast: image.bmp spr2.dat
	$(NEDORES) $^ $@

zxbattle/spr2.dat: spr2.asm spr2.ast
	$(AS) $(AFLAGS) $<

spr3.ast: image.bmp spr3.dat
	$(NEDORES) $^ $@

zxbattle/spr3.dat: spr3.asm spr3.ast
	$(AS) $(AFLAGS) $<

tiles.ast: image.bmp tiles.dat
	$(NEDORES) $^ $@

zxbattle/tiles.bin: tiles.ast
	$(AS) $(AFLAGS) $< --raw=$@

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/zxbattle.com \
 $(INSTALLDIR)/zxbattle \
 $(INSTALLDIR)/zxbattle/font.bin \
 $(INSTALLDIR)/zxbattle/hi_score.dat \
 $(INSTALLDIR)/zxbattle/lvl_00us.dat \
 $(INSTALLDIR)/zxbattle/lvln0116.dat \
 $(INSTALLDIR)/zxbattle/lvln1732.dat \
 $(INSTALLDIR)/zxbattle/menu.bmp \
 $(INSTALLDIR)/zxbattle/muz_boss.dat \
 $(INSTALLDIR)/zxbattle/muz_end.dat \
 $(INSTALLDIR)/zxbattle/muz_main.dat \
 $(INSTALLDIR)/zxbattle/sound_fx.bin \
 $(INSTALLDIR)/zxbattle/spr0.dat \
 $(INSTALLDIR)/zxbattle/spr1.dat \
 $(INSTALLDIR)/zxbattle/spr2.dat \
 $(INSTALLDIR)/zxbattle/spr3.dat \
 $(INSTALLDIR)/zxbattle/tiles.bin

$(INSTALLDIR) \
 $(INSTALLDIR)/zxbattle:
	$(MKDIR) $@

$(INSTALLDIR)/zxbattle.com: zxbattle.com
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/font.bin: zxbattle/font.bin
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/hi_score.dat: zxbattle/hi_score.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/lvl_00us.dat: zxbattle/lvl_00us.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/lvln0116.dat: zxbattle/lvln0116.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/lvln1732.dat: zxbattle/lvln1732.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/menu.bmp: zxbattle/menu.bmp
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/muz_boss.dat: zxbattle/muz_boss.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/muz_end.dat: zxbattle/muz_end.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/muz_main.dat: zxbattle/muz_main.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/sound_fx.bin: zxbattle/sound_fx.bin
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/spr0.dat: zxbattle/spr0.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/spr1.dat: zxbattle/spr1.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/spr2.dat: zxbattle/spr2.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/spr3.dat: zxbattle/spr3.dat
	$(CP) $< $@

$(INSTALLDIR)/zxbattle/tiles.bin: zxbattle/tiles.bin
	$(CP) $< $@

clean:
	$(RM) \
 font.ast \
 pal.ast \
 spr1.ast \
 spr2.ast \
 spr3.ast \
 sprites.ast \
 tiles.ast \
 zxbattle.com \
 zxbattle/font.bin \
 zxbattle/spr0.dat \
 zxbattle/spr1.dat \
 zxbattle/spr2.dat \
 zxbattle/spr3.dat \
 zxbattle/tiles.bin
