;maincode
;возврат в систему
;TODO через функцию системы (чтобы 0x0000 можно было использовать для своих целей, напр. структура NIL или указатель в 0xffff)
user_fdvalue1=$+1
        ld a,fd_system
        out (0xfd),a
;(в CP/M текущий дисковод!)
user_scr0_low=0x0004
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
        display "kernel_result_a=",$
kernel_result_a
        ex af,af'
        ret ;можно перенести вместо kernel_setpg
user_scr0_high=0x0017
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
        jr $
user_scr1_low=0x0032
        nop
user_scr1_high=0x0033
        nop
        ds 2
INTMICROSTACK ;2 байта до (стек) и 2 байта после (bc) ;di!!!
        ds 2

;int=4246t (из них 905t установка палитры, 874t чтение клавиатуры)
        ds 0x0038-$ ;0 b
        ex de,hl ;de="hl", hl="de"
        ex (sp),hl ;hl=адрес выхода, de="hl", в стеке "de"
         ;ld (intsp),sp ;можно убрать эту операцию в kernelspace
        ld (intjp),hl ;TODO писать не прямо в intjp, а в промежуточную локацию (иначе хвост обработчика нельзя с ei - он сам не может сменить режим обработки прерывания после jp)
        ld l,a
user_fdvalue6=$+1
        ld a,fd_system
        out (0xfd),a ;10 b
;---------
        ;ld sp,INTSTACK
        ;(keep bc in MICROSTACK)
        ;...
        ;ld sp,INTMICROSTACK
        ;ld a,%0101s111;%0x01sx1x ;для неисправленного АТМ2 надо A9=1, а номер страницы в 0x7ffd не будет влиять, если адресация по memportc000
        ;out (0xfd),a
;---------
;сейчас стек INTSTACK (иначе нельзя вызвать rst)
init_resident
;sp=INTMICROSTACK
;bc=memport0000
;d=pgmain
;e=значение для аккумулятора
;di
        out (c),d
curpg16k=$+1
        ld a,0;pgmain4000
        SETPG16K ;rst ;чтобы инлайнить, надо 9 байт лишних, а у нас только 5 (6?)
curpg32klow=$+1
        ld a,0;pgmain8000
        SETPG32KLOW ;rst
curpg32khigh=$+1
        ld a,0;pgmainc000
        SETPG32KHIGH ;rst
         pop bc
;        ld a,e
;intde=$+1
;        ld de,0
intsp=$+1
        ld sp,0xfffe;STACK-2 ;там de ;нельзя в kernelspace, т.к. вложенное прерывание запортит стек! и de уже должно быть присвоено
        ld a,e
        pop de ;TODO ld de, причём перед ld sp, иначе вложенное прерывание запортит стек!
         ei ;TODO в kernelspace (чтобы делать yield с включенными прерываниями), когда тут будет сохранение intsp, intjp через промежуточную локацию, а в kernelspace будет мьютекс
intjp=$+1
        jp 0x0100 ;main_go ;18+2 b

        display "end of user kernel=",$
        display "curpg16k=",curpg16k
        display "curpg32klow=",curpg32klow
        display "curpg32khigh=",curpg32khigh
