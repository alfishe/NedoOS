# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

smb.com: main.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 6502fast.asm \
 SMBDIS.ASM \
 nesconst.asm \
 smbconst.asm \
 smbmusic.asm \
 smbsound.asm \
 tileattr.asm
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/smb.com \
 $(INSTALLDIR)/antipac.fm2

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/smb.com: smb.com
	$(CP) $< $@

$(INSTALLDIR)/antipac.fm2: antipac.fm2
	$(CP) $< $@

clean:
	$(RM) smb.com
