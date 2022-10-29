playtext
playwait=$+1
        ld a,1
        dec a
        jr nz,playsetwait
cursampleaddr=$+1
        ld hl,snd_empty
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld (cursampleaddr),hl
curvowellength=$+1
        ld a,6
        dec c ;1: wait after vowel with current sound
        jr z,setwait_playnextletter ;эта процедура обязана установить валидный cursampleaddr
        inc c ;0: end of sample
        jr z,playnextletter ;эта процедура обязана установить валидный cursampleaddr
        call decodesampleframe
        jp playsound

playsetwait
        ld (playwait),a
        ret

playtonedigit
        sub '0'
        ld l,a
        ld h,0
        add hl,hl
        ld bc,tnotes
        add hl,bc
        ld (curnote),hl
        jr playnextletter
playincvowel
        inc (hl)
        inc (hl)
playdecvowel
        dec (hl)
        jr playnextletter
playlonger
        ld a,2+1
setwait_playnextletter ;эта процедура обязана установить валидный cursampleaddr
        ld (playwait),a
playnextletter ;эта процедура обязана установить валидный cursampleaddr
playtextaddr=$+1
        ld hl,0
        ld a,(hl)
        or a
         jr nz,$+2+3+1
          ld hl,playtextloop
          ld a,(hl)
        inc hl
        ld (playtextaddr),hl
         cp ':'
         jr z,playlonger ;wait 2 frames with current sound
         ld hl,curvowellength
         cp '+'
         jr z,playincvowel
         cp '-'
         jr z,playdecvowel
         cp ' '
         jr nz,$+4
         ld a,'_'
         cp '0'+10
         jr c,playtonedigit
        sub 64
        ld l,a
        ld h,0
        add hl,hl
        ld bc,tsounds
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl) ;bc=sample
        ld (cursampleaddr),bc
        ret

decodesampleframe
;структура фрейма сэмпла (0=конец сэмпла? 1=зацикливание на прошлый фрейм?):
 ;c=
;1: noiseoff
;1: tonedivon (иначе работает tonefreq)
;1: toneoff
;1: envon (иначе работает vol)
;4: vol (4 bit, 0 != отключение) или envslow (1 bit) + envtype (3 bit) (envslow также отвечает за быстро/медленно для envtype=9))
 ;b=
;3: tonediv (2+1 bit, всего 4 варианта используется) или tonefreq (12 bit? реально пока используется только =0)
;5: noise (5 bit)
curnote=$+1
        ld hl,tnotes+(4*2)
        bit 5,b
        jr z,$+3
         inc hl ;там *4/3
        ld e,(hl)
        ld d,0 ;de=base envfreq
        ld a,b ;noise freq
        ex af,af' ;'
        ld lx,c ;envon+vol
        ld a,b
        rlca
        rlca
        and 3
        add a,2
        ld b,a ;b=shift left ;2..5
        ld l,e
        ld h,d
tonefromenv0
        add hl,hl
        djnz tonefromenv0
         inc hl ;разлив
        bit 6,c ;tonedivon
        jr nz,notonefreq
         ld l,d;0
notonefreq
        ld a,c
        and 7
        add a,8
        ld hx,a ;envtype
         cp 9 ;удар
        jr nz,noenvfreq
         ld de,300 ;?
noenvfreq
        ld a,c ;N?T?????
        rlca   ;?T?????N
        rla
        rla    ;?????N?? CY=T
        rla
        rla    ;???N??T?
         and 0x3f ;all ports IN
         or 0b00101101 ;TODO mix with current mixer value
         ;ld a,0b00101101 ;TN
         ;ld a,0b00111101 ;T-
         ;ld a,0b00101111 ;-N
        bit 3,c
        ret z;jr z,noenvslow
         sla e
         rl d ;на октаву вниз или быстро/медленно для удара
;noenvslow
;de=envfreq
;hl=tonefreq
;hx=env type
;lx=volume
;a=mixer
;a'=noise freq
        ret


;i: --E 0028                                ;u: T-E 0028 (D-3)      
                      ;e: T-E 0028 (G-3)
                      ;a: --C 0050 (D-4)    ;O: T-- (D-2) (vol f)
;E: T-C 0050 (D-4)    ;A: T-E 0028 (D-4)

;N: --E 0050 (тихая) (1-2 frames)
;M: T-E 0028 (G-3) (1-2 frames)
;L: ??? тембр как u?O? (можно тише)
;l: --E 0028 (1 frame)??? тембр как i (можно тише)

;RR: (T-E --E) 0028 (D-4)

;s: noise=00
;S: noise=03
;c: noise=08
;C: noise=0b
;f: noise=11
;F: noise=13 (vol 8,9)
;x: noise=1d
;X: noise=1f

;T: noise=05 (vol 7,2)
;P: noise=11? (vol 7,2?)
;K: noise=1f? (vol f,c?)

;B: T-- (D-2) (vol f,e)??? тембр как O

;TS: noise=2,1 (vol d,b)

playsound
;hl=freq
;de=env freq
;hx=env type
;lx=volume
;a=mixer
;a'=noise freq
        exx
        ld bc,0xfffd
        ld de,0x0902 ;d=B volume, e=B freq
        out (c),e
        exx
        ld bc,0xbffd
        out (c),l       
        exx
        inc e ;B freq HSB
        out (c),e
        exx
        out (c),h
       
        exx
        ld e,7 ;mixer
        out (c),e
        exx
        out (c),a
        exx
        dec e;ld e,6 ;noise freq
        out (c),e
        exx
        ex af,af' ;' ;ld a,hy
        out (c),a

        exx
        ;ld d,0x09 ;B volume
        out (c),d ;B volume
        exx
        ld a,lx
        out (c),a
        
        exx
        ld e,0x0b ;env freq
        out (c),e
        exx
        out (c),e
        exx
        inc e ;env freq HSB
        out (c),e
        exx
        out (c),d
        
        ld a,hx
        cp 9 ;удар
        jr z,nocheckcurenv
curenv=$+1
        cp 0
        ret z
nocheckcurenv
        ld (curenv),a
        exx
        inc e ;ld e,0x0d ;env type
        out (c),e
        exx
        out (c),a
        ret

;D-2 = 0x6b0 = 1712 (32*4:3)
;D-3 = 0x358 = 856 (16*4:3)
;G-3 = 0x27c = 636 (16:1)
;D-4 = 0x1ac = 428 (8*4:3)

;Ноты огибающей (0028 = 4-й тон перечисления, 1-й тон назовём 0, чтобы вклинить ноту ре на всякий случай):
;0: C-3 = 0x003c = 59.875 (от деления 0xef8=3832)
;1: D-3 = 0x0035 = 53.3
;2: D#3 = 0x0032 = 50.3
;3: F-3 = 0x002c = 44.8
;4: G-3 = 0x0028 = 40.0
;5: ...
;из них вычисляются ноты тона (сдвиг влево на N, возможное деление на 3, прибавление разлива)
;но тон может быть задан явно (для тихой огибающей), огибающая тоже? (для удара)

;TODO или все ноты в 2 октавах, чтобы могло петь?

        macro DWNOTE t
        db t
        db (t)*4/3
        endm

;TODO *2 для точности расчёта 4/3?
tnotes
        DWNOTE 60 ;0: C
        DWNOTE 53 ;1: D
        DWNOTE 50 ;2: D#
        DWNOTE 45 ;3: F
        DWNOTE 40 ;4: G
        DWNOTE 38 ;5: G#
        DWNOTE 36 ;6: A
        DWNOTE 32 ;7: H
        DWNOTE 30 ;8: c
        DWNOTE 27 ;9: d

;описатель фонемы - просто указатель на сэмпл
;тоны и спецсимволы проверять вручную перед этим
;если потом выяснится, что они все по 2 фрейма или 1+вечный повтор, то можно внести сэмпл (2*2 байта) прямо в описатель

tsounds
        dw snd_schwa
        dw snd_A
        dw snd_B
        dw snd_C
        dw snd_D
        dw snd_E
        dw snd_F
        dw snd_G
        dw snd_H
        dw snd_I
        dw snd_J
        dw snd_K
        dw snd_L
        dw snd_M
        dw snd_N
        dw snd_O
        dw snd_P
        dw snd_Q
        dw snd_R
        dw snd_S
        dw snd_T
        dw snd_U
        dw snd_V
        dw snd_W
        dw snd_X
        dw snd_Y
        dw snd_Z
        dw snd_pause
        dw snd_pause
        dw snd_pause
        dw snd_ishort
        dw snd_pause

        dw snd_backtick
        dw snd_a
        dw snd_b
        dw snd_c
        dw snd_d
        dw snd_e
        dw snd_f
        dw snd_g
        dw snd_h
        dw snd_i
        dw snd_j
        dw snd_k
        dw snd_l
        dw snd_m
        dw snd_n
        dw snd_o
        dw snd_p
        dw snd_q
        dw snd_r
        dw snd_s
        dw snd_t
        dw snd_u
        dw snd_v
        dw snd_w
        dw snd_x
        dw snd_y
        dw snd_z
        dw snd_pause
        dw snd_hole
        dw snd_pause
        dw snd_pause
        dw snd_pause

snd_r ;TODO r - одно колебание
snd_R ;RR: (T-E --E) 0028 (D-4) (8*4:3)
        db 0b11110110, 0b01100000
        db 0b11010110, 0b01100000+16
        ;db 0b11000110, 0b01100000
        ;db 0b11100110, 0b01100000
        ;db 0b11000110, 0b01100000
        db 0

snd_Y ;TODO Й в начале слога, английское /j/
snd_y ;Й в конце слога (дольше, чем ', но не имеет длительности гласной)
        db 0b11110110, 0b00000000
        db 0b11110110, 0b00000000
        db 0
snd_I ;не получается мягче, чем i
snd_i ;i: --E 0028
        db 0b11110110, 0b00000000
        db 1

snd_E ;E: T-C 0050 (D-4) (8*4:3)
        db 0b11011100, 0b01100000
        db 1

snd_ishort ;shoft for diphthongs
        db 0b11110110, 0b00000000
        db 0

snd_backtick ;untested
        db 0b01000000+15, 0b00000000
        db 0

snd_schwa ;1 фрейм для начала Ы
        db 0b11010110, 0b10000000
        db 0

snd_e ;e: T-E 0028 (G-3) (16:1)
        db 0b11010110, 0b10000000
        db 1

snd_A ;A: T-E 0028 (D-4) (8*4:3)
        db 0b11010110, 0b01100000
        db 1

snd_o
snd_O ;O: T-- (D-2) (vol f) (32*4:3)
        db 0b11000000+15, 0b11100000
        db 1

snd_W
        db 0b11010110, 0b10100000
        db 0b11010110, 0b10100000
        db 0
snd_w ;shoft for diphthongs
        db 0b11010110, 0b10100000
        db 0
snd_U
snd_u ;u: T-E 0028 (D-3) (16*4:3)
        db 0b11010110, 0b10100000
        db 1

snd_a ;a: --C 0050 (Э, предударное А)
        db 0b11111100, 0b00000000
        db 1

snd_p ;TODO p - губно-зубной взрывной
snd_P
        db 0b11011001, 0b11100000+13
        ;db 0b01100000+10, 0b00000000+3
        db 0

snd_T ;T: noise=05 (vol 7,2)
        ;db 0b01100000+8, 0b00000000+5
        db 0b01110001, 0b00000000+3;5
        ;db 0b01100000+2, 0b00000000+5
        db 0
snd_t ;untested ;TS: noise=2,1 (vol d,b) ;TODO t - боковой глухой взрывной звук
        db 0b01111001, 0b00000000+0
        ;db 0b01100000+10, 0b00000000+0
        db 0b01100000+8, 0b00000000+0
        db 0

snd_K ;K: noise=31? (vol 7,2?)
        db 0b01110001, 0b00000000+31
        ;db 0b01100000+2, 0b00000000+31
        db 0
snd_k
        db 0b01111001, 0b00000000+29
        ;db 0b01100000+9, 0b00000000+29
        ;db 0b01100000+4, 0b00000000+29
        db 0

snd_Q ;q - взрывной глухой звук спинкой языка ;untested
        db 0b01100000+7, 0b00000000+11
        db 0b01100000+2, 0b00000000+11
        db 0
snd_q ;q - взрывной звонкий звук спинкой языка ;untested
        db 0b01110110, 0b00000000+11
        db 0b01110110, 0b00000000+11
        db 0

;B: T-- (D-2) (vol f,e)??? тембр как O
snd_B
snd_b
        db 0b11000000+15, 0b11100000
        ;db 0b11000000+13, 0b11100000
        db 0

snd_D
        db 0b11000000+15, 0b10100000
        ;db 0b11000000+13, 0b10100000
        db 0
snd_d ;untested
        db 0b11000000+15, 0b10100000
        db 0b01000000+13, 0b10100000+3
        ;db 0b01110100, 0b00000000+0
        db 0

snd_G ;untested
        db 0b11000000+15, 0b10100000
        db 0b01010100, 0b00000000+31
        db 0
snd_g ;untested
        db 0b01010100, 0b00000000+29
        db 0b01010100, 0b00000000+29
        db 0

snd_V ;v: -NC 0028?
        db 0b01110100, 0b00000000+19
        db 0b01110100, 0b00000000+19
        db 0
snd_v ;v: -NC 0028?
        db 0b01110100, 0b00000000+17
        db 0b01110100, 0b00000000+17
        db 0

snd_Z ;untested
        db 0b01110100, 0b00000000+3
        db 0b01110100, 0b00000000+3
        db 0
snd_z ;untested
        db 0b01110100, 0b00000000+0
        db 0b01110100, 0b00000000+0
        db 0

snd_J ;untested Ж
        db 0b01110100, 0b00000000+11
        db 0b01110100, 0b00000000+11
        db 0
snd_j ;untested Ж'
        db 0b01110100, 0b00000000+8
        db 0b01110100, 0b00000000+8
        db 0

snd_F ;F: noise=13 (vol=8,9?)
        db 0b01100000+8, 0b00000000+19
        db 0b01100000+9, 0b00000000+19
        db 0
snd_f ;f: noise=11 (vol=8,9?)
        db 0b01100000+8, 0b00000000+17
        db 0b01100000+9, 0b00000000+17
        db 0

snd_S ;S: noise=03 (vol=8,9?)
        db 0b01100000+8, 0b00000000+3
        db 0b01100000+9, 0b00000000+3
        db 0
snd_s ;s: noise=00 (vol=8,9?)
        db 0b01100000+8, 0b00000000+0
        db 0b01100000+9, 0b00000000+0
        db 0

snd_C ;С: noise=0b (vol=8,9?) Ш
        db 0b01100000+8, 0b00000000+11
        db 0b01100000+9, 0b00000000+11
        db 0
snd_c ;с: noise=08 (vol=8,9?) Щ
        db 0b01100000+8, 0b00000000+8
        db 0b01100000+9, 0b00000000+8
        db 0

snd_H
snd_X ;X: noise=1f (vol=8,9?)
        db 0b01100000+8, 0b00000000+31
        db 0b01100000+9, 0b00000000+31
        db 0
snd_h
snd_x ;x: noise=1d (vol=8,9?)
        db 0b01100000+8, 0b00000000+29
        db 0b01100000+9, 0b00000000+29
        db 0

snd_n
snd_N ;N: --E 0050 (тихая) (1-2 frames)
        db 0b10011110, 0b00000000
        db 0b10011110, 0b00000000
        db 0

snd_m ;TODO m - губно-зубной
snd_M ;M: T-E 0028 (G-3) (1-2 frames)??? тембр как u
        db 0b11010110, 0b10100000
        db 0b11010110, 0b10100000
        db 0

snd_L ;L: ??? тембр как u?O? (можно тише)
        db 0b11000000+13, 0b11100000
        db 0b11000000+13, 0b11100000
        db 0
snd_l ;l: --E 0028 (1 frame)??? тембр как i (можно тише)
        db 0b10010110, 0b00000000
        db 0b10010110, 0b00000000
        db 0

snd_hole ;закрытие перед взрывным
        db 0b11000000+0, 0b00000000+0
snd_empty
        db 0

snd_pause ;pause
        db 0b11000000+0, 0b00000000+0
        db 1
