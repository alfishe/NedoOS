        DEVICE ZXSPECTRUM48
        include "../../_sdk/sys_h.asm"


        macro BRIGHTBYTE x
_=x
        if _>15
_=15
        endif
_g0=~_&1
_g1=(~_>>1)&1
_g2=(~_>>2)&1
_g3=(~_>>3)&1
;0g20G3G3
        ;db _
        db (_g0<<6)+(_g2<<5)+(_g1<<3)+(_g3<<2)+(_g1<<1)+(_g3<<0)
        endm



        org PROGSTART
cmd_begin
        ld sp,0x4000




        ld e,6+0x80  //set TEXT mode  keep
        OS_SETGFX
        
        ld e,0
        OS_CLS




        OS_GETMAINPAGES
        ;dehl= o 0000,4000,8000,c000
        ld a,d
        ld (winpage0),a
        ld a,e
        ld (winpage1),a
        ld a,h
        ld (winpage2),a
        ld a,l
        ld (winpage3),a

        ;d=pgmain0000
        call dropotherapps ;OS_HIDEFROMPARENT
        call setpgsmain4000_C000



        ld de,res_path
        OS_CHDIR
        or a
        jp nz,dirchangeerror


        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (winpage11),a


        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (winpage13),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (winpage14),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (winpage16),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (winpage17),a


        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (vidbuf),a


;-------------pre-setup. choose game version
        ld hl,pre_setup
        call print_hl

setup_lp:        
        YIELDGETKEYLOOP
        cp "1"
        jr z,setup_is1
        cp "2"
        jr z,setup_is2
        jr setup_lp
setup_is1:
          xor a
          jr setup_set
setup_is2:
         ld a,1
          jr setup_set
setup_set:
        ld (mode),a

        and a
        jp z,skip_dfclt_setup

;---------------------------------------------------
        ld hl,difficulty_setup
        call print_hl
setup_df:        
        YIELDGETKEYLOOP
        cp "1"
        jr z,setup_df1
        cp "2"
        jr z,setup_df2
        cp "3"
        jr z,setup_df3
        cp "4"
        jr z,setup_df4
        jr setup_lp
setup_df1:
          xor a
          jr setup_df_set
setup_df2:
         ld a,1
          jr setup_df_set
setup_df3:
         ld a,2
          jr setup_df_set
setup_df4:
         ld a,3
          jr setup_df_set
setup_df_set:
        ld (difficulty),a
;---------------------------------------------------

skip_dfclt_setup:
        ld a,(mode)
        and a
        jp z,scr_unmodded
; modded - load ega screen         

                        ld e,0+0x80  //set EGA mode  keep
                        OS_SETGFX
                        
                        ld e,0
                        OS_CLS
                        
                        ld de,blackpal
                        OS_SETPAL
                        
                        
                        ld a,(user_scr1_low)
                        SETPG8000 
                        ld a,(user_scr1_high)
                        SETPGC000 

                        ld e,1
                        OS_SETSCREEN

                         ld de,scr16c
                         call openstream_file
                         ld hl,0x8000 ;len
                         ld de,0x8000 ;where 
                         call readstream_file
                         ld hl,32
                         ld de,pal
                         call readstream_file
                         call closestream_file
                
                          call palette_precalc
                          call fade_fromblack



                        ld e,0+8+0x80  //set EGA no turbo mode  keep
                        OS_SETGFX
                        
                        jp cont_load1

scr_unmodded:
                                ;set mode
                                ld e,3+0x80  //set 6912 mode keep
                                OS_SETGFX
                        
                        
                                ld a,(user_scr0_high)
                                SETPG4000
                                ld a,(winpage2)
                                SETPG8000
                        
                                 ld e,0
                                 OS_CLS
                                 ld e,0
                                 OS_SETSCREEN
                                 ld de,stdpal
                                 OS_SETPAL   


                                ld hl,0x4000
                                ld de,0x4001
                                ld (hl),l
                                ld bc,6143
                                ldir        


                                ld hl,0x5800
                                ld de,0x5801
                                ld (hl),l
                                ld bc,767
                                ldir


                                 ld de,scr6912
                                 call openstream_file
                                         ld hl,6144 ;len
                                         ld de,0x4000 ;where 
                                         call readstream_file
                        
                                         ld hl,768
                                         ld de,0x8000 ;where 
                                         call readstream_file
                                 call closestream_file


                                ld e,3+8+0x80  //set 6912 mode keep
                                OS_SETGFX
                                call fade_fromblack6912
cont_load1:
         ld a,(winpage11)
         SETPGC000
         ld de,f_name11
         call openstream_file
         ld hl,0x4000 ;len
         ld de,0xc000 ;where 
         call readstream_file
         call closestream_file

;-------------ram11 patch
               ld a,(mode)
                and a
                jr z,skip_ram11_patch 
                                ;org 0xc35c
                                ;call inert
                        ld de,inert
                        ld hl,0xc35c
                        ld (hl),0xcd
                        inc hl:ld (hl),e
                        inc hl:ld (hl),d


                  ld de,set_next_difficulty
                  ld hl,0xc347
                  ld (hl),0x00 : inc hl
                  ld (hl),0x00 : inc hl
                  ld (hl),0x00 : inc hl
                  ld (hl),0xcd : inc hl
                  ld (hl),e    : inc hl
                  ld (hl),d    : inc hl 
;------------------------------------------
skip_ram11_patch:

         ld a,(winpage13)
         SETPGC000
         ld de,f_name13
         call openstream_file
         ld hl,0x4000 ;len
         ld de,0xc000 ;where 
         call readstream_file
         call closestream_file
;-------------ram 13 patch
                            ;org 0xe060
                            ;ld b,6   ;menu lines count+1
                            ;ld hl,controls_menu
                
                            ;org 0xe075
                            ;jp menu_keyscan_mod

                ld de,controls_menu
                ld hl,0xe060
                ld (hl),6
                inc hl
                ld (hl),6
                inc hl:ld (hl),0x21
                inc hl:ld (hl),e
                inc hl:ld (hl),d

                ld de,menu_keyscan_mod
                ld hl,0xe075
                ld (hl),0xc3
                inc hl:ld (hl),e
                inc hl:ld (hl),d


                  ld de,set_difficulty
                  ld hl,0xe251
                  ld (hl),0x00 : inc hl
                  ld (hl),0x00 : inc hl
                  ld (hl),0x00 : inc hl
                  ld (hl),0xcd : inc hl
                  ld (hl),e    : inc hl
                  ld (hl),d    : inc hl 
;------------------------------------------
         ld a,(winpage14)
         SETPGC000
         ld de,f_name14
         call openstream_file
         ld hl,0x4000 ;len
         ld de,0xc000 ;where 
         call readstream_file
         call closestream_file


         ld a,(winpage16)
         SETPGC000
         ld de,f_name16
         call openstream_file
         ld hl,0x4000 ;len
         ld de,0xc000 ;where 
         call readstream_file
         call closestream_file

;-------------ram16 patch
               ld a,(mode)
                and a
                jr z,skip_ram16_patch 
                        ld de,fix_stun_ram16_1
                        ld hl,0xe6fa
                        ld (hl),0xcd : inc hl
                        ld (hl),e    : inc hl
                        ld (hl),d

                        ld de,fix_stun_ram16_2
                        ld hl,0xe70a
                        ld (hl),0xcd : inc hl
                        ld (hl),e    : inc hl
                        ld (hl),d
;------------------------------------------
skip_ram16_patch:
         ld a,(winpage17)
         SETPGC000
         ld de,f_name17
         call openstream_file
         ld hl,0x4000 ;len
         ld de,0xc000 ;where 
         call readstream_file
         call closestream_file


        ld a,(mode)
        and a
        jp z,skip_mid_scr
              

                        ld e,0+0x80  //set EGA mode  keep
                        OS_SETGFX

                         call fade_toblack      



                        ;set mode
                        ld e,3+0x80  //set 6912 mode keep
                        OS_SETGFX
                
                
                        ld a,(user_scr0_high)
                        SETPG4000
                        ld a,(winpage2)
                        SETPG8000
                
                         ld e,0
                         OS_CLS
                         ld e,0
                         OS_SETSCREEN
                         ld de,stdpal
                         OS_SETPAL   



                                ld hl,0x4000
                                ld de,0x4001
                                ld (hl),l
                                ld bc,6143
                                ldir        


                                ld hl,0x5800
                                ld de,0x5801
                                ld (hl),0x47
                                ld bc,767
                                ldir



        ld hl,0x4000
        ld (VP_ADR1),hl
        ld (VP_ADR2),hl
        ld (VP_ADR3),hl


        ld de,intro
        call vid_load_play


        ld hl,0x4021
        ld (VP_ADR1),hl
        ld (VP_ADR2),hl
        ld (VP_ADR3),hl



                                ld hl,0x4000
                                ld de,0x4001
                                ld (hl),l
                                ld bc,6143
                                ldir        


                                ld hl,0x5800
                                ld de,0x5801
                                ld (hl),l
                                ld bc,767
                                ldir

         ld de,scr6912
         call openstream_file
                 ld hl,6144 ;len
                 ld de,0x4000 ;where 
                 call readstream_file

                 ld hl,768
                 ld de,0x8000 ;where 
                 call readstream_file
         call closestream_file



                ld e,3+8+0x80  //set 6912 mode keep
                OS_SETGFX

                call fade_fromblack6912

skip_mid_scr:
         ld a,(winpage3)
         SETPGC000
         ld de,f_name_main
         call openstream_file
         ld hl,0x8000 ;len
         ld de,0x7404 ;where 
         call readstream_file
         call closestream_file


        call fade_toblack6912
;------------------ main patch
        		;org 0x7a62         ;  (615e)
        		;ld a,3
        		;call select_page
        		;nop:nop        

        		;org #7a70         ;    (616d)
                        ;xor a
         		;jp select_page
                  ld de,select_page
                  ld hl,0x7a62
                  ld (hl),0x3e: inc hl
                  ld (hl),0x03: inc hl
                  ld (hl),0xcd: inc hl
                  ld (hl),e   : inc hl
                  ld (hl),d   : inc hl
                  ld (hl),0: inc hl
                  ld (hl),0

                  ld hl,0x7a70
                  ld (hl),0xaf:inc hl
                  ld (hl),0xc3:inc hl
                  ld (hl),e   : inc hl
                  ld (hl),d   : inc hl

                          ;      ORG #9BEE
                          ;      CALL select_page
                                
                          ;      ORG #9C2A
                          ;      CALL select_page

                  ld de,select_page
                  ld hl,0x9bee
                  ld (hl),0xcd: inc hl
                  ld (hl),e   : inc hl
                  ld (hl),d   : inc hl

                  ld hl,0x9c2a
                  ld (hl),0xcd: inc hl
                  ld (hl),e   : inc hl
                  ld (hl),d   : inc hl


                                ;org 0x9c4c        
                                ;di
                                ;ds 3,0
                                ;call pg_transfer
                                ;ds 7,0
                                
                                ;org 0x9c7f
                                ;jp setpg0

                  ld de,pg_transfer
                  ld hl,0x9c4c
                  ld (hl),0xf3:inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0xcd:inc hl
                  ld (hl),e   : inc hl
                  ld (hl),d   : inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0x00:inc hl
                  ld (hl),0x00:inc hl

                  ld de,setpg0
                  ld hl,0x9c7f
                  ld (hl),0xc3:inc hl
                  ld (hl),e   : inc hl
                  ld (hl),d   : inc hl

                              ;  org 0xaa78
                              ;  ld b,6   ;menu lines count+1
                              ;  ld hl,controls_menu
                                
                              ;  org 0xaa8d
                              ;  jp menu_keyscan_mod
                ld de,controls_menu
                ld hl,0xaa78
                ld (hl),6:inc hl
                ld (hl),6:inc hl
                ld (hl),0x21:inc hl
                ld (hl),e:inc hl
                ld (hl),d

                ld de,menu_keyscan_mod
                ld hl,0xaa8d
                ld (hl),0xc3 : inc hl
                ld (hl),e    : inc hl
                ld (hl),d
;-------------------------------------
                                                            ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                ;;  first level hack
                                                                       ; org 0xac32   ;ram3 conatains level 0 and restores after death
                ;      ld hl,0xac32
                ;      ld (hl),8

                                                            
               ;immunity cheat
               ;      ld hl,0x9a74
               ;      ld (hl),0xc9

                                                            ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
               ;restore sound effect 1
               ;      ld hl,0x7bec        ;;after init - 62e8   
               ;      ld (hl),0x18

                ld a,(mode)
                and a
                jp z,0x8134
;--modded patch

                                ;  ORG #798A                ;(0x6086)
                		;  CALL p_manager

                  ld de,p_manager
                  ld hl,0x798a
                  ld (hl),0xcd:inc hl
                  ld (hl),e   : inc hl
                  ld (hl),d   : inc hl

                                ; ORG 0x7E37 ;(6533)  ;ОБРАБОТЧИК УРОВНЯ 9 (JP Z,#7F55)
                                ; JP Z,level9_video

                  ld de,level9_video
                  ld hl,0x7e37
                  ld (hl),0xca : inc hl
                  ld (hl),e    : inc hl
                  ld (hl),d    : inc hl        

                               ; org 0x7dcf  ;0x64cb 0     
                               ; nop:nop
                               ; call fix_stun

                  ld de,fix_stun
                  ld hl,0x7dcf
                  ld (hl),0x00 : inc hl
                  ld (hl),0x00 : inc hl
                  ld (hl),0xcd : inc hl
                  ld (hl),e    : inc hl
                  ld (hl),d    : inc hl        



                  ld de,set_difficulty
                  ld hl,0xac69
                  ld (hl),0x00 : inc hl
                  ld (hl),0x00 : inc hl
                  ld (hl),0x00 : inc hl
                  ld (hl),0xcd : inc hl
                  ld (hl),e    : inc hl
                  ld (hl),d    : inc hl            

        jp 0x8134



cmd_quit:
        ;unload resered page

        im 1
        di

        call nomus

;        ld hl,t_vid_file00_pages_list+$FF 
;        call free_vid_file

        ld a,(winpage17)
        ld e,a
        OS_DELPAGE

        ld a,(winpage16)
        ld e,a
        OS_DELPAGE

        ld a,(winpage14)
        ld e,a
        OS_DELPAGE

        ld a,(winpage13)
        ld e,a
        OS_DELPAGE

        ld a,(winpage11)
        ld e,a
        OS_DELPAGE

        ld a,(winpage3)
        ld e,a
        OS_DELPAGE

        ld a,(winpage2)
        ld e,a
        OS_DELPAGE

        ld a,(winpage1)
        ld e,a
        OS_DELPAGE

        ld a,(winpage0)
        ld e,a
        OS_DELPAGE

        ld a,(vidbuf)
        ld e,a
        OS_DELPAGE


        ;set mode
        ld e,6+0x80  //set 6912 mode keep
        OS_SETGFX

        ;fix. robocop modify byte at 0000
        ld a,0x3e
        ld (0),a        
        QUIT

;---------------------------------------
fade_toblack6912:
        ld b,8
.loop_6c1b:
        push bc
        ld hl,0x5800
.loop_6c1f:
        ld a,(hl)
        ld b,a
        and 7
        jr z,.loop_6c26
        dec a
.loop_6c26:
        ld c,a
        ld a,b
        and 0x38
        jr z,.loop_6c2e
        sub 8
.loop_6c2e:
        or c
        ld (hl),a
        inc hl
        ld a,h
        cp 0x5b
        jr nz,.loop_6c1f
        
.loop_l6c39        
        halt
        halt
        pop bc
        djnz .loop_6c1b        
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x1aff
        ld (hl),l
        ldir
        ret




fade_fromblack6912:
        ld b,7
.loop1:
        push bc
        ld hl,0x5800
        ld de,0x8000
        ld bc,768
.loop2:
        push bc
        ld a,(de)
        and 7
        ld c,a
        ld a,(hl)
        ld b,a
        and 7
        cp c
        jr z,.skip_s1
        inc b
        ld (hl),b
.skip_s1:
        ld a,(de)
        and 0x38
        ld c,a
        ld a,(hl)
        ld b,a
        and 0x38
        cp c
        jr z,.skip_s2
        ld a,b
        add a,8
        ld (hl),a
.skip_s2:
        inc hl
        inc de
        pop bc
        dec bc
        ld a,b
        or c
        jr nz,.loop2
        halt
        halt
        pop bc
        djnz .loop1
        ld hl,0x8000
        ld de,0x5800
        ld bc,768
        ldir
        ret        


;<----------------------
fade_toblack:
        ;dec lx
        ld hl,0x2ddd
        xor a
        jp fade_to_sub
fade_fromblack:
        ;inc lx
        ld hl,0x2cdd
        xor a
        jp fade_from_sub




fade_to_sub:
        ld (fade_tocolor),a
        ld (fade_to_op),hl

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;

        call palette_precalc_sub

        ld lx,8
fade0
        dec lx
fade_to_op: equ $-2        
        ld hl,pal_rgb
        ld de,pal
        call recolour
        push ix

;	ld a,1
;	ld (setpalflag),a
        ld de,pal
        OS_SETPAL


	halt
	halt
	halt
        pop ix
        ld a,lx
        cp 0
fade_tocolor: equ $-1
        jr nz,fade0
	halt
	halt
	halt
        ret

;<--------
fade_from_sub:
        ld (fade_fromcolor),a
        ld (fade_from_op),hl


        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;


        call palette_precalc_sub

        ld lx,15
fade_fromcolor: equ $-1


fadew1:
        dec lx
fade_from_op: equ $-2
        ld hl,pal_rgb
        ld de,pal
        call recolour
        push ix

;	ld a,1
;	ld (setpalflag),a
        ld de,pal
        OS_SETPAL


	halt
	halt
	halt
        pop ix
        ld a,lx
        cp 8
        jr nz,fadew1
	halt
	halt
	halt

        ld hl,temppal
        ld bc,32
        ld de,pal
        ldir
;	ld a,1
;	ld (setpalflag),a
        ld de,pal
        OS_SETPAL

        halt
        ret
;<--------
















palette_precalc_sub:
palette_precalc:
                ld hl,pal
                ld de,pal_rgb

                ld b,16
mkpalATM3RGB
                push bc
                ld a,(hl)
                inc hl
                push hl
                ld h,(hl)
                ld l,a
                push de
                
                call calchexcolor ;hl=color (DDp palette) ;out: ;b=B, d=R, e=G
        
                ld a,e ;G
                add a,a
                add a,a
                add a,a
                add a,a
                or d ;R
                pop de
                ld c,a ;GR
                ld a,b
                add a,a
                add a,a
                add a,a
                add a,a
                ld (de),a ;B0
                inc de
                ld a,c
                ld (de),a ;GR
                inc de
                pop hl
                inc hl
                pop bc
                djnz mkpalATM3RGB
                ret


calchexcolor ;hl=color (DDp palette) ;out: ;b=B, d=R, e=G
;keep c!!!
;DDp palette: %grbG11RB(low),%grbG11RB(high)
;high B, high b, low B, low b
                ld b,0;0xff
                ld de,0;0xffff
                ld a,h
               cpl
                rra
                rl b ;B high
                rra
                rl d ;R high
                rra
                rra
                rra
                rl e ;G high
                rra
                rl b ;b high
                rra
                rl d ;r high
                rra
                rl e ;g high
                ld a,l
               cpl
                rra
                rl b ;B low
                rra
                rl d ;R low
                rra
                rra
                rra
                rl e ;G low
                rra
                rl b ;b low
                rra
                rl d ;r low
                rra
                rl e ;g low
;b=B
;d=R
;e=G
        ret


recolour
;hl=palfrom (RGB)
;de=palto (DDp)
;lx=brightness=0..15
        di
        ld (recoloursp),sp
        ld sp,hl
       ld h,tbright/256 ;once
        ld hx,16
bripalATM3
         ;ld a,(hl) ;B0
         ;inc hl
         ;push hl
         ;ld b,(hl) ;GR
       pop bc
       ld a,c
         ;ld h,tbright/256
;de=palto
;h=tbright/256
;lx=brightness
;a,b = B0,GR
         add a,lx
        ld l,a
        ld c,(hl) ;B colour component with brightness
        ld a,b
        and 0xf0
         add a,lx
        ld l,a
        ld a,b
        ld b,(hl) ;G colour component with brightness
        add a,a
        add a,a
        add a,a
        add a,a
         add a,lx
        ld l,a
        ld l,(hl) ;R colour component with brightness

       ld a,b ;G
       rlca ;g??G???? ;G10
       xor l ;R
       and 0b10010000;0b01000010 ;R10
       xor l;gr?G??R?
       rlca ;r?G??R?g
       xor c ;B
       and 0b10100101;0b01000010 ;B10
       xor c;rbG??RBg
       rrca ;grbG??RB
        or 0b00001100 ;unused bits
        ld (de),a ;low %grbG11RB
        inc de ;TODO ld (),a

       ld a,b ;G
       rlca ;?g??G??? ;G32
       xor l ;R
       and 0b01001000;0b00100001 ;R32
       xor l;?gr?G??R
       rlca ;gr?G??R?
       xor c ;B
       and 0b11010010;0b00100001 ;B32
       xor c;grbG??RB
        or 0b00001100 ;unused bits
        ld (de),a ;high %grbG11RB
        inc de ;TODO ld (),a

         ;pop hl
         ;inc hl
         dec hx
         jp nz,bripalATM3 ;TODO dup..edup
recoloursp=$+1
        ld sp,0
        ei
        ret


        align 256
tbright
;brightness levels (black 0..7 less than original, 8 equal, 9..15 to white)
;0, 1/12, 1/8, 3/16, 2/8, 3/8, 4/8, 6/8, 1
_lev=0
        dup 16 ;colour component level
_antilev=15-_lev
        BRIGHTBYTE _lev*0
        BRIGHTBYTE _lev/12
        BRIGHTBYTE _lev*1/8
        BRIGHTBYTE _lev*3/16
        BRIGHTBYTE _lev*2/8
        BRIGHTBYTE _lev*3/8
        BRIGHTBYTE _lev*4/8
        BRIGHTBYTE _lev*6/8

        BRIGHTBYTE _lev

        BRIGHTBYTE 15-(_antilev*6/8)
        BRIGHTBYTE 15-(_antilev*4/8)
        BRIGHTBYTE 15-(_antilev*3/8)
        BRIGHTBYTE 15-(_antilev*2/8)
        BRIGHTBYTE 15-(_antilev*3/16)
        BRIGHTBYTE 15-(_antilev*1/8)
        BRIGHTBYTE 15

_lev=_lev+1
        edup
;===================
  ;#DD #2C      INC  IXL           #FD #2C       INC  IYL
 ; #DD #2D      DEC  IXL 





;---------------------------------------

nomus:
NOMUS   XOR A
        LD D,14
MU_1    LD BC,#FFFD
        DEC D
        OUT (C),D
        LD B,#BF
        OUT (C),A
        JR NZ,MU_1
        LD B,#FF
        LD D,7
        OUT (C),D
        LD B,#BF
        DEC A
        OUT (C),A
        RET

dirchangeerror
        ld hl,txt_dircherror
        jr openerror



memoryerror
        OS_CLOSEHANDLE
        ld e,6+0x80
        OS_SETGFX
        ld e,0
        OS_CLS
        ld hl,txt_memoryerror
        call print_hl
        YIELDGETKEYLOOP
        jp cmd_quit


openerror:
        push hl
        ld e,6+0x80
        OS_SETGFX
        ld e,0
        OS_CLS
        pop  hl
        call print_hl
        ld hl,txt_nl
        call print_hl
        YIELDGETKEYLOOP
        jp cmd_quit

print_hl
        ld a,(hl)
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        inc hl
        jp print_hl
        ret

setpage0
        ld a,(winpage3)
        jr setpage_m
setpage1
        ld a,(winpage11)
        jr setpage_m
setpage2
        ld a,(winpage2)
        jr setpage_m
setpage3
        ld a,(winpage13)
        jr setpage_m
setpage4
        ld a,(winpage14)
        jr setpage_m
setpage5
        ld a,(user_scr0_high)
        jr setpage_m
setpage6
        ld a,(winpage16)
        jr setpage_m
setpage7
        ld a,(winpage17)
setpage_m
        SETPGC000
        pop hl
        ret

set_next_difficulty:
       push af,hl,de,bc
       ld a,(difficulty_c)
        cp 3
        jr z,set_difc1
        inc a
        ld (difficulty_c),a
        jr set_difc1

set_max_difficulty:
       push af,hl,de,bc
                ld a,3
                jr set_difc1
set_difficulty:
       push af,hl,de,bc
                ld a,(difficulty_c)
set_difc1:
                add a,a
                ld e,a
                ld d,0
                ld hl,dfc_table
                add hl,de
                ld a,(hl)
                inc hl
                ld h,(hl)
                ld l,a
                ld de,0x9a7d
                ld bc,4
                ldir
                
                pop bc,de,hl,af
                ret

mode            db 0
difficulty      db 0
difficulty_c    db 0
dfc_table:      dw easy_tbl
                dw normal_tbl
                dw hard_tbl
                dw hell_tbl

easy_tbl          db 0x87,0x00,0x00,0x00
normal_tbl        db 0x87,0x87,0x00,0x00
hard_tbl          db 0x87,0x87,0x87,0x00
hell_tbl          db 0x87,0x87,0x87,0x87

pre_setup:          db 0x0A,"RoboCop by Ocean Software Ltd [1988]",0x0D,0x0A
                    db "Adapted for NedoOS an modded by Zorba (Transman/Triumf) [2025]",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db 0x0D,0x0A,"Choose game version:",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. Original",0x0D,0x0A
                    db "2. Slightly modded",0x0D,0x0A,0
difficulty_setup:
                    db 0x0D,0x0A,"Select difficulty:",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. Easy",0x0D,0x0A
                    db "2. Normal",0x0D,0x0A
                    db "3. Hard",0x0D,0x0A
                    db "4. Hell",0x0D,0x0A,0
                    

video_name    db "video"
vidloadnum db "0.bin",0

res_path db "robocop",0


pal_rgb   ds 32,0xff
temppal   ds 32,0
pal       ds 32,0xff 
blackpal  ds 32,0xff
stdpal:  STANDARDPAL

winpage0    db 0
winpage1    db 0
winpage2    db 0
winpage3    db 0

winpage11   db 0
winpage13   db 0
winpage14   db 0
winpage16   db 0
winpage17   db 0

vidbuf      db 0

f_name_main db "main.bin",0

f_name11   db "ram11.bin",0
f_name13   db "ram13.bin",0
f_name14   db "ram14.bin",0
f_name16   db "ram16.bin",0
f_name17   db "ram17.bin",0

scr16c     db "robo.16c",0
scr6912    db "robo.scr",0
intro      db "intro.bin",0

txt_memoryerror:    db 0x0A,"Memory allocation error!",0x0D,0x0A,0
txt_dircherror:     db 0x0A,"Cannot change directory: ",0
txt_nl:             db 0x0D,0x0A,0
        include "../../_sdk/file.asm"

page_switch_table
        dw setpage0
        dw setpage1
        dw setpage2
        dw setpage3
        dw setpage4
        dw setpage5
        dw setpage6
        dw setpage7



select_page:
;        push hl,bc
        and 7
        push hl
        ld hl,page_switch_table
        add a,a
        ld b,0
        ld c,a
        add hl,bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        jp (hl)



pg_transfer:
;hl - pages
        ld a,l
        and 7
        call select_page
        ld a,(iy)

        push af

        ld a,h
        and 7
        call select_page
        pop af
        ld (ix),a
        ret


setpg0
        call select_page
        jp 0x66ef





menu_keyscan_mod:
        rra
        ld hl,0xaa58
        jr c,.key1
        ld hl,0xae4f
        rra
        jr nc,.key3plus
.key1:
        ;keyboard /sinclair
        ld bc,0x00a
        ld de,0x9b7d
        ldir
        ld a,0xc9
        jp .togam
.key3plus:
        rra
        jr nc,.key4plus
;kempston
        xor a
        jp .togam
.key4plus:
        rra
        jp c,0xaaae ;redefine keys
        rra
        jp nc,0xaa62  ;no valid key pressed
        jp cmd_quit

.togam
         push af
            call clr_v_t

             ld a,(difficulty)
             ld (difficulty_c),a
         pop af
         jp 0xac22


inert:
           call clr_v_t
           ld hl,0x604e
           ret          


clr_v_t:
	LD HL,VIDEO_S
	LD B,10
.init_loop
        LD (HL),0
        INC HL
        DJNZ .init_loop
        ret







level9_video:
                CALL p_manager
                JP 0x7F55

p_manager:
                ld (store_sp),sp
                ld sp,0x4000
                push hl


                call area_cls

                call p_manager_controller_text
                call p_manager_controller_video

                ;disable stun
                xor a
                ld (0x9acb),a


                pop hl

        		LD A,(0x9CCD)
                ld sp,0
store_sp     equ $-2
		RET


p_manager_controller_video
        	LD A,(0x9CCD)
        	LD E,A
        	LD D,0
        	LD HL,VIDEO_S
        	ADD HL,DE
        	LD A,(HL)
        	AND A
        	RET NZ
            inc a
            ld (hl),a

            ld a,"0"
            add a,e
            ld (vidloadnum),a
;play video
;e - video number

                di
                im 1
                ei
        



;load selected video
                ld de,video_name
                call vid_load_play



                di
                im 2
                ei
                ret






vid_load_play:
                call openstream_file
                or a
                jp nz,$


                ld e,3+0x80  //set 6912 mode keep
                OS_SETGFX


                ld hl,t_vid_file00_pages_list
                ld (load_vid_file_number),hl
;-----------------------------
load_vid_file_number = $+1 :
                ld bc,t_vid_file00_pages_list
                push bc
                                
.read_file_loop:
                OS_NEWPAGE              ;out: a=0 (OK)/!=0 (fail), e=page
                
                pop bc ;file tab
                or a
                jp nz,memoryerror
                ld a,e
1               ld (bc),a
                inc c   
                push bc ;file tab
                SETPGC000
        
                ld de,0xC000
                ld hl,0x4000
                call readstream_file    ;DE = Buffer address, HL = Number of bytes to read
                                ;hl=actual size
                ld a,h
                cp $40
                jr nc,.read_file_loop    ;>= $40

                pop bc ;file tab
                ;тут можно достать количество страниц
                ld a,c
                ld c,$FF
                ld (bc),a
                call closestream_file
;-----------------------------------------

                CALL VIDEOPLAY

                ld hl,t_vid_file00_pages_list+$FF 
                call free_vid_file

                ld a,(winpage3)
                SETPGC000

                                ld e,3+8+0x80  //set 6912 mode keep
                                OS_SETGFX

                halt
                ret


                align 256
t_vid_file00_pages_list:  ds 256,0
                nop



p_manager_controller_text
        	LD A,(0x9CCD)
	LD E,A
	LD D,0
	LD HL,VIDEO_S
	ADD HL,DE
	LD A,(HL)
	AND A
	RET NZ

        ld a,e
        add a,a
        ld e,a
        ld d,0
        ld hl,text_table
         add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
;0x61ab
        ld b,(hl)
        ld a,b
        and a
        ret z


        push de,bc,hl

            ld hl,mess_diff
            call _clone_0xac80 ;print string
            ld a,0x40
            call 0x9b90 ;erase cursor
            
            ld a,(difficulty_c)
            add a,a
            ld e,a
            ld d,0
            ld hl,mes_d_tabl
             add hl,de
            ld a,(hl)
            inc hl
            ld h,(hl)
            ld l,a
            call _clone_0xac80 ;print string
            ld a,0x40
            call 0x9b90 ;erase cursor

       pop hl,bc,de




        inc hl
.prt_loop
        call _clone_0xac80 ;print string

        ld a,0x40
        call 0x9b90 ;erase cursor

       djnz .prt_loop



;------------------------------------------------------------------
;debug
/*
                
                di
                im 1
                ei

                call mem_check
                ;a - free pages count
                ld de,mes_free_pg_num_c
                call ConvertNumberA

                di
                im 2
                ei
        
                
                ld hl,mes_free_mem
                call _clone_0xac80
                ld a,0x40
                call 0x9b90 ;erase cursor


                ld hl,mes_free_pg_num
                call _clone_0xac80
                ld a,0x40
                call 0x9b90 ;erase cursor

*/
;------------------------------------------------------------------












       call 0x61ab
       ret 

mes_free_mem:
           dw 0x5001
           db "FREE@PAGES:@@",0
mes_free_pg_num:
           dw 0x500d
mes_free_pg_num_c:
           db "00000" ,0    


_clone_0xac80:
            ld e,(hl)
            inc hl
            ld d,(hl)
            inc hl
            ld (0x9ba1),de
._0xac88
            ld a,(hl)
            inc hl
            or a
            ret z
            call 0x9b90
            ld a,0x3d
            call 0x9b90
            ld a,(0x9ba1)
            dec a
            ld (0x9ba1),a
            push bc
            ld b,3
            call _clone_0xac75
            pop bc
            jr ._0xac88

_clone_0xac75:
            ld a,0x7f
            in a,(0xfe)
            rra 
            ret nc
            ei
            halt
            djnz _clone_0xac75
            ret


free_vid_file:
               ld a,(hl)
                and a
                ret z
                ld l,a
free_vid_loop
                dec l
                ld e,(hl)

                push af
                push hl
                OS_DELPAGE
                pop hl
                pop af                
                jr nz,free_vid_loop          
        ret

;216*128 pixels (27*16)
area_cls:
        ld hl,0x5821
        ld c,16
.lllp:
        push hl
        ld b,0x1b
.eer2
        ld (hl),0x47
        inc hl
        djnz .eer2
        pop hl

        ld de,32
        add hl,de
        dec c
        jr nz,.lllp            




        ld hl,0x4021
        ld c,128
._62f2:
        push hl
        ld b,0x1b
.eer
        ld (hl),0
        inc hl
        djnz .eer
        pop hl
        call DownHL
._6321:
        dec c
        jr nz,._62f2
        ret


DownHL:
		inc	h
		ld	a, h
		and	7
		ret	nz
		ld	a, l
		add	a, 20h
		ld	l, a
		ret	c
		ld	a, h
		sub	8
		ld	h, a
		ret

VIDEO_S	      DB         0,0,0,0,0,0,0,0,0,0
text_table
         dw txt_mission0
         dw txt_mission1
         dw txt_mission2
         dw txt_mission3
         dw txt_mission4
         dw txt_mission5
         dw txt_mission6
         dw txt_mission7
         dw txt_mission8
         dw txt_mission9

txt_mission0 
             db 2   
             dw 0x480a
             db  "ON@PATROL",0
             dw 0x4849
             db  "IN@DETROIT",0   
txt_mission1:
             db 2   
             dw 0x4806
             db  "ATTACK@IN@PROGRESS",0
             dw 0x4847
             db  "RESCUE@THE@WOMAN",0   
txt_mission2:
             db 2   
             dw 0x4809
             db  "ON@PATROL",0
             dw 0x4842
             db  "ARMED@CRIMINALS@AT@LARGE",0   
txt_mission3:
             db 2   
             dw 0x4802
             db  "IDENTIFY@DISCEASED@USING",0
             dw 0x4841
             db  "POLICE@DEPARTMENT@COMPUTER",0    

txt_mission4:
             db 3   
             dw 0x4807
             db  "CONGRATULATIONS",0  
             dw 0x4846
             db  "NOW@RAID@THE@GANG",0
             dw 0x4889
             db  "DRUG@FACTORY",0    
txt_mission5:
             db 2   
             dw 0x4806
             db  "ARREST@DICK@JONES",0
             dw 0x4848
             DB  "AT@O.C.P.@HQ",0    
txt_mission6:
             db 1
             dw 0x4806
             db  "ESCAPE@FROM@O.C.P.",0    

txt_mission7:
             db 1   
             dw 0x4806
             db  "REST@IN@JUNKYARD",0    

txt_mission8:
             db 3   
             dw 0x4802
             db  "PRESIDENT@O.C.P.@BOARD@OF",0  
             dw 0x4843
             db  "DIRECTORS@WITH@EVIDENCE",0
             dw 0x4885
             db  "AGAINST@DICK@JONES",0    

txt_mission9 db 0
             dw 0x4801
             db 0


controls_menu
        dw 0x480a
        db "1@@KEYBOARD",0
        dw 0x484a
        db "2@@SINCLAIR",0
        dw 0x488a
        db "3@@KEMPSTON",0
        dw 0x48ca
        db "4@@DEFINE@KEYS",0
        dw 0x500a
        db "5@@EXIT@@@",0,0,0,0,0,0,0,0

mess_diff dw 0x4046
          db "DIFFICULTY:@",0
mes_d_easy dw 0x4052
           db "EASY@@",0
mes_d_norm dw 0x4052
           db "NORMAL",0
mes_d_hard dw 0x4052
           db "HARD@@",0
mes_d_hell dw 0x4052
           db "HELL@@",0        


mes_d_tabl
            dw mes_d_easy
            dw mes_d_norm
            dw mes_d_hard
            dw mes_d_hell    
/*
sounds_table
        db 0,3,7,8,3,8,5,3,2,4,6,3,3,4,6
        db 4,5,4,4,3,5,3,2,5,4,3,4,6,1,9
        db 255,10,6,8,12,9,0x14,0x20,255
        db 0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14
        db 0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14
        db 0x14,0x14,0x14,0x14,255,0,0,0
*/

fix_stun:
            ld a,0x77
            ld (0x9acb),a
            call 0x9ab0

            ld a,8
            ld (0x9cb8),a
            ret


fix_stun_ram16_1:
            ;C = 1
            ld a,0x77
            ld (0x9acb),a
            jp 0x9ab0


fix_stun_ram16_2:
            ld (0x9acb),a
            ld (0x9cbc),a
            ret    

CONT    EQU 254         ;служебные константы
COMAND  EQU 255

BMODE   EQU 0           ;биты режимов
DMODE   EQU 1
EXTPCK  EQU 2
EXCMODE EQU 3
EXCFIN  EQU 4

EX_ENDSTR  EQU -1               ;"короткие" команды
EX_NEWFRM  EQU %00011111
EX_KEYFRM  EQU %00111111


VIDEO   EQU 49152       ;адрес распложения видео


FIRST1  EQU 0x4201  ;0x4000 ;       ;адрес экрана
FSTATR  EQU 0x5800  ; ;x`22528+32+1


MAXSCR  EQU 0x58 ;HIGH FIRST1 + #18

SPEDE   EQU 4           ;задержка между кадрами

        MACRO   IDE
        INC E
        CALL Z,R_DE
        ENDM 





VIDEOPLAY:
        LD (STAKP+1),SP
        LD IX,PLFLG
	XOR A
        ld (current_ram_page),a
        LD (IX),A


        
        push hl
        	LD l,0
current_ram_page EQU $-1
                ld h,HIGH t_vid_file00_pages_list
                
                ld a,(hl)
                SETPGC000
        pop hl
        




        LD DE,VIDEO
NEWKAD  EXX

        LD HL,FSTATR
        SET EXCFIN,(IX)
        EXX
        LD HL,FIRST1
VP_ADR1 equ $-2 
        LD C,0
PLCYC
        BIT EXTPCK,(IX)
        JP NZ,EXTP_STRM

        LD A,(DE)
        IDE
        CP COMAND
        JR NZ,NOCOM

EX_COMM
        LD A,(DE)
        IDE

        DEC A
        JP Z,WAIT
        DEC A
        RET Z
        DEC A
        JR NZ,NCHS
        LD A,(DE)
        LD (WAIT+1),A
        IDE
        JR PLCYC

NCHS    DEC A
        JP Z,SCRENE

        DEC A
        JR NZ,LGRP

        LD A,(DE)
        IDE
        LD C,A
C_GROUP LD B,8
PTS1    LD A,(DE)
        LD (HL),A
        IDE
        INC H
        DJNZ PTS1
        INC L
        JR Z,M7
        LD A,H
        SUB 8
        LD H,A
M7      DEC C
        JR NZ,C_GROUP
        JR PLCYC

LGRP    DEC A
        JP NZ,LNOGR
        LD A,(DE)
        IDE
        LD C,A          ;QUANTITY
        CALL DEP_ZN_
        JR PLCYC
LNOGR   DEC A
        JP Z,LSCRENE
        DEC A
        JR NZ,NOBMOD
        SET BMODE,(IX)
        JR PLCYC
NOBMOD
        LD A,(DE)
        IDE
        RRA
        JR NC,NODPK
        SET DMODE,(IX)

NODPK   RRA
        JR NC,PLCYC
        SET EXTPCK,(IX)
        RRA
        JP NC,PLCYC
        SET EXCMODE,(IX)
        JP PLCYC

NOCOM   CP CONT
        JR NZ,NOCNT
        ADD A,L
        LD L,A
        JP NC,PLCYC
        LD A,H
        ADD A,8
        LD H,A
        JP PLCYC
NOCNT
        ADD A,L
        LD L,A
        JR NC,M8
        LD A,H
        ADD A,8
        LD H,A
M8
        BIT BMODE,(IX)
        JR Z,OLDZZ
        LD C,1
        CALL DEP_ZN_
        JP PLCYC
OLDZZ   LD B,#08
PUTES   LD A,(DE)
        LD (HL),A
        IDE
        INC H
        DJNZ PUTES
        INC L
        JP Z,PLCYC
        LD A,H
        SUB 8
        LD H,A
        JP PLCYC
WAIT    LD A,SPEDE
W_LOOP  HALT
        DEC A
        JR NZ,W_LOOP
ESCR    


        LD A,127
        IN A,(254)
        RRA
        JP C,NEWKAD

STAKP   LD SP,0
        SCF
        RET

;-------EXTPACK STREAM PROCESSING -------
EXTP_STRM
        LD A,(DE)
        IDE
        CP -1
        RET Z
        CP EX_NEWFRM
        JR Z,WAIT
        CP EX_KEYFRM
        JR Z,EX_KEYF

        JR NZ,EX_CDEPC

EX_KEYF
        ;...
        JP LSCRENE

;------------------
EX_CDEPC
        LD C,A          ;MASK1
        LD B,8

EX_DPCK RR C
        JR C,EX_OFFS
        PUSH BC
        LD A,(DE)
        IDE
        LD C,A
        XOR A
        LD B,A          ;OLDB
        EX AF,AF'

EX_DBPC RR C
        JR NC,EX_NOB1
        LD A,(DE)
        IDE
        LD B,A
EX_NOB1 EX AF,AF'
        XOR B
        LD (HL),A
        EX AF,AF'
        INC H
        LD A,H
        AND 7
        JR NZ,EX_DBPC
        INC L
        JR Z,EX_NOSH
        LD A,H
        SUB 8
        LD H,A
EX_NOSH POP BC
EX_CONC DJNZ EX_DPCK
        CALL EX_CMODE
        JP EXTP_STRM

EX_OFFS LD A,(DE)
        IDE
        AND A
        JR Z,EX_FCOLR
        ADD A,L
        LD L,A
        JR NC,EX_CONC
        LD A,H
        ADD A,8
        LD H,A
        JR EX_CONC

EX_FCOLR
        CALL EX_CMODE
        JR NZ,EX_FCOLR
        JP EXTP_STRM

EX_CMODE
        BIT EXCMODE,(IX)
        RET Z
        BIT EXCFIN,(IX)
        RET Z
        LD A,(DE)
        IDE
        LD C,A          ;MASK
        LD B,8          ;DATA

EX_CDPC RR C
        JR C,EX_COFS
        LD A,(DE)
        AND 63
        EXX
        LD (HL),A
        INC HL
        EXX
        LD A,(DE)
        IDE
        RLA
        JR NC,EX_CNS
        RES EXCFIN,(IX)
        AND 128
        RET

EX_CNS  DJNZ EX_CDPC
        LD A,-1
        AND A
        RET

EX_COFS LD A,(DE)
        IDE
        EXX
        ADD A,L
        LD L,A
        ADC A,H
        SUB L
        LD H,A
        EXX
        JR EX_CNS


SCRENE  

        LD HL,FIRST1
VP_ADR2 equ $-2 
        LD A,(DE)
        LD C,A
        IDE
PCK_CYC LD A,(DE)
        CP C
        JR Z,REPT
        LD B,8
PGR     LD A,(DE)
        LD (HL),A
        INC H
        IDE
        DJNZ PGR
        INC L
        JR Z,M5
        LD A,H
        SUB 8
        LD H,A
M5
        LD A,H
        CP MAXSCR
        JR C,PCK_CYC
        JR NEWK

REPT    IDE
        LD A,C
        EX AF,AF'
        LD A,(DE)
        LD C,A
        IDE
        LD B,8
        PUSH HL
COZN    LD A,(DE)
        LD (HL),A
        IDE
        INC H
        DJNZ COZN
        INC L
        JR Z,NDP1
        LD A,H
        SUB 8
        LD H,A
NDP1
        DEC C
        JR NZ,CONDP
        POP BC
        JR ISEND
CONDP   EX DE,HL ;HL-ADRESS DE-SCREEN+1
        EX (SP),HL      ;HL-SCREEN DE-SCREEN+1
        EX DE,HL        ;DE-SCREEN HL-SCREEN+1
DEPCYC  LD B,8
        PUSH DE
COZN1   LD A,(DE)
        LD (HL),A
        INC H
        INC D
        DJNZ COZN1
        INC L
        JR Z,NDP2
        LD A,H
        SUB 8
        LD H,A
NDP2    POP DE
        LD A,H
        CP MAXSCR
        JR C,CONPKC
        POP DE
        JR NEWK
CONPKC  DEC C
        JR NZ,DEPCYC
        POP DE
ISEND   EX AF,AF'
        LD C,A
        LD A,H
        CP MAXSCR
        JR C,PCK_CYC
NEWK




        LD A,(WAIT+1)
        SUB 2
        JP C,ESCR
        JP Z,ESCR
        JP W_LOOP

LSCRENE 

        LD HL,FIRST1
VP_ADR3 equ $-2 
        EXX
        LD HL,FSTATR    ;ADR
        EXX

LPCK_CYC
        LD A,(DE)
        IDE
        INC A
        JR Z,NEWK
        DEC A
        JR NZ,LREPT
        LD A,(DE)
        IDE
        LD C,A
        BIT EXCMODE,(IX)
        JR Z,NOCO1
DEPSCC  PUSH BC
        LD C,1
        CALL DEP_ZN
        CALL DEPCOL
        POP BC
        DEC C
        JR NZ,DEPSCC
        JP LPCK_CYC

NOCO1   CALL DEP_ZN
        JR LPCK_CYC
LREPT
        LD A,(DE)
        LD C,A
        IDE
        PUSH HL
        PUSH BC
        LD C,1
        CALL DEP_ZN
        CALL DEP_COL_
        POP BC
        DEC C
        JR NZ,CONPA
        POP AF
        JR LPCK_CYC


;fill empty area with repeat blocks
CONPA   EX DE,HL        ;HL-ADRESS DE-SCREEN+1
        EX (SP),HL      ;HL-SCREEN DE-SCREEN+1
        EX DE,HL        ;DE-SCREEN HL-SCREEN+1
LDEPCYC LD B,8
        PUSH DE
LCOZN1                  LD A,(DE)
                        LD (HL),A
        INC H
        INC D
        DJNZ LCOZN1
        INC L
        JR Z,LNDP2
        LD A,H
        SUB 8
        LD H,A
LNDP2   POP DE
        BIT EXCMODE,(IX)
        JR Z,LCONPKC
        LD A,L
        and 31   ;AND 31
        JR NZ,LCONPKC   ;

        EX DE,HL   ;ZZZZ
        EX (SP),HL
        EX DE,HL
        CALL DEPCLA
        EX DE,HL
        EX (SP),HL
        EX DE,HL

LCONPKC DEC C
        JR NZ,LDEPCYC
LISEND  POP DE
        JR LPCK_CYC

DEP_COL_
        BIT EXCMODE,(IX)
        RET Z
DEPCOL  LD A,L
        AND 31
        RET NZ

DEPCLA  EXX
        LD E,0
        EXX

DPCC1   LD A,(DE)
        IDE
        EXX
        LD C,A
        LD B,8

DPCC    RR C
        JR NC,OLDCOL
        EXX
        LD A,(DE)
        IDE
        EXX
        LD E,A
OLDCOL  LD (HL),E
        INC HL
        DJNZ DPCC
        LD A,L
        EXX
        AND 31
        JR NZ,DPCC1
        RET

INCHL   INC H
        LD A,H
        AND 7
        RET NZ
        INC L
        RET Z
        LD A,H
        SUB 8
        LD H,A
        RET

INCDE1  INC D
        LD A,D
        AND 7
        RET NZ
        INC E
        RET Z
        LD A,D
        SUB 8
        LD D,A
        RET

R_DE    INC D
        RET NZ
SWPAG   LD D,192
        PUSH AF

                push de
                push hl
                push bc

        	LD A,(current_ram_page)
                inc a
                ld (current_ram_page),a
                ld l,a
                ld h,HIGH t_vid_file00_pages_list
                ld a,(hl)
                SETPGC000

                pop bc
                pop hl
                pop de        

        POP AF
        RET



;single row
DEP_ZN_
DPMODE  LD A,0
        AND #AE         ;XOR (HL)
        LD (XORHL),A
DEP_ZN
MAKALL  PUSH BC
        LD A,(DE)
        IDE
        LD B,A  ;MASK
        XOR A
        LD C,A  ;PREWDAT
        LD (OLBYT+1),A
MAKGR
        RR B
        JR NC,OLBYT
        LD A,(DE)
        IDE
        LD (OLBYT+1),A
OLBYT
        LD A,0
        XOR C
        LD C,A
XORHL   NOP
        LD (HL),A
        INC H
        LD A,H
        AND 7
        JR NZ,MAKGR
        INC L
        JR Z,M7_
        LD A,H
        SUB 8
        LD H,A
M7_     POP BC
        DEC C
        JR NZ,MAKALL
        XOR A
        LD (XORHL),A

        RET


PLFLG   DB 0







mem_check:
        ld d,0
        ld e,0
.loop
        push de
        dec e
        OS_GETPAGEOWNER
        ld a,e
        pop de

        and a
        jr nz,.ll
        inc d
.ll:
        dec e
        jr nz,.loop 
        ;ld h,0
        ;ld l,d
        ld a,d
        ret 


ConvertNumberA:
    ld h, 0
    ld l, a
ConvertNumberHL:
    ; Get the number in hl as text in de
    ld bc, -10000
    call .one
    ld bc, -1000
    call .one
    ld bc, -100
    call .one
    ld bc, -10
    call .one
    ld c, -1
.one
    ld a, "0"-1
.two
    inc a
    add hl, bc
    jr c, .two
    push bc;
    push af;
    ld a, b;
    cpl;
    ld b, a;
    ld a, c;
    cpl;
    ld c, a;
    inc bc;
    call c, .carry;
    pop af;
    add hl, bc;
    pop bc;
    ld (de), a
    inc de
    ret

.carry;
    dec bc;
    ret;

dropotherapps
;d=pgmain0000
;от последних id (детей) к первым (родителям), т.к. при dropapp будится родитель
        ld e,0xfe ;no id 0xff
dropotherapps0
        push de
        OS_GETAPPMAINPAGES ;d,e,h,l=pages in 0000,4000,8000,c000, c=flags ;a!=0: no app
        or a
        ld a,d
        pop de
        jr nz,dropotherapps_skip ;no app
       cp d
       jr z,dropotherapps_skip ;my app
        push de
        ;e=id
        OS_DROPAPP
        pop de
dropotherapps_skip
        dec e
        ld a,e
        dec a ;no id 0 ;id 1 = idle
        cp 3
        jr nz,dropotherapps0
        ret

setpgsmain4000_C000
        ld a,(winpage1)
        SETPG4000
        ld a,(winpage2)
        SETPG8000
        ld a,(winpage3)
        SETPGC000
        ret


;scr_buffer ds 6912,0

cmd_end:


        savebin "robocop.com",cmd_begin,cmd_end-cmd_begin
 ;       LABELSLIST "..\..\us_ns2\user.l",1
