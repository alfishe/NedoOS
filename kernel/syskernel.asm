;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; KERNEL (system side) ;;;;;;;;;;;;;;;;;;;;;;;        
;при вызове #0005 в системе включены страницы: pgsystem, pgkillable, pgkillable, pgkillable (на случай порчи стеком)

MAXAPPS=16
bdosstack_sz=0;150 ;80 мало для загрузки файла, 110 мало для fopen (даже с INTSTACK2), 140 мало для чтения каталога (даже с INTSTACK2) ;0=отключить мьютекс BDOS

        macro BDOSSETPGSSCR
        ld a,pgscr0_0
        ld bc,memport8000
        out (c),a
        ld a,pgscr0_1
        ld b,memportc000_hi;#ff
        out (c),a
        endm

        macro BDOSSETPGFATFS
        call BDOS_setpgfatfs
        endm

        macro BDOSSETPGTRDOSFS
        call BDOS_setpgtrdosfs
        endm


fatfs.tabl=#4000
        include "fatfs_h.asm"
        
wassyscode
        disp #0000
syscode
        ds #0000+4-$
        jp sys_quit
        ds #0005+4-$
        jp callbdos

        ds #0009+4-$
        jp sys_getchar

        ds #0015-2-$
endsys_result_aq
        out (#fd),a
        display "kernel_result_a=",$
        ds #0010+5-$
;e=char
        if bdosstack_sz==0
        ld (sys_prchar_sp),sp
        ld sp,BDOSSTACK ;до этого момента прерывание может запороть любое место памяти (user sp >=#3b00)
        else
        exx
        ld hl,0
        add hl,sp
        ld iy,(appaddr)
        ;ld (iy+app.callbdos_sp),l
        ;ld (iy+app.callbdos_sp+1),h
        ld bc,app.bdosstack+bdosstack_sz
        add iy,bc
        ld sp,iy ;до этого момента прерывание может запороть любое место памяти (user sp >=#3b00)
        exx
        endif
        
        ld iy,(appaddr)
        call BDOS_prchar ;портит только #c000+, но сама восстанавливает pgkillable
        if bdosstack_sz==0
sys_prchar_sp=$+1
        ld sp,0
        else
        exx
        ;ld iy,(appaddr)
        ;ld l,(iy+app.callbdos_sp)
        ;ld h,(iy+app.callbdos_sp+1)
        ld sp,hl
        exx
        endif
        jp endsys_result_a

sys_timer
        ds 4

        ds #0030+4-$
        jp sys_farcall

        ds #0038-$
        jp sys_sysint

        ds #0038+9-$ -4
sys_intq
;bc=memport0000
;d=pgmain
;e=значение для аккумулятора
;a=screenpg
;iy="iy"
        ld sp,INTMICROSTACK
        out (#fd),a ;дальше попадаем в init_resident
;sp=INTMICROSTACK
;bc=memport0000
;d=pgmain
;e=значение для аккумулятора
;di

        ds #0038+14-$ -4
        ;TODO захватить мьютекс (прерывание внутри прерывания должно попасть в простой обработчик без шедулера)
        jp sys_intgo
        
        ds #0101-$ ;чтобы можно было ставить точку останова на #0100
sys_intgo
        ld (sys_int_iy),iy
appaddr=$+2
        ld iy,app1
         ld (sys_intsp),sp
        ld sp,iy ;safestack_end
         push af ;skipped
        exx
        push bc
        push de
        push hl
	push ix
        ;ld a,(iy+app.screen)
        push af ;f, a=screenpg
	ex af,af'
	push af
         exx
        ld h,(iy+app.mainpg)
	push de ;"hl"
        push hl ;h=mainpg,l="a"

        ld sp,iy
sys_int_iy=$+1
        ld de,0
        push de

        ld d,b
         ld e,c
        ld bc,memport4000
         out (c),h
         ld (INTMICROSTACK+#4000),de ;"bc"
sys_intsp=$+1
         ld hl,0
         ld (intsp+#4000),hl ;"sp"
        ld a,pgtrdosfs;pagexor-5
        out (c),a ;там INTSTACK

;sys_int_schedule_and_go
        ld sp,INTSTACK2

        call setgfxpal_focus

        call schedule ;out: hl=iy=app

        ;ld hl,(appaddr)
        ;ld iy,(appaddr)
        ;call iffocus_setgfx

        call on_int

        ld a,pgkillable
        ld bc,memport4000
        ld (sys_curpg4000),a
        out (c),a

sys_int_popregs
        ld de,-safestack_sz
        add iy,de
        ld sp,iy
        
	pop de ;d=mainpg,e="a"
	pop hl ;"hl"
        ld bc,memport0000
         exx
	pop af
	ex af,af'
        pop af ;f, a=screenpg
         ;ld a,(curscreen) ;(focusappaddr)+app.screen
         ld iy,(focusappaddr)
         ld a,(iy+app.screen)
	pop ix
        pop hl
        pop de
        pop bc
        exx
        pop iy
        ;TODO освободить мьютекс, можно включить прерывания
        jp sys_intq

        ;ds #0050-$
endsys_result_a
        ld iy,(appaddr)
        ex af,af'
        ld a,(iy+app.screen)
        jp endsys_result_aq

schedule
;find next app, set iy
;out: hl=iy=app
        ld hl,(appaddr)
        ld bc,-app_last;app_afterlast
        ld de,app_last+app_sz;app_sz
        ld a,MAXAPPS
findnextapp0
        ;add hl,de
        ;sbc hl,bc
        ;add hl,bc
        ;jr nz,$+5
        ;ld hl,app1
        add hl,bc
        jr nc,$+5
        ld hl,app1 -(app_last+app_sz)
        add hl,de
        bit factive,(hl)
        jr nz,findnextappq
        dec a
        jr nz,findnextapp_idle
findnextapp_idle
        ld hl,app1
findnextappq
        ld (appaddr),hl
        ld iy,(appaddr)
        ret

setgfxpal_focus
;если в yield не поставить палитру второй задаче, то она никогда не поставится, если первая задача в цикле делает yield
;потому что все прерывания будут ставить первую задачу
;если же палитру ставить в самом yield, то могут быть проблемы с выставлением палитры, если yield вызывать в случайных местах или если все задачи неактивны
;поэтому обработчик прерываний должен выставлять палитру и видеорежим задачи, которая в фокусе, независимо от её активности

        ;ld de,(focusappaddr)
        ;or a
        ;sbc hl,de
        ;jp nz,sys_int_nofocus
        ;add hl,de ;appaddr
        ;ld a,(iy+app.gfxmode)
        ;ld (sys_curgfxmode),a
;sys_int_nofocus
        
        ;TODO в момент переключения на focusapp (т.е. на предыдущем фрейме не было фокуса)
        ;;push iy
        ;;ld iy,(focusappaddr)
        ;call restoretextmode
        ;;pop iy

        ld hl,(focusappaddr)
        ld bc,app.gfxmode
        add hl,bc
        ld a,(hl)
        ld bc,#bd77
        out (c),a ;set gfx mode
        
        ;ld hl,(focusappaddr)
        ld bc,app.pal+31 -app.gfxmode
        add hl,bc
        
        ld c,#ff
        ld a,7
        dup 8
        OUT (#F6),A
        ld d,(hl)
        dec hl
        ld b,(hl) ;DDp palette low bits
        OUT (c),d;(#FF),A
        dec hl
        dec a
        edup
        ld a,7
        dup 7
        OUT (#FE),A
        ld d,(hl)
        dec hl
        ld b,(hl) ;DDp palette low bits
        OUT (c),d;(#FF),A
        dec hl
        dec a
        edup
        OUT (#FE),A ;0
        ld d,(hl)
        dec hl
        ld b,(hl) ;DDp palette low bits
        OUT (c),d;(#FF),A
        ret

sys_sysint
;TODO schedule (для RTOS), но тогда надо реентерабельность всех процедур BDOS (даже без этого шедулинга они всё равно не должны иметь состояния!)
;как шедулить, когда мы в kernelspace???
;TODO проверка критической секции (в обычном прерывании не нужно)
        ex de,hl
        ex (sp),hl ;восстановили стек из de
        ld (sys_sysint_jp),hl
        ld (sys_sysint_sp),sp
        ld sp,INTSTACK1
        push af
        push bc
        push de ;"hl"
        ;push hl
        exx
        ex af,af'
        push af
        push bc
        push de
        push hl
        push ix
        push iy
        ld sp,INTSTACK2

        ld bc,memport4000
        ld a,pgtrdosfs;pagexor-5 ;там INTSTACK
        out (c),a

        call setgfxpal_focus

        call on_int
sys_curpg4000=$+1
        ld a,pgkillable
        ld bc,memport4000
        out (c),a

        ld sp,INTSTACK1-18
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af'
        exx
        pop hl ;"hl"
        ;pop de
        pop bc
        pop af
sys_sysint_sp=$+1
        ld sp,0
        pop de
        ei
        ;ret
sys_sysint_jp=$+1
        jp 0
        
on_int
;в #4000 сейчас pg5, там стек
focusappaddr=$+1
        ld hl,app1
        ld bc,app.gfxmode
        add hl,bc
        ld e,(hl)
;sys_curgfxmode=$+1
        ;ld e,%10101000 ;320x200 mode
        call readmouse ;resident >=#4000
        ld (sys_mousecoords),hl
        ld a,d
	ld (sys_mousebuttons),a
        call readtime ;hl=date, de=time
        ld (sys_time_date),de
        ld (sys_time_date+2),hl

        ld hl,sys_timer
        inc (hl)
        inc hl
        jr nz,on_int_timerq
        inc (hl)
        inc hl
        jr nz,on_int_timerq
        inc (hl)
        inc hl
        jr nz,on_int_timerq
        inc (hl)
on_int_timerq
        
        call KEYSCAN

        ;call PEEKKEY ;ld a,(curkey)
        ;cp ssEnter
        
        ld a,#7f
        in a,(#fe)
        rra
        ld c,a ;c0=ss
        ld a,#bf
        in a,(#fe)
        or c
        cpl
        ld c,a
        cpl
        ;a0=c0=0: ssEnter pressed
on_int_oldssEnter=$+1
        or 0 ;=0: ssEnter was released
        rra
        ld a,c
        ld (on_int_oldssEnter),a
        jr c,sys_int_noselectapp
;кладём кнопку перерисовки, если её нет в очереди
         ;ld a,key_redraw
         ;ld (curkey),a
         call PEEKKEY ;ld a,(curkey) ;TODO смотреть голову очереди, а не хвост
         cp key_redraw
	 ld bc,key_redraw
	 ld (keyqueueput_codenolang),bc
	 call nz,KEYQUEUEPUT ;если переключились на неактивную задачу, то некому прочитать код!!

        ld hl,(focusappaddr)
        ld bc,-app_last;app_afterlast
        ld de,app_last+app_sz;app_sz
        ld a,MAXAPPS
findnextgfxapp0
        ;add hl,de
        ;sbc hl,bc
        ;add hl,bc
        ;jr nz,$+5
        ;ld hl,app1
        add hl,bc
        jr nc,$+5 ;hl < app_last
        ld hl,app1 -(app_last+app_sz)
        add hl,de
        bit fgfx,(hl)
        jr nz,findnextgfxappq
        dec a
        jr nz,findnextgfxapp0
        ld hl,app1
findnextgfxappq
        ld (focusappaddr),hl
sys_int_noselectapp

muzcall=$+1
	call sys_reter;pt3player.PLAY ;TODO call drivers

        ret

        
sys_getchar
;out: de=mouse dydx, l=buttons, A=key, H=high bits of key
        call checkfocus_getmouse
        call z,GETKEY ;A=key, H=high bits of key, BC=keynolang
        jp endsys_result_a
sys_getchar_fail
;nz
        ld a,NOKEY ;no key
         ;ld h,a
         ;ld b,a
         ld c,a ;no keynolang
        ld d,a;0
        ld e,a;0 ;no mouse movement
        ld l,#ff ;no buttons
        ret ;nz ;jp endsys_result_a

checkfocus_getmouse
;out: nz=fail
        ld de,(focusappaddr)
        ld hl,(appaddr)
        or a
        sbc hl,de
        jr nz,sys_getchar_fail ;nz
sys_mousecoords=$+1
        ld hl,0
sys_oldmousecoords=$+1
        ld de,0
        ld (sys_oldmousecoords),hl
        ld a,l
        sub e ;a=dx
        ld e,a ;e=dx
        ld a,d
        sub h ;a=dy
        ld d,a ;d=dy
sys_mousebuttons=$+1
        ld l,#ff
        xor a
        ret ;z
        
sys_farcall
        jp endsys_result_a


callbdos
;при вызове bdos надо включить:
;#0000 - syscode (уже включено)
;#4000 - fatfs
;[#8000 - curpg32klow]
;#c000 - curpg32khigh
;защита от одновременного доступа двум задачам
;занято a,bc,de,hl
;свободно iy
        if bdosstack_sz==0

        ld (callbdos_sp),sp
        ld sp,BDOSSTACK ;до этого момента прерывание может запороть любое место памяти (user sp >=#3b00)

        else
        
        exx
callbdos_lock        
        ld hl,callbdos_mutex ;изначально #c0
        sla (hl)
        jr z,callbdos_lock ;был занят
        
        ld hl,0
        add hl,sp
        ld iy,(appaddr)
        ;ld (iy+app.callbdos_sp),l
        ;ld (iy+app.callbdos_sp+1),h
        ld bc,app.bdosstack+bdosstack_sz
        add iy,bc
        ld sp,iy ;до этого момента прерывание может запороть любое место памяти (user sp >=#3b00)
        push hl
        exx
        
        endif
        
        ld iy,(appaddr)
        call BDOS
         push af
         push bc
         call setpgs_killable
        if bdosstack_sz !=0
        ld a,#c0
        ld (callbdos_mutex),a ;то же самое делают те функции BDOS, которые не собираются возвращаться
        endif
         pop bc
         pop af
         
        if bdosstack_sz==0
callbdos_sp=$+1
        ld sp,0
        else
        exx
        pop hl
        ld iy,(appaddr)
        ;ld l,(iy+app.callbdos_sp)
        ;ld h,(iy+app.callbdos_sp+1)
        ld sp,hl
        exx
        endif
        jp endsys_result_a

callbdos_mutex
        db #c0

setpgs_killable
        ld a,pgkillable
        ld bc,memport4000
        ld (sys_curpg4000),a
        out (c),a
        ld b,memport8000_hi;#bf
        out (c),a
        ld b,memportc000_hi;#ff
        out (c),a
        ret

sys_quit
;снять текущую задачу
        ld iy,(appaddr)
        ld e,(iy+app.id)
        call BDOS_freezeapp
        call BDOS_delapppages
        jp BDOS_yield_q ;переходим на какую-нибудь задачу
        
sys_reter
        ret

setkernelpages_go
;sp=#3ffx
;сейчас включена 5-я страница
        ;ld a,pgtrdosfs
        ;ld bc,memport4000
        ;ld (sys_curpg4000),a
        ;out (c),a
        ;ld hl,wasresident
        ;ld de,resident
        ;ld bc,resident_sz
        ;ldir

        BDOSSETPGTRDOSFS
        call makeidle
setkernelpages_go_iy
        ;ld sp,BDOSSTACK
        call setpgs_killable

        ;ld iy,(appaddr)
        ld d,(iy+app.mainpg)
;d=pgmain
;e=значение для аккумулятора
        ld bc,memport0000
        ld a,(iy+app.screen)
        jp sys_intq ;там ei


sys_findfreeappstruct
;out: nz=error, iy=free struct
        ld iy,app1
        ld de,app_sz
        ld b,MAXAPPS
        xor a
sys_findfreeappstruct0
        cp (iy+app.id)
        ret z ;iy = free app struct
        add iy,de
        djnz sys_findfreeappstruct0
;too many apps!!!
        ret ;nz
        
sys_findfreeid
        xor a
sys_findfreeid_next
        inc a ;a!=0 (0 и #ff нельзя - см. BDOS_newpage)
        ld iy,app1
        ld de,app_sz
        ld b,MAXAPPS
sys_findfreeid0
        cp (iy+app.id)
        jr z,sys_findfreeid_next
        add iy,de
        djnz sys_findfreeid0
;a=free id
        ret
        
        
        
safestack_sz=18
        STRUCT app
flags           BYTE ;флаги (всегда в начале структуры)
;priority        BYTE ;TODO приоритет (0=конец списка)
id              BYTE ;номер задачи (0=свободно)
parentid        BYTE ;номер родительской задачи
mainpg          BYTE ;главная страница задачи (там userkernel)
;callbdos_sp     WORD ;сюда сохраняется стек при вызове BDOS
;curmsg          WORD ;TODO адрес текущего сообщения этой задаче
;endmsg          WORD ;TODO адрес конца очереди сообщений этой задаче
;sp              WORD ;текущий адрес стека (лежит в mainpg:intsp)
;next            WORD ;TODO указатель на следущую задачу (следующая за выполняемой внутри того же приоритета)
screen          BYTE ;текущий номер экрана ;fd_user + 8*screen
gfxmode         BYTE ;текущий видеорежим ;значение для #bd77
textcuraddr     WORD ;адрес курсора на экране
curcolor        BYTE ;текущий атрибут при печати
dta             WORD ;data transfer address
vol             BYTE ;текущий драйв (volume)
dircluster      DWORD ;текущая директория
dir             BLOCK DIR_sz ;временный буфер для чтения каталога
bdosstack       BLOCK bdosstack_sz ;стек при вызове BDOS
pal             BLOCK 32
;safestack       BLOCK safestack_sz ;de,hl,af',af,ix,hl',de',bc',iy
        ENDS

        display "apps start=",/h,$
safestack
        ds safestack_sz
app1    app
app_sz=$-safestack

        ds (MAXAPPS-1)*app_sz
        display "MAXAPPS=",/h,MAXAPPS

app_afterlast=$+safestack_sz
app_last=app_afterlast-app_sz
        display "app1=",/h,app1
        display "app_last=",/h,app_last
        
        include "syskey2.asm"
        
        include "fatfs_drivers.asm"
        include "sysbdos.asm"
        ent
syscodesz=$-wassyscode
        display "syscodesz=",/h,syscodesz," < minstack=",/h,SYSMINSTACK
