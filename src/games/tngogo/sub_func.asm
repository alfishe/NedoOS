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
oldimer:
        jp int_proc
        jp 0x0038+3

;-setup interrupt
int_set:
int_reset:
        di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
.swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,.swapimer0
        ei
        ret

int_proc
        EX DE,HL
        EX (SP),HL ;de="hl", ??? "de"
        LD (on_int_jp),HL
        LD (on_int_sp),SP
        LD SP,sp_alt
        push af
        push bc
        push de ;"hl"
        exx
        ex af,af'
        push af
        push bc
        push de
        push hl
        push ix
        push iy

        ld hl, (on_int_jp)
        ld de, on_int_jp-1
        and a
        sbc hl,de
         ld hl,(on_int_jp)
         jr nz,int_not_same_jp

         ld hl,0
prev_on_int equ $-2
         ld (on_int_jp),hl
         jp insspp_exit


int_not_same_jp
        jp $+3
         ld (prev_on_int),hl



         ld a,0xc9  ;ret
         ld (int_proc),a



        ld hl,(on_int_sp)
        ld de,sp_alt
        and a
        sbc hl,de

        jp nc,int_proc_byp
        di
        halt

int_proc_byp:
        ld a,(setpalflag)
        or a
        call nz,setpal_proc


        call oldimer
        di

        GET_KEY
        ld a,c
        ld (keyreg),a
        OS_GETKEYMATRIX
        ld (keymatrixbc),bc
        ld (keymatrixde),de
        ld (keymatrixhl),hl
        ld (keymatrixix),ix


        OS_GETMAINPAGES
        di
        ld a,e
        ld (im_stor_4000),a
        ld a,h
        ld (im_stor_8000),a
        ld a,l
        ld (im_stor_c000),a

;        ld a,(curpg4000)
;        ld (im_stor_4000),a
;        ld a,(curpg8000)
;        ld (im_stor_8000),a
;        ld a,(curpgc000)
;        ld (im_stor_c000),a



        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld a,0
wlock equ $-1
        and a
        CALL nz,anim_wait

        ld a,0
alock equ $-1 
        and a       
        CALL nz,anim_eyes

        ld a,0
screenswapper: equ $-1
        and a
        call nz,switchscreens


        ld a,(core_page)
        SETPG4000

        ld a,(mus_mode)
        and a
        jp z,skip_sfx
        ld a,(tsfm_detected)
        and a
        call nz,set_ay1
        call ayfx.FRAME
        ld a,(tsfm_detected)
        and a
        call nz,set_ay0
skip_sfx:


        ld a,0
im_stor_8000 equ $-1
        SETPG8000
        ld a,0
im_stor_c000 equ $-1
        SETPGC000
        ld a,0
im_stor_4000 equ $-1
        SETPG4000




insspp_exit:
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af'
        exx
        pop hl
        pop bc

        ;xor a
        ;ld r,a

        ld a,0xeb   ;ex de,hl
;c_stor equ $-1
         ld (int_proc),a

        pop af
on_int_sp=$+1
        ld sp,0
        pop de
        ei
on_int_jp=$+1
        jp 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
free_s98_file:

               ld l,(hl)
free_s98_loop
                dec l
                ld e,(hl)
                push af
                push hl
                OS_DELPAGE
                pop hl
                pop af
               jr nz,free_s98_loop
               ret     

no_mus
         call set_music_pages
                 call PLR_MUTE
                 ld a,(plr_page)
                 ld hl,0
                 OS_SETMUSIC
         call unset_music_pages
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
        ld e,6+0x80
        OS_SETGFX

        call int_reset

        ld hl,t_s98_file00_pages_list+$FF 
        call free_s98_file

        ld b,pagestbllen
        ld hl,pagestbl
.getpagesloop
        push bc,hl
        ld e,(hl)
        OS_DELPAGE
        pop hl,bc
        inc hl
        djnz .getpagesloop
        QUIT 

;----------------------------------------        
load_mus

        ld b,0
old_mus EQU $-1
        cp b
        ret z
        ld (old_mus),a

        cp 255
        jp z,no_mus
        
        call calc_mus

        call no_mus
        ld hl,t_s98_file00_pages_list+$FF 
        call free_s98_file
        
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

        ld de,buf
        call openstream_file
        or a
        jp nz,fileopenerror


        ld hl,t_s98_file00_pages_list
        ld (load_s98_file_number),hl


; загружаем файл в память
; и создаем таблицу

                ;заполняем таблицу страниц файла
                
                
load_s98_file_number_haddr = $+2 :
load_s98_file_number = $+1 :
                ld bc,t_s98_file00_pages_list
                push bc
                                
read_file_loop:
                OS_NEWPAGE              ;out: a=0 (OK)/!=0 (fail), e=page
                
                pop bc ;file tab
                                
                or a
                jp nz,memoryerror
                ld a,e
                                        ;НУЖНО СЧИТАТЬ КОЛИЧЕСТВО СТРАНИЦ !!!!
                                        ;ЧТОБЫ ПОТОМ ОСВОБОЖДАТЬ ТАБЛИЦУ !!!!

1               ld (bc),a
                inc c           ;теперь нет проверки на файлы больше 4М !!!!!
                        
                push bc ;file tab
                SETPGC000
        
                ld de,$C000
                ld hl,$4000
        
                call readstream_file    ;DE = Buffer address, HL = Number of bytes to read
                                ;hl=actual size
                ld a,h
                cp $40
                jr nc,read_file_loop    ;>= $40
        
read_file_exit

                pop bc ;file tab
                ;тут можно достать количество страниц
                ld a,c

                ld c,$FF
                ld (bc),a

                call closestream_file                                
;-------------------------------------------------------
; загрузили все куски музыки.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				call set_music_pages
				ld hl,t_s98_file00_pages_list
				ld de,0x4100         ;0x5000
				ld bc,256
				ldir

				ld hl,t_s98_file00_pages_list
				ld a,(hl)
				SETPGC000

				ld hl,module
				ld (0x4001),hl
				call PLR_INIT        ;init music
				
				ld a,(plr_page3)
				SETPGC000

				ld a,(plr_page)
				ld hl,PLR_PLAY
				OS_SETMUSIC
				jp unset_music_pages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calc_mus:
        call a_to_dec

        LD (mus_path2+6),A
        LD A,B
        LD (mus_path2+5),A
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
set_music_pages:
        ld a,(curpg4000)
        ld (zbank1),a
        ld a,(curpg8000)
        ld (zbank2),a
        ld a,(curpgc000)
        ld (zbank3),a

        ld a,(plr_page)
        SETPG4000
        ld a,(plr_page2)
        SETPG8000
        ld a,(plr_page3)
        SETPGC000
        ret

unset_music_pages:
        ld a,0
zbank1 equ $-1
        SETPG4000
        ld a,0
zbank2 equ $-1
        SETPG8000
        ld a,0
zbank3 equ $-1
        SETPGC000
        ret

;---------------------
setfontpage
		push bc,af
        ld a,(curpg8000)
        ld (fbank2),a
        ld a,(font_page)
        SETPG8000
		pop af,bc
        ret

unsetfontpage
        ld a,0
fbank2 equ $-1
        SETPG8000
        ret

;---------------------
store8000c000
		push af
        ld a,(curpg8000)
        ld (ztbank2),a
        ld a,(curpgc000)
        ld (ztbank3),a
		pop af
        ret

restore8000c000
        ld a,0
ztbank2 equ $-1
        SETPG8000
        ld a,0
ztbank3 equ $-1
        SETPGC000        
        ret
;========================
storec000
        ld a,(curpgc000)
        ld (tcbank3),a
        ret

restorec000
        ld a,0
tcbank3  equ $-1
        SETPGC000        
        ret
;========================
store8000
        ld a,(curpg8000)
        ld (t8bank2),a
        ret

restore8000
        ld a,0
t8bank2 equ $-1
        SETPG8000        
        ret
;========================
store4000l
        ld a,(curpg4000)
        ld (t42bank1l),a
        ret

restore4000l
        ld a,0
t42bank1l equ $-1
        SETPG4000        
        ret
		
store4000
        ld a,(curpg4000)
        ld (t42bank1),a
        ret

restore4000:
        ld a,0
t42bank1 equ $-1
        SETPG4000        
        ret
;========================
setcorepage:
		push af
		push bc
		push hl
		push de
		push ix
		push iy
        call store4000
        ld a,(core_page)
        SETPG4000
		pop iy
		pop ix
		pop de
		pop hl
		pop bc
		pop af
		ret

unsetcorepage:
		push af
		push bc
		push hl
		push de
		push ix
		push iy
        call restore4000
		pop iy
		pop ix
		pop de
		pop hl
		pop bc
		pop af
		ret
;--------------
getkey
        ld a,(keyreg)
        ret


waitkey_a
        ld a,1
        ld (wlock),a
        call waitkey_al
        push af
        xor a
        ld (wlock),a
        pop af
        ret

waitkey_al:
.waitkey_loop
        call getkey
        cp 's'
        jr z,.ss_pressed
        cp 'S'
        jr z,.ss_pressed
        cp NOKEY
        jr nz,.waitkey_loop

.waitkey0
        ld (lastkey),a

        call getkey
        cp 's'
        jr z,.ss_pressed
        cp 'S'
        jr z,.ss_pressed
        cp 13
        jr z,.waitkey1
        cp ' '
        jr z,.waitkey1
        jr .waitkey0 ;  пропускаем только ENTER И SPACE

.ss_pressed:
        xor a
        ld (lastkey),a
.waitkey1:
        ld a,(lastkey)
         ret

waitkey:
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
         DB 186,188 ;     141 142
         DS 15,32
         DB 186,188 ;      158 159
         DB 189,190,191,192,193,129,130,131,132,133,134,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154
         DB 155,156,157,158,159,160,161,162,163,164,165,166,194,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185
         DB 186,188,189,190,191,192,193
         DS 6,32
         DB 143
         DB 32,32,150 ;Р Тђ
         DB 32,154,155

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;in - none/ out - hl -point to script name to load
save_to_globals:
        ld hl,buf
        ld de,GLOBVARS
        ld b,0
_stg_loop:
        ld a,(hl)
        ld (de),a
        inc hl
        inc hl
        inc de
        djnz _stg_loop
        ld bc,6
        add hl,bc
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;in - none/ out - hl -point to script name to load
globals_to_save:
        ld hl,buf
        ld de,GLOBVARS
        ld b,0
_gts_loop:
        ld a,(de)
        ld (hl),a
        inc hl
        ld (hl),0
        inc hl
        inc de
        djnz _gts_loop
        ld (hl),0
        inc hl
        ld (hl),0
        inc hl
        ld (hl),0
        inc hl
        ld (hl),0
        inc hl
        ld (hl),0
        inc hl
        ld (hl),0
        inc hl          ;copy global variables to save

        ld de,LOADED
        ex de,hl
        call copystr_hlde
        xor a
        ld (de),a ;copy loaded ovl name
        ret        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_ftp:
       LD HL,#4002  ;FIRST TEXT POINTER
        LD B,(HL)
        INC HL
        LD H,(HL)
        LD A,#40
        ADD A,H
        LD H,A
        LD L,B
        LD B,(HL)
        INC HL
        LD H,(HL)
        LD A,#40
        ADD A,H
        LD H,A
        LD L,B  ;HL-FIRST TEXT ADRESS
        RET        
;;;;;;;;;;;;;;
_precache:
        LD IX,ILINK
        LD A,1
        LD (MM),A
        LD (SM),A
        LD HL,#4000
        LD L,(HL)
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD HL,#4002
        LD L,(HL)
        INC DE
        LD A,E
        OR D
        RET Z
        DEC DE
        LD A,E
        OR D
        RET Z
        LD A,E
        CP (HL)
        JR NZ,$+6
        INC HL
        LD A,D
        CP (HL)
        RET Z
        LD HL,#4004
        LD L,(HL)
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD A,D
        OR E
        RET Z
        DEC HL
        LD (TREEE),HL
        LD DE,#4006
        LD A,(DE)
        LD (LIMIT4),A;LOW
        LD A,D
        LD (LIMIT3),A;HI
        LD DE,#4000
        LD A,(DE)
        LD E,A
        LD (STRUCTURE),DE
PRECAH  LD HL,(TREEE)
        LD A,H
        CP 0
LIMIT3  EQU $-1
        JR NZ,PRECAH1
        LD A,L
        CP 0
LIMIT4  EQU $-1
        RET Z   ;END OF TREE

PRECAH1
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD A,#40
        ADD A,D
        LD D,A

        LD A,(DE)
        LD (STORE),A
        INC DE
        LD A,(DE)
        LD (STORE+1),A
        INC DE
        LD A,(DE)
        INC A
        JR NZ,PRECAH2
        INC DE
        LD A,(DE)
        INC A
        JR Z,PRECAH3 ;NONE OF SUBMENU
        DEC DE

PRECAH2 LD A,(DE)
        LD (STORE1),A
        INC DE
        LD A,(DE)
        LD (STORE1+1),A
        DEC DE
        PUSH DE
        LD A,4
        CALL SEARCHING
        LD A,1
MM      EQU $-1
        LD (IX),A
        INC IX
        LD A,1
SM      EQU $-1
        LD (IX),A
        INC IX
        LD (IX),L
        INC IX
        LD (IX),H
        INC IX
        LD A,(SM)
        INC A
        LD (SM),A
        POP DE
        INC DE,DE
        LD A,(DE)
        INC A
        JR NZ,PRECAH2
        INC DE
        LD A,(DE)
        DEC DE
        INC A
        JR NZ,PRECAH2

PRECAH4 LD A,1
        LD (SM),A
        LD HL,MM
        INC (HL)
        LD HL,0
TREEE   EQU $-2
        INC HL,HL
        LD (TREEE),HL
        JP PRECAH
PRECAH3 LD HL,#FFFF
        LD (STORE1),HL
        LD A,2
        CALL SEARCHING
        LD A,(MM)
        LD (IX),A
        INC IX
        XOR A
        LD (IX),A
        INC IX
        LD (IX),L
        INC IX
        LD (IX),H
        INC IX
        JR PRECAH4
STORE   DW 0
STORE1  DW 0

SEARCHING
          LD (SEAR2-1),A
          LD HL,0
STRUCTURE EQU $-2
SEAR1   PUSH HL
         LD E,(HL)
        INC HL
        LD D,(HL)
        LD A,#40
        ADD A,D
        LD D,A
        LD HL,STORE
        LD B,4
SEAR2   LD A,(DE)
        CP (HL)
        JR NZ,SEAR3
        INC DE
        INC HL
        DJNZ SEAR2
        POP HL
        RET
SEAR3   POP HL
        INC HL,HL
        JR SEAR1
;---------------------------------------------------------------








disable_anim:
        push af
        push hl
		
        ;swith off animations
        xor a
        ld (alock),a
        ;clear animations stack
        ld hl,anim_stack
        ld (hl),0xff
		
        pop hl
        pop af
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
		

		
		
		
		
		
		
		
palette_precalc:
			call setcorepage
			call palette_precalc_sub
			jp unsetcorepage
fade_toblack:
			ld hl,0x2ddd
			xor a
			jr fade_to
fade_towhite:
			ld a,15
			ld hl,0x2cdd
fade_to:
			call setcorepage
			call fade_to_sub
			jp unsetcorepage

fade_fromblack:
			ld hl,0x2cdd
			xor a
			jr fade_from
fade_fromwhite:
			ld a,15
			ld hl,0x2ddd
fade_from:
			call setcorepage
			call fade_from_sub
			jp unsetcorepage
;=====================================
set_ay0;
      	ld a,0+%11111000
        jr $+4
set_ay1:
	ld a,1+%11111000
	ld bc,0xFFFD
	out (c),a
	in a,(c)
	rlca
	jr c,$-3 
        ret
;===============================
randr:
        push    hl
        push    de
        ld      hl,0 ;(randData)
randData: equ $-2
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
        ld      (randData),hl
        pop     de
        pop     hl
        ret
		
;===========
clear_txt_buff:
        push bc,de
        xor a
        ld b,0
        ld de,txt_buff
.lp1
        ld (de),a
        inc de
        djnz .lp1
        pop de,bc
        ret
;================
_last_image 		db 0
_last_draw_effect 	db 0
_get_show_scr:
		ld (_last_image),a
        push af
        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)              
        SETPG8000         

        ld hl,(ovl_start+6)
        ld a,h
        add a,HIGH ovl_start
        ld h,a
       
        pop af
        call sel_word
        ld a,h
        add a,HIGH ovl_start
        ld h,a       

        ld a,(hl)
        ld (draw_effect),a ;output type
		ld (_last_draw_effect),a
        inc hl
        ld a,(hl)
        ld (outtype2),a ;image type p,n,8 or addition overlay if 0-16
        inc hl
		
		
		;<<<<< TODO   -  - - - - screen scrool types
        ld a,(outtype2)
        cp '8'
        jp z,_it_is_overlay
        cp 'P'
        jp z,_clear_screen_before	
		;"n-mode"
		
_show_screen_immedatelly:
		call store_name
        call load_gfx_to_load_buf
        call _buffer_output        
		call load_bgnd_anim
				
		ld a,(_last_draw_effect)
		cp 3
		ret nz
		
		; load following image into membuf34
		ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)              
        SETPG8000         

        ld hl,(ovl_start+6)
        ld a,h
        add a,HIGH ovl_start
        ld h,a
		ld a,(_last_image)
		inc a
		call sel_word
        ld a,h
        add a,HIGH ovl_start
        ld h,a
		inc hl ;skip draw effect
		inc hl ;skip image type
		jp load_gfx_to_mem2_buf
		
		
	
draw_effect_conv: db 0,10,10,10,4,5,6,12,13,0,10,11,12,13,   1 ,0,15
_clear_screen_before:

		;##TODO
		;use empty membuf1-2 as empty black  screen
		;we should use another approach because screen scroller use membuf1-2-3-4
				
        push hl
		
		;clear mem_buf 1-2
		call storec000
		call clrsa
		call restorec000
		
		
        ld a,(draw_effect)
        push af

        ld e,a
        ld d,0
        ld hl, draw_effect_conv
        add hl,de
        ld a,(hl)
        ld (draw_effect),a

        ld hl,pal
        ld de,mempal
        ld bc,32
        ldir
        call _memory_output
        pop af
        ld (draw_effect),a
        pop hl
        jp _show_screen_immedatelly		
_it_is_overlay:
		
        call store_name
        call load_gfx_to_scr_buf
        call _sprite_output_mask_no_pal
        jp load_bgnd_anim

			
		
;=========
ENDTEXT
SUBLOCK 
		XOR A
        JP NC,ENDTEXTa
        LD A,#AF
        LD (SUBLOCK),A
RETURN  LD HL,0
        JP _print_ovl
ENDTEXTa:		
		ld a,(first_word)
		and a
		call nz,waitkey_a
		jp WINCLR2
		
WINCLR
		inc hl
		CALL WINCLR1
		xor a
        ld (first_word),a
        JP _print_ovl


WINCLRB:
		CALL WINCLR1
        JP _print_b

WINCLR1 CALL waitkey_a
WINCLR2
        PUSH HL
        CALL _clear_textbox  ;-0-0-3423566400------------------
        POP HL
COOOR   ld bc ,0
        jp _pradd_p
        


WINCLR3
        PUSH HL
        CALL _clear_textbox  ;-0-0-3423566400------------------
        POP HL
        ld bc ,txt_coor_8_4
        jp _pradd
        

LOADSCRIPT2BYTE:
		inc hl
		inc hl
		ld l,(hl)
		bit 7,l
		jr nz,LOADOVL_s  ;128 or greater
		ld h,0
		ld de,256
		add hl,de
		jp LOADOVL_s1
		
LOADSCRIPT:
		inc hl
		ld l,(hl)
LOADOVL_s:		
		ld h,0
		pop de
LOADOVL_s1:		
		;two byte value to dec
		ld de,ovldigitpntr
		call Num2Dec
	
		ld hl,OVLLOAD
        ld de,OVL
        call copystr_hlde
        xor a
        ld (DE),a
        JP BEG
		
Num2Dec:
	ld	bc,-10000
	call	Num3
	ld	bc,-1000
	call	Num3
	ld	bc,-100
	call	Num1
	ld	c,-10
	call	Num1
	ld	c,b

Num1	ld	a,'0'-1
Num2	inc	a
	add	hl,bc
	jr	c,Num2
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret


Num3	ld	a,'0'-1
Num4	inc	a
	add	hl,bc
	jr	c,Num4
	sbc	hl,bc
	ret

	
SELMUSIC
		inc hl
		PUSH HL
        LD A,(HL)
        CALL load_mus
        POP HL
        INC HL
        JP _print_ovl		
		
SHOWSCR:
        call disable_anim
		inc hl
        ld a,(hl)
        inc hl
        push hl
        call _get_show_scr
        pop hl
        jp _print_ovl
		
;## TODO		
LOADSFX:
		inc hl ;sfx num
        push hl

        ld a,(hl)
        push af
        call setcorepage
        pop af
        ld c,10
        call ayfx.PLAY

        ld ix,ayfx.afxChDesc
.wait_for_end
        xor a
        and a,(ix+1)
        and a,(ix+5)
        and a,(ix+9)
        jr nz,.wait_for_end
        call unsetcorepage
        pop hl
		inc hl
		jp _print_ovl
		

LINEFEED:
		inc hl
		push hl
		call _linefeed
		pop hl
		jp _print_ovl
		
LINEFEEDB:
		push hl
		call _linefeed
		pop hl
		jp _print_b
PAUSE
		inc hl
        LD A,(HL)
        LD B,A
        INC HL
        PUSH HL
        RLCA
        LD B,A
PAUSE1  HALT
        HALT
        HALT
        HALT
        DJNZ PAUSE1
        call WINCLR2
        POP HL
        JP _print_ovl
		
F_CALI:	;ADDNUM  
		LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,A
        LD A,(HL)
        ADD A,B
        LD (HL),A
        POP HL
        JP _print_b
		
F_PLUS:	;ADDVAR
		LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,B
        LD B,(HL)
        LD L,A
        LD A,(HL)
        ADD A,B
        LD (HL),A
        POP HL
        JP _print_b
		
F_MINUS	;SUBVAR 
		LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,B
        LD B,(HL)
        LD L,A
        LD A,(HL)
        SUB B
        LD (HL),A
        POP HL
        JP _print_b		
		
F_COPYI:	;LOCLET
		LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,A
        LD (HL),B
        POP HL
        JP _print_b
		
SUBSTRACT 
		LD D,(HL);X
        INC HL
        LD A,(HL)  ;Y
        INC HL
        LD B,(HL)  ;Z
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,A
        LD A,(HL)
        LD L,B
        LD B,(HL)
        SUB B
        LD L,D
        LD (HL),A
        POP HL
        JP _print_b
		
F_COMPI:
;SUBNUM  
		LD D,(HL);X
        INC HL
        LD A,(HL)  ;Y
        INC HL
        LD B,(HL)  ;Z
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,A
        LD A,(HL)
        SUB B
        LD L,D
        LD (HL),A
        POP HL
        JP _print_b

F_AND		
;COMPAND
		LD D,(HL)
        INC HL
        LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,A
        LD A,(HL)
        CP 1
        JP M,.COMPAND1
        LD L,B
        LD A,(HL)
        CP 1
        JP M,.COMPAND1
        LD A,1
        JR .COMPAND1+1
.COMPAND1 XOR A
        LD L,D
        LD (HL),A
        POP HL
        JP _print_b

F_OR:
;COMPOR 
		LD D,(HL)
        INC HL
        LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,A
        LD A,(HL)
        CP 1
        JP P,.COMPOR0
        LD L,B
        LD A,(HL)
        CP 1
        JP P,.COMPOR0
        XOR A
        JR .COMPOR1
.COMPOR0 LD A,1
.COMPOR1 LD L,D
        LD (HL),A
        POP HL
        JP _print_b

F_EXIT:		
;TRUECONT
		LD E,(HL)
        LD D,HIGH LOCVARS
        LD A,(DE)
        AND A
        JP Z,ENDTEXT
        INC HL
        JP _print_b
	
F_RAND:	
;RANDOMIZE
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        PUSH HL
.ll:
        call randr
        cp d
        jr nc,.ll
        LD D,HIGH LOCVARS
        LD (DE),A
        POP HL
        JP _print_b

F_JGR:
ISPOSITIVEGOTO:
        LD E,(HL)
        LD D,HIGH LOCVARS
        INC HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD A,(DE)
        CP 1
        JP M,_print_b      ;A={0 FALSE
        LD A,HIGH ovl_start			;  #40        ;A}0 TRUE
        ADD A,B
        LD  H,A
        LD L,C
        JP _print_b

F_JEQ:
;ISZEROGOTO:
        LD E,(HL)
        LD D,HIGH LOCVARS
        INC HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD A,(DE)
        AND A
        JP NZ,_print_b ;A{}0
        LD A,HIGH ovl_start			;  #40        ;A}0 TRUE
        ADD A,B
        LD  H,A
        LD L,C
        JP _print_b
		
F_JLW:
;ISNEGATIVEGOTO:
         LD E,(HL)
        LD D,HIGH LOCVARS
        INC HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD A,(DE)
        AND A
        JP P,_print_b      ;}=0
        LD A,HIGH ovl_start			;  #40        ;A}0 TRUE
        ADD A,B
        LD  H,A
        LD L,C
        JP _print_b
		
F_JNEQ:
;ISNOTZEROGOTO:
        LD E,(HL)
        LD D,HIGH LOCVARS
        INC HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD A,(DE)
        and a
        JP z,_print_b      ;A={0 FALSE
        LD A,HIGH ovl_start			;  #40        ;A}0 TRUE
        ADD A,B
        LD  H,A
        LD L,C
        JP _print_b
		
F_JR:
;GOTO
		LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        LD A,HIGH ovl_start			;  #40        ;A}0 TRUE
        ADD A,H
        LD H,A
        JP _print_b

G_COPYF:
;GLOBTOLOC
        LD A,(HL);LOC
        INC HL
        LD B,(HL);GLOB
        INC HL
        PUSH HL
        LD H,HIGH GLOBVARS
        LD L,B
        LD C,(HL)
        LD H,HIGH LOCVARS
        LD L,A
        LD (HL),C
        POP HL
        JP _print_b
		
G_COPYG:
;LOCTOGLOB
        LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,B
        LD C,(HL)
        LD H,HIGH GLOBVARS
        LD L,A
        LD (HL),C
        POP HL
        JP _print_b

G_COPYI:
;GLOBLET
		LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH GLOBVARS
        LD L,A
        LD (HL),B
        POP HL
        JP _print_b
		
;###TODO !
SCROLLCG
		inc hl
		ld a,(hl)	;scroll type 5-top image  to bottom image 4-bottom to up 6 - right image to left image 7 -from left image to right image   //check ten_109   scroll 7,6   th_109, th_110  ///ten_041   scroll 7,6 th_041 th_042
		inc hl
		push hl
		ld hl,SCROLLCG_RET_POINT
		push hl
		cp 4
		jp z,_img_to_up
		cp 5
		jp z,_img_to_down
		cp 6
		jp z,_img_to_left
		cp 7
		jp z,_img_to_right
		pop hl
		jp _print_ovl
		
SCROLLCG_RET_POINT
		call waitkey_al
		pop hl
		jp _print_ovl
		
		
C_V_ON:		
;MENUOFF
		LD A,(HL)
        DEC A
        INC HL
        PUSH HL
        LD H,HIGH ACTMENU
        RLCA
        RLCA
        RLCA
        RLCA
        LD L,A
        XOR A
        LD (g_curpos),A
        LD (g_curpos+1),A
        INC A
        LD (HL),A
        POP HL
        JP _print_b

C_V_OFF:
;MENUON 
		LD A,(HL)
        DEC A
        INC HL
        PUSH HL
        LD H,HIGH ACTMENU
        RLCA
        RLCA
        RLCA
        RLCA
        LD L,A
        XOR A
        LD (HL),A
        LD (g_curpos),A
        LD (g_curpos+1),A
        POP HL
        JP _print_b

C_N_ON:
;SUBMENUOFF
        LD A,(HL)
        DEC A   ;;;
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH ACTMENU
        RLCA
        RLCA
        RLCA
        RLCA
        OR B
        LD L,A
        XOR A
        LD (g_curpos+1),A
        INC A
        LD (HL),A
        POP HL
        JP _print_b

C_N_OFF:
;SUBMENUON
        LD A,(HL)
        DEC A   ;;;;;;
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH ACTMENU
        RLCA
        RLCA
        RLCA
        RLCA
        OR B
        LD L,A
        XOR A
        LD (HL),A
        POP HL
        LD (g_curpos+1),A
        JP _print_b


		
		
		
		
;-----------
_menu:
        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)
        SETPG8000 
		
        ;clear stk_menu
        ld hl,STK_MENU
        ld de,STK_MENU+1
        ld bc,355
        ld (hl),0xff
        ldir

        ld hl,ACTMENU
        ld (ACTTMP),hl ;
        ld hl,STK_MENU
        ld (STK_MTMP),hl 
        xor a
        ld (COUNTER),a ;....
		
        ld hl,txt_coor_8_4
        ld (g_atpos),hl   ;...

        ld hl,ovl_start+6	;0x4006 ; pic pointer (limiter)

        ld a,(hl)
        ld (LIMIT1),a ;low  

        inc hl
        ld a,(hl)
        ld b,HIGH ovl_start
        add a,b
        ld (LIMIT2),a ;high

        ld hl,ovl_start+4	;		0x4004 ;tree pointer
        ld b,(hl)
        inc hl
        ld h,(hl)
        ld a,HIGH ovl_start
        add a,h
        ld h,a
        ld l,b ;hl pointer to tree root
_menu1:
        ld a,0
LIMIT2 equ $-1
        cp h
        jr nz,_menu2
        ld a,0
LIMIT1  equ $-1
        cp l
        jp z,SELECTOR ; end of tree
_menu2:
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,d
        or e
        jp z,SELECTOR ;no menu tree

        push hl
        ld bc,0
ACTTMP  equ $-2

        LD A,(BC)
        LD B,A
        LD  A,C
        ADD A,16
        LD (ACTTMP),A
        LD A,B
        AND A
        JP NZ,_menu5     ;NOT ACTIVE
        LD A,#40
        ADD A,D
        LD D,A
        LD HL,0
STK_MTMP EQU $-2
        LD A,(COUNTER)
        LD (HL),A
        INC HL
        LD (HL),E
        INC HL
        LD (HL),D
        INC HL
        LD (STK_MTMP),HL ;
        LD (HL),#FF
        EX DE,HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD A,#40
        ADD A,D
        LD D,A
        INC DE ;SKIP MENUNAME NUM
        EX DE,HL

;---печать названия меню--

        LD BC,(g_atpos)
        CALL _pradd

_menu3:
        LD A,(HL)
        INC HL
        AND A
        JR Z,_menu4
        CP 128
        CALL NC,change_cp        
        SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR _menu3

_menu4:
        LD A,(g_atpos) ;x-coord
        add a,16
        ld (g_atpos),a
        cp 64
        jr c,_menu5

        and 0x3f
        LD (g_atpos),A

        ld a,(g_atpos+1)
        inc a
        ld (g_atpos+1),a
_menu5
        LD A,0
COUNTER EQU $-1
        INC A
        LD (COUNTER),A
        POP HL
        JP _menu1

SELECTOR:



        ld a,8
        ld (_line_lenght),a

        LD DE,STK_MENU
        LD A,(g_curpos)
        LD L,A
        ADD A,A
        ADD A,L
        LD L,A
        LD H,0
        ADD HL,DE
        EX DE,HL

SELS0:
        ld a,(g_curpos)
        ld hl,MENUCURHELPER
        call sel_word
        ld (SELS4),hl

        call _highlight_selected
		
		
		
SELS3:
        call waitkey



        cp key_esc
        jp z,TO_MENU

        cp key_left
        jp z,SELS_keyleft
        cp key_right
        jp z,SELS_keyright


        cp key_up
        jp z,SELS_keyup
        cp key_down
        jp z,SELS_keydown


        cp key_enter
        jp z,SELECTED1
        cp ' '
        jp z,SELECTED1
        jr SELS3        


SELS_keyup:
;        ;de - modified pos in stk_menu
;
        push de        
        pop hl

        ld bc,0xfff4 ;(-12)
        add hl,bc
        ld bc,STK_MENU
        and a
        sbc hl,bc
;        ld  a,h
;        or l
;        jr z,SELS_keyup_c
        jp m,SELS3
;SELS_keyup_c:
        ex de,hl
        ld bc,-12
        add hl,bc
        ex de,hl


        ld hl,(SELS4)
        call _highlight_selected
        ld a,(g_curpos)
        add a,-4
        ld (g_curpos),a
        xor a
        ld (g_curpos+1),a
        jp SELS0


SELS_keydown:
        ;de - modified pos in stk_menu
        push de
        pop hl
        ld bc,12
        add hl,bc
        ld a,(hl)
        inc a
        jr  z,SELS3
        ex de,hl

        ld a,(g_curpos)
        add a,4
        ld (g_curpos),a        
        ld hl,(SELS4)
        call _highlight_selected
        xor a
        ld (g_curpos+1),a        
        jp SELS0   

SELS_keyleft:
        push de        
        pop hl
        ld bc,STK_MENU
        and a
        SBC HL,BC
        ld  a,h
        or l
        jp z,SELS3
        ex de,hl
        ld bc,3
        and a

        sbc hl,bc

        ex de,hl
        ld hl,(SELS4)
        call _highlight_selected
        ld hl,g_curpos
        dec (hl)
        xor a
        ld (g_curpos+1),a
        jp SELS0
SELS_keyright:
        push de
        pop hl
        ld bc,3
        add hl,bc
        ld a,(hl)
        inc a
        jp  z,SELS3
        ex de,hl

        ld hl,g_curpos
        inc (hl)        
        ld hl,0
SELS4   equ $-2
        call _highlight_selected
        xor a
        ld (g_curpos+1),a        
        jp SELS0   
     
SELECTED1:
        push de
        call WINCLR2
        ld hl,ACTMENU
        ld (ACTTMP1),hl
        xor a
        ld (COUNTER),a

        ;clear stk_sub
        ld hl,STK_SUB
        ld de,STK_SUB+1
        ld bc,355
        ld (hl),0xff
        ldir

        LD HL,STK_SUB
        LD (STK_STMP),HL
        LD HL,#1300
        LD (g_atpos),HL        
        POP DE
        LD A,(DE)
        LD (RESULT),A;сохраняем номер выбранного меню
        RLCA
        RLCA
        RLCA
        RLCA
        INC A
        LD (ACTTMP1),A
        INC DE
        LD A,(DE)
        LD L,A
        INC DE
        LD A,(DE)
        LD H,A
        INC HL,HL
        ;HL-TREE          SUBMENU NAMES
SMENU1:
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL,DE
        LD A,D
        OR E
        JP Z,SELECTOR2
        DEC DE
        PUSH HL
        LD BC,0
ACTTMP1 EQU $-2

        LD A,(BC)
        LD B,A
        LD  A,C
        INC A
        LD (ACTTMP1),A
        LD A,B
        AND A
        JP NZ,SMENU5    ;IF NOT ACTIVE
        LD A,0x40
        ADD A,D
        LD D,A
;DE - ADR OF SUBMENU NAME1              ;
        LD HL,0                         ;
STK_STMP EQU $-2                        ;
        LD A,(COUNTER)                  ;
        LD (HL),A                       ;
        INC HL                          ;
        LD (STK_STMP),HL ;              ;
        LD (HL),#FF                     ;

        INC DE ;SKIP MENUNAME NUMBER
        EX DE,HL        
;HL-NAME OF MENUITEM

;---печать названия меню--

        LD BC,(g_atpos)
        CALL _pradd

SMENU3
        LD A,(HL)
        INC HL
        AND A
        JR Z,SMENU4
        CP 128
        CALL NC,change_cp        
        SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR SMENU3

SMENU4:
        LD A,(g_atpos) ;x-coord
        add a,16
        ld (g_atpos),a
        cp 64
        jr c,SMENU5

        and 0x3f
        LD (g_atpos),A

        ld a,(g_atpos+1)
        inc a
        ld (g_atpos+1),a

SMENU5  LD HL,COUNTER
        INC (HL)
        POP HL
        JP SMENU1

SELECTOR2:
        ld hl,(STK_STMP)
        ld de,STK_SUB
        and a
        sbc hl,de
        ld a,h
        or l
        jp z,RESULT1
        ld a,(g_curpos+1)
        ld l,a
        ld h,0
        add hl,de
        ex de,hl

SSELS0:
        ld a,(g_curpos+1)
        ld hl,MENUCURHELPER
        call sel_word
SSELS2:        
        ld (SSELS4),hl
        call _highlight_selected
SSELS3:
        call waitkey
;        cp key_up
;        jr z,SELS_keyup
;        cp key_down
;        jr z,SELS_keydown
        cp key_esc
        jp z,SSELLL


        cp key_left
        jr z,SSELS_keyleft
        cp key_right
        jr z,SSELS_keyright


        cp key_up
        jr z,SSELS_keyup
        cp key_down
        jr z,SSELS_keydown

        cp key_enter
        jr z,SELECTED
        cp ' '
        jr z,SELECTED
        jr SSELS3        


SSELS_keyup:
        push de        
        pop hl
        
        ld bc,-4 ;-1
        add hl,bc
        ld bc,STK_SUB
        and a
        SBC HL,BC
        jp m,SSELS3

        ex de,hl
        ld bc,-4
        add hl,bc
        ex de,hl

        ld hl,(SSELS4)
        call _highlight_selected
        ld a,(g_curpos+1)
        add a,-4
        ld (g_curpos+1),a
        jp SSELS0




SSELS_keydown:
        push de
        pop hl
        
        ld bc,4
        add hl,bc

        ld a,(hl)
        inc a
        jr  z,SSELS3
        ex de,hl

        ld a,(g_curpos+1)
        add a,4
        ld (g_curpos+1),a
        ld hl,(SSELS4)
        call _highlight_selected
        jp SSELS0  




SSELS_keyleft:
        push de        
        pop hl
        ld bc,STK_SUB
        and a
        SBC HL,BC
        ld  a,h
        or l
        jp z,SSELS3
        dec de
        ld hl,(SSELS4)
        call _highlight_selected
        ld hl,g_curpos+1
        dec (hl)
        jp SSELS0
SSELS_keyright:
        push de
        pop hl
        inc hl
        ld a,(hl)
        inc a
        jp  z,SSELS3
        ex de,hl
        ld hl,g_curpos+1
        inc (hl)        
        ld hl,0
SSELS4   equ $-2
        call _highlight_selected
        jp SSELS0  
SELECTED:
        LD A,(DE)
        LD H,A
        PUSH HL
        LD HL,(SSELS4)
        CALL _highlight_selected
        POP HL
RESSULT   LD L,0
RESULT  EQU $-1
;L-MENU NUM H-SUBMENUNUM
        INC H
        INC L
        RET
RESULT1 LD H,#FF
        JR RESSULT
SSELLL:
        pop hl
        jp TXTOUT1
		
		
TO_MENU:
        pop hl

        ld a,2
        ld (_ingame_m_downlimit),a

        ld hl,loc_m1_menu
        ld de,menu_m1_action
        jr _ingame_menu_mnu

_ingame_menu_mnu:

        push hl
        push de

;        ld hl,TABLE_W
;        ld (CODEPAGE),hl
        
        CALL WINCLR2


        LD HL,#1300
        LD (_ingame_m_mnpos),HL

        xor a
        ld (_ingame_m_curpos),a

        pop de
        pop hl

        push de
        ld a,(language)
        call sel_word

        call _prt_ingame_menu

        call _sel_ingame_menu

        pop hl

        cp 0xff
        jp z,TO_MENU_ESC
        call sel_word
        jp (hl)
TO_MENU_ESC
       ; pop hl ; ;;??????
        ;ld hl,TABLE_W
        ;ld (CODEPAGE),hl       
        jp TXTOUT1


_confirm_quit:
        ld a,1
        ld (_ingame_m_downlimit),a

        ld  hl,loc_m2_menu
        ld  de,menu_m2_action
        jp _ingame_menu_mnu
_ram_save:
        ld a,4
        ld (_ingame_m_downlimit),a

        ld  hl,loc_save_menu_ingame
        ld  de,loc_save_menu_ingame_action
        jp _ingame_menu_mnu
_ram_load:
        ld a,4
        ld (_ingame_m_downlimit),a
        
        ld  hl,loc_load_menu_ingame
        ld  de,loc_load_menu_ingame_action
        jp _ingame_menu_mnu
		
		
		
;-----------------------
_prt_ingame_menu:
        ld bc,0
_ingame_m_mnpos: equ $-2
        call _pradd
prt_ingame_m1:
        ld a,(hl)
        inc hl
        and a
        RET Z
        cp 1
        JR Z,prt_ingame_m2
        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2        
        SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR prt_ingame_m1
prt_ingame_m2:
        LD A,(_ingame_m_mnpos) ;x-coord
        add a,16
        ld (_ingame_m_mnpos),a
        cp 64
        jr c,_prt_ingame_menu
        and 0x3f
        LD (_ingame_m_mnpos),A
        ld a,(_ingame_m_mnpos+1)
        inc a
        ld (_ingame_m_mnpos+1),a
        JR _prt_ingame_menu
;------------------------------------

_sel_ingame_menu:
        ld a,0
_ingame_m_curpos equ $-1
        ld hl,MENUCURHELPER
        call sel_word
        ld (_sel_ingame_SELS4),hl
        call _highlight_selected
_sel_ingame_SELS3:        
        call waitkey

        cp key_esc
        jp z,_sel_ingame_esc

        cp key_left
        jr z,_sel_ingame_SELS_keyleft
        cp key_right
        jr z,_sel_ingame_SELS_keyright

        cp key_up
        jr z,_sel_ingame_SELS_keyup
        cp key_down
        jr z,_sel_ingame_SELS_keydown

        cp key_enter
        jr z,_sel_ingame_SELECTED
        cp ' '
        jr z,_sel_ingame_SELECTED
        jr _sel_ingame_SELS3        
_sel_ingame_esc:
        ld hl,0
_sel_ingame_SELS4: equ $-2
        call _highlight_selected
        ld a,0xff
        ret
_sel_ingame_SELS_keyleft:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 

        ld hl,_ingame_m_curpos
        ld a,(hl)
        and a
        jp z,_sel_ingame_menu
        dec (HL)
        jp _sel_ingame_menu


_sel_ingame_SELS_keyright:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 
        ld hl,_ingame_m_curpos
        ld a,(hl)

        cp 0
_ingame_m_downlimit: EQU $-1        

        jp nc,_sel_ingame_menu
        inc (hl)
        jp _sel_ingame_menu
_sel_ingame_SELECTED:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected
        ld a,(_ingame_m_curpos)
        ret


_sel_ingame_SELS_keyup:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 


        ld hl,_ingame_m_curpos
        ld a,(hl)
        sub 4
        jp m,_sel_ingame_menu        
        ld (hl),a
        jp _sel_ingame_menu

_sel_ingame_SELS_keydown:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 

        ld a,(_ingame_m_downlimit)
        inc a
        ld b,a

        ld hl,_ingame_m_curpos
        ld a,(hl)
        add a,4
        sub b       
        jp p,_sel_ingame_menu        
        add a,b
        ld (hl),a

        jp _sel_ingame_menu
		
		
_save_slot_1:
        ld a,1
        jr _save_slot
_save_slot_2:
        ld a,2
        jr _save_slot
_save_slot_3:
        ld a,3
        jr _save_slot
_save_slot_4:
        ld a,4
        jr _save_slot
_save_slot_5:
        ld a,5
_save_slot:
        add a,"0"
        ld (SAVETEMPL_N),a

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
        ld hl,buf
        ld de,buf+1
        ld bc,537
        ld (hl),0
        ldir            ;clear buffer

        call globals_to_save

        ld hl,538 ;len
        ld de,buf ;addr
        call savestream_file
        or a
        jp nz,filewriteerror 

        call closestream_file        
        jp TO_MENU_ESC



_load_slot_1:
        ld a,1
        jr _load_slot_o
_load_slot_2:
        ld a,2
        jr _load_slot_o
_load_slot_3:
        ld a,3
        jr _load_slot_o
_load_slot_4:
        ld a,4
        jr _load_slot_o
_load_slot_5:
        ld a,5
_load_slot_o:
        add a,"0"
        ld (SAVETEMPL_N),a

        ld de,SAVETEMPL
        call openstream_file
        or a
        jp nz,TO_MENU_ESC

        call disable_anim

        ld a,(mus_mode)
        and a
        jp z,_load_common

        call setcorepage
        ld a,(tsfm_detected)
        and a
        call nz,set_ay1
        ld hl, sfxdata
        call   ayfx.INIT
        ld a,(tsfm_detected)
        and a
        call nz,set_ay0
        call unsetcorepage
        jp _load_common

GAMEOVER:
		call disable_anim
		call WINCLR2
		call setcorepage
        ld a,0xff
        ld (old_mus),a
		call no_mus
		
		ld a,(language)
		ld hl,gameover_message_tbl
		call sel_word
		call _print_b

		pop hl:nop:nop
		
		call palette_precalc
        call fade_toblack

       CALL clear_whole_screen
	   
       JP begin1

halt_wait:
;in b = sec to wait
		ld c,50
.hw1:		
	    HALT
		dec c
		jr nz,.hw1
		djnz halt_wait
		ret
ENDING:
		call disable_anim
		ld a,(eyes_table)
		ld (.t_e_t),a
				
		ld a,print_p_len
		ld (_print_b.set_pLen),a
		
		call setcorepage

		
		ld hl,credits_img1
        call load_gfx_to_load_buf
		call _immed_big_core		

		
		ld hl,credits_img2
        call load_gfx_to_load_buf
        call _immed_overlay_big_routine
		
		
		call waitkey_al
		
		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		call fade_to_sub
        ld hl,credits_img3
        call load_big_img_dark2		
		ld hl,credits_img3a
        call load_gfx_to_load_buf
        call _immed_overlay_big_routine		

		ld bc,credits_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p		
		ld hl,credits_txt_1
		call _print_b
		
        call palette_precalc_sub		
		ld hl,0x2cdd
		xor a
		call fade_from_sub
		
		


		ld b,6
		call halt_wait

		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		call fade_to_sub
        ld hl,credits_img4
        call load_big_img_dark2		
		ld hl,credits_img4a
        call load_gfx_to_load_buf
        call _immed_overlay_big_routine		
		
		ld bc ,credits_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p		
		ld hl,credits_txt_2
		call _print_b
		
        call palette_precalc_sub
		ld hl,0x2cdd
		xor a
		call fade_from_sub







		ld b,6
		call halt_wait

		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		call fade_to_sub
        ld hl,credits_img5
        call load_big_img_dark2		
		ld hl,credits_img5a
        call load_gfx_to_load_buf
        call _immed_overlay_big_routine		

		ld bc ,credits_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p		
		ld hl,credits_txt_3
		call _print_b
		
        call palette_precalc_sub
		ld hl,0x2cdd
		xor a
		call fade_from_sub


		ld b,6
		call halt_wait


		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		call fade_to_sub
        ld hl,credits_img6
        call load_big_img_dark2		
		ld hl,credits_img6a
        call load_gfx_to_load_buf
        call _immed_overlay_big_routine		

		ld bc ,credits_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p		
		ld hl,credits_txt_4
		call _print_b
		
        call palette_precalc_sub
		ld hl,0x2cdd
		xor a
		call fade_from_sub


		ld b,6
		call halt_wait

		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		call fade_to_sub
        ld hl,credits_img7
        call load_big_img_dark2		
		ld hl,credits_img7a
        call load_gfx_to_load_buf
        call _immed_overlay_big_routine		

		ld bc ,credits_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p		
		ld hl,credits_txt_5
		call _print_b
		
        call palette_precalc_sub
		ld hl,0x2cdd
		xor a
		call fade_from_sub


		ld b,6
		call halt_wait

		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		call fade_to_sub
        ld hl,credits_img8
        call load_big_img_dark2		
		ld hl,credits_img8a
        call load_gfx_to_load_buf
        call _immed_overlay_big_routine		

		ld bc ,credits_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p		
		ld hl,credits_txt_6
		call _print_b
		
        call palette_precalc_sub
		ld hl,0x2cdd
		xor a
		call fade_from_sub


		ld b,6
		call halt_wait

		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		call fade_to_sub
        ld hl,credits_img9
        call load_big_img_dark2		

		ld bc ,credits_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p		
		ld hl,credits_txt_7
		call _print_b
		
        call palette_precalc_sub
		ld hl,0x2cdd
		xor a
		call fade_from_sub

		call waitkey_al
.t_e_t = $+1
		ld a,0
		ld (eyes_table),a

		pop hl

		call palette_precalc
		call fade_toblack
		CALL clear_whole_screen

        ld a,0xff
        ld (old_mus),a
		call no_mus

		JP begin1
		
