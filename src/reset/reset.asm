        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
cmd_begin
        ld sp,0x4000
        
        ld e,3 ;6912
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        YIELD ;set palette

        ;OS_GETSCREENPAGES
;de=pages of screen 0 (d=higher page), hl=pages of screen 1 (h=higher page)
        ld a,(user_scr0_low) ;ok
        ld (cmdpgscreen0_0),a

hobetarunner=#4100
        ld a,(cmdpgscreen0_0)
	sub 4-1 ;ld a,#ff-4 ;pgkillable
	SETPG16K

        ld hl,washobetarunner
        ld de,hobetarunner
        ld bc,hobetarunner_sz
        ldir
cmdpgscreen0_0=$+1
	ld a,#ff-1
	SETPG32KLOW
        inc a ;ld a,#ff-0
	SETPG32KHIGH

        ;call loadhobeta
        ;ret nz ;error
        ;ld hl,#6000
        ;ld bc,(#6000-17+11) ;len
        ;add hl,bc
        ;dec hl ;hl=load end
        ;ex de,hl
        ;ld hl,(#6000-17+9) ;start
        ;ld (hobetarunner_jp),hl
        ;add hl,bc
        ;dec hl
        ;ex de,hl ;de=destination end
        ;lddr
	jp hobetarunner

washobetarunner
;pgsys=pagexor-10
;pgfatfs=pagexor-9
;pgtrdosfs=pagexor-8
;pgkillable=pagexor-4 ;в 128K памяти, т.к. можно портить
	disp hobetarunner ;in pgkillable
;$c loaded in pages 4,1,0
;only ATM2 ports here!
	di
	ld a,#7f-5
        ld bc,#bff7
	out (c),a
	ld a,#7f-4
        ld bc,#fff7
	out (c),a
        ld hl,#c000
        ld de,#8000
        ld bc,#4000
        ldir ;pg4 -> pg5
	ld a,#7f-8;pgtrdosfs
        ld bc,#fff7
	out (c),a
        ld hl,#1c00+#c000
        ld de,#1c00+#8000
        ld bc,#400
        ldir ;restore sysvars
	ld a,#7f-2
        ld bc,#bff7
	out (c),a
	ld a,#7f-1
        ld bc,#fff7
	out (c),a
        ld hl,#c000
        ld de,#8000
        ld bc,#4000
        ldir ;pg1 -> pg2
	ld a,#7f-0+#80
	ld bc,#fff7
	out (c),a
	ld a,#00
	ld bc,#7ffd
	out (c),a
	ld a,#81 ;128 basic (with 7ffd)
	ld bc,#3ff7
	out (c),a
	ld a,#7f-5
	ld bc,#7ff7
	out (c),a
;128: pages 128/DOS,5,2,0(7ffd)
	ld a,#10
	ld bc,#7ffd
	out (c),a
;48: pages 2,4,4,4
	ld a,#7f-5
	ld bc,#7ff7
	out (c),a
	ld a,#7f-2
        ld bc,#bff7
	out (c),a
	ld a,#7f-0+#80
        ld bc,#fff7
	out (c),a
	ld a,#83 ;48 basic switchable to DOS
	ld bc,#3ff7
	out (c),a
;48: pages 48/DOS,5,2,0(7ffd)
        
        LD A,%10101011 ;6912
	ld bc,#ff77 ;shadow ports off, palette off
        out (c),a
	ld sp,#6000
    
    
    ld a,0x10
    ld bc,#7ffd
    out (c),a ;for 128 basic (проверено, работает, 48 тоже работает)
    ld a,(0x3CBC)
    cp 0x87
    call z,0x3C9E   ;переключить в vtrdos
    ld bc,0x0001    ;хотресет втрдоса, на всякий случай, может и ненадо
    call 0x3D42
    
    
         ld a,0
         ld bc,#7ffd
         out (c),a ;for 128 basic (проверено, работает, 48 тоже работает)
	ei
hobetarunner_jp=$+1
	jp 0;#6000
        ent
hobetarunner_sz=$-washobetarunner

cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "reset.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
