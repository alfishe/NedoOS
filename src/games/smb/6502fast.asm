;"a"=a
;"x"=c (b=0)
;"y"=e (d=0)

        macro checka
        inc a
        dec a
        endm

        macro checkx
        inc c
        dec c
        endm

        macro checky
        inc e
        dec e
        endm

        macro sei ;ei
        endm

        macro cld ;clear decimal mode
        endm

        macro txs ;set stack pointer = x
        endm

        macro beq addr
        jp z,addr
        endm
        
        macro bne addr
        jp nz,addr
        endm
        
        macro bcs addr
        jp c,addr
        endm
        
        macro bcc addr
        jp nc,addr
        endm
        
        macro bmi addr
        jp m,addr
        endm

        macro bpl addr
        jp p,addr
        endm
        
        macro jsr addr
        call addr
        endm

        macro jmp addr
        jp addr
        endm
        
        macro jmpindirect addr
        ld hl,(addr)
        jp (hl)
        endm
        
        macro rts
        ret
        endm
        
        macro rti ;return from interrupt
        ret
        endm
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        macro sec
        scf
        endm
        
        macro secsub ;перенос в вычитании инверсный
        or a
        endm
        
        macro cmpcy ;перенос после сравнения инверсный
        ccf
        endm
        
        macro clc ;сохраняет Z как минимум в chkjumpstringmetatiles
        scf
        ccf
        endm
        
        macro lsr
        srl a ;set Z,N,CY
        endm

        macro ror
        rr a ;set Z,N,CY
        endm
        
        macro rol
        rl a ;set Z,N,CY
        endm
        
        macro asl
        add a,a ;set Z,N,CY
        endm
        
        macro lsri addr
        ld hl,addr
        srl (hl)
        endm
        
        macro rori addr
        ld hl,addr
        rr (hl)
        endm
        
        macro roli addr
        ld hl,addr
        rl (hl)
        endm
        
        macro asli addr
        ld hl,addr
        sla (hl)
        endm
        
        macro rorx shift,x
        push af
        ld hl,shift
        add hl,bc
        pop af
        rr (hl)
        endm

        macro rolx shift,x
        push af
        ld hl,shift
        add hl,bc
        pop af
        rl (hl)
        endm

        macro oran value ;TODO don't spoil CY
        or value
        endm
        
        macro eorn value ;TODO don't spoil CY
        xor value
        endm
        
        macro andn value ;TODO don't spoil CY
        and value
        endm
        
        macro orax shift,x
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        or (hl) ;TODO don't spoil CY
        endm

        macro oray shift,y
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        or (hl) ;TODO don't spoil CY
        endm

        macro eorx shift,x
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        xor (hl) ;TODO don't spoil CY
        endm

        macro eory shift,y
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        xor (hl) ;TODO don't spoil CY
        endm

        macro andx shift,x
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        and (hl) ;TODO don't spoil CY
        endm

        macro andy shift,y
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        and (hl) ;TODO don't spoil CY
        endm

        macro orai addr ;TODO don't spoil CY
        ld hl,addr
        or (hl)
        endm
        
        macro eori addr ;TODO don't spoil CY
        ld hl,addr
        xor (hl)
        endm
        
        macro andi addr ;TODO don't spoil CY
        ld hl,addr
        and (hl)
        endm
        
        macro biti addr ;TODO don't spoil CY
        ld hl,(addr)
        ld h,a
        and l
        ld a,h
        endm
        
        macro adcn value
        adc a,value
        endm
        
        macro sbcn value
        sbc a,value
        endm
        
        macro adci addr
        ld hl,addr
        adc a,(hl)
        endm
        
        macro sbci addr
        ld hl,addr
        sbc a,(hl)
        endm
        
        macro adcx shift,x
        push af
        ld hl,shift
        add hl,bc
        pop af
        adc a,(hl)
        endm

        macro sbcx shift,x
        push af
        ld hl,shift
        add hl,bc
        pop af
        sbc a,(hl)
        endm

        macro adcy shift,y
        push af
        ld hl,shift
        add hl,de
        pop af
        adc a,(hl)
        endm

        macro sbcy shift,y
        push af
        ld hl,shift
        add hl,de
        pop af
        sbc a,(hl)
        endm

        macro cmpn value
        cp value
        endm

        macro cpxn value
        ld l,a
        ld a,c
        cp value
        ld a,l
        endm

        macro cpyn value
        ld l,a
        ld a,e
        cp value
        ld a,l
        endm

        macro cmpi addr
        ld hl,addr
        cp (hl)
        endm

        macro cpxi addr
        ld hl,(addr)
        ld h,a
        ld a,c
        cp l
        ld a,h
        endm

        macro cpyi addr
        ld hl,(addr)
        ld h,a
        ld a,e
        cp l
        ld a,h
        endm

        macro cmpx shift,x
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        cp (hl)
        endm

        macro cmpy shift,y
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        cp (hl)
        endm

        macro dex
        dec c
        endm
        
        macro inx
        inc c
        endm
        
        macro dey
        dec e
        endm
        
        macro iny
        inc e
        endm
        
        macro deci addr
        ld hl,addr
        dec (hl)
        endm
        
        macro inci addr
        ld hl,addr
        inc (hl)
        endm
        
        macro incx shift,x
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        inc (hl)
        endm

        macro decx shift,x
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        dec (hl)
        endm

        macro incy shift,y
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        inc (hl)
        endm

        macro decy shift,y
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        dec (hl)
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        macro pha
        push af
        endm
        
        macro pla
        ;pop hl
        ;ld a,h ;keep CY
        ;inc a
        ;dec a ;keep CY, set Z,N
        pop af
        endm
        
        macro plakeepcy
        pop hl
        ld a,h ;keep CY
        inc a
        dec a ;set Z,N
        endm
        
        macro plarol ;pla:rol
        pop hl
        ld a,h ;keep CY
        rla
        endm

        macro txa
        ld a,c
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm
        
        macro tya
        ld a,e
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm
        
        macro tax
        ld c,a
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm
        
        macro tay
        ld e,a
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm
        
        macro ldan value
        ld a,value
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm

        macro ldxn value
        ld c,value
        ;inc c
        ;dec c ;keep CY, set Z,N
        endm

        macro ldyn value
        ld e,value
        ;inc e
        ;dec e ;keep CY, set Z,N
        endm

        macro ldyn16 value
        ld de,value
        endm

        macro lda addr
        ld a,(addr)
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm

        macro ldx addr
        ld hl,addr
        ld c,(hl)
        ;inc c
        ;dec c ;keep CY, set Z,N
        endm

        macro ldy addr
        ld hl,addr
        ld e,(hl)
        ;inc e
        ;dec e ;keep CY, set Z,N
        endm

        macro ldax shift,x ;???
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        ld a,(hl)
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm

        macro ldaxkeepcy shift,x ;???
        push af
        ld hl,shift
        add hl,bc
        pop af
        ld a,(hl)
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm

        macro lday shift,y ;???
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        ld a,(hl)
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm

        macro ldaykeepcy shift,y ;???
        push af
        ld hl,shift
        add hl,de
        pop af
        ld a,(hl)
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm

        macro ldxy shift,y ;???
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        ld c,(hl)
        ;inc c
        ;dec c ;keep CY, set Z,N
        endm

        macro ldyx shift,x ;???
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        ld e,(hl)
        ;inc e
        ;dec e ;keep CY, set Z,N
        endm

        macro ldayindirect addr,y ;???
        ;push af
        ld hl,(addr)
        add hl,de
        ;pop af
        ld a,(hl)
        ;inc a
        ;dec a ;keep CY, set Z,N
        endm

        macro sta addr
        ld (addr),a
        endm

        macro stx addr
        ld hl,addr
        ld (hl),c
        endm

        macro sty addr
        ld hl,addr
        ld (hl),e
        endm

        macro stax shift,x ;??? no branches found after stax
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        ld (hl),a
        endm

        macro stay shift,y ;??? no branches found after stay
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        ld (hl),a
        endm

        macro stxy shift,y ;??? no branches found after stxy
        ;push af
        ld hl,shift
        add hl,de
        ;pop af
        ld (hl),c
        endm

        macro styx shift,x ;??? no branches found after styx
        ;push af
        ld hl,shift
        add hl,bc
        ;pop af
        ld (hl),e
        endm

        macro stayindirect addr,y ;??? no branches found after stayindirect
        ;push af
        ld hl,(addr)
        add hl,de
        ;pop af
        ld (hl),a
        endm
