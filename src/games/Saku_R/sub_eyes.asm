;1251
load_eyes:
    ;ret
        push hl
        push bc
        push de
        push af

        call setcorepage

        xor a
        ld (anim_is_found),a

        ;namebuf
        ;eyes_table:
        ld hl,eyes_table

load_eyes_main_loop:
        ld de,namebuf
        ld a,(hl)
        cp 0xff
        jp z,load_eyes_exit ;eof


        push hl
            call cmpr_dehl
            jp nz,load_eyes_skip_to_next
            ld (.leml1+1),hl ;skip filename length after load  ;!!!!!!!!!!!!!!!!!!! учесть что нулей после имени может быть 2!!!!
        pop hl

                ld a,1
                ld (anim_is_found),a
                call load_anim_pre_sub
                ld de,(load_anim_slot_addr)     ;addr to store sprire
                ld hl,(anim_stack_slot_pointer)    ;addr to store sprite info 
                   ld (hl),e
                   inc hl
                   ld a,d
                   sub 0x40
                   ld (hl),a
                   inc hl
                ld (anim_stack_slot_pointer),hl        ;write in aim stack adress of sprite location in slot page
                ;load animation to given slot page  ;de =addr to load
                  ld hl,0x8000
                  call readstream_file
                  or a
                  jp nz,filereaderror

                  ld (temp_addr_storage),de ;store addr in slot page next to just loaded sprite.
                  call closestream_file



        ;skip name again
.leml1:
        ld hl,0
        inc hl ;; !!!!!!!!!!!!!!!!!!! учесть что нулей после имени может быть 2!!!!
        ld a,(hl)
        and a
        jr nz,.leml2
        inc hl
.leml2:        
;======================================
        push hl
        pop ix    ;(base+8. so next point is ix+10)




        ;get x
        ld l,(ix+0)
        ld h,(ix+1)
        call p_calc_x
                ;set background sprite offset

        ld a,(x_pos_anim_divided) ; main sprite x-coord adapted to 0-319
        add a,5                   ;add offset (left element of picture frame)
        ld c,a
        ld b,0 ;offscreen offset
        add hl,bc                 ;get final x-position of animation

;======================================
        push hl    
            ;get_y
            ld e,(ix+2)
            ld d,(ix+3)
            ld a,8  ;offscreen offset
            add a,e
            ;add y offset
        pop hl  
        call p_calc_y

        ex de,hl  ;de = scr adress in 8000-ffff area
;======================================
                ;put sprite ega screen  addr in anim stack
                ld hl,(anim_stack_slot_pointer)
                ld (hl),e
                inc hl
                ld (hl),d
                inc hl
;======================================
        ld c,(ix+4)  ;len
        ld b,(ix+6)  ;hgt
                ld (hl),c ;len
                inc hl
                ld (hl),b ;hgt
                inc hl


        ld b,(ix+8) ;num phases
        ld c,(ix+9) ;animation type
;======================================
                ld (hl),b ; phases
                inc hl
                ld (hl),c ; anim type
                inc hl
    
          ld a,c
          ld c,0xfe
          cp 2
          jr z,.leml3 
          cp 3
          jr z,.leml3 
          ld c,0xff
.leml3:
                ld (hl),c ;counter 1
                inc hl
                ld (hl),0        ;counter 2
                inc hl
                ld (hl),0        ;counter 3
                inc hl
                ld (anim_stack_slot_pointer),hl        
    
 ;;;;;тут строим таблицу адресов для каждй фазы. для быстроо доступа   

           ld b,0
           ld c,(ix+4)
           srl c
           ld d,0     
           ld e,(ix+6)                          
           call mult_de_bc   ;hl - output len of single fase

 

                
                ld de,(load_anim_slot_addr)     ;addr to store sprire
                ld a,d
                sub 0x40
                ld d,a
                ex de,hl      ;hl sprite start addr , de - size of one frame

           ld b,(ix+8)
           push ix




                           ld ix,(anim_stack_slot_pointer)
                             push ix
.innrrl
                             ld (ix),l
                             inc ix
                             ld (ix),h
                             inc ix
                             add hl,de
                             djnz .innrrl

                             pop hl
                             ld bc,16
                             add hl,bc                      
                             ld (anim_stack_slot_pointer),hl
  
            ld hl,(temp_addr_storage)
            ld (load_anim_slot_addr),hl


            pop bc
            ld hl,10
            add hl,bc ;переход к следующей записи в eyes_table



        jp load_eyes_main_loop
        ;load gfx to buf by name
        ;move gfx to font_page 
        ;setup animation stack




load_eyes_exit:
;        ld a,1
;        ld(alock),a

        ld a,(anim_is_found)
        and a
        jr z,.lee1

        ld hl,(anim_stack_slot_pointer)
        ld (hl),0xff
        ld a,(load_anim_slot)
        call animon_sub               ;set anim switch on
.lee1:        

        call unsetcorepage
        pop af
        pop de
        pop bc
        pop hl
        ret
load_eyes_skip_to_next:
        pop hl
        ld bc,18
        add hl,bc
        jp load_eyes_main_loop





























;================================================
clear_slot_area_by_a:
                ld l,a
                ld h,0
                add hl,hl  ;x2       4
                add hl,hl  ;x4       8
                add hl,hl  ;x8      16
                add hl,hl  ;x16      32
                add hl,hl  ;x32      64
                add hl,hl  ;x64      64
                ld de,anim_stack
                add hl,de
                ld b,32
.emry_clr_loop:                
                ld (hl),0xff
                inc hl
                djnz .emry_clr_loop
                ret


init_setslotpage_by_a:
        ;in a - load_anim_slot
        push af

            ld hl,anim_slot03
            cp 4
            jr c,.ssp1
            sub 4
            ld hl,anim_slot47
            cp 4
            jr c,.ssp1
            sub 4
            ld hl,anim_slot811

.ssp1:

            add a,a ;x2
            add a,a ;x4
            add a,a ;x8
            add a,a ;x16
            ld de,ANIM_BFF
            add a,d
                and 10111111b
            ld d,a    ;de - slot adr to load sprite
            ld (load_anim_slot_addr),de

        pop af
        push hl
                ld l,a
                ld h,0
                add hl,hl  ;x2       4
                add hl,hl  ;x4       8
                add hl,hl  ;x8      16
                add hl,hl  ;x16      32
                add hl,hl  ;x32      64
                add hl,hl  ;x64      64
                ld de,anim_stack
                add hl,de
                ld (anim_stack_slot_pointer),hl
        pop hl

        jr setslotpage_by_a.ssp1



anim_offsets_slot_addr

setslotpage_by_a:
        ;in a - load_anim_slot
        ld hl,anim_slot03
        cp 4
        jr c,.ssp1
        ld hl,anim_slot47
        cp 8
        jr c,.ssp1
        ld hl,anim_slot811
.ssp1:
        ld a,(hl)        
        push bc
        push af
        ld a,(curpg8000)
        ld (abank2),a
        pop af
        SETPG8000
        pop bc        
        ret
;---------------------
mult_de_bc:
;he following routine multiplies bc by de and places the result in dehl. 
   ld	hl, 0

   sla	e		; optimised 1st iteration
   rl	d
   jr	nc, $+4
   ld	h, b
   ld	l, c

   ld	a, 15
._loop:
   add	hl, hl
   rl	e
   rl	d
   jr	nc, $+6
   add	hl, bc
   jr	nc, $+3
   inc	de
   
   dec	a
   jr	nz, ._loop
   
   ret
 




anim_eyes:
eyes_perfomance:
        nop

        LD      A,0
        INC     A
        AND     1
        LD      (anim_eyes+2),A
        RET     NZ







        ld b,16
        ld hl,anim_switches+15
.ani_e_l1:
        push hl
        push bc
            ld a,(hl)
            and a
            call nz,ani_e_draw
        pop bc
        pop hl 
        dec hl
        djnz .ani_e_l1


anim_eyes_exit:
        ret


ani_e_draw:
        dec b
        ;in b - slot to draw
        ld a,b
        push af

            ld hl,anim_slot03
            cp 4
            jr c,.ssp1
            ld hl,anim_slot47
            cp 8
            jr c,.ssp1
            ld hl,anim_slot811
.ssp1:
            ld a,(hl)        
            SETPG4000

        pop af
        push hl
             ;   ld l,a
             ;   ld h,0
             ;   add hl,hl  ;x2       2
             ;   add hl,hl  ;x4       4
             ;   add hl,hl  ;x8      8
             ;   add hl,hl  ;x16      16
             ;   add hl,hl  ;x32      32
             ;   add hl,hl  ;x64      64

                ld l,0        
                and a
                rra
                rr l
                rra
                rr l
                ld h,a
                

                ld de,anim_stack
                add hl,de
                push hl
                pop ix
        pop hl


.ani_loop:
        ld a,(ix)
        cp 0xff    ;end of slot
        ret z

        ld a,(ix+10)
        and a
        jr z,.anim_eyes_mc
        dec a
        ld (ix+10),a  ;time between animations
.anim_eyes_loop_cont:
        ld bc,11+16
        add ix,bc   ;pointer to next anim 
        jp .ani_loop

.anim_eyes_mc:



            ld a,(ix+9) ;time between animation fases
            and a
                jr z,.anim_eyes_mc2    
            dec a
            ld (ix+9),a
            jr .anim_eyes_loop_cont

.anim_eyes_mc2:
            ;select sequence for anim
            ld a,(ix+7); animation type
;BLINKS = 0   ;;HALFBLINKS = 1;SPARKLING = 2
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            ld hl,ani_mode_tbl
            call sel_word
            ld a,(ix+6)
            call sel_word
.ereee
            ld (use_seq),hl

            ld a,(ix+8) ;current phase

            cp 0xfe ;need init? ; fastloop
            jr z,.anim_mc_fe
            cp 0xff ;need init?  ;slow loop
;            jr nz,.anim_mc_cont_print
            jr z,.anim_mc_ff
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.anim_mc_cont_print:
            ;display animation fase
            call .anim_mc_print_sub

            ;setup next animation fase
            ld a,(ix+8)
            inc a    
            add a,a
            ld c,a
            ld b,0
            ld hl,(use_seq)
            add hl,bc
            ld a,(hl)
            cp 0xfe
            jr nc,.anim_eos
;proceed to  next fase. inc fase counter. set delay before new fase
            inc hl
            ld a,(hl)
            ld (ix+9),a
            inc (ix+8)
            jp   .anim_eyes_loop_cont          

.anim_eos:
            ;end of animation sequence 
            ;is it was 0xfe or 0xff ???

            ld (ix+8),a 
            ld (ix+9),0
            ld (ix+10),0
            jp   .anim_eyes_loop_cont 


.anim_mc_fe:
            ld (ix+10),0 ;no delay between of animations
.anim_mc_fe1:
            ld hl,(use_seq)
            inc hl
            ld a,(hl)
            ld (ix+9),a ;delay between fases of animation
            ld (ix+8),0  ;init animation (first fase of anim)

            jp .anim_eyes_loop_cont ;setup complete. skip to next anim


.anim_mc_ff:
            call randr
;            and 0x7f
            or 128
            sub 96
            ld (ix+10),a
            jr .anim_mc_fe1


.anim_mc_print_sub:

                ld a,(ix+8)
                add a,a ;!!!!x2
                ld c,a
                ld b,0
                ld hl,(use_seq)
                add hl,bc
                ld a,(hl)  ;a = current fase sprite offset



                push ix
                  pop hl
                  push hl


                  ld bc,11
                  add hl,bc ;hl = pointer to fases spr table
                  add a,a
                  ld c,a
                  ld b,0
                  add hl,bc
                  ld e,(hl)
                  inc hl
                  ld d,(hl)
;                  ld l,a                                   
;                  ld (.anim_src),hl ;prepare sprite src adress 


                pop ix

                ld l,(ix+2);screen pos
                ld h,(ix+3)

;               ld de,0
;.anim_src    equ $-2
                ld b,(ix+4) ;len
                srl b
.anim_eyes_inner_loop:
                push bc

                        ;hl ega scr addr
                        push hl
                        ld b,(ix+5) ;hgt
.anim_eyes_inner_loop2:
                        push bc  

                        call _iob_byte

                        inc de
                        call DHL

                        pop bc
                        djnz .anim_eyes_inner_loop2

                        pop hl
                        call p_nextcolumn

                        ;skip to next column of current frame



                pop bc
                djnz .anim_eyes_inner_loop
                ret

use_seq: dw 0