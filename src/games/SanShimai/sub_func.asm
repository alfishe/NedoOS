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


        ld a,0
alock equ $-1 
        and a       
        CALL nz,anim_eyes

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
        OS_GETMAINPAGES
        ld a,h
        ld (tbank2),a
        ld a,(font_page)
        SETPG8000
        ret

unsetfontpage
        ld a,(tbank2)
        SETPG8000
        ret
;---------------------
store8000c000
        OS_GETMAINPAGES
        ld a,h
        ld (tbank2),a
        ld a,l
        ld (tbank3),a
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



getkey
        ld a,(keyreg)
        ret


waitkey_a
        ld a,1
        ld (wlock),a
        call waitkey
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
         DB 186,188 ;С‰ СЉ        141 142
         DS 15,32
         DB 186,188 ;С‰ СЉ        158 159
         DB 189,190,191,192,193,129,130,131,132,133,134,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154
         DB 155,156,157,158,159,160,161,162,163,164,165,166,194,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185
         DB 186,188,189,190,191,192,193
         DS 6,32
         DB 143
         DB 32,32,150 ;РҐ
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;롪Ὥ󬡬ᤨ 嬿 椷殨 餠������𐬠
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
        DW SHOWSCR
        DB 07
        DW SELMUSIC ;07XX                       ;++++
        DB 08
        DW WAITKEY_SUB                          ;++++
        DB 09
        DW WAITKEY_SUB_LINEFEED                          ;++++
        DB #0A
        DW LINEFEED                             ;++++
        DB #0F
        DW EXITLIGHT                            ;-
        DB #10
        DW EXITDARK     ;GAME OVER              ;++++
        DB #13
        DW FLASH ;#16XX XX-BLINKS               ;++++
        DB #14
        DW PAUSE                                ;++++
        DB #18
        DW SHAKE ;#18XX XX-SHAKES               ;++++
        DB #0B
        DW GROUP0B
        DB #0C
        DW GROUP0C
        DB #11
        DW GROUP11
        DB #12
        DW GROUP12
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
TOKENTABLE11
        DB	02
        DW	SHOWDOUBLESCR
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

GROUP0C LD DE,TOKENTABLE0C
        JR GROUPS
GROUP0B LD DE,TOKENTABLE0B
        JR GROUPS
GROUP11 LD DE,TOKENTABLE11
        JR GROUPS
GROUP12 LD DE,TOKENTABLE12
        JR GROUPS
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
        call waitkey_a
        pop hl 
        jp _print
WAITKEY_SUB_LINEFEED
;TODO  - add  'wait' animation enable | disable
        push hl
        call waitkey_a
        pop hl 
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
        call WINCLR2
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
        call randr
        LD D,HIGH LOCVARS
        LD (DE),A
        POP HL
        JP _print
randr:
SEED    LD HL,26356
        LD B,H
        ld C,L
        DB "))))"
        ADD HL,BC
        LD BC,20981
        ADD HL,BC
        LD (SEED+1),HL
        LD A,H
        ADD A,D
        JR NC,$-1
        ret
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

        ld hl,0x4006 ; pic pointer (limiter)

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
        jr z,SELS3

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
        jr z,SSELS3
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
        LD B,250
        HALT
        DJNZ $-1

       call fade_towhite
;       CALL clear_whole_screen
       JP begin
;        LD B,250
;        HALT
;        DJNZ $-1
;
 ;       CALL clear_whole_screen
;prebegin        
;
;        ld hl,endingovl
;        jp LOADOVL


;---------------------------
EXITDARK
;        LD B,250
;        HALT
;        DJNZ $-1

       call fade_toblack 
       CALL clear_whole_screen
       JP begin

;;;;;;;;;;;;;;;;;;;;;;;;;;        
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


outtype2 db 0   ;"P' 򮡷ᬠ ︨᳼. 'N' ⦧ ︨򳫨  '8' 򰱠갍

;;;;
SHOWSCR

        call disable_anim

        ld a,(hl)
        inc hl
        push hl
        call _get_show_scr
        pop hl
        jp _print

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


        call load_eyes

        ld a,1
        ld (alock),a
        ret

SHOWDOUBLESCR:

                call disable_anim

                ld a,(script_buf1)
                SETPG4000
                ld a,(script_buf2)              
                SETPG8000         

        LD	E,(HL)
        INC	HL
        INC	HL
        LD	D,(HL)
        INC	HL
        PUSH	HL    


            push de
            ld a,d

                push af      
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
                jp z,_second_is_overlay


                call load_gfx_to_load_buf
                xor a
                ld (mask_mode),a 
                jr _sds_second_image

_second_is_overlay:
                ld a,1
                ld (mask_mode),a 
;load tb_008                
                push hl
                ld hl,tb008
                 call load_gfx_to_load_buf_nopal
                pop hl 
;load sprite to scr_buf

                call store_name

                call load_gfx_to_scr_buf
                CALL DECR_SPR

                call load_eyes

_sds_second_image:
        pop de
        ld a,e
                push af      
                ld hl,(0x4006)
                ld a,h
                add a,0x40
                ld h,a       
                pop af

                call sel_word
                ld a,h
                add a,0x40
                ld h,a
                inc hl
                inc hl

                call store_name

                call load_gfx_to_scr_buf
                CALL DECR_SPR

                call load_eyes

                call _buffer_output_op

                ld a,1
                ld (alock),a

        pop hl
        jp _print
;==============================================================        
disable_anim:
        push af
        push hl
        push bc

        ;swith off animations
        xor a
        ld (alock),a
        ld (anim_stack_spr_num),a

        ;clear animations stack
        ld b,0
1       ld hl,anim_stack
        ld (hl),a
        inc hl
        djnz 1b

        ld hl,anim_stack
        ld (anim_stack_cursor),hl

        pop bc
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

load_eyes:
    ;ret
        push hl
        push bc
        push de
        push af


        ;namebuf
        ;eyes_table:
        ld hl,eyes_table

load_eyes_main_loop:
        ld de,namebuf
        ld a,(hl)
        cp 0xff
        jp z,load_eyes_exit ;eof


        push hl
            call cmpr_dehl
            jp nz,load_eyes_skip_to_next
    
            call setfontpage
        pop hl
        push hl
            call load_anim_pre_sub

            ld a,(anim_stack_spr_num)
            add a,a
            ld d,a
            add a,a ;ax4
            add a,d ;ax6
            ld de,ANIM_BFF
            add a,d
            ld d,a
                ;put sprite addr in anim stack
                ld hl,(anim_stack_cursor)
                ld (hl),e
                inc hl
                ld (hl),d
                inc hl
                ld (anim_stack_cursor),hl

            ;load animation to font page
            ld hl,0x8000
            call readstream_file
            or a
            jp nz,filereaderror

            call closestream_file

            call unsetfontpage
        pop hl


        ;skip name again
        ld de,buf
        call copystr_hlde
        inc hl
        
        ;get x
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl

        ;x - to addr
        ex de,hl
        call p_calc_x
        ld bc,5 ;offscreen offset
        add hl,bc
        push hl
        ex de,hl

        ;get_y
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,8  ;offscreen offset
        add a,e


        ;add y offset
        ex de,hl
        pop hl  
        call p_calc_y


        push hl
        pop bc

                ;put sprite ega screen  addr in anim stack
                ld hl,(anim_stack_cursor)
                ld (hl),c
                inc hl
                ld (hl),b
                inc hl
                ld (anim_stack_cursor),hl        

        ex de,hl

        ld c,(hl)
        inc hl
        inc hl
        ld b,(hl)
        inc hl
        inc hl

        ex de,hl
        ld hl,(anim_stack_cursor)
        ld (hl),c ;len
        inc hl
        ld (hl),b ;hgt
        inc hl
        ld (anim_stack_cursor),hl        
        ex de,hl

        ld b,(hl) ;num phases
        inc hl

        ex de,hl
        ld hl,(anim_stack_cursor)
        ld (hl),b ; phases
        inc hl
        ld (hl),0xfe ;counter 1
        inc hl
        ld (hl),0        ;counter 2
        inc hl
        ld (hl),0     ;placeholders   
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
        inc hl        
        ld (hl),0        
        inc hl        
        ld (anim_stack_cursor),hl        


        ld hl,anim_stack_spr_num
        inc (hl)

        ex de,hl

        jp load_eyes_main_loop
        ;load gfx to buf by name
        ;move gfx to font_page 
        ;setup animation stack


load_eyes_exit:
;        ld a,1
;        ld(alock),a
        pop af
        pop de
        pop bc
        pop hl
        ret
load_eyes_skip_to_next:
        pop hl
        ld bc,16
        add hl,bc
        jp load_eyes_main_loop


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
                push hl
                push de
                push bc
                push af

                ld b,6
_pal_pc_l1:
                push bc

                ld a,b
                push af ;store fase
                add a,a ;x2
                add a,a ;x4
                add a,a ;x8
                add a,a ;x16
                add a,a ;x32
                ld e,a
                ld d,high _pal_bright   ;adr palette
                ld hl,pal ;source palette

                pop af
                call _pal_transfer

                pop bc
                djnz _pal_pc_l1

                pop af
                pop bc
                pop de
                pop hl 
                ret  

_pal_transfer:
                cp 0
                jp z,_pal_tsf_0
                cp 1
                jp z,_pal_tsf_1
                cp 2
                jp z,_pal_tsf_2
                cp 3
                jp z,_pal_tsf_3
                cp 4
                jp z,_pal_tsf_4
                cp 5
                jp z,_pal_tsf_5
                cp 6
                jp z,_pal_tsf_6
                cp 7
                jp z,_pal_tsf_7


_pal_tsf_3:
                ld b,16
1               ld a,(hl)
                ld (de),a
                inc hl
                inc de
                ld a,(hl)
                or 0x1f ;b00011111
                ld (de),a
                inc de
                inc hl
                djnz 1b
                ret

_pal_tsf_2:
                ld b,16
1               ld a,(hl)
                ld (de),a
                inc hl
                inc de
                ld a,(hl)
                or 0xff
                ld (de),a
                inc de
                inc hl
                djnz 1b
                ret

_pal_tsf_1:
                ld b,16
1               ld a,(hl)
                or 0x1f     ;b00011111
                ld (de),a
                inc hl
                inc de
                ld a,(hl)
                or 0xff
                ld (de),a
                inc de
                inc hl
                djnz 1b
                ret        
_pal_tsf_0:
                ld b,32
                ld a,0xff
1               ld (de),a
                inc de
                djnz 1b
                ret

_pal_tsf_4:
                ld b,16
1               ld a,(hl)
                and 0x1f ;b00011111
                ld (de),a
                inc hl
                inc de
                ld a,(hl)
                ld (de),a
                inc de
                inc hl
                djnz 1b
                ret

_pal_tsf_5:
                ld b,16
1               ld a,(hl)
                and 0x0c ;b00001100
                ld (de),a
                inc hl
                inc de
                ld a,(hl)
                ld (de),a
                inc de
                inc hl
                djnz 1b
                ret        
_pal_tsf_6:
                ld b,16
1               ld a,(hl)
                and 0x0c ;b00001100
                ld (de),a
                inc hl
                inc de
                ld a,(hl)
                and 0x1f   ;b00011111
                ld (de),a
                inc de
                inc hl
                djnz 1b
                ret        
_pal_tsf_7:
                ld b,32
                ld a,0x0c ;00001100
1               ld (de),a
                inc de
                djnz 1b
                ret
;===================
fade_toblack:
        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;



	ld a,3 ;2
.fade0;
	halt
	halt
	halt
	halt
	halt
;	halt
       

	push af

        add a,a ;x2
        add a,a ;x4
        add a,a ;x8
        add a,a ;x16
        add a,a ;x32
        ld l,a
        ld h,high _pal_bright   ;adr palette
        ld de,pal
        ld bc,32 
        ldir

	ld a,1
	ld (setpalflag),a

       ;call waitkey

	pop af
	dec a
	cp 255
	jr nz,.fade0


	halt
	halt
	halt
	halt
	halt

       ret

fade_towhite:
        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;



	ld a,4 ;2
.fade_w0;
	halt
	halt
	halt
	halt
	halt
;	halt
       

	push af

        add a,a ;x2
        add a,a ;x4
        add a,a ;x8
        add a,a ;x16
        add a,a ;x32
        ld l,a
        ld h,high _pal_bright   ;adr palette
        ld de,pal
        ld bc,32 
        ldir

	ld a,1
	ld (setpalflag),a

       ;call waitkey

	pop af
	inc a
	cp 8
	jr nz,.fade_w0


	halt
	halt
	halt
	halt
	halt

       ret

fade_fromwhite:
        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;



	ld a,6 ;2
.fade_w1;
	halt
	halt
	halt
	halt
	halt
;	halt
       

	push af

        add a,a ;x2
        add a,a ;x4
        add a,a ;x8
        add a,a ;x16
        add a,a ;x32
        ld l,a
        ld h,high _pal_bright   ;adr palette
        ld de,pal
        ld bc,32 
        ldir

	ld a,1
	ld (setpalflag),a

       ;call waitkey

	pop af
	dec a
	cp 3
	jr nz,.fade_w1



	halt
	halt
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
;------------------------------------
fade_fromblack:
        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;

	ld a,0 ;2
.fade_b1;
	halt
	halt
	halt
	halt
	halt
;	halt
       

	push af

        add a,a ;x2
        add a,a ;x4
        add a,a ;x8
        add a,a ;x16
        add a,a ;x32
        ld l,a
        ld h,high _pal_bright   ;adr palette
        ld de,pal
        ld bc,32 
        ldir

	ld a,1
	ld (setpalflag),a

       ;call waitkey

	pop af
	inc a
	cp 4
	jr nz,.fade_b1

	halt
	halt
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