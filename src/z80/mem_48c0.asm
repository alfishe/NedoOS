;8000,c000 - всегда замапленные страницы
;4000 - страница ПЗУ или текущая 4000 (каждый раз включать)
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
        MACRO mem ;page [hl] ;not used outside this module!
        ld a,h
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,3f;0000
        ld a,(curpg5) ;4000
        jp 5f;o
3;0000
        set 6,h
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

        MACRO get ;a<=[de]
        ld a,d
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,3f;0000
        ld a,(curpg5) ;4000
        OUTPG4000
        jp 6f;sl
3;0000
        set 6,d
        ld a,(currom) ;0000
        OUTPG4000
        ld a,(de)
        res 6,d
        jp $+4
6;sl
        ld a,(de)
        ENDM 

;портит BC!
        MACRO getHL ;hl<=[de+=2]
        ld a,d
        add a,a
        jr c,6f;sl ;8000,c000
        jp m,4f;4000
        set 6,d
        ld a,(currom) ;0000
        OUTPG4000
        ld a,(de)
        ld l,a
        inc e
        jr nz,9f;same page in 0000
        inc d
        jp p,9f;same page in 0000
        ld a,(curpg5) ;4000 after 3fff
        OUTPG4000
        ld d,0x40
        jp 5f;h<=(de)
9;same page in 0000
        ld a,(de)
        res 6,d
        jp 7f;h<=a
6;sl ;8000,c000
        ld a,(de)
        ld l,a
        inc e
        jr nz,5f;same page in 8000,c000
        inc d
        jr nz,5f;same page in 8000,c000
        ld a,(currom) ;0000 after ffff
        OUTPG4000
        ld d,0x40
        ld a,(de)
        ld d,e;0
        jp 7f
4;4000
        ld a,(curpg5) ;4000
        OUTPG4000
        ld a,(de)
        ld l,a
        inc de ;может выйти на 8000, но это не страшно - там всегда включена нужная страница
5;same page in 8000,c000
        ld a,(de)
7;
        ld h,a
        inc de
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
        MACRO putmemBC
        ld a,b
        ld ($+33),a
        LD A,C
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
        INC HL
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
