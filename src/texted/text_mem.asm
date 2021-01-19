insertbyte
;ahl=insert addr        
;c=symbol
;out: ahl=next addr (kills bc,de)
        push af
        push hl

         push bc ;c=symbol
        push af
        push hl
        call incfilesize ;before! because we can access new page
	 call setchanged
        pop hl
        pop af
         pop de ;e=symbol

insertbyte_pg0
;ahl=addr
;e=symbol
          push af
          push hl
        call ahl_to_pgaddr_pgsizeafter ;hl=phys addr, bc=block size after hl (may be 0!) (keeps de)
        push bc
        call insertbyte_ldirbc
        pop bc
          pop hl
          pop af
        add hl,bc
        adc a,0
;ahl=addr for next block
;e=symbol for next block (out-of-text for eof)
        call iseof
        jr nz,insertbyte_pg0
        
        pop hl
        pop af ;insert addr
nextbyte
        ld bc,1
        add hl,bc
        adc a,b;0
        ret

deletebyte
;ahl=delete addr (kept) (kills bc,de)
        push af
        push hl

deletebyte_pg0
;ahl=addr        
          push af
          push hl
        call ahl_to_pgaddr_pgsizeafter ;hl=phys addr, bc=block size after hl (may be 0!) (keeps de)
	 call setchanged
;hl=byte addr to delete
;bc=size from hl to end
        push bc
        call deletebyte_ldirbc
        pop bc
          pop hl
          pop af
        add hl,bc
        adc a,0
;ahl=addr for next block
        call iseof
        jr z,deletebyte_pgq
;copy first byte of next block to last byte of this block
        push af
        push hl
        call ahl_to_pgaddr;_pgsizeafter ;hl=phys addr, bc=block size after hl (may be 0!) (keeps de)
        ld e,(hl) ;first byte of next block
        pop hl
        pop af
        push af
        push hl
         dec hl ;last byte of this block
        call ahl_to_pgaddr;_pgsizeafter ;hl=phys addr, bc=block size after hl (may be 0!) (keeps de)
        ld (hl),e
        pop hl
        pop af
        jr deletebyte_pg0
        
deletebyte_pgq
        call decfilesize ;after! because we can access deleted last page
        pop hl
        pop af ;delete addr
        ret

deletebyte_ldirbc
;hl=byte addr to delete
;bc=size from hl to end (may be 0!)
        dec bc ;bc=size from ahl+1 to end
        ld a,b
        or c
        ret z
        ld d,h
        ld e,l
        inc hl
        ld a,b
        or c
        ret z ;jr z,$+4
        ldir
        ret        

;reserves page
incfilesize
        ;ld hl,(fcb+FCB_FSIZE)
        call getsize
        
        push af
        push hl
        ld a,h
        and 0x3f
        or l
        call z,reservepage
        pop hl
        pop af
        
        ld bc,1
        add hl,bc
        adc a,b;0
        ld (filesize),hl
        ld (filesizeHSW),a
        ret

;unreserves page
decfilesize
        ;ld hl,(fcb+FCB_FSIZE)
        call getsize
        or a
        ld bc,1
        sbc hl,bc
        sbc a,b;0
        ld (filesize),hl
        ld (filesizeHSW),a

        ld a,h
        and 0x3f
        or l
        call z,unreservepage
        ret


ahl_to_pgaddr_pgsizeafter
;ahl=addr
;out: hl=phys addr, bc=block size after hl (may be 0!) (keeps de)
        push af
        push hl
        ld l,h
        ld h,a
        add hl,hl
        add hl,hl
        push hl ;h=page number
        call getsize
        ld c,h
        rl c
        rla
        rl c
        rla
        ld c,a ;c=end page number
        pop af ;page number
        cp c
        ld bc,0x4000
        jr nz,ahl_to_pgaddr_pgsize_noend
        ;size=hl&0x3fff
        ;add hl,hl
        ;add hl,hl
        ;srl h
        ;srl h
        ld a,h
        and 0x3f
        ld b,a
        ld c,l
ahl_to_pgaddr_pgsize_noend
;bc=pg size (may be 0!)
        pop hl
        pop af
        call ahl_to_pgaddr ;hl=phys addr (keeps bc)
        push hl
        res 7,h
        ;res 6,h
        ld a,c
        sub l
        ld c,a
        ld a,b
        sbc a,h
        ld b,a ;bc=block size after hl (may be 0!)
        pop hl
        ret
        
insertbyte_ldirbc
;e=byte to insert
;hl=byte addr to insert
;bc=size from hl to end (may be 0!)
;out: e=deleted last byte, [hl=end addr]
        ld a,b
        or c
        ret z
        ld a,e
        add hl,bc ;end addr
        dec hl
        ld e,(hl)
        push de ;d=deleted last byte
        ld d,h
        ld e,l
        inc de
        ;push de ;end addr
        dec hl
        dec de
        push af
        dec bc
        ld a,b
        or c
        jr z,$+4
        lddr
        pop af
        ;pop hl ;end addr
        ld (de),a
        pop de ;e=deleted last byte
        ret
        
prevbyte
        ld bc,1
        or a
        sbc hl,bc
        sbc a,b;0
        ret
        
getbyte
        push af
        push hl
        call ahl_to_pgaddr
        ld c,(hl)
        pop hl
        pop af
        ret
        
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
        
        align 256
textpages
        ds 256
