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
        call nc,setmem00004000
        ENDM 

        MACRO getmem ;a<=[hl]
        mem
        LD A,(HL)
        ENDM 

;портит BC! (в версии без ПЗУ не портило hl, но это ни на что не влияет)
        MACRO putmem ;[hl]<=a
        ld ($+9),a
        ld a,h
        add a,a
        ;jr c,6f;sl ;8000,c000
        ;jp p,1f;q ;0000 ;TODO RAM in 0000
        call nc,setmem00004000forwrite;set4000 ;OUTPG4000
6;sl
        LD (HL),0
1;q
        ENDM 

        MACRO get ;a<=[de]
        ld a,d
        add a,a
         ld a,(de)
        call nc,getde00004000
        ENDM     

       if 0
;портит BC!
;used only for reading command parameters, so we can ignore the case ffff->0000
        MACRO getHL ;hl<=[de+=2]
        ld a,d
        add a,a
         ld a,(de)
        call nc,getde00004000
        ld l,a
       inc de
        ld a,d
        add a,a
         ld a,(de)
        call nc,getde00004000
        ld h,a
       inc de
        ENDM 
       endif

;портит BC!
;used only for reading command parameters, so we can ignore the case ffff->0000
        MACRO getHL ;hl<=[de+=2]
        ld a,d
        add a,a
         ld a,(de)
        jr c,6f;sl ;8000,c000
        jp m,4f;4000
        call getde0000l_getde00004000
        jp 7f;h<=a
4;4000
        call set4000 ;OUTPG4000
        ;ld a,(de)
6;sl ;8000,c000
        ;ld a,(de)
        ld l,a
        inc de ;может выйти на 8000, но это не страшно - там всегда включена нужная страница
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
       ;PUSH BC
        INC HL
        mem
       ;POP BC
        JP $+4
1;q
       POP AF ;просто скипаем
        LD B,(HL)
        ENDM 

;портит HL,A,BC!
;TODO как убрать ld (),a в вызывающую процедуру, чтобы не перекладывать через bc?
        MACRO putmemBC
        ;ld a,b
        ;ld ($+23),a
        ;LD A,C
        ;ld ($+10),a
       push hl
        ld a,h
        add a,a
        ;jr c,6f;sl ;8000,c000
        ;jp p,1f;q ;0000 ;TODO RAM in 0000
        call nc,setmem00004000forwrite;set4000 ;OUTPG4000
6;sl
        LD (HL),c;0
1;q
       pop hl
       ;rra
       ;ld h,a
        INC HL
        ld a,h
        add a,a
        ;jr c,6f;sl ;8000,c000
        ;jp p,1f;q ;0000 ;TODO RAM in 0000
        call nc,setmem00004000forwrite;set4000 ;OUTPG4000
6;sl
        LD (HL),b;0
1;q
        ENDM 
