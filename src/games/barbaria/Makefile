# Supported environments:
#   GNU/Linux
#   Windows NT


include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

barbaria.com: 1.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 FILE.ASM \
 font.bin \
 prspr.asm \
 screen.scr
	$(AS) $(AFLAGS) $<

0barbaria.bmpx 1barbaria.bmpx: barbaria.bmp
	$(CONVEGA) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/barbaria.com \
 $(INSTALLDIR)/barbaria \
 $(INSTALLDIR)/barbaria/0barbari.bmx \
 $(INSTALLDIR)/barbaria/1barbari.bmx

$(INSTALLDIR) \
 $(INSTALLDIR)/barbaria:
	$(MKDIR) $@

$(INSTALLDIR)/barbaria.com: barbaria.com
	$(CP) $< $@

$(INSTALLDIR)/barbaria/0barbari.bmx: 0barbaria.bmpx
	$(CP) $< $@

$(INSTALLDIR)/barbaria/1barbari.bmx: 1barbaria.bmpx
	$(CP) $< $@

clean:
	$(RM) \
 0barbaria.bmpx \
 1barbaria.bmpx \
 barbaria.com
