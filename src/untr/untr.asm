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

;+-96 semitone shift
;masks (T,N,E,hole,outerenv)
;+-96 env semitone shift (fair tone ratio guaranteed for 1:1, 3:4, 1:2, 1:4, 3:1, 5:2, 2:1, 3:2 + 4:1)
;+-4095 tonefrq shift
;+-15 volume shift
;retrigtone
;31 noisefrq
;16 envtype
;retrigenv
;в этой структуре накопления запрещены!
        STRUCT chnout
note_in BYTE
keepme_in BYTE ;priority for keep on top (bigger is more priority)
tonefrq WORD
masks   BYTE ;T,N,E,hole,outerenv ;дырка управляется отдельно!!! т.к. уровень для !T!N отличается от T vol 0
keepme  BYTE ;priority for keep on top (bigger is more priority)
volume  BYTE ;volume = +-127 (cut to 0..15)
noisefrq BYTE ;noise = 0..255 (cut to 0..31)
envtype BYTE
retrigenv BYTE ;retrigger envelope ;retrigenvbit
retrigtone BYTE ;retrigger tone ;0=off/0xff=on
envfrq  WORD
        ENDS

MASKBIT_T=0
MASKBIT_N=1
MASKBIT_E=2
MASKBIT_HOLE=3
MASKBIT_OUTERENV=4

retrigenvbit=7

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
;в release должен быть понижен приоритет канала
;если в from1 есть огибающая, то игнорируем from1, если его KEEPME <= чем у from2
;т.к. огибающую должен перекрывать тональник!!!
        bit MASKBIT_E,(ix+chnout.masks)
        jr nz,mixchn_keep2
;если в from1 есть шум, то игнорируем from2, если его KEEPME <= чем у from1
        ;bit MASKBIT_N,(ix+chnout.masks)
        ;jr nz,mixchn_keep1
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
        bit MASKBIT_OUTERENV,(iy+chnout.masks)
        jr nz,mixchn_keep2outerenv
        ld a,(ix+chnout.keepme)
        cp (iy+chnout.keepme)
        ret nc ;при равенстве keepme оставляем from1
        jr mixchn_keep2_ok
mixchn_keep2
        bit MASKBIT_OUTERENV,(iy+chnout.masks)
        jr nz,mixchn_keep1outerenv
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
mixchn_keep1outerenv
        ld a,(iy+chnout.envfrq)
        ld (ix+chnout.envfrq),a
        ld a,(iy+chnout.envfrq+1)
        ld (ix+chnout.envfrq+1),a
        ret
mixchn_keep2outerenv
        push iy
        pop hl
        push ix
        pop de
        ld bc,chnout
        ldir
        ld a,(ix+chnout.envfrq)
        ld (iy+chnout.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chnout.envfrq+1),a
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
        set retrigenvbit,b
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
        bit retrigenvbit,d
        ret z ;no env retrigger
        LD B,0xff
        OUT (C),a
        LD B,E
        OUTI
        ret

;Sample:
;256 masks (T,N,E,hole,outerenv, retrigtone,semitoneshiftpresent,tonefrqshiftpresent), одна из комбинаций означает loop (например, E=0 и envsemitoneshiftpresent=1)
noisefrqpresent=1
envtypepresent=2
semitoneshiftpresent=6
tonefrqshiftpresent=7
;+-96 semitone shift (в потоке при наличии semitoneshiftpresent)
;+-96 env semitone shift (fair tone ratio guaranteed for 1:1, 3:4, 1:2, 1:4, 3:1, 5:2, 2:1, 3:2 + 4:1) (в потоке при наличии E)
;8*2 envtype + retrigenv (в потоке при наличии E)
;16 volume (в потоке при отсутствии E)
;+-4095 tonefrq shift (в потоке при наличии tonefrqshiftpresent)
;31 noisefrq (в потоке при наличии N)
;>1 >256 loop addrshift

playsample_loop
        ld e,(hl)
        inc hl
        ld d,(hl)
        add hl,de
playsample
;ix=chnout
;в любом случае полностью определяет текущие значения полей chnout:
 ;(берутся из потока:)
;masks   BYTE ;T,N,E,hole,outerenv, retrigtone,semitoneshiftpresent,tonefrqshiftpresent (должен быть первым байтом строки в потоке)
;noisefrq BYTE ;noise = 0..31 (в потоке при наличии N)
;envtype BYTE (в потоке при наличии E, значения 8..15 (15 как 4, 9 как 1) + retrigenv + outerenv, иначе volume)
;retrigenv BYTE ;retrigger envelope ;bit 3 (берётся из envtype)
;retrigtone BYTE ;retrigger tone ;0=off/0xff=on (берётся из маски)
;volume  BYTE ;volume = 0..15
 ;(вычисляются:)
;keepme  BYTE ;priority for keep on top (bigger is more priority)
;envfrq  WORD
;tonefrq WORD
        ld b,(hl) ;masks
        inc hl
        inc b
        jr z,playsample_loop
        dec b
        ld (ix+chnout.masks),b ;masks   BYTE ;T,N,E,hole,outerenv,retrigtone,semitoneshiftpresent,tonefrqshiftpresent (должен быть первым байтом строки в потоке)
        ld a,(ix+chnout.note)
        bit semitoneshiftpresent,b
        jr z,playsample_nosemitoneshift
        add a,(hl)
        inc hl
        jp po,playsample_nosemitoneshift ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
playsample_nosemitoneshift
        bit envtypepresent,b
        jr z,playsample_noenvsemitoneshift
        add a,(hl) ;envsemitoneshift
        ld e,a
        ld d,tfrq/256
;cout env frq (use frq table)
        ld a,(de)
        ld c,a
        inc d
        ld a,(de)
        ;ld d,a
        ld (ix+chnout.envfrq),c
        ld (ix+chnout.envfrq+1),a;d
;count tone frq (TODO use ratio)
;временная затычка - частота тона по частотной таблице без envsemitoneshift
        ld a,e
        sub (hl)
        ld e,a
        ld a,(de)
        ld c,a
        dec d
        ld a,(de)
        ld e,a
        ld d,c
        ;ld a,(hl) ;envsemitoneshift

        inc hl
        jr playsample_noenvsemitoneshiftq
playsample_noenvsemitoneshift
;count tone frq (use frq table)
        ld e,a
        ld d,tfrq/256
;cout env frq (use frq table)
        ld a,(de)
        ld c,a
        inc d
        ld a,(de)
        ld d,a
        ld e,c
playsample_noenvsemitoneshiftq

        bit envtypepresent,b
        jr z,playsample_noenvtype
        ld a,(hl)
        inc hl
        ld (ix+chnout.retrigenv),a ;retrigenv BYTE ;retrigger envelope ;retrigenvbit
        and 0x0f
        ld (ix+chnout.envtype),a ;envtype BYTE (в потоке при наличии E, значения 8..15 (15 как 4, 9 как 1) + retrigenvbit, иначе volume) ;тип огибающей без E не важен
        ;ld a,16 ;volume НЕ ВАЖНО
        ;ld (ix+chnout.volume),a ;volume  BYTE ;volume = 0..15
        jr playsample_noenvtypeq
playsample_noenvtype
        ld a,(hl) ;volume
        inc hl
        ld (ix+chnout.volume),a ;volume  BYTE ;volume = 0..15
playsample_noenvtypeq
        bit noisefrqpresent,b
        jr z,playsample_nonoisefrq
        ld a,(hl)
        inc hl
        ld (ix+chnout.noisefrq),a ;noisefrq BYTE ;noise = 0..31 (в потоке при наличии N) ;noisefrq без N не важен
playsample_nonoisefrq
        bit tonefrqshiftpresent,b
        jr z,playsample_notonefrqshift
        ld a,(hl)
        add a,e
        ld e,a
        inc hl
        ld a,(hl)
        adc a,d
        ld d,a ;correct tone frq
        inc hl
playsample_notonefrqshift
        ld (ix+chnout.tonefrq),e
        ld (ix+chnout.tonefrq+1),d
        ld a,b
        and 32 ;retrigtone
        add a,-32
        sbc a,a
        ld (ix+chnout.retrigtone),a ;retrigtone BYTE ;retrigger tone ;0=off/0xff=on (берётся из маски)
 (берётся из envtype)
        ld a,(ix+chnout.keepme_in)
        ld (ix+chnout.keepme),a ;keepme  BYTE ;priority for keep on top (bigger is more priority)

;out: hl=next line in sample
        ret


cmd_end

	;display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "untr.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l"
