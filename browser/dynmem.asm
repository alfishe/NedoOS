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
        
reserve_bmp_pages
;TODO резервировать блок памяти, а не страницы!
        ld de,(curpichgt)
        ld bc,(curpicwidx3)
        CALL MULWORD
        ld d,b
        ld e,c
        ;hlde=bmp size
        
        if 1==0
        
        push iy
;ищем адрес последнего байта картинки
        ex de,hl
        ld bc,0
        scf
        sbc hl,bc
        ex de,hl
        sbc hl,bc
;ищем номер страницы последнего байта картинки
        ld a,l
        rl d
        rla
        rl d
        rla ;a=lastpg
        inc a ;a=npages
        ld b,a
reserve_bmp_pages0
        push bc
        push hl
reserve_bmp_pages_fail        
        call reservepage
        or a
        jr nz,reserve_bmp_pages_fail ;repeat until success
        pop hl
        pop bc
        djnz reserve_bmp_pages0
        pop iy
        ret
        
        endif
        
reserve_mem
;hlde=size
freemem_hl=$+1
        ld bc,0
freemem_a=$+1
        ld a,0

;freemem может указывать на начало пока не заказанной страницы
;1.если (freememaddr&0x3fff) == 0, то заказать страницу
;2.если остаток страницы >= hlde, то сдвигаем freememaddr и выходим
;3.уменьшить hlde на длину остатка страницы
;4.сдвинуть freememaddr на начало следующей страницы
;5.goto 1
;TODO уметь откатывать заказанные страницы, если не хватает памяти
reserve_mem0
;если (freememaddr&0x3fff) == 0, то заказать страницу:
         ;inc b
         ;djnz reserve_mem_noreservepage
         ;push bc
         ;sla b
         ;sla b
         ;pop bc
         ;jr nz,reserve_mem_noreservepage
        push af
        ld a,b
        and 0x3f
        or c
        jr nz,reserve_mem_noreservepage
        push bc
        push de
        push hl
        push iy
reserve_mem_pages_fail
        call reservepage
        or a
        jr nz,reserve_mem_pages_fail ;repeat until success
        pop iy
        pop hl
        pop de
        pop bc
reserve_mem_noreservepage
        pop af
;если остаток страницы >= hlde (при прибавлении freememaddr+hlde-1 не меняется номер страницы), то сдвигаем freememaddr и выходим:
        inc h
        dec h
        jr nz,reserve_mem_nolast
        inc l
        dec l
        jr nz,reserve_mem_nolast
   ;hldeHSW=0
        push bc
        push hl
   ;bc=freememaddr&0xffff
        res 7,b
        res 6,b
   ;bc=0..0x3fff
        ld hl,0x4000
        or a
        sbc hl,bc ;NC
   ;hl = остаток страницы = 0x4000..1
        ;or a
        sbc hl,de ;остаток страницы-hlde
        pop hl
        pop bc
        jr c,reserve_mem_nolast
 ;сдвигаем freememaddr и выходим:        
        ex de,hl
        add hl,bc
        adc a,0 ;т.к. могли попасть ровно на конец страницы
        ld (freemem_hl),hl
        ld (freemem_a),a
        ret
reserve_mem_nolast
;уменьшить hlde на длину остатка страницы:
        push bc
        push hl
   ;bc=freememaddr&0xffff
        res 7,b
        res 6,b
   ;bc=0..0x3fff
        ld hl,0x4000
        or a
        sbc hl,bc
        ld b,h
        ld c,l
   ;bc = остаток страницы = 0x4000..1
        pop hl
        ex de,hl
        or a
        sbc hl,bc
        ex de,hl
        jr nc,$+3
        dec hl ;hlde = hlde - остаток страницы
        pop bc
;сдвинуть freememaddr на начало следующей страницы:
        sla c
        rl b
        rla
        sla c
        rl b
        rla
        ;dec abc:
        dec c
        jr nz,reserve_mem_nolast_decabcq
        dec b
        djnz reserve_mem_nolast_decabcq
        dec a
reserve_mem_nolast_decabcq
        inc a   ;next pg
        ld bc,0 ;
        srl a
        rr b
        rr c
        srl a
        rr b
        rr c
        jr reserve_mem0
        
writebyte
;c=byte
        push af
        push hl
        call ahl_to_pgaddrc000
        ld (hl),c
        pop hl
        pop af
        jp skipbyte
        
writeword
;bc=word
        push af
        push hl
        call ahl_to_pgaddrc000
        ld (hl),c
        pop hl
        pop af
        call skipbyte
        push af
        push hl
        call ahl_to_pgaddrc000
        ld (hl),b
        pop hl
        pop af
        jp skipbyte
        
readbyte
;out: c
        push af
        push hl
        call ahl_to_pgaddrc000
        ld c,(hl)
        pop hl
        pop af
skipbyte
        inc l
        ret nz
        inc h
        ret nz
        inc a
        ret
        
ahl_to_pgaddrc000
;keeps bc,de
;counts physical hl
        rl h
        rla
        rl h
        rla
        scf
        rr h
        sra h
        push bc
        ld c,a
        ld b,textpages/256
        ld a,(bc)
        SETPG32KHIGH
        pop bc
        ret

ahl_to_pgaddr_setpg32k
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

reservemem_puttomem
;hl=from
;bc=size
;out: ahl=addr
        push hl
        ld hl,(freemem_hl)
        ld a,(freemem_a)
        push af
        push hl
        push bc ;size
        ld d,b
        ld e,c
        ld hl,0
;hlde=size
        call reserve_mem
        pop bc ;size
        pop hl
        pop af
        pop de
;de=from
;ahl=to
;bc=size
        push af
        push hl
        call puttomem
        pop hl
        pop af
        ret
        
puttomem
;de=from
;ahl=to
;bc=size
        ld (putchar_ldir_hl),de
        push bc
        rl h
        rla
        rl h
        rla
        scf
        rr h
        scf
        rr h
;a=page number in table (0..)
        ld c,a
        ld b,textpages/256
        ld a,(bc)
        inc c
         ld (purchar_nextpgtabaddr),bc
        SETPG32KHIGH
        ex de,hl

        pop bc ;сколько байт копируем
        
;если строка не помещается в страничке, то копируем сколько помещается, включаем следующую страницу и копируем остаток
        ld hl,0
        or a
        sbc hl,de ;hl=сколько места осталось в страничке
        or a
        sbc hl,bc ;hl>=0: места хватает
        jr nc,putchar_ldir
;места не хватает -hl байт
         push hl ;-остаток ширины
        add hl,bc ;hl=сколько места осталось в страничке
        ld b,h
        ld c,l
        ld hl,(putchar_ldir_hl) ;локальное начало строки
        ldir
purchar_nextpgtabaddr=$+1
        ld a,(0)
        SETPG32KHIGH
        ld de,0xc000
;hl=остаток строки
         pop bc ;-остаток ширины
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a ;bc=остаток ширины
        ldir
        ret;jr putchar_ldirq
putchar_ldir
putchar_ldir_hl=$+1
        ld hl,0 ;локальное начало строки
        ldir
;putchar_ldirq
        ret
;;;;;;;;;;;;;;;;;;;;;;;

;структура списков:
;+0 3 следующий элемент или -1
;+3 3 предыдущий элемент или -1
;+6 данные
        
getprevelement
;ahl=pointer
        call skipbyte
        call skipbyte
        call skipbyte
getnextelement
;ahl=pointer
        call readbyte ;c
        ld e,c
        call readbyte ;c
        ld d,c
        call readbyte ;c
        ld a,c
        ex de,hl
        ret
        
readword
;ahl=pointer
;out: de=word
        call readbyte ;c
        ld e,c
        call readbyte ;c
        ld d,c
        ret
        
isnull
;ahl=pointer
;out: z=null
        push bc
        ld c,a
        and h
        and l
        inc a
        ld a,c
        pop bc
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STRINGBUFSZ=256

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
stringbuf1
        ds STRINGBUFSZ

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
stringbuf2
        ds STRINGBUFSZ

first2pointer
        dw 0
first2pointerHSB
        db 0

;TODO следить за переполнением STRINGBUFSZ!
printtostringbuf1
curstringbuf1addr=$+1
        ld hl,stringbuf1
        ld (hl),a
        inc hl
        ld (curstringbuf1addr),hl
        ret
        
;TODO следить за переполнением STRINGBUFSZ!
printtostringbuf2
curstringbuf2addr=$+1
        ld hl,stringbuf2
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
        ld c,a
        call writebyte ;c
        jr linklastpointer_lastnullq
linklastpointer_lastnull
        ld (firstpointer),bc
        ex af,af'
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
        call writebyte ;c
        jr linklast2pointer_lastnullq
linklast2pointer_lastnull
        ld (first2pointer),bc
        ex af,af'
        ld (first2pointerHSB),a
linklast2pointer_lastnullq
        pop hl
        pop af
        ld (last2pointer),hl
        ld (last2pointerHSB),a
        ret

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
        ld hl,stringbuf1
        ld (curstringbuf1addr),hl
        call setfontweight
        ret

savestringbuf2
;add terminator
;find size
;form header
;reservemem & put
;if (not isnull(lastpointer)) lastpointer->next=addr else firstpointer=addr
;lastpointer = addr
;initialize stringbuf2
        ld hl,(curstringbuf2addr)
        xor a
        ld (hl),a
        inc hl
        ld de,stringbuf2header
        ;or a
        sbc hl,de ;hl=size
        push hl ;size
        
;form header:
        ld a,(prcharmc_stateful_x)
        ld (stringbuf2header+HREF_ENDX),a
        ld hl,(curprintvirtualy)
        ld (stringbuf2header+HREF_ENDY),hl
         ;jr $
        ld hl,-1
        ld a,-1
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
        ld (stringbuf2header+HREF_VISITED),a
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
