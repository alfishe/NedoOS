                MODULE AY_PLR1
PLR_START= 0x4000
EXT_RTN = 0x5800
ay_begin:
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


init_:
                LD BC,#FFFD
                LD A,%11111100
                OUT (C),A


                call ay_init

                ;call mute
                xor a
                ld (PLR_PLAY),a
				ld (player),a
                ld      (is_music_ended), a
                ret

PLR_PLAY:
                ret
                call exit_routine 
                
                LD BC,#FFFD
                LD A,%11111100
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
speed_loop:     dec b
                ret z ;jp z,speed_loop_exit
                push bc
                    call player
                pop bc
                jp speed_loop
;speed_loop_exit:
;                ret



player:
				ret
                ld      a, (byte_4459)
                ld      b, a
loc_41B7:
                push    bc
                xor     a
loc_41B9:
                ld      (current_channel), a
                call    play_ay
                ld      a, (current_channel)
                inc     a
                cp      3
                jr      nz, loc_41B9
                pop     bc
                djnz    loc_41B7
                ret


mute
e_o_mus:
                LD BC,#FFFD
                LD A,%11111100
                OUT (C),A



;                ld      a, 7
;                ld      e, 0BFh
;                call    j_WRTPSG
                call NOMUS

                ld      a, 1
                ld      (is_music_ended), a
                ld a,0xc9
                ld (PLR_PLAY),a
				ld (player),a
                ret

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


select_chan_data_byte:
                push    de
                ld      de, (current_channel)
                add     hl, de
                pop     de
                ret
select_chan_data_word:
                push    de
                ld      de, (current_channel)
                add     hl, de
                add     hl, de
                pop     de
                ret

j_WRTPSG   ; a - register  ; e - data
                push bc
                LD BC,#FFFD
                OUT (C),A
                push af
                LD B,#BF
                LD A,E
                OUT (C),A
                pop af
                pop bc
                ret

play_ay:
                ld      hl, byte_442D
                call    select_chan_data_byte
                dec     (hl)
                jp      nz, loc_42A9
loc_4255:
                ld      hl, off_4430
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
loc_425E:
                ld      a, (de)
                inc     de
                cp      61h ; 'a'
                jp      nc, loc_437B
                push    hl
                push    af
                ld      hl, byte_442D
                call    select_chan_data_byte
                ld      a, (de)
                ld      (hl), a
                inc     de
                pop     af
                pop     hl
loc_4272:
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      hl, byte_4439
                call    select_chan_data_byte
                ld      (hl), a
                or      a
                jr      z, loc_42A9
                add     a, a
                ld      e, a
                ld      d, 0
                ld      hl, byte_4459   ; table 445b
                add     hl, de
                ld      a, (current_channel)
                add     a, a
                ld      e, (hl)
                inc     hl
                call    j_WRTPSG
                inc     a
                ld      e, (hl)
                call    j_WRTPSG
                ld      hl, byte_4451
                call    select_chan_data_byte
                xor     a
                ld      (hl), a
                call    sub_4301
                ld      hl, byte_4442
                call    select_chan_data_word
                ld      (hl), a
                inc     hl
                ld      (hl), a
loc_42A9:
                ld      hl, byte_4439
                call    select_chan_data_byte
                ld      a, (hl)
                or      a
                jr      z, loc_42F8
                ld      hl, byte_4451
                call    select_chan_data_byte
                ld      a, (hl)
                dec     a
                jr      z, loc_42C9
                dec     a
                jr      z, loc_42D2
                dec     a
                jr      z, loc_42DC
                dec     a
                jr      z, loc_42F0
                xor     a
                jr      loc_42F8
loc_42C9:
                xor     a
                ld      (loc_4357), a
                call    loc_4334
                jr      loc_42F8
loc_42D2:
                ld      a, 3Fh ; '?'
                ld      (loc_4357), a
                call    loc_4334
                jr      loc_42F8
loc_42DC:
                ld      hl, byte_4448
                call    select_chan_data_word
                dec     (hl)
                ret     nz
                call    sub_4301
                ld      hl, byte_444E
                call    select_chan_data_byte
                ld      (hl), 0
                ret
loc_42F0:
                ld      a, 3Fh ; '?'
                ld      (loc_4357), a
                call    loc_4334
loc_42F8:
                ld      e, a
                ld      a, (current_channel)
                add     a, 8
loc_42FE:
                jp      j_WRTPSG
                
sub_4301:
                ld      hl, byte_443C
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, byte_4451
                call    select_chan_data_byte
                ld      a, (hl)
                push    hl
                ld      l, a
                ld      h, 0
                push    hl
                add     a, 8
                ld      l, a
                add     hl, de
                ld      b, (hl)
                ld      hl, byte_444E
                call    select_chan_data_byte
                ld      (hl), b
                pop     hl
                add     hl, hl
                add     hl, de
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, byte_4448
                call    select_chan_data_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                pop     hl
                inc     (hl)
                ret
loc_4334:
                ld      hl, byte_4448
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      a, d
                or      e
                jr      z, loc_4364
                ld      hl, byte_4442
                call    select_chan_data_word
                ld      c, (hl)
                inc     hl
                ld      b, (hl)
                ex      de, hl
                add     hl, bc
                ex      de, hl
                push    hl
                ld      hl, byte_444E
                call    select_chan_data_byte
                ld      a, d
                cp      (hl)
                pop     hl
loc_4357:
                nop
                jr      nc, loc_4364
                cp      10h
                jr      c, loc_4360
                xor     a
                ret
loc_4360:
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ret
loc_4364:
                ld      hl, byte_444E
                call    select_chan_data_byte
                ld      a, (hl)
                push    af
                call    sub_4301
                ld      hl, byte_4442
                call    select_chan_data_word
                pop     af
                ld      (hl), 0
                inc     hl
                ld      (hl), a
                ret
loc_437B:
                cp      0FFh
                jp      z, loc_4398
                cp      0C6h
                jp      z, loc_43DA
                cp      0C5h
                jp      z, loc_43E7
                cp      0C3h
                jp      z, loc_43BA
                cp      0C7h
                jp      z, loc_43F7
                inc     de
                jp      loc_425E
loc_4398:
                ld      hl, byte_4436
                call    select_chan_data_byte
                ld      (hl), 1
                ld      a, (current_channel)
                add     a, a
                jr      nz, loc_43A7
                inc     a
loc_43A7:
                ld      b, a
                add     a, a
                add     a, a
                add     a, a
                or      b
                ld      b, a
                ld      a, (byte_4454)
                or      b
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                jp      loc_441C
loc_43BA:
                push    hl
                ld      a, (de)
                ld      l, a
                ld      h, 0
                ld      c, l
                ld      b, h
                add     hl, hl
                add     hl, hl
                add     hl, bc
                add     hl, hl
                ld      bc, (frst_block)
                add     hl, bc
                ld      b, h
                ld      c, l
                ld      hl, byte_443C
                call    select_chan_data_word
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     hl
                inc     de
                jp      loc_425E
loc_43DA:
                push    de
                ld      a, (de)
                ld      e, a
                ld      a, 6
                call    j_WRTPSG
                pop     de
loc_43E3:
                inc     de
                jp      loc_425E
loc_43E7:
                push    de
                ld      a, (de)
                ld      e, a
                ld      a, (byte_4454)
                and     e
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                pop     de
                jr      loc_43E3
loc_43F7:
                ld      a, (byte_445A)
                or      a
                jr      nz, loc_4413
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
loc_4402:
                ld      hl, (scnd_block)
                add     hl, de
                ex      de, hl
                ld      hl, off_4430
                call    select_chan_data_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_4255
loc_4413:
                dec     a
                ld      (byte_445A), a
                inc     de
                inc     de
                jp      loc_43E3
loc_441C:
                ld      hl, byte_4436
                ld      b, 3
loc_4421:
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                djnz    loc_4421
;                pop     hl

                jp      e_o_mus

; ---------------------------------------------------------------------------
current_channel:dw 0
byte_442D:      db 1, 1, 1
off_4430:       dw f_thrdblock
                dw byte_4819
                dw byte_4989
byte_4436:      db 0, 0, 0
byte_4439:      db 0, 0, 0
byte_443C:      db 0, 0, 0, 0, 0, 0
byte_4442:      db 0, 0, 0, 0, 0, 0
byte_4448:      db 0, 0, 0, 0, 0, 0
byte_444E:      db 0, 0, 0
byte_4451:      db 0, 0, 0
byte_4454:      db 0F8h
frst_block:     dw f_frst_blck
scnd_block:     dw f_scnd_blck
byte_4459:      db 2
byte_445A:      db 0
word_445B:      dw 0D5Dh, 0C9Ch, 0BE7h, 0B3Ch, 0A9Bh, 0A02h, 973h, 8EBh, 86Bh, 7F2h, 780h, 714h, 6AFh, 64Eh, 5F4h, 59Eh
                dw 54Eh, 501h, 4BAh, 476h, 436h, 3F9h, 3C0h, 38Ah, 357h, 327h, 2FAh, 2CFh, 2A7h, 281h, 25Dh, 23Bh
                dw 21Bh, 1FDh, 1E0h, 1C5h, 1ACh, 194h, 17Dh, 168h, 153h, 140h, 12Eh, 11Dh, 10Dh, 0FEh, 0F0h, 0E3h
                dw 0D6h, 0CAh, 0BEh, 0B4h, 0AAh, 0A0h, 97h, 8Fh, 87h, 7Fh, 78h, 71h, 6Bh, 65h, 5Fh, 5Ah
                dw 55h, 50h, 4Ch, 47h, 43h, 40h, 3Ch, 39h, 35h, 32h, 30h, 2Dh, 2Ah, 28h, 26h, 24h
                dw 22h, 20h, 1Eh, 1Ch, 1Bh, 19h, 18h, 16h, 15h, 14h, 13h, 12h, 11h, 10h, 0Fh, 0Eh
; =============== S U B R O U T I N E =======================================

ay_init:
                ld      hl, (initial_position)
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                inc     hl
                ld      (frst_block), hl
                dec     hl
                dec     hl
                add     hl, de
                ld      (scnd_block), hl
                ld      hl, byte_442D
                ld      b, 3
loc_4530:
                ld      (hl), 1
                inc     hl
                djnz    loc_4530
                ld      hl, byte_4436
                ld      b, 3
loc_453A:
                ld      (hl), 0
                inc     hl
                djnz    loc_453A
                ld      hl, (scnd_block)
                ld      (loc_454E+1), hl
                ex      de, hl
                ld      hl, off_4430
                ld      (loc_4556+1), hl
                ld      b, 3
loc_454E:
                ld      hl, f_thrdblock
                ld      a, (hl)
                inc     hl
                ld      l, (hl)
                ld      h, a
                add     hl, de
loc_4556:
                ld      (byte_4436), hl
                ld      hl, (loc_454E+1)
                inc     hl
                inc     hl
                ld      (loc_454E+1), hl
                ld      hl, (loc_4556+1)
                inc     hl
                inc     hl
                ld      (loc_4556+1), hl
                djnz    loc_454E
                ld      a, 0F8h
                ld      (byte_4454), a
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                ld      a, 0Dh
                ld      e, 0
                jp      j_WRTPSG
; ---------------------------------------------------------------------------
initial_position:
                dw music0_data
music0_data:    db 0CAh,0
f_frst_blck:    db 2, 4Dh, 0, 0, 0, 1Ah, 0FFh, 0F4h, 7, 7, 5, 0C0h, 0, 0, 0, 53h
                db 0FFh, 0F8h, 0Ch, 0Ch, 2, 4Dh, 0, 0, 0, 32h, 0FFh, 0F4h, 9, 9, 2, 4Dh
                db 0, 0, 0, 2Fh, 0FFh, 0F5h, 0Ah, 0Ah, 2, 4Dh, 0, 0, 0, 2Ch, 0FFh, 0F5h
                db 0Bh, 0Bh, 2, 4Dh, 0, 0, 0, 2Ch, 0FFh, 0F4h, 0Ch, 0Ch, 2, 4Dh, 0, 0
                db 0, 2Ah, 0FFh, 0F5h, 0Dh, 0Dh, 2, 4Dh, 0, 0, 0, 34h, 0FFh, 0F4h, 0Eh, 0Eh
                db 2, 4Dh, 0, 0, 0, 1Ah, 0FFh, 0F5h, 0Fh, 0Fh, 2, 4Dh, 0, 0, 0, 1Ah
                db 0FFh, 0F5h, 0Fh, 0Fh, 0, 0, 0, 0, 0, 8, 0FFh, 0EBh, 0Ah, 0Ah, 0, 0
                db 0FFh, 0CEh, 0, 7Bh, 0FFh, 0F8h, 0Bh, 0Ah, 0, 0, 0FFh, 0D8h, 0, 10h, 0FFh, 0E7h
                db 0Dh, 0Ch, 0, 0, 0, 0, 0, 21h, 0FFh, 0FBh, 7, 7, 0, 0, 0FFh, 0D8h
                db 0, 8, 0FFh, 0F4h, 7, 6, 0, 0, 0FFh, 0E6h, 0, 3, 0FFh, 0F4h, 9, 8
                db 5, 0C0h, 0FFh, 0BEh, 0, 34h, 0FFh, 0F3h, 0Eh, 0Bh, 5, 0C0h, 0FFh, 0CEh, 0, 4Eh
                db 0FFh, 0E0h, 0Fh, 0Ch, 0, 0, 0FFh, 0CEh, 0, 70h, 0FFh, 0ECh, 0Fh, 0Ch, 0, 0
                db 0FFh, 0CFh, 0, 32h, 0FFh, 0E9h, 0Fh, 0Bh
f_scnd_blck:    db 0, 6
                db 1, 0D0h
                db 3, 40h
f_thrdblock:    db 0C5h, 38h, 0C6h, 4, 0C3h, 0Ah, 1Fh, 90h, 26h, 90h, 2Dh, 0F0h, 0, 30h, 1Fh, 90h
                db 24h, 48h, 26h, 90h, 2Eh, 90h, 30h, 48h, 24h, 90h, 1Fh, 90h, 1Ah, 0D8h, 1Ah, 48h
                db 24h, 60h, 2Eh, 60h, 30h, 60h, 28h, 0D8h, 2Dh, 48h, 28h, 6Ch, 2Dh, 0B4h, 26h, 6Ch
                db 29h, 0B4h, 24h, 6Ch, 26h, 0B4h, 26h, 48h, 0C5h, 38h, 0C6h, 4, 0C3h, 4, 2Bh, 18h
                db 0C3h, 3, 2Eh, 18h, 0C3h, 2, 32h, 18h, 0C3h, 4, 35h, 24h, 0C3h, 4, 34h, 0D8h
                db 0C3h, 0Ah, 29h, 0B4h, 0C3h, 5, 37h, 0D8h, 0C3h, 3, 34h, 18h, 0C3h, 4, 37h, 18h
                db 34h, 84h, 0C3h, 0Ah, 32h, 0B4h, 26h, 48h, 0C3h, 4, 2Eh, 18h, 0C3h, 3, 32h, 18h
                db 0C3h, 4, 39h, 18h, 0C3h, 5, 3Ch, 90h, 0C3h, 3, 39h, 12h, 0C3h, 4, 3Ch, 12h
                db 0C3h, 3, 39h, 6Ch, 0C3h, 0Ah, 21h, 30h, 26h, 30h, 28h, 30h, 26h, 90h, 0C3h, 5
                db 35h, 30h, 0C3h, 4, 34h, 18h, 2Fh, 18h, 0C3h, 3, 30h, 18h, 0C3h, 5, 32h, 18h
                db 0C3h, 6, 34h, 30h, 0C3h, 5, 30h, 0A8h, 0C3h, 4, 2Ah, 18h, 2Bh, 18h, 0C3h, 5
                db 2Dh, 18h, 0C3h, 6, 30h, 24h, 0C3h, 4, 2Eh, 24h, 0C3h, 3, 28h, 0D8h, 0C3h, 0Ah
                db 24h, 24h, 21h, 24h, 1Ch, 24h, 1Dh, 24h, 21h, 30h, 1Fh, 30h, 24h, 30h, 0C3h, 7
                db 39h, 0B4h, 37h, 18h, 32h, 18h, 34h, 0A8h, 0, 24h, 37h, 18h, 0, 0Ch, 3Ch, 6Ch
                db 39h, 0B4h, 37h, 18h, 32h, 18h, 34h, 0A8h, 0, 60h, 0, 0Ch, 30h, 2Ah, 2Eh, 1Eh
                db 2Dh, 2Ah, 2Bh, 0A8h, 0, 6, 0C3h, 1, 29h, 48h, 24h, 24h, 2Bh, 0B4h, 2Bh, 24h
                db 24h, 24h, 26h, 24h, 2Dh, 0B4h, 2Dh, 48h, 28h, 24h, 2Eh, 0B4h, 2Eh, 48h, 29h, 24h
                db 30h, 0B4h, 30h, 48h, 2Bh, 24h, 32h, 0B4h, 32h, 48h, 2Dh, 24h, 34h, 0F0h, 0, 0Ch
                db 28h, 0D8h, 0C3h, 0Ah, 0C5h, 38h, 0C6h, 4, 0C3h, 0Dh, 28h, 0D8h, 0, 30h, 0, 18h
                db 0C5h, 38h, 0C6h, 4, 0C3h, 3, 34h, 18h, 0C3h, 4, 35h, 18h, 0C3h, 5, 3Ah, 18h
                db 0C3h, 6, 39h, 90h, 34h, 30h, 0C3h, 4, 32h, 24h, 0C3h, 6, 35h, 30h, 2Dh, 0B4h
                db 0, 60h, 0, 18h, 0C3h, 6, 3Ch, 30h, 0C3h, 5, 3Ah, 18h, 0C3h, 3, 35h, 18h
                db 0C3h, 4, 31h, 18h, 2Dh, 18h, 0C3h, 5, 2Eh, 24h, 0C3h, 6, 39h, 6Ch, 37h, 30h
                db 0C3h, 5, 35h, 18h, 0C3h, 4, 34h, 18h, 0C3h, 2, 31h, 18h, 0C3h, 5, 32h, 18h
                db 0C3h, 6, 35h, 30h, 0C3h, 5, 2Dh, 48h, 0, 18h, 0, 48h, 0C3h, 2, 2Bh, 18h
                db 0C3h, 4, 2Dh, 18h, 0C3h, 5, 32h, 18h, 0C3h, 7, 37h, 2Ah, 0C3h, 5, 34h, 1Eh
                db 0C3h, 7, 37h, 30h, 0C3h, 6, 35h, 78h, 0, 30h, 0, 30h, 0, 30h, 0, 30h
                db 0C3h, 7, 37h, 0C0h, 0, 60h, 0C3h, 6, 34h, 0C0h, 0, 60h, 0C3h, 0Bh, 37h, 0F0h
                db 0C3h, 0Dh, 37h, 0C0h, 0, 60h, 0, 30h, 0FFh, 0FFh
byte_4819:      db 0C5h, 38h, 0C6h, 4, 0C3h, 0Ah, 0, 3, 1Ah, 90h, 21h, 90h, 28h, 0F0h, 0, 30h
                db 24h, 90h, 28h, 0C0h, 2Bh, 30h, 2Dh, 30h, 28h, 90h, 2Bh, 90h, 26h, 90h, 21h, 0D8h
                db 2Bh, 78h, 2Dh, 60h, 2Bh, 60h, 32h, 60h, 2Dh, 0F0h, 2Dh, 6Ch, 30h, 0B4h, 2Bh, 6Ch
                db 2Eh, 0B4h, 29h, 6Ch, 2Dh, 0B4h, 1Fh, 90h, 26h, 90h, 2Dh, 6Ch, 2Dh, 0B4h, 1Fh, 90h
                db 26h, 90h, 30h, 6Ch, 29h, 0B4h, 1Fh, 90h, 26h, 90h, 2Dh, 0F0h, 0, 30h, 1Fh, 90h
                db 26h, 90h, 32h, 6Ch, 37h, 0B4h, 1Fh, 90h, 26h, 90h, 2Dh, 66h, 30h, 0B4h, 0C3h, 0Ah
                db 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h, 24h, 24h, 13h, 24h, 0Eh, 24h, 15h, 24h
                db 18h, 48h, 15h, 24h, 16h, 24h, 15h, 6Ch, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h
                db 1Fh, 24h, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h, 15h, 24h, 16h, 24h, 15h, 6Ch
                db 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h, 24h, 24h, 13h, 24h, 0Eh, 24h, 15h, 24h
                db 18h, 48h, 15h, 24h, 16h, 24h, 15h, 6Ch, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h
                db 21h, 24h, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h, 15h, 24h, 16h, 24h, 15h, 6Ch
                db 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h, 24h, 24h, 15h, 24h, 10h, 24h, 16h, 24h
                db 1Ch, 60h, 0, 0Ch, 16h, 24h, 11h, 24h, 18h, 24h, 1Dh, 24h, 18h, 24h, 13h, 24h
                db 1Ah, 24h, 1Fh, 0B4h, 0C3h, 0Bh, 1Fh, 0D8h, 0C3h, 0Dh, 1Fh, 0D8h, 0, 30h, 0, 30h
                db 0, 30h, 0C5h, 38h, 0C6h, 4, 0C3h, 0Ch, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 30h
                db 0, 30h, 0, 0Ch, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h, 15h, 24h, 16h, 24h
                db 15h, 6Ch, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 30h, 0, 30h, 0, 0Ch, 13h, 24h
                db 0Eh, 24h, 15h, 24h, 18h, 48h, 15h, 24h, 16h, 24h, 15h, 6Ch, 13h, 24h, 0Eh, 24h
                db 15h, 24h, 18h, 30h, 0, 30h, 0, 0Ch, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h
                db 15h, 24h, 16h, 24h, 15h, 6Ch, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 30h, 0, 30h
                db 0, 0Ch, 13h, 24h, 0Eh, 24h, 15h, 24h, 18h, 48h, 15h, 24h, 16h, 24h, 15h, 6Ch
                db 0C5h, 38h, 0C6h, 4, 0C3h, 0Bh, 13h, 0F0h, 0C3h, 0Dh, 13h, 0C0h, 0, 90h, 0FFh, 0FFh
byte_4989:      db 0C5h, 38h, 0C6h, 4, 0C3h, 0Dh, 0C5h, 38h, 0C6h, 4, 0C3h, 0, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Dh, 24h, 18h, 24h
                db 13h, 24h, 1Fh, 24h, 18h, 24h, 13h, 24h, 1Dh, 24h, 18h, 24h, 1Dh, 24h, 18h, 24h
                db 13h, 24h, 1Fh, 24h, 18h, 24h, 13h, 24h, 1Dh, 24h, 18h, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Dh, 24h, 18h, 24h
                db 13h, 24h, 1Fh, 24h, 18h, 24h, 13h, 24h, 1Dh, 24h, 18h, 24h, 1Dh, 24h, 18h, 24h
                db 13h, 24h, 1Fh, 24h, 18h, 24h, 13h, 24h, 1Dh, 24h, 18h, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Dh, 24h, 18h, 24h
                db 13h, 24h, 1Fh, 24h, 18h, 24h, 13h, 24h, 1Dh, 24h, 18h, 24h, 1Dh, 24h, 18h, 24h
                db 13h, 24h, 1Fh, 24h, 18h, 24h, 13h, 24h, 1Dh, 24h, 18h, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Dh, 24h, 18h, 24h
                db 13h, 24h, 1Fh, 24h, 18h, 24h, 13h, 24h, 1Dh, 24h, 18h, 24h, 1Dh, 24h, 18h, 24h
                db 13h, 24h, 1Fh, 24h, 18h, 24h, 13h, 24h, 1Dh, 24h, 18h, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 1Fh, 24h, 1Ah, 24h
                db 15h, 24h, 21h, 24h, 1Ah, 24h, 15h, 24h, 1Fh, 24h, 1Ah, 24h, 0C5h, 38h, 0C3h, 0
                db 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h, 21h, 12h, 18h, 12h, 2Dh, 12h, 24h, 12h
                db 21h, 12h, 18h, 12h, 26h, 12h, 1Ch, 12h, 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h
                db 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h, 21h, 12h, 18h, 12h, 2Dh, 12h, 24h, 12h
                db 21h, 12h, 18h, 12h, 26h, 12h, 1Ch, 12h, 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h
                db 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h, 21h, 12h, 18h, 12h, 2Dh, 12h, 24h, 12h
                db 21h, 12h, 18h, 12h, 26h, 12h, 1Ch, 12h, 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h
                db 0C5h, 38h, 0C6h, 4, 0C3h, 2, 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h, 21h, 12h
                db 18h, 12h, 2Dh, 12h, 24h, 12h, 21h, 12h, 18h, 12h, 26h, 12h, 1Ch, 12h, 2Bh, 12h
                db 21h, 12h, 26h, 12h, 1Ch, 12h, 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h, 21h, 12h
                db 18h, 12h, 2Dh, 12h, 24h, 12h, 21h, 12h, 18h, 12h, 26h, 12h, 1Ch, 12h, 2Bh, 12h
                db 21h, 12h, 26h, 12h, 1Ch, 12h, 0C5h, 38h, 0C6h, 4, 0C3h, 3, 2Bh, 12h, 21h, 12h
                db 26h, 12h, 1Ch, 12h, 21h, 12h, 18h, 12h, 2Dh, 12h, 24h, 12h, 21h, 12h, 18h, 12h
                db 26h, 12h, 1Ch, 12h, 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h, 0C5h, 38h, 0C6h, 4
                db 0C3h, 4, 2Bh, 12h, 21h, 12h, 26h, 12h, 1Ch, 12h, 21h, 12h, 18h, 12h, 2Dh, 12h
                db 24h, 12h, 21h, 12h, 18h, 12h, 26h, 12h, 1Ch, 12h, 2Bh, 12h, 21h, 12h, 26h, 12h
                db 1Ch, 12h, 0C5h, 18h, 0C6h, 1, 0C3h, 0Bh, 1Fh, 0D8h, 0C3h, 0Dh, 1Fh, 0D8h, 0, 48h
                db 0C5h, 38h, 0C6h, 4, 0C3h, 2, 2Bh, 24h, 26h, 24h, 0C5h, 38h, 0C6h, 4, 0C3h, 0Ah
                db 2Bh, 24h, 26h, 24h, 21h, 24h, 2Dh, 24h, 26h, 24h, 21h, 24h, 2Bh, 24h, 26h, 24h
                db 2Bh, 24h, 26h, 24h, 21h, 24h, 2Dh, 24h, 26h, 24h, 21h, 24h, 2Bh, 24h, 26h, 24h
                db 2Bh, 24h, 26h, 24h, 21h, 24h, 2Dh, 24h, 26h, 24h, 21h, 24h, 2Bh, 24h, 26h, 24h
                db 2Bh, 24h, 26h, 24h, 21h, 24h, 2Dh, 24h, 26h, 24h, 21h, 24h, 2Bh, 24h, 26h, 24h
                db 2Bh, 24h, 26h, 24h, 21h, 24h, 2Dh, 24h, 26h, 24h, 21h, 24h, 2Bh, 24h, 26h, 24h
                db 2Bh, 24h, 26h, 24h, 21h, 24h, 2Dh, 24h, 26h, 24h, 21h, 24h, 2Bh, 24h, 26h, 24h
                db 2Bh, 24h, 26h, 24h, 21h, 24h, 2Dh, 24h, 26h, 24h, 21h, 24h, 2Bh, 24h, 26h, 24h
                db 2Bh, 24h, 26h, 24h, 21h, 24h, 2Dh, 24h, 26h, 24h, 21h, 24h, 2Bh, 24h, 26h, 24h
                db 0C5h, 38h, 0C6h, 4, 0C3h, 0Bh, 1Fh, 0F0h, 0C3h, 0Dh, 1Fh, 0C0h, 0, 90h, 0FFh, 0FFh







	       ENT
ay_end:


                savebin "jb2manreq/ay_plr1.bin",ay_begin,ay_end-ay_begin
                ENDMODULE