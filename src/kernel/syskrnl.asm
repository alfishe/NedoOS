;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; KERNEL (system side) ;;;;;;;;;;;;;;;;;;;;;;;        
;при вызове 0x0005 в системе включены страницы: pgsystem, pgkillable, pgkillable, pgkillable (на случай порчи стеком)

MAXAPPS=16
bdosstack_sz=0;150 ;80 мало для загрузки файла, 110 мало для fopen (даже с INTSTACK2), 140 мало для чтения каталога (даже с INTSTACK2) ;0=отключить мьютекс BDOS

QUITSTACK=0x4000 ;<=0x4000

        macro BDOSSETPGSSCR
        call sys_setpgsscr
        endm

        macro BDOSSETPGFATFS
        call BDOS_setpgfatfs
        endm

        macro BDOSSETPGTRDOSFS
        call BDOS_setpgtrdosfs
        endm

        macro BDOSSETPGW5300
        call BDOS_setpgtrdosfs
        endm


fatfs.tabl=0x4000
        include "fatfs_h.asm"
        
wassyscode
        disp 0x0000
syscode
sys_time_date
        ds 4

        ds 0x0000+4-$
        jp sys_quit

sys_reter
	ret

callbdos_mutex
        db 0xc0
        ds 0x0005+4-$
        jp callbdos

        ds 0x0009+4-$
        jp sys_getchar

sys_farcall
        jp endsys_result_a

        ds 0x0015-2-$
endsys_result_aq
        out (0xfd),a
        display "kernel_result_a=",$
        ds 0x0010+5-$
        jp fastprchar

        ds 0x0018-$
;setpg4000=0x0018
        ld bc,memport4000
        out (c),a
        ret

        ds 0x0020-$
;setpg8000=0x0020
        ld bc,memport8000
        out (c),a
        ret

        ds 0x0028-$
;setpgc000=0x0028
        ld bc,memportc000
        out (c),a
        ret

sys_timer
        ds 4

        ds 0x0030+4-$
        jp sys_farcall

        ds 0x0038-$
        jp sys_sysint

        ds 0x0038+7-$ -3
sys_intq
;bc=memport0000
;d=pgmain
;a=screenpg
       di ;на время до включения нужной pg0000, чтобы не запороть чужой стек
        out (0xfd),a ;дальше попадаем в init_resident
;выход в конец юзерского обработчика прерываний

;вход из начала юзерского обработчика прерываний
        ;ds 0x0038+14-$ -4
        ;TODO захватить мьютекс (прерывание внутри прерывания должно попасть в простой обработчик без шедулера)
        jp sys_intgo ;нужно, чтобы можно было ставить точку останова на 0x0100

fastprchar
;e=char
        if bdosstack_sz==0
        ld (sys_prchar_sp),sp
        ld sp,BDOSSTACK ;до этого момента прерывание может запороть любое место памяти (user sp >=0x3b00)
        else
        exx
        ld hl,0
        add hl,sp
        ld iy,(appaddr)
        ;ld (iy+app.callbdos_sp),l
        ;ld (iy+app.callbdos_sp+1),h
        ld bc,app.bdosstack+bdosstack_sz
        add iy,bc
        ld sp,iy ;до этого момента прерывание может запороть любое место памяти (user sp >=0x3b00)
        exx
        endif
        
        ld iy,(appaddr)
        call BDOS_prchar ;портит только 0xc000+, но сама восстанавливает pgkillable
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

        ds 0x0100-$ ;stack for CP/M programs
        
safestack_sz=16 +2 ;на запарывание прерыванием
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
stdin           BYTE
stdout          BYTE
stderr          BYTE ;TODO не нужен?
lasttime        BYTE
border          BYTE ;текущий цвет бордера 0..15
screen          BYTE ;текущий номер экрана ;fd_user + 8*screen
gfxmode         BYTE ;текущий видеорежим ;значение для 0xbd77
gfxkeep         BYTE ;b7 = keep gfx pages
scr0low         BYTE ;pages
scr0high        BYTE ;pages
scr1low         BYTE ;pages
scr1high        BYTE ;pages
childresult     WORD ;filled by closed child
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

sys_intgo
        ex de,hl
        ld hl,0
        add hl,sp
appaddr=$+1
        ld sp,app1 ;safestack_end
        push hl ;"sp"
        push de ;"hl"
        push iy
        exx
        push bc
        push de
        push hl
        push ix
        ex af,af' ;'
        push af

        ld bc,memport4000
        ld a,pgtrdosfs;pagexor-5
        out (c),a ;там INTSTACK
        ld sp,INTSTACK2
        call setgfxpal_focus
        call on_int ;тикает таймер
        call schedule ;out: iy=app
        ld a,pgkillable
        ld bc,memport4000
        ld (sys_curpg4000),a ;не надо? (если di)
        out (c),a

sys_int_popregs ;только для выхода из yield
;iy=app
        ld de,-(safestack_sz-2) ;2 на запарывание прерыванием
        add iy,de
        ld sp,iy ;di!!!

        pop af
        ex af,af' ;'
        pop ix
        pop hl
        pop de
        pop bc
        exx
        ld d,(iy+app.mainpg+safestack_sz-2) ;2 на запарывание прерыванием
        ld iy,(focusappaddr)
        ld a,(iy+app.screen)
        pop iy
        pop bc ;"hl"
        pop hl ;"sp"
        ld sp,hl
        ld h,b
        ld l,c
        ld bc,memport0000
        ;TODO освободить мьютекс, можно включить прерывания
        jp sys_intq ;out (0xfd),a ;дальше попадаем в init_resident

schedule
;find next app, set iy
;out: iy=app, ix=(focusappaddr)
        ld iy,(appaddr)
        ld bc,-app_last;app_afterlast
        ld de,app_last+app_sz;app_sz
         ld a,(sys_timer) ;ok
        ld l,MAXAPPS
findnextapp0
        add iy,bc
        jr nc,$+6
        ld iy,app1 -(app_last+app_sz)
        add iy,de
         cp (iy+app.lasttime)
         jr z,findnextappskip
         ;bit fyield,(iy)
         ;jr nz,findnextappq
        bit factive,(iy)
        jr nz,findnextappq
findnextappskip
        dec l
        jr nz,findnextapp0
;no active apps (или каждая в данном фрейме уже вызывалась)
        ld iy,app1 ;idle
findnextappq
;TODO при fwaitfocus пропускать app, если у него нет фокуса
;или пусть term (хозяин пайпа) получает factive только после появления чего-то в пайпе или при нажатии клавиши (когда он в фокусе)
        ld (appaddr),iy
         ld (iy+app.lasttime),a
          ;ld iy,(appaddr)
          ld a,(iy+app.mainpg)
          ld bc,memport4000
          ld (sys_curpg4000),a ;нужно (могут вызвать из yield - в любой момент)
          out (c),a
          ld ix,(focusappaddr)
          ld a,(ix+app.screen)
          or fd_system
          ;ld (user_fdvalue1+0x4000),a ;for QUIT, мешает делать многозадачность с 0xffff: jp nn
          ld (user_fdvalue2+0x4000),a
          ld (user_fdvalue3+0x4000),a
          ld (user_fdvalue4+0x4000),a
          ;ld (user_fdvalue5+0x4000),a ;not supported yet
          ld (user_fdvalue6+0x4000),a
          ld a,pgtrdosfs
          ;ld (sys_curpg4000),a ;нужно (могут вызвать из yield - в любой момент - но там не важно, там стек в нулях, а потом само ввключает pgkillable)
          out (c),a ;там INTSTACK
        ;ld iy,(appaddr)
        ret

setgfxpal_focus
;если в yield не поставить палитру второй задаче, то она никогда не поставится, если первая задача в цикле делает yield
;потому что все прерывания будут ставить первую задачу
;если же палитру ставить в самом yield, то могут быть проблемы с выставлением палитры, если yield вызывать в случайных местах или если все задачи неактивны
;поэтому обработчик прерываний должен выставлять палитру и видеорежим задачи, которая в фокусе, независимо от её активности
;менять палитру только после смены фокуса или записи палитры
		display "setgfxpal_focus ",setgfxpal_focus
palettechanged=$
        or a
        jp c,focusappborder
        ld a,55 ;"scf"
        ld (palettechanged),a
       ifndef NOPAL
        ld hl,(focusappaddr)
        ld bc,app.pal+31 ;-app.gfxmode
        add hl,bc
	if atm==1
		ld bc,0x07ff
		dup 8
		ld a,b
		out (0xf6),a
		outd
		dec hl
		edup
		ld b,0x07
		dup 7
		ld a,b
		out (0xfe),a
		outd
		dec hl
		edup
		ld a,b
		out (0xfe),a
		outd
	else

        ld c,0xff
        ld a,7
        dup 8
        OUT (0xF6),A
        ld d,(hl)
        dec hl
        ld b,(hl) ;DDp palette low bits
        OUT (c),d;(0xFF),A
        dec hl
        dec a
        edup
        ld a,7
        dup 7
        OUT (0xFE),A
        ld d,(hl)
        dec hl
        ld b,(hl) ;DDp palette low bits
        OUT (c),d;(0xFF),A
        dec hl
        dec a
        edup
        OUT (0xFE),A ;0
        ld d,(hl)
        dec hl
        ld b,(hl) ;DDp palette low bits
        OUT (c),d;(0xFF),A
	endif
       endif
focusappborder
         ld ix,(focusappaddr)
       ifndef NOPAL
         ld a,(ix+app.border)
         cp 8
         res 3,a ;tapeout sound
         out (0xfe),a
         ret c
         out (0xf6),a
       endif
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
        ex af,af' ;'
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
        ex af,af' ;'
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
;в 0x4000 сейчас pg5, там стек
focusappaddr=$+1
        ld hl,app1
        ld bc,app.gfxmode
        add hl,bc
        ld e,(hl)
;sys_curgfxmode=$+1
        ;ld e,%10101000 ;320x200 mode
		if atm==1
			ld bc,0xfadf ;buttons
			in a,(c)
			ld (sys_mousebuttons),a
			inc b ;ld bc,0xfbdf ;x
			in l,(c)
			ld b,0xff ;y
			in h,(c)
			 ld bc,0xff77	;shadow ports and palette off
			 out (c),e
                        in a,(0x1f)
                        ld (sys_kempstonbuttons),a
                         ld bc,0x01bf
			 out (c),b
			 ld bc,0xbd77	;shadow ports and palette remain on
			 out (c),e
			 xor a
			 out (0xbf),a
		else
                        push de ;e=gfxmode
                        ifdef NOMOUSE
                        ld hl,0
                        ld de,0x0f00
                        else
			call readmouse ;resident >=0x4000
                        endif
                        ld a,d
                        ld (sys_mousebuttons),a
                        ld a,e
                        ld (sys_kempstonbuttons),a
                        pop de ;e=gfxmode
		endif
        ld (sys_mousecoords),hl
		if atm != 1
			ld a,(sys_timer) ;ok
			and 7
			jr nz,on_int_noreadtime
                        ifdef NOCMOS
                        else
			call readtime ;in: e=gfxmode, out: hl=date, de=time
			ld (sys_time_date),de
			ld (sys_time_date+2),hl
                        endif
on_int_noreadtime
		endif
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
        
		if PS2KBD==0
			ld a,pgtrdosfs
			ld bc,memport4000
			out (c),a ;don't keep in sys_curpg4000!
			call KEYSCAN
		else
KEYSCAN
.rep_wait=$+1
			ld a,0
			dec a
			jp m,.end_keyscan
			ld (.rep_wait),a
.end_keyscan			
		endif
;TODO при наличии клавиши или события мышки поставить factive для задачи в фокусе
;пока что просто ставим factive для задачи в фокусе, если у неё есть fgfx (т.е. это не idle) - этого достаточно для ускорения игр
        ld iy,(focusappaddr)
        bit fgfx,(iy+app.flags)
        jr z,keyscan_nosetactive
        set factive,(iy+app.flags)
keyscan_nosetactive

        ;call PEEKKEY ;ld a,(curkey)
        ;cp ssEnter
        
        ld a,0x7f
        in a,(0xfe)
        rra
        ld c,a ;c0=ss
        ld a,0xbf
        in a,(0xfe)
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
         call KEY_PUTREDRAW

        if 1==1
        ld iy,(focusappaddr)
        call disablescrpgs_setc000
        ld bc,-app_last;app_afterlast
        ld de,app_last+app_sz;app_sz
        ld l,MAXAPPS
findnextgfxapp0
        add iy,bc
        jr nc,$+6
        ld iy,app1 -(app_last+app_sz)
        add iy,de
        ld a,(iy+app.flags)
        bit fgfx,a
        jr z,findnextgfxappskip
         bit fwaiting,a
         jr z,findnextgfxappq
findnextgfxappskip
        dec l
        jr nz,findnextgfxapp0
;no active apps (или каждая в данном фрейме уже вызывалась)
        ld iy,app1 ;idle
findnextgfxappq
        ld (focusappaddr),iy
        call setpalettechanged

        else
        
        ld hl,(focusappaddr)
        ;отключить страницы экрана этой задаче и выключить их в памяти задачи
        push hl
        pop iy
        call disablescrpgs_setc000
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
        jr z,findnextgfxappskip
         bit fwaiting,(hl)
         jr z,findnextgfxappq
findnextgfxappskip
        dec a
        jr nz,findnextgfxapp0
        ld hl,app1
findnextgfxappq
        ld (focusappaddr),hl
        call setpalettechanged
        ;включить страницы экрана этой задаче
        ;push iy
        push hl
        pop iy
        endif
        
        call enablescreeninapp_setc000
        
        ;pop iy
        
sys_int_noselectapp
muzpg=$+1
        ld a,pgkillable
        ld bc,memport4000
        out (c),a
muzpg8000=$+1
         ld a,pgkillable
         ld b,memport8000_hi
         out (c),a
muzpgc000=$+1
         ld a,pgkillable
         ld b,memportc000_hi
         out (c),a

        ;jr $
        ld sp,INTMUZSTACK

         ld e,pgsys
        ld ix,(focusappaddr)
        ld a,(ix+app.gfxmode)
muzcall=$+1
	call sys_reter;pt3player.PLAY ;TODO call drivers
        
        ld sp,INTSTACK2-2

        ld ix,(focusappaddr)
        ld a,(ix+app.gfxmode)
        ld bc,0xbd77
        out (c),a ;set gfx mode
        
        ld a,pgtrdosfs;pagexor-5
        ld bc,memport4000
        out (c),a ;там INTSTACK
sys_curpg8000=$+1
         ld a,pgkillable
         ld b,memport8000_hi
         out (c),a
sys_curpgc000=$+1
         ld a,pgkillable
         ld b,memportc000_hi
         out (c),a
        ret

copypage_a_to_e
        call sys_setpg8000
        ld a,e
        call sys_setpgc000
        ld hl,0x8000
        ld de,0xc000
        ld bc,0x4000
        ldir
        ret

disablescrpgs_setc000
        bit 7,(iy+app.gfxkeep)
        jr z,disablescrpgs_nokeep
        ld a,pgscr0_0
        ld e,(iy+app.scr0low)
        call copypage_a_to_e
        ld a,pgscr0_1
        ld e,(iy+app.scr0high)
        call copypage_a_to_e
        ld a,pgscr1_0
        ld e,(iy+app.scr1low)
        call copypage_a_to_e
        ld a,pgscr1_1
        ld e,(iy+app.scr1high)
        call copypage_a_to_e
        call setmainpg_c000
        if 1==0
        ds 6*4
        else
       display "===",$
        ld a,(iy+app.scr0low)
        ld (0xc000+user_scr0_low),a
        ld a,(iy+app.scr0high)
        ld (0xc000+user_scr0_high),a
        ld a,(iy+app.scr1low)
        ld (0xc000+user_scr1_low),a
        ld a,(iy+app.scr1high)
        ld (0xc000+user_scr1_high),a
        endif
        jr disablescrpgs_keepok
disablescrpgs_nokeep
        call setmainpg_c000
        call disablescreeninapp ;set user_scr0_low etc to pgkillable
disablescrpgs_keepok
        ld de,curpg16k+0xc000
        call disablescrpg
        ld  e,0xff&(curpg32klow+0xc000)
        call disablescrpg
        ld  e,0xff&(curpg32khigh+0xc000)
        ;call disablescrpg
disablescrpg
;de=page keeping addr
        ld a,(de)
        ;or 7&(pgscr0_0|pgscr0_1|pgscr1_0|pgscr1_1)
        ;cp pgscr0_0
        ;ret nz;jr z,disablescrpg_ok
;disablescrpg_ok
        ;ld a,pgkillable
        ld c,(iy+app.scr0low)
        cp pgscr0_0
        jr z,disablescrpg_ok
        ld c,(iy+app.scr0high)
        cp pgscr0_1
        jr z,disablescrpg_ok
        ld c,(iy+app.scr1low)
        cp pgscr1_0
        jr z,disablescrpg_ok
        ld c,(iy+app.scr1high)
        cp pgscr1_1
        ret nz;jr z,disablescrpg_ok
disablescrpg_ok
        ld a,c
        ld (de),a
        ret
enablescrpg
;de=page keeping addr
        ld a,(de)
        cp (iy+app.scr0low)
        ld c,pgscr0_0
        jr z,disablescrpg_ok
        cp (iy+app.scr0high)
        ld c,pgscr0_1
        jr z,disablescrpg_ok
        cp (iy+app.scr1low)
        ld c,pgscr1_0
        jr z,disablescrpg_ok
        cp (iy+app.scr1high)
        ld c,pgscr1_1
        ret nz;jr z,enablescrpg_ok
enablescrpg_ok
        ld a,c
        ld (de),a
        ret

sys_getchar
;out:
;de=mouse yx, l=buttons, A=key, H=high bits of key, bc=keynolang, lx=joystick 0bP2JFUDLR, nz=no focus (mouse position=0, ignore it!)
        ;call checkfocus_getkbdmouse
;checkfocus_getkbdmouse
;out: nz=fail
        ld de,(focusappaddr)
        ld hl,(appaddr)
        xor a
        sbc hl,de
        jr nz,sys_getchar_fail ;nz
;sys_oldmousecoords=$+1
;        ld de,0
;        ld (sys_oldmousecoords),hl
;        ld a,l
;        sub e ;a=dx
;        ld e,a ;e=dx
;        ld a,d
;        sub h ;a=dy
;        ld d,a ;d=dy
		if PS2KBD==1
			display "ps2_sp ",$
			ld (ps2_sp),sp
			ld sp,BDOSSTACK ;это может затереть стек возврата! поэтому возвращаемся через jp
			call BDOS_setpgtrdosfs
			call GETKEY ;A=key, H=high bits of key, BC=keynolang
			ld e,a
			push bc ;ld (ps2_bc),bc
			ld a,pgkillable
			ld bc,memport4000
			ld (sys_curpg4000),a
			out (c),a
			pop bc
ps2_sp=$+1
			ld sp,0
;ps2_bc=$+1
;			ld bc,0
			ld a,e
		else
			call GETKEY ;A=key, H=high bits of key, BC=keynolang
		endif
        cp a ;z
sys_mousecoords=$+1
        ld de,0;hl,0
sys_mousebuttons=$+1
        ld l,0xff
sys_kempstonbuttons=$+2
        ld lx,0
        ;ret ;z
        ;jp endsys_result_a
endsys_result_a
         ld iy,(focusappaddr)
        ex af,af' ;'
        ld a,(iy+app.screen)
        ;ld iy,(appaddr)
        jp endsys_result_aq

;TODO брать номер экрана у задачи с фокусом и при шедулинге ставить этот номер в userkernel новой задачи
        
sys_getchar_fail
;a=0, nz
        ;ld a,NOKEY ;no key
         ;ld h,a
         ;ld b,a
         ld c,a ;no keynolang
        ld d,a;0
        ld e,a;0 ;no mouse movement
         ld lx,a ;no joystick buttons
        ld l,0xff ;no buttons
        jr endsys_result_a ;ret ;nz ;jp endsys_result_a

callbdos
;при вызове bdos надо включить:
;0x0000 - syscode (уже включено)
;[0x4000 - pgfatfs или bdospg2]
;защита от одновременного доступа двум задачам
;занято a,bc,de,hl
;свободно iy
        if bdosstack_sz==0

        ld (callbdos_sp),sp
        ld sp,BDOSSTACK ;до этого момента прерывание может запороть любое место памяти (user sp >=0x3b00) ;это может затереть стек возврата! поэтому возвращаемся через jp

        else
        
        exx
callbdos_lock        
        ld hl,callbdos_mutex ;изначально 0xc0
        sla (hl)
        jr z,callbdos_lock ;был занят
        
        ld hl,0
        add hl,sp
        ld iy,(appaddr)
        ;ld (iy+app.callbdos_sp),l
        ;ld (iy+app.callbdos_sp+1),h
        ld bc,app.bdosstack+bdosstack_sz
        add iy,bc
        ld sp,iy ;до этого момента прерывание может запороть любое место памяти (user sp >=0x3b00)
        push hl
        exx
        
        endif
        
            ;ld iy,(focusappaddr)
            ;ld a,(iy+app.screen)
            ;xor 0x10 ;fd_user^fd_system
            ;out (0xfd),a
        ld iy,(appaddr)
       if 1
        ;push hl
        ;ld l,c
        ;ld h,tbdoscmds/256
        ;ld a,(hl)
        ;inc h
        ;ld h,(hl)
        ;ld l,a
        ;ex (sp),hl
        ;ret ;73t+call ;TODO jp (hl)..pop hl..jp NN ;58t, no call
        push hl
        ld l,c
        ld h,tbdoscmds/256
        ld a,(hl)
        inc h
        ld h,(hl)
        ld l,a
        ld ($+3+1+1),hl
        pop hl ;70t+call
        call 0
       else
        call BDOShandler
       endif
         push af
         push bc
         call setpgs_killable
        if bdosstack_sz !=0
        ld a,0xc0
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

       if 0
BDOShandler
        push hl
        ld a,c
        ld hl,tbdoscmds
        push bc
        ld bc,nbdoscmds
        cpir
        jp nz,BDOS_pop2fail
;bc=nbdoscmds-(cmdnumber+1) = 0..(nbdoscmds-1)
        add hl,bc
;hl=tbdoscmds+nbdoscmds
        add hl,bc
        add hl,bc
;hl=tbdoscmds+nbdoscmds+ 2*(nbdoscmds-(cmdnumber+1))
        pop bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ;hl=jump addr
        ex (sp),hl
        ret
       endif

sys_quit
;снять текущую задачу
;hl=result
        ld sp,QUITSTACK ;если не сделать, то всё ещё стек задачи, и мы не вернёмся из schedule
        ld iy,(appaddr)
        ld e,(iy+app.id)
       if 1==0
        push de
        push iy
        call BDOS_freezeapp
        pop iy
;если установлен muzcall в пространстве задачи, снимаем его
        ld a,(muzpg)
        call addrpage
        pop de
        ld a,(hl)
        cp e
        jr nz,sys_quit_nomuzcall
       ld hl,sys_reter
       ld (muzcall),hl ;есть в delapppages тоже!!! TODO выбросить?
sys_quit_nomuzcall
        call BDOS_delapppages ;глушит сокеты и музыку, удаляет страницы
       endif
;hl=result
       call BDOS_dropapp ;будит родителя, глушит сокеты и музыку, удаляет страницы
        jp BDOS_yield_q ;переходим на какую-нибудь задачу (там же ставим pgkillable в 4000,8000,c000)
        
setkernelpages_go
;di!!!
;sp=0x3ffx
;сейчас включена 5-я страница
        BDOSSETPGTRDOSFS
        call makeidle
;setkernelpages_go_iy
        ;ld sp,BDOSSTACK
        call setpgs_killable
        ld sp,-8

        ;ld iy,(appaddr)
        ld d,(iy+app.mainpg)
;d=pgmain
;[e=значение для аккумулятора]
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
        inc a ;a!=0 (0 и 0xff нельзя - см. BDOS_newpage)
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
		
		if atm==1
NVRAM_REG=0xde
NVRAM_VAL=0xbe
readtime
;sp=0x7fxx
;e=gfxmode
;out: hl=date, de=time
;TODO атомарно
		ld bc,0xf7 + (NVRAM_REG<<8)
		ld a,0x0b
		out (c),a
		ld b,NVRAM_VAL
		in a,(c)
		or 0x04
		out (c),a
		xor a		;sec
		call bcd2bin
		srl a
		ld l,a
		
		ld a,2		;min
		call bcd2bin
		call minmes
		add a,l
		ld (sys_time_date),a	;ld e,a
		ld l,h
		
		ld a,4		;h
		call bcd2bin
		add a,a
		add a,a
		add a,a
		add a,l
		ld (sys_time_date+1),a	;ld d,a
		
		ld a,7		;day
		call bcd2bin
		ld l,a
		
		ld a,8		;mes
		call bcd2bin
		call minmes
		add a,l
		ld (sys_time_date+2),a	;ld l,a
		
		ld a,9		;god
		call bcd2bin
		add a,20
		add a,a
		add a,h
		ld (sys_time_date+3),a	;ld h,a
		ret
minmes
		ld h,a
		xor a
		srl h
		rra
		srl h
		rra
		srl h
		rra
		ret

bcd2bin
		ld b,NVRAM_REG
		out (c),a
		ld b,NVRAM_VAL
		in a,(c)
		ret
    
		endif


		if PS2KBD==1
KEY_PUTREDRAW
		ld bc,0xdef7
		out (c),c
		ld b,0xbe
        ld a,2
        out (c),a
		in a,(c)
		jr z,.buf_empty
		inc a
		jr nz,KEY_PUTREDRAW
		ld b,0xde		;переполнено
		ld a,0x0c		;сбросить буфер
		out (c),a
		ld b,0xbe
		ld a,1
		out (c),a
.buf_empty		
		xor a
		ld (KEYSCAN.rep_wait),a
		ld b,a
		ld c,a
		ld (.rep_key),bc
		ld bc,key_redraw
		ld (.redrawkey),bc
		ret
.rep_key
		defw 0x0000
.redrawkey
		defw 0x0000
		else
			include "syskey1.asm"
		endif
                
        ds 50  
INTSTACK1;!=0x3f00 ;kernelspace (для входа в обработчик без порчи стека) (не пересекается с возможным стеком задачи!!!)

        include "fatfsdrv.asm"
        include "sysbdos.asm" ;в конце есть align 256
syskrnl_end=$
        ent
