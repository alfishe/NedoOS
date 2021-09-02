init
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
;command line = bk <file to load>"
       ld (filenameaddr),hl
       ld hl,0x1fc
       ld (loadaddr),hl
       jr autoloadq
noautoload
        ld de,path
        OS_CHDIR
autoloadq
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
        call clpga
        ld a,(user_scr0_low) ;ok
        call clpga

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

        call swapimer ;сначала прерывания ничего не делают (iff1==0)

        jp initq

resetpp
        xor a
        ld (iff1),a

        ;call INT_setgfxTEXT80

        ld hl,0x0200
        ld (_SP),hl

loadaddr=$+1
        ld de,0x0200;STARTPC
       push de
        ld hl,0x01fc
filenameaddr=$+1
        ld de,tprog ;de=filename
;de=filename
;hl=addr in segment
        call loadcompp
       pop de ;LD DE,STARTPC ;=IP(PC)

        LD IY,EMUCHECKQ
        ;ld a,-1
        ;ld (iff1),a
     jp loopcjp;_LoopC_JP заменит текущую страницу

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

cmd_loadfullpage
        SETPGC000
        ld a,0xc000/256
cmd_loadpage
;out: a=error, bc=bytes read
;keeps hl,de
        push de
        push hl
        ld d,a
        xor a
        ld l,a
        ld e,a
        sub d
        ld h,a ;de=buffer, hl=size
        call readcurhandle
        ld b,h
        ld c,l
        pop hl
        pop de
        or a
        ret

readcurhandle
curhandle=$+1
        ld b,0
        OS_READHANDLE
        ret

clpga
        SETPGC000
        ld hl,0xc000
        ld d,h
        ld e,l
        inc e
        ld bc,0x3fff
        ld (hl),l;0
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
tprog
        db "textshow.bin",0
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
;hl=addr in segment
       push hl
        OS_OPENHANDLE
        ld a,b
        ld (curhandle),a
       pop de ;addr in segment
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
        OS_GETFILESIZE ;b=handle, out: dehl=file size
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
