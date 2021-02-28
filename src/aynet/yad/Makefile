# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk
include ../../_sdk/iar.mk

.PHONY: install clean

ifeq ($(OS),Windows_NT)
yad.com: lnk.xcl \
 list/main.r01 \
 list/yadplay.r01 \
 | $(XLINK)
	$(XLINK) list/main.r01 list/yadplay.r01 -FRAW-BINARY -S -o $@ -f $<
else
yad.com:
	$(warning Target "$@" is not implemented)
endif

list:
	$(MKDIR) $@

list/main.r01: main.asm | $(AZ80) list
	$(AZ80) -S -uu -Olist/ $<

list/yadplay.r01: yadplay.asm | $(AZ80) list
	$(AZ80) -S -uu -Olist/ $<

install: yad.com

clean:
	$(RM) \
 list/cout.html \
 list/main.r01 \
 list/yadplay.r01 \
 yad.com
