OPL4_DEVICE_ID = 0x20
OPL4_MAX_RAM_BANK  = 64
OPL4_MAGIC_NUMBER  = 123
OPL4_MAGIC_NUMBER_INVERT = 321



init_opl4_device:
                switch_to_pcm_ports_c2_c3
                ld hl,msg_detect_opl4
                call print_hl

                call opl4_detect
                jr z,.detected



                ld hl,msg_opl_not_detected
                jp printerrorandexit
;                call print_hl        
 ;               jp $
.detected

;                call opl4init

                call opl4_reset


                ld hl,msg_opl_is_detected
                call print_hl

                

              call opl4_sample_ram_banks        
        
                ld l,a
                ld h,0
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL   ;*64
                call printushort_hl

                ld hl,msg_opl_is_detected2
                call print_hl



;                call print_nl
                
                call opl4_reset

                ld bc,15
        	ld d,0
        	ld hl,0x1200
        	ld ix,oplbuff
        	call opl4readmemory
        
        	ld b,15
        	ld de,rom001200
                call cmpmem
                and a
                jp z,firmwareproblem
        
        	ld bc,2
        	ld d,0x1f
        	ld hl,0xfffe
        	ld ix,oplbuff
        	call opl4readmemory
                ld a,(oplbuff)
                cp 1
                jp nz,noYRW801
                add a,"0"
                ld (romYRW801mes_v1),a
                ld a,(oplbuff+1)
                add a,"0"
                ld (romYRW801mes_v2),a
                ld hl,romYRW801mes
                call print_hl
                jp print_nl




firmwareproblem:
                pop hl
                ld hl,firmwareerrorstr
                jp printerrorandexit

noYRW801:
                pop hl
                ld hl,noYRW801mes
                jp printerrorandexit


;---------------------------
cmpmem:
   ;in b- chars to compare
   ;de - control value
   ;ix - string what we should check
.cmploop
	ld a,(de)
	cp (ix)
	jr nz,.notf
	inc de
	inc ix
	djnz .cmploop
        ld a,1
        ret 
.notf
         or a
        ret









opl4_detect:
;out Z is set = Moonsound present Z is unset = no moonsound
                ld e,0x05
                ld d,0x03
                call opl4writefm2

        	ld e,0x02
                	opl4_wait
                	ld a,e
                	out (MOON_WREG),a
                call opl4readwave
                and 0xe0  ;0xef


                push af
                        ld e,0x05
                        ld d,0x00
                        call opl4writefm2
                pop af
                cp OPL4_DEVICE_ID
                ret



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



opl4_sample_ram_banks:

  /* Set custom sample headers to 16Mb area and READ/WRITE mode */
        ld e,0x02
        ld d,0x11
        call opl4writewave

  /* Detect the number of 64K banks of RAM available */


                xor a
                ld (.result),a
        
                ld b,0
.dloop
                push bc
    /* Write block number to corresponding OPL4 RAM address */                
                ld a,0
.result equ $-1
                and a
                jp nz,.exit_loop

                ld a,0x20:add a,b:ld d,a
                ld e,0x03
                call opl4writewave                              /* Register 3: memory addres bits 16-21 */
                ld de,0x0004                                    
                call opl4writewave                              /* Register 4: memory addres bits 08-15 */
                ld de,0x0005
                call opl4writewave                              /* Register 5: memory addres bits 00-07 */
                ld a,OPL4_MAGIC_NUMBER:add a,b:ld d,a
                ld e,0x06
                call opl4writewave                              


                ld a,0x20:add a,b:ld d,a
                ld e,0x03
                call opl4writewave                              /* Register 3: memory addres bits 16-21 */
                ld de,0x0004                                    
                call opl4writewave                              /* Register 4: memory addres bits 08-15 */
                ld de,0x0105
                call opl4writewave                              /* Register 5: memory addres bits 00-07 */
                ld a,OPL4_MAGIC_NUMBER_INVERT:add a,b:ld d,a
                ld e,0x06
                call opl4writewave                              


    /* Read back the number from the same location and check */
                ld a,0x20:add a,b:ld d,a
                ld e,0x03
                call opl4writewave                              /* Register 3: memory addres bits 16-21 */
                ld de,0x0004                                    
                call opl4writewave                              /* Register 4: memory addres bits 08-15 */
                ld de,0x0005
                call opl4writewave                              /* Register 5: memory addres bits 00-07 */


                ld a,OPL4_MAGIC_NUMBER
                add a,b
                ld d,a

                ld e,0x06
                call opl4readwave
                cp d
                jr z,.nxt_lop

                  ld a,b
                  ld (.result),a
                  jr z,.exit_loop

    /* Check if one of the earlier found banks has been overwritten */


.nxt_lop
                ;count b - backwards
                        ld c,b

.inrloop
                ld a,0x20:add a,c:ld d,a
                ld e,0x03
                call opl4writewave                              /* Register 3: memory addres bits 16-21 */
                ld de,0x0004                                    
                call opl4writewave                              /* Register 4: memory addres bits 08-15 */
                ld de,0x0005
                call opl4writewave                              /* Register 5: memory addres bits 00-07 */

                ld a,OPL4_MAGIC_NUMBER
                add a,c
                ld d,a

                ld e,0x06
                call opl4readwave
                cp d
                jr z,.nxt_lop2
                ld a,c
                ld (.result),a
                pop bc
                jp .dloop

.nxt_lop2
                dec c
                ld a,c
                cp 0xff
                jr nz,.inrloop


                pop bc
                inc b
                ld a,b
                cp OPL4_MAX_RAM_BANK+1
                jp c,.dloop
                jr .exit_loop1

.exit_loop:
                
                pop bc
.exit_loop1:
  /* Set custom sample headers to 16Mb area and PLAY mode*/
                ld d,0x10
                ld e,0x02
                call opl4writewave
                ld a,(.result)
                ret





opl4_write_fm_register_array_1:
.to_fm
        jp opl4writefm1
        
opl4_write_fm_register_array_2:
        jp opl4writefm2

msg_detect_opl4:
                db    "\n\rDetecting OPL4      device",0
msg_opl_not_detected:
                db " ...Not Found",0

msg_opl_is_detected:
                db " ...Found, sample memory: ",0
msg_opl_is_detected2   db "K",0