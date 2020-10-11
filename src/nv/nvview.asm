NVVIEW_XYTOP=0x0000
NVVIEW_HGT=24
NVVIEW_WID=80
_NVVIEW_PANELCOLOR=0x0700;0x38

editcmd_3
        call ifcmdnonempty_typedigit
editcmd_F3
        ;jr $
        call getfcbundercursor ;->fcb
	ld a,(fcb+FCB_FATTRIB)
	and FATTRIB_DIR;#10
        ret nz

        ;call nv_openfcb ;autopush nv_closefcb
        ;ret nz ;error
	ld hl,fcb_filename
        ld de,filenametext
	call cpmname_to_dotname

	call setcurpaneldir

        call setdrawtablesneeded
        ld hl,editcmd_reprintall_noreaddir
        push hl
        ld de,filenametext
nvview
;de=filename
        OS_OPENHANDLE
	or a
        ret nz ;error
        ld a,b
        ld (curhandle),a
        ;ld hl,nv_closehandle
        ;push hl

        ;ld e,COLOR
        ;OS_CLS
        ld de,0
        SETXY_
        CLS_

        ld hl,unreservepages
        push hl
        
        ld hl,0
        ld de,0
nvview_load0
        push de
        push hl
        call reservepage
        pop hl
        pop de
        ret nz ;no memory
;nvview_load0nonewpg        
        ld a,0xc000/256
        call cmd_loadpage
        jr nz,nvview_load0q
        ex de,hl
        add hl,bc
        ex de,hl
        jr nc,$+3
        inc hl
         ;TODO nvview_load0nonewpg with new pointer if no new page
        ld a,b
        or c
        jr nz,nvview_load0
nvview_load0q
;hlde=true file size (for TRDOSFS)
        ld (filesize),de
        ld (filesizeHSW),hl
        call nv_closehandle

        xor a
        ld h,a
        ld l,a
        call nvview_settop
        
        ;call nvview_panel        
        
        call nvview_calclines
        ld hl,1;0
        ld (nvview_ncurline),hl

nvview_redrawloop
        ;jp nvview_hexeditor

        call nvview_prcurpage
nvview_mainloop
        ld a,2
nvview_yieldkeep
        ld (nvview_wasnokey),a
       ;ld a,4 ;b
       ;out (-2),a
	YIELDKEEP
        ;ld a,55+128 ;"or a"
        ;ld (nvview_wasyield),a
nvview_mainloop_nokey
       ;ld a,2 ;g
       ;out (-2),a
        GETKEY_ ;OS_GETKEYNOLANG
         ;jr c,$
        jr z,nvview_mainloop_nokeygo
;есть событие (a=0: от мыши)
        ;ld a,c ;keynolang
        ;cp NOKEY
         or a
        jr nz,nvview_mainloop_keyq
       ;ld a,3 ;y
       ;out (-2),a
         ;jr nvview_mainloop_nokey
nvview_mainloop_nokeygo
        ld a,(nvview_wasnokey)
        out (-2),a        
       ld a,(stdindatacount)
       or a
       jr nz,nvview_mainloop;_nokey
        xor a
        out (-2),a        
;если два раза подряд нет события, то делаем YIELD, иначе YIELDKEEP
nvview_wasnokey=$+1
        ld a,1
        dec a
        jr nz,nvview_yieldkeep
       ;jr nvview_yieldkeep
;рисовать панельку только при отсутствии события после YIELD
;nvview_wasyield=$
        ;scf
        ;call c,nvview_panel ;97359 t
	YIELD
        ;ld a,55 ;"scf"
        ;ld (nvview_wasyield),a
        GETKEY_ ;OS_GETKEYNOLANG
         ;jr c,$
        jr z,nvview_mainloop_yieldnokeygo
;есть событие (a=0: от мыши)
        ;ld a,c ;keynolang
        ;cp NOKEY
         or a
        jr nz,nvview_mainloop_keyq
        jr nvview_mainloop_nokey
nvview_mainloop_yieldnokeygo
       ;ld a,6 ;c
       ;out (-2),a
        call nvview_panel ;97359 t
        jr nvview_mainloop_nokey
nvview_mainloop_keyq
        cp key_redraw
        jr z,nvview_redrawloop
        cp key_esc
        ret z
        cp key_tab
        jp z,nvview_hexeditor
        ld hl,nvview_mainloop
        push hl
        cp key_up
        jp z,nvview_up
        cp key_down
        jp z,nvview_down
        cp key_pgup
        jp z,nvview_pgup
        cp key_pgdown
        jp z,nvview_pgdown
        cp 's';csss
        jp z,nvview_changeencoding
        cp key_home
        jp z,nvview_home
        cp key_sspgup;ext3
        jp z,nvview_home
        cp key_end
        jp z,nvview_end
        cp key_sspgdown;ext4
        jp z,nvview_end
        cp key_left
        jp z,nvview_left
        cp key_right
        jp z,nvview_right
        cp 'w'
        jp z,nvview_wrap
        ret

nvview_hexeditor
        ;pop af ;снимаем адрес возврата
        ld de,0x0000
        call nv_setxy
        ld hl,(curtoptextaddr)
        ld a,(curtoptextHSB)
        ld (hexaddrlineHSB),a
        ld a,l
        and 0xf0
        ld l,a
        ld (hexaddrline),hl
        ld hl,0
        ld (hexcuraddrxy),hl
        jp hexeditor_redrawloop
nvview_hexeditorq
        call nvview_calclines
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        call nvview_nextline
        call nvview_prevline ;line beginning (TODO fix uneven sizes in wrap mode)
        
        call nvview_settop
        call nvview_calccurline
        
        jp nvview_redrawloop

nvview_wrap
        ld a,(wrapflag)
        xor 128 
        ld (wrapflag),a
        ld hl,0
        ld (nvview_prline_shift),hl
        ld hl,(curtoptextaddr)
        ld a,(curtoptextHSB)
        call nvview_pgdown_pgup_ahl;nvview_prcurpage
        call nvview_calclines
        ld hl,(curtoptextaddr)
        ld a,(curtoptextHSB)
        call nvview_calccurline
        ret 
        
nvview_right
        ld a,(nvview_prline_shift)
        add a,8
        ret c
        ld (nvview_prline_shift),a
        call nvview_prcurpage
        jp clear_keyboardbuffer
        
nvview_left
        ld a,(nvview_prline_shift)
        sub 8
        ret c
        ld (nvview_prline_shift),a
        call nvview_prcurpage
        jp clear_keyboardbuffer
        
nvview_prcurpage
        ld hl,(curtoptextaddr)
        ld a,(curtoptextHSB)
        jp nvview_prpage
        
nvview_home
        ld hl,1;0
        ld (nvview_ncurline),hl
        xor a
        ld h,a
        ld l,a
        call nvview_settop
        jp nvview_prpage
        
nvview_end
        ld hl,(filesize)
        ld a,(filesizeHSW)
        ld b,NVVIEW_HGT
nvview_end0
        push bc 
        call nvview_prevline
        pop bc
        djnz nvview_end0
        call nvview_calccurline
        jp nvview_prpage

deccurline
        push hl
        ld hl,(nvview_ncurline)
        dec hl
        ld (nvview_ncurline),hl
        pop hl
        ret
        
inccurline
        push hl
        ld hl,(nvview_ncurline)
        inc hl
        ld (nvview_ncurline),hl
        pop hl
        ret

nvview_up
        ld hl,(curtoptextaddr)
        ld a,(curtoptextHSB)
        call isbof
        ret z
        call nvview_prevline
        call nvview_settop
        push af
        push hl
        ld de,NVVIEW_XYTOP
        ld hl,256*NVVIEW_HGT + NVVIEW_WID
        call scrolldown ;OS_SCROLLDOWN
        ld de,NVVIEW_XYTOP
        call nv_setxy
        pop hl
        pop af
        call nvview_prline
         ld de,24*256+79
         call nv_setxy ;avoid cursor at 0x0100
        call deccurline
        ld hl,(curbottomtextaddr)
        ld a,(curbottomtextHSB)
        call nvview_prevline
        jp nvview_setbottom

nvview_down
curbottomtextaddr=$+1
        ld hl,0
curbottomtextHSB=$+1
        ld a,0
        call iseof
        ret z
        push af
        push hl
        ld de,NVVIEW_XYTOP
        ld hl,256*NVVIEW_HGT + NVVIEW_WID
        call scrollup ;OS_SCROLLUP
        ld de,NVVIEW_XYTOP+((NVVIEW_HGT-1)*256)
        call nv_setxy
        pop hl
        pop af
        call nvview_prline_nextline
        call nvview_setbottom
        call inccurline
curtoptextaddr=$+1
        ld hl,0
curtoptextHSB=$+1
        ld a,0
        call nvview_nextline
nvview_settop        
        ld (curtoptextaddr),hl
        ld (curtoptextHSB),a
        ret

nvview_pgup
        ld hl,(curtoptextaddr)
        ld a,(curtoptextHSB)
nvview_pgup_go
        ld b,NVVIEW_HGT
nvview_pgup0
        push bc 
        call nvview_prevline
         call nc,deccurline
        pop bc
        djnz nvview_pgup0
        call nvview_prpage
        jp clear_keyboardbuffer
        
nvview_pgdown
         ld hl,(nvview_ncurline)
         ld bc,NVVIEW_HGT
         add hl,bc
         ld (nvview_ncurline),hl
        ld hl,(curbottomtextaddr)
        ld a,(curbottomtextHSB)
nvview_pgdown_pgup_ahl
        ld b,NVVIEW_HGT
nvview_pgdown0
        push bc 
        call nvview_nextline
         call nc,inccurline
        pop bc
        djnz nvview_pgdown0
        jr nvview_pgup_go
        if 1==0
        ld b,NVVIEW_HGT
nvview_pgdown1
        push bc 
        call nvview_prevline
         call nc,deccurline
        pop bc
        djnz nvview_pgdown1
        call nvview_prpage
        jp clear_keyboardbuffer
        endif
        
nvview_calccurline
        ;ld hl,(curtoptextaddr)
        ;ld a,(curtoptextHSB)
;ahl=curtextline (kept)
        push af
        push hl
        ld (nvview_calccurline_old),hl
        ld (nvview_calccurline_oldHSB),a
        ld ix,1;0
         or h
         or l
         jr z,nvview_calccurline_countq
        xor a
        ld h,a
        ld l,a
nvview_calccurline_count0
        call nvview_nextline;nvview_pseudoprline
        push hl
nvview_calccurline_old=$+1
        ld bc,0
        or a
        sbc hl,bc ;nc: hl>=old
        ld l,a
nvview_calccurline_oldHSB=$+1
        sbc a,0
        ld a,l
        pop hl
        inc ix
        jr c,nvview_calccurline_count0 ;cy: ahl<old
nvview_calccurline_countq
        ;push ix
        ;pop hl
        ld (nvview_ncurline),ix;hl
        pop hl
        pop af
        ret
        
nvview_calclines
;out ix = lines
        ld ix,0
        xor a
        ld h,a
        ld l,a
nvview_calclines0
        inc ix
        call nvview_nextline
        call iseof
        jp nz,nvview_calclines0
        ld (nlines),ix
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
        
nvview_changeencoding
        ld hl,nvview_prline_recodepatch
        ld a,(hl)
        xor 0x7e ;"ld a,(hl)"
        ld (hl),a
        call nvview_prcurpage
        ;ret
nvview_panel
        ld de,0x1800
        call nv_setxy
        ld de,_NVVIEW_PANELCOLOR;#38
        SETCOLOR_
        
        ld a,(nvview_prline_recodepatch)
        or a
        ld hl,t866
        jr z,$+5
        ld hl,twin
         ld c,0
        call prtext
        
        ld a,' '
        PRCHAR_
nvview_ncurline=$+1
        ld hl,0
        exx 
        ld hl,0
        exx
        call prdword
        ;ix
        ld a,'/'
        PRCHAR_
        ld hl,(nlines)
        exx 
        ld hl,0
        exx
        call prdword
        ld a,' '
        PRCHAR_
        ld hl,(filesizeHSW)
        exx
        ld hl,(filesize)
        call prdword
;        ld b,43
;nvview_panel0
;        ld a,' '
;        push bc
;        PRCHAR_
;        pop bc
;        djnz nvview_panel0
        ld de,tspaces
        ld hl,43
        call sendchars
        ;ld e,NVVIEW_PANELCOLOR;#38
        ;OS_PRATTR
        ld de,_COLOR;#38
        SETCOLOR_
        
        ret
        
twin
        db "WIN",0
t866
        db "866",0

      
isbof
        push bc
        ld c,a
        or h
        or l
        ld a,c
        pop bc
        ret
iseof
        push bc
        push de
        push hl
        ld de,(filesize)
        ld bc,(filesizeHSW)
        ld b,a
        or a
        sbc hl,de
        sbc a,c
        ld a,b
        pop hl
        pop de
        pop bc
        ret
      
nvview_prpage
;ahl=addr
        ld (curtoptextaddr),hl
        ld (curtoptextHSB),a
        push af
        ld de,NVVIEW_XYTOP
        call nv_setxy
        pop af
        ld b,NVVIEW_HGT
nvview_prpage0
        push bc
        ;push de
        ;push af
        ;push hl
        ;call nv_setxy
        ;pop hl
        ;pop af
        call nvview_prline_nextline
        ;pop de
        pop bc
        ;inc d
        djnz nvview_prpage0
nvview_setbottom
        ld (curbottomtextaddr),hl
        ld (curbottomtextHSB),a
        ret
        
nvview_prevline
;ahl=addr
;line < 16K
;out: ahl, CY=error
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
        
        ld de,0x4000
        or a
        sbc hl,de
        sbc a,e;0
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
        jr z,nvview_prevlineq
        ld a,0x0a
        cp (hl)
        jr nz,nvview_prevline_nolf
        dec hl
        dec bc
        ld a,b
        or c
        jr z,nvview_prevlineq
nvview_prevline_nolf
        ld a,0x0d
        cp (hl)
        jr nz,nvview_prevline_nocr
        dec hl
        dec bc
        ld a,b
        or c
        jr z,nvview_prevlineq
nvview_prevline_nocr
;сейчас мы находимся перед символом конца предыдущей строки (не на нём)
nvview_prevline0
        ld a,(hl)
        cp 0x0d
        jr z,nvview_prevline_cr
        cp 0x0a
        jr z,nvview_prevline_lf
        dec hl
        dec bc
        ld a,b
        or c
        jr nz,nvview_prevline0
;beginning of file
        jr nvview_prevlineq
nvview_prevline_cr
nvview_prevline_lf
;сейчас мы находимся на конце символа конца строки перед предыдущей
        inc hl
nvview_prevlineq
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
        call nvview_pseudoprline
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
;out: bc=max line size before eof, z=(bc==0)
        push af
        push hl
        ex de,hl
        ld hl,(filesize)
        ld c,a
        ld a,(filesizeHSW)
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
        ret

nvview_prline_nextline
        push af
        push hl
        call nvview_prline
        pop hl
        pop af
nvview_nextline
;if eof, returns eof addr
;ahl=addr
;line < 16K
;out: ahl, CY=error
        call iswrapon ;CY=on
        jp c,nvview_pseudoprline
        call getmaxlinesize ;bc=max line size before eof, z=(bc==0)
         scf
        ret z
        push af
        push hl
        call ahl_to_pgaddr
;bc=number of chars to go != 0
nvview_nextline0
        ld a,(hl)
        inc hl
        dec bc
        cp 0x0d
        jr z,nvview_nextline_cr
        cp 0x0a
        jr z,nvview_nextline_cr;lf
        ld a,b
        or c
        jr nz,nvview_nextline0
nvview_nextlineq
        ex de,hl ;new addr (bits 13..0), bit 14 = overflow
        pop hl ;old addr
        pop af
pgaddr_to_ahl
;de = new addr (bits 13..0), bit 14 = overflow
;ahl = old addr
        bit 6,d
        ld bc,0x4000
        jr z,$+4
        add hl,bc
        adc a,c;0
        ld c,a
        ld l,e
        ld a,d
        xor h
        and 0x3f
        xor h
        ld h,a ;bits 13..0 copied
        ld a,c ;ahl = new addr
        ret ;nc
nvview_nextline_cr
        ld a,b
        or c
        jr z,nvview_nextlineq
        ld a,(hl)
        cp 0x0a
        jr nz,nvview_nextline_lf
        inc hl
nvview_nextline_lf
        jr nvview_nextlineq
        
nvview_prline
;ahl=addr
;check for last line (vs. file size)
;if filesize-addr < 80, then b=filesize-addr, else b=80
        call getmaxlinesize ;bc=max line size before eof, z=(bc==0)
        jr z,nvview_prlinespc_all;ret z
        call ahl_to_pgaddr
;hl=#8000+0..#3fff
;bc=max line size before eof != 0
nvview_prline_shift=$+1
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
        ld a,NVVIEW_WID
        jr c,nvview_prlinespc
        jr z,nvview_prlinespc

        push hl
        ld hl,NVVIEW_WID
        call minhl_bc_tobc
        ld b,c
        pop hl
;b=number of chars to print != 0
        ld de,prlinebuf
        ld c,NVVIEW_WID
nvview_prline0
        ld a,(hl)
        inc hl
        cp 0x0d
        jr z,nvview_prline_cr
        cp 0x0a
        jr z,nvview_prline_cr;lf
        ;push bc
        push hl
        ld h,twinto866/256
        ld l,a
nvview_prline_recodepatch=$
        nop ;/ld a,(hl)
        ld (de),a ;PRCHAR_
        inc de
        pop hl
        ;pop bc
        dec c
        djnz nvview_prline0
        ;call print_prlinebuf
        ;jr nz,nvview_prline_lf
        ;ret
nvview_prline_cr
        call print_prlinebuf
;nvview_prline_lf
;допечатать пробелы до конца строки
        jr nvview_prlinespc
nvview_prlinespc_all
        ld c,NVVIEW_WID
nvview_prlinespc
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
;c=NVVIEW_WID-число символов
        ld de,prlinebuf
        ld a,NVVIEW_WID
        sub c
        ld l,a
        ld h,0
        call sendchars
        pop hl
        pop bc
        pop af
        ret

prlinebuf
        ds NVVIEW_WID

nvview_pseudoprline
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
        ld hl,NVVIEW_WID
        call minhl_bc_tobc
        ld b,c
        pop hl
;b=number of chars to print != 0
        ld c,NVVIEW_WID
nvview_pseudoprline0
        ld a,(hl)
        inc hl
        cp 0x0d
        jr z,nvview_pseudoprline_cr
        cp 0x0a
        jr z,nvview_pseudoprline_lf
        dec c
        djnz nvview_pseudoprline0
         ld a,(hl)
         inc hl
         cp 0x0d
         jr z,nvview_pseudoprline_crok
         cp 0x0a
         jr z,nvview_pseudoprline_lf
         dec hl
        jp nvview_nextlineq
nvview_pseudoprline_cr
        dec b
        jp z,nvview_nextlineq
nvview_pseudoprline_crok
        ld a,(hl)
        cp 0x0a
        jr nz,nvview_pseudoprline_lf
        inc hl
nvview_pseudoprline_lf
        jp nvview_nextlineq
        
istherecr_or_lf
;hl=addr
;de=length to search
;out: z=found, hl=at match or after area
        ld a,d
        or e
        jr z,istherecr_or_lf_fail
         push hl
        ld a,0x0d
        call istherecrlfgo
        jr z,popafZret;ret z
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
        
popafZret
        pop af
        cp a ;Z
        ret
        
;nvview_closefcb
;        ld de,fcb
;        OS_FCLOSE
;        ret

iswrapon
;CY = on
wrapflag=$
        scf;or a ;/scf
        ret

reservepage
;new page, set page in textpages, npages++, set page in #c000
;nz=error
        OS_NEWPAGE
        or a
        ret nz
npages=$+1
        ld hl,textpages
        ld (hl),e
        inc l
        ld (npages),hl
        ld a,e
        SETPG32KHIGH
        xor a
        ret ;z

unreservepages
unreservepages0
        call unreservepage
        jr z,unreservepages0
        ret
        
unreservepage
;del page, npages--
;nz=error
        ld hl,(npages)
        ld a,l
        or a
        jr z,unreservepage_fail
        dec l
        ld (npages),hl
        ld e,(hl)
        OS_DELPAGE
        xor a
        ret ;z
unreservepage_fail
        xor a
        dec a
        ret ;nz
        
ahl_to_pgaddr
;keeps bc,de
;counts physical hl
        rl h
        rla
        rl h
        rla
        srl h
        scf
        rr h
        push bc
        call setpg32k
        pop bc
        ret

setpg32k
;a=page number in table (0..)
        push hl
        ld l,a
        ld h,textpages/256
        ld a,(hl)
        SETPG32KLOW
        inc l
        ld a,(hl)
        SETPG32KHIGH
        pop hl
        ret

filesize
        dw 0
filesizeHSW
        dw 0

nlines
        dw 0
