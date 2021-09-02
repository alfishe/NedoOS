        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

DEBUG=0;1

	include "bk.ini"

STACK=0x4000

;PC=0x4000...
;data=0xC000...
        include "macros.asm"

        org PROGSTART
begin
        jp init
initq
Reset
       ld a,(pgprog)
       SETPG4000
       jp resetpp

quiter
       ld a,(pgprog)
       SETPG4000
       jp farquiter
       
       if 0
jpiyer
        ld hl,jpiyer
        push hl
        jp (iy)
       endif
EMUCHECKQ
        ;call getflags_bc
        ;call makeflags_frombc
        ;call getflags_bc
       if DEBUG
      push de
       decodePC
      if 1;0
       ;ld a,(_SP)
       ;rra
       ;jr c,$
       ;ld (oldpc),de
oldpcaddr=$+1
        ld hl,oldpc
        ld (hl),e
        inc l
        ld (hl),d
        inc l
        ld (oldpcaddr),hl
       endif
       ld a,d
       ;sub 0x40+((STARTPC/256)&0x3f);0x7c
       ;or e;cp 0x30
       ;cp 0x97
      ld hl,0x2d09;0x2976
      or a
      sbc hl,de
      pop de
      ;jr nc,$
      jr z,$
       endif
        get
        next
        ld c,a
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD b,(HL)
        INC H
        LD H,(HL)
        ld L,b ;ac=cmd
        JP (HL) 

;иначе pop iy запорет iy от обработчика прерывания
disable_iff0_keep_iy
      ;di
        ld (iykeeper_iy),iy
        ld a,55 ;scf
        ld (iykeeper_on),a ;keep hl,de!
        ret
;иначе pop iy запорет iy от обработчика прерывания
enable_iff0_remember_iy
iykeeper_iy=$+2
        ld iy,0
        ld hl,iykeeper_on
        ld (hl),55+128 ;or a ;keep a!
      ;ei
        ret

on_int
        PUSH AF,HL
        push bc,de
        exx
        push bc
        push de
        push hl
        push ix
        push iy
        ex af,af' ;'
        push af 
        call oldimer
        
	;ld hl,(timer)
	;inc hl
	;ld (timer),hl
       ld a,0xf7
       in a,(0xfe)
       and 0b10101
       jp z,quiter ;1+3+5 = quit

       ld a,(curpg4000) ;ok
       push af
       ld a,(pgprog)
       SETPG4000
        call KEYB ;TODO в странице
       pop af
       SETPG4000
        ;OS_GETKEY
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется для обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус.  
        pop af
        ex af,af' ;'
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        exx
        pop de,bc
       LD A,(iff1)
       OR A
       jr NZ,IMEREI
        POP HL,AF
        EI
       RET
IMEREI
        XOR A
        LD (iff1),A
;перед эмуляцией INT завершаем тек.команду (перехват на EMULOOP)
        LD (keepemuchecker),IY
        LD IY,IMINT
        POP HL,AF
        RET  ;di!
IMINT
keepemuchecker=$+2
        LD IY,0
iykeeper_on=$
        or a ;scf=on
        jr nc,IMINT_noiykeeperdata
        ld iy,(iykeeper_iy)
IMINT_noiykeeperdata
       ;LD (retfromim),DE ;для индикации времени обработки прерыв
              
      ld a,(tpgs)
      SETPGC000

        ;call KEYB ;TODO в странице
GKEYADR=$+1
        LD HL,KEYBUFF ;адрес конца списка

;04 -- ошибка шины/HALT/"СТОП"
;60 (0x30) -- клавиатура
;274 (0xbc) -- клавиатура с нажатой АР2
;на 11М еще 100 (0x40) -- кадровое прерывание
;10 (0x08) -- нелегальная команда
;ещё есть программные EMT/TRAP/BPT/IOT

      ld hl,(0x30*4+0xc000) ;pc
      ld bc,(0x30*4+0xc002) ;psw
      ld a,h
      or l
     xor a
      jp z,STIer ;костыль для неинициализированного прерывания
        
gotoint
;push psw; push pc (адрес после команды)
       push hl
       call getflags_bc
        set 7,c ;interrupt enable
       putmemspBC

       decodePC
        LD b,d
        ld c,e ;=old PC
       pop de ;new PC
        putmemspBC

       _LoopC_JP

       if 1;AFFLAG_16BIT
;как сформировать ZF,SF, не трогая AF?
;для этого надо сформировать число с нужными свойствами и сделать inc
         ;ZF SF AF OF
;ff даёт  1  0  1  0 ;имитирует флаги после inc ffff
;7f даёт  0  1  1  1 ;имитирует флаги после inc 7fff
;80 даёт  0  1  0  0 ;имитирует флаги после inc 8000
;8f даёт  0  1  1  0 ;имитирует флаги после inc 800f
;т.е. ff, 7f надо формировать только для 7fff, ffff
;а в остальных случаях надо брать (h&0x80) + (l&0x08)
;если l!=ff, l!=7f, то можно просто сделать inc l
;если l=ff, то нельзя просто сделать inc h - запортится AF!
inchlwithflags_l00 ;inc h needed
        inc h
        ret z ;set ZF=1(ok), AF=1(ok), OF=0(ok)
        jp pe,inchlwithflags_overflow
inchlwithflags_a0_setAF ;set ZF=0(ok), SF=h7(ok), AF=1, keep CY
;a=0
        jp m,$+5
        ld a,0x80 ;after dec: a7=h7
        dec a ;set ZF=0, SF=h7, AF=1, keep CY
        ret
incbcwithflags_c00 ;inc b needed
        inc b
        ret z ;set ZF=1(ok), AF=1(ok), OF=0(ok)
        jp po,inchlwithflags_a0_setAF
inchlwithflags_overflow
        exx
        ld e,0x80 ;overflow (e7!=e6)
        exx
        ret

inchlwithflags_l80 ;fix SF, keep AF=1, ZF=0
;a=0x80
        bit 7,h
        jr z,inchlwithflags_l80_p
inchlwithflags_l80_m
        ld a,0 ;keep CY!
        dec a ;00->ff ;set ZF=0, SF=h7, AF=1, keep CY
        ret
incbcwithflags_c80 ;fix SF, keep AF=1, ZF=0
;a=0x80
        bit 7,b
        jr nz,inchlwithflags_l80_m
inchlwithflags_l80_p
        dec a ;80->7f ;set ZF=0, SF=h7, AF=1, keep CY
        ret

dechlwithflags_fixflags
	ex af,af' ;'
        dec l
        ld a,l
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        exx
        jr z,dechlwithflags_l00 ;maybe zero
        inc a
        jp pe,inchlwithflags_l80;dechlwithflags_l7f ;fix SF, keep AF=1, ZF=0
        ret nz
        dec h
        jp pe,inchlwithflags_overflow
        jr nz,inchlwithflags_a0_setAF ;set ZF=0, SF=h7, AF=1, keep CY
;a=0, hl=0x00ff
        inc a ;set ZF=0, SF=0, AF=0, keep CY
        ret
dechlwithflags_l00 ;maybe zero
;a=0
        inc h
        dec h
        ret z ;set ZF=1, SF=0, AF=0
        ld a,h
        res 0,a ;for ZF=0, AF=0
        inc a ;set ZF=0, SF=h7, AF=0, keep CY
        ret

decbcwithflags_fixflags
	ex af,af' ;'
        dec c
        ld a,c
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        exx
        jr z,decbcwithflags_c00 ;maybe zero
        inc a
        jp pe,inchlwithflags_l80;dechlwithflags_l7f ;fix SF, keep AF=1, ZF=0
        ret nz
        dec b
        jp pe,inchlwithflags_overflow
        jr nz,inchlwithflags_a0_setAF ;set ZF=0, SF=h7, AF=1, keep CY
;a=0, bc=0x00ff
        inc a ;set ZF=0, SF=0, AF=0, keep CY
        ret
decbcwithflags_c00 ;maybe zero
;a=0
        inc b
        dec b
        ret z ;set ZF=1, SF=0, AF=0
        ld a,b
        res 0,a ;for ZF=0, AF=0
        inc a ;set ZF=0, SF=h7, AF=0, keep CY
        ret

       endif

recountpc_inc ;keep CY!
	inc d
        ret p ;<0x8000
        push af
        push bc
        dec de
        decodePC ;de->de
        inc de
        encodePC ;de->de
        pop bc
        pop af
        ;ld de,0x4000
	ret

inchnextpg
        inc h
        ret nz
hlnextpg
        push af
        push bc
	ld a,lx
        add a,0x40
        ;adc a,0
        ld c,a
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        pop bc
        pop af
        ld h,0xc0
	ret

PUTscreen_logpgc_zxaddrhl_datamhl_keephlpg_do
       push hl
       push bc
       call PUTscreen_logpgc_zxaddrhl_datamhl_do ;не получится inline, т.к. многие вызывают прямо PUTscreen_logpgc_zxaddrhl_datamhl_do
       pop bc
        ld b,tpgs/256
        ld a,(bc)
        SETPGC000 ;как было
       pop hl
        ret

PUTscreen_logpgc_zxaddrhl_datamhl_do
        
        ret

getflags_bc
;формат PSW такой: IxxTNZVC
;разрешение прерываний -- маска 0200(0x80) в PSW
;T - разрешение трассировочного прерывания
        ex af,af' ;'
        push af
        ex af,af' ;'
        pop bc
;c=%SZ???V?C
        ld a,c ;flags
        ld bc,0
        add a,a
        jr nc,$+4
        set 3,c ;N=S
        jp p,$+5
        set 2,c ;Z
        rra ;a=flags
        rra
        jr nc,$+3
        inc c ;C
        rra
        rra
        jr nc,$+4
        set 1,c ;V
        ld a,(iff1)
       and 0x80
       or c
       ld c,a
        ret
        
STIer
        ld a,-1
        ld (iff1),a
       _LoopC

getmemspBCpp
        ld hl,(_SP)
        inc hl
        inc hl
        ld (_SP),hl
        dec hl
        dec hl
        ld a,h
        and 0xc0
	ld c,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        ld c,(hl)
        inc l
        ld b,(hl)
        ret nz
        push bc
        ld hl,(_SP)
        dec hl
        ld a,h
        and 0xc0
	ld c,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        pop bc
        ld b,(hl)
	ret

recountsp_inc
        push bc
        ld hl,(_SP)
        inc hl
        ld a,h
        and 0xc0
	ld c,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        pop bc
	ret

;a=cmdLSB
getdest
;out: bc=dest, a=cmdLSB
;TODO

        ret

;bc=dest, a=cmdLSB
putdest
;TODO

        ret

readsourceop
;bc=cmd
;out: bc=sourceop, a=cmdLSB

;TODO read pc

;15-12 Opcode
;11-9 Src
;8-6 Register
;5-3 Dest
;2-0 Register

;0n	Register	Rn	The operand is in Rn
;1n	Register deferred	(Rn)	Rn contains the address of the operand
;2n	Autoincrement	(Rn)+	Rn contains the address of the operand, then increment Rn
;3n	Autoincrement deferred	@(Rn)+	Rn contains the address of the address of the operand, then increment Rn by 2
;4n	Autodecrement	−(Rn)	Decrement Rn, then use the result as the address of the operand
;5n	Autodecrement deferred	@−(Rn)	Decrement Rn by 2, then use the result as the address of the address of the operand
;6n	Index	X(Rn)	Rn+X is the address of the operand
;7n	Index deferred	@X(Rn)	Rn+X is the address of the address of the operand
        ld a,b
        rra
        rra
        jr c,readsourceop_xx1
        rra
        jr c,readsourceop_x10
        rra
        jp c,readsourceop_100
;000 Register
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a
        ld h,_R0/256
         ;ld l,(hl) ;TODO
;0000rrr0
         ld a,c
        ld c,(hl)
        inc l
        ld b,(hl)
        ret

readsourceop_xx1
        rra
        jr c,readsourceop_x11
        rra
        jp c,readsourceop_101
;001 (Rn): Rn contains the address of the operand
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a
        ld h,_R0/256
         ;ld l,(hl) ;TODO
;0000rrr0
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ld a,h
        and 0xc0
       ld hx,c
	ld c,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        inc l
        ld b,(hl)
        ret

readsourceop_x10
        rra
        jp c,readsourceop_110
;010 (Rn)+
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
        cp 0x0c
       ld hx,c
        ld c,(hl)
        ;jr nc,readsourceop_010_sppc
       jr c,$+2+2+1
       jr nz,readsourceop_010_pc
       inc (hl) ;sp/pc +=2 ;TODO нечётный?
        inc (hl)
        inc hl
        ld a,(hl)
        jr nz,$+3
        inc (hl)
        ld l,c
        ld h,a
        and 0xc0
	ld c,a
       ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        inc l
        ld b,(hl)
        ret nz
        inc h
        call z,hlnextpg
        ld b,(hl)
        ret

readsourceop_010_pc
        get
        next
        ld c,a
        get
        next
        ld b,a
       ld a,hx
        ret

readsourceop_x11
        rra
        jp c,readsourceop_111
;011 @(Rn)+
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
        cp 0x0c
       ld hx,c
        ld c,(hl)
       inc (hl) ;sp/pc +=2 ;TODO нечётный?
        inc (hl)
        inc hl
        ld a,(hl)
        jr nz,$+3
        inc (hl)
        ld l,c
        ld h,a
readsourceop_addrfromaddr
        and 0xc0
	ld c,a
       ld lx,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        ld c,(hl)
        inc l
        call z,inchnextpg
        ld a,(hl)
        ld l,c
        ld h,a
        and 0xc0
	ld c,a
       ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        inc l
        ld b,(hl)
        ret nz
        inc h
        call z,hlnextpg
        ld b,(hl)
        ret

readsourceop_100
;100 -(Rn)
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
        cp 0x0c
       ld hx,c
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
       jr c,$+3
       dec bc ;sp/pc +=2
        ld (hl),b
        dec l
        ld (hl),c
        ld l,c
        ld a,b
        ld h,a
        and 0xc0
	ld c,a
       ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        inc l
        ld b,(hl)
        ret nz
        inc h
        call z,hlnextpg
        ld b,(hl)
        ret

readsourceop_101
;101 @-(Rn)
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
        cp 0x0c
       ld hx,c
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
       dec bc ;sp/pc -=2
        ld (hl),b
        dec l
        ld (hl),c
        ld l,c
        ld a,b
        ld h,a
        and 0xc0
	ld c,a
       ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        ld c,(hl)
        inc l
        call z,inchnextpg
        ld a,(hl)
        ld l,c
        ld h,a
        and 0xc0
	ld c,a
       ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        inc l
        ld b,(hl)
        ret nz
        inc h
        call z,hlnextpg
        ld b,(hl)
        ret

readsourceop_110
;110 Index: X(Rn): Rn+X is the address of the operand
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a
        ld h,_R0/256
       ld hx,c
        get
        next
        add a,(hl)
        ld c,a
        inc l
        get
        next
        adc a,(hl)
        ld h,a
        ld l,c
;hl=Rn+X
        and 0xc0
	ld c,a
       ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        inc l
        ld b,(hl)
        ret nz
        inc h
        call z,hlnextpg
        ld b,(hl)
        ret
readsourceop_111
;111 Index deferred: @X(Rn): Rn+X is the address of the address of the operand
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a
        ld h,_R0/256
       ld hx,c
        get
        next
        add a,(hl)
        ld c,a
        inc l
        get
        next
        adc a,(hl)
        ld h,a
        ld l,c
;hl=Rn+X ;a=h
        jp readsourceop_addrfromaddr

poprecodePCLoop
       pop af ;ignore
recodePCLoop
;de=new PC
       _LoopC_JP


	include "bkcmd.asm"

        align 256
tpgs
        ds 256 ;%10765432

        align 256
;8 r16s
_R0
        dw 0
_R1
        dw 0
_R2
        dw 0
_R3
        dw 0
_R4
        dw 0
_R5
        dw 0
_R6
_SP
        dw 0
_R7
        dw 0

ansipal ;можно убрать в ints
;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
        ;dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        ;dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
;по сравнению с цветами терминала переставлено:
;1-4
;3-6
	dw 0xffff,0xfefe,0xefef,0xeeee,0xfdfd,0xfcfc,0xeded,0xecec
	dw 0x1f1f,0x1e1e,0x0f0f,0x0e0e,0x1d1d,0x1c1c,0x0d0d,0x0c0c

pc_high
        db 0
iff1
	db 0
pgprog
        db 0 ;там можно хранить дополнительный код (напр., отладчик)
oldimer
        jp on_int
        jp 0x0038+3
        
        align 256
	include "bktable.asm"

       if DEBUG
       align 256
oldpc
        ;dw 0
        ds 256
       endif

;генерируется для textmode
        align 256
ttextaddr
        ds 128

        display "killable=",$
;killable

        display "lowend=",$
        ds 0x3fc0-$
        ds 0x4000-$
        include "ints.asm"
	include "keyscan.asm"
        display "end=",$
end

	savebin "bk.com",begin,end-begin

	LABELSLIST "../../us/user.l"
