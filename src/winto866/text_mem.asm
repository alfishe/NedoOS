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
        SETPGC000
        xor a
        ret ;z

       if 0
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


getbyte
        push af
        push hl
        call ahl_to_pgaddr
        ld c,(hl)
        pop hl
        pop af
        ret

putbyte
        push af
        push hl
        call ahl_to_pgaddr
        ld (hl),c
        pop hl
        pop af
        ret

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
        SETPG8000
        inc l
        ld a,(hl)
        SETPGC000
        pop hl
        ret
       endif
