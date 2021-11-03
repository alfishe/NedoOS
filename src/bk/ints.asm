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

        ld sp,STACK

        ld a,0;1 ;pseudo-color
        call setgfxmode

        ;ld de,diskname
        ;OS_OPENHANDLE
        ;ld a,b
        ;ld (diskhandle),a

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld a,e
        ld (pgprog),a
       push hl
        ld e,h
        OS_DELPAGE
       pop hl
        ld e,l
        OS_DELPAGE

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
       call clpga
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

        ld de,oldpath
        OS_GETPATH

        ld de,path
        OS_CHDIR

        ld de,tlowmem ;de=filename
        ld hl,0x0000 ;addr in segment
        call loadcompp

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

        ld hl,0x02d8
        ld (bkscroll),hl

        ld a,(tpgs+0x00)
       call clpga
        call cls_bk
        call cls_for_curgfxmode

        ld hl,0x01fe;0x0200
        ld (_SP),hl

       ld hl,0x8000

filenameaddr=$+1
        ld de,0;tprog ;de=filename
       ld a,d
       or e
       jr z,noloadfile
      push de
      ex de,hl
      call findlastdot
      ld a,(de) ;de = after last dot
      pop de
      cp '0' ;костыль для теста .0bk
      ld hl,4
      jr nz,$+3
      ld l,h
      push hl
        OS_OPENHANDLE
        ld a,b
        ld (curhandle),a
        ld de,bkheader
      pop hl
      push hl ;header size
        ;ld hl,4 ;de=buffer, hl=size
        ld a,h
        or l
        call nz,readcurhandle
      pop hl ;size defect
        ld de,(bkheader)
        ;ld de,0x01fc
;de=addr
       push de
        ;ld hl,4 ;size defect
        call loadcompp_noheader
       pop hl ;=IP(PC)
       ld a,h
       cp 2
       jr nc,noloadfile
     or a
     jr z,loadfile_testq ;костыль для теста
;autostart: берём адрес из 0x01fe
        ld a,(tpgs)
        SETPGC000
        ld hl,(0x01f6+0xc000) ;1f6 for newlode
noloadfile
       ex de,hl
        LD IY,EMUCHECKQ
        ;ld a,-1
        ;ld (iff1),a
     jp loopcjp;_LoopC_JP заменит текущую страницу

loadfile_testq
        ld hl,0x0080
        jr noloadfile

;hl = poi to filename in string
;out: ;de = after last dot
findlastdot
nfopenfndot.
	ld d,h
	ld e,l ;de = after last dot
nfopenfndot0.
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '.'
	jr nz,nfopenfndot0.
	jr nfopenfndot.

bkheader
        dw 0 ;addr
        dw 0 ;size (not used)

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

changegfxmode
;TODO защита от int!!!
       di
        ld a,(curgfxmode)
        inc a
        cp 3
        jr c,$+3
        xor a
        call setgfxmode
        call cls_for_curgfxmode
        call redraw_for_curgfxmode
       ei
        ret

setgfxmode
       ld (curgfxmode),a
;0=mono
;1=pseudo-color
;2=rgb
;...
        or a
        jr z,setgfxmode_mono
;1=pseudo-color
;2=rgb
        cp 1
        ld de,bkpal
        jr z,$+5
        ld de,rgbpal
        OS_SETPAL
       ld e,0+0x80 ;EGA+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld hl,tleftpixels
mkrecolor0
        ld a,l ;%????RrLl ;%????LlRr
        rrca
        rrca   ;%Ll????Rr
        rla
        rla    ;%????Rr?L
        rla    ;%???Rr?Ll
        and 0x1b
        ld (hl),a;000Rr0Ll
        inc l
        jr nz,mkrecolor0
        ld a,PUTSCREEN_C_PATCH_COLOR
        ld (putscreen_c_patch),a
        ret
setgfxmode_mono
        ld e,2+0x80 ;MC+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld de,standardpal
        OS_SETPAL       
        ld hl,tmirror
mkmirror0
        ld b,8
mkmirror1
        rlc l
        rra
        djnz mkmirror1
        ld (hl),a
        inc l
        jr nz,mkmirror0
        ld e,7 ;атрибут для mono
        ld a,(user_scr0_low) ;ok
       call clpga_e
        ld a,PUTSCREEN_C_PATCH_MONO
        ld (putscreen_c_patch),a
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

tlowmem
        db "bklowmem.bin",0
trom0
        db "bk10_017_mon.rom",0
trom1
        db "bk10_106_basic1.rom",0
trom2
        db "bk10_107_basic2.rom",0
trom3
        db "bk10_108_basic3.rom",0
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

;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
;standard:
        ;dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        ;dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
;ansi:
	;dw 0xffff,0xfdfd,0xefef,0xeded,0xfefe,0xfcfc,0xeeee,0xecec
	;dw 0x1f1f,0x1d1d,0x0f0f,0x0d0d,0x1e1e,0x1c1c,0x0e0e,0x0c0c
bkpal
;0,W,orange,teal
       dup 4
	dw 0xffff,0x8d8d,0x5f5f,0x0c0c
       edup
rgbpal
;0,R,B,G:
       dup 4
	dw 0xffff,0xdede,0x6f6f,0xbdbd
       edup
standardpal
        STANDARDPAL
