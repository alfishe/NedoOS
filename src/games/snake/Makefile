# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

snake.com: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 fontgfx \
 zx.fnt
	$(AS) $(AFLAGS) $<

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/snake.com

$(INSTALLDIR):
	$(MKDIR) $@

$(INSTALLDIR)/snake.com: snake.com
	$(CP) $< $@

clean:
	$(RM) snake.com
