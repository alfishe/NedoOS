# Supported environments:
#   GNU/Linux
#   Windows NT

include ../_sdk/common.mk

.PHONY: install clean

nedoos.$$C: hobeta.asm \
 code.c
	$(AS) $(AFLAGS) $<

ffsfunc.ast: ../fatfs4os/fatfs.exp
	$(SED) -Ee 's/^(.+)[[:space:]]+(.+)/.\1 EQU 0x\2/' $< > $@

initcode.c \
syscode.c: main.asm \
 ../_sdk/codepage/866toatm \
 ../_sdk/sys_h.asm \
 ../_sdk/sysdefs.asm \
 ../_sdk/syssets.asm \
 ../fatfs4os/fatfs.raw \
 bdospg2.asm \
 fatfs_h.asm \
 fatfsdrv.asm \
 ffsfunc.asm \
 ffsfunc.ast \
 idle.asm \
 ngssddrv.asm \
 portsngs.asm \
 ps2drv.asm \
 sl811.asm \
 sysbdos.asm \
 syskey1.asm \
 syskey2.asm \
 syskrnl.asm \
 trdosfs.asm \
 trdosio.asm \
 unmegalz.asm \
 userkrnl.asm \
 w5300.asm
	$(AS) $(ASFLAGS) $<

syscode.c.mlz: syscode.c
	$(MHMT) -mlz $< > $(NUL)

# order matters!
code.c: initcode.c syscode.c.mlz
	$(CAT) $^ > $@

install: nedoos.$$C

clean:
	$(RM) \
 code.c \
 ffsfunc.ast \
 initcode.c \
 nedoos.\$$C \
 syscode.c \
 syscode.c.mlz
