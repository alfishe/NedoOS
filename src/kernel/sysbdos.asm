
;NVOLUMES=8
MAXFILES=16;8
vol_trdos=4 ;'A'..'D'
vol_pipe=25 ;'Z'

TRDOSADD40=0x40
PIPEADD80=0x80

MAXPIPES=8
PIPEBUF_SZ=255
PIPEDESC_SZ=PIPEBUF_SZ+1

;предполагается, что юзер не имеет стек ниже 0x3b00, иначе он затрёт систему

;FCB и имя можно передавать в любой области userspace
;DTA может быть в любой области userspace
fatfs_org=0x4000
;CurrVol=0X4000+26
;CurrDir=CurrVol+1

        MACRO GETVOLUME
        ;ld a,(CurrVol)
        ;ld a,(iy+app.dir+DIR.ID)
         ld a,(iy+app.vol)
        ENDM
        MACRO SETVOLUME
        ;ld a,(CurrVol)
        ;ld a,(iy+app.dir+DIR.ID)
         ld (iy+app.vol),a
        ENDM

        MACRO CHECKVOLUMETRDOS
        GETVOLUME
        cp vol_trdos
        ENDM

BDOS_setpgtrdosfs
        ld a,pgtrdosfs
	jr sys_setpg4000
        ;ld bc,memport4000
        ;ld (sys_curpg4000),a
        ;out (c),a
        ;ret

BDOS_setpgfatfs
        ld a,pgfatfs
sys_setpg4000
        ld bc,memport4000
        ld (sys_curpg4000),a ;для sys_sysint
        out (c),a
        ret

blocksize=128 ;сколько байтов читать в CP/M операциях

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BDOS_wiznetopen
        BDOSSETPGW5300 ;портит bc
        jp wiznet_open

BDOS_wiznetclose
        BDOSSETPGW5300 ;портит bc
        jp wiznet_close

BDOS_wiznetread
;de=pointer, hl=buffer size
;out: hl=size
        call BDOS_preparedepage
        call BDOS_setdepage
;DE = Pointer to physical data
        BDOSSETPGW5300
        jp wiznet_read

BDOS_wiznetwrite
;de=pointer, hl=size
        call BDOS_preparedepage
        call BDOS_setdepage
;DE = Pointer to physical data
        BDOSSETPGW5300
        jp wiznet_write

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BDOS_setmusic
muzpid=$+1
        ld a,0
        or a
        call z,killmuz
        ex af,af' ;'
        ld (muzpg),a
        ld (muzcall),hl
        ld a,(iy+app.id)
        ld (muzpid),a
;страницы для 8000, c000 берём из текущей юзерской карты памяти
        ld a,(iy+app.mainpg)
        call sys_setpg8000
        ld a,(curpg32klow+0x8000)
        ld (muzpg8000),a
        ld a,(curpg32khigh+0x8000)
        ld (muzpgc000),a
        ret

killmuz
        xor a
        ld (muzpid),a
        ld de,sys_reter
        ld (muzcall),de
        ld a,0xfe
        call shut1ay
        ld a,0xff
shut1ay
        ld bc,0xfffd
        out (c),a
        ld de,0x0e00
shutay0
        dec d
        ld b,0xff
        out (c),d
        ld b,0xbf
        out (c),e
        jr nz,shutay0
        ret

BDOS_setmainpage
        ;ld iy,(appaddr)
;e=page for 0x0000
        ld (iy+app.mainpg),e
        ret
        
BDOS_setborder
        ;ld iy,(appaddr)
;e=border=0..15
        ld (iy+app.border),e
        ret
        
BDOS_setscreen
        ;ld iy,(appaddr)
;e=screen=0..1
        ld a,e
        add a,a
        add a,a
        add a,a
        ld d,a
        or fd_user
        ld (iy+app.screen),a
        ;xor a ;success
        ret;jr rest_exit

BDOS_getappmainpages
;e=id
;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, a=error
        call BDOS_findapp
        jp nz,BDOS_fail
BDOS_getmainpages
        ;ld iy,(appaddr)
;out: dehl=номера страниц в 0000,4000,8000,c000, c=flags, b=id
BDOS_getmainpages_iy
        call setmainpg_c000
        ld d,a
        ld a,(curpg16k+0xc000)
        ld e,a
        ld a,(curpg32klow+0xc000)
        ld hl,(curpg32khigh+0xc000)
        ld h,a
        ld c,(iy+app.flags)
        ld b,(iy+app.id)
        xor a
        ret

BDOS_preparedepage
;de=userspace addr
;out: de>=0x8000, включены нужные страницы в 8000,c000
        ;ld iy,(appaddr)
        ld a,(iy+app.mainpg)
        call sys_setpg8000
        bit 7,d
        jr nz,BDOS_preparedepage8000_c000
        bit 6,d
        jr nz,BDOS_preparedepage4000_8000
        set 7,d
	ld (depage8000),a
        ld a,(curpg4000+0x8000)
        ;ld bc,memportc000
        ;out (c),a
	ld (depagec000),a
        ret
BDOS_preparedepage4000_8000
        ld a,d
        add a,0x40
        ld d,a
        ld a,(curpg8000+0x8000)
        ;call sys_setpgc000
	ld (depagec000),a
        ld a,(curpg4000+0x8000)
        ;call sys_setpg8000
	ld (depage8000),a
        ret
BDOS_preparedepage8000_c000
        ld a,(curpgc000+0x8000)
        ;call sys_setpgc000
	ld (depagec000),a
        ld a,(curpg8000+0x8000)
        ;call sys_setpg8000
	ld (depage8000),a
        ret

BDOS_setdepage
;keep de,hl
depagec000=$+1
        ld a,pgkillable;0
        call sys_setpgc000
depage8000=$+1
        ld a,pgkillable;0
sys_setpg8000
        ld (sys_curpg8000),a
        ld bc,memport8000
        out (c),a
	ret

BDOS_setpal
        call BDOS_preparedepage
        call BDOS_setdepage
;de=палитра (выше 0xc000)
        push iy
        pop hl
        ld bc,app.pal
        add hl,bc
        ex de,hl
        ld bc,32
        ldir
        ;call setpalettechanged
        ;xor a
        ;ret
setpalettechanged
        ld a,55+128 ;"or a"
        ld (palettechanged),a
        ret
        
BDOS_scroll_prepare
        ld a,l
        srl a
        ld (BDOS_scrollpagelinelayer_wid),a
        ld b,h
        dec b
BDOS_countxy
;keeps bc
        ld a,d ;y
        sub -0x87&0xff ;0xe1c0*4=0x8700
        rra
        ld h,a
         ld a,0;16
        rra
        sra h
        rra
        ld l,e ;x
        srl l
        jr c,$+4
        res 5,h
        add a,l
        ld l,a
        ret

BDOS_getxy
;out: de=yx ;GET CURSOR POSITION
        ;ld hl,(pr_textmode_curaddr)
        ld l,(iy+app.textcuraddr)
        ld h,(iy+app.textcuraddr+1)
        ld a,h
        rla
        rla
        rla ;bit5
        ld a,l
        rla
        and 0x7f
        ld e,a ;x
        add hl,hl
        add hl,hl ;h=y*4 + const + n*0x80
        ld a,h
        sub 0x87 ;0xe1c0*4=0x8700
        and 0x1f
        ld d,a ;y
        xor a ;success
        ret

BDOS_countattraddr
        BDOSSETPGSSCR
        ;ld hl,(pr_textmode_curaddr)
        ld l,(iy+app.textcuraddr)
        ld h,(iy+app.textcuraddr+1)
        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
         and 0x20
        jr nz,$+3
        inc l
        ret
        
BDOS_prattr
;e=color byte
         ld hl,(appaddr)
         ld bc,(focusappaddr)
         or a
         sbc hl,bc
         ret nz
        call BDOS_countattraddr
        ld (hl),e
        ret

BDOS_getattr
;out: a=color byte
        call BDOS_countattraddr
        ld a,(hl)
        ret

BDOS_setxy
;de=yx
        call BDOS_countxy
BDOS_settextcuraddr
        ;ld (pr_textmode_curaddr),hl
        ld (iy+app.textcuraddr),l
        ld (iy+app.textcuraddr+1),h
        xor a ;success
        ret
        
BDOS_prchar_controlcode
        cp 0x0a
        jr z,BDOS_prchar_lf
        cp 0x0d
        jp nz,BDOS_prchar_nocontrolcode
        ;jr z,BDOS_prchar_cr
BDOS_prchar_cr
        ld a,l
        and 0xc0
        ld l,a
        res 5,h
        jr BDOS_settextcuraddr
        ;jp BDOS_prchar_q
        
BDOS_prchar_lf
        ld a,l
        add a,0x40
        ld l,a
        jr nc,BDOS_settextcuraddr ;BDOS_prchar_q ;ret nc
        jr BDOS_prchar_lf_q

BDOS_prchar
;e=char
        ld a,e
BDOS_prchar_a
;портит только 0xc000+, но сама восстанавливает там pgkillable (для быстрого вызова через rst)
         ld hl,(appaddr)
         ld bc,(focusappaddr)
         or a
         sbc hl,bc
         ret nz ;no focus - no print

	ld h,trecode/256
	ld l,a
	ld a,(hl)
;pr_textmode_curaddr=$+1
        ;ld hl,0xc1c0
        ld l,(iy+app.textcuraddr)
        ld h,(iy+app.textcuraddr+1)
        cp 0x0e
        jr c,BDOS_prchar_controlcode
BDOS_prchar_nocontrolcode
         ;push hl
         ;ld hl,(appaddr)
         ;ld bc,(focusappaddr)
         ;or a
         ;sbc hl,bc
         ;pop hl
         ;jr nz,BDOS_prchar_skip
        ;ld de,pgscr0_1*256+pgscr0_0
        ;ld bc,memportc000
        ;out (c),d ;text
        ;ld (hl),a
        ;out (c),e ;attr
        ld e,a
        ld a,pgscr0_1
        call sys_setpgc000
        ld (hl),e
        ld a,pgscr0_0
        call sys_setpgc000
;BDOS_prchar_skip        

        ;ld de,0x2000 + pgkillable
        
         ;push af

        ld a,h
        xor 0x20;d;0x20 ;attr + 0x20
        ld h,a
        and 0x20;d;0x20
        jr nz,$+3
        inc l

         ;pop af
         ;jr nz,BDOS_prchar_skipattr
;pr_textmode_curcolor=$+1
        ;ld (hl),7
        ld a,(iy+app.curcolor)
        ld (hl),a
        
        ;set 6,h ;attr -> next char

        ;;ld e,pgkillable
        ;out (c),e ;pgkillable
        ld a,pgkillable
        call sys_setpgc000
;BDOS_prchar_skipattr

        ld a,l
        and 0x3f
        cp 80/2
        ;ld (pr_textmode_curaddr),hl
        ld (iy+app.textcuraddr),l
        ld (iy+app.textcuraddr+1),h
        ret nz ;jr nz,BDOS_prchar_q ;ret nz ;нет переноса строки
        ld a,l
        and 0xc0
        add a,0x40
        ld l,a
        jr nc,BDOS_settextcuraddr ;BDOS_prchar_q ;ret nc
BDOS_prchar_lf_q
        inc h
        bit 3,h
        jr z,BDOS_settextcuraddr ;BDOS_prchar_q ;нет выхода за последнюю строку
BDOS_scrolllock0
        ld a,0xfe
        in a,(0xfe)
        rra ;Caps Shift
        jr nc,BDOS_scrolllock0
        ld hl,(appaddr)
        ld de,(focusappaddr)
        or a
        sbc hl,de
        jr nz,BDOS_prchar_skipscroll
;scroll+clear bottom line
        call BDOS_scrollpage ;attr
        ld a,pgscr0_1 ;text
        ;ld bc,memportc000
        ;out (c),a
        call sys_setpgc000
        call BDOS_cllastline
        ld a,pgscr0_0 ;attr
        ;ld bc,memportc000
        ;out (c),a
        call sys_setpgc000
        call BDOS_cllastline
        ld a,pgkillable
        ;ld bc,memportc000
        ;out (c),a
        call sys_setpgc000
BDOS_prchar_skipscroll
        ld hl,0xc7c0
BDOS_prchar_q
        jp BDOS_settextcuraddr
        ;;ld (pr_textmode_curaddr),hl
        ;ld (iy+app.textcuraddr),l
        ;ld (iy+app.textcuraddr+1),h
        ;ret
        
BDOS_scrollpage
        ld a,40
        ld (BDOS_scrollpagelinelayer_wid),a
        ld hl,0xc1c0
        ld b,24
BDOS_scrollpage0
        push bc
        ld d,h
        ld e,l
        ld bc,64
        add hl,bc
        call BDOS_scrollpageline
        pop bc
        djnz BDOS_scrollpage0
        ret
BDOS_scrollpageline
        ld a,pgscr0_1 ;text
        or a
        call BDOS_scrollpagelinelayers ;text
        ld a,pgscr0_0 ;attr
        scf
BDOS_scrollpagelinelayers
        ;ld bc,memportc000
        ;out (c),a
        call sys_setpgc000
        push af
        push de
        push hl
        set 5,h
        set 5,d
        or a
        call BDOS_scrollpagelinelayer
        pop hl
        pop de
        pop af
BDOS_scrollpagelinelayer
        push de
        push hl
        jr nc,$+4
        inc hl
        inc de
BDOS_scrollpagelinelayer_wid=$+1
        ld bc,39;40
        ldir
        pop hl
        pop de
        ret

BDOS_scrolldown
;de=topyx, hl=hgt,wid
;x, wid even
         ;push hl
         ;ld hl,(appaddr)
         ;ld bc,(focusappaddr)
         ;or a
         ;sbc hl,bc
         ;pop hl
         ;ret nz
        ld a,d
        add a,h
        dec a
        ld d,a ;ybottom
        call BDOS_scroll_prepare
BDOS_scrolldown0
        push bc
        ld d,h
        ld e,l
        ld bc,-64
        add hl,bc
        call BDOS_scrollpageline
        pop bc
        djnz BDOS_scrolldown0
        ret

BDOS_scrollup
;de=topyx, hl=hgt,wid
;x, wid even
         ;push hl
         ;ld hl,(appaddr)
         ;ld bc,(focusappaddr)
         ;or a
         ;sbc hl,bc
         ;pop hl
         ;ret nz
        call BDOS_scroll_prepare
        jp BDOS_scrollpage0
        
BDOS_cllastline
        ld hl,0xc7c0
        call BDOS_scrollpage_clline
        ;ld de,0xc7c1
        ;ld bc,64-1
        ;ld (hl),b
        ;ldir
        ld hl,0xe7c0
BDOS_scrollpage_clline        
        ld d,h
        ld e,l
        inc e
        ld bc,64-1
        ld (hl),b
        ldir ;clear bottom line
        ret
        
BDOS_setcolor
;e=color byte
        ;ld a,e
        ;ld (pr_textmode_curcolor),a
        ld (iy+app.curcolor),e
        ret
;BDOS_getcolor
;	ld e,(iy+app.curcolor)
;	ret
        
BDOS_cls
         ld hl,(appaddr)
         ld bc,(focusappaddr)
         or a
         sbc hl,bc
         ret nz
        ;ld iy,(appaddr)
;e=color byte
        BDOSSETPGSSCR

        if 1==1
        ld a,(iy+app.gfxmode)
        and 7
        ;jr z,BDOS_cls_EGA(0)
         sub 3 ;MC hires(2)
        ld a,e ;attr byte
         jr c,BDOS_cls_EGA ;TODO отдельную очистку для MC hires
         ;dec a ;6912(3)
;textmode (6)
         ld hl,0xc000
         ld bc,0x1aff
         jr z,BDOS_cls_textmode_ldirbc ;6912(3)
        ld h,0x81;c0
        call BDOS_cls_textmode_ldir
        ld h,0xa1;c0
        call BDOS_cls_textmode_ldir
        endif
        
        ;ld de,0
        ld d,b
        ld e,b ;0
        call BDOS_setxy
        
        if 1==1
        xor a
        ld h,0xc1;c0
        call BDOS_cls_textmode_ldir
        ld h,0xe1;c0
BDOS_cls_textmode_ldir
        ld l,0xc0
        ld bc,25*64-1
BDOS_cls_textmode_ldirbc
        ld d,h
        ld e,l
        inc de
        ld (hl),a
        ldir
        ret
BDOS_cls_EGA
        endif
       
        ;ld a,e
scrbase=0x8000
;чистим через стек, кроме первых байтов (иначе прерывание может запортить два байта перед экраном)
        ld (clssp),sp
        ld hl,scrbase+(200*40) ;чистим с конца, потому что прерывание портит стек
        ld b,200-1
        scf
clsline0
        ld d,a
        ld e,a
        
        ;ld c,2
clsline1  
        ld sp,hl
        dup 20
        push de
        edup
        set 5,h
        ld sp,hl
        dup 20
        push de
        edup
        res 5,h
        
        set 6,h
        ;dec c
        ;jp nz,clsline1
        ccf
        jp nc,clsline1
        
        ;ld sp,hl
        ;dup 20
        ;push de
        ;edup
        ;res 5,h
        ;ld sp,hl
        ;dup 20
        ;push de
        ;edup
        ;res 6,h
        ld de,-40-0x4000
        add hl,de ;CY=1!!!
        djnz clsline0
clssp=$+1
        ld sp,0
        ld hl,0x0000 + scrbase
        call clslayer2
        ;ld hl,0x2000 + scrbase
        ;call clslayer
clslayer2
        ;ld hl,0x4000 + scrbase
        call clslayer
        ;ld hl,0x6000 + scrbase
clslayer
        ld d,h
        ld e,l
        inc de
        ld  c,40-1;8000-1
        ld (hl),a
        ldir
        ld de,0x2000-(40-1)
        add hl,de
        ret

BDOS_playcovox
;hl=data (0xc000+), ends with 0x00
;de=pagetable (0x0000+)
;hx=delay
        set 7,d ;de=pagetable (0x8000+)
        ld a,(iy+app.mainpg)
        call sys_setpg8000 ;pagetable in mainpg
	di
        ld a,(iy+app.gfxmode)
        and 0xf7 ;noturbo
	ld bc,0xbd77
	out (c),a
        push bc
;hx=delay
;hl=data
;de=pagetable (0x8000+)
        ld bc,memportc000
	ld a,(de)
	out (c),a
BDOS_playcovox0
        xor a ;4
BDOS_playcovox0_a0
	or (hl)	;7
	out (0xfb),a	;11
	jr z,BDOS_playcovoxdone	;7/12
	inc hl		;6
	bit 6,h		;8
	jr z,BDOS_playcovoxpage	;7/12
BDOS_playcovoxdelay
	ld a,hx		;4+4
	dec a		;4
	jp nz,$-1	;10
	jp BDOS_playcovox0_a0		;10=78t при d=1, шаг задержки 14 тактов
BDOS_playcovoxpage
;тут и раньше была неточная задержка
	ld h,0xc0
        inc de
	ld a,(de)
	out (c),a
	jp BDOS_playcovoxdelay
BDOS_playcovoxdone
        ld a,(iy+app.gfxmode) ;turbo
        pop bc
	out (c),a
	ei
        ret

BDOS_getchildresult
         res fchildfinished,(iy+app.flags) ;устанавливался по завершении дочерней задачи (чтобы в этом случае проскочить SETWAITING)
        ld l,(iy+app.childresult)
        ld h,(iy+app.childresult+1)
        ret

BDOS_hidefromparent
;просто разбудить родителя
activateparent
;hl=result
         ld e,(iy+app.parentid)
         ld a,e
         dec a
         ret z ;idle
        push hl
         ld (iy+app.parentid),1;idle ;чтобы после закрытия задачи не пришлось будить родителя (он может уже не существовать)
         call BDOS_findapp ;iy=found app
        pop hl
        ret nz ;not found
         set factive,(iy+app.flags)
          ld (iy+app.childresult),l
          ld (iy+app.childresult+1),h
         ret

BDOS_setstdinout
;b=id, e=stdin, d=stdout, h=stderr
        push de
        ld e,b
        call BDOS_findapp
        pop de
        ld (iy+app.stdin),e
        ld (iy+app.stdout),d
        ld (iy+app.stderr),h
        ret

BDOS_getstdinout
;out: e=stdin, d=stdout, h=stderr, l=hgt of stdout
        ld e,(iy+app.stdin)
        ld d,(iy+app.stdout)
       ld h,0
       ld l,d ;stdout
       ld bc,pipetypes-PIPEADD80
       add hl,bc
       ld l,(hl)
        ld h,(iy+app.stderr)
        ret

BDOS_getkeymatrix
;out: bcdehlix = полуряды cs...space
        ld hl,(appaddr)
        ld de,(focusappaddr)
        or a
        sbc hl,de
        jr nz,BDOS_getkeymatrix_fail
        ld bc,0x7ffe
        in a,(c)
        ld lx,a  ;lx=%???bnmS_
        ld b,0xbf
        in a,(c)
        ld hx,a  ;hx=%???hjklE
        ld b,0xdf
        in l,(c)  ;l=%???yuiop
        ld b,0xef
        in h,(c)  ;h=%???67890
        ld b,0xf7
        in e,(c)  ;e=%???54321
        ld b,0xfb
        in d,(c)  ;d=%???trewq
        ld a,0xfd
        in a,(0xfe);c=%???gfdsa
        ld b,c;0xfe
        in b,(c)  ;b=%???vcxzC
        ld c,a
         xor a ;z
        ret
BDOS_getkeymatrix_fail
;nz
        ld bc,0xffff
        ld d,c
        ld e,c
        ld h,c
        ld l,c
        push bc
        pop ix
        ret

BDOS_gettimerX
BDOS_gettimer
        ld hl,(sys_timer+2) ;ok
        ld de,(sys_timer) ;ok
         ld a,(sys_timer+2) ;ok
         sub l
         jr nz,BDOS_gettimerX ;для атомарности
        ret ;a=0
        
;BDOS_yield
;        ex af,af'
;        or a
;        jr z,BDOS_yieldnokeep
;        ;dec (iy+app.lasttime)
BDOS_yieldkeep
         ld a,(sys_timer) ;ok
         dec a
         jr BDOS_yieldgo
         ;ld (iy+app.lasttime),a
;BDOS_yieldnokeep
BDOS_yield
         ld a,(sys_timer) ;ok
BDOS_yieldgo
         ld (iy+app.lasttime),a
;регистры не сохраняем, т.к. нам не важно, что на выходе из yield
        if 1==1
;но надо:
;взять адрес стека для выхода из CALLBDOS и записать его в ld sp на выходе из обработчика прерываний
;взять адрес возврата из CALLBDOS и записать его в jp на выходе из обработчика прерываний
;на выходе надо вручную выставить везде pgkillable!
        ;ld iy,(appaddr)
        
        if bdosstack_sz==0
        ld hl,(callbdos_sp)
        else
        ;ld l,(iy+app.callbdos_sp)
        ;ld h,(iy+app.callbdos_sp+1)
        exx
        endif

        ;call setmainpg_c000
         ;halt ;проверка на вшивость
        ;ld (intsp+0xc000),hl

        ;ex de,hl
        ld de,-6
        add hl,de ;место в стеке под 3 рег.пары (а потом адрес возврата из bdos)
        ld (iy-2),l
        ld (iy-1),h ;sp в описателе текущей задачи
        ;call BDOS_preparedepage
        ;call BDOS_setdepage ;включается сразу 2 страницы на случай sp на границе страниц
        ;ex de,hl
         ;halt ;проверка на вшивость        
        ;ld e,(hl)
        ;inc hl
        ;ld d,(hl) ;вместо адреса возврата из bdos

        ;call setmainpg_c000
         ;halt ;проверка на вшивость
        ;ld (intjp+0xc000),de ;TODO при многозадачности в кернале это надо делать атомарно вместе с записью sp!
        endif
        
        ;ld a,pgkillable
        ;call sys_setpgc000
        ;call sys_setpg8000
        ;call setpgs_killable
        
        if bdosstack_sz !=0
        ld a,0xc0
        ld (callbdos_mutex),a ;то же самое делают те функции BDOS, которые не собираются возвращаться
        endif

;не выходим из CALLBDOS, взамен шедулим и выходим через конец обработчика прерываний

BDOS_yield_q

;        push iy
        call schedule ;out: iy=app ;можно с включенными прерываниями, пока системный обработчик не умеет шедулить
        call setpgs_killable ;во всех случаях!
         ;halt ;проверка на вшивость
;        pop de
;        or a
;        sbc hl,de
;        jr nz,BDOS_yield_nosame
;        ld iy,app1 ;idle (TODO вместо этого сделать полноценные приоритеты)
;        ld (appaddr),iy
;BDOS_yield_nosame
        
        ;di ;TODO critical section
        
        jp sys_int_popregs ;там ei
        
BDOS_newapp
;пока структура не заполнена до конца, нельзя делать runapp
;out: b=id, dehl=номера страниц в 0000,4000,8000,c000 нового приложения, a=error
        BDOSSETPGTRDOSFS
        jp sys_newapp_forBDOS

BDOS_findapp
;nz=error
        ld iy,app1
        ld a,e
        ld de,app_sz
        ld b,MAXAPPS
BDOS_findapp0
        cp (iy+app.id)
        ret z
        add iy,de
        djnz BDOS_findapp0
        ret ;nz
        
BDOS_dropapp
;e=id
;hl=result
       push hl
        call BDOS_findapp
       pop hl
        jp nz,BDOS_fail ;BDOS_popfail
        push iy
       push hl
        call BDOS_freezeapp_go
       pop hl ;result
        pop iy
;BDOS_delapppages
         push iy
         call activateparent ;in: hl=result
         pop iy
       ld a,(muzpid)
       cp (iy+app.id)
       call z,killmuz ;before killing pages!!!
        ld hl,tsys_pages
        ld a,(iy+app.id)
        ld b,sys_npages&0xff
sys_quit_delpages0
        cp (hl) ;id==снимаемая задача?
        jr nz,$+4
        ld (hl),0 ;освободили страницу
        inc hl
        djnz sys_quit_delpages0
		if INETDRV
		BDOSSETPGW5300
		call w53_drop_socs
		endif
        if 1==1
        call BDOS_setpgstructs
        ld ix,ffilearray
        ld b,MAXFILES
BDOS_dropapp_closefiles0
        ld de,FIL_sz
        ld a,(ix+FIL.PAD1)
        cp (iy+app.id)
        jr nz,BDOS_dropapp_closefiles_skip
        push bc
        push ix
        pop de
        push de
        F_CLOS_CURDRV
        pop ix
        pop bc
BDOS_dropapp_closefiles_skip
        add ix,de
        djnz BDOS_dropapp_closefiles0
        endif
        ;ld a,(muzpid)
        ;cp (iy+app.id)
        ;call z,killmuz
        xor a ;ok
        ld (iy+app.id),a ;b;0 ;освободили место
        ret
        
open_keeppid
        push af
        push de
        inc de
        inc de
        inc de
        inc de
        inc de
    push bc
    call BDOS_setpgstructs
    pop bc
        ld a,(iy+app.id)
        ld (de),a
        pop de
        pop af
        ret

BDOS_runapp
;e=id
        ;push iy
        call BDOS_findapp
        jp nz,BDOS_fail ;BDOS_popfail
        set factive,(iy+app.flags)
        ;pop iy
        xor a
        ret

BDOS_setwaiting
        ;set fwaiting,(iy+app.flags)
         bit fchildfinished,(iy+app.flags)
         ret nz ;не замораживает, если дочерний процесс уже завершился
        res factive,(iy+app.flags)
        ret

BDOS_checkpid
;e=id
;check if this child(!) app exists, out: a!=0 => OK, or else a=0
         push iy
         ;set fwaiting,(iy+app.flags)
        ld c,(iy+app.id) ;my (parent's) id ;caller is the parent
        push bc
        call BDOS_findapp ;iy=found app
        pop bc
        ld a,(iy+app.parentid)
         pop iy
        jr nz,BDOS_checkpid_OK ;app doesn't exist = OK
        cp c ;parent id
        jp z,BDOS_fail ;existing app = fail
BDOS_checkpid_OK
         ;res fwaiting,(iy+app.flags)
        xor a
        ret

BDOS_setgfx
        ;ld iy,(appaddr)
;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+8 = noturbo ;+128=keep screen
;e=-1: disable gfx (out: e=old gfxmode)
        push de
        bit 7,(iy+app.gfxkeep)
        jr z,BDOS_setgfx_nkept
        ld e,(iy+app.scr0low)
        call BDOS_delpage
        ld e,(iy+app.scr0high)
        call BDOS_delpage
        ld e,(iy+app.scr1low)
        call BDOS_delpage
        ld e,(iy+app.scr1high)
        call BDOS_delpage        
BDOS_setgfx_nkept
        pop de
        ld a,e
        cp -1
        jr z,BDOS_setgfx_gfxoff;BDOS_gfxoff_givefocus
		IFDEF NOTURBO
		ELSE
        xor 0x08;%00001000 ;+8 = noturbo
		ENDIF
        ld (iy+app.gfxkeep),a ;b7 = keep gfx pages
        push af
        rla
        jr nc,BDOS_setgfx_nokeep
;TODO return error if error
        call BDOS_newpage_iy ;out: a=0 (OK)/0xff (fail), e=page
        ld (iy+app.scr0low),e
        call BDOS_newpage_iy ;out: a=0 (OK)/0xff (fail), e=page
        ld (iy+app.scr0high),e
        call BDOS_newpage_iy ;out: a=0 (OK)/0xff (fail), e=page
        ld (iy+app.scr1low),e
        call BDOS_newpage_iy ;out: a=0 (OK)/0xff (fail), e=page
        ld (iy+app.scr1high),e        
BDOS_setgfx_nokeep
        pop af
        or 0xa0;%10100000
        ld (iy+app.gfxmode),a

        call enablescreeninapp_nokeep ;enablescreeninapp_setc000
        
;кладём фокус в стек, только если не два раза setgfx в одной задаче:
        ld hl,(focusappaddr)
        push iy
        pop de
        or a
        sbc hl,de
        jr z,BDOS_setgfx_nopushfocus ;not in focus
        ;jr $
        add hl,de
        push de;iy
        push hl
        pop iy
        call disablescrpgs_setc000 ;у старой focusapp отключить экран в переменных и в памяти
        pop iy
        
         ld hl,(oldfocusappaddr)
         ld (oldoldfocusappaddr),hl ;TODO стек фокусов (чтобы после закрытия задачи вернуть фокус вызвавшей)
        ld hl,(focusappaddr)
        ld (oldfocusappaddr),hl ;TODO стек фокусов (чтобы после закрытия задачи вернуть фокус вызвавшей)
        ld (focusappaddr),iy
        call setpalettechanged
BDOS_setgfx_nopushfocus        
        set fgfx,(iy+app.flags)
        ld e,(iy+app.gfxmode)
        ;xor a ;success
        ret
BDOS_setgfx_gfxoff
        call disablescrpgs_setc000 ;у старой focusapp отключить экран в переменных и в памяти
        ld e,(iy+app.gfxmode)
        push de
        call BDOS_gfxoff_givefocus ;spoils iy!
        pop de
        ret
;disablescreeninapp_setc000
        ;call setmainpg_c000
disablescreeninapp ;used in sys_newapp
        ld a,pgkillable
        ld (0xc000+user_scr0_low),a
        ld (0xc000+user_scr0_high),a
        ld (0xc000+user_scr1_low),a
        ld (0xc000+user_scr1_high),a
        ret
enablescreeninapp_setc000
        bit 7,(iy+app.gfxkeep)
        jr z,enablescreeninapp_nokeep
        ld e,pgscr0_0
        ld a,(iy+app.scr0low)
        call copypage_a_to_e
        ld e,pgscr0_1
        ld a,(iy+app.scr0high)
        call copypage_a_to_e
        ld e,pgscr1_0
        ld a,(iy+app.scr1low)
        call copypage_a_to_e
        ld e,pgscr1_1
        ld a,(iy+app.scr1high)
        call copypage_a_to_e
        call setmainpg_c000
        ld de,curpg16k+0xc000
        call enablescrpg
        ld  e,0xff&(curpg32klow+0xc000)
        call enablescrpg
        ld  e,0xff&(curpg32khigh+0xc000)
        call enablescrpg
enablescreeninapp_nokeep
        call setmainpg_c000
        ld a,pgscr0_0
        ld (0xc000+user_scr0_low),a
        ld a,pgscr0_1
        ld (0xc000+user_scr0_high),a
        ld a,pgscr1_0
        ld (0xc000+user_scr1_low),a
        ld a,pgscr1_1
        ld (0xc000+user_scr1_high),a
        ret
        
BDOS_freezeapp
;e=id
        ;push iy
        call BDOS_findapp
        jp nz,BDOS_fail ;BDOS_popfail
BDOS_freezeapp_go
        ;ld (iy+app.flags),0 ;пока тут 0, задачу никто не будет трогать
        res factive,(iy+app.flags)
BDOS_gfxoff_givefocus
        res fgfx,(iy+app.flags) ;если в конце, то по дороге могут вручную переключить фокус, а если в начале, то ...
;если фокус у этой задачи, то дать фокус какой-нибудь графической задаче
        push iy
        pop hl
        ld de,(focusappaddr)
        xor a
        sbc hl,de
        ret nz ;jr nz,sys_quit_findgfxapp_fail ;фокус не у этой задачи
        
oldfocusappaddr=$+1
        ld hl,app1
oldoldfocusappaddr=$+1
         ld de,app1
         ld (oldfocusappaddr),de
        bit fgfx,(hl)
        jr nz,sys_quit_findgfxappq ;TODO стек фокусов (чтобы после закрытия задачи вернуть фокус вызвавшей)
        
        ld hl,app1
        ld bc,-app_last;app_afterlast
        ld de,app_last+app_sz;app_sz
sys_quit_findgfxapp0
        add hl,bc
        jr c,sys_quit_findgfxapp_fail ;уже проверили app_last, у него нет фокуса - некому давать фокус
        add hl,de
        bit fgfx,(hl)
        jr z,sys_quit_findgfxapp0
sys_quit_findgfxappq
        ld (focusappaddr),hl
        call setpalettechanged
        push hl
        pop iy
        call enablescreeninapp_setc000 ;включить экран в переменные этой задачи
        
         ;ld a,key_redraw
         ;ld (curkey),a
         ;ld bc,key_redraw
         ; ld (keyqueueput_codenolang),bc
         ;call KEYQUEUEPUT
         call KEY_PUTREDRAW
sys_quit_findgfxapp_fail
        ;pop iy
        xor a
        ret

BDOS_getpageowner
;e=page ;out: e=owner id (0=free, 0xff=system)
        ld hl,tsys_pages
      if sys_npages != 256
       ld a,e
       cp sys_npages
       jr nc,BDOS_getpageowner_toobig
      endif
        ld d,0
        add hl,de
        ld e,(hl)
        ret
      if sys_npages != 256
BDOS_getpageowner_toobig
       ld e,0xff
        ret
      endif

BDOS_newpage
        ;ld iy,(appaddr)
BDOS_newpage_iy
;out: a=0 (OK)/0xff (fail), e=page
       if TOPDOWNMEM
        ld hl,tsys_pages +sys_npages-1
        ld bc,sys_npages
        xor a
        cpdr
        jr nz,BDOS_fail
        inc hl
        ld a,(iy+app.id)
        ld (hl),a
        ld a,pagexor;0x7f
        sub c ;c=0..sys_npages-1
       else
        ld hl,tsys_pages
        ;push hl
        ld bc,sys_npages
        xor a
        cpir
        ;pop de
        jr nz,BDOS_fail
        dec hl
        ld a,(iy+app.id)
        ld (hl),a
         ;or a
         ;sbc hl,de ;hl=(0..sys_npages-1)
        ;ld a,pagexor;0x7f
        ;sub l ;l=0..sys_npages-1
        ld a,0xff&(pagexor-(sys_npages-1))
        add a,c
       endif
        ld e,a ;page
BDOS_OK
        xor a
        ret ;a=0 (OK), e=page

BDOS_pop2fail
        pop af
BDOS_popfail
        pop af
BDOS_fail
        ld a,0xff
        ret

BDOS_delpage
;e=page
;не портит de
;в конце A не гарантировано
        ld a,e
        ;call addrpage ;a=0
         xor pagexor;0x7f
         ld c,a
         ld hl,tsys_pages
         xor a
         ld b,a
         add hl,bc
       ld a,(hl)
       inc a
       ret z ;reserved page (for example pgkillable)
        ld (hl),b ;id=0, т.е. у этой страницы нет хозяина
        ret

       if 1==0
addrpage
        xor pagexor;0x7f
        ld c,a
        ld hl,tsys_pages
        xor a
        ld b,a
        add hl,bc
        ret ;a=0
       endif

;DEPRECATED!!!!! 
BDOS_fdel
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to unopened FCB
        CHECKVOLUMETRDOS
        jr c,BDOS_fdel_noFATFS

	call get_name
	ld de,mfil
	F_UNLINK_CURDRV
	;or a:jp z,fexit
	;ld a,0xff
	ret;jp fexit
BDOS_fdel_noFATFS
        BDOSSETPGTRDOSFS
;DE = Pointer to unopened FCB
        jp nfdel

BDOS_rndrdwrseek
;DE = Pointer to opened FCB
       push de
        ld hl,0x21 ;outsize FCB_sz!!!
        add hl,de
        ld c,(hl)
        inc hl
        ld b,(hl)
        push bc ;record number BC
        call getFILfromFCB ;hl=FIL
        ex de,hl ;de=fil (2 words in stack = shift)        
        push de
        call BDOS_getfilesize_filde
;dehl=filesize (no more than 8M in CP/M finction)
;highest record number = dehl/128???
        add hl,hl
        rl e
        ld l,h
        ld h,e
;highest record number = dehl/128-1??? wrong!
        ;add hl,hl
        ;rl e
        ;ld l,h
        ;ld h,e
        ; ld a,h
        ; or l
        ; jr z,$+3
        ; dec hl
;highest record number = (dehl-1)/128??? wrong!
        ;ld a,h
        ;or l
        ;dec hl
        ;jr nz,$+3
        ;dec de
        ;add hl,hl
        ;rl e
        ;ld l,h
        ;ld h,e
        ; ld a,h
        ; and l
        ; inc a
        ; jr nz,$+3
        ; inc hl
        pop de
        pop bc ;record number BC
        call minhl_bc_tobc        
        ld l,b ;HSB from BC
        ld h,0
        srl l
        push hl ;HSW
        ld b,c
        ld c,h;0
        rr b
        rr c
        push bc ;LSW
        F_LSEEK_CURDRV        
        pop bc
        pop bc
       pop de 
        ret

;TODO TR-DOS???
BDOS_rndrd
        call BDOS_preparedepage
        call BDOS_setdepage
;DE = Pointer to opened FCB
        call BDOS_rndrdwrseek
         call BDOS_setdepage
        jr BDOS_fread_gofatfs

;TODO TR-DOS???
BDOS_rndwr
        call BDOS_preparedepage
        call BDOS_setdepage
;DE = Pointer to opened FCB
        call BDOS_rndrdwrseek
         call BDOS_setdepage
        jr BDOS_fwrite_gofatfs

BDOS_fread
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to opened FCB
        ;CHECKVOLUMETRDOS
        ld a,(de)
        cp vol_trdos
        jr c,BDOS_fread_noFATFS
BDOS_fread_gofatfs
;достать из него адрес ffile
        call getFILfromFCB ;hl=FIL
        call BDOS_getdta ;de = disk transfer address
       push de
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        ld b,d
        ld c,e
	ld de,blocksize
         push de ;blocksize
	ld ix,fres
        push ix ;fres
        push de ;blocksize
	ex de,hl;ld de,ffile
	F_READ_CURDRV
BDOS_fread_fatfsq        
	pop bc
        pop bc
	ld a,(bc)
         pop bc ;blocksize
       pop de ;de = disk transfer address
        ;call movedma_addr ;+bc ;TODO remove!!!
	xor 0x80 ;!=, если прочитали не 128 байт ;TODO remove!!!
;a=0: OK (прочитали 128 байт)
;a=128: fail (прочитали 0 байт)
;a=???: OK (последний блок файла меньше 128 байт)
        ret z
        cp 0x80
        ret z ;fail
;for CP/M compatibility: fill unused part of sector with 0x1a
        push af
        ;call BDOS_getdta ;de = disk transfer address
        call BDOS_preparedepage
        call BDOS_setdepage ;нельзя надеяться на включение выше, если будет убрано в драйвер (т.к. это могло быть не последнее включение страницы)
        pop af
        push af
;a=128+bytes loaded
        neg
;a=128-bytes loaded
        ld b,a
        ld a,e
        add a,127
        ld e,a
        adc a,d
        sub e
        ld d,a ;de= Point to buffer end
        ld a,0x1a
        ld (de),a
        dec de
        djnz $-2
        pop af
	ret;jp fexit
BDOS_fread_noFATFS
        BDOSSETPGTRDOSFS
;DE = Pointer to opened FCB (0x8000+/0xc000+)
        jp trdos_fread

BDOS_fwrite
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to opened FCB
        ;CHECKVOLUMETRDOS
        ld a,(de)
        cp vol_trdos
        jr c,BDOS_fwrite_noFATFS
BDOS_fwrite_gofatfs
;достать из него адрес ffile
        call getFILfromFCB ;hl=FIL
        call BDOS_getdta ;de = disk transfer address
       push de
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        ld b,d
        ld c,e
	ld de,blocksize
         push de ;blocksize
	ld ix,fres
        push ix ;fres
        push de ;blocksize
	ex de,hl;ld de,ffile
	F_WRITE_CURDRV
        jr BDOS_fread_fatfsq
BDOS_fwrite_noFATFS
        BDOSSETPGTRDOSFS
;DE = Pointer to opened FCB
        jp trdos_fwrite

        if 1==0
BDOS_fwrite_nbytes
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to opened FCB
;hl = bytes
        ;CHECKVOLUMETRDOS
        ld a,(de)
        cp vol_trdos
        jr c,BDOS_fwrite_nbytes_noFATFS
;достать из него адрес ffile
         push hl ;bytes
        call getFILfromFCB ;hl=FIL

        call BDOS_getdta ;de = disk transfer address
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        ld b,d
        ld c,e
	;ld de,blocksize
         pop de ;bytes
         push de ;blocksize
	ld ix,fres
        push ix ;fres
        push de ;blocksize
	ex de,hl;ld de,ffile
	F_WRITE_CURDRV
        jr BDOS_fread_fatfsq
BDOS_fwrite_nbytes_noFATFS
        BDOSSETPGTRDOSFS
;DE = Pointer to opened FCB
;hl = bytes
        ld b,h
        ld c,l
        jp trdos_fwrite_nbytes
        endif

;de=path
;hl=FILINFO buffer
BDOS_getfilinfo
        push hl ;FILINFO buffer
        call BDOS_preparedepage
        call BDOS_setdepage
        call countfiledrive
        pop bc
        F_STAT
        ret
        
count_fdir
        push iy
        pop de
        ld hl,app.dir
        add hl,de
        ex de,hl
        ret

;de=path
BDOS_opendir
        call BDOS_preparedepage
        call BDOS_setdepage
	call countfiledrive
        ld b,d
        ld c,e
        CHECKVOLUMETRDOS
        jr c,BDOS_opendir_noFATFS
BDOS_opencurdir
        call count_fdir ;LD de,fdir
        F_OPDIR_CURDRV
        ret

BDOS_opendir_noFATFS
       push af
        BDOSSETPGTRDOSFS
       pop af
       ld (trdoscurdrive),a
        ld hl,trdos_catbuf
        call writedircluster_hl        
        ld de,0x0000 ;track,sector
       ld (hl),e;0
        ld bc,0x0905 ;read 9 sectors
        call iodos.
        xor a ;no error
        ret

;de=buf for FILINFO, 0x00 in FILINFO_FNAME = end dir
BDOS_readdir
        call BDOS_preparedepage
        call BDOS_setdepage
        ld b,d
        ld c,e
        CHECKVOLUMETRDOS
        jr c,BDOS_readdir_noFATFS
        call count_fdir ;LD de,fdir
	F_RDIR_CURDRV
        ret
        
BDOS_readdir_noFATFS
;bc=addrto
        push bc
        BDOSSETPGTRDOSFS
        ld l,(iy+app.dircluster)
        ld h,(iy+app.dircluster+1)
        ld de,fcb2+FCB_FNAME
        call trdos_searchnext
        jp z,BDOS_popfail ;fsearchnext_nofile;BDOS_fsearch_loadloop_noFATFS_empty
        call writedircluster_hl
        pop de
;de=addrto
        ld hl,fcb2+FCB_FSIZE
        ld bc,4
        ldir
        ld hl,fcb2+FCB_FDATE
        ld c,2
        ldir
        ld hl,fcb2+FCB_FTIME
        ld c,2
        ldir
        ld hl,fcb2+FCB_FATTRIB
        ldi
        ld hl,fcb2+FCB_FNAME
        call get_name_hltode ;делает из имени без точки имя с точкой
        ld h,d
        ld l,e
        ld bc,12
        xor a ;no error
        ld (hl),a
		inc de
        ldir ;независимо от длины короткого имени он длинное затирает
        ret
;FILINFO_FSIZE=0;	        DWORD		;/* FILE SIZE */
;FILINFO_FDATE=4;	        WORD		;/* LAST MODIFIED DATE */
;FILINFO_FTIME=6;	        WORD		;/* LAST MODIFIED TIME */
;FILINFO_FATTRIB=8;	        BYTE		;/* ATTRIBUTE */
;FILINFO_FNAME=9;	        BLOCK 13,0	;/* SHORT FILE NAME (8.3 FORMAT with dot and terminator) */
;FILINFO_LNAME=22;	        BLOCK DIRMAXFILENAME64,0	;/* LONG FILE NAME (ASCIIZ) */
;FILINFO_sz=FILINFO_LNAME+DIRMAXFILENAME64


;SEARCH FOR FIRST [FCB] (11H)
;     Parameters:    C = 11H (_SFIRST)
;                   DE = Pointer to unopened FCB
;     Results:     L=A = 0FFH if file not found
;                      =   0  if file found.
;The filename may be ambiguous (containing "?" characters) in which case the first match will be found. 
;The low byte of the extent field will be used, and a file will only be found if it is big enough 
;to contain this extent number. Normally the extent field will be set to zero by the program before 
;calling this function. System file and sub-directory entries will not be found.
;If a suitable match is found (A=0) then the directory entry will be copied to the DTA address, 
;preceded by the drive number. This can be used directly as an FCB for an OPEN function call if desired. 
;The extent number will be set to the low byte of the extent from the search FCB, and the record count 
;will be initialized appropriately (as for OPEN). The attributes byte from the directory entry will be
;stored in the S1 byte position, since its normal position (immediately after the filename extension field) 
;is used for the extent byte.
BDOS_fsearchfirst
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
         push de ;DE = Pointer to unopened FCB (0x8000+/0xc000+)
        CHECKVOLUMETRDOS
        jr c,BDOS_fsearchfirst_noFATFS
		ld bc,0 ; TCHAR *path	/* Pointer to the directory path */
        call BDOS_opencurdir

         pop de ;DE = Pointer to unopened FCB (0x8000+/0xc000+)
        or a
        ret nz;jp nz,fexit
        jr BDOS_fsearch_goloadloop
BDOS_fsearchfirst_noFATFS
;TR-DOS
       push af
        BDOSSETPGTRDOSFS
       pop af
       ld (trdoscurdrive),a
        ld hl,trdos_catbuf
        ;ld (BDOS_fsearch_loadloop_trdosaddr),hl ;TODO где хранить для многозадачности? возвращать в FCB_DIRPOS?
        call writedircluster_hl
        
        ld de,0x0000 ;track,sector
       ld (hl),e;0
        ld bc,0x0905 ;read 9 sectors
        call iodos.
         pop de ;DE = Pointer to unopened FCB (0x8000+/0xc000+)
        jr BDOS_fsearch_goloadloop
        
;SEARCH FOR NEXT [FCB] (12H)
;     Parameters:    C = 12H (_SNEXT)
;     Results:     L=A = 0FFH if file not found
;                      =   0  if file found.
BDOS_fsearchnext
;(not CP/M!!!) для многозадачности принимать тут de = Pointer to unopened FCB
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
BDOS_fsearch_goloadloop
        inc de
        ld (fsearchnext_filename),de
BDOS_fsearch_loadloop
        ld iy,(appaddr) ;т.к. ffs портит iy
        CHECKVOLUMETRDOS
        jr c,BDOS_fsearch_loadloop_noFATFS

        call count_fdir ;LD de,fdir
	LD bc,mfilinfo
	F_RDIR_CURDRV
         or a
         jp nz,BDOS_fail ;fsearchnext_nofile ;иначе после удаления файла каталог не заканчивается

;переделать структуру FILINFO (которую мы сейчас считали) в структуру FCB
        ld de,mfilinfo+FILINFO_FNAME
        ld a,(de)
        or a
        jp z,BDOS_fail ;fsearchnext_nofile
        BDOSSETPGTRDOSFS
        call trdosgetdirfcb
        jr BDOS_fsearch_loadloop_FATFSq
BDOS_fsearch_loadloop_noFATFS
;TR-DOS
        BDOSSETPGTRDOSFS
        ld l,(iy+app.dircluster)
        ld h,(iy+app.dircluster+1)
        ld de,fcb2+FCB_FNAME
        call trdos_searchnext
        jp z,BDOS_fail ;fsearchnext_nofile;BDOS_fsearch_loadloop_noFATFS_empty
        call writedircluster_hl
        jr BDOS_fsearch_loadloop_FATFSq
BDOS_fsearch_loadloop_FATFSq
        ld hl,fcb2+FCB_FNAME ;прочитанное имя
fsearchnext_filename=$+1
        ld de,0 ;образец
        
;проверить имя файла hl == de (игнорировать (de)=='?')
	ld bc,11*256;0x0a00 ;b=bytes to compare, c=errors
fsearchnext_cp00
	ld a,[de]
        cp '?'
        jr z,fsearchnext_cpskip
	sub [hl]
	or c
	ld c,a ;errors
fsearchnext_cpskip
	inc hl
	inc de
	djnz fsearchnext_cp00
        
;если не совпало, зациклить
        ld a,c
        or a
        jp nz,BDOS_fsearch_loadloop
fsearchnext_nofileq
;иначе записать в dma
        ld iy,(appaddr)
        ld hl,fcb2
        call BDOS_getdta ;de = disk transfer address
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        ld bc,FCB_sz;32;16
         push bc
        ldir
         pop bc
        call movedma_addr ;+bc
        xor a ;success
        ret;jp rest_exit

BDOS_getfiletime
;de=Drive/path/file ASCIIZ string
;out: ix=date, hl=time
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        call countfiledrive ;a=volume, de=path without drive, c=1: drive in path, CY=TR-DOS
        jr c,BDOS_getfiletime_zero
        ld bc,fres
;de=name
;bc=pointer to time,date
		F_GETUTIME
        ld hl,(fres)
        ld ix,(fres+2)
        ;xor a
        ret
BDOS_getfiletime_zero
        ;display "BDOS_getfiletime_zero=",BDOS_getfiletime_zero
        BDOSSETPGTRDOSFS
        jp trdos_getfiletime
        ;xor a
        ;ld l,a
        ;ld h,a
        ;push hl
        ;pop ix
BDOS_gettime
;out: ix=date, hl=time
		if atm==1
			call readtime
		endif
        ld hl,(sys_time_date) ;ok
        ld ix,(sys_time_date+2) ;ok
        ret
        

BDOS_setfiletime
;de=Drive/path/file ASCIIZ string, ix=date, hl=time
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
         call countfiledrive ;a=volume, de=path without drive, c=1: drive in path, CY=TR-DOS
         jr c,BDOS_getfiletime_zero
        push hl ;time
        push ix ;date
        pop bc ;date
;de=name
;bc=date
;stack=time
        F_UTIME_CURDRV
        pop bc
        ret
        
BDOS_seekhandle
;                    B = File handle
;                    [A = Method code: 0=begin,1=cur,2=end]
;                DE:HL = Signed offset
;     Results:       A = Error
;                DE:HL = New file pointer
        bit 6,b
        jr nz,BDOS_seekhandle_noFATFS
        push de ;HSW
        push hl ;LSW
        call BDOS_number_to_fil ;de=fil
        F_LSEEK_CURDRV        
        pop bc
        pop bc
        ret
BDOS_seekhandle_noFATFS
        push bc
        BDOSSETPGTRDOSFS
        pop bc
        jp trdos_seekhandle

BDOS_getfilesize
;b=handle
;out: dehl=filesize
        bit 6,b
        jr nz,BDOS_getfilesize_noFATFS
        call BDOS_number_to_fil ;de=fil
BDOS_getfilesize_filde
        ld hl,FIL.FSIZE
        jr BDOS_tellhandleq
        ;add hl,de
        ;ld e,(hl)
        ;inc hl
        ;ld d,(hl)
        ;inc hl
        ;ld a,(hl)
        ;inc hl
        ;ld h,(hl)
        ;ld l,a
        ;ex de,hl
        ;xor a
        ;ret
BDOS_getfilesize_noFATFS
        push bc
        BDOSSETPGTRDOSFS
        pop bc
        jp trdos_getfilesize ;dehl=filesize

BDOS_tellhandle
;b=file handle, out: dehl=offset
;TODO TR-DOS
        call BDOS_number_to_fil ;de=fil
        ld hl,FIL.FPTR
BDOS_tellhandleq
        call BDOS_setpgstructs
        add hl,de
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        ld h,b
        ld l,c
        xor a
        ret
        
BDOS_createhandle
;DE = Drive/path/file ASCIIZ string
;A = Open mode. b0 set => no write, b1 set => no read, b2 set => inheritable, b3..b7   -  must be clear
;B = b0..b6 = Required attributes, b7 = Create new flag
;out: B = new file handle, A=error
        ld c,a
        ld a,'w'
	LD HL,FA_READ|FA_WRITE|FA_CREATE_ALWAYS
        jr BDOS_openorcreatehandle

BDOS_openhandle
;DE = Drive/path/file ASCIIZ string
;[A = Open mode. b0 set => no write, b1 set => no read, b2 set => inheritable, b3..b7   -  must be clear]
;out: B = new file handle, A=error
        ld c,a
        ld a,'r'
        ld hl,FA_READ|FA_WRITE
BDOS_openorcreatehandle
        ld (BDOS_openorcreatehandle_trdosmode),a
        ld (.mode),hl
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Drive/path/file ASCIIZ string
        call countfiledrive ;a=volume, de=path without drive, c=1: drive in path, CY=TR-DOS
        jr c,BDOS_openhandle_noFATFS
        cp vol_pipe
        jr z,BDOS_openhandle_pipe
		ld (.store_a),a
        push de
         ;dec c ;was c=1: drive in path
         ;call z,BDOS_setvol_rootdir ;drive specified in path
        call findfreeffile
         jr nz,$ ;TODO error
        push bc
        call BDOS_setdepage ;TODO убрать в драйвер????
        pop bc
        ld a,b
        ex de,hl ;a=fil number, de=poi to FIL
        pop bc
        push af
.mode=$+1
	LD HL,FA_READ|FA_WRITE
.store_a=$+1
		ld a,0
        F_OP
        pop bc ;b=fil number=new file handle
         ret

BDOS_openhandle_noFATFS
;a=drive
;recode file name
        ;pop af ;z=drive in path
       push af ;drive
        BDOSSETPGTRDOSFS
        ex de,hl ;hl=path
        call findlastslash. ;de=after last slash or beginning of path
        ld hl,BDOS_parse_filename_cpmnamebuf
        push hl
        call dotname_to_cpmname ;de -> hl ;out: de=pointer to termination character, hl=buffer filled in
        ;BDOSSETPGTRDOSFS
        pop de
BDOS_openorcreatehandle_trdosmode=$+1
        ld c,'r'
       pop af ;drive
        call nfopen ;hl=trdosfcb
        ld b,h ;new file handle
        ret

BDOS_openhandle_pipe
;find free pipe
        ld hl,freepipes
        xor a
        ld bc,MAXPIPES
        cpir
        jp nz,BDOS_fail
        dec hl
         inc (hl)
        inc (hl) ;opened once, used as stdin and as stdout, closed twice
        ld a,l
        add a,0xff&(-freepipes+PIPEADD80)
        push af ;a=handle
;a = PIPEADD80+pipeindex
        call findpipe_byhandle ;out: hl=pipebuf, a=pipe#
        ld bc,pipeowners
        add a,c
        ld c,a
        jr nc,$+3
        inc b
        ld a,(iy+app.id)
        ld (bc),a ;pipe owner (потом переназначится тому, кто читает)
        xor a
        ld (hl),a ;size=0
       ld hl,pipetypes-pipeowners
       add hl,bc
       inc de
       inc de ;de=path without drive, skip slash and first letter (for unique names in the future)
       ld a,(de)
       sub '0'
       ld c,a
       add a,a
       add a,a
       add a,c
       add a,a ;*10
       ld c,a
       inc de
       ld a,(de)
       sub '0'
       add a,c
       ld (hl),a ;размер терминала в строках (делается из имени пайпа типа "a33")
        pop bc ;b=handle
;b=new pipe handle
        ret

BDOS_number_to_fil
;b = file handle = 0..
;out: de=fil
        inc b
        ld hl,ffilearray-FIL_sz
        ld de,FIL_sz
BDOS_number_to_fil0
        add hl,de
        djnz BDOS_number_to_fil0
        ex de,hl
        ret
        
BDOS_closehandle
;B = file handle
;out: A=error
        bit 7,b
        jr nz,BDOS_closehandle_pipe
        bit 6,b
        jr nz,BDOS_closehandle_noFATFS
        call BDOS_number_to_fil
;de=fil
        F_CLOS_CURDRV
        ret
BDOS_closehandle_noFATFS
        ld h,b
        ld l,0
        BDOSSETPGTRDOSFS
        jp trdos_fclose_hl

BDOS_closehandle_pipe
;B = file handle
        inc b
        ret z ;0xff=rnd
        ld hl,freepipes-1-PIPEADD80
        ld c,b
        xor a
        ld b,a
        add hl,bc
        dec (hl)
        ret p
        inc (hl) ;чтобы терминал не думал, а закрывал оба пайпа дважды
        ret
freepipes
        ds MAXPIPES
pipeowners
        ds MAXPIPES
pipetypes ;пока тут размер терминала в строках, делается из имени пайпа
        ds MAXPIPES

BDOS_readwritehandleprepare
;b=handle, hl=number of bytes, de=addr
;out: hl=fil, de=number of bytes, bc=addr(0x8000+)
        push hl ;Number of bytes to read
        push de ;Buffer address
        call BDOS_number_to_fil ;de=fil
        ex de,hl ;hl=FIL
        pop de ;Buffer address
        call BDOS_preparedepage
         call BDOS_setdepage ;TODO убрать в драйвер (или уже убрано?)
        ld b,d
        ld c,e
        pop de ;Number of bytes to read
        ret
        
BDOS_readhandle
;B = file handle 
;DE = Buffer address
;HL = Number of bytes to read
;out: HL = Number of bytes actually read, A=error
        dec hl
         ld a,h
        inc hl
         cp 0x40
         jr c,BDOS_readhandlego
        push hl
        ld hl,BDOS_readhandlego
BDOS_readwritehandle
        ld (BDOS_readwritehandle_proc),hl
        pop hl
        ld (BDOS_readwritehandle_oldaddr),de
BDOS_readwritehandle0
        push bc
        push hl
        push de ;addr
         dec hl
         ld a,h
         inc hl
         cp 0x40
         jr c,$+5 ;<=0x4000
         ld hl,0x4000
         push hl ;bytes to process
        ;call BDOS_readwritehandlego ;hl=processed bytes
BDOS_readwritehandle_proc=$+1
        call BDOS_readhandlego
;TODO что делать, если возвратилось hl==0 или a!=0?
        ;ex af,af' ;error
         pop bc ;bytes to process
         or a
         sbc hl,bc
         ld a,h
         or l
         add hl,bc ;z=all bytes were processed
        ld b,h
        ld c,l
        pop hl ;addr
        add hl,bc ;+processed bytes
        ex de,hl ;de = new addr
        pop hl
        or a
        sbc hl,bc ;-processed bytes
        pop bc
        jr z,BDOS_readwritehandleq ;0 bytes remain
        jr c,BDOS_readwritehandleq ;less than 0 bytes remain
        ;jr nc,BDOS_readwritehandle0 ;no less than 0 bytes remain
         or a
        jr z,BDOS_readwritehandle0 ;all bytes were processed
BDOS_readwritehandleq
;0 bytes remain
;de=end address
        ld h,d
        ld l,e
BDOS_readwritehandle_oldaddr=$+1
        ld bc,0
        xor a ;no error
        sbc hl,bc ;hl=processed bytes
        ;ex af,af' ;error
        jr BDOS_readhandle_errorfromEOF ;ret
;BDOS_readwritehandlego
;BDOS_readwritehandle_proc=$+1
;        jp BDOS_readhandlego
BDOS_readhandlego
;b=handle
        bit 7,b
        jr nz,BDOS_readhandle_pipe
        bit 6,b
        jr nz,BDOS_readhandle_noFATFS
        call BDOS_readwritehandleprepare
;hl=fil, de=number of bytes, bc=addr(0x8000+)
	ld ix,fres
        push ix ;fres
        push de ;blocksize
	ex de,hl;ld de,ffile
	F_READ_CURDRV
	pop bc
        pop bc ;fres
        ld hl,(fres) ;hl=total processed bytes
BDOS_readhandle_errorfromEOF
        ;xor a ;no error
         ld a,h
         or l
         ld a,0
         ret nz
         dec a
        ret
BDOS_readhandle_noFATFS
        push bc
        BDOSSETPGTRDOSFS
        pop bc
        jp trdos_fread_b ;hl=total processed bytes, A=error

BDOS_writehandle
;B = file handle
;DE = Buffer address
;HL = Number of bytes to write
;out: HL = Number of bytes actually written, A=error
         ld a,h
         cp 0x40
         jr c,BDOS_writehandlego
        push hl
        ld hl,BDOS_writehandlego
        jr BDOS_readwritehandle
BDOS_writehandlego
;B = file handle
;DE = Buffer address
;HL = Number of bytes to write <= 0x4000
;out: HL = Number of bytes actually written, A=error
        bit 7,b
        jp nz,BDOS_writehandle_pipe
        bit 6,b
        jr nz,BDOS_writehandle_noFATFS
        call BDOS_readwritehandleprepare
	ld ix,fres
        push ix ;fres
        push de ;blocksize
	ex de,hl;ld de,ffile
	F_WRITE_CURDRV
	pop bc
        pop bc ;fres
        ld hl,(fres) ;hl=total processed bytes
        xor a ;a=0: no error
        ret
BDOS_writehandle_noFATFS
        push bc
        BDOSSETPGTRDOSFS
        pop bc
        jp trdos_fwrite_b ;hl=total processed bytes, a=0: no error

BDOS_readhandle_pipe
;B = file handle
;DE = Buffer address
;HL = Number of bytes to write <= 0x4000
;out: HL = Number of bytes actually written, A=error
;TODO check EOF (input closed)
        push bc
        call BDOS_preparedepage
        call BDOS_setdepage
        pop af ;a=handle
        cp 0xff
        jr nz,BDOS_readhandle_pipe_nrnd
        ld a,r
        ld (de),a
        ld hl,1
        xor a ;no error
        ret
BDOS_readhandle_pipe_nrnd
;a = PIPEADD80+pipeindex
         ld (BDOS_readhandle_pipe_handle),a
        call findpipe_byhandle ;out: hl=pipebuf, a=pipe# ;bc=number of bytes
        ld bc,pipeowners
        add a,c
        ld c,a
        jr nc,$+3
        inc b
        ld a,(iy+app.id)
        ld (bc),a ;pipe owner - это адресат (чтобы его будить)
;читаем из текущей головы столько байт, сколько есть, но не больше number of bytes
;пока делаем, что вся очередь лежит в начале (не атомарно)
         ld (BDOS_readhandle_pipe_addr),hl
        ld a,(hl) ;cur_size
        inc hl
       push hl ;buf start
        ld l,a
        ld h,0
        call minhl_bc_tobc ;to_user_size=bc<=hl
       pop hl ;buf start
;
        ex af,af' ;'
        ld a,b
        or c
        jr z,BDOS_readhandle_pipe_empty
        ex af,af' ;'
       push bc ;to_user_size
        ldir ;to user
       pop bc ;to_user_size
        ex de,hl
        ld l,a
        xor a
        ld h,a
       push bc ;to_user_size
;bc=cur_size-to_user_size
        sbc hl,bc
        ld b,h
        ld c,l
        ex de,hl
BDOS_readhandle_pipe_addr=$+1
        ld de,0
         ld a,c
         ld (de),a
         inc de
        jr z,$+4
        ldir ;на начало очереди
       pop hl ;to_user_size ;возвращаем, сколько реально прочитано
        xor a ;no error
        ret
BDOS_readhandle_pipe_empty
;проверяем, что нет EOF (т.е. не закрыла пишущая сторона)
        ld hl,freepipes-PIPEADD80
BDOS_readhandle_pipe_handle=$+1
        ld bc,0 ;PIPEADD80+pipeindex
        add hl,bc
        ld a,(hl) ;2=both sides open, 1=one side closed
        sub 2 ;a=error
        ld h,b
        ld l,b ;0 ;возвращаем, сколько реально прочитано
        ret
        
findpipe_byhandle
;hl=number of bytes
;out: hl=pipebuf, a=pipe#, bc=oldhl
        sub PIPEADD80
        ld b,a
        inc b
        push hl ;number of bytes
        push de ;user space
        ld de,PIPEDESC_SZ
        ld hl,pipebufs-PIPEDESC_SZ
        add hl,de
        djnz $-1
        pop de ;user space
        pop bc ;bc=number of bytes
        ret

BDOS_writehandle_pipe
;b=handle, hl=number of bytes, de=addr
        push bc
        call BDOS_preparedepage
        call BDOS_setdepage
        pop af ;a=handle
        cp 0xff
        ret z ;rnd - fail
;a = PIPEADD80+pipeindex
         ld (BDOS_writehandle_pipe_handle),a
        call findpipe_byhandle ;out: hl=pipebuf, a=pipe# ;bc=number of bytes ;keep de
;включить адресату пайпа (он крутится в YIELD) возможность принять сообщение сразу
        push bc
        push de
        ld bc,pipeowners
        add a,c
        ld c,a
        jr nc,$+3
        inc b
        ld a,(bc)
        ld e,a ;pipe owner
        call BDOS_findapp ;iy=found app ;keep hl
        ;set factive,(iy+app.flags)
        ld a,(sys_timer) ;ok
        dec a
        ld (iy+app.lasttime),a
        pop de
        pop bc
;добавляем в текущий хвост столько байт, сколько есть, но чтобы не превысило размер буфера
;пока делаем, что вся очередь лежит в начале (не атомарно)
         ld (BDOS_writehandle_pipe_addr),hl
        ld a,(hl) ;cur_size
        inc hl
        push af
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        pop af
        push hl ;tail
        ld hl,PIPEBUF_SZ
        push bc ;bc=number of bytes
        ld c,a
        xor a
        ld b,a
        sbc hl,bc ;оставшееся место в буфере
        pop bc ;bc=number of bytes
        call minhl_bc_tobc ;from_user_size=bc<=hl
BDOS_writehandle_pipe_addr=$+1
         ld hl,0
         ld a,(hl) ;cur_size
         add a,c ;from_user_size
         ld (hl),a ;cur_size
        ex de,hl ;hl=user space
        pop de ;tail
        ld a,b
        or c
        jr z,BDOS_readhandle_pipe_full
        push bc ;from_user_size
        ldir ;from user
        pop hl ;from_user_size ;возвращаем, сколько реально записано
        xor a ;no error
        ret
BDOS_readhandle_pipe_full
;проверяем, что не закрыла читающая сторона
        ld hl,freepipes-PIPEADD80
BDOS_writehandle_pipe_handle=$+1
        ld bc,0 ;PIPEADD80+pipeindex
        add hl,bc
        ld a,(hl) ;2=both sides open, 1=one side closed
        sub 2 ;a=error
        ld h,b
        ld l,b ;0 ;возвращаем, сколько реально записано
        ret
        
minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret


BDOS_fopen_getname_fil
;out: de=poi to FIL, bc=mfil
        push de
	call get_name ;->mfil
        pop de
        call findfreeffile
         jr nz,$ ;TODO error
        ex de,hl ;de=poi to FIL
	LD bc,mfil
        jp nz,BDOS_pop2fail ;снимаем адрес возврата и FCB
        ret
        
BDOS_fopen
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;de = pointer to unopened FCB
        GETVOLUME
        ld (de),a ;volume
        cp vol_trdos ;CHECKVOLUMETRDOS
        jr c,BDOS_fopen_noFATFS
        push de ;FCB
        call BDOS_fopen_getname_fil ;de=poi to FIL, bc=mfil
	LD HL,FA_READ|FA_WRITE
        jr BDOS_fopen_go
BDOS_fopen_noFATFS
;a=drive
       push af
        BDOSSETPGTRDOSFS
       pop af
        jp trdos_fopen

BDOS_fcreate
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to unopened FCB
        GETVOLUME
        ld (de),a ;volume
        cp vol_trdos ;CHECKVOLUMETRDOS
        jr c,BDOS_fcreate_noFATFS
        push de ;FCB
        call BDOS_fopen_getname_fil ;de=poi to FIL, bc=mfil
	LD HL,FA_READ|FA_WRITE|FA_CREATE_ALWAYS
BDOS_fopen_go
	;F_OPEN ffile,mfil,FA_READ|FA_WRITE|FA_CREATE_ALWAYS
       	;LD de,ffile
        push de ;FIL
        F_OPEN_CURDRV
        pop de ;FIL
        pop bc ;FCB
        or a
        ret nz ;error
;BDOS_fopen_OK
;de=ffile (FIL)
;bc=FCB
        ;ld iy,(appaddr)
        ;GETVOLUME
        ;ld (bc),a ;volume
        ld hl,FCB_FFSFCB
        add hl,bc
	push af
        call BDOS_setdepage
	pop af
        ld (hl),e
        inc hl
        ld (hl),d
	ret
BDOS_fcreate_noFATFS
       push af
        BDOSSETPGTRDOSFS
       pop af
        jp trdos_fcreate

getFILfromFCB
;de=FCB (страницы уже включены)
;out: hl=FIL
        ld hl,FCB_FFSFCB
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl = poi to FIL
        ret
        
BDOS_fclose
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to opened FCB (для FATFS придётся игнорировать, брать текущий ffile - TODO искать подходящий ffile)
        ;CHECKVOLUMETRDOS
        ld a,(de)
        cp vol_trdos
        jr c,BDOS_fclose_noFATFS
	;F_CLOSE ffile ;сам освобождает FIL
        call getFILfromFCB
        ex de,hl
        F_CLOS_CURDRV
;TODO убрать poi to FIL из FCB?
	;or a:jp z,fexit
	;ld a,0xff
	ret;jp fexit
BDOS_fclose_noFATFS
        BDOSSETPGTRDOSFS
        jp trdos_fclose


call_ffs_curvol
		GETVOLUME
call_ffs	;A=логический раздел, HL=функция 
;портит iy! но нельзя двигать стек! в нём параметры!
		push hl
		push bc
        ld hl,fatfsarray ;вычисляем указатель на структуру fatfs
		sub vol_trdos
        ;or a
        jr z,.fix_vol_dir
        ld bc,FATFS_sz
.calcfatfs
        add hl,bc
        dec a
        jr nz,.calcfatfs
.fix_vol_dir	;устанавливаем текущие fatfs и директорию
		BDOSSETPGFATFS
        ld (fatfs_org+FFS_DRV.curr_fatfs),hl
         ld l,(iy+app.dircluster)
         ld h,(iy+app.dircluster+1)
        ld (fatfs_org+FFS_DRV.curr_dir0),hl
         ld l,(iy+app.dircluster+2)
         ld h,(iy+app.dircluster+3)
        ld (fatfs_org+FFS_DRV.curr_dir2),hl
		call BDOS_setpgstructs	
		pop bc
		ret		;уходим в фатфс

		
BDOS_mount
;e=logical volume(char A-Z)
;out: a!=0 => not mounted
		ld a,e
		and 0xdf
		sub 'A'
		ret c
		cp 26
		ret nc
		sub vol_trdos
        jr c,.noFATFS
		ld e,a
        BDOSSETPGFATFS
		call BDOS_setpgstructs
        ld hl,fatfsarray ;вычисляем указатель на структуру fatfs
        ld a,e
		or a
        jr z,.fix_ffs
        ld bc,FATFS_sz
.calcfatfs
        add hl,bc
        dec a
        jr nz,.calcfatfs
.fix_ffs
        ld (fatfs_org+FFS_DRV.curr_fatfs),hl ;l
		inc hl
		ld a,e
		cp 8
		jr c,.isHDD
		sub 6
		ld (hl),a	;номер драйва
		xor a
		jr .f_mnt
.isHDD		
		srl e
		srl e
		ld (hl),e	;номер драйва
		and %00000011
.f_mnt
		inc hl
		ld (hl),a	;номер раздела
		F_MNT
		ret
.noFATFS
        xor a ;xor a ;NC:success, CY:fail
        ret;jr rest_exit
BDOS_setsysdrv
SYSDRV_VAL=$+1
        ld e,SYSDRV
         call BDOS_setdrv
         ld de,syspath
         jp setpath ;NB! uses strcpy_usp2lib -> BDOS_setdepage without BDOS_preparedepage

BDOS_preparereadwritesectors_FATFS
        sub vol_trdos ;получаем физический номер устройства (HDD master, HDD slave, SD...)
        push af
        BDOSSETPGFATFS
	call BDOS_setdepage
        pop af
        push ix
        pop bc
        ex de,hl ;bcde=sector number, hl=buffer
;hl=buffer
;a=drive
;bcde=sector
;a'=count
        ret
 
BDOS_preparereadwritesectors_TRDOSFS
         push af
        BDOSSETPGTRDOSFS
         pop af
        ld (trdoscurdrive),a
        ld a,l
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ex de,hl ;hl=buffer, d=track
        and 0x0f
        ld e,a ;e=sector
        ex af,af' ;'
        ld b,a ;count
;hl=buffer
;d=track
;e=sector
;b=count
        ret

BDOS_readsectors
;b=drive(0..), de=buffer, ixhl=sector number, a'=count
;передавать логический volume (букву) и пересчитать в номер драйвера (в смещение раздела, наверно, бессмысленно)?
        push bc
        call BDOS_preparedepage
        call BDOS_setdepage
        pop af
        cp vol_trdos
        jr c,BDOS_readsectors_TRDOS
        call BDOS_preparereadwritesectors_FATFS
        jp devices_read_go_regs
BDOS_readsectors_TRDOS
        call BDOS_preparereadwritesectors_TRDOSFS
        jp rdsectors. ;out: a=error?

BDOS_writesectors
;b=drive(0..), de=buffer, ixhl=sector number, a'=count
;передавать логический volume (букву) и пересчитать в номер драйвера (в смещение раздела, наверно, бессмысленно)?
        push bc
        call BDOS_preparedepage
        call BDOS_setdepage
        pop af
        cp vol_trdos
        jr c,BDOS_writesectors_TRDOS
        call BDOS_preparereadwritesectors_FATFS
        jp devices_write_go_regs
BDOS_writesectors_TRDOS
        call BDOS_preparereadwritesectors_TRDOSFS
        jp wrsectors. ;out: a=error?
 
BDOS_setdrv
;e=volume
;out: a!=0 => not mounted (TODO), [l=number of volumes]
;мы не должны монтировать, просто должны указать volume, текущий для данной задачи, и сбросить path, текущий для данной задачи
        ld a,e
        ;call BDOS_setvol_rootdir
        ;call BDOS_opencurdir ;эта операция нужна для определения смонтированности (F_MNT всегда возвращает 0)
        ;or a
        ;jr nc,BDOS_setdrvnfail
        ; ld (iy+app.vol),d
;BDOS_setdrvnfail
         
        ;ld l,NVOLUMES ;доступно 8 драйвов???
        ;xor a ;success
        ;ret;jr rest_exit
        
;BDOS_setvol_rootdir
;установлена страница PGFATFS
          ld d,(iy+app.vol)
         ld (iy+app.vol),a
;BDOS_setrootdir
;не установлена страница PGFATFS
;CY=error (при NC a=0) - TODO убрать?
         xor a
         ld h,a
         ld l,a
         call writedircluster_hl
         ;ld (iy+app.dircluster),a
         ;ld (iy+app.dircluster+1),a
         ld (iy+app.dircluster+2),a
         ld (iy+app.dircluster+3),a
        CHECKVOLUMETRDOS
        push de
        ;sbc a,a; ld a,0
        jr c,BDOS_setrootdir_trdos ;ret c ;NC=no error, A=0
		ld bc,0 ; TCHAR *path	/* Pointer to the directory path */
        call BDOS_opencurdir ;эта операция нужна для определения смонтированности (F_MNT всегда возвращает 0)
BDOS_setrootdir_q
        pop de
        or a
        ret z ;NC=no error, A=0
         ld (iy+app.vol),d
         scf
        ret ;CY=error
BDOS_setrootdir_trdos
	push af
        BDOSSETPGTRDOSFS
	pop af
	call iodos_setdrive
	;ld a,(eRR2) ;0=OK, 0xff=Abort
	jr BDOS_setrootdir_q
        
BDOS_delete
;DE = Drive/path/file ASCIIZ string
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to ASCIIZ string
        call countfiledrive ;a=volume, de=path without drive, c=1: drive in path, CY=TR-DOS
        ;call eatdrive ;TODO keep and restore curdrv,curdir!!!
        jr c,BDOS_delete_nofatfs
        ;call keepvoldir
        ; dec c ;was c=1: drive in path
        ; push de
        ; call z,BDOS_setvol_rootdir ;drive specified in path
        ; pop de
	F_UNLINK
	ret        
BDOS_delete_nofatfs
        BDOSSETPGTRDOSFS
        jp trdos_delete
        
BDOS_rename
;DE = Drive/path/file ASCIIZ string, HL = New filename ASCIIZ string (can contain drive/path! NOT MSXDOS)
        ex de,hl
        call BDOS_preparedepage ;TODO разные страницы hl,de (т.е. надо копировать отсюда в буфер)
        call BDOS_setdepage ;TODO убрать в драйвер
        ex de,hl
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        CHECKVOLUMETRDOS
        jr c,BDOS_rename_nofatfs
        ld b,h
        ld c,l
;DE = Drive/path/file ASCIIZ string, BC = New filename ASCIIZ string
        F_RENAME
        ret
BDOS_rename_nofatfs
        BDOSSETPGTRDOSFS
        jp trdos_rename

countfiledrive
;DE = Drive/path/file ASCIIZ string
;out: a=volume, de=path without drive, c=1: drive in path, CY=TR-DOS
        inc de
        ld a,(de)
        cp ':'
        dec de
         ld c,0
        ;push af ;z=drive in path
        GETVOLUME
        jr nz,BDOS_openhandle_nodriveinpath ;drive not specified in path
         ld a,(de)
         and 0xdf
         sub 'A'
         inc de
         inc de
        ;cp a ;z
         inc c
BDOS_openhandle_nodriveinpath
;a=volume, de=path without drive, c=1: drive in path
        cp vol_trdos
        ret
        
BDOS_mkdir
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to ASCIIZ string
        call countfiledrive ;call eatdrive
        jp c,BDOS_fail
;DE = Pointer to ASCIIZ string
        ;call keepvoldir
        ; dec c ;was c=1: drive in path
        ; push de
        ; call z,BDOS_setvol_rootdir ;drive specified in path
        ; pop de
        F_MKDIR
        ret
		
BDOS_chdir
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to ASCIIZ string

setpath
;установлена страница PGFATFS
;DE = Pointer to ASCIIZ string
        call countfiledrive ;call eatdrive
        jr c,BDOS_chdir_trdos
        push af
        ; dec c ;was c=1: drive in path
        ; call z,BDOS_setvol_rootdir ;drive specified in path
        F_CHDIR
        pop hl
        or a
        ret nz
		ld (iy+app.vol),h
         ld hl,(fatfs_org+FFS_DRV.curr_dir2)
         ld (iy+app.dircluster+2),l
         ld (iy+app.dircluster+3),h
		 ;xor a
         ld hl,(fatfs_org+FFS_DRV.curr_dir0)
         ;ld (iy+app.dircluster),l
         ;ld (iy+app.dircluster+1),h
         ;ret
writedircluster_hl
        ld (iy+app.dircluster),l
        ld (iy+app.dircluster+1),h
        ret
        
BDOS_chdir_trdos
		ld (iy+app.vol),a
                xor a
        ;ld a,(de) ;путь пустой?
        ;or a
        ;jp nz,BDOS_fail ;непустой
        ret

	if 1==0
strlen
;hl=str
;out: hl=length
        xor a
	ld b,a
	ld c,a ;bc=0 ;чтобы точно найти терминатор
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        ;or a
        sbc hl,bc
        ret
	endif

;GET WHOLE PATH STRING (5EH)
;     Parameters:    C = 5EH (_WPATH) 
;                   DE = Pointer to 64 byte (MAXPATH_sz!) buffer
;     Results:       A = Error
;                   DE = Filled in with whole path string
;                   HL = Pointer to start of last item 
;This function simply copies an ASCIIZ path string from an internal buffer into the user's buffer. The string represents the whole path and filename, from the root ;directory, of a file or sub-directory located by a previous "find first entry" or "find new entry" function. [MSXDOS: The returned string will not include a drive, or an; ;initial "\" character.] Register HL will point at the first character of the last item on the string, exactly as for the "parse path" function (function 5Bh).
;in NedoOS: DRIVE:/PATH/ !!!
BDOS_getpath
        push de ;нельзя после BDOS_preparedepage
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        push de ;DE = Pointer to 64 byte (MAXPATH_sz!) buffer (0x8000+/0xc000+!)

        push de ;Pointer to 64 byte (MAXPATH_sz!) buffer (0x8000+/0xc000+!)
        
        GETVOLUME
        add a,'A'
        ex de,hl
        ld (hl),a
        inc hl
        ld (hl),':'
        inc hl
        ld (hl),'/'
        inc hl
        ld (hl),0
        cp vol_trdos+'A'
        jr c,BDOS_getpath_FATq
        ex de,hl
BDOS_getpath_FAT
        ;DE=TCHAR *path,	/* Pointer to the directory path */ буфер
        ld bc,MAXPATH_sz;64 ;BC=UINT sz_path	/* Size of path */) размер буфера 
        F_GETCWD_CURDRV
BDOS_getpath_FATq
        pop hl ;Pointer to 64 byte (MAXPATH_sz!) buffer (0x8000+/0xc000+!)
        call findlastslash. ;NC!!!
        ex de,hl ;HL = Pointer to start of last item (0x8000+/0xc000+!)
        
        pop de ;DE = Pointer to 64 byte (MAXPATH_sz!) buffer (0x8000+/0xc000+!)
        ;or a
        sbc hl,de ;hl=расстояние до последнего слэша
        pop de ;DE = Pointer to 64 byte (MAXPATH_sz!) buffer
        add hl,de ;HL = Pointer to start of last item
        ret

;hl = poi to filename in string
findlastslash.
;hl=path string
;out: de = after last slash (or start of path) ;NC!!!
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
;find last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	ret z;jr z,nfopenfnslashq. ;NC!!!
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.
 
;PARSE FILENAME (5CH) - MSX-DOS
;     Parameters:    C = 5CH (_PFILE) 
;                   DE = ASCIIZ string for parsing
;                   HL = Pointer to 11 byte buffer
;     Results:       A = Error (always zero)
;                   DE = Pointer to termination character
;                   HL = Preserved, buffer filled in
;                    B = Parse flags (TODO)
;b0 - set if any characters parsed other than drive name
;b1 - set if any directory path specified
;b2 - set if drive name specified
;b3 - set if main filename specified in last item
;b4 - set if filename extension specified in last item
;b5 - set if last item is ambiguous
;b6 - set if last item is "." or ".."
;b7 - set if last item is ".."
BDOS_parse_filename
        BDOSSETPGTRDOSFS
;делает из имени с точкой имя без точки (для CP/M)
        push hl ;Pointer to 11 byte buffer

        push de ;ASCIIZ string for parsing
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        push de ;ASCIIZ string for parsing (0x8000+/0xc000+)
        ld hl,BDOS_parse_filename_cpmnamebuf
        call dotname_to_cpmname ;de -> hl
        ex de,hl ;de=Pointer to termination character (0x8000+/0xc000+)
        pop bc ;ASCIIZ string for parsing (0x8000+/0xc000+)
        or a
        sbc hl,bc ;hl=расстояние до терминатора
        pop bc ;ASCIIZ string for parsing
        add hl,bc ;Pointer to termination character

        pop de ;Pointer to 11 byte buffer
        push hl ;Pointer to termination character

        push de ;Pointer to 11 byte buffer
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        ld hl,BDOS_parse_filename_cpmnamebuf
        ld bc,11
        ldir
        pop hl ;HL = Pointer to 11 byte buffer

        pop de ;DE = Pointer to termination character
        xor a
        ret

get_name
;делает из имени без точки имя с точкой (для FATFS и для печати)
;de(FCB)->hl
	inc de
	ex hl,de
	ld de,mfil
get_name_hltode
	ld b,7
	ld a,' '
get_name1
	ldi
	cp (hl)
        jr z,get_name_skipspaces
	djnz get_name1
        ldi
        jr get_name_findext ;скопировали 8 символов, пробел не нашли
get_name_skipspaces
	inc hl
	djnz $-1;1b ;пропускаем оставшиеся пробелы
get_name_findext
	cp (hl)
	jr z,get_name1f ;на месте расширения пробел - не ставим точку
	ex hl,de
	ld (hl),'.'
	inc hl
	ex hl,de
	ldi
	cp (hl)
	jr z,get_name1f
	ldi
	cp (hl)
	jr z,get_name1f
	ldi
get_name1f
	xor a
        ld (de),a
	ret

findfreeffile
;out: nz=fail, hl=FIL, b=fil number
        call BDOS_setpgstructs
        ld hl,ffilearray
        ld de,FIL_sz
        ld b,0
findfreeffile0
        inc hl
        ld a,(hl) ;FS(HSB)
        dec hl
        or a
        ret z ;OK
        add hl,de
        inc b
        ;ld a,b
        ;cp MAXFILES
        ;jr nz,findfreeffile0
        ;or a ;nz
         ld a,MAXFILES-1
         cp b
         jr nc,findfreeffile0
         ;or a ;nz
        ret
        
movedma_addr
        ld iy,(appaddr)
        ;ld hl,(dma_addr) ;оригинальный, не пересчитанный адрес
        call BDOS_getdta
        ex de,hl
        add hl,bc
        ex de,hl
        ;ld (dma_addr),hl
        ;ret
BDOS_setdta
        ld (iy+app.dta),e
        ld (iy+app.dta+1),d
        ;ret
BDOS_getdta
        ld e,(iy+app.dta)
        ld d,(iy+app.dta+1)
        ret
        
;получить конфиг железа
BDOS_get_config
    ld a,(SYSDRV_VAL)
    ld h,a
    ifdef KOE
        ld l,0x06
    else
        ld l,atm
    endif
    ld a,(sys_pgdos)
    ld d,a
    ld e,pgsys
    ret
        
;*****************НЕДОКУМЕНТИРОВАННЫЕ*********************
;вызов функции DE с картой керналя.
BDOS_reserv_1
    di
        call BDOS_preparedepage
        call BDOS_setdepage
        ex de,hl
        ld a,pgsys
        jp (hl)

;***********************ЗАГЛУШКИ**************************	

;копирование строки из\в юзерспейса в\из либу фатфс
strcpy_lib2usp	;DE - dst, BC - src
strcpy_usp2lib
	push bc
	call BDOS_setdepage
	pop bc
strcpy_lib2usp0
	ld a,(bc)
	ld (de),a
	inc de
	inc bc
	or a
	jr nz,strcpy_lib2usp0
        ;BDOSSETPGFATFS
	;jp BDOS_setpgstructs
BDOS_setpgstructs
	ld a,pgfatfs2
        jr sys_setpgc000

setmainpg_c000
        ld a,(iy+app.mainpg)
        jr sys_setpgc000

sys_setpgsscr
        ld a,(iy+app.screen)
	bit 3,a
        ld a,pgscr0_0
	jr z,$+4
        ld a,pgscr1_0
        ;ld bc,memport8000
        ;out (c),a
        call sys_setpg8000
        xor pgscr0_1^pgscr0_0 ;ld a,pgscr0_1
        ;ld b,memportc000_hi;0xff
        ;out (c),a
        jr sys_setpgc000

setpgs_killable
        ld a,pgkillable
        ld bc,memport4000
        ld (sys_curpg4000),a
        out (c),a
        ;ld b,memport8000_hi;0xbf
        ;out (c),a
        ;ld b,memportc000_hi;0xff
        ;out (c),a
        ;ret
        call sys_setpg8000
sys_setpgc000
        ld (sys_curpgc000),a
        ld bc,memportc000
        out (c),a
        ret

;копирование в\из юзерспейса в\из структуру
memcpy_buf2usp	;DE - dst, BC - src, на стеке count
	res 7,b ;src=buf
	jr memcpy_buf_go
memcpy_usp2buf
	res 7,d ;dst=buf
memcpy_buf_go
	push bc
        ld a,pgfatfs2;=pgstructs
	call sys_setpg4000
	pop bc
	jr memcpy_loop
;копирование в\из юзерспейса в\из либу фатфс
memcpy_lib2usp	;DE - dst, BC - src, на стеке count
memcpy_usp2lib
memcpy_loop
	push bc
	call BDOS_setdepage
	pop hl;bc
	;ld h,b
	;ld l,c
	pop af
	pop bc
	push bc
	push af
	ldir
        BDOSSETPGFATFS ;4000
	jp BDOS_setpgstructs

;по числу драйвов FatFS (для TR-DOS не надо)
fatfsarray=0xc000
	;display "fatfsarray=",fatfsarray
        ;ds 4*FATFS_sz

ffilearray=fatfsarray+(13*FATFS_sz)
        display "ffilearray_end=",ffilearray+(MAXFILES*FIL_sz)
        ;ds MAXFILES*FIL_sz
        ;dw 0x100 ;признак конца ffilearray
        
mfil    db "12345678.123",0 ;нужно только на время операции, которая принимает имя файла (может быть с путём?)

mfilinfo ds FILINFO_sz ;FILINFO ;нужно только на время findnext

fcb2    ds FCB_sz ;нужно только на время findnext

fres	dw 0 ;структура для возврата результата FatFS (число прочитанных/записанных байт)
        dw 0 ;для возврата даты

syspath
        db "bin",0
        
;для TASiS: не используются страницы ОЗУ 0x00, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F
;для избежания гибернации: не используются страницы ОЗУ 128K
tsys_pages
        ifdef FREEPG0
        db 0
        else
        db 0xff
        endif
        ds 3,0xff ;системные страницы 128K: 1,2,3
        ifdef FREEPG4
        db 0
        else
        db 0xff
        endif
        db 0xff ;pg5
        ifdef FREEPG6
        db 0
        else
        db 0xff
        endif
        db 0xff ;pg7
;;;;;;;;;;
        if TOPDOWNMEM
        db 0,0,0,0
        else
        db 0xff,0xff,0xff,0xff ;системные страницы
        endif
        db 0,0,0,0 ;0x08..0x0f
        db 0,0,0,0,0,0,0,0 ;0x10..0x17
        db 0,0,0 ;0x18..0x1a
        ifdef ATMRESIDENT
        db 0xff,0xff,0xff,0xff,0xff ;0x1b..0x1f for resident
        else
        db 0,0,0,0,0 ;0x1b..0x1f
        endif
      dup sys_npages-32-4
_=$-tsys_pages
_wrongpg=0
       ifdef KEEPPG38
        if (_ == 0x38)
_wrongpg=0xff
        endif
       endif
       ifdef KOE
        if (_ >= (64+8)) && (_ <= (64+12)) ;TODO ramdisk тоже?
_wrongpg=0xff
        endif
       endif
       db _wrongpg ;0 ;0=empty, or else process number
      edup
        if TOPDOWNMEM
        db 0xff,0xff,0xff,0xff ;системные страницы
        else
        db 0,0,0,0
        endif

pipebufs
        ds PIPEDESC_SZ*MAXPIPES
