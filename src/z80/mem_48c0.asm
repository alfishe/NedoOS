;8000,c000 - всегда замапленные страницы
;4000 - страница ПЗУ или текущая 4000
        MACRO OUTcom
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
        ld a,h
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,3f;0000
        ld a,(curpg5) ;4000
        jp 5f;o
3;0000
        set 5,h
        ld a,(currom) ;0000
5;o
        OUTPG4000
6;sl
        ENDM 

        MACRO getmem ;a<=[hl]
        mem
        LD A,(HL)
        ENDM 

;портит BC! (в этой версии не портит hl)
        MACRO putmem ;[hl]<=a
        ld ($+15),a
        ld a,h
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,1f;q ;0000
        ld a,(curpg5) ;4000
        OUTPG4000
6;sl
        LD (HL),0
1;q
        ENDM 

;портит BC,DE!
        MACRO getnp ;a<=[de]
        ld a,d
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,3f;0000
        ld a,(curpg5) ;4000
        jp 5f;o
3;0000
        set 5,d
        ld a,(currom) ;0000
5;o
        OUTPG4000
6;sl
        ld a,(de)
        ENDM 

        MACRO get ;a<=[de]
        ld a,d
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,3f;0000
        ld a,(curpg5) ;4000
        OUTPG4000
        jp 6f;sl
3;0000
        set 5,d
        ld a,(currom) ;0000
        OUTPG4000
        ld a,(de)
        res 5,d
        jp $+4
6;sl
        ld a,(de)
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
       LD A,(DE)
       POP DE
       INC DE
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
