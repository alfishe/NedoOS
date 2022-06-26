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
;-setup interrupt
int_set:
        di
        ld hl,0x0038
        ld de,int_orig
        ld bc,5
        ldir
        ld hl,0x0038
        ld a,0xC3 ;jp
        ld (hl),a
        inc hl
        ld de,int_proc
        ld a,e
        ld (hl),a
        inc hl
        ld a,d
        ld (hl),a
        ei
        ret

int_reset:
        di
        ld de,0x0038
        ld hl,int_orig
        ld bc,3
        ldir
        ei
        ret

int_proc
        push af
        ex af,af'
        push af
        push bc
        push de
        push hl
        push ix
        push iy
        exx
        push bc
        push de
        push hl

;        ld a,1
;        out (0xfe),a

        ld a,(setpalflag)
        or a
        call nz,setpal_proc
;       ld a,(setscreenflag)
;       or a
;       call nz,setscreen_proc
        GET_KEY
        ld a,c
        ld (keyreg),a
        OS_GETKEYMATRIX
        ld (keymatrixbc),bc
        ld (keymatrixde),de
        ld (keymatrixhl),hl
        ld (keymatrixix),ix


        ld a,0
wlock equ $-1 
        and a       
        CALL nz,anim_wait



;        ld a,0
;        out (0xfe),a

        ld a,0
screenswapper: equ $-1
        and a
        call nz,switchscreens

        pop hl
        pop de
        pop bc
        exx
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af'
        pop af
int_orig ds 5
        jp 0x0038+5        

no_mus
          call setmusicpage
          ld a,(music_buf)
          ld hl,PLR_MUTE
          OS_SETMUSIC
          call unsetmusicpage
          halt
          ret 
;==========================
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
        
;---------------------
filecreateeerror:
        ld hl,txt_fcreateerror
        jr openerror        
filewriteerror:
        call closestream_file
        ld hl,txt_fwriteerror
        jr openerror
filereaderror:
        call closestream_file
        ld hl,txt_freaderror
        jr openerror
dirchangeerror
        ld hl,txt_dircherror
        jr openerror
fileopenerror
        ld hl,txt_fopenerror
openerror:
        push hl
        ld e,6+0x80
        OS_SETGFX
        ld e,0
        OS_CLS
        pop  hl
        call print_hl
        ld hl,buf
        call print_hl
        ld hl,txt_nl
        call print_hl
        YIELDGETKEYLOOP
        jp cmd_quit


memoryerror
        OS_CLOSEHANDLE
        ld e,6+0x80
        OS_SETGFX
        ld e,0
        OS_CLS
        ld hl,txt_memoryerror
        call print_hl
        YIELDGETKEYLOOP
        jp cmd_quit


cmd_quit
;;      call closestream_file
        ld e,6+0x80
        OS_SETGFX
        call int_reset
;;       call disablemusic
        QUIT        

;----------------------------------------        
load_mus

        ld b,0
old_mus EQU $-1
        cp b
        ret z
        ld (old_mus),a

        and a
        jp z,no_mus

        
        call calc_mus

        call no_mus
        
        ;generate path to music file in 'buf'
        ld hl,mus_path1
        ld de,buf
        call copystr_hlde ;'copy path  'mus/' '
        
        ld a,(mus_mode)
        ld hl,mus_modes
        call sel_word
        call copystr_hlde ;copy "aym / s98 path"
        ld hl,mus_path2
        call copystr_hlde ;copy name without ext
        
        ld a,(mus_mode)
        ld hl,plr_ext
        call sel_word
        call copystr_hlde  ;copy file ext
        xor a
        ld (de),a  ;string terminator



        call setmusicpage

                ld de,buf
                call openstream_file
                or a
                jp nz,fileopenerror

                ld hl,0x3000 ;len
                ld de,module ;addr
                call readstream_file
                or a
                jp nz,filereaderror 

                call closestream_file

                ld a,0b00100000
                ld (SETUP),a
                ld hl,module

                call PLR_INIT        ;init music

                ld a,(music_buf)
                ld hl,PLR_PLAY
                OS_SETMUSIC         
        jp unsetmusicpage

calc_mus:
        call a_to_dec

        LD (mus_path2+5),A
        LD A,B
        LD (mus_path2+4),A
        RET        

a_to_dec:
        CP 30
        JR C,calc_m0
        SUB 30
        LD B,"3"
        JR calc_mus_f
calc_m0   CP 20
        JR C,calc_m1
        SUB 20
        LD B,"2"
        jr calc_mus_f
calc_m1   CP 10
        JR C,calc_m2
        SUB 10
        LD B,"1"
        JR calc_mus_f
calc_m2   LD B,"0"
calc_mus_f:
         ADD A,"0"
         ret
;------------------
setmusicpage
        OS_GETMAINPAGES
        ld a,e
        ld (tbank1),a
        ld a,(music_buf)
        SETPG4000
        ret

unsetmusicpage
        ld a,(tbank1)
        SETPG4000
        ret

;---------------------
setfontpage
        push af
        push bc
        OS_GETMAINPAGES
        ld a,h
        ld (tbank2),a
        ld a,(font_page)
        SETPG8000
        pop bc
        pop af
        ret

unsetfontpage
        ld a,(tbank2)
        SETPG8000
        ret
;---------------------
store8000c000
        push af
        push bc
        OS_GETMAINPAGES
        ld a,h
        ld (tbank2),a
        ld a,l
        ld (tbank3),a
        pop bc
        pop af
        ret

restore8000c000
        ld a,(tbank2)
        SETPG8000
        ld a,(tbank3)
        SETPGC000        
        ret
;========================
storec000
        OS_GETMAINPAGES
        ld a,l
        ld (tbank3),a
        ret

restorec000
        ld a,(tbank3)
        SETPGC000        
        ret
;========================
store8000
        OS_GETMAINPAGES
        ld a,h
        ld (tbank2),a
        ret

restore8000
        ld a,(tbank2)
        SETPG8000        
        ret
;========================
_load_common:
        ld hl,33 ;len
        ld de,buf
        call readstream_file
        or a
        jp nz,filereaderror

        call closestream_file

        ld hl,buf
        ld a,(hl)
        inc a
        jp nz,_load_save_exit
        inc hl
        ld de,OVL
        ld bc,32
        ldir
        pop hl
        jp BEG



;========================
_ram_load:
        push hl
        ld de,SAVETEMPL
        call openstream_file
        or a
        jp nz,_load_save_exit
        jp _load_common



_ram_save:
        push hl

        ld hl,SAVESLOT
        ld de,SAVESLOT+1
        ld bc,32
        ld (hl),0
        ldir

        
        ld hl,SAVESLOT        
        ld de,LOADED
        
        ld (hl),#ff
        inc hl
        ex de,hl

        ld bc,32
        ldir


_retry_save:
        ld de,SAVETEMPL
        call openstream_file
        or a
        jp z,_save_slot_is_present
        ; we should create file here

         LD DE,SAVETEMPL
         OS_CREATEHANDLE
         OR A
         JP NZ,filecreateeerror
         ld a,b
         ld (filehandle),a

_save_slot_is_present:

        ld hl,33 ;len
        ld de,SAVESLOT ;addr
        call savestream_file
        or a
        jp nz,filewriteerror 

        call closestream_file        



_load_save_exit:
        ld a,NOKEY
        pop hl
        ret


_is_quit:
        pop hl
        xor a
        ld (wlock),a
        jp _exitdark


getkey
        ld a,(keyreg)
        ret


waitkey_a
        ld a,1
        ld (wlock),a
        call waitkey


	 CP "Q"
	 JR Z,_is_quit
	 CP "q"
	 JR Z,_is_quit

	 CP "L"
	 CALL Z,_ram_load
	 CP "l"
	 CALL Z,_ram_load
	 CP "S"
	 CALL Z,_ram_save
	 CP "s"
	 CALL Z,_ram_save


        cp NOKEY
        jr z,waitkey_a

        push af
        xor a
        ld (wlock),a
        pop af
        ret

waitkey

waitkey_unpress ;Wait for enter unpress
        ld a,(keymatrixix+1)
        bit 0,a
        jr z,waitkey_unpress
waitkey_loop
        call getkey
        cp NOKEY
        jr z,waitkey_loop
waitkey0
        ld (lastkey),a
        call getkey
        cp NOKEY
        jr nz,waitkey0 ; purge key buffer
        ld a,(lastkey)
        ret
        ;cp key_esc
        ;jp z,cmd_quit
        ;ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

change_cp1 ;#
            LD A,186
            RET
change_cp2   ;@
          LD A,188
          RET
change_cp
         PUSH HL,DE
         LD HL,TABLE_W
CODEPAGE EQU $-2
         SUB 128
         LD D,0
         LD E,A
         ADD HL,DE
         LD A,[HL]
         POP DE,HL
         RET

TABLE_W  DS 40,32
         DB 134
         DS 15,32
         DB 194
         DS 7,32
         DB 129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160
         DB 161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,188,189,190,191,192,193

TABLE_J  DS 13,32
         DB 186,188 ;щ ъ        141 142
         DS 15,32
         DB 186,188 ;щ ъ        158 159
         DB 189,190,191,192,193,129,130,131,132,133,134,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154
         DB 155,156,157,158,159,160,161,162,163,164,165,166,194,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185
         DB 186,188,189,190,191,192,193
         DS 6,32
         DB 143
         DB 32,32,150 ;Х
         DB 32,154,155

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


WINCLR1 CALL waitkey_a
WINCLR2
        PUSH HL
        CALL _clear_textbox  ;-0-0-3423566400------------------
        POP HL
COOOR   LD BC,txt_coor
        CALL _pradd_p
        ret
;;;;;;=====
LOADOVL POP DE
        ld de,OVL
        call copystr_hlde
        xor a
        ld (DE),a
        JP BEG




outtype2 db 0   ;"P' 򮡷ᬠ ︨᳼. 'N' ⦧ ︨򳫨  '8' 򰱠갍


_get_show_scr:
        push af

        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)              
        SETPG8000         

        ld hl,(0x4006)
        ld a,h
        add a,0x40
        ld h,a
       
        pop af
        call sel_word
        ld a,h
        add a,0x40
        ld h,a       

        ld a,(hl)
        ld (outtyp),a
        inc hl
        ld a,(hl)
        ld (outtype2),a
        inc hl




        ld a,(outtype2)

        cp '8'
        jp z,_it_is_overlay

        cp 'P'
        jp z,_clear_screen_before

_show_screen_immedatelly:

        call load_gfx_to_load_buf

        jp _buffer_output        
outtyp_conv: db 0,10,10,10,4,5,6,12,13,0,10,11
_clear_screen_before:
        push hl
        ld a,(outtyp)
        push af

        ld e,a
        ld d,0
        ld hl, outtyp_conv
        add hl,de
        ld a,(hl)
        ld (outtyp),a

        ld hl,pal
        ld de,mempal
        ld bc,32
         ldir


        call _memory_output

    ;    ld hl,temppal
     ;   ld de,pal
      ;  ld bc,32
       ; ldir

        pop af
        ld (outtyp),a
        pop hl
        jp _show_screen_immedatelly

_it_is_overlay:
        call store_name


        call load_gfx_to_scr_buf

        call _sprite_output_mask_no_pal


        ret





store_name:
        push hl
        ld hl,namebuf
        ld de,namebuf+1
        ld bc,13
        ld (hl),0
        ldir
        pop hl
        push hl
        ld de,namebuf
        call copystr_hlde
        pop hl
        ret        



cmpr_dehl:
        ld a,(de)
        and a
        ret z   ;string fully equally and dtring in de not begin from 0

        cpi
        ret nz
        inc de
        jr cmpr_dehl

C_Time_D:
;Outputs:
;     A is the result
;     B is 0
     ld b,8          ;7           7
     xor a           ;4           4
       rlca          ;4*8        32
       rlc c         ;8*8        64
       jr nc,$+3     ;(12|11)    96|88
         add a,d     ;--
       djnz $-6      ;13*7+8     99
     ret             ;10         10

;___________________________________
;A15	A14	A13	A12	A11	A10	 A9	 A8
; G0	 R0	 B0	 G1	 1	 1	 R1	 B1
	      	
; D7	 D6	 D5	 D4	 D3	 D2	 D1	 D0
; G2	 R2	 B2	 G3	 1	 1	 R3	 B3
palette_precalc:
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
;===================

fade_toblack:
        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;


        ld lx,8
.fade0
        dec lx
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
        jr nz,.fade0
	halt
	halt
	halt
        ret


fade_towhite:
        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;


        ld lx,8
.fadew0
        inc lx

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
        cp 15
        jr nz,.fadew0
	halt
	halt
	halt
        ret


fade_fromwhite:
        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;


        ld lx,15
.fadew1
        dec lx

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
        jr nz,.fadew1
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



fade_fromblack:
        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;


        ld lx,0
.fadeb1
        inc lx

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
        jr nz,.fadeb1
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

clear_ovlnamebuf:
        push hl
        push bc
        push de
        ld hl,ovlnamebuf
        ld de,ovlnamebuf+1
        ld bc,127
        ld (hl),0
        ldir
        pop de
        pop bc
        pop hl
        ret