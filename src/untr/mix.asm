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

filtertone
;ix=from=to
;de=tone shift (+-4095)
        ld a,(ix+chnout.tonefrq)
        add a,e
        ld e,a
        ld a,(ix+chnout.tonefrq+1)
        adc a,d
        ld d,a
        jp p,$+6
         ld de,0
        ld (ix+chnout.tonefrq),e
        ld (ix+chnout.tonefrq+1),d
        ret

filterenv
;ix=from=to
;de=env shift
        ld a,(ix+chnout.envfrq)
        add a,e
        ld e,a
        ld a,(ix+chnout.envfrq+1)
        adc a,d
        ld d,a
        jp p,$+6
         ld de,0
        ld (ix+chnout.envfrq),e
        ld (ix+chnout.envfrq+1),d
        ret

mixchn
;ix=from1=to
;iy=from2
;в release должен быть понижен приоритет канала
;если в from1 есть огибающая, то игнорируем from1, если его KEEPME <= чем у from2
;т.к. огибающую должен перекрывать тональник!!!
        ;bit MASKBIT_E,(ix+chnout.masks)
        ;jr nz,mixchn_keep2
;если в from1 есть шум, то игнорируем from2, если его KEEPME <= чем у from1
        ;bit MASKBIT_N,(ix+chnout.masks)
        ;jr nz,mixchn_keep1
;если в from2 дырка, то берём from1
        bit MASKBIT_HOLE,(iy+chnout.masks)
        ret nz;jr nz,mixchn_keep1_ok
;если в from1 дырка, то берём from2
        bit MASKBIT_HOLE,(ix+chnout.masks)
        jr nz,mixchn_keep2_ok
;берём самый громкий по тональнику
;TODO низкие ноты не считать громкими
        ld a,(iy+chnout.volume)
        add a,(iy+chnout.keepme)
        add a,0x80
        ld e,a
        ld a,(ix+chnout.volume)
        add a,(ix+chnout.keepme)
        add a,0x80
        cp e
        jr c,mixchn_keep2_ok
mixchn_keep1
        ;ld a,(ix+chnout.keepme)
        ;cp (iy+chnout.keepme)
        ;ret nc ;при равенстве keepme оставляем from1
        ;jr c,mixchn_keep2_ok
        bit MASKBIT_OUTERENV,(iy+chnout.masks)
        jr nz,mixchn_keep2outerenv
        ret
mixchn_keep2
        ;ld a,(iy+chnout.keepme)
        ;cp (ix+chnout.keepme)
        ;jr c,mixchn_keep1 ;при равенстве keepme оставляем from2
        bit MASKBIT_OUTERENV,(iy+chnout.masks)
        jr nz,mixchn_keep1outerenv
mixchn_keep2_ok
        push iy
        pop hl
        push ix
        pop de
        ld bc,chnout.note_in;chnout
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
        ld bc,chnout.note_in;chnout
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
        ld bc,0x00ff ;b=ретриггеры A,B,C ;c=masks: все выключены
        ld d,b ;текущий приоритет шума
        ld e,b ;текущий приоритет огибающей
        ld h,(iy+chip.envtype) ;бывший тип огибающей
        res retrigenvbit,h

        xor a
        bit MASKBIT_HOLE,(ix+chnout.masks)
        jr nz,rendchip_Anoenv
        ld a,(ix+chnout.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,rendchip_Anoenv
        ld e,(ix+chnout.keepme) ;текущий приоритет огибающей
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chnout.envtype) ;текущий тип огибающей
        ld a,16
rendchip_Anoenv
        ld (iy+chip.Avolume),a
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Anotone
        dec c ;res 0,c
        ld a,(ix+chnout.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Atonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Atonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chnout.masks)
        jr z,$+3
        inc b ;set 0,b сумма ретриггеров
rendchip_Anotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Anonoise
        res 3,c
        ld d,(ix+chnout.keepme) ;текущий приоритет шума
        ld a,(ix+chnout.noisefrq)
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
        bit MASKBIT_HOLE,(ix+chnout.masks)
        jr nz,rendchip_Bnoenv
        ld a,(ix+chnout.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,rendchip_Bnoenv
        ld a,(ix+chnout.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Buseenv
        ld e,a
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chnout.envtype) ;текущий тип огибающей
rendchip_Buseenv
        ld a,16
rendchip_Bnoenv
        ld (iy+chip.Bvolume),a
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Bnotone
        res 1,c
        ld a,(ix+chnout.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Btonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Btonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chnout.masks)
        jr z,$+4
         set 1,b ;сумма ретриггеров
rendchip_Bnotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Bnonoise
        res 4,c
        ld a,(ix+chnout.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Bnonoise
        ld d,a
        ld a,(ix+chnout.noisefrq)
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
        bit MASKBIT_HOLE,(ix+chnout.masks)
        jr nz,rendchip_Cnoenv
        ld a,(ix+chnout.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,rendchip_Cnoenv
        ld a,(ix+chnout.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Cuseenv
        ;ld e,a
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chnout.envtype) ;текущий тип огибающей
rendchip_Cuseenv
        ld a,16
rendchip_Cnoenv
        ld (iy+chip.Cvolume),a
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Cnotone
        res 2,c
        ld a,(ix+chnout.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Ctonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Ctonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chnout.masks)
        jr z,$+4
         set 2,b ;сумма ретриггеров
rendchip_Cnotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Cnonoise
        res 5,c
        ld a,(ix+chnout.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Cnonoise
        ;ld d,a
        ld a,(ix+chnout.noisefrq)
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
        ret z
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
        ld l,(ix+chnout.smpcuraddr)
        ld h,(ix+chnout.smpcuraddr+1)
        jr playsample_go
playsample_loop
        ld e,(hl)
        inc hl
        ld d,(hl)
        add hl,de
playsample_go
;ix=chnout
;в любом случае полностью определяет текущие значения полей chnout:
;masks   BYTE ;T,N,E,hole,outerenv,retrigtone, semitoneshiftpresent,tonefrqshiftpresent (должен быть первым байтом строки в потоке)
;envtype BYTE (в потоке при наличии E, значения 8..15 (15 как 4, 9 как 1) + retrigenv)
;volume  BYTE ;volume = 0..15 (в потоке при отсутствии E)
;noisefrq BYTE ;noise = 0..31 (в потоке при наличии N)
;keepme  BYTE ;priority for keep on top (bigger is more priority)
;envfrq  WORD
;tonefrq WORD
        ld b,(hl) ;masks
        inc hl
        inc b
        jr z,playsample_loop
        dec b
        ld (ix+chnout.masks),b ;masks   BYTE ;T,N,E,hole,outerenv,retrigtone, semitoneshiftpresent,tonefrqshiftpresent (должен быть первым байтом строки в потоке)
        ld a,(ix+chnout.note_in)

        bit semitoneshiftpresent,b
        jr z,playsample_nosemitoneshift
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
        ld a,(hl)
        inc hl
        ld (ix+chnout.envtype),a ;envtype BYTE (в потоке при наличии E, значения 8..15 (15 как 4, 9 как 1) + retrigenvbit) ;тип огибающей без E не используется
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
        ld a,(hl)
        inc hl
        ld (ix+chnout.volume),a ;volume  BYTE ;volume = 0..15 ;громкость при E не используется
playsample_noenvsemitoneshiftq

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
        
        bit noisefrqpresent,b
        jr z,playsample_nonoisefrq
        ld a,(hl)
        inc hl
        ld (ix+chnout.noisefrq),a ;noisefrq BYTE ;noise = 0..31 (в потоке при наличии N) ;noisefrq без N не используется
playsample_nonoisefrq
        ld a,(ix+chnout.keepme_in)
        ld (ix+chnout.keepme),a ;keepme  BYTE ;priority for keep on top (bigger is more priority)

;out: hl=next line in sample
        ld (ix+chnout.smpcuraddr),l
        ld (ix+chnout.smpcuraddr+1),h
        ret

