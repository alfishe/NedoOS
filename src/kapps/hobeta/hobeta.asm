; hobeta.com ? load and run TR-DOS Hobeta file (*.$C)
; Algorithm from src/nv/nv.asm (loadhobeta + washobetarunner).
; Usage: hobeta <file.$c>
; Leaves NedoOS and transfers control to the hobeta start address.
;
        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

hobetarunner=0x4100
STACK=0x4000
; File is read at 0x6000-17 into pages at 4000/8000/C000 ? keep code below 0x4000.

        org PROGSTART
cmd_begin
        ld sp,STACK

        ld hl,COMMANDLINE
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jp z,usage

        push hl
        call skipword
        ld (hl),0
        pop hl
        ld (filename),hl

        ld e,6              ; textmode
        OS_SETGFX
        YIELD

        ld a,(user_scr0_low)
        SETPG8000
        inc a
        SETPGC000
; 0x4000 : app page (load target start)
; 0x8000 : pg1 (scr0_low)
; 0xc000 : pg0 (scr0_low+1)
        ld de,(filename)
        call loadhobeta
        jp nz,load_error

        di
        ld a,(user_scr0_low)
        sub 4-1             ; pgkillable
        SETPG8000
        ld hl,0x4000
        ld de,0x8000
        ld bc,0x4000
        ldir                ; copy load page -> pgkillable

        ld a,(user_scr0_low)
        SETPG8000
        sub 4-1
        SETPG4000
        ld hl,washobetarunner
        ld de,hobetarunner
        ld bc,hobetarunner_sz
        ldir
; 0x4000 : pgkillable (has hobeta head + runner)
; 0x8000 : pg1
; 0xc000 : pg0
        ld hl,0x6000
        ld bc,(0x6000-17+11) ; length
        add hl,bc
        dec hl              ; hl = load end
        ex de,hl
        ld hl,(0x6000-17+9) ; start
        ld (hobetarunner_jp),hl
        add hl,bc
        dec hl
        ex de,hl            ; de = destination end
        lddr
        jp hobetarunner

; de = filename ASCIIZ
; out: nz = error
loadhobeta
        OS_OPENHANDLE
        or a
        ret nz
        ld a,b
        ld (curhandle),a
        ld de,0x6000-17
        ld hl,-(0x6000-17)
        OS_READHANDLE
        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
        xor a
        ret

usage
        ld hl,t_usage
        jr pr_quit

load_error
        ld hl,t_loaderr
pr_quit
        call prstr
        QUIT

prstr
        ld a,(hl)
        or a
        ret z
        push hl
        OS_PRCHAR
        pop hl
        inc hl
        jr prstr

skipword
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr skipword

skipspaces
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

curhandle
        db 0
filename
        dw 0

t_usage
        db "Usage: hobeta <file.$c>",0x0d,0x0a,0
t_loaderr
        db "hobeta: cannot load file",0x0d,0x0a,0

washobetarunner
; pgkillable runner ? ATM2 ports; $c already in pages 4,1,0
        disp hobetarunner
        ld a,0x7f-5
        ld bc,0xbff7
        out (c),a           ; 4,5,0
        ld a,0x7f-4
        ld b,0xff
        out (c),a           ; 4,5,4
        ld hl,0xc000
        ld de,0x8000
        ld bc,0x4000
        ldir                ; pg4 -> pg5
        ld a,0x7f-8         ; pgtrdosfs
        ld bc,0xfff7
        out (c),a           ; 4,5,8
        ld hl,0x1c00+0xc000
        ld de,0x1c00+0x8000
        ld bc,0x400
        ldir                ; restore sysvars
        ld a,0x7f-2
        ld bc,0xbff7
        out (c),a
        ld a,0x7f-1
        ld b,0xff
        out (c),a
        ld hl,0xc000
        ld de,0x8000
        ld bc,0x4000
        ldir                ; pg1 -> pg2
        ld a,0x7f-0+0x80
        ld bc,0xfff7
        out (c),a
        xor a
        ld bc,0x7ffd
        out (c),a
        ld a,0x81           ; 128 BASIC (with 7ffd)
        ld bc,0x3ff7
        out (c),a
        ld a,0x7f-5
        ld b,0x7f
        out (c),a
; 128: pages DOS,5,2,0(7ffd)
        ld a,0x10
        ld bc,0x7ffd
        out (c),a
; 48 setup
        ld a,0x7f-5
        ld bc,0x7ff7
        out (c),a
        ld a,0x7f-2
        ld b,0xbf
        out (c),a
        ld a,0x7f-0+0x80
        ld b,0xff
        out (c),a
        ld a,0x83           ; 48 BASIC switchable to DOS
        ld b,0x3f
        out (c),a
; 48: pages DOS,5,2,0(7ffd)

        ld a,0b10101011     ; 6912
        ld bc,0xff77        ; shadow ports off, palette off
        out (c),a
        ld sp,0x6000
        ld iy,23610
        ld a,0xc9
        ld (0x5cc2),a
        ei
hobetarunner_jp=$+1
        jp 0x6000
        ent
hobetarunner_sz=$-washobetarunner

cmd_end
        display "hobeta size ",/d,cmd_end-cmd_begin," bytes"
        assert cmd_end < 0x4000

        savebin "hobeta.com",cmd_begin,cmd_end-cmd_begin
