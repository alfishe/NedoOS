FRAME_BOX_WIDTH = 42
clear_screen:
        ld e,0
        OS_CLS
        ret


setpal_proc
        ld de,pal
        OS_SETPAL
        xor a
        ld (setpalflag),a
        ret        


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



;select word from table
;by index
;in A - index HL - table
;out HL -adress from table

sel_word:
        add a,a
        ld c,a
        ld b,0
        add hl,bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ret

;hl-src de-dest string limiter -  0
copystr_hlde:
        ld a,(hl)
        and a
        ret z
        ld (de),a
        inc hl
        inc de
        jr copystr_hlde
;------------------------
oldimer:
        jp int_proc
        jp 0x0038+3

;-setup interrupt
int_set:
int_reset:
        di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
.swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,.swapimer0
        ei
        ret

int_proc
        EX DE,HL
        EX (SP),HL ;de="hl", ??? "de"
        LD (on_int_jp),HL
        LD (on_int_sp),SP
        LD SP,sp_alt
        push af
        push bc
        push de ;"hl"
        exx
        ex af,af'
        push af
        push bc
        push de
        push hl
        push ix
        push iy

        ld hl, (on_int_jp)
        ld de, on_int_jp-1
        and a
        sbc hl,de
         ld hl,(on_int_jp)
         jr nz,int_not_same_jp

         ld hl,0
prev_on_int equ $-2
         ld (on_int_jp),hl
         jp insspp_exit


int_not_same_jp
        jp $+3
         ld (prev_on_int),hl



         ld a,0xc9  ;ret
         ld (int_proc),a



        ld hl,(on_int_sp)
        ld de,sp_alt
        and a
        sbc hl,de

        jp nc,int_proc_byp
        di
        halt

int_proc_byp:
        ld a,(setpalflag)
        or a
        call nz,setpal_proc


        call oldimer
        di

        GET_KEY
        ld a,c
        ld (keyreg),a
        OS_GETKEYMATRIX
        ld (keymatrixbc),bc
        ld (keymatrixde),de
        ld (keymatrixhl),hl
        ld (keymatrixix),ix





insspp_exit:
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af'
        exx
        pop hl
        pop bc

        ;xor a
        ;ld r,a

        ld a,0xeb   ;ex de,hl
;c_stor equ $-1
         ld (int_proc),a

        pop af
on_int_sp=$+1
        ld sp,0
        pop de
        ei
on_int_jp=$+1
        jp 0


cp_hl_de:
                ld      a, h
                cp      d
                ret     nz
                ld      a, l
                cp      e
                ret
;------------------------------
set_music_pages:
        ld a,(curpg4000)
        ld (zbank1),a
        ld a,(curpg8000)
        ld (zbank2),a
        ld a,(curpgc000)
        ld (zbank3),a

        ld a,(plr_page)
        SETPG4000
        ld a,(plr_page2)
        SETPG8000
        ld a,(plr_page3)
        SETPGC000
        ret

unset_music_pages:
        ld a,0
zbank1 equ $-1
        SETPG4000
        ld a,0
zbank2 equ $-1
        SETPG8000
        ld a,0
zbank3 equ $-1
        SETPGC000
        ret
		
		
		
set_text_pages:
        ld a,(curpg4000)
        ld (ztbank1),a
        ld a,(curpg8000)
        ld (ztbank2),a
        ld a,(curpgc000)
        ld (ztbank3),a

        ld a,(textpage1)
        SETPG4000
        ld a,(textpage2)
        SETPG8000
        ld a,(textpage3)
        SETPGC000
        ret

unset_text_pages:
        ld a,0
ztbank1 equ $-1
        SETPG4000
        ld a,0
ztbank2 equ $-1
        SETPG8000
        ld a,0
ztbank3 equ $-1
        SETPGC000
        ret
;----------------------------
store_c000:
		push af
        ld a,(curpgc000)
        ld (restore_c000.bank3),a
		pop af
		ret
restore_c000:
		push af,bc
        ld a,0
.bank3 equ $-1
        SETPGC000
		pop bc,af
        ret
;---------------------------		
store_48c
        ld a,(curpg4000)
        ld (ebank1),a
        ld a,(curpg8000)
        ld (ebank2),a
        ld a,(curpgc000)
        ld (ebank3),a
		ret

set_loadbuf:
		call store_48c
        ld a,(load_buf1)
        SETPG4000
        ld a,(load_buf2)
        SETPG8000
        ret

restore_48c:
        ld a,0
ebank1 equ $-1
        SETPG4000
        ld a,0
ebank2 equ $-1
        SETPG8000
        ld a,0
ebank3 equ $-1
        SETPGC000
        ret


;---------------------
load_mus
        cp 0xff
        ret z
        ld (load_mus+1),a
        
		push af
		call set_music_pages
		ld a,(plr_page)
		ld hl,p_play
		OS_SETMUSIC
		
		pop af
        push af
		call p_init
		pop af
		call p_init
		jp unset_music_pages


no_mus:
		call set_music_pages
                 call p_mute
;                 ld a,(plr_page)
;                 ld hl,0
;                 OS_SETMUSIC
		jp unset_music_pages


set_p_mod:
		call set_music_pages
                call p_mod
		jp unset_music_pages
		
advance_music:
                call set_music_pages
                call p_advance
                jp unset_music_pages
music_till_end:
                call set_music_pages
                call p_tillend
                jp unset_music_pages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getkey
        ld a,(keyreg)
        ret
check_space_key
		call getkey
		cp " "
		ret nz
.fexit		
		call set_music_pages
		ld a,0xc9
		ld (SCROLL_LOCK),a		
		call unset_music_pages
		
		call no_mus		
		jp ze_start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NumToHex    ld c, a   ; a = number to convert
            call Num1
            ld d, a
            ld a, c
            call Num2
            ld e, a
            ret  ; return with hex number in de
            
Num1        rra
            rra
            rra
            rra
Num2        or $F0
            daa
            add a, $A0
            adc a, $40 ; Ascii hex at this point (0 to F)   
            ret
;-------------------------------------------------------			
mul_h_l:
                push    de
                push    bc
                ld      e, l
                ld      d, 0
                ld      l, d
                ld      b, 8
.loc_8BA3:               
                add     hl, hl
                jr      nc, .loc_8BA7
                add     hl, de
.loc_8BA7:               
                djnz    .loc_8BA3
                pop     bc
                pop     de
                ret
;-------------------------------------------------------
div_hl_a:							
                push    bc
                ld      c, a
                ld      b, 0x10
                xor     a
.loop:
                add     hl, hl
                adc     a, a
                jr      c, 1f
                cp      c
                jr      c, 2f
1
                sub     c
                inc     l
2
                djnz    .loop
                pop     bc
                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
randomizer_pseudo:               
                push    hl
.curr_line_counter = $+1:  
                ld      a, 9Dh
.curr_line_ptr = $+1
                ld      hl, vertial_coordinates_array
                dec     a
                jr      z, .end_of_list

.loc_8951:                             
                ld      (.curr_line_counter), a
                ld      a, (hl)
                inc     hl
                ld      (.curr_line_ptr), hl
                pop     hl
                ret
; ---------------------------------------------------------------------------

.end_of_list:
                ld      hl, vertial_coordinates_array
                ld      a, 9Ch
                jr      .loc_8951

				
				
draw_line_on_screen:
                push af
                ld a,(sizex)
                add a,a  
                add a,a ; a- sizex *4 - actual bytes for one string
                ld h,a

                pop af
                ld l,a  ;vertical coord
                call mul_h_l
                ld de,IMG_BUFFER   ;!buffer start
                add hl,de                 ; hl - src
                ex de,hl 
                ld l,a  ;vertical coord
                ld h,40         ;40 bytes per screen line
                call mul_h_l
                push af


                        ld bc,(screen_adr_img)
                        add hl,bc               
                        ex de,hl        ;de actual adress on the screen

                        push de
                                ld a,(user_scr0_low) ;ok       ;attrs
                                SETPGC000

                                ld bc,(sizex)
                                ld b,0          ;c - sizex
                                ;ldir
								ex de,hl
.lp1:								
								ld a,(de)
								ld (hl),a
								inc hl:inc de:dec bc
								ld a,b:or c:jr nz,.lp1
								ex de,hl
                        pop de
                        push de
                                ;ld a,d
                                ;xor 0x20
                                ;ld d,a                                
								nextcolumnde

                                ld bc,(sizex)
                                ld b,0          ;c - sizex
                                ;ldir
								ex de,hl
.lp2:								
								ld a,(de)
								ld (hl),a
								inc hl:inc de:dec bc
								ld a,b:or c:jr nz,.lp2
								ex de,hl
                        pop de

                        push de
                                ld a,(user_scr0_high) ;ok       ;pixels
                                SETPGC000

                                ld bc,(sizex)
                                ld b,0          ;c - sizex
                                ldir
                        pop de
								nextcolumnde
                                ;ld a,d
                                ;xor 0x20
                                ;ld d,a                                

                                ld bc,(sizex)
                                ld b,0          ;c - sizex
                                ldir

                pop af
                ret				
				

				
				
			
vertial_coordinates_array:
                db 26h, 30h, 31h, 51h, 9, 7Ch, 4Eh, 39h, 9Bh, 8Eh, 72h, 1, 99h, 0, 97h, 6
                db 8Dh, 68h, 57h, 81h, 8Fh, 87h, 89h, 50h, 5Ch, 46h, 5, 5Fh, 7Bh, 2Dh, 15h, 23h
                db 22h, 8Ah, 59h, 78h, 1Fh, 60h, 3Bh, 75h, 28h, 92h, 47h, 8Bh, 2Bh, 76h, 73h, 14h
                db 3, 6Dh, 5Bh, 70h, 8Ch, 24h, 12h, 6Fh, 56h, 7Fh, 4Ch, 88h, 13h, 0Fh, 79h, 43h
                db 7Eh, 18h, 63h, 44h, 55h, 96h, 35h, 5Dh, 37h, 7, 67h, 2Fh, 4Ah, 42h, 69h, 2
                db 10h, 8, 17h, 6Bh, 64h, 85h, 5Ah, 2Ah, 38h, 0Eh, 4, 54h, 32h, 19h, 4Fh, 3Ch
                db 98h, 7Dh, 94h, 33h, 0Ch, 3Eh, 80h, 53h, 21h, 4Bh, 62h, 91h, 86h, 25h, 93h, 61h
                db 84h, 7Ah, 0Ah, 66h, 58h, 3Ah, 16h, 6Eh, 65h, 34h, 49h, 1Ch, 71h, 3Dh, 0Dh, 1Eh
                db 5Eh, 95h, 9Ah, 2Eh, 90h, 40h, 20h, 52h, 41h, 3Fh, 2Ch, 82h, 11h, 36h, 1Bh, 74h
                db 6Ch, 1Dh, 27h, 6Ah, 77h, 4Dh, 48h, 1Ah, 45h, 0Bh, 29h, 83h

load_item_image:
			push af
				call store_48c
				ld a,(item_buf)
				push hl
				ld hl,IMG_BUFFER
				jp load_image.insrt
load_portrait_image:
			ld b,0
			push af
				ld a,b
				ld (portrait_lock),a				
				call store_48c
				ld a,(portrait_buf)
				push hl
				ld hl,IMG_BUFFER
				jp load_image.insrt
load_logo_img
			push af
				call store_48c
				ld a,(jb_logo_buf)
				push hl
				ld hl,IMG_BUFFER
				jp load_image.insrt
				

load_image_waddr
				push af
				push hl
				ld a,(load_buf2)
				SETPG8000				
				ld a,(load_buf1)
				jp load_image.insrt


load_image_intro:
			push af
			jr load_image.intr
load_image
;in a = file index
			push af

				call store_48c
.intr				
				ld a,(load_buf2)
				SETPG8000				
				ld a,(load_buf1)
				push hl
				ld hl,IMG_BUFFER
.insrt			
				ld (.imgaddr),hl
				pop hl
				SETPG4000

			pop af

	
				ld (file_index),a
				push af
				ld de,buf
				ld hl,gfx_path1
				call copystr_hlde
				pop af
				
				ex de,hl
				call NumToHex
				ex de,hl
				ld a,h
				ld (de),a
				inc de
				ld a,l
				ld (de),a
				inc de
				ld hl,gfx_path2
				call copystr_hlde
				xor a
				ld (de),a
				
				ld de,buf
				call openstream_file
;read image dimensions
				ld hl,2 ;len
				ld de,sizex ;addr
				call readstream_file	
;read image
.imgaddr = $+1
				ld de,IMG_BUFFER
				ld hl,0x8000
				call readstream_file
				
				call closestream_file 
				ld a,(sizey)
				cp 200
				jp z,display_fullscreen_image
				ld a,(file_index)
				cp 0x0a
				jp c,display_image_from_buffer
				cp 0x11
				ret c   	;intro and fullscreen images with external drawing routine
				cp 0x20
				jp c,display_item_images
				cp 0x47
				jp c,display_portrait_images
				cp 0x8d ;ignore images above 0x8c
				ret nc
				
				ld hl,0xc000
display_image_from_buffer_with_addr:
				ld (screen_adr_img),hl
display_image_from_buffer:
                ld a,(sizey)
                ld ixh,a
                ld ixl,a
.shuffled
                call  randomizer_pseudo    ;out - A - line number             
                cp ixl
                jp nc,.shuffled 
                call draw_line_on_screen

.display_delay = $+1
				ld bc,DEFAULT_DELAY
.dsd			dec bc
				ld a,b
				or c
				jr nz,.dsd


                dec ixh
                jr nz,.shuffled
                call  randomizer_pseudo
.img_exit
				call restore_48c
                ret
display_fullscreen_image:
				ld hl,0xc000
				ld (screen_adr_img),hl
				xor a
.loop
				push af
				call draw_line_on_screen
				pop af
				inc a
				cp 200
				jr nz,.loop
				jr display_image_from_buffer.img_exit
;-----------------------------
display_item_images:
                ld      hl, 0xc000+79*40+31		; 0D8EEh      pc-88 screen address
                xor     a
                ld      (load_card_image+1), a
                jp      display_image_from_buffer_with_addr
;-----------------------------
display_portrait_images:
				ld a,(portrait_lock)
				or a
				ret nz
				call randomizer_pseudo
				
				push af
				and 2
				ld l,a
				ld h,0x42
				call mul_h_l
				pop af
				and 1
				ld (frame_horisontal_offset_type),a
				or l
				ld l,a
				ld h,0x14			;0x28 pc-88
				call mul_h_l
				ld de,0xc000			
				add hl,de
;-----------------------------
				
				
				ld (screen_adress_for_npc_portrait),hl
				push hl
				call  store_person_background
				pop hl
				jp display_image_from_buffer_with_addr

store_person_background:
				ld a,(curpgc000)
				push af
				ld a,(curpg8000)
				push af
				ld a,(load_buf1)
				SETPG8000
				
		
SA_LINE_LEN = 9
				ld de,G_BUFFER1
				ld a,0x5a
.loop:
				push af				
				ld a,(user_scr0_low)
				SETPGC000	
				push hl
				ld bc,SA_LINE_LEN
				ldir
				pop hl
				push hl
				set 5,h
				ld bc,SA_LINE_LEN
				ldir
				ld a,(user_scr0_high)
				SETPGC000	
				pop hl
				push hl
				ld bc,SA_LINE_LEN
				ldir
				pop hl
				push hl
				set 5,h
				ld bc,SA_LINE_LEN
				ldir
				pop hl
				ld bc,40
				add hl,bc								
				pop af
				dec a
				jr nz,.loop
				pop af
				SETPG8000
				pop af
				SETPGC000
				ret

;-----------------------------
clear_window:
;hl-addr
;b - height lines
;c - width bytes+1
		dec c
		push de,af,bc
		call store_c000
		ld a,(user_scr0_high)
		SETPGC000
		pop bc
		
		ld a,b
		ld b,0
		ld (.clear_bitplan_area+1), bc
		ld (.clear_bitplan_area2+1), bc
		
		
.lp_scrh
		ld d,h
		ld e,l
		inc de


.clear_bitplan_area:
                ld      bc, 0
                push    hl,de
                ld      (hl), 0
                ldir
                pop     de,hl
				push 	hl,de
.clear_bitplan_area2:
                ld      bc, 0
				set 5,h
				set 5,d
                ld      (hl), 0
                ldir
                pop     de,hl

		ld bc,40
		add hl,bc
		dec a
		jr nz,.lp_scrh

		call restore_c000
		pop af,de
		ret

;-----------------------------
clear_loc_screen:
		ld a,(curpgc000)
		ld (.pgc0000stor1),a

		ld a,(user_scr0_high)
		SETPGC000
		
		ld hl,0xc000
		ld de,0xc001
		ld bc,16383
		ld (hl),0
		ldir

		ld a,(user_scr0_low)
		SETPGC000
		
		ld hl,0xc000
		ld de,0xc001
		ld bc,16383
		ld (hl),7
		ldir
		
.pgc0000stor1 = $+1
		ld a,0
		SETPGC000
		ret
;-------------------------------------------		

load_card_image
		ld a,0
		or a
		ret nz
		ld hl,0xc000+77*40+29+0x2000	;		49152+77*40+60/2
		ld (screen_adr_img),hl
;<<<<		
		call load_logo_img   ;a = image number
							;ld      hl, jb_logo_location
							;call    image_load_w_addr
;<<<<		
		ld a,1
		ld (load_card_image+1),a
		ret
		
		

;fdc function 2		
gamestate_fdc_handler:

;in: -A,E   (DE)
;                call    wait_byte_from_pc88
;                ld      e, a
;                call    wait_byte_from_pc88


                ld      d, a		 
				ld 		hl,gamestate_fdc_buffer
				ld 		(.sendbyte_pointer),hl
				
				ld 		(.store_sp),sp
                ld      bc, 0x0E02       ; len = 0x010e records
                di
                ld      sp, gamestate_fdc

.game_state_handler_loop:                ; CODE XREF: RAM:_fdc_to_the_endvj
                                        ; RAM:68D9vj
                ld      (.set_position_sp+1), sp

.game_state_handler_loop_inner:          ; CODE XREF: RAM:68BCvj
                pop     hl
                ld      a, h
                or      l
                jp      z, .hl_0_skip
                sbc     hl, de
                jp      nz, .game_state_handler_loop_inner
                ld      h, 0xFF
                push    hl

.set_position_sp:               ; DATA XREF: RAM:game_state_handler_loop^w
                ld      sp, 0 ; 788a
                                        ; указатель на последние 8 байт блока данных fdc gamestate

.high_h_is_set:                         ; CODE XREF: RAM:68CDvj
                pop     hl
                ld      a, h
                or      l
                jp      z, .hl_is_zero
                rlc     h
                jr      c, .high_h_is_set

.hl_is_not_zero:                        ; CODE XREF: RAM:68D2vj
                pop     hl
                ld      a, h
                or      l
                jr      nz, .hl_is_not_zero

.hl_0_skip:                             ; CODE XREF: RAM:68B7^j
                pop     hl
                inc     sp

.fdc_to_the_end:                        ; CODE XREF: RAM:6900vj
                djnz    .game_state_handler_loop
                dec     c
                jr      nz, .game_state_handler_loop
.store_sp = $+1
                ld      sp,0 ; restore original SP
                ei
                ld      a, 0xFF
                jp    .send_byte_to_pc88
                ;ret        ; exit		
				
.hl_is_zero:                            ; CODE XREF: RAM:68C8^j
                dec     sp
                pop     hl
                ld      a, h
                pop     hl
                ld      (.fdc_preserve_sp), sp
				
                ld      sp, (.store_sp)
                call    .send_byte_to_pc88
                ld      a, l
                call    .send_byte_to_pc88
                ld      a, h
                call    .send_byte_to_pc88
				

.fdc_preserve_sp: = $+1                       ; DATA XREF: RAM:68EB^w
                ld      sp, 0
                jr      .fdc_to_the_end
				
.send_byte_to_pc88
				push hl
.sendbyte_pointer = $+1
				ld hl,0
				ld (hl),a
				inc hl
				ld (.sendbyte_pointer),hl
				pop hl
				ret
;----------------------------------------------------------------------------------	
;get_pointer_to_tbl_999e_gamestate_by_8D27value			
get_pointer_to__gamestate_main_by_8D27value:
                ld      a, (temp_location_id_byte_8d27)  
				
;get_pointer_to_tbl_999e_gamestate_by_A:
get_pointer_to__gamestate_main_by_A:
;in a ;  min A=1
                ld      l, a
                ld      h, 0
                add     hl, hl
                add     hl, hl
                add     hl, hl
                push    de
                ld      de, gamestate_main-8 ; 8 bytes per entry
                add     hl, de
                pop     de
                ret
;=======================================================================================
find_string_by_de:
				dec de
				inc d
				inc e
				push bc
				ld bc,0xffff
				ld a,b
				jr .nex
.nex1:
				cpir
.nex:
				dec e
				jr nz,.nex1
				dec d
				jr nz,.nex1
				pop bc
				ret
;=======================================================================================
get_fdc_byte:
			push hl
.gfb = $+1		
			ld hl,0
			ld a,(hl)
			inc hl
			ld (.gfb),hl
			pop hl
			ret
;=======================================================================================
;modules_loader
load_text_module:
				cp 0
				ret z
				ld (load_text_module+1),a
				add a,"0"
				ld (txt_mdl+5),a
				push de
				call set_text_pages
				
				ld de,txt_mdl
				call openstream_file
				ld hl,0xc000 ;len
				ld de,TEXT_START ;addr
				call readstream_file					
				call closestream_file                                
				call unset_text_pages
				pop de
				ret
;-------------------------
wait_for_key_input:
				call getkey
				cp NOKEY
				ret z	;no key_exit
				cp 13   
				jr nz,1f
				ld a,0xFF
				ret    ; enter - exit
1				cp ' ' 
				jr nz,1f
				ld a,0x1b
				ret    ;	space - exit
1				cp "1"
				jr nc,1f	;less than 1 - exit
				ld a,NOKEY
				ret
1				cp "7"+1
				jr nc,1f
				;digits
				sub "0"
				ret
1				cp "A"
				jr nc,1f
				ld a,NOKEY
				ret
1				cp "Z"+1
				jr nc,1f
				;letter A-Z ret
				ret
1				cp "a"
				jr nc,1f
				ld a,NOKEY
				ret
1				cp "z"+1
				jr c,1f
				; out of a-z range
				ld a,NOKEY
				ret
1				;a-z range	
				sub 0x20		;change to A-Z range
				ret
				
;---
;------------------
draw_image_stripes
                ld hl,gfdpal
                ld de,pal
                ld bc,32
                ldir 
                ld a,1
                ld (setpalflag),a

				ld a,(curpgc000)
				push af
				ld a,(curpg8000)
				push af

				
                ld      hl, 08006h
                ld      bc, 0
                ld      xh, 0Dh

.loc_AE73:                 
				xor a
				ld (.rety),a
                push    bc
                push    hl
;				halt
.loc_AE75:               
				push bc
				ld a,(user_scr0_low)
				SETPGC000
				ld a,(load_buf2)
				SETPG8000
                ld a,(hl)
				set 6,h
				ld (hl),a
				res 6,h
				
				ld a,(user_scr0_high)
				SETPGC000
				ld a,(load_buf1)
				SETPG8000
                ld a,(hl)
				set 6,h
				ld (hl),a
				res 6,h
				pop bc
				
                ld      de, 6
                add     hl, de
				nextcolumnhl
.rety	= $+1			
				ld a,0				
                add     a, c
                add     a, e
                ld      c, a
				push af
				ld a,(.rety)
				xor 1
				ld (.rety),a
				pop af
                sub     29+6			;3Ah ; ':'
                jr      c, .loc_AE75
				
                ld      c, a
                ld      de, 11-6	;16h
                add     hl, de
                inc     b
                ld      a, b
                cp      9Ch
                jr      c, .loc_AE75
                pop     hl
                pop     bc
                ;inc     hl
				nextcolumnhl
                inc     c
                dec     xh
                jr      nz, .loc_AE73

				pop af
				SETPG8000
				pop af
				SETPGC000
				ret
;--------------
load_gfd_direct:
;in de-filename
		call store_48c
		ld a,(user_scr0_high)
		SETPG8000
		ld a,(user_scr0_low)
                jr load_gfd.bp
load_gfd:
;in de-filename
		call store_48c
		ld a,(load_buf1)
		SETPG8000
		ld a,(load_buf2)
.bp
		SETPGC000
		call openstream_file
						;		or a
						;		jp nz,fileopenerror
		ld hl,0x8000 ;len
		ld de,0x8000 ;addr
		call readstream_file
						;		or a
						;		jp nz,filereaderror
		ld hl,32 ;len
		ld de,gfdpal ;addr
		call readstream_file
						;		or a
						;		jp nz,filereaderror
		call closestream_file
		jp restore_48c
