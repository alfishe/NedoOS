# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

scratch.com: scratch.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 64qua.fnt \
 bitmap.asm \
 control.asm \
 files.asm \
 math.asm \
 navigator.asm \
 pal.asm \
 prarrow.asm \
 prbitmap.asm \
 prshapes.asm \
 prtext.asm \
 sqrtmax2 \
 tarcsin \
 tsin200 \
 window.asm \
 windows.asm \
 windowsh.asm
	$(AS) $(AFLAGS) $<

install: \
 $(BIN_INSTALLDIR)scratch.com \
 $(DOC_INSTALLDIR)scratch.new \
 $(DOC_INSTALLDIR)scratch.txt

$(BIN_INSTALLDIR)scratch.com: scratch.com
	$(CP) $< $@

$(DOC_INSTALLDIR)scratch.new: scratch.new
	$(CP) $< $@

$(DOC_INSTALLDIR)scratch.txt: scratch.txt
	$(CP) $< $@

clean:
	$(RM) scratch.com
