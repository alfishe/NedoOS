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
         ld a,-1
         ld (npages_old),a
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
        ld hl,(freemem_hl)
        ld a,(freemem_a)
        ld (putchar_hl),hl
        ld (putchar_a),a

        ld de,(curpichgt_visible)
         ;inc de
         ;srl d
         ;rr e
        ld bc,(curpicwidx3)
        CALL MULWORD
        ld d,b
        ld e,c
        ;hlde=bmp size
        
reserve_mem
;hlde=size
;out: ahl=freemem pointer
;меняет страницу в 0xc000
;ставит pgtemp в 0x8000
;ставит pgcode в 0x4000
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
         push af
         push hl
         call showmem ;ставит pgcode в 0x4000
         call setpgtemp8000
         pop hl
         pop af
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
        jp reserve_mem0
        
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
        ret
putchar_ldir
putchar_ldir_hl=$+1
        ld hl,0 ;локальное начало строки
        ldir
        ret
        
        
getfrommem
;de=to
;ahl=from
;bc=size
        ld (getfrommem_ldir_hl),de
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
         ld (getfrommem_nextpgtabaddr),bc
        SETPG32KHIGH
        ex de,hl
        pop bc ;сколько байт копируем
        
;если строка не помещается в страничке, то копируем сколько помещается, включаем следующую страницу и копируем остаток
        ld hl,0
        or a
        sbc hl,de ;hl=сколько места осталось в страничке
        or a
        sbc hl,bc ;hl>=0: места хватает
        jr nc,getfrommem_ldir
;места не хватает -hl байт
         push hl ;-остаток ширины
        add hl,bc ;hl=сколько места осталось в страничке
        ld b,h
        ld c,l
        ld hl,(getfrommem_ldir_hl) ;локальное начало строки
        ex de,hl
        ldir
        ex de,hl
getfrommem_nextpgtabaddr=$+1
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
        ex de,hl
        ldir
        ex de,hl
        ret
getfrommem_ldir
getfrommem_ldir_hl=$+1
        ld hl,0 ;локальное начало строки
        ex de,hl
        ldir
        ex de,hl
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
