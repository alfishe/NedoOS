# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

.PHONY: all install clean

all: \
 noise.com \
 noise/forest.dat

noise.com: noise.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 NOISE20.pt3 \
 ptsplay.asm
	$(AS) $(AFLAGS) $<

0forest00.bmpx 1forest00.bmpx: forest00.bmp
	$(CONVEGA) $<

0forest01.bmpx 1forest01.bmpx: forest01.bmp
	$(CONVEGA) $<

0forest02.bmpx 1forest02.bmpx: forest02.bmp
	$(CONVEGA) $<

0forest03.bmpx 1forest03.bmpx: forest03.bmp
	$(CONVEGA) $<

0forest10.bmpx 1forest10.bmpx: forest10.bmp
	$(CONVEGA) $<

0forest11.bmpx 1forest11.bmpx: forest11.bmp
	$(CONVEGA) $<

0forest12.bmpx 1forest12.bmpx: forest12.bmp
	$(CONVEGA) $<

0forest13.bmpx 1forest13.bmpx: forest13.bmp
	$(CONVEGA) $<

0forest20.bmpx 1forest20.bmpx: forest20.bmp
	$(CONVEGA) $<

0forest21.bmpx 1forest21.bmpx: forest21.bmp
	$(CONVEGA) $<

0forest22.bmpx 1forest22.bmpx: forest22.bmp
	$(CONVEGA) $<

0forest23.bmpx 1forest23.bmpx: forest23.bmp
	$(CONVEGA) $<

0forest30.bmpx 1forest30.bmpx: forest30.bmp
	$(CONVEGA) $<

0forest31.bmpx 1forest31.bmpx: forest31.bmp
	$(CONVEGA) $<

0forest32.bmpx 1forest32.bmpx: forest32.bmp
	$(CONVEGA) $<

0forest33.bmpx 1forest33.bmpx: forest33.bmp
	$(CONVEGA) $<

# ходом коня (чтобы всегда чередовалась чётность сетки 50%):
# e 1 8 5
# b 4 f 2
# 0 d 6 9
# 7 a 3 c

# порядок получился такой:
# 20 01 13 32
# 11 03 22 30
# 02 23 31 10
# 33 21 00 12

noise/forest.dat: \
 0forest00.bmpx \
 0forest01.bmpx \
 0forest02.bmpx \
 0forest03.bmpx \
 0forest10.bmpx \
 0forest11.bmpx \
 0forest12.bmpx \
 0forest13.bmpx \
 0forest20.bmpx \
 0forest21.bmpx \
 0forest22.bmpx \
 0forest23.bmpx \
 0forest30.bmpx \
 0forest31.bmpx \
 0forest32.bmpx \
 0forest33.bmpx \
 16b \
 1forest00.bmpx \
 1forest01.bmpx \
 1forest02.bmpx \
 1forest03.bmpx \
 1forest10.bmpx \
 1forest11.bmpx \
 1forest12.bmpx \
 1forest13.bmpx \
 1forest20.bmpx \
 1forest21.bmpx \
 1forest22.bmpx \
 1forest23.bmpx \
 1forest30.bmpx \
 1forest31.bmpx \
 1forest32.bmpx \
 1forest33.bmpx
	$(CAT) \
 0forest20.bmpx 16b 1forest20.bmpx 16b \
 0forest01.bmpx 16b 1forest01.bmpx 16b \
 0forest13.bmpx 16b 1forest13.bmpx 16b \
 0forest32.bmpx 16b 1forest32.bmpx 16b \
 0forest11.bmpx 16b 1forest11.bmpx 16b \
 0forest03.bmpx 16b 1forest03.bmpx 16b \
 0forest22.bmpx 16b 1forest22.bmpx 16b \
 0forest30.bmpx 16b 1forest30.bmpx 16b \
 0forest02.bmpx 16b 1forest02.bmpx 16b \
 0forest23.bmpx 16b 1forest23.bmpx 16b \
 0forest31.bmpx 16b 1forest31.bmpx 16b \
 0forest10.bmpx 16b 1forest10.bmpx 16b \
 0forest33.bmpx 16b 1forest33.bmpx 16b \
 0forest21.bmpx 16b 1forest21.bmpx 16b \
 0forest00.bmpx 16b 1forest00.bmpx 16b \
 0forest12.bmpx 16b 1forest12.bmpx 16b > $@

install: \
 $(BIN_INSTALLDIR)noise.com \
 $(RES_INSTALLDIR)noise \
 $(RES_INSTALLDIR)noise/forest.dat

$(RES_INSTALLDIR)noise:
	$(MKDIR) $@

$(BIN_INSTALLDIR)noise.com: noise.com
	$(CP) $< $@

$(RES_INSTALLDIR)noise/forest.dat: noise/forest.dat
	$(CP) $< $@

clean:
	$(RM) \
 0forest00.bmpx \
 0forest01.bmpx \
 0forest02.bmpx \
 0forest03.bmpx \
 0forest10.bmpx \
 0forest11.bmpx \
 0forest12.bmpx \
 0forest13.bmpx \
 0forest20.bmpx \
 0forest21.bmpx \
 0forest22.bmpx \
 0forest23.bmpx \
 0forest30.bmpx \
 0forest31.bmpx \
 0forest32.bmpx \
 0forest33.bmpx \
 1forest00.bmpx \
 1forest01.bmpx \
 1forest02.bmpx \
 1forest03.bmpx \
 1forest10.bmpx \
 1forest11.bmpx \
 1forest12.bmpx \
 1forest13.bmpx \
 1forest20.bmpx \
 1forest21.bmpx \
 1forest22.bmpx \
 1forest23.bmpx \
 1forest30.bmpx \
 1forest31.bmpx \
 1forest32.bmpx \
 1forest33.bmpx \
 noise.com \
 noise/forest.dat
