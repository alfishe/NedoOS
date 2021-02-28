# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

midnight.com \
 midnight/level1.o \
 midnight/level2.o \
 midnight/level3.o \
 midnight/level4.o \
 midnight/level5.o \
 midnight/level6.o \
 midnight/level7.o \
 midnight/level8.o \
 midnight/level9.o \
 midnight/music.o: \
 1.asm \
 ../../_sdk/file.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 Game.a80 \
 Level_01.a80 \
 Level_02.a80 \
 Level_03.a80 \
 Level_04.a80 \
 Level_05.a80 \
 Level_06.a80 \
 Level_07.a80 \
 Level_08.a80 \
 Level_09.a80 \
 Mirror.a80 \
 Music.a80 \
 Page1_FF00.a80 \
 font88 \
 midnight.scr \
 prspr.asm \
 | midnight
	$(AS) $(AFLAGS) $<

midnight:
	$(MKDIR) $@

0midnight.bmpx 1midnight.bmpx: midnight.bmp
	$(CONVEGA) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/midnight.com \
 $(INSTALLDIR)/midnight \
 $(INSTALLDIR)/midnight/0midnigh.bmx \
 $(INSTALLDIR)/midnight/1midnigh.bmx \
 $(INSTALLDIR)/midnight/level1.o \
 $(INSTALLDIR)/midnight/level2.o \
 $(INSTALLDIR)/midnight/level3.o \
 $(INSTALLDIR)/midnight/level4.o \
 $(INSTALLDIR)/midnight/level5.o \
 $(INSTALLDIR)/midnight/level6.o \
 $(INSTALLDIR)/midnight/level7.o \
 $(INSTALLDIR)/midnight/level8.o \
 $(INSTALLDIR)/midnight/level9.o \
 $(INSTALLDIR)/midnight/music.o

$(INSTALLDIR) \
 $(INSTALLDIR)/midnight:
	$(MKDIR) $@

$(INSTALLDIR)/midnight.com: midnight.com
	$(CP) $< $@

$(INSTALLDIR)/midnight/0midnigh.bmx: 0midnight.bmpx
	$(CP) $< $@

$(INSTALLDIR)/midnight/1midnigh.bmx: 1midnight.bmpx
	$(CP) $< $@

$(INSTALLDIR)/midnight/level1.o: midnight/level1.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/level2.o: midnight/level2.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/level3.o: midnight/level3.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/level4.o: midnight/level4.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/level5.o: midnight/level5.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/level6.o: midnight/level6.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/level7.o: midnight/level7.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/level8.o: midnight/level8.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/level9.o: midnight/level9.o
	$(CP) $< $@

$(INSTALLDIR)/midnight/music.o: midnight/music.o
	$(CP) $< $@

clean:
	$(RM) \
 0midnight.bmpx \
 1midnight.bmpx \
 midnight.com \
 midnight/level1.o \
 midnight/level2.o \
 midnight/level3.o \
 midnight/level4.o \
 midnight/level5.o \
 midnight/level6.o \
 midnight/level7.o \
 midnight/level8.o \
 midnight/level9.o \
 midnight/music.o
