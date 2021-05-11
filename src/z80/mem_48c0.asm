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

;портит BC! (в этой версии не портит hl)
        MACRO putmem ;[hl]<=a
        ld ($+14),a
        ld a,h
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,1f;q ;0000 ;TODO RAM in 0000
        call set4000 ;OUTPG4000
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

;портит BC!
        MACRO getHL ;hl<=[de+=2]
        ld a,d
        add a,a
        jr c,6f;sl ;8000,c000
        jp m,4f;4000
        set 6,d
        call setrom ;OUTPG4000
        ld a,(de)
        ld l,a
        inc e
        jr nz,9f;same page in 0000
        inc d
        jp p,9f;same page in 0000
        call set4000 ;OUTPG4000
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
        call setrom ;OUTPG4000
        ld d,0x40
        ld a,(de)
        ld d,e;0
        jp 7f
4;4000
        call set4000 ;OUTPG4000
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
;TODO как убрать ld (),a в вызывающую процедуру, чтобы не перекладывать через bc?
        MACRO putmemBC
        ld a,b
        ld ($+31),a
        LD A,C
        ld ($+14),a
        ld a,h
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,1f;q ;0000 ;TODO RAM in 0000
        call set4000 ;OUTPG4000
6;sl
        LD (HL),0
1;q
        INC HL
        ld a,h
        add a,a
        jr c,6f;sl ;8000,c000
        jp p,1f;q ;0000 ;TODO RAM in 0000
        call set4000 ;OUTPG4000
6;sl
        LD (HL),0
1;q
        ENDM 
