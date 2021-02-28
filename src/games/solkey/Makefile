# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

solkey.com: 1.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 SOLKEY.asm \
 prspr.asm
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/solkey.com \
 $(INSTALLDIR)/solkey \
 $(INSTALLDIR)/solkey/solkey.bmp \
 $(INSTALLDIR)/solkey/solkey.scr \

$(INSTALLDIR) \
 $(INSTALLDIR)/solkey:
	$(MKDIR) $@

$(INSTALLDIR)/solkey.com: solkey.com
	$(CP) $< $@

$(INSTALLDIR)/solkey/solkey.bmp: solkey/solkey.bmp
	$(CP) $< $@

$(INSTALLDIR)/solkey/solkey.scr: solkey/solkey.scr
	$(CP) $< $@

clean:
	$(RM) solkey.com
