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
        jr z,INT21
        cp 0x80
        ret nc;jr nc,intlooper ;костыль для megapole
        cp 0x20
        jp z,quiter
        
        cp 0x11
        ret z ;TODO for shamus

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
     DISABLE_IFF0
       push iy
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
       pop iy
     ENABLE_IFF0 ;иначе pop iy запорет iy от обработчика прерывания
       pop de
       ret;_Loop_

INT10
        ld a,(_AH)
        or a
        jr z,INT_setgfx
        cp 0x13
        jp z,printstring
        cp 0x0e
        jp z,INT_printal
        cp 0x01
        ret z;jr z,intlooper ;TODO disable caret
        cp 0x02
        ret z;jr z,intlooper ;TODO set cursor position
        cp 0x0a
        ret z ;TODO ;Write character only at cursor position	AH=0Ah	AL = Character, BH = Page Number, CX = Number of times to print character
        cp 0x0b
        ret z ;TODO for zaxon Set background/border color	AH=0Bh, BH = 00h	BL = Background/Border color (border only in text modes)
        cp 0x10
        ret z ;TODO for plutina AL = 1A  read color page state
        
 if debug_stop = 0
 ret
 else
 jr $
 endif

INT21
        ld a,(_AH)
;TODO 00h	Program terminate (plutina), с ожиданием клавиши
        cp 0x09
        jr z,INT_printstringdx
        cp 0x4a
        ret z;jr z,intlooper ;TODO deallocate (Resize memory block)
        cp 0x48
        ret z;jr z,intlooper ;TODO allocate (return ax = segment)
        cp 0x06
        ret z ;TODO 06h	Direct console I/O (for blaze0)
        cp 0x07
        jp z,dosgetchar ;(for mision)
        cp 0x25
        ret z ;TODO for pitman ;set new int 09h vector
        cp 0x35
        ret z ;TODO for pitman ;get and save old int 09h vector
        cp 0x30
        jp z,dosversion ;for rax
;TODO for lander:
;        mov     ax,ds                   ;deallocate all but 128k mem
;        mov     es,ax
;        mov     ah,4Ah
;        mov     bx,2000h ;size 128k
;        int     21h

;        mov     ah,35h                  ;get and save old int 09h vector
;        mov     al,09h
;        int     21h
;        mov     word ptr old_int9[0],bx
;        mov     word ptr old_int9[2],es

;set new int 09h vector
;        push    cs
;        pop     ds
;        mov     dx,offset key_int
;        mov     ah,25h
;        mov     al,09h
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

INT_setgfx
       ld a,(_AL)
       cp 0x01 ;sorryass
       jr z,INT_setgfxTEXT40
       cp 0x07 ;shamus "please turn on the color display"
       jr z,INT_setgfxTEXT40
       cp 0x04 ;CGA 320x200x4
       jr z,INT_setgfxCGA
       cp 0x13
       jr nz,INT_setgfxTEXT80
        call setegamode
;INT_setgfxq
       ret;_Loop_
INT_setgfxCGA
        call setegamode
        ld hl,_PUTscreen_do_patch_cgadata
        ld (_PUTscreen_do_patch),hl
;TODO

       ret;_Loop_
INT_setgfxTEXT40
        call settextmode
        ld hl,_PUTscreen_do_patch_textmode40
        ld (_PUTscreen_do_patch),hl ;TODO копировать всю процедуру?
        ld a,0xf8
        ld (PUTscreen_textmode_groupmask),a
        ld a,0xf0
        ld (PUTscreen_textmode_groupmask2),a
        ld a,0x3f ;srl a
        ld (PUTscreen_textmode_srlcode),a
        ;jr $
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
        ld a,0xf0
        ld (PUTscreen_textmode_groupmask),a
        ld a,0xe0
        ld (PUTscreen_textmode_groupmask2),a
        ld a,0x38 ;srl b
        ld (PUTscreen_textmode_srlcode),a
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

setegamode
        ld hl,_PUTscreen_do_patch_vgadata
        ld (_PUTscreen_do_patch),hl ;TODO копировать всю процедуру?
        push de
        ld e,0+0x80 ;EGA+keep
        call setgfx
        ld hl,wastrecolour
        ld de,trecolour
        ld bc,256
        ldir
        pop de
        ret

settextmode
        ld hl,_PUTscreen_do_patch_textmode
        ld (_PUTscreen_do_patch),hl ;TODO копировать всю процедуру?
        push de
        ld e,6+0x80 ;text+keep
        call setgfx
        ld hl,wast866toatm
        ld de,trecolour
        ld bc,256
        ldir
        pop de
        ret

setgfx
     DISABLE_IFF0
        push iy
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        pop iy
     ENABLE_IFF0 ;иначе pop iy запорет iy от обработчика прерывания
        ret

INT_printal
        push de
        ex af,af' ;'
        push af
     DISABLE_IFF0
        push iy
	ld a,(_AL)
	PRCHAR
        pop iy
     ENABLE_IFF0 ;иначе pop iy запорет iy от обработчика прерывания
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
       jr nz,INT_getkeyflags
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
     DISABLE_IFF0
        push iy
        OS_GETKEY
        pop iy
     ENABLE_IFF0 ;иначе pop iy запорет iy от обработчика прерывания
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
        ld b,a
       ld c,a
         ld (_AX),bc
        ex af,af' ;'
        inc b
        dec b ;NZ
        ex af,af' ;'
       ret;_Loop_
       endif
INT_inputal
prefetchedkey=$+1
        ld a,0
        or a
        jr nz,INT_inputal_a
        push de
     DISABLE_IFF0
        push iy
        YIELDGETKEYLOOP;OS_GETKEY
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется для обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус.  
        pop iy
     ENABLE_IFF0 ;иначе pop iy запорет iy от обработчика прерывания
        pop de
INT_inputal_a
	;ld (_AL),a
         ld bc,0x011b ;1b for pitman, 01 for pillman?
         cp key_esc
         jr z,INT_inputal_a_scancodeq
         ld bc,0x4b00
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
        dw 0xfff8
       edup
