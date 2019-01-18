        bit 0,c ;x
        jr nz,setpixel_r
setpixel_l
        xor (hl)
        and %01000111
        xor (hl)
        ld (hl),a
        push bc
        call setpgs_scr
        pop bc
        ret
setpixel_r
        xor (hl)
        and %10111000
        xor (hl)
        ld (hl),a
        push bc
        call setpgs_scr
        pop bc
        ret

setpixel
        call setpixel_fast
        push bc
        call setpgs_scr
        pop bc
        ret
        
        ld hl,editpal_colory*40 + editpal_colorx8
        ld c,editpal_colorhgt
drawpalcolor0
        if 1==0
        exx
curV=$+1
        ld l,16 ;l=iv=0..32
        ld a,(curS)
        ld h,a ;h=is=#e0+0..31
        ld h,(hl) ;h=is=#c0+0..31 (уже пересчитано для заданного iv)
        ld b,l ;b=iv=0..32
        ld a,(curH)
        calcHSVtoRGB_1
        exx
        ld a,c
        exx ;a=y
        and 3
        add a,a
        add a,tabclippal/256
        ld h,a ;d=tabclippal/256 + (y&3)*2
        calcHSVtoRGB_2
        exx
        endif
        
        ld a,%11000000
        
        dup editpal_colorwid8-1
        ld (hl),a
        inc hl
        edup
        ld (hl),a
        set 5,h
        dup editpal_colorwid8-1
        ld (hl),a
        dec hl
        edup
        ld (hl),a
        set 6,h
        ;ex af,af'
        dup editpal_colorwid8-1
        ld (hl),a
        inc hl
        edup
        ld (hl),a
        res 5,h
        dup editpal_colorwid8-1
        ld (hl),a
        dec hl
        edup
        ld (hl),a
        ld de,40-#4000
        add hl,de
        
        dec c
        jr nz,drawpalcolor0
        ret

        
        ld l,a
        ld h,tcountpixels/256 ;считает число пикселей в позициях %00..R..R
        ld a,(hl)
        add a,e
        ld e,a
        srl l
        ld a,(hl)
        add a,d
        ld d,a
        srl l
        ld a,(hl)
        add a,b
        ld b,a
        ex af,af'
        ld l,a
        ld a,(hl)
        add a,e
        ld e,a
        srl l
        ld a,(hl)
        add a,d
        ld d,a
        srl l
        ld a,(hl)
        add a,b
        ld b,a

        
drawpal_countpixels
;d'=r, e'=g
;b'=b
;a'a=два цвета = %00bgrbgr
        exx
        call drawpal_countpixels_pp
        call drawpal_countpixels_pp
        ex af,af'
        call drawpal_countpixels_pp
        call drawpal_countpixels_pp
        exx
        ret
drawpal_countpixels_pp        
        rra
        jr nc,$+3
        inc d ;r
        rra
        jr nc,$+3
        inc e ;g
        rra
        ret nc ;jr nc,$+3
        inc b ;b
        ret
        
        if 1==0
calcRGBtopal
;d=r, e=g, b=b = 0..15
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
;high B, high b, low B, low b
        rr e ;g low
        rla
        rr d ;r low
        rla
        rr b ;b low
        rla
        rr e ;G low
        rla
        rla
        rla
        rr d ;R low
        rla
        rr b ;B low
        rla
        ld l,a
        rr e ;g high
        rla
        rr d ;r high
        rla
        rr b ;b high
        rla
        rr e ;G high
        rla
        rla
        rla
        rr d ;R high
        rla
        rr b ;B high
        rla
        ld h,a
;hl=color (DDp palette)
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
        ret
        endif
        
        ;ld b,a
        ;ld hl,400
        ;djnz $+5
        ;ld hl,25
        ;djnz $+5
        ;ld hl,50
        ;djnz $+5
        ;ld hl,100
        ;djnz $+5
        ;ld hl,200
        ;call prnum3

        
readsecIDE	
        ld a,#40
	ld c,hdddatlo
readsecIDE0
	in e,(C)
	inc c
	in d,(C)
	dec c
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	in e,(C)
	inc c
	in d,(C)
	dec c
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	in e,(C)
	inc c
	in d,(C)
	dec c
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	in e,(C)
	inc c
	in d,(C)
	dec c
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	dec a
	jr nz,readsecIDE0
	ret

        push hl
	ld (writesecIDESP),sp
	ld sp,hl
	ld a,#40
	ld hl,#1011
writesecIDE0
        pop de
	ld c,l
	out (C),d
	ld c,h
	out (C),e
	pop de
	ld c,l
	out (C),d
	ld c,h
	out (C),e
	pop de
	ld c,l
	out (C),d
	ld c,h
	out (C),e
	pop de
	ld c,l
	out (C),d
	ld c,h
	out (C),e
	dec a
	jr nz,writesecIDE0
writesecIDESP=$+1
	ld sp,0
	pop hl

        if 1==0
        ld bc,2 ;x
        ld de,2 ;y
        ld ix,32 ;ix=x2
        ld hl,20 ;hl=y2
        ld a,6 ;color
        call prlinebitmap
        call setpgs_scr
        
        ld bc,2 ;x
        ld de,2 ;y
        ld ix,20 ;ix=x2
        ld hl,32 ;hl=y2
        ld a,3 ;color
        call prlinebitmap
        call setpgs_scr
        
        ld bc,40 ;x
        ld de,2 ;y
        ld ix,4 ;ix=x2
        ld hl,32 ;hl=y2
        ld a,4 ;color
        call prlinebitmap
        call setpgs_scr
       
        ld bc,40 ;x
        ld de,2 ;y
        ld ix,4 ;ix=x2
        ld hl,10 ;hl=y2
        ld a,5 ;color
        call prlinebitmap
        call setpgs_scr
       
        ld bc,40 ;x
        ld de,5 ;y
        ld ix,4 ;ix=x2
        ld hl,5 ;hl=y2
        ld a,7 ;color
        call prlinebitmap
        call setpgs_scr
       
        ld bc,30 ;x
        ld de,5 ;y
        ld ix,30 ;ix=x2
        ld hl,50 ;hl=y2
        ld a,2 ;color
        call prlinebitmap
        call setpgs_scr
        endif
        
;только короткие линии
prlinebitmap
;bc=x
;de=y ;TODO рисовать без учёта этого пикселя (но 1 пиксель рисовать всегда)
;ix=x2
;hl=y2
;a=color1
;a'=color2
        ld (setpixel_color),a
        ex af,af'
        ld (setpixel_color2),a
        or a
        sbc hl,de
        add hl,de
        jr nc,prlinebitmap_noswap
        ex de,hl ;y <-> y2
        ld a,lx
        ld lx,c
        ld c,a
        ld a,hx
        ld hx,b
        ld b,a ;x <-> x2
prlinebitmap_noswap
        ld a,l
        sub e
        ld hx,a ;dy >= 0
        ld a,lx
        sub c
        ld l,#03 ;inc bc
        jp p,prlinebitmap_nodec
        neg
        ld l,#0b ;dec bc
prlinebitmap_nodec
        ld lx,a ;dx >= 0
;bc=x
;de=y
;lx=dx
;hx=dy
        cp hx ;dy
        jr c,prverlinebitmap
        ;ld a,lx ;a=dx
        ;or a
        ;ret z ;len=0
        ld hy,a ;counter=dx
        inc hy ;рисуем, включая последний пиксель
        rra ;a div 2        
        neg
        ld ly,a ;mym=256-(dx div 2)        
        ld a,l
        ld (prlinebitmapincx),a
prhorlinebitmap0
;prlinebitmapcolor=$+1
        ;ld a,5
        call setpixel_fast
prlinebitmapincx=$
        inc bc ;x+1        
        ld a,ly
        add a,hx ;mym+dy
        jr nc,prhorlinebitmap1
        inc de ;y+1
        sub lx ;mym+dx
prhorlinebitmap1
        ld ly,a ;mym 
        dec hy
        jp nz,prhorlinebitmap0
        ret ;jp setpgs_scr
prverlinebitmap       
        ld a,hx ;dy
        ;or a
        ;ret z ;len=0
        ld hy,a ;counter=dy
        inc hy ;рисуем, включая последний пиксель
        srl a ;dy div 2
        neg ;256-(dy div 2)
        ld ly,a ;xm:=256-(dy div 2)        
        ld a,l
        ld (prlinebitmapincx2),a
prverlinebitmap0
;prlinebitmapcolor2=$+1
        ;ld a,5
        call setpixel_fast
        inc de ;y+1
        ld a,ly
        add a,lx ;xm+dx
        jr nc,prverlinebitmap1
prlinebitmapincx2=$
        inc bc ;x+1
        sub hx ;xm-dy
prverlinebitmap1
        ld ly,a ;xm
        dec hy
        jp nz,prverlinebitmap0
        ret ;jp setpgs_scr


        if 1==0
IMER
	ld (imstack),sp
        ex (sp),hl
        ld (imjp),hl
	ld sp,IMSTACK
	push af
	push bc
	push de
	push hl
        exx
        push bc
        push de
        push hl
	push ix
	ex af,af'
	push af
	push iy
        call KEYSCAN
        ;ld a,(curpg_low)
        ;push af
	;ld a,#83 ;48 basic switchable to DOS
	;call setpg_low
        ;LD A,%10101000 ;320x200 mode
	;ld bc,#ff77 ;shadow ports off
	;out (c),a
        ld bc,#fbdf ;x
        in a,(c)
        ld l,a
        ld b,#ff ;y
        in a,(c)
        ld h,a
        ld (imer_mousecoords),hl
        ld bc,#fadf ;buttons
        in a,(c)
	ld (imer_buttons),a
        ;LD A,%10101000 ;320x200 mode
        ;CALL OUTSHADON
        ;pop af
        ;call setpg_low
muzcall=$+1
	call reter;pt3player.PLAY
        
	pop iy
	pop af
	ex af,af'
	pop ix
        pop hl
        pop de
        pop bc
        exx
	pop hl
	pop de
	pop bc
	pop af
imstack=$+1
	ld sp,0
        pop hl
	ei
imjp=$+1
	jp 0
        endif
        
;curpg32klow
;        db #7f-0
;curpg32khigh
;        db #7f-0
;curpg16k
;        db #7f-0

        if 1==0
setpg_low
        ;ld (curpg32klow),a
        LD BC,#3ff7 ;page for #0000..#3fff
        OUT (C),A
        ret
        endif

;setpgROM
;        ld a,#83 ;48 basic switchable to DOS
;        jp setpg_low

setpg32k
        ld (curpg32klow),a
        ;LD BC,#3ff7 ;page for #0000..#3fff
        LD BC,#bff7 ;page for #8000..#bfff
        OUT (C),A
        dec a
setpg32khigh
        ld (curpg32khigh),a
        ;LD BC,#7ff7 ;page for #4000..#7fff
        LD BC,#fff7 ;page for #c000..#ffff
        OUT (C),A
        ret
        
setpg32klow
        ld (curpg32klow),a
        ;LD BC,#3ff7 ;page for #0000..#3fff
        LD BC,#bff7 ;page for #8000..#bfff
        OUT (C),A
        ret
setpg16k
        ld (curpg16k),a
        ;LD BC,#fff7 ;page for #c000..#ffff
        LD BC,#7ff7 ;page for #4000..#7fff
        OUT (C),A
        ret

        ld a,b ;b = 0..15
        ld bc,#ffff ;DDp palette
        rra
        jr nc,$+4
        res 5,c ;b low
        rra
        jr nc,$+4
        res 0,c ;B low
        rra
        jr nc,$+4
        res 5,b ;b
        rra
        jr nc,$+4
        res 0,b ;B
        
        ld a,d ;r = 0..15
        rra
        jr nc,$+4
        res 6,c ;r low
        rra
        jr nc,$+4
        res 1,c ;R low
        rra
        jr nc,$+4
        res 6,b ;r
        rra
        jr nc,$+4
        res 1,b ;R
        
        ld a,e ;g = 0..15
        rra
        jr nc,$+4
        res 7,c ;g low
        rra
        jr nc,$+4
        res 4,c ;G low
        rra
        jr nc,$+4
        res 7,b ;g
        rra
        jr nc,$+4
        res 4,b ;G
        
        if 1==0
filemenu_waitnokey0
        halt
        xor a
        in a,(#fe)
        cpl
        and #1f
        jr nz,filemenu_waitnokey0 ;ждём отпускания кнопок
        endif


        if 1==0
        sub 24
        jr z,readbmp_fixwid24 ;a=0
        cp 8-24
        ld a,8-1 ;для 4bit
        jr nz,$+4
        ld a,4-1 ;для 8bit
        dec l
        jr nz,$+4
        ld a,32-1 ;для 1bit
readbmp_fixwid24
        ld hl,(curbitmapwid_edit)
        dec hl
        or l
        ld l,a
        inc hl ;округлили до 4 вверх для 8bit, до 8 вверх для 4bit, до 32 вверх для 1bit, а у 24bit своё округление в цикле
        ld (curbitmapwid_view),hl ;TODO fix: в ACDSee нет выравнивающих байтов в конце последней строки, так что получается чтение ненужных байтов после файла!!!
        endif

;200%
        ld b,lx
_=$
        exx
        ld l,(iy)
        ld a,(hl)
        ld (de),a
        set 5,d
        ld l,(iy+4) ;!=#ff
        ldi
        res 5,d
        exx
        add iy,de ;4
        djnz _
;120t/

;200%
        ld b,lx
_=$
        pop de
        ld l,e
        ld a,(hl)
        ld (bc),a
        set 5,b
        ld l,e
        ld a,(hl)
        ld (bc),a
        res 5,b
        inc bc
        dec hx
        jp nz,_
;86t/

        ;ld (callbdos_sp),sp
        ;ld sp,BDOSSTACK ;до этого момента прерывание может запороть любое место памяти (user sp >=#3b00)

        ld hl,0
        add hl,sp
        ld iy,(appaddr)
        ld (iy+app.callbdos_sp),l
        ld (iy+app.callbdos_sp+1),h
        ld bc,app.bdosstack+bdosstack_sz
        add iy,bc
        ld sp,iy ;до этого момента прерывание может запороть любое место памяти (user sp >=#3b00)

        ld hl,0
        add hl,sp
        ex de,hl
        ld hl,(appaddr)
        ld bc,app.callbdos_sp
        add hl,bc
        ld (hl),e
        inc hl
        ld (hl),d
        ld bc,app.bdosstack+bdosstack_sz-(app.callbdos_sp+1)
        add hl,bc
        ld sp,hl ;до этого момента прерывание может запороть любое место памяти (user sp >=#3b00)
;выгоднее на 1 байт и 3 такта, чем через iy, но iy нужен
        
        ...
        
        ld iy,(appaddr)
        push hl
        ld l,(iy+app.callbdos_sp)
        ld h,(iy+app.callbdos_sp+1)
        ex (sp),hl
        pop iy
        ld sp,iy
        
        exx
        ;ld iy,(appaddr)
        ld l,(iy+app.callbdos_sp)
        ld h,(iy+app.callbdos_sp+1)
        ld sp,hl
        exx



        dw BDOS_setdta
	jp z,BDOS_fopen
	jp z,BDOS_fread
	jp z,BDOS_fclose
	jp z,BDOS_fdel
	jp z,BDOS_fcreate
	jp z,BDOS_fwrite
        jp z,BDOS_fsearchfirst
        jp z,BDOS_fsearchnext
        jp z,BDOS_remount
        jp z,BDOS_parse_filename
        jp z,BDOS_chdir
        jp z,BDOS_getpath
        jp z,BDOS_getkeymatrix
        jp z,BDOS_gettimer
        jp z,BDOS_yield
        jp z,BDOS_runapp
        jp z,BDOS_newapp
        jp z,BDOS_prattr
        jp z,BDOS_cls
        jp z,BDOS_setcolor
        jp z,BDOS_prchar
        jp z,BDOS_setxy
        jp z,BDOS_setgfx
        jp z,BDOS_setpal
        jp z,BDOS_getmainpages
        jp z,BDOS_newpage
        jp z,BDOS_delpage
        jp z,BDOS_setscreen
        jp z,BDOS_getscreenpages
                

BDOS_old
	ld a,c
	cp CMD_SETDTA;0x1a
        jr nz,1f
;SET DISK TRANSFER ADDRESS
BDOS_setdta
	ld (dma_addr),de
	xor a
	ret
1	;cp 0x09
	;jp z,print_string
	cp CMD_FOPEN;0x0f
	jp z,BDOS_fopen
	cp CMD_FREAD;0x14
	jp z,BDOS_fread
	cp CMD_FCLOSE;0x10
	jp z,BDOS_fclose
	;cp 0x20
	;jp z,BDOS_cur_user
	;cp 0x1e
	;jp z,BDOS_set_attr
	cp CMD_FDEL;0x13
	jp z,BDOS_fdel
	cp CMD_FCREATE;0x16
	jp z,BDOS_fcreate
	cp CMD_FWRITE;0x15
	jp z,BDOS_fwrite
        cp CMD_FSEARCHFIRST;0x11
        jp z,BDOS_fsearchfirst
        cp CMD_FSEARCHNEXT;0x12
        jp z,BDOS_fsearchnext
        cp CMD_REMOUNT
        jp z,BDOS_remount

	cp CMD_PARSEFNAME;0x5c
	jp z,BDOS_parse_filename
        cp CMD_CHDIR
        jp z,BDOS_chdir
        cp CMD_GETPATH
        jp z,BDOS_getpath

        cp CMD_GETKEYMATRIX
        jp z,BDOS_getkeymatrix
        cp CMD_GETTIMER
        jp z,BDOS_gettimer
        cp CMD_YIELD
        jp z,BDOS_yield
        cp CMD_RUNAPP
        jp z,BDOS_runapp
        cp CMD_NEWAPP
        jp z,BDOS_newapp
        cp CMD_PRATTR
        jp z,BDOS_prattr
        cp CMD_CLS
        jp z,BDOS_cls
        cp CMD_SETCOLOR
        jp z,BDOS_setcolor
        cp CMD_PRCHAR
        jp z,BDOS_prchar
        cp CMD_SETXY
        jp z,BDOS_setxy
        cp CMD_SETGFX
        jp z,BDOS_setgfx
        cp CMD_SETPAL
        jp z,BDOS_setpal
        cp CMD_GETMAINPAGES
        jp z,BDOS_getmainpages
        cp CMD_NEWPAGE
        jp z,BDOS_newpage
        cp CMD_DELPAGE
        jp z,BDOS_delpage
        cp CMD_SETSCREEN
        jp z,BDOS_setscreen
        cp CMD_GETSCREENPAGES
        jp z,BDOS_getscreenpages
;never
        jp BDOS_fail

        macro COPYPAGE
;#8000 -> newpage
;out: a=newpage (in #c000)
1
        ld c,CMD_NEWPAGE
        CALLBDOS
        or a
        jr nz,1b
        ld a,e
        SETPG32KHIGH
        ld hl,#8000
        ld de,#c000
        ld bc,#4000
        ldir
        endm
        
;TODO keeppages_withintjp
        
;TODO restorepages_jpintjp (rst0? т.к. вызванная программа не знает, откуда восстанавливать) а откуда ось знает? особенно если было много вложенных вызовов
;надо хранить такие данные в стеке, но стек вызывающей программы не найдёшь, пока её не восстановишь, а стек вызываемой может быть передвинут
        

;0=nokey всегда, 1..26=ext+буквы, остаётся 5 кодов H=1 и 31 код H=0 (а надо разместить 34 команды)

;00 nokey ^@ NUL <--------- cs
;01 ssQ   ^A SOH All (WordLeft в TP) -- home
;02 cs5   ^B STX -- left
;03 csSpc ^C ETX Copy (PgDn в TP) (close app в MS-DOS) -- close app
;04 cs9   ^D EOT (Right в TP и ATM CP/M) -- del
;05 ssE   ^E ENQ (Up в TP) -- end
;06 cs8   ^F ACK Find (WordRight в TP) -- right
;07 cs3?  ^G BEL Replace (Del в TP)
;08 cs0   ^H BS  BS! (BS в MS-DOS) (Up в TPlib) -- bs
;09 csss? ^I HT  Tab! (Tab в MS-DOS) -- tab
;0A cs4?  ^J LF (Enter в ATM CP/M)
;0B ext4? ^K VT (Left в TPlib) -- kill line
;0C ssEnt ^L FF  (FindNext в TP) -- update screen
;0D Enter ^M CR  Enter! (Enter в ATM CP/M и Notepad++) (Right в TPlib) (режим выделения в Win) -- enter
;0E cs7   ^N SO  New -- next
;0F ext2? ^O SI  Open -- flush
;10 cs6   ^P DEL Del (Down в TPlib) -- previous
;11 ext3? ^Q DC1 -- verbatim?
;12 ext6  ^R DC2 (PgUp? в TP) -- search back
;13 ext7  ^S DC3 Save (Left в TP и ATM CP/M) -- search forward
;14 ext8  ^T DC4 (DelWordRight в TP)
;15 cs2?  ^U NAK -- numeric?
;16 ssW   ^V SYN Paste (Ins в TP) -- verbatim? pgup?
;17 ext5? ^W ETB
;18 cs1   ^X CAN Cut (Down в TP) (delete command в ATM CP/M)
;19 ext9  ^Y EM  DelLn
;1A ssI?  ^Z SUB Undo (EOF)
;1B ssSpc ^[ SUB (Esc key, Esc symbol) <---------- extSpc
;1C       ^\ FS
;1D csEnt?^] GS <--------- extEnt
;1E ext1? ^^ RS <--------- ss
;1F ext0? ^_ US
