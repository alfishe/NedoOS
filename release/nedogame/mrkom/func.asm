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

        ld a,0
screenswapper: equ $-1
        and a
        call nz,switchscreens



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



switchscreens:
        ld e,1
swscrsw equ $-1
        push de
        OS_SETSCREEN
        pop de
        ld a,e
        xor 1
        ld (swscrsw),a
        ret
		
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
;        ld a,(curpgc000)
;        ld (ztbank3),a

        ld a,(textpage1)
        SETPG4000
        ld a,(textpage2)
        SETPG8000
;        ld a,(textpage3)
;        SETPGC000
        ret

unset_text_pages:
        ld a,0
ztbank1 equ $-1
        SETPG4000
        ld a,0
ztbank2 equ $-1
        SETPG8000
;        ld a,0
;ztbank3 equ $-1
;        SETPGC000
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
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getkey
        ld a,(keyreg)
        ret
;-------------------------------------------------------
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
		
load_mus
		push af
		call set_music_pages
		ld a,(plr_page)
		ld hl,p_play
		OS_SETMUSIC
		
		pop af
		call p_init
		
		jp unset_music_pages


no_mus:
		call set_music_pages
                 call p_mute
                 ld a,(plr_page)
                 ld hl,0
                 OS_SETMUSIC
		jp unset_music_pages


set_p_mod:
		call set_music_pages
                call p_mod
		jp unset_music_pages
		
advance_music:
		call set_music_pages
        call p_advance
		jp unset_music_pages
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
                db 6Ch, 1Dh, 27h, 6Ah, 77h, 4Dh, 48h, 1Ah, 45h, 0Bh, 29h, 83h,0
				
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
				
				ld a,(load_image_directly)
				and a
				jp nz,display_fullscreen_image
				
				ld a,(file_index)
				and a
				jr z,display_image_from_buffer
				cp 0x47
				jr c,display_image_bgnd
				cp 0x6e
				jp c,display_portrait_images
				cp 0x79
				ret c		;external routine
				cp 0x8d
				jp c,display_item_images
				ret		;external routine

display_image_bgnd:				
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
;-----------------------------------------------------	

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
                ld      bc, 4F02h        ; ; len = 0x014f
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
				push hl,bc,af
				add a,"0"
				ld (txt_mdl+5),a
				push de
				call set_text_pages
				
				ld de,txt_mdl
				call openstream_file
				ld hl,0x8000 ;len
				ld de,TEXT_START ;addr
				call readstream_file					
				call closestream_file                                
				call unset_text_pages
				pop de
				pop af
				push af
				cp 5
				jr nc,.loc_9381
                ld      hl, tbl_9391-1	;не допускать пересечения ff - 00
                add     a, l
                ld      l, a
                ld      a, (hl)
                ld      (next_modul), a
.loc_9381:
                pop     af
                pop     bc
                pop     hl
                ret
tbl_9391:       db    2
                db    4                 ; только для модулей с номером меньше 5
                db    3
                db    5                 ; подставляется при загрузке модуля 4
;=======================================================================================
get_pointer_to__gamestate_main_by_b9ea:
                ld      a, (temp_location_id_byte_b9ea)
                jr      get_pointer_to__gamestate_main_by_A
get_pointer_to__gamestate_by_temp_location_id:
                ld      a, (temp_location_id)
get_pointer_to__gamestate_main_by_A:
                ld      l, a
                ld      h, 0
                add     hl, hl
                add     hl, hl
                add     hl, hl
                push    de
                ld      de, gamestate_main-8
                add     hl, de
                pop     de
                ret
;=======================================================================================
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
execute_hl:                             ; CODE XREF: seg002:AD42p
                                        ; seg002:AD9Bp ...
                ld      d, 0
                ld      (.callhl+1), hl
                ld      hl, table_dialogue_questions_index_buffer
                ld      (loc_ABA8+1), hl
                ld      c, 1
                ld      hl, gamestate_main

.loop:                               ; CODE XREF: execute_hl+1Dj
                push    hl

.callhl:
                call    0
                pop     hl
                ld      de, 8
                add     hl, de
                inc     c
                ld      a, c
                cp      0ADh
                jr      nz, .loop
                ld      a, (loc_ABA8+1)
                sub     LOW table_dialogue_questions_index_buffer		;4Bh ; 'K'
                ret     nc
                neg
                ret
loc_ABA8:
                ld      hl, table_dialogue_questions_index_buffer
                ld      (hl), c
                inc     hl
                ld      (loc_ABA8+1), hl
                ret
				
				
				
sub_ABB1:
                ld      hl, (temp_location_id_byte_b9ea)
                ld      h, 5
                call    mul_h_l
                ld      de, byte_A021
                add     hl, de
                ld      d, 5
                jr      loc_ABE6
sub_ABC1:
                ld      hl, (temp_location_id_byte_b9ea)
                ld      h, 9
                call    mul_h_l
                ld      de, msg_9F24
                add     hl, de
                ld      d, 9
                jr      loc_ABE6
sub_ABD1:
                ld      hl, (temp_location_id_byte_b9ea)
                ld      h, 7
                call    mul_h_l
                ld      de,  byte_9F40+4
                add     hl, de
                ld      d, 7
                jr      loc_ABE6

sub_ABE1:
                ld      hl, byte_9F40
                ld      d, 0Eh
loc_ABE6:
                ld      e, 1
loc_ABE8:
                cp      (hl)
                ret     z
                inc     hl
                inc     e
                dec     d
                jr      nz, loc_ABE8
                dec     d
                ret
;--------------------------------------------------
sub_AC64:
                ld      l, a
                ld      h, 0
                ld      c, l
                ld      b, h
                add     hl, hl
                add     hl, bc
                ret
sub_AC6C:
                push    hl
                ld      hl, (next_modul)
                ld      h, 64h ; 'd'
                call    mul_h_l
                ld      b, h
                ld      c, l
                ld      hl, (unk_B9F4)
                dec     l
                ld      h, 46h ; 'F'
                call    mul_h_l
                add     hl, bc
                pop     bc
loc_AC82:
                add     hl, bc
                ld      b, 0
                ret
sub_AC86:
                ld      b, h
                ld      c, l
                ld      hl, (unk_B9F4)
                ld      h, 64h ; 'd'
loc_AC8D:
                dec     l
                call    mul_h_l
                jr      loc_AC82
sub_AC93:
                ld      b, h
                ld      c, l
                ld      hl, (word_B9EC)
                ld      h, 50h ; 'P'
                jr      loc_AC8D
sub_AC9C:
                ld      b, h
                ld      c, l
                ld      hl, (temp_location_id_byte_b9ea+1)
                ld      h, 9
                jr      loc_AC8D

sub_ACA5:
                ld      (temp_location_id_byte_b9ea), a
                push    af
                push    hl
                ld      hl, unk_ACC5
                dec     a
                srl     a
                ld      c, a
                ld      b, 0
                push    af
                add     hl, bc
                pop     af
                ld      a, (hl)
                jr      c, loc_ACBD
                rrca
                rrca
                rrca
                rrca

loc_ACBD:                               ; CODE XREF: sub_ACA5+12j
                and     0Fh
                ld      (unk_B9F4), a
                pop     hl
                pop     af
                ret
unk_ACC5:       db    1                 ; DATA XREF: sub_ACA5+5o
                db  12h
                db  23h ; #
                db  13h
                db  14h
                db  23h ; #
                db  54h ; T
                db  21h ; !
                db  23h ; #
                db  11h
                db  42h ; B
                db  34h ; 4
                db  25h ; %
                db  53h ; S
                db  45h ; E
                db  68h ; h
                db    7
                db  67h ; g
                db    0
                db    0









				
fade_toblack:
			ld hl,0x2ddd
			xor a
			jr fade_to
fade_towhite:
			ld a,15
			ld hl,0x2cdd
fade_to:
			jp fade_to_sub

fade_fromblack:
			ld hl,0x2cdd
			xor a
			jr fade_from
fade_fromwhite:
			ld a,15
			ld hl,0x2ddd
fade_from:
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

	ld a,1
	ld (setpalflag),a

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

	ld a,1
	ld (setpalflag),a

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
	ld a,1
	ld (setpalflag),a
        halt
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
palette_precalc_sub:
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


;===================
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
		
		
;=====
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
				
				
;------------------
draw_image_stripes
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
				halt
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
		call closestream_file
		jp restore_48c

		
wait_mus_end
				call set_music_pages
.llpp
				ld a,(mus_end)
				or a
				jr z,.llpp
				jp unset_music_pages