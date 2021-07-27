        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
cmd_begin
        ld sp,0x4000
        
        ld e,3 ;6912
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        YIELD ;set palette
        OS_GETMAINPAGES
        ld (reset_hook_place+5),de
        ld (reset_hook_place+7),hl

        ;OS_GETSCREENPAGES
;de=pages of screen 0 (d=higher page), hl=pages of screen 1 (h=higher page)
        ld a,(user_scr0_low) ;ok
        ld (cmdpgscreen0_0),a

hobetarunner=0x4100

    OS_GETCONFIG
    ld d,l
    ld a,l    
    cp 1
    jr nz,no_eva

    OS_SETSYSDRV
    ld sp,0x0000
    ld hl,nmisvc_starter
    ld de,0x0080
    ld bc,nmisvc_starter_size
    ldir
    ld de,str_nmisvc
    OS_OPENHANDLE
    jp nmisvc_start
    
nmisvc_starter
    disp 0x0080
str_nmisvc
    defb "/bin/nmisvc.com",0
nmisvc_start
    push bc
        ld de,0x0100
        ld hl,0xc000
        OS_READHANDLE
    pop bc
    OS_CLOSEHANDLE
    jp PROGSTART
    ent
nmisvc_starter_size=$-nmisvc_starter

no_eva    
    ld (pcconf),a
    ld c,0xff
    cp 2
    jr z,atm_1f
    cp 3
    jr nz,not_atm_1f
atm_1f
    ld c,0x7f
    ld d,0
not_atm_1f
    ld (reset_hook_place+3),de
    ld a,0x1f^0xff
    and c
    SETPGC000
    ld hl,reset_hook_place
    ld de,0xc000
    ld bc,reset_hook_end - reset_hook_begin
    ldir
    ld hl,0xaa55
    ld (0xfffe),hl
    xor a
    ld (0xfffd),a
    ld hl,0xc000
    ld e,a
hook_crc_loop
    add a,(hl)
    adc a,e
    inc hl
    bit 7,h
    jr nz,hook_crc_loop
    neg
    ld (0xfffd),a
    di
cmdpgscreen0_0=$+1
	ld a,0xff-1
	SETPG32KLOW
        inc a ;ld a,0xff-0
	SETPG32KHIGH


    ld a,(cmdpgscreen0_0)
    sub 4-1 ;ld a,0xff-4 ;pgkillable
    SETPG16K

    ld hl,washobetarunner
    ld de,hobetarunner
    ld bc,hobetarunner_sz
    ldir
    jp hobetarunner

    
washobetarunner
	disp hobetarunner ;in pgkillable
	di
	ld a,0x7f-5
        ld bc,0xbff7
	out (c),a
	ld a,0x7f-4
        ld bc,0xfff7
	out (c),a
        ld hl,0xc000
        ld de,0x8000
        ld bc,0x4000
        ldir ;pg4 -> pg5
	ld a,0x7f-8;pgtrdosfs
        ld bc,0xfff7
	out (c),a
        ld hl,0x1c00+0xc000
        ld de,0x1c00+0x8000
        ld bc,0x400
        ldir ;restore sysvars
	ld a,0x7f-2
        ld bc,0xbff7
	out (c),a
	ld a,0x7f-1
        ld bc,0xfff7
	out (c),a
        ld hl,0xc000
        ld de,0x8000
        ld bc,0x4000
        ldir ;pg1 -> pg2
	ld a,0x7f-0+0x80
	ld bc,0xfff7
	out (c),a
	ld a,0x00
	ld bc,0x7ffd
	out (c),a
	ld a,0x01 ;128 basic (with 7ffd)
	ld bc,0x3ff7
	out (c),a
	ld a,0x7f-5
	ld bc,0x7ff7
	out (c),a
;128: pages 128/DOS,5,2,0(7ffd)
	ld a,0x10
	ld bc,0x7ffd
	out (c),a
;48: pages 2,4,4,4
	ld a,0x7f-5
	ld bc,0x7ff7
	out (c),a
	ld a,0x7f-2
        ld bc,0xbff7
	out (c),a
	ld a,0x7f-0+0x80
        ld bc,0xfff7
	out (c),a
	ld a,0x83 ;48 basic switchable to DOS
	ld bc,0x3ff7
	out (c),a
;48: pages 48/DOS,5,2,0(7ffd)
        
        LD A,%10100011 ;6912
	ld bc,0xff77 ;shadow ports off, palette off
        out (c),a
	ld sp,0x6000
    	ld bc,0xeff7
    	ld a,0x10
    	out (c),a
    	
    ld a,0x10
    ld bc,0x7ffd
    out (c),a ;for 128 basic (проверено, работает, 48 тоже работает)
pcconf=$ - hobetarunner + washobetarunner + 1
    ld a,1
    cp 2
    jr z,set_xbios
    cp 3
    jr nz,not_set_xbios
set_xbios
    ld a,(0x3CBC)
    cp 0x87
    call z,0x3C9E   ;переключить в vtrdos
not_set_xbios   
    ld a,0
    ld bc,0x7ffd
    out (c),a ;for 128 basic (проверено, работает, 48 тоже работает)
    ld a,7
    out (0xfe),a
    ld hl,0
    push hl
	ei
hobetarunner_jp=$+1
	jp 0 ;0x3d2f ;0;0x6000
;АТМный перехватчик ресета
        ent
hobetarunner_sz=$-washobetarunner

reset_hook_place
    disp 0xc000
reset_hook_begin
    jp reset_hook_start
    defs 10
reset_hook_start
    di
    xor a
    ld (reset_hook_begin),a
    ld hl,reset_hook_begin
    ld de,0x8000
    ld bc,reset_hook_end - reset_hook_begin
    ldir
    jp $ + 3 - 0x4000
    ld a,0x57
    ld bc,0x7ffd
    out (c),a
    ld de,(0x8003)
    ld iy,0x3f7f
    ld ix,0xbfff
    dec d
    inc d
    jr z,rest_atm2
    ld iy,0x3777
    ld ix,0xb7f7
rest_atm2
    ld a,0x7f
    ld bc,0x3FF7
    out (c),a
    ld b,iyh
    out (c),e
    ld e,0x7b
    ld b,0x7f
    out (c),e
    ld b,0xff
    out (c),e
    ld e,0x47
    ld bc,0x7ffd
    out (c),e
    ld hl,(0x8005)
    ld bc,0x3FF7
    out (c),a
    ld b,iyh
    out (c),h
    ld b,0x7F
    out (c),a
    ld b,iyl
    out (c),l
    ld hl,(0x8007)
    ld b,0xfF
    out (c),a
    ld b,ixl
    out (c),l
    ld bc,0xbd77
    ld a,0xae
    out (c),a
    ld sp,0x4000
    im 1
    ei
    jp 0x0000
    
reset_hook_end
        ent
    nop
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "reset.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
