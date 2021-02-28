# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

pt.com: pt.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 digits.bin \
 f7400.bin \
 gsports.asm \
 pt3d.asm \
 pt5_371.asm \
 pt6_371.asm \
 ptcmpv8.asm \
 ptconst.asm \
 ptinpage.asm \
 ptmsg.asm \
 tvol.bin
	$(AS) $(AFLAGS) $<

install: \
 $(BIN_INSTALLDIR)pt.com \
 $(DOC_INSTALLDIR)pt3hist.txt \
 $(DOC_INSTALLDIR)pt3_7x.txt \
 $(DOC_INSTALLDIR)pt3_7xe.txt \
 $(DOC_INSTALLDIR)ptdoc.txt \
 $(DOC_INSTALLDIR)pt_vs_vt.txt

$(BIN_INSTALLDIR)pt.com: pt.com
	$(CP) $< $@

$(DOC_INSTALLDIR)pt3hist.txt: pt3hist.txt
	$(CP) $< $@

$(DOC_INSTALLDIR)pt3_7x.txt: pt3_7x.txt
	$(CP) $< $@

$(DOC_INSTALLDIR)pt3_7xe.txt: pt3_7xe.txt
	$(CP) $< $@

$(DOC_INSTALLDIR)ptdoc.txt: ptdoc.txt
	$(CP) $< $@

$(DOC_INSTALLDIR)pt_vs_vt.txt: pt_vs_vt.txt
	$(CP) $< $@

clean:
	$(RM) pt.com
