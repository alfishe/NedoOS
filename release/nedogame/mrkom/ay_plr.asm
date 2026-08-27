                MODULE AY_PLR
PLR_START= 0x4000
ay_begin:
                DISP PLR_START
                jr init_
                jp PLR_PLAY
                jp mute
is_music_ended  db 0
                jp plr_mod
                jp plr_adv
                jp plr_unmod

tbl_music
                dw music1_data
                dw music2_data
                dw music3_data
                dw music4_data
                dw music5_data

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
                ld a,(byte_5607)
                and a
                jr nz,plr_adv
                ld a,(byte_560b)
                or a
                ld a,3
                jr z,1_f
                ld a,6
1
                ld (byte_5607),a
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
                ld (off_59E7),hl


                ld      a, (music_number)
                ld      hl, unk_5A06
                cp      4
                jr      z, loc_562A
                ld      hl, unk_5A02
                cp      2
                jr      z, loc_562A
                ld      hl, unk_59FE
loc_562A:
                ld      de, unk_59EB
                ld      bc, 4
                ldir
                call    sub_5959
                ld      bc, unk_5A0A
                add     hl, bc
                ld      de, unk_59F4
                ld      bc, 0Ah
                ldir



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
speed_loop
                dec b
                jp z,speed_loop_exit
                push bc
                call player
                pop bc
                jp speed_loop
        
speed_loop_exit
                ret



player:
				ret
                ld      hl, (off_59E9)
                ld      a, (hl)
                inc     hl
                or      a
                jr      nz, loc_5760
                ld      hl, unk_59EC
                ld      a, (hl)
loc_5760:
                ld      (off_59E9), hl
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

                ld      hl, unk_59BD
                call    select_chan_data_byte
                dec     (hl)
                jp      nz, loc_5819
loc_57A9:
                xor     a
                ld      (byte_5A3D), a
                ld      hl, off_59C0
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)

loc_57B6:
                ld      a, (de)
                inc     de
                cp      61h ; 'a'
                jp      nc, loc_58EB
                push    hl
                push    af
                ld      hl, unk_59BD
                call    select_chan_data_byte
                ld      a, (de)
                ld      (hl), a
                inc     de
                pop     af
                pop     hl
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ld      hl, unk_59C9
                call    select_chan_data_byte
                ld      (hl), a
                or      a
                jr      z, loc_5819
                ld      e, a
                ld      a, (word_59FC)
                add     a, e
                add     a, a
                ld      e, a
                ld      d, 0
                ld      hl, byte_5A3C
                add     hl, de
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, unk_59F0
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
                ld      a, (byte_5A3D)
                or      a
                jr      nz, loc_5819
                ld      hl, unk_59E1
                call    select_chan_data_byte
                xor     a
                ld      (hl), a
                call    sub_5871
                ld      hl, unk_59D2
                call    select_chan_data_word
                ld      (hl), a
                inc     hl
                ld      (hl), a

loc_5819:
                ld      hl, unk_59C9
                call    select_chan_data_byte
                ld      a, (hl)
                or      a
                jr      z, loc_5868

sub_5823:
                ld      hl, unk_59E1
                call    select_chan_data_byte
                ld      a, (hl)
                dec     a
                jr      z, loc_5839
                dec     a
                jr      z, loc_5842
                dec     a
                jr      z, loc_584C
                dec     a
                jr      z, loc_5860
                xor     a
                jr      loc_5868

loc_5839:
                xor     a
                ld      (loc_58C7), a
                call    loc_58A4
                jr      loc_5868

loc_5842:
                ld      a, 3Fh ; '?'
                ld      (loc_58C7), a
                call    loc_58A4
                jr      loc_5868

loc_584C:
                ld      hl, unk_59D8
                call    select_chan_data_word
                dec     (hl)
                ret     nz
                call    sub_5871
                ld      hl, unk_59DE
                call    select_chan_data_byte
                ld      (hl), 0
                ret

loc_5860:
                ld      a, 3Fh ; '?'
                ld      (loc_58C7), a
                call    loc_58A4

loc_5868:
                ld      e, a
                ld      a, (current_channel)
                add     a, 8
                jp      j_WRTPSG

sub_5871:
                ld      hl, unk_59CC
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      hl, unk_59E1
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
                ld      hl, unk_59DE
                call    select_chan_data_byte
                ld      (hl), b
                pop     hl
                add     hl, hl
                add     hl, de
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, unk_59D8
                call    select_chan_data_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                pop     hl
                inc     (hl)
                ret

loc_58A4:
                ld      hl, unk_59D8
                call    select_chan_data_word
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      a, d
                or      e
                jr      z, loc_58D4
                ld      hl, unk_59D2
                call    select_chan_data_word
                ld      c, (hl)
                inc     hl
                ld      b, (hl)
                ex      de, hl
                add     hl, bc
                ex      de, hl
                push    hl
                ld      hl, unk_59DE
                call    select_chan_data_byte
                ld      a, d
                cp      (hl)
                pop     hl

loc_58C7:
                nop
                jr      nc, loc_58D4
                cp      10h
                jr      c, loc_58D0
                xor     a
                ret


loc_58D0:
                ld      (hl), d
                dec     hl
                ld      (hl), e
                ret

loc_58D4:
                ld      hl, unk_59DE
                call    select_chan_data_byte
                ld      a, (hl)
                push    af
                call    sub_5871
                ld      hl, unk_59D2
                call    select_chan_data_word
                pop     af
                ld      (hl), 0
                inc     hl
                ld      (hl), a
                ret

loc_58EB:
                cp      0FFh
                jp      z, loc_5903
                cp      0C0h
                jp      z, loc_5930
                cp      0C8h
                jp      z, loc_5927
                cp      0C7h
                jp      z, loc_5982
                inc     de
                jp      loc_57B6

loc_5903:
                ld      hl, word_59C6
                call    select_chan_data_byte
                ld      (hl), 1
                ld      a, (current_channel)
                add     a, a
                jr      nz, loc_5912
                inc     a

loc_5912:
                ld      b, a
                add     a, a
                add     a, a
                add     a, a
                or      b
                ld      b, a
                ld      a, (byte_59E4)
                or      b
                and     0BFh
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                jp      loc_59AC

loc_5927:
                ld      a, 1
                ld      (byte_5A3D), a
                inc     de
                jp      loc_57B6

loc_5930:
                push    hl
                push    de
                ld      a, (de)
                ld      e, a
                ld      d, 0
                ld      hl, byte_5AFE
                add     hl, de
                pop     de
                inc     de
                ld      a, (hl)
                and     0F0h
                rrca
                rrca
                rrca
                rrca
                call    sub_5959
                ld      bc, byte_5B1E
                add     hl, bc
                ld      b, h
                ld      c, l
                ld      hl, unk_59CC
                call    select_chan_data_word
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     hl
                jp      loc_57B6

sub_5959:
                ld      l, a
                ld      h, 0
                ld      c, l
                ld      b, h
                add     hl, hl
                add     hl, hl
                add     hl, bc
                add     hl, hl
                ret

                push    de
                ld      a, (de)
                ld      e, a
                ld      a, 6
                call    j_WRTPSG
                pop     de

loc_596C:
                inc     de
                jp      loc_57B6

                push    de
                ld      a, (de)
                ld      e, a
                ld      a, (byte_59E4)
                and     e
                or      80h
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                pop     de
                jr      loc_596C
loc_5982:
                ld      a, 1
                ld      (byte_5A3C), a
                ld      a, (byte_5607)
                or      a
                jr      nz, loc_59A3
                inc     de
                ex      de, hl
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ld      hl, (off_59E7)
                add     hl, de
                ex      de, hl
                ld      hl, off_59C0
                call    select_chan_data_word
                ld      (hl), e
                inc     hl
                ld      (hl), d
                jp      loc_57A9
loc_59A3:                               
                dec     a
                ld      (byte_5607), a
                inc     de
                inc     de
                jp      loc_596C
loc_59AC:                               
                ld      hl, word_59C6
                ld      b, 3

loc_59B1:                               
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                djnz    loc_59B1
                ;pop     hl
                jp      e_o_mus
; ---------------------------------------------------------------------------
current_channel:dw 0        
                            
unk_59BD:       db    1     
                            
                db    1
                db    1
off_59C0:       dw 0,0,0
word_59C6:      dw 0        
                            
                db    0
unk_59C9:       db    0     
                            
                db    0
                db    0
unk_59CC:       db    0     
                            
                db    0
                db    0
                db    0
                db    0
                db    0
unk_59D2:       db    0     
                            
                db    0
                db    0
                db    0
                db    0
                db    0
unk_59D8:       db    0     
                            
                db    0
                db    0
                db    0
                db    0
                db    0
unk_59DE:       db    0     
                            
                db    0
                db    0
unk_59E1:       db    0     
                            
                db    0
                db    0
byte_59E4:      db 0B8h     
                            
                db    0
                db    0
off_59E7:       dw music1_data
                            
off_59E9:       dw unk_59EB 
                            
unk_59EB:       db    1
                       
unk_59EC:       db    2
                db    1
                db    2
                db    0
unk_59F0:       db    0
                db    0
                db    0
                db    0
unk_59F4:       db    0
                db    1
unk_59F6:       db    0
                db    0
                db    1
                db    0
                db    0
                db    0
word_59FC:      dw 0F4h
                       
unk_59FE:       db    1
                db    2
                db    1
                db    2
unk_5A02:       db    1
                db    1
                db    1
                db    1
unk_5A06:       db    1
                db    1
                db    2
                db    1
unk_5A0A:       db    0
                db    1
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db 0F4h
                db    0
                db    0
                db    1
                db    0
                db    0
                db    1
                db    0
                db    2
                db    0
                db 0F4h
                db    0
                db    0
                db    5
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db 0F4h
                db    0
                db    0
                db    2
                db    0
                db    0
                db    1
                db    0
                db    4
                db    0
                db 0F4h
                db    0
                db    0
                db    1
                db    0
                db    0
                db    2
                db    0
                db    1
                db    0
                db 0FAh
                db    0
byte_5A3C:      db 0
byte_5A3D:      db 0, 5Dh, 0Dh, 9Ch, 0Ch, 0E7h, 0Bh, 3Ch, 0Bh, 9Bh, 0Ah, 2, 0Ah, 73h, 9, 0EBh
                db 8, 6Bh, 8, 0F2h, 7, 80h, 7, 14h, 7, 0AFh, 6, 4Eh, 6, 0F4h, 5, 9Eh
                db 5, 4Eh, 5, 1, 5, 0BAh, 4, 76h, 4, 36h, 4, 0F9h, 3, 0C0h, 3, 8Ah
                db 3, 57h, 3, 27h, 3, 0FAh, 2, 0CFh, 2, 0A7h, 2, 81h, 2, 5Dh, 2, 3Bh
                db 2, 1Bh, 2, 0FDh, 1, 0E0h, 1, 0C5h, 1, 0ACh, 1, 94h, 1, 7Dh, 1, 68h
                db 1, 53h, 1, 40h, 1, 2Eh, 1, 1Dh, 1, 0Dh, 1, 0FEh, 0, 0F0h, 0, 0E3h
                db 0, 0D6h, 0, 0CAh, 0, 0BEh, 0, 0B4h, 0, 0AAh, 0, 0A0h, 0, 97h, 0, 8Fh
                db 0, 87h, 0, 7Fh, 0, 78h, 0, 71h, 0, 6Bh, 0, 65h, 0, 5Fh, 0, 5Ah
                db 0, 55h, 0, 50h, 0, 4Ch, 0, 47h, 0, 43h, 0, 40h, 0, 3Ch, 0, 39h
                db 0, 35h, 0, 32h, 0, 30h, 0, 2Dh, 0, 2Ah, 0, 28h, 0, 26h, 0, 24h
                db 0, 22h, 0, 20h, 0, 1Eh, 0, 1Ch, 0, 1Bh, 0, 19h, 0, 18h, 0, 16h
                db 0, 15h, 0, 14h, 0, 13h, 0, 12h, 0, 11h, 0, 10h, 0, 0Fh, 0, 0Eh
                db 0
byte_5AFE:      db 0B4h, 34h, 0C4h, 24h, 44h, 14h, 94h, 34h, 0E4h, 0F4h, 14h, 74h, 14h, 94h, 14h,  14h
                db 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 0A4h, 14h, 28h, 21h, 30h, 0A4h, 0A4h 
byte_5B1E:      db 2, 80h, 0, 0, 0, 18h, 0FFh, 0F4h, 7, 7
                db 0, 2Dh, 0, 0, 0, 52h, 0FFh, 0F7h, 0Ch, 0Ch
                db 0, 0, 0, 0, 0, 2Ah, 0FFh, 0E3h, 0Ah, 0Ah
                db 0, 0, 0FFh, 0E2h, 0, 16h, 0FFh, 0EDh, 0Dh, 0Ch
                db 2, 15h, 0FFh, 0E7h, 0, 56h, 0FFh, 0F4h, 0Dh, 0Ch
                db 2, 80h, 0, 0, 0, 29h, 0FFh, 0F4h, 0Ch, 0Ch
                db 3, 20h, 0FFh, 0D4h, 0, 54h, 0FFh, 0FAh, 0Fh, 0Ch
                db 2, 80h, 0, 0, 0, 22h, 0FFh, 0F4h, 0Dh, 0Dh
                db 4, 2Bh, 0, 0, 0, 82h, 0FFh, 0F4h, 0Ch, 0Ch
                db 0Ch, 80h, 0, 0, 0, 4Dh, 0FFh, 0F6h, 0Ch, 0Ch
                db 0, 0, 0FFh, 0B8h, 0, 0Eh, 0FFh, 0E7h, 0Dh, 0Bh
                db 0, 0, 0FEh, 0F4h, 0, 0Eh, 0FFh, 0E5h, 0Dh, 0Ch
                db 0, 0, 0FFh, 0D4h, 0, 5, 0FFh, 0E3h, 0Dh, 0Bh
                db 0, 0, 0FFh, 0D4h, 0, 7, 0FFh, 0F7h, 0Eh, 0Bh
                db 0, 0, 0FFh, 0E4h, 0, 13h, 0FFh, 0F3h, 0Fh, 0Dh
                db 6, 40h, 0FFh, 0B8h, 0, 1Ch, 0FFh, 0F2h, 0Fh, 0Dh

; =============== S U B R O U T I N E =======================================


ay_init:
initialize_player:
                ld      hl, (initial_position)
                ld      (off_59E7), hl
                ld      hl, unk_59BD
                ld      b, 3
loc_5BC9:
                ld      (hl), 1
                inc     hl
                djnz    loc_5BC9
                ld      hl, word_59C6
                ld      b, 3
loc_5BD3:
                ld      (hl), 0
                inc     hl
                djnz    loc_5BD3
                ld      hl, off_59C0
                ld      (loc_5BF6+1), hl
                ld      hl, unk_59F6
                ld      (loc_5BEB+1), hl
                ld      b, 3
loc_5BE6:
                push    bc
                ld      bc, (initial_position)
loc_5BEB:
                ld      hl, (word_59FC)
                sla     l
                add     hl, bc
                ld      d, (hl)
                inc     hl
                ld      e, (hl)
                ex      de, hl
                add     hl, bc
loc_5BF6:
                ld      (word_59C6), hl
                ld      hl, (loc_5BEB+1)
                inc     hl
                inc     hl
                ld      (loc_5BEB+1), hl
                ld      hl, (loc_5BF6+1)
                inc     hl
                inc     hl
                ld      (loc_5BF6+1), hl
                pop     bc
                djnz    loc_5BE6
                ld      a, 0B8h
                ld      (byte_59E4), a
                ld      e, a
                ld      a, 7
                call    j_WRTPSG
                ld      a, 0Dh
                ld      e, 0
                jp      j_WRTPSG

                
music1_data:   incbin "_common/music1ay.bin"
music2_data:   incbin "_common/music2ay.bin"
music3_data:   incbin "_common/music3ay.bin"
music4_data:   incbin "_common/music4ay.bin"
music5_data:   incbin "_common/music5ay.bin"


	       ENT
ay_end:


                savebin "kissofmurder/ay_plr.bin",ay_begin,ay_end-ay_begin
                ENDMODULE