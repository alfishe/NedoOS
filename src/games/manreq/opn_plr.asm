                MODULE OPN_PLR
PLR_START= 0x4000
EXT_RTN = 0x5800
opn_begin:
                DISP PLR_START
                jr init_
                jp PLR_PLAY
                jp mute
is_music_ended  db 0
;0x4009
                jp plr_mod
;0x400c
                jp plr_adv
;0x400f
                jp plr_unmod
;0x4012
                jp plr_tillend
;0x4015
scroll_lock_routine:
                ret                 
                JP EXT_RTN
;0x4019
                db 0    ;UNBL_FLAG
;0x401a
                db 0    ;SCR0HIGH_
;0x401b
                db 0    ;SCR0LOW_                        
tbl_music       
                dw 417	;0xdb
                dw music1_data  ;=============

                dw 417		        ;0xd5       (80£æ -417 81£æ-423)
                dw music1_data  ;game

                dw 376		        ;0xd0       (72£æ)
                dw music2_data  ;bar

                dw 386		;0xd1
                dw music3_data  ;facts1

                dw 386		;0xd1
                dw music4_data  ;facts2

                dw 386			;d1
                dw music5_data  ;facts3

                dw 386			;d1
                dw music6_data  ;epilogue

init_
                ld h,0
                ld l,a
				add hl,hl
				add hl,hl
                ld de,tbl_music
                add hl,de
                ld e,(hl)
				inc hl
				ld d,(hl)
				ld (speed_frq),de
								;ld (tempo_OPN_timer_B),a
                inc hl
                ld a,(hl)
                inc hl
                ld h,(hl)
                ld l,a
                ld (mus_pointer),hl


;                LD BC,#FFFD
;                LD A,%11111001
;                OUT (C),A
;        		call ym_reset_1	

                LD BC,#FFFD
                LD A,%11111000
                OUT (C),A
 ;       		call ym_reset_1	
			
                ld      d,0x91   ;set prescaler				
                ld      a, 2Dh ; '-'
                call    WRITE_FM1
				
                call    initialize_player

                ld      a, (tempo_OPN_timer_B)
                ld      d, a
                ld      a, 26h ; '&'
                call    WRITE_FM1
				xor a
				ld (PLR_PLAY),a
				ld (player),a
                jp      player	;+3

plr_mod

plr_unmod
            ret
plr_adv
                ld      a, (byte_A2C3)
                or      a
                jr      nz, plr_adv
                ld      a, 6
                ld      (byte_A2C3), a
                ret
plr_tillend
                ld      a, (table_byte_A285)
                or      a
                jr      z, plr_tillend
                ret
;------------------------------------------------------------------------------					
/*

ym_reset_loop
		call ym_reset_write
		dec a
		cp l
		jr nz,ym_reset_loop	;if =>
		ret
		

ym_reset_write
			ld bc,$FFFD
2				
			nop
			nop
			in f,(c)
			jp m,2B
			out (c),a
			
2				
			nop
			nop
			in f,(c)
			jp m,2B
			ld b,0xBF		;FD
			out (c),h
			ret
			
ym_reset_1

		ld a,$0D	;a start reg	0D...00		SSG
		ld hl,$00FF	;h 00 reset
				;l last reg-1
		call ym_reset_loop

		ld a,$B3	;		B3...50		FM
		ld l,$4F	;
		call ym_reset_loop

		ld a,$3F	;		3F...30		DETUNE MUL
		ld l,$2F	;
		call ym_reset_loop
	
		ld a,$07	;a reg		07		SSG MIXER
		ld h,$F8	;h F8 reset
		call ym_reset_write	
		
		ld a,$8F	;a start reg	8F...80		SUSTAIN RELEASE
		ld hl,$0F7F	;h 0F reset
		;		;l last reg-1
		call ym_reset_loop


		ld a,$28	;a start reg	28		KEY OFF CH1
		ld h,$00	;h 00 reset
		call ym_reset_write
		
		;ld a,$28	;a start reg	28		KEY OFF CH2
		ld hl,$01	;h 00 reset
		call ym_reset_write
		
		;ld a,$28	;a start reg	28		KEY OFF CH3
		ld hl,$02	;h 00 reset
		call ym_reset_write		
	
		ld a,$27	;a start reg	27		TIMER
		ld hl,$02	;h 00 reset
		call ym_reset_write		


		ld a,$4F	;a start reg	4F...40		TOTAL LEVEL
		ld hl,$7F3F	;h 00 reset
		;		;l last reg-1
		call ym_reset_loop		
	
	

		ld a,$2F	;a start reg	2F		PRESCALER
		ld h,$7F	;h 00 reset
		call ym_reset_write	
		

		ld a,$2D	;a start reg	2D		PRESCALER
		ld hl,$7F	;h 00 reset
		jp ym_reset_write	
*/
;------------------------------------------------------------------------------	
mute:
                LD BC,#FFFD
                LD A,%11111000
                OUT (C),A

                ld      d, 0
                ld      a, 28h ; '('
                call    WRITE_FM1
                inc     d
                call    WRITE_FM1
                inc     d
                call    WRITE_FM1
				jp 		loc_9F4F
						
				
PLR_PLAY:       ret 
                call scroll_lock_routine
                LD BC,#FFFD
                LD A,%11111000
                OUT (C),A


speed_frq = $+1
                ld de,307               ;speed
                ;int_frq = ((zxint/256)*speed_frq)
                ;speed_frq = (int_frq/(zxint/256))    
                ;50Hz = 256    60Hz = 307.2
                ;100Hz = 512    120Hz = 614.4
    
speed_cnt = $+1
                ld hl,$0000
                add hl,de
                
                ld b,h
                ld h,0
                ld (speed_cnt),hl
                inc b    
speed_loop
                dec b
                ret z   ;jp z,speed_loop_exit
                push bc
                call player
                pop bc
                jp speed_loop
;speed_loop_exit
;                ret
				

	
player:
				ret
                ld      a, 27h ; '''
                ld      d, 2Ah ; '*'
                call    WRITE_FM1
                xor     a

loc_9F23:
                ld      (cur_opn_channel), a
                call    loc_A169
                call    sub_9F6D
                ld      a, (cur_opn_channel)
                inc     a
                cp      3
                jr      nz, loc_9F23
                ret

sel_byte:
                push    de
                ld      de, (cur_opn_channel)
                add     hl, de
                pop     de
                ret
sel_word:
                push    de
                ld      de, (cur_opn_channel)
                add     hl, de
                add     hl, de
                pop     de
                ret


loc_9F4F:
                ld      a, 27h ; '''
                ld      d, 0
                call    WRITE_FM1
                ld      a, 7
                ld      d, 0FFh
                call    WRITE_FM1

                LD BC,#FFFD
                LD A,%11111111
                OUT (C),A

                ld      (is_music_ended), a
				ld a,0xc9
				ld (PLR_PLAY),a
				ld (player),a
                ret

WRITE_FM1:
				push    af
;------------------------------------------         
/*
                cp 8
                jr z,5f
                cp 9
                jr z,5f
                cp 0x0a
                jr nz,4f                
5                
                push af
                ld a,d
                cp 8
                jr c,6f
                ld a,7
6                
                ld d,a
                pop af
4
*/
;------------------------------------------
				push bc
				ld bc,$FFFD
2	
				nop:nop
				in f,(c)
				jp m,2B

				out (c),a
2	
				nop:nop
				in f,(c)
				jp m,2B

				ld b,0xBF
				ld      a, d
				out (c),a
				pop bc
				pop     af
				ret



sub_9F6D:
                ld      hl, table_unk_A273
                call    sel_byte
                dec     (hl)
                jp      nz, loc_9FD9
loc_9F77:
                ld      hl, table_byte_A27F
                call    sel_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
loc_9F80:
                ld      a, (de)
                inc     de
                cp      61h ; 'a'
                jp      nc, loc_A030
                push    hl
                push    af
                ld      hl, table_unk_A273
                call    sel_byte
                ld      a, (de)
                ld      (hl), a
                inc     de
                pop     af
                pop     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      hl, table_word_A2BD
                call    sel_byte
                ld      (hl), a
                or      a
                jr      z, loc_9FD9
                add     a, a
                ld      e, a
                ld      d, 0
                ld      hl,  mus_pointer+1 ; 2 bytes per entry. ; min offset is 1. no 0 offset
                add     hl, de
                ld      c, 45h ;
                ld      a, (cur_opn_channel)
                add     a, a
                ld      d, (hl)
                inc     hl
                call    WRITE_FM1
                inc     a
                ld      d, (hl)
                call    WRITE_FM1
                ld      hl, table_unk_A2A6
                call    sel_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl,tbl_volume
                call    sel_word
                ld      a, (de)
                inc     de
                ld      (hl), a
                inc     hl
                ld      (hl), 0
                ld      hl,  byte_A2A3
                call    sel_byte
                ld      a, (de)
                ld      (hl), a
                jp      loc_A021
loc_9FD9:
                ld      hl, table_word_A2BD
                call    sel_byte
                ld      a, (hl)
                or      a
                jr      z, loc_A01D
                ld      hl, table_unk_A2A6
                call    sel_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl,  byte_A2A3
                call    sel_byte
                ld      a, (hl)
                dec     a
                jr      z, loc_A002
                ld      (hl), a
                ld      hl,tbl_volume
                call    sel_word
                ld      a, (de)
                add     a, (hl)
                ld      (hl), a
                jr      loc_A027
loc_A002:
                inc     de
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                push    de
                ld      hl,tbl_volume
                call    sel_word
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                pop     bc
                ex      de, hl
                add     hl, bc
                jr      nc, loc_A01D
                ex      de, hl
                ld      (hl), e
                dec     hl
                ld      (hl), d
                jr      loc_A027
loc_A01D:
                ld      d, 0
                jr      loc_A028
loc_A021:
                ld      hl,tbl_volume
                call    sel_word
loc_A027:
                ld      d, (hl)
loc_A028:
                ld      a, (cur_opn_channel)
                add     a, 8
                jp      WRITE_FM1

loc_A030:
                cp      0FFh
                jp      z, loc_A04D
                cp      0C6h
                jp      z, loc_A08A
                cp      0C5h
                jp      z, loc_A095
                cp      0C3h
                jp      z, loc_A06F
                cp      0C7h
                jp      z, loc_A0A7
                inc     de
                jp      loc_9F80

loc_A04D:
                ld      hl, table_byte_A285
                call    sel_byte
                ld      (hl), 1
                ld      a, (cur_opn_channel)
                add     a, a
                jr      nz, loc_A05C
                inc     a
loc_A05C:
                ld      b, a
                add     a, a
                add     a, a
                add     a, a
                or      b
                ld      b, a
                ld      a, (byte_A2AC)
                or      b
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                jp      loc_A24A

loc_A06F:
                push    hl
                ld      a, (de)
                add     a, a
                add     a, a
                ld      c, a
                ld      b, 0
                ld      hl, table_unk_A4CF ; 4 bytes per entry?
                add     hl, bc
                ld      b, h
                ld      c, l
                ld      hl, table_unk_A2A6 ; 2 bytes per entry?
                call    sel_word
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     hl
loc_A086:
                inc     de
                jp      loc_9F80
loc_A08A:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, 6
                call    WRITE_FM1
                pop     de
                jr      loc_A086
loc_A095:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, (byte_A2AC)
                and     d
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                pop     de
                inc     de
                jp      loc_9F80
loc_A0A7:
                ld      a, (byte_A2C3)
                or      a
                jr      nz, loc_A0C3
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (mus_pointer)
                add     hl, de
                ex      de, hl
                ld      hl, table_byte_A27F ; 2 bytes per entry ?
                call    sel_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_9F77

loc_A0C3:
                dec     a
                ld      (byte_A2C3), a
                inc     de
                inc     de
                jp      loc_A086

sub_A0E2:
                push    hl
                ld      b, 18h
                ld      a, (cur_opn_channel)
                add     a, 30h ; '0'
loc_A0EA:
                ld      d, (hl)
                inc     hl
                call    WRITE_FM1
                add     a, 4
                djnz    loc_A0EA
                ld      d, (hl)
                ld      a, (cur_opn_channel)
                add     a, 0B0h
                call    WRITE_FM1
                ld      a, (cur_opn_channel)
                ld      c, a
                ld      b, 0
                ld      hl, table_unk_A28B
                add     hl, bc
                ld      (hl), d
                ld      hl,  table_unk_A28B+3
                add     a, a
                add     a, a
                ld      c, a
                add     hl, bc
                ex      de, hl
                pop     hl
                ld      c, 4
                add     hl, bc
                ldir
                ret
sub_A116:
                dec     a
                ld      de, 30h ; '0'
                ld      h, d
                cp      e
                jr      c, loc_A121
                sub     e
                set     5, d
loc_A121:
                ld      e, 18h
                cp      e
                jr      c, loc_A129
                sub     e
                set     4, d
loc_A129:
                ld      e, 0Ch
                cp      e
                jr      c, loc_A131
                sub     e
                set     3, d
loc_A131:
                add     a, a
                ld      l, a
                ld      h, 0
                ld      bc,  table_unk_A259+1 ; 2 bytes per entry , pointer is increased by +1 so actual table starts at a259
                add     hl, bc
                ld      a, (hl)
                dec     hl
                or      d
                ld      d, a
                ld      a, (cur_opn_channel)
                add     a, 0A4h
                call    WRITE_FM1
                ld      b, d
                ld      d, (hl)
                ld      a, (cur_opn_channel)
                add     a, 0A0h
                jp      WRITE_FM1
loc_A14F:
                push    af
                ld      a, (cur_opn_channel)
                or      0F0h
                ld      d, a
                ld      a, 28h ; '('
                call    WRITE_FM1
                pop     af
                ret
sub_A15D:
                push    af
                ld      a, (cur_opn_channel)
                ld      d, a
                ld      a, 28h ; '('
                call    WRITE_FM1
                pop     af
                ret
loc_A169:
                ld      hl, byte_A276
                call    sel_byte
                dec     (hl)
                ret     nz
loc_A171:
                ld      hl, table_word_A279
                call    sel_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
loc_A17A:
                ld      a, (de)
                inc     de
                push    de
                call    sub_A15D
                pop     de
                cp      61h ; 'a'
                jp      nc, loc_A19E
                push    af
                push    hl
                ld      hl, byte_A276
                call    sel_byte
                ld      a, (de)
                inc     de
                ld      (hl), a
                pop     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                pop     af
                or      a
                ret     z
                call    sub_A116
                jp      loc_A14F
loc_A19E:
                cp      0FFh
                jp      z, loc_A242
                cp      0C0h
                jp      z, loc_A1DA
                cp      0C1h
                jp      z, loc_A1F1
                cp      0C7h
                jp      z, loc_A1B6
loc_A1B2:
                inc     de
                jp      loc_A17A
loc_A1B6:
                ld      a, (byte_A2C3)
                or      a
                jr      nz, loc_A1D2
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (mus_pointer)
                add     hl, de
                ex      de, hl
                ld      hl, table_word_A279
                call    sel_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_A171
loc_A1D2:
                dec     a
                inc     de
                inc     de
                ld      (byte_A2C3), a
                jr      loc_A1B2
loc_A1DA:
                push    hl
                ld      hl, table_unk_A2AD ; 2 bytes per entry
                ld      a, (de)
                inc     de
                push    de
                add     a, a
                ld      c, a
                ld      b, 0
                add     hl, bc
                ld      a, (hl)
                inc     hl
                ld      h, (hl)
                ld      l, a
                call    sub_A0E2
                pop     de
                pop     hl
                jr      loc_A17A
loc_A1F1:
                push    hl
                ld      a, (de)
                inc     de
                push    de
                ld      c, a
                ld      hl, table_unk_A28B
                call    sel_byte
                ld      b, 1
                ld      a, (hl)
                and     7
                cp      4
                jr      c, loc_A20E
                jr      z, loc_A20D
                inc     b
                inc     b
                cp      7
                jr      c, loc_A20E
loc_A20D:
                inc     b
loc_A20E:
                ld      hl, table_unk_A292 ; 5 bytes per entry
                ld      a, (cur_opn_channel)
                add     a, a
                add     a, a
                ld      e, a
                ld      d, 0
                add     hl, de
                ld      a, (cur_opn_channel)
                add     a, 4Ch ; 'L'
                ld      e, a
loc_A220:
                dec     hl
                ld      a, (hl)
                add     a, c
                ld      d, a
                ld      a, e
                call    WRITE_FM1
                sub     4
                ld      e, a
                djnz    loc_A220
                pop     de
                pop     hl
                jp      loc_A17A


sub_A232:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, 26h ; '&'
                call    WRITE_FM1
                ld      (tempo_OPN_timer_B), a
                pop     de
                inc     de
                jp      loc_A17A
; ---------------------------------------------------------------------------

loc_A242:
                ld      hl,  table_byte_A288
                call    sel_byte
                ld      (hl), 1
loc_A24A:
                ld      hl, table_byte_A285
                ld      b, 6
loc_A24F:
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                djnz    loc_A24F
                pop     hl
                jp      loc_9F4F

table_unk_A259: dw 26Ah
                dw 28Fh
                dw 2B6h
                dw 2DFh
                dw 30Bh
                dw 339h
                dw 36Ah
                dw 39Eh
                dw 3D5h
                dw 410h
                dw 44Eh
                dw 48Fh

cur_opn_channel:dw 0                                       
table_unk_A273:  db 1, 1, 1             
byte_A276:       db 1, 1, 1             
table_word_A279: db 0, 0, 0, 0, 0, 0    
table_byte_A27F: db 0, 0, 0, 0, 0, 0    
table_byte_A285: db 0, 0, 0             ;if (table_byte_A285) == 0 then we could think what music is over
table_byte_A288: db 0, 0, 0             
table_unk_A28B:  db 0, 0, 0, 0, 0, 0
                 db    0
table_unk_A292:  db    0                
                 dw 0, 0, 0, 0, 0
tbl_volume:       db 0, 0, 0, 0, 0, 0    
byte_A2A3:       db 0, 0, 0             

table_unk_A2A6: dw table_unk_A4CF       
                dw table_unk_A4CF
                dw table_unk_A4CF
byte_A2AC:      db 0FFh                 
                                        
table_unk_A2AD: dw byte_A407            
                dw byte_A420
                dw byte_A439
                dw byte_A452
                dw byte_A46B
                dw byte_A484
                dw byte_A49D
                dw byte_A4B6
table_word_A2BD:dw 0                    
                db    0
tempo_OPN_timer_B:db 0D5h               
                                        
mus_pointer:    dw 0           
                                        
byte_A2C3:      db 0                    
                                        
                dw 0EF0h, 0E1Ah, 0D4Fh, 0C90h, 0BDCh, 0B31h, 0A91h, 9F9h, 96Ah, 8E3h, 863h, 7EBh, 779h, 70Eh, 6A9h, 649h
                dw 5EFh, 59Ah, 549h, 4FEh, 4B6h, 472h, 433h, 3F6h, 3BEh, 388h, 355h, 326h, 2F8h, 2CEh, 2A6h, 280h
                dw 25Ch, 23Ah, 21Ah, 1FCh, 1E0h, 1C5h, 1ACh, 194h, 17Dh, 168h, 154h, 141h, 12Fh, 11Eh, 10Eh, 0FFh
                dw 0F1h, 0E3h, 0D7h, 0CBh, 0C0h, 0B5h, 0ABh, 0A1h, 98h, 90h, 88h, 81h, 79h, 73h, 6Ch, 66h
                dw 61h, 5Bh, 56h, 52h, 4Dh, 49h, 45h, 41h, 3Eh, 3Ah, 37h, 34h, 31h, 2Fh, 2Ch, 2Ah
                dw 28h, 26h, 24h, 22h, 20h, 1Eh, 1Dh, 1Bh, 1Ah, 18h, 17h, 16h, 15h, 14h, 13h, 12h



initialize_player:
                ld      hl, table_unk_A273
                ld      b, 6
loc_A38A:
                ld      (hl), 1
                inc     hl
                djnz    loc_A38A

                ld      hl, table_byte_A285
                ld      b, 6
loc_A394:
                ld      (hl), 0
                inc     hl
                djnz    loc_A394


                ld      hl, tbl_volume
                ld      b, 6
loc_A394a:
                ld      (hl), 0
                inc     hl
                djnz    loc_A394a

                ld      hl, (mus_pointer)
                ld      (loc_A3A8+1), hl
                ex      de, hl
                ld      hl, table_word_A279
                ld      (loc_A3B0+1), hl

                ld      b, 6
loc_A3A8:
                ld      hl, 0
                ld      a, (hl)
                inc     hl
                ld      l, (hl)
                ld      h, a
                add     hl, de
loc_A3B0:
                ld      (table_word_A279), hl
                ld      hl, (loc_A3A8+1)
                inc     hl
                inc     hl
                ld      (loc_A3A8+1), hl
                ld      hl, (loc_A3B0+1)
                inc     hl
                inc     hl
                ld      (loc_A3B0+1), hl
                djnz    loc_A3A8
                ld      d,0x91   ;set prescaler				
                ld      a, 2Dh ; '-'
                call    WRITE_FM1       ; set prescaler (port 0x2d)

                ld      a, (tempo_OPN_timer_B)
                ld      d, a
                ld      a, 26h ; '&'
                call    WRITE_FM1       ; set timer B (port 0x26)
                ld      a, 0F8h
                ld      (byte_A2AC), a
                ld      d, a
                ld      a, 7
                call    WRITE_FM1       ; enable output and noise (port 0x07)
                ld      a, 0Dh
                ld      d, 0
                jp      WRITE_FM1

byte_A407:      db 7Fh, 0Fh, 72h, 7, 0, 0, 3, 3, 1Fh, 1Fh, 5Fh, 1Fh, 1Ch, 19h, 19h, 19h, 0, 0, 11h, 13h, 6, 28h, 3Ah, 5Ch, 2Ch
byte_A420:      db 3Fh, 1, 1, 1, 28h, 2Ah, 14h, 8, 9Fh, 9Eh, 0DBh, 5Eh, 0Fh, 6, 7, 6, 8, 0Bh, 0Ah, 0, 88h, 0F6h, 8Ah, 0F7h, 1Ch
byte_A439:      db 52h, 61h, 31h, 1, 1Bh, 2Dh, 1Eh, 10h, 11h, 4Ah, 11h, 4Bh, 3, 0, 0, 0, 1, 2, 0, 0, 1Ch, 7, 0Ah, 0Dh, 10h
byte_A452:      db 0, 3, 2, 1, 1Ah, 29h, 21h, 2, 0DFh, 95h, 1Fh, 95h, 0, 0Bh, 0Bh, 0, 3, 15h, 0, 0, 0B0h, 5, 7Ah, 0Fh, 3Bh
byte_A46B:      db 72h, 70h, 73h, 73h, 1Bh, 34h, 21h, 13h, 52h, 55h, 54h, 49h, 7, 7, 9, 0Ch, 0, 0, 0, 0, 3, 3, 2, 1Ch, 3Bh
byte_A484:      db 73h, 0, 2, 32h, 26h, 1Ch, 3Ah, 0, 0DFh, 95h, 0C1h, 8Fh, 7, 0, 6, 6, 7, 6, 6, 0, 29h, 19h, 19h, 69h, 8
byte_A49D:      db 72h, 0, 0, 31h, 26h, 1Ch, 26h, 4, 0DFh, 9Fh, 0D4h, 9Fh, 7, 0, 6, 6, 7, 6, 6, 0, 29h, 19h, 19h, 69h, 38h
byte_A4B6:      db 36h, 30h, 33h, 31h, 1Ch, 1Ch, 34h, 6, 0DFh, 9Fh, 0DFh, 9Fh, 7, 9, 6, 4, 7, 6, 6, 0, 29h, 19h, 19h, 39h, 20h
                                       
table_unk_A4CF: db 0Ah, 1, 0FFh, 0E8h 
                db 0Ch, 1, 0FFh, 0EAh
                db 0Dh, 1, 0FFh, 0E3h
                db 0Eh, 1, 0FFh, 0EEh
                db 2, 5, 0FFh, 0F2h
                db 8, 1, 0FFh, 0E2h
                db 9, 1, 0FFh, 0E3h
                db 0Ah, 1, 0FFh, 0D9h
                db 0Bh, 1, 0FFh, 0D6h
                db 5, 2, 0FFh, 0CBh
                db 8, 1, 0FFh, 0BCh
                db 0Ah, 1, 0FFh, 0CAh
                db 7, 1, 0FFh, 0D6h
                db 0Fh, 1, 0FFh, 0E2h
                db 6, 2, 0FFh, 0D7h
                db 9, 1, 0FFh, 0C7h
                db 0Bh, 1, 0FFh, 0BFh
                db 0Ah, 1, 0FFh, 0CBh
                db 6, 1, 0FFh, 0F1h
                db 7, 1, 0FFh, 0EEh
                db 8, 1, 0FFh, 0E7h
                db 0D0h, 0D1h, 9Eh, 0D2h, 8Eh, 91h, 0B1h, 0FFh







music6_data:   include "_common/music6opn.asm"
music1_data:   include "_common/music1opn.asm"
music2_data:   include "_common/music2opn.asm"
music3_data:   include "_common/music3opn.asm"
music4_data:   include "_common/music4opn.asm"
music5_data:   include "_common/music5opn.asm"



				ENT
opn_end:


                savebin "jb2manreq/opn_plr.bin",opn_begin,opn_end-opn_begin
                ENDMODULE
        
