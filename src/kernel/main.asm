        DEVICE ZXSPECTRUM128
        ;device pentagon1024

        include "../_sdk/syssets.asm"
       ifdef USETOPDOWNMEM
TOPDOWNMEM=1 
       else
TOPDOWNMEM=0;1
       endif

EFF7VALUE=0x10 ;noturbo

		if atm != 2
memport0000=0x37f7
memport4000=0x77f7
memport8000=0xb7f7
memportc000=0xf7f7
memportrom0000=0x3ff7
memportrom4000=0x7ff7
memportrom8000=0xbff7
memportromc000=0xfff7
pagexor=0xff
        else
memport0000=0x3ff7
memport4000=0x7ff7
memport8000=0xbff7
memportc000=0xfff7
memportrom0000=0x3ff7
memportrom4000=0x7ff7
memportrom8000=0xbff7
memportromc000=0xfff7
pagexor=0x7f
        endif
        
        if NEMOIDE==1
;схема Nemo:
hddstat=0xF0
hddcmd=0xF0
hddhead=0xD0
hddcylhi=0xB0
hddcyllo=0x90
hddsec=0x70
hddcount=0x50
hdderr=0x30
hdddatlo=0x10
hdddathi=0x11
hddupr=0xC8
hdduprON=0
        else
;схема ATM:
hddstat=0xFEEF
hddcmd=0xFEEF
hddhead=0xFECF
hddcylhi=0xFEAF
hddcyllo=0xFE8F
hddsec=0xFE6F
hddcount=0xFE4F
hdderr=0xFE2F
hdddatlo=0xFE0F
hdddathi=0xFF0F
hddupr=0xFEBE ;при установленном b7 FFBA
hdduprON=0xFFBA
hddupr1=0xF7
hddupr0=0x77
        endif
memport8000_hi=memport8000/256
memportc000_hi=memportc000/256

SYSMINSTACK=0x3b00

resident=0x6000;0x6000+8000 (где не затрут при очистке экрана) ;pgtrdosfs
trdos_catbuf=0x6300;0x3200 ;,0x900 ;pgtrdosfs (0x4000)
trdos_sectorbuf=0x6c00
trdos_fcbbuf=0x6d00 ;size=0x200*trdos_MAXFILES
trdos_MAXFILES=8
INTMUZSTACK=0x3e00 ;kernelspace
;INTSTACK1=0x3f00 ;kernelspace (для входа в обработчик без порчи стека) (не пересекается с возможным стеком задачи!!!)
INTSTACK2=0x5f00;0x6000 ;pgkillable и pgtrdosfs (рабочий стек обработчика прерываний) (>=0x4000, иначе нельзя выключить теневые порты)
TRDOSSTACK=0x5f00-96;0x6000-96 ;чтобы не пересекалось с INTSTACK (в промежутке между преключениями страниц может произойти системное прерывание), но и на экран не попало
BDOSSTACK=0x4000 ;kernelspace
STACK=0x4000 ;userspace
;при вызове BDOS стек некоторое время такой же, как в юзерспейсе
;поэтому на входе в BDOS надо иметь в 0x4000...0xffff страницы, которые не жалко
;предполагается, что юзер не имеет стек ниже 0x3b00, иначе он затрёт систему

        include "../_sdk/sys_h.asm"

        if TOPDOWNMEM
pgtrdosfs=pagexor-(sys_npages-1)
pgfatfs=pagexor-(sys_npages-2)
pgsys=pagexor-(sys_npages-3)
pgfatfs2=pagexor-(sys_npages-4) ;structs
        else
pgtrdosfs=pagexor-8
pgfatfs=pagexor-9
pgsys=pagexor-10
pgfatfs2=pagexor-11 ;structs
        endif

pgkillable=pagexor-4 ;в 128K памяти, т.к. можно портить
;pgfirstfree=pagexor-11

pgscr0_0=pagexor-1
pgscr0_1=pagexor-5
pgscr1_0=pagexor-3
pgscr1_1=pagexor-7

fd_system=0x57;%01010111 ;%0x01sx1x ;для неисправленного АТМ2 надо A9=1, а номер страницы в 0x7ffd не будет влиять, если адресация по memportc000
fd_system_getchar=0x56;%01010110 ;%0x01sx1x ;для неисправленного АТМ2 надо A9=1, а номер страницы в 0x7ffd не будет влиять, если адресация по memportc000
fd_user=0x47;%01000111 ;%0x00sx1x ;для неисправленного АТМ2 надо A9=1, а номер страницы в 0x7ffd не будет влиять, если адресация по memportc000

;условные страницы для sjasm
COMPILEPG_INIT=0
COMPILEPG_SYS0=4
COMPILEPG_SYS1=6

        SLOT 1
        page COMPILEPG_INIT
	org 0x6000
begin
        di
        xor a
        out (0xfe),a
        ifdef KOE
            display "KOE!!!"
            ld a,0+EFF7VALUE ;turbo ;0x10 ;noturbo
            ld bc,0xeff7
            out (c),a ;for KOE
            ld a,0x10
            ld bc,0x7ffd
            out (c),a
        endif
	if atm==2
            ld hl,basvar.tape
            ld de,0x5c00
            ld bc,basvar.endtape - basvar.tape
            ldir
            ld sp,0x5800
            ld a,(0x3CBC)
            cp 0x83
            call z,0x3C9E
            ;call 0x3d21
        endif
        if atm==3
	 ld a,32 ;xor a ;D5=444 palette
	 out (0xbf),a
        endif
        LD (IY+1),0xCC

        if 1==0
            LD A,(23833)
            ADD A,'A'
            LD (src),A
            LD (dst),A
            XOR A
            LD (23658),A ;0x5c6a
            ;LD L,A,H,L
            ;LD (23802),HL 
        endif
        XOR A
        ld (0x5d10),a 
        
        call reset_ay
        
        ;ld hl,0xc9f1 ;pop af:ret
        ;ld (0x5cc2),hl
        
        ;ld bc,0xfbdf ;x
        ;in l,(c)
        ;ld b,0xff
        ;in h,(c)
        ;ld (init_oldmousecoords),hl

;;;;;;;;;;;;;;;;;;; set gfx mode ;;;;;;;;;;;;;;;;;
		ei
        halt
        ;LD A,0xaa;%10101010 ;640x200 mode
        ;LD A,0xae;%10101110 ;textmode
		if atm==1
init_rst_buf=0x4000
            ;проверим версию ers
            ld d,0x00
			rst 0x08
			defb 0x4d,0x00
            ld hl,-0x5812    ;ERS_MIN_VERSION 0.58.12
            add hl,de
            ld a,0xff
            jr nc,.err_version
			;выясним откуда запустились
			ld hl,init_rst_buf
			rst 0x08
			defb 0x50,0x03
			rst 0x08	; в D вернется текущий драйв
			defb 0x50,0x02
			ld a,d
			add a,a
			add a,a
			add a,a
			ld hl,init_rst_buf
			ld b,0
			ld c,a
			add hl,bc
			ld de,init_rst_buf+512
			ld bc,8
			ldir
			ld a,(init_rst_buf+512)
			rst 0x08
			defb 0x50,0x05
			ld a,(init_rst_buf+512)
			and 1 ;m/s
			ld hl,init_rst_buf
			ld bc,0x0000
			ld d,b
			ld e,c
			ld a,2
			ex af,af' ;'
			ld a,1
			rst 0x08
			defb 0x50,0x04,0x02
			ld a,(init_rst_buf+512)
			ld d,12
			cp 0x0f
			jr z,.l3
			ld d,3
			cp 4
			jr z,.init_sysdev_part
			ld d,7
			cp 5
			jp nz,init_sysdev_end
.init_sysdev_part
			ld hl,init_rst_buf+0x01BE+0x0008-12
.l2
			inc d
			push de
			ld bc,12
			add hl,bc
			ld bc,0x0400
			ld de,init_rst_buf+512+3
.l1			ld a,(de)
			xor (hl)
			or c
			ld c,a
			inc de
			inc hl
			djnz .l1
			pop de
			or a
			jr nz,.l2
.l3
			ld a,d
.err_version
			ld (init_sysdrv_val),a
init_sysdev_end
			halt
			ld bc,0xeff7
			ld a,0x80+EFF7VALUE
			out (c),a
			ld a,0x10
			ld bc,0x7ffd
			out (c),a
			ld bc,0x01bf
			out (c),b
			LD A,0xa8;%10101000 ;320x200 mode
			ld bc,0xbd77	;shadow ports and palette remain on
			out (c),a
			 ld a,32 ;xor a ;D5=444 palette
			out (0xbf),a
		else
			LD A,0xa8;%10101000 ;320x200 mode
			CALL INIT_OUTSHADON
        endif
        call INIT_blackpal

        di
		if atm==1 and PS2KBD
			ld bc,0xdef7	
			out (c),c		
			ld b,0xbe		
			ld a,2			
			out (c),a
		endif
		
		if atm==3 or atm==1
			ld a,0x7f-5
			ld bc,memportrom4000
			out (c),a ;отключаем 7ffd
			ld a,0x7f-2
			ld bc,memportrom8000
			out (c),a ;отключаем 7ffd
			;ld a,0x7f-2
			ld bc,memportromc000
			out (c),a ;отключаем 7ffd
		endif
        
		if atm != 1
			call findpgdos
		else
			ld a,0x04
			in a,(0xbd)
			and 0xbf;%10111111
			;ld a,0x8b
		endif
        ld lx,a
        ld (sys_pgdos),a ;до установки резидента

        ld a,pgsys
        call INIT_setpg_c000
        ld hl,0x8000
        ld de,0xc000
        ld bc,0x4000
        ldir
        
        ld a,pgtrdosfs
        call INIT_setpg_c000
        ld hl,wastrdosfs
        ld de,0xc000+idle;COMMANDLINE;PROGSTART ;idle code
        ld bc,trdosfs_sz
        ldir
        ld a,(init_sysdrv_val)  ;нужно для проверки версии ERS
        ld (0xc000+idle+6),a    ;при неправильном ERS сисдир==0xff
			ld a,0xc3
			ld (0x5cc2),a
			ld hl,ONERR;ddrv
			ld (0x5cc3),hl
			ld hl,0x5c00
			ld de,0xc000+0x1c00
			ld bc,0x0400;for run hobeta;0x0200;0x5d3b-0x5c00
			ldir
        ld hl,wasresident
        ld de,resident+0xc000-0x4000
        ld bc,resident_sz
        ldir
			ld hl,0x5c4b
			ld de,varbas_stor+0x8000
			ld bc,32
			ldir
        
        ld hl,0xc000+trdos_fcbbuf-0x4000
        ld d,h
        ld e,l
        inc de
        ld bc,0x200*trdos_MAXFILES-1
        ld (hl),l;0
        ldir

        ;ld a,pgidle
        ;call INIT_setpg_c000
        ;ld hl,wasidle
        ;ld de,0x0100+0xc000
        ;ld bc,idle_sz
        ;ldir
        
        ld a,pgsys
        call INIT_setpg_8000
        ld a,pgfatfs
        call INIT_setpg_c000
        
        ;jr $
;перебрасываем 16K упакованный блок в 0xb000
        ld hl,wassys+0x4fff
        ld de,0xffff
        ld bc,0x5000
        lddr
;распаковываем в 0x6400
        ld hl,0xb000;wassys
        ld de,0x6400;0x8000
        call DEC40 ;распаковываем в de (там уже включены системные странички)
;перебрасываем 32K из 0x6400 в 0x8000
        ld hl,0x6400+0x7fff
        ld de,0x8000+0x7fff
        ld bc,0x8000
        lddr

fatfspatchaddr=0xc000
        
        ld hl,devices_init
        ld (0xc000+FFS_DRV.init),hl
        ld hl,disk_status
        ld (0xc000+FFS_DRV.status),hl
        ld hl,devices_read	;read to userspace
        ld (0xc000+FFS_DRV.rd_to_usp),hl
        ld hl,devices_readnopg	;read to buffer
        ld (0xc000+FFS_DRV.rd_to_buf),hl
        ld hl,devices_write	;write from userspace
        ld (0xc000+FFS_DRV.wr_fr_usp),hl
        ld hl,devices_writenopg	;write from buffer
        ld (0xc000+FFS_DRV.wr_fr_buf),hl
        ld hl,get_fattime
        ld (0xc000+FFS_DRV.RTC),hl
        ld hl,strcpy_lib2usp	
        ld (0xc000+FFS_DRV.strcpy_lib2usp),hl
        ld hl,strcpy_usp2lib
        ld (0xc000+FFS_DRV.strcpy_usp2lib),hl
        ld hl,memcpy_lib2usp
        ld (0xc000+FFS_DRV.memcpy_lib2usp),hl
        ld hl,memcpy_usp2lib
        ld (0xc000+FFS_DRV.memcpy_usp2lib),hl
        ld hl,memcpy_buf2usp
        ld (0xc000+FFS_DRV.memcpy_buf2usp),hl
        ld hl,memcpy_usp2buf
        ld (0xc000+FFS_DRV.memcpy_usp2buf),hl

;инициализация менеджера памяти и вход в юзерспейс:
;HALT (чтобы прерывание не произошло когда не надо)
;[назначаем страницы системспейса (одна из них должна быть такая же, как в юзерспейсе) - уже есть общая страница 5]
;в юзерспейсе назначаем нижнюю страницу с керналем (вместо ПЗУ)
        ld a,fd_user
        out (0xfd),a
		if atm==3 or atm==1
         ld a,0x7f
         ld bc,memportrom0000
         out (c),a ;отключаем ПЗУ
         ld a,0x7f-5
         ld bc,memportrom4000
         out (c),a ;отключаем 7ffd
         ld a,0x7f-2
         ld bc,memportrom8000
         out (c),a ;отключаем 7ffd
         ;ld a,0x7f-2
         ld bc,memportromc000
         out (c),a ;отключаем 7ffd
        endif
        ld a,pgtrdosfs ;idle
        ld bc,memport0000
        out (c),a
        
        ;ld hl,wasuserkernel+0x8000
        ;ld de,0
        ;ld bc,userkernel_sz
        ;ldir
        
        ld a,fd_system
        out (0xfd),a
		if atm==3 or atm==1
         ld a,0x7f
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

        if 1==0
        ld a,lx;(sys_pgdos)
        ld bc,memportrom0000
        out (c),a
        LD A,0xa8;%10101000 ;320x200 mode
	ld bc,0xff77 ;shadow ports off, palette off
        out (c),a
        ld a,1
        ld c,1
        call 0x3d13
        ld c,0x18
        call 0x3d13
        ld hl,0xc000
        ld de,0x0000
        ld bc,0x0805
        call 0x3d13
        jr $
        endif

        ld sp,BDOSSTACK
        ;ei
        ;halt ;чтобы прерывание не произошло когда не надо
        ;di
        ;jr $
;init_oldmousecoords=$+1
;        ld hl,0
;        ld (sys_oldmousecoords),hl
	 call BDOS_setpgstructs
	 ld hl,0xc000
	 ld de,0xc001
	 ld bc,0x3fff
	 ld (hl),l;0
	 ldir ;не помогло
init_sysdrv_val=$+1
	 ld a,SYSDRV
	 ld (SYSDRV_VAL),a
        jp setkernelpages_go ;di!!!

reset_ay
        ld a,0xfe
        call reset_ay_ay
        ld a,0xff
reset_ay_ay
	ld bc,#fffd
	out (c),a
	xor a
	ld l,a
reset_ay_ay0
	ld b,#ff
	out (c),a
	ld b,#bf
	out (c),l
	inc a
	cp 14
	jr nz,reset_ay_ay0
	ret

		if atm != 1
INIT_OUTSHADON
        ;LD BC,0xFF77 ;shadow ports remain off
			LD BC,0xBD77 ;shadow ports and palette remain on
			LD IX,10835
			PUSH IX
			JP 0x3D2F
		endif

INIT_setpg_low
        LD BC,memportrom0000 ;page for 0x0000..0x3fff
        OUT (C),A
        ret

INIT_setpg_8000
        LD BC,memport8000 ;page for 0x8000..0xbfff
        OUT (C),A
        ret

INIT_setpg_c000
        LD BC,memportc000 ;page for 0xc000..0xffff
        OUT (C),A
        ret
        
		if atm==2
basvar
.tape
	defb 0xFF, 0x00, 0x00, 0x00, 0x0D, 0x05, 0x10, 0x0D, 0x0D, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	defb 0x01, 0x00, 0x06, 0x00, 0x0B, 0x00, 0x01, 0x00, 0x01, 0x00, 0x06, 0x00, 0x10, 0x00, 0x00, 0x00
	defb 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFD, 0x7F, 0x3E, 0x14, 0xED, 0x79, 0xC3, 0x00, 0xC0
	defb 0x18, 0xF4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3C, 0x40, 0x00, 0xFF, 0xCC, 0x01, 0xFC, 0x5F, 0x00
	defb 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x00, 0x02, 0x07, 0x00, 0x00, 0xB4, 0x5D, 0x00, 0x00, 0x26
	defb 0x5D, 0x26, 0x5D, 0x3B, 0x5D, 0xB4, 0x5D, 0x3A, 0x5D, 0xB5, 0x5D, 0xB5, 0x5D, 0xB3, 0x5D, 0x00
	defb 0x00, 0xB7, 0x5D, 0xC3, 0x5D, 0xC3, 0x5D, 0x2D, 0x92, 0x5C, 0x10, 0x02, 0x00, 0x00, 0x00, 0x00
	defb 0x00, 0x00, 0x00, 0x00, 0xB6, 0x1A, 0x92, 0x00, 0x24, 0x01, 0x00, 0x58, 0xFF, 0x00, 0x00, 0x21
	defb 0x00, 0x5B, 0x21, 0x17, 0x00, 0x40, 0xE0, 0x50, 0x21, 0x18, 0x21, 0x17, 0x01, 0x07, 0x00, 0x07
	defb 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	defb 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	defb 0x00, 0x00, 0xFF, 0x5F, 0xFF, 0xFF, 0xF4, 0x09, 0xA8, 0x10, 0x4B, 0xF4, 0x09, 0xC4, 0x15, 0x53
	defb 0x81, 0x0F, 0xC9, 0x49, 0x91, 0xF4, 0x09, 0xC4, 0x83, 0x83, 0x83, 0x83, 0x00, 0x00, 0x00, 0x35
	defb 0x36, 0x31, 0x36, 0x0E, 0x00, 0x00, 0x03, 0x6B, 0x5E, 0x95, 0x5E, 0x00, 0x25, 0x73, 0x74, 0x73
	defb 0x35, 0x2E, 0x31, 0x61, 0x20, 0x43, 0x00, 0xDB, 0x00, 0x25, 0x25, 0x03, 0x09, 0x00, 0x00, 0x00
	defb 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x08, 0x08, 0x80, 0x08
	defb 0x00, 0xC8, 0xFA, 0x5C, 0xFA, 0x5C, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00
	defb 0xFF, 0x89, 0x5D, 0xFC, 0x5F, 0xFF, 0x3C, 0xAA, 0x00, 0x00, 0x01, 0x02, 0xFA, 0x5F, 0x03, 0x00
	defb 0xFE, 0x0D, 0x80, 0x00, 0x00, 0xFF, 0xF4, 0x09, 0xA8, 0x10, 0x4B, 0xF4, 0x09, 0xC4, 0x15, 0x53
	defb 0x81, 0x0F, 0xC4, 0x15, 0x52, 0xF4, 0x09, 0xC4, 0x15, 0x50, 0x80, 0x01, 0x00, 0x23, 0x00, 0xFD
	defb 0xB0, 0x22, 0x36, 0x35, 0x33, 0x36, 0x38, 0x22, 0x3A, 0xF9, 0xC0, 0xB0, 0x22, 0x31, 0x35, 0x36
	defb 0x31, 0x39, 0x22, 0x3A, 0xEA, 0x3A, 0xF7, 0x22, 0x62, 0x6F, 0x6F, 0x74, 0x20, 0x20, 0x20, 0x20
	defb 0x22, 0x0D, 0x80, 0xF4, 0x5C, 0x01, 0x05, 0x2E, 0x21, 0x00, 0x60, 0xE5, 0xC3, 0x13, 0x3D, 0x0D
.endtape
        endif

		if atm != 1
findpgdos
;если не найти страницу текущего доса, то на старых версиях ПЗУ ZX Evo не будет работать (в странице 0x83 почему-то не дос по умолчанию)
        call crcdos
        ld (doscrchi),de
        ld (doscrclo),bc
        ld lx,0x83
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
        cp 0xc0
        jr c,findpgdos0
        ld a,0x83 ;not found
        ret
crcdos
        ld hl,0x0000
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
		endif

INIT_blackpal
        LD HL,blackpalend
        ;halt ;halt есть выше - убрано, чтобы не светилось ничего
        LD DE,0xa80f ;0xab=6912 ;palette on, EGA, turbo
        LD BC,0xBD77
        OUT (C),D
INIT_setpal0 LD A,E
	and 7
        BIT 3,E
        OUT (0xFE),A
        JR Z,$+4
        OUT (0xF6),A
        LD A,(HL)
        DEC HL
        ld b,(hl) ;DDp palette low bits
        dec hl
        ld c,0xff
        OUT (c),a;(0xFF),A
        DEC E
        JP P,INIT_setpal0
        ret

        ifdef NOPAL
        dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
        else
        ds 32,0xf3
        endif
blackpalend=$-1

        include "unmegalz.asm" ;DEC40

wasresident
        disp resident
		if atm != 1
readmouse  ;=$-wasresident+resident
;sp=0x7fxx
;e=gfxmode
;out:
;a=gfxmode, hl=mousecoords, d=mousebuttons, e=kempstonbuttons
			call sys_SHADOFF
                       ;ifdef NOMOUSE
                       ; ld hl,0
                       ; ld d,0x0f ;buttons
                       ;else
			ld bc,0xfadf ;buttons
			in d,(c)
			inc b ;ld bc,0xfbdf ;x
			in l,(c)
			ld b,0xff ;y
			in h,(c)
                        ld c,0x1f
                        in e,(c) ;kempstonbuttons
                        inc e
                        jr nz,$+3 ;0xff = kempston joystick absent
                         inc e ;will be 0 after dec
                        dec e
                        jr shadon_pgsys_a
                       ;endif
		endif
shadon_pgsys  ;=$-wasresident+resident
        LD A,e;0xa8;%10101000 ;320x200 mode
shadon_pgsys_a  ;=$-wasresident+resident
		if atm != 1
			CALL sys_SHADON
		else
			ld bc,0x01bf
			out (c),b
			ld bc,0xbd77	;shadow ports and palette remain on
			out (c),a
			 ld a,32 ;xor a ;D5=444 palette
			out (0xbf),a
		endif
		
		if atm==3 or atm==1
			ld a,0x7f
			call sys_setpg_low
			ld a,pgsys
			ld bc,memport0000
			jr sys_outca_jr
         else
			ld a,0x7f-(pagexor-pgsys)
         endif
sys_setpg_low  ;=$-wasresident+resident
		ld bc,memportrom0000
		jr sys_outca_jr
sys_SHADOFF  ;=$-wasresident+resident
sys_pgdos=wasresident+(($+1)-resident) ;для патча
		ld a,0x83 ;48 basic switchable to DOS
		call sys_setpg_low
        LD A,e;0xa8;%10101000 ;320x200 mode
		ld bc,0xff77 ;shadow ports off, palette off
sys_outca_jr
        out (c),a
		ret
		if atm != 1
sys_SHADON  ;=$-wasresident+resident
			LD bc,10835
			PUSH bc
			LD BC,0xBD77 ;shadow ports and palette remain on
			JP 0x3D2F
		endif

;TODO убрать в pgtrdos
dos3d13_resident  ;=$-wasresident+resident

;сейчас включена pg5
;iy=23610
        ld (dos3d13_sp_st),sp
        ld sp,trdos_sp ;надо стек в 0x4000+ (не пересекающийся с INTSTACK, т.к. сейчас может произойти системное прерывание), по умолчанию стек был в 0x3fxx
        ;call swap_sysvars
        ex af,af' ;'
        call sys_SHADOFF ;включили ПЗУ
		ld (em3d13_de_st),de	;push de ;e=gfxmode
		 
		;*****************************	
		;call EM3D13PP;0x3d13
		;собственно дpайвеp, аналогичный 0x3д13 (и с его использованием)
		;на выходе - A pавно 0 - все окей, не 0 - ошибка
		;вместо  пpоцедyp DRAW_WINDOWS, PRINT_WINDOWS и REST_WINDOW
		;использyй свои.
		;Kurleson
;EM3D13PP
	ld      hl,em3d13pp_ret
	push    hl
	ld      (23613),sp
	xor     a
	ld (23801),a
	ld      (23823),a
	ld      (23824),a
	ld hl,varbas_stor
	ld de,0x5c4b
	ld bc,32
	ldir
	if atm == 1
		 ld a,32 ;xor a ;D5=444 palette
		out (0xbf),a
	endif
	exx	;pop hl,de,bc
	ex af,af' ;'
	jp      0x3D13

ONERR
	ex      (sp),hl
	push    af
	ld a,(0x5d0f)
	or a
	jr nz,em3d13pp_ret
	ld      a,h
	cp      0x0d
	jr      z,em3d13_error
ONERR_NO
	pop     af
	ex      (sp),hl
	ret 
em3d13_error   
	ld      a,0xff
	ld (0x5d0f),a
em3d13pp_ret

em3d13_de_st=$+1
    ld de,0	;e=gfxmode
	di
    call shadon_pgsys ;выключили ПЗУ (неатомарно - две записи в порт!!!)
	ei
        ;call swap_sysvars
dos3d13_sp_st=$+1	;-wasresident+resident
	ld sp,0
	ld a,(0x5d0f)	;возврат ошибки
	ret

	if atm != 1
		if atm2clock != 1
; Подержка часов GLUK в АТМ2+ (актуальная процедура для Evo находится в syskrnl)
NVRAM_REG=0xdf
NVRAM_VAL=0xbf

bin2cmos ;a to cmos cell b (BCD)
        push af
        ld a,b
        ld bc,0xf7 + (NVRAM_REG<<8)
        out (c),a
        pop af
        ld b,-1
        inc b
        sub 10
        jr nc,$-3
        add a,10
;a=num mod 10
;b=num div 10
        sla b
        sla b
        sla b
;b=(num div 10) *8
        add a,b
        add a,b
        ld b,NVRAM_VAL
        out (c),a ;BCD
        ret

minmes  ;=$-wasresident+resident
        ld h,a
        xor a
        srl h
        rra
        srl h
        rra
        srl h
        rra
        ret

bcd2bin  ;=$-wasresident+resident
        ld bc,0xf7 + (NVRAM_REG<<8)
        out (c),a
        ld b,NVRAM_VAL
        in a,(c)
        ld b,a
        and 0xf0
        rra ;*8
        ld c,a ;*8
        rra ;*4
        rra ;*2
        add a,c ;*10
        res 7,b
        res 6,b
        res 5,b
        res 4,b
        add a,b
        ret

readtime  ;=$-wasresident+resident
;sp=0x7fxx
;e=gfxmode
;out: hl=date, de=time
;TODO атомарно
	call sys_SHADOFF
	LD A,e;0xa8;%10101000 ;320x200 mode
	push af
	ld bc,0xeff7
	ld a,0x80+EFF7VALUE
	out (c),a
	;ld bc,0xf7 + (NVRAM_REG<<8)
    ;ld a,0x0b
    ;out (c),a
    ;ld b,NVRAM_VAL
    ;in a,(c)
    ;or 0x04
    ;out (c),a
    xor a		;sec
    call bcd2bin
    srl a
    ld e,a
    
    ld a,2		;min
    call bcd2bin
    call minmes ;a0 >> 3 => ha
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
    
    ld a,8		;month
    call bcd2bin
    call minmes ;a0 >> 3 => ha
    add a,l
    ld l,a
    
    ld a,9		;year
    call bcd2bin
    add a,20
    add a,a
    add a,h
    ld h,a
    jp readtimeq
        
writetime
;bc=time
;hl=date
       push bc
	call sys_SHADOFF
	LD A,e;0xa8;%10101000 ;320x200 mode
       pop de
	push af
	ld bc,0xeff7
	ld a,0x80+EFF7VALUE
	out (c),a
        
        ld a,e
        add a,a
        and 63
        ld b,0		;sec
        call bin2cmos

        ld a,d
        rra
        rra
        rra
        and 31 ;h
        ld b,4
        call bin2cmos

        ex de,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ex de,hl
        ld a,d
        and 63 ;m
        ld b,2
        call bin2cmos

        ld a,h
        srl a
        sub 20
        ld b,9		;year
        call bin2cmos

        ld a,l
        and 31
        ld b,7		;day
        call bin2cmos
    
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and 15
        ld b,8		;month
        call bin2cmos
readtimeq
	ld bc,0xeff7
	ld a,0+EFF7VALUE
	out (c),a
	pop af
        ld e,a ;!!! потом будет использоваться в readtime
	jp shadon_pgsys

                else ;if atm2clock == 1

; Подержка часов 8952  АТМ2+ и АТМ8		
cmd2ve:	;e=command	 возвращаем результат в A
		di
		ld bc,0x55FE		;адрес 8952
		in a,(c)		;Переход в режим команды
		ld b,e             	;команда из E переноcим в B
		in a,(c)		;выполнить команду
		ei
		ret
send2ve:	;e=command b=data
		push de
                ld e,b
                ld d,a
                di
		ld bc,0x55FE            ;адрес 8952
		in a,(c)		;Переход в режим команды
		ld b,e                  ;команда из E переноcим в B 
		IN a,(c)
		ld b,d                  ;Параметр
		in a,(c)
		ei
                pop de
		ret
writetime
;bc=time
;hl=date
;TODO (keep de!)
        push bc
	call sys_SHADOFF
	LD A,e;0xa8;%10101000 ;320x200 mode
        pop de
	push af
	ld bc,0xeff7
	ld a,0x80+EFF7VALUE
	out (c),a

        ld a,e
        add a,a
        and 63
        ld b,0x11		;sec
        call send2ve

        ld a,d
        rra
        rra
        rra
        and 31 ;h
        ld b,0x91
        call send2ve

        ex de,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ex de,hl
        ld a,d
        and 63                  ;m
        ld b,0x51
        call send2ve

        ld a,h
        srl a
        ;sub 20
        ld b,0x93		;year
        call send2ve

        ld a,l
        and 31
        ld b,0x13		;day
        call send2ve
    
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and 15
        ld b,0x53	        ;month
        call send2ve
	ld bc,0xeff7
	ld a,0+EFF7VALUE
	out (c),a
	pop af
        ld e,a                   ;!!! потом будет использоваться в readtime
	jp shadon_pgsys


readtime  ;=$-wasresident+resident
;sp=0x7fxx
;e=gfxmode
;out: hl=date, de=time
;TODO атомарно

	call sys_SHADOFF
	LD A,e;0xa8;%10101000 ;320x200 mode
	push af
	push bc

	ld e, 0x90		;hours
	call cmd2ve
	ld l, a
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ld e, 0x50		;Minutes
	call cmd2ve
	add a,l
	ld l,a
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ld e, 0x10		;Seconds
	call cmd2ve
	srl a
	add a,l
	ld l,a
	push hl			;save time

;	Date	
	ld e, 0x92		;year
	call cmd2ve
	;add a, 20
	ld l, a
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	
	ld e, 0x52		;month
	call cmd2ve
	add a,l
	ld l,a	
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL

	ld e, 0x12		;day
	call cmd2ve
	add a,l
	ld l,a
	pop de

	pop bc
	pop af
	jp shadon_pgsys_a

                endif ;if atm2clock != 1

	endif ;if atm != 1
	;disp $-wasresident+resident

		
		ds 100
trdos_sp
varbas_stor
		ds 32
        ent
resident_sz=$-wasresident
        display "residentend=",resident+resident_sz,"<=",trdos_catbuf

wastrdosfs
        disp COMMANDLINE;PROGSTART
idle
        db "idle",0
        ds PROGSTART-$
        include "idle.asm"
idle_sz=$-idle
        ent
        disp 0x4000+idle+idle_sz
        include "trdosfs.asm"
        include "trdosio.asm"
        include "bdospg2.asm"
        ent
trdosfs_sz=$-wastrdosfs
        display "trdosfs_sz=",/h,trdosfs_sz,"<=0x1c00"
        
end
wassys

        SLOT 0
        page COMPILEPG_SYS0
        SLOT 1
        page COMPILEPG_SYS1
        org 0x0000
sysbegin
        include "syskrnl.asm"
        
	display "$ before align=",syskrnl_end
       if 1
       macro SETHANDLER cmd,addr
        org wastbdoscmds+cmd
        db addr&0xff
        org wastbdoscmds+256+cmd
        db addr/256
       endm

        ds 0xff&(-syskrnl_end)
tbdoscmds=syskrnl_end+(0xff&(-syskrnl_end))
wastbdoscmds
        ds 256,BDOS_fail&0xff
        ds 256,BDOS_fail/256
       
         SETHANDLER CMD_GETPAGEOWNER,BDOS_getpageowner
         SETHANDLER CMD_WRITEHANDLE,BDOS_writehandle
         SETHANDLER CMD_WIZNETREAD,BDOS_wiznetread
         SETHANDLER CMD_YIELDKEEP,BDOS_yieldkeep
         SETHANDLER CMD_YIELD,BDOS_yield
         SETHANDLER CMD_READHANDLE,BDOS_readhandle
          SETHANDLER CMD_GETKEYMATRIX,BDOS_getkeymatrix
          SETHANDLER CMD_GETTIMER,BDOS_gettimer
          SETHANDLER CMD_CHECKPID,BDOS_checkpid
          SETHANDLER CMD_SETSCREEN,BDOS_setscreen
         SETHANDLER CMD_PRATTR,BDOS_prattr
         SETHANDLER CMD_SETXY,BDOS_setxy
         SETHANDLER CMD_SETCOLOR,BDOS_setcolor
         SETHANDLER CMD_PRCHAR,BDOS_prchar
         SETHANDLER CMD_GETATTR,BDOS_getattr
	SETHANDLER CMD_SETDTA,BDOS_setdta;0x1a
	SETHANDLER CMD_FOPEN,BDOS_fopen;0x0f
	SETHANDLER CMD_FREAD,BDOS_fread;0x14
	SETHANDLER CMD_FCLOSE,BDOS_fclose;0x10
	SETHANDLER CMD_FDEL,BDOS_fdel;0x13 ;DEPRECATED!!!!! 
	SETHANDLER CMD_FCREATE,BDOS_fcreate;0x16
	SETHANDLER CMD_FWRITE,BDOS_fwrite;0x15
        SETHANDLER CMD_FSEARCHFIRST,BDOS_fsearchfirst;0x11
        SETHANDLER CMD_FSEARCHNEXT,BDOS_fsearchnext;0x12
        SETHANDLER CMD_OPENDIR,BDOS_opendir
        SETHANDLER CMD_READDIR,BDOS_readdir
        SETHANDLER CMD_SETDRV,BDOS_setdrv
	SETHANDLER CMD_PARSEFNAME,BDOS_parse_filename;0x5c
        SETHANDLER CMD_CHDIR,BDOS_chdir
        SETHANDLER CMD_GETPATH,BDOS_getpath
        SETHANDLER CMD_RUNAPP,BDOS_runapp
        SETHANDLER CMD_NEWAPP,BDOS_newapp
        SETHANDLER CMD_CLS,BDOS_cls
        SETHANDLER CMD_SETGFX,BDOS_setgfx
        SETHANDLER CMD_SETPAL,BDOS_setpal
        SETHANDLER CMD_GETMAINPAGES,BDOS_getmainpages
        SETHANDLER CMD_NEWPAGE,BDOS_newpage
        SETHANDLER CMD_DELPAGE,BDOS_delpage
        SETHANDLER CMD_MOUNT,BDOS_mount
        SETHANDLER CMD_FREEZEAPP,BDOS_freezeapp
        SETHANDLER CMD_MKDIR,BDOS_mkdir
        SETHANDLER CMD_RENAME,BDOS_rename
        SETHANDLER CMD_SETSYSDRV,BDOS_setsysdrv
        ;SETHANDLER CMD_FWRITE_NBYTES,BDOS_fwrite_nbytes
        SETHANDLER CMD_SCROLLUP,BDOS_scrollup
        SETHANDLER CMD_SCROLLDOWN,BDOS_scrolldown
        SETHANDLER CMD_OPENHANDLE,BDOS_openhandle
        SETHANDLER CMD_CREATEHANDLE,BDOS_createhandle
        SETHANDLER CMD_CLOSEHANDLE,BDOS_closehandle
        SETHANDLER CMD_SEEKHANDLE,BDOS_seekhandle
        SETHANDLER CMD_TELLHANDLE,BDOS_tellhandle
        SETHANDLER CMD_SETFILETIME,BDOS_setfiletime
        SETHANDLER CMD_GETFILETIME,BDOS_getfiletime
        SETHANDLER CMD_GETTIME,BDOS_gettime
        SETHANDLER CMD_GETXY,BDOS_getxy
        SETHANDLER CMD_GETAPPMAINPAGES,BDOS_getappmainpages
        SETHANDLER CMD_DROPAPP,BDOS_dropapp
        SETHANDLER CMD_WIZNETOPEN,BDOS_wiznetopen
        SETHANDLER CMD_WIZNETCLOSE,BDOS_wiznetclose
        SETHANDLER CMD_WIZNETWRITE,BDOS_wiznetwrite
        SETHANDLER CMD_GETFILESIZE,BDOS_getfilesize
        SETHANDLER CMD_DELETE,BDOS_delete
        SETHANDLER CMD_GETCHILDRESULT,BDOS_getchildresult
        SETHANDLER CMD_SETWAITING,BDOS_setwaiting
        SETHANDLER CMD_SETBORDER,BDOS_setborder
        SETHANDLER CMD_READSECTORS,BDOS_readsectors
        SETHANDLER CMD_WRITESECTORS,BDOS_writesectors
        SETHANDLER CMD_SETMAINPAGE,BDOS_setmainpage
        SETHANDLER CMD_SETMUSIC,BDOS_setmusic
        SETHANDLER CMD_PLAYCOVOX,BDOS_playcovox
        SETHANDLER CMD_GETSTDINOUT,BDOS_getstdinout
        SETHANDLER CMD_SETSTDINOUT,BDOS_setstdinout
        SETHANDLER CMD_HIDEFROMPARENT,BDOS_hidefromparent
        SETHANDLER CMD_RNDRD,BDOS_rndrd
        SETHANDLER CMD_RNDWR,BDOS_rndwr
        SETHANDLER CMD_GETFILINFO,BDOS_getfilinfo
        SETHANDLER CMD_RESERV_1,BDOS_reserv_1
        SETHANDLER CMD_GETCONFIG,BDOS_get_config
        SETHANDLER CMD_GETMEMPORTS,BDOS_getmemports
        SETHANDLER CMD_SETTIME,BDOS_settime
        SETHANDLER CMD_GETPAL,BDOS_getpal
         
         org wastbdoscmds+512
trecode=tbdoscmds+512
         
       else

tbdoscmds=syskrnl_end
wastbdoscmds
         db CMD_WRITEHANDLE
         db CMD_WIZNETREAD
         db CMD_YIELDKEEP
         db CMD_YIELD
         db CMD_READHANDLE
          db CMD_GETKEYMATRIX
          db CMD_GETTIMER
          db CMD_CHECKPID
          db CMD_SETSCREEN
         db CMD_PRATTR
         db CMD_SETXY
         db CMD_SETCOLOR
         db CMD_PRCHAR
         db CMD_GETATTR
	db CMD_SETDTA;0x1a
	db CMD_FOPEN;0x0f
	db CMD_FREAD;0x14
	db CMD_FCLOSE;0x10
	db CMD_FDEL;0x13 ;DEPRECATED!!!!! 
	db CMD_FCREATE;0x16
	db CMD_FWRITE;0x15
        db CMD_FSEARCHFIRST;0x11
        db CMD_FSEARCHNEXT;0x12
        db CMD_OPENDIR
        db CMD_READDIR
        db CMD_SETDRV
	db CMD_PARSEFNAME;0x5c
        db CMD_CHDIR
        db CMD_GETPATH
        db CMD_RUNAPP
        db CMD_NEWAPP
        db CMD_CLS
        db CMD_SETGFX
        db CMD_SETPAL
        db CMD_GETMAINPAGES
        db CMD_NEWPAGE
        db CMD_DELPAGE
        db CMD_MOUNT
        db CMD_FREEZEAPP
        db CMD_MKDIR
        db CMD_RENAME
        db CMD_SETSYSDRV
        ;db CMD_FWRITE_NBYTES
        db CMD_SCROLLUP
        db CMD_SCROLLDOWN
        db CMD_OPENHANDLE
        db CMD_CREATEHANDLE
        db CMD_CLOSEHANDLE
        db CMD_SEEKHANDLE
        db CMD_TELLHANDLE
        db CMD_SETFILETIME
        db CMD_GETFILETIME
        db CMD_GETTIME
        db CMD_GETXY
        db CMD_GETAPPMAINPAGES
        db CMD_DROPAPP
        db CMD_WIZNETOPEN
        db CMD_WIZNETCLOSE
        db CMD_WIZNETWRITE
        db CMD_GETFILESIZE
        db CMD_DELETE
        db CMD_GETCHILDRESULT
        db CMD_SETWAITING
        db CMD_SETBORDER
        db CMD_READSECTORS
        db CMD_WRITESECTORS
        db CMD_SETMAINPAGE
        db CMD_SETMUSIC
        db CMD_PLAYCOVOX
        db CMD_GETSTDINOUT
        db CMD_SETSTDINOUT
        db CMD_HIDEFROMPARENT
        db CMD_RNDRD
        db CMD_RNDWR
        db CMD_GETFILINFO
        db CMD_RESERV_1
        db CMD_GETCONFIG
        db CMD_GETMEMPORTS
        db CMD_SETTIME
        db CMD_GETPAL
nbdoscmds=$-wastbdoscmds
        dw BDOS_getpal
        dw BDOS_settime
        dw BDOS_getmemports
        dw BDOS_get_config
        dw BDOS_reserv_1
        dw BDOS_getfilinfo
        dw BDOS_rndwr
        dw BDOS_rndrd
        dw BDOS_hidefromparent
        dw BDOS_setstdinout
        dw BDOS_getstdinout
        dw BDOS_playcovox
        dw BDOS_setmusic
        dw BDOS_setmainpage
        dw BDOS_writesectors
        dw BDOS_readsectors
        dw BDOS_setborder
        dw BDOS_setwaiting
        dw BDOS_getchildresult
        dw BDOS_delete
        dw BDOS_getfilesize
        dw BDOS_wiznetwrite
        dw BDOS_wiznetclose
        dw BDOS_wiznetopen
        dw BDOS_dropapp
        dw BDOS_getappmainpages
        dw BDOS_getxy
        dw BDOS_gettime
        dw BDOS_getfiletime
        dw BDOS_setfiletime
        dw BDOS_tellhandle
        dw BDOS_seekhandle
        dw BDOS_closehandle
        dw BDOS_createhandle
        dw BDOS_openhandle
        dw BDOS_scrolldown
        dw BDOS_scrollup
        ;dw BDOS_fwrite_nbytes
        dw BDOS_setsysdrv
        dw BDOS_rename
        dw BDOS_mkdir
        dw BDOS_freezeapp
        dw BDOS_mount
        dw BDOS_delpage
        dw BDOS_newpage
        dw BDOS_getmainpages
        dw BDOS_setpal
        dw BDOS_setgfx
        dw BDOS_cls
        dw BDOS_newapp
        dw BDOS_runapp
        dw BDOS_getpath
        dw BDOS_chdir
        dw BDOS_parse_filename
        dw BDOS_setdrv
        dw BDOS_readdir
        dw BDOS_opendir
        dw BDOS_fsearchnext
        dw BDOS_fsearchfirst
	dw BDOS_fwrite
	dw BDOS_fcreate
	dw BDOS_fdel ;DEPRECATED!!!!! 
	dw BDOS_fclose
	dw BDOS_fread
	dw BDOS_fopen
        dw BDOS_setdta
         dw BDOS_getattr
         dw BDOS_prchar
         dw BDOS_setcolor
         dw BDOS_setxy
         dw BDOS_prattr
          dw BDOS_setscreen
          dw BDOS_checkpid
          dw BDOS_gettimer
          dw BDOS_getkeymatrix
         dw BDOS_readhandle
         dw BDOS_yield
         dw BDOS_yieldkeep
         dw BDOS_wiznetread
         dw BDOS_writehandle
trecode=tbdoscmds+$-wastbdoscmds
       endif

;TODO хранить прямо в текстовом экране? а если затрут, то восстанавливать? по какому событию?
	incbin "../_sdk/codepage/866toatm"

syscodesz=trecode+256-wassyscode
        display "syscodesz=",/h,syscodesz," < minstack=",/h,SYSMINSTACK

wasuserkernel
        disp 0x0000
        include "userkrnl.asm"
        ent
userkernel_sz=$-wasuserkernel
	;display "wasuserkernel=",/d,wasuserkernel
	;display "wasuserkernel_end=",/d,$
	;display "userkernel_sz=",/d,userkernel_sz
;wastjump
;        include "tjump.asm"
;tjump_sz=$-wastjump
        ds 0x4000-$
        incbin "../fatfs4os/fatfs.raw"
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
	
	LABELSLIST "..\..\us\user.l",1
