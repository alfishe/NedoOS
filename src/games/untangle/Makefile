# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

untangle.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 control.asm \
 fontgfx \
 prarrow.asm
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/untangle.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/untangle.com: untangle.com
	$(CP) $< $@

clean:
	$(RM) untangle.com
