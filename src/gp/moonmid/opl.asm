opl4_reset:
/* Set to OPL4 mode */
        ld de,0x0305
        call     opl4_write_fm_register_array_2
        
/* Reset FM registers */
        ld de,0x0001
        call opl4_write_fm_register_array_1
        ld de,0x0002
        call opl4_write_fm_register_array_1
        ld de,0x0003
        call opl4_write_fm_register_array_1
        ld de,0x0004
        call opl4_write_fm_register_array_1
        ld de,0x0008
        call opl4_write_fm_register_array_1    
        
        ld de,0x0001
        call opl4_write_fm_register_array_2
        ld de,0x0002
        call opl4_write_fm_register_array_2
        ld de,0x0003
        call opl4_write_fm_register_array_2
        ld de,0x0004
        call opl4_write_fm_register_array_2
        ld de,0x0008
        call opl4_write_fm_register_array_2    


    
        ld e,0x14
.rloop
        push de
        ld  d,0
        
        ld a,e
        cp 0x60
        jr c,.rlcont1
        cp 0xa0
        jr nc,.rlcont1                
        ld d,0xff
.rlcont1       
        push de
        call opl4_write_fm_register_array_1
        pop de
        call opl4_write_fm_register_array_2        
        pop de
        inc e
        ld a,e
        cp 0xf6
        jr c,.rloop
    
    

/* Set mix control */
        ld de,0x1bf8
        call opl4writewave
        ld de,0x00f9
        call opl4writewave
        
        
/* Reset WAVE registers */
        ld de,0x4068
        ld b,OPL4MAXWAVECHANNELS
        opl4_write_wave_regs
        
        
/* Reset timer flags */
        ld de,0x8004
        call opl4_write_fm_register_array_1




        ld de,0xff03
        call opl4writefm1
        ld de,0x4204
        call opl4writefm1
        ld de,0x8004
        jp opl4writefm1

opl4_write_fm_register_array_1:
.to_fm
        jp opl4writefm1
        
opl4_write_fm_register_array_2:
        jp opl4writefm2