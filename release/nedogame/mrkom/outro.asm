        	MODULE outro
ro_start:
				DISP T_START
				ld a,5
				call load_mus
				call fade_toblack	
				
				call clear_loc_screen
				call clear_2nd_screen


				ld a,(user_scr0_high)
				SETPG4000
				ld a,(user_scr1_high)
				SETPGC000




				ld de,tree
				call load_gfd_direct




				
				
				ld      b, 0D2h
.gen_snow_lp:
                push    bc
                call    generate_snow_table
                pop     bc
                djnz    .gen_snow_lp

				ld hl,mempal
				ld de,pal
				ld bc,32
				ldir 


                ld hl,pal+9*2
				ld de,pal+1*2
                ldi
				ldi

                ld hl,pal+9*2
				ld de,mempal+1*2
                ldi
				ldi


				;=============================
				ld a,1
				ld (screenswapper),a
				;=============================
				
				call fade_fromblack
		




				
			
loc_AC3F:

                ld      b, 1Eh
sf_dl:
                push    bc
                xor     a

sf_loop:
                push    af              ; выводим снежинки по одной
                call    draw_snowflake
                pop     af
                inc     a
                ld      hl, snowflakes_count ; здесь хранится максимальное количество снежинок которые мы сгенерировали
                cp      (hl)
                jr      c,sf_loop
                halt	;call    wait_vertical_retrace
                pop     bc
                djnz    sf_dl        ; повторяем 0x1e раз

;-------------------------------------
;set random chistmas tree lights color
loc_AC55:
.color = $+1
                ld a,2
                xor 4
                ld (.color),a
                call randomizer2
                and 7
                add a,a
                ld e,a
                ld d,0
                ld hl,mempal
                add hl,de
                ld c,(hl)
                inc hl
                ld b,(hl)

                ld hl,pal
                ld a,(.color)
                add a,a
                ld e,a
                ld d,0
                add hl,de
                ld (hl),c
                inc hl
                ld (hl),b

		ld a,1
		ld (setpalflag),a
;		halt
;-------------------------------------
sffal_wait = $+1
                ld      a, 4Bh
                dec     a
                jr      z, loc_AC6F
                ld      (sffal_wait), a
                jp      loc_AC3F

loc_AC6F:	;turn off NY tree
                ld      a, 0C3h
                ld      (loc_AC55), a
                ld      hl, loc_AC3F
                ld      (loc_AC55+1), hl

;-------------------------------				
;set all white lights on NY tree
                ld hl,mempal+7*2
                ld c,(hl)
                inc hl
                ld b,(hl)

                ld hl,pal+2*2
                ld (hl),c
                inc hl
                ld (hl),b

                ld hl,pal+6*2
                ld (hl),c
                inc hl
                ld (hl),b

				ld a,1
				ld (setpalflag),a
;-------------------------------				
				
				
                jp      loc_AC3F


increment_snowflake_vertical_position:
                ld      hl, 0
                inc     hl
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                inc     hl
                ld      a, (hl)
                inc     a
                cp      0C8h
                jp      z, snowflake_out_of_bounds
                ld      (hl), a
                ex      de, hl
                ld      bc, 40		;50h ; 'P'
                add     hl, bc
                ex      de, hl
                dec     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                dec     hl
                ret

snowflake_out_of_bounds:
                call    randomizer
                ld      hl, (increment_snowflake_vertical_position+1)
                and     0Fh
                ld      (hl), a
                inc     hl
                call    randomizer_0_4f
				and a
				rra
				jr c,.is_odd
                ld      (hl), a
                inc     hl
                ld      (hl), 0C0h
                inc     hl
                ld      (hl), 0
                ret
.is_odd
				ld      (hl), a
                inc     hl
                ld      (hl), 0E0h
                inc     hl
                ld      (hl), 0
                ret


randomizer:
                push    bc
.loc_91D7:
                ld      b, 0
                ld      a, r
                add     a, b
                ld      (.loc_91D7+1), a
                pop     bc
                ret

randomizer2:
                push    bc
.loc_91D7:
                ld      b, 0
                ld      a, r
                add     a, b
                ld      (.loc_91D7+1), a
                pop     bc
                ret


clear_2nd_screen
		ld a,(curpgc000)
		ld (.pgc0000stor1),a
		ld a,(user_scr1_high)
		SETPGC000
		ld hl,0xc000
		ld de,0xc001
		ld bc,16383
		ld (hl),0
		ldir
		ld a,(user_scr1_low)
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
		
generate_snow_table:			;table at 0x8000		
               ld      a, (snowflakes_count)
               ld      l, a
               ld      h, 20h ; ' '
               add     hl, hl
               add     hl, hl
               push    hl
               ex      de, hl
               inc     a
               ld      (snowflakes_count), a
               call    randomizer
               and     0Fh
               ld      (de), a         ; value 0-15
               call    randomizer_0_C6
               push    af
               ld      l, a
               ld      h, 0
               ld      d, h
               ld      e, l
               add     hl, hl
               add     hl, hl
               add     hl, de
               add     hl, hl
               add     hl, hl
               add     hl, hl          ; generate vertical coordinate
                                       ; 0-0xc6 *40
               call    randomizer_0_4f ; generate horisontal coordinate
                                       ; in 0 - 79
				and a
				rra
				ld d,0xc0
				jr nc,.is_even
				ld d,0xe0
.is_even				
                ld      e, a
               add     hl, de
               ex      de, hl
               pop     af              ; de = screen adress
                                       ; a = vertical coordinate
               pop     hl              ; restore position in array
               inc     hl
               ld      (hl), e         ; write - screen addr, vertical coordinate
               inc     hl
               ld      (hl), d
               inc     hl
               ld      (hl), a         ; итого запись - 4 байта
                                       ;
                                       ; db индекс - 0-15
                                       ; dw экранный удрес
                                       ; db вертикальная координата
               ret
			   
snowflakes_count:
               db 0
			   
randomizer_0_4f:
                push    hl
.loop:
                call    randomizer
                and     7Fh
                cp      50h ; 'P'
                jr      nc,.loop
                pop     hl
                ret

randomizer_0_C6:
                push    hl
.loop:
                call    randomizer
                cp      0C7h
                jr      nc,.loop
                pop     hl
                ret


draw_snowflake:
                ld      l, a
                ld      h, 20h ; ' '
                add     hl, hl
                add     hl, hl
                ld      (increment_snowflake_vertical_position+1), hl
                ld      a, (hl)
                inc     hl
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                cp      2
                jr      c, snowflake_0_1
                xor     a               ; erase snowflake?
                ld      (de), a
                jr      loc_AB82

snowflake_0_1:
                ex      de, hl
				
                ld      de, 40 	;50h
                ld      (hl), d
                add     hl, de
                ld      (hl), d
                add     hl, de
                ld      (hl), d


loc_AB82:       
                call    increment_snowflake_vertical_position ; с пересчётом адреса
                ld      a, (hl)         ; index
                cp      8
                jr      nc, index_8_15
                cp      2
                jr      c, index_01
                xor     1
                ld      (hl), a
                and     1
                jr      z, index_8_15

index_01:
                call    increment_snowflake_vertical_position

index_8_15:
                ld      hl, (increment_snowflake_vertical_position+1)
                ld      a, (hl)         ; get new position for current snowflake
                inc     hl
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                cp      2
                jr      c, index_0_1
                ld      hl, sprite_2
                cp      8
                jr      c, index_2_7
                inc     hl
                and     1
                jr      z, index_2_7
                inc     hl

index_2_7:
                                        ; draw_snowflake+52j
                ld a,(hl)
				ld (de),a
				inc bc
				nextcolumnde
                ret

index_0_1:
               ld      hl, sprite_1
               ex      de, hl
               ld      bc, 40		;50h ; 'P'
               ld      a, (de)
               ld      (hl), a
               inc     de
               add     hl, bc
               ld      a, (de)
               ld      (hl), a
               inc     de
               add     hl, bc
               ld      a, (de)
               ld      (hl), a
               
               ret
			   
sprite_1:       db    8
                db  1Ch
                db    8
sprite_2:       db  18h
                db  20h
                db    2
tree		db "gfx/tree.gfd",0

		ENT
ro_end:
			savebin "kissofmurder/outro.bin",ro_start,ro_end-ro_start
			ENDMODULE