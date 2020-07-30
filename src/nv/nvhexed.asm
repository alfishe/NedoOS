NVVIEW_HEXEDITOR_XYTOP=0x0000
NVVIEW_HEXEDITOR_HGT=24
NVVIEW_HEXEDITOR_WID=80
NVVIEW_HEXEDITOR_MAXX=15
NVVIEW_HEXEDITOR_PAGESIZE=16*NVVIEW_HEXEDITOR_HGT

_NVVIEW_HEXEDITOR_CURSORCOLOR=0x0700;0x38
_NVVIEW_HEXEDITOR_COLOR=0x0007;7

nvview_hexeditor_redrawloop
        ;YIELDGETKEYLOOP
        call nvview_hexeditor_prpage
nvview_hexeditor_prfile_mainloop
1;prwindow_waitkey_nokey
        call nvhexed_calccursorxy
        ld hl,_NVVIEW_HEXEDITOR_CURSORCOLOR
        ld b,2
        call drawfilecursor_sizeb_colorhl
        call nvhexed_calctextcursorxy
        ld hl,_NVVIEW_HEXEDITOR_CURSORCOLOR
        ld b,1
        call drawfilecursor_sizeb_colorhl
	
        YIELD ;halt ;если сделать просто di:rst #38, то 1.сдвинем таймер и 2.можем потерять кадровое прерывание, а если без ei, то будут глюки
        GETKEY_ ;OS_GETKEYNOLANG
        ld a,c ;keynolang
        push hl
        push bc
        push de
        push af
        call nvhexed_calccursorxy
        ld hl,_NVVIEW_HEXEDITOR_COLOR
        ld b,2
        call drawfilecursor_sizeb_colorhl
        call nvhexed_calctextcursorxy
        ld hl,_NVVIEW_HEXEDITOR_COLOR
        ld b,1
        call drawfilecursor_sizeb_colorhl
	pop af
	pop de
	pop bc
	pop hl
        
        cp NOKEY
        jr nz,nvview_hexeditor_prfileq
        call nvview_hexeditor_panel
        jr 1b;prwindow_waitkey_nokey
nvview_hexeditor_prfileq
        cp key_redraw
        jr z,nvview_hexeditor_redrawloop
        cp key_esc
        ret z
        cp key_tab
        jp z,nvview_hexeditorq
        ld hl,nvview_hexeditor_prfile_mainloop
        push hl
         cp key_up
         jp z,nvview_hexeditor_up
         cp key_down
         jp z,nvview_hexeditor_down
         cp key_pgup
         jp z,nvview_hexeditor_pgup
         cp key_pgdown
         jp z,nvview_hexeditor_pgdown
        ;cp key_home
        ;jp z,nvview_hexeditor_home
        ;cp key_sspgup;ext3
        ;jp z,nvview_hexeditor_home
        ;cp key_end
        ;jp z,nvview_hexeditor_end
        ;cp key_sspgdown;ext4
        ;jp z,nvview_hexeditor_end
        cp key_left
        jp z,nvview_hexeditor_left
        cp key_right
        jp z,nvview_hexeditor_right
         cp key_csenter
         jp z,nvview_hexeditor_save
         cp key_F2
         jp z,nvview_hexeditor_save
        ;cp 'w'
        ;jp z,nvview_wrap
        cp '0'
        ret c
        cp '9'+1
        jp c,nvview_hexeditor_symbol
        cp 'a'
        ret c
        cp 'f'+1
        jp c,nvview_hexeditor_symbol
        ret 

nvview_hexeditor_symbol
        push af
        call nvhex_calccuraddrline ;addr cur line
        ld de,(hexcuraddrxy)
        ld d,0
        add hl,de ;addrcurline + x(e)
        call ahl_to_pgaddr
        pop af
        ;0   a-10
        cp 'a'
        jr nc,nvview_hexeditor_symbol_af
        ld b,-0x30
        jr nvview_hexeditor_symbol_pr
nvview_hexeditor_symbol_af        
        ld b,-0x61+0x0a;0x56
nvview_hexeditor_symbol_pr        
        add a,b
        
nvhexed_half=$
        or a ;/scf
        jr c,nvhexed_symbol_right
        add a,a
        add a,a
        add a,a
        add a,a;a=XXXX0000
        xor (hl)
        and #f0
        xor (hl)
        jr nvhexed_symbol_rightq
nvhexed_symbol_right
        xor (hl)
        and 0x0f
        xor (hl)
nvhexed_symbol_rightq
        ld (hl),a
        ld hl,nvhexed_half
        ld a,(hl)
        xor 0x80
        ld (hl),a
        call nvhex_calccuraddrline ;addr cur line
        ld de,(hexcuraddrxy)
        ld e,0 
        call nv_setxy
        call nvview_hexeditor_prline
        ret
;--------
        ;ld a,(fcb+FCB_FSIZE)
        ;dec a   ;a=????xxxx  l=XXXXzzzz
        ;;xor l   ;a=????xzxz  l=XXXXzzzz
        ;and #0f ;a=0000xzxz  l=XXXXzzzz
        ;;xor l   ;a=XXXXxxxx  l=XXXXzzzz
        ;;ld l,a
        ;ld e,a
        
;--------
        
        
nvview_hexeditor_save
        ;call getfcbundercursor ;->fcb
        ld hl,fcb_filename
        ld de,fcb2_filename
        call copy_to_defcb_filename
	;call setcurpaneldir
        call nv_createfcb2 ;autopush nv_closefcb2
        ret nz ;error
        ld de,(fcb+FCB_FSIZE)
        ld hl,(fcb+FCB_FSIZE+2)
        ld a,0 ;page number
nvview_hexeditor_save0
;a=page number in table (0..)
;hlde=remaining size
        push af
        push de
        push hl
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
        jr z,nvview_hexeditor_save_popq
        pop af
        inc a
        jr nvview_hexeditor_save0
nvview_hexeditor_save_popq
        pop af
        ret
        
nvview_hexeditor_left
        ld de,(hexcuraddrxy)
        ld a,e
        cp 0
        ret z
        dec e
        ld (hexcuraddrxy),de
        ret
        
nvview_hexeditor_right
        ld de,(hexcuraddrxy)
        ld a,e
        cp NVVIEW_HEXEDITOR_MAXX
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
        
nvhexed_calccursorxy
        ld de,(hexcuraddrxy)
        ld a,e
        add a,a
        add a,e
        add a,8
        ld e,a
        ret
        
nvhexed_calctextcursorxy
        ld de,(hexcuraddrxy)
        ld a,e
        add a,57
        ld e,a
        ret
        
nvview_hexeditor_panel
        ret
        
nvview_hexeditor_prpage
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        ld de,NVVIEW_HEXEDITOR_XYTOP
        ld b,NVVIEW_HEXEDITOR_HGT
nvview_hexeditor_prpage0
        push bc
        push de
        push af
        push hl
        SETXY_
        pop hl
        pop af
        call nvview_hexeditor_prline
        pop de
        pop bc
        inc d
        djnz nvview_hexeditor_prpage0
;nvview_hexeditor_setbottom
        ;ld (hexaddrline),hl
        ;ld (hexaddrlineHSB),a
        ret
        

nvview_hexeditor_prline
;ahl =  addr line      
        ;jr $
        push hl
        push af
        
        push hl
        call getmaxlinesize ;bc=max line size before eof, z=(bc==0)
        ld hl,16
        call minhl_bc_tobc ;bc = min(16, max line size before eof) 
        pop hl
                 
        push bc
        call nvview_hexeditor_praddrline
        call ahl_to_pgaddr
        
        push hl
        ld a,':'
        PRCHAR_
        pop hl
        
        pop bc;ld b,0
        
        push hl
nvview_hexeditor1        
        ld a,b
        cp 8
        ld a,' '
        jr nz,nvview_hexeditor0
        ld a,'|'
nvview_hexeditor0
        push hl 
        push bc
        PRCHAR_
        pop bc
        pop hl
        
        ld a,b
        cp c
        jr c,nvview_hexeditor_prhex
        push bc
        ld b,2
        call nvview_prlinespc_b
        pop bc
        jr nvview_hexeditor_notprhex
nvview_hexeditor_prhex        
        ld a,(hl)
        push bc
        call nvview_hexeditor_prNN
        pop bc
nvview_hexeditor_notprhex
        inc hl
        inc b
        ld a,b
        cp 16
        jr nz,nvview_hexeditor1        
        pop hl
        
        ld b,2
        call nvview_prlinespc_b
        
        ld b,0
nvview_hexeditor2      
        ld a,b
        cp c
        ld a,' '
        jr nc,nvview_hexeditor2_sym   
nvview_hexeditor2_prtext        
        ld a,(hl)
        cp 32 
        jr nc,nvview_hexeditor2_sym
        ld a,'.'
nvview_hexeditor2_sym        
        push hl
        push bc
        PRCHAR_
        pop bc
        pop hl
        inc hl
        inc b
        ld a,b
        cp 16
        jr nz,nvview_hexeditor2        
        pop af
        pop hl
        ld b,0
        add hl,bc
        adc a,b

        ld b,7
        call nvview_prlinespc_b
        ret        

nvview_hexeditor_prNN
        push af
        push hl 
        call nvview_prhexbyte
        pop hl
        pop af
        ret
        
nvview_hexeditor_praddrline
;ahl = addr line
        push af
        call nvview_hexeditor_prNN
        ld a,h
        call nvview_hexeditor_prNN      
        ld a,l        
        call nvview_hexeditor_prNN
        pop af
        ret
        
nvview_prhexbyte
;ld a,#30;a=#30 - 0,1,2..9 #41 - A,B,C,D,E,F #61 - a,b,c..
;a=XX 
        ;push hl
        ;push af
        rrca
        rrca
        rrca
        rrca
        call pronehexdigit
        rlca
        rlca
        rlca
        rlca
        ;call pronehexdigit
        ;pop af
        ;pop hl
        ;ret
pronehexdigit
;a=?X
        push bc
        push af
        and #f
        cp 10
        jr c,prcharbit_noletter
        add a,'a'-('0'+10)
prcharbit_noletter
        add a,'0'
        PRCHAR_
        pop af
        pop bc
        ret

nvview_hexeditor_prevline
;ahl =addr line  
;out: ahl =addr line, nc=error      
        call isbof ;cy=0
        ret z
        push bc
        ld bc,#0010
        or a 
        sbc hl,bc
        sbc a,b
        scf
        pop bc
        ret ;c         
        
nvview_hexeditor_nextline
        call iseof
        ret nc
        push bc
        ld bc,#0010
        add hl,bc
        adc a,b
        pop bc
        ret         
                

nvview_hexeditor_up
        call nvhex_calccuraddrline 
        call nvview_hexeditor_prevline
        ret nc
        ld de,(hexcuraddrxy)
        ld a,d
        or a
        jp z,nvview_hexeditor_up_scroll
        dec d
        ld (hexcuraddrxy),de
        ret
nvview_hexeditor_up_scroll        
        ld de,NVVIEW_HEXEDITOR_XYTOP
        ld hl,256*NVVIEW_HEXEDITOR_HGT + NVVIEW_HEXEDITOR_WID
        OS_SCROLLDOWN
        ld de,NVVIEW_HEXEDITOR_XYTOP
        SETXY_
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        call nvview_hexeditor_prevline
        ld (hexaddrline),hl
        ld (hexaddrlineHSB),a
        
        call nvview_hexeditor_prline
        ;call nvview_prline
        ;call deccurline
        ;ld hl,(curbottomtextaddrhex)
        ;ld a,(curbottomtextHSBhex)
        ;call nvview_prevline
        ;jp nvview_hexeditor_setbottom
        ret
        
nvview_hexeditor_pgdown
        call nvhex_calccuraddrline 
        ld de,(hexcuraddrxy)
        ld c,a
        ld a,d
        cp NVVIEW_HEXEDITOR_HGT-1
        ld a,c
        jp z,nvview_hexeditor_pgdown_do
nvview_hexeditor_pgdown0
        ld c,a
        ld a,d
        cp NVVIEW_HEXEDITOR_HGT-1
        ld a,c
        jp z,nvview_hexeditor_pgdownq
        call nvhex_calcnextcorrectxy
        jp c,nvview_hexeditor_pgdown0
nvview_hexeditor_pgdownq
        ld (hexcuraddrxy),de
        ret
nvview_hexeditor_pgdown_do
        ld (hexaddrline),hl
        ld (hexaddrlineHSB),a
        push de
        call nvview_hexeditor_prpage
        pop de
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        ld d,0
nvview_hexeditor_pgdown_do0
        ld c,a
        ld a,d
        cp NVVIEW_HEXEDITOR_HGT-1
        ld a,c
        jp z,nvview_hexeditor_pgdown_doq
        call nvhex_calcnextcorrectxy
        jp c,nvview_hexeditor_pgdown_do0
nvview_hexeditor_pgdown_doq
        ld (hexcuraddrxy),de
        jp clear_keyboardbuffer 

nvview_hexeditor_pgup
        call nvhex_calccuraddrline 
        ld de,(hexcuraddrxy)
        ld c,a
        ld a,d
        or a
        ld a,c
        jp nz,nvview_hexeditor_pgupq
        ld b,NVVIEW_HEXEDITOR_HGT-1
nvview_hexeditor_pgup0
        push bc
        call nvview_hexeditor_prevline
        pop bc
        djnz nvview_hexeditor_pgup0
        ld (hexaddrline),hl
        ld (hexaddrlineHSB),a
        call nvview_hexeditor_prpage
        jp clear_keyboardbuffer 
nvview_hexeditor_pgupq
        ld d,0
        ld (hexcuraddrxy),de
        ret
        
        
        
nvview_hexeditor_down
        call nvhex_calccuraddrline 
        ld de,(hexcuraddrxy)
        call nvhex_calcnextcorrectxy
        ret nc
        ld c,a
        ld a,d
        cp NVVIEW_HEXEDITOR_HGT
        ld a,c
        jr z,nvview_hexeditor_down_scroll
        ld (hexcuraddrxy),de
        ret
nvview_hexeditor_down_scroll
        ;ld hl,(hexaddrline)
        ;ld a,(hexaddrlineHSB)
        ;ld bc,NVVIEW_HEXEDITOR_PAGESIZE
        ;add hl,bc
        ;adc a,0
        push af
        push hl
	ld a,e
        ld (hexcuraddrx),a
        ld de,NVVIEW_HEXEDITOR_XYTOP
        ld hl,256*NVVIEW_HEXEDITOR_HGT + NVVIEW_HEXEDITOR_WID
        OS_SCROLLUP
        ld de,NVVIEW_HEXEDITOR_XYTOP+((NVVIEW_HEXEDITOR_HGT-1)*256)
        SETXY_
        ld hl,(hexaddrline)
        ld a,(hexaddrlineHSB)
        ld bc,16
        add hl,bc
        ld (hexaddrline),hl
        ld (hexaddrlineHSB),a
        pop hl
        pop af
        jp nvview_hexeditor_prline
        
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
        ld a,(fcb+FCB_FSIZE)
        dec a   ;a=????xxxx  l=XXXXzzzz
        ;xor l   ;a=????xzxz  l=XXXXzzzz
        and #0f ;a=0000xzxz  l=XXXXzzzz
        ;xor l   ;a=XXXXxxxx  l=XXXXzzzz
        ;ld l,a
        ld e,a
        pop af 
        scf
        ret ;c
nvhex_calcnextcorrectxy_error
        call nvview_hexeditor_prevline
        or a
        ret ;nc
        
hexcuraddrxy
hexcuraddrx
        db 0
hexcuraddry
        db 0

hexaddrline
        dw 0
hexaddrlineHSB
        db 0
