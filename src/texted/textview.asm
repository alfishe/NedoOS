
texted_XYTOP=0x0000
texted_HGT=24
texted_WID=80
_texted_PANELCOLOR=0x0700;0x38

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

;texted_waitkey_nokey
        ld de,(curxy)
	call nv_setxy
        ld a,2
mainloop_yieldkeep
        ld (wasnokey),a
	YIELDKEEP
        ld a,55+128 ;"or a"
        ld (texted_wasyield),a
texted_waitkey_nokey
        GETKEY_ ;OS_GETKEYNOLANG
        ;or a ;cp NOKEY ;keylang==0?
        ;jr nz,texted_mainloop_keyq
        ;cp c ;keynolang==0?
        ;ld a,c ;keynolang
        ;cp NOKEY ;TODO отличить от отсутствия фокуса nz? (не в фокусе клавиши не отдаются)
        jr nz,texted_mainloop_keyq ;event
        GETKEY_
        jr nz,texted_mainloop_keyq ;event
       ld a,(stdindatacount)
       or a
       jr nz,texted_mainloop
;если два раза подряд нет события, то делаем YIELD, иначе YIELDKEEP
;рисовать панельку только при отсутствии события после YIELD
wasnokey=$+1
        ld a,1
        dec a
        jr nz,mainloop_yieldkeep
texted_wasyield=$
        scf
        jr nc,nopanel
texted_panelredrawflag=$
        scf ;/or a
        call c,texted_panel
        ld de,(curxy)
	call nv_setxy
nopanel
        YIELD
        ld a,55 ;"scf"
        ld (texted_wasyield),a
        jr texted_waitkey_nokey
texted_mainloop_keyq      

        cp key_redraw
        jr z,texted_redrawloop
        cp key_esc
        ret z
        
        ld hl,texted_mainloop
        push hl
        cp key_up
        jp z,texted_up
        cp key_down
        jp z,texted_down
        cp key_pgup
        jp z,texted_pgup
        cp key_pgdown
        jp z,texted_pgdown
        ;cp 's'
        ;jp z,texted_changeencoding
        cp key_home
        jp z,texted_home
        cp key_end
        jp z,texted_end
        cp key_left
        jp z,texted_left
        cp key_right
        jp z,texted_right
        cp key_sspgup;ext3
        jp z,texted_gotobof;home
        cp key_sspgdown;ext4
        jp z,texted_gotoeof;end
        cp extW
        jp z,texted_wrap
         cp key_ins
         jp z,texted_wrap
        cp key_backspace
        jp z,texted_backspace
        cp key_del
        jp z,texted_del
        cp key_enter
        jp z,texted_enter
        cp key_csenter
        jp z,texted_save
        cp key_F2
        jp z,texted_save
        cp 0x20
        ret c ;прочие системные кнопки не нужны
typein
        ld c,a
        call linesize_minus_x ;sz<x = error
        call c,insert_minushl_spaces
        call calccursoraddr
        call insertbyte
;TODO wrap (reprint screen if needed)        
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
        ld de,defaultfilename
        OS_CREATEHANDLE
        or a
        ret nz
;b=new file handle
        push bc
        ld a,b
        ld (cmd_savepage_handle),a

        ;ld de,(fcb+FCB_FSIZE)
        ;ld hl,(fcb+FCB_FSIZE+2)
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
        and 0xc0
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
	call setunchanged
        jp setpanelredrawflag

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
;TODO wrap (set y, reprint screen if needed)
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
         ld a,c ;deleted byte
         cp 0x0d
         ld a,b
         jr z,texted_backspace_startline_onlycr ;for CR texts
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
;ahl=at deleted CR/LF
;if not CR/LF before, go to "previous line" (after earlier CR/LF) and count difference
;else x=0
	 push af
	 push hl
        call prevbyte
        call getbyte ;c
	 pop hl
	 pop af
	 ld d,h
	 ld e,l
        ld b,a
        ld a,c
        cp 0x0d
	jr z,texted_backspace_startline_setxshift_hlminusde
        cp 0x0a
	jr z,texted_backspace_startline_setxshift_hlminusde
        ld a,b

        ;push af
        push hl
        call texted_prevline ;CY=error (impossible?)
        ex de,hl
        ;ld c,a
        pop hl ;hl=at deleted CR?,de=prevline
        ;pop af
texted_backspace_startline_setxshift_hlminusde
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
;TODO wrap (set y)
        ld hl,0
        call setxshift_hl
        jp setredrawflag

texted_end
;TODO wrap (set y)
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
         cp 0x0d
         ld a,b
         ret z ;for CR texts
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
;TODO wrap (set y, reprint screen if needed)
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
         call iswrapon ;CY=on
         jr c,texted_right_wrap
	ld hl,(texted_prline_shift)
        ld bc,8
        add hl,bc
        ld (texted_prline_shift),hl
        ld a,e
        sub c;8
        ld (curx),a
        jp setredrawflag;texted_prcurpage
        
texted_right_wrap
        xor a
        ld (curx),a
        jp texted_down
        
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
        ld a,55+0x80 ;or a
        ld (texted_lineredrawflag),a
        ld de,(curxy)
        ld e,0
        push de
	call nv_setxy
        pop de
;print lines until CR or EOF
        ld hl,(curlineaddr)
        ld a,(curlineaddrHSB)
texted_prcurline_continue0
        push de
        call texted_prline_nextline
        call c,getsize
        call iseof
        pop de
        ret z
        call prevbyte
        call getbyte
        ld b,a
        ld a,c
        cp 0x0d
        ret z
        cp 0x0a
        ret z
        inc d
        ld a,d
        cp texted_HGT
        ret z
        ld a,b
        call nextbyte
        jr texted_prcurline_continue0

texted_prcurpage
         ;ld e,0
         ;OS_CLS
        ld a,55+0x80 ;or a
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
        ld hl,(filesize)
        ld a,(filesizeHSW)
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
        call scrolldown ;OS_SCROLLDOWN
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
        call scrollup ;OS_SCROLLUP
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
        ld b,50;5
clear_keyboardbuffer0
        push bc
        GETKEY_
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
        ld a,55+0x80 ;or a
        ld (texted_panelredrawflag),a
        ld de,0x1800
	call nv_setxy
        ld de,_texted_PANELCOLOR
        SETCOLOR_
        
        ld a,(texted_prline_recodepatch)
        or a
        ld hl,t866
        jr z,$+5
        ld hl,twin
        call prtext
        
fchanged=$+1
        ld a,' '
        PRCHAR_
        call calccurlinex
        inc hl
        call prword
        ld a,','
        PRCHAR_
texted_ncurline=$+1
        ld hl,0
        call prword
        ld a,'/'
        PRCHAR_
        ld hl,(nlines)
        exx 
        ld hl,0
        exx
        call prdword
        ld a,' '
        PRCHAR_
        call getsize
        exx
        ;ld hl,(fcb+FCB_FSIZE+2)
        ld l,a
        ld h,0
        exx
        ;ld hl,(fcb+FCB_FSIZE)
        call prdword
        ld de,tspaces_filename
        ld hl,TSPACES_FILENAME_SZ
        call sendchars
        ;ld de,_texted_PANELCOLOR;#38
        ;OS_PRATTR
        ld de,_COLOR
        SETCOLOR_
        
        ret

tspaces_filename
	db ' '
tshown_filename
        ds TSPACES_FILENAME_SZ,' '
        
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
        ;ld de,(fcb+FCB_FSIZE)
        ;ld bc,(fcb+FCB_FSIZE+2)
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
        push af
        ld de,texted_XYTOP
	call nv_setxy
        pop af
        ld b,texted_HGT
texted_prpage0
        push bc
        ;push de
        call texted_prline_nextline
        call c,getsize
        ;pop de
        pop bc
        ;inc d
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
;if eof, returns CY and old addr (use call c,getsize) [eof addr]
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
        ;ld a,texted_WID
        jr c,texted_prlinespc_all
        jr z,texted_prlinespc_all ;maxlinesize<=lineshift

        push hl
        ld hl,texted_WID
        call minhl_bc_tobc
        ld b,c
        pop hl
;b=number of chars to print != 0
        ld de,prlinebuf
        ld c,texted_WID
texted_prline0
        ld a,(hl)
        inc hl
        cp 0x0d
        jr z,texted_prline_cr
        cp 0x0a
        jr z,texted_prline_cr;lf
        ;push bc
        push hl
        ld h,twinto866/256
        ld l,a
texted_prline_recodepatch=$
        nop ;/ld a,(hl)
        ld (de),a ;PRCHAR_
        inc de
        pop hl
        ;pop bc
        dec c
        djnz texted_prline0
        ;call print_prlinebuf
        ;jr nz,texted_prline_lf
        ;ret
texted_prline_cr
        call print_prlinebuf
;texted_prline_lf
;допечатать пробелы до конца строки
        jr texted_prlinespc
texted_prlinespc_all
        ld c,texted_WID
texted_prlinespc
        push af
        push hl
        ;ld l,b
        ;ld h,0
        ;ld de,tspaces
        ;call sendchars
         ld a,c
         or a
        call nz,clearrestofline_crlf
        pop hl
        pop af
        ret

print_prlinebuf
        push af
        push bc
        push hl
;c=texted_WID-число символов
        ld de,prlinebuf
        ld a,texted_WID
        sub c
        ld l,a
        ld h,0
        call sendchars
        pop hl
        pop bc
        pop af
        ret

prlinebuf
        ds texted_WID

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
         ld a,(hl)
         inc hl
         cp 0x0d
         jr z,texted_pseudoprline_crok
         cp 0x0a
         jr z,texted_pseudoprline_lf
         dec hl
        jp texted_nextlineq
texted_pseudoprline_cr
        dec b
        jp z,texted_nextlineq
texted_pseudoprline_crok
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
        jr z,istherecr_or_lf_popafZret;ret z
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
        
istherecr_or_lf_popafZret
        pop af
        cp a ;Z
        ret
        
;texted_closefcb
;        ld de,fcb
;        OS_FCLOSE
;        ret

setunchanged
	ld a,' '
	jr setchanged_a
setchanged
	ld a,'*'
setchanged_a
	ld (fchanged),a
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
        incbin "../_sdk/codepage/winto866"
