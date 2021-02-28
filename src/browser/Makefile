# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

browser.com: browser.asm \
 ../_sdk/codepage/winto866 \
 ../_sdk/file.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 ../pkunzip/depk.asm \
 1125vert.fnt \
 drawmc.asm \
 dynmem.asm \
 editline.asm \
 gif.asm \
 html.asm \
 htmlview.asm \
 http.asm \
 init.asm \
 jpeg.asm \
 mempgs.asm \
 png.asm \
 prmc.asm \
 prvirt.asm \
 svg.asm \
 t64to16i \
 t64to16p \
 tdiv \
 tmaxaxis \
 zxpal
	$(AS) $(AFLAGS) $<

install: \
 $(BIN_INSTALLDIR)browser.com \
 $(RES_INSTALLDIR)browser \
 $(RES_INSTALLDIR)browser/nos.htm \
 $(DOC_INSTALLDIR)browser.thk \
 $(DOC_INSTALLDIR)browsgfx.thk

$(RES_INSTALLDIR)browser \
 $(DOC_INSTALLDIR)browser:
	$(MKDIR) $@

$(BIN_INSTALLDIR)browser.com: browser.com
	$(CP) $< $@

$(RES_INSTALLDIR)browser/nos.htm: browser/nos.htm
	$(CP) $< $@

$(DOC_INSTALLDIR)browser.thk: browser.thk
	$(CP) $< $@

$(DOC_INSTALLDIR)browsgfx.thk: browsgfx.thk
	$(CP) $< $@

clean:
	$(RM) browser.com
