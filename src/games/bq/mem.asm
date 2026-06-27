setpgmainc000
pgmainc000=$+1
        ld a,0
        SETPG32KHIGH
        ret

setpg14000
        call getuser_scr_low_cur ;ld a,(user_scr0_high) ;ok
        SETPG4000
        ret
setpg54000
        call getuser_scr_high_cur ;ld a,(user_scr0_high) ;ok
        SETPG4000
        ret

setpgmain4000
pgmain4000=$+1
        ld a,0
        SETPG4000
        ret

setpgsmain40008000
        call setpgmain4000
pgmain8000=$+1
        ld a,0
        SETPG32KLOW
        ret

setpgsscr40008000_current
        call getuser_scr_low_cur
        SETPG16K
        call getuser_scr_high_cur
        SETPG32KLOW
        ret

setpgsscr40008000
        call getuser_scr_low
        SETPG16K
        call getuser_scr_high
        SETPG32KLOW
        ret

setpgscrlow4000
        call getuser_scr_low
        SETPG16K
        ret

setpgscrhigh4000
        call getuser_scr_high
        SETPG16K
        ret

getuser_scr_low
getuser_scr_low_patch=$+1
getuser_scr_low_patchN=0xff&(user_scr0_low^user_scr1_low)
        ld a,(user_scr1_low) ;ok
        ret

getuser_scr_high
getuser_scr_high_patch=$+1
getuser_scr_high_patchN=0xff&(user_scr0_high^user_scr1_high)
        ld a,(user_scr1_high) ;ok
        ret

getuser_scr_low_cur
getuser_scr_low_cur_patch=$+1
getuser_scr_low_cur_patchN=0xff&(user_scr0_low^user_scr1_low)
        ld a,(user_scr0_low) ;ok
        ret

getuser_scr_high_cur
getuser_scr_high_cur_patch=$+1
getuser_scr_high_cur_patchN=0xff&(user_scr0_high^user_scr1_high)
        ld a,(user_scr0_high) ;ok
        ret

;p14=#14 ;экр0 слой0
;p15=#15 ;экр0 слой1
;p16=#16 ;экр1 слой0 (выводится экр0)
;p17=#17 ;экр1 слой1
OUTp14
        call getuser_scr_low_cur ;ld a,(user_scr0_low) ;ok
        SETPGC000
        ret
OUTp15
        call getuser_scr_high_cur ;ld a,(user_scr0_high) ;ok
        SETPGC000
        ret
OUTp16
        call getuser_scr_low ;ld a,(user_scr1_low) ;ok
        SETPGC000
        ret
OUTp17
        call getuser_scr_high ;ld a,(user_scr1_high) ;ok
        SETPGC000
        ret

changescrpg_current
        ld hl,getuser_scr_low_patch
        ld a,(hl)
        xor getuser_scr_low_patchN
        ld (hl),a
        ld hl,getuser_scr_high_patch
        ld a,(hl)
        xor getuser_scr_high_patchN
        ld (hl),a
        ld hl,getuser_scr_low_cur_patch
        ld a,(hl)
        xor getuser_scr_low_cur_patchN
        ld (hl),a
        ld hl,getuser_scr_high_cur_patch
        ld a,(hl)
        xor getuser_scr_high_cur_patchN
        ld (hl),a

        ld a,1
curscrnum=$+1
        xor 0
        ld ($-1),a
        ret
        
changescrpg
        call changescrpg_current
        ld (curscrnum_int),a
        ret
        
