;maincode
;возврат в систему
;TODO через функцию системы (чтобы 0x0000 можно было использовать для своих целей, напр. структура NIL или указатель в 0xffff)
user_fdvalue1=$+1
        ld a,fd_system
        out (0xfd),a
;(в CP/M текущий дисковод!)
        nop

        ds 0x0005-$ ;0 b
;вызов функции системы
;TODO сделать рестарт, с сохранением аккумулятора
user_fdvalue2=$+1
        ld a,fd_system
        out (0xfd),a
;getchar=0x0009 (можно rst 0x08)
user_fdvalue3=$+1
        ld a,fd_system
        out (0xfd),a
kernel_setpg
        out (c),a
        ret

        ds 0x0010-$ ;0 b
;putchar=0x0010
        ld e,a
user_fdvalue4=$+1
        ld a,fd_system
        out (0xfd),a
kernel_result_a
        ex af,af' ;'
        ret ;можно перенести вместо kernel_setpg
user_scr0_low=0x0017
        nop

;TODO убрать рестарты включения страниц, вместо них сделать вызовы (будет быстрее из-за отсутствия jr)
        ds 0x0018-$ ;1 b
;setpg4000=0x0018
        ld bc,memport4000
        ld (curpg16k),a
        jr kernel_setpg

        ds 0x0020-$ ;0 b
;setpg8000=0x0020
        ld bc,memport8000
        ld (curpg32klow),a
        jr kernel_setpg

        ds 0x0028-$ ;0 b
;setpgc000=0x0028
        ld bc,memportc000
        ld (curpg32khigh),a
        jr kernel_setpg

        ds 0x0030-$ ;0 b
        jp $
        nop
        nop
user_scr0_high=0x0035
        nop
user_scr1_low=0x0036
        nop
user_scr1_high=0x0037
        nop

;int=3946t / 1800t без палитры (из них 905t установка палитры, 874t чтение клавиатуры)
        ds 0x0038-$ ;0 b
        push af
        push bc
        push de
user_fdvalue6=$+1
        ld a,fd_system ;%0x0Ksx1x ;для неисправленного АТМ2 надо A9=1, а номер страницы в 0x7ffd не будет влиять, если адресация по memportc000
        out (0xfd),a ;7 b
;---------
init_resident
;di ;сейчас мы в стеке чужой задачи, т.к. свою ещё не включили!!! можем запороть чужой стек!!!
;bc=memport0000
;d=pgmain
       nop
       ei ;for YIELD: interrupt will be enabled after the following command (31 t-states di:out:ei:out, normal INT len = 32 t)
;for normal exit
        out (c),d ;may switch this code page
curpg16k=$+1
        ld a,pgkillable;0;pgmain4000
        ld b,memport4000/256
        out (c),a
curpg32klow=$+1
        ld a,pgkillable;0;pgmain8000
        ld b,memport8000/256
        out (c),a
curpg32khigh=$+1
        ld a,pgkillable;0;pgmainc000
        ld b,memportc000/256
        out (c),a
        pop de
        pop bc
        pop af
       ei ;for normal exit
        ret

        display "end of user kernel=",$
        display "curpg16k=",curpg16k
        display "curpg32klow=",curpg32klow
        display "curpg32khigh=",curpg32khigh
