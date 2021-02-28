# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

DIRS	:= \
 barbaria \
 br \
 eric \
 hws \
 isitar \
 loyd \
 midnight \
 montana2 \
 nedoload \
 net \
 q1 \
 slabage \
 smb \
 snake \
 solkey \
 sprexamp \
 tank \
 tetris \
 untangle \
 vera \
 wolf3d \
 zxbattle

install \
clean:
ifeq ($(OS),Windows_NT)
	for %%d in ($(DIRS)) do $(MAKE) $(MFLAGS) -C %%d $@
else
	for d in $(DIRS); do $(MAKE) $(MFLAGS) -C $$d $@; done
endif
