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
        
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
        ld (filenameaddr),hl
;command line = "texted <file to load>"
        ;ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        OS_OPENHANDLE
;b=new file handle

        ld de,module;0xc000
        ld hl,0xffff&(-module);0x4000
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push bc
        OS_READHANDLE
        pop bc

;B = file handle
        OS_CLOSEHANDLE
        
	ld a,(module)
        cp 'V'
        jr z,$+4
	cp 'P' ;'P'/'V' for PT3
	ld a,%00100000 ;PT3
	jr z,$+4
	ld a,%00000010 ;PT2
	ld (SETUP),a
	
        ld hl,module
	ld a,(hl)
	cp 'T'
        push af
        call nz,INIT
        pop af
        call z,tfmini

musicpage=$+1
	 ld a,0
         ld hl,player
         OS_SETMUSIC 
         
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

	ld a,(module)
	cp 'T'
        push af
        ;push de
        call nz,PLAY
        ;pop de
        pop af
        call z,tfm
        
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
        ent
szplayer=$-wasplayer
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "player.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
