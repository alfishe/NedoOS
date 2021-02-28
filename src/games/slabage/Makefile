# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

slabage.com: 1.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 SB.ASM \
 pal.ast \
 prspr.asm \
 slabage/panel.bin \
 slabage/sprdata.bin \
 slabage/tiles.bin
	$(AS) $(AFLAGS) $<

tiles.ast: slabtile.bmp tiles.dat
	$(NEDORES) $^ $@

panel.ast: slabpane.bmp panel.dat
	$(NEDORES) $^ $@

sprites.ast: slabspr.bmp sprites.dat
	$(NEDORES) $^ $@

pal.ast: slabspr.bmp pal.dat
	$(NEDORES) $^ $@

slabage:
	$(MKDIR) $@

slabage/sprdata.bin: sprdata.asm sprites.ast | slabage
	$(AS) $(AFLAGS) $<

slabage/tiles.bin: tiles.ast | slabage
	$(AS) $(AFLAGS) $< --raw=$@

slabage/panel.bin: panel.ast | slabage
	$(AS) $(AFLAGS) $< --raw=$@

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/slabage.com \
 $(INSTALLDIR)/slabage \
 $(INSTALLDIR)/slabage/sprdata.bin \
 $(INSTALLDIR)/slabage/tiles.bin \
 $(INSTALLDIR)/slabage/panel.bin

$(INSTALLDIR) \
 $(INSTALLDIR)/slabage:
	$(MKDIR) $@

$(INSTALLDIR)/slabage.com: slabage.com
	$(CP) $< $@

$(INSTALLDIR)/slabage/sprdata.bin: slabage/sprdata.bin
	$(CP) $< $@

$(INSTALLDIR)/slabage/tiles.bin: slabage/tiles.bin
	$(CP) $< $@

$(INSTALLDIR)/slabage/panel.bin: slabage/panel.bin
	$(CP) $< $@

clean:
	$(RM) \
 pal.ast \
 panel.ast \
 slabage.com \
 slabage/panel.bin \
 slabage/sprdata.bin \
 slabage/tiles.bin \
 sprites.ast \
 tiles.ast
