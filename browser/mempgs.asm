setpghist
histpg=$+1
	ld a,0
	SETPG32KHIGH
	ret

setpgdiv4000
codepg8000=$+1
        ld a,0 ;tdiv
        SETPG16K ;0x4000
        ret
        
setpgcode4000
codepg4000=$+1
        ld a,0
        SETPG16K
        ret

setpgtemp8000
temppg8000=$+1
        ld a,0
        SETPG32KLOW
        ret

setpgs_scr
        call setpgscr8000
setpgscrc000
setpgs_scr_high=$+1
        ld a,0;pgscr0_1 ;scr0_1
        SETPG32KHIGH
        ret
setpgscr8000
setpgs_scr_low=$+1
        ld a,0;pgscr0_0 ;scr0_0
        SETPG32KLOW
        ret

