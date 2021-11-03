        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

DEBUG=0;1
CRUTCH=1 ;костыль для movb
DEBUGWR=0
BASIC=1;0

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
      bit 0,e
      jr nz,$
      ld a,d
      sub 0x40
      cp 0x40
      jr nc,$
      
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
        ld bc,(_R1)
        ld (hl),c
        inc l
        ld (hl),b
        inc l
        ld (oldpcaddr),hl
       endif
       ld a,d
       ;sub 0x40+((STARTPC/256)&0x3f);0x7c
       ;or e;cp 0x30
       ;cp 1
       ;jr z,$
      ld hl,0x228;0x8252;0x0318;0x32c8;0x3222;0x3262;0x1f74;0x0258;0x3dc8
      or a
      sbc hl,de
      pop de
      ;jr z,$
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
        call oldimer ;делает ei!!! двигать позже нельзя, он ставит палитру в верхнем бордере и потом не будет второй раз!
        
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

       ld a,0xf7
       in a,(0xfe)
       and 0b11000
on_int_oldchgfxmodekey=$+1
        cp 0
        ld (on_int_oldchgfxmodekey),a
        cp c
        jr z,on_int_nochgfxmode
       or a
       call z,changegfxmode ;4+5 = change gfx mode
on_int_nochgfxmode

        call KEYB
;iskeymessage=$
;        or a ;/scf
;        jr c,int_alreadyhavekey
       ;ld a,(bk_curkey)
       ;or a
       ;jr nz,int_alreadyhavekey
        call keyscan_getkey
       jr z,int_alreadyhavekey ;no keys in buf
        ld (bk_curkey),a
        ;ld a,55 ;"scf"
        ;ld (iskeymessage),a ;message
int_alreadyhavekey
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
              
      ld a,(tpgs)
      SETPGC000

GKEYADR=$+1
        LD HL,KEYBUFF ;адрес конца списка

;04 -- ошибка шины/HALT/"СТОП"
;60 (0x30) -- клавиатура
;274 (0xbc) -- клавиатура с нажатой АР2
;на 11М еще 100 (0x40) -- кадровое прерывание
;10 (0x08) -- нелегальная команда
;ещё есть программные EMT/TRAP/BPT/IOT

      ld hl,(0x30+0xc000) ;pc
      ld bc,(0x30+0xc002) ;psw
      ld a,h
      or l
     xor a
      jp z,STIer ;костыль для неинициализированного прерывания
        
;должно вызываться только при нажатии на клавишу
        ld a,(bk_curkey)
        or a
        jp z,STIer
        
gotoint
;push psw; push pc (адрес после команды)
       push hl
       call getflags_bc
        set 7,c ;interrupt enable
       putmemspBC

       decodePC_to_ae
        LD b,a
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
        encodePC ;de->de, setpg
        pop bc
        pop af
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

putscreen_c
putscreen_c_patch=$
PUTSCREEN_C_PATCH_MONO=0x3e
PUTSCREEN_C_PATCH_COLOR=0x18
        jr putscreen_c_color
       push hl
       push bc
       ld b,tmirror/256
       ld a,(bc)
       push af
;y=%TTYYYyyy
;hl=%01TTYYYy yyxxxxxx
       ld b,0
       bit 0,l
       jr z,$+4
       ld b,0x20
        ld a,l
        rra
        and 0x1f
       add hl,hl
       add hl,hl
       ld l,h
        ld h,ty/256
        ld c,(hl)
        inc h
        ld h,(hl) ;hc = ybase
        ld l,a
        add hl,bc
;addr=0x8000+(half*0x2000)+y*40+x
        ld a,(user_scr0_high) ;ok
        SETPG8000 ;TODO щёлкать только в color      
       pop af
        ld (hl),a
       pop bc
       pop hl
        ret

putscreen_c_color
       push hl
       push bc
;y=%TTYYYyyy
;hl=%01TTYYYy yyxxxxxx
       ld b,0
       bit 0,l
       jr z,$+4
       ld b,0x20
        ld a,l
        rra
        and 0x1f
       add hl,hl
       add hl,hl
       ld l,h
        ld h,ty/256
        ld c,(hl)
        inc h
        ld h,(hl) ;hc = ybase
        ld l,a
        add hl,bc
;addr=0x8000+(half*0x2000)+y*40+x
        ld a,(user_scr0_low) ;ok
        SETPG8000
       pop bc
       push bc
        ld b,tleftpixels/256
        ld a,(bc)
        ld (hl),a
        ld a,c
        rlca
        rlca
        rlca
        rlca
        ld c,a
        ld a,(bc)
       push af
        ld a,(user_scr0_high) ;ok
        SETPG8000
       pop af
        ld (hl),a
       pop bc
       pop hl
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

makeflags_frombc
;c=IxxTNZVC
        ld a,c
        rla ;interrupt enable
        sbc a,a
        ld (iff1),a
        ld a,c
        ld c,0
        rra
        jr nc,$+3
        inc c ;C
        rra
        jr nc,$+4
        set 2,c ;V
        rra
        jr nc,$+4
        set 6,c ;Z
        rra
        jr nc,$+4
        set 7,c ;Z
;c=%SZ???V?C
        push bc
        ex af,af' ;'
        pop af
        ex af,af' ;'
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getdest8_aisc
;out: c=dest, a=cmdLSB
;15-12 Opcode
;11-9 Src
;8-6 Register
;5-3 Dest
;2-0 Register
        rla
        and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
         ;ld l,(hl) ;TODO
        bit 3,c
        jr nz,rddest8_xx1
        bit 4,c
        jr nz,rddest8_x10
        bit 5,c
        jr nz,rddest8_100
;000 Register ;TODO pc
       cp 0x0e
       jr z,$
         ld a,c
        ld c,(hl)
        ret
rddest8_x10
        bit 5,c
        jp nz,rddest8_110
        jp rddest8_010
rddest8_xx1
        bit 4,c
        jr nz,rddest8_x11
        bit 5,c
        jp nz,rddest8_101
        jp rddest8_001
rddest8_x11
        bit 5,c
        jp nz,rddest8_111
        ;jp rddest8_011
;rddest8_011 ;@(Rn)+ ;всегда +=2
        ld a,l
       ld hx,c
        cp 0x0e
        jr z,rddest8_011_pc
        UNTESTED ;GOOD ;road2cafe ;нет в leopol
        ld c,(hl)
        inc l
        ld a,(hl)
        jp rdsrc8_addrfromaddr_ac
rddest8_011_pc
        UNTESTED ;GOOD ;bubbler ;нет в leopol
;инкремент не делаем, чтобы его делал putdest
        get
        inc e ;next без переключения страниц!!! FIXME
        ld c,a
        get
        dec e ;FIXME
        RDMEM8_ac_ret ;c=result, a=hx

rddest8_100
;100 -(Rn)
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
        ld a,l
       ld hx,c
       cp 0x0e
       jr z,$;rddest8_100_pc
        cp 0x0c
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
       jr c,$+3
       dec bc ;sp/pc +=2
        UNTESTED
        ld a,b
        RDMEM8_ac_ret ;c=result, a=hx

rddest8_101
        ld a,l
;101 @-(Rn) ;всегда -=2
       ld hx,c
       cp 0x0e
       jr z,$;rddest8_101_pc
        UNTESTED
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
        dec bc
        ld a,b
        jp rdsrc8_addrfromaddr_ac

rddest8_110
        ld a,l
;X(Rn)
       ld hx,c
       cp 0x0e
       jr z,rddest8_110_pc
        UNTESTED ;GOOD ;leopol демо2
        get
        inc e
        add a,(hl)
        ld c,a
        inc l
        get
        dec e ;FIXME
        adc a,(hl) ;ac=Rn+X
        RDMEM8_ac_ret ;c=result, a=hx
rddest8_110_pc ;for mona
        UNTESTED ;GOOD ;leopol начало
        get
        inc e
        ld c,a
        ;inc l
        get
        dec e ;FIXME
        ld b,a
       decodePC_to_ae
      inc bc
      inc bc
        ld h,a
       ld a,c
       add a,e
       ld c,a
       ld a,b
       adc a,h ;ac=pc+X
        RDMEM8_ac_ret ;c=result, a=hx       

rddest8_111
       ld a,l
;111 Index deferred: @X(Rn): Rn+X is the address of the address of the operand
       ld hx,c
       cp 0x0e
       jr z,rddest8_111_pc
        UNTESTED
        get
        inc e
        add a,(hl)
        ld c,a
        inc l
        get
        dec e ;FIXME
        adc a,(hl) ;ac=Rn+X
        jp rdsrc8_addrfromaddr_ac
rddest8_111_pc ;for leopol?
;[[pc+X]]
        UNTESTED ;GOOD ;leopold когда уже появилась грязь вместо мышей
        get
        inc e
        ld c,a
        ;inc l
        get
        dec e ;FIXME
        ld b,a
       decodePC_to_ae
      inc bc
      inc bc ;TODO надо ли?
        ld h,a
       ld a,c
       add a,e
       ld c,a
       ld a,b
       adc a,h ;ac=pc+X
        jp rdsrc8_addrfromaddr_ac

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;c=data, a=cmdLSB = %??fmtRRR
putdest8_Loop
;15-12 Opcode
;11-9 Src
;8-6 Register
;5-3 Dest
;2-0 Register
        ld h,a
        rla
        and 0x0e
        ld l,a ;0000rrr0
        ld a,h
        ld h,_R0/256
         ;ld l,(hl) ;TODO
        rla
        rla
        rla
        jp c,wrdest8_1xx
        add a,a
        jr c,wrdest8_01x
        jp m,wrdest8_001
;000 Register
        ld a,l
        cp 0x0e
        jp z,$;bctoPCLoop
        ld (hl),c ;не надо расширять знак (Alexander Tishin), кроме movb (см. там отдельно)
        _LoopC

wrdest8_001 ;(Rn): Rn contains the address of the operand
       ld a,l
       cp 0x0e
       jr z,$
        GOOD ;leopol начало
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        WRMEM8_hl_LoopC
wrdest8_01x
        jp m,wrdest8_011
;wrdest_010 ;(Rn)+
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
        ld a,l
        cp 0x0c
        ld a,(hl)
       jr c,$+2+2+1
       jr nz,wrdest8_010_pc
       inc (hl) ;sp/pc +=2 ;TODO нечётный?
        GOOD ;leopol демо
        inc (hl)
        inc hl
        jr nz,$+2+3+2
         inc (hl)
         ld h,(hl)
         dec h
         jr $+3
       ld h,(hl)
        ld l,a
        WRMEM8_hl_LoopC
wrdest8_010_pc ;TODO так ли при dest=(pc+)? bkscope
        GOOD ;bkscope ;нет в leopol
        ld a,c
        ld (de),a
        next
        ;ld a,b
        ;ld (de),a
        next
       _LoopC

wrdest8_011 ;@(Rn)+
        ld a,l
        cp 0x0e
        jr z,wrdest8_011_pc
        UNTESTED
       push de
        ld e,(hl)
        inc l
        ld d,(hl)
        inc de
        inc de
        ld (hl),d
        dec l
        ld (hl),e
        dec de
        dec de
        ex de,hl
       pop de
wrdest8_memfrommem       
       push bc
        ld a,h
        and 0xc0
	ld c,a
       ld lx,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        ld b,(hl)
        inc l
        call z,inchnextpg
        ld h,(hl)
        ld l,b
       pop bc
        WRMEM8_hl_LoopC
wrdest8_011_pc
        GOOD ;pacman
        get
        next
        ld l,a
        get
        next
        ld h,a
        WRMEM8_hl_LoopC

wrdest8_1xx
        add a,a
        jp c,wrdest8_11x
        jp m,wrdest8_101
;wrdest8_100
;100 -(Rn)
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
        ld a,l
        cp 0x0c
       push de
        ld e,(hl)
        inc l
        ld d,(hl)
        dec de
       jr c,$+2+2+1
       jr nz,wrdest8_100_pc
       dec de ;sp/pc +=2
        GOOD ;leopol начало
        ld (hl),d
        dec l
        ld (hl),e
        ex de,hl
       pop de
     ;inc hl
       ;jr $
        WRMEM8_hl_LoopC
wrdest8_100_pc ;TODO так ли при -(pc)?
       jr $
       pop af ;skip
        decodePC
        dec de
        dec de
        encodePC
        ld a,c
        ld (de),a
       _LoopC
        
wrdest8_101
;101 @-(Rn) ;всегда -=2
       ld a,l
       cp 0x0e
       jr z,$;wrdest8_101_pc ;TODO pc
        UNTESTED
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
        dec bc
        ld (hl),b
        dec l
        ld (hl),c
        ld h,b
        ld l,c
        jp wrdest8_memfrommem
wrdest8_11x
        jp m,wrdest8_111
;wrdest8_110
;110 Index: X(Rn): Rn+X is the address of the operand
       ld a,l
       cp 0x0e
       jr z,wrdest8_110_pc
        GOOD ;bkscope
        get
        next
        add a,(hl)
       push af
        inc l
        get
        next
        adc a,(hl)
        ld h,a
       pop af
        ld l,a ;hl=Rn+X
        WRMEM8_hl_LoopC
wrdest8_110_pc
        GOOD ;leopol начало
       push bc
        get
        next;inc e
        ld c,a
        get
        next;dec e
        ld b,a
       decodePC_to_ae
        ld h,a
        ld l,e
        add hl,bc ;hl=pc+X
       pop bc
        WRMEM8_hl_LoopC
        
wrdest8_111
;111 Index deferred: @X(Rn): Rn+X is the address of the address of the operand
       ld a,l
       cp 0x0e
       jr z,wrdest8_111_pc
        UNTESTED
        get
        next
        add a,(hl)
       push af
        inc l
        get
        next
        adc a,(hl)
        ld h,a
       pop af
        ld l,a ;hl=Rn+X
        jp wrdest8_memfrommem
wrdest8_111_pc
        UNTESTED
       push bc
        get
        next;inc e
        ld c,a
        get
        next;dec e
        ld b,a
       decodePC_to_ae
        ld h,a
        ld l,e
        add hl,bc ;hl=pc+X
       pop bc
        jp wrdest8_memfrommem

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;a=cmdLSB = %??fmtRRR
getdest_aisc
;out: bc=dest, a=cmdLSB
;15-12 Opcode
;11-9 Src
;8-6 Register
;5-3 Dest
;2-0 Register
        rla
        and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
         ;ld l,(hl) ;TODO
        bit 3,c
        jr nz,rddest_xx1
        bit 4,c
        jr nz,rddest_x10
        bit 5,c
        jp nz,rddest_100
;000 Register
       cp 0x0e
       jr z,rddest_000_pc
         ld a,c
        ld c,(hl)
        inc l
        ld b,(hl)
        ret
rddest_000_pc ;cd.bk - TODO правильно ли? программа не работает
        GOOD ;basic
      ld hx,c
       decodePC_to_ae
       ld b,a
       ld c,e
      ld a,hx
        ret
rddest_x10
        bit 5,c
        jp nz,rddest_110
        jp rddest_010
rddest_xx1
        bit 4,c
        jr nz,rddest_x11
        bit 5,c
        jp nz,rddest_101
        jp rddest_001
rddest_x11
        bit 5,c
        jp nz,rddest_111
        ;jp rddest_011
;rddest_011 ;@(Rn)+ ;всегда +=2
       ld hx,c
        cp 0x0e
        jr z,rddest_011_pc
        GOOD ;road2cafe ;нет в leopol
        ld c,(hl)
        inc l
        ld a,(hl)
        jp rdsrc_addrfromaddr_ac
rddest_011_pc
        GOOD ;bubbler ;нет в leopol
;инкремент не делаем, чтобы его делал putdest
        get
        inc e ;next без переключения страниц!!! FIXME
        ld c,a
        get
        dec e ;FIXME
        RDMEM_ac_ret ;bc=result, a=hx

rddest_100
;100 -(Rn)
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
       ld hx,c
       cp 0x0e
       jr z,$;rddest_100_pc ;TODO pc
        GOOD ;sokoban ;нет в leopol
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
        dec bc
        ld a,b
        RDMEM_ac_ret ;bc=result, a=hx

rddest_101
;101 @-(Rn) ;всегда -=2
       ld hx,c
       cp 0x0e
       jr z,rddest_101_pc
        UNTESTED
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
        dec bc
        ld a,b
        jp rdsrc_addrfromaddr_ac
rddest_101_pc ;TODO
        jr $

rddest_110
;X(Rn)
       ld hx,c
       cp 0x0e
       jr z,rddest_110_pc
        GOOD ;leopol демо2
        get
        inc e
        add a,(hl)
        ld c,a
        inc l
        get
        dec e ;FIXME
        adc a,(hl) ;ac=Rn+X
        RDMEM_ac_ret ;bc=result, a=hx
rddest_110_pc ;for mona
        GOOD ;leopol начало
        get
        inc e
        ld c,a
        ;inc l
        get
        dec e ;FIXME
        ld b,a
       decodePC_to_ae
      inc bc
      inc bc
        ld h,a
       ld a,c
       add a,e
       ld c,a
       ld a,b
       adc a,h ;ac=pc+X
        RDMEM_ac_ret ;bc=result, a=hx

rddest_111
;111 Index deferred: @X(Rn): Rn+X is the address of the address of the operand
       ld hx,c
       cp 0x0e
       jr z,rddest_111_pc
        UNTESTED
        get
        inc e
        add a,(hl)
        ld c,a
        inc l
        get
        dec e ;FIXME
        adc a,(hl) ;ac=Rn+X
        jp rdsrc_addrfromaddr_ac
rddest_111_pc ;for leopol?
;[[pc+X]]
        GOOD ;leopold когда уже появилась грязь вместо мышей
        get
        inc e
        ld c,a
        ;inc l
        get
        dec e ;FIXME
        ld b,a
       decodePC_to_ae
      inc bc
      inc bc ;TODO надо ли?
        ld h,a
       ld a,c
       add a,e
       ld c,a
       ld a,b
       adc a,h ;ac=pc+X
        jp rdsrc_addrfromaddr_ac

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;bc=data, a=cmdLSB = %??fmtRRR
putdest_Loop
;15-12 Opcode
;11-9 Src
;8-6 Register
;5-3 Dest
;2-0 Register
        ld h,a
        rla
        and 0x0e
        ld l,a ;0000rrr0
        ld a,h
        ld h,_R0/256
         ;ld l,(hl) ;TODO
        rla
        rla
        rla
        jp c,wrdest_1xx
        add a,a
        jr c,wrdest_01x
        jp m,wrdest_001
;000 Register
        ld a,l
        cp 0x0e
        jp z,bctoPCLoop
        ld (hl),c
        inc l
        ld (hl),b
        _LoopC
wrdest_001 ;(Rn): Rn contains the address of the operand
       ld a,l
       cp 0x0e
       jr z,$
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        WRMEM_hl_LoopC
wrdest_01x
        jp m,wrdest_011
;wrdest_010 ;(Rn)+
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
;а тут небайтовая, значит, всегда +=2
        ld a,l
        cp 0x0e
       jr z,wrdest_010_pc
        GOOD ;textshow
       push de
        ld e,(hl)
        inc l
        ld d,(hl)
        inc de
        inc de
        ld (hl),d
        dec l
        ld (hl),e
        dec de
        dec de
        ex de,hl
       pop de
        WRMEM_hl_LoopC

wrdest_010_pc
;dest=(pc+) mona: mov r4,#0 ;space4k: dec #6000
        ld a,c
        ld (de),a
        next
        ld a,b
        ld (de),a
        next
       _LoopC

wrdest_011 ;@(Rn)+
        ld a,l
        cp 0x0e
        jr z,wrdest_011_pc
        UNTESTED ;road2cafe после этого портит экран
       push de
        ld e,(hl)
        inc l
        ld d,(hl)
        inc de
        inc de
        ld (hl),d
        dec l
        ld (hl),e
        dec de
        dec de
        ex de,hl
       pop de
wrdest_memfrommem
       push bc
        ld a,h
        and 0xc0
	ld c,a
       ld lx,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        ld a,(hl)
       push af
        inc l
        call z,inchnextpg
        ld h,(hl)
       pop af
        ld l,a
       pop bc
        WRMEM_hl_LoopC
wrdest_011_pc
        GOOD ;textshow
        get
        next
        ld l,a
        get
        next
        ld h,a
        WRMEM_hl_LoopC

wrdest_1xx
        add a,a
        jp c,wrdest_11x
        jp m,wrdest_101
;wrdest_100
;100 -(Rn)
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
        ld a,l
        cp 0x0e
        jr z,wrdest_100_pc
        GOOD ;textshow
       push de
        ld e,(hl)
        inc l
        ld d,(hl)
        dec de
        dec de
        ld (hl),d
        dec l
        ld (hl),e
        ex de,hl
       pop de
        WRMEM_hl_LoopC
wrdest_100_pc ;TODO так ли при -(pc)?
       jr $
        decodePC
        dec de
        dec de
        encodePC
        ld a,c
        ld (de),a
        inc e
        ld a,b
        ld (de),a
        dec e
       _LoopC

wrdest_101
;101 @-(Rn) ;всегда -=2
       ld a,l
       cp 0x0e
       jr z,$;rddest_101_pc ;TODO pc
        UNTESTED
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
        dec bc
        ld (hl),b
        dec l
        ld (hl),c
        ld h,b
        ld l,c
        jp wrdest_memfrommem
wrdest_11x
        jp m,wrdest_111
;wrdest_110
;110 Index: X(Rn): Rn+X is the address of the operand
        ld a,l
       cp 0x0e
       jr z,wrdest_110_pc
        GOOD ;leopol демо3
        get
        next
        add a,(hl)
       push af
        inc l
        get
        next
        adc a,(hl)
        ld h,a
       pop af
        ld l,a ;hl=Rn+X
        WRMEM_hl_LoopC
wrdest_110_pc ;for mona, leopol
        GOOD ;leopol начало
       push bc
        get
        next;inc e
        ld c,a
        get
        next;dec e
        ld b,a
       decodePC_to_ae
        ld h,a
        ld l,e
        add hl,bc ;hl=pc+X
       pop bc
        WRMEM_hl_LoopC

wrdest_111
;111 Index deferred: @X(Rn): Rn+X is the address of the address of the operand
        ld a,l
       cp 0x0e
       jr z,wrdest_111_pc
        UNTESTED
        get
        next
        add a,(hl)
       push af
        inc l
        get
        next
        adc a,(hl)
        ld h,a
       pop af
        ld l,a ;hl=Rn+X
        jp wrdest_memfrommem
wrdest_111_pc
;[[pc+X]]
        GOOD ;leopold глубоко во время игрового процесса (появление мышей?)
       push bc
        get
        next;inc e
        ld c,a
        get
        next;dec e
        ld b,a
       decodePC_to_ae
        ld h,a
        ld l,e
        add hl,bc ;hl=pc+X
       pop bc
        jp wrdest_memfrommem


;15c2
;0001 0101 1100 0010
;0 001 010 111 000 010
;mov  ;src;(pc)+;dst ;r2

;65c0
;0110 0101 1100 0000
;0 110 010 111 000 000
;add ;src;(pc)+;dst ;r0

;02fc
;0000 0010 1111 1100
;0 000 001 011 111 100
     ;bne
     
;1c71 ;mov barofs(r1), nhbar(r1)
;0001 1100 0111 0001
;0 001 110 001 110 001
      ;src;X(r1);dst;X(r1)

;7951
;0111 1001 0101 0001
;0 111 100 101 010 001
     ;XOR ;r5;dst;(r1)+

;7e85 ;sob
;0111 1110 1000 0101
;0 111 111 010 000 101

;[025c]:2017 ;cmp r0,#...
;0010 0000 0001 0111
;0 010 000 000 010 111
      ;src;r0 ;dst;(pc)+

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;a=cmdLSB = %??fmtRRR
getdest_aisc_autoinc ;TODO всегда +=2
;out: bc=dest, a=cmdLSB
       rra
       rra
       ld b,a       
        ld a,c
        rla
        jp rdsrc_go

getdest8_aisc_autoinc
;out: c=dest, a=cmdLSB
       rra
       rra
       ld b,a       
        ld a,c
        rla
        jp rdsrc8_go

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rdsrcop
;ac=cmd
;out: bc=sourceop, a=cmdLSB
;15-12 Opcode
;11-9 Src
;8-6 Register
;5-3 Dest
;2-0 Register
        ld b,a
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
rdsrc_go
         and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
         ;ld l,(hl) ;TODO

;0n	Register	Rn	The operand is in Rn
;1n	Register deferred	(Rn)	Rn contains the address of the operand
;2n	Autoincrement	(Rn)+	Rn contains the address of the operand, then increment Rn
;3n	Autoincrement deferred	@(Rn)+	Rn contains the address of the address of the operand, then increment Rn by 2
;4n	Autodecrement	?(Rn)	Decrement Rn, then use the result as the address of the operand
;5n	Autodecrement deferred	@?(Rn)	Decrement Rn by 2, then use the result as the address of the address of the operand
;6n	Index	X(Rn)	Rn+X is the address of the operand
;7n	Index deferred	@X(Rn)	Rn+X is the address of the address of the operand
        bit 1,b
        jr nz,rdsrc_xx1
        bit 2,b
        jr nz,rdsrc_x10
        bit 3,b
        jp nz,rdsrc_100
;000 Register
       cp 0x0e
       jr z,rdsrc_000_pc
         ld a,c
        ld c,(hl)
        inc l
        ld b,(hl)
        ret
rdsrc_000_pc
        GOOD ;leopol начало
        decodePC_to_ae
        ld b,a
         ld a,c
        ld c,e
        ret

rdsrc_xx1
        bit 2,b
        jp nz,rdsrc_x11
        bit 3,b
        jp nz,rdsrc_101
;001: (Rn)
rddest_001 ;(Rn): Rn contains the address of the operand
rddest_010 ;(Rn)+ ;инкремент не делаем, чтобы его делал putdest
       ld hx,c
       cp 0x0e
       jr z,rdsrc_001_pc
        ld c,(hl)
        inc l
        ld a,(hl)
        RDMEM_ac_ret ;bc=result
rdsrc_001_pc
        GOOD ;bkscope
        get
        ld c,a
        inc e
        get
        ld b,a
        dec e ;TODO нечётные
       ld a,hx
        ret

rdsrc_x10
        bit 3,b
        jp nz,rdsrc_110
;(Rn)+
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
       ld hx,c
        cp 0x0e
       jr z,rdsrc_010_pc
        GOOD ;textshow
        ld c,(hl)
        inc (hl) ;sp/pc +=2 ;TODO нечётный?
        inc (hl)
        inc hl
        ld a,(hl)
        jr nz,$+3
        inc (hl)
        RDMEM_ac_ret ;bc=result, a=hx
rdsrc_010_pc
        GOOD ;textshow
        get
        next
        ld c,a
        get
        next
        ld b,a
       ld a,hx
        ret

rdsrc_x11
        bit 3,b
        jp nz,rdsrc_111
rdsrc_011 ;@(Rn)+ ;всегда +=2
       ld hx,c
        cp 0x0e
        jr z,rdsrc_011_pc
        GOOD ;mars1
        ld c,(hl)
        inc l
        ld b,(hl)
        inc bc
        inc bc
        ld (hl),b
        dec l
        ld (hl),c
        dec bc
        dec bc
        ld a,b
rdsrc_addrfromaddr_ac
        ld l,c
        ld h,a
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
        RDMEM_ac_ret ;bc=result, a=hx
rdsrc_011_pc
        GOOD ;leopol демо4(кот у цифр)
        get
        next
        ld c,a
        get
        next
        RDMEM_ac_ret ;bc=result, a=hx

rdsrc_100
;100 -(Rn)
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
       ld hx,c
        cp 0x0e ;TODO pc
        jr z,$ ;ninza_1 сюда не должен попадать
        GOOD ;leopol начало
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
        dec bc
        ld (hl),b
        dec l
        ld (hl),c
rdmem_bc_to_bc
        ld a,b
rdmem_ac_to_bc
        RDMEM_ac_ret ;bc=result, a=hx

rdsrc_101
;101 @-(Rn) ;всегда -=2
       ld hx,c
        cp 0x0e
        jr z,$;rdsrc_101_pc ;TODO pc
        UNTESTED
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
        dec bc
        ld (hl),b
        dec l
        ld (hl),c
        ld a,b
        jp rdsrc_addrfromaddr_ac

rdsrc_110
;110 Index: X(Rn): Rn+X is the address of the operand
       ld hx,c
        cp 0x0e
        jr z,rdsrc_110_pc
        GOOD ;leopol начало
        get
        next
        add a,(hl)
        ld c,a
        inc l
        get
        next
        adc a,(hl) ;ac=Rn+X
        RDMEM_ac_ret ;bc=result, a=hx
rdsrc_110_pc
        GOOD ;leopol демо
        get
        next
        ld c,a
        get
        next
        ld b,a
        decodePC_to_ae
         ld h,a
        ld a,c
        add a,e
        ld c,a
        ld a,b
        adc a,h;d
        RDMEM_ac_ret ;bc=result, a=hx

rdsrc_111
;111 Index deferred: @X(Rn): Rn+X is the address of the address of the operand
       ld hx,c
       cp 0x0e
       jr z,rdsrc_111_pc
        GOOD ;klad ;нет в leopol
        get
        next
        add a,(hl)
        ld c,a
        inc l
        get
        next
        adc a,(hl) ;ac=Rn+X
        jp rdsrc_addrfromaddr_ac
rdsrc_111_pc ;for morf
        GOOD ;leopol появление мышей2?
        get
        next
        ld c,a
        get
        next
        ld b,a
        decodePC_to_ae
        ld h,a
        ld l,e
        add hl,bc
        ld a,h
        ld c,l ;ac=Rn+X
        jp rdsrc_addrfromaddr_ac

;;;;;;;;;;;;;;;;;;;;;;;
rdsrc8op
;ac=cmd
;out: c=sourceop, a=cmdLSB
;15-12 Opcode
;11-9 Src
;8-6 Register
;5-3 Dest
;2-0 Register
        ld b,a
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
rdsrc8_go
         and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
         ;ld l,(hl) ;TODO

;0n	Register	Rn	The operand is in Rn
;1n	Register deferred	(Rn)	Rn contains the address of the operand
;2n	Autoincrement	(Rn)+	Rn contains the address of the operand, then increment Rn
;3n	Autoincrement deferred	@(Rn)+	Rn contains the address of the address of the operand, then increment Rn by 2
;4n	Autodecrement	?(Rn)	Decrement Rn, then use the result as the address of the operand
;5n	Autodecrement deferred	@?(Rn)	Decrement Rn by 2, then use the result as the address of the address of the operand
;6n	Index	X(Rn)	Rn+X is the address of the operand
;7n	Index deferred	@X(Rn)	Rn+X is the address of the address of the operand
        bit 1,b
        jr nz,rdsrc8_xx1
        bit 2,b
        jr nz,rdsrc8_x10
        bit 3,b
        jp nz,rdsrc8_100
;000 Register
         ld a,c
        ld c,(hl)
        ;inc l
        ;ld b,(hl)
        ret

rdsrc8_xx1
        bit 2,b
        jp nz,rdsrc8_x11
        bit 3,b
        jp nz,rdsrc8_101
;001: (Rn)
rddest8_001 ;(Rn): Rn contains the address of the operand ;TODO optimize
rddest8_010 ;(Rn)+ ;инкремент не делаем, чтобы его делал putdest ;TODO optimize
       ld hx,c
       cp 0x0e
       jr z,rdsrc8_001_pc
        ld c,(hl)
        inc l
        ld a,(hl)
        RDMEM8_ac_ret ;bc=result
rdsrc8_001_pc
        UNTESTED ;GOOD ;bkscope
        get
        ld c,a
       ld a,hx
        ret

rdsrc8_x10
        bit 3,b
        jp nz,rdsrc8_110
;(Rn)+
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
       ld hx,c
        cp 0x0e
       jr z,rdsrc8_010_pc
        GOOD ;textshow
        ld c,(hl)
      cp 0x0c
      jr c,$+3 ;для textshow
         inc (hl) ;sp/pc +=2 ;TODO нечётный?
        inc (hl)
        inc hl
        ld a,(hl)
        jr nz,$+3
        inc (hl)
        RDMEM8_ac_ret ;bc=result, a=hx
rdsrc8_010_pc
        UNTESTED ;GOOD ;textshow
        get
        next
        ld c,a
        next
       ld a,hx
        ret

rdsrc8_x11
        bit 3,b
        jp nz,rdsrc8_111
rdsrc8_011 ;@(Rn)+ ;всегда +=2
       ld hx,c
        cp 0x0e
       jr z,rdsrc8_011_pc
        UNTESTED
        ld c,(hl)
        inc l
        ld b,(hl)
       push bc
      cp 0x0c
      jr c,$+3 ;не проверяется в textshow!
         inc bc
        inc bc
        ld (hl),b
        dec l
        ld (hl),c
       pop bc
        ld a,b
rdsrc8_addrfromaddr_ac
        ld l,c
        ld h,a
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
        RDMEM8_ac_ret ;c=result, a=hx ;TODO optimize
rdsrc8_011_pc
        UNTESTED ;GOOD ;leopol демо4(кот у цифр)
        get
        next
        ld c,a
        get
        next
        RDMEM8_ac_ret ;c=result, a=hx

rdsrc8_100
;100 -(Rn)
;при адресациях (reg)+ и -(reg), есть особый случай: если регистр -- это r6 или r7, то регистр всегда изменяется на 2, даже если команда байтовая
       ld hx,c
        cp 0x0e
       jr z,$;rdsrc8_100_pc
        GOOD ;leopol начало
        ld c,(hl)
        inc l
        ld b,(hl)
        dec bc
       cp 0x0c
       jr c,$+3
       dec bc ;sp/pc +=2
        ld (hl),b
        dec l
        ld (hl),c
        ld a,b
        RDMEM8_ac_ret ;bc=result, a=hx

rdsrc8_101
;101 @-(Rn) ;всегда -=2
       ld hx,c
        cp 0x0e
       jr z,$;rdsrc8_101_pc
        UNTESTED
        ld c,(hl)
        inc l
        ld b,(hl)
         dec bc
        dec bc
        ld (hl),b
        dec l
        ld (hl),c
        ld a,b
        jp rdsrc8_addrfromaddr_ac

rdsrc8_110
;110 Index: X(Rn): Rn+X is the address of the operand
       ld hx,c
        cp 0x0e
       jr z,rdsrc8_110_pc
        UNTESTED ;GOOD ;leopol начало
        get
        next
        add a,(hl)
        ld c,a
        inc l
        get
        next
        adc a,(hl) ;ac=Rn+X
        RDMEM8_ac_ret ;bc=result, a=hx
rdsrc8_110_pc
        UNTESTED ;GOOD ;leopol демо
        get
        next
        ld c,a
        get
        next
        ld b,a
        decodePC_to_ae
         ld h,a
        ld a,c
        add a,e
        ld c,a
        ld a,b
        adc a,h;d
        RDMEM8_ac_ret ;bc=result, a=hx

rdsrc8_111
;111 Index deferred: @X(Rn): Rn+X is the address of the address of the operand
       ld hx,c
        cp 0x0e
       jr z,rdsrc8_111_pc
        UNTESTED ;GOOD ;klad ;нет в leopol
        get
        next
        add a,(hl)
        ld c,a
        inc l
        get
        next
        adc a,(hl) ;ac=Rn+X
        jp rdsrc8_addrfromaddr_ac
rdsrc8_111_pc ;for morf
        UNTESTED ;GOOD ;leopol появление мышей2?
        get
        next
        ld c,a
        get
        next
        ld b,a
        decodePC_to_ae
        ld h,a
        ld l,e
        add hl,bc
        ld a,h
        ld c,l ;ac=Rn+X
        jp rdsrc8_addrfromaddr_ac

;;;;;;;;;;;;;;;;;;;;;;;;
rdport_c
;out: a=hx!!!
       ;ld b,a
        ld a,c
;FFB0=177660 регистр состояния клавиатуры (Разряд 6 - маска прерываний от клавиатуры. разряд доступен по записи и чтению. "0" - разрешено прерывание от клавиатуры; "1" - запрещено прерывание от клавиатуры. Разряд 7 - флаг состояния клавиатуры. Устанавливается в единицу при поступлении в регистр данных клавиатуры нового кода. Сбрасывается в "0" при чтении регистра данных клавиатуры.)
;FFB2=177662 Регистр данных клавиатуры
;bit #100,@#177716 (ffce): tapestate, Разряд 6 служит индикатором нажатия клавиши ("лог 0" - клавиша нажата, "лог 1" - клавиша отжата). Используется при реализации режима "повтор".
;177714: Регистр порта ввода-вывода
;177664 предназначен для указания начала экранного ОЗУ и организации рулонного сдвига экрана. При начальной установке экрана в регистре записывается значение 1330 (0x02d8). Изменение этого значения на 1 приводит к сдвигу изображения на экране по вертикали на 1 точечную строку. Сразу же после включения питания разряд 9 устанавливается в "1". При включении режима расширенной памяти разряд сбрасывается в "0". Разряды 8, 10-15 не используются.
        cp 0xb0 ;177660
        jr z,2f ;kbd state
         cp 0xb4 ;177662
         jr z,rdport_c_scrshift ;Bubbler
         cp 0xcc
         jr z,rdport_c_io ;Клад
         cp 0xc8 ;177710 ;Таймер работает независимо от работы программы. Содержимое счётчика времени определяется как результат функции PEEK(&O177710) и периодически уменьшается от S0 до 0 (рис. 10).
         jr z,rdport_c_timer ;kld19nm_bk10
        cp 0xce ;177716
        jr z,rdport_c_tapestate
        cp 0xcf
        jr z,rdport_c_tapestate_hsb
         ;cp 0x70 ;В *560м регистре имеются два бита, 6й и 7й. 7 бит *560го регистра устанавливается по reset или если во входной регистр *562 поступил новый байт, а если перед приемом байтов установить в 1 6й бит *560го регистра, то произойдет прерывание с вектором, адрес которого читается из регистра *566
         ;cp 0x72 ;*562й регистр - буфер приемника, оттуда считывается последний принятый байт, по записи регистр ничего не делает
         cp 0x74 ;В регистре *564 имеются тоже два бита, 6й и 7й, с тем же назначением, что и у приемника, 7й бит устанавливается в 0, когда процессор пишет байт в буфер передатчика, *566, и устанавливается в 1, когда заканчивается передача, т.е. когда буфер готов к приему следующего байта. Если при установке 7го бита был установлен 6й, то по готовности передатчика возникает прерывание с вектором, на 4 бОльшим, чем считываемое из регистра *566 значение.
         jr z,rdport_c_testconsole_txstate
         ;cp 0x76 ;буфер передатчика
        cp 0xb2
        jr nz,9f ;no ports
;kbd data
bk_oldkey=$+1
        ld c,0
bk_curkey=$+1
        ld a,0
        or a
        jr z,bk_port_getkey_no
        ld (bk_oldkey),a
        ld c,a
bk_port_getkey_no
        xor a
        ld (bk_curkey),a ;no message (INT прочитает новую кнопку)
       ld a,hx
       ld b,0
        ret
2 ;kbd state
        ;ld a,(iskeymessage) ;a7=no message
        ;rra
       ld a,(bk_curkey)
       sub 1
       sbc a,a ;CY=no message
        and 0x40
        ld c,a
       ld a,hx
       ld b,0
        ret
rdport_c_io
       ld a,hx
       ld bc,0
        ret
rdport_c_scrshift
       ld a,hx
       ld bc,0x02d8
        ret
9
;TODO прерывание ошибки шины
        jr $
       ld a,hx
        ret
rdport_c_timer ;kld19nm_bk10
;177710 ;Таймер работает независимо от работы программы. Содержимое счётчика времени определяется как результат функции PEEK(&O177710) и периодически уменьшается от S0 до 0 (рис. 10).
bktimer=$+1
        ld bc,0
        dec bc
        ld (bktimer),bc
       ld a,hx
        ret

rdport_c_testconsole_txstate
;В регистре *564 имеются тоже два бита, 6й и 7й, с тем же назначением, что и у приемника, 7й бит устанавливается в 0, когда процессор пишет байт в буфер передатчика, *566, и устанавливается в 1, когда заканчивается передача, т.е. когда буфер готов к приему следующего байта. Если при установке 7го бита был установлен 6й, то по готовности передатчика возникает прерывание с вектором, на 4 бОльшим, чем считываемое из регистра *566 значение.
       ld bc,0x80 ;ready
       ld a,hx
        ret
rdport_c_tapestate
;Разряд 6 служит индикатором нажатия клавиши ("лог 0" - клавиша нажата, "лог 1" - клавиша отжата). Используется при реализации режима "повтор".
;labyrinh ждёт в (0xffce) 0x80a0
iskeypressed=$+1
        ld a,0;(iskeypressed) ;0=not pressed
       ;ld a,(bk_curkey) ;не помогает
        sub 1
       ;scf ;не помогает (Клад не видит нажатий в игре)
        sbc a,a ;-1=not pressed
        and 0x40
       or 0xa0
        ld c,a
       ld a,hx
       ld b,0x80
        ret
rdport_c_tapestate_hsb ;for morf
       ld a,hx
       ld bc,0x0080
        ret

buserror
;из rdmem
JMPer_error
        ld sp,STACK
;TRAP to 4
        call getflags_bc
        putmemspBC
        decodePC_to_ae
        ld b,a
        ld c,e
        putmemspBC
        ld bc,0x06
        call rdmem_bc_to_bc
        call makeflags_frombc
        ld bc,0x04
        call rdmem_bc_to_bc
        ld d,b
        ld e,c
       _LoopC_JP

wrongcmd
        ld sp,STACK
;TRAP to 10
        call getflags_bc
        putmemspBC
        decodePC_to_ae
        ld b,a
        ld c,e
        putmemspBC
        ld bc,0x0a
        call rdmem_bc_to_bc
        call makeflags_frombc
        ld bc,0x08
        call rdmem_bc_to_bc
        ld d,b
        ld e,c
       _LoopC_JP


cls_bk
        ld a,(tpgs+0x40)
       ;jp clpga
clpga
        ld e,0
clpga_e
        SETPGC000
        ld hl,0xc000
       ld a,e
        ld d,h
        ld e,l
        inc e
        ld bc,0x3fff
       ld (hl),a;0
        ldir
        ret

	include "bkcmd.asm"

        align 256
tpgs
        ds 256 ;%10765432

        align 256
tmirror
tleftpixels
       dup 256
_7=$&0x80
_6=$&0x40
_5=$&0x20
_4=$&0x10
_3=$&0x08
_2=$&0x04
_1=$&0x02
_0=$&0x01
        db (_7>>7)+(_6>>5)+(_5>>3)+(_4>>1)+(_3<<1)+(_2<<3)+(_1<<5)+(_0<<7)
       edup

        align 256
ty
__=0
        dup 32
        dup 8
_=__-8 ;логический номер строки БК
       if (_<0)
_=200
       endif
       if (_>200)
_=200
       endif
       if ($&7)==0
_=200
       endif
        db 0xff&(_*40+4)
       if ($&7)
__=__+1
       endif
        edup
        edup
__=0
        dup 32
        dup 8
_=__-8 ;логический номер строки БК
       if (_<0)
_=200
       endif
       if (_>200)
_=200
       endif
       if ($&7)==0
_=200
       endif
        db (_*40+4)/256+0x80
       if ($&7)
__=__+1        
       endif
        edup
        edup


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

;ansipal ;можно убрать в ints
;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
        ;dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        ;dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
;по сравнению с цветами терминала переставлено:
;1-4
;3-6
	;dw 0xffff,0xfefe,0xefef,0xeeee,0xfdfd,0xfcfc,0xeded,0xecec
	;dw 0x1f1f,0x1e1e,0x0f0f,0x0e0e,0x1d1d,0x1c1c,0x0d0d,0x0c0c

pc_high
        db 0
iff1
	db 0
pgprog
        db 0 ;там можно хранить дополнительный код (напр., отладчик)
oldimer
        jp on_int
        jp 0x0038+3

print_bc_to_log
print_bc_to_log_addr=$+1
        ld hl,log
        ld (hl),c
        inc l
        ld (print_bc_to_log_addr),hl
        ret

        align 256
log
        ds 256
        
        align 256
	include "bktable.asm"

       if DEBUG
       align 256
oldpc
        ;dw 0
        ds 256
       endif

font
        incbin "866_code.fnt"
        display "tkoi=",$
tkoi
        dup 0xc0
        db $&0xff
        edup
        db "юабцдефгхийклмнопярстужвьызшэщч "
        db "ЮАБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧ "

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
