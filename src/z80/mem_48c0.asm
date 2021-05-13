;8000,c000 - всегда замапленные страницы
;4000 - страница ПЗУ или текущая 4000 (каждый раз включать)
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

        MACRO get ;a<=[de]
        ld a,d
        add a,a
         ld a,(de)
        call nc,getde00004000
        ENDM     

;портит BC!
;used only for reading command parameters, so we can ignore the case ffff->0000
        MACRO getHL ;hl<=[de+=2]
        ld a,d
        add a,a
         ld a,(de)
        jr c,6f;8000,c000
        jp m,4f;4000
        call getde0000l_getde00004000
        jp 7f;h<=a
4;4000
        call set4000
6;8000,c000
        ld l,a
        inc de ;может выйти на 8000, но это не страшно - там всегда включена нужная страница
        ld a,(de)
7;
        ld h,a
        inc de
        ENDM 

        MACRO next
        INC DE
        ENDM 

        MACRO mem ;a<=[hl]
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
        ld c,a
        ld a,h
        add a,a
        call nc,setmem00004000forwrite
        LD (HL),c
        ENDM 

;портит HL,A!
        MACRO getmemBC
        ld a,h
        add a,a
        call nc,setmem00004000
        LD C,(HL)
        INC L
        JP NZ,1f;q
       rra
       ld h,a
        INC h
        ld a,h
        add a,a
        call nc,setmem00004000
1;q
        LD B,(HL)
        ENDM 

;портит HL,A!
        MACRO putmemBC
        ld a,h
        add a,a
        call nc,setmem00004000forwrite
        LD (HL),c
       rra
       ld h,a
        INC HL
        ld a,h
        add a,a
        call nc,setmem00004000forwrite
        LD (HL),b
        ENDM 
