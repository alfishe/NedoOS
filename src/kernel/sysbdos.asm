
;NVOLUMES=8
MAXFILES=8
vol_trdos=4

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
	jr BDOS_setpg4000
        ;ld bc,memport4000
        ;ld (sys_curpg4000),a
        ;out (c),a
        ;ret

BDOS_setpgfatfs
        ld a,pgfatfs
BDOS_setpg4000
        ld bc,memport4000
        ld (sys_curpg4000),a ;для sys_sysint
        out (c),a
        ret

blocksize=128 ;сколько байтов читать в CP/M операциях

setmainpg_c000
        ld a,(iy+app.mainpg)
        ld bc,memportc000
        out (c),a
        ret

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
        ld (muzpg),a
        ld (muzcall),hl
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

BDOS_getscreenpages
;out: de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld de,pgscr0_1*256+pgscr0_0
        ld hl,pgscr1_1*256+pgscr1_0
        ;xor a
        ret

BDOS_getappmainpages
;e=id
;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, a=error
        call BDOS_findapp
        jp nz,BDOS_fail
BDOS_getmainpages
        ;ld iy,(appaddr)
;out: dehl=номера страниц в 0000,4000,8000,c000, c=flags
BDOS_getmainpages_iy
        call setmainpg_c000
        ld d,a
        ld a,(curpg16k+0xc000)
        ld e,a
        ld a,(curpg32klow+0xc000)
        ld hl,(curpg32khigh+0xc000)
        ld h,a
        ld c,(iy+app.flags)
        xor a
        ret

BDOS_preparedepage
;de=userspace addr
;out: de>=0x8000, включены нужные страницы в 8000,c000
        ;ld iy,(appaddr)
        ld a,(iy+app.mainpg)
        ld bc,memport8000
        out (c),a
        bit 7,d
        jr nz,BDOS_preparedepage8000_c000
        bit 6,d
        jr nz,BDOS_preparedepage4000_8000
        set 7,d
	ld (depage8000),a
        ld a,(curpg16k+0x8000)
        ;ld bc,memportc000
        ;out (c),a
	ld (depagec000),a
        ret
BDOS_preparedepage4000_8000
        ld a,d
        add a,0x40
        ld d,a
        ld a,(curpg32klow+0x8000)
        ;ld bc,memportc000
        ;out (c),a
	ld (depagec000),a
        ld a,(curpg16k+0x8000)
        ;ld bc,memport8000
        ;out (c),a
	ld (depage8000),a
        ret
BDOS_preparedepage8000_c000
        ld a,(curpg32khigh+0x8000)
        ;ld bc,memportc000
        ;out (c),a
	ld (depagec000),a
        ld a,(curpg32klow+0x8000)
        ;ld bc,memport8000
        ;out (c),a
	ld (depage8000),a
        ret

BDOS_setdepage
;keep de,hl
depagec000=$+1
        ld a,0
        ld bc,memportc000
        out (c),a
depage8000=$+1
        ld a,0
        ld b,memport8000_hi
        out (c),a
	ret

BDOS_setpgstructs
	ld a,pgfatfs2
        ld bc,memportc000
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
        xor a
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
;портит только 0xc000+, но сама восстанавливает там pgkillable
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
         push hl
         ld hl,(appaddr)
         ld de,(focusappaddr)
         or a
         sbc hl,de
         pop hl
         jr nz,BDOS_prchar_skip
        ld de,pgscr0_1*256+pgscr0_0
        ld bc,memportc000
        out (c),d ;text
        ld (hl),a
        out (c),e ;attr
BDOS_prchar_skip        

        ld de,0x2000 + pgkillable
        
         push af

        ld a,h
        xor d;0x20 ;attr + 0x20
        ld h,a
        and d;0x20
        jr nz,$+3
        inc l

         pop af
         jr nz,BDOS_prchar_skipattr
;pr_textmode_curcolor=$+1
        ;ld (hl),7
        ld a,(iy+app.curcolor)
        ld (hl),a
        
        ;set 6,h ;attr -> next char

        ;ld e,pgkillable
        out (c),e ;pgkillable
BDOS_prchar_skipattr

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
        ld bc,memportc000
        out (c),a
        call BDOS_cllastline
        ld a,pgscr0_0 ;attr
        ld bc,memportc000
        out (c),a
        call BDOS_cllastline
        ld a,pgkillable
        ld bc,memportc000
        out (c),a
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
        ld bc,memportc000
        out (c),a
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
         push hl
         ld hl,(appaddr)
         ld bc,(focusappaddr)
         or a
         sbc hl,bc
         pop hl
         ret nz
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
         push hl
         ld hl,(appaddr)
         ld bc,(focusappaddr)
         or a
         sbc hl,bc
         pop hl
         ret nz
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
        ld a,(iy+app.gfxmode)
        and 7
        jr z,BDOS_cls_EGA
         cp 2 ;MC hires
         jr z,BDOS_cls_EGA ;TODO отдельную очистку для MC hires
;textmode
        ld a,e ;attr byte
        ld hl,0x81c0
        call BDOS_cls_textmode_ldir
        ld hl,0xa1c0
        call BDOS_cls_textmode_ldir
        
        ;ld de,0
        ld d,b
        ld e,b ;0
        call BDOS_setxy
        
        xor a
        ld hl,0xc1c0
        call BDOS_cls_textmode_ldir
        ld hl,0xe1c0
BDOS_cls_textmode_ldir
        ld d,h
        ld e,l
        inc de
        ld (hl),a
        ld bc,25*64-1
        ldir
        ret
BDOS_cls_EGA
        ld a,e
scrbase=0x8000
;чистим через стек, кроме первых байтов (иначе прерывание может запортить два байта перед экраном)
        ld (clssp),sp
        ld hl,scrbase+(200*40) ;чистим с конца, потому что прерывание портит стек
        ld b,200-1
clsline0
        ld d,a
        ld e,a
        ld sp,hl
        dup 20
        push de
        edup
        set 5,h
        ld sp,hl
        dup 20
        push de
        edup
        set 6,h
        ld sp,hl
        dup 20
        push de
        edup
        res 5,h
        ld sp,hl
        dup 20
        push de
        edup
        ;res 6,h
        ld de,-40-0x4000
        add hl,de
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

BDOShandler
        push hl
        ld a,c
        ld hl,tbdoscmds
        push bc
        ld bc,nbdoscmds
        cpir
        jp nz,BDOS_pop2fail
;bc=nbdoscmds-(cmdnumber+1) = 0..(nbdoscmds-1)
        add hl,bc
;hl=tbdoscmds+nbdoscmds
        add hl,bc
        add hl,bc
;hl=tbdoscmds+nbdoscmds+ 2*(nbdoscmds-(cmdnumber+1))
        pop bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ;hl=jump addr
        ex (sp),hl
        ret

tbdoscmds
         db CMD_PRATTR
         db CMD_SETXY
         db CMD_SETCOLOR
         db CMD_GETATTR
         db CMD_PRCHAR
         db CMD_WIZNETREAD
	db CMD_SETDTA;0x1a
	db CMD_FOPEN;0x0f
	db CMD_FREAD;0x14
	db CMD_FCLOSE;0x10
	db CMD_FDEL;0x13
	db CMD_FCREATE;0x16
	db CMD_FWRITE;0x15
        db CMD_FSEARCHFIRST;0x11
        db CMD_FSEARCHNEXT;0x12
        db CMD_SETDRV
	db CMD_PARSEFNAME;0x5c
        db CMD_CHDIR
        db CMD_GETPATH
        db CMD_GETKEYMATRIX
        db CMD_GETTIMER
        db CMD_YIELD
        db CMD_RUNAPP
        db CMD_NEWAPP
        db CMD_CLS
        db CMD_SETGFX
        db CMD_SETPAL
        db CMD_GETMAINPAGES
        db CMD_NEWPAGE
        db CMD_DELPAGE
        db CMD_SETSCREEN
        db CMD_GETSCREENPAGES
        db CMD_MOUNT
        db CMD_FREEZEAPP
        db CMD_WAITPID
        db CMD_MKDIR
        db CMD_RENAME
        db CMD_SETSYSDRV
        db CMD_FWRITE_NBYTES
        db CMD_SCROLLUP
        db CMD_SCROLLDOWN
        db CMD_OPENHANDLE
        db CMD_CREATEHANDLE
        db CMD_CLOSEHANDLE
        db CMD_READHANDLE
        db CMD_WRITEHANDLE
        db CMD_SEEKHANDLE
        db CMD_TELLHANDLE
        db CMD_SETFILETIME
        db CMD_GETFILETIME
        db CMD_GETTIME
        db CMD_GETXY
        db CMD_GETAPPMAINPAGES
        db CMD_DROPAPP
        db CMD_WIZNETOPEN
        db CMD_WIZNETCLOSE
        db CMD_WIZNETWRITE
        db CMD_GETFILESIZE
        db CMD_DELETE
        db CMD_SETWAITING
        db CMD_SETBORDER
        db CMD_READSECTORS
        db CMD_WRITESECTORS
        db CMD_SETMAINPAGE
        db CMD_SETMUSIC
nbdoscmds=$-tbdoscmds
        dw BDOS_setmusic
        dw BDOS_setmainpage
        dw BDOS_writesectors
        dw BDOS_readsectors
        dw BDOS_setborder
        dw BDOS_setwaiting
        dw BDOS_delete
        dw BDOS_getfilesize
        dw BDOS_wiznetwrite
        dw BDOS_wiznetclose
        dw BDOS_wiznetopen
        dw BDOS_dropapp
        dw BDOS_getappmainpages
        dw BDOS_getxy
        dw BDOS_gettime
        dw BDOS_getfiletime
        dw BDOS_setfiletime
        dw BDOS_tellhandle
        dw BDOS_seekhandle
        dw BDOS_writehandle
        dw BDOS_readhandle
        dw BDOS_closehandle
        dw BDOS_createhandle
        dw BDOS_openhandle
        dw BDOS_scrolldown
        dw BDOS_scrollup
        dw BDOS_fwrite_nbytes
        dw BDOS_setsysdrv
        dw BDOS_rename
        dw BDOS_mkdir
        dw BDOS_waitpid
        dw BDOS_freezeapp
        dw BDOS_mount
        dw BDOS_getscreenpages
        dw BDOS_setscreen
        dw BDOS_delpage
        dw BDOS_newpage
        dw BDOS_getmainpages
        dw BDOS_setpal
        dw BDOS_setgfx
        dw BDOS_cls
        dw BDOS_newapp
        dw BDOS_runapp
        dw BDOS_yield
        dw BDOS_gettimer
        dw BDOS_getkeymatrix
        dw BDOS_getpath
        dw BDOS_chdir
        dw BDOS_parse_filename
        dw BDOS_setdrv
        dw BDOS_fsearchnext
        dw BDOS_fsearchfirst
	dw BDOS_fwrite
	dw BDOS_fcreate
	dw BDOS_fdel
	dw BDOS_fclose
	dw BDOS_fread
	dw BDOS_fopen
        dw BDOS_setdta
         dw BDOS_wiznetread
         dw BDOS_prchar
         dw BDOS_getattr
         dw BDOS_setcolor
         dw BDOS_setxy
         dw BDOS_prattr
        
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
        ret
BDOS_getkeymatrix_fail
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
        ld hl,(sys_timer+2)
        ld de,(sys_timer)
         ld a,(sys_timer+2)
         sub l
         jr nz,BDOS_gettimerX ;для атомарности
        ret ;a=0
        
BDOS_yield
;регистры не сохраняем, т.к. нам не важно, что на выходе из yield
;но надо:
;взять адрес стека для выхода из CALLBDOS и записать его в ld sp на выходе из обработчика прерываний
;взять адрес возврата из CALLBDOS и записать его в jp на выходе из обработчика прерываний
        ;ld iy,(appaddr)
        
        if bdosstack_sz==0
        ld hl,(callbdos_sp)
        else
        ;ld l,(iy+app.callbdos_sp)
        ;ld h,(iy+app.callbdos_sp+1)
        exx
        endif

        call setmainpg_c000
        ld (intsp+0xc000),hl

        ex de,hl
        call BDOS_preparedepage
        call BDOS_setdepage
        ex de,hl
        
        ld e,(hl)
        inc hl
        ld d,(hl)

        call setmainpg_c000
        ld (intjp+0xc000),de

        ld a,pgkillable
        out (c),a
        ld b,memport8000_hi
        out (c),a
        
        ld a,0xc0
        ld (callbdos_mutex),a ;то же самое делают те функции BDOS, которые не собираются возвращаться

;не выходим из CALLBDOS, взамен шедулим и выходим через конец обработчика прерываний

BDOS_yield_q
        ;di ;TODO critical section

;        push iy
        call schedule ;out: iy=app ;можно с включенными прерываниями, пока системный обработчик не умеет шедулить
;        pop de
;        or a
;        sbc hl,de
;        jr nz,BDOS_yield_nosame
;        ld iy,app1 ;idle (TODO вместо этого сделать полноценные приоритеты)
;        ld (appaddr),iy
;BDOS_yield_nosame
        
        di ;TODO critical section

;если сейчас не поставить палитру второй задаче, то она никогда не поставится, если первая задача в цикле делает yield
;потому что все прерывания будут ставить первую задачу
        ;ld hl,(appaddr)
        ;ld iy,(appaddr)
        ;call iffocus_setgfx ;могут быть проблемы с выставлением палитры, если yield вызывать в случайных местах или если все задачи неактивны
;поэтому обработчик прерываний должен выставлять палитру задачи, которая в фокусе, независимо от её активности
        
        jp sys_int_popregs ;там ei
        
BDOS_newapp
;пока структура не заполнена до конца, нельзя делать runapp
;out: b=id, dehl=номера страниц в 0000,4000,8000,c000 нового приложения, a=error
        BDOSSETPGTRDOSFS
        ld a,(iy+app.id)
        push af ;parent id
         ld l,(iy+app.textcuraddr)
         ld h,(iy+app.textcuraddr+1)
         push hl
          di ;между findfreeid+findfreeappstruct и заполнением iy+app.id нельзя переключать задачи!!! ;TODO critical section
        call sys_findfreeid ;портит iy
         pop hl
        push af ;id
         push hl
        call sys_findfreeappstruct ;возвращает iy = адрес первой свободной структуры app ;TODO error
         pop hl
         jr nz,BDOS_newapp_fail
        pop af ;id
        push af ;id
        ld e,0xff ;auto page
        ;hl=textcuraddr
        call sys_newapp
          ei
         push iy
         pop de
         ld hl,(appaddr)
         ld bc,app.vol
         add hl,bc
         ex de,hl
         add hl,bc
         ex de,hl
         ld bc,5;DIR_sz
         ;jr $
         ldir ;копировать текущий vol и dircluster
        call BDOS_getmainpages_iy
        pop bc ;b=id
        pop af ;parent id
        ld (iy+app.parentid),a
        xor a
        ret ;success
BDOS_newapp_fail
        pop af
        pop af
        ld a,0xff
          ei
        ret

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
        call BDOS_findapp
        jp nz,BDOS_fail ;BDOS_popfail
        call BDOS_freezeapp_go
BDOS_delapppages
        ld hl,tsys_pages
        ld a,(iy+app.id)
        ld b,sys_npages&0xff
sys_quit_delpages0
        cp (hl) ;страница снимаемой задачи
        jr nz,$+4
        ld (hl),0 ;освободили страницу
        inc hl
        djnz sys_quit_delpages0
		if INETDRV
		BDOSSETPGW5300
		call w53_drop_socs
		endif
        xor a ;ok
        ld (iy+app.id),a ;b;0 ;освободили место
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
         set fwaiting,(iy+app.flags)
        ret

BDOS_waitpid
;e=id
;check for app close (a=0 and reset waiting, or else a!=0)
         push iy
         ;set fwaiting,(iy+app.flags)
        ld c,(iy+app.id) ;my (parent's) id ;caller is the parent
        push bc
        call BDOS_findapp ;iy=found app
        pop bc
        ld a,(iy+app.parentid)
         pop iy
        jr nz,BDOS_waitpid_OK ;app doesn't exist = OK
        cp c ;parent id
        jp z,BDOS_fail ;existing app = fail
BDOS_waitpid_OK
         res fwaiting,(iy+app.flags)
        xor a
        ret

BDOS_setgfx
        ;ld iy,(appaddr)
;e=0:EGA, e=2:MC, e=3:6912, e=6:text
;e=-1: disable gfx (out: e=old gfxmode)
        ld a,e
        cp -1
        jr z,BDOS_gfxoff;BDOS_gfxoff_givefocus
		IFDEF NOTURBO
        or 0xa0;%10100000
		ELSE
        or 0xa8;%10101000
		ENDIF
        ld (iy+app.gfxmode),a
        
;кладём фокус в стек, только если не два раза setgfx в одной задаче:
        ld hl,(focusappaddr)
        push iy
        pop de
        or a
        sbc hl,de
        jr z,BDOS_setgfx_nopushfocus
         ld hl,(oldfocusappaddr)
         ld (oldoldfocusappaddr),hl ;TODO стек фокусов (чтобы после закрытия задачи вернуть фокус вызвавшей)
        ld hl,(focusappaddr)
        ld (oldfocusappaddr),hl ;TODO стек фокусов (чтобы после закрытия задачи вернуть фокус вызвавшей)
        ld (focusappaddr),iy
BDOS_setgfx_nopushfocus        
        set fgfx,(iy+app.flags)
        ld e,(iy+app.gfxmode)
        xor a ;success
        ret
BDOS_gfxoff
        ld e,(iy+app.gfxmode)
        push de
        call BDOS_gfxoff_givefocus
        pop de
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
        
         ;jr $
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
        ld a,pagexor;0x7f
        sub e
        ld c,a
        ld hl,tsys_pages
        xor a
        ld b,a
        add hl,bc
        ld (hl),b ;0
        ret ;a=0

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

BDOS_fread
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
;DE = Pointer to opened FCB
        ;CHECKVOLUMETRDOS
        ld a,(de)
        cp vol_trdos
        jr c,BDOS_fread_noFATFS
;достать из него адрес ffile
        call getFILfromFCB ;hl=FIL
        call BDOS_getdta ;de = disk transfer address
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
        call movedma_addr ;+bc
	xor 0x80 ;!=, если прочитали не 128 байт
;a=0: OK (прочитали 128 байт)
;a=128: fail (прочитали 0 байт)
;a=???: OK (последний блок файла меньше 128 байт)
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
;достать из него адрес ffile
        call getFILfromFCB ;hl=FIL
        call BDOS_getdta ;de = disk transfer address
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

        
count_fdir
        push iy
        pop de
        ld hl,app.dir
        add hl,de
        ex de,hl
        ret

BDOS_opencurdir
        call count_fdir ;LD de,fdir
		F_OPDIR_CURDRV
        ret

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
        ld (iy+app.dircluster),l
        ld (iy+app.dircluster+1),h
        
        ld de,0x0000 ;track,sector
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
        ;or a
        ;ret nz;jp nz,fexit

;переделать структуру FILINFO (которую мы сейчас считали) в структуру FCB
        ld de,mfilinfo+FILINFO.FNAME
        ld a,(de)
        or a
        jp z,BDOS_fail ;fsearchnext_nofile
        BDOSSETPGTRDOSFS
        ld hl,fcb2+FCB_FNAME
        call dotname_to_cpmname ;de -> hl
        ld hl,mfilinfo+FILINFO.FSIZE
        ld de,fcb2+FCB_FSIZE
        ld bc,4
        ldir
        ld hl,(mfilinfo+FILINFO.FDATE)
        ld (fcb2+FCB_FDATE),hl
        ld hl,(mfilinfo+FILINFO.FTIME)
        ld (fcb2+FCB_FTIME),hl       
     	ld a,(mfilinfo+FILINFO.FATTRIB)
	;and 0x10
	ld (fcb2+FCB_FATTRIB),a
        jr BDOS_fsearch_loadloop_FATFSq
BDOS_fsearch_loadloop_noFATFS
;TR-DOS
        BDOSSETPGTRDOSFS
;BDOS_fsearch_loadloop_trdosaddr=$+1
        ;ld hl,0
        ld l,(iy+app.dircluster)
        ld h,(iy+app.dircluster+1)
        ld de,fcb2+FCB_FNAME
        call trdos_searchnext
        jp z,BDOS_fail ;fsearchnext_nofile;BDOS_fsearch_loadloop_noFATFS_empty
        ;ld (BDOS_fsearch_loadloop_trdosaddr),hl
        ld (iy+app.dircluster),l
        ld (iy+app.dircluster+1),h
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
		;push af
		;pop af
        ld bc,fres
;de=name
;bc=pointer to time,date
		F_GETUTIME
        ld hl,(fres)
        ld ix,(fres+2)
        ;xor a
        ret
BDOS_getfiletime_zero
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
        ld hl,(sys_time_date)
        ld ix,(sys_time_date+2)
        ret
        

BDOS_setfiletime
;de=Drive/path/file ASCIIZ string, ix=date, hl=time
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
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
		ld (.store_a),a
        push de
         ;dec c ;was c=1: drive in path
         ;call z,BDOS_setvol_rootdir ;drive specified in path
        call findfreeffile
         jr nz,$ ;TODO error
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

        
BDOS_readwritehandleprepare
;b=handle, hl=number of bytes, de=addr
;out: hl=fil, de=number of bytes, bc=addr(0x8000+)
        push hl ;Number of bytes to read
        push de ;Buffer address
        call BDOS_number_to_fil ;de=fil
        ex de,hl ;hl=FIL
        pop de ;Buffer address
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        ld b,d
        ld c,e
        pop de ;Number of bytes to read
        ret
        
BDOS_readhandle
;B = file handle 
;DE = Buffer address
;HL = Number of bytes to read
;out: HL = Number of bytes actually read, A=error
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
;TODO что делать, если возвратилось hl=0?
        ;ex af,af' ;error
        ;jr $
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
        ret
;BDOS_readwritehandlego
;BDOS_readwritehandle_proc=$+1
;        jp BDOS_readhandlego
BDOS_readhandlego
;b=handle
        bit 6,b
        jr nz,BDOS_readhandle_noFATFS
        call BDOS_readwritehandleprepare
	ld ix,fres
        push ix ;fres
        push de ;blocksize
	ex de,hl;ld de,ffile
	F_READ_CURDRV
	pop bc
        pop bc ;fres
        ld hl,(fres) ;hl=total processed bytes
        ret
BDOS_readhandle_noFATFS
        push bc
        BDOSSETPGTRDOSFS
        pop bc
        jp trdos_fread_b ;hl=total processed bytes

BDOS_writehandle
;B = file handle
;DE = Buffer address
;HL = Number of bytes to write
;out: HL = Number of bytes actually written, A=error
        push hl
        ld hl,BDOS_writehandlego
        jr BDOS_readwritehandle
BDOS_writehandlego
;b=handle
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
        ret
BDOS_writehandle_noFATFS
        push bc
        BDOSSETPGTRDOSFS
        pop bc
        jp trdos_fwrite_b ;hl=total processed bytes

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
        ld e,SYSDRV
         call BDOS_setdrv
         ld de,syspath
         jp setpath

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
        ex af,af'
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
        pop af
        cp vol_trdos
        jr c,BDOS_readsectors_TRDOS
        call BDOS_preparereadwritesectors_FATFS
        jp devices_read_go_regs
BDOS_readsectors_TRDOS
        call BDOS_preparereadwritesectors_TRDOSFS
        jp wrsectors. ;out: a=error?

BDOS_writesectors
;b=drive(0..), de=buffer, ixhl=sector number, a'=count
;передавать логический volume (букву) и пересчитать в номер драйвера (в смещение раздела, наверно, бессмысленно)?
        push bc
        call BDOS_preparedepage
        pop af
        cp vol_trdos
        jr c,BDOS_writesectors_TRDOS
        call BDOS_preparereadwritesectors_FATFS
        jp devices_write_go_regs
BDOS_writesectors_TRDOS
        call BDOS_preparereadwritesectors_TRDOSFS
        jp rdsectors. ;out: a=error?
 
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
         ld (iy+app.dircluster),a
         ld (iy+app.dircluster+1),a
         ld (iy+app.dircluster+2),a
         ld (iy+app.dircluster+3),a
        CHECKVOLUMETRDOS
        push de
        ;sbc a,a; ld a,0
        jr c,BDOS_setrootdir_trdos ;ret c ;NC=no error, A=0
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
         ld hl,(fatfs_org+FFS_DRV.curr_dir0)
         ld (iy+app.dircluster),l
         ld (iy+app.dircluster+1),h
         ld hl,(fatfs_org+FFS_DRV.curr_dir2)
         ld (iy+app.dircluster+2),l
         ld (iy+app.dircluster+3),h
		 ;xor a
         ret
        
BDOS_chdir_trdos
		ld (iy+app.vol),a
        ld a,(de) ;путь пустой?
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
        call findlastslash.
        ex de,hl ;HL = Pointer to start of last item (0x8000+/0xc000+!)
        
        pop de ;DE = Pointer to 64 byte (MAXPATH_sz!) buffer (0x8000+/0xc000+!)
        or a
        sbc hl,de ;hl=расстояние до последнего слэша
        pop de ;DE = Pointer to 64 byte (MAXPATH_sz!) buffer
        add hl,de ;HL = Pointer to start of last item
        ret

;hl = poi to filename in string
findlastslash.
;hl=path string
;out: de = after last slash (or start of path)
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
;find last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	ret z;jr z,nfopenfnslashq.
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
;hl->de
	inc de
	ex hl,de
	ld b,7
	ld de,mfil
	ld a,' '
1	ldi
	cp (hl)
        jr z,get_name_skipspaces
	djnz 1b
        ldi
        jr get_name_findext ;скопировали 8 символов, пробел не нашли
get_name_skipspaces
1	inc hl
	djnz 1b ;пропускаем оставшиеся пробелы
get_name_findext
	cp (hl)
	jr z,1f ;на месте расширения пробел - не ставим точку
	ex hl,de
	ld (hl),'.'
	inc hl
	ex hl,de
	ldi
	cp (hl)
	jr z,1f
	ldi
	cp (hl)
	jr z,1f
	ldi
1	xor a
        ld (de),a
	ret

findfreeffile
;out: nz=fail, hl=FIL, b=fil number
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
        ld a,b
        cp MAXFILES
        jr nz,findfreeffile0
        or a ;nz
        ret

BDOS_getdta
        ld e,(iy+app.dta)
        ld d,(iy+app.dta+1)
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
        ret

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
	jp BDOS_setpgstructs

;копирование в\из юзерспейса в\из структуру
memcpy_buf2usp	;DE - dst, BC - src, на стеке count
	res 7,b ;src=buf
	jr memcpy_buf_go
memcpy_usp2buf
	res 7,d ;dst=buf
memcpy_buf_go
	push bc
        ld a,pgfatfs2;=pgstructs
	call BDOS_setpg4000
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

ffilearray
        ds MAXFILES*FIL_sz
        ;dw 0x100 ;признак конца ffilearray
        
mfil    db "12345678.123",0 ;нужно только на время операции, которая принимает имя файла (может быть с путём?)

mfilinfo FILINFO ;нужно только на время findnext

fcb2    ds FCB_sz ;нужно только на время findnext

fres	dw 0 ;структура для возврата результата FatFS (число прочитанных/записанных байт)
        dw 0 ;для возврата даты

syspath
        db "bin",0
        
;для TASiS: не используются страницы ОЗУ 0x00, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F
;для избежания гибернации: не используются страницы ОЗУ 128K
tsys_pages
        ds 8,0xff ;системные страницы
        if TOPDOWNMEM
        db 0,0,0,0
        else
        db 0xff,0xff,0xff,0xff
        endif
        db 0,0,0,0 ;0x08..0x0f
        db 0,0,0,0,0,0,0,0 ;0x10..0x17
        db 0,0,0,0xff,0xff,0xff,0xff,0xff ;0x18..0x1f
        ds sys_npages-32-4 ;0=empty, or else process number
        if TOPDOWNMEM
        db 0xff,0xff,0xff,0xff
        else
        db 0,0,0,0
        endif

	display "$ before align=",$
;TODO хранить прямо в текстовом экране? а если затрут, то восстанавливать? по какому событию?
	align 256
trecode
	incbin "866toatm"
