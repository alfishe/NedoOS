;---------------------------------------
; Depacker Laser Compact 5.2
; +0(5): "LCMP5"
; +5(2): Length screen without header
; +7(1): Additional info length:
;-------
; 11 byte - File name
; N byte - Comment.
;-------
;(C) Hrumer. 06.12.99. Hrumer@inbox.ru
;
; IN: HL - Address of compressed screen
;---------------------------------------


;deblcscradr     EQU #4000;#8000;#C000

deblc
        LD DE,7;SKIP "LCMP5" & LENGTH
        ADD HL,DE

        LD A,(HL)
        INC HL
        LD E,A
        ADD HL,DE

        LD A,(HL)
        LD E,A;ÐÀÇÐÛÂ

        AND 3
        RLCA 
        RLCA 
        RLCA 
        OR deblcscradr/256

        EXX 
        LD D,A;ÍÀ×ÀËÎ
        LD E,0
        EXX 

        LD A,(HL)
        INC HL
        XOR deblcscradr/256+#18
        AND #FC
        LD HX,A;ÊÎÍÅÖ ×. ÈÇÎ.

dlc1    LD A,(HL)
        INC HL
        LD LX,#FF
dlc2
        EXX 
        JR NZ,dlc10
        LD B,1

dlc3    EX AF,AF'
        SLA D
        JR NZ,$+6
        LD D,(HL)
        INC HL
        SLI D

        DJNZ dlc7

        JR C,dlc1

        INC B
;-----------
dlc4    LD C,#56;            %01010110
        LD A,#FE
dlc5    SLA D
        JR NZ,$+6
        LD D,(HL)
        INC HL
        RL D
        RLA 
        SLA C
        JR Z,dlc6
        JR C,dlc5
        RRCA 
        JR NC,dlc5
        SUB 8
dlc6    ADD A,9
;---------
        DJNZ dlc3

        CP 0-8+1
        JR NZ,$+4
        LD A,(HL)
        INC HL

        ADC A,#FF
        LD LX,A
        JR C,dlc4
        LD HL,#2758
        EXX 
        RET 
;-------------
dlc7    LD A,(HL)
        INC HL

        EXX 
        LD L,A
        EX AF,AF'
        LD H,A
        ADD HL,DE

        CP #FF-2
        JR NC,dlc8
        DEC LX
dlc8
        LD A,H
        CP HX
        JR NC,dlc13
        XOR L
        AND #F8
        XOR L
        LD B,A
        XOR L
        XOR H
        RLCA 
        RLCA 
        LD C,A

dlc9    EX AF,AF'
        LD A,(BC)
dlc10   EX AF,AF'
        LD A,D
        CP HX
        JR NC,dlc14
        XOR E
        AND #F8
        XOR E
        LD B,A
        XOR E
        XOR D
        RLCA 
        RLCA 
        LD C,A

dlc11   EX AF,AF'
        LD (BC),A

        INC DE
        JR NC,$+4
        DEC HL
        DEC HL
        INC HL
        EX AF,AF'
        INC LX
        JR NZ,dlc8
        JR dlc2

dlc13   SCF 
dlc14   PUSH AF
        EXX 
        ADD A,E
        EXX 
        LD B,A
        POP AF
        LD C,E
        JR NC,dlc11
        LD C,L
        JR dlc9

;LENDEC  EQU $-DECOMPR

