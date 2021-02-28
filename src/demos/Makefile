# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

DIRS	:= \
 noise \
 raytrace

install \
clean:
ifeq ($(OS),Windows_NT)
	for %%d in ($(DIRS)) do $(MAKE) $(MFLAGS) -C %%d $@
else
	for d in $(DIRS); do $(MAKE) $(MFLAGS) -C $$d $@; done
endif
