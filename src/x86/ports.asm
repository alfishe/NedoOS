INali8
        get
        next
        ld c,a
        ld b,0
INal_bc
        call IN_bc_to_bc
        ld a,c
	ld (_AL),a
       _Loop_
INaldx
        ld bc,(_DX)
        jr INal_bc

INaxi8
        get
        next
        ld c,a
        ld b,0
INax_bc
        call IN_bc_to_bc
	ld (_AL),bc
       _Loop_
INaxdx
        ld bc,(_DX)
        jr INax_bc

OUTi8al
        get
        next
        ld c,a
        ld b,0
        ld hl,(_AL)
        call OUTbc_l
        _LoopC
OUTi8ax
        get
        next
        ld c,a
        ld b,0
        ld hl,(_AX)
        call OUTbc_hl
        _LoopC
OUTdxal
        ld bc,(_DX)
        ld hl,(_AL)
        call OUTbc_l
        _LoopC
OUTdxax
        ld bc,(_DX)
        ld hl,(_AX)
        call OUTbc_hl
        _LoopC

OUTbc_hl
        ;ret
OUTbc_l
        ret

IN_bc_to_bc
        ld hl,0x03da
        or a
        sbc hl,bc
        jr z,IN_03da ;может быть 3ba todo
       ld hl,0x0060
       or a
       sbc hl,bc
       jr z,IN_0060 ;for mision
       inc hl ;ld hl,0x0061
       or a
       sbc hl,bc
       jr z,IN_0061 ;for mision
       ld hl,0x0201
       or a
       sbc hl,bc
       jr z,IN_0201 ;for planeta
        ld hl,0x0202
        or a
        sbc hl,bc
        jr z,IN_0202
        ld hl,0x0040
        or a
        sbc hl,bc
        jr nz,IN_skip
;in al,0x40          ; Read timer counter 0 
      if 1
        ld a,0
        inc a
        ld ($-2),a
        ld c,a
        ld b,a
      else
	ld bc,(timer_cnt);(timer)
       ;srl b
       ;rr c
       ;srl b
       ;rr c
       ;ld b,c
       ld a,r
       add a,a
       add a,c
       ld c,a
       endif
       ;ld bc,0xffff
        ret
IN_skip
        ld bc,0xffff
        ret

;Порт 60h при чтении содержит скан-код последней нажатой клавиши.
;ещё отжатие (+0x80)
;Порт 61h управляет не только клавиатурой, но и другими устройствами компьютера, например, работой встроенного динамика. Этот порт доступен как для чтения, так и для записи. Для нас важен самый старший бит этого порта. Если в старший бит порта 61h записать значение 1, клавиатура будет заблокирована, если 0 - разблокирована.
;Так как порт 61h управляет не только клавиатурой, при изменении содержимого старшего бита необходимо сохранить состояние остальных битов этого порта. Для этого можно сначала выполнить чтение содержимого порта в регистр, изменить состояние старшего бита, затем выполнить запись нового значения в порт:
;        in      al, 61h
;        or      al, 80h
;        out     61h, al
        
IN_0060
        push de
     ;DISABLE_IFF0_KEEP_IY
        ;OS_GETKEY
       ld a,(curpg4000) ;ok
       push af
       ld a,(pgprog)
       SETPG4000
        call keyscan_getkey
       ;or a
       ;jr z,IN_0060_nokey
      if 0
       push af
       and 0x7f
        cp 0x60
        jr c,$+4
        sub 0x20
        ld c,a
        ld b,0
        ld hl,tkeytoscancode
        add hl,bc
       pop af
        xor (hl)
        and 0x80
        xor (hl)
      endif
     ;ENABLE_IFF0_REMEMBER_IY ;иначе pop iy запорет iy от обработчика прерывания
      ;ld c,0x18
      ; ld a,r
      ; and 7
       ;add a,a
      ; add a,c
       ld c,a
       ;jr $
       pop af
       push bc
       SETPG4000
       pop bc
        pop de
        ret
IN_0061
        ;ld a,0xfb
        ;in a,(0xfe)
        ;cpl
        ld c,0;a
       ;ld a,r
       ;add a,a
       ;add a,c
       ;ld c,a
        ret

IN_0201
;проверяется по маске 3 (planeta). не помогает
        ;jr $
        ld a,r
        rra
        rra
        ld c,a
        ret

IN_0202
;проверяется на равенство 3f (ptica)
        ld bc,0x003f
        ret

;0x03da - порт видеоконтроллера. проверяется на равенство 8 - во время КСИ? (pixeltown) и на and 1 (cgademo)
;- bit 0 Display Enable-Logical 0 indicates the CRT
;raster is in a horizontal or vertical retrace
;interval. This bit is the real time status of the
;display enable signal. Some programs use this
;status bit to restrict screen updates to inactive
;display intervals. The Enhanced Graphics
;Adapter does not require the CPU to update the
;screen buffer during inactive display intervals to .~
;avoid glitches in the display image.
;- bit 3 Vertical Retrace-A logical 0 indicates that video
;information is being displayed on the CRT
;screen; a logicall indicates the CRT is in a
;vertical retrace interval. This bit can be
;programmed to interrupt the processor on
;interrupt level 2 at the start of the vertical
;retrace. This is done through bits 4 and 5 of the ~
;Vertical Retrace End Register of the CRTC. 
IN_03da
        ld a,r
       rra
       rra
        and 8+1
        ld c,a
        ld b,0
        ret

       if 0
tkeytoscancode
       ;db 0x20+128 ;unpress D
        ds 13+tkeytoscancode-$
        db 0x1c ;enter
        ds 32+tkeytoscancode-$
        db 0x39 ;space
        ds 48+tkeytoscancode-$
        db 0x0b,2,3,4,5,6,7,8,9,10
        ds 0x41+tkeytoscancode-$
        db 0x1e ;(A)
        db 0x30 ;(B)
        db 0x2e ;(C)
        db 0x20 ;(D)
        db 0x12 ;(E)
        db 0x21 ;(F)
        db 0x22 ;(G)
        db 0x23 ;(H)
        db 0x17 ;(I)
        db 0x24 ;(J)
        db 0x25 ;(K)
        db 0x26 ;(L)
        db 0x32 ;(M)
        db 0x31 ;(N)
        db 0x18 ;(O)
        db 0x19 ;(P)
        db 0x10 ;(Q)
        db 0x13 ;(R)
        db 0x1f ;(S)
        db 0x14 ;(T)
        db 0x16 ;(U)
        db 0x2f ;(V)
        db 0x11 ;(W)
        db 0x2d ;(X)
        db 0x15 ;(Y)
        db 0x2c ;(Z)
        ds 96+tkeytoscancode-$
       endif
