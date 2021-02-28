# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: all install clean

all: \
 C.CCC \
 cc.com \
 cc2.com \
 clink.com \
 deff2.crl \
 deffgfx.crl

cc.com: CC.ASM \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 8080.asm \
 CCA.ASM \
 CCB.ASM \
 CCCOMP.ASM \
 CCD.ASM
	$(AS) $(AFLAGS) $<

cc2.com: CC2.ASM \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 8080.asm
	$(AS) $(AFLAGS) $<

clink.com: CLINK.ASM \
 ../_sdk/stdio.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 8080.asm \
 CLINKA.ASM \
 CLINKB.ASM
	$(AS) $(AFLAGS) $<

C.CCC: mkccc.asm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 8080.asm \
 CCC.ASM
	$(AS) $(AFLAGS) $<

deff2.crl: DEFF2A.CSM \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 8080.asm \
 BDS.LIB \
 CCC.ASM \
 DEFF2B.CSM \
 DEFF2C.CSM \
 liblib.asm
	$(AS) $(AFLAGS) $<

deffgfx.crl: deffgfx.csm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 8080.asm \
 BDS.LIB \
 CCC.ASM \
 liblib.asm
	$(AS) $(AFLAGS) $<

install: \
 $(BIN_INSTALLDIR)cc.com \
 $(BIN_INSTALLDIR)cc2.com \
 $(BIN_INSTALLDIR)clink.com \
 $(RES_INSTALLDIR)C.CCC \
 $(RES_INSTALLDIR)CASM.C \
 $(RES_INSTALLDIR)CCONFIG.C \
 $(RES_INSTALLDIR)CCONFIG.H \
 $(RES_INSTALLDIR)CCONFIG2.C \
 $(RES_INSTALLDIR)CLOAD.C \
 $(RES_INSTALLDIR)L2.C \
 $(RES_INSTALLDIR)STDIO.H \
 $(RES_INSTALLDIR)STDLIB1.C \
 $(RES_INSTALLDIR)STDLIB2.C \
 $(RES_INSTALLDIR)STDLIB3.C \
 $(RES_INSTALLDIR)cc.bat \
 $(RES_INSTALLDIR)concat.c \
 $(RES_INSTALLDIR)cut.c \
 $(RES_INSTALLDIR)deff2.crl \
 $(RES_INSTALLDIR)deffgfx.crl \
 $(RES_INSTALLDIR)ex.c

$(BIN_INSTALLDIR)cc.com: cc.com
	$(CP) $< $@

$(BIN_INSTALLDIR)cc2.com: cc2.com
	$(CP) $< $@

$(BIN_INSTALLDIR)clink.com: clink.com
	$(CP) $< $@

$(RES_INSTALLDIR)CASM.C: CASM.C
	$(CP) $< $@

$(RES_INSTALLDIR)CCONFIG2.C: CCONFIG2.C
	$(CP) $< $@

$(RES_INSTALLDIR)CCONFIG.C: CCONFIG.C
	$(CP) $< $@

$(RES_INSTALLDIR)CLOAD.C: CLOAD.C
	$(CP) $< $@

$(RES_INSTALLDIR)concat.c: concat.c
	$(CP) $< $@

$(RES_INSTALLDIR)cut.c: cut.c
	$(CP) $< $@

$(RES_INSTALLDIR)ex.c: ex.c
	$(CP) $< $@

$(RES_INSTALLDIR)L2.C: L2.C
	$(CP) $< $@

$(RES_INSTALLDIR)STDLIB1.C: STDLIB1.C
	$(CP) $< $@

$(RES_INSTALLDIR)STDLIB2.C: STDLIB2.C
	$(CP) $< $@

$(RES_INSTALLDIR)STDLIB3.C: STDLIB3.C
	$(CP) $< $@

$(RES_INSTALLDIR)CCONFIG.H: CCONFIG.H
	$(CP) $< $@

$(RES_INSTALLDIR)STDIO.H: STDIO.H
	$(CP) $< $@

$(RES_INSTALLDIR)C.CCC: C.CCC
	$(CP) $< $@

$(RES_INSTALLDIR)deff2.crl: deff2.crl
	$(CP) $< $@

$(RES_INSTALLDIR)deffgfx.crl: deffgfx.crl
	$(CP) $< $@

$(RES_INSTALLDIR)cc.bat: cc.bat
	$(CP) $< $@

clean:
	$(RM) \
 C.CCC \
 cc.com \
 cc2.com \
 clink.com \
 deff2.crl \
 deffgfx.crl
