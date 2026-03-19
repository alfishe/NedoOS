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


        ld a,(core_page)
        SETPG4000


        ld a,(mus_mode)
        and a
        jp z,.skip_fx_play

        ld a,(tsfm_detected)
        and a
        call nz,set_ay1
        call ayfx.FRAME
        ld a,(tsfm_detected)
        and a
        call nz,set_ay0
.skip_fx_play:

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
         call set_music_pages
                 call PLR_MUTE
                 ld a,(plr_page)
                 ld hl,0
                 OS_SETMUSIC
         call unset_music_pages
         halt
         ret
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

flg_if_error
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

               // sub 16   ; !!!!! помним что счётчик расроркается не с 0 а с+16

                ld c,$FF
                ld (bc),a

;-------------------------------------------------------
; загрузили все куски музыки.
;теперь нужно  скопировать првый банк в plr_page2 и прести инициаоищацию плеера
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                call closestream_file



                call set_music_pages
                        ld hl,t_s98_file00_pages_list
                        ld de,0x4100         ;0x5000
                        ld bc,256
                        ldir

;                        ld hl,t_s98_file00_pages_list
;                        ld a,(hl)
;                        SETPG8000
;                        ld hl,0x8000
;                        ld de,module
;                        ld bc,16384
;                        ldir
;                        ld a,(plr_page2)
;                        SETPG8000



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
setfontpage:
        push af,bc
        ld a,(curpg8000)
        ld (fbank2),a
        ld a,(font_page)
        SETPG8000
        pop bc,af
        ret

unsetfontpage
        ld a,0
fbank2 equ $-1
        SETPG8000
        ret
;---------------------
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
;--------------
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

getkey
        ld a,(keyreg)
        ret


waitkey_a
        ld a,1
        ld (wlock),a
        call waitkey

        cp key_esc
        jp z,TO_MENU

; 	 CP "Q"
; 	 JR Z,_is_quit
; 	 CP "q"
; 	 JR Z,_is_quit

; 	 CP "L"
; 	 CALL Z,_ram_load
; 	 CP "l"
; 	 CALL Z,_ram_load
; 	 CP "S"
; 	 CALL Z,_ram_save
; 	 CP "s"
; 	 CALL Z,_ram_save


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




outtype2 db 0   ;"P' т®Ў·б¬  пёЁбіј. 'N' в¦§ пёЁті«Ё  '8' т°± к°Ќ





cmpr_dehl:
        ld a,(de)
        and a
        ret z   ;string fully equally and dtring in de not begin from 0

        cpi
        ret nz
        inc de
        jr cmpr_dehl
;___________________________________
;A15	A14	A13	A12	A11	A10	 A9	 A8
; G0	 R0	 B0	 G1	 1	 1	 R1	 B1

; D7	 D6	 D5	 D4	 D3	 D2	 D1	 D0
; G2	 R2	 B2	 G3	 1	 1	 R3	 B3
;///////////////////////////////////////////

palette_precalc:
                call setcorepage
                        call palette_precalc_sub
                jp unsetcorepage



fade_toblack:
        ;dec lx
        ld hl,0x2ddd
        xor a
        jr fade_to
fade_towhite:
        ;inc lx
        ld a,15
        ld hl,0x2cdd
fade_to:
        call setcorepage
                call fade_to_sub
        jp unsetcorepage


fade_fromblack:
        ;inc lx
        ld hl,0x2cdd
        xor a
        jr fade_from
fade_fromwhite:
        ;dec lx
        ld a,15
        ld hl,0x2ddd
fade_from:
        call setcorepage
                call fade_from_sub
        jp unsetcorepage


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
;;;;;;;;;;;;;;;;;;;;;
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

;---
_print_txt_buf_p:
            push bc,hl,af
                    ld hl,txt_buff
                    call _type_txt_buf_p
                    call clear_txt_buff
            pop af,hl,bc
            ret
;;;
_type_txt_buf_p:
            ld c,1
.l1
            ld a,(hl)
            and a
            ret z
            push hl
            call _type_p


.debb:
            ld hl,COORDS_P
            ld a,(COORDS_P_L)
            cp (hl)
            jr z,.debb2
            jr c,.debb2
            jr .debb0
.debb2:
            call _linefeed
.debb0:
            pop hl
            inc hl
            jr .l1

;;;;;
; clear_loaded_spr1:
;             ld hl,loadedSpr1
;             jr clr_loaded_name
; clear_loaded_spr2:
;             ld hl,loadedSpr2
;             jr clr_loaded_name
; clear_loaded_spr3:
;             ld hl,loadedSpr3
;             jr clr_loaded_name
clear_loaded_cg:
            ld hl,loadedCg
clr_loaded_name:
            ld (hl),0
            ret
;;;;;
clear_all_stored_names:
                call clear_loaded_cg
; clear_all_stored_names_spr:
;                 call clear_loaded_spr1
;                 call clear_loaded_spr2
;                 call clear_loaded_spr3

                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                      ;L=C/B:
DIVIS   XOR A         ;обнуление  текущего  ос-
                      ;татка
DIVIS2  LD L,#01      ;счетчик (сдвиг 8 раз)
D1      RL C          ;чтение текущего разряда
        RLA           ;накопитель разрядов
        CP B          ;какой результат текущего
                      ;разряда
        JR C,ZER      ;переход,если текущий
                      ;разряд=0
        SUB B         ;тек.разряд=1,снятие с
                      ;накопителя
        SLI L         ;занесение разряда=1
        JR NC,D1      ;переход,если счетчик не
                      ;переполнился
        RET           ;выход
ZER     SLA L         ;занесение разряда=0
        JR NC,D1      ;переход,если счетчик не
                      ;переполнился
        RET           ;выход
;;;;;;;;;;;;;;;;;;
copy_screen_to_loadbuf:
        call store8000c000

        ld a,(load_buf1)
        SETPG8000

        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0xc000+320
        ld de,0x8000
        ld bc,16384-320
        ldir

        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0xc000+320
        ld de,0x8000
        ld bc,16384
        ldir

        jp restore8000c000


_s_pntr_goto: dw 0
_s_pntr_vv: dw 0
_cm_pntr_vv: dw 0
_c_counter db 0
_fill_sc_com_tables:
        push hl
        ld hl,CM1
        ld (_cm_pntr_vv),hl
        ld hl,S1
        ld (_s_pntr_vv),hl
        ld hl,S1+6
        ld (_s_pntr_goto),hl
        ld a,0x01
        ld (_c_counter),a
        pop hl
.fill_tbl_lp:
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld a,c
        cp 0xff
        jr nz,.its_not_eom
        ld a,b
        cp 0xff
        jr z,.its_eom
;definitely end of menu setup
.its_not_eom
        push hl
                ld hl,(_s_pntr_goto)
                ld (hl),c
                inc hl
                ld (hl),b
                ld bc,7
                add hl,bc
                ld (_s_pntr_goto),hl
        pop hl
        push hl
          push hl
            push hl
            pop bc
              ld hl,(_cm_pntr_vv)
              ld (hl),c
              inc hl
              ld (hl),b
              ld bc,3
              add hl,bc
              ld (_cm_pntr_vv),hl
          pop bc
            ld hl,(_s_pntr_vv)
            ld (hl),c
            inc hl
            ld (hl),b
            ld bc,7
            add hl,bc
            ld (_s_pntr_vv),hl
        pop hl
        ld de,buf
        call copystr_hlde
        inc hl

        ld a,(_c_counter)
        inc a
        ld (_c_counter),a

        jr .fill_tbl_lp
.its_eom
        push hl
        ld a,0xff
        ld hl,(_cm_pntr_vv)
        ld (hl),a
        inc hl
        ld (hl),a
        ld (_cm_pntr_vv),hl
        ld hl,(_s_pntr_vv)
        ld (hl),a
        inc hl
        ld (hl),a
        ld (_s_pntr_vv),hl



        ;deactivate unused dialogue
        ld a,(_c_counter)
        ld l,0xf0-1
        add a,l
        ld l,a
        ld h,high GLOBVARS
.f_dlg_lp:
         ld (hl),0
         inc l
         ld a,l
         cp 0xf8
         jr nc,.f_dlg_lp
         pop hl
         ret


_precache_menu:
_precache:
        LD IX,ILINK

        LD A,1
        LD (MM),A
        LD (SM),A

        ld hl,COMTBL
        LD (TREEE),HL      ;hl = COMTBL table
        ld hl,SCTBL
        LD (STRUCTURE),hl    ;DE = SCTBL table

PRECAH:
        LD HL,(TREEE)

PRECAH1:                   ;перебираем записи в COMTBL
        LD E,(HL)
        INC HL
        LD D,(HL)

        ld a,e
        cp 0xff
        jr nz,precah1a
        ld a,d
        cp 0xff
        ret z  ;END OF TREE - end of COMTBL


precah1a:
        ; получили адрес описателя текущего пункта меню в таблице CM

        LD A,(DE)
        LD (STORE),A

        INC DE
        LD A,(DE)
        LD (STORE+1),A ;получили и сохранили адрес расположения номера текущего пункта меню и его наименования. (num + name + eol(0))

        ld a,(STORE)
        cp 0xff
        jr nz,precah1b
        ld a,(STORE+1)
        cp 0xff
        ret z


precah1b
        INC DE
        LD A,(DE)
        INC A
        JR NZ,precah2   ;если есть подменю переходим на PRECAH2
        INC DE
        LD A,(DE)
        INC A
        JR Z,precah3 ;;если нет подменю переходим на PRECAH3
        DEC DE

precah2:
         LD A,(DE)  ;обрабатывваем подменю текущего пункта меню.
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
        JR NZ,precah2
        INC DE
        LD A,(DE)
        DEC DE
        INC A
        JR NZ,precah2

precah4:
        LD A,1
        LD (SM),A
        LD HL,MM
        INC (HL)          ;увеличиваем счётчик номера текущего пункта главного меню на 1
        LD HL,0
TREEE:   EQU $-2
        INC HL,HL
        LD (TREEE),HL    ;переходим к следующему элементу таблицы COMTBL

        JP PRECAH
precah3:
        LD HL,#FFFF
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
        JR precah4
STORE:   DW 0
STORE1:  DW 0

SEARCHING:              ;ищет сопадение vv адреса из s описателей SCTBL с аналогичным указателем vv из COMTBL

          LD (SEAR2-1),A
          LD HL,0
STRUCTURE: EQU $-2           ; hl= SCTBL adress
SEAR1:
        PUSH HL
         LD E,(HL)
        INC HL
        LD D,(HL)
        LD HL,STORE
        LD B,4
SEAR2:
        LD A,(DE)
        CP (HL)
        JR NZ,SEAR3
        INC DE
        INC HL
        DJNZ SEAR2
        POP HL
        RET
SEAR3:
        POP HL
        INC HL,HL
        JR SEAR1


_menu:
        ;clear stk_menu
        ld hl,STK_MENU
        ld de,STK_MENU+1
        ld bc,254
        ld (hl),0xff
        ldir


        ld h,high GLOBVARS
        ld l,0xf0  ;
        ld (ACTTMP),hl ;menu availablity (0 - menu active 1-inactive)

        ld hl,STK_MENU
        ld (STK_MTMP),hl

        xor a
        ld (COUNTER),a ;....

        ld hl,txt_coor
        ld (g_atpos),hl   ;...


        ld hl,COMTBL

_menu1:
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl

        ld a,d
        or e
        jp z,SELECTOR ;no menu tree  JUMP to SELECTOR if all elements of COMTBL used

        ld a,e
        cp 0xff
        jr nz,_menu2a
        ld a,d
        cp 0xff
        jp z,SELECTOR ;no menu tree  JUMP to SELECTOR if all elements of COMTBL used
_menu2a:
        ld a,(de)
        cp 0xff
        jr nz,_menu2
        inc de
        ld a,(de)
        cp 0xff
        jp z,SELECTOR
        dec de

_menu2:

        push hl
        ld bc,0
ACTTMP: equ $-2

        LD A,(BC)
        LD B,A
        LD  A,C
        inc a
        LD (ACTTMP),A
        LD A,B
        AND A
        JP z,_menu5     ;NOT ACTIVE
;        LD A,#40
;        ADD A,D
;        LD D,A
        LD HL,0
STK_MTMP: EQU $-2
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
 ;       LD A,#40
 ;       ADD A,D
 ;       LD D,A
 ;       INC DE ;SKIP MENUNAME NUM
        EX DE,HL


        LD BC,(g_atpos)
        CALL _pradd_p


        call _type_txt_buf_p

;  horisontal menu
;        LD A,(g_atpos) ;x-coord
;        add a,20
;        ld (g_atpos),a
;
;        cp print_p_len
;        jr c,_menu5
;
;        and 0x3f
;        LD (g_atpos),A
;
;        ld a,(g_atpos+1)
;        inc a
;        ld (g_atpos+1),a




;vertical menu
        LD a,(g_atpos+1)
        inc a
        ld (g_atpos+1),a
        cp 24
        jr nz,_menu5


        ld bc,txt_coor2
        ld (g_atpos),bc




_menu5

        LD A,0
COUNTER EQU $-1
        INC A
        LD (COUNTER),A
        POP HL
        JP _menu1


SELECTOR:
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
        LD A,(g_curpos)
        ld hl,MENUCURHELPER
        call sel_word
        ld (SELS4),hl

        CALL show_hand

SELS3:
        call waitkey

   ;     cp key_esc
   ;     jp z,TO_MENU

      ;  cp key_left
      ;  jr z,SELS_keyleft
      ;  cp key_right
      ;  jp z,SELS_keyright

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

        call restore_hand
        ld hl,g_curpos
        dec (hl)
        xor a
        ld (g_curpos+1),a
        jp SELS0


SELS_keydown:
        ;de - modified pos in stk_menu
        push de
        pop hl
        ld bc,3
        add hl,bc
        ld a,(hl)
        inc a
        jp  z,SELS3
        ex de,hl

        call restore_hand

        ld hl,g_curpos
        inc (hl)
        xor a
        ld (g_curpos+1),a
        jp SELS0


        jp $
SELS4:  dw 0

SELECTED1:
        call restore_hand

        ld a,(de)
        LD (RESULT),A
        inc de
        ld a,(de)
        ld l,a
        inc de
        ld a,(de)
        ld h,a
        inc hl
        inc hl

        ld e,(hl)
        inc hl
        ld d,(hl)

        inc de

        ld a,d
        or e
        jr z,SELECTOR2

        ;error in menu. hang game
        jp $
SELECTOR2:
        LD H,0xff
        ld l,0
RESULT: EQU $-1
        INC H
        INC L
        RET
        ;push de
        ;call WINCLR2
        ;pop de
        ;ret

;in a - number de - string
convA:
        ld      c,-100
        call    Na1
        ld      c,-10
        call    Na1
        ld      c,-1
Na1:    ld      b,'0'-1
Na2:    inc     b
        add     a,c
        jr      c,Na2
        sub     c               ;works as add 100/10/1
        push af         ;safer than ld c,a
        ld      a,b             ;char is in b
        ;CALL    PUTCHAR ;plot a char. Replace with bcall(_PutC) or similar.

        ld (de),a
        inc de

        pop af          ;safer than ld a,c
        ret
redraw_border_sub:
        jp update_satus_bar

print_loaded:
        ret ;!!!!
        ld bc,0x001d
        call _pradd_p
        ld hl,LOADED
        jp _type_txt_buf_p


print_excite:
        ld bc,0x0000
        call _pradd_p

        ld a,(language)
        ld hl,loc_excite
        call sel_word    ;hl - point to localized name
        call _type_txt_buf_p


        ld h,HIGH GLOBVARS
        ld l,201
        ld a,(hl)
        ld de,excite_nums
        call convA

        ld hl,excite_nums
        jp _type_txt_buf_p


print_day:
        ld bc,0x0028
        call _pradd_p

        ld h,HIGH GLOBVARS
        ld l,2
        ld a,(hl)
        ld hl,daylist
        call sel_word
        ld a,(language)
        call sel_word

        jp _type_txt_buf_p

print_lamp_post:
                ld bc,0x0018
                call _pradd_p

                ld hl,lamp_def
                ld de,lamps
                call copystr_hlde

                ld h,HIGH GLOBVARS
                ld l,7
                ld a,(hl)
                and a
                jr z,.op_skip
                jr nc,.op3
                xor a
                jr .op_skip
.op3:
                cp 5
                jr c,.op4
                ld a,4

.op4:
                ld de,lamps+1
                ld b,a
                ld a,"X"
.op0:
                ld (de),a
                inc de
                djnz .op0
.op_skip:
                ld hl,lamps
                jp _type_txt_buf_p

;-----------
TO_MENU:
        pop hl,hl
TO_MENU1:
        xor a
        ld (wlock),a


        ld a,2
        ld (_ingame_m_downlimit),a

        ld hl,loc_m1_menu
        ld de,menu_m1_action
        jr _ingame_menu_mnu

_ingame_menu_mnu:

        push hl
        push de

        CALL WINCLR2


        ld hl,txt_coor
        LD (_mnpos),HL

        xor a
        ld (_ingame_m_curpos),a
        pop de
        pop hl

        push de
        ld a,(language)
        call sel_word
        call _prt_menu

        call _sel_ingame_menu

        pop hl

        cp 0xff
        jp z,TO_MENU_ESC
        call sel_word
        jp (hl)

_confirm_quit:
        ld a,1
        ld (_ingame_m_downlimit),a

        ld  hl,loc_m2_menu
        ld  de,menu_m2_action
        jp _ingame_menu_mnu
_ram_save:
        ld a,3
        ld (_ingame_m_downlimit),a

        ld  hl,loc_save_menu_ingame
        ld  de,loc_save_menu_ingame_action
        jp _ingame_menu_mnu
_ram_load:
        ld a,3
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
_save_slot:
        add a,"0"
        ld (SAVETEMPL_N),a


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;create 'screenshot'
        call copy_screen_to_loadbuf



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

; take screenshot
         call storec000
                ld a,(load_buf1)
                SETPGC000
                ld hl,16384 ;len
                ld de,0xc000 ;addr
                call savestream_file
                or a
                jp nz,filewriteerror


                ld a,(load_buf2)
                SETPGC000

                ld a,(gfx_mode)
                ld (0xffff),a


                ld hl,16384 ;len
                ld de,0xc000 ;addr
                call savestream_file
                or a
                jp nz,filewriteerror
        call restorec000
;save palette
        ld hl,32 ;len
        ld de,pal ;addr
        call savestream_file
        or a
        jp nz,filewriteerror
;save globals
        ld hl,256 ;len
        ld de,GLOBVARS ;addr
        call savestream_file
        or a
        jp nz,filewriteerror
;save loadedCg
        ld hl,32 ;len
        ld de,loadedCg ;addr
        call savestream_file
        or a
        jp nz,filewriteerror
;save loaded ovl
        ld hl,32 ;len
        ld de,LOADED ;addr
        call savestream_file
        or a
        jp nz,filewriteerror

;save text_pointer
        ld hl,2 ;len
        ld de,text_pointer ;addr
        call savestream_file
        or a
        jp nz,filewriteerror
;save text_pointer need redraw border&
        ld hl,1 ;len
        ld de,redraw_border ;addr
        call savestream_file
        or a
        jp nz,filewriteerror
;current music
        ld hl,1 ;len
        ld de,old_mus ;addr
        call savestream_file
        or a
        jp nz,filewriteerror

        call closestream_file


        jp TO_MENU1



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
        jp nz,TO_MENU1


        ld a,(mus_mode)
        and a
        jp z, _load_common

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



;------------------------------------

_sel_ingame_menu:
        ld a,0
_ingame_m_curpos equ $-1
        ld hl,MENUCURHELPER
        call sel_word
        ld (SELS4),hl

        CALL show_hand
_sel_ingame_SELS3:
        call waitkey

        cp key_esc
        jp z,_sel_ingame_esc

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
        call restore_hand
        ld a,0xff
        ret
_sel_ingame_SELS_keyup:
        call restore_hand

        ld hl,_ingame_m_curpos
        ld a,(hl)
        and a
        jp z,_sel_ingame_menu
        dec (HL)
        jp _sel_ingame_menu

_sel_ingame_SELS_keydown:
        call restore_hand
        ld hl,_ingame_m_curpos
        ld a,(hl)
        cp 0
_ingame_m_downlimit: EQU $-1

        jp nc,_sel_ingame_menu
        inc (hl)
        jp _sel_ingame_menu
_sel_ingame_SELECTED:
        call restore_hand
        ld a,(_ingame_m_curpos)
        ret

TO_MENU_ESC

;TODO
;restore pointer to script and continue script execute
        CALL _clear_textbox
        ld hl,(text_pointer)
deeebb:
        jp _txt_out



;SAVE STRUCTURE
;32768 - 16c screenshot
;32 palette
;256 globals
;32 loaded cg (mem_buf)
;32 loaded ovl
;2 text_pointer
;1 redraw border
;1 music


