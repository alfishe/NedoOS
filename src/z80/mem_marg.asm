;4000 - страница команд (может подменяться при доступе к данным, но потом вызывается OUTcom)
;8000,c000 - страницы в 8000,c000

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

        MACRO next
        inc e
        call z,next_incd
        ENDM 

;TODO вариант с call nc после большинства команд, работающих с памятью
        MACRO OUTcom ;если вместо стр.команд включили др.стр.
        ;LD HL,(curquart)
        ;LD A,(HL)
        ;OUTPGCOM
        call set4000com ;проскакивает, если 4000 не щёлкали
        ENDM 

        MACRO CALCpgcom ;изменилась конфигурация памяти, надо включить страницу для DE(PC)
        ;LD HL,(curquart)
        ;LD A,(HL)
        ;OUTPGCOM
        call set4000com ;проскакивает, если 4000 не щёлкали
        ENDM 

     ;перед JR/CALL/RST (на входе - урезанный DE(PC), а надо получить полный)
        MACRO CALCpc
        LD A,(curquart) ;один из 4 адресов подряд, где лежат текущие страницы в окнах ;a=0,1,2,3 for 4000,8000,c000,0000
        RRCA 
        RRCA ;a=0x00,0x40,0x80,0xc0 for 4000,8000,c000,0000
        add a,d ;d=0x40+
        LD D,A ;0x40,0x80,0xC0,0x00 for 4000,8000,c000,0000
        ENDM 

     ;после JR/JP/CALL/RST/RET (на входе - полный DE(PC), а надо получить урезанный)
     ;в случае CALL/RST/RET могла подмениться 4000
        MACRO CALCiypgcom
        ld a,d
        rlca
        rlca
        dec a
        and 3 ;a=0,1,2,3 for 4000,8000,c000,0000
        res 7,d
        set 6,d
       ;ld hl,(curquart)
       ;cp l
       ;jp z,1f ;не получится после щёлканья в 4000
        ld (curquart),a
        ld l,a
        ld h,currom/256
        LD A,(HL)
        OUTPGCOM
        ld a,0xc9
        ld (set4000com),a
        ;ld a,0x3e
        ;ld (setrom),a
        ;ld (getde0000ret),a
        ;ld (set4000),a
        ;ld (set4000forwrite),a
1;oldpg
        ENDM 

;портит HL,BC!
        MACRO mem ;page [hl]
        ld a,h
        add a,a
        call nc,setmem00004000
        ENDM 

        MACRO getmem ;a<=[hl]
        mem
        LD A,(HL)
        ENDM 

;портит BC!
        MACRO putmem ;a<=[hl]
        ld c,a
        ld a,h
        add a,a
        call nc,setmem00004000forwrite
       if extpg5
        call c,setmem8000c000forwrite
       endif
        LD (HL),c
        ENDM 

;портит HL,A!
        MACRO getmemBC
        ld a,h
        add a,a
        call nc,setmem00004000
        LD C,(HL)
        INC L
        JP NZ,1f;q ;внутри mem нет метки 1
        rra
        ld h,a
        INC h
        mem
1;q
        LD B,(HL)
        ENDM 

;портит HL,A!
        MACRO putmemBC
        ld a,h
        add a,a
        call nc,setmem00004000forwrite
       if extpg5
        call c,setmem8000c000forwrite
       endif
        LD (HL),c
       if extpg5
        rra
        ld h,a
        inc hl
       else
        INC L
        JP NZ,1f;q
        rra
        ld h,a
        INC h
       endif
        ld a,h
        add a,a
        call nc,setmem00004000forwrite
       if extpg5
        call c,setmem8000c000forwrite
       endif
1;q
        LD (HL),b
        ENDM 
