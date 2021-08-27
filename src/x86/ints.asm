init
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
        ld a,h
        ld (tpgs+0xcf),a ;pgrom0 (#0x3f)
        ld e,l
        OS_DELPAGE

        ld a,(user_scr0_high) ;ok
        call clpga
        ld a,(user_scr0_low) ;ok
        call clpga

        ld de,tallmem
        OS_OPENHANDLE
        ld a,b
        ld (curhandle),a

        ld hl,tpgs
       if FULL1M
        ld b,64
       else
        ld b,48 ;для АТМ2
       endif
filltpgs0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
     ;ld a,l
     ;add a,-40
     ;cp 4-40 ;чистим первые 4 страницы и экран с остатком памяти ;para512 ожидает чистую память после себя, pillman ожидает чистый экран
     ;;jr nc,filltpgs0_noclear
       push de
       push hl
       ld a,e
       ;call c,clpga
       call clpga
        SETPGC000
        ld de,0xc000
        ld hl,0x4000
        ;call readcurhandle
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

        call closecurhandle

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

        ld bc,0xf000
        ld (_CS),bc
        countCS
        ld bc,0xe000
        ;encodePC;memCS ;out: a=physpg, de=zxaddr
	ld hl,(cs_LSW)
	ld a,(cs_HSB)
        ADDRSEGMENT_chl_bHSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ld de,trom0
;de=имя файла
;hl=куда грузим
        call loadfile_in_hl
        ;ld de,0xfff0

        call swapimer ;сначала прерывания ничего не делают (iff1==0)

        jp initq

resetpp
        xor a
        ld (iff1),a

        call INT_setgfxTEXT80

        ld bc,0x0c02;0400
        ld (_CS),bc
        countCS
        ld (_DS),bc
        countDS
        ld (_ES),bc
        countES
        ld (_SS),bc
        countSS
        ld hl,0xfffe;0xfff0
        ld (_SP),hl
        encodeSP
       ;ld a,(tpgs+0x40) ;cs
       ;SETPGC000
       ;ld hl,0x9fff
       ;ld (0xc002),hl ;cs:0002=top segment of mem?
	ld hl,0x0002
	ld bc,(cs_LSW)
	ld a,(cs_HSB)
        ADDRSEGMENT_chl_bHSB
         ld lx,c
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       ld bc,0x9fff
        _PUTm16_oldpglx

loadaddr=$+1
        ld de,0x7c00;STARTPC
       push de
        ;encodePC;memCS ;out: a=physpg, de=zxaddr
filenameaddr=$+1
        ld hl,tprog
       ld a,d
       dec a;cp 0x41
       jr z,loadcom
       ; set 7,d;STARTPC
       ; ex de,hl
       ;ld a,(tpgs+0x80) ;2-я страница сегмента программы = 3-я страница памяти (#2)
       ;SETPGC000
	ex de,hl
       ;push de
	ld bc,(cs_LSW)
	ld a,(cs_HSB)
        ADDRSEGMENT_chl_bHSB
         ld lx,c
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       ;pop de
;de=имя файла
;hl=куда грузим
        call loadfile_in_hl ;for bootbasic
        jr loadcomq
loadcom
        call loadcompp
loadcomq
       pop de ;LD DE,STARTPC ;=IP(PC)

        LD IY,EMUCHECKQ
        ld a,-1
        ld (iff1),a
     jp JRer_qslow ;_LoopC_JP

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

farquiter
        call swapimer
        ld hl,0
        QUIT

trom0
        db "compaq.bin",0 ;грузить в F000:E000, запускать с FFF0?
tallmem
        db "em87_1_3_installed.BIN",0 ;грузить во всю память
tprog
        ;db "atomchess.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h, 16h, 20h(system)
        db "basic.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h, 16h, 20h(system)
        ;db "lander.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 21h(allocate, vectors)
        ;db "ladybug.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        ;db "megapole.img",0 ;Его надо запускать в 0:0100h, требует bios int 10h, 21h#9 (print)
        ;DB "pc102782.bin",0
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

loadcompp
;hl=filename
        ex de,hl
        OS_OPENHANDLE
        ld a,b
        ld (curhandle),a

        ld hl,0x0100
	ld bc,(cs_LSW)
	ld a,(cs_HSB)
        ADDRSEGMENT_chl_bHSB
	ld b,tpgs/256
       push bc
       push hl
        ld a,(curhandle)
        ld b,a
        OS_GETFILESIZE ;b=handle, out: dehl=file size
       pop de
       pop bc
loadcompp0
;de=текущий адрес загрузки (c000+)
;hl=сколько байтов осталось грузить
;bc=tpgs+текущий номер страницы
        push bc
        ld a,(bc)
        SETPGC000
       push hl ;сколько байтов осталось грузить
       add hl,de
       sbc hl,de
       jr nc,loadcompp_nocroppg
       ld hl,1
       ;scf
       sbc hl,de
loadcompp_nocroppg
        call readcurhandle
        ld b,h
        ld c,l
       pop hl ;сколько байтов осталось грузить
       or a
       sbc hl,bc
       ld de,0xc000
        pop bc
        ld a,c
        rlca
        rlca
        inc a
        rrca
        rrca
        ld c,a ;next pg
        ld a,h
        or l
        jr nz,loadcompp0
       if 0
        ld a,(tpgs+0x40)
        ld d,a
        ld a,(tpgs+0x80)
        ld e,a
        ld a,(tpgs+0xc0)
        ld h,a
        ld a,(tpgs+0x01)
        ld l,a
        ;jr $
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
        call cmd_loadfullpage
       endif
closecurhandle
        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
        ret


INT_gettimer
;int 1Ah ;AL= 24 hours overflow flag, CX:DX = 32bit timer
;_microtimer=$+1
;        ld hl,0
;        inc hl
;        ld (_microtimer),hl
       ld hl,(timer)
       ;srl h
       ;rr l
       ;srl h
       ;rr l
        ld (_DX),hl
       ret;_Loop_

far_int
;int 0x20 ;system
;int 0x16 ;ah=0: input key -> al
;int 0x10 ;ah=0x0e: print al (зачем bx=7?)
;int 0x10 ;ah=0x00: set gfx mode = al (0x13)
	cp 0x10
	jr z,INT10
	cp 0x16
	jp z,INT16
	cp 0x1a
	jr z,INT_gettimer
        cp 0x21
        jp z,INT21
        cp 0x80
        ret nc;jr nc,intlooper ;костыль для megapole
        cp 0x20
        jp z,quiter

        cp 0x11
        ret z ;TODO for shamus

        cp 0x13
        ret z ;TODO for digger
        cp 0x60
        ret z ;TODO for digger

        cp 0x65
        ret z ;TODO for NSTALKER

 if debug_stop = 0
 ret
 else
 jr $
 endif

;intlooper
;       _Loop_
printstring
;TODO AL = Write mode
;TODO BH = Page Number
;BL = Color
;CX = Number of characters in string
;DH = Row, DL = Column
;ES:BP = Offset of string
       push de
     DISABLE_IFF0_KEEP_IY
       ld a,(_BL)
       ld e,a ;%PpppIiii
      rra
      xor e
      and 0x38
      xor e
      and 0xbf ;%P0pppiii
      bit 3,e
      jr z,$+4
      or 0x40
      ld e,a ;%PIpppiii
       OS_SETCOLOR
       ld hl,(_DX)
       ;ld e,h
       ;ld d,l
       ex de,hl
       OS_SETXY
       ld bc,(_CX)
       ld hl,(_BP)
printstringbp0
       push bc
       push hl
       getmemES
       ;ld a,'@'
;a=char
       PRCHAR
       pop hl
       pop bc
       cpi
       jp pe,printstringbp0
      ;ld (_BP),hl ;так хуже в pitman
     ENABLE_IFF0_REMEMBER_IY ;иначе pop iy запорет iy от обработчика прерывания
       pop de
       ret;_Loop_

INT10
        ld a,(_AH)
        or a
        jp z,INT_setgfx
        cp 0x13
        jp z,printstring
        cp 0x0e
        jp z,INT_printal
        cp 0x01
        ret z;jr z,intlooper ;TODO disable caret
        cp 0x02
        jp z,INT_setcursorposition ;set cursor position
        cp 0x03
        jp z,INT_getcursorposition ;get cursor position
        cp 0x09
        jp z,INT_prcharandattr ;Писать символ и атрибут в текущей позиции курсора (zaxon, km, nstalker, pipes)
        cp 0x0a
        jp z,INT_prcharnoattr ;Write character only at cursor position	AH=0Ah	AL = Character, BH = Page Number, CX = Number of times to print character
        cp 0x0b
        ret z ;TODO for zaxon Set background/border color	AH=0Bh, BH = 00h	BL = Background/Border color (border only in text modes)
        cp 0x10
        ret z ;TODO for plutina AL = 1A  read color page state
        cp 0x11
        jp z,INT_setgfx ;blue (установка шрифта? не вызывает setgfx!!!)
        cp 0x0f
        jp z,INT_getgfx ;blue

 if debug_stop = 0
 ret
 else
 jr $
 endif

;03h  Узнать позицию и размер курсора
;Вход:
;BH = видео страница
;Выход:
;DH = текущая строка курсора (см. функцию 02H)
;DL = текущий столбец курсора (см. функцию 02H)
;CH = текущая начальная строка экрана, содержащая курсор (см. функцию 01H) 0..7 внутри знакоместа?
;CL = текущая конечная строка экрана, содержащая курсор (см. функцию 01H)
INT_getcursorposition
        ld hl,(intcursorposition)
        ld (_DX),hl
        ld hl,0 ;TODO
        ld (_CX),hl
        ret


INT_setcursorposition
;Вход:
;BH = видео страница
;DH = номер строки (считая от 0)
;DL = номер столбца (считая от 0)
        ld hl,(_DX)
        ld (intcursorposition),hl
        ret

INT_prcharnoattr
INT_prcharandattr
;Писать символ и атрибут в текущей позиции курсора (zaxon, km, nstalker, pipes)
;Вход:
;BH = номер видео страницы
;AL = записываемый символ (ASCII код)
;CX = счетчик (сколько экземпляров символа записать)
;BL = видео атрибут (текстовый режим) или цвет (графический режим)
;Примечание:
;При записи с помощью этой функции курсор не сдвигается!
;В графических режимах не рекомендуется использовать значение CX, отличное от единицы, т.к. не везде правильно реализован повтор символа
;Если программа работает под управлением PTS-DOS, то значения в BH, BL и CX могут быть проигнорированны)
       push de
        ld hl,(_AL)
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font;0x1a6e+0xa000
        add hl,bc
        ;ld a,(tpgs+0xcf) ;last page of BIOS
        ;SETPG8000 ;TODO fix for fast stack!!!
       push hl
intcursorposition=$+1
        ld de,0
        ld l,d
        ld h,0
         ld b,h
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc ;y*5
        add hl,hl
        add hl,hl
        add hl,hl ;y*40
        add hl,hl
        add hl,hl
        add hl,hl ;y*40*8
        ld c,e
         set 7,h
         set 6,h
       pop de ;gfx
    if 0
       push bc ;x
       push de ;gfx
       push hl ;y*40*8 + 0xc000
        add hl,bc
        ld b,8
_leftpix=0x07
_rightpix=0x38
INT_prchar0
        push bc
        push de
        ld a,(de)
        ld e,a
        ld a,(user_scr0_low) ;ok
        SETPGC000
        xor a
        bit 7,e
        jr z,$+4
        or _leftpix
        bit 6,e
        jr z,$+4
        or _rightpix
        ld (hl),a
        set 5,h
        xor a
        bit 3,e
        jr z,$+4
        or _leftpix
        bit 2,e
        jr z,$+4
        or _rightpix
        ld (hl),a
        ld a,(user_scr0_high) ;ok
        SETPGC000
        xor a
        bit 1,e
        jr z,$+4
        or _leftpix
        bit 0,e
        jr z,$+4
        or _rightpix
        ld (hl),a
        res 5,h
        xor a
        bit 5,e
        jr z,$+4
        or _leftpix
        bit 4,e
        jr z,$+4
        or _rightpix
        ld (hl),a
        ld bc,40
        add hl,bc
        pop de
        inc de
        pop bc
        djnz INT_prchar0
        ld a,(tpgs+0x8b) ;cga screen
        SETPGC000
       pop hl ;y*40*8 + 0xc000 = y*320 + 0xc000 = y*(320/4)*4 + 0xc000
       pop de ;gfx
       pop bc ;x
    endif
        add hl,bc
        add hl,bc
       ;jr $
        call cgaput2bytes
        set 5,h
        call cgaput2bytes
        ld bc,80-0x2000
        add hl,bc
        call cgaput2bytes
        set 5,h
        call cgaput2bytes
        ld bc,80-0x2000
        add hl,bc
        call cgaput2bytes
        set 5,h
        call cgaput2bytes
        ld bc,80-0x2000
        add hl,bc
        call cgaput2bytes
        set 5,h
        call cgaput2bytes
        ;ld bc,80-0x2000
        ;add hl,bc
       pop de
        ret

cgaput2bytes
        ld a,(de)
        ld c,a
        xor a
        rl c
        rla
        add a,a
        rl c
        rla
        add a,a
        rl c
        rla
        add a,a
        rl c
        rla
        ld b,a
        add a,a
        or b
        ld (hl),a
       push bc
        ld c,0x8b
        _PUTscreen_logpgc_zxaddrhl_datamhl_keephlpg
       pop bc
        
        inc l
        xor a
        rl c
        rla
        add a,a
        rl c
        rla
        add a,a
        rl c
        rla
        add a,a
        rl c
        rla
        ld c,a
        add a,a
        or c
        ld (hl),a
        ld c,0x8b
        _PUTscreen_logpgc_zxaddrhl_datamhl_keephlpg

        dec l
        inc de
        ret

INT21
        ld a,(_AH)
;TODO 00h	Program terminate (plutina), с ожиданием клавиши
        cp 0x09
        jr z,INT_printstringdx
        cp 0x4a
        ret z;jr z,intlooper ;TODO deallocate (Resize memory block)
        cp 0x48
        ret z;jr z,intlooper ;TODO allocate (return ax = segment)
        ;cp 0x06
        ;ret z ;TODO 06h	Direct console I/O (for blaze0)
        cp 0x07
        jp z,dosgetchar ;(for mision)
        cp 0x25
        jp z,setvector;ret z ;for pitman ;set new int 09h vector
        cp 0x35
        jp z,getvector;ret z ;for pitman ;get and save old int 09h vector
        cp 0x30
        jp z,dosversion ;for rax
;TODO for lander:
;        mov     ax,ds                   ;deallocate all but 128k mem
;        mov     es,ax
;        mov     ah,4Ah
;        mov     bx,2000h ;size 128k
;        int     21h

;        mov     ah,48h                  ;allocate       starbuf
;        mov     bx,1000h                ;64k
;        int     21h
;        mov     es,ax

;        mov     ah,0                    ;init random seed
;        int     1Ah                     ; to timer
;        mov     word ptr r3[0],dx       ;
;        mov     word ptr r3[2],cx       ;


;        mov     ah,2                    ;scoreboard
;        mov     bh,0
;        mov     dh,24
;        mov     dl,0
;        int     10h ;???
;        mov     dx,offset fuelS
;        mov     ah,9
;        int     21h

 if debug_stop = 0
 ret
 else
 jr $
 endif

setvector
;set new int 09h vector
;        push    cs
;        pop     ds
;        mov     dx,offset key_int
;        mov     ah,25h
;        mov     al,09h
;        int     21h ;set vector al = ds:dx
      ld a,(tpgs)
      SETPGC000
        ld a,(_AL)
        add a,a
        add a,a
        ld l,a
        ld h,0xc0
        ld bc,(_DX)
        ld (hl),c
        inc l
        ld (hl),b
        inc l
        ld bc,(_DS)
        ld (hl),c
        inc l
        ld (hl),b
        ret

getvector
;        mov     ah,35h                  ;get and save old int 09h vector
;        mov     al,09h
;        int     21h
;        mov     word ptr old_int9[0],bx
;        mov     word ptr old_int9[2],es
      ld a,(tpgs)
      SETPGC000
        ld a,(_AL)
        add a,a
        add a,a
        ld l,a
        ld h,0xc0
        ld c,(hl)
        inc l
        ld b,(hl)
        ld (_BX),bc
        inc l
        ld c,(hl)
        inc l
        ld b,(hl)
        ld (_ES),bc
        ret

dosversion
;Entry: AL = what to return in BH (00h OEM number, 01h version flag)
;Return:
;AL = major version number (00h if DOS 1.x)
;AH = minor version number
;BL:CX = 24-bit user serial number (most versions do not use this) if DOS <5 or AL=00h
;BH = MS-DOS OEM number if DOS 5+ and AL=01h
;BH = version flag bit 3: DOS is in ROM other: reserved (0)
;TODO
        ld hl,5
        ld (_AX),hl
        ret

INT_printstringdx
;TODO
        ;jr $
       ret;_Loop_

INT_getgfx ;blue
;Выход:
;AL = текущий режим (см. функцию 00h)
;AH = число текстовых столбцов на экране
;BH = текущий номер активной страницы дисплея
curgfxmode=$+1
        ld hl,80*256 ;TODO patch h
        ld (_AX),hl
        xor a
        ld (_BH),a
        ret

INT_setgfx
         ;jr $
       ld a,(_AL)
       ld (curgfxmode),a
       cp 0x01 ;sorryass
       jr z,INT_setgfxTEXT40
       cp 0x07 ;shamus "please turn on the color display"
       jr z,INT_setgfxTEXT40
       cp 0x04 ;CGA 320x200x4
       ld hl,cgapal1
       jr z,INT_setgfxCGA
       cp 0x05 ;CGA 320x200x4
       ld hl,cgapal2
       jr z,INT_setgfxCGA
       cp 0x13
       jr nz,INT_setgfxTEXT80
        ld hl,ansipal
        call setegamode_palhl
        ld hl,wasPUTscreen_vga
        call setPUTscreen_hl
;INT_setgfxq
       ret;_Loop_
INT_setgfxCGA
        call setegamode_palhl
        ld hl,wasPUTscreen_cga
        call setPUTscreen_hl
        ld hl,trecolour
mkrecga0
        ld c,l ;%????LlRr
        xor a
        rr c
        rla
        rr c
        rla
        add a,a
        rr c
        rla
        rr c
        rla
        ;rlca ;a=%lRr????L
        ;rlca ;a=%Rr????Ll
        ;add a,a;%r????Ll0 CY=R
        ;rla  ;a=%????Ll0R
        ;rla  ;a=%???Ll0Rr
        ;and 0x1f;000rR0lL
        ld (hl),a
        inc l
        jr nz,mkrecga0
       ret;_Loop_
INT_setgfxTEXT40
        call settextmode
        ld hl,wasPUTscreen_textmode40
        call setPUTscreen_hl
;       macro dbrrc3 data
;        db (data>>3)+((data<<5)&0xe0)
;       endm
;ttextaddr
;        dup 128
;_=$&0xff
;; |младший
;;0GgggGGG -> 0GGGGggg:
;_=((_&0x07)<<4)+((_&0x78)>>3)
;       if _<125
;_=_/5*8+(_-(_/5*5))+56
;        dbrrc3 _
;       else
;        dbrrc3 255
;       endif
;        edup
        ld hl,ttextaddr
mktext40addr0
        ld (hl),0;255
        ld a,l
        and 0x07
       rrca
       ;rrca
       ;rrca
       ;rrca
       ;ld c,a
        ;ld a,l
        ;and 0x78
        xor l
        and 0x87
        xor l
       rrca
       rrca
       rrca
       ;or c
;a=_
        cp 125
        jr nc,mktext40addr_skip
        ld b,-1
       inc b
       sub 5
       jr nc,$-3
        add a,5 ;a=(_ mod 5) ;b=_/5
        sla b
        sla b
        add a,b
        add a,b
        add a,56 ;a=_/5*8+(_-(_/5*5))+56
        rrca
        rrca
        rrca
        ld (hl),a
mktext40addr_skip
        inc l
        jp p,mktext40addr0
        ret
INT_setgfxTEXT80
        call settextmode
        ld hl,wasPUTscreen_textmode
        call setPUTscreen_hl
;       macro dbrrc3 data
;        db (data>>3)+((data<<5)&0xe0)
;       endm
;ttextaddr
;        dup 128
;_=$&0xff
;;0gggGGGG -> 0GGGGggg:
;_=((_&0x0f)<<3)+((_&0x70)>>4)
;       if _<125
;_=_/5*8+(_-(_/5*5))+56
;        dbrrc3 _
;       else
;        dbrrc3 255
;       endif
;        edup
        ld hl,ttextaddr
mktextaddr0
        ld (hl),255
        ld a,l
        and 0x70
        rlca
        xor l
        and 0xf0
        xor l
       rlca
       rlca
       rlca
;a=_
        cp 125
        jr nc,mktextaddr_skip
        ld b,-1
       inc b
       sub 5
       jr nc,$-3
        add a,5 ;a=(_ mod 5) ;b=_/5
        sla b
        sla b
        add a,b
        add a,b
        add a,56 ;a=_/5*8+(_-(_/5*5))+56
        rrca
        rrca
        rrca
        ld (hl),a
mktextaddr_skip
        inc l
        jp p,mktextaddr0
        ret

setegamode_palhl
        push de
        call setpalhl_with_caution ;OS_SETPAL ;TODO с копированием во временную палитру
        ld e,0+0x80 ;EGA+keep
        call setgfx
        ld hl,wastrecolour
        ld de,trecolour
        ld bc,256
        ldir
        pop de
        ret

settextmode
        push de
        ld hl,ansipal
        call setpalhl_with_caution ;OS_SETPAL ;TODO с копированием во временную палитру
        ld e,6+0x80 ;text+keep
        call setgfx
        ld hl,wast866toatm
        ld de,trecolour
        ld bc,256
        ldir
        pop de
        ret

setPUTscreen_hl
        push de
        ld de,PUTscreen_logpgc_zxaddrhl_datamhl_do
        ld bc,maxszPUTscreen
        ldir
        pop de
        ret

setgfx
     DISABLE_IFF0_KEEP_IY
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0
        OS_CLS
     ENABLE_IFF0_REMEMBER_IY ;иначе pop iy запорет iy от обработчика прерывания
        ret

setpalhl_with_caution
       push de
     DISABLE_IFF0_KEEP_IY
       ex de,hl
       OS_SETPAL
     ENABLE_IFF0_REMEMBER_IY ;иначе pop iy запорет iy от обработчика прерывания
       pop de
       ret

INT_printal
        push de
        ex af,af' ;'
        push af
     DISABLE_IFF0_KEEP_IY
	ld a,(_AL)
	PRCHAR
     ENABLE_IFF0_REMEMBER_IY ;иначе pop iy запорет iy от обработчика прерывания
        pop af
        ex af,af' ;'
        pop de
       ret;_Loop_

INT16
        ;mov ah,0x01     ; Any key pressed?
        ;int 0x16
        ;jz fb26         ; No, go to main loop
       ld a,(_AH)
       or a
       jr z,INT_inputal
       dec a
       jp nz,INT_getkeyflags
        ;jr $
;1 Получить состояние клавиатуры (84-клавишная клавиатура)
;Выход:
;При ZF=1 нет клавиши
;При ZF=0: (враньё??? pillman игнорит это значение ax и сразу читает через ah=0!!!)
;     AH - скан-код
;     AL - ASCII код
int16getkey
        ld a,(prefetchedkey)
        or a
       if 0
        jr nz,INT_inputal_a
       else
        jr nz,INT16havekey
       endif
        push de
     DISABLE_IFF0_KEEP_IY
        OS_GETKEY
     ENABLE_IFF0_REMEMBER_IY ;иначе pop iy запорет iy от обработчика прерывания
        pop de
        ret nz;jr nz,INT16q ;no focus
       ld b,a
        ex af,af' ;'
        inc b
        dec b ;Z (no key)
        ex af,af' ;'
       or a
       ret z
       if 0
       jr INT_inputal_a
       else
INT16havekey
       ;ld a,0x48
        ld (prefetchedkey),a
        call nedooskey_to_pckey ;a->bc
         ld (_AX),bc
        ex af,af' ;'
        inc b
        dec b ;Z/NZ
        ex af,af' ;'
       ret;_Loop_
       endif
INT_inputal
prefetchedkey=$+1
        ld a,0
        or a
        jr nz,INT_inputal_a
        push de
     DISABLE_IFF0_KEEP_IY
        YIELDGETKEYLOOP;OS_GETKEY
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется для обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус.
     ENABLE_IFF0_REMEMBER_IY ;иначе pop iy запорет iy от обработчика прерывания
        pop de
INT_inputal_a
	;ld (_AL),a
        call nedooskey_to_pckey ;a->bc
         ;ld a,c
	 ;ld (_AH),a ;scancode for pillman
         ld (_AX),bc
        ex af,af' ;'
        inc b
        dec b ;NZ if key
        ex af,af' ;'
        xor a
        ld (prefetchedkey),a
;INT16q
       ret;_Loop_
INT_getkeyflags
;16h#2 (keyboard flags: al=0x10(scrolllock)+0x08(alt)+0x04(ctrl)+0x03(shifts))
        ld a,0xfe
        in a,(0xfe)
        cpl
        and 0x1f
	ld (_AL),a
       ret;_Loop_

dosgetchar=INT_inputal
;dosgetchar=int16getkey ;livin проскакивает меню
;Return:
;ZF set if no character available and AL = 00h
;ZF clear if character available AL = character read

nedooskey_to_pckey ;a->bc
         ld bc,0x011b ;1b for pitman, 01 for pillman?
         cp key_esc
         jr z,INT_inputal_a_scancodeq
         ld bc,0x1c1c ;HSB for pipes, LSB not needed?
         cp key_enter
         jr z,INT_inputal_a_scancodeq
         ld bc,0x3b00
         cp key_F1
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x3c
         cp key_F2
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x3d
         cp key_F3
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x3e
         cp key_F4
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x3f
         cp key_F5
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x40
         cp key_F6
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x41
         cp key_F7
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x42
         cp key_F8
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x43
         cp key_F9
         jr z,INT_inputal_a_scancodeq
         inc b;ld b,0x44
         cp key_F10
         jr z,INT_inputal_a_scancodeq
         ld b,0x4b
         cp key_left
         jr z,INT_inputal_a_scancodeq
         ld b,0x4d
         cp key_right
         jr z,INT_inputal_a_scancodeq
         ld b,0x48
         cp key_up
         jr z,INT_inputal_a_scancodeq
         ld b,0x50
         cp key_down
         jr z,INT_inputal_a_scancodeq
        ld b,a;c;0
         ld c,a
INT_inputal_a_scancodeq
        ret




wasPUTscreen_cga
     disp PUTscreen_logpgc_zxaddrhl_datamhl_do
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
      ent
szPUTscreen_cga=$-wasPUTscreen_cga

wasPUTscreen_vga
     disp PUTscreen_logpgc_zxaddrhl_datamhl_do
        ld c,(hl)
        inc b ;(b=trecolour/256)
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
     ent
szPUTscreen_vga=$-wasPUTscreen_vga


wasPUTscreen_textmode40
     disp PUTscreen_logpgc_zxaddrhl_datamhl_do
       bit 3,h
       ret nz ;only for 40 pitch (sorryass)
        ld c,(hl) ;colour
;The VGA text buffer is located at physical memory address 0xB8000.
;25 строк по 40 слов: символ, атрибут (%FpppIiii - пересчитать в PIpppiii)
       push bc
;для 40 символов в строке группы по 8 символов:
;hl=00000GGG GgggXXxA
        ld a,l  ;gggXXXxA
        srl a
        xor h
        and 0xf8 ;0xf8 для 40 символов в строке
        xor h   ;0gggGGGG
;пересчитываем в номер группы на АТМ textmode:
        ld b,ttextaddr/256
        ld c,a
        ld a,(bc) ;gggGGGgg
       rra;srl a ;srl a для 40 символов в строке (для 80 вообще не нужно)
        xor l
        and 0xf0 ;0xf0 для 40 символов в строке
        xor l
        ld l,a
        ld a,(bc) ;gggGGGgg
        and 0x1f
;пересчитываем в адрес группы на ATM textmode (группы по 8 символов):
;hl=000GGGgg 0gggXXxA ;+0x01c0 уже прибавлено к номеру группы как +56
         scf
         rra
        rr l
        jr c,PUTscreen_textmode40_attr
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
PUTscreen_textmode40_attr
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
     ent
szPUTscreen_textmode40=$-wasPUTscreen_textmode40


wasPUTscreen_textmode
     disp PUTscreen_logpgc_zxaddrhl_datamhl_do
        ld c,(hl) ;colour
;The VGA text buffer is located at physical memory address 0xB8000.
;25 строк по 80 слов: символ, атрибут (%FpppIiii - пересчитать в PIpppiii)
;как пересчитать строки по 160 байт (80 символов) в строки по 64 байта (128 виртуальных символов)? всего 2000 знакомест = 125 групп по 16 символов, можно по таблице получить адрес (2 байта) или номер виртуальной группы (их всего 200, т.е. 1 байт)
       push bc
;получаем номер группы по 16 символов:
;hl=0000GGGG gggXXXxA
        ld a,l  ;gggXXXxA
        srl a
        xor h
        and 0xf0 ;0xf8 для 40 символов в строке
        xor h   ;0gggGGGG
;пересчитываем в номер группы на АТМ textmode:
        ld b,ttextaddr/256
        ld c,a
        ld a,(bc) ;gggGGGgg
        xor l
        and 0xe0 ;srl a...0xf0 для 40 символов в строке
        xor l
        ld l,a
        ld a,(bc) ;gggGGGgg
        and 0x1f
;пересчитываем в адрес группы на ATM textmode:
;hl=000GGGgg gggXXXxA ;+0x01c0 уже прибавлено к номеру группы как +56
         scf
         rra
        rr l
        jr c,PUTscreen_textmode_attr
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
PUTscreen_textmode_attr
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
     ent
szPUTscreen_textmode=$-wasPUTscreen_textmode

        display "szPUTscreen_cga=",szPUTscreen_cga
        display "szPUTscreen_vga=",szPUTscreen_vga
        display "szPUTscreen_textmode40=",szPUTscreen_textmode40
        display "szPUTscreen_textmode=",szPUTscreen_textmode
        display "memory for PUTscreen=",maxszPUTscreen



;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
;standard:
        ;dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        ;dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
;ansi:
	;dw 0xffff,0xfdfd,0xefef,0xeded,0xfefe,0xfcfc,0xeeee,0xecec
	;dw 0x1f1f,0x1d1d,0x0f0f,0x0d0d,0x1e1e,0x1c1c,0x0e0e,0x0c0c
cgapal1
;0,R,G,Y (bits swapped):
       dup 4
	dw 0xffff,0x1d1d,0x0f0f,0x0d0d
       edup
cgapal2
;0,M,C,W (bits swapped):
       dup 4
	dw 0xffff,0x9c9c,0x4e4e,0x0c0c
       edup

wast866toatm
        incbin "../kernel/866toatm"

       macro dbcol _0
        db ((_0)&7)*9 + (((_0)&8)*0x18)
       endm

       macro dbcol8 _0,_1,_2,_3,_4,_5,_6,_7
        dbcol _0
        dbcol _1
        dbcol _2
        dbcol _3
        dbcol _4
        dbcol _5
        dbcol _6
        dbcol _7
       endm

       macro dbcol8i _0,_1,_2,_3,_4,_5,_6,_7
        dbcol8 _0|0x08,_1|0x08,_2|0x08,_3|0x08,_4|0x08,_5|0x08,_6|0x08,_7|0x08
       endm

wastrecolour ;TODO generate for given palette
        dup 16
        dbcol ($-wastrecolour)
        edup
;0x10
        dbcol8 0,0,0,0,8,8,8,8
        dbcol8 7,7,7,7,15,15,15,15
;0x20
        dbcol8 1,1,1,5,5,5,4,4
        dbcol8 4,4,4,6,6,6,2,2
        dbcol8 2,2,2,3,3,3,1,1
;0x38
        dbcol8i 1,1,1,5,5,5,4,4
        dbcol8i 4,4,4,6,6,6,2,2
        dbcol8i 2,2,2,3,3,3,1,1
;0x50
        dbcol8i 7,7,7,7,7,7,7,7
        dbcol8i 7,7,7,7,7,7,7,7
        dbcol8i 7,7,7,7,7,7,7,7
;0x68
        dbcol8 1,1,1,5,5,5,4,4
        dbcol8 4,4,4,6,6,6,2,2
        dbcol8 2,2,2,3,3,3,1,1
;0x80
       dup 6
        dbcol8 8,8,8,8,8,8,8,8
       edup
;0xb0
        ds 72,0x00
;0xf8
        ds 8,0

        align 256
tcga
_y=0
       dup 100
_x=0
       dup 5
       dw 0xc000+(80*_y)+(8*_x)
_x=_x+1
       edup
_y=_y+1
       edup
       dup 24
        ;dw 0xfff8;запарывает rst
        dw 0xc000+(80*200)
       edup

font
        incbin "866_code.fnt"
