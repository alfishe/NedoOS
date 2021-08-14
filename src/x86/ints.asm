INT_gettimer
;int 1Ah ;AL= 24 hours overflow flag, CX:DX = 32bit timer
;_microtimer=$+1
;        ld hl,0
;        inc hl
;        ld (_microtimer),hl
       ld hl,(timer)
       srl h
       rr l
       srl h
       rr l
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
       jr $
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
       pop de
       ret;_Loop_

INT10
        ld a,(_AH)
        or a
        jr z,INT_setgfx
        cp 0x13
        jp z,printstring
        cp 0x0e
        jr z,INT_printal
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
       jr $

INT21
        ld a,(_AH)
;TODO 00h	Program terminate (plutina), с ожиданием клавиши
        cp 0x09
        jr z,INT_printstringdx
        cp 0x4a
        ret z;jr z,intlooper ;TODO deallocate
        cp 0x48
        ret z;jr z,intlooper ;TODO allocate (return ax = segment)
        cp 0x06
        ret z ;TODO 06h	Direct console I/O (for blaze0)
        cp 0x25
        ret z ;TODO for pitman
        cp 0x35
        ret z ;TODO for pitman
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

       jr $
INT_printstringdx
;TODO
        ;jr $
       ret;_Loop_

INT_setgfx
       ld a,(_AL)
       ;cp 0x03
       ;jr z,INT_setgfxq ;TODO setgfx textmode
       cp 0x04 ;CGA 320x200x4
       jr z,INT_setgfxCGA
       cp 0x13
       jr nz,INT_setgfxq ;TODO setgfx textmode
        ld hl,_PUTscreen_do_patch_vgadata
        ld (_PUTscreen_do_patch),hl
        push de
        push iy
        ld e,0+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        pop iy
        pop de
INT_setgfxq
       ret;_Loop_
INT_setgfxCGA

       ret;_Loop_

INT_printal
        push de
        ex af,af' ;'
        push af
        push iy
	ld a,(_AL)
	PRCHAR
        pop iy
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
        ld a,(prefetchedkey)
        or a
        jr nz,INT16havekey
        push de
        push iy
        OS_GETKEY
        pop iy
        pop de
        ret nz;jr nz,INT16q ;no focus
INT16havekey
       ;ld a,0x48
        ld (prefetchedkey),a
        ld b,a
        ex af,af' ;'
        inc b
        dec b
        ex af,af' ;'
       ret;_Loop_
INT_inputal
prefetchedkey=$+1
        ld a,0
        or a
        jr nz,INT_inputal_a
        push de
        push iy
        YIELDGETKEYLOOP;OS_GETKEY
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется для обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус.  
        pop iy
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
        ld b,c;0
         ld c,a
INT_inputal_a_scancodeq
         ;ld a,c
	 ;ld (_AH),a ;scancode for pillman
         ld (_AX),bc
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
