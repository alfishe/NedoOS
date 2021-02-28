# Supported environments:
#   GNU/Linux
#   Windows NT

# TODO: Pack data files (author used `xlpz' tool).
# TODO: Missing file "barkov/hellfire.scr", used in "levels/w~214.a80".

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: all install clean

all: \
 br.com \
 br/br0.dat \
 br/br1.dat \
 br/br3.dat \
 br/br4.dat \
 br/br6.dat \
 br/br7.dat \
 br/brfinal.dat \
 br/bri3.dat \
 br/bri4.dat \
 br/bri7.dat \
 brintro.com

# Modules: convert images to assembler sources and compile

WHUMBUTT.ast: images/WHUMBUTT.bmp images/WHUMBUTT.dat
	$(NEDORES) $^ $@
br/W0BUT.bin: WHUMBUTT.ast
	$(AS) $(AFLAGS) $< --raw=$@

WORCBUTT.ast: images/WORCBUTT.bmp images/WORCBUTT.dat
	$(NEDORES) $^ $@
br/W1BUT.bin: WORCBUTT.ast
	$(AS) $(AFLAGS) $< --raw=$@

W1LAND.ast: images/W1LAND.bmp images/W1LAND.dat
	$(NEDORES) $^ $@
br/W1LAND.bin: W1LAND.ast
	$(AS) $(AFLAGS) $< --raw=$@

W2LAND.ast: images/W2LAND.bmp images/W2LAND.dat
	$(NEDORES) $^ $@
br/W2LAND.bin: W2LAND.ast
	$(AS) $(AFLAGS) $< --raw=$@

W3LAND.ast: images/W3LAND.bmp images/W3LAND.dat
	$(NEDORES) $^ $@
br/W3LAND.bin: W3LAND.ast
	$(AS) $(AFLAGS) $< --raw=$@

W4LAND.ast: images/W4LAND.bmp images/W4LAND.dat
	$(NEDORES) $^ $@
br/W4LAND.bin: W4LAND.ast
	$(AS) $(AFLAGS) $< --raw=$@

WBAR.ast: images/WBAR.bmp images/WBAR.dat
	$(NEDORES) $^ $@
br/WBAR.bin: WBAR.ast
	$(AS) $(AFLAGS) $< --raw=$@

WBULLET.ast: images/WMISC.bmp images/WBULLET.dat
	$(NEDORES) $^ $@
br/WBULLET.bin: WBULLET.asm gfxinc.asm WBULLET.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WCREAT1.ast: images/WCREAT1.bmp images/WCREAT1.dat
	$(NEDORES) $^ $@
br/WCREAT1.bin: WCREAT1.asm gfxinc.asm WCREAT1.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WCREAT1b.ast: images/WCREAT1.bmp images/WCREAT1b.dat
	$(NEDORES) $^ $@

br/WCREAT1b.bin: WCREAT1b.asm gfxinc.asm WCREAT1b.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WCREAT1c.ast: images/WCREAT1.bmp images/WCREAT1c.dat
	$(NEDORES) $^ $@
br/WCREAT1c.bin: WCREAT1c.asm gfxinc.asm WCREAT1c.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WCREAT2.ast: images/WCREAT2.bmp images/WCREAT2.dat
	$(NEDORES) $^ $@
demobar.ast: images/demobar.bmp images/demobar.dat

	$(NEDORES) $^ $@
br/WCREAT2.bin: WCREAT2.asm gfxinc.asm WCREAT2.ast demobar.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WCREAT2b.ast: images/WCREAT2.bmp images/WCREAT2b.dat
	$(NEDORES) $^ $@
br/WCREAT2b.bin: WCREAT2b.asm gfxinc.asm WCREAT2b.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WCREAT2c.ast: images/WCREAT2.bmp images/WCREAT2c.dat
	$(NEDORES) $^ $@
WBODY.ast: images/WMISC.bmp images/WBODY.dat
	$(NEDORES) $^ $@
br/WCREAT2c.bin: WCREAT2c.asm gfxinc.asm WCREAT2c.ast WBODY.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WHUM1.ast: images/WHUM1.bmp images/WHUM1.dat
	$(NEDORES) $^ $@
br/WHUM1.bin: WHUM1.asm gfxinc.asm WHUM1.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WHUM1b.ast: images/WHUM1.bmp images/WHUM1b.dat
	$(NEDORES) $^ $@
br/WHUM1b.bin: WHUM1b.asm gfxinc.asm WHUM1b.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WHUM1c.ast: images/WHUM1.bmp images/WHUM1c.dat
	$(NEDORES) $^ $@
br/WHUM1c.bin: WHUM1c.asm gfxinc.asm WHUM1c.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WHUMCAT.ast: images/WHUM2.bmp images/WHUMCAT.dat
	$(NEDORES) $^ $@
br/WHUMCAT.bin: WHUMCAT.asm gfxinc.asm WHUMCAT.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WHUMHOR.ast: images/WHUM2.bmp images/WHUMHOR.dat
	$(NEDORES) $^ $@
br/WHUMHOR.bin: WHUMHOR.asm gfxinc.asm WHUMHOR.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WORC1.ast: images/WORC1.bmp images/WORC1.dat
	$(NEDORES) $^ $@
br/WORC1.bin: WORC1.asm gfxinc.asm WORC1.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WORC1b.ast: images/WORC1.bmp images/WORC1b.dat
	$(NEDORES) $^ $@
br/WORC1b.bin: WORC1b.asm gfxinc.asm WORC1b.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WORC1c.ast: images/WORC1.bmp images/WORC1c.dat
	$(NEDORES) $^ $@
br/WORC1c.bin: WORC1c.asm gfxinc.asm WORC1c.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WORCCAT.ast: images/WORC2.bmp images/WORCCAT.dat
	$(NEDORES) $^ $@
br/WORCCAT.bin: WORCCAT.asm gfxinc.asm WORCCAT.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

WORCHOR.ast: images/WORC2.bmp images/WORCHOR.dat
	$(NEDORES) $^ $@
br/WORCHOR.bin: WORCHOR.asm gfxinc.asm WORCHOR.ast gfxinc2.asm
	$(AS) $(AFLAGS) $< --raw=$@

# Levels: compile and pack

# humans:

#levels/w~101.dat: levels/w~101.a80 task/w101.tsk map/w101_s4.her map/w101_s4.map barkov/castle.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~101.lpz: levels/w~101.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~102.dat: levels/w~102.a80 task/w102.tsk map/w102_s4.her map/w102_s4.map barkov/knights.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~102.lpz: levels/w~102.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~103.dat: levels/w~103.a80 task/w103.tsk map/w103_s1.her map/w103_s1.map barkov/arcer.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~103.lpz: levels/w~103.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

levels/w~104.dat: levels/w~104.a80 task/w104.tsk map/w104_s1.her map/w104_s1.map barkov/morte.scr
	$(AS) $(AFLAGS) $<
levels/w~104.lpz: levels/w~104.dat
	$(CP) $< $@

#levels/w~105.dat: levels/w~105.a80 task/w105.tsk map/w105_s3.her map/w105_s3.map barkov/lady.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~105.lpz: levels/w~105.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~106.dat: levels/w~106.a80 task/w106.tsk map/w106_s1.her map/w106_s1.map barkov/land.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~106.lpz: levels/w~106.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

levels/w~107.dat: levels/w~107.a80 task/w107.tsk map/w107_s1.her map/w107_s1.map barkov/horse.scr
	$(AS) $(AFLAGS) $<
levels/w~107.lpz: levels/w~107.dat
	$(CP) $< $@

#levels/w~108.dat: levels/w~108.a80 task/w108.tsk map/w108_s2.her map/w108_s2.map barkov/human.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~108.lpz: levels/w~108.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~109.dat: levels/w~109.a80 task/w109.tsk map/w109_s1.her map/w109_s1.map barkov/old_man.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~109.lpz: levels/w~109.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~110.dat: levels/w~110.a80 task/w110.tsk map/w110_s3.her map/w110_s3.map barkov/pacman.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~110.lpz: levels/w~110.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~111.dat: levels/w~111.a80 task/w111.tsk map/w111_s2.her map/w111_s2.map barkov/prince.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~111.lpz: levels/w~111.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

levels/w~112.dat: levels/w~112.a80 task/w112.tsk map/w112_s1.her map/w112_s1.map barkov/sword.scr
	$(AS) $(AFLAGS) $<
levels/w~112.lpz: levels/w~112.dat
	$(CP) $< $@

#levels/w~113.dat: levels/w~113.a80 task/w113.tsk map/w113_s2.her map/w113_s2.map barkov/dragon1.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~113.lpz: levels/w~113.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~114.dat: levels/w~114.a80 task/w114.tsk map/w114_s3.her map/w114_s3.map barkov/mongol.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~114.lpz: levels/w~114.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~115.dat: levels/w~115.a80 task/w115.tsk map/w115_s2.her map/w115_s2.map barkov/gigant.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~115.lpz: levels/w~115.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~116.dat: levels/w~116.a80 task/w116.tsk map/w116_s2.her map/w116_s2.map barkov/tzar.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~116.lpz: levels/w~116.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

levels/w~117end.dat: levels/w~117end.a80 ../../_sdk/sys_h.asm barkov/w_end_h.scr barkov/w_end2.scr
	$(AS) $(AFLAGS) $<
levels/w~117end.lpz: levels/w~117end.dat
	$(CP) $< $@

# kungs:

#levels/w~201.dat: levels/w~201.a80 task/w201.tsk map/w201_s2.her map/w201_s2.map barkov/o_shield.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~201.lpz: levels/w~201.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~202.dat: levels/w~202.a80 task/w202.tsk map/w202_s2.her map/w202_s2.map barkov/chess.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~202.lpz: levels/w~202.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~203.dat: levels/w~203.a80 task/w203.tsk map/w203_s2.her map/w203_s2.map barkov/scull.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~203.lpz: levels/w~203.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~204.dat: levels/w~204.a80 task/w204.tsk map/w204_s2.her map/w204_s2.map barkov/o_holypl.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~204.lpz: levels/w~204.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

levels/w~205.dat: levels/w~205.a80 task/w205.tsk map/w205_s4.her map/w205_s4.map barkov/disketa.scr
	$(AS) $(AFLAGS) $<
levels/w~205.lpz: levels/w~205.dat
	$(CP) $< $@

#levels/w~206.dat: levels/w~206.a80 task/w206.tsk map/w206_s3.her map/w206_s3.map barkov/girl.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~206.lpz: levels/w~206.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~207.dat: levels/w~207.a80 task/w207.tsk map/w207_s4.her map/w207_s4.map barkov/map.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~207.lpz: levels/w~207.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~208.dat: levels/w~208.a80 task/w208.tsk map/w208_s2.her map/w208_s2.map barkov/draghead.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~208.lpz: levels/w~208.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~209.dat: levels/w~209.a80 task/w209.tsk map/w209_s4.her map/w209_s4.map barkov/spider.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~209.lpz: levels/w~209.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~210.dat: levels/w~210.a80 task/w210.tsk map/w210_s1.her map/w210_s1.map barkov/twotower.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~210.lpz: levels/w~210.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~211.dat: levels/w~211.a80 task/w211.tsk map/w211_s2.her map/w211_s2.map barkov/idol.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~211.lpz: levels/w~211.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~212.dat: levels/w~212.a80 task/w212.tsk map/w212_s3.her map/w212_s3.map barkov/copper.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~212.lpz: levels/w~212.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

levels/w~213.dat: levels/w~213.a80 task/w213.tsk map/w213_s1.her map/w213_s1.map barkov/sekira.scr
	$(AS) $(AFLAGS) $<
levels/w~213.lpz: levels/w~213.dat
	$(CP) $< $@

#levels/w~214.dat: levels/w~214.a80 task/w214.tsk map/w214_s1.her map/w214_s1.map barkov/hellfire.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~214.lpz: levels/w~214.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~215.dat: levels/w~215.a80 task/w215.tsk map/w215_s1.her map/w215_s1.map barkov/satan.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~215.lpz: levels/w~215.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

#levels/w~216.dat: levels/w~216.a80 task/w216.tsk map/w216_s1.her map/w216_s1.map barkov/warrior.scr
#	$(AS) $(AFLAGS) $< --raw=$@
#levels/w~216.lpz: levels/w~216.dat
#	$(XLPZ) $(XLPZFLAGS) $< $@

levels/w~217end.dat: levels/w~217end.a80 ../../_sdk/sys_h.asm barkov/w_end_k.scr barkov/w_end2.scr
	$(AS) $(AFLAGS) $<
levels/w~217end.lpz: levels/w~217end.dat
	$(CP) $< $@

# Executables

br.com br/br0.dat br/br1.dat br/br3.dat br/br4.dat br/br6.dat br/br7.dat: main.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 barkov/w_world.scr \
 data/w2spr.dat \
 data/wbar.dat \
 data/wfont.fnt \
 data/wgrizold.dat \
 data/whumbutt.dat \
 data/wmisc.dat \
 data/wnames.dat \
 data/wscreat1.dat \
 data/wscreat2.dat \
 data/wshum.dat \
 data/wsorc.dat \
 map/w0_s1.her \
 map/w0_s1.map \
 task/w000.tsk \
 w_demo.asm \
 w_intv.asm \
 w_io.asm \
 wintel.asm \
 wlib1a.asm \
 wlib2.asm \
 wlib2x3.asm \
 wlib3.asm \
 wlib3vi.asm \
 wlib4.asm \
 wlic.asm \
 wlid.asm \
 wlie.asm \
 wlif.asm \
 wlig.asm \
 wlih.asm \
 wlik.asm \
 wmap.asm \
 wmenu2.asm \
 wmisc_1.asm \
 wmisc_4.asm \
 wmisc_6.asm \
 wsound2.asm \
 wstrateg.asm \
 wwizard.asm \
 w~level.asm \
 w~local.asm \
 w~var.asm \
 xdelpz.asm
	$(AS) $(AFLAGS) $<

brintro.com br/bri3.dat br/bri4.dat br/bri7.dat: WSTART1.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 WINSTR.asm \
 WINTRO.asm \
 barkov/crow1.lpz \
 data/wflictxt.lpz \
 data/wfont.fnt \
 data/winstr.dat \
 data/winstr0.lpz \
 data/winstr1.lpz \
 data/winstr2.lpz \
 data/winstrcm.dat \
 data/wnf1.fnt \
 data/wnf2.fnt \
 intro/forgivme.mus \
 intro/jammy45.lpz \
 intro/winflick.lpz \
 intro/wxlag.lpz \
 intro/xlag_bl0.dat \
 intro/xlag_bl1.dat \
 xdelpz.asm
	$(AS) $(AFLAGS) $<

br/brfinal.dat: brfinal.asm \
 ../../_sdk/sys_h.asm \
 ../../_sdk/sysdefs.asm \
 bobov/crow_h.lpz \
 bobov/crow_k.lpz \
 data/wfont.fnt \
 data/wvicthum.dat \
 data/wvictorc.dat \
 intro/winvict.lpz \
 xdelpz.asm
	$(AS) $(AFLAGS) $< --raw=$@

install: \
 $(INSTALLDIR) \
 $(INSTALLDIR)/br \
 $(INSTALLDIR)/br.com \
 $(INSTALLDIR)/br/W0BUT.bin \
 $(INSTALLDIR)/br/W1BUT.bin \
 $(INSTALLDIR)/br/W1LAND.bin \
 $(INSTALLDIR)/br/W2LAND.bin \
 $(INSTALLDIR)/br/W3LAND.bin \
 $(INSTALLDIR)/br/W4LAND.bin \
 $(INSTALLDIR)/br/WBAR.bin \
 $(INSTALLDIR)/br/WBULLET.bin \
 $(INSTALLDIR)/br/WCREAT1.bin \
 $(INSTALLDIR)/br/WCREAT1b.bin \
 $(INSTALLDIR)/br/WCREAT1c.bin \
 $(INSTALLDIR)/br/WCREAT2.bin \
 $(INSTALLDIR)/br/WCREAT2b.bin \
 $(INSTALLDIR)/br/WCREAT2c.bin \
 $(INSTALLDIR)/br/WHUM1.bin \
 $(INSTALLDIR)/br/WHUM1b.bin \
 $(INSTALLDIR)/br/WHUM1c.bin \
 $(INSTALLDIR)/br/WHUMCAT.bin \
 $(INSTALLDIR)/br/WHUMHOR.bin \
 $(INSTALLDIR)/br/WORC1.bin \
 $(INSTALLDIR)/br/WORC1b.bin \
 $(INSTALLDIR)/br/WORC1c.bin \
 $(INSTALLDIR)/br/WORCCAT.bin \
 $(INSTALLDIR)/br/WORCHOR.bin \
 $(INSTALLDIR)/br/br0.dat \
 $(INSTALLDIR)/br/br1.dat \
 $(INSTALLDIR)/br/br101.dat \
 $(INSTALLDIR)/br/br102.dat \
 $(INSTALLDIR)/br/br103.dat \
 $(INSTALLDIR)/br/br104.dat \
 $(INSTALLDIR)/br/br105.dat \
 $(INSTALLDIR)/br/br106.dat \
 $(INSTALLDIR)/br/br107.dat \
 $(INSTALLDIR)/br/br108.dat \
 $(INSTALLDIR)/br/br109.dat \
 $(INSTALLDIR)/br/br110.dat \
 $(INSTALLDIR)/br/br111.dat \
 $(INSTALLDIR)/br/br112.dat \
 $(INSTALLDIR)/br/br113.dat \
 $(INSTALLDIR)/br/br114.dat \
 $(INSTALLDIR)/br/br115.dat \
 $(INSTALLDIR)/br/br116.dat \
 $(INSTALLDIR)/br/br117.dat \
 $(INSTALLDIR)/br/br201.dat \
 $(INSTALLDIR)/br/br202.dat \
 $(INSTALLDIR)/br/br203.dat \
 $(INSTALLDIR)/br/br204.dat \
 $(INSTALLDIR)/br/br205.dat \
 $(INSTALLDIR)/br/br206.dat \
 $(INSTALLDIR)/br/br207.dat \
 $(INSTALLDIR)/br/br208.dat \
 $(INSTALLDIR)/br/br209.dat \
 $(INSTALLDIR)/br/br210.dat \
 $(INSTALLDIR)/br/br211.dat \
 $(INSTALLDIR)/br/br212.dat \
 $(INSTALLDIR)/br/br213.dat \
 $(INSTALLDIR)/br/br214.dat \
 $(INSTALLDIR)/br/br215.dat \
 $(INSTALLDIR)/br/br216.dat \
 $(INSTALLDIR)/br/br217.dat \
 $(INSTALLDIR)/br/br3.dat \
 $(INSTALLDIR)/br/br4.dat \
 $(INSTALLDIR)/br/br6.dat \
 $(INSTALLDIR)/br/br7.dat \
 $(INSTALLDIR)/br/braniu_0.dat \
 $(INSTALLDIR)/br/braniu_1.dat \
 $(INSTALLDIR)/br/braniv_0.dat \
 $(INSTALLDIR)/br/braniv_1.dat \
 $(INSTALLDIR)/br/braniw_0.dat \
 $(INSTALLDIR)/br/braniw_1.dat \
 $(INSTALLDIR)/br/branix_0.dat \
 $(INSTALLDIR)/br/branix_1.dat \
 $(INSTALLDIR)/br/braniy_0.dat \
 $(INSTALLDIR)/br/braniy_1.dat \
 $(INSTALLDIR)/br/braniz_0.dat \
 $(INSTALLDIR)/br/braniz_1.dat \
 $(INSTALLDIR)/br/brbar.dat \
 $(INSTALLDIR)/br/brbut0.dat \
 $(INSTALLDIR)/br/brbut1.dat \
 $(INSTALLDIR)/br/brfinal.dat \
 $(INSTALLDIR)/br/bri3.dat \
 $(INSTALLDIR)/br/bri4.dat \
 $(INSTALLDIR)/br/bri7.dat \
 $(INSTALLDIR)/br/brmuz0.dat \
 $(INSTALLDIR)/br/brmuz1.dat \
 $(INSTALLDIR)/br/brmuz2.dat \
 $(INSTALLDIR)/br/brmuz3.dat \
 $(INSTALLDIR)/br/brmuz4.dat \
 $(INSTALLDIR)/br/brmuz5.dat \
 $(INSTALLDIR)/br/brmuz6.dat \
 $(INSTALLDIR)/br/brmuz7.dat \
 $(INSTALLDIR)/br/brspr1.dat \
 $(INSTALLDIR)/br/brspr2.dat \
 $(INSTALLDIR)/br/brspr3.dat \
 $(INSTALLDIR)/br/brspr4.dat \
 $(INSTALLDIR)/br/wani2_0.lpz \
 $(INSTALLDIR)/br/wani2_1.lpz \
 $(INSTALLDIR)/br/wani3_0.lpz \
 $(INSTALLDIR)/br/wani3_1.lpz \
 $(INSTALLDIR)/br/wani4_0.lpz \
 $(INSTALLDIR)/br/wani4_1.lpz \
 $(INSTALLDIR)/br/wani5_0.lpz \
 $(INSTALLDIR)/br/wani5_1.lpz \
 $(INSTALLDIR)/br/wani6_0.lpz \
 $(INSTALLDIR)/br/wani6_1.lpz \
 $(INSTALLDIR)/br/wani7_0.lpz \
 $(INSTALLDIR)/br/wani7_1.lpz \
 $(INSTALLDIR)/br/wani8_0.lpz \
 $(INSTALLDIR)/br/wani8_1.lpz \
 $(INSTALLDIR)/br/wani9_0.lpz \
 $(INSTALLDIR)/br/wani9_1.lpz \
 $(INSTALLDIR)/br/wania_0.lpz \
 $(INSTALLDIR)/br/wania_1.lpz \
 $(INSTALLDIR)/br/wanib_0.lpz \
 $(INSTALLDIR)/br/wanib_1.lpz \
 $(INSTALLDIR)/br/wanic_0.lpz \
 $(INSTALLDIR)/br/wanic_1.lpz \
 $(INSTALLDIR)/br/wanid_0.lpz \
 $(INSTALLDIR)/br/wanid_1.lpz \
 $(INSTALLDIR)/br/wanie_0.lpz \
 $(INSTALLDIR)/br/wanie_1.lpz \
 $(INSTALLDIR)/br/wanif_0.lpz \
 $(INSTALLDIR)/br/wanig_0.lpz \
 $(INSTALLDIR)/br/wanig_1.lpz \
 $(INSTALLDIR)/br/wanih_0.lpz \
 $(INSTALLDIR)/br/wanih_1.lpz \
 $(INSTALLDIR)/br/wanii_0.lpz \
 $(INSTALLDIR)/br/wanii_1.lpz \
 $(INSTALLDIR)/br/wanij_0.lpz \
 $(INSTALLDIR)/br/wanij_1.lpz \
 $(INSTALLDIR)/br/waniu_0.lpz \
 $(INSTALLDIR)/br/waniu_1.lpz \
 $(INSTALLDIR)/br/waniv_0.lpz \
 $(INSTALLDIR)/br/waniv_1.lpz \
 $(INSTALLDIR)/br/waniw_0.lpz \
 $(INSTALLDIR)/br/waniw_1.lpz \
 $(INSTALLDIR)/br/wanix_0.lpz \
 $(INSTALLDIR)/br/wanix_1.lpz \
 $(INSTALLDIR)/br/waniy_0.lpz \
 $(INSTALLDIR)/br/waniz_0.lpz \
 $(INSTALLDIR)/brintro.com

$(INSTALLDIR) \
 $(INSTALLDIR)/br:
	$(MKDIR) $@

$(INSTALLDIR)/br.com: br.com
	$(CP) $< $@
$(INSTALLDIR)/br/W0BUT.bin: br/W0BUT.bin
	$(CP) $< $@
$(INSTALLDIR)/br/W1BUT.bin: br/W1BUT.bin
	$(CP) $< $@
$(INSTALLDIR)/br/W1LAND.bin: br/W1LAND.bin
	$(CP) $< $@
$(INSTALLDIR)/br/W2LAND.bin: br/W2LAND.bin
	$(CP) $< $@
$(INSTALLDIR)/br/W3LAND.bin: br/W3LAND.bin
	$(CP) $< $@
$(INSTALLDIR)/br/W4LAND.bin: br/W4LAND.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WBAR.bin: br/WBAR.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WBULLET.bin: br/WBULLET.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WCREAT1.bin: br/WCREAT1.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WCREAT1b.bin: br/WCREAT1b.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WCREAT1c.bin: br/WCREAT1c.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WCREAT2.bin: br/WCREAT2.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WCREAT2b.bin: br/WCREAT2b.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WCREAT2c.bin: br/WCREAT2c.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WHUM1.bin: br/WHUM1.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WHUM1b.bin: br/WHUM1b.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WHUM1c.bin: br/WHUM1c.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WHUMCAT.bin: br/WHUMCAT.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WHUMHOR.bin: br/WHUMHOR.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WORC1.bin: br/WORC1.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WORC1b.bin: br/WORC1b.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WORC1c.bin: br/WORC1c.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WORCCAT.bin: br/WORCCAT.bin
	$(CP) $< $@
$(INSTALLDIR)/br/WORCHOR.bin: br/WORCHOR.bin
	$(CP) $< $@
$(INSTALLDIR)/br/br0.dat: br/br0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/br1.dat: br/br1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/br101.dat: levels/w~101.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br102.dat: levels/w~102.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br103.dat: levels/w~103.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br104.dat: levels/w~104.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br105.dat: levels/w~105.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br106.dat: levels/w~106.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br107.dat: levels/w~107.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br108.dat: levels/w~108.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br109.dat: levels/w~109.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br110.dat: levels/w~110.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br111.dat: levels/w~111.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br112.dat: levels/w~112.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br113.dat: levels/w~113.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br114.dat: levels/w~114.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br115.dat: levels/w~115.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br116.dat: levels/w~116.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br117.dat: levels/w~117end.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br201.dat: levels/w~201.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br202.dat: levels/w~202.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br203.dat: levels/w~203.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br204.dat: levels/w~204.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br205.dat: levels/w~205.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br206.dat: levels/w~206.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br207.dat: levels/w~207.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br208.dat: levels/w~208.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br209.dat: levels/w~209.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br210.dat: levels/w~210.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br211.dat: levels/w~211.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br212.dat: levels/w~212.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br213.dat: levels/w~213.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br214.dat: levels/w~214.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br215.dat: levels/w~215.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br216.dat: levels/w~216.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br217.dat: levels/w~217end.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/br3.dat: br/br3.dat
	$(CP) $< $@
$(INSTALLDIR)/br/br4.dat: br/br4.dat
	$(CP) $< $@
$(INSTALLDIR)/br/br6.dat: br/br6.dat
	$(CP) $< $@
$(INSTALLDIR)/br/br7.dat: br/br7.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniu_0.dat: br/braniu_0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniu_1.dat: br/braniu_1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniv_0.dat: br/braniv_0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniv_1.dat: br/braniv_1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniw_0.dat: br/braniw_0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniw_1.dat: br/braniw_1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/branix_0.dat: br/branix_0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/branix_1.dat: br/branix_1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniy_0.dat: br/braniy_0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniy_1.dat: br/braniy_1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniz_0.dat: br/braniz_0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/braniz_1.dat: br/braniz_1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brbar.dat: br/brbar.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brbut0.dat: br/brbut0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brbut1.dat: br/brbut1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brfinal.dat: br/brfinal.dat
	$(CP) $< $@
$(INSTALLDIR)/br/bri3.dat: br/bri3.dat
	$(CP) $< $@
$(INSTALLDIR)/br/bri4.dat: br/bri4.dat
	$(CP) $< $@
$(INSTALLDIR)/br/bri7.dat: br/bri7.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brmuz0.dat: br/brmuz0.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brmuz1.dat: br/brmuz1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brmuz2.dat: br/brmuz2.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brmuz3.dat: br/brmuz3.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brmuz4.dat: br/brmuz4.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brmuz5.dat: br/brmuz5.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brmuz6.dat: br/brmuz6.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brmuz7.dat: br/brmuz7.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brspr1.dat: br/brspr1.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brspr2.dat: br/brspr2.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brspr3.dat: br/brspr3.dat
	$(CP) $< $@
$(INSTALLDIR)/br/brspr4.dat: br/brspr4.dat
	$(CP) $< $@
$(INSTALLDIR)/br/wani2_0.lpz: intro/flick.lpz/wani2_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani2_1.lpz: intro/flick.lpz/wani2_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani3_0.lpz: intro/flick.lpz/wani3_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani3_1.lpz: intro/flick.lpz/wani3_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani4_0.lpz: intro/flick.lpz/wani4_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani4_1.lpz: intro/flick.lpz/wani4_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani5_0.lpz: intro/flick.lpz/wani5_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani5_1.lpz: intro/flick.lpz/wani5_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani6_0.lpz: intro/flick.lpz/wani6_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani6_1.lpz: intro/flick.lpz/wani6_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani7_0.lpz: intro/flick.lpz/wani7_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani7_1.lpz: intro/flick.lpz/wani7_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani8_0.lpz: intro/flick.lpz/wani8_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani8_1.lpz: intro/flick.lpz/wani8_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani9_0.lpz: intro/flick.lpz/wani9_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wani9_1.lpz: intro/flick.lpz/wani9_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wania_0.lpz: intro/flick.lpz/wania_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wania_1.lpz: intro/flick.lpz/wania_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanib_0.lpz: intro/flick.lpz/wanib_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanib_1.lpz: intro/flick.lpz/wanib_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanic_0.lpz: intro/flick.lpz/wanic_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanic_1.lpz: intro/flick.lpz/wanic_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanid_0.lpz: intro/flick.lpz/wanid_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanid_1.lpz: intro/flick.lpz/wanid_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanie_0.lpz: intro/flick.lpz/wanie_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanie_1.lpz: intro/flick.lpz/wanie_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanif_0.lpz: intro/flick.lpz/wanif_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanig_0.lpz: intro/flick.lpz/wanig_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanig_1.lpz: intro/flick.lpz/wanig_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanih_0.lpz: intro/flick.lpz/wanih_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanih_1.lpz: intro/flick.lpz/wanih_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanii_0.lpz: intro/flick.lpz/wanii_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanii_1.lpz: intro/flick.lpz/wanii_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanij_0.lpz: intro/flick.lpz/wanij_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanij_1.lpz: intro/flick.lpz/wanij_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/waniu_0.lpz: intro/flick.lpz/waniu_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/waniu_1.lpz: intro/flick.lpz/waniu_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/waniv_0.lpz: intro/flick.lpz/waniv_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/waniv_1.lpz: intro/flick.lpz/waniv_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/waniw_0.lpz: intro/flick.lpz/waniw_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/waniw_1.lpz: intro/flick.lpz/waniw_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanix_0.lpz: intro/flick.lpz/wanix_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/wanix_1.lpz: intro/flick.lpz/wanix_1.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/waniy_0.lpz: intro/flick.lpz/waniy_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/br/waniz_0.lpz: intro/flick.lpz/waniz_0.lpz
	$(CP) $< $@
$(INSTALLDIR)/brintro.com: brintro.com
	$(CP) $< $@

clean:
	$(RM) \
 W1LAND.ast \
 W2LAND.ast \
 W3LAND.ast \
 W4LAND.ast \
 WBAR.ast \
 WBODY.ast \
 WBULLET.ast \
 WCREAT1.ast \
 WCREAT1b.ast \
 WCREAT1c.ast \
 WCREAT2.ast \
 WCREAT2b.ast \
 WCREAT2c.ast \
 WHUM1.ast \
 WHUM1b.ast \
 WHUM1c.ast \
 WHUMBUTT.ast \
 WHUMCAT.ast \
 WHUMHOR.ast \
 WORC1.ast \
 WORC1b.ast \
 WORC1c.ast \
 WORCBUTT.ast \
 WORCCAT.ast \
 WORCHOR.ast \
 br.com \
 br/W0BUT.bin \
 br/W1BUT.bin \
 br/W1LAND.bin \
 br/W2LAND.bin \
 br/W3LAND.bin \
 br/W4LAND.bin \
 br/WBAR.bin \
 br/WBULLET.bin \
 br/WCREAT1.bin \
 br/WCREAT1b.bin \
 br/WCREAT1c.bin \
 br/WCREAT2.bin \
 br/WCREAT2b.bin \
 br/WCREAT2c.bin \
 br/WHUM1.bin \
 br/WHUM1b.bin \
 br/WHUM1c.bin \
 br/WHUMCAT.bin \
 br/WHUMHOR.bin \
 br/WORC1.bin \
 br/WORC1b.bin \
 br/WORC1c.bin \
 br/WORCCAT.bin \
 br/WORCHOR.bin \
 br/br0.dat \
 br/br1.dat \
 br/br3.dat \
 br/br4.dat \
 br/br6.dat \
 br/br7.dat \
 br/brfinal.dat \
 br/bri3.dat \
 br/bri4.dat \
 br/bri7.dat \
 brintro.com \
 demobar.ast \
 levels/w~104.dat \
 levels/w~104.lpz \
 levels/w~107.dat \
 levels/w~107.lpz \
 levels/w~112.dat \
 levels/w~112.lpz \
 levels/w~117end.dat \
 levels/w~117end.lpz \
 levels/w~205.dat \
 levels/w~205.lpz \
 levels/w~213.dat \
 levels/w~213.lpz \
 levels/w~217end.dat \
 levels/w~217end.lpz
