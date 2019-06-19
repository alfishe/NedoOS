        DEVICE ZXSPECTRUM128
        ;device pentagon1024

        include "../_sdk/syssets.asm"
TOPDOWNMEM=1

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
INTSTACK1=0x3f00 ;kernelspace (для входа в обработчик без порчи стека)
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
        xor a
        out (0xfe),a

        LD (IY+1),0xCC

        if 1==0
       ;IFN em3d13
       ; LD HL,ONERR
       ; LD (23747),HL
       ;ENDIF 
       LD A,(23833)
       ADD A,"A
       LD (src),A
       LD (dst),A
       XOR A
       LD (23658),A ;0x5c6a
      ;LD L,A,H,L
      ;LD (23802),HL 
        endif
       XOR A
	ld (0x5d10),a
        
        ;ld hl,0xc9f1 ;pop af:ret
        ;ld (0x5cc2),hl
        
        ld bc,0xfbdf ;x
        in l,(c)
        ld b,0xff
        in h,(c)
        ld (init_oldmousecoords),hl

;;;;;;;;;;;;;;;;;;; set gfx mode ;;;;;;;;;;;;;;;;;
        halt
        LD A,0xa8;%10101000 ;320x200 mode
        ;LD A,0xaa;%10101010 ;640x200 mode
        ;LD A,0xae;%10101110 ;textmode
		if atm==1
			ld bc,0x01bf
			out (c),b
			ld bc,0xbd77	;shadow ports and palette remain on
			out (c),a
			xor a
			out (0xbf),a
		else
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
		
		ifn atm==1
			call findpgdos
		else
			ld a,0x04
			in a,(0xbe)
			and 0xbf;%10111111
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
        ld hl,0x5c00
        ld de,0xc000+0x1c00
        ld bc,0x0400;0x5d3b-0x5c00
        ldir
        ld hl,wasresident
        ld de,resident+0xc000-0x4000
        ld bc,resident_sz
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
        
;перебрасываем 16K упакованный блок в 0xc000
        ld hl,wassys+0x3fff
        ld de,0xffff
        ld bc,0x4000
        lddr
;распаковываем в 0x6400
        ld hl,0xc000;wassys
        ld de,0x6400;0x8000
        call DEC40 ;распаковываем в 0x8000 (там уже включены системные странички)
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
init_oldmousecoords=$+1
        ld hl,0
        ld (sys_oldmousecoords),hl
	 call BDOS_setpgstructs
	 ld hl,0xc000
	 ld de,0xc001
	 ld bc,0x3fff
	 ld (hl),l;0
	 ldir ;не помогло
        jp setkernelpages_go

        
		ifn atm==1
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
		
		ifn atm==1
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

        ds 32,0xf3
blackpalend=$-1

        include "unmegalz.asm" ;DEC40

wasresident
        ;disp resident
		ifn atm==1
readmouse=$-wasresident+resident
;sp=0x7fxx
;e=gfxmode
;out: hl=mousecoords, d=mousebuttons
        call sys_SHADOFF
        ld bc,0xfadf ;buttons
        in d,(c)
        inc b ;ld bc,0xfbdf ;x
        in l,(c)
        ld b,0xff ;y
        in h,(c)
		endif
shadon_pgsys=$-wasresident+resident
        LD A,e;0xa8;%10101000 ;320x200 mode
shadon_pgsys_a=$-wasresident+resident
		ifn atm==1
			CALL sys_SHADON
		else
			ld bc,0x01bf
			out (c),b
			ld bc,0xbd77	;shadow ports and palette remain on
			out (c),a
			xor a
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
sys_setpg_low=$-wasresident+resident
		ld bc,memportrom0000
		jr sys_outca_jr
sys_SHADOFF=$-wasresident+resident
sys_pgdos=$+1 ;для патча
		ld a,0x83 ;48 basic switchable to DOS
		call sys_setpg_low
        LD A,e;0xa8;%10101000 ;320x200 mode
		ld bc,0xff77 ;shadow ports off, palette off
sys_outca_jr
        out (c),a
		ret
		ifn atm==1
sys_SHADON=$-wasresident+resident
			LD bc,10835
			PUSH bc
			LD BC,0xBD77 ;shadow ports and palette remain on
			JP 0x3D2F
		endif

;TODO убрать в pgtrdos
dos3d13_resident=$-wasresident+resident
;сейчас включена pg5
;iy=23610
        ld (dos_sp),sp
        ld sp,TRDOSSTACK ;надо стек в 0x4000+ (не пересекающийся с INTSTACK, т.к. сейчас может произойти системное прерывание), по умолчанию стек был в 0x3fxx
        ;call swap_sysvars
        ex af,af'
        call sys_SHADOFF ;включили ПЗУ
        ex af,af'
         push de ;e=gfxmode
        exx
	call EM3D13PP;0x3d13
         pop de ;e=gfxmode
	di
        call shadon_pgsys ;выключили ПЗУ (неатомарно - две записи в порт!!!)
	ei
        ;call swap_sysvars
dos_sp=$+1-wasresident+resident
        ld sp,0
        ret
		
	ifn atm==1
NVRAM_REG=0xdf
NVRAM_VAL=0xbf
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
    ld b,NVRAM_REG
    out (c),a
    ld b,NVRAM_VAL
    in a,(c)
    ret
    
readtime=$-wasresident+resident
;sp=0x7fxx
;e=gfxmode
;out: hl=date, de=time
;TODO атомарно
	call sys_SHADOFF
	LD A,e;0xa8;%10101000 ;320x200 mode
	push af
	ld bc,0xeff7
	ld a,0x80
	out (c),a
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
		endif

	disp $-wasresident+resident
;собственно дpайвеp, аналогичный 0x3д13 (и с его использованием)
;на выходе - A pавно 0 - все окей, не 0 - ошибка
;вместо  пpоцедyp DRAW_WINDOWS, PRINT_WINDOWS и REST_WINDOW
;использyй свои.
;Kurleson
EM3D13PP
        PUSH    HL
        LD      HL,(23613)
        LD      (eRR),HL
       LD      HL,ONERR;DDRV
       LD      (0x5CC3),HL
        LD      HL,ERR
        EX      (SP),HL
        LD      (23613),SP
        EX      AF,AF'
;AC3=$+1
        LD      A,0xC3
        LD      (0x5CC2),A
        XOR     A
        LD      (23823),A
        LD      (23824),A
        LD      (eRR2),A
        EX      AF,AF'
        PUSH BC,DE,HL
        LD HL,0x5e00;5f00
        LD DE,SYSBUF
        LD BC,256
        LDIR 
        POP HL,DE,BC
EMCALL  JP      0x3D13
ERR
eRR=$+1
        LD      HL,0x0000
        LD      (23613),HL ;??? eRR же не меняется ???
        LD      A,0xC9
        LD      (0x5CC2),A
        LD DE,0x5e00;5f00
        LD HL,SYSBUF
        LD BC,256
        LDIR 
eRR2=$+1
        LD      A,0x00
        OR      A
        RET     NZ
        LD      A,(23823)
        AND     A
        RET     Z
        PUSH    AF
       LD A,2
       OUT (-2),A
       ;PUSH    IX

       ;LD      IX,DISKERROR_TBL ;здесь y меня pисyется окно
       ;CALL    DRAW_WINDOWS     ;с надписью DISK ERROR
       ;CALL    PRINT_WINDOWS
        XOR     A
        IN      A,(0xFE)
        CPL 
        AND     0x1F
        JR      Z,$-6             ;нажата ли кнопка
       ;CALL    REST_WINDOW       ;востановили то, что было под
       ;POP     IX                ;окном
       XOR A
       OUT (-2),A
       ;CALL OLDRV
        POP     AF
        RET 
ONERR
        EX      (SP),HL
        PUSH    AF
        LD      A,H
        CP      0x0D
        JR      Z,ERROR
        POP     AF
        EX      (SP),HL
        RET 
ERROR   POP     HL
        POP     HL     ;ЕСЛИ L=0xD8, ТО        READ ONLY
                       ;ИHАЧЕ DISK ERROR
        POP     HL
        POP     HL
        POP     HL
       LD A,2
       OUT (-2),A
       ;PUSH    IX
       ;LD      IX,SAVELOADERROR_TBL ;здесь окно
       ;CALL    DRAW_WINDOWS      ;LOAD/SAVE ERROR
       ;CALL    PRINT_WINDOWS     ;ABORT/RETRY/IGNORE
                                  ;инфy о тpеке/сектоpе можно
                                  ;взять из (0x5CF4)

ERROR0  LD      A,0xFB        ;пpовеpяем нажатие клавиш R,A,I
        IN      A,(0xFE)
        LD      C,"R"
        BIT     3,A
        JR      Z,ERROR1
        LD      C,"A"
        LD      A,0xFD
        IN      A,(0xFE)
        RRA 
        JR      NC,ERROR1
        LD      C,"I"
        LD      A,0xDF
        IN      A,(0xFE)
        BIT     2,A
        JR      NZ,ERROR0
ERROR1  LD      A,C
        CP      "A"
        JR      NZ,$+7
        LD      A,0xFF
        LD      (eRR2),A
       ;PUSH    AF
       ;CALL    REST_WINDOW     ;востанавливаем то, что было
                                ;под LOAD/SAVE ERROR окном
       XOR A
       OUT (-2),A
       ;POP     AF
       ;POP     IX
        LD      HL,0x3F7E
        EX      (SP),HL
        JP       0x3D2F
SYSBUF
	ds 256

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
wasuserkernel
        disp 0x0000
        include "userkrnl.asm"
        ent
userkernel_sz=$-wasuserkernel
	;display "wasuserkernel=",/d,wasuserkernel
	;display "wasuserkernel_end=",/d,$
	;display "userkernel_sz=",/d,userkernel_sz
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
	
	LABELSLIST "user.l"
