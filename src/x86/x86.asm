        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

DEBUG=0;1

	include "x86.ini"

STACK=0x4000

SHIFTCOUNTMASK=1 ;and 31
AFFLAG_16BIT=0;1 ;only for add_test
FASTADC16WITHFLAGS=0 ;NS

;PC=0x4000...
;SP=0x8000...
;data=0xC000...
        include "macros.asm"

        org PROGSTART
begin
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
;command line = "x86 <file to load>"
       ld (filenameaddr),hl
       ld hl,0x100
       ld (loadaddr),hl
       jr autoloadq
noautoload
        ld de,path
        OS_CHDIR
autoloadq
        jp init
initq
Reset       
        ld de,ansipal
        OS_SETPAL ;TODO с копированием во временную палитру
;TODO установить текстмод

        ld bc,0
        ld (_SS),bc
        countSS
        ld hl,0xfff0
        ld (_SP),hl
        encodeSP
        
        ld bc,0xf000
        ld (_CS),bc
        countCS      
        ld de,0xe000
        encodePC;memCS ;out: a=physpg, de=zxaddr
        ex de,hl
        ld de,trom0
;de=имя файла
;hl=куда грузим
        call loadfile_in_hl

        ld de,0xfff0

       if 1
        ld bc,0
        ld (_CS),bc
        countCS
loadaddr=$+1
        ld de,0x7c00;STARTPC
       push de
        encodePC;memCS ;out: a=physpg, de=zxaddr
       ld hl,0x9fff
       ld (0x4002),hl ;cs:0002=top segment of mem?
        ex de,hl
filenameaddr=$+1
        ld de,tprog
       ld a,h
       cp 0x41
       jr z,loadcom
;de=имя файла
;hl=куда грузим
        call loadfile_in_hl ;for bootbasic
        jr loadcomq
loadcom
        OS_OPENHANDLE
        ld a,b
        ld (curhandle),a
        ld a,(tpgs)
        ld d,a
        ld a,(tpgs+0x40)
        ld e,a
        ld a,(tpgs+0x80)
        ld h,a
        ld a,(tpgs+0xc0)
        ld l,a
        ;jr $
        call readfile_pages_dehl
        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
loadcomq
       pop de ;LD DE,STARTPC ;=IP(PC)
       endif
       
       
        LD IY,EMUCHECKQ
        ;EI 
       _LoopC_JP

quiter
        call swapimer ;сначала прерывания ничего не делают (iff0==0)
        QUIT
       
       if 0
jpiyer
        ld hl,jpiyer
        push hl
        jp (iy)
       endif
       if DEBUG
       align 256
oldpc
        ;dw 0
        ds 256       endif
EMUCHECKQ
       if DEBUG
      push de
       decodePC
       ld a,d
       ;sub 0x40+((STARTPC/256)&0x3f);0x7c
       cp 0x30
      pop de
      jr nc,$
       ld a,(_SP)
       rra
       jr c,$
       ;ld (oldpc),de
oldpcaddr=$+1
        ld hl,oldpc
        ld (hl),e
        inc l
        ld (hl),d
        inc l
        ld (oldpcaddr),hl

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

clpga
        SETPGC000
        ld hl,0xc000
        ld d,h
        ld e,l
        inc e
        ld bc,0x3fff
        ld (hl),l;0
        ldir
        ret     

;de=имя файла
;hl=куда грузим
loadfile_in_hl
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld h,0x7f ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	ret

readfile_pages_dehl
        ld a,d
        SETPGC000
        ld a,0xc100/256
        call cmd_loadpage
        ret nz
        ld a,e
        call cmd_loadfullpage
        ret nz
        ld a,h
        call cmd_loadfullpage
        ret nz
        ld a,l
cmd_loadfullpage
        SETPGC000
        ld a,0xc000/256
cmd_loadpage
;out: a=error, bc=bytes read
;keeps hl,de
        push de
        push hl
        ld d,a
        xor a
        ld l,a
        ld e,a
        sub d
        ld h,a ;de=buffer, hl=size
        call readcurhandle
        ld b,h
        ld c,l
        pop hl
        pop de
        or a
        ret

readcurhandle
curhandle=$+1
        ld b,0
        OS_READHANDLE
        ret

trom0
        db "compaq.bin",0 ;грузить в F000:E000, запускать с FFF0?
tprog
        db "atomchess.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h, 16h, 20h(system)
        ;db "basic.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h, 16h, 20h(system)
        ;db "lander.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 21h(allocate, vectors)
        ;db "ladybug.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        ;db "megapole.img",0 ;Его надо запускать в 0:0100h, требует bios int 10h, 21h#9 (print)
        ;DB "pc102782.bin",0

pgprog
        db 0 ;там можно хранить дополнительный код (напр., отладчик)

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

;keep here for quit
swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int
        jp 0x0038+3

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
       if 0;1 ;костыль для livin,tetris
       ld a,(curpgc000)
       ld hl,tpgs+0x40
       cp (hl)
       ;ld hl,0xfc28 ;tetris
       ld hl,0xffb2 ;livin
       jr nz,$+3
        dec (hl)
       endif      
        
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
       ld a,0xf7
       in a,(0xfe)
       and 0b10101
       jp z,quiter ;1+3+5 = quit

        call KEYB
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
        ;LD (iff2),A ;для NMI надо только iff1!
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
      ;костыль для неинициализированного прерывания
      ld a,(tpgs)
      SETPGC000
;int 0 - ??? (Goody, Ms Pacman) - убитый (в cs там лежит свободная память, но даже при cs=0 лажа)
;int 1 - cpu generated??? (есть обработчик в mision, но если его поставить, всё время стреляет)
;int 8 - timer
;int 9 - keyboard
      ld hl,(9*4+0xc000) ;ip
      ld bc,(9*4+0xc002) ;cs
     ld a,0x55
     rlca
     ld ($-2),a
     jr c,int_no8
      ld hl,(8*4+0xc000) ;ip
      ld bc,(8*4+0xc002) ;cs
     ;ld a,0x55
     ;rlca
     ;ld ($-2),a
     ;jr c,int_no8
     ; ld hl,(0*4+0xc000) ;ip
     ; ld bc,0 ;cs
int_no8
      ld a,h
      or l
     ;xor a
      jp z,STIer
      ;jr $
        
gotoint
;push cs; push ip (адрес после команды) (retf читает ip,cs)
      push bc
      push hl
       ld bc,(_CS)
        putmemspBC ;old CS
;абсолютный адрес ip, cs
        ld a,(tpgs)
        SETPGC000
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
       putmemspBC

     ;jp IRETer
       _LoopC_JP 

INT1
      ld a,(tpgs)
      SETPGC000
      ld hl,(1*4+0xc000) ;ip
      ld bc,(1*4+0xc002) ;cs
        jp gotoint
INT3
      ld a,(tpgs)
      SETPGC000
      ld hl,(3*4+0xc000) ;ip
      ld bc,(3*4+0xc002) ;cs
        jp gotoint
INTOer
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
        push bc
        push hl
        memSS
        pop hl
        pop bc
	ret

recountsp_dec
;вызывается до dec l!
        dec h
        push bc
        push hl
        memSS
        pop hl
        pop bc
	ret

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
        ld de,0x4000
	ret

PUTscreen_logpgc_zxaddrhl_datamhl_keephlpg_do
       push hl
       push bc
       call PUTscreen_logpgc_zxaddrhl_datamhl_do
       pop bc
        ld b,tpgs/256
        ld a,(bc)
        SETPGC000 ;как было
       pop hl
        ret

PUTscreen_cgadata
        ld c,(hl) ;4 pixels
        inc b ;(b=trecolour/256)
;a=1..4*0x40
       ld a,(bc)
       ld (cgarightpair),a
       ld a,c
       rlca
       rlca
       rlca
       rlca
       ld c,a ;или ещё одну таблицу
       ld a,(bc)
       ld (cgaleftpair),a
        ld a,(pgprog)
        SETPGC000

;экран CGA = 80 байт на строку (8000 байт один слой)
;экран ZXEGA = 40 байт на строку *4 слоя
;чередование строк CGA (нечётные идут вторым слоем с +8192) - по таблице 64-пиксельных блоков? если берём одну половину CGA экрана, то это из 500 блоков вычисляем 1000 (или если ещё разделить на 4 части, то из 125 блоков вычисляем 250)
;или придётся быстро делить на 80 и умножать на 40
;или по большой таблице в страничке
       ld c,l ;запомнить младшие 4 бита
       ld b,h ;запомнить bit 5
        ld a,h
        rra
        rr l
        rra
        rr l
        rra
        rr l
        and 0x03
        add a,+(tcga|0xc000)/256
        ld h,a
        res 0,l
        ld a,(hl)
        inc l
        ld h,(hl)
       rr c
        jr nc,$+4
        set 5,h
        xor c
        and 0xf8
        xor c
        ld l,a     
       bit 5,b ;бывший bit 5,h
        jr z,$+2+3+1
         ld bc,40
         add hl,bc
        ld a,(user_scr0_low) ;ok
        SETPGC000
cgaleftpair=$+1
     ld (hl),0
        ld a,(user_scr0_high) ;ok
        SETPGC000
cgarightpair=$+1
     ld (hl),0
        ret

PUTscreen_logpgc_zxaddrhl_datamhl_do
_PUTscreen_do_patch=$
_PUTscreen_do_patch_vgadata=0x044e ;ld c,(hl):inc b
        jr PUTscreen_textmode ;/ld c,(hl):inc b (b=trecolour/256)
;a=1..4*0x40
        add a,h
        ld h,a
;экран VGA = 320 байт на строку
;экран ZXEGA = 40 байт на строку *4 слоя
        scf
        rr h
        rr l ;CY=left/right
        jr c,PUTscreen_rightpixel
        sra h
        rr l
        ld a,(user_scr0_low) ;ok
        jr nc,$+5
        ld a,(user_scr0_high) ;ok
       push bc
        SETPGC000
       pop bc
        sra h
        rr l
        jr c,$+4
        res 5,h
     ld a,(bc)
     xor (hl)
     and 0b01000111
     xor (hl)
     ld (hl),a    
        ret
PUTscreen_rightpixel
        sra h
        rr l
        ld a,(user_scr0_low) ;ok
        jr nc,$+5
        ld a,(user_scr0_high) ;ok
       push bc
        SETPGC000
       pop bc
        sra h
        rr l
        jr c,$+4
        res 5,h
     ld a,(bc)
     xor (hl)
     and 0b10111000
     xor (hl)
     ld (hl),a    
        ret

PUTscreen_textmode40
_PUTscreen_do_patch_textmode40=256*(PUTscreen_textmode40-(_PUTscreen_do_patch+2))+0x18
       bit 3,h
       ret nz ;only for 40 pitch (sorryass)
PUTscreen_textmode
_PUTscreen_do_patch_textmode=256*(PUTscreen_textmode-(_PUTscreen_do_patch+2))+0x18
        ld c,(hl) ;colour
     ;inc b ;ld b,trecolour/256
;a=1..4*0x40
;hl=addr in screen=0..65535
;The VGA text buffer is located at physical memory address 0xB8000.
;25 строк по 80 слов: символ, атрибут (%FpppIiii - пересчитать в PIpppiii)
;как пересчитать строки по 160 байт (80 символов) в строки по 64 байта (128 виртуальных символов)? всего 2000 знакомест = 125 групп по 16 символов, можно по таблице получить адрес (2 байта) или номер виртуальной группы (их всего 200, т.е. 1 байт)
       push bc
;получаем номер группы по 16 символов:
;hl=0000GGGG gggXXXxA

;для 40 символов в строке группы по 8 символов:
;hl=00000GGG GgggXXxA

        ;xor l
        ;and 0xe0
        ;xor h
           ;rlca
           ;rlca
           ;rlca
        ld a,l  ;gggXXXxA
        srl a
        xor h 
PUTscreen_textmode_groupmask=$+1
        and 0xf0
        xor h   ;0gggGGGG
        
;для 40 символов в строке:
        ;ld a,l  ;GgggXXxA
        ;srl a   ;0GgggXXx
        ;xor h 
        ;and 0xf8
        ;xor h   ;0GgggGGG
        
;пересчитываем в номер группы на АТМ textmode:
        ld b,ttextaddr/256
        ld c,a
        ld a,(bc) ;gggGGGgg
        ld h,a
PUTscreen_textmode_srlcode=$+1
       srl b ;srl a для 40 символов в строке (для 80 вообще не нужно)
        xor l
PUTscreen_textmode_groupmask2=$+1
        and 0xe0 ;0xf0 для 40 символов в строке
        xor l
        ld l,a
        ld a,h
        and 0x1f
;пересчитываем в адрес группы на ATM textmode:
;hl=000GGGgg gggXXXxA ;+0x01c0 уже прибавлено к номеру группы как +56

;для 40 символов в строке (группы по 8 символов):
;hl=000GGGgg 0gggXXxA

         scf
         rra
        rr l
        jr c,PUTscreen_attr
         scf
         rra
        rr l
        jr nc,$+4
         or 0x20;set 5,h
        ld h,a
;RAM page #05 (#07):
;#21C0...#27FF - character codes of odd (1,3,...) characters (25 lines, every line is 64 bytes, of which only first 40 are significant).
;#01C0...#07FF - character codes of even (0,2,...) characters (ditto).
        ld a,(user_scr0_high) ;ok
        SETPGC000
       pop bc
       inc b ;ld b,t866toatm/256
       ld a,(bc)
        ld (hl),a
        ret
PUTscreen_attr
         rra
        rr l
        inc l
        jr c,$+5
         or 0x20
         dec l
        ld h,a
;RAM page #01 (#03):
;#21C0...#27FF - attributes of even(!) characters (ditto).
;#01C1...#07FF - attributes of odd(!) characters (ditto).
        ld a,(user_scr0_low) ;ok
        SETPGC000
       pop bc ;c=%ppppiiii
        ld a,c
        rra
        xor c
        and 0b00111000
        xor c
        and 0b10111111
        bit 3,c
        jr z,$+4
        or 0b01000000
        ld (hl),a ;%pipppiii
        ret

_PUTscreen_do_patch_cgadata=256*(PUTscreen_cgadata-(_PUTscreen_do_patch+2))+0x18

	include "keyscan.asm"
       display "--",$
	include "rmbyte.asm"
       display "--",$
	include "rmbytcmd.asm"
       display "--",$
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
        incbin "../kernel/866toatm"

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

ansipal
;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
        ;dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        ;dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
;по сравнению с цветами терминала переставлено:
;1-4
;3-6
	dw 0xffff,0xfefe,0xefef,0xeeee,0xfdfd,0xfcfc,0xeded,0xecec
	dw 0x1f1f,0x1e1e,0x0f0f,0x0e0e,0x1d1d,0x1c1c,0x0d0d,0x0c0c

pc_high     db 0

_DIRECTION
	db 0
iff1	db 0xff
;iff2	db 0 ;TODO unneeded?

;timer
;	dw 0
        
;000... -> 000 ;al
;001... -> 010 ;cl
;010... -> 100 ;dl
;011... -> 110 ;bl
;100... -> 001 ;ah
;101... -> 011 ;ch
;110... -> 101 ;dh
;111... -> 111 ;bh
       ds _AX+128-$
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

;генерируется для textmode
        align 256
       macro dbrrc3 data
        db (data>>3)+((data<<5)&0xe0)
       endm
ttextaddr
        dup 128
_=$&0xff

      if 0 ;40 символов в строке

; |младший
;0GgggGGG -> 0GGGGggg:
_=((_&0x07)<<4)+((_&0x78)>>3)
      
      else ;80 символов в строке

;0gggGGGG -> 0GGGGggg:
_=((_&0x0f)<<3)+((_&0x70)>>4)
       
      endif

       if _<125
_=_/5*8+(_-(_/5*5))+56
        dbrrc3 _
       else
        dbrrc3 255
       endif

        edup

        display "killable=",$

;killable
init
        OS_HIDEFROMPARENT
        ld e,6+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ;ld e,0
        ;OS_SETSCREEN
        ;ld e,0
        ;OS_CLS
        ;ld e,1
        ;OS_SETSCREEN
        ;ld e,0
        ;OS_CLS

        ld sp,STACK
        ;ld de,diskname
        ;OS_OPENHANDLE
        ;ld a,b
        ;ld (diskhandle),a

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld a,e
        ld (pgprog),a

        ld a,(user_scr0_high) ;ok
        call clpga
        ld a,(user_scr0_low) ;ok
        call clpga

        ld hl,tpgs
        ld b,64 ;TODO меньше для АТМ2
filltpgs0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
     ld a,l
     add a,-40
     cp 4-40 ;чистим первые 4 страницы и экран с остатком памяти ;para512 ожидает чистую память после себя, pillman ожидает чистый экран
     ;jr nc,filltpgs0_noclear
       push de
       push hl
       ld a,e
       call c,clpga
       pop hl
       pop de
filltpgs0_noclear
        pop bc
       ld a,l
       rrc l
       rrc l
        ld (hl),e
       ld l,a
        inc l
        djnz filltpgs0
       
;0xa0000 (pg 40): 4 pages for screen
;0xb8000 (pg 46): 1 page for textmode
        ld h,tscreenpgs/256
        ld bc,4*256+40
        xor a
filltscreenpgs0
        add a,0x40
       ld l,c
       rrc l
       rrc l
        ld (hl),a
            ;dec l     ;
            ;ld (hl),a ;test backbuffer
        inc c
        djnz filltscreenpgs0
       ld (tscreenpgs+0x8b),a ;for textmode

        call swapimer ;сначала прерывания ничего не делают (iff0==0)

        jp initq
path
        db "x86",0
skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

        display "lowend=",$
        ds 0x3fc0-$
        ds 0x4000-$
        include "ints.asm"
end

	savebin "x86.com",begin,end-begin

	LABELSLIST "../../us/user.l"
