	device pentagon1024 ;don't trust this line, it's for ATM2 :)

        include "../_sdk/syssets.asm"
        ;include "../_sdk/atm.asm"

        if atm==3
;схема Nemo:
hddstat=#F0
hddcmd=#F0
hddhead=#D0
hddcylhi=#B0
hddcyllo=#90
hddsec=#70
hddcount=#50
hdderr=#30
hdddatlo=#10
hdddathi=#11
hddupr=#C8
hdduprON=0

memport0000=#37f7
memport4000=#77f7
memport8000=#b7f7
memportc000=#f7f7
memportrom0000=#3ff7
memportrom4000=#7ff7
memportrom8000=#bff7
memportromc000=#fff7

pagexor=#ff
        else
;схема ATM:
hddstat=#FEEF
hddcmd=#FEEF
hddhead=#FECF
hddcylhi=#FEAF
hddcyllo=#FE8F
hddsec=#FE6F
hddcount=#FE4F
hdderr=#FE2F
hdddatlo=#FE0F
hdddathi=#FF0F
hddupr=#FEBE ;при установленном b7 FFBA
hdduprON=#FFBA
hddupr1=#F7
hddupr0=#77

memport0000=#3ff7
memport4000=#7ff7
memport8000=#bff7
memportc000=#fff7
memportrom0000=#3ff7
memportrom4000=#7ff7
memportrom8000=#bff7
memportromc000=#fff7
           
pagexor=#7f
        endif
memport8000_hi=memport8000/256
memportc000_hi=memportc000/256
        
SYSMINSTACK=#3b00        

resident=#6000;#6000+8000 (где не затрут при очистке экрана) ;pgtrdosfs
trdos_catbuf=#6100;#3200 ;,#900 ;pgtrdosfs (#4000)
INTSTACK1=#3f00 ;kernelspace (для входа в обработчик без порчи стека)
INTSTACK2=#5f00;#6000 ;pgkillable и pgtrdosfs (рабочий стек обработчика прерываний) (>=#4000, иначе нельзя выключить теневые порты)
TRDOSSTACK=#5f00-96;#6000-96 ;чтобы не пересекалось с INTSTACK (в промежутке между преключениями страниц может произойти системное прерывание), но и на экран не попало
BDOSSTACK=#4000 ;kernelspace
STACK=#4000 ;userspace
;при вызове BDOS стек некоторое время такой же, как в юзерспейсе
;поэтому на входе в BDOS надо иметь в #4000...#ffff страницы, которые не жалко
;предполагается, что юзер не имеет стек ниже #3b00, иначе он затрёт систему

        include "../_sdk/sys_h.asm"

pgsys=pagexor-10
pgfatfs=pagexor-9
pgtrdosfs=pagexor-8
pgkillable=pagexor-4 ;в 128K памяти, т.к. можно портить

pgfirstfree=pagexor-11

pgscr0_0=pagexor-1
pgscr0_1=pagexor-5
pgscr1_0=pagexor-3
pgscr1_1=pagexor-7

COMPILEPG_INIT=0
COMPILEPG_SYS0=10
COMPILEPG_SYS1=11

fd_system=%01010111 ;%0x01sx1x ;для неисправленного АТМ2 надо A9=1, а номер страницы в #7ffd не будет влиять, если адресация по memportc000
fd_system_getchar=%01010110 ;%0x01sx1x ;для неисправленного АТМ2 надо A9=1, а номер страницы в #7ffd не будет влиять, если адресация по memportc000
fd_user=%01000111 ;%0x00sx1x ;для неисправленного АТМ2 надо A9=1, а номер страницы в #7ffd не будет влиять, если адресация по memportc000

        SLOT 1
        page COMPILEPG_INIT
	org #6000
begin
        xor a
        out (#fe),a

        ld hl,#c9f1 ;pop af:ret
        ld (#5cc2),hl
        
        ld bc,#fbdf ;x
        in l,(c)
        ld b,#ff
        in h,(c)
        ld (init_oldmousecoords),hl

;;;;;;;;;;;;;;;;;;; set gfx mode ;;;;;;;;;;;;;;;;;
        halt
        LD A,%10101000 ;320x200 mode
        ;LD A,%10101010 ;640x200 mode
        ;LD A,%10101110 ;textmode
        CALL INIT_OUTSHADON
        
        call INIT_blackpal

        di

        if atm==3
         ld a,#7f-5
         ld bc,memportrom4000
         out (c),a ;отключаем 7ffd
         ld a,#7f-2
         ld bc,memportrom8000
         out (c),a ;отключаем 7ffd
         ;ld a,#7f-2
         ld bc,memportromc000
         out (c),a ;отключаем 7ffd
        endif

        call findpgdos
        ld (sys_pgdos),a ;до установки резидента

        ld a,pgsys
        call INIT_setpg_c000
        ld hl,#8000
        ld de,#c000
        ld bc,#4000
        ldir
        
        ld a,pgtrdosfs
        call INIT_setpg_c000
        ld hl,wastrdosfs
        ld de,#c000+idle;COMMANDLINE;PROGSTART ;idle code
        ld bc,trdosfs_sz
        ldir
        ld hl,#5c00
        ld de,#c000+#1c00
        ld bc,#0400;#5d3b-#5c00
        ldir
        ld hl,wasresident
        ld de,resident+#c000-#4000
        ld bc,resident_sz
        ldir

        ;ld a,pgidle
        ;call INIT_setpg_c000
        ;ld hl,wasidle
        ;ld de,#0100+#c000
        ;ld bc,idle_sz
        ;ldir
        
        ld a,pgsys
        call INIT_setpg_8000
        ld a,pgfatfs
        call INIT_setpg_c000
        
;перебрасываем 16K упакованный блок в #c000
        ld hl,wassys+#3fff
        ld de,#ffff
        ld bc,#4000
        lddr
;распаковываем в #6400
        ld hl,#c000;wassys
        ld de,#6400;#8000
        call DEC40 ;распаковываем в #8000 (там уже включены системные странички)
;перебрасываем 32K из #6400 в #8000
        ld hl,#6400+#7fff
        ld de,#8000+#7fff
        ld bc,#8000
        lddr

fatfspatchaddr=#c000
        
        ld hl,devices_init
        ld (0xc000+0),hl
        ld hl,devices_read
        ld (0xc000+2),hl
        ld hl,devices_write
        ld (0xc000+4),hl
        ld hl,disk_status
        ld (0xc000+6),hl
        ld hl,get_fattime
        ld (0xc000+8),hl

;инициализация менеджера памяти и вход в юзерспейс:
;HALT (чтобы прерывание не произошло когда не надо)
;[назначаем страницы системспейса (одна из них должна быть такая же, как в юзерспейсе) - уже есть общая страница 5]
;в юзерспейсе назначаем нижнюю страницу с керналем (вместо ПЗУ)
        ld a,fd_user
        out (#fd),a
        if atm==3
         ld a,#7f
         ld bc,memportrom0000
         out (c),a ;отключаем ПЗУ
         ld a,#7f-5
         ld bc,memportrom4000
         out (c),a ;отключаем 7ffd
         ld a,#7f-2
         ld bc,memportrom8000
         out (c),a ;отключаем 7ffd
         ;ld a,#7f-2
         ld bc,memportromc000
         out (c),a ;отключаем 7ffd
        endif
        ld a,pgtrdosfs ;idle
        ld bc,memport0000
        out (c),a
        
        ;ld hl,wasuserkernel+#8000
        ;ld de,0
        ;ld bc,userkernel_sz
        ;ldir
        
        ld a,fd_system
        out (#fd),a
        if atm==3
         ld a,#7f
         ld bc,memportrom0000
         out (c),a ;отключаем ПЗУ
         ;4000,8000,c000 уже отключили 7ffd выше
        endif
        ld a,pgsys
        ld bc,memport0000
        out (c),a
;в системспейсе:
;включить fatfs
;поставить резидент в 7fxx
;переходим в sys_intq, а оттуда в init_resident


        ld sp,BDOSSTACK
        ;ei
        ;halt ;чтобы прерывание не произошло когда не надо
        ;di

init_oldmousecoords=$+1
        ld hl,0
        ld (sys_oldmousecoords),hl
        jp setkernelpages_go

        
INIT_OUTSHADON
        ;LD BC,#FF77 ;shadow ports remain off
        LD BC,#BD77 ;shadow ports and palette remain on
        LD IX,10835
        PUSH IX
        JP #3D2F

INIT_setpg_low
        LD BC,memportrom0000 ;page for #0000..#3fff
        OUT (C),A
        ret

INIT_setpg_8000
        LD BC,memport8000 ;page for #8000..#bfff
        OUT (C),A
        ret

INIT_setpg_c000
        LD BC,memportc000 ;page for #c000..#ffff
        OUT (C),A
        ret

findpgdos
;если не найти страницу текущего доса, то на старых версиях ПЗУ ZX Evo не будет работать (в странице #83 почему-то не дос по умолчанию)
        call crcdos
        ld (doscrchi),de
        ld (doscrclo),bc
        ld lx,#83
findpgdos0
        ld a,lx
        call INIT_setpg_low
        call crcdos
doscrchi=$+1
        ld hl,0
        or a
        sbc hl,de
        jr nz,doscrcbad
doscrclo=$+1
        ld hl,0
        or a
        sbc hl,bc
        jr nz,doscrcbad
        ld a,lx
        ret
doscrcbad
        ld a,lx
        add a,4
        ld lx,a
        cp #c0
        jr c,findpgdos0
        ld a,#83 ;not found
        ret
crcdos
        ld hl,#0000
        ld bc,0
        ld de,0
crcdos0
        ld a,d
        add a,a
        rl c
        rl b
        rl e
        rl d
        xor b
        ld b,a
        ld a,(hl)
        xor c
        ld c,a
        inc hl
        bit 6,h
        jr z,crcdos0
        ret

INIT_blackpal
        LD HL,blackpalend
        ;halt ;halt есть выше - убрано, чтобы не светилось ничего
        LD DE,#a80f ;#ab=6912 ;palette on, EGA, turbo
        LD BC,#BD77
        OUT (C),D
INIT_setpal0 LD A,E
	and 7
        BIT 3,E
        OUT (#FE),A
        JR Z,$+4
        OUT (#F6),A
        LD A,(HL)
        DEC HL
        ld b,(hl) ;DDp palette low bits
        dec hl
        ld c,#ff
        OUT (c),a;(#FF),A
        DEC E
        JP P,INIT_setpal0
        ret

        ds 32,#f3
blackpalend=$-1

        include "megaLZunpack.asm" ;DEC40

wasresident
        ;disp resident
readmouse=$-wasresident+resident
;sp=#7fxx
;e=gfxmode
;out: hl=mousecoords, d=mousebuttons
        call sys_SHADOFF
        ld bc,#fadf ;buttons
        in d,(c)
        inc b ;ld bc,#fbdf ;x
        in l,(c)
        ld b,#ff ;y
        in h,(c)
shadon_pgsys=$-wasresident+resident
        LD A,e;%10101000 ;320x200 mode
shadon_pgsys_a=$-wasresident+resident
        CALL sys_SHADON
        ld a,#7f-(pagexor-pgsys)
sys_setpg_low=$-wasresident+resident
	ld bc,memportrom0000
        jr sys_outca_jr
sys_SHADOFF=$-wasresident+resident
sys_pgdos=$+1 ;для патча
	ld a,#83 ;48 basic switchable to DOS
	call sys_setpg_low
        LD A,e;%10101000 ;320x200 mode
	ld bc,#ff77 ;shadow ports off, palette off
sys_outca_jr
        out (c),a
	ret
sys_SHADON=$-wasresident+resident
        LD bc,10835
        PUSH bc
        LD BC,#BD77 ;shadow ports and palette remain on
        JP #3D2F

dos3d13_resident=$-wasresident+resident
;сейчас включена pg5
;iy=23610
        ld (dos_sp),sp
        ld sp,TRDOSSTACK ;надо стек в #4000+ (не пересекающийся с INTSTACK, т.к. сейчас может произойти системное прерывание), по умолчанию стек был в #3fxx
        ;call swap_sysvars
        call sys_SHADOFF ;включили ПЗУ
         push de ;e=gfxmode
        exx
	call 0x3d13
         pop de ;e=gfxmode
        call shadon_pgsys ;выключили ПЗУ
        ;call swap_sysvars
dos_sp=$+1-wasresident+resident
        ld sp,0
        ret

minmes=$-wasresident+resident
    ld h,a
    xor a
    srl h
    rra
    srl h
    rra
    srl h
    rra
    ret

bcd2bin=$-wasresident+resident
    ld b,0xdf
    out (c),a
    ld b,0xbf
    in a,(c)
    ret
    
readtime=$-wasresident+resident
;sp=#7fxx
;e=gfxmode
;out: hl=date, de=time
;TODO атомарно
        call sys_SHADOFF
        LD A,e;%10101000 ;320x200 mode
        push af
      ld bc,0xeff7
      ld a,0x80
      out (c),a
    ld a,0x0b
    ld bc,0xdff7
    out (c),a
    ld b,0xbf
    in a,(c)
    or 0x04
    out (c),a
    xor a		;sec
    call bcd2bin
    srl a
    ld e,a
    
    ld a,2		;min
    call bcd2bin
    call minmes
    add a,e
    ld e,a
    ld d,h
    
    ld a,4		;h
    call bcd2bin
    add a,a
    add a,a
    add a,a
    add a,d
    ld d,a
    
    ld a,7		;day
    call bcd2bin
    ld l,a
    
    ld a,8		;mes
    call bcd2bin
    call minmes
    add a,l
    ld l,a
    
    ld a,9		;god
    call bcd2bin
    add a,20
    add a,a
    add a,h
    ld h,a
      ld bc,0xeff7
      xor a
      out (c),a

        pop af
        jp shadon_pgsys_a

        ;ent
resident_sz=$-wasresident
        display "residentend=",resident+resident_sz,"<=#8000"

wastrdosfs
        disp COMMANDLINE;PROGSTART
idle
        db "idle",0
        ds PROGSTART-$
        include "idle.asm"
idle_sz=$-idle
        ent
        disp #4000+idle+idle_sz
        include "trdosfs.asm"
        include "sysiofast.asm"
        include "bdospg2.asm"
        ent
trdosfs_sz=$-wastrdosfs
        display "trdosfs_sz=",/h,trdosfs_sz,"<=#1c00"
        
end
wassys

        SLOT 0
        page COMPILEPG_SYS0
        SLOT 1
        page COMPILEPG_SYS1
        org #0000
sysbegin
        include "syskernel.asm"
wasuserkernel
        disp #0000
        include "userkernel.asm"
        ent
userkernel_sz=$-wasuserkernel
	;display "wasuserkernel=",/d,wasuserkernel
	;display "wasuserkernel_end=",/d,$
	;display "userkernel_sz=",/d,userkernel_sz
        ds #4000-$
        incbin "..\fatfs4os\fatfs.raw"
sysend

	;display "begin=",/d,begin
	;display "end=",/d,end
	
	;display "sysbegin=",/d,sysbegin
	;display "sysend=",/d,sysend
	
        SLOT 1
        page COMPILEPG_INIT
	savebin "initcode.c",begin,end-begin
	
        SLOT 0
        page COMPILEPG_SYS0
        SLOT 1
        page COMPILEPG_SYS1
	savebin "syscode.c",sysbegin,sysend-sysbegin
	
	LABELSLIST "..\us\user.l"
