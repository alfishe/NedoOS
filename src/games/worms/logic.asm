;вместо dy могут стоять значения:
SPRLIST_STAYING=99 ;мёртвый (xhigh=INVISIBLEX) или уже впечатанный в карту, не обрабатывается логикой
SPRLIST_END=100 ;в конце списка ещё spritehsb=1!
SPRLIST_PRINTED=101
SPRLIST_IMPOSSIBLE=102

;в каких регистрах хранить данные при обработке:
;lc=x16 ;XXXXXXXX XXx????? (могут быть проблемы с точностью X при скольжении)
;e=dx8 ;sXXXXXXx (не более +-4)
;h=y8
;d=dy8
;c=phase5 (в физике используются только первые несколько фаз)

NEWREGS=0 ;TODO de=x16 (00XXXXXX XXXXxxxx), l=y8, h=dy8, b=dx8 (sXXXxxxx); c=phase (>600*2 фаз не влезет! придётся использовать поле dx8 (или ст. биты h и мл. биты l?) у стоячих червей)

;фазы (черви и мины отличаются регистром B - а у зафиксированных червей больше допустимых комбинаций BC):
;0 - стоим (TODO 8 в другую сторону)
;TODO 1 - скользим (TODO 9 в другую сторону)
;TODO 2..7 - втыкаемся и вылезаем (TODO 10..15 в другую сторону)
;16..23 - крутимся (TODO 24..31 в другую сторону) - или стоим/крутимся/сторона - это разные B? тогда всего 3 бита на фазу и 3 на xxx?


;CHECKMASK не должна портить эти регистры!
;ADDCOORDS не должна портить dx,dy!

        macro GETCOORDS
       if 1
        ld c,(hl)
        inc l
        ld b,(hl)
        inc l
       push hl
        ld e,(hl)
        inc l
        ld d,(hl)
        inc l
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex de,hl
       else
        POP BC ;SPRITE
        POP HL ;COORDS
        POP DE ;SPEED
       endif
        endm

        macro REGETCOORDS
       if 1 ;TODO NEWREGS
       pop hl
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
       else
        DUP 4
        DEC SP
        EDUP 
        POP HL ;OLD COORDS
        pop af ;POP DE ;OLD SPEED
       endif
        endm

        macro PUTCOORDS
       if 1
       ex (sp),hl
        dec l
        dec l
        ld (hl),c
        inc l
        ld (hl),b
        inc l
       pop bc
        ld (hl),c
        inc l
        ld (hl),b
        inc l
        ld (hl),e
        inc l
        ld (hl),d
        inc l
       else
        PUSH de
        PUSH hl
        PUSH BC
        DUP 3
        POP BC
        EDUP 
       endif
        endm

        macro ADDCOORDS
       if NEWREGS
        ld a,l ;dx
        or a
        jp p,$+4 ;a>=0
;a<0,C: значит e>|a|, т.е. фактически нет переноса
        dec d ;a<0,NC: d-- (иначе будет компенсирующий инкремент) ;+20
        add a,e
        jr nc,$+3
        inc d ;a>=0,C: d++ (или a<0,C: компенсирующий инкремент) ;+15.5
        ld e,a
        ld a,h ;dy
        add a,l ;y
        ld l,a ;y                                                ;+16 = 51.5t (можно x=de, так проще CHECKMASK)
       else
         ld lx,e
        XOR A
        SRA E
        RRA 
        SRA E
        RRA 
         sra e
         rra
        ADD A,C ;xlow, phase
        ADC HL,DE ;y,xhigh
         ld c,a ;xlow, phase
         ld e,lx
       endif
        endm

        macro NEGDX
        XOR A
       if NEWREGS
        sub b ;dx
        ld b,a
       else
        SUB E
        LD E,A
       endif
        endm

        macro NEGDY
        XOR A
       if NEWREGS
        sub h ;dy
        ld h,a
       else
        SUB D
        LD D,A
       endif
        endm

        macro CHECKMASK
       if NEWREGS
;l=y, de=x (00XXXXXX XXXXxxxx) (ст. биты X использовать только для разных фаз стоячих червей)
        push hl
         ld a,d ;xhigh>>2
         ld h,TMASKLN/256
         add a,(hl)
         inc h
         ld h,(hl)
         ld l,a
        jr nc,$+3
        inc h
         ld a,(hl) ;mask byte
         ld l,e ;xlow>>2
         ld h,TABROLL/256
         and (hl) ;bit(x)
        pop hl
       else
;l=xhigh, c=xlow (XXXXXXXX XXx?????), h=y
        push hl
         ld a,c ;xlow
         srl l
         rra
         srl l
         rra
         ex af,af' ;' ;xlow>>2
        ld a,l ;xhigh>>2
        LD L,h ;y
        LD H,TMASKLN/256
        ADD A,(HL)
        INC H
        LD H,(HL)
        LD L,A
       JR NC,$+3
       INC H
         ex af,af' ;' ;xlow>>2
         LD h,(HL) ;mask byte
         ld l,a ;xlow>>2
         ld a,h ;mask byte
         LD H,TABROLL/256
         AND (HL) ;bit(x)
        pop hl
       endif
        endm
        
        macro CHECKX deadaddr
       if NEWREGS
        ld a,d ;x HSB
       else
        LD A,L ;x HSB
       endif
        CP XWID
        JP NC,deadaddr;WMDEAD
        endm

WRMOVEQ
       pop hl
        RET 
WRMOVE
        ld hl,WORMXY
       call SetPgMask
DOGRAVa=$+1
        LD A,0
        ADD A,64
        LD (DOGRAVa),A
        SBC A,A
        and 20 ;"inc d"
        LD (WMGRAV_patch),A
WM0
        GETCOORDS
       ld a,d ;dy
       cp SPRLIST_PRINTED
       jp z,NEWSPD_nogravity;WM0 ;стоячий червь (уже напечатанный) или пустышка
       cp SPRLIST_END
       jr z,WRMOVEQ ;конец списка
       cp SPRLIST_STAYING
       jp z,NEWSPD_nogravity;WM0 ;стоячий червь или пустышка
        ADDCOORDS
        BIT 7,D
        jp NZ,WMGOUP
        JP C,WMDEAD
;движение вниз
        CHECKX WMDEAD
        CHECKMASK
        JP Z,NEWSPD ;проходимо, выходим с новыми координатами
        REGETCOORDS
        NEGDX ;непроходимо, делаем dx=-dx
        ADDCOORDS
        JP C,WMDEAD
        CHECKX WMDEAD
        CHECKMASK
        JP Z,NEWSPD_rotate ;проходимо, выходим с новыми координатами
;с dx=-dx тоже непроходимо
         REGETCOORDS
        DEC d ;делаем dy=1 или останавливаем, если уже dy=1
        LD de,256
        jp nz,NEWSPD_nogravity
        ld a,c
        and 7
        jp nz,NEWSPD_nogravity;nostoprot
        ld a,c
        and 0xe0
        ;or 0;16
        ld c,a
;nostoprot
        LD de,SPRLIST_STAYING*256 ;когда напечатается, будет e!=0
       jp NEWSPD_nogravity
WMGOUP
;движение вверх
        jp NC,WMDEAD
        CHECKX WMDEAD
        CHECKMASK
        JP Z,NEWSPD ;проходимо, выходим с новыми координатами
        REGETCOORDS
        NEGDX ;непроходимо, делаем dx=-dx
        ADDCOORDS
        jp NC,WMDEAD
        CHECKX WMDEAD
        CHECKMASK
        JP Z,NEWSPD ;проходимо, выходим с новыми координатами
        REGETCOORDS
         NEGDX ;dx как было
        ld d,0;NEGDY ;непроходимо, делаем dy=-dy (отскочили от потолка)
        ADDCOORDS
        ;JR  C,WMDEAD
        CHECKX WMDEAD
        CHECKMASK
        JR Z,NEWSPD_rotate ;проходимо, выходим с новыми координатами
        REGETCOORDS
        LD de,0 ;с dy=-dy тоже непроходимо, делаем dx=0, dy=0
        ;JR NEWSPDgode
NEWSPD
WMGRAV_patch=$
        INC d ;/nop ;dy
NEWSPD_nogravity
       bit 4,c
       jr z,NEWSPD_skiprot
        ld a,c
        inc a
        xor c
        and 7
        xor c
        ld c,a
NEWSPD_skiprot
        PUTCOORDS
        JP WM0

NEWSPD_rotate
        ld a,c
        and 0xe0
        or 16
        ld c,a
       ;set 4,c
        jp NEWSPD

WMDEAD
      if 1
      pop hl
      push hl
       ld a,l
       add a,4
       ld l,a
      else
        ld hl,0
        add hl,sp
        LD (WMsp),HL
       ld d,SPRLIST_STAYING ;don't move
       push de
       ld e,INVISIBLEX ;invisible x
       push de 
       ;ld a,-1
       ;push af ;пустышка
      endif
       ld a,b
       cp sprmine_0/256
       jp z,WMDEAD_noworm
        ld h,0
        add hl,hl
        LD DE,NAMES
        ADD HL,DE ;name+12
      if 1
      else
        LD SP,iy
      endif
        CALL MTIDEAD
WMDEAD_noworm
      if 1
       ld d,SPRLIST_STAYING ;don't move
       ld l,INVISIBLEX ;invisible x
       jp NEWSPD_nogravity
      else
WMsp=$+1
        LD SP,0
       JP WM0
      endif

ControlCurWorm ;в это время logic вызывать не надо
        ret

WormsVsMines
        ret

StayingWormsVsMovingWorms ;столкновение летящего со стоящим
        ret
       
CheckFlyingWorms
;проверить, есть ли живые не стоящие (логика не дожна зависеть от разницы STAYING/PRINTED!)
;z=нету
        ld hl,WORMXY
CheckFlyingWorms0
        ;POP BC ;SPRITE (lsb=xlow*64;32)
        ;POP HL ;COORDS
        ;POP DE ;SPEED
        inc l
        inc l
        ld a,(hl) ;xhigh
        inc l
        inc l
        inc l
       cp XWID
       jr nc,CheckFlyingWorms_skip
        ld a,(hl) ;dy
        cp SPRLIST_END
        ret z
        cp SPRLIST_PRINTED
        jr z,CheckFlyingWorms_skip
        cp SPRLIST_STAYING
        ret nz
CheckFlyingWorms_skip
        inc l
        jr CheckFlyingWorms0
