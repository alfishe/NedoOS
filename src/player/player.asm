        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

COLOR=7
module=0x6000;0xc000
        
		
        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
        OS_HIDEFROMPARENT
        ld e,6 ;textmode
        OS_SETGFX
        ;call initstdio

	OS_GETMAINPAGES ;out: dehl=номера страниц в 0000,4000,8000,c000, c=flags, b=id
	ld a,e
	ld (musicpage),a
        ld a,b
        ld (myid),a
       if 0
        ld a,h
        ld (page8000),a
        ld a,l
        ld (pagec000),a
       endif
        ;push hl
        ;ld e,h
        ;OS_DELPAGE
        ;pop hl
        ;ld e,l
        ;OS_DELPAGE

;TODO найти копию себя в памяти и послать ей 0 в COMMANDLINE
        ld e,1 ;no id 0
cmd_proc0
        push de
        ld a,e
myid=$+1
        cp 0
        jr z,cmd_proc_skip
        OS_GETAPPMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, a=error
        or a
        jr nz,cmd_proc_skip
        ld a,d ;main page
        SETPG32KHIGH
        ld de,COMMANDLINE+0xc000
        ld hl,ttestdatacom
        ld bc,ttestdatacom_sz
        call teststr
        jr z,cmd_proc_found
        ld de,COMMANDLINE+0xc000
        ld hl,ttestdata
        ld bc,ttestdata_sz
        call teststr
        jr nz,cmd_proc_skip
cmd_proc_found
        xor a
        ld (COMMANDLINE+0xc000),a ;ok ;"закройся"
cmd_proc_skip
        pop de
        inc e
        ld a,e
        inc a ;no id 0xff
        jr nz,cmd_proc0

;а как заглушить музыку, если не опрашивать клаву?
;если опрашивать, то нужен терминал
;можно было бы в nv.ext прописать cmd.com start term.com player.com, но такие конструкции пока не поддержаны ни в nv, ни в term
;поэтому пока без терминала
        
        ld hl,wasplayer
        ld de,0x4000
        ld bc,szplayer
        ldir

       if 0
page8000=$+1
        ld a,0
        SETPG8000
pagec000=$+1
        ld a,0
        SETPGC000
       endif
        
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jp z,noautoload
        ld (filenameaddr),hl
;command line = "texted <file to load>"
       push hl
        call findlastdot ;out: de = after last dot or start
        ld (extaddr),de
       pop hl
        ;ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        OS_OPENHANDLE
;b=new file handle

extaddr=$+1
        ld hl,0
        inc hl
        inc hl
        ld a,(hl)
        or 0x20
        cp 'd'
        jp z,play_tfd
        cp 'm'
        jp z,play_tfm
        
        ld de,module;0xc000
        ld hl,0xffff&(-module);0x4000
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push bc
        OS_READHANDLE
;hl = file size
        pop bc
;B = file handle
        push hl

;B = file handle
        OS_CLOSEHANDLE
        pop ix
;ix = file size
        call getptsconfig
;a = player config bits, hl = offset to the second module if available
        ld (SETUP),a
        ld (secondmoduleoffset), hl

        halt
	;инитим до инита трека, иначе не работает SAA
musicpage=$+1
	ld a,0
	ld hl,player
	OS_SETMUSIC ;пишет в AY
	
	di
	ld hl,end_init
	push hl
	;display $
    ld hl,module
	ld a,(module + 0x0a)
	cp 'E'
        jp z,EPlayer_Init
	ld a,(hl)
	cp 'T'
        jp z,tfmini

secondmoduleoffset=$+1
        ld de,0
        add de,hl ;address of the second module

		jp INIT
end_init
    ei  
mainloopredraw
        ld e,COLOR
        OS_CLS
filenameaddr=$+1
        ld hl,0
        call prtext
        ld a,0x0d
        PRCHAR
        ld a,0x0a
        PRCHAR
        
mainloop
        YIELD
	;di ;TODO fix player
        ;call player
	;ei
        ld a,(COMMANDLINE) ;ok
        or a
        jr z,quit
        
        GET_KEY
      cp key_redraw
      jr z,mainloopredraw
        ;or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+2+1+2
        ;cp c ;keynolang==0?
        ;jr z,_1;1b;prwindow_waitkey_nokey
        cp key_esc
        jr nz,mainloop
quit
	  ld a,(musicpage)
	  ld hl,muter
	  OS_SETMUSIC 
          halt
noautoload
        QUIT

play_tfd
;b=handle
        call loadtfd

        call tfd_ini
        call tfmshut

	ld a,(musicpage)
	ld hl,tfd_play
	OS_SETMUSIC 
        jp mainloopredraw

play_tfm
;b=handle
        call loadtfd

        ;call tfm_ini

        halt
	ld a,(musicpage)
	ld hl,tfm_play
	OS_SETMUSIC ;пишет в AY

        call tfmshut

        ld a,0xa0;%10101000 ;320x200 mode noturbo
	ld bc,0xbd77	;shadow ports and palette remain on
        out (c),a

        LD DE,#FFBF
        LD C,#FD 
        CALL selChip0
        CALL clrSSG;tfminiPP
        LD A,%11111000
        EXA 
        LD A,7
        CALL WRITEREG
        CALL selChip1
        CALL clrSSG;tfminiPP
        LD A,%11101111
        EXA 
        LD A,7
        call WRITEREG 

	LD A,0xa8;%10101000 ;320x200 mode
	ld bc,0xbd77	;shadow ports and palette remain on
        out (c),a

        jp mainloopredraw

clrSSG
        XOR A
        EXA 
        LD A,#0D ;SSG
regClrS0 CALL WRITEREG
        DEC A
        JP P,regClrS0
        ret

loadtfd
;b=handle
        ld a,b
        ld (curhandle),a
       if 1
        ld hl,0
        ld de,0
nvview_load0
        push de
        push hl
        call reservepage
        pop hl
        pop de
        ret nz ;no memory
;nvview_load0nonewpg        
        ld a,0xc000/256
        call cmd_loadpage
        jr nz,nvview_load0q
        ex de,hl
        add hl,bc
        ex de,hl
        jr nc,$+3
        inc hl
         ;TODO nvview_load0nonewpg with new pointer if no new page
        ld a,b
        or c
        jr nz,nvview_load0
nvview_load0q
;hlde=true file size (for TRDOSFS)
        ;ld (filesize),de
        ;ld (filesizeHSW),hl

        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
       else
        ld de,tfmData
        ld hl,0xffff&(-tfmData);0x4000
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push bc
        OS_READHANDLE
        pop bc

;B = file handle
        OS_CLOSEHANDLE
       endif
        ret

reservepage
;new page, set page in textpages, npages++, set page in #c000
;nz=error
        OS_NEWPAGE
        or a
        ret nz
npages=$+1
        ld hl,tpgs;textpages
        ld (hl),e
        inc l
        ld (npages),hl
        ld a,e
        SETPGC000
        xor a
        ret ;z

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

;hl = poi to filename in string
;out: de = after last dot or start
findlastdot
	ld d,h
	ld e,l ;de = after last dot
findlastdot0
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '.'
	jr nz,findlastdot0
	jr findlastdot


teststr
testdata0
        ld a,(de)
        or 0x20
        cp (hl)
        ret nz ;jr nz,cmd_proc_skip
        inc de
        cpi
        jp pe,testdata0
        xor a
        ret

ttestdatacom
        db "player.com"
ttestdatacom_sz=$-ttestdatacom

ttestdata
        db "player "
ttestdata_sz=$-ttestdata

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

prtext
;out: hl=after terminator
prtext0
        ld a,(hl)
        inc hl
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        jp prtext0

findts
;ix = file size
;out: zf = 1 if TS data is found, hl = offset to the second module if available
        ld de,module
        add ix,de ;past-the-end address of the data buffer

        ld a,'0'
        cp (ix-4)
        ret nz
        ld a,'2'
        cp (ix-3)
        ret nz
        ld a,'T'
        cp (ix-2)
        ret nz
        ld a,'S'
        cp (ix-1)
        ret nz

        ld hl,(ix-12)
        ret

getptsconfig
;ix = file size
;out: a = player config bits, hl = offset to the second module if available
        call findts
        ld a,%00010000 ;2xPT3
        ret z

        ld a,(module)
        cp 'V'
        jr z,$+4
        cp 'P' ;'P'/'V' for PT3
        ld a,%00100000 ;PT3
        ret z

        ld a,%00000010 ;PT2
        ret

;oldtimer
;        dw 0

        ;include "../_sdk/stdio.asm"

        ;ds 0x4000-$
wasplayer
        disp 0x4000
player
;a = port bd77 value
        di
        push af
        and 0xf7;0xa0;%10101000 ;320x200 mode noturbo
	ld bc,0xbd77	;shadow ports and palette remain on
        out (c),a

	ld hl,end_player
	push hl
	
	ld a,(module + 0x0a)
	cp 'E'
        jp z,EPlayer_Play
	ld a,(module)
	cp 'T'
        jp z,tfm
        
        jp nz,PLAY
        
end_player
        pop af
	;LD A,0xa8;%10101000 ;320x200 mode
	ld bc,0xbd77	;shadow ports and palette remain on
        out (c),a
        ei
        ret
muter        
	ld a,(module)
	cp 'T'
        push af
        call nz,MUTE
        pop af
        call z,tfmshut
        ret

        include "ptsplay.asm"
        include "tfmplay.asm"
        include "tfdtest.asm"
        include "tfmtest.asm"
        include "etplayer.asm"
;tfmData
        ent
szplayer=$-wasplayer

cmd_end

	display "szplayer ",/d,szplayer," bytes"
	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "player.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l",1
