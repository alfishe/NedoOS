filterhandler_vol
        ld a,e
        sub 1+15 ;"f" (1="0", 2="1"...)
        ld e,a ;vol "f" = +0, "g" = +1...
filtervolume
;ix=from=to
;e=volume shift (+-15)
        ld a,(ix+chn.volume)
        add a,e
        jp po,filtervolumeq ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
filtervolumeq        
        ld (ix+chn.volume),a
        ret

filterhandler_noise
;TODO
        ret
filternoise
;ix=from=to
;e=noise shift (+-15)
        ld a,(ix+chn.noisefrq)
        add a,e
        jp po,filternoiseq ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
filternoiseq
        ld (ix+chn.noisefrq),a
        ret

filterhandler_vib
;TODO
        ret
filtertone
;ix=from=to
;de=tone shift (+-4095)
        ld a,(ix+chn.tonefrq)
        add a,e
        ld e,a
        ld a,(ix+chn.tonefrq+1)
        adc a,d
        ld d,a
        jp p,$+6
         ld de,0
        ld (ix+chn.tonefrq),e
        ld (ix+chn.tonefrq+1),d
        ret

filterhandler_env
;TODO
filterenv
;ix=from=to
;de=env shift
        ld a,(ix+chn.envfrq)
        add a,e
        ld e,a
        ld a,(ix+chn.envfrq+1)
        adc a,d
        ld d,a
        jp p,$+6
         ld de,0
        ld (ix+chn.envfrq),e
        ld (ix+chn.envfrq+1),d
        ret

mixchn
;ix=from1=to
;iy=from2
;в release должен быть понижен приоритет канала
;если в from1 есть огибающая, то игнорируем from1, если его KEEPME <= чем у from2
;т.к. огибающую должен перекрывать тональник!!!
        ;bit MASKBIT_E,(ix+chn.masks)
        ;jr nz,mixchn_keep2
;если в from1 есть шум, то игнорируем from2, если его KEEPME <= чем у from1
        ;bit MASKBIT_N,(ix+chn.masks)
        ;jr nz,mixchn_keep1
;если в from2 дырка, то берём from1
        bit MASKBIT_HOLE,(iy+chn.masks)
        ret nz;jr nz,mixchn_keep1_ok
;если в from1 дырка, то берём from2
        bit MASKBIT_HOLE,(ix+chn.masks)
        jr nz,mixchn_keep2_ok
;берём самый громкий по тональнику
;TODO низкие ноты не считать громкими
        ld a,(iy+chn.volume)
         bit MASKBIT_E,(iy+chn.masks)
         jr z,$+4
         ld a,12 ;E играет на уровне 11, C на уровне 13, T-E играет громко!!! TODO
        add a,(iy+chn.keepme)
        add a,0x80
        ld e,a
        ld a,(ix+chn.volume)
         bit MASKBIT_E,(ix+chn.masks)
         jr z,$+4
         ld a,12 ;E играет на уровне 11, C на уровне 13, T-E играет громко!!! TODO
        add a,(ix+chn.keepme)
        add a,0x80
        cp e
        jr c,mixchn_keep2_ok
mixchn_keep1
        ;ld a,(ix+chn.keepme)
        ;cp (iy+chn.keepme)
        ;ret nc ;при равенстве keepme оставляем from1
        ;jr c,mixchn_keep2_ok
        bit MASKBIT_OUTERENV,(iy+chn.masks)
        jr nz,mixchn_keep2outerenv
        ret
mixchn_keep2
        ;ld a,(iy+chn.keepme)
        ;cp (ix+chn.keepme)
        ;jr c,mixchn_keep1 ;при равенстве keepme оставляем from2
        bit MASKBIT_OUTERENV,(iy+chn.masks)
        jr nz,mixchn_keep1outerenv
mixchn_keep2_ok
        push iy
        pop hl
        push ix
        pop de
        ld bc,chn.note_in;chn
        ldir
        ret
mixchn_keep1outerenv
        ld a,(iy+chn.envfrq)
        ld (ix+chn.envfrq),a
        ld a,(iy+chn.envfrq+1)
        ld (ix+chn.envfrq+1),a
        ret
mixchn_keep2outerenv
        push iy
        pop hl
        push ix
        pop de
        ld bc,chn.note_in;chn
        ldir
        ld a,(ix+chn.envfrq)
        ld (iy+chn.envfrq),a
        ld a,(ix+chn.envfrq+1)
        ld (iy+chn.envfrq+1),a
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
        ld bc,0x00ff ;b=ретриггеры A,B,C ;c=masks: все выключены
        ld d,b ;текущий приоритет шума
        ld e,b ;текущий приоритет огибающей
        ld h,(iy+chip.envtype) ;бывший тип огибающей
        res retrigenvbit,h
        ld l,h

        xor a
        bit MASKBIT_HOLE,(ix+chn.masks)
        jr nz,rendchip_Anoenv
        ld a,(ix+chn.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chn.masks)
        jr z,rendchip_Anoenv
        ld e,(ix+chn.keepme) ;текущий приоритет огибающей
        ld a,(ix+chn.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chn.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chn.envtype) ;текущий тип огибающей
        ld a,16
rendchip_Anoenv
        ld (iy+chip.Avolume),a
        bit MASKBIT_T,(ix+chn.masks)
        jr z,rendchip_Anotone
        dec c ;res 0,c
        ld a,(ix+chn.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Atonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chn.tonefrq)
        ld (iy+chip.Atonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chn.masks)
        jr z,$+3
        inc b ;set 0,b сумма ретриггеров
rendchip_Anotone
        bit MASKBIT_N,(ix+chn.masks)
        jr z,rendchip_Anonoise
        res 3,c
        ld d,(ix+chn.keepme) ;текущий приоритет шума
        ld a,(ix+chn.noisefrq)
        cp 32
        jr c,$+5;7
         rla
         sbc a,a
         cpl
         ;and 31
        ld (iy+chip.noisefrq),a
rendchip_Anonoise

        pop ix ;fromB
        xor a
        bit MASKBIT_HOLE,(ix+chn.masks)
        jr nz,rendchip_Bnoenv
        ld a,(ix+chn.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chn.masks)
        jr z,rendchip_Bnoenv
        ld a,(ix+chn.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Buseenv
        ld e,a
        ld a,(ix+chn.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chn.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chn.envtype) ;текущий тип огибающей
rendchip_Buseenv
        ld a,16
rendchip_Bnoenv
        ld (iy+chip.Bvolume),a
        bit MASKBIT_T,(ix+chn.masks)
        jr z,rendchip_Bnotone
        res 1,c
        ld a,(ix+chn.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Btonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chn.tonefrq)
        ld (iy+chip.Btonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chn.masks)
        jr z,$+4
         set 1,b ;сумма ретриггеров
rendchip_Bnotone
        bit MASKBIT_N,(ix+chn.masks)
        jr z,rendchip_Bnonoise
        res 4,c
        ld a,(ix+chn.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Bnonoise
        ld d,a
        ld a,(ix+chn.noisefrq)
        cp 32
        jr c,$+5;7
         rla
         sbc a,a
         cpl
         ;and 31
        ld (iy+chip.noisefrq),a
rendchip_Bnonoise
        
        pop ix ;fromC
        xor a
        bit MASKBIT_HOLE,(ix+chn.masks)
        jr nz,rendchip_Cnoenv
        ld a,(ix+chn.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chn.masks)
        jr z,rendchip_Cnoenv
        ld a,(ix+chn.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Cuseenv
        ;ld e,a
        ld a,(ix+chn.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chn.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chn.envtype) ;текущий тип огибающей
rendchip_Cuseenv
        ld a,16
rendchip_Cnoenv
        ld (iy+chip.Cvolume),a
        bit MASKBIT_T,(ix+chn.masks)
        jr z,rendchip_Cnotone
        res 2,c
        ld a,(ix+chn.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Ctonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chn.tonefrq)
        ld (iy+chip.Ctonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chn.masks)
        jr z,$+4
         set 2,b ;сумма ретриггеров
rendchip_Cnotone
        bit MASKBIT_N,(ix+chn.masks)
        jr z,rendchip_Cnonoise
        res 5,c
        ld a,(ix+chn.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Cnonoise
        ;ld d,a
        ld a,(ix+chn.noisefrq)
        cp 32
        jr c,$+5;7
         rla
         sbc a,a
         cpl
         ;and 31
        ld (iy+chip.noisefrq),a
rendchip_Cnonoise

        ld (iy+chip.retriggers),b
        ld (iy+chip.masks),c
        ld a,l
        cp h ;несовпадение в том числе при retrigenvbit (в h он сброшен)
        jr z,$+4
         set retrigenvbit,a
        ld (iy+chip.envtype),a ;текущий тип огибающей
        ret

outchip
;hl=chip (байт флагов ретриггера (ABC) + 13 байт данных AY)
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
        ld b,0xff
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
        ld b,0xff
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
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
outchip_noretrigC
        inc hl
        ;xor a
        ld d,0xff
       dup 12
        ld b,d;0xff
        OUT (C),a
        LD B,E
        OUTI
        inc a
       edup
        ld b,d;0xff
        OUT (C),a
        LD B,E
        OUTI
        bit retrigenvbit,(hl)
        ret z ;no env retrigger
        inc a
        ld b,d;0xff
        OUT (C),a
        LD B,E
        OUTI
        ret

setchip1
        ld a,0xff
        jr setchip_a
setchip0
        ld a,0xfe
setchip_a
        ld bc,0xfffd
        out (c),a
        ret
        
;Sample:
;256 masks (T,N,E,hole,outerenv,retrigtone, semitoneshiftpresent,tonefrqshiftpresent), одна из комбинаций означает loop (например, -1)
noisefrqpresent=1
envtypepresent=2
semitoneshiftpresent=6
tonefrqshiftpresent=7
;+-96 semitone shift (в потоке при наличии semitoneshiftpresent)
;+-96 env semitone shift (fair tone ratio guaranteed for 1:1, 3:4, 1:2, 1:4, 3:1, 5:2, 2:1, 3:2 + 4:1) (в потоке при наличии E)
;8*2 envtype + retrigenv (в потоке при наличии E)
;16 volume (в потоке при отсутствии E)
;+-4095 tonefrq shift (в потоке при наличии tonefrqshiftpresent)
;32 noisefrq (в потоке при наличии N)
;>1 >256 loop addrshift

playsample
        ld l,(ix+chn.smpcuraddr)
        ld h,(ix+chn.smpcuraddr+1)
;playsample_go
;ix=chn
;в любом случае полностью определяет текущие значения полей chn:
;masks   BYTE ;T,N,E,hole,outerenv,retrigtone, semitoneshiftpresent,tonefrqshiftpresent (должен быть первым байтом строки в потоке)
;envtype BYTE (в потоке при наличии E, значения 8..15 (15 как 4, 9 как 1) + retrigenv) ;или volume  BYTE ;volume = 0..15 (в потоке при отсутствии E)
;noisefrq BYTE ;noise = 0..31 (в потоке при наличии N)
    ;keepme  BYTE ;priority for keep on top (bigger is more priority)
    ;envfrq  WORD
    ;tonefrq WORD
        ld b,(hl) ;masks
        inc hl
        ld (ix+chn.masks),b ;masks   BYTE ;T,N,E,hole,outerenv,retrigtone, semitoneshiftpresent,tonefrqshiftpresent (должен быть первым байтом строки в потоке)
        ld a,(ix+chn.note_in)

        ;bit semitoneshiftpresent,b
        ;jr z,playsample_nosemitoneshift
        add a,(hl)
        inc hl
        jp po,playsample_nosemitoneshift ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
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
        ld (ix+chn.envfrq),c
        ld (ix+chn.envfrq+1),a;d
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
        ld a,(hl)
        inc hl
        ld (ix+chn.envtype),a ;envtype BYTE (в потоке при наличии E, значения 8..15 (15 как 4, 9 как 1) + retrigenvbit) ;тип огибающей без E не используется
        jr playsample_noenvsemitoneshiftq
playsample_noenvsemitoneshift
;count tone frq (use frq table)
        ld e,a
        ld d,tfrq/256
        ld a,(de)
        ld c,a
        inc d
        ld a,(de)
        ld d,a
        ld e,c ;de=tonefrq
        
         inc hl ;skip envsemitoneshift
        ld a,(hl)
        inc hl
         add a,(ix+chn.volume_in)
        ld (ix+chn.volume),a ;volume  BYTE ;volume = 0..15 ;громкость при E не используется
playsample_noenvsemitoneshiftq

        ;bit tonefrqshiftpresent,b
        ;jr z,playsample_notonefrqshift
        ld a,(hl)
        add a,e
        ld e,a
        inc hl
        ld a,(hl)
        adc a,d
        ld d,a ;correct tone frq
        inc hl
;playsample_notonefrqshift
        
        ;bit noisefrqpresent,b
        ;jr z,playsample_nonoisefrq
        ld a,(hl)
        inc hl
        ld (ix+chn.noisefrq),a ;noisefrq BYTE ;noise = 0..31 (в потоке при наличии N) ;noisefrq без N не используется
;playsample_nonoisefrq
        ld a,(ix+chn.keepme_in)
        ld (ix+chn.keepme),a ;keepme  BYTE ;priority for keep on top (bigger is more priority)

;out: hl=next line in sample
        ld a,(hl)
        inc a
        jr nz,playsample_noloop
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        add hl,bc
playsample_noloop
        ld (ix+chn.smpcuraddr),l
        ld (ix+chn.smpcuraddr+1),h

;накапливать глисс и прибавить его к tonefrq (в будущем считать глисс и пр. параметры от времени?)
        ld a,(ix+chn.curgliss)
        add a,(ix+chn.glissspeed_in)
        ld (ix+chn.curgliss),a
        ld l,a
        ld a,(ix+chn.curgliss+1)
        adc a,(ix+chn.glissspeed_in+1)
        ld (ix+chn.curgliss+1),a
        ld h,a
        sra h
        rr l
        sra h
        rr l
        sra h
        rr l ;+-12.3
        add hl,de
        ld (ix+chn.tonefrq),l
        ld (ix+chn.tonefrq+1),h

        ;ld de,0x03ef
        ;or a
        ;sbc hl,de
        ;jr z,$

        ret

shutay
        ld de,0x0e00
shutay0
        dec d
        ld bc,0xfffd
        out (c),d
        ld b,0xbf
        out (c),e
        jr nz,shutay0
        ret
