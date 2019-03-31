loadchr
;dehl=size
;TODO streaming & reserve mem
        
loadchr_pages0
;dehl=size
        push de
        push hl
        call setpgs_scr2
        call cleanafter8000
        pop hl
        pop de

;dehl=remaining size
        ld a,h
        or l
        or d
        or e
        jr z,loadchr_pagesq
        push de
        push hl
        call reservepage

        ld de,0xc000
        ld hl,0x4000
         push hl
        call readstream_file
        ld b,h
        ld c,l
;bc = Number of bytes actually read
         pop hl
        or a
        sbc hl,bc ;NZ = bytes to read != bytes actually read
        
        pop hl
        pop de
;dehl=remaining size
        push af
        or a
        sbc hl,bc
        jr nc,$+3
        dec de
        
        pop af ;NZ = bytes to read != bytes actually read
        jr z,loadchr_pages0
loadchr_pagesq
        
        
        call closestream_file

        ;jr $
        ld hl,0x0004
        xor a
        
        call readbyte ;c=wid
         ld b,0
         ld (chrswid),bc
        call readbyte ;c=hgt
         ld b,0
         ld (chrshgt),bc
        call readbyte ;c=type
        ld (chrsdataaddr),hl
        ld (chrsdataaddrHSB),a
         ld a,c
         ld (chrstype),a

        ld b,0
        ld de,(chrswid)
        call MULWORD ;out: HLBC=DE*BC
        ld (chrslinesize),bc

        ld hl,(chrswid)
        ld bc,32
        call minhl_bc_tobc
        ld a,c
        ld (drawchrs_scrwid),a

chrscontroldraw0
        call chrsdraw
chrscontrol0
        ld a,(chrstype)
        cp 18
        ld a,1
        jr z,$+3
        xor a
        xor 0
        ld ($-1),a
        ld e,a
        OS_SETSCREEN ;e=screen=0..1
        call yieldgetkeynolang
        jr z,chrscontrol0
        cp csSpace
        ret z
        cp Enter
        ret z
        ld hl,chrscontroldraw0
        push hl
        ld hl,(chrs_xscroll)
        cp cs5
        jr z,chrs_left
        cp cs8
        jr z,chrs_right
        ld hl,(chrs_yscroll)
        cp cs7
        jr z,chrs_up
        cp cs6
        jr z,chrs_down
        ret
        
chrs_left
        ld a,h
        or l
        ret z
        dec hl
        ld (chrs_xscroll),hl
        ret
        
chrs_right
        inc hl
;не двигаем xscroll, если правая граница (=wid-xscroll) получается <32
        ex de,hl
        ld hl,(chrswid)
        or a
        sbc hl,de ;wid-xscroll
        ld bc,32
        or a
        sbc hl,bc
        ex de,hl
        ret c
        ld (chrs_xscroll),hl
        ret
        
chrs_up
        ld a,h
        or l
        ret z
        dec hl
        ld (chrs_yscroll),hl
        ret
        
chrs_down
        inc hl
;не двигаем yscroll, если нижняя граница (=hgt-yscroll) получается <24
        ex de,hl
        ld hl,(chrshgt)
        or a
        sbc hl,de ;hgt-yscroll
        ld bc,24
        or a
        sbc hl,bc
        ex de,hl
        ret c
        ld (chrs_yscroll),hl
        ret
        
chrsdraw
        ld hl,(chrshgt)
        ld bc,24
        call minhl_bc_tobc
        push bc
;count data start shift = (chrslinesize*y) + (type*x)
        ld bc,(chrslinesize)
chrs_yscroll=$+1
        ld de,0
        call MULWORD ;out: HLBC=DE*BC
        ld d,b
        ld e,c
;hlde
chrs_xscroll=$+1
        ld bc,0
        ld a,(chrstype)
        ex de,hl
chrdrawincx0
        add hl,bc
        jr nc,$+3
        inc de
        dec a
        jr nz,chrdrawincx0
        ex de,hl
        ld b,h
;bde=data start shift
chrsdataaddr=$+1
        ld hl,0
chrsdataaddrHSB=$+1
        ld a,0
        add hl,de
        adc a,b
        pop bc
        
        ld de,0x4000
        ld b,c;24 ;TODO
drawchrslines0
        push bc
        
        push af
        push hl

        push de
        
        call ahl_to_pgaddr_setpg32k ;sets hl=0x8000+
        
        ld hx,d
        ld a,d
        rra
        rra
        rra
        and 3
        add a,0x58
        ld hy,a
drawchrs_scrwid=$+2
        ld lx,32 ;TODO
drawchrs0
         ld a,(setpgs_scr_high)
         SETPG16K
        ld d,hx
        dup 7
        ld a,(hl)
        inc hl
        ld (de),a
        inc d
        edup
        ld a,(hl)
        inc hl
        ld (de),a
        ld d,hy
        ld a,(hl)
        inc hl
        ld (de),a
        
chrstype=$+1
        ld a,0
        cp 18
        jr nz,drawchrs_skipscr2
        
         ld a,(setpgs_scr2_high)
         SETPG16K
        ld d,hx
        dup 7
        ld a,(hl)
        inc hl
        ld (de),a
        inc d
        edup
        ld a,(hl)
        inc hl
        ld (de),a
        ld d,hy
        ld a,(hl)
        inc hl
        ld (de),a
drawchrs_skipscr2
        inc e
        dec lx
        jr nz,drawchrs0
        pop de
        ld a,e
        add a,32
        ld e,a
        jr nc,$+6
        ld a,d
        add a,8
        ld d,a
        
        pop hl
        pop af
chrslinesize=$+1
        ld bc,18*32 ;TODO
        add hl,bc
        adc a,0
        
        pop bc
        dec b
        jp nz,drawchrslines0
        ret
        

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

MULWORD
;out: HLBC=DE*BC
        LD HL,0
        LD A,17
MULWOR0 RR B
        RR C
        DEC A
        RET Z
        JR NC,$+3
        ADD HL,DE
        RR H
        RR L
        JR MULWOR0

chrswid
        dw 0
chrshgt
        dw 0
        
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
         ;ld a,-1
         ;ld (npages_old),a
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

        align 256
textpages
        ds 256
