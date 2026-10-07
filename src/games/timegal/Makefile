# Time Gal. Video engine stays in kapps/tgvplay; this dir is the script.
BIN := timegal.com
INSTDIR := nedogame
CONSOLE := BDOS
SRCC := main.c script.c
SRCH := script.h
SRCA :=
XCLFILE := lnk.xcl
TGV := ../../kapps/tgvplay

include ../../kapps/iarlib/iar.mk

# iccz80/az80 take -O relative to the source file and reject "..".
# Make expands this from ./obj when the recipe runs.
TGVOBJ := $(abspath $(OBJ))

OBJC += $(OBJ)/fmv.r01
OBJA += $(OBJ)/tgv_hot.r01 $(OBJ)/gs_pcm.r01

$(BIN): $(OBJ)/fmv.r01 $(OBJ)/tgv_hot.r01 $(OBJ)/gs_pcm.r01 timegal/gover

# Amiga Game Over, 16 ATM colours, next to the clips.
timegal/gover: gover.bin
	$(CP) gover.bin timegal/gover
	$(MKDIR) -p $(ROOTDIR)/release/$(INSTDIR)/timegal
	$(CP) gover.bin $(ROOTDIR)/release/$(INSTDIR)/timegal/gover

$(OBJ)/main.r01: main.c $(TGV)/tgvplay.h script.h | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) -I"$(TGV)/" main.c

$(OBJ)/script.r01: script.c $(TGV)/tgvplay.h script.h | $(OBJ)
	$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) -I$(LIBDIR) -I"$(TGV)/" script.c

$(OBJ)/fmv.r01: $(TGV)/fmv.c $(TGV)/tgvplay.h | $(OBJ)
	cd $(TGV) && $(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$(TGVOBJ)/ -L$(TGVOBJ)/ -A$(TGVOBJ)/ -I$(IARINC) -I$(LIBDIR) fmv.c

$(OBJ)/tgv_hot.r01: $(TGV)/tgv_hot.asm | $(OBJ)
	cd $(TGV) && $(AZ80) -uu -S -v0 -O$(TGVOBJ)/ -I$(OSSDK) tgv_hot.asm

$(OBJ)/gs_pcm.r01: $(TGV)/gs_pcm.asm | $(OBJ)
	cd $(TGV) && $(AZ80) -uu -S -v0 -O$(TGVOBJ)/ -I$(OSSDK) gs_pcm.asm
