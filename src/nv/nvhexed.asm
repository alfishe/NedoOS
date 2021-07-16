hexeditor_XYTOP=0x0000
hexeditor_HGT=txtscrhgt-1
hexeditor_WID=80
hexeditor_MAXX=15
hexeditor_PAGESIZE=16*hexeditor_HGT

       if PRSTDIO
_hexeditor_CURSORCOLOR=0x0700;0x38
_hexeditor_COLOR=0x0007;7
       else
_hexeditor_CURSORCOLOR=0x38
_hexeditor_COLOR=7
       endif

hexeditor_redrawloop
        ;YIELDGETKEYLOOP
        call hexeditor_prpage
hexeditor_mainloop
        call hexeditor_calccursorxy
        ld hl,_hexeditor_CURSORCOLOR
        ld b,2
        call drawfilecursor_sizeb_colorhl
        call hexeditor_calctextcursorxy
       if PRSTDIO
        call nv_setxy ;keeps de,hl,ix
       else
        ld hl,_hexeditor_CURSORCOLOR
        ld b,1
        call drawfilecursor_sizeb_colorhl
       endif
      if 0
;hexeditor_yieldkeep
        ld a,2
hexeditor_yieldkeep
        ld (hexeditor_wasnokey),a
	YIELDKEEP
        ld a,55+128 ;"or a"
        ld (hexeditor_wasyield),a
      endif
hexeditor_mainloop_nokey
      if 0
      else
        YIELD
      endif
       if PRSTDIO
        GETKEY_
        jr nz,hexeditor_keyq
        GETKEY_
        jr nz,hexeditor_keyq
        GETKEY_
        jr nz,hexeditor_keyq ;event бывает 3-символьный
       else
        GET_KEY
        ld a,c ;keynolang
        ;cp NOKEY
         or a
        jr nz,hexeditor_keyq
       endif
       if PRSTDIO
       ld a,(stdindatacount)
       or a
       jr nz,hexeditor_mainloop;_nokey
       endif
      if 0
;если два раза подряд нет события, то рисуем панельку и делаем YIELD, иначе YIELDKEEP
hexeditor_wasnokey=$+1
        ld a,1
        dec a
        jr nz,hexeditor_yieldkeep
;рисовать панельку только при отсутствии события после YIELD
hexeditor_wasyield=$
        scf
        jr nc,hexeditor_nopanel
      endif
        call hexeditor_panel
       if PRSTDIO
        call hexeditor_calctextcursorxy
        call nv_setxy ;keeps de,hl,ix
       endif
      if 0
hexeditor_nopanel
	YIELD
        ld a,55 ;"scf"
        ld (hexeditor_wasyield),a
      endif
        jr hexeditor_mainloop_nokey
hexeditor_keyq
        ;push hl
        ;push bc
        ;push de
        push af
        call hexeditor_calccursorxy
        ld hl,_hexeditor_COLOR
        ld b,2
        call drawfilecursor_sizeb_colorhl
       if PRSTDIO == 0
        call hexeditor_calctextcursorxy
        ld hl,_hexeditor_COLOR
        ld b,1
        call drawfilecursor_sizeb_colorhl
       endif
	pop af
	;pop de
	;pop bc
	;pop hl
        cp key_redraw
        jr z,hexeditor_redrawloop
        cp key_esc
        ret z
        cp key_tab
        jp z,nvview_hexeditorq
        ld hl,hexeditor_mainloop
        push hl
         cp key_up
         jp z,hexeditor_up
         cp key_down
         jp z,hexeditor_down
         cp key_pgup
         jp z,hexeditor_pgup
         cp key_pgdown
         jp z,hexeditor_pgdown
        ;cp key_home
        ;jp z,hexeditor_home
        ;cp key_sspgup;ext3
        ;jp z,hexeditor_home
        ;cp key_end
        ;jp z,hexeditor_end
        ;cp key_sspgdown;ext4
        ;jp z,hexeditor_end
        cp key_left
        jp z,hexeditor_left
        cp key_right
        jp z,hexeditor_right
         cp key_csenter
         jp z,hexeditor_save
         cp key_F2
         jp z,hexeditor_save
        cp '0'
        ret c
        cp '9'+1
        jr c,hexeditor_symbol
        cp 'a'
        ret c
        cp 'f'+1
        ret nc ;jp c,hexeditor_symbol
        ;ret
hexeditor_symbol
        push af
        call nvhex_calccuraddrline ;addr cur line
        ld de,(hexcuraddrxy)
        ld d,0
        add hl,de ;addrcurline + x(e)
        call ahl_to_pgaddr
        pop af
        ;0   a-10
        cp 'a'
        jr nc,hexeditor_symbol_af
        ld b,-0x30
        jr hexeditor_symbol_pr
hexeditor_symbol_af        
        ld b,-0x61+0x0a;0x56
hexeditor_symbol_pr        
        add a,b
        
hexeditor_half=$
        or a ;/scf
        jr c,hexeditor_symbol_right
        add a,a
        add a,a
        add a,a
        add a,a;a=XXXX0000
        xor (hl)
        and 0xf0
        xor (hl)
        jr hexeditor_symbol_rightq
hexeditor_symbol_right
        xor (hl)
        and 0x0f
        xor (hl)
hexeditor_symbol_rightq
        ld (hl),a
        ld hl,hexeditor_half
        ld a,(hl)
        xor 0x80
        ld (hl),a
	call setchanged
        call nvhex_calccuraddrline ;ahl=addr cur line
        ld de,(hexcuraddrxy)
        ld e,0 
        push af
        call nv_setxy ;keeps de,hl,ix
        pop af ;keep ahl!!!
        jp hexeditor_prline

hexeditor_save
        ;ld hl,fcb_filename
        ;ld de,fcb2_filename
        ;call copy_to_defcb_filename
        ;call nv_createfcb2 ;autopush nv_closefcb2
        ;ret nz ;error
        ld de,filenametext
        OS_CREATEHANDLE
	or a
        ret nz ;error
        ld a,b
        ld (curhandle),a
        ld de,(filesize)
        ld hl,(filesizeHSW)
        ld a,0 ;page number
hexeditor_save0
;a=page number in table (0..)
;hlde=remaining size
        push af
        push de
        push hl
        call setpg32k
        ld a,d
        and 0xc0
        or h
        or l
        jr z,$+5 ;de=size
         ld de,0x4000
        ex de,hl ;hl=pg size
        push hl ;hl=pg size
        call cmd_savepage
        pop bc ;bc=pg size
        pop hl
        pop de
        ex de,hl
        or a
        sbc hl,bc
        ex de,hl
        jr nc,$+3
         dec hl ;size = size-pgsize
        ld a,h
        or l
        or d
        or e
        jr z,hexeditor_save_popq
        pop af
        inc a
        jr hexeditor_save0
hexeditor_save_popq
        call nv_closehandle
	call setunchanged
        pop af
        ret

hexeditor_left
        ld de,(hexcuraddrxy)
        ld a,e
        cp 0
        ret z
        dec e
        ld (hexcuraddrxy),de
        ret

hexeditor_right
        ld de,(hexcuraddrxy)
        ld a,e
        cp hexeditor_MAXX
        ret z
        inc e
        push de
        call nvhex_calccuraddrline ;ahl=lineaddr
        pop de
        push af
        ld a,e
        add a,l
        ld l,a
        pop af
        call iseof
        ret nc
        ld (hexcuraddrxy),de
        ret

hexeditor_calccursorxy
        ld de,(hexcuraddrxy)
        ld a,e
        add a,a
        add a,e
        add a,8
        ld e,a
        ret

hexeditor_calctextcursorxy
        ld de,(hexcuraddrxy)
        ld a,e
        add a,57
        ld e,a
        ret ;no ret because panel is empty

hexeditor_panel=nvview_panel
        ;ret

hexeditor_prpage
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        ld de,hexeditor_XYTOP
        ld b,hexeditor_HGT
hexeditor_prpage0
        push bc
        push de
        push af
        call nv_setxy ;keeps de,hl,ix
        pop af
        call hexeditor_prline
        pop de
        pop bc
        inc d
        djnz hexeditor_prpage0
;hexeditor_setbottom
        ;ld (hexaddrline),hl
        ;ld (hexaddrlineHSB),a
        ret

hexeditor_prline
;ahl =  addr line      
        push af
        push hl
        push hl
        call getmaxlinesize ;bc=max line size before eof, z=(bc==0)
        ld hl,16
        call minhl_bc_tobc ;bc = min(16, max line size before eof) 
        pop hl
        ;push bc
         ld de,thexedline
        call hexeditor_praddrline
        call ahl_to_pgaddr
         inc de      
        ;pop bc ;bc = min(16, max line size before eof)

         push bc
        push hl
        ld a,c
        or a
        jr z,hexeditor_prlhex0q
        ld b,a
hexeditor_prlhex0
         inc de
        ld a,(hl)
        rrca
        rrca
        rrca
        rrca
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
         ld (de),a
         inc de
        ld a,(hl)
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
         ld (de),a
         inc de
        inc  l
        djnz hexeditor_prlhex0
hexeditor_prlhex0q
        ld a,16
        sub c
        jp z,hexeditor_prlhex1q
        ld b,a
         ld a,' '
hexeditor_prlhex1
         inc de
         ld (de),a
         inc de
         ld (de),a
         inc de
        djnz hexeditor_prlhex1
hexeditor_prlhex1q

        pop hl
         inc de
         inc de
        ld a,c
        or a
        jr z,hexeditor_prlsym0q
        ld b,a
hexeditor_prlsym0
        ld a,(hl)
        cp 32 
        jr nc,$+4
          ld a,'.'
         ld (de),a
         inc de
        inc  l
        djnz hexeditor_prlsym0
hexeditor_prlsym0q
        ld a,16
        sub c
        jp z,hexeditor_prlsym1q
        ld b,a
         ld a,' '
hexeditor_prlsym1
         ld (de),a
         inc de
        djnz hexeditor_prlsym1
hexeditor_prlsym1q
         ld de,thexedline
         ld hl,80
         call sendchars
         pop bc ;bc=bytes shown in line
        pop hl
        pop af
        ;ld b,0
        add hl,bc
        adc a,b
        ret

hexeditor_praddrline
;ahl = addr line
        push af
        call hexeditor_prNN
        ld a,h
        call hexeditor_prNN      
        ld a,l        
        call hexeditor_prNN
        pop af
        ret

hexeditor_prNN
;#30 - 0,1,2..9 #41 - A,B,C,D,E,F #61 - a,b,c..
;a=XX 
        push af
        rrca
        rrca
        rrca
        rrca
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
         ld (de),a
         inc de
        pop af
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
         ld (de),a
         inc de
        ret

thexedline
        db "000000: 00 00 00 00 00 00 00 00|00 00 00 00 00 00 00 00  ................       "

hexeditor_prevline
;ahl =addr line  
;out: ahl =addr line, NC=error      
        call isbof ;CY=0
        ret z ;NC
        push bc
        ld bc,0x0010
        or a 
        sbc hl,bc
        sbc a,b
        scf
        pop bc
        ret ;CY

        if 1==0
hexeditor_nextline
        call iseof
        ret nc
        push bc
        ld bc,0x0010
        add hl,bc
        adc a,b
        pop bc
        ret
        endif

hexeditor_pgup
        call nvhex_calccuraddrline 
        ld de,(hexcuraddrxy)
        ld c,a
        ld a,d
        or a
        ld a,c
        jr nz,hexeditor_pgupq
        ld b,hexeditor_HGT-1
hexeditor_pgup0
        push bc
        call hexeditor_prevline
        pop bc
        djnz hexeditor_pgup0
        ld (hexaddrline),hl
        ld (hexaddrlineHSB),a
        call hexeditor_prpage
        jp clear_keyboardbuffer 
hexeditor_pgupq
        ld d,0
        ld (hexcuraddrxy),de
        ret

hexeditor_pgdown
        call nvhex_calccuraddrline 
        ld de,(hexcuraddrxy)
        ld c,a
        ld a,d
        cp hexeditor_HGT-1
        ld a,c
        jr z,hexeditor_pgdown_do
hexeditor_pgdown0
        ld c,a
        ld a,d
        cp hexeditor_HGT-1
        ld a,c
        jr z,hexeditor_pgdownq
        call nvhex_calcnextcorrectxy
        jr c,hexeditor_pgdown0
hexeditor_pgdownq
        ld (hexcuraddrxy),de
        ret
hexeditor_pgdown_do
        ld (hexaddrline),hl
        ld (hexaddrlineHSB),a
        push de
        call hexeditor_prpage
        pop de
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        ld d,0
hexeditor_pgdown_do0
        ld c,a
        ld a,d
        cp hexeditor_HGT-1
        ld a,c
        jr z,hexeditor_pgdown_doq
        call nvhex_calcnextcorrectxy
        jr c,hexeditor_pgdown_do0
hexeditor_pgdown_doq
        ld (hexcuraddrxy),de
        jp clear_keyboardbuffer 

hexeditor_up
        call nvhex_calccuraddrline 
        call hexeditor_prevline
        ret nc ;bof
        ld de,(hexcuraddrxy)
        ld a,d
        or a
        jr z,hexeditor_up_scroll
        dec d
        ld (hexcuraddrxy),de
        ret
hexeditor_up_scroll        
        ld de,hexeditor_XYTOP
        ld hl,256*hexeditor_HGT + hexeditor_WID
       if PRSTDIO
        call scrolldown
       else
        OS_SCROLLDOWN
       endif
        ld de,hexeditor_XYTOP
        call nv_setxy ;keeps de,hl,ix
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        call hexeditor_prevline
        ld (hexaddrline),hl
        ld (hexaddrlineHSB),a
        jp hexeditor_prline

hexeditor_down
        call nvhex_calccuraddrline 
        ld de,(hexcuraddrxy)
        call nvhex_calcnextcorrectxy
        ret nc
        ld c,a
        ld a,d
        cp hexeditor_HGT
        ld a,c
        jr z,hexeditor_down_scroll
        ld (hexcuraddrxy),de
        ret
hexeditor_down_scroll
        ;ld hl,(hexaddrline)
        ;ld a,(hexaddrlineHSB)
        ;ld bc,hexeditor_PAGESIZE
        ;add hl,bc
        ;adc a,0
        push af
        push hl
        ld a,e
        ld (hexcuraddrx),a
        ld de,hexeditor_XYTOP
        ld hl,256*hexeditor_HGT + hexeditor_WID
       if PRSTDIO
        call scrollup
       else
        OS_SCROLLUP
       endif
        ld de,hexeditor_XYTOP+((hexeditor_HGT-1)*256)
        call nv_setxy ;keeps de,hl,ix
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        ld bc,16
        add hl,bc
        adc a,b;0
        ld (hexaddrline),hl
        ld (hexaddrlineHSB),a
        pop hl
        pop af
        jp hexeditor_prline

nvhex_calccuraddrline
;out: ahl = addr cur line
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        ld de,(hexcuraddrxy)
        ld e,0
        srl d
        rr e
        srl d
        rr e
        srl d
        rr e
        srl d
        rr e
        add hl,de       ;hl+d*16
        adc a,0
        ret

nvhex_calcnextcorrectxy
;ahl=line addr, de=yx
;out:ahl=line addr, de=yx, NC=error
        ld bc,16
        add hl,bc
        adc a,b
        call iseof
        jr nc,nvhex_calcnextcorrectxy_error
        inc d
        ld c,e
        ld b,0
        push hl
        add hl,bc
        call iseof
        pop hl
        ret c
        push af
        ld a,(filesize)
        dec a
        and 0x0f
        ld e,a
        pop af 
        scf
        ret ;CY
nvhex_calcnextcorrectxy_error
        call hexeditor_prevline
        or a
        ret ;NC
        
hexcuraddrxy
hexcuraddrx
        db 0
hexcuraddry
        db 0

hexaddrline
        dw 0
hexaddrlineHSB
        db 0
