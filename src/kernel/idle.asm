;не включаем gfxmode, чтобы idle никогда не получал фокус
;по умолчанию стоит текстмод
        ld sp,0x4000 ;нельзя ниже 0x3b00 и нельзя пересечься с resident (если мы в pgtrdosfs)
        ld e,7
        OS_CLS
        ;если сделать SETGFX, то после введения терминалов появится лишний терминал под idle
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        push hl
        OS_DELPAGE
        pop hl
        push hl
        ld e,h
        OS_DELPAGE
        pop hl
        ld e,l
        OS_DELPAGE
        ld e,'A'
mountdrives0
        push de
        ld a,e
        ld (tdrivemounted_drive),a
        OS_MOUNT
        or a
        jr nz,.mnt_fail
        ld hl,tdrivemounted
        call prtext
        pop de
		jr .mnt_next
.mnt_fail
        pop de
		cp 13 		;There is no valid FAT volume on the physical drive
		jr z,.mnt_next
		cp 10 		;The physical drive is write protected
		jr z,.mnt_next
		ld a,e
		cp 'M'
		jr nc,.mnt_next
		dec a
		or %00000011	;Next drive
		inc a
		ld e,a
.mnt_next
        inc e
        ld a,e
        cp 'P'
        jr nz,mountdrives0
		
idle_runcmd
        OS_SETSYSDRV

        ld de,cmd_filename
        OS_OPENHANDLE
        or a
        jr nz,execcmd_error
        ld a,b
        ld (curhandle),a
        
        ld hl,tcmdloading
        call prtext
        
        OS_NEWAPP
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
        push bc ;b=id

        ld a,d
        SETPG32KHIGH
        push de
        push hl
        ld hl,cmdbuf
        ld de,0xc080
        ld bc,128  
        ldir ;command line
        pop hl
        pop de

        call readfile_pages_dehl

        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE

        pop af ;id
        ld e,a
        OS_RUNAPP
        
;понизить приоритет себе
        ld e,1
        OS_FREEZEAPP
        
idleloop
        ;ld a,1
        ;out (0xfe),a
        
        ld a,0xfe
        in a,(0xfe)
        bit 3,a ;'c'
        jr nz,idleloop
        ld a,0x7f
        in a,(0xfe)
        bit 2,a ;'m'
        jr nz,idleloop
        ld a,0xfd
        in a,(0xfe)
        bit 2,a ;'d'
        jr nz,idleloop
        ld e,7
        OS_CLS
        ;jr $
        jp idle_runcmd

execcmd_error
        ld hl,tcmdnotfound
        call prtext
        jr idleloop

tcmdnotfound
        db "cmd.com not found",0x0d,0x0a,0
tcmdloading
        db "loading cmd.com",0x0d,0x0a,0
tdrivemounted
        db "Drive "
tdrivemounted_drive
        db "N mounted",0x0d,0x0a,0

cmdbuf
        ;db "cmd autoexec.bat",0
        db "autoexec.bat autoexec.bat",0 ;чтобы потом входить в интерактивный режим (cmd проверяет первое слово), иначе придётся прописать в autoexec.bat команду cmd и иметь две задачи cmd (одну висящую в ожидании другого cmd)
        
prtext
prtext0
        ld a,(hl)
        or a
        ret z
        push hl
        PRCHAR ;testing (351/352t) (was 986/987t)
        pop hl
        inc hl
        jr prtext0

        
        
readfile_pages_dehl
        ld a,d
        SETPG32KHIGH
        ld a,0xc100/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,e
        SETPG32KHIGH
        ld a,0xc000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,h
        SETPG32KHIGH
        ld a,0xc000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,l
        SETPG32KHIGH
        ld a,0xc000/256

cmd_loadpage
;out: a=error
;keeps hl,de
        push de
        push hl
        ld d,a
        xor a
        ld l,a
        ld e,a
        sub d
        ld h,a ;de=buffer, hl=size
curhandle=$+1
        ld b,0
        OS_READHANDLE
        pop hl
        pop de
        ret

cmd_filename
        db "cmd.com"
stack
        ds 64
endstack
