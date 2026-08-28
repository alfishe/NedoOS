                MODULE OPN_PLR1             
PLR_START= 0x4000
opn_begin:
                DISP PLR_START
                jr init_
                jp PLR_PLAY
                jp mute
is_music_ended  db 0

tbl_music       
                db 0xdb
                dw music1_data
                db 0xdb
                dw music1_data

init_
                ld h,0
                ld l,a
                add a,a
                add a,l
                ld l,a
                ld de,tbl_music
                add hl,de
                ld a,(hl)
                ld (tempo_OPN_timer_B),a
                inc hl
                ld a,(hl)
                inc hl
                ld h,(hl)
                ld l,a
                ld (mus_pointer),hl

                LD BC,#FFFD
                LD A,%11111000
                OUT (C),A
                ld      d,0x91   ;set prescaler
                ld      a, 2Dh ; '-'
                call    WRITE_FM1
                call    loc_9697
                ld      a, (tempo_OPN_timer_B)
                ld      d, a
                ld      a, 26h ; '&'
                call    WRITE_FM1
				xor a
				ld (PLR_PLAY),a
                jp      PLR_PLAY+3

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
				
				jp loc_9235
				
				
				
				
PLR_PLAY:       ret 
                call $+3
                LD BC,#FFFD
                LD A,%11111000
                OUT (C),A
                ld      a, 27h ; '''
                ld      d, 2Ah ; '*'
                call    WRITE_FM1
                xor     a
.loc_9209:
          
                ld      (word_95A8), a
                call    sub_94F3
                call    sub_9256
                ld      a, (word_95A8)
                inc     a
                cp      3
                jr      nz, .loc_9209
				
                ret

sub_9224:
                push    de
                ld      de, (word_95A8)
                add     hl, de
                pop     de
                ret

sub_922C:
                push    de
                ld      de, (word_95A8)
                add     hl, de
                add     hl, de
                pop     de
                ret

;-----------------------------------------
loc_9235:
                ld      a, 27h ; '''
                ld      d, 0
                call    WRITE_FM1
                ld      a, 7
                ld      d, 0FFh
                call    WRITE_FM1
                ld      (is_music_ended), a
				ld a,0xc9
				ld (PLR_PLAY),a
				
				
				ld bc,0xFFFD
				ld a,%11111111
				out (c),a
				
                ret
;-----------------------------------------

sub_9256:
                ld      hl, unk_95AA
                call    sub_9224
                dec     (hl)
                jp      nz, loc_92CE
loc_9260:
                ld      hl, byte_95B6
                call    sub_922C
                ld      e, (hl)
                inc     hl
                ld      d, (hl)

loc_9269:
                ld      a, (de)
                inc     de
                cp      61h ; 'a'
                jp      nc, loc_93D5
                push    hl
loc_9271
                push    af
                ld      hl, unk_95AA
                call    sub_9224
                ld      a, (de)
                ld      (hl), a
                inc     de
                pop     af
                pop     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      hl, unk_95D2
                call    sub_9224
                ld      (hl), a
                or      a
                jr      z, loc_92CE
                add     a, a
                ld      e, a
                ld      d, 0
                ld      hl, tempo_OPN_timer_B
                add     hl, de
                ld      a, (word_95A8)
                add     a, a
                ld      d, (hl)
                ld      e, d
                inc     hl
                call    WRITE_FM1
                inc     a
                ld      d, (hl)
                inc     hl
                call    WRITE_FM1
                ld      hl, unk_9388
                call    sub_922C
                ld      (hl), e
                inc     hl
                ld      (hl), d
                call    sub_93A3
                ld      hl, off_95CB
                call    sub_922C
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, byte_95C2
                call    sub_922C
                ld      a, (de)
                inc     de
                ld      (hl), a
                inc     hl
                ld      (hl), 0
                ld      hl, byte_95C8
                call    sub_9224
                ld      a, (de)
                ld      (hl), a
                jp      loc_9316

loc_92CE:
                ld      hl, unk_95D2
                call    sub_9224
                ld      a, (hl)
                or      a
                jr      z, loc_9312
                ld      hl, off_95CB
                call    sub_922C
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, byte_95C8
                call    sub_9224
                ld      a, (hl)
                dec     a
                jr      z, loc_92F7
                ld      (hl), a
                ld      hl, byte_95C2
                call    sub_922C
                ld      a, (de)
                add     a, (hl)
                ld      (hl), a
                jr      loc_931C

loc_92F7:
                inc     de
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                push    de
                ld      hl, byte_95C2
                call    sub_922C
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                pop     bc
                ex      de, hl
                add     hl, bc
                jr      nc, loc_9312
                ex      de, hl
                ld      (hl), e
                dec     hl
                ld      (hl), d
                jr      loc_931C
loc_9312:
                ld      d, 0
                jr      loc_931D

loc_9316:
                ld      hl, byte_95C2
                call    sub_922C
loc_931C:
                ld      d, (hl)

loc_931D:
                ld      a, (word_95A8)
                add     a, 8
                call    WRITE_FM1
                ld      hl, unk_939D
                call    sub_9224
                dec     (hl)
                ret     nz
                inc     (hl)
                ld      hl, unk_9388
                call    sub_922C
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                push    de
                srl     d
                rr      e
                ld      hl, unk_9394
                call    sub_9224
                bit     1, (hl)
                call    z, sub_93CD
                ld      hl, unk_938E
                call    sub_922C
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
loc_9357:
                ld      d, 0
                bit     7, e
                jr      z, loc_935E
                dec     d
loc_935E:
                pop     hl
                add     hl, de
                ld      a, (word_95A8)
                add     a, a
                ld      d, l
                call    WRITE_FM1
                inc     a
                ld      d, h
                call    WRITE_FM1
                ld      hl, unk_9397
                call    sub_9224
                dec     (hl)
                ret     nz
                ex      de, hl
                ld      hl, unk_939A
                call    sub_9224
                ld      a, (hl)
                ld      (de), a
                ld      hl, unk_9394
                call    sub_9224
                ld      a, (hl)
                cpl
                ld      (hl), a
                ret
; ---------------------------------------------------------------------------
sub_93A3:
                ld      hl, unk_938E
                call    sub_922C
                ld      (hl), 0
                inc     hl
                ld      (hl), 0
                ld      hl, unk_939A
                call    sub_9224
                ld      a, (hl)
                ld      hl, unk_9397
                call    sub_9224
                srl     a
                ld      (hl), a
                ld      hl, unk_93A0
                call    sub_9224
                ld      a, (hl)
                ld      hl, unk_939D
                call    sub_9224
                ld      (hl), a
                ret
sub_93CD:
                ld      a, d
                cpl
loc_93CF:
                ld      d, a
                ld      a, e
                cpl
                ld      e, a
                inc     de
                ret
loc_93D5:
                cp      0FFh
                jp      z, loc_93F2
                cp      0C6h
                jp      z, loc_942F
                cp      0C5h
                jp      z, loc_943C
                cp      0C3h
                jp      z, loc_9414
                cp      0C7h
                jp      z, loc_944C
                inc     de
                jp      loc_9269

loc_93F2:
                ld      hl, byte_95BC
                call    sub_9224
                ld      (hl), 1
                ld      a, (word_95A8)
                add     a, a
                jr      nz, loc_9401
loc_9400:
                inc     a
loc_9401:
                ld      b, a
                add     a, a
                add     a, a
                add     a, a
                or      b
                ld      b, a
                ld      a, (byte_95D1)
                or      b
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                jp      loc_9581
loc_9414:
                push    hl
                ld      a, (de)
                add     a, a
                add     a, a
                ld      c, a
                ld      b, 0
                ld      hl, byte_9860
                add     hl, bc
                ld      b, h
                ld      c, l
                ld      hl, off_95CB
                call    sub_922C
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     hl
                inc     de
                jp      loc_9269
loc_942F:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, 6
                call    WRITE_FM1
                pop     de
loc_9438:
                inc     de
                jp      loc_9269
loc_943C:
                push    de
                ld      a, (de)
                ld      d, a
                ld      a, (byte_95D1)
                and     d
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                pop     de
                jr      loc_9438
loc_944C:
                ld      a, (byte_95D6)
                or      a
                jr      nz, loc_9468
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (mus_pointer)
                add     hl, de
                ex      de, hl
                ld      hl, byte_95B6
                call    sub_922C
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_9260
loc_9468:
                dec     a
                ld      (byte_95D6), a
                inc     de
                inc     de
                jp      loc_9438

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

sub_9487:
                ld      b, 18h
                ld      a, (word_95A8)
                add     a, 30h ; '0'
loc_948E:
                ld      d, (hl)
                inc     hl
                call    WRITE_FM1
                add     a, 4
                djnz    loc_948E
                ld      d, (hl)
                ld      a, (word_95A8)
                add     a, 0B0h
                jp      WRITE_FM1

sub_94A0:
                dec     a
                ld      de, 30h ; '0'
                ld      h, d
                cp      e
                jr      c, loc_94AB
                sub     e
                set     5, d

loc_94AB:
                ld      e, 18h
                cp      e
                jr      c, loc_94B3
                sub     e
                set     4, d

loc_94B3:
                ld      e, 0Ch
                cp      e
                jr      c, loc_94BB
                sub     e
                set     3, d

loc_94BB:
                add     a, a
                ld      l, a
                ld      h, 0
                ld      bc, table_unk_9590+1
                add     hl, bc
                ld      a, (hl)
                dec     hl
                or      d
                ld      d, a
                ld      a, (word_95A8)
                add     a, 0A4h
                call    WRITE_FM1
                ld      b, d
                ld      d, (hl)
                ld      a, (word_95A8)
                add     a, 0A0h
                jp      WRITE_FM1

loc_94D9:
                push    af
                ld      a, (word_95A8)
                or      0F0h
                ld      d, a
                ld      a, 28h ; '('
                call    WRITE_FM1
                pop     af
                ret

sub_94E7:
                push    af
                ld      a, (word_95A8)
                ld      d, a
                ld      a, 28h ; 
                call    WRITE_FM1
                pop     af
                ret

sub_94F3:
                ld      hl, byte_95AD
                call    sub_9224
                dec     (hl)
                ret     nz

loc_94FB:
                ld      hl, byte_95B0
                call    sub_922C
                ld      e, (hl)
                inc     hl
                ld      d, (hl)

loc_9504:
                ld      a, (de)
                inc     de
                push    de
                call    sub_94E7
                pop     de
                cp      61h ; 'a'
                jp      nc, loc_9528
                push    af
                push    hl
                ld      hl, byte_95AD
                call    sub_9224
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
                call    sub_94A0
                jp      loc_94D9

loc_9528:
                cp      0FFh
                jp      z, loc_9579
                cp      0C0h
                jp      z, loc_955F
                cp      0C7h
                jp      z, loc_953B

loc_9537:
                inc     de
                jp      loc_9504

loc_953B:
                ld      a, (byte_95D6)
                or      a
                jr      nz, loc_9557
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (mus_pointer)
                add     hl, de
                ex      de, hl
                ld      hl, byte_95B0
                call    sub_922C
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_94FB

loc_9557:
                dec     a
                inc     de
                inc     de
                ld      (byte_95D6), a
                jr      loc_9537

loc_955F:
				push hl
                ld      a, (de)
                inc     de
                push    de
                ld      l, a
                ld      h, 0
                ld      e, l
                ld      d, h
                add     hl, hl
                add     hl, de          ; *3 =3
                add     hl, hl          ; *2 =6
                add     hl, hl          ; *2 = 12
                add     hl, hl          ; *2 = 24
                add     hl, de          ; +1 = 25
                ld      de, byte_96E9
                add     hl, de
                call    sub_9487
                pop     de
                pop     hl
                jr      loc_9504

loc_9579:
                ld      hl, byte_95BF
                call    sub_9224
                ld      (hl), 1

loc_9581: 
                ld      hl, byte_95BC
                ld      b, 6

loc_9586: 
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                djnz    loc_9586
                pop     hl
                jp      loc_9235

unk_9388:       db    0                 
                                        
                db    0
                db    0
                db    0
                db    0
                db    0
unk_938E:       db    0                 
                                        
                db    0
                db    0
                db    0
                db    0
                db    0
unk_9394:       db    0                 
                                        
                db    0
                db    0
unk_9397:       db    3                 
                                        
                db    3
                db    3
unk_939A:       db    4                 
                                        
                db    6
                db    8
unk_939D:       db  18h                 
                                        
                db  18h
                db  18h
unk_93A0:       db  18h                 
                db  18h
                db  18h

table_unk_9590: dw 26Ah                 
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
word_95A8:      dw 0                    
                                        
unk_95AA:       db    1                 
                                        
                db    1
                db    1
byte_95AD:      db 1, 1, 1              
                                        
byte_95B0:      db 0, 0, 0, 0, 0, 0     
                                        
byte_95B6:      db 0, 0, 0, 0, 0, 0     
                                        
byte_95BC:      db 0, 0, 0              
                                        
byte_95BF:      db 0, 0, 0              
byte_95C2:      db 0, 0, 0, 0, 0, 0     
                                        
byte_95C8:      db 0, 0, 0              
                                        
off_95CB:       dw byte_9860            
                                        
                dw byte_9860
                dw byte_9860
byte_95D1:      db 0FFh                 
                                        
unk_95D2:       db    0                 
                                        
                db    0
                db    0
tempo_OPN_timer_B:db 0DFh               
                                        
byte_95D6:      db 0                    
                                        
                dw 0EE9h
                dw 0E12h
                dw 0D48h
                dw 0C89h
                dw 0BD5h
                dw 0B2Bh
                dw 0A8Ah
                dw 9F3h
                dw 964h
                dw 8DDh
                dw 85Eh
                dw 7E6h
                dw 774h
                dw 709h
                dw 6A4h
                dw 644h
                dw 5EAh
                dw 595h
                dw 545h
                dw 4F9h
                dw 4B2h
                dw 46Eh
                dw 42Fh
                dw 3F3h
                dw 3BAh
                dw 384h
                dw 352h
                dw 322h
                dw 2F5h
                dw 2CAh
                dw 2A2h
                dw 27Ch
                dw 259h
                dw 237h
                dw 217h
                dw 1F9h
                dw 1DDh
                dw 1C2h
                dw 1A9h
                dw 191h
                dw 17Ah
                dw 165h
                dw 151h
                dw 13Eh
                dw 12Ch
                dw 11Bh
                dw 10Bh
                dw 0FCh
                dw 0EEh
                dw 0E1h
                dw 0D4h
                dw 0C8h
                dw 0BDh
                dw 0B2h
                dw 0A8h
                dw 9Fh
                dw 96h
                dw 8Dh
                dw 85h
                dw 7Eh
                dw 77h
                dw 70h
                dw 6Ah
                dw 64h
                dw 5Eh
                dw 59h
                dw 54h
                dw 4Fh
                dw 4Bh
                dw 46h
                dw 42h
                dw 3Fh
                dw 3Bh
                dw 38h
                dw 35h
                dw 32h
                dw 2Fh
                dw 2Ch
                dw 2Ah
                dw 27h
                dw 25h
                dw 23h
                dw 21h
                dw 1Fh
                dw 1Dh
                dw 1Ch
                dw 1Ah
                dw 19h
                dw 17h
                dw 16h
                dw 15h
                dw 13h
                dw 12h
                dw 11h
                dw 10h
                dw 0Fh

loc_9697:
                ld      hl, unk_95AA
                ld      b, 6

.loc_969C:                               ; CODE XREF: ROM:969F↓j
                ld      (hl), 1
                inc     hl
                djnz    .loc_969C
                ld      hl, byte_95BC
                ld      b, 6

.loc_96A6:                               ; CODE XREF: ROM:96A9↓j
                ld      (hl), 0
                inc     hl
                djnz    .loc_96A6
                ld      hl, (mus_pointer)
                ld      (.loc_96BA+1), hl
                ex      de, hl
                ld      hl, byte_95B0
                ld      (.loc_96C2+1), hl
                ld      b, 6
.loc_96BA:
                ld      hl, 0
                ld      a, (hl)
                inc     hl
                ld      l, (hl)
                ld      h, a
                add     hl, de
.loc_96C2:
                ld      (byte_95B0), hl
                ld      hl, (.loc_96BA+1)
                inc     hl
                inc     hl
                ld      (.loc_96BA+1), hl
                ld      hl, (.loc_96C2+1)
                inc     hl
                inc     hl
                ld      (.loc_96C2+1), hl
                djnz    .loc_96BA
                ld      a, 0F8h
                ld      (byte_95D1), a
                ld      d, a
                ld      a, 7
                call    WRITE_FM1
                ld      a, 0Dh
                ld      d, 0
                jp      WRITE_FM1

byte_96E9:      db 3Fh, 3Ch, 2Fh, 38h, 14h, 0, 14h, 0, 1Fh, 1Fh, 19h, 19h, 19h, 19h, 0Ch, 0Ch, 0, 3, 5, 5, 2Fh, 57h, 3Fh, 4Fh, 1Fh
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
byte_9860:      db 0Ah, 1, 0FFh, 0F9h
                db 9, 1, 0FFh, 0F9h
                db 0Ch, 1, 0FFh, 0CBh
                db 0Ch, 1, 0FFh, 0D9h
                db 1, 0Ah, 0FFh, 0F2h
                db 0Ah, 1, 0FFh, 0E9h
                db 1, 0Bh, 0FFh, 0FAh
                db 1, 0Ah, 0FFh, 0FAh
                db 1, 0Ch, 0FFh, 0FAh
mus_pointer:    dw music1_data
; ---------------------------------------------------------------------------
music1_data:     db 0, 0Ch, 0, 0CAh, 1, 0F8h, 4, 4, 4, 0B8h, 5, 6Ch, 0C0h, 6, 29h, 90h
                db 2Dh, 90h, 32h, 0F0h, 0C8h, 0, 0C8h, 0, 0, 30h, 0C0h, 0Ah, 19h, 90h, 1Ah, 90h
                db 1Dh, 90h, 21h, 90h, 19h, 90h, 1Ah, 90h, 1Dh, 90h, 15h, 90h, 0C0h, 4, 34h, 90h
                db 32h, 90h, 2Dh, 90h, 2Fh, 90h, 2Bh, 90h, 26h, 90h, 28h, 6Ch, 0C8h, 0, 0C8h, 0
                db 30h, 18h, 34h, 0Ch, 35h, 18h, 37h, 0Ch, 39h, 18h, 37h, 0Ch, 3Ah, 0Ch, 3Ch, 0Ch
                db 3Ah, 0Ch, 39h, 18h, 35h, 9Ch, 0C8h, 0, 0C8h, 0, 37h, 90h, 39h, 90h, 3Bh, 48h
                db 3Ch, 18h, 3Eh, 18h, 40h, 18h, 43h, 90h, 3Eh, 48h, 3Ch, 48h, 3Bh, 90h, 37h, 90h
                db 0C0h, 9, 39h, 48h, 2Bh, 18h, 2Dh, 0Ch, 2Ah, 0Ch, 2Fh, 0Ch, 32h, 0Ch, 36h, 24h
                db 37h, 18h, 34h, 42h, 0C8h, 0, 0C8h, 0, 36h, 12h, 32h, 18h, 2Dh, 0Ch, 2Bh, 18h
                db 28h, 0Ch, 26h, 18h, 2Bh, 0Ch, 34h, 66h, 0C8h, 0, 0C8h, 0, 0, 18h, 37h, 12h
                db 39h, 0Ch, 3Ch, 0Ch, 3Eh, 0Ch, 40h, 24h, 40h, 24h, 3Ch, 18h, 37h, 0Ch, 36h, 24h
                db 35h, 24h, 33h, 24h, 30h, 18h, 2Ah, 0Ch, 29h, 18h, 2Bh, 6Ch, 0C8h, 0, 0C8h, 0
                db 29h, 18h, 28h, 18h, 26h, 90h, 23h, 0C0h, 0FFh, 0FFh, 0C0h, 6, 2Fh, 48h, 32h, 48h
                db 35h, 48h, 37h, 48h, 39h, 0F0h, 0C8h, 0, 0C8h, 0, 0, 30h, 0C0h, 8, 21h, 48h
                db 28h, 3Ch, 0C8h, 0, 0C8h, 0, 21h, 0Ch, 0, 18h, 21h, 30h, 28h, 48h, 21h, 48h
                db 28h, 3Ch, 0C8h, 0, 0C8h, 0, 21h, 0Ch, 0, 18h, 21h, 0Ch, 0, 18h, 21h, 0Ch
                db 28h, 24h, 21h, 24h, 21h, 48h, 28h, 3Ch, 0C8h, 0, 0C8h, 0, 21h, 0Ch, 0, 18h
                db 21h, 30h, 28h, 48h, 21h, 48h, 28h, 3Ch, 0C8h, 0, 0C8h, 0, 21h, 0Ch, 0C0h, 8
                db 28h, 18h, 21h, 24h, 21h, 24h, 21h, 0Ch, 24h, 24h, 21h, 48h, 28h, 3Ch, 0C8h, 0
                db 0C8h, 0, 21h, 0Ch, 0, 18h, 21h, 30h, 28h, 48h, 21h, 48h, 28h, 3Ch, 0C8h, 0
                db 0C8h, 0, 21h, 0Ch, 0, 18h, 21h, 0Ch, 0, 18h, 21h, 0Ch, 28h, 24h, 21h, 24h
                db 21h, 48h, 28h, 3Ch, 0C8h, 0, 0C8h, 0, 21h, 0Ch, 0, 18h, 21h, 30h, 28h, 48h
                db 21h, 48h, 28h, 3Ch, 0C8h, 0, 0C8h, 0, 21h, 0Ch, 0C0h, 8, 28h, 18h, 21h, 24h
                db 21h, 24h, 21h, 0Ch, 24h, 24h, 0C0h, 0Ch, 28h, 48h, 0C0h, 0Ah, 23h, 90h, 26h, 90h
                db 28h, 90h, 2Bh, 48h, 0C0h, 8, 24h, 48h, 2Bh, 3Ch, 0C8h, 0, 0C8h, 0, 24h, 0Ch
                db 29h, 18h, 24h, 30h, 28h, 48h, 24h, 48h, 2Bh, 3Ch, 0C8h, 0, 0C8h, 0, 24h, 0Ch
                db 2Dh, 18h, 24h, 24h, 24h, 24h, 24h, 0Ch, 28h, 24h, 24h, 48h, 2Bh, 3Ch, 0C8h, 0
                db 0C8h, 0, 24h, 0Ch, 29h, 18h, 24h, 30h, 28h, 48h, 24h, 48h, 2Bh, 3Ch, 0C8h, 0
                db 0C8h, 0, 24h, 0Ch, 0, 18h, 24h, 0Ch, 0, 18h, 24h, 0Ch, 2Dh, 24h, 28h, 24h
                db 24h, 48h, 2Bh, 3Ch, 0C8h, 0, 0C8h, 0, 24h, 0Ch, 29h, 18h, 24h, 30h, 28h, 48h
                db 24h, 48h, 2Bh, 3Ch, 0C8h, 0, 0C8h, 0, 24h, 0Ch, 2Dh, 18h, 24h, 24h, 24h, 24h
                db 24h, 0Ch, 28h, 24h, 23h, 0C0h, 0FFh, 0FFh, 0C0h, 6, 31h, 48h, 35h, 48h, 39h, 48h
                db 3Dh, 48h, 3Eh, 0F0h, 0C8h, 0, 0C8h, 0, 0, 30h, 31h, 0D8h, 0C8h, 0, 0C8h, 0
                db 0C0h, 0Ah, 1Ah, 90h, 0C8h, 0, 0C8h, 0, 1Dh, 90h, 21h, 90h, 0C8h, 0, 0C8h, 0
                db 19h, 90h, 1Ah, 0A8h, 0C8h, 0, 0C8h, 0, 0, 0Ch, 0, 18h, 0C0h, 0Eh, 21h, 0Ch
                db 0C0h, 0Ch, 2Bh, 18h, 2Bh, 24h, 0C0h, 0Eh, 21h, 24h, 21h, 0Ch, 0C0h, 0Ch, 28h, 24h
                db 0C0h, 0Eh, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h
                db 0C0h, 0Dh, 34h, 18h, 0C0h, 0Eh, 21h, 0Ch, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h
                db 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h, 34h, 0Ch, 0C0h, 0Eh, 21h, 18h
                db 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h
                db 0C0h, 0Eh, 21h, 0Ch, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch
                db 28h, 24h, 0C0h, 0Dh, 34h, 18h, 34h, 0Ch, 0C0h, 0Eh, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch
                db 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h, 0C0h, 0Eh, 21h, 0Ch
                db 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh
                db 34h, 18h, 34h, 0Ch, 0C0h, 0Eh, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch
                db 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h, 0C0h, 0Eh, 21h, 0Ch, 0C0h, 0Ch, 2Bh, 18h
                db 2Bh, 24h, 0C0h, 0Eh, 21h, 24h, 21h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Ah, 1Ch, 90h
                db 1Fh, 90h, 23h, 90h, 26h, 48h, 28h, 18h, 2Bh, 18h, 2Fh, 18h, 0C0h, 0Eh, 21h, 18h
                db 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h
                db 0C0h, 0Eh, 21h, 0Ch, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch
                db 28h, 24h, 0C0h, 0Dh, 34h, 18h, 34h, 0Ch, 0C0h, 0Eh, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch
                db 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h, 0C0h, 0Eh, 21h, 0Ch
                db 0C0h, 0Ch, 2Bh, 18h, 2Bh, 24h, 0C0h, 0Eh, 21h, 24h, 21h, 0Ch, 0C0h, 0Ch, 28h, 24h
                db 0C0h, 0Eh, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h
                db 0C0h, 0Dh, 34h, 18h, 0C0h, 0Eh, 21h, 0Ch, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h
                db 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h, 34h, 0Ch, 0C0h, 0Eh, 21h, 18h
                db 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h
                db 0C0h, 0Eh, 21h, 0Ch, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch
                db 28h, 24h, 0C0h, 0Dh, 34h, 18h, 34h, 0Ch, 0C0h, 0Eh, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch
                db 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h, 0C0h, 0Eh, 21h, 0Ch
                db 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch, 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh
                db 34h, 18h, 34h, 0Ch, 0C0h, 0Eh, 21h, 18h, 0C0h, 0Dh, 34h, 0Ch, 34h, 18h, 34h, 0Ch
                db 0C0h, 0Ch, 28h, 24h, 0C0h, 0Dh, 34h, 18h, 0C0h, 0Eh, 21h, 0Ch, 0C0h, 0Ch, 2Bh, 18h
                db 2Bh, 24h, 0C0h, 0Eh, 21h, 24h, 21h, 0Ch, 0C0h, 0Ch, 28h, 24h, 28h, 0C0h, 0C8h, 0
                db 0C8h, 0, 0FFh, 0FFh, 0, 9, 0, 90h, 0, 90h, 0, 90h, 0, 90h, 0, 90h
                db 0, 90h, 0, 90h, 0, 90h, 0, 90h, 0, 48h, 0, 24h, 0C3h, 3, 51h, 90h
                db 0, 24h, 0, 90h, 0C3h, 7, 34h, 90h, 32h, 90h, 2Dh, 90h, 2Fh, 90h, 2Bh, 90h
                db 26h, 90h, 28h, 60h, 0, 0Ch, 30h, 18h, 34h, 0Ch, 35h, 18h, 37h, 0Ch, 39h, 18h
                db 37h, 0Ch, 3Ah, 0Ch, 3Ch, 0Ch, 3Ah, 0Ch, 39h, 18h, 35h, 9Ch, 0C8h, 0, 0C8h, 0
                db 37h, 90h, 39h, 90h, 3Bh, 90h, 43h, 90h, 3Eh, 48h, 3Ch, 48h, 3Bh, 90h, 37h, 90h
                db 39h, 48h, 2Bh, 18h, 2Dh, 0Ch, 2Ah, 0Ch, 2Fh, 0Ch, 32h, 0Ch, 36h, 24h, 37h, 18h
                db 34h, 42h, 0C8h, 0, 0C8h, 0, 36h, 12h, 32h, 18h, 2Dh, 0Ch, 2Bh, 18h, 28h, 0Ch
                db 26h, 18h, 2Bh, 0Ch, 34h, 66h, 0C8h, 0, 0C8h, 0, 0, 18h, 37h, 12h, 39h, 0Ch
                db 3Ch, 0Ch, 3Eh, 0Ch, 40h, 24h, 40h, 24h, 3Ch, 18h, 37h, 0Ch, 36h, 24h, 35h, 24h
                db 33h, 24h, 30h, 18h, 2Ah, 0Ch, 29h, 18h, 2Bh, 6Ch, 0C8h, 0, 0C8h, 0, 29h, 18h
                db 28h, 18h, 26h, 90h, 23h, 0C0h, 0FFh, 0FFh, 0, 12h, 0, 90h, 0, 90h, 0, 90h
                db 0, 90h, 0, 90h, 0, 90h, 0, 90h, 0, 90h, 0, 90h, 0, 48h, 0, 24h
                db 0C3h, 3, 53h, 90h, 0, 24h, 0, 90h, 0C3h, 8, 34h, 90h, 32h, 90h, 2Dh, 90h
                db 2Fh, 90h, 2Bh, 90h, 26h, 90h, 28h, 60h, 0, 0Ch, 30h, 18h, 34h, 0Ch, 35h, 18h
                db 37h, 0Ch, 39h, 18h, 37h, 0Ch, 3Ah, 0Ch, 3Ch, 0Ch, 3Ah, 0Ch, 39h, 18h, 35h, 9Ch
                db 0C8h, 0, 0C8h, 0, 37h, 90h, 39h, 90h, 3Bh, 90h, 43h, 90h, 3Eh, 48h, 3Ch, 48h
                db 3Bh, 90h, 37h, 90h, 39h, 48h, 2Bh, 18h, 2Dh, 0Ch, 2Ah, 0Ch, 2Fh, 0Ch, 32h, 0Ch
                db 36h, 24h, 37h, 18h, 34h, 42h, 0C8h, 0, 0C8h, 0, 36h, 12h, 32h, 18h, 2Dh, 0Ch
                db 2Bh, 18h, 28h, 0Ch, 26h, 18h, 2Bh, 0Ch, 34h, 66h, 0C8h, 0, 0C8h, 0, 0, 18h
                db 37h, 12h, 39h, 0Ch, 3Ch, 0Ch, 3Eh, 0Ch, 40h, 24h, 40h, 24h, 3Ch, 18h, 37h, 0Ch
                db 36h, 24h, 35h, 24h, 33h, 24h, 30h, 18h, 2Ah, 0Ch, 29h, 18h, 2Bh, 6Ch, 0C8h, 0
                db 0C8h, 0, 29h, 18h, 28h, 18h, 26h, 90h, 23h, 0C0h, 0FFh, 0FFh, 0FFh, 0FFh, 0, 1Ch
                db 59h, 50h, 45h, 0Dh, 0Ah, 0, 18h, 98h, 31h, 0FEh, 0E5h, 0CDh, 6Ch, 6, 0CDh, 89h
                db 0D4h, 21h, 2, 22h, 22h, 0B7h, 3, 0CDh, 2Dh, 3, 0CDh, 0B9h, 0F1h, 0E8h


				ENT
opn_end:


                savebin "kissofmurder/opn_plr1.bin",opn_begin,opn_end-opn_begin
                ENDMODULE
        