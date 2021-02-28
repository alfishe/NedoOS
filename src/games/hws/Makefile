# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

hws.com: 1.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 HWC1.ASM
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/hws.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/hws.com: hws.com
	$(CP) $< $@

clean:
	$(RM) hws.com
