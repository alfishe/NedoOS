	device pentagon1024 ;don't trust this line, it's for ATM2 :)
        include "../_sdk/sys_h.asm"

;text=#4000
COLOR=7

;b=R/G/Bmin
;hl на начале буфера R/G/B
;d=maxdistdiv
;в диферинге ходим только по одной составл€ющей, остальные не читаем:
        macro DITHERMC1B ch0,ch1,ch2,ch3
        ld a,(hl) ;R(pixel)
        inc l
        sub b ;Rmin
         rra ;maybe<0
        ld e,a ;d=maxdistdiv
        ld a,(de) ;inklevel
        cp ch0 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(hl) ;R(pixel)
        inc l
        sub b ;Rmin
         rra ;maybe<0
        ld e,a ;d=maxdistdiv
        ld a,(de) ;inklevel
        cp ch1 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(hl) ;R(pixel)
        inc l
        sub b ;Rmin
         rra ;maybe<0
        ld e,a ;d=maxdistdiv
        ld a,(de) ;inklevel
        cp ch2 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(hl) ;R(pixel)
        inc l
        sub b ;Rmin
         rra ;maybe<0
        ld e,a ;d=maxdistdiv
        ld a,(de) ;inklevel
        cp ch3 ;chunklevel[x%4][y%4]
        rl c ;bits

        ld a,(hl) ;R(pixel)
        inc l
        sub b ;Rmin
         rra ;maybe<0
        ld e,a ;d=maxdistdiv
        ld a,(de) ;inklevel
        cp ch0 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(hl) ;R(pixel)
        inc l
        sub b ;Rmin
         rra ;maybe<0
        ld e,a ;d=maxdistdiv
        ld a,(de) ;inklevel
        cp ch1 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(hl) ;R(pixel)
        inc l
        sub b ;Rmin
         rra ;maybe<0
        ld e,a ;d=maxdistdiv
        ld a,(de) ;inklevel
        cp ch2 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(hl) ;R(pixel)
        inc l
        sub b ;Rmin
         rra ;maybe<0
        ld e,a ;d=maxdistdiv
        ld a,(de) ;inklevel
        cp ch3 ;chunklevel[x%4][y%4]
        ld a,c
        rla ;bits
        endm
        
        org PROGSTART
cmd_begin
        ld sp,#4000 ;не должен опускатьс€ ниже #3b00! иначе возможна порча OS
        ld e,2 ;MC hires mode
        OS_SETGFX
        
        ;YIELD ;чтобы cmd мог доделать свои дела на экране

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старша€), hl=страницы 1-го экрана (h=старша€)
        ld a,e
        ld (setpgs_scr_low),a
        ld a,d
        ld (setpgs_scr_high),a
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        ;ld (curpgshapes),a
        ld a,h
        ;ld (curpgpal),a
        ld a,l
        ;ld (curpgtemp),a

        
        ld e,0;COLOR
        OS_CLS

        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr nz,$+5
        ld hl,filename
;command line = "texted <file to load>"
        ;ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        OS_OPENHANDLE
;b=new file handle

        ld hl,0
        ld de,0
nvview_load0
        push bc
        push de
        push hl
        call reservepage
        pop hl
        pop de
        pop bc
        ret nz ;no memory
        ;ld a,#c000/256
        ;call cmd_loadpage

        push bc
        
        push de
        push hl
        ld de,0xc000
        ld hl,0x4000
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        OS_READHANDLE
;HL = Number of bytes actually read, A=error
        ld b,h
        ld c,l
        ld hl,0x4000
        or a
        sbc hl,bc ;NZ = bytes to read != bytes actually read
        pop hl
        pop de

        push af ;NZ = bytes to read != bytes actually read
        ex de,hl
        add hl,bc
        ex de,hl
        jr nc,$+3
        inc hl
        pop af ;NZ = bytes to read != bytes actually read

        pop bc

        ;or a
        jr z,nvview_load0
;hlde=true file size (for TRDOSFS)
        ld (fcb+FCB.FSIZE),de
        ld (fcb+FCB.FSIZE+2),hl
        
        OS_CLOSEHANDLE
        
noautoload

        ld de,zxpal
        ld c,CMD_SETPAL
        CALLBDOS


        ld a,0
        ld hl,54
        exx
        ld hl,0x8000+(40*199)
        ld b,200
fill0
;ahl' = readaddr
;hl = attraddr
        push bc
        push hl
        
        push af
        push hl
        ld a,b
        and 3
        add a,a
        ld l,a
        ld h,0
        ld bc,tdithermcpatch
        add hl,bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        ld (dithermc1b_patch),de
        pop hl
        pop af
        
        ld d,h
        ld e,l
        set 6,d
        ld b,80
fill1
        push bc
        exx
        call readchr
        push af
        push hl
        call setpgs_scr
        call convertchr
        pop hl
        pop af
        exx
        push af
        ld a,h
        xor 0x20
        cp h
        ld h,a
        jr nc,$+3
        inc hl
        ld a,d
        xor 0x20
        cp d
        ld d,a
        jr nc,$+3
        inc de
        pop af
        pop bc
        djnz fill1
        exx
        call skipline
        exx
        pop hl
        ld bc,-40
        add hl,bc
        pop bc
        djnz fill0

        jp $
        
skipline
        ld bc,640*3
        add hl,bc
        ret nc
        inc a
        ret
        
readchr
;b,g,r
        ld de,chrbuf+16
        ld b,8
        ;jr $
readchr0
         push bc
        set 4,e
        call readbyte ;c=b
        ex de,hl
        ld (hl),c
        ex de,hl
        res 4,e
        set 3,e
        call readbyte ;c=g
        ex de,hl
        ld (hl),c
        ex de,hl
        res 3,e
        call readbyte ;c=r
        ex de,hl
        ld (hl),c
        ex de,hl
        inc e
         pop bc
        djnz readchr0
        ret
        
convertchr
chrbufG=64+8
;поиск 2 цветов (запоминаем положени€ рекордных цветов, чтобы потом их прочитать):
        ld hl,chrbuf
_=chrbufG
        ld de,_*257
        ld c,(hl) ;Rmin
        ld b,c ;Rmax
_=_+1
        dup 7
        inc l
        ld a,(hl) ;R(pixel)
        cp c ;Rmin
        jr nc,$+2+1+2
         ld c,a ;Rmin
         ld e,_ ;Rmincolor = положение текущего цвета
        cp b ;Rmax
        jr c,$+2+1+2
         ld b,a ;Rmax
         ld d,_ ;Rmaxcolor = положение текущего цвета
_=_+1
        edup
        push de ;ld (Rminmaxcolor),de
        ld a,b
        sub c
        push af ;Rmax-Rmin

        inc l ;ld hl,chrbuf+8
_=chrbufG
        ld de,_*257
        ld c,(hl) ;Gmin
        ld b,c ;Gmax
_=_+1
        dup 7
        inc l
        ld a,(hl) ;G(pixel)
        cp c ;Gmin
        jr nc,$+2+1+2
         ld c,a ;Gmin
         ld e,_ ;Gmincolor = положение текущего цвета
        cp b ;Gmax
        jr c,$+2+1+2
         ld b,a ;Gmax
         ld d,_ ;Gmaxcolor = положение текущего цвета
_=_+1
        edup
        push de ;ld (Gminmaxcolor),de
        ld a,b
        sub c
        push af ;Gmax-Gmin

        inc l ;ld hl,chrbuf+16
_=chrbufG
        ld de,_*257
        ld c,(hl) ;Bmin
        ld b,c ;Bmax
_=_+1
        dup 7
        inc l
        ld a,(hl) ;B(pixel)
        cp c ;Bmin
        jr nc,$+2+1+2
         ld c,a ;Bmin
         ld e,_ ;Bmincolor = положение текущего цвета
        cp b ;Bmax
        jr c,$+2+1+2
         ld b,a ;Bmax
         ld d,_ ;Bmaxcolor = положение текущего цвета
_=_+1
        edup
        ;ld (Bminmaxcolor),de
        ld a,b
        sub c ;Bmax-Bmin

;выбираем лучшую ось и еЄ minmaxcolor:
        ld c,a ;maxdist
        pop af ;Gmax-Gmin
        pop hl ;Gminmaxcolor
        cp c ;>=maxdist?
        jr c,$+2+1+1
         ld c,a ;maxdist
         ex de,hl
        pop af ;Rmax-Rmin
        pop hl ;Rminmaxcolor
        cp c ;>=maxdist?
        jr c,$+2+1
         ex de,hl

;d=maxcolor
;e=mincolor
;берЄм рекордные цвета (в виде color16):
;чтобы получить color16, надо сначала color64(=BBGGRR), потом по таблице из него
        ld h,chrbuf/256
        ld l,d ;maxcolor
;округл€ть вверх! +32 (найдено подбором)
        ld a,(hl) ;G
ROUNDUP=32
         add a,ROUNDUP
         jr nc,$+3
         sbc a,a
        ld c,a
        res 3,l
        ld a,(hl) ;R
         add a,ROUNDUP
         jr nc,$+3
         sbc a,a
        ld b,a
        set 4,l
        ld a,(hl) ;B
         add a,ROUNDUP
         jr nc,$+3
         sbc a,a
        rlca
        rlca
        rl c
        rla
        rl c ;g
        rla
        rl b
        rla
        rl b ;r
        rla ;BBGGRR
        ;and 0x3f
        or 0xc0
        ld l,a
        ;ld h,t64to16ink/256
        ld d,(hl) ;d=maxcolor16=ink
        ld l,e ;mincolor
        ;ld h,chrbuf/256
;округл€ть вниз! -64 (найдено подбором)
        ld a,(hl) ;G
ROUNDDOWN=64
         sub ROUNDDOWN
         jr nc,$+3
         xor a
        ld c,a
        res 3,l
        ld a,(hl) ;R
         sub ROUNDDOWN
         jr nc,$+3
         xor a
        ld b,a
        set 4,l
        ld a,(hl) ;B
         sub ROUNDDOWN
         jr nc,$+3
         xor a
        rlca
        rlca
        rl c
        rla
        rl c ;g
        rla
        rl b
        rla
        rl b ;r
        rla ;BBGGRR
        ;or 0xc0
        and 0x3f
        ld l,a
        ;ld h,t64to16paper/256
        ld a,(hl) ;a=mincolor16=paper
        or d
;a=attr
        exx
        ld (hl),a ;записать attr
        exx
        
;по реальным атрибутам заново пересчитать maxaxis, min, maxdist! (проверено, что без этого получаетс€ п€тнистость):
        ld l,a
        ld h,tmaxaxis/256
        ld d,(hl) ;maxdistdiv
        inc h
        ld b,(hl) ;min
        inc h
        ld l,(hl) ;maxaxis*3
        ld h,chrbuf/256
        
;ch0=0x1
;ch1=0xd
;ch2=0x3
;ch3=0xf
;b=R/G/Bmin
;hl на начале буфера R/G/B
;d=maxdistdiv
;в диферинге ходим только по одной составл€ющей, остальные не читаем:
dithermc1b_patch=$+1
        call dithermcy0

        exx
         ;cpl
         ;ld a,#aa
        ld (de),a ;записать bits
        ;inc de
        exx
        
        ret


 ;0 бессмысленно (всегда NC), поэтому все значени€ увеличены на 1:
dithermcy0
        DITHERMC1B 0x1, 0xd, 0x3, 0xf
        ;DITHERMC1B 0x0, 0xc, 0x2, 0xe
        ret
dithermcy1
        DITHERMC1B 0x9, 0x5, 0xb, 0x7
        ;DITHERMC1B 0x8, 0x4, 0xa, 0x6
        ret
dithermcy2
        DITHERMC1B 0x4, 0x10, 0x2, 0xe
        ;DITHERMC1B 0x3, 0x0f, 0x1, 0xd
        ret
dithermcy3
        DITHERMC1B 0xc, 0x8, 0xa, 0x6
        ;DITHERMC1B 0xb, 0x7, 0x9, 0x5
        ret

tdithermcpatch
        dw dithermcy0
        dw dithermcy1
        dw dithermcy2
        dw dithermcy3
        
        
skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
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
        
readbyte
;out: c
        push af
        push hl
        call ahl_to_pgaddr
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

setpgs_scr
setpgs_scr_low=$+1
        ld a,0;pgscr0_0 ;scr0_0
        SETPG32KLOW
setpgs_scr_high=$+1
        ld a,0;pgscr0_1 ;scr0_1
        SETPG32KHIGH
        ret

zxpal
        incbin "zxpal"
        
        
        align 256
textpages
        ds 256

oldtimer
        dw 0
        
fcb
        ds FCB_sz
fcb_filename=fcb+FCB.FNAME        ;по умолчанию там длина 0

filename
        db "0:/hippiman.bmp",0

        align 256
t64to16ink
        incbin "t64to16i"
chrbuf
        ds 8 ;R
chrbufG=$&0xff
        ds 8 ;G
        ds 8 ;B
        ds 256-64-24-64
t64to16paper
        incbin "t64to16p"

        align 256
tmaxaxis ;maxdistdiv_fromattr[256], min_fromattr[256], maxaxis_fromattr[256]
        incbin "tmaxaxis"
        
        ds 0x4000-$
        
        incbin "tdiv"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "browser.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
