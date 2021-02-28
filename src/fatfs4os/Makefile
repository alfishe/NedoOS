# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk
include ../_sdk/iar.mk

C_OPTIONS	= -S -v0 -ml -uua -q -e -K -gA -z9 -t4 -T -Llist/ -Olist/ -Alist/ -I$(IARINC)

.PHONY: all install clean

all: \
 fatfs.exp \
 fatfs.raw

ifeq ($(OS),Windows_NT)
list:
	$(MKDIR) $@

list/ff.lst \
list/ff.r01 \
list/ff.s01: ff.c \
 diskio.h \
 ff.h \
 ffconf.h \
 integer.h \
 | list
	$(ICCZ80) $(C_OPTIONS) $<

list/ccsbcs.lst \
list/ccsbcs.r01 \
list/ccsbcs.s01: ccsbcs.c \
 ff.h \
 ffconf.h \
 integer.h \
 | list
	$(ICCZ80) $(C_OPTIONS) $<

list/mylib.r01: mylib.asm | list
	$(AZ80) -S -O$|/ -uu $<

fatfs.raw \
list/cout.l: link.lnk \
 list/ccsbcs.r01 \
 list/ff.r01 \
 list/mylib.r01 \
 | list
	$(XLINK) ff ccsbcs mylib -f $<

fatfs.exp: list/cout.l
	$(GREP) -Ee '^[[:space:]]+f_[[:alnum:]]+[[:space:]]+[[:xdigit:]]+' $< > fatfs.tmp
	$(SED) -Ee 's/^[[:space:]]+(f_[[:alnum:]]+)[[:space:]]+([[:xdigit:]]+).*/\1 \2/' fatfs.tmp > $@
	$(RM) fatfs.tmp
else
fatfs.raw \
fatfs.exp:
	$(error Target "$@" is not implemented)
endif

install: all

ifeq ($(OS),Windows_NT)
clean:
#	$(RM) fatfs.exp fatfs.raw
	$(RM) fatfs.tmp
# list/ccsbcs.lst \
# list/ccsbcs.r01 \
# list/ccsbcs.s01 \
# list/cout.l \
# list/ff.lst \
# list/ff.r01 \
# list/ff.s01 \
# list/mylib.r01
#	$(RMDIR) list
	$(RM) -r list/
else
clean: ;
endif
