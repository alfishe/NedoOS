;выводит в текстовый буфер
SMALLLETTERADD=32;0

;TODO fix ld (ix+d),n - пишет ld (ix+d),d

Disasm_PrWord_de
;de=word
        ld a,d
        call Disasm_PrHex_a
        ld a,e
Disasm_PrHex_a
        push af
        rra
        rra
        rra
        rra
        call Disasm_PrHexDig
        pop af
Disasm_PrHexDig
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
Disasm_PrChar
        ld (ix),a
        inc ix
        ret

ED      INC HL
        LD B,' ';32
        LD A,(HL)
        SUB 64
        RET C
        SUB 64
        JR NC,C5
        CP 196
        LD DE,COMN
        JR Z,CT
        AND 7
        CP 7
        LD DE,COME
        JR Z,CT
        CP 5
        JR NZ,C6
        LD A,(HL)
        CP 80
        LD DE,COMR
        RET NC
CT      CALL CALC
TXT     JP TEXT

C6      CP 4
        RET Z
        CP 6
        JR NZ,C7
        LD A,(HL)
        CP 100
        LD DE,COMHim ;"IM "
        RET NC
        CALL T0
        CALL CALC
        CP 1
        RET Z
        JR C,$+3
        DEC A
        ADD A,'0'
       jp Disasm_PrChar

C7      LD E,A
        LD A,(HL)
        AND 15
        CP 10
        LD A,E
        JR C,C8
        ADD A,2
C8      LD DE,COMI
        CP 3 ;ld (nn), ;ld rp,(nn) - как работает? показывает правильно даже с префиксом
        JR NZ,TXT ;а как проверяется 2? sbc/adc hl,rp - всегда hl, а не ix/iy! показывает правильно даже с префиксом
        LD C,(HL)
        CALL TEXT
        LD A,C
PAIR    CALL CALCa
        RRA 
        CP 2 ;hl?
        LD DE,RP
        JR NZ,TXT
LHL     LD DE,RPhl
        BIT 6,B
        JP Z,T0
        LD A,'I'+SMALLLETTERADD
       call Disasm_PrChar
        LD A,B
       jp Disasm_PrChar

C5      SUB 32
        RET C
        CP 32
        RET NC
        BIT 2,A
        RET NZ
        BIT 4,A
        JR Z,C9
        SUB 12
C9      LD DE,COMM
        JR TXT

disasmbit
        INC HL
        BIT 6,B
        JR Z,B0
        INC HL
        DEC B
        DEC B
B0      LD A,(HL)
        SUB 64
        LD DE,COMB
        JR NC,B1
        CALL CT ;rl/rlc/...
        LD A,' '
        JR B2

B1      RLCA 
        RLCA 
        AND 3
        ADD A,8 ;bit/res/set
        CALL TEXT
        CALL CALC
        ADD A,'0'
       call Disasm_PrChar
        LD A,',';44
B2     call Disasm_PrChar
        LD A,(HL)
        ;BIT 5,B
        ;JR NZ,$+6
        bit 6,b
        jr z,$+6
         AND 7
         CP 6
        CALL NZ,REG
        BIT 6,B
        RET Z
        INC B
        INC B
        JP R1p4

Disasm_COMMAND
        LD B,' ';32
clear   LD A,(HL)
        CP 0xdd;221
        JR NZ,CY
        LD B,'X'+SMALLLETTERADD
CX      INC HL
        INC HL
        LD C,(HL)
        DEC HL
        JR clear

CY      CP 0xfd;253
        JR NZ,CZ
        LD B,'Y'+SMALLLETTERADD
        JR CX

CZ      CP 0xcb;203
        JR Z,disasmbit
        CP 0xed;237
        JP Z,ED
        CP 0x76;118
        LD DE,COMH ;"halt"
        JR Z,T0
        CP 0x40;64
        JP NC,C1
        AND 7
        LD DE,COM0
        JR Z,jpCT
C0      CP 7
        LD DE,COM7
        JR Z,jpCT
        CP 2
        JR NZ,TZ
        LD A,8 ;"ld "
        CALL TEXT
        LD DE,COM2
jpCT    JP CT

TZ      LD A,(HL)
        AND 15
        CP 12
        JR NC,TEXT ;inc reg, dec reg, ld reg,i8 - и для чётных, и для нечётных восьмёрок
        ADD A,8 ;[8],9,[10],11,12,13,14,[15],[16],17,[18],19: [], ld rp,i16, [], inc rp, inc reg, dec reg, ld reg,i8, add hl,rp, [], dec rp
TEXT    OR A
        JR NZ,T7
T0      LD A,(DE)
        BIT 7,A
        PUSH AF
        PUSH DE
        AND 127
        JR NZ,T1
        CALL LHL ;0=hl/ix/iy
        JR T6
T1      DEC A
        JR NZ,T2
        CALL CALC ;1=reg (n/8)
        CALL REG
        JR T6
T2      DEC A
        JR NZ,T3
        LD A,(HL) ;2=rp
        CALL PAIR
        JR T6
T3      DEC A
        JR NZ,T4
        INC HL
        LD C,(HL) ;3=i8
        CALL S7
        JR T6
T4      DEC A
        JR NZ,TX
        INC HL
        LD E,(HL) ;4=i16
        INC HL
        LD D,(HL)
        CALL Disasm_PrHashWord_de
        JR T6
TX      DEC A
        JR NZ,TY
        INC HL
        PUSH HL
        LD E,(HL) ;5=$+shift (for 0x10,0x18..0x38, в 0x00,0x08 нет параметров)
        LD D,A
        BIT 7,E
        JR Z,$+3
        DEC D
disasmcmdaddr=$+1
       ld hl,0
       inc hl
        INC HL
        ADD HL,DE
        EX DE,HL
        POP HL
        CALL Disasm_PrHashWord_de
        JR T6
TY      DEC A
        JR NZ,T5
        LD DE,CC ;6=cc
        CALL CT
        JR T6
T5
       or SMALLLETTERADD
       call Disasm_PrChar
T6      POP DE
        POP AF
        INC DE
        JR Z,T0
        RET 

T7      DEC A
        EX DE,HL
T8      BIT 7,(HL)
        INC HL
        JR Z,T8
        EX DE,HL
        JR TEXT

C1      CP 128
        JR NC,C4
        LD DE,COML ;"ld reg,"
        PUSH AF
        CALL T0
        POP AF
        LD D,A
        JR REGd

C4      CP 192
        LD DE,COM
        JR NC,C2
        CALL CT
        LD A,(HL)
REG     LD D,(HL)
REGd    AND 7
        ADD A,66+SMALLLETTERADD
        AND 71+SMALLLETTERADD ;0x47+
        CP 70+SMALLLETTERADD ;0x46+
        JR NZ,R0
        LD A,'H'+SMALLLETTERADD
        JR R6

R0      CP 71+SMALLLETTERADD ;0x47+
        JR NZ,R1
        LD A,'L'+SMALLLETTERADD
R6     call Disasm_PrChar
        LD A,D
        and 0xf7
        cp 0x26 ;ld h,i8 (0x2e=ld l,i8)
        jr z,REG_hzlz
        AND 7
        CP 6
        RET Z ;(hl)/(iz+),h/l не пересчитываем
        XOR D
        CP 112
        RET Z ;h/l,(hl)/(iz+) не пересчитываем
REG_hzlz
        LD A,B
        CP 'X'
        RET C
        ;LD A,B
R8     jp Disasm_PrChar

R1      CP 64+SMALLLETTERADD
        JR NZ,R8
R1p4
        LD A,'('
       call Disasm_PrChar
        CALL LHL
        BIT 6,B
        JR Z,R5
        LD A,C
        RLA 
        LD A,'+'
        JR NC,R4
        XOR A
        SUB C
        LD C,A
        LD A,'-'
R4     call Disasm_PrChar
        CALL S7
R5      LD A,')'
       jp Disasm_PrChar

C2      AND 7
        CP 6
        JR NZ,C3
        CALL CT
        INC HL
        LD C,(HL)
        JR S7

C3      CP 1
        LD DE,COM1
CTT     JP Z,CT
        CP 3
        LD DE,COM3
        JR Z,CTT
        CP 5
        LD DE,COM5
        JR Z,CTT
        CP 7
        LD DE,COMJ
        JP NZ,TEXT
        CALL TEXT
        LD A,(HL)
        SUB 199
        LD C,A
S7      ;LD A,(S1)
        ;CP 24
        ;JR Z,S8_100 ;decimal mode
        LD A,'#'
       call Disasm_PrChar
        LD E,C
        JR prhex_e;S2

       if 0
S8_100  LD D,100
        CALL S9
S8_10   LD D,10
        CALL S9
        LD D,1
S9      LD E,47
        LD A,C
        INC E
        SUB D
        JR NC,$-2;S9+3
        ADD A,D
        LD C,A
        LD A,E
       call Disasm_PrChar
        RET
       endif

;S1
Disasm_PrHashWord_de
        LD A,'#' ;WARNING! рассчитано на JR ZZZZZZ
       call Disasm_PrChar
        jp Disasm_PrWord_de
prhex_e
        LD A,E
       jp Disasm_PrHex_a

       if 0
ZZZZZZ
        EX DE,HL
        LD BC,10000
        CALL S5
        LD BC,1000
        CALL S5
        LD BC,100
        CALL S5
        EX DE,HL
        LD C,E
        JR S8_10

S5      LD A,47
S6      INC A
        SBC HL,BC
        JR NC,S6
        ADD HL,BC
       jp Disasm_PrChar
       endif

CALC    LD A,(HL)
CALCa   RRA 
        RRA 
        RRA 
        AND 7
        RET 

       macro dbletter s1
        if (s1&0x7f) < 'A'
        if (s1&0x7f) < ' '
        db s1
        else
        db s1+6
        endif
        else
        db (s1^SMALLLETTERADD)+6
        endif
       endm
       macro db1letter s1
        dbletter s1+128
       endm
       macro db2letter s1,s2
        dbletter s1
        dbletter s2+128
       endm
       macro db3letter s1,s2,s3
        dbletter s1
        dbletter s2
        dbletter s3+128
       endm
       macro db4letter s1,s2,s3,s4
        dbletter s1
        dbletter s2
        dbletter s3
        dbletter s4+128
       endm
       macro db5letter s1,s2,s3,s4,s5
        dbletter s1
        dbletter s2
        dbletter s3
        dbletter s4
        dbletter s5+128
       endm
       macro db6letter s1,s2,s3,s4,s5,s6
        dbletter s1
        dbletter s2
        dbletter s3
        dbletter s4
        dbletter s5
        dbletter s6+128
       endm
       macro db7letter s1,s2,s3,s4,s5,s6,s7
        dbletter s1
        dbletter s2
        dbletter s3
        dbletter s4
        dbletter s5
        dbletter s6
        dbletter s7+128
       endm
       macro db8letter s1,s2,s3,s4,s5,s6,s7,s8
        dbletter s1
        db7letter s2,s3,s4,s5,s6,s7,s8
       endm
COM7
        db4letter 'R','L','C','A';DB 88,82,73,199
        db4letter 'R','R','C','A';db 88,88,73,199
        db3letter 'R','L','A';db 88,82,199
        db3letter 'R','R','A';db 88,88,199
        db3letter 'D','A','A';db 74,71,199
        db3letter 'C','P','L';db 73,86,210
        db3letter 'S','C','F';db 89,73,204
        db3letter 'C','C','F';db 73,73,204
;8
        db3letter 'L','D',' ';db 82,74,166
;9
        db6letter 'L','D',' ',2,',',4;DB 82,74,38,2,50,132 ;rp,i16
COMN
         db3letter 'N','E','G';DB 84,75,205
;11
        db5letter 'I','N','C',' ',2;db 79,84,73,38,2+128 ;rp
;12
        db5letter 'I','N','C',' ',1;db 79,84,73,38,1+128 ;reg ;например, 0x3c
;13
        db5letter 'D','E','C',' ',1;db 74,75,73,38,1+128 ;reg ;например, 0x3d
;14
        db6letter 'L','D',' ',1,',',3;db 82,74,38,1,50,3+128 ;reg,i8 ;например, 0x3e
COMR
         db4letter 'R','E','T','N';DB 88,75,90,212
         db4letter 'R','E','T','I';db 88,75,90,207
;17
        db7letter 'A','D','D',' ',0,',',2;db 71,74,74,38,0,50,2+128 ;hl/ix/iy,rp
COML
        db5letter 'L','D',' ',1,',';DB 82,74,38,1,178 ;reg,
;19
        db5letter 'D','E','C',' ',2;db 74,75,73,38,2+128 ;rp
RP
        db2letter 'B','C';DB 72,201
        db2letter 'D','E';db 74,203
RPhl
        db2letter 'H','L';db 78,210
        db2letter 'S','P';db 89,214
COM5
        db6letter 'P','U','S','H',' ',2;DB 86,91,89,78,38,2+128 ;push rp ;bc
        db6letter 'C','A','L','L',' ',4;db 73,71,82,82,38,4+128 ;call i16
        db6letter 'P','U','S','H',' ',2;db 86,91,89,78,38,2+128 ;push rp ;de
COMJ
        db5letter 'R','E','T',' ',6;db 88,75,90,38,6+128 ;ret cc
        db6letter 'P','U','S','H',' ',2;db 86,91,89,78,38,2+128 ;push rp ;hl
        db6letter 'J','P',' ',6,',',4;db 80,86,38,6,50,4+128 ;jp cc,i16
        db7letter 'P','U','S','H',' ','A','F';db 86,91,89,78,38,71,204 ;push af
        db8letter 'C','A','L','L',' ',6,',',4;db 73,71,82,82,38,6,50,4+128 ;call cc,i16
COMH
        db4letter 'H','A','L','T';DB 78,71,82,218
COMHim
        db3letter 'I','M',' ';db 79,83,166
        db4letter 'R','S','T',' ';db 88,89,90,166
CC
       if SMALLLETTERADD
        db2letter 'N','z';DB 84,224 ;'z'+6=128!!!
        db1letter 'z';db 224
       else
        db2letter 'N','Z';DB 84,224 ;'z'+6=128!!!
        db1letter 'Z';db 224
       endif
        db2letter 'N','C';db 84,201
        db1letter 'C';db 201
        db2letter 'P','O';db 86,213
        db2letter 'P','E';db 86,203
        db1letter 'P';db 214
        db1letter 'M';db 211
COM0
        DB 84,85,214 ;nop
        db 75,94,38,71,76,50,71,76,173 ;ex af,af'
        db 74,80,84,96,38,133 ;djnz $+
        db 80,88,38,133 ;jr $+
        db 80,88,38,84,96,50,133 ;jr nz,$+
        db 80,88,38,96,50,133 ;jr z,$+
        db 80,88,38,84,73,50,133 ;jr nc,$+
        db 80,88,38,73,50,133 ;jr c,$+
COM
        DB 71,74,74,38,71,178 ;add a,
        db 71,74,73,38,71,178 ;adc a,
        db 89,91,72,166 ;sub
        DB 89,72,73,38,71,178 ;sbc a,
        db 71,84,74,166 ;and
        db 94,85,88,166 ;xor
        db 85,88,166 ;or
        db 73,86,166 ;cp
COMB
        DB 88,82,201 ;rlc
        db 88,88,201 ;rrc
        db 88,210 ;rl
        db 88,216 ;rr
        db 89,82,199 ;sla
        db 89,88,199 ;sra
        db 89,82,207 ;sli
        db 89,88,210 ;srl
        db 72,79,90,166 ;bit
        db 88,75,89,166 ;res
        DB 89,75,90,166 ;ret
COM3
        DB 80,86,38,4+128 ;jp i16
        db 166 ;NU
        db 85,91,90,38,46,3,47,50,199 ;out (i8),a
        db 79,84,38,71,50,46,3,175 ;in a,(i8)
        db 75,94,38,46,89,86,47,50,128 ;ex (sp),hl/ix/iy
        db 75,94,38,74,75,50,128 ;ex de,hl
        db 74,207 ;di
        db 75,207 ;ei
COM1
        DB 86,85,86,38,130 ;pop rp ;bc
        db 88,75,218 ;ret
        db 86,85,86,38,130 ;pop rp ;de
        db 75,94,222 ;exx
        DB 86,85,86,38,130 ;pop rp ;hl
        db 80,86,38,46,0,175 ;jp (hl/ix/iy)
        db 86,85,86,38,71,204 ;pop af
        db 82,74,38,2,50,128 ;ld rp,hl/ix/iy (rp=sp)
COME
        DB 82,74,38,79,50,199 ;ld i,a
        db 82,74,38,88,50,199 ;ld r,a
        db 82,74,38,71,50,207 ;ld a,i
        db 82,74,38,71,50,216 ;ld a,r
        db 88,88,202 ;rrd
        db 88,82,202 ;rld
        db 166 ;wrong ED XX
        DB 166 ;wrong ED XX
COMI
        DB 79,84,38,1,50,46,73,175 ;in reg,(c)
        db 85,91,90,38,46,73,47,50,129 ;out (c),reg
        DB 89,72,73,38,0,50,130 ;sbc hl,rp
        db 82,74,38,46,4,47,178 ;ld (i16), ;rp печатается отдельно с проверкой hl
        db 71,74,73,38,0,50,130 ;adc hl,rp
        db 82,74,38,2,50,46,4,175 ;ld rp,(i16)
COMM
        DB 82,74,207 ;ldi
        db 73,86,207 ;cpi
        db 79,84,207 ;ini
        db 85,91,90,207 ;outi
        db 82,74,79,216 ;ldir
        db 73,86,79,216 ;cpir
        db 79,84,79,216 ;inir
        db 85,90,79,216 ;otir
        db 82,74,202 ;ldd
        db 73,86,202 ;cpd
        db 79,84,202 ;ind
        db 85,91,90,202 ;outd
        db 82,74,74,216 ;lddr
        DB 73,86,74,216 ;cpdr
        db 79,84,74,216 ;indr
        db 85,90,74,216 ;otdr
COM2
        DB 46,2,47,50,199 ;(rp),a
        db 71,50,46,2,175 ;a,(rp)
        db 46,2,47,50,199 ;(rp),a
        db 71,50,46,2,175 ;a,(rp)
        db 46,4,47,50,128 ;(i16),hl/ix/iy
        db 0,50,46,4,175 ;hl/ix/iy,(i16)
        db 46,4,47,50,199 ;(i16),a
        db 71,50,46,4,175 ;a,(i16)

Disasm_GetCmdLen_bc
       ;push hl
        call Disasm_LEN ;return b=len
       ;pop hl
        LD A,B
        DEC A
        CP 5
        JR C,$+4
         LD B,1 ;если много префиксов, оставляем один
        ld c,b
        ld b,0
        ret

;COUNT Z80 COMMAND LENGTH
Disasm_LEN ;return b=len
        ;PUSH HL
        LD E,0x40;64 ;const (used 5 times)
        LD BC,#0301;769 ;c=1: не было dd/fd
LNX     LD D,(HL)
        LD A,D
        CP 0xdd;221
        JR NZ,LENL1
LENL0   INC HL
        INC C
        INC B
        JR LNX
LENL1
;b=3+
        CP 0xfd;253
        JR Z,LENL0 ;может зациклиться на префиксах
        CP 0xcd;205 ;call
        JR Z,LENend
        CP 0xc3;195 ;jp
        JR Z,LENend
        DEC B ;b=2+
        CP 0xcb;203
        JR Z,LENend
        CP 0xd3;211 ;out (n),a
        JR Z,LENend
        CP 0xdb;219 ;in a,(n)
        JR Z,LENend
        CP 0xed;237
        JR NZ,LENL2
;ed
        INC HL
        LD A,(HL)
        add a,a
        LD A,(HL)
        ;POP HL
        RET C
       ret p
;ed 40..7f
        AND 7
        CP 3
        RET NZ
        INC B
        INC B ;ld rp,(mm)/ld (mm),rp
        RET 
LENL2 ;b=2+
        AND 7
        JR NZ,LENL6
        LD A,D
        CP 16
        JR C,LENendB1
LNY     CP E;0x40
        JR LENL7
LENL6 ;b=2+
        CP 6
        JR NZ,LENL5
        LD A,D
        SUB E;0x40
;LENrlaL7
        RLA 
LENL7
        JR C,LENend
LENendB1
        dec b ;LD B,1
LENend
        ;POP HL
        DEC C
        RET Z ;не было dd/fd
;b=длина команды + длина префикса
;надо добавить 1 байт (iz+) для некоторых команд
        ;INC B
        LD A,D
        CP 0xcb;203
        JR Z,LENINCB ;везде появляется iz+d
        CP 0x34;52 ;inc (hl)/(iz+)
        ret c ;JR C,LENL3 ;<0x34
        CP 0x37;55
        
;TODO fix ld (ix),c - почему 4 байта?
        
       if 0
        CCF 
        JR LENretcINCB ;0x34..0x36: inc (hl),dec (hl),ld (hl),i8 do b++
       endif
       if 1
        JR c,LENINCB ;0x34..0x36: inc (hl),dec (hl),ld (hl),i8 do b++
        xor 6 ;чтобы halt вышел за диапазон сравнения
        cp 0x70
        ret z ;halt
        jr c,LENend_noldmreg
        cp 0x78
        jr c,LENINCB ;ld (hl),reg
LENend_noldmreg
        sub 0x40
        ret m
        and 7
        ret nz
        ;jr LENINCB
       endif
       if 0
LENL3
        AND 7
        CP 6
        JR NZ,LENL4
        LD A,D
        ADD A,E;0x40
        RLA
LENretcINCB
        RET C
       endif
LENINCB
        INC B
        RET
       if 0
LENL4
        XOR D
        CP 0x70 ;112
        RET NZ
        INC B
        RET
       endif

LENL5
        INC B ;b=3+
        CP 2
        JR NZ,LENL8
        LD A,D
        ADD A,E;0x40
        JR C,LENend
        CP 0x60 ;96
       dec b
        JR C,LENendB1
       inc b
        CPL 
        ;JR LENrlaL7
        RLA
        jr len3or1
LENL8 ;b=3+
        CP 4
        LD A,D
        JR NZ,LENL9
        ADD A,E;0x40
        ;JR LENL7
len3or1
        JR C,LENend ;call pp,nn
        dec b
        jr LENendB1
LENL9 ;b=3+
        AND 15
       dec b
        DEC A
        JR NZ,LENendB1
       inc b
        LD A,D
        JR LNY
