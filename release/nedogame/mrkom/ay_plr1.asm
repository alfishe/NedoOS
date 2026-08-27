                MODULE AY_PLR1             
PLR_START= 0x4000
ay_begin:
                DISP PLR_START
                jr init_
                jp PLR_PLAY
                jp mute
is_music_ended  db 0

;tbl_music       
;                db 0xdb
;                dw music1_data







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
    
speed_loop    dec b
        jp z,speed_loop_exit
        push bc
        
        
            call player
        
        pop bc
        jp speed_loop
        
speed_loop_exit
        ret



player:
				ret
                ld      hl, unk_4396
                ld      a, (hl)
loc_40F7:
                ld      (off_4393), hl
                ld      b, a
loc_40FB:
                push    bc
                xor     a
loc_40FD:
                ld      (current_channel), a
                call    play_ay
                ld      a, (current_channel)
                inc     a
                cp      3
                jr      nz, loc_40FD
                pop     bc
                djnz    loc_40FB
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
                ld      hl, byte_4367
                call    select_chan_data_byte
                dec     (hl)
                jp      nz, loc_41AD

loc_4140:
                xor     a
                ld      (byte_43A2), a
                ld      hl, off_436A
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)

loc_414D:
                ld      a, (de)
                inc     de
                cp      61h ; 'a'
                jp      nc, loc_4299
                push    hl
                push    af
                ld      hl, byte_4367
                call    select_chan_data_byte
                ld      a, (de)
                ld      (hl), a
                inc     de
                pop     af
                pop     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      hl, unk_4373
                call    select_chan_data_byte
                ld      (hl), a
                or      a
                jr      z, loc_41AD
                add     a, 0F4h
                add     a, a
                ld      e, a
                ld      d, 0
                ld      hl, word_43A8
                add     hl, de
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, unk_43A4
                call    select_chan_data_word
                ld      a, (hl)
                inc     hl
                ld      l, (hl)
                ld      h, a
                add     hl, de
                ex      de, hl
                ld      a, (current_channel)
                add     a, a
                call    j_WRTPSG
                inc     a
                ld      e, d
                call    j_WRTPSG
                ld      a, (byte_43A2)
                or      a
                jr      nz, loc_41AD
                ld      hl, unk_438B
                call    select_chan_data_byte
                xor     a
                ld      (hl), a
                call    sub_421F
                ld      hl, word_437C
                call    select_chan_data_word
                ld      (hl), a
                inc     hl
                ld      (hl), a

loc_41AD:
                ld      a, (byte_43A3)
                or      a
                ld      hl, unk_4373
                call    select_chan_data_byte
                ld      a, (hl)
                or      a
                jr      z, loc_4200
                ld      hl, unk_438B
                call    select_chan_data_byte
                ld      a, (hl)
                dec     a
                jr      z, loc_41D1
                dec     a
                jr      z, loc_41DA
                dec     a
                jr      z, loc_41E4
                dec     a
                jr      z, loc_41F8
                xor     a
                jr      loc_4200
; ---------------------------------------------------------------------------

loc_41D1:
                xor     a
                ld      (loc_4275), a
                call    sub_4252
                jr      loc_4200
; ---------------------------------------------------------------------------

loc_41DA:
                ld      a, 3Fh ; '?'
                ld      (loc_4275), a
                call    sub_4252
                jr      loc_4200
; ---------------------------------------------------------------------------

loc_41E4:
                ld      hl, word_4382
                call    select_chan_data_word
                dec     (hl)
                ret     nz
                call    sub_421F
                ld      hl, unk_4388
                call    select_chan_data_byte
                ld      (hl), 0
                ret
; ---------------------------------------------------------------------------

loc_41F8:
                ld      a, 3Fh ; '?'
                ld      (loc_4275), a
                call    sub_4252

loc_4200:
                push    af
                ld      a, (byte_43A3)
                or      a
                jr      nz, loc_4215
                pop     af
                push    hl
                or      a
                rra
                ld      h, a
                or      a
                rra
                or      a
                ld      l, a
                rra
                add     a, h
                add     a, l
                pop     hl
                push    af

loc_4215:
                pop     af
                ld      e, a
                ld      a, (current_channel)
                add     a, 8
                jp      j_WRTPSG

sub_421F:
                ld      hl, word_4376
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, unk_438B
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
                ld      hl, unk_4388
                call    select_chan_data_byte
                ld      (hl), b
                pop     hl
                add     hl, hl
                add     hl, de
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, word_4382
                call    select_chan_data_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                pop     hl
                inc     (hl)
                ret

sub_4252:
                ld      hl, word_4382
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      a, d
                or      e
                jr      z, loc_4282
                ld      hl, word_437C

sub_4262:
                call    select_chan_data_word
                ld      c, (hl)
                inc     hl
                ld      b, (hl)
                ex      de, hl
                add     hl, bc
                ex      de, hl
                push    hl
                ld      hl, unk_4388
                call    select_chan_data_byte
                ld      a, d
                cp      (hl)
                pop     hl

loc_4275:
                nop
                jr      nc, loc_4282
                cp      10h
                jr      c, loc_427E
                xor     a
                ret

loc_427E:
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ret

loc_4282:
                ld      hl, unk_4388
                call    select_chan_data_byte
                ld      a, (hl)
                push    af
                call    sub_421F
                ld      hl, word_437C
                call    select_chan_data_word
                pop     af
                ld      (hl), 0
                inc     hl
                ld      (hl), a
                ret


loc_4299:
                cp      0FFh
                jp      z, loc_42B1
                cp      0C0h
                jp      z, loc_42DE
                cp      0C8h
                jp      z, loc_42D5
                cp      0C7h
                jp      z, loc_432C
                inc     de
                jp      loc_414D

loc_42B1:
                ld      hl, word_4370
                call    select_chan_data_byte
                ld      (hl), 1
                ld      a, (current_channel)
                add     a, a
                jr      nz, loc_42C0
                inc     a

loc_42C0:
                ld      b, a
                add     a, a
                add     a, a
                add     a, a
                or      b
                ld      b, a
                ld      a, (byte_438E)
                or      b
                and     0BFh
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                jp      loc_4356

loc_42D5:
                ld      a, 1
                ld      (byte_43A2), a
                inc     de
                jp      loc_414D

loc_42DE:
                push    hl
                push    de
                ld      a, (de)
                ld      e, a
                ld      d, 0
                ld      hl, byte_446A
                add     hl, de
                pop     de
                inc     de
                ld      a, (hl)
                and     0F0h
                rrca
                rrca
                rrca
                rrca
                ld      l, a
                ld      h, 0
                ld      c, l
                ld      b, h
                add     hl, hl
                add     hl, hl
                add     hl, bc
                add     hl, hl
                ld      bc, byte_448A
                add     hl, bc
                ld      b, h
                ld      c, l
                ld      hl, word_4376
                call    select_chan_data_word
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     hl
                jp      loc_414D

                push    de
                ld      a, (de)
                ld      e, a
                ld      a, 6
                call    j_WRTPSG
                pop     de

loc_4316:
                inc     de
                jp      loc_414D

                push    de
                ld      a, (de)
                ld      e, a
                ld      a, (byte_438E)
                and     e
                or      80h
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                pop     de
                jr      loc_4316


loc_432C:
                ld      a, 1
                ld      (word_43A0+1), a
                ld      a, (word_43A0)
                or      a
                jr      loc_434D

                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (off_4391)
                add     hl, de
                ex      de, hl
                ld      hl, off_436A
                call    select_chan_data_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_4140


loc_434D:
                dec     a
                ld      (word_43A0), a
                inc     de
                inc     de
                jp      loc_4316


loc_4356:
                ld      hl, word_4370
                ld      b, 3

loc_435B:
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                djnz    loc_435B
;                pop     hl
                jp      e_o_mus

; ---------------------------------------------------------------------------
current_channel:dw 0 

byte_4367:      db 1, 1, 1

off_436A:       dw byte_4FF7
                dw byte_50BD
                dw byte_53FD
word_4370:      db    0,0,0
unk_4373:       db    0,0,0

word_4376:      dw 0
                dw 0
                dw 0

word_437C:      dw 0
                dw 0
                dw 0

word_4382:      dw 0
                dw 0
                dw 0

unk_4388:       db    0,0,0
unk_438B:       db    0,0,0
byte_438E:      db 0B8h,0,0

off_4391:       dw unk_4FEB
off_4393:       dw _unk_4395
_unk_4395:      db    1 
unk_4396:       db    2
                db    1
                db    2
                db    0
unk_439A:       db    0
                db    0
                db    1
                db    0
                db    3
                db    0
word_43A0:      dw 0
byte_43A2:      db 0
byte_43A3:      db 1
unk_43A4:       db    0
                db    0
                db    0
                db    0
word_43A8:      dw 100h
                dw 0D5Dh
                dw 0C9Ch
                dw 0BE7h
                dw 0B3Ch
                dw 0A9Bh
                dw 0A02h
                dw 973h
                dw 8EBh
                dw 86Bh
                dw 7F2h
                dw 780h
                dw 714h
                dw 6AFh
                dw 64Eh
                dw 5F4h
                dw 59Eh
                dw 54Eh
                dw 501h
                dw 4BAh
                dw 476h
                dw 436h
                dw 3F9h
                dw 3C0h
                dw 38Ah
                dw 357h
                dw 327h
                dw 2FAh
                dw 2CFh
                dw 2A7h
                dw 281h
                dw 25Dh
                dw 23Bh
                dw 21Bh
                dw 1FDh
                dw 1E0h
                dw 1C5h
                dw 1ACh
                dw 194h
                dw 17Dh
                dw 168h
                dw 153h
                dw 140h
                dw 12Eh
                dw 11Dh
                dw 10Dh
                dw 0FEh
                dw 0F0h
                dw 0E3h
                dw 0D6h
                dw 0CAh
                dw 0BEh
                dw 0B4h
                dw 0AAh
                dw 0A0h
                dw 97h
                dw 8Fh
                dw 87h
                dw 7Fh
                dw 78h
                dw 71h
                dw 6Bh
                dw 65h
                dw 5Fh
                dw 5Ah
                dw 55h
                dw 50h
                dw 4Ch
                dw 47h
                dw 43h
                dw 40h
                dw 3Ch
                dw 39h
                dw 35h
                dw 32h
                dw 30h
                dw 2Dh
                dw 2Ah
word_4444:      dw 28h
                dw 26h
                dw 24h
                dw 22h
                dw 20h
                dw 1Eh
                dw 1Ch
                dw 1Bh
                dw 19h
                dw 18h
                dw 16h
                dw 15h
                dw 14h
                dw 13h
                dw 12h
                dw 11h
                dw 10h
                dw 0Fh
                dw 0Eh
byte_446A:      db 0B4h, 34h, 0C4h, 24h, 44h, 14h, 94h, 34h, 0E4h, 0F4h, 14h, 74h, 14h, 94h, 14h, 14h
                db 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 0A4h, 14h, 28h, 21h, 30h, 0A4h, 0A4h
byte_448A:      db 2, 80h, 0, 0, 0, 18h, 0FFh, 0F4h, 7, 7
                db 0, 2Dh, 0, 0, 0, 52h, 0FFh, 0F7h, 0Ch, 0Ch
                db 0, 0, 0, 0, 0, 2Ah, 0FFh, 0E3h, 0Ah, 0Ah
                db 0, 0, 0FFh, 0E2h, 0, 16h, 0FFh, 0EDh, 0Dh
                db 0Ch, 2, 15h, 0FFh, 0E7h, 0, 56h, 0FFh, 0F4h, 0Dh
                db 0Ch, 2, 80h, 0, 0, 0, 29h, 0FFh, 0F4h, 0Ch
                db 0Ch, 3, 20h, 0FFh, 0D4h, 0, 54h, 0FFh, 0FAh, 0Fh
                db 0Ch, 2, 80h, 0, 0, 0, 22h, 0FFh, 0F4h, 0Dh
                db 0Dh, 4, 2Bh, 0, 0, 0, 82h, 0FFh, 0F4h, 0Ch
                db 0Ch, 0Ch, 80h, 0, 0, 0, 4Dh, 0FFh, 0F6h, 0Ch
                db 0Ch, 0, 0, 0FFh, 0B8h, 0, 0Eh, 0FFh, 0E7h, 0Dh
                db 0Bh, 0, 0, 0FEh, 0F4h, 0, 0Eh, 0FFh, 0E5h, 0Dh
                db 0Ch, 0, 0, 0FFh, 0D4h, 0, 5, 0FFh, 0E3h, 0Dh
                db 0Bh, 0, 0, 0FFh, 0D4h, 0, 7, 0FFh, 0F7h, 0Eh
                db 0Bh, 0, 0, 0FFh, 0E4h, 0, 13h, 0FFh, 0F3h, 0Fh
                db 0Dh, 6, 40h, 0FFh, 0B8h, 0, 1Ch, 0FFh, 0F2h, 0Fh
                db 0Dh

; =============== S U B R O U T I N E =======================================

ay_init:
sub_452A:
                ld      hl, (word_458A)
                ld      (off_4391), hl
                ld      hl, byte_4367
                ld      b, 3

loc_4535:
                ld      (hl), 1
                inc     hl
                djnz    loc_4535
                ld      hl, word_4370
                ld      b, 3

loc_453F:
                ld      (hl), 0
                inc     hl
                djnz    loc_453F
                ld      hl, off_436A
                ld      (loc_4562+1), hl
                ld      hl, unk_439A
                ld      (loc_4557+1), hl
                ld      b, 3

loc_4552:
                push    bc
                ld      bc, (word_458A)

loc_4557:
                ld      hl, (word_43A0)
                sla     l
                add     hl, bc
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ex      de, hl
                add     hl, bc

loc_4562:
                ld      (word_4370), hl
                ld      hl, (loc_4557+1)
                inc     hl
                inc     hl
                ld      (loc_4557+1), hl
                ld      hl, (loc_4562+1)
                inc     hl
                inc     hl
                ld      (loc_4562+1), hl
                pop     bc
                djnz    loc_4552
                ld      a, 0B8h
                ld      (byte_438E), a

                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                ld      a, 0Dh
                ld      e, 0
                jp      j_WRTPSG
; ---------------------------------------------------------------------------
word_458A:      dw unk_4FEB

unk_4FEB:       db    0
                db  0Ch
                db    0
                db 0D2h
                db    2
                db    2
                db    4
                db  12h
                db    4
                db 0C8h
                db    5
                db  7Eh ; 




byte_4FF7:      db 0C4h, 0E0h, 0C0h, 7, 29h, 90h, 2Dh, 90h, 32h, 0C0h, 0C8h, 0, 32h, 18h, 0, 18h
                db 0C0h, 5, 39h, 0C0h, 0C8h, 0, 39h, 30h, 0C0h, 0Dh, 31h, 90h, 32h, 90h, 35h, 90h
                db 39h, 90h, 31h, 90h, 32h, 90h, 35h, 90h, 2Dh, 90h, 0C0h, 4, 4Ch, 90h, 4Ah, 90h
                db 45h, 90h, 47h, 90h, 43h, 90h, 3Eh, 90h, 40h, 60h, 0C8h, 0, 40h, 0Ch, 48h, 18h
                db 4Ch, 0Ch, 4Dh, 18h, 4Fh, 0Ch, 51h, 18h, 4Fh, 0Ch, 52h, 0Ch, 54h, 0Ch, 52h, 0Ch
                db 51h, 18h, 4Dh, 0Ch, 0C8h, 0, 4Dh, 90h, 4Fh, 90h, 53h, 48h, 54h, 18h, 56h, 18h
                db 58h, 18h, 5Bh, 90h, 56h, 48h, 54h, 48h, 53h, 90h, 4Fh, 90h, 0C0h, 0Bh, 39h, 48h
                db 2Bh, 18h, 2Dh, 0Ch, 2Ah, 0Ch, 2Fh, 0Ch, 32h, 0Ch, 36h, 24h, 37h, 18h, 34h, 30h
                db 0C8h, 0, 34h, 12h, 36h, 12h, 32h, 18h, 2Dh, 0Ch, 2Bh, 18h, 28h, 0Ch, 26h, 18h
                db 2Bh, 0Ch, 34h, 60h, 0C8h, 0, 34h, 18h, 0, 6, 37h, 12h, 39h, 0Ch, 3Ch, 0Ch
                db 3Eh, 0Ch, 40h, 24h, 40h, 24h, 3Ch, 18h, 37h, 0Ch, 36h, 24h, 35h, 24h, 33h, 24h
                db 30h, 18h, 2Ah, 0Ch, 29h, 18h, 2Bh, 60h, 0C8h, 0, 2Bh, 0Ch, 29h, 18h, 28h, 18h
                db 26h, 90h, 23h, 0C0h, 0FFh, 0FFh

byte_50BD:      db 0C0h, 7, 2Fh, 48h, 32h, 48h, 35h, 48h, 37h, 48h, 39h, 0C0h, 0C8h, 0, 39h, 30h
                db 0, 30h, 0C0h, 5, 34h, 0C0h, 0C0h, 9, 15h, 48h, 1Ch, 30h, 0C8h, 0, 1Ch, 0Ch
                db 15h, 0Ch, 0, 18h, 15h, 30h, 1Ch, 48h, 15h, 48h, 1Ch, 30h, 0C8h, 0, 1Ch, 0Ch
                db 15h, 0Ch, 0, 18h, 15h, 0Ch, 0, 18h, 15h, 0Ch, 1Ch, 24h, 15h, 24h, 15h, 48h
                db 1Ch, 30h, 0C8h, 0, 1Ch, 0Ch, 15h, 0Ch, 0, 18h, 15h, 30h, 1Ch, 48h, 15h, 48h
                db 1Ch, 30h, 0C8h, 0, 1Ch, 0Ch, 15h, 0Ch, 0C0h, 9, 1Ch, 18h, 15h, 24h, 15h, 24h
                db 15h, 0Ch, 18h, 24h, 15h, 48h, 1Ch, 30h, 0C8h, 0, 1Ch, 0Ch, 15h, 0Ch, 0, 18h
                db 15h, 30h, 1Ch, 48h, 15h, 48h, 1Ch, 30h, 0C8h, 0, 1Ch, 0Ch, 15h, 0Ch, 0, 18h
                db 15h, 0Ch, 0, 18h, 15h, 0Ch, 1Ch, 24h, 15h, 24h, 15h, 48h, 1Ch, 30h, 0C8h, 0
                db 1Ch, 0Ch, 15h, 0Ch, 0, 18h, 15h, 30h, 1Ch, 48h, 15h, 48h, 1Ch, 30h, 0C8h, 0
                db 1Ch, 0Ch, 15h, 0Ch, 0C0h, 9, 1Ch, 18h, 15h, 24h, 15h, 24h, 15h, 0Ch, 18h, 24h
                db 0C0h, 1Bh, 1Ch, 48h, 0C0h, 0Dh, 3Bh, 90h, 3Eh, 90h, 43h, 48h, 0C0h, 9, 18h, 48h
                db 1Fh, 30h, 0C8h, 0, 1Fh, 0Ch, 18h, 0Ch, 1Dh, 18h, 18h, 30h, 1Ch, 48h, 18h, 48h
                db 1Fh, 30h, 0C8h, 0, 1Fh, 0Ch, 18h, 0Ch, 21h, 18h, 18h, 24h, 18h, 24h, 18h, 0Ch
                db 1Ch, 24h, 18h, 48h, 1Fh, 30h, 0C8h, 0, 1Fh, 0Ch, 18h, 0Ch, 1Dh, 18h, 18h, 30h
                db 1Ch, 48h, 18h, 48h, 1Fh, 30h, 0C8h, 0, 1Fh, 0Ch, 18h, 0Ch, 0, 18h, 18h, 0Ch
                db 0, 18h, 18h, 0Ch, 21h, 24h, 1Ch, 24h, 18h, 48h, 1Fh, 30h, 0C8h, 0, 1Fh, 0Ch
                db 18h, 0Ch, 1Dh, 18h, 18h, 30h, 1Ch, 48h, 18h, 48h, 1Fh, 30h, 0C8h, 0, 1Fh, 0Ch
                db 18h, 0Ch, 21h, 18h, 18h, 24h, 18h, 24h, 18h, 0Ch, 1Ch, 24h, 17h, 0C0h, 0FFh, 0FFh
                db 0C0h, 7, 31h, 48h, 35h, 48h, 39h, 48h, 3Dh, 48h, 3Eh, 0C0h, 0C8h, 0, 3Eh, 30h
                db 0, 60h, 0C0h, 5, 3Ch, 90h, 0C0h, 7, 31h, 90h, 0C8h, 0, 30h, 48h, 0C0h, 0Dh
                db 32h, 48h, 0C8h, 0, 32h, 48h, 35h, 90h, 39h, 48h, 0C8h, 0, 39h, 48h, 31h, 90h
                db 32h, 48h, 0C8h, 0, 32h, 60h, 18h, 0Ch, 18h, 18h, 0C0h, 10h, 21h, 0Ch, 0C0h, 1Bh
                db 37h, 18h, 37h, 24h, 0C0h, 1Dh, 23h, 24h, 23h, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Dh
                db 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch
                db 1Dh, 18h, 0C0h, 1Dh, 23h, 0Ch, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch
                db 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Dh, 23h, 18h, 0C0h, 1Ch
                db 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 0C0h, 1Dh
                db 23h, 0Ch, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h
                db 0C0h, 1Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Dh, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h
                db 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 0C0h, 1Dh, 23h, 0Ch, 23h, 18h
                db 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h
                db 1Dh, 0Ch, 0C0h, 1Dh, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh
                db 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 0C0h, 10h, 21h, 0Ch, 0C0h, 1Bh, 37h, 18h, 37h, 24h
                db 0C0h, 1Dh, 23h, 24h, 23h, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 0Dh, 34h, 90h, 37h, 90h
                db 3Bh, 48h, 40h, 18h, 43h, 18h, 47h, 18h, 0C0h, 1Dh, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch
                db 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 0C0h, 1Dh, 23h, 0Ch
                db 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch
                db 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Dh, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch
                db 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 0C0h, 10h, 21h, 0Ch, 0C0h, 1Bh, 37h, 18h
                db 37h, 24h, 0C0h, 1Dh, 23h, 24h, 23h, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Dh, 23h, 18h
                db 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h
                db 0C0h, 1Dh, 23h, 0Ch, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh
                db 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Dh, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch
                db 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 0C0h, 1Dh, 23h, 0Ch
                db 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch
                db 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Dh, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch
                db 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 0C0h, 1Dh, 23h, 0Ch, 23h, 18h, 0C0h, 1Ch
                db 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h, 0C0h, 1Ch, 1Dh, 18h, 1Dh, 0Ch
                db 0C0h, 1Dh, 23h, 18h, 0C0h, 1Ch, 1Dh, 0Ch, 1Dh, 18h, 1Dh, 0Ch, 0C0h, 1Bh, 34h, 24h
                db 0C0h, 1Ch, 1Dh, 18h, 0C0h, 10h, 21h, 0Ch, 0C0h, 1Bh, 37h, 18h, 37h, 24h, 0C0h, 1Dh
                db 23h, 24h, 23h, 0Ch, 0C0h, 1Bh, 34h, 24h, 34h, 90h, 0C8h, 0, 34h, 30h, 0FFh, 0FFh

byte_53FD:      db 0C0h, 7, 31h, 48h, 35h, 48h, 39h, 48h, 3Dh, 48h, 3Eh, 0F0h, 0, 30h, 0, 30h
                db 0C0h, 5, 3Ch, 90h, 0C0h, 7, 31h, 0D8h, 0, 48h, 0, 0F0h, 0, 0F0h, 0, 0F6h
                db 0C0h, 2, 5Dh, 90h, 0C0h, 6, 34h, 90h, 32h, 90h, 2Dh, 90h, 2Fh, 90h, 2Bh, 90h
                db 26h, 90h, 28h, 60h, 0, 0Ch, 30h, 18h, 34h, 0Ch, 35h, 18h, 37h, 0Ch, 39h, 18h
                db 37h, 0Ch, 3Ah, 0Ch, 3Ch, 0Ch, 3Ah, 0Ch, 39h, 18h, 35h, 0Ch, 0C8h, 0, 35h, 90h
                db 37h, 90h, 3Bh, 90h, 43h, 90h, 3Eh, 48h, 3Ch, 48h, 3Bh, 90h, 37h, 90h, 39h, 48h
                db 2Bh, 18h, 2Dh, 0Ch, 2Ah, 0Ch, 2Fh, 0Ch, 32h, 0Ch, 36h, 24h, 37h, 18h, 34h, 30h
                db 0C8h, 0, 34h, 12h, 36h, 12h, 32h, 18h, 2Dh, 0Ch, 2Bh, 18h, 28h, 0Ch, 26h, 18h
                db 2Bh, 0Ch, 34h, 60h, 0C8h, 0, 34h, 18h, 0, 6, 37h, 12h, 39h, 0Ch, 3Ch, 0Ch
                db 3Eh, 0Ch, 40h, 24h, 40h, 24h, 3Ch, 18h, 37h, 0Ch, 36h, 24h, 35h, 24h, 33h, 24h
                db 30h, 18h, 2Ah, 0Ch, 29h, 18h, 2Bh, 60h, 0C8h, 0, 2Bh, 0Ch, 29h, 18h, 28h, 18h
                db 26h, 90h, 23h, 0C0h, 0FFh, 0FFh, 0, 12h, 0, 90h, 0, 90h, 0, 90h, 0, 90h
                db 0, 0C0h, 0, 90h, 0, 90h, 0, 90h, 0, 90h, 0, 90h, 0, 48h, 0, 24h
                db 0, 48h, 0, 24h, 0, 48h, 0C0h, 2, 5Fh, 90h, 0C0h, 6, 34h, 90h, 32h, 90h
                db 2Dh, 90h, 2Fh, 90h, 2Bh, 90h, 26h, 90h, 28h, 60h, 0, 0Ch, 30h, 18h, 34h, 0Ch
                db 35h, 18h, 37h, 0Ch, 39h, 18h, 37h, 0Ch, 3Ah, 0Ch, 3Ch, 0Ch, 3Ah, 0Ch, 39h, 18h
                db 35h, 0Ch, 0C8h, 0, 35h, 90h, 37h, 90h, 3Bh, 90h, 43h, 90h, 3Eh, 48h, 3Ch, 48h
                db 3Bh, 90h, 37h, 90h, 39h, 48h, 2Bh, 18h, 2Dh, 0Ch, 2Ah, 0Ch, 2Fh, 0Ch, 32h, 0Ch
                db 36h, 24h, 37h, 18h, 34h, 30h, 0C8h, 0, 34h, 12h, 36h, 12h, 32h, 18h, 2Dh, 0Ch
                db 2Bh, 18h, 28h, 0Ch, 26h, 18h, 2Bh, 0Ch, 34h, 60h, 0C8h, 0, 34h, 18h, 0, 6
                db 37h, 12h, 39h, 0Ch, 3Ch, 0Ch, 3Eh, 0Ch, 40h, 24h, 40h, 24h, 3Ch, 18h, 37h, 0Ch
                db 36h, 24h, 35h, 24h, 33h, 24h, 30h, 18h, 2Ah, 0Ch, 29h, 18h, 2Bh, 60h, 0C8h, 0
                db 2Bh, 0Ch, 29h, 18h, 28h, 18h, 26h, 90h, 23h, 0C0h, 0FFh, 0FFh, 0FFh, 0FFh, 1Ah







	       ENT
ay_end:


                savebin "kissofmurder/ay_plr1.bin",ay_begin,ay_end-ay_begin
                ENDMODULE