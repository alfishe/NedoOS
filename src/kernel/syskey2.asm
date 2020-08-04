;кодировка 866!
;notepad++ неправильно определяет кодировку
;поэтому напишем здесь довольно много текста кириллицей
;поэтому напишем здесь довольно много текста кириллицей
;поэтому напишем здесь довольно много текста кириллицей
numlangs=3 ;including graph

keyqueuemax=2;5

kZ=0 ;ja w e r t y
kJ=0 ;j c u k e n
multikbd=0
kR=1 ;sh w e r t y
NkJ=kZ+kR 
ukr=1

KEYM0change
        LD (keym0BC),BC
        LD (keym0HL),HL
        ld c,d ;C=very old state
        LD D,A ;D=changes
        LD B,5 ;5 keys in a halfrow
KEYM1   RR D
        jr NC,KEYMnPUT
        LD (keym1BC),BC
        LD (keym1DE),DE
keymshifts=$+1
        LD D,0
;C0=press(1)/release(0)
;E=scancode, D=shiftstate
;D=%00: ext
;D=%01: cs
;D=%10: ss
;D=%11: no shifts
        DEC D
        LD HL,tkeydecodecs
        jr Z,KEYDECODEPASS ;cs+key
        DEC D
        LD HL,tkeydecodess
        JR z,KEYDECODEPASS ;ss+key
        DEC D
        LD HL,tkeydecode
        jr Z,KEYDECODEPASS ;no shifts+key
        LD HL,tkeydecodeext ;ext+key
KEYDECODEPASS
        LD D,0
        ADD HL,DE
        ld A,(HL)
       CP ssnoshifts ;crucial for autorepeat of ssSpace
       jr Z,KEYMPUTSKIP
       CP csnoshifts ;csnoshifts keypress can appear in the same frame as cs6 etc and must be ignored
keym_keyrep
       LD B,E
        CALL NZ,KEYREP ;A=code
                       ;C0=press(1)/release(0)
                       ;B=scancode without shifts
KEYMPUTSKIP
keym1DE=$+1
        LD DE,0
keym1BC=$+1
        LD BC,0
KEYMnPUT
        INC E
        RR C
        DJNZ KEYM1
keym0HL=$+1
        LD HL,0
keym0BC=$+1
        LD BC,0
        jp KEYM0nexthalfrow

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KEYSCAN
;to make shifts always press no later than alphanumerics
;use old scanchange of alphanumerics and old&new scan of shifts (to make them longer)
;tkeymatrixstate (even) = old scan
;tkeymatrixstate+1 (odd) = very old scan

KEYMATRIX
        LD HL,tkeymatrixstate +(2*7)
        LD BC,0x7FFE
         ld a,c
         in a,(0xfe) ;cs halfrow
         and (hl) ;old cs halfrow
         ld e,a
        LD HL,tkeymatrixstate
        IN A,(C) ;ss halfrow
         and (hl) ;old ss halfrow
        RRA 
        RRA ;ss
        ;LD A,C
        ;IN A,(0xFE)
         ld a,e
        RLA 
        AND 3
        LD (keymshifts),A ;A0=ss,A1=cs
        LD E,0 ;scancode ;Space=0, cs=35
KEYM0   ;IN A,(C)
         ld a,(hl) ;old state (to use)
         ini ;current keymatrix for alphanumerics will be used in the next frame
         inc b
         ;inc hl
        LD d,(HL) ;very old state
        ld (HL),A ;old state (to use)
        XOR d ;very old state
         jr nz,KEYM0change
        ld a,e
        add a,5
        ld e,a
KEYM0nexthalfrow
        INC HL
        RRC B ;next halfrow
        jp C,KEYM0

        if 1==0
;current keymatrix for alphanumerics will be used in the next frame
        ld hl,tkeymatrixstate
        LD BC,0x7FFE ;Space=0, cs=35
KEYSCAN0
        IN A,(C)
        ld (hl),a
        inc hl
        ;ini
        ;inc b
        inc hl
        rrc b
        jp c,KEYSCAN0
        endif
        
;blowing
        ld a,(keyrepcounter)
        OR A
        RET Z
        DEC A
        jr Z,KEYREPSEND
KEYREPSETCNT
        LD (keyrepcounter),A
        RET

;C0=press(1)/release(0)
;A=code
;B=scancode without shifts
KEYREP
        IF 1==0
        push af
        push bc
        push de
        push hl
        ld a,b
        add a,'A'       
        ld c,a
        ld b,0
        call KEYQUEUEPUT
        ld a,(keyrepscancode)
        add a,'A'
        ld c,a
        ld b,0
        call KEYQUEUEPUT
        pop hl
        pop de
        pop bc
        pop af
        ENDIF
        RR C ;NC=release
        jr C,KEYREPPRESS
;CP/M: if this is "ext" (cs or ext release): if keyrepkey was "ext", then make "ext" keypress (and forget "ext" to avoid "ext, cs" work as ext, ext), else make "csnoshifts" keypress (for AltGr)
         cp csss
         jr nz,KEYREPRELEASE
keyrepkey=$+1
        cp 0
        ld a,csnoshifts
        LD (keyrepkey),A ;forget "ext" to avoid "ext, cs" work as ext, ext
        jr nz,KEYREPSEND
        ld a,csss
        jr KEYREPSENDA
KEYREPRELEASE
;if the repeated key (without shifts) is released
;then stop key repeat
;or else ignore
       LD A,B ;scancode without shifts
keyrepscancode=$+1
       SUB -1
        RET NZ
      ;XOR A
       JR KEYREPSETCNT
KEYREPPRESS
        cp cssspress ;=csss
        jr nz,KEYREPPRESSncsss
keyrepcounter=$+1
        LD d,0
        inc d
        dec d
        ret nz ;ext keypress, but another key is already pressed - ignore ext ;to filter out ext keypress in the same frame as ext+3 keypress (ss+PgUp pressed)
        ;z
KEYREPPRESSncsss
       LD (keyrepkey),A
        ret z ;no "ext" keypress, only release
       SUB cs1;'1'-32
       CP 2
       jr C,KEYREPSEND ;no autorep for cs1..2
       LD A,B ;scancode without shifts
       LD (keyrepscancode),A
        LD A,14;10
        LD (keyrepcounter),A
KEYREPSEND
         ld a,(keyrepkey)
KEYREPSENDA
         
;A = code ;[(cs+1 was encoded as '1'-32)]
;csnoshifts means CS release
;idle: cs1..2 start, csnoshifts skip, others pass by
;working: cs0..9 add, others end (1,2 add cs0)
KEYALTGR
altgrN=$+1
        LD BC,0x100 ;C=AltGr code (0=idle), B=1 (codes)
         ld e,a ;current key
           sub cs0;'0'-32
           jr z,KEYALTGRcs0
        SUB cs1-1 -cs0
KEYALTGRcs0
       LD D,A ;0..9 in good case
       INC C
       DEC C
       jr Z,KEYALTGR_IDLE
        CP 10
       LD A,C
        jr NC,KEYALTGRPUT ;stop AltGr (csnoshifts or wrong key) ;a=final code
        ADD A,A
        ADD A,A
        ADD A,C
        ADD A,A ;D*10
        ADD A,D
KEYALTGRN
        LD (altgrN),A
        RET
KEYALTGR_IDLE
;A=1..2 in good case
        DEC A
        CP 2 ;CY=1: cs1/cs2
        INC A
        jr C,KEYALTGRN ;start AltGr
         ld a,e ;current key
        jr KEYALTGRPUT_NO1_2 ;for passing extA(=1),extB(=2)
KEYALTGRPUT
;cs release gives final code here (=1 or 2 for single keypress of cs1 or cs2)
        cp 3
        jr nc,$+5
            add a,cs1-1
KEYALTGRPUT_NO1_2
            inc b ;control keys
        or a;CP csnoshifts
        RET Z ;avoid NOKEY
        LD C,A
       XOR A
       LD (altgrN),A ;idle

;BC=code (B=2 => might be control code) (B=1 means AltGr symbol, for KEYLANG passby)
KEYSWITCH
       DEC B
       jr Z,KEYSWPASS ;B=0 ;AltGr symbol, for KEYLANG passby
        LD A,C
        ;push af
        ;push bc
        ;ld bc,'a'
        ;ld c,a
        ;call KEYQUEUEPUT
        ;pop bc
        ;pop af
keyswstate=$+1
        LD HL,0x100 ;H=язык=1..numlangs (H=numlangs при graph)
                   ;L0=CapsLock
        CP cs2
        jr Z,KEYSWCAPSLOCK
        CP cs1
        jr Z,KEYSWLANG
        CP graphlock;ext1
        jr NZ,KEYSWPASS
KEYSWGRAPH
        LD A,H
        LD H,numlangs
        CP H ;graph уже включен?
        jr NZ,KEYSWOK ;нет - включаем, иначе DEC H
KEYSWLANG
        DEC H
        jr NZ,$+4
        LD H,numlangs-1
        DEC L
KEYSWCAPSLOCK
        INC L
KEYSWOK
        LD (keyswstate),HL
;pass key to make possible to redraw blinking cursor
KEYSWPASS

;BC=code (B=0 means AltGr symbol, for KEYLANG passby) (B=1 for usual keys)
KEYLANG
        INC B
        DEC B
        jr Z,KEYLANGPASS ;B=0: symbol from ALTGR
;B=1
        ;CALL KEYQUEUEPUT ;BC=code
        ld (keyqueueput_codenolang),bc
KEYLANG_REPEAT
        LD A,C
        LD (keylangcode),A
         ;sub graphlock;ext1 ;how it worked in ACEdit without this check?
         ;jr z,KEYLANGPASS_A ;B=1 (control key) ;a=0=NOKEY => c
         ;sub cs1-graphlock;ext1 ;how it worked in ACEdit without this check?
         ;jr z,KEYLANGPASS_A ;B=1 (control key) ;a=0=NOKEY => c
         ;sub cs2-cs1 ;how it worked in ACEdit without this check?
         ;jr z,KEYLANGPASS_A ;B=1 (control key) ;a=0=NOKEY => c
         ;SUB 0xff&(32-cs2)
         cp graphlock;ext1 ;how it worked in ACEdit without this check?
         ret z
         cp cs1 ;how it worked in ACEdit without this check?
         ret z
         cp cs2 ;how it worked in ACEdit without this check?
         ret z
         SUB ' '
        CP 95
        jr NC,KEYLANGPASS ;B=1 (control key)
rustrdisp=$+1
       LD DE,0 ;D=0
       INC E
       DEC E
       jr NZ,KEYLANG_SHV2 ;second key of combination?
keylangcode=$+1
        LD BC,0 ;B=0, C=code
        LD DE,(keyswstate)
;BC=code
        DEC D
        jr Z,KEYL_ENG ;B=0
        DEC D
        jr NZ,KEYL_GRAPH ;B=0
KEYL_RUSTR
;B=0
       IF multikbd
kmode=$+1
        LD A,1
        CP kR
        jr Z,KEYL_SHVERTY
        CALL RERUS
        JR KEYLANGPUT ;B=0
KEYL_SHVERTY
       ENDIF 
        LD A,C
        CP 64
        jr C,KEYLANGPUT ;B=0
        LD HL,tkeyl_rustr
        ADD HL,BC
        LD C,(HL)
        LD A,C
        CP 64
        jr NC,KEYLANGPUT ;B=0
       ;LD (rustrdisp),BC ;B=0
      ;LD A,C
       LD (rustrdisp),A
        ;RET
        ld c,b ;b=0 ;put keylang=0 with current keynolang
        jr KEYLANGQ
        
KEYLANG_SHV2
        LD (rustrNEW),BC
       LD A,C;(rustrNEW)
      ;LD (rustrNEW),A
;rustrdisp=$+1
       ;LD DE,0 ;D=0
        LD HL,tkeyl_rustrc
        ADD HL,DE
        LD C,(HL) ;len
       LD B,D ;=0
        INC HL
        LD E,C
        CPIR 
        LD C,E ;B=0
        ADD HL,BC
        jr Z,KEYLANGCOMBO ;combination entered (such as qq)
;no such combination - take symbol #len
       LD A,(HL)
       CALL case
       LD C,A
        CALL KEYQUEUEPUT ;B=0
rustrNEW=$+1
       LD BC,0 ;B=0
       XOR A
       LD (rustrdisp),A
         ld h,a
         ld l,a
         ;ld (keyqueueput_codenolang),hl ;no keynolang for 2nd symbol
        JR KEYLANG_REPEAT ;doubling and recoding the 2nd symbol
KEYL_GRAPH
;B=0
;'0' -> 0030
;'1' -> 0031
;'2' -> 0032
;'3' -> 0033
;'4' -> 0034
;'a' -> 0061
;do "case" first!!!
       LD A,C
       CALL case
       LD C,A
        LD HL,tkeyl_graph
        ADD HL,BC
        LD C,(HL)
        jr KEYLANGPASS
        
KEYLANGCOMBO
        DEC HL
        LD C,(HL)
KEYL_ENG ;B=0
KEYLANGPUT ;B=0
       LD A,C
       CALL case
;KEYLANGPASS_A ;A=0
       LD C,A
KEYLANGPASS
       XOR A
       LD (rustrdisp),A
KEYLANGQ
        jp KEYQUEUEPUT

tkeydecodeext
        DB key_extspace,ssnoshifts,extM,extN,extB
        DB extenter,extL,extK,extJ,extH
        DB extP,extO,extI,extU,extY
        DB ext0,ext9,ext8,ext7,ext6
        DB ext1,ext2,ext3,ext4,ext5
        DB extQ,extW,extE,extR,extT
        DB extA,extS,extD,extF,extG
        DB cssspress,extZ,extX,extC,extV
tkeydecode
        DB " ",ssnoshifts,"mnb"
        DB key_enter,"lkjh"
        DB "poiuy"
        DB "09876"
        DB "12345"
        DB "qwert"
        DB "asdfg"
        DB csss,"zxcv"
tkeydecodecs
        DB key_esc,ssnoshifts,"MNB"
        DB key_csenter,"LKJH"
        DB "POIUY"
        ;DB '0'-32,'9'-32,'8'-32,'7'-32,'6'-32
        ;DB '1'-32,'2'-32,'3'-32,'4'-32,'5'-32
        db cs0,cs9,cs8,cs7,cs6
        db cs1,cs2,cs3,cs4,cs5
        DB "QWERT"
        DB "ASDFG"
        DB csnoshifts,"ZXCV"
tkeydecodess
        DB key_ssspace,ssnoshifts,".,*"
        DB ssnoshifts,"=+-^"
        DB 34,";",ssI,"]["
        DB "_)('&"
        DB "!@#$%"
        DB ssQ,ssW,ssE,"<>"
        DB "~|",0x5c,"{}"
        DB csss,":`?/" ;in fact csss keypress is taken from tkeydecodeext, csss release from tkeydecodecs
tkeymatrixstate
        ;DS 8,0xFF ;initially nothing pressed
        DS 16,0xFF ;initially nothing pressed

tkeyl_graph=$-32
        DB 32,14,34,16,17,18,19,20,"()*+,-./"
        DB 12,1,2,3,4,5,6,7,8,11,":;єўЄ?"
        DB 15,"╠╧╝╣╗╞╪╡▄▀■¤№╛▌▐╔╒╬╤█╘╦╩╕╚[",0x5c,"]^_"
        DB "`├╨┘┤┐╟╫╢─░▒▓√╜║═┌╓┼╥│╙┬┴╖└{|}~"
tkeyl_rustr=$-64
        DB "@АБ",rustrCdisp
        DB "ДЕФГ",rustrHdisp,"И",rustrJdisp
        DB "КЛМНОП",rustrQdisp
        DB "РСТУЖВЬЫЗ[",0x5c,"]^_"
        DB "`аб",rustrcdisp
        DB "дефг",rustrhdisp,"и",rustrjdisp
        DB "клмноп",rustrqdisp
        DB "рстужвьыз{|}~"

tkeyl_rustrc=$-1 ;to avoid zero displacements
rustrhdisp=$-tkeyl_rustrc
        DB 1,"h","э","х"
rustrHdisp=$-tkeyl_rustrc
        DB 1,"H","Э","Х"
rustrqdisp=$-tkeyl_rustrc
        DB 1,"q","щ","ш"
rustrQdisp=$-tkeyl_rustrc
        DB 1,"Q","Щ","Ш"
rustrcdisp=$-tkeyl_rustrc
       IF ukr
        DB 2,"gc",0xF3,"ц","ч"
       ELSE 
        DB 1,"c","ц","ч"
       ENDIF 
rustrCdisp=$-tkeyl_rustrc
       IF ukr
        DB 2,"GC",0xF2,"Ц","Ч"
       ELSE 
        DB 1,"C","Ц","Ч"
       ENDIF 
rustrjdisp=$-tkeyl_rustrc
       IF ukr
        DB 7,"eyiaouj",0xF5,0xF7,0xF9,"яёюъ","й"
       ELSE 
        DB 4,"aouj","яёюъ","й"
       ENDIF 
rustrJdisp=$-tkeyl_rustrc
        DISPLAY $-tkeyl_rustrc,"<64"
       IF ukr
        DB 7,"EYIAOUJ",0xF4,0xF6,0xF8,"ЯЁЮЪ","Й"
       ELSE 
        DB 4,"AOUJ","ЯЁЮЪ","Й"
       ENDIF 

       IF kZ
rt
        DB "ЮАБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧъ"
       ENDIF 
       IF kJ
rtjcuk
        DB "@ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ[",0x5c,"]^_"
       ENDIF 
RERUS
;in: C=code (32..126), A=kmode
;out: C=code
;keeps B
        LD D,C ;code
       IF kZ
        LD HL,rt
       ENDIF 
       IF kJ
        IF multikbd
        CP NkJ
        jr NZ,rERUSnJCUK
        ENDIF 
        LD HL,rtjcuk
        LD A,D ;code
        LD C,'б'
        CP '!'
        RET Z
        LD C,'ж'
        CP '@'
        RET Z
        LD C,'х'
        SUB '#'
        RET Z
        LD C,'э'
        DEC A ;'$'
        RET Z
        INC C ;'ю'
        DEC A ;'%'
        RET Z
rERUSnJCUK ;
       ENDIF 
        LD A,D ;code (32..126)
        LD C,'ё'
        CP '&'
        RET Z
        LD C,D
        BIT 6,D ;code
        RET Z ;code <64 (not letter) - return old code
;A=code (64..126)
        AND 31
        ADD A,L
        LD L,A
        jr NC,$+3
        INC H
        LD A,(HL) ;capital Russian
        BIT 7,A
        RET Z ;not a letter in the table - return old code
        LD C,A ;capital Russian
        BIT 5,D ;code
        RET Z ;C contained capital letter, return capital
        CALL RECAP
        LD C,A ;small Russian
        RET 

CHECKCAPSLOCK
        PUSH HL
        LD HL,keyswstate
        BIT 0,(HL)
        POP HL
        RET 
case
        CALL CHECKCAPSLOCK
        RET Z
RECAP
        CP 0xf2;je'Є'
        RET NC
        XOR 1
        CP 0xf0;jo'Ё'
        RET NC
        XOR 1
        CP 0xe0;'р'
        jr NC,BECAPRL
        CP 0xb0;'-'
        RET NC
        CP 0xa0;'а'
        jr NC,BECAPOK
        CP 0x90;'Р'
        jr NC,BECAPRL
        CP 0x80;'А'
        jr NC,BECAPOK
        CP '@'
        RET Z
        CP '_'
        RET Z
        CP 'A'
        RET C
        CP '{'
        RET NC
        CP '['
        jr C,$+5
        CP 'a'
        RET C
BECAPOK XOR 80
BECAPRL XOR 0x70
        RET 

