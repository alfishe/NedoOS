STRINGBUFSZ=MAXLINKSZ ;512;256

;for text
stringbuf1header
TEXT_BASE
TEXT_NEXT=$-TEXT_BASE
        ds 3 ;next
TEXT_PREV=$-TEXT_BASE
        ds 3 ;prev
TEXT_Y=$-TEXT_BASE
        ds 2 ;y
TEXT_X=$-TEXT_BASE
        ds 1 ;x
TEXT_TEXT=$-TEXT_BASE
stringbuf1
        ds STRINGBUFSZ
        db 0 ;на случай длины STRINGBUFSZ

firstpointer
        dw 0
firstpointerHSB
        db 0
        
;for href
stringbuf2header
HREF_BASE
HREF_NEXT=$-HREF_BASE
        ds 3 ;next
HREF_PREV=$-HREF_BASE
        ds 3 ;prev
HREF_Y=$-HREF_BASE
        ds 2 ;y
HREF_X=$-HREF_BASE
        ds 1 ;x
HREF_ENDY=$-HREF_BASE
        ds 2 ;endy (TODO сложную геометрию ссылок разбивать на части с общим полем ссылок, но разными полями геометрии)
HREF_ENDX=$-HREF_BASE
        ds 1 ;endx (TODO сложную геометрию ссылок разбивать на части с общим полем ссылок, но разными полями геометрии)
HREF_VISITED=$-HREF_BASE
        ds 1 ;visited
HREF_TEXT=$-HREF_BASE
stringbuf2
        ds STRINGBUFSZ
        db 0 ;на случай длины STRINGBUFSZ

first2pointer
        dw 0
first2pointerHSB
        db 0

;следить за переполнением STRINGBUFSZ!
printtostringbuf1
curstringbuf1addr=$+1
        ld hl,stringbuf1
	 push de
	 ld de,stringbuf1+STRINGBUFSZ
	 or a
	 sbc hl,de
	 add hl,de
	 pop de
	 ret nc
        ld (hl),a
        inc hl
        ld (curstringbuf1addr),hl
        ret
        
;следить за переполнением STRINGBUFSZ!
printtostringbuf2
curstringbuf2addr=$+1
        ld hl,stringbuf2
	 push de
	 ld de,stringbuf2+STRINGBUFSZ
	 or a
	 sbc hl,de
	 add hl,de
	 pop de
	 ret nc
        ld (hl),a
        inc hl
        ld (curstringbuf2addr),hl
        ret

linklastpointer_next_ahl_setlastpointer
;if (not isnull(lastpointer)) lastpointer->next=addr else firstpointer=addr
;lastpointer = addr
        push af
        push hl
        ex af,af'
        ld b,h
        ld c,l
        ld hl,(lastpointer)
        ld a,(lastpointerHSB)
        call isnull
        jr z,linklastpointer_lastnull
        call writeword ;bc
        ex af,af'
         ;cp 0xff
         ;jr z,$
        ld c,a
        ex af,af'
        call writebyte ;c
        jr linklastpointer_lastnullq
linklastpointer_lastnull
        ex af,af'
        ld (firstpointer),bc
        ld (firstpointerHSB),a
linklastpointer_lastnullq
        pop hl
        pop af
        ld (lastpointer),hl
        ld (lastpointerHSB),a
        ret

linklast2pointer_next_ahl_setlast2pointer
;if (not isnull(last2pointer)) last2pointer->next=addr else first2pointer=addr
;last2pointer = addr
        push af
        push hl
        ex af,af'
        ld b,h
        ld c,l
        ld hl,(last2pointer)
        ld a,(last2pointerHSB)
        call isnull
        jr z,linklast2pointer_lastnull
        call writeword ;bc
        ex af,af'
        ld c,a
        ex af,af'
        call writebyte ;c
        jr linklast2pointer_lastnullq
linklast2pointer_lastnull
        ex af,af'
        ld (first2pointer),bc
        ld (first2pointerHSB),a
linklast2pointer_lastnullq
        pop hl
        pop af
        ld (last2pointer),hl
        ld (last2pointerHSB),a
        ret

        display "savestringbuf1=",$
savestringbuf1
;add terminator
;find size
;form header
;reservemem & put
;if (not isnull(lastpointer)) link lastpointer->next = addr
;lastpointer = addr
;initialize stringbuf1
        ld hl,(curstringbuf1addr)
        xor a
        ld (hl),a
        inc hl
        ld de,stringbuf1header
        ;or a
        sbc hl,de ;hl=size
        ld b,h
        ld c,l
        
;form header:
        ld hl,-1
        ld a,-1
        ld (stringbuf1header+TEXT_NEXT),hl
        ld (stringbuf1header+TEXT_NEXT+2),a
lastpointer=$+1
        ld hl,-1
lastpointerHSB=$+1
        ld a,-1
        ld (stringbuf1header+TEXT_PREV),hl
        ld (stringbuf1header+TEXT_PREV+2),a
laststringy=$+1
        ld hl,0
        ld (stringbuf1header+TEXT_Y),hl
laststringx=$+1
        ld a,0
        ld (stringbuf1header+TEXT_X),a
        
;if iscentered then TEXT_X = (textfieldwidth-textlength)/2
iscentered=$+1
        ld a,0
        or a
        jr z,savestringbuf1_notcentered
        call countlinewidth ;hl
        ld a,80 ;TODO textfieldwidth
        sub l
        rra
        ld (stringbuf1header+TEXT_X),a
savestringbuf1_notcentered
        
        if 1==0
        push bc
        push de
        push hl
        
        ld hl,(stringbuf1header+TEXT_Y)
        ld bc,25
        or a
        sbc hl,bc
        add hl,bc
        jr nc,notest1
        ld a,l
        add a,a
        add a,a
        add a,a
        ld d,a
        ld a,(stringbuf1header+TEXT_X)
        ld e,a
        call setxymc_stateful
        ld hl,stringbuf1
test10
        ld a,(hl)
        or a
        jr z,notest1
        inc hl
        push hl
        ;halt
        call prcharmc_stateful
        pop hl
        jr test10
        
notest1
        pop hl
        pop de
        pop bc
        endif
        
        ex de,hl
;hl=from
;bc=size
;out: ahl=addr
        ;jr $
        call reservemem_puttomem
        call linklastpointer_next_ahl_setlastpointer        
initstringbuf1
        xor a
        ld (iscentered),a
        ;ld (ncharsinline),a
        ld hl,stringbuf1
        ld (curstringbuf1addr),hl
        jp setfontweight

        display "savestringbuf2=",$
savestringbuf2
;add terminator
;find size
;form header
;reservemem & put
;if (not isnull(lastpointer)) lastpointer->next=addr else firstpointer=addr
;lastpointer = addr
;initialize stringbuf2
        ld hl,(curstringbuf2addr)
         ld de,stringbuf2
         or a
         sbc hl,de
         add hl,de
         ret z ;пустую не сохраняем, иначе глюк с первой ссылкой после div???
        xor a
        ld (hl),a
        inc hl
        ld de,stringbuf2header
        ;or a
        sbc hl,de ;hl=size
        push hl ;size
        
;form header:
        ld a,(prcharvirtual_stateful_x)
        ld (stringbuf2header+HREF_ENDX),a
        ld hl,(curprintvirtualy)
        ld (stringbuf2header+HREF_ENDY),hl
        ld a,-1
        ld h,a
        ld l,a
        ld (stringbuf2header+HREF_NEXT),hl
        ld (stringbuf2header+HREF_NEXT+2),a
last2pointer=$+1
        ld hl,-1
last2pointerHSB=$+1
        ld a,-1
        ld (stringbuf2header+HREF_PREV),hl
        ld (stringbuf2header+HREF_PREV+2),a
hrefyposition=$+1
        ld hl,0
        ld (stringbuf2header+HREF_Y),hl
hrefxposition=$+1
        ld a,0
        ld (stringbuf2header+HREF_X),a
        xor a
        ld (stringbuf2header+HREF_VISITED),a ;TODO check history
        ;jr $
        
        if 1==0
        push de
        push hl
        
        ld hl,(stringbuf2header+HREF_Y)
        ld bc,25
        or a
        sbc hl,bc
        add hl,bc
        jr nc,notest
        ld a,l
        add a,a
        add a,a
        add a,a
        ld d,a
        ld a,(stringbuf2header+HREF_X)
        ld e,a
        call setxymc_stateful
        ld a,'@'
        call prcharmc_stateful        
        
notest
        pop hl
        pop de
        endif
        
        ex de,hl
        pop bc ;size
;hl=from
;bc=size
;out: ahl=addr
        ;jr $
        call reservemem_puttomem
        call linklast2pointer_next_ahl_setlast2pointer
initstringbuf2
        ld hl,stringbuf2
        ld (curstringbuf2addr),hl
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

setdefaultfontweight
        xor a
        ld (curbold),a
        ld (curlink),a
        ld (curlinkimg),a
        ld (curmark),a
        ld (curitalic),a
        ld (curunderline),a
        ld (curstroke),a
        ret

setfontweight
        ld a,(printableflag)
        or a
        ret z
         ld a,1
         call prcharvirtual_stateful
curbold=$+1
        ld a,0
curlink=$+1
        or 0
curlinkimg=$+1
        or 0
curmark=$+1
        or 0
        inc a
        call prcharvirtual_stateful
         ld a,2
         call prcharvirtual_stateful
curitalic=$+1
        ld a,0
        inc a
        call prcharvirtual_stateful
         ld a,3
         call prcharvirtual_stateful
curstroke=$+1
        ld a,0
        inc a
        call prcharvirtual_stateful
         ld a,4
         call prcharvirtual_stateful
curunderline=$+1
        ld a,0
        inc a
        jp prcharvirtual_stateful

prcharvirtual_tab_stateful
        ld a,(prcharvirtual_stateful_x)
        and 7 ;0..7
        cpl ;-1..-8
        add a,9
        ld b,a ;8..1
prcharvirtual_tab_stateful0
        push bc
        ld a,' '
        call prcharvirtual_stateful
        pop bc
        djnz prcharvirtual_tab_stateful0
        ret
        
prcharvirtual_controlcode
        cp 0x09 ;tab
        jr z,prcharvirtual_tab_stateful
        cp 0x0a ;LF
        jr z,prcharvirtual_crlf_stateful
        cp 0x0d ;CR
        ret z
        jr prcharvirtual_stateful_nocontrolcode
        
prcharvirtual_stateful
;a=code
printableflag=$+1
        ld l,0
        dec l
        ret nz
        cp 32
        jr c,prcharvirtual_controlcode
prcharvirtual_stateful_nocontrolcode
        push af
         cp 0x80
         jr c,prcharvirtual_noutf8
utf8flag=$+1
         ld l,0
         dec l
         jr nz,prcharvirtual_noutf8
         sub 0xd0
         jr z,prcharvirtual_utf8_d0
         cp 1
         jr z,prcharvirtual_utf8_d0
         cp 0xe2-0xd0 ;dash = e2 80 94 (но 80 используется в "а" = d1 80)
         jr z,prcharvirtual_utf8_e2
         cp 0xc2-0xd0 ;bullet = c2 b7
         jr z,prcharvirtual_utf8_c2
         ;sub 0x80
prcharvirtual_utf8_add=$+1
        add a,0x00
        ;add a,0x80
         cp 0x01
         jr z,prcharvirtual_utf8_yo
         cp 0x20
         jr nc,prcharvirtual_noutf8
         pop af
         ret
prcharvirtual_utf8_yo
         ld a,0xb8;'ё'
        jr prcharvirtual_noutf8
prcharvirtual_utf8_c2
        ld a,0xb7-0xb7+0xd0
        ld (prcharvirtual_utf8_add),a
        pop af
        ret
prcharvirtual_utf8_e2
        ld a,'-'-0x94+0xd0
        ld (prcharvirtual_utf8_add),a
        pop af
        ret
prcharvirtual_utf8_d0
        add a,a
        add a,a
        add a,a
        add a,a
        add a,a
        add a,a
        ld (prcharvirtual_utf8_add),a
        pop af
        ret
prcharvirtual_noutf8
        ld h,twinto866/256
        ld l,a
        ld a,(hl)
        call printtostringbuf1
        pop af
        cp 32
        ret c
prcharvirtual_stateful_x=$+1
        ld a,0
        inc a
        ld (prcharvirtual_stateful_x),a
        cp 80
        ret c
prcharvirtual_crlf_stateful
        ld a,(printableflag)
        or a
        jr z,prcharvirtual_x0
        call savestringbuf1
curprintvirtualy=$+1
        ld hl,0
        inc hl
        ld (laststringy),hl
        ld (curprintvirtualy),hl
prcharvirtual_x0
        xor a
        ld (prcharvirtual_stateful_x),a
        ld (laststringx),a
        ret

countlinewidth
;out:hl
        ld a,(prcharvirtual_stateful_x)
        ld hl,laststringx
        sub (hl)
        ld l,a ;number of visible chars in line        
        ld h,0
        ret
