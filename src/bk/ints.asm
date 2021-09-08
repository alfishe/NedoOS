init
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
;command line = bk <file to load>"
       ld (filenameaddr),hl
       ;jr autoloadq
noautoload
;autoloadq
        OS_HIDEFROMPARENT
        ld e,2+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ;ld e,0
        ;OS_SETSCREEN
        ;ld e,0
        ;OS_CLS
        ;ld e,1
        ;OS_SETSCREEN
        ;ld e,0
        ;OS_CLS

        ld sp,STACK
        ;ld de,diskname
        ;OS_OPENHANDLE
        ;ld a,b
        ;ld (diskhandle),a

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld a,e
        ld (pgprog),a
        ;ld a,h
        ;ld (tpgs+0xcf),a ;pgrom0 (#0x3f)
       push hl
        ld e,h
        OS_DELPAGE
       pop hl
        ld e,l
        OS_DELPAGE

        ld a,(user_scr0_high) ;ok
        ld e,0xaa
        call clpga_e
        ld a,(user_scr0_low) ;ok
        ld e,7
        call clpga_e

        ;ld de,tallmem
        ;OS_OPENHANDLE
        ;ld a,b
        ;ld (curhandle),a

        ld hl,tpgs
        ld b,4
filltpgs0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
       push de
       push hl
       ld a,e
       ;call c,clpga
       call clpga
        ;SETPGC000
        ;ld de,0xc000
        ;ld hl,0x4000
        ;call readcurhandle
       pop hl
       pop de
filltpgs0_noclear
        pop bc
       ld a,l
       rrc l
       rrc l
        ld (hl),e
       ld l,a
        inc l
        djnz filltpgs0

        ;call closecurhandle

        ld de,oldpath
        OS_GETPATH

        ld de,path
        OS_CHDIR

        ld de,trom0 ;de=filename
        ld hl,0x8000 ;addr in segment
        call loadcompp
        ld de,trom1 ;de=filename
        ld hl,0xa000 ;addr in segment
        call loadcompp
        ld de,trom2 ;de=filename
        ld hl,0xc000 ;addr in segment
        call loadcompp
        ld de,trom3 ;de=filename
        ld hl,0xe000 ;addr in segment
        call loadcompp

        ld de,oldpath
        OS_CHDIR

        call swapimer ;сначала прерывания ничего не делают (iff1==0)

        jp initq

resetpp
        xor a
        ld (iff1),a

        ;call INT_setgfxTEXT80

        ld hl,0x0200
        ld (_SP),hl

       ld hl,0x8000

filenameaddr=$+1
        ld de,0;tprog ;de=filename
       ld a,d
       or e
       jr z,noloadfile
        OS_OPENHANDLE
        ld a,b
        ld (curhandle),a
        ld de,bkheader
        ld hl,4 ;de=buffer, hl=size
        call readcurhandle
        ld de,(bkheader)
        ;ld de,0x01fc
;de=addr
       push de
        ld hl,4 ;size defect
        call loadcompp_noheader
       pop hl ;=IP(PC)
       ld a,h
       cp 2
       jr nc,noloadfile
;autostart: берём адрес из 0x01fe
        ld a,(tpgs)
        SETPGC000
        ld hl,(0x01fe+0xc000)
noloadfile
       ex de,hl
        LD IY,EMUCHECKQ
        ;ld a,-1
        ;ld (iff1),a
     jp loopcjp;_LoopC_JP заменит текущую страницу

bkheader
        ds 4

;de=имя файла
;hl=куда грузим
loadfile_in_hl
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld h,0x7f ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	ret

readcurhandle
curhandle=$+1
        ld b,0
        OS_READHANDLE
        ret

clpga
        ld e,0
clpga_e
        SETPGC000
        ld hl,0xc000
       ld a,e
        ld d,h
        ld e,l
        inc e
        ld bc,0x3fff
       ld (hl),a;0
        ldir
        ret

;keep here for quit
swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret

farquiter
        call swapimer
        ld hl,0
        QUIT

trom0
        db "bk10_017_mon.rom",0
trom1
        db "bk10_106_basic1.rom",0
trom2
        db "bk10_107_basic2.rom",0
trom3
        db "bk10_108_basic3.rom",0
;tprog
;        db "textshow.bk",0
path
        db "bk",0

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

loadcompp
;de=filename
;hl=addr
       push hl
        OS_OPENHANDLE
        ld a,b
        ld (curhandle),a
       pop de ;addr
       ld hl,0 ;no size defect
loadcompp_noheader
;de=addr, hl=size defect
        ld a,d
        and 0xc0
	ld c,a
	ld b,tpgs/256
	set 7,d
        set 6,d
       push bc
       push de
        ld a,(curhandle)
        ld b,a
       push hl ;size defect
        OS_GETFILESIZE ;b=handle, out: dehl=file size
       pop bc ;ld bc,4
        or a
        sbc hl,bc
        jr nc,$+3
        dec de
       pop de
       pop bc
loadcompp0
;de=текущий адрес загрузки (c000+)
;hl=сколько байтов осталось грузить
;bc=tpgs+текущий номер страницы
        push bc
        ld a,(bc)
        SETPGC000
       push hl ;сколько байтов осталось грузить
       add hl,de
       sbc hl,de
       jr nc,loadcompp_nocroppg
       ld hl,1
       ;scf
       sbc hl,de
loadcompp_nocroppg
        call readcurhandle
        ld b,h
        ld c,l
       pop hl ;сколько байтов осталось грузить
       or a
       sbc hl,bc
       ld de,0xc000
        pop bc
        ld a,c
        rlca
        rlca
        inc a
        rrca
        rrca
        ld c,a ;next pg
        ld a,h
        or l
        jr nz,loadcompp0
closecurhandle
        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
        ret

far_int
        ret

oldpath
        ds MAXPATH_sz
