;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        
sys_newapp
;iy=app
;a=id
;e=page (#ff = auto)
;hl=textcuraddr
;в это время нельзя переключать задачи, иначе структуру могут перезахватить!
        ;TODO priority
        ld (iy+app.id),a ;зарезервировали место
        ld (iy+app.flags),0 ;пока тут 0, задачу никто не будет трогать
        ;ld hl,#c1c0
        ld (iy+app.textcuraddr),l
        ld (iy+app.textcuraddr+1),h
        ;TODO curmsg
        ;TODO endmsg
        ;TODO next
        ld a,e
        inc a
        call z,BDOS_newpage_iy
        ld (iy+app.mainpg),e

        ld bc,memportc000
        out (c),e

        ld hl,wasuserkernel
        ld de,0+#c000
        ld bc,userkernel_sz
        ldir
        xor a
        ld (#c000+COMMANDLINE),a ;command line
        
        call BDOS_newpage_iy
        ld a,e
        ld (curpg16k+#c000),a
        call BDOS_newpage_iy
        ld a,e
        ld (curpg32klow+#c000),a
        call BDOS_newpage_iy
        ld a,e
        ld (curpg32khigh+#c000),a
        
        ld (iy+app.curcolor),7
        ld (iy+app.screen),fd_user
        ;ld (iy+app.gfxmode),%10101000 ;320x200 mode
        ld (iy+app.gfxmode),%10101110 ;textmode
        push iy
        pop de
        ld hl,app.pal
        add hl,de
        ex de,hl
        ld hl,standardpal
        ld bc,32
        ldir

        ld a,4 ;TODO брать драйв от текущего app
        call BDOS_setvol_rootdir

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
        ld hl,#c1c0
        call sys_newapp
        ld a,'i' ;idle
        ld (#c000+COMMANDLINE),a ;command line
        set factive,(iy+app.flags)
        ret

standardpal
        STANDARDPAL
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        include "w5300.asm"
