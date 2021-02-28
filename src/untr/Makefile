# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

untr.com: untr.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 64qua.fnt \
 fnotes.fnt \
 mem.asm \
 mix.asm \
 play.asm \
 save.asm \
 struct.asm \
 tb_st.bin \
 view.asm
	$(AS) $(AFLAGS) $<

install: $(BIN_INSTALLDIR)untr.com

$(BIN_INSTALLDIR)untr.com: untr.com
	$(CP) $< $@

clean:
	$(RM) untr.com
