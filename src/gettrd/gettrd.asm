        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

MAXCMDSZ=COMMANDLINE_sz-1;127 ;не считая терминатора
filebuf=0xc000
filebufsz=0x4000;512
TRDSIZE=655360

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        ;OS_HIDEFROMPARENT

         ld a,0 ;EGA
         OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+128=keep gfx ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode) 
         ld e,0
         OS_CLS

        if 1
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
        endif

        ld hl,tpgs
        ld b,TRDSIZE/0x4000
getpgs
        push bc
        push hl
        OS_NEWPAGE
        pop hl
        ld (hl),e
        inc hl
        pop bc
        djnz getpgs

        ld hl,COMMANDLINE ;command line
;command line = "print <file>"
        ld de,wordbuf
        call skipword
        ld a,(hl)
        or a
        jr z,nofilename
        call skipspaces
        ld de,wordbuf
        call getword
nofilename
        ld de,wordbuf
        OS_CREATEHANDLE
        or a
        jp nz,errorquit
        push bc
        ld a,b
        ld (filehandle),a

        ;call dosoff

;Пример настройки контроллера на скорость обмена 9600 бод из режима BASIC-48:
;10 LET register = 3: LET value = 128: GO SUB 1000
;20 LET register = 0: LET value = 12: GO SUB 1000
;30 LET register = 1: LET value =0: GO SUB 1000
;40 LET register = 3: LET value = 3: GOSUB 1000
        ld bc,#fbef ;RS232_LINE_CTRL
        in a,(c)
        or 128
        out (c),a
        ld bc,#f8ef ;RS232_DIV_L
        ld a,2;12 ;115200/2 (иначе не успеет)
        out (c),a
        ld bc,#f9ef ;RS232_DIV_H
        ld a,0 ;+128 native ZXEvo mode
        out (c),a
        ld bc,#fbef ;RS232_LINE_CTRL
        ld a,3
        out (c),a
	ld bc,0xFAEF;UART_FCR	;сбрасываем буферы
	ld a,7
	out (c),a

        ;call doson

        di
        ld hl,TRDSIZE&0xffff
        ld de,TRDSIZE/65536
readloop0
;dehl=remaining size
        ld bc,filebufsz
       push de ;remaining size HSW
       push hl ;remaining size
        ld a,d
        or e
        jr nz,readloop_fullsize
        sbc hl,bc
        add hl,bc
        jr c,readloop_tailsize ;dehl < bc
readloop_fullsize
        ld h,b
        ld l,c
readloop_tailsize
       push hl ;size to read
        call readtomem;file
       pop bc ;size to read
       pop hl ;remaining size
       pop de ;remaining size HSW
        or a
        sbc hl,bc
        jr nc,$+3
        dec de
        ld a,d
        or e
        or h
        or l
        jr nz,readloop0
        ei

        ld hl,TRDSIZE&0xffff
        ld de,TRDSIZE/65536
saveloop0
;dehl=remaining size
        ld bc,filebufsz
       push de ;remaining size HSW
       push hl ;remaining size
        ld a,d
        or e
        jr nz,saveloop_fullsize
        sbc hl,bc
        add hl,bc
        jr c,saveloop_tailsize ;dehl < bc
saveloop_fullsize
        ld h,b
        ld l,c
saveloop_tailsize
       push hl ;size to read
        call savetofile
       pop bc ;size to read
       pop hl ;remaining size
       pop de ;remaining size HSW
        or a
        sbc hl,bc
        jr nc,$+3
        dec de
        ld a,d
        or e
        or h
        or l
        jr nz,saveloop0
        
        pop bc
        OS_CLOSEHANDLE
       ld hl,0
        QUIT
errorquit
       ld l,a
       ld h,0
        QUIT

readtomem;file
;hl=size
        push hl
        ;call dosoff
        
readtomem_tpgspointer=$+1
        ld hl,tpgs
        ld a,(hl)
        SETPGC000
        inc hl
        ld (readtomem_tpgspointer),hl
        
        pop hl

        ld de,filebuf
        
       push hl
readtofile0        
        ;push de
        ;push hl
        ;YIELDGETKEYLOOP
        ld bc,#fdef ;состояние приёмопередатчика
readbyte0
        in a,(c) ;Устанавливается в "1" при успешном приеме данных
        and 1
        jr z,readbyte0
        ld bc,#f8ef ;регистр данных
        in a,(c)

        ;pop hl
        ;pop de
        ld (de),a
        inc de
        dec hl
        ld a,h
        or l
        jp nz,readtofile0

        ;call doson

       pop hl ;size
        ret

savetofile
       push hl ;size
savetofile_tpgspointer=$+1
        ld hl,tpgs
        ld a,(hl)
        SETPGC000
        inc hl
        ld (savetofile_tpgspointer),hl
       pop hl ;size
        
        ld de,filebuf
filehandle=$+1
        ld b,0
        OS_WRITEHANDLE
        ret
        
dosoff
        ;ld a,0xa8 ;turbo
        ;ld bc,0xff77
        ;out (c),a
        ret
doson
        ;ld a,1+32
        ;out (0xbf),a
        ;ld a,0xa8 ;turbo
        ;ld bc,0xbd77
        ;out (c),a
        ;ld a,0+32 ;ATM3 pal
        ;out (0xbf),a
        ret
        
getword
;hl=string
;de=wordbuf
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        jr z,getwordq
        sub ' '
        jr z,getwordq
        ldi
        jp getword0
getwordq
        ;xor a
        ld (de),a
        ret

skipword
;hl=string
;out: hl=terminator/space addr
skipword0
        ld a,(hl)
        or a
        ret z
        sub ' '
        ret z
        inc hl
        jp skipword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

wordbuf
        db "file.trd"
        ds MAXCMDSZ+1 -8

cmd_end

        align 256
tpgs
        ds 64

;filebuf
;        ds filebufsz



	savebin "gettrd.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "..\..\us\user.l",1
