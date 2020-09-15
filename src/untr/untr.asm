        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
cmd_begin

        
        QUIT

        STRUCT chip
retriggers BYTE ;A,B,C,E
Atonefrq WORD
Btonefrq WORD
Ctonefrq WORD
noisefrq BYTE
masks   BYTE ;!AT,!BT,!CT,!AN,!BN,!CN
Avolume BYTE
Bvolume BYTE
Cvolume BYTE
envfrq  WORD
envtype BYTE
        ENDS

        STRUCT chnout
tonefrq WORD
masks   BYTE ;T,N,E,hole ;дырка управляется отдельно!!! т.к. уровень для !T!N отличается от T vol 0
keepme  BYTE ;priority for keep on top (bigger is more priority)
volume  BYTE ;volume = +-127 (cut to 0..15)
noisefrq BYTE ;noise = 0..255 (cut to 0..31)
envtype BYTE
retrigenv BYTE ;retrigger envelope ;bit 3
retrigtone BYTE ;retrigger tone ;0=off/0xff=on
envfrq  WORD
        ENDS

MASKBIT_T=0
MASKBIT_N=1
MASKBIT_E=2
MASKBIT_HOLE=3

filtervolume
;ix=from=to
;e=volume shift (+-15)
        ld a,(ix+chnout.volume)
        add a,e
        ld (ix+chnout.volume),a
        ret po ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
        ret

filternoise
;ix=from=to
;e=noise shift (+-15)
        ld a,(ix+chnout.noisefrq)
        add a,e
        ld (ix+chnout.noisefrq),a
        ret po ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
        ret

mixchn
;ix=from1=to
;iy=from2
;если в from1 есть огибающая, то игнорируем from2, если его KEEPME <= чем у from1
;TODO или тихую огибающую должен перекрывать тональник?
        bit MASKBIT_E,(ix+chnout.masks)
        jr nz,mixchn_keep1
;если в from1 есть шум, то игнорируем from2, если его KEEPME <= чем у from1
        bit MASKBIT_N,(ix+chnout.masks)
        jr nz,mixchn_keep1
;если в from2 дырка, то берём from1
        bit MASKBIT_HOLE,(iy+chnout.masks)
        jr nz,mixchn_keep1
;если в from1 дырка, то берём from2
        bit MASKBIT_HOLE,(iy+chnout.masks)
        jr nz,mixchn_keep2
;берём самый громкий по тональнику
;TODO низкие ноты не считать громкими
        ld a,(iy+chnout.volume)
        add a,0x80
        ld e,a
        ld a,(ix+chnout.volume)
        add a,0x80
        cp e
        jr c,mixchn_keep2
mixchn_keep1
        ld a,(ix+chnout.keepme)
        cp (iy+chnout.keepme)
        ret nc ;при равенстве keepme оставляем from1
        jr mixchn_keep2_ok
mixchn_keep2
        ld a,(iy+chnout.keepme)
        cp (ix+chnout.keepme)
        jr c,mixchn_keep1 ;при равенстве keepme оставляем from2
mixchn_keep2_ok
        push iy
        pop hl
        push ix
        pop de
        ld bc,chnout
        ldir
        ret

;надо в дырке такое поведение:
;       ||
;      |||        
;|||||||||____
;т.е. в дырке ставим громкость 0 (а не маску !T!N)
rendchip
;ix=fromA
;hl=fromB
;de=fromC
;iy=chip
        push de ;fromC
        push hl ;fromB
        ld bc,0x00ff ;b=ретриггеры A,B,C,E ;c=masks: все выключены
        ld d,b
        ld e,c ;d=текущий приоритет шума, e=текущий приоритет огибающей
        ld h,(iy+chip.envtype) ;бывший тип огибающей

        ld a,(ix+chnout.volume)
        or a
        jp p,$+4
        xor a
        cp 15
        jr c,$+4
        ld a,15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,$+4
        ld a,16
        ld (iy+chip.Avolume),a
        jr z,rendchip_Anoenv
        ld a,(ix+chnout.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Anoenv
        ld e,a
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld a,(ix+chnout.envtype)
        ld (iy+chip.envtype),a
        ld a,(ix+chnout.retrigenv)
        or b
        ld b,a ;сумма ретриггеров
rendchip_Anoenv
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Anotone
        res 0,c
        ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Atonefrq),a
        ld a,(ix+chnout.tonefrq+1)
        ld (iy+chip.Atonefrq+1),a
        ld a,(ix+chnout.retrigtone)
        and 1
        or b
        ld b,a ;сумма ретриггеров
rendchip_Anotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Anonoise
        res 3,c
        ld a,(ix+chnout.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Anonoise
        ld d,a
        ld a,(ix+chnout.noisefrq)
        ld (iy+chip.noisefrq),a
rendchip_Anonoise

        pop ix ;fromB
        ld a,(ix+chnout.volume)
        or a
        jp p,$+4
        xor a
        cp 15
        jr c,$+4
        ld a,15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,$+4
        ld a,16
        ld (iy+chip.Bvolume),a
        jr z,rendchip_Bnoenv
        ld a,(ix+chnout.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Bnoenv
        ld e,a
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld a,(ix+chnout.envtype)
        ld (iy+chip.envtype),a
        ld a,(ix+chnout.retrigenv)
        or b
        ld b,a ;сумма ретриггеров
rendchip_Bnoenv
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Bnotone
        res 1,c
        ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Btonefrq),a
        ld a,(ix+chnout.tonefrq+1)
        ld (iy+chip.Btonefrq+1),a
        ld a,(ix+chnout.retrigtone)
        and 2
        or b
        ld b,a ;сумма ретриггеров
rendchip_Bnotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Bnonoise
        res 4,c
        ld a,(ix+chnout.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Bnonoise
        ld d,a
        ld a,(ix+chnout.noisefrq)
        ld (iy+chip.noisefrq),a
rendchip_Bnonoise
        
        pop ix ;fromC
        ld a,(ix+chnout.volume)
        or a
        jp p,$+4
        xor a
        cp 15
        jr c,$+4
        ld a,15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,$+4
        ld a,16
        ld (iy+chip.Cvolume),a
        jr z,rendchip_Cnoenv
        ld a,(ix+chnout.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Cnoenv
        ld e,a
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld a,(ix+chnout.envtype)
        ld (iy+chip.envtype),a
        ld a,(ix+chnout.retrigenv)
        or b
        ld b,a ;сумма ретриггеров
rendchip_Cnoenv
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Cnotone
        res 2,c
        ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Ctonefrq),a
        ld a,(ix+chnout.tonefrq+1)
        ld (iy+chip.Ctonefrq+1),a
        ld a,(ix+chnout.retrigtone)
        and 4
        or b
        ld b,a ;сумма ретриггеров
rendchip_Cnotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Cnonoise
        res 5,c
        ld a,(ix+chnout.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Cnonoise
        ld d,a
        ld a,(ix+chnout.noisefrq)
        ld (iy+chip.noisefrq),a
rendchip_Cnonoise

        ld a,(iy+chip.envtype)
        cp h
        jr z,$+4
        set 3,b
        ld (iy+chip.retriggers),b
        
        ld (iy+chip.masks),c
        ret

outchip
;hl=chip (байт флагов ретриггера (ABCE) + 13 байт данных AY)
        xor a
        LD C,0xfd
        LD E,0xBF
        bit 0,(hl)
        jr z,outchip_noretrigA
        ld d,0
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
        inc d
        out (c),d
        ld b,e
        out (c),a
outchip_noretrigA
        bit 1,(hl)
        jr z,outchip_noretrigB
        ld d,2
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
        inc d
        out (c),d
        ld b,e
        out (c),a
outchip_noretrigB
        bit 2,(hl)
        jr z,outchip_noretrigC
        ld d,4
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
        inc d
        out (c),d
        ld b,e
        out (c),a
outchip_noretrigC
        ;xor a
        ld d,(hl)
OUTAY0
        ld b,0xff
        OUT (C),a
        LD B,E
        OUTI
        inc a
        cp 13
        jr NZ,OUTAY0
        bit 3,d
        ret z ;no env retrigger
        LD B,0xff
        OUT (C),a
        LD B,E
        OUTI
        ret

cmd_end

	;display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "untr.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../../us/user.l"
