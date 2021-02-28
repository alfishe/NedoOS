# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

.PHONY: install clean

raytrace.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 math.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)raytrace.com

$(BIN_INSTALLDIR)raytrace.com: raytrace.com
	$(CP) $< $@

clean:
	$(RM) raytrace.com
