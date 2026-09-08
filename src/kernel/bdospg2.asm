;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

sys_newapp_forBDOS
        ld a,(iy+app.id)
       push af ;parent id
         push iy ;parent app
          di ;между findfreeid+findfreeappstruct и заполнением iy+app.id нельзя переключать задачи!!! ;TODO critical section
        call sys_findfreeid ;портит iy
         pop hl ;parent app
        push af ;id
         push hl ;parent app
        call sys_findfreeappstruct ;возвращает iy = адрес первой свободной структуры app ;TODO error
         pop ix ;parent app
         ld a,(ix+app.stdin)
         ld (iy+app.stdin),a
         ld a,(ix+app.stdout)
         ld (iy+app.stdout),a
         ld a,(ix+app.stderr)
         ld (iy+app.stderr),a
         ld l,(ix+app.textcuraddr)
         ld h,(ix+app.textcuraddr+1)
         ;jr nz,BDOS_newapp_fail
         jr z,sys_newapp_forBDOS2
;BDOS_newapp_fail
        pop af
       pop af
        ld a,0xff
          ei
        ret

sys_newapp_forBDOS2
        pop af ;id
        push af ;id
        ld e,0xff ;auto page
        ;hl=textcuraddr
        call sys_newapp
          ei
         push iy
         pop de
         ld hl,(appaddr)
         ld bc,app.vol
         add hl,bc
         ex de,hl
         add hl,bc
         ex de,hl
         ld bc,5;DIR_sz
         ldir ;копировать текущий vol и dircluster
        call BDOS_getmainpages_iy
        pop bc ;b=id
       pop af ;parent id
        ld (iy+app.parentid),a
        xor a
        ret ;success
        
sys_newapp
;iy=app
;a=id
;e=page (0xff = auto)
;hl=textcuraddr
;в это время нельзя переключать задачи, иначе структуру могут перезахватить!
        ;TODO priority
        ld (iy+app.id),a ;зарезервировали место
        ld (iy+app.flags),0 ;пока тут 0, задачу никто не будет трогать
        ;ld hl,0xc1c0
        ld (iy+app.textcuraddr),l
        ld (iy+app.textcuraddr+1),h
        ;TODO curmsg
        ;TODO endmsg
        ;TODO next
        ld a,e
        inc a
       push af
        call z,BDOS_newpage_iy
        ld (iy+app.mainpg),e

        ld a,e
        call sys_setpgc000

        ld hl,wasuserkernel
        ld de,0+0xc000
        ld bc,userkernel_sz
        ldir
       pop af
       jr nz,sys_newapp_nokillcmdline ;for idle
        xor a
        ld (0xc000+COMMANDLINE),a ;command line
sys_newapp_nokillcmdline
        call disablescreeninapp
        
        call BDOS_newpage_iy
        ld a,e
        ld (curpg16k+0xc000),a
        call BDOS_newpage_iy
        ld a,e
        ld (curpg32klow+0xc000),a
        call BDOS_newpage_iy
        ld a,e
        ld (curpg32khigh+0xc000),a

        call sys_setpgc000
        ld hl,0x0100
        ld (0xfffe),hl ;адрес выхода
        
        ld (iy+app.curcolor),7
        ld (iy+app.screen),fd_user
        ;ld (iy+app.gfxmode),0xa8;%10101000 ;320x200 mode
		IFDEF NOTURBO
        ld (iy+app.gfxmode),0xa6;%10101110 ;textmode
		ELSE
        ld (iy+app.gfxmode),0xae;%10101110 ;textmode
		ENDIF
        push iy
        pop de
        ld hl,app.pal
        add hl,de
        ex de,hl
        ld hl,standardpal
        ld bc,32
        ldir

        ;ld a,SYSDRV ;TODO брать драйв от текущего app
        ;call BDOS_setvol_rootdir ;требует PGFATFS
		ld a,(SYSDRV_VAL)
         ld (iy+app.vol),a	;SYSDRV ;TODO брать драйв от текущего app
         ld (iy+app.dircluster),b;0
         ld (iy+app.dircluster+1),b;0
         ld (iy+app.dircluster+2),b;0
         ld (iy+app.dircluster+3),b;0

        ld (iy+app.border),b;0

        ld a,pgkillable
         ld (iy+app.scr0low),a;0
         ld (iy+app.scr0high),a;0
         ld (iy+app.scr1low),a;0
         ld (iy+app.scr1high),a;0

        ;ld a,(iy+app.mainpg)
        ;ld (iy-safestack_sz+1),a
        ;ld a,(iy+app.screen)
        ;ld (iy-safestack_sz+7),a
        ld (iy-2),0xf8
        ld (iy-1),0xff ;sp=-8 в описателе задачи (там 3 рег.пары и адрес выхода)
        ;jr $
        ret
        
makeidle
        ld iy,app1
        ld (appaddr),iy
        ld a,1 ;id
        ld e,pgtrdosfs ;pgidle
        ld hl,0xc1c0
        call sys_newapp
        ;ld a,'i' ;idle
        ;ld (0xc000+COMMANDLINE),a ;command line
         ;ld (iy+app.vol),SYSDRV ;есть в самом idle
        set factive,(iy+app.flags)
        ret

standardpal
        STANDARDPAL

        if PS2KBD==0
			include "syskey2.asm"
		else
			include "ps2drv.asm"
        endif
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		if INETDRV == 1
        include "w5300.asm"
		endif
		if INETDRV == 2
        include "espnet.asm"
		endif
		if INETDRV == 0
wiznet_open
wiznet_close
wiznet_read
wiznet_write
        ld hl,0xffff
        ld a,l
        ret
		endif
