        include "sysdefs.asm"
        
        macro YIELD ;use instead of HALT
        OS_YIELD
        endm
        macro YIELDKEEP ;use instead of HALT if you want reentry in this frame
        OS_YIELDKEEP
        endm
        macro YIELDGETKEY ;out: nz=nokey, a=keylang, c=keynolang
	YIELD ;halt ;если сделать просто di:rst 0x38, то 1.сдвинем таймер и 2.можем потерять кадровое прерывание, а если без ei, то будут глюки
        GET_KEY
        or a ;cp NOKEY ;keylang==0?
        jr nz,$+3
        cp c ;keynolang==0?
        endm
        macro YIELDGETKEYLOOP
_1=$
        YIELDGETKEY
        jr z,_1
        endm

        macro WAITPID ;wait task E to close
        ;push de
        ;YIELD ;чтобы запускаемая задача успела захватить фокус
        ;ld e,-1
        ;OS_SETGFX ;disable gfx, give focus (если не сделать YIELD, фокус отдаётся не тому приложению, какое мы ждём!)
        ;ld a,e
        ;pop de
        ;ld d,a
        push de
        OS_SETWAITING
        pop de
_1=$
        push de
        YIELD
        pop de
        push de
        OS_WAITPID
        pop de
        or a
        jr nz,_1
        ;push de
        ;OS_RESETWAITING
        ;pop de
        ;ld e,d ;ld e,6 ;textmode
        ;OS_SETGFX ;take focus (can be random after closing cmd)
        endm
        
;from CP/M (try to avoid use!) FCB = file control block (size FCB_sz)    
        macro OS_PRCHAR ;e=char
        ld c,CMD_PRCHAR
        CALLBDOS
        endm
        macro OS_SETDRV ;e=drive ;out: a!=0 => not mounted, [l=number of drives]
        ld c,CMD_SETDRV
        CALLBDOS
        endm
        macro OS_FOPEN ;de = pointer to unopened FCB
        ld c,CMD_FOPEN
        CALLBDOS
        endm
        macro OS_FCLOSE ;de = pointer to opened FCB
        ld c,CMD_FCLOSE
        CALLBDOS
        endm
        macro OS_FSEARCHFIRST ;de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA. DTA had to set every time
        ld c,CMD_FSEARCHFIRST
        CALLBDOS
        endm
        macro OS_FSEARCHNEXT ;(NOT CP/M compatible!!!)de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA. DTA had to set every time
        ld c,CMD_FSEARCHNEXT
        CALLBDOS
        endm
        macro OS_FDEL ;DE = Pointer to unopened FCB
        ld c,CMD_FDEL
        CALLBDOS
        endm
        macro OS_FREAD ;DE = Pointer to opened FCB, read 128 bytes in DTA, out: a=128^bytes actually read (not CP/M!)
        ld c,CMD_FREAD
        CALLBDOS
        endm
        macro OS_FWRITE ;DE = Pointer to opened FCB, write 128 bytes from DTA
        ld c,CMD_FWRITE
        CALLBDOS
        endm
        macro OS_FCREATE ;DE = Pointer to unopened FCB
        ld c,CMD_FCREATE
        CALLBDOS
        endm
        macro OS_SETDTA ;DE = data transfer address (DTA)
        ld c,CMD_SETDTA
        CALLBDOS
        endm

;from MSX-DOS
        macro OS_SEEKHANDLE ;b=file handle, dehl=offset
        ld c,CMD_SEEKHANDLE
        CALLBDOS
        endm
        macro OS_OPENHANDLE ;DE = Drive/path/file ASCIIZ string ;out: B = new file handle, A=error
        ld c,CMD_OPENHANDLE
        CALLBDOS
        endm
        macro OS_CREATEHANDLE ;DE = Drive/path/file ASCIIZ string ;out: B = new file handle, A=error
        ld c,CMD_CREATEHANDLE
        CALLBDOS
        endm
        macro OS_CLOSEHANDLE ;B = file handle, out: A=error
        ld c,CMD_CLOSEHANDLE
        CALLBDOS
        endm
        macro OS_READHANDLE ;B = file handle, DE = Buffer address, HL = Number of bytes to read, out: HL = Number of bytes actually read, A=error(=0)
        ld c,CMD_READHANDLE
        CALLBDOS
        endm
        macro OS_WRITEHANDLE ;B = file handle, DE = Buffer address, HL = Number of bytes to write, out: HL = Number of bytes actually written, A=error(=0)
        ld c,CMD_WRITEHANDLE
        CALLBDOS
        endm
        macro OS_RENAME ;DE = Drive/path/file ASCIIZ string, HL = New filename ASCIIZ string (NOT MSXDOS compatible! with Drive/path!) ;RENAME OR MOVE FILE
        ld c,CMD_RENAME
        CALLBDOS
        endm
        macro OS_CHDIR ;DE = Pointer to ASCIIZ string. Out A=error
        ld c,CMD_CHDIR
        CALLBDOS
        endm
        macro OS_PARSEFNAME ;de(dotname) -> hl(cpmname) ;out: de=pointer to termination character, hl=buffer filled in
        ld c,CMD_PARSEFNAME
        CALLBDOS
        endm
        macro OS_GETPATH ;DE = Pointer to 64 byte (MAXPATH_sz!) buffer ;out: DE = Filled in with whole path string (WITH DRIVE! Finished by slash only if root dir), HL = Pointer to start of last item
        ld c,CMD_GETPATH
        CALLBDOS
        endm
        macro OS_DELETE ;DE = Drive/path/file ASCIIZ string, out: A = Error
        ld c,CMD_DELETE
        CALLBDOS
        endm

;invented  
        macro OS_SETSTDINOUT ;e=stdin, d=stdout, h=stderr
        ld c,CMD_SETSTDINOUT
	CALLBDOS
        endm
        macro OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr
        ld c,CMD_GETSTDINOUT
	CALLBDOS
        endm
        macro OS_PLAYCOVOX ;hl=data (0xc000+, 0x00=end), de=pagetable (0x0000+), hx=delay (18=11kHz, 7=22kHz, 1=44kHz)
        ld c,CMD_PLAYCOVOX
	CALLBDOS
        endm
        macro OS_SETMUSIC ;hl=muzaddr (0x4000..0xffff), a=muzpg (pages in 0x8000, 0xc000 are taken from current user memory)
        ld c,CMD_SETMUSIC
	CALLBDOS
        endm
        macro OS_READSECTORS ;b=drive, de=buffer, ixhl=sector number, a=count
        ld c,CMD_READSECTORS
	CALLBDOS
        endm
        macro OS_WRITESECTORS ;b=drive, de=buffer, ixhl=sector number, a=count
        ld c,CMD_WRITESECTORS
	CALLBDOS
        endm
        macro OS_GETFILESIZE ;b=handle, out: dehl=file size
        ld c,CMD_GETFILESIZE
	CALLBDOS
        endm
        macro OS_SETBORDER ;e=0..15
        ld c,CMD_SETBORDER
	CALLBDOS
        endm
        macro OS_SETWAITING ;set WAITING state for current task
        ld c,CMD_SETWAITING
	CALLBDOS
        endm
        macro OS_NETSOCKET ;D=address family (2=inet, 23=inet6), E=socket type (0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip) ;out: L=SOCKET (if L < 0 then A=error)
	ld l,0x01
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_NETSHUTDOWN;A=SOCKET ; out: if HL < 0 then A=error
	ld l,0x02
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_NETCONNECT;A=SOCKET, DE=sockaddr ptr {unsigned char sin_family /*net type*/; unsigned short sin_port; struct in_addr sin_addr /*4 bytes IP*/; char sin_zero[8];}; out: if HL < 0 then A=error
	ld l,0x03
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_ACCEPT;A=SOCKET; out: HL
	ld l,0x04
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_BIND;A=SOCKET, DE=sockaddr ptr {unsigned char sin_family /*net type*/; unsigned short sin_port; struct in_addr sin_addr /*4 bytes IP*/; char sin_zero[8];}
	ld l,0x05
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_LISTEN;A=SOCKET
	ld l,0x06
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_WIZNETCLOSE;A=SOCKET
        ld c,CMD_WIZNETCLOSE
	CALLBDOS
        endm
        macro OS_WIZNETREAD;A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) ; out: HL=count if HL < 0 then A=error
        ld c,CMD_WIZNETREAD
	CALLBDOS
        endm
        macro OS_WIZNETWRITE;A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) ; out: HL=count if HL < 0 then A=error
        ld c,CMD_WIZNETWRITE
	CALLBDOS
        endm
        macro OS_DROPAPP ;e=id
        ld c,CMD_DROPAPP
	CALLBDOS
        endm
        macro OS_GETAPPMAINPAGES ;e=id ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id, a=error
        ld c,CMD_GETAPPMAINPAGES
	CALLBDOS
        endm
        macro OS_GETXY ;out: de=yx ;GET CURSOR POSITION
        ld c,CMD_GETXY
	CALLBDOS
        endm
        macro OS_GETTIME ;out: ix=date, hl=time
        ld c,CMD_GETTIME
        CALLBDOS
        endm
        macro OS_GETFILETIME ;de=Drive/path/file ASCIIZ string, out: ix=date, hl=time
        ld c,CMD_GETFILETIME
        CALLBDOS
        endm
        macro OS_SETFILETIME ;de=Drive/path/file ASCIIZ string, ix=date, hl=time
        ld c,CMD_SETFILETIME
        CALLBDOS
        endm
        macro OS_TELLHANDLE ;b=file handle, out: dehl=offset ;GET POSITION IN FILE
        ld c,CMD_TELLHANDLE
        CALLBDOS
        endm
        macro OS_SCROLLUP ;de=topyx, hl=hgt,wid ;x, wid even ;TEXTMODE ONLY
        ld c,CMD_SCROLLUP
        CALLBDOS
        endm
        macro OS_SCROLLDOWN ;de=topyx, hl=hgt,wid ;x, wid even ;TEXTMODE ONLY
        ld c,CMD_SCROLLDOWN
        CALLBDOS
        endm
        macro OS_FWRITE_NBYTES ;hl=bytes, de=FCB ;don't use! ;TODO выбросить
        ld c,CMD_FWRITE_NBYTES
        CALLBDOS
        endm
        macro OS_SETMAINPAGE ;e=page for 0x0000
        ld c,CMD_SETMAINPAGE
        CALLBDOS
        endm
        macro OS_SETSYSDRV ;out: a!=0 => not mounted, l=number of drives
        ld c,CMD_SETSYSDRV
        CALLBDOS
        endm
        macro OS_MKDIR ;DE = Pointer to ASCIIZ string, out: a
        ld c,CMD_MKDIR
        CALLBDOS
        endm
        macro OS_WAITPID ;e=id ;check if app closed, out: a=0 => OK (and reset waiting), or else a!=0
        ld c,CMD_WAITPID
        CALLBDOS
        endm
        macro OS_FREEZEAPP ;e=id ;disable app and make non-graphic
        ld c,CMD_FREEZEAPP
        CALLBDOS
        endm
        macro OS_GETATTR ;out: a ;READ ATTR AT CURSOR POSITION
        ld c,CMD_GETATTR
        CALLBDOS
        endm
        macro OS_MOUNT ;e=drive, out: a
        ld c,CMD_MOUNT
        CALLBDOS
        endm
        macro OS_GETKEYMATRIX ;out: bcdehlix = halfrows cs...space
        ld c,CMD_GETKEYMATRIX
        CALLBDOS
        endm
        macro OS_GETTIMER ;out: hlde=timer
        ld c,CMD_GETTIMER
	CALLBDOS
        endm
        macro OS_YIELD ;schedule to another app (use YIELD macro instead of HALT!!!)
        ld c,CMD_YIELD
	CALLBDOS
        endm
        macro OS_RUNAPP ;e=id ;ACTIVATE DISABLED APP
        ld c,CMD_RUNAPP
	CALLBDOS
        endm
        macro OS_NEWAPP ;out: b=id, a=error, dehl=newapp pages in 0000,4000,8000,c000 ;MAKE NEW DISABLED APP
        ld c,CMD_NEWAPP
	CALLBDOS
        endm
        macro OS_PRATTR ;e=color byte ;DRAW ATTR AT CURSOR POSITION
        ld c,CMD_PRATTR
	CALLBDOS
        endm
        macro OS_CLS ;e=color byte
        ld c,CMD_CLS
	CALLBDOS
        endm
        macro OS_SETCOLOR ;e=color byte
        ld c,CMD_SETCOLOR
	CALLBDOS
        endm
        macro OS_SETXY ;de=yx ;SET CURSOR POSITION
        ld c,CMD_SETXY
	CALLBDOS
        endm
        macro OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld c,CMD_SETGFX
	CALLBDOS
        endm
        macro OS_SETPAL ;de=palette (32 bytes)
        ld c,CMD_SETPAL
	CALLBDOS
        endm
        macro OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld c,CMD_GETMAINPAGES
	CALLBDOS
        endm
        macro OS_NEWPAGE ;out: a=0 (OK)/!=0 (fail), e=page
        ld c,CMD_NEWPAGE
	CALLBDOS
        endm
        macro OS_DELPAGE ;e=page ;GIVE SOME PAGE BACK TO THE OS
        ld c,CMD_DELPAGE
	CALLBDOS
        endm
        macro OS_SETSCREEN ;e=screen=0..1
        ld c,CMD_SETSCREEN
	CALLBDOS
        endm
        ;macro OS_GETSCREENPAGES ;DEPRECATED!!!! out: de=pages of screen 0 (d=higher page), hl=pages of screen 1 (h=higher page)
        ;ld c,CMD_GETSCREENPAGES
	;CALLBDOS
        ;endm
        macro OS_YIELDKEEP ;schedule to another app, can return in this frame
        ld c,CMD_YIELDKEEP
	CALLBDOS
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        macro QUIT
        rst 0 ;close app
        endm

        macro CALLBDOS ;don't use directly CALLBDOS or call 0x0005!!!
        ex af,af'
        call 0x0005 ;c=CMD
        endm

        macro GET_KEY
        rst 0x08 ;out: a=key (NOKEY=no key), de=mouse position (y,x), l=mouse buttons (bits 0,1,2: 0=pressed), h=high bits of key|register, bc=keynolang, nz=no focus (mouse position=0, ignore it!)
        endm

        macro PRCHAR
        rst 0x10 ;a=char ;spoils all registers!
        endm

        macro SETPG16K
        rst 0x18 ;set page "a" in 0x4000 ;spoils BC
        endm
        
        macro SETPG32KLOW
        rst 0x20 ;set page "a" in 0x8000 ;spoils BC
        endm
        
        macro SETPG32KHIGH
        rst 0x28 ;set page "a" in 0xc000 ;spoils BC
        endm

        macro STANDARDPAL ;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
        dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
        endm
