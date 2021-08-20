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
        ret
OUTbc_l
        ret

IN_bc_to_bc
        ld hl,0x03da
        or a
        sbc hl,bc
        jr z,IN_03da
       ld hl,0x0060
       or a
       sbc hl,bc
       jr z,IN_0060 ;for mision
       ld hl,0x0061
       or a
       sbc hl,bc
       jr z,IN_0061 ;for mision
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
;Порт 61h управляет не только клавиатурой, но и другими устройствами компьютера, например, работой встроенного динамика. Этот порт доступен как для чтения, так и для записи. Для нас важен самый старший бит этого порта. Если в старший бит порта 61h записать значение 1, клавиатура будет заблокирована, если 0 - разблокирована.
;Так как порт 61h управляет не только клавиатурой, при изменении содержимого старшего бита необходимо сохранить состояние остальных битов этого порта. Для этого можно сначала выполнить чтение содержимого порта в регистр, изменить состояние старшего бита, затем выполнить запись нового значения в порт:
;        in      al, 61h
;        or      al, 80h
;        out     61h, al
        
IN_0060
        push de
     DISABLE_IFF0
        push iy
        OS_GETKEY
        pop iy
     ENABLE_IFF0 ;иначе pop iy запорет iy от обработчика прерывания
        pop de
      ;ld c,0x18
      ; ld a,r
      ; and 7
       ;add a,a
      ; add a,c
       ld c,a
        ret
IN_0061
        ld a,0xfb
        in a,(0xfe)
        cpl
        ld c,a
       ld a,r
       add a,a
       add a,c
       ld c,a
        ret

IN_0202
;проверяется на равенство 3f (ptica)
        ld bc,0x003f
        ret

;0x03da - порт видеоконтроллера. проверяется на равенство 8 - во время КСИ? (pixeltown) и на and 1 (cgademo)
IN_03da
        ld a,r
        and 8+1
        ld c,a
        ld b,0
        ret
