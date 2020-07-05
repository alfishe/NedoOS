;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        
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
        call z,BDOS_newpage_iy
        ld (iy+app.mainpg),e

        ;ld bc,memportc000
        ;out (c),e
        ld a,e
        call sys_setpgc000

        ld hl,wasuserkernel
        ld de,0+0xc000
        ld bc,userkernel_sz
        ldir
        xor a
        ld (0xc000+COMMANDLINE),a ;command line
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
         ;xor a
         ld (iy+app.dircluster),b;a
         ld (iy+app.dircluster+1),b;a
         ld (iy+app.dircluster+2),b;a
         ld (iy+app.dircluster+3),b;a

        ld (iy+app.border),b;a

        ld a,(iy+app.mainpg)
        ld (iy-safestack_sz+1),a
        ld a,(iy+app.screen)
        ld (iy-safestack_sz+7),a
        
        ret
        
makeidle
        ld iy,app1
        ld (appaddr),iy
        ld a,1 ;id
        ld e,pgtrdosfs ;pgidle
        ld hl,0xc1c0
        call sys_newapp
        ld a,'i' ;idle
        ld (0xc000+COMMANDLINE),a ;command line
         ;ld (iy+app.vol),SYSDRV ;есть в самом idle
        set factive,(iy+app.flags)
        ret

standardpal
        STANDARDPAL
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		if INETDRV
        include "w5300.asm"
        else
wiznet_open
wiznet_close
wiznet_read
wiznet_write
        ld hl,0xffff
        ret
		ENDIF
