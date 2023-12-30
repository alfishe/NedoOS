reservepage
;new page, set page in textpages, npages++, set page in #c000
;nz=error
        OS_NEWPAGE
        or a
        ret nz
npages=$+1
        ld hl,tpg
        ld (hl),e
        inc l
        ld (npages),hl
        ld a,e
        SETPGC000
        xor a
        ret ;z

unreservepages
         ;ld a,-1
         ;ld (npages_old),a
unreservepages0
        call unreservepage
        jr z,unreservepages0
	ld hl,0xc000
	ld (freemem_addr),hl
	ld a,-1
	ld (freemem_pg),a
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
        
reserve_mem
;bc=size
;out: a=pg, de=addr of free space
;изначально ни одной страницы не заказано
freemem_addr=$+1
        ld de,0xc000 ;при 0xc000 ещё не заказана страница
	ld h,d
	ld l,e
	dec hl
	bit 6,h
	jr z,reserve_mem_pg ;при 0xc000 ещё не заказана страница
	add hl,bc ;hl=конец блока
	jr nc,reserve_mem_nopg
reserve_mem_pg
	ld hl,freemem_pg
	inc (hl)
	push bc
	call reservepage
	pop bc
	ld de,0xc000
	ld h,d
	ld l,e
	dec hl
	add hl,bc ;hl=конец блока
reserve_mem_nopg
	inc hl ;может быть 0 (ещё не заказана страница)
	set 7,h
	set 6,h ;при 0xc000 ещё не заказана страница
	ld (freemem_addr),hl ;0xc000..0xffff
freemem_pg=$+1
        ld a,-1;ld hl,tpg+0xff ;L=условный номер страницы в таблице ;изначально ни одной страницы не заказано
	;ld a,(hl)
;out: a=pg, de=addr of free space
	ret
