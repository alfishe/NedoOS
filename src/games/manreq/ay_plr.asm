                MODULE AY_PLR
PLR_START= 0x4000
EXT_RTN = 0x5800
ay_begin:
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
exit_routine:
                ret
                JP EXT_RTN
;0x4019
                db 0    ;UNBL_FLAG
;0x401a
                db 0    ;SCR0HIGH_
;0x401b
                db 0    ;SCR0LOW_
tbl_music
;                dw music1_data  ;=============
                dw music1_data  ;game
                dw music2_data  ;bar
                dw music3_data  ;facts1
                dw music4_data  ;facts2
                dw music5_data  ;facts3
                dw music6_data  ;epilogue

music_number:   db 0
byte_5607:      db 0
byte_5608:      db    1
initial_position:
                dw music1_data
byte_560b:      db    0
;---------------
plr_mod
plr_unmod
                ret
;---------------
plr_adv
                ld a,(byte_57D7)
                and a
                jr nz,plr_adv
                ld a,3
                ld (byte_57D7),a
                ret
plr_tillend
                ld      a, (is_music_ended)
                or      a
                jr      z, plr_tillend
                ret
init_
                dec a
                ld (music_number),a

                ;set music beginning
                add a,a
                ld l,a
                ld h,0
                ld bc,tbl_music
                add hl,bc
                ld a,(hl)
                inc hl
                ld h,(hl)
                ld l,a

                ld (initial_position),hl
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                LD BC,#FFFD
                LD A,%11111100
                OUT (C),A
                call ay_init
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
speed_loop
                dec b
                ret z       ;jp z,speed_loop_exit
                push bc
                call player
                pop bc
                jp speed_loop
;speed_loop_exit
;                ret



player:
				ret
                ld      a, (byte_57D6)
                ld      b, a
loc_5764:
                push    bc
                xor     a
loc_5766:
                ld      (current_channel), a
                call    play_ay
                ld      a, (current_channel)
                inc     a
                cp      3
                jr      nz, loc_5766
                pop     bc
                djnz    loc_5764
                ret
mute
e_o_mus:
                LD BC,#FFFD
                LD A,%11111100
                OUT (C),A

                call NOMUS

                ld      a, 7
                ld      e, 0BFh
                call    j_WRTPSG

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
                ld      hl, byte_57AA
                call    select_chan_data_byte
                dec     (hl)
                jp      nz, loc_5607
loc_55B3:
                ld      hl, byte_57AD
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
loc_55BC:
                ld      a, (de)
                inc     de
                cp      61h ; 'a'
                jp      nc, loc_56F3
                push    hl
                push    af
                ld      hl, byte_57AA
                call    select_chan_data_byte
                ld      a, (de)
                ld      (hl), a
                inc     de
                pop     af
                pop     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      hl, byte_57B6
                call    select_chan_data_byte
                ld      (hl), a
                or      a
                jr      z, loc_5607
                add     a, a
                ld      e, a
                ld      d, 0
                ld      hl, byte_57D8
                add     hl, de
                ld      a, (current_channel)
                add     a, a
                ld      e, (hl)
                inc     hl
                call    j_WRTPSG
                inc     a
                ld      e, (hl)
                call    j_WRTPSG
                ld      hl, byte_57CE
                call    select_chan_data_byte
                xor     a
                ld      (hl), a
                call    sub_5679
                ld      hl, byte_57BF
                call    select_chan_data_word
                ld      (hl), a
                inc     hl
                ld      (hl), a
loc_5607:
                ld      a, (byte_57D9)
                or      a
                ld      hl, byte_57B6
                call    select_chan_data_byte
                ld      a, (hl)
                or      a
                jr      z, loc_565A
                ld      hl, byte_57CE
                call    select_chan_data_byte
                ld      a, (hl)
                dec     a
                jr      z, loc_562B
                dec     a
                jr      z, loc_5634
                dec     a
                jr      z, loc_563E
                dec     a
                jr      z, loc_5652
                xor     a
                jr      loc_565A
loc_562B:
                xor     a
                ld      (loc_56CF), a
                call    loc_56AC
                jr      loc_565A
loc_5634:
                ld      a, 3Fh ; '?'
                ld      (loc_56CF), a
                call    loc_56AC
                jr      loc_565A
loc_563E:
                ld      hl, byte_57C5
                call    select_chan_data_word
                dec     (hl)
                ret     nz
                call    sub_5679
                ld      hl, byte_57CB
                call    select_chan_data_byte
                ld      (hl), 0
                ret
loc_5652:
                ld      a, 3Fh ; '?'
                ld      (loc_56CF), a
                call    loc_56AC
loc_565A:
                push    af
                ld      a, (byte_57D9)
                or      a
                jr      nz, loc_566F
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
loc_566F:
                pop     af
                ld      e, a
                ld      a, (current_channel)
                add     a, 8
                jp      j_WRTPSG
sub_5679:
                ld      hl, byte_57B9
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, byte_57CE
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
                ld      hl, byte_57CB
                call    select_chan_data_byte
                ld      (hl), b
                pop     hl
                add     hl, hl
                add     hl, de
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, byte_57C5
                call    select_chan_data_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                pop     hl
                inc     (hl)
                ret
loc_56AC:
                ld      hl, byte_57C5
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      a, d
                or      e
                jr      z, loc_56DC
                ld      hl, byte_57BF
                call    select_chan_data_word
                ld      c, (hl)
                inc     hl
                ld      b, (hl)
                ex      de, hl
                add     hl, bc
                ex      de, hl
                push    hl
                ld      hl, byte_57CB
                call    select_chan_data_byte
                ld      a, d
                cp      (hl)
                pop     hl
loc_56CF:
                nop
                jr      nc, loc_56DC
                cp      10h
                jr      c, loc_56D8
                xor     a
                ret
loc_56D8:
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ret
loc_56DC:
                ld      hl, byte_57CB
                call    select_chan_data_byte
                ld      a, (hl)
                push    af
                call    sub_5679
                ld      hl, byte_57BF
                call    select_chan_data_word
                pop     af
                ld      (hl), 0
                inc     hl
                ld      (hl), a
                ret
loc_56F3:
                cp      0FFh
                jp      z, loc_5710
                cp      0C6h
                jp      z, loc_5752
                cp      0C5h
                jp      z, loc_575F
                cp      0C3h
                jp      z, loc_5732
                cp      0C7h
                jp      z, loc_576F
                inc     de
                jp      loc_55BC
loc_5710:
                ld      hl, byte_57B3
                call    select_chan_data_byte
                ld      (hl), 1
                ld      a, (current_channel)
                add     a, a
                jr      nz, loc_571F
                inc     a
loc_571F:
                ld      b, a
                add     a, a
                add     a, a
                add     a, a
                or      b
                ld      b, a
                ld      a, (byte_57D1)
                or      b
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                jp      loc_5799
loc_5732:
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
                ld      bc, (word_57D2)
                add     hl, bc
                ld      b, h
                ld      c, l
                ld      hl, byte_57B9
                call    select_chan_data_word
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     hl
                inc     de
                jp      loc_55BC
loc_5752:
                push    de
                ld      a, (de)
                ld      e, a
                ld      a, 6
                call    j_WRTPSG
                pop     de
loc_575B:
                inc     de
                jp      loc_55BC
loc_575F:
                push    de
                ld      a, (de)
                ld      e, a
                ld      a, (byte_57D1)
                and     e
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                pop     de
                jr      loc_575B
loc_576F:
                ld      a, 1
                ld      (byte_57D8), a
                ld      a, (byte_57D7)
                or      a
                jr      nz, loc_5790
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (word_57D4)
                add     hl, de
                ex      de, hl
                ld      hl, byte_57AD
                call    select_chan_data_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_55B3
loc_5790:
                dec     a
                ld      (byte_57D7), a
                inc     de
                inc     de
                jp      loc_575B
loc_5799:
                ld      hl, byte_57B3
                ld      b, 3
loc_579E:
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                djnz    loc_579E
                ;pop     hl
                jp      e_o_mus
; ---------------------------------------------------------------------------
current_channel:dw      0
byte_57AA:       db      1, 1, 1
byte_57AD:      db      0, 0, 0, 0, 0, 0
byte_57B3:      db      0, 0, 0
byte_57B6:       db      0, 0 ,0
byte_57B9:      db      0, 0, 0, 0, 0, 0
        
byte_57BF:      db      0, 0, 0, 0, 0, 0
        
byte_57C5:      db      0, 0, 0, 0, 0, 0
        
byte_57CB:      db      0, 0, 0
        
byte_57CE:      db      0, 0, 0
        
byte_57D1:      db      0FFh
        
word_57D2:      dw      0
        
word_57D4:      dw      0
        
byte_57D6:      db      1
byte_57D7:      db      0
        
byte_57D8:      db      0
        
byte_57D9:      db      1
        
                dw      0D5Dh, 0C9Ch, 0BE7h, 0B3Ch, 0A9Bh, 0A02h, 973h, 8EBh, 86Bh, 7F2h, 780h, 714h, 6AFh, 64Eh, 5F4h, 59Eh
                dw      54Eh, 501h, 4BAh, 476h, 436h, 3F9h, 3C0h, 38Ah, 357h, 327h, 2FAh, 2CFh, 2A7h, 281h, 25Dh, 23Bh
                dw      21Bh, 1FDh, 1E0h, 1C5h, 1ACh, 194h, 17Dh, 168h, 153h, 140h, 12Eh, 11Dh, 10Dh, 0FEh, 0F0h, 0E3h
                dw      0D6h, 0CAh, 0BEh, 0B4h, 0AAh, 0A0h, 97h, 8Fh, 87h, 7Fh, 78h, 71h, 6Bh, 65h, 5Fh, 5Ah
                dw      55h, 50h, 4Ch, 47h, 43h, 40h, 3Ch, 39h, 35h, 32h, 30h, 2Dh, 2Ah, 28h, 26h, 24h
                dw      22h, 20h, 1Eh, 1Ch, 1Bh, 19h, 18h, 16h, 15h, 14h, 13h, 12h, 11h, 10h, 0Fh, 0Eh

; =============== S U B R O U T I N E =======================================


ay_init:
initialize_player:                      ; CODE XREF: sub_53C3+1Ep
                ld      hl, (initial_position)
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                inc     hl
                ld      (word_57D2), hl
                dec     hl
                dec     hl
                add     hl, de
                ld      (word_57D4), hl
                ld      hl, byte_57AA
                ld      b, 3
loc_58AF:
                ld      (hl), 1
                inc     hl
                djnz    loc_58AF
                ld      hl, byte_57B3
                ld      b, 3
loc_58B9:
                ld      (hl), 0
                inc     hl
                djnz    loc_58B9
                ld      hl, (word_57D4)
                ld      (loc_58CD+1), hl
                ex      de, hl
                ld      hl, byte_57AD
                ld      (loc_58D5+1), hl
                ld      b, 3
loc_58CD:
                ld      hl, 0
                ld      a, (hl)
                inc     hl
                ld      l, (hl)
                ld      h, a
                add     hl, de
loc_58D5:
                ld      (byte_57AD), hl
                ld      hl, (loc_58CD+1)
                inc     hl
                inc     hl
                ld      (loc_58CD+1), hl
                ld      hl, (loc_58D5+1)
                inc     hl
                inc     hl
                ld      (loc_58D5+1), hl
                djnz    loc_58CD
                ld      a, 0F8h
                ld      (byte_57D1), a
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                ld      a, 0Dh
                ld      e, 0
                jp      j_WRTPSG

music6_data:   include "_common/music6ay.asm"
music1_data:   include "_common/music1ay.asm"       ;+
music2_data:   include "_common/music2ay.asm"
music3_data:   include "_common/music3ay.asm"
music4_data:   include "_common/music4ay.asm"
music5_data:   include "_common/music5ay.asm"


	       ENT
ay_end:


                savebin "jb2manreq/ay_plr.bin",ay_begin,ay_end-ay_begin
                ENDMODULE