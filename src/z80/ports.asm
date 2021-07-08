EMUOUT
;BC=port, A=value
       BIT 0,C
       jp Z,eoutFE
       BIT 1,C
       jr Z,eoutFD
        PUSH AF
        LD A,(doson0)
        OR A
        jp Z,EMUOUTDOS
        POP AF
        RET 
eoutFD
       BIT 7,B
       jp Z,eout7FFD
       BIT 6,B
       jr NZ,eoutFFFD
        LD BC,#BFFD
        OUT (C),A
        RET 
eoutFFFD
       BIT 5,B
       jr z,eoutDFFD
        LD BC,#FFFD
        OUT (C),A
        RET 
eoutDFFD
        ld (_dffd),a
        AND 128 ;video mode
oldcurvideomode=$+1
        cp 0
        ;jr z,eoDFFDnovideomode
        ;ld (oldcurvideomode),a
        call nz,setvideomode
;eoDFFDnovideomode
        ld a,(_fd)
eout7FFD
;TODO block if bit 5 was "1" in (_fd)
        LD (_fd),A
        LD C,A
        AND #C7
        and 7
        ld l,a
       ld a,(_dffd)
	if PROFI==512
       and 3 ;Profi 512K
	else
       and 7 ;Profi 1024K
	endif
       add a,a
       add a,a
       add a,a
       add a,l
       ld (_logicpg),a
       ld l,a
        ld h,temulpgs/256
        ld a,(hl)
deadpg=$+1
        cp 0
        jr nz,eout7FFDOK
       push bc
       push de
       push hl
       exx
       push bc
       push de
       push hl
       push ix
       push iy
       exa
       push af
       OS_NEWPAGE ;мегабайт захватывать динамически постранично
       pop af
       exa
        ld a,e
       pop iy
       pop ix
       pop hl
       pop de
       pop bc
       exx
       pop hl
       pop de
       pop bc      
        ld (hl),a
eout7FFDOK

        ld a,(_dffd)
        and 16 ;D4 = rom off
        jr z,eout7FFD_romon
        ld a,(temulpgs+0)
        LD (emulcurpg0000),A
         ld a,ROMSTATE_OFF
         ld (romstate_flag),a
         ld a,DOSSTATE_FROM128
         ld (DOSER_state),a ;skip DOSER
        jr eout7FFD_romonq
eout7FFD_romon
       LD A,(doson0) ;DOS ports on
       OR A
       jr Z,eo7FFDdos
        BIT 4,C ;номер ПЗУ
        ld b,DOSSTATE_FROM48
        LD A,(pgrom48)
        jr NZ,eo7FFDo
        ld b,DOSSTATE_FROM128
        LD A,(pgrom128)
        JR eo7FFDo
eo7FFDdos
        BIT 4,C ;номер ПЗУ
        ld b,DOSSTATE_FROMDOS
        LD A,(pgromDOS)
        jr NZ,eo7FFDo
        LD A,(pgromSYS)
eo7FFDo
        LD (emulcurpg0000),A
        ld a,b
        ld (DOSER_state),a
         ld a,ROMSTATE_ON
         ld (romstate_flag),a
eout7FFD_romonq

        LD A,C
        AND 8 ;номер экрана
        LD (curscr),A
oldcurscr7ffd=$+1
        cp 0
        ;jr z,eo7FFDnoscr
        ;ld (oldcurscr7ffd),a
        call nz,setscreen
;eo7FFDnoscr
        ld hl,_dffd
        bit 3,(hl)
        ld a,5
        jr z,eo7FFD_nomem4000
_logicpg=$+1
        ld a,0;(_logicpg)
eo7FFD_nomem4000
        ld (_logicpg4000),a
        ld a,(_logicpg)
        jr z,eo7FFD_nomemc000
        ld a,7
eo7FFD_nomemc000
        ld (_logicpgc000),a
        bit 6,(hl)
        ld a,2
        jr z,eo7FFD_nomem8000
        ld a,6
eo7FFD_nomem8000
        ld (_logicpg8000),a
;(_logicpgx000) are formed!

        ld hl,(_logicpg4000)
        ld h,temulpgs/256
        ld a,(hl)        
        LD (emulcurpg4000),A

        ld hl,(_logicpgc000)
        ld h,temulpgs/256
        ld a,(hl)        
        LD (emulcurpgc000),A
       if margins;MEM48C0
        SETPGC000
       endif
        ld hl,(_logicpg8000)
        ld h,temulpgs/256
        ld a,(hl)        
        LD (emulcurpg8000),A
       if margins;MEM48C0
        SETPG8000
       endif

       if extpg5
        ld a,(_dffd)
        rla
        ld a,(_logicpgc000)
        jr nc,screeninc000_noprofi
        and 0xff-2
        cp 0x04
        jr z,screeninc000_noprofiq
        cp PGATTR0
        jr screeninc000_noprofiq
screeninc000_noprofi
        and 0xff-2
        cp 5
screeninc000_noprofiq
        ld a,0xc9 ;screen off
        jr nz,$+3
         xor a ;screen on
        ld (screeninc000_flag),a
        
        ld a,(_dffd)
        rla
        ld a,(_logicpg4000)
        jr nc,screenin4000_noprofi
        and 0xff-2
        cp 0x04
        jr z,screenin4000_noprofiq
        cp PGATTR0
        jr screenin4000_noprofiq
screenin4000_noprofi
        and 0xff-2
        cp 5
screenin4000_noprofiq
        ld a,0xc9 ;screen off
        jr nz,$+3
         xor a ;screen on
        ld (screenin4000_flag),a
        
        ld a,(_dffd)
        rla
        ld a,(_logicpg8000)
        jr nc,screenin8000_noprofi
        and 0xff-2
        cp 0x04
        jr z,screenin8000_noprofiq
        cp PGATTR0
        jr screenin8000_noprofiq
screenin8000_noprofi
        and 0xff-2
        cp 5
screenin8000_noprofiq
        ld a,0xc9 ;screen off
        jr nz,$+3
         xor a ;screen on
        ld (screenin8000_flag),a
        
       endif

       if margins
        ld a,0x3e
        ld (set4000com),a
        CALCpgcom
       endif
        RET 
eoutFE
        LD (_fe),A
outFE
        OUT (#FE),A
        RET 
EMUOUTDOS
        LD A,C
        CP #3F
        jr Z,eod3F
        CP #5F
        jr Z,eod5F
        CP #FF
        jr Z,eodFF
        POP AF
        RET 
eod3F
        POP AF
        LD (dos3F),A
        RET 
eod5F
        POP AF
        LD (dos5F),A
        RET 
eodFF
        POP AF
        LD (dosFF),A
        RET 

copyscreen_profi
;a=logicpg
        ld (copyscreen_profi_logicpg),a
        ld c,a
        ld b,temulpgs/256
        ld a,(bc)
        ld (copyscreen_profi_physpg),a
        ld hl,0x4000
copyscreen_profi0
        push hl
copyscreen_profi_physpg=$+1
        ld a,0
        OUTPG4000
        ld c,(hl)
        or a
copyscreen_profi_logicpg=$+1
        ld a,0
        call screen4000_branchvideomode
        pop hl
        inc l
        jr nz,copyscreen_profi0
        inc h
        jp p,copyscreen_profi0
        ret

EMUIN
;BC=port
;return A=value
       BIT 0,C
       jr Z,einFE
        LD A,(doson0)
        OR A
        jr Z,EMUINDOS
       LD A,C
       cp 0xfd
       jr z,einAY
       CP #DF
       jr Z,einMOUSE
       CP #1F
       jr Z,einKEMPSTON
        LD A,#FF
        RET 
einAY
        ld bc,0xfffd
        in a,(c)
        ret
einMOUSE
       LD A,B
       CP #FA
       jr Z,einFADF
       CP #FB
       jr Z,einFBDF
       CP #FF
       jr Z,einFFDF
        LD A,#FF
        RET 
einFADF
        ;LD BC,#FADF
        ;IN A,(C)
mousebuttons=$+1
        ld a,0xff
        RET 
einFBDF
        ;LD BC,#FBDF
        ;IN A,(C)
mousex=$+1
        ld a,0
        RET 
einFFDF
        ;LD BC,#FFDF
        ;IN A,(C)
mousey=$+1
        ld a,0
        RET 
einKEMPSTON
        ;IN A,(#1f)
kempston=$+1
        ld a,0
        RET 
einFE
        ;LD C,#FE
        ;IN A,(C)
        ;ld a,b
        ;or a
        ;jr z,$
       push hl
       ld hl,keymatrix
       ld a,0xff
       dup 8
       rlc b
       jr c,$+3
       and (hl)
       inc hl
       edup
       pop hl
       and a
        ;LD C,#FE
        ;IN A,(C)
        RET
EMUINDOS
        LD A,C
        CP #1F
        jr Z,eid1F
        CP #3F
        jr Z,eid3F
        CP #5F
        jr Z,eid5F
        CP #5F
        jr Z,eidFF
        LD A,#FF
        RET
eidFF
        ;LD A,#80 ;INTRQ=команда выполнена ok
        ld a,r
        rla
        and 0xc0 ;D6=DRQ, D7=INTRQ
        RET
eid1F
        ;LD A,#80 ;команда выполнена ok, диск вставлен
        ld a,r
fddstatemask=$+1
        and 3
        or 0x80
        RET
eid3F
        LD A,(dos3F) ;trk
        RET
eid5F
        LD A,(dos5F) ;sec
        RET

setvideomode
        ld (oldcurvideomode),a
;video mode changed! set system video mode and recode screen data
       ;push bc
       push de
       ;push hl
        rla
        jr c,eoDFFD_copyprofi
        ld a,SCREEN4000_VIDEOMODE_6912
        ld (screen4000_videomode),a
        ld a,SCREEN8000_VIDEOMODE_6912
        ld (screen8000_videomode),a
        ld a,SCREENC000_VIDEOMODE_6912
        ld (screenc000_videomode),a
        ld a,0x05
        call copyscreen_profi
        ld a,0x07
        call copyscreen_profi
        ld e,3+0x80 ;6912+keep
        jr eoDFFD_copyprofiq
eoDFFD_copyprofi
        ld a,(user_scr1_high) ;ok
        call clearpg
        ld a,(user_scr0_high) ;ok
        call clearpg
        ld a,SCREEN4000_VIDEOMODE_PROFI
        ld (screen4000_videomode),a
        ld a,SCREEN8000_VIDEOMODE_PROFI
        ld (screen8000_videomode),a
        ld a,SCREENC000_VIDEOMODE_PROFI
        ld (screenc000_videomode),a
        ld a,0x04
        call copyscreen_profi
        ld a,0x06
        call copyscreen_profi
        ld a,PGATTR0;0x38
        call copyscreen_profi
        ld a,PGATTR1;0x3a
        call copyscreen_profi
        ld e,2+0x80 ;MC+keep
eoDFFD_copyprofiq
       exx
       push bc
       push de
       push hl
       push ix
       push iy
       exx
       exa
       push af
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
       pop af
       exa
        ld a,e
       pop iy
       pop ix
       pop hl
       pop de
       pop bc
       exx
       ;pop hl
       pop de
       ;pop bc
       ret

setscreen
        ld (oldcurscr7ffd),a
       ;push bc
       push de
       ;push hl
       exx
       push bc
       push de
       push hl
       push ix
       push iy
        rrca
        rrca
        rrca
        ld e,a
       exa
       push af
       OS_SETSCREEN
       pop af
       exa
       pop iy
       pop ix
       pop hl
       pop de
       pop bc
       exx
       ;pop hl
       pop de
       ;pop bc
       ret
