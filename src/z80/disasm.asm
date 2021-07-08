
ED      INC HL
        LD B,32
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
        LD DE,COMH+4
        RET NC
        CALL T0
        CALL CALC
        CP 1
        RET Z
        JR C,$+3
        DEC A
        ADD A,"0"
       jp Disasm_PrChar

C7      LD E,A
        LD A,(HL)
        AND 15
        CP 10
        LD A,E
        JR C,C8
        ADD A,2
C8      LD DE,COMI
        CP 3
        JR NZ,TXT
        LD C,(HL)
        CALL TEXT
        LD A,C
PAIR    CALL CALCa
        RRA 
        CP 2
        LD DE,RP
        JR NZ,TXT
LHL     LD DE,RP+4
        BIT 6,B
        JP Z,T0
        LD A,"I"
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
        CALL CT
        LD A,32
        JR B2

B1      RLCA 
        RLCA 
        AND 3
        ADD A,8
        CALL TEXT
        CALL CALC
        ADD A,"0"
       call Disasm_PrChar
        LD A,44
B2     call Disasm_PrChar
        LD A,(HL)
        BIT 5,B
        JR NZ,$+6
         AND 7
         CP 6
        CALL NZ,REG
        BIT 6,B
        RET Z
        INC B
        INC B
        JP R1p4

Disasm_COMMAND
        LD B,32
clear   LD A,(HL)
        CP 221
        JR NZ,CY
        LD B,"X"
CX      INC HL
        INC HL
        LD C,(HL)
        DEC HL
        JR clear

CY      CP 253
        JR NZ,CZ
        LD B,"Y"
        JR CX

CZ      CP 203
        JR Z,disasmbit
        CP 237
        JP Z,ED
        CP 118
        LD DE,COMH
        JR Z,T0
        CP 64
        JP NC,C1
        AND 7
        LD DE,COM0
        JR Z,jpCT
C0      CP 7
        LD DE,COM7
        JR Z,jpCT
        CP 2
        JR NZ,TZ
        LD A,8
        CALL TEXT
        LD DE,COM2
jpCT    JP CT

TZ      LD A,(HL)
        AND 15
        CP 12
        JR NC,TEXT
        ADD A,8
TEXT    OR A
        JR NZ,T7
T0      LD A,(DE)
        BIT 7,A
        PUSH AF
        PUSH DE
        AND 127
        JR NZ,T1
        CALL LHL
        JR T6

T1      DEC A
        JR NZ,T2
        CALL CALC
        CALL REG
        JR T6

T2      DEC A
        JR NZ,T3
        LD A,(HL)
        CALL PAIR
        JR T6

T3      DEC A
        JR NZ,T4
        INC HL
        LD C,(HL)
        CALL S7
        JR T6

T4      DEC A
        JR NZ,TX
        INC HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        CALL Disasm_PrHashWord_de
        JR T6

TX      DEC A
        JR NZ,TY
        INC HL
        PUSH HL
        LD E,(HL)
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
        LD DE,CC
        CALL CT
        JR T6

T5     call Disasm_PrChar
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
        LD DE,COML
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
        ADD A,66
        AND 71
        CP 70
        JR NZ,R0
        LD A,"H"
        JR R6

R0      CP 71
        JR NZ,R1
        LD A,"L"
R6     call Disasm_PrChar
        LD A,D
        AND 7
        CP 6
        RET Z
        XOR D
        CP 112
        RET Z
        LD A,B
        CP 88
        RET C
        LD A,B
R8     jp Disasm_PrChar

R1      CP 64
        JR NZ,R8
R1p4
        LD A,"("
       call Disasm_PrChar
        CALL LHL
        BIT 6,B
        JR Z,R5
        LD A,C
        RLA 
        LD A,"+"
        JR NC,R4
        XOR A
        SUB C
        LD C,A
        LD A,"-"
R4     call Disasm_PrChar
        CALL S7
R5      LD A,")"
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
        LD DE,COMJ+2
        JP NZ,TEXT
        CALL TEXT
        LD A,(HL)
        SUB 199
        LD C,A
S7      ;LD A,(S1)
        ;CP 24
        ;JR Z,S8_100 ;decimal mode
        LD A,"#"
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
        LD A,"#" ;WARNING! рассчитано на JR ZZZZZZ
       call Disasm_PrChar
        jp Disasm_PrWord_de
prhex_e
        LD A,E
       jp Disasm_PrHex_a

       if 0
        NOP 
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
       call Disasm_PrChar
        RET 
       endif

CALC    LD A,(HL)
CALCa   RRA 
        RRA 
        RRA 
        AND 7
        RET 

COM7    DB 88,82,73,199,88,88,73,199,88,82,199,88,88,199,74
        DB 71,199,73,86,210,89,73,204,73,73,204,82,74,166
        DB 82,74,38,2,50,132
COMN    DB 84,75,205,79,84,73,38,130,79,84,73,38,129,74
        DB 75,73,38,129,82,74,38,1,50,131
COMR    DB 88,75,90,212,88,75,90,207,71,74,74,38,0,50,130
COML    DB 82,74,38,1,178,74,75,73,38,130
RP      DB 72,201,74,203,78,210,89,214
COM5    DB 86,91,89,78,38,130,73,71,82,82,38,132,86,91,89,78
COMJ    DB 38,130,88,75,90,38,134,86,91,89,78,38,130,80,86,38
        DB 6,50,132,86,91,89,78,38,71,204,73,71,82,82,38,6,50
        DB 132
COMH    DB 78,71,82,218,79,83,166,88,89,90,166
CC      DB 84,224,224,84,201,201,86,213,86,203,214,211
COM0    DB 84,85,214,75,94,38,71,76,50,71,76,173,74,80,84,96
        DB 38,133,80,88,38,133,80,88,38,84,96,50,133,80,88,38
        DB 96,50,133,80,88,38,84,73,50,133,80,88,38,73,50,133
COM     DB 71,74,74,38,71,178,71,74,73,38,71,178,89,91,72,166
        DB 89,72,73,38,71,178,71,84,74,166,94,85,88,166,85,88
        DB 166,73,86,166
COMB    DB 88,82,201,88,88,201,88,210,88,216,89,82,199,89,88
        DB 199,89,82,207,89,88,210,72,79,90,166,88,75,89,166
        DB 89,75,90,166
COM3    DB 80,86,38,132,166,85,91,90,38,46,3,47,50,199,79,84
        DB 38,71,50,46,3,175,75,94,38,46,89,86,47,50,128,75,94
        DB 38,74,75,50,128,74,207,75,207
COM1    DB 86,85,86,38,130,88,75,218,86,85,86,38,130,75,94,222
        DB 86,85,86,38,130,80,86,38,46,0,175,86,85,86,38,71
        DB 204,82,74,38,2,50,128
COME    DB 82,74,38,79,50,199,82,74,38,88,50,199,82,74,38,71
        DB 50,207,82,74,38,71,50,216,88,88,202,88,82,202,166
        DB 166
COMI    DB 79,84,38,1,50,46,73,175,85,91,90,38,46,73,47,50,129
        DB 89,72,73,38,0,50,130,82,74,38,46,4,47,178,71,74
        DB 73,38,0,50,130,82,74,38,2,50,46,4,175
COMM    DB 82,74,207,73,86,207,79,84,207,85,91,90,207,82,74,79
        DB 216,73,86,79,216,79,84,79,216,85,90,79,216,82,74
        DB 202,73,86,202,79,84,202,85,91,90,202,82,74,74,216
        DB 73,86,74,216,79,84,74,216,85,90,74,216
COM2    DB 46,2,47,50,199,71,50,46,2,175,46,2,47,50,199,71,50
        DB 46,2,175,46,4,47,50,128,0,50,46,4,175,46,4,47,50
        DB 199,71,50,46,4,175

;COUNT Z80 COMMAND LENGTH
Disasm_LEN ;keep hl ;return b=len
        PUSH HL
        LD E,64
        LD BC,#0301;769
LNX     LD D,(HL)
        LD A,D
        CP 221
        JR NZ,LENL1
LENL0   INC HL
        INC C
        INC B
        JR LNX
LENL1
        CP 253
        JR Z,LENL0 ;может зациклиться на префиксах
        CP 205
        JR Z,LENend
        CP 195
        JR Z,LENend
        DEC B
        CP 203
        JR Z,LENend
        CP 211
        JR Z,LENend
        CP 219
        JR Z,LENend
        CP 237
        JR NZ,LENL2
        INC HL
        LD A,(HL)
        RLA 
        LD A,(HL)
        POP HL
        RET C
        AND 7
        CP 3
        RET NZ
        INC B
        INC B
        RET 
LENL2
        AND 7
        JR NZ,LENL6
        LD A,D
        CP 16
        JR C,LENendB1
LNY     CP E
        JR LENL7
LENL6
        CP 6
        JR NZ,LENL5
        LD A,D
        SUB E
LENrlaL7
        RLA 
LENL7
        JR C,LENend
LENendB1
        LD B,1
LENend
        POP HL
        DEC C
        RET Z
        INC B
        LD A,D
        CP 203
        JR Z,LENINCB
        CP 52
        JR C,LENL3
        CP 55
        CCF 
        JR LENretcINCB
LENL3
        AND 7
        CP 6
        JR NZ,LENL4
        LD A,D
        ADD A,E
        RLA
LENretcINCB
        RET C
LENINCB
        INC B
        RET 
LENL4
        XOR D
        CP 112
        RET NZ
        INC B
        RET 
LENL5
        INC B
        CP 2
        JR NZ,LENL8
        LD A,D
        ADD A,E
        JR C,LENend
        CP 96
        JR C,LENendB1
        CPL 
        JR LENrlaL7
LENL8
        CP 4
        LD A,D
        JR NZ,LENL9
        ADD A,E
        JR LENL7
LENL9
        AND 15
        DEC A
        JR NZ,LENendB1
        LD A,D
        JR LNY
