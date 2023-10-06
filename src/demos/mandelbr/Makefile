# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

.PHONY: install clean

raytrace.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)mandelbr.com

$(BIN_INSTALLDIR)raytrace.com: mandelbr.com
	$(CP) $< $@

clean:
	$(RM) mandelbr.com
