# Supported environments:
#   GNU/Linux
#   Windows NT

include ../src/_sdk/common.mk

.PHONY: all clean-aspp clean-dmimg clean-mhmt clean-sjasmplus clean

ifeq ($(OS),Windows_NT)
all:
	@echo Nothing to do on Windows.
else
all: aspp dmimg mhmt sjasmplus
endif

aspp: src/aspp/build/release/linux/aspp | src/aspp
	$(CP) $< $@

src/aspp/build/release/linux/aspp: | src/aspp
	$(MAKE) $(MFLAGS) -C $| all

clean-aspp: | src/aspp
	$(MAKE) $(MFLAGS) -C $| clean
	$(RM) aspp

dmimg: src/dmimg/dmimg | src/dmimg
	$(CP) $< $@

src/dmimg/dmimg: | src/dmimg
	$(MAKE) $(MFLAGS) -C $|

clean-dmimg: | src/dmimg
	$(MAKE) $(MFLAGS) -C $| clean
	$(RM) dmimg

mhmt: src/mhmt/linux/mhmt | src/mhmt/linux
	$(CP) $< $@

src/mhmt/linux/mhmt: | src/mhmt/linux
	$(MAKE) $(MFLAGS) -C $|

clean-mhmt: | src/mhmt/linux
	$(MAKE) $(MFLAGS) -C $| clean
	$(RM) mhmt

sjasmplus: src/sjasmplus/sjasmplus
	$(CP) $< $@

src/sjasmplus/sjasmplus: | src/sjasmplus
	$(MAKE) $(MFLAGS) -C $|

clean-sjasmplus: | src/sjasmplus
	$(MAKE) $(MFLAGS) -C $| clean
	$(RM) sjasmplus

clean: clean-aspp clean-dmimg clean-mhmt clean-sjasmplus
