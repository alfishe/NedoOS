# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: all install clean

all: \
 nv.com \
 nvfast.com

nv.com: nv.asm \
 ../_sdk/codepage/winto866 \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 cmdpr.asm \
 heapsort.asm \
 nveditln.asm \
 nvfind.asm \
 nvhexed.asm \
 nvjptbl.asm \
 nvsort.asm \
 nvunit.asm \
 nvview.asm \
 prdword.asm
	$(AS) $(AFLAGS) -DPRSTDIO=1 $<

nvfast.com: nv.asm \
 ../_sdk/codepage/winto866 \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 cmdpr.asm \
 heapsort.asm \
 nveditln.asm \
 nvfind.asm \
 nvhexed.asm \
 nvjptbl.asm \
 nvsort.asm \
 nvunit.asm \
 nvview.asm \
 prdword.asm
	$(AS) $(AFLAGS) -DPRSTDIO=0 $<

install: \
 $(BIN_INSTALLDIR)nv.com \
 $(BIN_INSTALLDIR)nvfast.com \
 $(RES_INSTALLDIR)nv.ext

$(BIN_INSTALLDIR)nv.com: nv.com
	$(CP) $< $@

$(BIN_INSTALLDIR)nvfast.com: nvfast.com
	$(CP) $< $@

$(RES_INSTALLDIR)nv.ext: nv.ext
	$(CP) $< $@

clean:
	$(RM) \
 nv.com \
 nvfast.com
