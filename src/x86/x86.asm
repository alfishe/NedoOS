        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

DEBUG=0
DEBUGSTOP=0;1
DEBUG03=0
FULL1M=1;0

	include "x86.ini"

STACK=0x4000

SHIFTCOUNTMASK=1 ;and 31
AFFLAG_16BIT=1 ;only for add_test
FASTADC16WITHFLAGS=0 ;NS

maxszPUTscreen=0x50

;PC=0x4000...
;SP=0x8000...
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
       if DEBUGSTOP
      push de
       decodePC
      if 1
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
       ;ld a,(_CS+1)
       ;or a
       ;jr z,$
       ;ld a,d
       ;sub 0x40+((STARTPC/256)&0x3f);0x7c
       ;or e;cp 0x30
       ;cp 0x97
      ld hl,0x03ce;iret;0x0304;int;0x2d09;0x2976
      or a
      sbc hl,de
      pop de
      ;jr nc,$
      call z,breakpoint
       endif
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD b,(HL)
        INC H
        LD H,(HL)
        ld L,b ;чётный для всех rm-команд
        JP (HL) 
breakpoint
        jr $

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
        
				;(65536 / 50) * 18,206 Hz
				;23862,96832 = $5D37
timer_frq = $+1
        ld de,0x5D37
timer_cnt = $+1
        ld hl,0x0000
	add hl,de
	ld (timer_cnt),hl
	jr nc,timer_inc_skip
timer = $+1
        ld hl,0x0000
	inc hl
	ld (timer),hl
timer_inc_skip
	;ld hl,(timer)
	;inc hl
	;ld (timer),hl

       ld a,(curpg4000) ;ok
       push af
       ld a,(pgprog)
       SETPG4000
        call KEYB ;TODO ниже
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

debugon=$
        scf;or a ;для нормального старта пока пропускаем все активности до JumpIn
        jr c,imerskipdebug

       ld a,0xf7
       in a,(0xfe)
       push af
       and 0b10101
       jp z,quiter ;1+3+5 = quit
       pop af
       and 0b11000 ;4+5
       jp z,GotoDebugger

       LD A,(iff1)
       OR A
       jr NZ,IMEREI
imerskipdebug
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
GotoDebugger
;перед входом в отладчик завершаем тек.команду (перехват на EMULOOP)
        LD (keepemuchecker),IY
        LD IY,IMDEBUG
        POP HL,AF
        EI 
        RET 
IMDEBUG
       ld a,55 ;scf
       ld (debugon),a

;запоминаем регистры в переменные
       decodePC ;de=old PC
       ld (curpc),de
       ;exx
       ;ex af,af' ;'
       ;push af
       ;pop hl
       call getflags_bc
       ld (curflags),bc

       ld a,(pgprog)
       SETPG4000
       
        ld de,ansipal
        OS_SETPAL
        call Debugger

        ld a,(curgfxmode)
        call INT_setgfx_a
        call redraw_screen_memory

       ld bc,(curflags)
       call makeflags_frombc
       
       ld a,55+128 ;or a
       ld (debugon),a
        ld iy,(keepemuchecker)
       ld de,(curpc)
       _LoopC_JP

IMINT
keepemuchecker=$+2
        LD IY,0
iykeeper_on=$
        or a ;scf=on
        jr nc,IMINT_noiykeeperdata
        ld iy,(iykeeper_iy)
IMINT_noiykeeperdata
       ;LD (retfromim),DE ;для индикации времени обработки прерыв
       
;NS:
;Planeta запускаетсо кода [0000:041A] != [0000:041c]
;это на вид именно сиистемные переменные
;они дрыгаются так же в досе
;там еще всякие щифты рядом
;это начало и конец буфера клавиатуры
       
      ld a,(tpgs)
      SETPGC000

        ;call KEYB ;TODO в странице
GKEYADR=$+1
        LD HL,KEYBUFF ;адрес конца списка
        ld (0x041c+0xc000),hl
        ld hl,KEYBUFF
        ld (0x041a+0xc000),hl

;int 0 - Переполнение при делении (Goody, Ms Pacman) - убитый (в cs там лежит свободная память, но даже при cs=0 лажа)
;int 1 - cpu generated??? Пошаговое прерывание (есть обработчик в mision, но если его поставить, всё время стреляет)
;int 8 - timer (ratillery for music)
;int 9 - keyboard
;int 1c - timer Пользовательское прерывание по таймеру (pitman)

;INT 00h: Переполнение при делении.
;INT 01h: Пошаговое прерывание.
;INT 02h: Немаскируемое прерывание.
;INT 03h: Прерывание по точке.
;INT 04h: Прерывание по переполнению.
;INT 05h: Печать экрана. 
;INT 06h: Неверная команда.
;INT 07h: Сопроцессор отсутсвует..
;INT 08h: IRQ 0 Прерывание от таймера.
;INT 09h: IRQ 1 Прерывание от клавиатуры. 
;INT 0Ah: IRQ 2 Оборудование.
;INT 0Bh: IRQ 3 Оборудование (COM 2).
;INT 0Ch: IRQ 4 Оборудование (COM 1).
;INT 0Dh: IRQ 5 Оборудование (LPT, на оригинальном IBM PC - жёсткий диск).
;INT 0Eh: IRQ 6 Прерывание от дискеты.
;INT 0Fh: IRQ 7 Оборудование.
;INT 10h: Видео сервис.
;INT 11h: Список оборудования.
;INT 12h: Размер используемой памяти.
;INT 13h: Дисковый ввод/вывод.
;INT 14h: Ввод/вывод через COM порт.
;INT 15h: Дополнительные функции.
;INT 16h: Ввод/вывод клавиатуры, управление процессором и кэшем.
;INT 17h: Ввод/вывод LPT.
;INT 18h: Возврат в BIOS.
;INT 19h: Загрузка.
;INT 1Ah: Ввод/вывод таймера и сервисы PCI BIOS.
;INT 1Bh: Прерывание клавиатуры.
;INT 1Ch: Пользовательское прерывание по таймеру
;INT 1Dh: Видео параметры
;INT 1Eh: Параметры дискет
;INT 1Fh: Символы графики

;INT 70h: IRQ 8 Оборудование (RTC).
;INT 71h: IRQ 9 Оборудование.
;INT 72h: IRQ 10 Оборудование.
;INT 73h: IRQ 11 Оборудование.
;INT 74h: IRQ 12 Оборудование (Мышь).
;INT 75h: IRQ 13 Оборудование (Сопроцессор 80287+).
;INT 76h: IRQ 14 Оборудование (Жёсткий диск).
;INT 77h: IRQ 15 Оборудование.

      ld hl,(9*4+0xc000) ;ip
      ld bc,(9*4+0xc002) ;cs
     ld a,0x55
     rlca
     ld ($-2),a
     jr c,int_no8
      ld hl,(8*4+0xc000) ;ip
       ld bc,0x0221
       or a
       sbc hl,bc
       add hl,bc
       jr z,int_1c ;костыль для PATROL - 0221 не работает
      ld bc,(8*4+0xc002) ;cs
     ld a,0x55
     rlca
     ld ($-2),a
     jr c,int_no8
int_1c
      ld hl,(0x1c*4+0xc000) ;ip
      ld bc,(0x1c*4+0xc002) ;cs
int_no8
      ld a,h
      or l
     ;xor a
      jp z,STIer ;костыль для неинициализированного прерывания
      ;jr $
        
gotoint
;push cs; push ip (адрес после команды); push flags (iret читает flags,ip,cs)
      push bc
      push hl
       ld bc,(_CS)
        putmemspBC ;old CS
;абсолютный адрес ip, cs
        ;ld a,(tpgs)
        ;SETPGC000
      pop hl
      pop bc
        ;ld hl,(9*4+0xc000) ;ip
        ;ld bc,(9*4+0xc002) ;cs
       push hl
        ld (_CS),bc ;new CS
        countCS
       decodePC
        LD b,d
        ld c,e ;=old PC
       pop de ;new PC
        putmemspBC

       call getflags_bc
        set 1,b ;interrupt enable
       putmemspBC

     jp JRer_qslow ;_LoopC_JP 

INT1
       UNTESTED
      ld a,(tpgs)
      SETPGC000
      ld hl,(1*4+0xc000) ;ip
      ld bc,(1*4+0xc002) ;cs
        jp gotoint
INT3
       UNTESTED
      ld a,(tpgs)
      SETPGC000
      ld hl,(3*4+0xc000) ;ip
      ld bc,(3*4+0xc002) ;cs
        jp gotoint
INTOer
       UNTESTED
	exx
	ld a,e ;overflow data
	and 0x40
	rla
	xor e
	exx
	JP p,NOPer
      ld a,(tpgs)
      SETPGC000
      ld hl,(4*4+0xc000) ;ip
      ld bc,(4*4+0xc002) ;cs
        jp gotoint

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

countXS_bc_to_ahl
	ld h,b
	ld l,c
	xor a
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
        ret

       if 1
getmemspBCpp
        ld bc,(_SP)
	ld hl,(ss_LSW)
	ld a,(ss_HSB)
        ADDSEGMENT_hl_abc_to_ahl
        inc bc
        inc bc
        ld (_SP),bc
	ld c,a
	ld b,tpgs/256
	set 7,h
        res 6,h
	ld a,(bc)
	SETPG8000
        ld c,(hl)
        inc l
        ld b,(hl)
        ret nz
        push bc
        ld hl,(_SP)
        dec hl;inc hl
        memSS
        pop bc
        ld b,(hl)
	ret
recountsp_inc
        push bc
        ld hl,(_SP)
        inc hl
        memSS
        pop bc
	ret
       else
;не работает при некруглых сегментах
putmemspBC_pp
        ;LD HL,(_SP)
	inc l
	dec l
	call z,recountsp_dec
	dec l
       push hl
       res 6,h
       set 7,h
	ld (hl),b
       pop hl
	call z,recountsp_dec
	dec l
        LD (_SP),HL	
       res 6,h
       set 7,h
	ld (hl),c
       pop hl
        ld bc,_putmemspBC_skipsize
        add hl,bc
        jp (hl)

getmemspBC_pp
        ;LD HL,(_SP)
       push hl
       res 6,h
       set 7,h
	ld c,(hl)
       pop hl
        inc l
	call z,recountsp_inc
       push hl
       res 6,h
       set 7,h
	ld b,(hl)
       pop hl
        inc l
	call z,recountsp_inc
        LD (_SP),HL
       pop hl
       push bc
        ld bc,_getmemspBC_skipsize
        add hl,bc
       pop bc
        jp (hl)

recountsp_inc
	inc h
        jr recountsp_incdec
recountsp_dec
;вызывается до dec l!
        dec h
recountsp_incdec
        push bc
        push hl
        memSS
        pop hl
        pop bc
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
        ds maxszPUTscreen;0x52;100

	;include "keyscan.asm"
       display "--",$
	include "rmbyte.asm"
       display "--",$
	include "rmbytcmd.asm"
       display "--",$
	include "extcmd.asm"
	include "x86cmd.asm"
       display "--",$
	include "x86math.asm"
       display "--",$
	include "x86logic.asm"
       display "--",$
	include "ports.asm"
       display "--",$

        align 256
tpgs
        ds 256 ;%10765432
tscreenpgs
        ds 256,tscreenpgs/256 ;%10765432 ;номер страницы в экране или tscreenpgs/256, если не экранная
trecolour
;trecolour = tscreenpgs+256
;сюда копируется либо wastrecolour, либо wast866toatm
        incbin "../_sdk/codepage/866toatm"

        align 256
;8 r16s
_AX
_AL     DB 0
_AH     DB 0
_CX
_CL     DB 0
_CH     DB 0
_DX
_DL     DB 0
_DH     DB 0
_BX
_BL     DB 0
_BH     DB 0
_SP     DW 0 ;use encodeSP (with hl=(_SP)) after write!
_BP     DW 0
_SI     DW 0
_DI     DW 0
;0x10
;4 sregs + 2
_ES     DW 0
_CS     DW 0
_SS     DW 0
_DS     DW 0
_FS     DW 0
_GS     DW 0
curpc    dw 0 ;for debugger
curflags dw 0 ;for debugger

        ds _ES+0x10-$
;0x20
es_HSB	db 0
        nop
cs_HSB	db 0
        nop
ss_HSB	db 0
        nop
ds_HSB	db 0
        nop
fs_HSB	db 0
        nop
gs_HSB	db 0

        ds _ES+0x20-$
;0x30
es_LSW	dw 0
cs_LSW	dw 0
ss_LSW	dw 0
ds_LSW	dw 0
fs_LSW	dw 0
gs_LSW	dw 0
     display $

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
;_DIRECTION
	;db 0
iff1
	db 0
pgprog
        db 0 ;там можно хранить дополнительный код (напр., отладчик)
oldimer
        jp on_int
        jp 0x0038+3
        
;000... -> 000 ;al
;001... -> 010 ;cl
;010... -> 100 ;dl
;011... -> 110 ;bl
;100... -> 001 ;ah
;101... -> 011 ;ch
;110... -> 101 ;dh
;111... -> 111 ;bh
       ds _AX+128-$
     display "=",$
;decode rm
        dup 8
        db _AL&0xff
        db _CL&0xff
        db _DL&0xff
        db _BL&0xff
        db _AH&0xff
        db _CH&0xff
        db _DH&0xff
        db _BH&0xff
        edup
       ds _AX+192-$
;decode r8 (TODO поменять местами с decode rm, т.к. rm нужно чаще)
        ds 8,_AL&0xff
        ds 8,_CL&0xff
        ds 8,_DL&0xff
        ds 8,_BL&0xff
        ds 8,_AH&0xff
        ds 8,_CH&0xff
        ds 8,_DH&0xff
        ds 8,_BH&0xff
        align 256
	include "x86table.asm"

       if DEBUGSTOP
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
        include "decoder.asm"
        include "opcodes.asm"
        include "nametables.asm"
        include "functions.asm" ;prchar for disasm 
        include "routines.asm" 
        include "debugger.asm" 
        include "editline.asm" 
; Чтение их памяти по адресу HL++
; _param_ip -- это РЕАЛЬНЫЙ ip, который должен быть сконвертирован
;              на память спектрума
; ----------------------------------------------------------------------

read:       push    hl
            ld      hl, (_param_ip)
            ;ld      a, (hl)
           call Debugger_GetMem_hl_to_a
            inc     hl
            ld      (_param_ip), hl
            pop     hl
            ret

; Реальный IP (в данном случае совпадает с адресом в памяти спектрума)
_param_ip:  defw    0

Debugger_PutMem_hl_a
       push bc
       push hl
       push af
	ld bc,(cs_LSW)
	ld a,(cs_HSB)
        ADDSEGMENT_hl_abc_to_ahl
	ld c,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       pop af
        ld (hl),a
       pop hl
       pop bc
        ret
Debugger_GetMem_hl_to_a
       push bc
       push hl
	ld bc,(cs_LSW)
	ld a,(cs_HSB)
        ADDSEGMENT_hl_abc_to_ahl
	ld c,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        ld a,(hl)
       pop hl
       pop bc
        ret

        align 256
t866toatm
        incbin "../_sdk/codepage/866toatm"

        display "end=",$
end

	savebin "x86.com",begin,end-begin

	LABELSLIST "../../us/user.l"
