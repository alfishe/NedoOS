;не включаем gfxmode, чтобы idle никогда не получал фокус
;по умолчанию стоит текстмод
        ld sp,0x4000 ;нельзя ниже 0x3b00 и нельзя пересечься с resident (если мы в pgtrdosfs)
        ld e,7
        OS_CLS
        ;если сделать SETGFX, то после введения терминалов появится лишний терминал под idle
        if atm==1
        ld a,(0x0086)
        inc a
        jr nz,.valid_ers_version
        ld hl,.ers_err_str
        call prtext
        di
        halt
.ers_err_str
        defb "You need update ERS to version 0.58.12 or newer!\r\nhttp://zxevo.ru/zxevo.rom",0x00
.valid_ers_version
        endif
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
		
		if atm==1
;заставка
		ld hl,spr_cat
logo_loop
		push hl
        ld hl,spr_str
        call prtext
		pop hl
		ld b,16
logo_loop1
		ld a,(hl)
		inc hl
		cp 0xff
		ld c,a
		jr z,logo_end
logo_pix_loop
		ld a,0xdb
		sla c
		jr c,logo_no_pix
		ld a,' '
logo_no_pix
		push hl
		push bc
		push af
		PRCHAR
		pop af
		PRCHAR
		pop bc
		pop hl
		dec b
		ld a,b
		cp 8
		jr z,logo_loop1
		or a
		jr nz,logo_pix_loop
		jr logo_loop
		
spr_cat
	defb %00100000, %00000100
	defb %00110000, %00001100
	defb %00111011, %11011100
	defb %00111111, %11111100
	defb %01100011, %11000110
	defb %01110001, %10001110
	defb %00111111, %11111100
	defb %00001111, %11110000
	defb %00000011, %11000000
	defb %00000000, %00000000
	defb %00000001, %10000000
	defb %00000001, %10000000
	defb %00000011, %11000000
	defb %00000011, %11000000
	defb %00000011, %11000000
	defb %00000111, %11100000
	defb %00001111, %11110000
	defb %00001111, %11110000
	defb %00000111, %11100000
	defb %00011111, %11111000
	defb %00111111, %11111100
	defb 0xff
spr_str
        db "\r\n                        ",0
logo_end	
		ld de,0
		OS_SETXY
		endif
		
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
        ;ld de,tpipename
        ;push de
        ;OS_OPENHANDLE
        ;ld a,b
        ;ld (pipe1handle),a
        ;pop de
        ;OS_OPENHANDLE
        ;ld a,b
        ;ld (pipe2handle),a

        OS_SETSYSDRV

        ld hl,tcmdloading
        call prtext
        
        ;ld de,cmd_filename
        ;OS_OPENHANDLE
        ;or a
        ;jr nz,execcmd_error
        
        ;call idle_readapp ;делает CLOSE
        
        ;push af
        ;ld b,a
;pipehandles=$+1
;pipe1handle=$+1
;pipe2handle=$+2
         ;ld de,0
         ;ld h,0xff ;rnd
;b=id, e=stdin, d=stdout, h=stderr        
        ;OS_SETSTDINOUT
        
        ;pop af ;id
        ;ld e,a
        ;OS_RUNAPP


        ld de,term_filename
        OS_OPENHANDLE
        or a
        jr nz,execcmd_error
        
        call idle_readapp ;делает CLOSE
        
         ;push af
         ;ld b,a
         ;ld hl,(pipehandles)
         ;ld d,l
         ;ld e,h
         ;ld h,0xff ;rnd
;b=id, e=stdin, d=stdout, h=stderr        
         ;OS_SETSTDINOUT
         ;pop af ;id

        ld e,a
        ;jr $
        OS_RUNAPP
        
;понизить приоритет себе
        ld e,1
        OS_FREEZEAPP
        
idleloop
		if atm != 1
        halt ;читаем клавиатуру не слишком часто
		endif
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

idle_readapp
        ld a,b
        ld (curhandle),a
        
        OS_NEWAPP ;для первой создаваемой задачи будут созданы первые два пайпа и подключены
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
        ret

tcmdnotfound
        db "term.com not found",0x0d,0x0a,0
tcmdloading
        db "loading term.com",0x0d,0x0a,0
tdrivemounted
        db "Drive "
tdrivemounted_drive
        db "N mounted",0x0d,0x0a,0

cmdbuf
        db "term.com cmd.com autoexec.bat",0 ;чтобы потом входить в интерактивный режим (cmd проверяет первое слово), иначе придётся прописать в autoexec.bat команду cmd и иметь две задачи cmd (одну висящую в ожидании другого cmd)
        
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
        ret nz        
        ld a,e
        call cmd_loadfullpage
        ret nz
        ld a,h
        call cmd_loadfullpage
        ret nz
        ld a,l
cmd_loadfullpage
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
        or a
        ret

term_filename
        db "term.com",0
;cmd_filename
;        db "cmd.com" ;0 в конце подразумевается
stack
        ds 64
endstack
