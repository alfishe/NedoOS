# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: all install clean

all: q1.com q1_1.com q1_2.com

q1.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 Fontlr.bin \
 MAPS.bin \
 Quake1_2.asm \
 Quake1_3.asm \
 QuakeSPR.bin
	$(AS) $(AFLAGS) $<

q1_1.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 Fontlr.bin \
 MAPS.bin \
 Quake1_2.asm \
 Quake1_3.asm \
 QuakeSPR.bin
	$(AS) $(AFLAGS) -DCLIENT=1 $<

q1_2.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 Fontlr.bin \
 MAPS.bin \
 Quake1_2.asm \
 Quake1_3.asm \
 QuakeSPR.bin
	$(AS) $(AFLAGS) -DCLIENT=0 $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/q1.com \
 $(INSTALLDIR)/q1_1.com \
 $(INSTALLDIR)/q1_2.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/q1.com: q1.com
	$(CP) $< $@

$(INSTALLDIR)/q1_1.com: q1_1.com
	$(CP) $< $@

$(INSTALLDIR)/q1_2.com: q1_2.com
	$(CP) $< $@

clean:
	$(RM) q1.com q1_1.com q1_2.com
