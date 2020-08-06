        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

_COLOR=0x0007

NVVIEW_XYTOP=0x0000
NVVIEW_HGT=24
NVVIEW_WID=80
;_NVVIEW_PANELCOLOR=0x0700;0x38
NVVIEW_PANELCOLOR=0x38

        org PROGSTART
cmd_begin
        ld sp,0x4000
        ;call initstdio

        ld e,6 ;textmode
        OS_SETGFX

        OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr
        ld a,e
        ld (stdinhandle),a
        ;ld a,d
        ;ld (stdouthandle),a
        
	;call nv_copyscreen0to1
        ;GET_KEY ;съедаем key_redraw
        
        ;ld e,COLOR
        ;OS_CLS
        ;CLS_
        
;        ld de,nvpal
;        OS_SETPAL
        
        ;OS_GETSCREENPAGES
;de=pages of screen 0 (d=higher page), hl=pages of screen 1 (h=higher page)
        ;ld a,e
        ;ld (cmdpgscreen0_0),a

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000(copybuf),8000,c000*(dirbuf)
        push hl
        ld e,h
        OS_DELPAGE
        pop hl
        ld e,l
        OS_DELPAGE
      
        call lister
      
        QUIT

lister
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
        push de
        push hl
        ld de,0xc000
        ld hl,0x4000
        call receivechars
;out: CY=error, de=end addr in buf
        push af
        ld a,d
        sub 0xc0
        ld b,a
        ld c,e
        ;push bc
        ;ld h,b
        ;ld l,c
        ;ld de,0xc000
        ;call sendchars
        ;pop bc
        pop af ;CY=error
        
        pop hl
        pop de
        push af ;CY=error
        ex de,hl
        add hl,bc
        ex de,hl
        jr nc,$+3
        inc hl
        pop af ;CY=error
        jr nc,nvview_load0
;hlde=true file size (for TRDOSFS)
        ld (filesize),de
        ld (filesizeHSW),hl

        xor a
        ld h,a
        ld l,a
        call nvview_settop
        
        ;call nvview_panel        
        ;jr $
        call nvview_calclines
        ld hl,1;0
        ld (nvview_ncurline),hl

nvview_redrawloop
        ;jp nvview_hexeditor

        call nvview_prcurpage
nvview_mainloop
nvview_mainloop0
	YIELD ;halt ;если сделать просто di:rst #38, то 1.сдвинем таймер и 2.можем потерять кадровое прерывание, а если без ei, то будут глюки
        GET_KEY ;GETKEY_ ;OS_GETKEYNOLANG
        ld a,c ;keynolang
        cp NOKEY
        jr nz,nvview_mainloop_keyq
        call nvview_panel
        jr nvview_mainloop0
nvview_mainloop_keyq
        cp key_redraw
        jr z,nvview_redrawloop
        cp key_esc
        ret z
        ;cp key_tab
        ;jp z,nvview_hexeditor
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
        jp nvview_prcurpage
        
nvview_left
        ld a,(nvview_prline_shift)
        sub 8
        ret c
        ld (nvview_prline_shift),a
        jp nvview_prcurpage
        
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
        OS_SCROLLDOWN
        ld de,NVVIEW_XYTOP
        OS_SETXY
        pop hl
        pop af
        call nvview_prline
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
        OS_SCROLLUP
        ld de,NVVIEW_XYTOP+((NVVIEW_HGT-1)*256)
        OS_SETXY
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
        ld b,5
clear_keyboardbuffer0
        push bc
        GET_KEY ;GETKEY_
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
        OS_SETXY
        ld de,NVVIEW_PANELCOLOR;#38
        OS_SETCOLOR
        
        ld a,(nvview_prline_recodepatch)
        or a
        ld de,t866
        jr z,$+5
        ld de,twin
        ld hl,3
        call sendchars
        ; ld c,0
        ;call prtext
        
        ld a,' '
        PRCHAR
nvview_ncurline=$+1
        ld hl,0
        exx 
        ld hl,0
        exx
        call prdword
        ;ix
        ld a,'/'
        PRCHAR
        ld hl,(nlines)
        exx 
        ld hl,0
        exx
        call prdword
        ld a,' '
        PRCHAR
        ld hl,(filesizeHSW)
        exx
        ld hl,(filesize)
        call prdword
        ld b,43
nvview_panel0
        ld a,' '
        push bc
        PRCHAR
        pop bc
        djnz nvview_panel0
        ;ld e,NVVIEW_PANELCOLOR;#38
        ;OS_PRATTR
        ld de,_COLOR;#38
        OS_SETCOLOR
        
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
        ld de,NVVIEW_XYTOP
        ld b,NVVIEW_HGT
nvview_prpage0
        push bc
        push de
        push af
        push hl
        OS_SETXY
        pop hl
        pop af
        call nvview_prline_nextline
        pop de
        pop bc
        inc d
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
        jr z,nvview_nextline_lf
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
        jr nz,$+3
        dec hl ;hl=cr/lf address

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
        ld c,NVVIEW_WID
nvview_prline0
        ld a,(hl)
        inc hl
        cp 0x0d
        jr z,nvview_prline_cr
        cp 0x0a
        jr z,nvview_prline_lf
        push bc
        push hl
        ld h,twinto866/256
        ld l,a
nvview_prline_recodepatch=$
        nop ;/ld a,(hl)
        PRCHAR
        pop hl
        pop bc
        dec c
        djnz nvview_prline0
        jr nz,nvview_prline_lf
        ret
nvview_prlinespc_all
        ld c,NVVIEW_WID
nvview_prline_cr
nvview_prline_lf
;допечатать пробелы до конца строки
        ld a,c
nvview_prlinespc
        ld b,a
nvview_prlinespc_b
        push af
        push hl
nvview_prlinespc0
        push bc
        ld a,' '
        PRCHAR
        pop bc
        djnz nvview_prlinespc0
        pop hl
        pop af
        ret

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
        jp nvview_nextlineq
nvview_pseudoprline_cr
        dec b
        jp z,nvview_nextlineq
        ld a,(hl)
        cp 0x0a
        jr nz,nvview_pseudoprline_lf
        inc hl
nvview_pseudoprline_lf
        jp nvview_nextlineq
        
istherecr_or_lf
;hl=addr
;de=length to search
;out: z=found, hl=after match or after area
        ld a,d
        or e
        jr z,istherecr_or_lf_fail
         push hl
        ld a,0x0d
        call istherecrlfgo
        jr z,popafret;ret z
         pop hl
        ld a,0x0a
istherecrlfgo
        push bc
        ld b,d
        ld c,e
        cpir
        pop bc
        ret ;z=found
istherecr_or_lf_fail
        dec a
        ret ;nz=not found
        
popafret
        pop af
        ret
        
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
;keeps bc
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

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

sendchars
;send chars to stdout (in: de=buf, hl=size, out: A=error)
        ld b,h
        ld c,l
        ex de,hl
sendchars0
        push bc
        push hl
        ld a,(hl)
        PRCHAR
        pop hl
        pop bc
        cpi
        jp pe,sendchars0
        ret

;receivechars - read chars from stdin
receivechars
;de=buf, hl=size
;out: de=end addr in buf (if EOF), CY=error(EOF))
receivechars0
        push de
        push hl
        ;ld a,(stdinhandle)
stdinhandle=$+1
        ld b,0;a
        OS_READHANDLE ;hl=size actually received
        ld b,h
        ld c,l
        pop hl
        pop de
        or a
        scf
        ret nz ;error
        ex de,hl
        add hl,bc ;addr+=readed
        ex de,hl
        or a
        sbc hl,bc ;size-=readed
        jr nz,receivechars0
        ret
        
nlines
        dw 0

filesize
        dw 0
filesizeHSW
        dw 0
        
        align 256
textpages
        ds 256
twinto866
        incbin "../_sdk/codepage/winto866"

        include "prdword.asm"
        ;include "../_sdk/stdio.asm"
        
cmd_end

	display "more size ",/d,cmd_end-cmd_begin," bytes"

	savebin "more.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l"
