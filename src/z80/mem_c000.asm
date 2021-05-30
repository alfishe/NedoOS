;без ускорения через margins
        MACRO OUTcom
        ENDM 
        MACRO OUTcomCY15
        ENDM 
        MACRO CALCpgcom
        ENDM 
        MACRO CALCpc
        ENDM 
        MACRO CALCiypgcom
        ENDM 

        MACRO next
        INC DE
        ENDM 

;портит HL,BC!
;оптимизен slow (там в 95% случаев стек)
        MACRO mem ;page [hl]
        LD A,H
        ADD A,A
        jr NC,4f;lo
          JP M,3f;pg
            SET 6,H
            LD A,(emulcurpg8000)
           JP 5f;o
3;pg
           LD A,(emulcurpgc000)
           JP 5f;o
4;lo
            JP M,6f;sl
            LD A,H
            OR #C0
            LD H,A
            LD A,(emulcurpg0000)
       IF extpg5
           JP 5f;o
6;sl
            LD A,(emulcurpg4000)
            SET 7,H
       ENDIF 
5;o
        OUTPG
       IF extpg5==0
6;sl
       ENDIF 
        ENDM 

        MACRO getmem ;a<=[hl]
        mem
        LD A,(HL)
        ENDM 

;портит BC,HL!
        MACRO putmem ;[hl]<=a
        ;LOCAL 
        ;module lcl
        ;LD (aa),A
        ld ($+0x28),a
        LD A,H
        ADD A,A
        jr NC,4f;lo
          JP M,3f;pg
            SET 6,H
            LD A,(@emulcurpg8000)
           JP 5f;o
3;pg
           LD A,(@emulcurpgc000)
       IF @extpg5
            CP @pg5
           JP NZ,5f;o
            RES 7,H
           JP 6f;sl
       ELSE 
           JP 5f;o
       ENDIF 
4;lo
          JP M,6f;sl
            LD A,(@romon0) ;0=ПЗУ, #C0=ОЗУ
            OR H
           JP P,1f;q ;невозможно putmem в ПЗУ
            LD H,A
            LD A,(@emulcurpg0000)
       IF extpg5
           JP 5f;o
6;sl
        BIT 5,H
        jr NZ,7f;ns
        LD A,L
        AND #1F
        CP 24
        jr NC,ns
         LD A,(aa)
         LD (HL),A ;экран
7;ns
        SET 7,H
        LD A,@pg5
       ENDIF 
5;o
        OUTPG
       IF @extpg5==0
6;sl
       ENDIF 
;aa=$+1
        LD (HL),0
1;q
        ;ENDL 
        ;endmodule
        ENDM 

;оптимизено ПЗУ и pg2
;портит BC,DE!
        MACRO getnp ;a<=[de] ;not used outside this module!
        LD A,D
        ADD A,A
        jr NC,4f;lo
          JP M,3f;pg
            SET 6,D
            LD A,(emulcurpg8000)
           JP 5f;o
3;pg
           LD A,(emulcurpgc000)
           JP 5f;o
4;lo
       IF extpg5
          JP P,8f;r
            LD A,(emulcurpg4000)
            SET 7,D
           JP 5f;o
       ELSE 
          JP M,9f;q
       ENDIF 
8;r
            LD A,D
            OR #C0
            LD D,A
            LD A,(emulcurpg0000)
5;o
        OUTPG
9;q
        LD A,(DE)
        ENDM 

        MACRO get ;a<=[de]
        PUSH DE
        getnp
        POP DE
        ENDM 

;портит BC!
        MACRO getHL ;hl<=[de+=2]
       PUSH DE
        getnp
        LD L,A
        INC E
        JP NZ,2f;x
       POP DE
       ;PUSH BC
        next
        get
       ;POP BC
        JP $+6
2;x
       LD A,(DE) ;the same page
       POP DE
       INC E
        next
        LD H,A
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
