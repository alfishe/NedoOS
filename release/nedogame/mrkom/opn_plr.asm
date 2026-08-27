                MODULE OPN_PLR
PLR_START= 0x4000
opn_begin:
                DISP PLR_START
                jr init_
                jp PLR_PLAY
                jp mute
is_music_ended  db 0
				jp plr_mod
				jp plr_adv
				jp plr_unmod
tbl_music       
                dw 495	;0xdb
                dw music1_data;======
                dw 495		;0xdb
                dw music1_data  ;game
                dw 495		;0xdb
                dw music2_data  ;bar
                dw 297		;0xc5
                dw music3_data  ;facts
                dw 495		;0xdc
                dw music4_data  ;ending
                dw 348			;0xcd
                dw music5_data  ;epiloigue

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

                LD BC,#FFFD
                LD A,%11111000
                OUT (C),A
			

		call ym_reset_1	
			
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
                jp      PLR_PLAY	;+3

;------------------------------------------------------------------------------					
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
		call ym_reset_write	

		ret	
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
				jp 		loc_A6D8
						
				
PLR_PLAY:       ret 
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
                jp z,speed_loop_exit
                push bc
                call player
                pop bc
                jp speed_loop
        
speed_loop_exit
                ret
				



                ;call $+3			
player:
				ret
                ld      a, 27h ; '''
                ld      d, 2Ah ; '*'
                call    WRITE_FM1
                xor     a
loc_9209:
          
                ld      (word_A830), a
                call    play_note1
loc_A6B2:
                ld      hl, 0
                ld      a, (word_A830)
                inc     a
                cp      3
                jr      nz, loc_9209
                ret
				

sub_A6C7:
                push    de
                ld      de, (word_A830)
                add     hl, de
                pop     de
                ret

sub_A6CF:
                push    de
                ld      de, (word_A830)
                add     hl, de
                add     hl, de
                pop     de
                ret

loc_A6D8:
                ld      a, 27h ; '''
                ld      d, 0
                call    WRITE_FM1
                ld      a, 7
                ld      d, 0FFh
                call    WRITE_FM1
                ld      (is_music_ended), a
				ld a,0xc9
				ld (PLR_PLAY),a
				ld (player),a
                ret

WRITE_FM1:
				push    af
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
				
sub_A70F:
                ld      b, 18h
                ld      a, (word_A830)
                add     a, 30h ; '0'
.loc_948E:
                ld      d, (hl)
                inc     hl
                call    WRITE_FM1
                add     a, 4
                djnz    .loc_948E
                ld      d, (hl)
                ld      a, (word_A830)
                add     a, 0B0h
                jp      WRITE_FM1
				
				
sub_A728:
                dec     a
                ld      de, 30h ; '0'
                ld      h, d
                cp      e
                jr      c, .loc_94AB
                sub     e
                set     5, d

.loc_94AB:
                ld      e, 18h
                cp      e
                jr      c, .loc_94B3
                sub     e
                set     4, d

.loc_94B3:
                ld      e, 0Ch
                cp      e
                jr      c, .loc_94BB
                sub     e
                set     3, d

.loc_94BB:
                add     a, a
                ld      l, a
                ld      h, 0
                ld      bc, tbl_a818+1
                add     hl, bc
                ld      a, (hl)
                dec     hl
                or      d
                ld      d, a
                ld      a, (word_A830)
                add     a, 0A4h
                call    WRITE_FM1
                ld      b, d
                ld      d, (hl)
                ld      a, (word_A830)
                add     a, 0A0h
                jp      WRITE_FM1

loc_A761:
                push    af
                ld      a, (word_A830)
                or      0F0h
                ld      d, a
                ld      a, 28h ; '('
                call    WRITE_FM1
                pop     af
                ret	
				
sub_A76F:
                push    af
                ld      a, (word_A830)
                ld      d, a
                ld      a, 28h ; 
                call    WRITE_FM1
                pop     af
                ret
;-----------------------------------------



play_note1:
                ld      hl,  byte_A832+3 
                call    sub_A6C7
                dec     (hl)
				ret nz
loc_A783:
                ld      hl, byte_A838
                call    sub_A6CF
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
loc_A78C:
                ld      a, (de)
                inc     de
                push    de
                call    sub_A76F
                pop     de
                cp      61h ; 'a'
                jp      nc, loc_A7B0
                push    af
                push    hl
                ld      hl,  byte_A832+3
                call    sub_A6C7
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
                call    sub_A728
                jp      loc_A761
				
				
loc_A7B0:
                cp      0FFh
                jp      z, loc_A801
                cp      0C0h
                jp      z, loc_A7E7
                cp      0C7h
                jp      z, loc_A7C3
loc_A7BF:
                inc     de
                jp      loc_A78C				
	
loc_A7C3:
                ld      a, (byte_A85F)
                or      a
                jr      nz, loc_A7DF
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (mus_pointer)
                add     hl, de
                ex      de, hl
                ld      hl, byte_A838
                call    sub_A6CF
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_A783

loc_A7DF:
                dec     a
                inc     de
                inc     de
                ld      (byte_A85F), a
                jr      loc_A7BF

loc_A7E7:
                push    hl
                ld      a, (de)
                inc     de
                push    de
                ld      l, a
                ld      h, 0
                ld      e, l
                ld      d, h
                add     hl, hl
                add     hl, de
                add     hl, hl
                add     hl, hl
                add     hl, hl
                add     hl, de
                ld      de, byte_A8BF
                add     hl, de
                call    sub_A70F
                pop     de
                pop     hl
                jr      loc_A78C

loc_A801:
                ld      hl,  byte_A844+3
                call    sub_A6C7
                ld      (hl), 1
loc_A809:
                ld      hl,  byte_A844+3
loc_A80C:
                ld      b, 3
loc_A80E:
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                djnz    loc_A80E
                pop     hl
                jp      loc_A6D8
tbl_a818:       dw 26Ah
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
word_A830:      dw 0
byte_A832:      db 1, 1, 1, 1, 1, 1
byte_A838:      db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_A844:      db 0, 0, 0, 0, 0, 0
				db 	  0
byte_A84B:      db    0,0,0,0,0,0
unk_A851:       db    0,0,0
unk_A854:       db    0,0,0,0,0,0
byte_A85A:      db 0FFh
unk_A85B        db    0,0,0
tempo_OPN_timer_B:db 0DFh
byte_A85F:      db 0
				
initialize_player:
                ld      hl, byte_A832
                ld      b, 6
.loc_A865:
                ld      (hl), 1
                inc     hl
                djnz    .loc_A865
                ld      hl, byte_A844
                ld      b, 6

.loc_A86F:
                ld      (hl), 0
                inc     hl
                djnz    .loc_A86F
                ld      hl, (mus_pointer)
                ld      (.loc_A883+1), hl
                ex      de, hl
                ld      hl, byte_A838
                ld      (.loc_A88B+1), hl
                ld      b, 6
.loc_A883:
                ld      hl, 0
                ld      a, (hl)
                inc     hl
                ld      l, (hl)
                ld      h, a
                add     hl, de

.loc_A88B:
                ld      (byte_A838), hl
                ld      hl, (.loc_A883+1)
                inc     hl
                inc     hl
                ld      (.loc_A883+1), hl
                ld      hl, (.loc_A88B+1)
                inc     hl
                inc     hl
                ld      (.loc_A88B+1), hl
                djnz    .loc_A883
                ld      a, 8
                ld      d, 0
                call    WRITE_FM1
                inc     a
                call    WRITE_FM1
                inc     a
                call    WRITE_FM1
                ld      a, 0Dh
                call    WRITE_FM1
                ld      a, 0F8h
                ld      (byte_A85A), a
                ld      d, a
                ld      a, 7
                jp      WRITE_FM1
				
				
byte_A8BF:      db 3Fh, 3Ch, 2Fh, 38h, 14h, 0, 14h, 0, 1Fh, 1Fh, 19h, 19h, 19h, 19h, 0Ch, 0Ch, 0, 3, 5, 5, 2Fh, 57h, 3Fh, 4Fh, 1Fh
                db 1, 6Ah, 31h, 31h, 1Eh, 23h, 0Ah, 0Fh, 5Ah, 9Ah, 98h, 58h, 0Fh, 7, 0Ch, 0Ch, 0, 3, 5, 5, 24h, 34h, 24h, 14h, 24h
                db 7Fh, 3, 71h, 2, 23h, 0Ah, 0Dh, 0Ah, 5Dh, 19h, 19h, 14h, 0Ah, 7, 0Ah, 12h, 4, 4, 4, 9, 73h, 73h, 73h, 73h, 3Eh
                db 0Ch, 1, 1Fh, 53h, 20h, 1Eh, 39h, 17h, 1Fh, 1Fh, 0DFh, 9Fh, 0Ch, 0Ch, 2, 0Bh, 4, 4, 4, 9, 1Ah, 6, 0F6h, 59h, 3Ah
                db 38h, 3, 3Ah, 64h, 23h, 2Dh, 3Ch, 0, 5Ch, 5Ch, 53h, 4Eh, 0, 0, 9, 8, 0, 0, 0, 6, 13h, 13h, 32h, 13h, 0Ah
                db 32h, 2, 3Ah, 63h, 1Bh, 33h, 18h, 0Ah, 5Ch, 5Ch, 52h, 44h, 0, 0, 9, 0Eh, 0, 0, 0, 0, 13h, 13h, 22h, 14h, 32h
                db 0Ah, 61h, 41h, 22h, 28h, 1Eh, 14h, 0, 1Fh, 9Ch, 59h, 9Fh, 0Ah, 0Ah, 0Ah, 8, 4, 1Fh, 4, 6, 0F2h, 0F1h, 0A3h, 54h, 2Ch
                db 30h, 30h, 35h, 31h, 1Ch, 0Dh, 2Ah, 8, 0DFh, 9Fh, 0DFh, 9Bh, 7, 12h, 6, 0, 7, 0, 6, 0, 29h, 60h, 19h, 24h, 20h
                db 31h, 30h, 33h, 31h, 1Ch, 20h, 14h, 0, 0D6h, 99h, 9Fh, 9Fh, 0, 6, 0Fh, 0Bh, 7, 6, 6, 7, 29h, 19h, 59h, 19h, 3
                db 1, 1, 21h, 21h, 0Eh, 1Dh, 19h, 8, 99h, 4Ch, 1Bh, 0CAh, 6, 6, 8, 0, 2, 0, 0, 0, 1Eh, 0Ch, 2Dh, 0Ch, 1Ah
                db 33h, 3, 66h, 64h, 12h, 6, 0Bh, 0Bh, 48h, 12h, 0Eh, 12h, 0, 7, 0, 7, 0, 0, 0, 0, 1Fh, 3Fh, 3Fh, 3Fh, 6
                db 31h, 31h, 44h, 24h, 1Ah, 14h, 0Fh, 0Fh, 12h, 12h, 0Bh, 0Ch, 4, 9, 0, 0, 0, 0, 0, 0, 0Eh, 7Eh, 0Eh, 0Eh, 36h
                db 0, 4, 0, 0, 0, 0, 0, 0, 1Fh, 1Fh, 1Fh, 1Fh, 0, 18h, 12h, 13h, 14h, 0, 11h, 12h, 9Fh, 98h, 31h, 0Ch, 3Ch
                db 1Dh, 7, 0Dh, 0Fh, 0Eh, 1Eh, 28h, 0Eh, 1Fh, 1Dh, 1Dh, 1Ch, 0Dh, 1Fh, 1Fh, 14h, 1Eh, 1Eh, 1Ah, 1Fh, 0FFh, 0FFh, 0Ah, 0FFh, 3Ah
                db 53h, 40h, 50h, 60h, 0, 0Ah, 17h, 0, 0DFh, 9Fh, 0DFh, 5Fh, 1Ah, 14h, 0Bh, 15h, 1Fh, 15h, 0, 0Eh, 0DFh, 10h, 0Fh, 3, 3Ah
mus_pointer:    dw music1_data  



plr_mod:
                ld      hl, play_note2 ; modify player
                ld      (loc_A6B2+1), hl
                ld      a, 0CDh
                ld      (loc_A6B2), a
                ld      hl, byte_A844
                ld      (loc_A809+1), hl
                ld      a, 6
                ld      (loc_A80C+1), a
                xor a
                ld      (is_music_ended),a
                ret				

plr_unmod:
                ld      a, 0x21                ;ld hl
                ld      (loc_A6B2), a
                ld      hl, byte_A844+3
                ld      (loc_A809+1), hl
                ld      a, 3
                ld      (loc_A80C+1), a
                xor a
                ld      (is_music_ended),a
                ret

plr_adv:
				ld      a, (byte_A85F)
				or      a
				jr      nz, plr_adv
				ld      a, 6
				ld      (byte_A85F), a
				ret

play_note2:
                ld      hl, byte_A832
                call    sub_A6C7
                dec     (hl)
                jp      nz, loc_ADB3

loc_AD45:
                ld      hl,  byte_A838+6
                call    sub_A6CF
                ld      e, (hl)
                inc     hl
                ld      d, (hl)

loc_AD4E:
                ld      a, (de)
                inc     de
                cp      61h ; 'a'
                jp      nc, loc_AEBA
                push    hl
                push    af
                ld      hl, byte_A832
                call    sub_A6C7
                ld      a, (de)
                ld      (hl), a
                inc     de
                pop     af
                pop     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      hl, unk_A85B
                call    sub_A6C7
                ld      (hl), a
                or      a
                jr      z, loc_ADB3
                add     a, a
                ld      e, a
                ld      d, 0
                ld      hl,  loc_AF53+1
                add     hl, de
                ld      a, (word_A830)
                add     a, a
                ld      d, (hl)
                ld      e, d
                inc     hl
                call    WRITE_FM1
                inc     a
                ld      d, (hl)
                inc     hl
                call    WRITE_FM1
                ld      hl, unk_AE6D
                call    sub_A6CF
                ld      (hl), e
                inc     hl
                ld      (hl), d
                call    sub_AE88
                ld      hl, unk_A854
                call    sub_A6CF
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, byte_A84B
                call    sub_A6CF
                ld      a, (de)
                inc     de
                ld      (hl), a
                inc     hl
                ld      (hl), 0
                ld      hl, unk_A851
                call    sub_A6C7
                ld      a, (de)
                ld      (hl), a
                jp      loc_ADFB
; ---------------------------------------------------------------------------

loc_ADB3:
                ld      hl, unk_A85B
                call    sub_A6C7
                ld      a, (hl)
                or      a
                jr      z, loc_ADF7
                ld      hl, unk_A854
                call    sub_A6CF
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, unk_A851
                call    sub_A6C7
                ld      a, (hl)
                dec     a
                jr      z, loc_ADDC
                ld      (hl), a
                ld      hl, byte_A84B
                call    sub_A6CF
                ld      a, (de)
                add     a, (hl)
                ld      (hl), a
                jr      loc_AE01
; ---------------------------------------------------------------------------

loc_ADDC:
                inc     de
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                push    de
                ld      hl, byte_A84B
                call    sub_A6CF
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                pop     bc
                ex      de, hl
                add     hl, bc
                jr      nc, loc_ADF7
                ex      de, hl
                ld      (hl), e
                dec     hl
                ld      (hl), d
                jr      loc_AE01
; ---------------------------------------------------------------------------

loc_ADF7:
                ld      d, 0
                jr      loc_AE02
; ---------------------------------------------------------------------------

loc_ADFB:
                ld      hl, byte_A84B
                call    sub_A6CF

loc_AE01:
                ld      d, (hl)

loc_AE02:
                ld      a, (word_A830)
                add     a, 8
                call    WRITE_FM1
                ld      hl, unk_AE82
                call    sub_A6C7
                dec     (hl)
                ret     nz
                inc     (hl)
                ld      hl, unk_AE6D
                call    sub_A6CF
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                push    de
                srl     d
                rr      e
                ld      hl, unk_AE79
                call    sub_A6C7
                bit     1, (hl)
                call    z, sub_AEB2
                ld      hl, unk_AE73
                call    sub_A6CF
                ld      c, (hl)
                inc     hl
                ld      b, (hl)
                ex      de, hl
                add     hl, bc
                ex      de, hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      e, d
                ld      d, 0
                bit     7, e
                jr      z, loc_AE43
                dec     d

loc_AE43:
                pop     hl
                add     hl, de
                ld      a, (word_A830)
                add     a, a
                ld      d, l
                call    WRITE_FM1
                inc     a
                ld      d, h
                call    WRITE_FM1
                ld      hl, unk_AE7C
                call    sub_A6C7
                dec     (hl)
                ret     nz
                ex      de, hl
                ld      hl, unk_AE7F
                call    sub_A6C7
                ld      a, (hl)
                ld      (de), a
                ld      hl, unk_AE79
                call    sub_A6C7
                ld      a, (hl)
                cpl
                ld      (hl), a
                ret
; ---------------------------------------------------------------------------
unk_AE6D:       db    0     
                            
                db    0
                db    0
                db    0
                db    0
                db    0
unk_AE73:       db    0     
                            
                db    0
                db    0
                db    0
                db    0
                db    0
unk_AE79:       db    0     
                            
                db    0
                db    0
unk_AE7C:       db    3     
                            
                db    3
location_AE7E:  db    3
unk_AE7F:       db    4     
                            
                db    6
                db    8
unk_AE82:       db  18h     
                            
                db  18h
                db  18h
unk_AE85:       db  18h     
                db  18h
                db  18h

; =============== S U B R O U T I N E =======================================


sub_AE88:                               ; CODE XREF: seg003:AD90↑p
                ld      hl, unk_AE73
                call    sub_A6CF
                ld      (hl), 0
                inc     hl
                ld      (hl), 0
                ld      hl, unk_AE7F
                call    sub_A6C7
                ld      a, (hl)
                ld      hl, unk_AE7C
                call    sub_A6C7
                srl     a
                ld      (hl), a
                ld      hl, unk_AE85
                call    sub_A6C7
                ld      a, (hl)
                ld      hl, unk_AE82
                call    sub_A6C7
                ld      (hl), a
                ret
; End of function sub_AE88


; =============== S U B R O U T I N E =======================================


sub_AEB2: 
                ld      a, d
                cpl
                ld      d, a
                ld      a, e
                cpl
                ld      e, a
                inc     de
                ret
; End of function sub_AEB2

; ---------------------------------------------------------------------------

loc_AEBA: 
                cp      0FFh
                jp      z, loc_AED7
                cp      0C6h
                jp      z, loc_AF14
                cp      0C5h
                jp      z, loc_AF21
                cp      0C3h
                jp      z, loc_AEF9
                cp      0C7h
                jp      z, loc_AF31
                inc     de
                jp      loc_AD4E
; ---------------------------------------------------------------------------

loc_AED7: 
                ld      hl, byte_A844
                call    sub_A6C7
                ld      (hl), 1
                ld      a, (word_A830)
                add     a, a
                jr      nz, loc_AEE6
                inc     a

loc_AEE6: 
                ld      b, a
                add     a, a
                add     a, a
                add     a, a
                or      b
                ld      b, a
                ld      a, (byte_A85A)
                or      b
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                jp      loc_A809
; ---------------------------------------------------------------------------

loc_AEF9:
                push    hl
                ld      a, (de)
                add     a, a
                add     a, a
                ld      c, a
                ld      b, 0
                ld      hl, byte_B016
                add     hl, bc
                ld      b, h
                ld      c, l
                ld      hl, unk_A854
                call    sub_A6CF
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     hl
                inc     de
                jp      loc_AD4E
; ---------------------------------------------------------------------------

loc_AF14:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, 6
                call    WRITE_FM1
                pop     de

loc_AF1D:
                inc     de
                jp      loc_AD4E
; ---------------------------------------------------------------------------

loc_AF21:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, (byte_A85A)
                and     d
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                pop     de
                jr      loc_AF1D
; ---------------------------------------------------------------------------

loc_AF31:
                ld      a, (byte_A85F)
                or      a
                jr      nz, loc_AF4D
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (mus_pointer)
                add     hl, de
                ex      de, hl
                ld      hl,  byte_A838+6
                call    sub_A6CF
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_AD45
; ---------------------------------------------------------------------------

loc_AF4D:
                dec     a
                ld      (byte_A85F), a
                inc     de
                inc     de

loc_AF53:
                jp      loc_AF1D
; ---------------------------------------------------------------------------
                db 0E9h, 0Eh, 12h, 0Eh, 48h, 0Dh, 89h, 0Ch, 0D5h, 0Bh, 2Bh, 0Bh, 8Ah, 0Ah, 0F3h, 9
                db 64h, 9, 0DDh, 8, 5Eh, 8, 0E6h, 7, 74h, 7, 9, 7, 0A4h, 6, 44h, 6
                db 0EAh, 5, 95h, 5, 45h, 5, 0F9h, 4, 0B2h, 4, 6Eh, 4, 2Fh, 4, 0F3h, 3
                db 0BAh, 3, 84h, 3, 52h, 3, 22h, 3, 0F5h, 2, 0CAh, 2, 0A2h, 2, 7Ch, 2
                db 59h, 2, 37h, 2, 17h, 2, 0F9h, 1, 0DDh, 1, 0C2h, 1, 0A9h, 1, 91h, 1
                db 7Ah, 1, 65h, 1, 51h, 1, 3Eh, 1, 2Ch, 1, 1Bh, 1, 0Bh, 1, 0FCh, 0
                db 0EEh, 0, 0E1h, 0, 0D4h, 0, 0C8h, 0, 0BDh, 0, 0B2h, 0, 0A8h, 0, 9Fh, 0
                db 96h, 0, 8Dh, 0, 85h, 0, 7Eh, 0, 77h, 0, 70h, 0, 6Ah, 0, 64h, 0
                db 5Eh, 0, 59h, 0, 54h, 0, 4Fh, 0, 4Bh, 0, 46h, 0, 42h, 0, 3Fh, 0
                db 3Bh, 0, 38h, 0, 35h, 0, 32h, 0, 2Fh, 0, 2Ch, 0, 2Ah, 0, 27h, 0
                db 25h, 0, 23h, 0, 21h, 0, 1Fh, 0, 1Dh, 0, 1Ch, 0, 1Ah, 0, 19h, 0
                db 17h, 0, 16h, 0, 15h, 0, 13h, 0, 12h, 0, 11h, 0, 10h, 0, 0Fh, 0
byte_B016:      db 0Ah, 1, 0FFh, 0F9h   ; DATA XREF: seg003:AF00↑o
                db 9, 1, 0FFh, 0F9h
                db 0Ch, 1, 0FFh, 0CBh
                db 0Ch, 1, 0FFh, 0D9h
                db 1, 0Ah, 0FFh, 0F2h
                db 0Ah, 1, 0FFh, 0E9h
                db 1, 0Bh, 0FFh, 0FAh
                db 1, 0Ah, 0FFh, 0FAh
                db 1, 0Ch, 0FFh, 0FAh
music4_data:   include "_common/music4opn.asm"
music1_data:   include "_common/music1opn.asm"
music2_data:   incbin "_common/music2opn.bin"
music3_data:   incbin "_common/music3opn.bin"
music5_data:   include "_common/music5opn.asm"
				ENT
opn_end:


                savebin "kissofmurder/opn_plr.bin",opn_begin,opn_end-opn_begin
                ENDMODULE
        
