# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

isitar.com: 1.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 ISITAR.ASM \
 cga.bin
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/isitar.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/isitar.com: isitar.com
	$(CP) $< $@

clean:
	$(RM) isitar.com
