setpgmainc000
pgmainc000=$+1
        ld a,0
        SETPG32KHIGH
        ret

setpgsmain40008000
pgmain4000=$+1
        ld a,0
        SETPG16K
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

setpgsscr8000c000
        call getuser_scr_low
        SETPG32KLOW
        call getuser_scr_high
        SETPG32KHIGH
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
curborder=$+1
         ld a,0
         ld (int_curborder),a
        ret
        
