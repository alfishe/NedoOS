
texted_XYTOP=0x0000
texted_HGT=24
texted_WID=80
texted_PANELCOLOR=#38

textview
        ;xor a
        ;ld h,a
        ;ld l,a
        ;call texted_settop
        ;ld (curlineaddr),hl
        ;ld (curlineaddrHSB),a
        ;ld hl,1
        ;ld (texted_ncurline),hl
        ;ld hl,0
        ;ld (curxy),hl
        call texted_gotobof
        
        call texted_panel        
        
        call texted_calclines

texted_redrawloop
        call setredrawflag
texted_mainloop
texted_lineredrawflag=$
        scf ;/or a
        call c,texted_prcurline ;might set redrawflag
texted_redrawflag=$
        scf ;/or a
        call c,texted_prcurpage
        ld de,(curxy)
	call nv_setxy
	OS_GETATTR ;a
        push af ;color
	ld e,#38 ;TODO зависит от регистра клавиатуры (передать его в старших битах H в GET_KEY)
	OS_PRATTR

        if 1==0
        YIELDGETKEYLOOP
texted_panelredrawflag=$
        scf ;/or a
        else
1;prwindow_waitkey_nokey
	YIELD ;halt ;если сделать просто di:rst #38, то 1.сдвинем таймер и 2.можем потерять кадровое прерывание, а если без ei, то будут глюки
        GET_KEY ;OS_GETKEYNOLANG
        or a ;cp NOKEY ;keylang==0?
        jr nz,texted_mainloop_keyq
        cp c ;keynolang==0?
        ;ld a,c ;keynolang
        ;cp NOKEY ;как отличить от отсутствия фокуса? (не в фокусе клавиши не отдаются) TODO
        jr nz,texted_mainloop_keyq
texted_panelredrawflag=$
        scf ;/or a
        call c,texted_panel
        jr 1b;prwindow_waitkey_nokey
texted_mainloop_keyq
        endif
         ;push af
         ;OS_CLS
         ;pop af
        
        pop bc ;b=color
        push af
        ld de,(curxy)
	call nv_setxy
	ld e,b;COLOR
	OS_PRATTR
        pop af

        cp key_redraw
        jr z,texted_redrawloop
        cp csSpace
        ret z
        
        ld hl,texted_mainloop
        push hl
        cp cs7
        jp z,texted_up
        cp cs6
        jp z,texted_down
        cp cs3
        jp z,texted_pgup
        cp cs4
        jp z,texted_pgdown
        ;cp 's';csss
        ;jp z,texted_changeencoding
        cp Home;ssQ
        jp z,texted_home
        cp End;ssE
        jp z,texted_end
        cp cs5
        jp z,texted_left
        cp cs8
        jp z,texted_right
        cp ext3
        jp z,texted_gotobof;home
        cp ext4
        jp z,texted_gotoeof;end
        cp extW;'w'
        jp z,texted_wrap
        cp cs0 ;backspace
        jp z,texted_backspace
        cp cs9 ;del
        jp z,texted_del
        cp Enter
        jp z,texted_enter
        cp csEnter
        jp z,texted_save
         ;cp csss
         ;jr z,typein
        ;cp csss;'4'
        ;jp z,texted_hexeditor
        cp ' '
        ret c
typein
        ld c,a
        call linesize_minus_x ;sz<x = error
        call c,insert_minushl_spaces
        call calccursoraddr
        call insertbyte
        
        call setlineredrawflag;texted_prcurpage
        jp texted_right

linesize_minus_x
;sz<x = CY
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
        call calclinesz ;hl=sz
        ex de,hl
        call calccurlinex
        ex de,hl
        or a
        sbc hl,de ;sz<x = error
        ret

insert_minushl_spaces
        push bc
textinsertsymbol_pseudospace0
        push hl ;sz-x < 0
        call texted_end
        call calccursoraddr
        ld c,' '
        call insertbyte
        pop hl ;sz-x < 0
        inc hl
        inc h
        dec h
        jr nz,textinsertsymbol_pseudospace0
        call texted_end
        pop bc
        ret

texted_enter
        call linesize_minus_x ;sz<x = error
        ;jr nc,texted_enter_nopseudospaces
        call c,texted_end
;texted_enter_nopseudospaces
        call calccursoraddr
        ld c,0x0d
        call insertbyte
        ld c,0x0a
        call insertbyte
        xor a
        ld (curx),a
        ld hl,0
        ld (texted_prline_shift),hl

        call setredrawflag;texted_prcurpage

        call incnlines
        jp texted_down
        
texted_save
texted_filenameaddr=$+1
        ld de,0;fcb_filename
        OS_CREATEHANDLE
        or a
        ret nz
;b=new file handle
        push bc
        ld a,b
        ld (cmd_savepage_handle),a

        ;ld de,(fcb+FCB.FSIZE)
        ;ld hl,(fcb+FCB.FSIZE+2)
        call getsize
        ex de,hl
        ld l,a
        ld h,0
        ld a,0 ;page number
texted_save0
;a=page number in table (0..)
;hlde=remaining size
        push af ;pg
        push de ;remaining LSW
        push hl ;remaining HSW
        call setpg32k
        ld a,d
        and #c0
        or h
        or l
        jr z,$+5 ;de=size
        ld de,#4000
        ex de,hl ;hl=pg size
         push hl ;hl=pg size
        call cmd_savepage
         pop bc ;bc=pg size
        pop hl ;remaining HSW
        pop de ;remaining LSW
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
        jr z,texted_save_popq
        pop af ;pg
        inc a
        jr texted_save0
texted_save_popq
        pop af
        pop bc
        OS_CLOSEHANDLE
        ret

cmd_savepage
;hl=size
;out: a=error
cmd_savepage_handle=$+1
        ld b,0
        ld de,#8000
;B = file handle, DE = Buffer address, HL = Number of bytes to write
        OS_WRITEHANDLE
;HL = Number of bytes actually written, A=error
        ret
        
setredrawflag
        ld a,55 ;scf
        ld (texted_redrawflag),a
        ;ret
setpanelredrawflag
        ld a,55 ;scf
        ld (texted_panelredrawflag),a
        ret
setlineredrawflag
        ld a,55 ;scf
        ld (texted_lineredrawflag),a
        jr setpanelredrawflag;ret

calccurlinex
        ld hl,(texted_prline_shift)
        ld a,(curx)
        add a,l
        ld l,a
        ret nc
        inc h
        ret
        
calccursoraddr
;TODO учитывать ширину строки (правее строки простое сложение бессмысленно)
        call calccurlinex
        ex de,hl
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
        add hl,de
        adc a,0
        ret
        
texted_backspace
        call calccurlinex
        ld a,h
        or l
        jr z,texted_backspace_startline

        call linesize_minus_x ;sz<x = error
        jp c,texted_left

        call calccursoraddr
        call prevbyte
        ;call isbof
        ;ret z
        call deletebyte        
        call setlineredrawflag
        jp texted_left
texted_backspace_startline
        call calccursoraddr
        call isbof
        ret z
        call prevbyte
        call getbyte
        push bc
        call deletebyte
        pop bc
        ld b,a
        ld a,c
        cp 0x0a
        ld a,b
        jr nz,texted_backspace_startline_onlycr
        call isbof
        jr z,texted_backspace_startline_onlycr
        call prevbyte
        call getbyte
        ld b,a
        ld a,c
        cp 0x0d
        ld a,b
        ;jr nz,texted_backspace_startline_onlycr
        call z,deletebyte ;0x0d
texted_backspace_startline_onlycr
        ;push af
        push hl
        call texted_prevline ;CY=error (impossible?)
        ex de,hl
        ;ld c,a
        pop hl
        ;pop af
        or a
        sbc hl,de
        ;sbc a,c
        call setxshift_hl
        
        call setredrawflag

        call decnlines
        jp texted_up

decnlines
        push hl
        ld hl,(nlines)
        dec hl
        ld (nlines),hl
        pop hl
        ret
incnlines
        push hl
        ld hl,(nlines)
        inc hl
        ld (nlines),hl
        pop hl
        ret

texted_home
        ld hl,0
        call setxshift_hl
        jp setredrawflag

texted_end
        ;call calccursoraddr
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
        call calclinesz ;hl=sz
        call setxshift_hl
        jp setredrawflag

calclinesz
;ahl=line addr
;out: hl=sz (keeps bc,de)
        push bc
        call texted_nextline ;CY=error
        call c,getsize
        call nc,skipbackcrlf
        ld bc,(curlineaddr)
        or a
        sbc hl,bc
        pop bc
        ret

skipbackcrlf
;out: ahl=eof or endline+1 (at cr/lf)
        call isbof
        ret z
        call prevbyte
        call getbyte
        ld b,a
        ld a,c
        cp 0x0a
        ld a,b
        jp nz,nextbyte
        call isbof
        ret z
        call prevbyte
        call getbyte
        ld b,a
        ld a,c
        cp 0x0d
        ld a,b
        jp nz,nextbyte
        ret
        
setxshift_hl
;X=hl=ahl-startline
;x+shift = X:
;x = min(X,texted_WID-1), но под mod8 должен совпадать с X
;shift = X-x
        ld bc,texted_WID-1
        call minhl_bc_tobc
        ld a,c
        xor l
        and %11111000
        xor l
        ld c,a
        ld (curx),a
        or a
        sbc hl,bc
        ld (texted_prline_shift),hl
        ret
        
texted_del
        call linesize_minus_x ;sz<x = error
        jr c,texted_del_newline
        jr z,texted_del_newline
        call texted_right
        jp texted_backspace
texted_del_newline
;удаление ентера справа (backspace не умеет)
;hl=sz-x
        call c,insert_minushl_spaces
        call setredrawflag
        call calccursoraddr
        call iseof
        ret z
        call decnlines
        call getbyte
        push af
        call deletebyte
        pop bc ;b=deleted byte
        ld c,a
        ld a,b
        cp 0x0a
        ld a,c
        ret z ;endline = 0x0a
        call iseof
        ret z
        call getbyte
        ld b,a
        ld a,c
        cp 0x0a
        ld a,b
        ret nz
        call deletebyte        
        ret
        
texted_wrap
        ld a,(wrapflag)
        xor 128 
        ld (wrapflag),a
        ld hl,0
        ld (texted_prline_shift),hl
        ld (curxy),hl
        call texted_calclines
        ld hl,(curtoptextaddr)
        ld a,(curtoptextHSB)
        ld (curlineaddr),hl
        ld (curlineaddrHSB),a
        call texted_calccurline
        jp setredrawflag;texted_prcurpage
        
texted_right
;TODO X<16384
        call setpanelredrawflag
        ld de,(curxy)
        inc e
        ld a,e
        cp texted_WID
        ld (curx),a
        ret c
	ld hl,(texted_prline_shift)
        ld bc,8
        add hl,bc
        ld (texted_prline_shift),hl
        ld a,e
        sub c;8
        ld (curx),a
        jp setredrawflag;texted_prcurpage
        
texted_left
        call setpanelredrawflag
        ld de,(curxy)
        ld a,e
        sub 1
        ld e,a
        ld (curx),a
        ret nc
        xor a
        ld (curx),a
        ld hl,(texted_prline_shift)
        ld bc,8
        or a
        sbc hl,bc
        ret c
        ld (texted_prline_shift),hl
        ld a,e
        add a,c;8
        ld (curx),a
        jp setredrawflag;texted_prcurpage
        
texted_prcurline
        ld a,55+#80 ;or a
        ld (texted_lineredrawflag),a
        ;TODO
        ld de,(curxy)
        ld e,0
	call nv_setxy
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
        jp texted_prline

texted_prcurpage
         ;ld e,0
         ;OS_CLS
        ld a,55+#80 ;or a
        ld (texted_redrawflag),a
        ld hl,(curtoptextaddr)
        ld a,(curtoptextHSB)
        jp texted_prpage
        
texted_gotobof
        xor a
        ld h,a
        ld l,a
;texted_gotobof_ok
        call texted_settop
        ld (curlineaddr),hl
        ld (curlineaddrHSB),a
        ;ld hl,1
        ;ld (texted_ncurline),hl
;ahl=curtextline (kept)
        call texted_calccurline
        ld hl,0
        ld (curxy),hl
        jp setredrawflag;texted_prcurpage

getsize
        ld hl,(fcb+FCB.FSIZE)
        ld a,(fcb+FCB.FSIZE+2)
        ret
        
texted_gotoeof
        call getsize
        ld b,texted_HGT
texted_end0
        push bc 
        call texted_prevline
        pop bc
        djnz texted_end0
;ahl=curtextline (kept)
        call texted_calccurline
        ;push hl
        ;ld hl,(texted_ncurline)
        ;jr $
        ;pop hl

        jp texted_pgdown_bottom


deccurline
        push hl
        ld hl,(texted_ncurline)
        dec hl
        ld (texted_ncurline),hl
        pop hl
        ret
deccury
        push hl
        ld hl,cury
        dec (hl)
        pop hl
        ret
        
inccurline
        push hl
        ld hl,(texted_ncurline)
        inc hl
        ld (texted_ncurline),hl
        pop hl
        ret
inccury
        push hl
        ld hl,cury
        inc (hl)
        pop hl
        ret

texted_up
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
        call texted_prevline
        ret c
        ld (curlineaddr),hl
        ld (curlineaddrHSB),a
        push af
        push hl
        call deccurline
        call setpanelredrawflag
        pop hl
        pop af
        ld c,a
        ld a,(cury)
        sub 1
        ld (cury),a
        ret nc
        inc a
        ld (cury),a
        ld a,c
        call texted_settop
        push af
        push hl
        ld de,texted_XYTOP
        ld hl,256*texted_HGT + texted_WID
        OS_SCROLLDOWN
        ld de,texted_XYTOP
	call nv_setxy
        pop hl
        pop af
        call texted_prline
        ret

texted_down
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
        call texted_nextline
        ret c
        ld (curlineaddr),hl
        ld (curlineaddrHSB),a
        push af
        push hl
        call inccurline
        call setpanelredrawflag
        pop hl
        pop af
        ld c,a
        ld de,(curxy)
        inc d
        ld a,d
        cp texted_HGT
        ld (curxy),de
        ret c
        dec a
        ld (cury),a
        ld a,c
        push af
        push hl
        ld de,texted_XYTOP
        ld hl,256*texted_HGT + texted_WID
        OS_SCROLLUP
        ld de,texted_XYTOP+((texted_HGT-1)*256)
	call nv_setxy
        pop hl
        pop af
        call texted_prline;_nextline
curtoptextaddr=$+1
        ld hl,0
curtoptextHSB=$+1
        ld a,0
        call texted_nextline
texted_settop        
        ld (curtoptextaddr),hl
        ld (curtoptextHSB),a
        ret

texted_pgup
        call setpanelredrawflag
        ld a,(cury)
        or a
        ld b,a
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
        jr z,texted_pgup_top
texted_pgup_gotop0
        push bc 
        call texted_prevline
         call nc,deccurline
         call nc,deccury
        pop bc
        djnz texted_pgup_gotop0
        ld (curlineaddr),hl
        ld (curlineaddrHSB),a
        ret
texted_pgup_top
        ld b,texted_HGT-1
texted_pgup0
        push bc 
        call texted_prevline
         call nc,deccurline
        pop bc
        djnz texted_pgup0
        call texted_settop
        ld (curlineaddr),hl
        ld (curlineaddrHSB),a
        call setredrawflag
        ret
        
texted_pgdown
        call setpanelredrawflag
        ld a,(cury)
        sub texted_HGT-1
        neg
        ld b,a
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
        jr z,texted_pgdown_bottom
texted_pgdown_gobottom0
        push bc 
        call texted_nextline
         call nc,inccurline
         call nc,inccury
        pop bc
        djnz texted_pgdown_gobottom0
        ld (curlineaddr),hl
        ld (curlineaddrHSB),a
        ret
texted_pgdown_bottom
        push af
        xor a
        ld (cury),a
        pop af
        call texted_settop
        ld b,texted_HGT-1
texted_pgdown0
        push bc 
        call texted_nextline
         call nc,inccurline
         call nc,inccury
        pop bc
        djnz texted_pgdown0
        ld (curlineaddr),hl
        ld (curlineaddrHSB),a
        jp setredrawflag
        
texted_calccurline
;ahl=curtextline (kept)
        push af
        push hl
        ld (texted_calccurline_old),hl
        ld (texted_calccurline_oldHSB),a
        ld ix,1;0
         or h
         or l
         jr z,texted_calccurline_countq
        xor a
        ld h,a
        ld l,a
texted_calccurline_count0
        call texted_nextline ;texted_pseudoprline

        if 1==0
        jr c,texted_calccurline_countq ;не помогает
        ex de,hl
texted_calccurline_old=$+1
        ld hl,0
        or a
        sbc hl,de ;nc: hl<=old
        ld l,a
texted_calccurline_oldHSB=$+1
        ld a,0
        sbc a,l
        ld a,l
        inc ix
        jr nc,texted_calccurline_count0 ;nc: ahl<=old
        else
        
        push hl
texted_calccurline_old=$+1
        ld bc,0
        or a
        sbc hl,bc ;nc: hl>=old
        ld l,a
texted_calccurline_oldHSB=$+1
        sbc a,0
        ld a,l
        pop hl
        inc ix
        jr c,texted_calccurline_count0 ;cy: ahl<old
        endif
texted_calccurline_countq
        ;push ix
        ;pop hl
        ld (texted_ncurline),ix;hl
        pop hl
        pop af
        ret
        
texted_calclines
;sets nlines
        xor a
        ld h,a
        ld l,a
        ld (nlines),hl
texted_calclines0
        call incnlines
        call texted_nextline
        jr nc,texted_calclines0
        ret
        
clear_keyboardbuffer
        push bc
        ld b,5
clear_keyboardbuffer0
        push bc
        GET_KEY
        pop bc
        djnz clear_keyboardbuffer0
        pop bc
        ret
        
texted_changeencoding
        ld hl,texted_prline_recodepatch
        ld a,(hl)
        xor 0x7e ;"ld a,(hl)"
        ld (hl),a
        call setredrawflag;texted_prcurpage
        ;call texted_prcurpage
        ;ret
texted_panel
        ld a,55+#80 ;or a
        ld (texted_panelredrawflag),a
        ld de,0x1800
	call nv_setxy
        ld e,texted_PANELCOLOR;#38
        OS_SETCOLOR
        
        ld a,(texted_prline_recodepatch)
        or a
        ld hl,t866
        jr z,$+5
        ld hl,twin
        call prtext
        
        ld a,' '
        PRCHAR
texted_ncurline=$+1
        ld hl,0
        exx 
        ld hl,0
        exx
        call prdword
        ld a,'/'
        PRCHAR
        ld hl,(nlines)
        exx 
        ld hl,0
        exx
        call prdword
        ld a,' '
        PRCHAR
        call getsize
        exx
        ;ld hl,(fcb+FCB.FSIZE+2)
        ld l,a
        ld h,0
        exx
        ;ld hl,(fcb+FCB.FSIZE)
        call prdword
        ld b,43
texted_panel0
        ld a,' '
        push bc
        PRCHAR
        pop bc
        djnz texted_panel0
        ld e,texted_PANELCOLOR;#38
        OS_PRATTR
        ld e,COLOR;#38
        OS_SETCOLOR
        
        ret
        
twin
        db "WIN",0
t866
        db "866",0

      
isbof
;out: z=bof
        push bc
        ld c,a
        or h
        or l
        ld a,c
        pop bc
        ret
iseof
;out: z=eof
        push bc
        push de
        push hl
        ;ld de,(fcb+FCB.FSIZE)
        ;ld bc,(fcb+FCB.FSIZE+2)
        ;ld b,a
        ;or a
        ;sbc hl,de
        ;sbc a,c
        ;ld a,b
        ex de,hl
        ld c,a
        call getsize
        or a
        sbc hl,de
        sbc a,c
        or h
        or l
        ld a,c
        pop hl
        pop de
        pop bc
        ret
      
texted_prpage
;ahl=addr
        ld (curtoptextaddr),hl
        ld (curtoptextHSB),a
        ld de,texted_XYTOP
        ld b,texted_HGT
texted_prpage0
        push bc
        push de
        push af
	call nv_setxy
        pop af
        call texted_prline_nextline
        call c,getsize
        pop de
        pop bc
        inc d
        djnz texted_prpage0
        ;call clear_keyboardbuffer
        ret
        
texted_prevline
;ahl=addr
;line < 16K
;out: ahl, CY=error (keeps de)
        call isbof
         scf
        ret z
;перед нами может быть #0d или #0d,#0a или ничего
        ld (findprevline_old),hl
        ld (findprevline_oldHSB),a
        
        or a
        ld bc,0xffff
        jr nz,$+4
         ld b,h
         ld c,l
         
        push de
        ld de,0x4000
        or a
        sbc hl,de
        sbc a,e;0
        pop de
        
        push af
        push hl
        call ahl_to_pgaddr
        set 6,h
;hl=c000+, можно уменьшать
;bc=number of chars to go != 0

;перед нами может быть #0d или #0d,#0a или ничего
        dec hl
        dec bc
        ld a,b
        or c
        jr z,texted_prevlineq
        ld a,0x0a
        cp (hl)
        jr nz,texted_prevline_nolf
        dec hl
        dec bc
        ld a,b
        or c
        jr z,texted_prevlineq
texted_prevline_nolf
        ld a,0x0d
        cp (hl)
        jr nz,texted_prevline_nocr
        dec hl
        dec bc
        ld a,b
        or c
        jr z,texted_prevlineq
texted_prevline_nocr
;сейчас мы находимся перед символом конца предыдущей строки (не на нём)
texted_prevline0
        ld a,(hl)
        cp 0x0d
        jr z,texted_prevline_cr
        cp 0x0a
        jr z,texted_prevline_lf
        dec hl
        dec bc
        ld a,b
        or c
        jr nz,texted_prevline0
;beginning of file
        jr texted_prevlineq
texted_prevline_cr
texted_prevline_lf
;сейчас мы находимся на конце символа конца строки перед предыдущей
        inc hl
texted_prevlineq
        ex de,hl ;new addr (bits 13..0), bit 14 = overflow
        pop hl ;old addr
        pop af
        call pgaddr_to_ahl
        call iswrapon ;CY=on
        ret nc ;no wrap

findprevline_linewrap
;ahl = в начале строки
;перед ней может быть #0d или #0d,#0a
;надо псевдонапечатать несколько псевдострок, пока не дойдём до текущей
findprevline_linewrap_count0
         push af
         push hl
        call texted_pseudoprline
        push hl
findprevline_old=$+1
        ld bc,0
        or a
        sbc hl,bc ;nc: hl>=old
        ld l,a
findprevline_oldHSB=$+1
        sbc a,0
        ld a,l
        pop hl
         pop de ;old addr
         pop bc ;b=old HSB
        jr c,findprevline_linewrap_count0
        ex de,hl
        ld a,b
;ahl=на псевдострочку раньше
        ret ;nc

getmaxlinesize
;ahl = addr
;out: bc=max line size before eof, z=(bc==0) (keeps ahl,de)
         push de
        push af
        push hl
        ex de,hl
        ld c,a
        call getsize
        or a
        sbc hl,de
        sbc a,c
        ld bc,0
        jr c,getmaxlinesize_aftereof
        dec bc
        or a
        jr nz,$+4 ;filesize-addr >= 0x10000, will be 0xffff
         ld b,h
         ld c,l ;filesize-addr
getmaxlinesize_aftereof
        pop hl
        pop af
        ld e,a
        ld a,b
        or c
        ld a,e
         pop de
        ret

texted_prline_nextline
        push af
        push hl
        call texted_prline
        pop hl
        pop af
texted_nextline
;if eof, returns eof addr
;ahl=addr
;line < 16K
;out: ahl, CY=error (keeps de)
        call iswrapon ;CY=on
        jp c,texted_pseudoprline
        call getmaxlinesize ;bc=max line size before eof, z=(bc==0)
         scf
        ret z
        push af
        push hl
        call ahl_to_pgaddr
;bc=number of chars to go != 0
texted_nextline0
        ld a,(hl)
        inc hl
        dec bc
        cp 0x0d
        jr z,texted_nextline_cr
        cp 0x0a
        jr z,texted_nextline_lf
        ld a,b
        or c
        jr nz,texted_nextline0
;texted_nextline_eof
        pop hl ;old addr
        pop af
        scf ;error
        ret
texted_nextlineq
        ex de,hl ;new addr (bits 13..0), bit 14 = overflow
        pop hl ;old addr
        pop af
        jp pgaddr_to_ahl
texted_nextline_cr
        ld a,b
        or c
        jr z,texted_nextlineq
        ld a,(hl)
        cp 0x0a
        jr nz,texted_nextline_lf
        inc hl
texted_nextline_lf
        jr texted_nextlineq
        
texted_prline
;ahl=addr
;check for last line (vs. file size)
;if filesize-addr < 80, then b=filesize-addr, else b=80
        call getmaxlinesize ;bc=max line size before eof, z=(bc==0)
        jr z,texted_prlinespc_all;ret z
        call ahl_to_pgaddr
;hl=#8000+0..#3fff
;bc=max line size before eof != 0
texted_prline_shift=$+1
        ld de,0
        call istherecr_or_lf ;add hl,de
        ;jr nz,$+3
        ;dec hl ;hl=cr/lf address

        push hl
        ld h,b
        ld l,c
        or a
        sbc hl,de
        ld b,h
        ld c,l ;bc=bc-lineshift
        pop hl
        ld a,texted_WID
        jr c,texted_prlinespc
        jr z,texted_prlinespc

        push hl
        ld hl,texted_WID
        call minhl_bc_tobc
        ld b,c
        pop hl
;b=number of chars to print != 0
        ld c,texted_WID
texted_prline0
        ld a,(hl)
        inc hl
        cp 0x0d
        jr z,texted_prline_cr
        cp 0x0a
        jr z,texted_prline_lf
        push bc
        push hl
        ld h,twinto866/256
        ld l,a
texted_prline_recodepatch=$
        nop ;/ld a,(hl)
        PRCHAR
        pop hl
        pop bc
        dec c
        djnz texted_prline0
        jr nz,texted_prline_lf
        ret
texted_prlinespc_all
        ld c,texted_WID
texted_prline_cr
texted_prline_lf
;допечатать пробелы до конца строки
        ld a,c
texted_prlinespc
        ld b,a
texted_prlinespc_b
        push af
        push hl
texted_prlinespc0
        push bc
        ld a,' '
        PRCHAR
        pop bc
        djnz texted_prlinespc0
        pop hl
        pop af
        ret

texted_pseudoprline
;ahl=addr
;out: ahl, CY=error
;check for last line (vs. file size)
;if filesize-addr < 80, then b=filesize-addr, else b=80
        call getmaxlinesize ;bc=max line size before eof, z=(bc==0)
         scf
        ret z
        push af
        push hl
        call ahl_to_pgaddr
;hl=#8000+0..#3fff
;bc=max line size before eof != 0
        push hl
        ld hl,texted_WID
        call minhl_bc_tobc
        ld b,c
        pop hl
;b=number of chars to print != 0
        ld c,texted_WID
texted_pseudoprline0
        ld a,(hl)
        inc hl
        cp 0x0d
        jr z,texted_pseudoprline_cr
        cp 0x0a
        jr z,texted_pseudoprline_lf
        dec c
        djnz texted_pseudoprline0
        jp texted_nextlineq
texted_pseudoprline_cr
        dec b
        jp z,texted_nextlineq
        ld a,(hl)
        cp 0x0a
        jr nz,texted_pseudoprline_lf
        inc hl
texted_pseudoprline_lf
        jp texted_nextlineq
        
;по идее это псевдопечать N экранных позиций (там могут быть цветовые коды и т.п.)
istherecr_or_lf
;hl=addr ;TODO ahl
;de=length to search
;out: z=found, hl=at match or after area (TODO ahl)
        ld a,d
        or e
        jr z,istherecr_or_lf_fail
         push hl
        ld a,0x0d
        call istherecrlfgo
        jr z,istherecr_or_lf_popafret;ret z
         pop hl
        ld a,0x0a
istherecrlfgo
        push bc
        ld b,d
        ld c,e
        cpir ;TODO несколько раз через все блоки, если заканчиваются блоки, то их переключать
        pop bc
        ret nz ;nz=not found
         dec hl
        ret ;z=found
istherecr_or_lf_fail
        dec a
        ret ;nz=not found
        
istherecr_or_lf_popafret
        pop af
        ret
        
texted_closefcb
        ld de,fcb
        OS_FCLOSE
        ret

iswrapon
;CY = on
wrapflag=$
        or a ;/scf
        ret

curlineaddr
        ds 3
curlineaddrHSB=$-1

nlines
        dw 0

curxy
curx
        db 0
cury
        db 0
        
        align 256
twinto866
        incbin "winto866"
