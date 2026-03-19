;1251

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
        EX (SP),HL ;de="hl", в стеке "de"
        LD (on_int_jp),HL
        LD (on_int_sp),SP


        LD SP,sp_alt
        push af

;        ld a,0x80
;        ld r,a




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
                ld (prev_on_int),hl
         
insspp
;         ld a,(int_proc)
;         ld (c_stor),a
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


;        ld a,1
;        out (0xfe),a

        ld a,(setpalflag)
        or a
        call nz,setpal_proc


;        ld a,0xf3
;        ld (0x003f),a

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


        ld a,0
petals_key: equ $-1
        and a
        call nz,petals_draw





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
          ;call setmusicpage
          
     

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
flg_if_error:
        ld hl,txt_unkflag
        jr openerror
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

        ld hl,t_s98_file00_pages_list+$FF 
        call free_s98_file

        ld a,(load_buf1)
        ld e,a
        OS_DELPAGE

        ld a,(load_buf2)
        ld e,a
        OS_DELPAGE


        ld a,(scr_buf1)
        ld e,a
        OS_DELPAGE

        ld a,(scr_buf2)
        ld e,a
        OS_DELPAGE

        ld a,(mem_buf1)
        ld e,a
        OS_DELPAGE

        ld a,(mem_buf2)
        ld e,a
        OS_DELPAGE


        ld a,(font_page)
        ld e,a
        OS_DELPAGE


        ld a,(plr_page)
        ld e,a
        OS_DELPAGE

        ld a,(plr_page2)
        ld e,a
        OS_DELPAGE

        ld a,(plr_page3)
        ld e,a
        OS_DELPAGE


        ld a,(anim_slot03)
        ld e,a
        OS_DELPAGE

        ld a,(anim_slot47)
        ld e,a
        OS_DELPAGE

        ld a,(anim_slot811)
        ld e,a
        OS_DELPAGE

        ld a,(core_page)
        ld e,a
        OS_DELPAGE

;        ld a,0xfb  ;ei
;        ld (0x003f),a


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


/////------        call load_s98_file      ;de=drive/path/file

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
                jp nz,memory_error
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

               // sub 16   ; !!!!! помним что счётчик расроркается не с 0 а с+16

                ld c,$FF
                ld (bc),a
                                
;-------------------------------------------------------
; загрузили все куски музыки.
;теперь нужно  скопировать првый банк в plr_page3 и прести инициаоищацию плеера
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                call closestream_file


                call store8000c000
;подключаем в 8000  пераую страницу загруженной музыки
                ld hl,t_s98_file00_pages_list
                ld a,(hl)
                SETPG8000
                ld a,(plr_page3)
                SETPGC000

;копируем эту страницу в plr_page3. Это нужно для начальной инициализации трека.
                ld hl,0x8000
                ld de,module
                ld bc,16384
                ldir

; в  plrpage  помещаем список страниц с музыкой. 
                ld a,(plr_page)
                SETPGC000
                ld hl,t_s98_file00_pages_list
                ld de,0xc100         ;0x5000
                ld bc,256
                ldir

         ;       DI

;инициалbизируем музыку. 
                call restore8000c000

                call set_music_pages

                ld hl,module
                ld (0x4001),hl
                call PLR_INIT        ;init music

          ;      EI
;----------------
;eloop           halt ;YIELD
;                call PLR_PLAY
;                jr eloop
;----------------


;!!!!!!!!!!

;запускаем плеер. 
                ld a,(plr_page)
                ld hl,PLR_PLAY
                OS_SETMUSIC         



                jp unset_music_pages
                

memory_error: 
        jp memoryerror
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
set_music_pages:

        ld a,(curpg4000)        
        ld (zbank1),a
        ld a,(curpg8000)
        ld (zbank2),a
        ld a,(curpgc000)        
        ld (zbank3),a

plr_page=$+1
        ld a,0
        SETPG4000
plr_page2=$+1
        ld a,0
        SETPG8000
plr_page3=$+1
        ld a,0
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
setfontpage:
        push af
        push bc
        
        ld a,(curpg8000)
        ld (tfbank2),a
        ld a,(font_page)
        SETPG8000
        pop bc
        pop af
        ret


unsetfontpage:
        ld a,0
tfbank2 equ $-1
        SETPG8000
        ret

;---------------------
unsetslotpage:
abank2=$+1
        ld a,0
        SETPG8000
        ret

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
;---------------------
store8000c000
        push af
        ld a,(curpg8000)
        ld (tcbank2),a
        ld a,(curpgc000)
        ld (tcbank3),a
        pop af
        ret

restore8000c000
        ld a,0
tcbank2 equ $-1
        SETPG8000
        ld a,0
tcbank3 equ $-1
        SETPGC000        
        ret
;========================
storec000
        ld a,(curpgc000)
        ld (tc2bank3),a
        ret

restorec000
        ld a,0
tc2bank3 equ $-1
        SETPGC000        
        ret
;========================
store8000
        ld a,(curpg8000)
        ld (t82bank2),a
        ret

restore8000
        ld a,0
t82bank2 equ $-1
        SETPG8000        
        ret
;========================
store4000
        ld a,(curpg4000)
        ld (t42bank1),a
        ret

restore4000
        ld a,0
t42bank1 equ $-1
        SETPG4000        
        ret
store4000l
        ld a,(curpg4000)
        ld (t42bank1l),a
        ret

restore4000l
        ld a,0
t42bank1l equ $-1
        SETPG4000        
        ret
;========================
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




outtype2 db 0   ;"P' т®Ў·б¬  пёЁбіј. 'N' в¦§ пёЁті«Ё  '8' т°± к°Ќ
outtyp   db 0



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
         DB 186,188 ;РЎвЂ° РЎР‰        141 142
         DS 15,32
         DB 186,188 ;РЎвЂ° РЎР‰        158 159
         DB 189,190,191,192,193,129,130,131,132,133,134,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154
         DB 155,156,157,158,159,160,161,162,163,164,165,166,194,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185
         DB 186,188,189,190,191,192,193
         DS 6,32
         DB 143
         DB 32,32,150 ;Р Тђ
         DB 32,154,155
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
introduction
        ;---load resources
        ; '1' - load image

        ld hl,TABLE_J
        ld (CODEPAGE),hl

        ld hl,intro_pic
;        call load_gfx_to_load_buf

        call load_big_img_dark2
        call palette_precalc


        ld hl,into_text
        call load_ovl_to_script_buf
        call fade_fromblack

        call setcorepage




        ;ld a,200-32

        xor a
        ld b,200-32
        ld c,(320-8+2)/2
        call leaf_init
        call unsetcorepage
        ld a,1
        ld (petals_key),a



        ld hl,ovl_start
        ld bc,0x1502
        call _pradd
        call _ppp
        ld a,1
        ld (intro_),a
        ld a,2
        ld (petals_key),a
        ret



_ppp:
        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)
        SETPG8000 

        ld a,(hl)
        inc hl
        cp 32
        jr  c,_ppp1
        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2
        sub 32
_ppp_o:        
        push hl
        call _type
        pop hl

        ld b,10
_ppp_o1        
        halt
        call getkey
        cp NOKEY
        jp nz,_ppp_exit        
        djnz _ppp_o1
        jr _ppp



_ppp1:  cp 3      ;3 end of text
        jp z,_ppp_exit

        cp 0x0a   ;0x0a next line
        jr z,_ppp_line_feed

        and a     ;0?  0 +0 end of line. pause.
        jr z,_ppp2

        ld a,"?"  ;unknown opcode print '?' char
        jr _ppp_o
_ppp2:        
        ld a,(hl)
        inc hl
        and a   ; second 0
        jr nz,_ppp



;double zero. end of line. pause.
        ld b,245
_ppp_halt_loop:
        halt
        call getkey
        cp NOKEY
        jr nz,_ppp_exit
_ppp_p2:
        djnz _ppp_halt_loop

        push hl

        call _clear_textbox
        ld bc,0x1502
        call _pradd

        pop hl

        jr _ppp



_ppp_line_feed:
        push hl
        ld bc,(CORDS)
        inc b
        ld c,0
        call _pradd
        pop hl
        jp _ppp


_ppp_exit:
;        jp clear_whole_screen
        jp fade_toblack
        
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;лЎЄбЅ­у¬Ў¬б¤Ё е¬ї пў«ж¤·ж®Ё оЎўй¤ нЅ¦н¶ рђ¬ 
_precache:
        LD IX,ILINK
        LD A,1
        LD (MM),A
        LD (SM),A
        LD HL,#4000
        LD L,(HL)  ;adress SCTBL table
        LD E,(HL)  ;
        INC HL      ;
        LD D,(HL)    ;get first value of SCTBL table
        LD HL,#4002 
        LD L,(HL)    ;adress of next element after SCTBL table (MSGTBL)
        INC DE
        LD A,E
        OR D
        RET Z       ;return if first value of SCTBL == -1  (no menu)
        DEC DE
        LD A,E
        OR D
        RET Z      ;return if first value of SCTBL == 0  (no menu)
        LD A,E
        CP (HL)
        JR NZ,$+6
        INC HL
        LD A,D
        CP (HL)
        RET Z     ;return if SCTBL is over (pointer set to MSGTBL value)
        LD HL,#4004
        LD L,(HL)   ; get adress COMTBL table
        LD E,(HL)
        INC HL
        LD D,(HL)  ;get first value of COMTBL table
        LD A,D
        OR E
        RET Z      ;return if first value of COMTBL table == 0 (no menu)
        DEC HL              
        LD (TREEE),HL      ;hl = COMTBL table
        LD DE,#4006
        LD A,(DE)
        LD (LIMIT4),A;LOW
        LD A,D
        LD (LIMIT3),A;HI   adress next to COMTBL (begin of VNTBL table) 
        LD DE,#4000
        LD A,(DE)
        LD E,A              
        LD (STRUCTURE),DE    ;DE = SCTBL table
PRECAH  LD HL,(TREEE)
        LD A,H
        CP 0
LIMIT3  EQU $-1
        JR NZ,PRECAH1
        LD A,L
        CP 0
LIMIT4  EQU $-1
        RET Z   ;END OF TREE - end of COMTBL

PRECAH1                   ;перебираем записи в COMTBL 
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD A,#40
        ADD A,D
        LD D,A       ; получили адрес описателя текущего пункта меню в таблице CM

        LD A,(DE)
        LD (STORE),A   
        INC DE
        LD A,(DE)
        LD (STORE+1),A ;получили и сохранили адрес расположения номера текущего пункта меню и его наименования. (num + name + eol(0))
        INC DE
        LD A,(DE)
        INC A
        JR NZ,PRECAH2   ;если есть подменю переходим на PRECAH2
        INC DE
        LD A,(DE)
        INC A
        JR Z,PRECAH3 ;;если нет подменю переходим на PRECAH3
        DEC DE

PRECAH2 LD A,(DE)  ;обрабатывваем подменю текущего пункта меню.
        LD (STORE1),A
        INC DE
        LD A,(DE)
        LD (STORE1+1),A
        DEC DE
        PUSH DE
        LD A,4
        CALL SEARCHING
        LD A,1    ;пишем в ILINK  .номер пункта меню (нач с 1), 
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
        INC (HL)          ;увеличиваем счётчик номера текущего пункта главного меню на 1
        LD HL,0
TREEE   EQU $-2
        INC HL,HL
        LD (TREEE),HL    ;переходим к следующему элементу таблицы COMTBL
        JP PRECAH
PRECAH3 LD HL,#FFFF
        LD (STORE1),HL ;пометили что подменю нет записав в указатель на поиск по подменю -1
        LD A,2
        CALL SEARCHING
        LD A,(MM)           ;пишем в ILINK  .номер пункта меню (нач с 1), 
        LD (IX),A
        INC IX
        XOR A
        LD (IX),A            ;подменю - 0 (тсутствуют)
        INC IX
        LD (IX),L
        INC IX
        LD (IX),H            ;адрес в SCTBL
        INC IX
        JR PRECAH4
STORE   DW 0
STORE1  DW 0

SEARCHING              ;ищет сопадение vv адреса из s описателей SCTBL с аналогичным указателем vv из COMTBL
          LD (SEAR2-1),A
          LD HL,0
STRUCTURE EQU $-2           ; hl= SCTBL adress
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

;PRINT ROUTEINES WITH TOKENS
_print
        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)
        SETPG8000 


        LD A,(HL)
        INC HL
        CP 32
        JR C,PRINT1
        CP "%"
        JR Z,_print_hero_name

        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2

PRINT0  SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR _print

PRINT1  PUSH HL
        LD HL,TOKENTABLE
        LD C,A
PRINT2  LD A,(HL)
        INC HL
        CP 255
        JR Z,PRINT4     ;END OF TABLE
        CP C
        JR Z,PRINT3     ;CODE FOUND
        INC HL
        INC HL
        JR PRINT2
PRINT3  LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        EX (SP),HL
        RET
PRINT4  POP HL
        JR _print


PRINT5  LD C,A
PRINT6  LD A,(HL)
        INC HL
        CP 255
        JR Z,PRINT8     ;END OF TABLE
        CP C
        JR Z,PRINT7     ;CODE FOUND
        INC HL
        INC HL
        JR PRINT6
PRINT7  LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        EX (SP),HL
        RET
PRINT8  POP HL
        JP _print

_print_hero_name
        INC HL,HL,HL
        PUSH HL

        ld hl,TABLE_W
        ld (CODEPAGE),HL


        
        ld a,(language)
        ld hl,loc_hero_name
        call sel_word    ;hl - point to localized name

PRINTA  LD A,(HL)
        INC HL
        AND A
        JR Z,PRINTB

        CP 128
        CALL NC,change_cp

        SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR PRINTA
PRINTB  LD HL,TABLE_J
        ld (CODEPAGE),HL
        POP HL
        JP _print        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TOKENTABLE
        DB 00
        DW ENDTEXT                              ;++++
        DB 01
        DW WINCLR  ;IF PRESSED KEY              ;++++
        DB 03
        DW _print   ;SKIP UNKNOWN COMMAND       ;++++
        DB 04
        DW LOADOVL  ;04NAM_000.OVL              ;++++
        DB 06
        DW SELMUSIC ;07XX                       ;++++
        DB 08
        DW WAITKEY_SUB                          ;++++
        DB #0A
        DW LINEFEED                             ;++++
        DB #0F
        DW EXITLIGHT                            ;-
        DB #10
        DW EXITDARK     ;GAME OVER              ;++++
        DB #16
        DW FLASH ;#16XX XX-BLINKS               ;++++
        DB #17
        DW PAUSE                                ;++++
        DB #18
        DW SHAKE ;#18XX XX-SHAKES               ;++++
        DB #0B
        DW GROUP0B
        DB #0C
        DW GROUP0C
        DB #12
        DW GROUP12
        DB #13
        DW GROUP13
        DB #14
        DW GROUP14
        DB #15
        DW GROUP15
        DB #FF
TOKENTABLE0C
             DB 01
             DW GLOBTOLOC                       ;++++
             DB 02
             DW LOCTOGLOB                       ;++++
             DB 03
             DW GLOBLET                         ;++++
             DB 255

TOKENTABLE0B
        DB 01
        DW ADDNUM                               ;++++
        DB 2
        DW ADDVAR                               ;++++
        DB 3
        DW SUBVAR                               ;++++
        DB 5
        DW LOCLET                               ;++++
        DB 6
        DW SUBSTRACT                            ;++++
        DB 7
        DW SUBNUM                               ;++++
        DB 8
        DW COMPAND                              ;++++
        DB 9
        DW COMPOR                               ;++++
        DB #0A
        DW TRUECONT                             ;++++
        DB #0B
        DW GRPAND                               ;++++
        DB #0C
        DW GRPOR                                ;++++
        DB #14
        DW RANDOMIZE                            ;++++
        DB #32
        DW ISPOSITIVEGOTO                       ;++++
        DB #33
        DW ISZEROGOTO                           ;++++
        DB #34
        DW ISNEGATIVEGOTO                       ;++++
        DB #35
        DW ISNOTZEROGOTO                         ;++++
        DB #36
        DW GOTO                                 ;++++
        DB #39
        DW EXPANDGOTO                           ;++++
        DB 255
TOKENTABLE12
        DB 01
        DW MENUOFF                              ;????
        DB 02
        DW MENUON                               ;????
        DB 04
        DW SUBMENUOFF                           ;????
        DB 05
        DW SUBMENUON                            ;????
        DB 255
TOKENTABLE13
        DB 01
        DW SCREENLOAD1                          ;++++
        DB 02
        DW SCREENOUTPUT1                        ;++++
        DB 03
        DW SPRITELOAD1
        DB 04
        DW SCREENLOAD2                          ;++++
        DB #0F
        DW RESTOREBGND                          ;++++
        DB #10
        DW STOREBGND                            ;++++
        DB 255
TOKENTABLE14
        DB 01
        DW CLRVARS                              ;+++++
        DB 03
        DW CLRSCREEN                            ;+++++
        DB 255
TOKENTABLE15  ;GROUP15 IS IGNORING
        DB 01
        DW LOADANIM                             ;++++
        DB 03
        DW ANIMON                               ;++++
        DB 04
        DW ALLANIMOFF                           ;++++
        DB 05
        DW ANIM_INIT                              ;++++
        DB 255
GROUP0C LD DE,TOKENTABLE0C
        JR GROUPS
GROUP0B LD DE,TOKENTABLE0B
        JR GROUPS
GROUP12 LD DE,TOKENTABLE12
        JR GROUPS
GROUP13 LD DE,TOKENTABLE13
        JR GROUPS
GROUP14 LD DE,TOKENTABLE14
        JR GROUPS
GROUP15 LD DE,TOKENTABLE15
GROUPS  LD A,(HL)
        INC HL
        PUSH HL
        EX DE,HL
        JP PRINT5
ENDTEXT
SUBLOCK XOR A
        JP NC,WINCLR1
        LD A,#AF
        LD (SUBLOCK),A
RETURN  LD HL,0
        ;CALL WINCLR1
        JP _print


;=;=;=;=;=;=;=;=;=;=;
SELMUSIC PUSH HL
        LD A,(HL)
        CALL load_mus
        POP HL
        INC HL
        JP _print
;;;;====
WAITKEY_SUB
;TODO  - add  'wait' animation enable | disable
        push hl
        call waitkey_al
        pop hl 
        jp _print
;;;;====
LINEFEED LD BC,(CORDS)
         INC B
        LD C,0
         CALL _pradd
         JP _print
;;;;====
WINCLR  CALL WINCLR1
        JP _print

WINCLR1 CALL waitkey_a
WINCLR2
        PUSH HL
        CALL _clear_textbox  ;-0-0-3423566400------------------
        POP HL
COOOR   LD BC,#1300
        CALL _pradd
        ret
;;;;;;=====
LOADOVL POP DE
        ld de,OVL
        call copystr_hlde
        xor a
        ld (DE),a
        JP BEG
;;;;;;=====
PAUSE
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
        POP HL
        JP _print
;;;;;-------------

GLOBTOLOC
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
        JP _print

LOCTOGLOB
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
        JP _print

GLOBLET LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH GLOBVARS
        LD L,A
        LD (HL),B
        POP HL
        JP _print        

LOCLET LD A,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,A
        LD (HL),B
        POP HL
        JP _print

ADDNUM  LD A,(HL)
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
        JP _print
ADDVAR  LD A,(HL)
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
        JP _print

SUBVAR  LD A,(HL)
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
        JP _print

SUBNUM  LD D,(HL);X
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
        JP _print

SUBSTRACT LD D,(HL);X
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
        JP _print

COMPAND LD D,(HL)
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
        JP M,COMPAND1
        LD L,B
        LD A,(HL)
        CP 1
        JP M,COMPAND1
        LD A,1
        JR COMPAND1+1
COMPAND1 XOR A
        LD L,D
        LD (HL),A
         POP HL
        JP _print

COMPOR  LD D,(HL)
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
        JP P,COMPOR0
        LD L,B
        LD A,(HL)
        CP 1
        JP P,COMPOR0
        XOR A
        JR COMPOR1
COMPOR0 LD A,1
COMPOR1 LD L,D
        LD (HL),A
        POP HL
        JP _print


GRPAND  LD B,(HL)
        DEC B
        INC HL
        LD D,(HL)
        INC HL
GRPAND0 LD E,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,D
        LD A,(HL)
        CP 1
        JP M,GRPAND1
        LD L,E
        LD A,(HL)
        CP 1
        JP M,GRPAND1
        LD A,1
        JR GRPAND1+1
GRPAND1 XOR A
        LD L,D
        LD (HL),A
        POP HL
        DJNZ GRPAND0
        JP _print

GRPOR   LD B,(HL)
        DEC B
        INC HL
        LD D,(HL)
        INC HL
GRPOR0 LD E,(HL)
        INC HL
        PUSH HL
        LD H,HIGH LOCVARS
        LD L,D
        LD A,(HL)
        CP 1
        JP P,GRPOR2
        LD L,E
        LD A,(HL)
        CP 1
        JP P,GRPOR2
        XOR A
        JR GRPOR1
GRPOR2  LD A,1
GRPOR1  LD L,D
        LD (HL),A
        POP HL
        DJNZ GRPOR0
        JP _print

TRUECONT LD E,(HL)
         LD D,HIGH LOCVARS
         LD A,(DE)
         AND A
         JP Z,ENDTEXT
;        CP 1
;        JP M,ENDTEXT
         INC HL
         JP _print

GOTO    LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        LD A,#40
        ADD A,H
        LD H,A
        JP _print

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
        JP M,_print      ;A={0 FALSE
        LD A,#40        ;A}0 TRUE
        ADD A,B
        LD  H,A
        LD L,C
        JP _print

ISZEROGOTO:
        LD E,(HL)
        LD D,HIGH LOCVARS
        INC HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD A,(DE)
        AND A
        JP NZ,_print ;A{}0
        LD A,#40        ;A=0
        ADD A,B
        LD  H,A
        LD L,C
        JP _print

ISNEGATIVEGOTO:
         LD E,(HL)
        LD D,HIGH LOCVARS
        INC HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD A,(DE)
        AND A
        JP P,_print      ;}=0
        LD A,#40    ;{0
        ADD A,B
        LD  H,A
        LD L,C
        JP _print

ISNOTZEROGOTO:
        LD E,(HL)
        LD D,HIGH LOCVARS
        INC HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD A,(DE)
        and a
        JP z,_print      ;A={0 FALSE
        LD A,#40        ;A}0 TRUE
        ADD A,B
        LD  H,A
        LD L,C
        JP _print 

EXPANDGOTO
        LD E,(HL)
        LD D,HIGH LOCVARS
        LD A,(DE)
        ADD A,A
        INC HL
        LD D,0
        LD E,A
        ADD HL,DE
        LD C,(HL)
        INC HL
        LD B,(HL)
        EX DE,HL
        LD A,#40
        ADD A,B
        LD H,A
        LD L,C

EXP_GT1 INC DE
        LD A,(DE)
        CP #FF
        JR NZ,EXP_GT1
        INC DE
        LD A,(DE)
        CP #FF
        JR NZ,EXP_GT1
        INC DE
        ;ex de,hl
        LD (RETURN+1),DE
        LD A,#37
        LD (SUBLOCK),A
        JP _print

RANDOMIZE
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
        JP _print
randr:
;SEED    LD HL,26356
;        LD B,H
;        ld C,L
;        DB "))))"
;        ADD HL,BC
;        LD BC,20981
;        ADD HL,BC
;        LD (SEED+1),HL
;        LD A,H
;        ADD A,D
;        JR NC,$-1
;        ret
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
;randData dw 0
;-------------------------------------
MENUOFF LD A,(HL)
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
        JP _print

MENUON  LD A,(HL)
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
        JP _print

SUBMENUOFF
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
        JP _print

SUBMENUON
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
        JP _print

;LOAD SCREEN TO BUFFER & OUTPUT
SCREENLOAD1
        INC HL,HL
        LD A,(HL) ;DELAY
        LD (DELAY),A
        INC HL,HL
        LD A,(HL)
        LD (outtyp),A

        INC HL


        push hl
        call load_gfx_to_load_buf

        call setcorepage
        call _buffer_output_kernel
        call unsetcorepage
        
        pop hl

        ld de,buf
        call copystr_hlde
        inc hl
        JP _print

SCREENOUTPUT1A:
;out load buffer to screen by mask index8
        INC HL
        LD A,(HL) ;DELAY
        LD (DELAY),A
        INC HL,HL
        LD A,(HL)
        LD (outtyp),A
        INC HL
        LD A,(HL)
        INC HL,HL
        PUSH HL
        CP 3       ;SELECTOR 3-FROM OUTPUT BUFER
        JR Z,scrop2m   ;         4- FROM MEMORY BUFFER
        CALL _memory_output_mask
        JR scrop1
scrop2m:
        call setcorepage
        CALL _buffer_output_mask_kernel
        call unsetcorepage
scrop1m:
        POP HL
        JP _print

SCREENOUTPUT1  ;SHOW FROM BUFFERS
        INC HL
        ld a,(hl)
        cp 8
        jr z,SCREENOUTPUT1A

        INC HL
        LD A,(HL) ;DELAY
        LD (DELAY),A
        INC HL,HL
        LD A,(HL)
        LD (outtyp),A
        INC HL
        LD A,(HL)
        INC HL,HL
        PUSH HL
        CP 3       ;SELECTOR 3-FROM OUTPUT BUFER
        JR Z,scrop2   ;         4- FROM MEMORY BUFFER
        CALL _memory_output
        JR scrop1
scrop2:
        call setcorepage
        CALL _buffer_output_kernel
        call unsetcorepage
scrop1:
        POP HL
        JP _print
;--------------------
;LOAD SCREEN TO MEMORY
SCREENLOAD2
        INC HL,HL

        push hl
        call load_gfx_to_mem_buf

        pop hl

        ld de,buf
        call copystr_hlde
        inc hl
        JP _print

;-----CLR GLOB VARS----
CLRVARS  LD B,(HL)
         XOR A
         INC HL
CLRVARS1 LD E,(HL)
         LD D,HIGH GLOBVARS
         LD (DE),A
         INC HL
         DJNZ CLRVARS1
        JP _print
;--------------------------
;==========================
_menu:
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
        ld hl,0x1300
        ld (g_atpos),hl   ;...

        ld hl,0x4006 ; pic pointer (limiter for COMTBL) VNTBL

        ld a,(hl)
        ld (LIMIT1),a ;low  

        inc hl
        ld a,(hl)
        ld b,0x40
        add a,b
        ld (LIMIT2),a ;high

        ld hl,0x4004 ;tree pointer
        ld b,(hl)
        inc hl
        ld h,(hl)
        ld a,0x40
        add a,h
        ld h,a
        ld l,b ;hl pointer to tree root (first element of COMTBL)
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
        jp z,SELECTOR ;no menu tree  JUMP to SELECTOR if all elements of COMTBL used

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

;---

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
        jr z,SELS_keyleft
        cp key_right
        jp z,SELS_keyright

        cp key_up
        jr z,SELS_keyup
        cp key_down
        jr z,SELS_keydown

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
        jp m,SELS3
        
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
;---------------------------------
;заглушки
EXITLIGHT
        ld a,(hl)
        push af
                add a,"0"
                ld (endingovl+6),a
                call _load_cdata
        pop af
        dec a
        push af   
                ld e,a
                ld d,0
                ld hl,_op_end_slct
                add hl,de
                ld e,(hl)
                ld d,0
                ld hl,CDATA
                add hl,de
                ld (hl),0x33

                call _save_cdata

;                call clear_whole_screen

        call disable_anim

        call palette_precalc
        call fade_toblack

        pop af
        push af

        ld hl,_op_gfx_ending
        call sel_word
        call load_big_img_dark2

        call palette_precalc
        call fade_fromblack



        pop af
        ld hl,endingovl
        call load_ovl_to_script_buf


        call setcorepage
        xor a
        ld b,200-32-20
        ld c,(320-8+2)/2
        call leaf_init
        call unsetcorepage
        ld a,1
        ld (petals_key),a



        ld hl,TABLE_J
        ld (CODEPAGE),hl

        LD B,150
        HALT
        DJNZ $-1

        call setcorepage
        call _draw_box
        call unsetcorepage

        call _clear_textbox

        ld hl,ovl_start
        ld bc,0x1300
        call _pradd
        call _print

        call _immed_big

        LD B,125
        HALT
        DJNZ $-1

;c01d

        ld a,2
        ld (petals_key),a
        halt

        call setcorepage
        

;сдвигаем картинку влево освобождая место для скролла
        call shifter


        ld hl,titles
        ld bc,title_len
        ld de,buf
        ldir


        xor a
        ld b,200-8
        ld c,(232-8+2)/2
        call leaf_init
        ld a,1
        ld (petals_key),a
        
        call unsetcorepage


        LD B,125
        HALT
        DJNZ $-1


;выводим скролл
        call exl_scroll

        LD B,125
        HALT
        DJNZ $-1


;        CALL clear_whole_screen
;        call palette_precalc
        call fade_toblack

        ld a,2
        ld (petals_key),a
        halt


        ld hl,tiare
        call load_big_img_dark2

        call palette_precalc
        call fade_fromblack


        call setcorepage
        call store8000c000

        ;active scr should be set 0
        call copy_scr0_scr1

        call tiare_star_lnm

        call restore8000c000
        call unsetcorepage        


        LD B,125
        HALT
        DJNZ $-1

        call fade_toblack
prebegin        
        xor a
        ld (_mmnr),a

        JP begin        


;---------------------------------------------------
/*
shifter:
        call store8000c000

        call clear_2_nd_scr


            xor a
            ld (mask_mode),a 
            ld (active_scr),a
;--------------------
        ld hl,0x8005
        ld (sslb_s),hl
        ld hl,0xC004
        ld (sslb_d),hl

        ld hl,0xA005
        ld (sslb_s2),hl
        ld hl,0xE004
        ld (sslb_d2),hl


        ld b,5

.exl_l:
        push bc
        call shift_screen_left_big

        halt
        halt
        ld a,(active_scr)
        and a
        jr nz,.spl1
        
        ; active scr 0 ; show 2nd screen . set active scr1
        inc a
        ld (active_scr),a
        ld e,a
        OS_SETSCREEN
        jr .spl0
.spl1:        
        ; active scr 1 ; show 1nd screen . set active scr 0
        dec a
        ld (active_scr),a
        ld e,a
        OS_SETSCREEN

.spl0:
        ld hl,(sslb_s)
        dec hl
        ld (sslb_s),hl
        ld hl,(sslb_s2)
        dec hl
        ld (sslb_s2),hl
        ld hl,(sslb_d)
        dec hl
        ld (sslb_d),hl
        ld hl,(sslb_d2)
        dec hl
        ld (sslb_d2),hl


        pop bc
        dec b
        jp nz,.exl_l

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        call force_scr0

        jp restore8000c000
*/
;---------------------------------------------------

exl_scroll:
        call store8000c000
        ld a,0xC9  ;ret. block 64 sym in string limit
        ld(_ppnz4_hook),a


;странно что это работает. делаем вывод текста на отображаемый в данный момент экран (не теневой)
        call set_type_to_active_scr

;выводим текст и прокручиваем его по достижении конца строки. То что работает - это магия. потому что сдвиг кратен 8 строкам и на момент вывода текста подключен тот экран, который был при инициализации.
        ld hl,buf
        call ._pop_2


        ld a,0xD8  ;ret C. enable 64 sym in string limit
        ld(_ppnz4_hook),a

        jp restore8000c000



._pop_2:


        ld a,(hl)
        inc hl
        cp 32
        jr c,._pop_cc
        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2
        sub 32

        push hl
        call _type
        pop hl
        jr ._pop_2

._pop_cc:
;.control codes
        cp 3              ;end_of_titles. exit
        jr z,.pop_cc_ext

        cp 1              ;reset print position
        jr nz,.pop_cc1
        push hl


        ld a,1
        ld (lines_up_ctr2),a
        ld a,8
        ld (lines_up_ctr1),a

        call pop_scroll_loop

        ld bc,0x1632  ;with corrections
        call _pradd
        pop hl
        jr ._pop_2
.pop_cc1:
        cp 2               ;scroll!!
        jr z,.pop_scroll
        jr ._pop_2

.pop_cc_ext:
        jp force_scr0


.pop_scroll:
        ;copy screen to second screen with line up
        ;swap screens
        ld a,(hl)
        ld (lines_up_ctr2),a
        ld a,8
        ld (lines_up_ctr1),a
        push hl
        call pop_scroll_loop

        pop hl
        inc hl
        jr ._pop_2

pop_scroll_loop:


         call setcorepage
         call  _to_psl_loop_core
         jp unsetcorepage       
         

;;;;;;;;;;;;;;;;;;;;;;;;;; 
lines_up_ctr1 db 0  ;cчётчик линий вверх 1
lines_up_ctr2 db 0  ;cчётчик линий вверх 2  batch of lines_up_ctr1

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

        ld hl,TABLE_W
        ld (CODEPAGE),hl
        
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
        ld hl,TABLE_J
        ld (CODEPAGE),hl       
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

        jp _load_common