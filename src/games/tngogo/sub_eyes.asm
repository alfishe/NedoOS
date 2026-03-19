maxfilenamelen = 8+1
eyerecordlen = eyerec_e - eyerec_s
eyedatalen = eyerec_e - eyerec_d
load_bgnd_anim:
        push hl
        push bc
        push de
        push af
		call setfontpage
		
        xor a
        ld (anim_is_found),a
		
		;we have only two (maximum) animations per screen so we use just one slot
		ld de,ANIM_BFF
		ld (load_anim_slot_addr),de
		ld de,anim_stack
		ld (anim_stack_slot_pointer),de
		
        ld hl,eyes_table
.load_bgnd_anim_main_loop:
        ld de,namebuf
        ld a,(hl)
        cp 0xff
        jp z,.load_bgnd_anim_exit ;eof

        push hl
		call cmpr_dehl
		jp nz,.load_bgnd_anim_skip_to_next
		pop hl
		ld (.leml1+1),hl ; store eye_name_start addr

		ld a,1
		ld (anim_is_found),a

		call load_anim_pre_sub
		ld de,(load_anim_slot_addr)     ;addr to store sprire
		ld hl,(anim_stack_slot_pointer)    ;addr to store sprite info 
		ld (hl),e
		inc hl
		ld a,d
		sub 0x40  ;fix to 0x4000 - 0x7fff area
		ld (hl),a
		inc hl
		ld (anim_stack_slot_pointer),hl        ;write in aim stack adress of sprite location in slot page
		;load animation to font page ;de - addr to load
		ld hl,0x8000
		call readstream_file
		or a
		jp nz,filereaderror
		ld (temp_addr_storage),de ;store addr in slot page next to just loaded sprite.
		call closestream_file

.leml1:
		ld hl,0
		ld de,maxfilenamelen
		add hl,de  ;skip name in eyes table to data
		push hl
		pop ix
        ;get x
        ld l,(ix+0)
        ld h,(ix+1)
        call p_calc_x
        ;set background sprite offset
		ld c,(ix+9)	  ;x-offscreen offset
		ld b,0
		add hl,bc	;add screen offset. get final x position
	
		push hl
		;get_y
		ld e,(ix+2)
		ld d,(ix+3)
		ld a,(ix+10)  ;y-offscreen offset
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
		ld c,(ix+11) ;animation type
;======================================
		ld (hl),b ; phases
		inc hl
		ld (hl),c ; anim type
		inc hl
		
		ld a,(ix+12) ;randomize start time ?
		dec a: dec a    ;0 becames 0xfe , 1 becames 0xff	
		ld (hl),a ;counter 1
		inc hl
		ld (hl),0        ;counter 2
		inc hl
		ld (hl),0        ;counter 3
		inc hl
		ld a,(ix+13)  ;use mask? (use transparency?)
		ld (hl),a
		inc hl
		ld (anim_stack_slot_pointer),hl 
;	generate fast access table for each animation fase			
			
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
		ld hl,eyedatalen
		add hl,bc ;переход к следующей записи в eyes_table
        jp .load_bgnd_anim_main_loop			


.load_bgnd_anim_skip_to_next:
        pop hl
        ld bc,eyerecordlen
        add hl,bc
        jp .load_bgnd_anim_main_loop
.load_bgnd_anim_exit:
        ld a,(anim_is_found)
        and a
        jr z,.lee1
		
        ld hl,(anim_stack_slot_pointer)
        ld (hl),0xff		
        ld a,1
        ld (alock),a
.lee1
		call unsetfontpage
        pop af
        pop de
        pop bc
        pop hl
        ret



cmpr_dehl:
        ld a,(de)
        and a
        ret z   ;string fully equally and dtring in de not begin from 0

        cpi
        ret nz
        inc de
        jr cmpr_dehl

C_Time_D:
;Outputs:
;     A is the result
;     B is 0
     ld b,8          ;7           7
     xor a           ;4           4
       rlca          ;4*8        32
       rlc c         ;8*8        64
       jr nc,$+3     ;(12|11)    96|88
         add a,d     ;--
       djnz $-6      ;13*7+8     99
     ret             ;10         10
;===========================================================================
;in hl - x-coord 0-319
;;out hl -adress in 8000 - ffff atm2 ega screen (x-offset)
p_calc_x:
        and a
        rr h
        rr l
        ld a,l
        rrca
        rrca
        ld h,0
        and a
        push af
        rla
        rr h
        rla
        rr h
        scf
        rr h
        pop af
        and 0x3f
        ld l,a
        ret 
;=============================================       
;in hl - x-adress in atm2 ega screen
;   a - y coord - 0-199
;;out hl -adress in 8000 - ffff atm2 ega screen (xy offset)
p_calc_y:
        ld bc,40
p_calc_y_loop:
        and a
        ret z
        add hl,bc
        dec a
        jr p_calc_y_loop        
;=============================================       
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
        LD      A,0
        INC     A
        AND     1
        LD      (anim_eyes+1),A
        RET     NZ

		ld a,(font_page)
		SETPG4000
		
		ld ix,anim_stack
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
        ld bc,12+16
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


			ld bc,12
			add hl,bc ;hl = pointer to fases spr table
			add a,a
			ld c,a
			ld b,0
			add hl,bc
			ld e,(hl)
			inc hl
			ld d,(hl)
			pop ix

			ld l,(ix+2);screen pos
			ld h,(ix+3)
			ld b,(ix+4) ;len
			srl b
.anim_eyes_inner_loop:
			push bc
			;hl ega scr addr
			push hl
			ld b,(ix+5) ;hgt
.anim_eyes_inner_loop2:
			push bc  
			
			ld a,(ix+11)
			and a
			jp nz,._to_iob_byte
			ld a,(de):ld (hl),a			
.anim_eyes_inner_exit_point:
			inc de
			call DHL
			pop bc
			djnz .anim_eyes_inner_loop2
			pop hl
			
			NEXTCOLUMN      ;call p_nextcolumn

			;skip to next column of current frame

			pop bc
			djnz .anim_eyes_inner_loop
			ret
._to_iob_byte:
			call _iob_byte
			jp .anim_eyes_inner_exit_point
use_seq: dw 0		