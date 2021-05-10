;TODO macro next ;de++ с переключением текущей страницы
;TODO macro mem ;pg [hl] ;not used outside this module
;TODO macro getmem ;a<=[hl]
;TODO macro putmem ;[hl]<=a

        MACRO get
        LD A,(DE)
        ENDM 

        MACRO getHL
        get
        next
        LD L,A
        get
        next
        LD H,A
        ENDM 

        MACRO OUTcom
        LD A,(curpgcom)
        OUTPG
        ENDM 

        MACRO CALCpgcom
        LD HL,(curquart)
        LD A,(HL)
        LD (curpgcom),A
        OUTPG
        ENDM 

     ;перед JR/CALL/RST
        MACRO CALCpc
        LD A,(curquart)
        SUB currom
        RRCA 
        RRCA 
        XOR D
        AND #C0
        XOR D
        LD D,A
        ENDM 

     ;после JR/JP/CALL/RST/RET (на входе - полный DE)
        MACRO CALCiypgcom
        LD A,D
        ADD A,A
        jr NC,4f;lo
          JP M,3f;pg
            SET 6,D
            LD HL,curpg2
            LD IY,marg2
           JP 5f;o
3;pg
            LD HL,curpghi
            LD IY,marg3
           JP 5f;o
4;lo
           JP M,6f;sl
            LD A,D
            OR #C0
            LD D,A
            LD HL,currom
            LD IY,marg0
           JP 5f;o
6;sl
            LD HL,curpg5
            LD IY,marg1
            SET 7,D
5;o
        LD (curquart),HL
        LD A,(HL)
        LD (curpgcom),A
        OUTPG
        ENDM 

;портит HL,A!
        MACRO getmemBC
       PUSH HL
        mem
        LD C,(HL)
        INC L
        JP NZ,1f;q ;внутри mem нет метки 1
       POP HL
       PUSH BC
        INC HL
        mem
       POP BC
        JP $+4
1;q
       POP AF ;просто скипаем
        LD B,(HL)
        ENDM 

;портит HL,A,BC!
;нельзя ускорить, иначе не перехватить экран
;сделать ветку?
;вообще не перехватывать экран?
        MACRO putmemBC
       PUSH HL
       PUSH BC
        LD A,C
        putmem
       POP AF
       POP HL
        INC HL
        putmem
        ENDM 
