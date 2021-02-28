# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: all install clean

all: net1.com net2.com

net1.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 fontgfx \
 zx.fnt
	$(AS) $(AFLAGS) -DCLIENT=1 $<

net2.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 fontgfx \
 zx.fnt
	$(AS) $(AFLAGS) -DCLIENT=0 $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/net1.com \
 $(INSTALLDIR)/net2.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/net1.com: net1.com
	$(CP) $< $@

$(INSTALLDIR)/net2.com: net2.com
	$(CP) $< $@

clean:
	$(RM) net1.com net2.com
