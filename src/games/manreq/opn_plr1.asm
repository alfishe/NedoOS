                MODULE OPN_PLR1             
PLR_START= 0x4000
EXT_RTN = 0x5800
opn_begin:
;0x4000
                DISP PLR_START
                jr init_
;0x4002
                jp PLR_PLAY
;4005
                jp mute
;0x4008
is_music_ended  db 0

                ds 12
;0x4015
exit_routine:
                ret                 
                JP EXT_RTN
;0x4019
                db 0    ;UNBL_FLAG
;0x401a
                db 0    ;SCR0HIGH_
;0x401b
                db 0    ;SCR0LOW_    



init_

                LD BC,#FFFD
                LD A,%11111000
                OUT (C),A


                ld      b, 3
                xor     a
loc_9714:
                ld      (opn_curr_channel), a
                ld      hl, byte_9792
                push    bc
                push    af
                call    sub_9466
                pop     af
                pop     bc
                inc     a
                djnz    loc_9714

                ld      hl, byte_95F6
                ld      b, 6
loc_9729:
                ld      (hl), 1
                inc     hl
                djnz    loc_9729

                ld      hl, byte_9608
                ld      b, 6
loc_9733:
                ld      (hl), 0
                inc     hl
                djnz    loc_9733

                ld      hl, (off_984A)
                ld      (loc_9747+1), hl
                ex      de, hl
                ld      hl, byte_95FC
                ld      (loc_974F+1), hl

                ld      b, 6
loc_9747:
                ld      hl, 0
                ld      a, (hl)
                inc     hl
                ld      l, (hl)
                ld      h, a
                add     hl, de
loc_974F:
                ld      (byte_95FC), hl
                ld      hl, (loc_9747+1)
                inc     hl
                inc     hl
                ld      (loc_9747+1), hl
                ld      hl, (loc_974F+1)
                inc     hl
                inc     hl
                ld      (loc_974F+1), hl
                djnz    loc_9747


                ld      a, 27h ; '''
                ld      d, 2Ah ; '*'
                call    WRITE_FM1

                ld      a, (byte_9643)
                ld      d, a
                ld      a, 26h ; '&'
                call    WRITE_FM1

                ld      a, 0F8h
                ld      (byte_962F), a
                ld      d, a
                ld      a, 7
                call    WRITE_FM1

                ld      a, 0Dh
                ld      d, 0
                call      WRITE_FM1

				xor a
				ld (PLR_PLAY),a
                ret

;----------------------------------------------------
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
                inc     d				;!
                call    WRITE_FM1		;!
				
				
				ld d,0
				ld a,8
				call    WRITE_FM1
				inc a
				call    WRITE_FM1
				inc a
				call    WRITE_FM1
				
				ld d,0
				ld a,0
				dup 14
				call    WRITE_FM1
				inc a
				edup
				
				jp skip_intro_for_OPN_machines


;----------------------------------------------				
				
				
				
PLR_PLAY:       ret
                call exit_routine 
speed_frq = $+1
                ld de,573              ;speed
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
                ret z           ;jp z,speed_loop_exit
                push bc
                call player
                pop bc
                jp speed_loop
;speed_loop_exit
;                ret


player:
                LD BC,#FFFD
                LD A,%11111000
                OUT (C),A
                ld      a, 27h ; '''
                ld      d, 2Ah ; '*'
                call    WRITE_FM1
                xor     a

_loc_929B:
                ld      (opn_curr_channel), a
                call    sub_94ED
                call    sub_92F0
                ld      a, (opn_curr_channel)
                inc     a
                cp      3
                jr      nz, _loc_929B


;--------------------------
sel_by_byte:
                push    de
                ld      de, (opn_curr_channel)
                add     hl, de
                pop     de
                ret
sel_by_word:
                push    de
                ld      de, (opn_curr_channel)
                add     hl, de
                add     hl, de
                pop     de
                ret
skip_intro_for_OPN_machines:
                ld      a, 27h ; '''
                ld      d, 0
                call    WRITE_FM1
                ld      a, 7
                ld      d, 0FFh
                call    WRITE_FM1
                ld      (is_music_ended), a

                ld      a, 3
loc_92E1:
                dec     a
                ld      (opn_curr_channel), a
                call    sub_94E1
                jr      nz, loc_92E1


				ld a,0xc9
				ld (PLR_PLAY),a
				
				
				ld bc,0xFFFD
				ld a,%11111111
				out (c),a
				
                ret
;===============================
sub_92F0:
                ld      hl, byte_95F6
                call    sel_by_byte
                dec     (hl)
                jp      nz, loc_935C
loc_92FA:
                ld      hl, byte_9602
                call    sel_by_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
loc_9303:
                ld      a, (de)
                inc     de
                cp      61h ; 'a'
                jp      nc, loc_93B3
                push    hl
                push    af
                ld      hl, byte_95F6
                call    sel_by_byte
                ld      a, (de)
                ld      (hl), a
                inc     de
                pop     af
                pop     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      hl, unk_9640
                call    sel_by_byte
                ld      (hl), a
                or      a
                jr      z, loc_935C
                add     a, a
                ld      e, a
                ld      d, 0
                ld      hl, byte_9643
                add     hl, de
                ld      c, 45h ; 'E'
                ld      a, (opn_curr_channel)
                add     a, a
                ld      d, (hl)
                inc     hl
                call    WRITE_FM1
                inc     a
                ld      d, (hl)
                call    WRITE_FM1
                ld      hl, off_9629
                call    sel_by_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, word_9620
                call    sel_by_word
                ld      a, (de)
                inc     de
                ld      (hl), a
                inc     hl
                ld      (hl), 0
                ld      hl, byte_9626
                call    sel_by_byte
                ld      a, (de)
                ld      (hl), a
                jp      loc_93A4
loc_935C:
                ld      hl, unk_9640
                call    sel_by_byte
                ld      a, (hl)
                or      a
                jr      z, loc_93A0
                ld      hl, off_9629
                call    sel_by_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, byte_9626
                call    sel_by_byte
                ld      a, (hl)
                dec     a
                jr      z, loc_9385
                ld      (hl), a
                ld      hl, word_9620
                call    sel_by_word
                ld      a, (de)
                add     a, (hl)
                ld      (hl), a
                jr      loc_93AA
loc_9385:
                inc     de
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                push    de
                ld      hl, word_9620
                call    sel_by_word
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                pop     bc
                ex      de, hl
                add     hl, bc
                jr      nc, loc_93A0
                ex      de, hl
                ld      (hl), e
                dec     hl
                ld      (hl), d
                jr      loc_93AA
loc_93A0:
                ld      d, 0
                jr      loc_93AB
loc_93A4:
                ld      hl, word_9620
                call    sel_by_word
loc_93AA:
                ld      d, (hl)
loc_93AB:
                ld      a, (opn_curr_channel)
                add     a, 8
                jp      WRITE_FM1
loc_93B3:
                cp      0FFh
                jp      z, loc_93D0
                cp      0C6h
                jp      z, loc_940D
                cp      0C5h
                jp      z, loc_941A
                cp      0C3h
                jp      z, loc_93F2
                cp      0C7h
                jp      z, loc_942C
                inc     de
                jp      loc_9303
loc_93D0:
                ld      hl, byte_9608
                call    sel_by_byte
                ld      (hl), 1
                ld      a, (opn_curr_channel)
                add     a, a
                jr      nz, loc_93DF
                inc     a
loc_93DF:
                ld      b, a
                add     a, a
                add     a, a
                add     a, a
                or      b
                ld      b, a
                ld      a, (byte_962F)
                or      b
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                jp      loc_95CD
loc_93F2:
                push    hl
                ld      a, (de)
                add     a, a
                add     a, a
                ld      c, a
                ld      b, 0
                ld      hl, byte_97F6
                add     hl, bc
                ld      b, h
                ld      c, l
                ld      hl, off_9629
                call    sel_by_word
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     hl
                inc     de
                jp      loc_9303
loc_940D:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, 6
                call    WRITE_FM1
                pop     de
                inc     de
                jp      loc_9303
loc_941A:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, (byte_962F)
                and     d
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                pop     de
                inc     de
                jp      loc_9303
loc_942C:
                ld      a, (unk_9644)
                or      a
                jr      nz, loc_9448
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (off_984A)
                add     hl, de
                ex      de, hl
                ld      hl, byte_9602
                call    sel_by_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_92FA
loc_9448:
                dec     a
                ld      (unk_9644), a
                inc     de
                jp      loc_9303

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


sub_9466:
                push    hl
                ld      b, 18h
                ld      a, (opn_curr_channel)
                add     a, 30h ; '0'
_loc_946E:
                ld      d, (hl)
                inc     hl
                call    WRITE_FM1
                add     a, 4
                djnz    _loc_946E
                ld      d, (hl)
                ld      a, (opn_curr_channel)
                add     a, 0B0h
                call    WRITE_FM1
                ld      a, (opn_curr_channel)
                ld      c, a
                ld      b, 0
                ld      hl, byte_960E
                add     hl, bc
                ld      (hl), d
                ld      hl, byte_9611
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
sub_949A:
                dec     a
                ld      de, 30h ; '0'
                ld      h, d
                cp      e
                jr      c, _loc_94A5
                sub     e
                set     5, d
_loc_94A5:
                ld      e, 18h
                cp      e
                jr      c, loc_94AD
                sub     e
                set     4, d
loc_94AD:
                ld      e, 0Ch
                cp      e
                jr      c, loc_94B5
                sub     e
                set     3, d

loc_94B5:
                add     a, a
                ld      l, a
                ld      h, 0
                ld      bc,  word_95DC+1
                add     hl, bc
                ld      a, (hl)
                dec     hl
                or      d
                ld      d, a
                ld      a, (opn_curr_channel)
                add     a, 0A4h
                call    WRITE_FM1
                ld      b, d
                ld      d, (hl)
                ld      a, (opn_curr_channel)
                add     a, 0A0h
                jp      WRITE_FM1
loc_94D3:
                push    af
                ld      a, (opn_curr_channel)
                or      0F0h
                ld      d, a
                ld      a, 28h ; '('
                call    WRITE_FM1
                pop     af
                ret
sub_94E1:
                push    af
                ld      a, (opn_curr_channel)
                ld      d, a
                ld      a, 28h ; '('
                call    WRITE_FM1
                pop     af
                ret
sub_94ED:
                ld      hl, byte_95F9
                call    sel_by_byte
                dec     (hl)
                ret     nz
loc_94F5:
                ld      hl, byte_95FC
                call    sel_by_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
loc_94FE:
                ld      a, (de)
                inc     de
                push    de
                call    sub_94E1
                pop     de
                cp      61h ; 'a'
                jp      nc, loc_9522
                push    af
                push    hl
                ld      hl, byte_95F9
                call    sel_by_byte
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
                call    sub_949A
                jp      loc_94D3
loc_9522:
                cp      0FFh
                jp      z, _loc_95C5
                cp      0C0h
                jp      z, _loc_955D
                cp      0C1h
                jp      z, _loc_9574
                cp      0C7h
                jp      z, _loc_953A
                inc     de
                jp      loc_94FE
_loc_953A:
                ld      a, (unk_9644)
                or      a
                jr      nz, _loc_9556
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (off_984A)
                add     hl, de
                ex      de, hl
                ld      hl, byte_95FC
                call    sel_by_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_94F5
_loc_9556:
                dec     a
                inc     de
                ld      (unk_9644), a
                jr      loc_94FE
_loc_955D:
                push    hl
                ld      hl, off_9630
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
                call    sub_9466
                pop     de
                pop     hl
                jr      loc_94FE
_loc_9574:
                push    hl
                ld      a, (de)
                inc     de
                push    de
                ld      c, a
                ld      hl, byte_960E
                call    sel_by_byte
                ld      b, 1
                ld      a, (hl)
                and     7
                cp      4
                jr      c, _loc_9591
                jr      z, _loc_9590
                inc     b
                inc     b
                cp      7
                jr      c, _loc_9591
_loc_9590:
                inc     b
_loc_9591:
                ld      hl, byte_9615
                ld      a, (opn_curr_channel)
                add     a, a
                add     a, a
                ld      e, a
                ld      d, 0
                add     hl, de
                ld      a, (opn_curr_channel)
                add     a, 4Ch ; 'L'
                ld      e, a
_loc_95A3:
                dec     hl
                ld      a, (hl)
                add     a, c
                ld      d, a
                ld      a, e
                call    WRITE_FM1
                sub     4
                ld      e, a
                djnz    _loc_95A3
                pop     de
                pop     hl
                jp      loc_94FE
; ---------------------------------------------------------------------------
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, 26h ; '&'
                call    WRITE_FM1
                ld      (byte_9643), a
                pop     de
                inc     de
                jp      loc_94FE
; ---------------------------------------------------------------------------

_loc_95C5:
                ld      hl, byte_960B
                call    sel_by_byte
                ld      (hl), 1
loc_95CD:
                ld      hl, byte_9608
                ld      b, 6
loc_95D2:
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                djnz    loc_95D2
                pop     hl
                jp      skip_intro_for_OPN_machines
;---------------------------------------------------------------------
word_95DC:      dw 26Ah
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
opn_curr_channel:dw 0                   
                                        
byte_95F6:      db 1, 1, 1              
                                        
byte_95F9:      db 1, 1, 1              
                                        
byte_95FC:      db 0, 0, 0, 0, 0, 0     
                                        
byte_9602:      db 0, 0, 0, 0, 0, 0     
                                        
byte_9608:      db 0, 0, 0              
                                        
byte_960B:      db 0, 0, 0              
byte_960E:      db 0, 0, 0              
                                        
byte_9611:      db 0, 0, 0, 0           
byte_9615:      db 0, 0, 0, 0           
                db 0, 0, 0, 0
                db    0
                db    0
                db    0
word_9620:      dw 0                    
                                        
                dw 0
                dw 0
byte_9626:      db 0, 0, 0              
off_9629:       dw byte_97F6            
                dw byte_97F6
                dw byte_97F6
byte_962F:      db 0FFh                 
                                        
off_9630:       dw byte_9792            
                dw byte_9792
                dw byte_97AB
                dw byte_97AB
                dw byte_97C4
                dw byte_97DD
                dw byte_97F6
                dw byte_97F6
unk_9640:       db    0                 
                db    0
                db    0
byte_9643:      db 0E1h                 
unk_9644:       db    0                 
                                        
                db 0F0h, 0Eh, 1Ah, 0Eh, 4Fh, 0Dh, 90h, 0Ch, 0DCh, 0Bh, 31h, 0Bh, 91h, 0Ah, 0F9h, 9
                db 6Ah, 9, 0E3h, 8, 63h, 8, 0EBh, 7, 79h, 7, 0Eh, 7, 0A9h, 6, 49h, 6
                db 0EFh, 5, 9Ah, 5, 49h, 5, 0FEh, 4, 0B6h, 4, 72h, 4, 33h, 4, 0F6h, 3
                db 0BEh, 3, 88h, 3, 55h, 3, 26h, 3, 0F8h, 2, 0CEh, 2, 0A6h, 2, 80h, 2
                db 5Ch, 2, 3Ah, 2, 1Ah, 2, 0FCh, 1, 0E0h, 1, 0C5h, 1, 0ACh, 1, 94h, 1
                db 7Dh, 1, 68h, 1, 54h, 1, 41h, 1, 2Fh, 1, 1Eh, 1, 0Eh, 1, 0FFh, 0
                db 0F1h, 0, 0E3h, 0, 0D7h, 0, 0CBh, 0, 0C0h, 0, 0B5h, 0, 0ABh, 0, 0A1h, 0
                db 98h, 0, 90h, 0, 88h, 0, 81h, 0, 79h, 0, 73h, 0, 6Ch, 0, 66h, 0
                db 61h, 0, 5Bh, 0, 56h, 0, 52h, 0, 4Dh, 0, 49h, 0, 45h, 0, 41h, 0
                db 3Eh, 0, 3Ah, 0, 37h, 0, 34h, 0, 31h, 0, 2Fh, 0, 2Ch, 0, 2Ah, 0
                db 28h, 0, 26h, 0, 24h, 0, 22h, 0, 20h, 0, 1Eh, 0, 1Dh, 0, 1Bh, 0
                db 1Ah, 0, 18h, 0, 17h, 0, 16h, 0, 15h, 0, 14h, 0, 13h, 0, 12h, 0

byte_9792:      db 3Fh, 1, 1, 1, 28h, 26h, 16h, 5, 9Fh, 9Eh, 0DBh, 5Eh, 0Fh, 6, 7, 6, 8, 0Bh, 0Ah, 0, 88h, 0F6h, 8Ah, 0F7h, 1Ch
byte_97AB:      db 0, 3, 2, 1, 1Ah, 29h, 21h, 2, 0DFh, 95h, 1Fh, 95h, 0, 10h, 0Bh, 0, 3, 0, 0, 0, 0B0h, 9, 6Dh, 0Fh, 3Bh
byte_97C4:      db 72h, 70h, 73h, 73h, 1Bh, 34h, 21h, 12h, 52h, 55h, 54h, 49h, 7, 7, 9, 0Ch, 0, 0, 0, 0, 3, 3, 2, 1Ch, 3Bh
byte_97DD:      db 73h, 0, 2, 32h, 26h, 1Ch, 3Ah, 0, 0DFh, 95h, 0C1h, 8Fh, 7, 0, 6, 6, 7, 6, 6, 0, 29h, 19h, 19h, 69h, 8
byte_97F6:      db 0Ah, 1, 0FFh, 0E8h, 0Ch, 1, 0FFh, 0EAh, 0Dh, 1, 0FFh, 0E3h, 0Eh, 1, 0FFh, 0EEh
                db 2, 5, 0FFh, 0F2h, 8, 1, 0FFh, 0E2h, 9, 1, 0FFh, 0E3h, 0Ah, 1, 0FFh, 0D9h
                db 0Bh, 1, 0FFh, 0D6h, 5, 2, 0FFh, 0CBh, 8, 1, 0FFh, 0BCh, 0Ah, 1, 0FFh, 0CAh
                db 7, 1, 0FFh, 0D6h, 0Fh, 1, 0FFh, 0E2h, 6, 2, 0FFh, 0D7h, 9, 1, 0FFh, 0C7h
                db 0Bh, 1, 0FFh, 0BFh, 0Ah, 1, 0FFh, 0CBh, 7, 1, 0FFh, 0EEh, 8, 1, 0FFh, 0E7h
                db 9, 1, 0FFh, 0DEh
off_984A:       dw music_start
music_start:    db 0, 0Ch, 1, 8Ah, 3, 10h, 4, 0FAh, 5, 0B6h, 6, 42h, 0, 60h, 0C0h, 3, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0
                db 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 18h, 0, 18h, 0, 18h, 0C1h, 12h, 32h, 18h
                db 0C1h, 0Fh, 35h, 18h, 0C1h, 18h, 39h, 18h, 0C1h, 0Ch, 3Ch, 24h, 0C1h, 12h, 3Bh, 0B4h, 0, 90h, 0, 48h, 3Eh, 0D8h, 3Bh, 18h, 3Eh
                db 18h, 3Bh, 60h, 0, 90h, 0, 48h, 0, 48h, 35h, 18h, 0C1h, 0Fh, 39h, 18h, 0C1h, 0Ch, 40h, 18h, 0C1h, 6, 43h, 90h, 0C1h, 12h
                db 40h, 12h, 0C1h, 0Fh, 43h, 12h, 0C1h, 0Ch, 40h, 6Ch, 0, 90h, 0, 90h, 0C1h, 0Ch, 3Ch, 30h, 0C1h, 12h, 3Bh, 18h, 36h, 18h, 0C1h
                db 15h, 37h, 18h, 0C1h, 0Fh, 39h, 18h, 0C1h, 9, 3Bh, 30h, 0C1h, 0Ch, 37h, 60h, 0, 48h, 0C1h, 12h, 31h, 18h, 32h, 18h, 0C1h, 0Fh
                db 34h, 18h, 0C1h, 6, 37h, 24h, 0C1h, 0Ch, 35h, 24h, 0C1h, 12h, 2Fh, 90h, 0, 60h, 0, 60h, 0, 60h, 0, 18h, 0, 18h, 0
                db 18h, 0C1h, 9, 40h, 0B4h, 3Eh, 18h, 39h, 18h, 3Bh, 0A8h, 0, 24h, 3Eh, 18h, 0, 0Ch, 43h, 6Ch, 40h, 0B4h, 3Eh, 18h, 39h, 18h
                db 3Bh, 0A8h, 0, 60h, 0, 0Ch, 37h, 2Ah, 35h, 1Eh, 34h, 2Ah, 32h, 0C0h, 0, 6, 0, 30h, 0C0h, 1, 0C1h, 6, 32h, 0F0h, 0
                db 30h, 34h, 0F0h, 0, 30h, 35h, 0F0h, 0, 30h, 37h, 0F0h, 0, 30h, 39h, 0F0h, 0, 30h, 3Bh, 0F0h, 0, 30h, 0C0h, 1, 39h, 0C0h
                db 0, 18h, 0C0h, 3, 0C1h, 15h, 3Bh, 18h, 0C1h, 0Fh, 3Ch, 18h, 0C1h, 0Ch, 41h, 18h, 0C1h, 6, 40h, 90h, 3Bh, 30h, 0C1h, 12h, 39h
                db 24h, 0C1h, 9, 3Ch, 30h, 34h, 0B4h, 0, 60h, 0, 18h, 0C1h, 9, 43h, 30h, 0C1h, 0Fh, 41h, 18h, 0C1h, 15h, 3Ch, 18h, 0C1h, 12h
                db 38h, 18h, 34h, 18h, 0C1h, 0Fh, 35h, 24h, 0C1h, 6, 40h, 6Ch, 3Eh, 30h, 0C1h, 0Fh, 3Ch, 18h, 0C1h, 12h, 3Bh, 18h, 0C1h, 18h, 38h
                db 18h, 0C1h, 0Fh, 39h, 18h, 0C1h, 9, 3Ch, 30h, 0C1h, 0Fh, 34h, 48h, 0, 18h, 0, 48h, 0C1h, 18h, 32h, 18h, 0C1h, 12h, 34h, 18h
                db 0C1h, 0Ch, 39h, 18h, 0C1h, 6, 3Eh, 2Ah, 0C1h, 0Ch, 3Bh, 1Eh, 0C1h, 6, 3Eh, 30h, 0C1h, 0Ch, 3Ch, 78h, 0, 30h, 0, 30h, 0
                db 30h, 0, 30h, 0C1h, 6, 3Eh, 0C0h, 0, 60h, 0C1h, 0Ch, 3Bh, 0C0h, 0, 60h, 3Eh, 0C0h, 0FFh, 0FFh, 0, 60h, 0C0h, 3, 0, 24h
                db 0C1h, 12h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0, 60h, 0
                db 60h, 0, 18h, 0, 18h, 0, 18h, 0C1h, 18h, 32h, 18h, 0C1h, 15h, 35h, 18h, 0C1h, 1Eh, 39h, 18h, 0C1h, 12h, 3Ch, 24h, 0C1h, 18h
                db 3Bh, 0B4h, 0, 90h, 0, 48h, 3Eh, 0D8h, 3Bh, 18h, 3Eh, 18h, 3Bh, 60h, 0, 90h, 0, 48h, 0, 48h, 35h, 18h, 0C1h, 15h, 39h
                db 18h, 0C1h, 1Bh, 40h, 18h, 0C1h, 9, 43h, 90h, 0C1h, 18h, 40h, 12h, 0C1h, 15h, 43h, 12h, 0C1h, 12h, 40h, 6Ch, 0, 90h, 0, 90h
                db 0C1h, 12h, 3Ch, 30h, 0C1h, 18h, 3Bh, 18h, 36h, 18h, 0C1h, 1Bh, 37h, 18h, 0C1h, 15h, 39h, 18h, 0C1h, 12h, 3Bh, 30h, 0C1h, 12h, 37h
                db 60h, 0, 48h, 0C1h, 18h, 31h, 18h, 32h, 18h, 0C1h, 15h, 34h, 18h, 0C1h, 0Ch, 37h, 24h, 0C1h, 12h, 35h, 24h, 0C1h, 18h, 2Fh, 90h
                db 0, 60h, 0, 60h, 0, 60h, 0, 18h, 0, 18h, 0, 18h, 0C1h, 0Fh, 40h, 0B4h, 3Eh, 18h, 39h, 18h, 3Bh, 0A8h, 0, 24h, 3Eh
                db 18h, 0, 0Ch, 43h, 6Ch, 40h, 0B4h, 3Eh, 18h, 39h, 18h, 3Bh, 0A8h, 0, 60h, 0, 0Ch, 37h, 2Ah, 35h, 1Eh, 34h, 2Ah, 32h, 0C0h
                db 0, 6, 0, 0Ch, 0C0h, 1, 0C1h, 4, 39h, 0F0h, 0, 30h, 3Bh, 0F0h, 0, 30h, 3Ch, 0F0h, 0, 30h, 3Eh, 0F0h, 0, 30h, 40h
                db 0F0h, 0, 30h, 41h, 0F0h, 0, 0Ch, 0, 24h, 0C0h, 1, 3Bh, 0C0h, 0, 24h, 0, 18h, 0C0h, 3, 0C1h, 1Bh, 3Bh, 18h, 0C1h, 15h
                db 3Ch, 18h, 0C1h, 12h, 41h, 18h, 0C1h, 0Fh, 40h, 90h, 3Bh, 30h, 0C1h, 18h, 39h, 24h, 0C1h, 0Fh, 3Ch, 30h, 34h, 0B4h, 0, 60h, 0
                db 18h, 0C1h, 0Fh, 43h, 30h, 0C1h, 15h, 41h, 18h, 0C1h, 1Bh, 3Ch, 18h, 0C1h, 18h, 38h, 18h, 34h, 18h, 0C1h, 0Fh, 35h, 24h, 0C1h, 0Ch
                db 40h, 6Ch, 3Eh, 30h, 0C1h, 15h, 3Ch, 18h, 0C1h, 18h, 3Bh, 18h, 0C1h, 1Eh, 38h, 18h, 0C1h, 15h, 39h, 18h, 0C1h, 0Fh, 3Ch, 30h, 0C1h
                db 15h, 34h, 48h, 0, 18h, 0, 48h, 0C1h, 1Eh, 32h, 18h, 0C1h, 18h, 34h, 18h, 0C1h, 12h, 39h, 18h, 0C1h, 0Ch, 3Eh, 2Ah, 0C1h, 12h
                db 3Bh, 1Eh, 0C1h, 0Ch, 3Eh, 30h, 0C1h, 12h, 3Ch, 78h, 0, 30h, 0, 30h, 0, 30h, 0, 30h, 0C1h, 0Ch, 3Eh, 0C0h, 0, 60h, 0C1h
                db 12h, 3Bh, 0C0h, 0, 60h, 3Eh, 0C0h, 0FFh, 0FFh, 0, 60h, 0C0h, 1, 0C1h, 8, 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h
                db 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h, 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h, 26h, 90h, 2Dh, 90h, 34h
                db 0B4h, 0, 48h, 0, 24h, 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h, 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h
                db 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h, 0C0h, 5, 0C1h, 7, 26h, 24h, 0C1h, 0Dh, 21h, 24h, 28h, 24h, 0C1h, 0Ah, 2Bh
                db 30h, 0, 30h, 0, 0Ch, 0C1h, 7, 26h, 24h, 0C1h, 0Dh, 21h, 24h, 28h, 24h, 0C1h, 0Ah, 2Bh, 48h, 28h, 24h, 0C1h, 0Ah, 29h, 27h
                db 28h, 60h, 0, 6, 0, 3, 0C1h, 7, 26h, 24h, 0C1h, 0Dh, 21h, 24h, 28h, 24h, 0C1h, 0Ah, 2Bh, 30h, 0, 30h, 0, 0Ch, 0C1h
                db 7, 26h, 24h, 0C1h, 0Dh, 21h, 24h, 28h, 24h, 0C1h, 0Ah, 2Bh, 48h, 28h, 24h, 0C1h, 0Ah, 29h, 27h, 28h, 60h, 0, 6, 0, 3
                db 0C1h, 7, 26h, 24h, 0C1h, 0Dh, 21h, 24h, 28h, 24h, 0C1h, 0Ah, 2Bh, 30h, 0, 30h, 0, 0Ch, 0C1h, 7, 26h, 24h, 0C1h, 0Dh, 21h
                db 24h, 28h, 24h, 0C1h, 0Ah, 2Bh, 48h, 28h, 24h, 0C1h, 0Ah, 29h, 27h, 28h, 60h, 0, 6, 0, 3, 0C1h, 7, 26h, 24h, 0C1h, 0Dh
                db 21h, 24h, 28h, 24h, 0C1h, 0Ah, 2Bh, 30h, 0, 30h, 0, 0Ch, 0C1h, 7, 26h, 24h, 0C1h, 0Dh, 21h, 24h, 28h, 24h, 0C1h, 0Ah, 2Bh
                db 48h, 28h, 24h, 0C1h, 0Ah, 29h, 27h, 28h, 60h, 0, 6, 0, 3, 0C1h, 7, 26h, 24h, 0C1h, 0Dh, 21h, 24h, 28h, 24h, 0C1h, 0Ah
                db 2Bh, 30h, 0, 30h, 0, 0Ch, 0C1h, 7, 28h, 24h, 23h, 24h, 29h, 24h, 2Fh, 60h, 0, 0Ch, 0C1h, 4, 29h, 24h, 24h, 24h, 2Bh
                db 24h, 30h, 24h, 2Bh, 24h, 26h, 24h, 2Dh, 24h, 32h, 0B4h, 0C0h, 1, 26h, 0F0h, 0, 30h, 0C0h, 5, 26h, 24h, 0C1h, 7, 21h, 24h
                db 28h, 24h, 0C1h, 4, 2Bh, 30h, 0, 30h, 0, 0Ch, 0C0h, 5, 26h, 24h, 0C1h, 7, 21h, 24h, 28h, 24h, 0C1h, 4, 2Bh, 48h, 28h
                db 24h, 0C1h, 7, 29h, 27h, 28h, 60h, 0, 6, 0, 3, 0C0h, 5, 26h, 24h, 0C1h, 7, 21h, 24h, 28h, 24h, 0C1h, 4, 2Bh, 30h
                db 0, 30h, 0, 0Ch, 0C0h, 5, 26h, 24h, 0C1h, 7, 21h, 24h, 28h, 24h, 0C1h, 4, 2Bh, 48h, 28h, 24h, 0C1h, 7, 29h, 27h, 28h
                db 60h, 0, 6, 0, 3, 0C0h, 5, 26h, 24h, 0C1h, 7, 21h, 24h, 28h, 24h, 0C1h, 4, 2Bh, 30h, 0, 30h, 0, 0Ch, 0C0h, 5
                db 26h, 24h, 0C1h, 7, 21h, 24h, 28h, 24h, 0C1h, 4, 2Bh, 48h, 28h, 24h, 0C1h, 7, 29h, 27h, 28h, 60h, 0, 6, 0, 3, 0C0h
                db 5, 26h, 24h, 0C1h, 7, 21h, 24h, 28h, 24h, 0C1h, 4, 2Bh, 30h, 0, 30h, 0, 0Ch, 0C0h, 5, 26h, 24h, 0C1h, 7, 21h, 24h
                db 28h, 24h, 0C1h, 4, 2Bh, 48h, 28h, 24h, 0C1h, 7, 29h, 27h, 28h, 60h, 0, 6, 0, 3, 0C0h, 5, 26h, 0C0h, 0FFh, 0FFh, 0
                db 60h, 0C5h, 38h, 0C6h, 4, 0C3h, 1, 1Ah, 90h, 21h, 90h, 28h, 0C0h, 0, 30h, 0, 30h, 1Ah, 90h, 21h, 90h, 28h, 6Ch, 2Bh, 0B4h
                db 1Ah, 90h, 21h, 90h, 2Dh, 0C0h, 0, 30h, 0, 30h, 1Ah, 90h, 21h, 90h, 30h, 6Ch, 28h, 0B4h, 1Ah, 90h, 21h, 90h, 2Dh, 0C0h, 0
                db 30h, 0, 30h, 1Ah, 90h, 21h, 90h, 28h, 6Ch, 2Bh, 0B4h, 1Ah, 90h, 21h, 90h, 2Dh, 0C0h, 0, 30h, 0, 30h, 0C5h, 38h, 0C6h, 4
                db 0C3h, 3, 1Ah, 90h, 21h, 90h, 30h, 6Ch, 28h, 0B4h, 1Ah, 90h, 21h, 90h, 28h, 0C0h, 0, 30h, 0, 30h, 1Ah, 90h, 21h, 90h, 28h
                db 6Ch, 2Bh, 0B4h, 1Ah, 90h, 21h, 90h, 2Dh, 0C0h, 0, 30h, 0, 30h, 1Ah, 90h, 21h, 90h, 30h, 6Ch, 28h, 0B4h, 1Ah, 90h, 21h, 90h
                db 0C5h, 30h, 0C6h, 1Ch, 0C3h, 4, 34h, 0C0h, 0, 30h, 0, 30h, 0C5h, 38h, 0C6h, 4, 0C3h, 3, 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0
                db 48h, 0, 24h, 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h, 26h, 90h, 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h, 26h, 90h
                db 2Dh, 90h, 34h, 0B4h, 0, 48h, 0, 24h, 28h, 0C0h, 0FFh, 0FFh, 0, 60h, 0C5h, 38h, 0C6h, 4, 0C3h, 0, 2Dh, 90h, 34h, 90h, 3Bh
                db 0C0h, 0, 60h, 2Dh, 90h, 34h, 90h, 3Bh, 6Ch, 40h, 0B4h, 2Dh, 90h, 34h, 90h, 3Eh, 0C0h, 0, 60h, 2Dh, 90h, 34h, 90h, 43h, 6Ch
                db 3Ch, 0B4h, 2Dh, 90h, 34h, 90h, 3Bh, 0C0h, 0, 60h, 2Dh, 90h, 34h, 90h, 3Bh, 6Ch, 40h, 0B4h, 2Dh, 90h, 34h, 90h, 3Eh, 0C0h, 0
                db 60h, 2Dh, 90h, 34h, 90h, 43h, 6Ch, 3Ch, 0B4h, 2Dh, 90h, 34h, 90h, 3Bh, 0C0h, 0, 60h, 2Dh, 90h, 34h, 90h, 3Bh, 6Ch, 40h, 0B4h
                db 2Dh, 90h, 34h, 90h, 3Eh, 0C0h, 0, 60h, 2Dh, 90h, 34h, 90h, 43h, 6Ch, 3Ch, 0B4h, 2Dh, 90h, 34h, 90h, 3Ch, 0C0h, 0, 30h, 0
                db 30h, 2Dh, 90h, 34h, 90h, 3Bh, 6Ch, 40h, 0B4h, 2Dh, 90h, 34h, 90h, 3Eh, 0C0h, 0, 60h, 2Dh, 90h, 34h, 90h, 43h, 6Ch, 3Ch, 0B4h
                db 0FFh, 0FFh, 0, 60h, 0C5h, 38h, 0C6h, 4, 0C3h, 0, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h, 1Ch, 24h, 26h, 24h, 21h
                db 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h
                db 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 26h
                db 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h
                db 1Ch, 24h, 26h, 24h, 21h, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 24h, 24h, 1Fh
                db 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h, 1Ch, 24h
                db 26h, 24h, 21h, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 24h, 24h, 1Fh, 24h, 1Ah
                db 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h
                db 1Fh, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h
                db 24h, 21h, 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h
                db 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h
                db 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 0C5h, 38h
                db 0C6h, 4, 0C3h, 0, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 28h, 12h, 1Fh, 12h, 34h, 12h, 2Bh, 12h, 28h, 12h, 1Fh, 12h, 2Dh
                db 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 28h, 12h, 1Fh, 12h, 34h, 12h
                db 2Bh, 12h, 28h, 12h, 1Fh, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h
                db 12h, 28h, 12h, 1Fh, 12h, 34h, 12h, 2Bh, 12h, 28h, 12h, 1Fh, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h
                db 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 28h, 12h, 1Fh, 12h, 34h, 12h, 2Bh, 12h, 28h, 12h, 1Fh, 12h, 2Dh, 12h, 23h, 12h, 32h
                db 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 28h, 12h, 1Fh, 12h, 34h, 12h, 2Bh, 12h, 28h, 12h
                db 1Fh, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 28h, 12h, 1Fh
                db 12h, 34h, 12h, 2Bh, 12h, 28h, 12h, 1Fh, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h
                db 2Dh, 12h, 23h, 12h, 28h, 12h, 1Fh, 12h, 34h, 12h, 2Bh, 12h, 28h, 12h, 1Fh, 12h, 2Dh, 12h, 23h, 12h, 32h, 12h, 28h, 12h, 2Dh
                db 12h, 23h, 12h, 0C5h, 30h, 0C6h, 4, 0C3h, 3, 32h, 0C0h, 0, 18h, 0C3h, 2, 26h, 24h, 21h, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h
                db 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh
                db 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h
                db 21h, 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 26h, 24h, 21h, 24h, 1Ch, 24h, 28h, 24h, 21h, 24h, 1Ch, 24h, 26h, 24h, 21h, 24h, 24h
                db 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h
                db 1Ah, 24h, 24h, 24h, 1Fh, 24h, 24h, 24h, 1Fh, 24h, 1Ah, 24h, 26h, 24h, 1Fh, 24h, 1Ah, 24h, 24h, 24h, 1Fh, 24h, 26h, 0C0h, 0FFh
                db 0FFh, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

				ENT
opn_end:


                savebin "jb2manreq/opn_plr1.bin",opn_begin,opn_end-opn_begin
                ENDMODULE
        