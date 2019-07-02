
        ;include "atm.asm"
        include "sysdefs.asm"
        
;do define oldtimer (2 bytes)
        macro YIELD ;use instead of HALT
        OS_YIELD
_0=$
        OS_GETTIMER ;hlde=timer
        ld hl,(oldtimer)
        or a
        sbc hl,de
        jr z,_0 ;TODO OS_YIELDIDLE (иначе не сработает 'c'+'m'+'d')
         ld (oldtimer),de
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

        macro WAITPID
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
        
;from CP/M        
        macro OS_PRCHAR
        ld c,CMD_PRCHAR
        CALLBDOS
        endm
        macro OS_SETDRV
        ld c,CMD_SETDRV
        CALLBDOS
        endm
        macro OS_FOPEN
        ld c,CMD_FOPEN
        CALLBDOS
        endm
        macro OS_FCLOSE
        ld c,CMD_FCLOSE
        CALLBDOS
        endm
        macro OS_FSEARCHFIRST
        ld c,CMD_FSEARCHFIRST
        CALLBDOS
        endm
        macro OS_FSEARCHNEXT
        ld c,CMD_FSEARCHNEXT
        CALLBDOS
        endm
        macro OS_FDEL
        ld c,CMD_FDEL
        CALLBDOS
        endm
        macro OS_FREAD
        ld c,CMD_FREAD
        CALLBDOS
        endm
        macro OS_FWRITE
        ld c,CMD_FWRITE
        CALLBDOS
        endm
        macro OS_FCREATE
        ld c,CMD_FCREATE
        CALLBDOS
        endm
        macro OS_SETDTA
        ld c,CMD_SETDTA
        CALLBDOS
        endm

;from MSX-DOS
        macro OS_SEEKHANDLE
        ld c,CMD_SEEKHANDLE
        CALLBDOS
        endm
        macro OS_OPENHANDLE
        ld c,CMD_OPENHANDLE
        CALLBDOS
        endm
        macro OS_CREATEHANDLE
        ld c,CMD_CREATEHANDLE
        CALLBDOS
        endm
        macro OS_CLOSEHANDLE
        ld c,CMD_CLOSEHANDLE
        CALLBDOS
        endm
        macro OS_READHANDLE
        ld c,CMD_READHANDLE
        CALLBDOS
        endm
        macro OS_WRITEHANDLE
        ld c,CMD_WRITEHANDLE
        CALLBDOS
        endm
        macro OS_RENAME
        ld c,CMD_RENAME
        CALLBDOS
        endm
        macro OS_CHDIR
        ld c,CMD_CHDIR
        CALLBDOS
        endm
        macro OS_PARSEFNAME
        ld c,CMD_PARSEFNAME
        CALLBDOS
        endm
        macro OS_GETPATH
        ld c,CMD_GETPATH
        CALLBDOS
        endm
        macro OS_DELETE
        ld c,CMD_DELETE
        CALLBDOS
        endm

;invented  
        macro OS_GETFILESIZE
        ld c,CMD_GETFILESIZE
	CALLBDOS
        endm
        macro OS_SETWAITING
        ld c,CMD_SETWAITING
	CALLBDOS
        endm
        ;macro OS_RESETWAITING
        ;ld c,CMD_RESETWAITING
	;CALLBDOS
        ;endm
        macro OS_NETSOCKET;D=address family, E=socket type ; out: L=SOCKET(if L < 0 then A=error)
	ld l,0x01
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_NETSHUTDOWN;A=SOCKET ; out: if HL < 0 then A=error
	ld l,0x02
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_NETCONNECT;A=SOCKET, DE=sockaddr ptr ; out: if HL < 0 then A=error
	ld l,0x03
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_ACCEPT;A=SOCKET; out: HL
	ld l,0x04
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_BIND;A=SOCKET, DE=
	ld l,0x05
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_LISTEN;A=SOCKET
	ld l,0x06
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_WIZNETCLOSE
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
        macro OS_DROPAPP
        ld c,CMD_DROPAPP
	CALLBDOS
        endm
        macro OS_GETAPPMAINPAGES
        ld c,CMD_GETAPPMAINPAGES
	CALLBDOS
        endm
        macro OS_GETXY
        ld c,CMD_GETXY
	CALLBDOS
        endm
        macro OS_GETTIME
        ld c,CMD_GETTIME
        CALLBDOS
        endm
        macro OS_GETFILETIME
        ld c,CMD_GETFILETIME
        CALLBDOS
        endm
        macro OS_SETFILETIME
        ld c,CMD_SETFILETIME
        CALLBDOS
        endm
        macro OS_TELLHANDLE
        ld c,CMD_TELLHANDLE
        CALLBDOS
        endm
        macro OS_SCROLLUP
        ld c,CMD_SCROLLUP
        CALLBDOS
        endm
        macro OS_SCROLLDOWN
        ld c,CMD_SCROLLDOWN
        CALLBDOS
        endm
        macro OS_FWRITE_NBYTES
        ld c,CMD_FWRITE_NBYTES
        CALLBDOS
        endm
        ;macro OS_GETKEYNOLANG
        ;ld c,CMD_GETKEYNOLANG
        ;CALLBDOS
        ;endm
        macro OS_SETSYSDRV
        ld c,CMD_SETSYSDRV
        CALLBDOS
        endm
        macro OS_MKDIR
        ld c,CMD_MKDIR
        CALLBDOS
        endm
        macro OS_WAITPID
        ld c,CMD_WAITPID
        CALLBDOS
        endm
        macro OS_FREEZEAPP
        ld c,CMD_FREEZEAPP
        CALLBDOS
        endm
        macro OS_GETATTR
        ld c,CMD_GETATTR
        CALLBDOS
        endm
        macro OS_MOUNT
        ld c,CMD_MOUNT
        CALLBDOS
        endm
        macro OS_GETKEYMATRIX
        ld c,CMD_GETKEYMATRIX
        CALLBDOS
        endm
        macro OS_GETTIMER
        ld c,CMD_GETTIMER
	CALLBDOS
        endm
        macro OS_YIELD
        ld c,CMD_YIELD
	CALLBDOS
        endm
        macro OS_RUNAPP
        ld c,CMD_RUNAPP
	CALLBDOS
        endm
        macro OS_NEWAPP
        ld c,CMD_NEWAPP
	CALLBDOS
        endm
        macro OS_PRATTR
        ld c,CMD_PRATTR
	CALLBDOS
        endm
        macro OS_CLS
        ld c,CMD_CLS
	CALLBDOS
        endm
        macro OS_SETCOLOR
        ld c,CMD_SETCOLOR
	CALLBDOS
        endm
        macro OS_GETCOLOR
        ld c,CMD_GETCOLOR
	CALLBDOS
        endm
        macro OS_SETXY
        ld c,CMD_SETXY
	CALLBDOS
        endm
        macro OS_SETGFX
        ld c,CMD_SETGFX
	CALLBDOS
        endm
        macro OS_SETPAL
        ld c,CMD_SETPAL
	CALLBDOS
        endm
        macro OS_GETMAINPAGES
        ld c,CMD_GETMAINPAGES
	CALLBDOS
        endm
        macro OS_NEWPAGE
        ld c,CMD_NEWPAGE
	CALLBDOS
        endm
        macro OS_DELPAGE
        ld c,CMD_DELPAGE
	CALLBDOS
        endm
        macro OS_SETSCREEN
        ld c,CMD_SETSCREEN
	CALLBDOS
        endm
        macro OS_GETSCREENPAGES
        ld c,CMD_GETSCREENPAGES
	CALLBDOS
        endm



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        macro QUIT
        rst 0 ;close app
        endm

        macro CALLBDOS ;don't use CALLBDOS or call 0x0005 directly!!!
        ex af,af'
        call 0x0005 ;c=CMD
        endm

        macro GET_KEY
        rst 0x08 ;out: a=key (NOKEY=no key), de=mouse delta (dy,dx), l=mouse buttons (bits 0,1,2: 0=pressed), h=high bits of key|register, bc=keynolang
        endm

        macro PRCHAR
        rst 0x10 ;a=char
        endm

        macro SETPG16K
        rst 0x18 ;set page "a" in 0x4000
        endm
        
        macro SETPG32KLOW
        rst 0x20 ;set page "a" in 0x8000
        endm
        
        macro SETPG32KHIGH
        rst 0x28 ;set page "a" in 0xc000
        endm

        macro STANDARDPAL
        dw 0xf3f3,0xf2f2,0xf1f1,0xf0f0,0xe3e3,0xe2e2,0xe1e1,0xe0e0
        dw 0xf3f3,0xd2d2,0xb1b1,0x9090,0x6363,0x4242,0x2121,0x0000
        endm

