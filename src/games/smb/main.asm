        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

Z80=1
Z80ATTR=1
Z80OPT=1 ;не влияет?
Z80OPT2=1 ;не влияет?
Z80OPT2bug=1 ;при 1 черепахи не сталкиваются друг об друга (там записана дема в 3-3, TODO переделать дему) - в релизе включать не надо!!!
Z80OPT2a=1 ;не влияет?
Z80OPT3=1 ;распаковка карты  - не влияет?
Z80OPT3ly=1 ;не влияет?
Z80OPT3hy=1 ;не влияет?
Z80OPT3hybug=1 ;при 1 не падает в первую яму в 1-4, а должен (задержка старта уровня на несколько фреймов, а карта та же) - в релизе включать не надо!!!
Z80OPT4=1 ;вывод распакованной карты - не влияет?

Z80MARIOCOLOR=1
Z80BGCOLOR=1
Z80MARIOCYCLECOLOR=1
Z80COINCYCLECOLOR=1

INFINITELIVES=1
NOPIRANHAPLANT=0 ;нет кактуса
GOODPIRANHAPLANT=1 ;кактус и плевок лавы не убивают (для демы)
GOODBULLET=0 ;пуля не убивает (не помогает для демы 8-2 при MULTITASKING)
ALWAYSPRINCESS=0;1 ;no mushroom retainer (Toad), princess in every level-4

FASTDEMOBEFOREBREAKPOINT=0;1 ;(без костыля влияет на прохождение 1-2 при MUSICONINT=1) до брякпоинта в деме (прописывается как reset, т.е. вторая клеточка) реже работает видеоконтроллер
;при запуске грузится дема antipac.fm2 - если её нет, то включается режим записи
;кнопки: стрелки, a="A", s="B", Enter="START", Space="SELECT"
;Esc (Break, Caps Shift + Space) - выход в OS
;C=продолжить показ демы после брякпоинта
;D=прервать показ демы (включается запись с клавиатуры с этого же места)
;V=записать на диск текущее записанное demo.fb2 (добавленные строчки с плюсиками)
;демы пишем так:
;- ставим в текущую дему в нужном месте брякпоинт (|.r|)
;запускаем с FASTDEMOBEFOREBREAKPOINT=1
;когда появляется изображение, жмём D, играем
;после ошибки жмём V (сохранение)
;экстрактим demo.fm2
;ищем строчку с |.r|
;исправляем следующую строчку на пустую? (сейчас вроде и так пустая)
;копируем из demo.fm2 то, что после |.r| до ошибки, в текущую дему, строчку с |.r| вообще стираем (она не участвует в таймингах игры)

        ;include "6502.asm"
        include "6502fast.asm"

RESTOREPG16K=1
MUSIC=1
MUSICONINT=0;1

OSCALLS=0
MULTITASKING=1 ;при MUSICONINT=1 влияет на прохождение 8-2 в деме (место облома зависит от числа тактов!), даже костыль мало помогает, приходится делать GOODBULLET
	;display "OSCALLS=",OSCALLS

SWEEP=0

DEMO=1

STACK=0x4000
INTSTACK=0x3f00
scrbase=0x8000

scrwid=320
scrhgt=200
;title safe area 224x192 (не видно 3 верхних знакоместа)
;добавим внизу ещё 8 пикс. под ямы
YSKIPFROMTOP=2;3

;font=0x4000+0x2000 ;TODO

COMPACTDATA=0 ;1 портит память после прерывания демы
SCRATCHPAD=0x100 ;в оригинале 0x000

ENDLINETILE=0xff;10+('J'-'A');0xff ;letter 'J' unused
EMPTYTILE=0x24 ;там и было в оригинале
FASTEMPTYTILES=1

        org PROGSTART
begin

        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        ld (codepage4000),a
        ld a,h
        ld (codepage8000),a
        ld a,l
        ld (codepagec000),a
        OS_NEWPAGE
        ld a,e
        ld (tilepage),a
        OS_NEWPAGE
        ld a,e
        ld (spritepage),a
        OS_NEWPAGE
        ld a,e
        ld (spritepagemirver),a
        OS_NEWPAGE
        ld a,e
        ld (spritepagemirhor),a
        OS_NEWPAGE
        ld a,e
        ld (spritepagemirhorver),a
        OS_NEWPAGE
        ld a,e
        ld (pgtileprocL),a
        OS_NEWPAGE
        ld a,e
        ld (pgtileprocR),a
        OS_NEWPAGE
        ld a,e
        ld (pgaddrstack),a
        OS_NEWPAGE
        ld a,e
        ld (pgaddrstackcopy),a
        
        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,e
        ld (setpgs_scr_low),a
	xor l
        ld (setpgs_scr_low_xor),a
        ld a,d
        ld (setpgs_scr_high),a
	xor h
        ld (setpgs_scr_high_xor),a

	ld de,gfxfilename
        call openstream_file
        or a
	jp nz,noloadgfx
;skip 0x8010 bytes
        ld de,0
        ld hl,0x8010
        ;dehl=shift
        ld a,(filehandle)
        ld b,a
        OS_SEEKHANDLE
	ld de,tilegfx
	ld hl,0x2000
;DE = Buffer address, HL = Number of bytes to read
        call readstream_file
        call closestream_file
        
        ld hl,0x2000+TitleScreenDataOffset
        ld de,TitleScreen
        ld bc,TitleScreenDataSize
        ldir

        call copytilesgfx
        
        ld a,(tilepage)
        SETPG16K ;stack in 0xfffx
	call recodetiles
	
        ld a,(spritepage)
        SETPG16K ;stack in 0xfffx
	call recodesprites
	
	call mirspritesver

        ld a,(spritepagemirver)
        SETPG16K ;stack in 0xfffx
	call recodesprites
	
	call mirspriteshor

        ld a,(spritepagemirhorver)
        SETPG16K ;stack in 0xfffx
	call recodesprites
	
	call mirspritesver

	ld a,(spritepagemirhor)
	SETPG16K
	call recodesprites
	
;result in 0x4000: 32bytes/tile
        
        ld sp,STACK
	
	
	ld de,filename
        call openstream_file
        or a
	jr nz,noloaddemo
	
        ld hl,0
        ld de,0
nvview_load0
        push de
        push hl
        call reservepage
        pop hl
        pop de
        ret nz ;no memory
        push de
        push hl
	ld de,0xc000
	ld hl,0x4000
;DE = Buffer address, HL = Number of bytes to read
	push hl
        call readstream_file
;hl=loaded bytes
	ld b,h
	ld c,l
	pop hl ;Number of bytes to read
	or a
	sbc hl,bc ;z=loaded as requested
;bc=loaded bytes
	pop hl
	pop de
;hlde=size
;z=loaded as requested
        ex de,hl
        add hl,bc
        ex de,hl
        jr nc,$+3
        inc hl
        jr z,nvview_load0
;hlde=true file size (for TRDOSFS)
        ;ld (fcb+FCB_FSIZE),de
        ;ld (fcb+FCB_FSIZE+2),hl

        call closestream_file

	jr loaddemoq
noloaddemo
	call demooff
loaddemoq
	
	
	
	call gentileproc_all
	call genaddrstack

	call shutay

	ld e,13
	ld bc,0xfffd
	out (c),e
	ld a,0x08 ;sawtooth
	ld b,0xbf
	out (c),a

        ld de,mariopal
        OS_SETPAL
        ;OS_GETTIMER ;hlde=timer
        ;ld (oldtimer),de
	YIELD ;иначе палитра не установится
        
        call setpgs_code
        call swapimer
	
        jp Start

mirspriteshor
	ld hl,0x2000
	ld bc,0x1000
mirspriteshor0
	ld e,(hl)
	ld a,1
mirspriteshor00
	rr e
	rla
	jr nc,mirspriteshor00
	ld (hl),a
	cpi
	jp pe,mirspriteshor0
	ret
	
mirspritesver
        ld de,0x2000
;sprite gfx: 256 tiles *2 (high, low bitchars)
mirspritesver0
	ld h,d
	ld l,e
	ld bc,4
	add hl,bc
	add hl,bc
	push hl
mirspritesver00
        dec hl
        ld a,(de)
        ldi
        dec hl
        ld (hl),a
        jp pe,mirspritesver00
	pop de
	bit 4,d ;<0x3000
        jr z,mirspritesver0
	ret
	
recodesprites
        ld hl,0x2000
        ld de,0x4000
;sprite gfx: 256 tiles
        ld hy,_K;_1 ;_3 too dark
        ld hx,0 ;256
recodesprites0
	push hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld l,h ;номер тайла
        ld h,tileattr/256+1
        ld a,(hl) ;номер палитры
        ld hy,a
        pop hl
        call recodesprite
        dec hx;bit 6,h ;<0x4000
        jr nz,recodesprites0
	ret

recodetiles
        ld hl,0x3000
        ld de,0x6000
;tile gfx: 256-tiles
        ld hx,0 ;256
recodetiles0
	push hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld l,h ;номер тайла
        ld h,tileattr/256
        ld a,(hl) ;_0.._3 номер палитры
        ld hy,a
        pop hl
        call recodetile
        dec hx;bit 6,h ;<0x4000
        jr nz,recodetiles0
	ret

recodetile
;16bytes/tile: 8bytes low bit, 8bytes high bit
        ld lx,8
recodetile0
        ld c,(hl) ;low bits
        set 3,l
        ld b,(hl) ;high bits
        res 3,l
        inc l
;c=high gfx byte
;b=low gfx byte
;hy=_0.._3 номер палитры
;de=to
	push hl
	 ld h,ttilepalrecode/256
recodetilebyte0
;сдвигом имеем номер цвета a=0..3
;складываем с номером палитры - получаем левый цвет
;так же получаем правый цвет
;пересчитываем в цветовой байт
	call recodetilepixel
        ld (de),a
        inc de
        ld a,e
        and 3
	jr nz,recodetilebyte0
	pop hl
        dec lx
        jr nz,recodetile0
        ld bc,8
        add hl,bc
        ret

recodesprite
;16bytes/tile: 8bytes low bit, 8bytes high bit
        ld lx,8
recodesprite0
	push de
	 ld a,d;e
	add a,3*16 ;with mask
	 ld d,a;e,a
        ld c,(hl) ;low bits
        set 3,l
        ld b,(hl) ;high bits
        res 3,l
        inc l
	push hl
	 ld h,ttilepalrecode/256
recodespritebyte0
	call recodetilepixel
	ld ly,a
	ld a,b
	or c
	rra ;right pixel mask (0=transparent)
	bit 0,a ;left pixel mask (0=transparent)
	ld a,0x00 ;skip all pixels
	jr c,$+4
	ld a,0xb8 ;keep right pixel
	jr nz,$+4
	or 0x47 ;keep left pixel
	ld (de),a ;mask
	ld a,ly
	 inc d;e
	ld (de),a ;gfx
         ld a,d;e
	sub 16+1 ;with mask
	 ld d,a;e,a
	cpl
        and 3*16 ;with mask
	jr nz,recodespritebyte0
	pop hl
	pop de
	 inc d;e
	 inc d;e ;next row
        dec lx
        jr nz,recodesprite0
	;ex de,hl
        ;ld bc,3*16 ;with mask
        ;add hl,bc
	;ex de,hl
         ld d,0x40
         inc e
        ld bc,8
        add hl,bc
        ret

recodetilepixel
;c=high gfx byte (берём два старших бита и сдвигаем)
;b=low gfx byte (берём два старших бита и сдвигаем)
;hy=_0.._3 номер палитры
;h=ttilepalrecode/256
;out: a=color byte
        xor a
        rlc c
        rla
        rlc b
        adc a,a ;a=0..3=номер цвета в палитре
	 add a,hy
	 ld l,a
	 ld a,(hl)
        ld ly,a ;%LLLLLlll
        xor a
        rlc c
        rla
        rlc b
        adc a,a ;a=0..3=номер цвета в палитре
	 add a,hy
	 ld l,a
	 ld a,(hl) ;a=%RRRRRrrr
        ;ly=%LLLLLlll
        add a,a
        add a,a
        add a,a
        ;a=%RRrrr000
        xor ly
        and %10111000
        xor ly
        ;a=%RLrrrlll
	ret

        
noaddr=0x6000 ;там можно портить 7*40+1 байт
genaddrstack
	call setpgaddrstack4000
	call genaddrstack_onepage
	call setpgaddrstackcopy4000
genaddrstack_onepage
;для scroll phase 0 стек такой:
;(scrL) 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 2
;(scrR) 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 2
;для scroll phase 1 стек такой:
;(scrR) noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 1
;(scrL) 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 2
;для scroll phase 2 стек такой:
;(scrL) noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 1
;(scrR) noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 1
;для scroll phase 3 стек такой:
;(scrR) noaddr, noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023
;(scrL) noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 1
	
;генерируем один стек на все фазы (строки лежат через 256 байт):
;noaddr, noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr, noaddr
	ld h,0x40
	ld de,0x8004
	
	ld b,25
genaddrstack_lines0
	ld l,2 ;2 spare bytes for interrupt
	push bc
	push de
	
	ld bc,noaddr
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ld b,32
genaddrstack_line0
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	set 5,d
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	res 5,d
	inc de
	djnz genaddrstack_line0
	ld bc,noaddr
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ld (hl),c
	inc hl
	ld (hl),b
	;inc hl
;выравнивание на 64*4 = 256
	inc h
	
	pop de
	ex de,hl
	ld bc,40*8
	add hl,bc
	ex de,hl
	pop bc
	djnz genaddrstack_lines0
	
	ret

copytilesgfx
        ld de,0x3000+(16*0xec) ;tile 0xec
        ld hl,copytiles_table
        ld b,copytiles_sz
copytilesgfx0
        push bc
        push hl
        ld l,(hl)
;l=tile from
;de=addr to
        ld h,3
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;*16 + 0x3000
        ld bc,16
        ldir
        pop hl
        inc hl
        pop bc
        djnz copytilesgfx0
        ld hl,0x3000+(16*0x26)
        ld de,0x3000+(16*w26)
        ld c,16
        ldir
        ld hl,0x3000+(16*0x91)
        ld de,0x3000+(16*x91)
        ld c,16
        ldir
        ld de,0x3000+(16*x92)
        ld c,16
        ldir
        ret
copytiles_table
        db 0xa0
        db 0xa1
        db 0xa2
        db 0xa3
        db 0x27
        db 0xba
        db 0xbb
        db 0x86
        db 0x87
        db 0x8a
        db 0x8b
        db 0x8e
        db 0x8f
        db 0x25
        db 0x26
        db 0x35
        db 0x36
        db 0x37 ;cloud middle
        db 0x38 ;cloud right
copytiles_sz=$-copytiles_table
        
gentileproc_all
        ld a,(tilepage)
        SETPG16K
	ld de,0x6000 ;data
	call setpgtileprocL
	call gentileproc_all_half
	ld de,0x6001 ;data
	call setpgtileprocR
gentileproc_all_half
	ld hl,0xc000 ;proc
gentileproc_all0
	push hl
	push de
	call gentileproc
	pop de
	ld hl,32
	add hl,de
	ex de,hl
	pop hl
	inc h
	ld a,h
	or 0xc0
	ld h,a
	inc l
	ld a,l
	inc a
	jr nz,gentileproc_all0
	ld (hl),0xf7 ;rst 0x30 for tile #0xff
;tile for endline = ENDLINETILE;0xff?
        ld hl,(0)
        ld (oldquitcode),hl
	ld hl,ENDLINETILE*0x0101|0xc000;0xffff
	ld (hl),0xc3 ;"jp"
	ret

gentileproc
;hl=proc
;de=data
;out: de=next data
;генерирует такое:
;pop hl ;пиксели 0..1
;dup 7
;[ld (hl),n]
;add hl,bc
;edup
;[ld (hl),n]
;pop hl ;пиксели 4..5 в той же странице (другой bit 5 и возможно +1)
;dup 7
;[ld (hl),n]
;add hl,bc
;edup
;[ld (hl),n]
;ld a,(de)
;inc e
;ld l,a
;or 0xc0
;ld h,a
;jp (hl)
	push de
	call gentileproc_bytes
	pop de
	inc de
	inc de
	call gentileproc_bytes
	push de
	ex de,hl
	ld hl,gentileproc_jpcode
	ld c,gentileproc_jpcode_sz
	ldir
        if FASTEMPTYTILES
        ld hl,premptytiles_was
        ld de,premptytiles;EMPTYTILE*257+0xc000
        ld c,premptytiles_sz
        ldir
        endif
	pop de
	ret
gentileproc_bytes
	ld (hl),0xe1 ;"pop hl"
	inc hl
	ld (gentileproc_lastnonzeroaddr),hl
	
;find most popular byte (at least 3 times), change to ld a,n:ld (hl),a
;это один из первых 6 байтов или 0 (если не найдено)
;TODO уметь находить две группы по 3 и более
	ld c,0 ;most popular byte (0=not found)
	push de
	push hl
	ex de,hl
	ld e,2 ;max times (find more than that!)
	ld b,7
gentileproc_testpopular_allbytes0
	ld a,(hl)
	push bc
	push hl
	ld d,1 ;times
gentileproc_testpopular0
	inc hl
	inc hl
	inc hl
	inc hl
	cp (hl)
	jr nz,$+3
	inc d ;times
	djnz gentileproc_testpopular0
	pop hl
	pop bc
	ld a,e ;max times
	cp d ;times
	jr nc,gentileproc_testpopular_nomax
	ld e,d ;max times = times
	ld c,(hl) ;most popular byte
gentileproc_testpopular_nomax
	inc hl
	inc hl
	inc hl
	inc hl ;try next byte
	djnz gentileproc_testpopular_allbytes0
	pop hl
	pop de
	
	ld a,c
	or a
	jr z,gentileproc_nooldbyte
	ld (hl),0x3e ;"ld a,n"
	inc hl
	ld (hl),c
	inc hl
gentileproc_nooldbyte
	
	ld b,8
gentileproc_bytes0
	ld a,(de)
	inc de
	inc de
	inc de
	inc de
	or a
	jr z,gentileproc_skipbyte
	 cp c
	 ld (hl),0x77 ;"ld (hl),a
	 jr z,gentileproc_oldbyte
	ld (hl),0x36 ;"ld (hl),n"
	inc hl
	ld (hl),a
gentileproc_oldbyte
	inc hl
	ld (gentileproc_lastnonzeroaddr),hl
gentileproc_skipbyte
	ld (hl),0x09 ;add hl,bc
	inc hl
	djnz gentileproc_bytes0
	;dec hl ;skip last add
gentileproc_lastnonzeroaddr=$+1
	ld hl,0
	ret

        if FASTEMPTYTILES
;сейчас процедура пустого тайла (0xe424) выглядит так:
        ;pop hl
        ;pop hl ;чтобы был правильный sp
        ;inc e
        ;ld a,(de)
        ;ld l,a
        ;or 0xc0
        ;ld h,a
        ;jp (hl) ;50t
;оптимизировать последовательность пустых тайлов:
;1 пустой тайл: проигрыш 54t (проигрыш 35t)
;2 пустых тайла: проигрыш 26t (выигрыш 23t)
;3 пустых тайла: выигрыш 0t (выигрыш 31t)
;>=4 пустых тайла: выигрыш 29..32t/tile
premptytiles_was
        disp EMPTYTILE*257+0xc000
premptytiles
;-24t
        ld a,l;EMPTYTILE
        ld h,d
        ld l,e ;+12t
        inc l
        cp (hl)
        jr nz,premptytilesq1
        inc l
        cp (hl)
        jr nz,premptytilesq2
        inc l
        cp (hl)
        jr nz,premptytilesq3
premptytiles0
        dup 3
        inc l
        cp (hl)
        jr nz,premptytilesq
        edup
        inc l
        cp (hl)
        jp z,premptytiles0 ;+18..21t/tile
premptytilesq
         ld a,l
         sub e
         ld e,l
         add a,a
         add a,a
         ld l,a
         ld h,0
         add hl,sp
         ld sp,hl ;48t
        ld a,(de)
        ld l,a
        or 0xc0
        ld h,a
        jp (hl)
premptytilesq3
        pop hl
        pop hl
        inc e
premptytilesq2
        pop hl
        pop hl
        inc e
premptytilesq1
        pop hl
        pop hl
        ent
gentileproc_jpcode
        inc e
        ld a,(de)
        ld l,a
        or 0xc0
        ld h,a
        jp (hl)
premptytiles_sz=$-premptytiles_was
        display "premptytiles_sz=",premptytiles_sz,"<=0x40!"
gentileproc_jpcode_sz=$-gentileproc_jpcode
        else
gentileproc_jpcode
	inc e
	ld a,(de)
	ld l,a
	or 0xc0
	ld h,a
	jp (hl)
gentileproc_jpcode_sz=$-gentileproc_jpcode
        endif


        align 256
tileattr
        include "tileattr.asm"
ttilepalrecode
	db 0,1,2,3 ;tilepal0
	db 0,4,5,6 ;tilepal1
	db 0,7,0xf8,0xf9 ;tilepal2
	db 0,0xfa,0xfb,6 ;tilepal3 ;10=тень монеты/каёмка огня, 11=яркая монета/огонь, 12=рубашка Марио (каёмка монеты бывает синяя - для неё берём цвет 6)
;цвета Марио: [1]=4 (лицо) или 13=0x3131, [2]=14=0xb1b1 (фартук красный, а может быть белый), [3]=12 (рубашка может быть коричневая и зелёная!!!)
;цвета черепахи/Lakitu: [1]=8 (белый), [2]=2 (зелёный панцирь, а может быть синий!!!) или 15=0xe3e3, [3]=13 (голова черепахи)
;цвета Goomba/жук/пушка/пуля: [1]=5 (ножка), [2]=6 (чёрный, а может быть тёмно-серый!!!), [3]=4 (шляпа)
;цвета огня: [1]=8 (белая внутренность), [2]=10 (красный), [3]=11 (жёлтый)
;цвета гриба: [1]=5 (ножка), [2]=10 (красный), [3]=13 (оранжевый)
;цветок отличается от черепахи тем, что всегда зелёная ножка
;платформа отличается от Марио стабильными цветами??? или она ближе к грибу/Goomba наверху
;наш флаг отличается от черепахи тем, что всегда красная звезда
	db 0,0xfd,0xfe,0xfc ;Mario
	db 0,0xf8,0xff,0xfd ;Koopa/Lakitu
	db 0,5,6,4 ;Goomba/жук/пушка/пуля
	db 0,0xf8,0xfa,0xfb ;огонь
	db 0,5,0xfa,0xfd ;гриб
	db 0,0xf8,2,0xfd ;цветок (всегда зелёная ножка)
	db 0,0xfb,0xf8,0xfa ;монета
	;db 0,0xfd,0xfa,4 ;платформа
	db 0,5,0xfa,0xfd ;платформа
	db 0,0xf8,0xfa,0xfd ;наш флаг (всегда красная звезда)

        ;ds 0x0200-$
	
        if COMPACTDATA
Sprite_Data=$           ;= $0200
Sprite_Y_Position=Sprite_Data     ;db 0;= $0200
;Sprite data is delayed by one scanline; you must subtract 1 from the sprite's Y coordinate before writing it here. Hide a sprite by writing any values in $EF-$FF here.
;Sprites are never displayed on the first line of the picture, and it is impossible to place a sprite partially off the top of the screen. 
Sprite_Tilenumber=Sprite_Data+1     ;db 0;= $0201
;For 8x8 sprites, this is the tile number of this sprite within the pattern table selected in bit 3 of PPUCTRL ($2000). 
;For 8x16 sprites, the PPU ignores the pattern table selection and selects a pattern table from bit 0 of this number. 
;76543210
;||||||||
;|||||||+- Bank ($0000 or $1000) of tiles
;+++++++-- Tile number of top of sprite (0 to 254; bottom half gets the next tile)
Sprite_Attributes=Sprite_Data+2     ;db 0;= $0202
;76543210
;||||||||
;||||||++- Palette (4 to 7) of sprite
;|||+++--- Unimplemented
;||+------ Priority (0: in front of background; 1: behind background)
;|+------- Flip sprite horizontally
;+-------- Flip sprite vertically
Sprite_X_Position=Sprite_Data+3     ;db 0;= $0203
;X-scroll values of $F9-FF results in parts of the sprite to be past the right edge of the screen, thus invisible. It is not possible to have a sprite partially visible on the left edge.
;Instead, left-clipping through PPUMASK ($2001) can be used to simulate this effect. 

        ds 0x0300-$
;tile buf
VRAM_Buffer1_Offset   db 0;= $0300
VRAM_Buffer1          ds 63;???;= $0301
VRAM_Buffer2_Offset   db 0;= $0340
VRAM_Buffer2          ds 0x100;TitleScreenDataSize-64;63;???;= $0341 ;следующий блок данных в $0363, но нужен буфер до 0x043a (невключительно)
       ds 0x0500-$ ;ClearBuffersDrawIcon чистит 512 байт
       endif

       ds 0x0800-$
SCRATCHPAD2=$-0x100
	ds 0x100 ;адреса SCRATCHPAD2+$01xx (сколько???)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	align 256
filepages
	ds 128

;DDp palette: %grbG11RB(low),%grbG11RB(high)
mariopalblack
castlepalette
        dw 0xffff
        dw 0xafaf,0xeded,0x7f7f ;1=средняя труба, 2=яркая труба, 3=каёмка трубы
        dw 0xecec,0x0c0c,0x1f1f ;4=яркий кирпич, 5=блик на кирпиче, 6=дверь замка=тень в кирпичах (по идее чёрные, но на 8-4 тёмно-серые)
        dw 0x3d3d,0x0c0c,0xffff ;7=вода/тень облака, 8=белый, 9=каёмка облака (чёрная)
        dw 0xfdfd,0xadad,0x3f3f ;10=тень монеты, 11=яркая монета, 12=рубашка Марио (каёмка монеты бывает синяя - для неё берём цвет 6)
        dw 0x3d3d,0xbdbd,0xefef ;13=лицо Марио/голова черепахи, 14=фартук Марио, 15=панцирь
undergroundpalette
;с чёрным фоном:			каёмка трубы	лицо	фартук	дверь замка, тень в кирпичах (по идее чёрные); рубашка Марио (по идее коричневая), шляпа злого гриба (в подземелье голубая), голова черепахи (по идее оранжевая), стебель кактуса (по идее оранжевый), лицо toad
        ;dw 0xf3f3,0xa3a3,0x6161,0x7373,0xf3f3,0x3131,0xa0a0,0xb3b3
        ;dw 0xf3f3,0x0202,0x0000,0xd3d3,0xf3f3,0xf1f1,0xa1a1,0xb3b3
				;край облака			разбитый блок с призом, край монеты
        dw 0xffff
        dw 0xafaf,0xeded,0x7f7f ;1=средняя труба, 2=яркая труба, 3=каёмка трубы
        dw 0xeeee,0x4c4c,0x5f5f ;4=яркий кирпич, 5=блик на кирпиче, 6=дверь замка=тень в кирпичах (по идее чёрные, но на 8-4 тёмно-серые)
        dw 0x0e0e,0x0c0c,0xffff ;7=вода/тень облака, 8=белый, 9=каёмка облака (чёрная)
        dw 0xfdfd,0xadad,0x3f3f ;10=тень монеты, 11=яркая монета, 12=рубашка Марио (каёмка монеты бывает синяя - для неё берём цвет 6)
        dw 0x3d3d,0xbdbd,0xefef ;13=лицо Марио/голова черепахи, 14=фартук Марио, 15=панцирь
waterpalette
        dw 0xcccc ;небо
        dw 0xafaf,0xeded,0x7f7f ;1=средняя труба, 2=яркая труба, 3=каёмка трубы
        dw 0x6f6f,0x6c6c,0xffff ;4=яркий кирпич, 5=блик на кирпиче, 6=дверь замка=тень в кирпичах (по идее чёрные, но на 8-4 тёмно-серые)
        dw 0x0e0e,0x0c0c,0xffff ;7=вода/тень облака, 8=белый/коралл???/подводная монета???, 9=каёмка облака (чёрная)
        dw 0xfdfd,0xadad,0x3f3f ;10=тень монеты, 11=яркая монета, 12=рубашка Марио (каёмка монеты бывает синяя - для неё берём цвет 6)
        dw 0x3d3d,0xbdbd,0xecec ;13=лицо Марио/голова черепахи, 14=фартук Марио, 15=панцирь/серая рыбка
mariopal
groundpalette
;с синим небом:
                          ;23           ;e3           ;e0
        ;dw 0xc0c0,0xa3a3,0x6161,0x7373,0xc0c0,0x3131,0xa0a0,0xb3b3
        ;dw 0xc0c0,0x0202,0x0000,0xd3d3,0xc0c0,0xf1f1,0xa1a1,0xb3b3
                ;вода/кусок облака
        dw 0xcccc ;небо
        dw 0xafaf,0xeded,0x7f7f ;1=средняя труба (0xe3 слишком холодно), 2=яркая труба (0x61 слишком ярко), 3=каёмка трубы
        dw 0x7d7d,0xacac,0xffff ;4=яркий кирпич (0x11 слишком ярко, 0x31 слишком насыщенно, 0x71 слишком коричнево - но в VirtualNES так), 5=блик на кирпиче, 6=дверь замка=тень в кирпичах (по идее чёрные, но на 8-4 тёмно-серые)
        dw 0x0e0e,0x0c0c,0xffff ;7=вода/тень облака, 8=белый, 9=каёмка облака (чёрная)
        dw 0xfdfd,0xadad,0x3f3f ;10=тень монеты/каёмка огня, 11=яркая монета/огонь, 12=рубашка Марио (0xb3 слишком насыщенно, каёмка монеты бывает синяя - для неё берём цвет 6)
        dw 0x3d3d,0xbdbd,0xefef ;13=лицо Марио/голова черепахи, 14=фартук Марио, 15=панцирь

;цвета Марио: [1]=4 (лицо) или 13=0x3131, [2]=14=0xb1b1 (фартук красный, а может быть белый), [3]=12 (рубашка может быть коричневая и зелёная!!!)
;цвета черепахи/Lakitu: [1]=8 (белый), [2]=2 (зелёный панцирь, а может быть синий!!!) или 15=0xe3e3, [3]=13 (голова черепахи)
;цвета Goomba/жук/пушка/пуля: [1]=5 (ножка), [2]=6 (чёрный, а может быть тёмно-серый!!!), [3]=4 (шляпа)
;цвета огня: [1]=8 (белая внутренность), [2]=10 (красный), [3]=11 (жёлтый)
;цвета рыбы: [1]=8 (белое брюшко), [2]=15 (серый), [3]=13 (розовый хвост) - как у черепахи
;цвета гриба: [1]=5 (ножка), [2]=10 (красный), [3]=13 (ярко-оранжевый)

quit
        call swapimer
	call shutay
oldquitcode=$+1
        ld hl,0
        ld (0),hl
quitquit
        QUIT

noloadgfx
        ld e,6
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
	ld e,0
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
        ld hl,tnofile
prerr0
        ld a,(hl)
        or a
        jr z,quitquit
        inc hl
        push hl
        PRCHAR
        pop hl
        jr prerr0

swapimer
	di
         if MULTITASKING
         ld hl,(0x0038+3) ;адрес intjp
         ld (intjpaddr),hl
         endif
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
        ;jr $
	ei
        ret
oldimer
        jp on_int ;заменится на код из 0x0038

        
setpgs_code
codepage4000=$+1
        ld a,0
         if RESTOREPG16K
         ld (curpg4000),a
         endif
        SETPG16K
codepage8000=$+1
        ld a,0
        SETPG32KLOW
codepagec000=$+1
        ld a,0
        SETPG32KHIGH
        ret
        
setpgs_scr
tilepage=$+1
        ld a,0
         if RESTOREPG16K
         ld (curpg4000),a
         endif
        SETPG16K
setpgs_scr_low=$+1
        ld a,0;pgscr0_0 ;scr0_0
        SETPG32KLOW
setpgs_scr_high=$+1
        ld a,0;pgscr0_1 ;scr0_1
        SETPG32KHIGH
        ret

        align 256
tytoscr
        dup 200
        db (($&0xff)*40)&0xff
        edup
        align 256
        dup 200
        db (($&0xff)*40)/256 + 0x80
        edup

	macro NEXTCOLUMN
	bit 6,h
	set 6,h
	jr z,$+2+4+2+2+1
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,$+3
	inc hl
	endm

        macro COUNTSCRADDR
        add a,(hl)
        inc h
         ld c,a
        ;ld h,(hl)
         adc a,(hl)
         sub c
       ld l,c;a
       ;ld a,b
       ;adc a,h
        ;inc h
        ;ld l,c ;x
        ;add a,(hl) ;8+7=15t, а если rra:srl a=12t, плюс выигрываем 2 команды bit
         ;inc h
         ;ld a,(hl)
         ;ld (prcharxy_jr),a ;4+7+13+12(jr) = 35t, а если bit:jr z:bit:jr z, то в среднем 16+7+12=35t тоже
        endm

	macro NEXTCOLUMNS0
        ld h,a ;.00
	push hl
	set 6,h ;.10
	push hl
	xor 0x20
	ld h,a ;.01
	push hl
	set 6,h ;.11
	endm
	macro NEXTCOLUMNS1
        ld c,a
        xor 0x40
        ld h,a ;.10
	push hl
	xor 0x60
	ld h,a ;.01
	push hl
	set 6,h ;.11
	push hl
	ld h,c ;.00
	inc hl
	endm
	macro NEXTCOLUMNS2
        ld h,a
        set 5,h ;.01
	push hl
	set 6,h ;.11
	push hl
	ld h,a ;.00
	inc hl
	push hl
	set 6,h ;.10
	endm
	macro NEXTCOLUMNS3
        ld c,a
        xor 0x60
        ld h,a ;.11
	push hl
	ld h,c ;.00
	inc hl
	push hl
	set 6,h ;.10
	push hl
         ld a,h ;нельзя старое, т.к. было inc hl
	 xor 0x60
	 ld h,a ;.01
	endm

prcharxy
;de=gfx
;la=yx
;CY=0
        ld h,tytoscr/256
       rra
       jr c,prcharxy_nextcolumns13
       rra;srl a
       jr c,prcharxy_nextcolumns2
prcharxy_nextcolumns0
        COUNTSCRADDR
	NEXTCOLUMNS0
        jp prcharxy_scrok
prcharxy_nextcolumns2
        COUNTSCRADDR
	NEXTCOLUMNS2
        jp prcharxy_scrok
prcharxy_nextcolumns13
       srl a
       jr c,prcharxy_nextcolumns3
prcharxy_nextcolumns1
        COUNTSCRADDR
	NEXTCOLUMNS1
        jp prcharxy_scrok
prcharxy_nextcolumns3
        COUNTSCRADDR
	NEXTCOLUMNS3
prcharxy_scrok

	macro SHOWBYTEBEHIND
	 inc d;e
	cp (hl) ;scr
	jr nz,$+5
	ld a,(de)
        ld (hl),a ;scr
        xor a
	 inc d;e
	endm
	macro SHOWBYTEBEHIND_LAST
	cp (hl) ;scr
	ret nz
	 inc d;e
	ld a,(de)
        ld (hl),a ;scr
        ret
	endm
        
	macro SHOWBYTE ;TODO pop de
	ex de,hl
	ld a,(de) ;scr
        and (hl) ;font
	 inc h;l
	or (hl)
	 inc h;l
        ld (de),a ;scr
	ex de,hl
	endm
	macro SHOWBYTE_LAST ;TODO pop de
	ex de,hl
	ld a,(de) ;scr
        and (hl) ;font
	 inc h;l
	or (hl)
        ld (de),a ;scr
        ret
	endm
        
        ;ld a,(de) ;font
        ;ld (hl),a ;scr
        ; inc d;e
        ;add hl,bc
        
        
;x=???432Xx
;scraddr = %1xX????? ?????432
        ld bc,40 ;TODO в зависимости от переворота
	
	bit 5,(ix+2) ;attributes.behind
	jp nz,prcharxy_behind
	
	dup 7
	SHOWBYTE
	add hl,bc
	edup
	SHOWBYTE
	
	pop hl
	dup 7
	SHOWBYTE
	add hl,bc
	edup
	SHOWBYTE
	
	pop hl
	dup 7
	SHOWBYTE
	add hl,bc
	edup
	SHOWBYTE
	
	pop hl
	dup 7
	SHOWBYTE
	add hl,bc
	edup
	SHOWBYTE_LAST
        ;ret ;там уже есть

prcharxy_behind
        xor a
	dup 7
	SHOWBYTEBEHIND
	add hl,bc
	edup
	SHOWBYTEBEHIND
	
	pop hl
	dup 7
	SHOWBYTEBEHIND
	add hl,bc
	edup
	SHOWBYTEBEHIND
	
	pop hl
	dup 7
	SHOWBYTEBEHIND
	add hl,bc
	edup
	SHOWBYTEBEHIND
	
	pop hl
	dup 7
	SHOWBYTEBEHIND
	add hl,bc
	edup
	SHOWBYTEBEHIND_LAST
        ;ret ;там уже есть

EmulatePPU
	if FASTDEMOBEFOREBREAKPOINT
	ld a,0
	sub 4
	ld ($-1-2),a
	 ;scf
	jr c,EmulatePPU_noskipgo
skipPPU=$
	ret
EmulatePPU_noskipgo	
	endif
;ждать флаг ожидания готовности экрана (включается по прерыванию)
;иначе будет так:
;фрейм 1:
;видим экран0, рисуем экран1
;фрейм 2:
;видим экран0, закончили рисовать экран1, [вот тут нужно ожидание], начали рисовать экран0 (хотя его видим)
;фрейм 3:
;видим экран1
;готовность - это когда текущий таймер != таймер конца прошлой отрисовки
;проверяем оба таймера, а то могло случиться системное прерывание
EmulatePPU_waitforscreenready0
        call gettimer
endoflastredrawtimer=$+1
        ld de,0
        or a
        sbc hl,de
        jr z,EmulatePPU_waitforscreenready0

	if OSCALLS
curpalette=$+1
        ld de,mariopal
oldpalette=$+1
	ld hl,0
	ld (oldpalette),de
	or a
	sbc hl,de
	jp z,EmulatePPU_nochpal ;реально поддержано изменение цвета Марио в палитре: при этом пишется oldpalette=левоечисло
	push de
        ;OS_GETTIMER ;hlde=timer
        ;ld (oldtimer),de ;иначе yield вылетит без ожидания прерывания
	YIELD ;иначе можем напороться на di в swapimer
	call swapimer ;делать это после YIELD, т.к. внутри di..ei
	pop de
        OS_SETPAL ;на это время восстановлен обработчик прерываний, музыка выключена (а так надо посчитать, сколько прошло прерываний по системному таймеру и добавить в игровой таймер)
	YIELD ;иначе палитра не установится
	call swapimer
	else
EmulatePPU_nochpal
	endif

        call setpgs_scr
        
	ld hl,0x8000+4+32
	call emppucls
	ld hl,0xa000+4+32
	call emppucls
	ld hl,0xc000+4+32
	call emppucls
	ld hl,0xe000+4+32
	call emppucls ;cls=173000
	
	ld hl,proc_endline
        ld (0),hl ;иначе системный обработчик прерываний успевает запортить (0x0001)
	call prtilesfast ;143700

        call setpgs_scr
        ;ld a,0x40
        ;ld (fonthsb),a
;рисуем спрайты в обратном порядке (0-й на переднем плане)
        ld ix,Sprite_Data+256-4
        ;ld b,64;8
prsprites0
        ;push bc
        ld a,(ix) ;y
         sub 8*YSKIPFROMTOP
        cp 200-8
        jp nc,prsprites_skip ;большинство спрайтовых записей пустые, можно даже проверять на ==0xf8
        ld l,a ;y

	ld a,(ix+2) ;attributes
	rla ;flip vertically ;TODO программно
spritepage=$+1
spritepagemirhor=$+2
	ld bc,0
	jr nc,$+5
spritepagemirver=$+1
spritepagemirhorver=$+2
	ld bc,0
	rla ;flip horizontally
        ld a,c;
	jr nc,$+3
        ld a,b;mirver
         if RESTOREPG16K
         ld (curpg4000),a
         endif
        SETPG16K
	
        ld a,(ix+3) ;x
	 inc a
	 jr z,prsprites_skip ;почему-то прыжки на левой границе экрана в контакте с камнем дают x=0xff TODO
	srl a
	add a,4*4
        
        ld e,(ix+1) ;tile
        ld d,0x40 ;gfx
        ;ld l,e
        ;ld h,0x40/64
        ; add hl,hl
        ; add hl,hl
        ; add hl,hl
        ; add hl,hl
        ; add hl,hl
        ; add hl,hl
        ;ex de,hl
;la=yx
;de=gfx
        call prcharxy
prsprites_skip
        ;ld bc,-4
        ;add ix,bc
        ;pop bc
        ;djnz prsprites0
        ld a,lx
        sub 4
        ld lx,a
        jp nz,prsprites0 ;0-й спрайт - край монетки, можно не выводить
        ;jp nc,prsprites0

        ld a,1
curscreen=$+1
        xor 1
        ld (curscreen),a
	if OSCALLS
        ld e,a
        OS_SETSCREEN ;фактически включится по прерыванию ;первый отобразится 0-й экран
         ld a,e
	endif
         add a,a
         add a,a
         add a,a
         ld (imer_curscreen_value),a
	 ;ld bc,0x7ffd
	 ;out (c),a

	call gettimer
        ld (endoflastredrawtimer),hl

        ld hl,setpgs_scr_low
        ld a,(hl)
setpgs_scr_low_xor=$+1
        xor 2
        ld (hl),a
        ld hl,setpgs_scr_high
        ld a,(hl)
setpgs_scr_high_xor=$+1
        xor 2
        ld (hl),a

        call setpgs_code
        ld d,0
        ld b,d
        ret        

emppucls
	ld (emppuclssp),sp
	ld de,0
	ld bc,40
	ld a,200
emppucls0
	ld sp,hl ;во время прерывания de=0
	ld (hl),e
	dup 32/2
	push de
	edup
	add hl,bc
	dec a
	jr nz,emppucls0
emppuclssp=$+1
	ld sp,0
	ret

        include "nesconst.asm"
        include "smbconst.asm"
        
TitleScreen
        ds TitleScreenDataSize

prtilesfast
	call setpgaddrstack4000
        ld hl,0x2000 + (32*YSKIPFROMTOP)
        ld de,0x4000+6 ;addrstack
	ld bc,0x0280;0x0220
	call prtilesfast0block
        
	 ld a,(Sprite0HitDetectFlag)
	 or a
         ld c,0x80
	 jr z,prtilesfastbottom ;no scroll
	
	ld a,(PPU_CTRL_REG1)
	rra
	jr nc,$+4
	set 2,h ;2nd tilemap

	ld a,(PPU_SCROLL_REG_H)
	rra
	;rra
	;rra
	and 127;31
	ld c,a ;scroll
	push hl
	 srl a
	 srl a
	add a,l
	ld l,a
;будем выводить слева 32-scroll, справа scroll знакомест
	
	push bc
	push de ;screen (addrstack)
	 ld a,c
	 and 3
	 jr z,prtilesfast_noblankleft
	 dec de
	 dec a
	 jr nz,$-3
prtilesfast_noblankleft
	ld a,128;32
	sub c
	ld c,a
        ld b,25-2
	call prtilesfast0block
	pop de ;screen (addrstack)
	pop bc ;scroll
	pop hl
	ld a,h
	xor 4
	ld h,a ;another tilemap
	;ld b,0
	ld a,128;32
	sub c
	 ;add a,a
	 ;add a,a
	add a,e
	ld e,a
	;adc a,d
	;sub e
	;ld d,a

prtilesfastbottom
        ld b,25-2
	ld a,c
	or a
        ret z
	
;для scroll phase 0 стек такой:
;(scrL) 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 2
;(scrR) 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 2
;для scroll phase 1 стек такой:
;(scrR) noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 1
;(scrL) 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 2
;для scroll phase 2 стек такой:
;(scrL) noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 1
;(scrR) noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 1
;для scroll phase 3 стек такой:
;(scrR) noaddr, noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023
;(scrL) noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr x 1
	
;генерируем один стек на все фазы (строки лежат через 256 байт):
;noaddr, noaddr, 0x8004, 0xa004, 0x8005, ... 0xa023, noaddr, noaddr
prtilesfast0block
	bit 0,e
	jr z,prtilesfast0block_even
	 res 0,e
	push bc
	push de
	push hl
	push bc
	ld a,(setpgs_scr_high)
	SETPG32KLOW
	call setpgtileprocL
	pop bc
	call prtilesfast0lines
	ld a,(setpgs_scr_low)
	SETPG32KLOW
	call setpgtileprocR
	pop hl
	pop de
	pop bc
	 inc de
	 inc de
	jp prtilesfast0lines

prtilesfast0block_even
	push bc
	push de
	push hl
	push bc
	ld a,(setpgs_scr_low)
	SETPG32KLOW
	call setpgtileprocL
	pop bc
	call prtilesfast0lines
	ld a,(setpgs_scr_high)
	SETPG32KLOW
	call setpgtileprocR
	pop hl
	pop de
	pop bc
	;call prtilesfast0
	;ret
	
;hl=tileaddr for line start
;de=addrstack
;b=hgt
;c=width ;max 128
;out: hl=tileaddr after last line, de=addrstack after last line
prtilesfast0lines
        ld hy,d
        ld ly,e ;iy=addrstack
	ld (prtilelinefast_sp),sp
	dec c
	srl c
	srl c
        inc c ;c=((width+3)/4)
	ld a,l
	add a,c ;без переноса, т.к. читаем тайлы через inc e
        ld l,a ;hl=tileaddr for line end
;hl=tileaddr for line end
;iy=addrstack
;b=hgt
;c=((width+3)/4)
        exx
	ld bc,40
        exx
	ld e,32
;a=l
        ;jr $
_prtilesfast0
        ld sp,iy ;addrstack for this line
	inc hy ;addrstack for next line
        sub c ;без переноса, т.к. читаем тайлы через inc e
        ld d,(hl) ;old tile after last tile
	ld (hl),ENDLINETILE;0xfe ;patch after last tile
        exx
        ld e,a
        exx
        ld a,h
        exx
	ld d,a ;de=tileaddr for line start
	ld a,(de)
	  ;inc e
	ld l,a
	or 0xc0
	ld h,a
	jp (hl)
proc_endline
        exx
	ld (hl),d ;unpatch after last tile
	;add hl,de ;+32 (for next tileline) ;это надо делать для адреса начала строки, а адрес конца строки перекошен по HSB
         ld a,l
         sub c
         add a,e
         jp nc,$+4
         inc h
         add a,c
         ld l,a
	djnz _prtilesfast0
prtilelinefast_sp=$+1
	ld sp,0
        ld d,hy
        ld e,ly
        sub c ;без переноса, т.к. читаем тайлы через inc e
        ld l,a ;hl=tileaddr after last line
	ret
        
setpgaddrstack4000
pgaddrstack=$+1
	ld a,0
         if RESTOREPG16K
         ld (curpg4000),a
         endif
	SETPG16K
	ret
setpgaddrstackcopy4000 ;только в ините и int
pgaddrstackcopy=$+1
	ld a,0
	SETPG16K
	ret

setpgtileprocL
pgtileprocL=$+1
	ld a,0
	SETPG32KHIGH
	ret
setpgtileprocR
pgtileprocR=$+1
	ld a,0
	SETPG32KHIGH
	ret

shutay
	ld de,0xe00
shutay0
	dec d
	ld bc,0xfffd
	out (c),d
	ld b,0xbf
	out (c),e
	jr nz,shutay0
	ret
	
	if OSCALLS==0
oldpalette=$
	dw 0
	endif
on_int
;if stack in 0x4000..0x7fff:
;restore stack from pgaddrstackcopy (set in 0x4000 temporarily, then set pgaddrstack)
;else restore stack with de;0
	ld (on_int_hl),hl
	ld (on_int_sp),sp
	ld (on_int_spcopy),sp
	pop hl
	ld (on_int_sp2),sp
        ld (on_int_jp),hl
	
	ld sp,INTSTACK
	
	push af
	push bc
	push de
	
imer_curscreen_value=$+1
         ld a,0
         ld bc,0x7ffd
         out (c),a

	ld a,(on_int_sp+1)
	sub 0x40
	cp 0x3f ;запас, чтобы не захватить очистку экрана в 0x8000
	ex de,hl;ld hl,0
	jr nc,on_int_norestoredata
	;jr $
	ld a,(pgaddrstackcopy)
	SETPG16K
on_int_spcopy=$+1
	ld hl,(0)
        ;if RESTOREPG16K==0
	ld a,(pgaddrstack)
	SETPG16K
        ;endif
on_int_norestoredata
on_int_sp=$+1
	ld (0),hl ;восстановили запоротый стек

        if MULTITASKING
        ld hl,on_int_q
intjpaddr=$+1
	ld (0),hl
        push ix
        push iy
        ex af,af'
        exx
        push af
        push bc
        push de
        push hl
        ld a,(curscreen)
        ld e,a
        OS_SETSCREEN ;вызываем здесь, а не в рандомном месте, иначе даже с одной задачей можем получить непредсказуемую задержку, которую не фиксирует наш таймер? с несколькими задачами надо учитывать и системный - TODO
curpalette=$+1
        ld de,mariopal
        OS_SETPAL
        pop hl
        pop de
        pop bc
        pop af
        exx
        ex af,af'
        pop iy
        pop ix
        endif
        
	if MULTITASKING==0 ;OSCALLS==0
curpalette=$+1
        ld de,mariopal
        ld hl,31
        add hl,de
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

	ld hl,(curtimer)
	inc hl
	ld (curtimer),hl

	if MUSIC
        if MUSICONINT
        ld a,(codepage4000)
        SETPG16K
        ld b,0
        ld d,b
soundenginecall=$
	call SoundEngine
        endif

	ld c,0xfd

	if SWEEP
;$4001(sq1)/$4005(sq2) bits
;--------------------------
;0-2	right shift amount
;3	decrease / increase (1/0) wavelength
;4-6	sweep update rate ;frequency at which $4002/3 is updated with the new calculated wavelength. The refresh rate frequency is 120Hz/(N+1), where N is the value written
;7	sweep enable 
sweep1=$+1
        ld de,0 ;сколько бит в этом счётчике??? будем считать, что 8
        ld a,(SND_SQUARE1_REG+1)
        rra
        rra
        rra
        rra
        and 7 ;sweep rate
        inc a
        ld b,a
sweep1counter=$+1
        ld a,0
        sub 2 ;2 "sound frames"
        jr nc,$+3
        add a,b ;sweep rate
        ld (sweep1counter),a
        jr nc,sweep1noinc
        inc e
        ld (sweep1),de
sweep1noinc
        ld a,(SND_SQUARE1_REG+1)
        and 7 ;right shift
        jr z,sweep1noshift
        ld b,a
sweep1shift0
        srl e
        djnz sweep1shift0
sweep1noshift
	endif

	ld hl,SND_SQUARE1_REG+3
	ld a,(hl)
        dec hl
        ld l,(hl)
	and 7
        ld h,a
	
	if SWEEP
        ld a,(SND_SQUARE1_REG+1)
        or a
        jp p,sweep1disabled
;add/sub sweep:
         scf ;for sq1 only!
        sbc hl,de
        and 8
        jr nz,$+5 ;decrease wavelength
         inc hl ;for sq1 only!
         add hl,de
         add hl,de ;increase wavelength
sweep1disabled
	endif

	ld a,1
	ld b,0xff
	out (c),a
	ld b,0xbf
	out (c),h
	dec a
	ld b,0xff
	out (c),a
	ld b,0xbf
	out (c),l

	if SWEEP
sweep2=$+1
        ld de,0 ;сколько бит в этом счётчике??? будем считать, что 8
        ld a,(SND_SQUARE2_REG+1)
        rra
        rra
        rra
        rra
        and 7 ;sweep rate
        inc a
        ld b,a
sweep2counter=$+1
        ld a,0
        sub 2 ;2 "sound frames"
        jr nc,$+3
        add a,b ;sweep rate
        ld (sweep2counter),a
        jr nc,sweep2noinc
        inc e
        ld (sweep2),de
sweep2noinc
        ld a,(SND_SQUARE2_REG+1)
        and 7 ;right shift
        jr z,sweep2noshift
        ld b,a
sweep2shift0
        srl e
        djnz sweep2shift0
sweep2noshift
	endif
	
	ld hl,SND_SQUARE2_REG+3
	ld a,(hl)
        dec hl
        ld l,(hl)
	and 7
        ld h,a
	
	if SWEEP
        ld a,(SND_SQUARE2_REG+1)
        or a
        jp p,sweep2disabled
;add/sub sweep:
        sbc hl,de
        ld a,(SND_SQUARE2_REG+1)
        and 8
        jr nz,$+4 ;decrease wavelength
         add hl,de
         add hl,de ;increase wavelength
sweep2disabled
	endif

	ld a,5
	ld b,0xff
	out (c),a
	ld b,0xbf
	out (c),h
	dec a
	ld b,0xff
	out (c),a
	ld b,0xbf
	out (c),l

	ld d,0x0f ;all channels enabled
	
	ld a,11
	ld b,0xff
	out (c),a
	ld hl,SND_TRIANGLE_REG+3
	ld a,(hl)
	and 7
	dec hl
	ld e,(hl)
	 sla e
	 adc a,a
	 jr z,$+2+2+2 ;иначе немного фальшивят верхние ноты в басу
	  srl a
	  rr e
	 srl a
	 rr e
	 ld hl,curtimer
	 bit 0,(hl)
	 jr z,$+3
	 inc e ;уседняем фальшь по 2 прерываниям
	 srl a
	 rr e
	 jr nz,$+4
	 res 1,d ;disable triangle if freq=0
	ld b,0xbf
	out (c),e
	;ld e,12;3
	;ld b,0xff
	;out (c),e
	;ld b,0xbf
	;out (c),a

	ld a,6
	ld b,0xff
	out (c),a
	ld a,(SND_NOISE_REG+2)
	add a,a
	ld b,0xbf
	out (c),a

;counters
	ld a,(SND_TRIANGLE_REG)
	or a
	jp m,trianglecount
;linear counter load, stop length counter
        ;and 0x7f
        ld (trianglelinearcounter),a
        ;jp trianglehalt
trianglecount
trianglelinearcounter=$+1
        ld a,0
	sub 4
	jr nc,$+3
	 xor a
	ld (trianglelinearcounter),a ;ld (SND_TRIANGLE_REG),a
	jr nz,$+4
        res 1,d ;triangle disabled because of linear counter=0
	ld a,(SND_COUNTER+8) ;(SND_TRIANGLE_REG+3) ;counter register, load it = f(SND_TRIANGLE_REG+3) at write there
	sub 1;2
	jr nc,$+3
	xor a
	ld (SND_COUNTER+8),a ;(SND_TRIANGLE_REG+3),a
	jr nz,$+4
        res 1,d ;triangle disabled because of counter=0
trianglehalt

	ld a,(SND_SQUARE2_REG)
	bit 5,a
	jp nz,square2halt ;counter disable
	ld a,(SND_COUNTER+4) ;(SND_SQUARE2_REG+3) ;counter register, load it = f(SND_SQUARE2_REG+3) at write there
	sub 1;2
	jr nc,$+3
	xor a
	ld (SND_COUNTER+4),a ;(SND_SQUARE2_REG+3),a
	jr nz,$+4
        res 2,d ;disabled because of counter=0
square2halt

	ld a,(SND_SQUARE1_REG)
	bit 5,a
	jp nz,square1halt ;counter disable
	ld a,(SND_COUNTER+0) ;(SND_SQUARE1_REG+3) ;counter register, load it = f(SND_SQUARE2_REG+1) at write there
	sub 1;2
	jr nc,$+3
	xor a
	ld (SND_COUNTER+0),a ;(SND_SQUARE1_REG+3),a
	jr nz,$+4
        res 0,d ;disabled because of counter=0
square1halt

	ld a,(SND_NOISE_REG)
	bit 5,a
	jp nz,noisehalt ;counter disable
	ld a,(SND_COUNTER+12) ;(SND_SQUARE1_REG+3) ;counter register, load it = f(SND_SQUARE2_REG+1) at write there
	sub 16;1;2
	jr nc,$+3
	xor a
	ld (SND_COUNTER+12),a ;(SND_SQUARE1_REG+3),a
	jr nz,$+4
        res 3,d ;disabled because of counter=0
noisehalt

;channel enable
	ld a,7
	ld b,0xff
	out (c),a
	ld hl,SND_MASTERCTRL_REG ;%???DNT21
	ld a,(hl)
       if 1==1
        add a,0x2 ;%00? -> %01? (bit 2 reset), %11? -> %00? (bit 2 reset)
        and 0x4 ;was %00? or %11? - no swap
        ld a,(hl)
        jr z,noswap21 ;bit 2 reset - no swap
        xor 0x6 ;swap %01? <-> %10?
noswap21
       else
	rra ;%??????T?
	xor (hl)
	and 0x02
	xor (hl) ;%???DNTT1
	and 0xfb ;%???DN0T1
	bit 1,(hl)
	jr z,$+4
	or 0x04  ;%???DN2T1
       endif
       ;or 8 ;noise
	and d
	ld d,a
	cpl
	;and 7
	 and 5 ;enable B (тихая огибающая) ;or 2 ;disable triangle(B) here
	or 0x38 ;disable noise
	 bit 3,d
	 jr z,$+2+2+2
	 set 1,a ;disable tone in B
	 res 4,a ;enable noise in B
	ld b,0xbf
	out (c),a

;Only a write out to $4003/$4007/$400F will reset the current envelope decay counter to a known state (to $F, the maximum volume level) for the appropriate channel's envelope decay hardware.
;Otherwise, the envelope decay counter is always counting down (by 1) at the frequency currently contained in the volume / envelope decay rate bits (even when envelope decays are disabled (setting bit 4)), except when the envelope decay counter contains a value of 0, and envelope decay looping (bit 5) is disabled (0). 
;vol
	ld e,8
	ld b,0xff
	out (c),e
	ld a,(SND_SQUARE1_REG) ;bit4=constant volume, or else envelope
        bit 4,a
        jr nz,vol1const
        ld a,(SND_DECAYVOL+0)
vol1const
	and 15
        ld hl,tvolume
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld l,(hl)
	ld b,0xbf
	out (c),l
        
        ld hl,SND_SQUARE1_REG
        ld a,(hl)
        and 15 ;decay rate
        inc a
        ld b,a
vol1decaycounter=$+1
        ld a,0
        sub 4 ;4 "sound frames"
        jr nc,$+3
        add a,b ;decay rate
        ld (vol1decaycounter),a
        jr nc,vol1nodecay
	 ld a,(SND_DECAYVOL+0)
         dec a
        jp p,vol1noenddecay
         and 0xf
        bit 5,(hl)
        jr nz,vol1noenddecay ;decay looping enabled
         xor a
vol1noenddecay
	 ld (SND_DECAYVOL+0),a
vol1nodecay

	ld e,10
	ld b,0xff
	out (c),e
	ld a,(SND_SQUARE2_REG) ;bit4=constant volume, or else envelope
        bit 4,a
        jr nz,vol2const
        ld a,(SND_DECAYVOL+4)
vol2const
	and 15
        ld hl,tvolume
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld l,(hl)
	ld b,0xbf
	out (c),l
        
        ld hl,SND_SQUARE2_REG
        ld a,(hl)
        and 15 ;decay rate
        inc a
        ld b,a
vol2decaycounter=$+1
        ld a,0
        sub 4 ;4 "sound frames"
        jr nc,$+3
        add a,b ;decay rate
        ld (vol2decaycounter),a
        jr nc,vol2nodecay
	 ld a,(SND_DECAYVOL+4)
         dec a
        jp p,vol2noenddecay
         and 0xf
        bit 5,(hl)
        jr nz,vol2noenddecay ;decay looping enabled
         xor a
vol2noenddecay
	 ld (SND_DECAYVOL+4),a
vol2nodecay

	ld e,9
	ld b,0xff
	out (c),e
	ld a,(SND_NOISE_REG) ;bit4=constant volume, or else envelope
        bit 4,a
        jr nz,noiseconst
        ld a,(SND_DECAYVOL+12)
noiseconst
	and 15
        ld hl,tvolume
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
	;ld b,0xbf
	;out (c),l

	;ld e,9
	;ld b,0xff
	;out (c),e
	 bit 3,d ;noise
	 jr nz,notrianglevolumeout
	xor a
	 bit 1,d ;triangle
	 jr z,$+4
	ld a,16
notrianglevolumeout
	ld b,0xbf
	out (c),a
	 ;and 15
	 ;jr nz,$
        
        ld hl,SND_NOISE_REG
        ld a,(hl)
        and 15 ;decay rate
        inc a
        ld b,a
noisedecaycounter=$+1
        ld a,0
        sub 4 ;4 "sound frames"
        jr nc,$+3
        add a,b ;decay rate
        ld (noisedecaycounter),a
        jr nc,noisenodecay
	 ld a,(SND_DECAYVOL+12)
         dec a
        jp p,noisenoenddecay
         and 0xf
        bit 5,(hl)
        jr nz,noisenoenddecay ;decay looping enabled
         xor a
noisenoenddecay
	 ld (SND_DECAYVOL+12),a
noisenodecay
	
	endif

        if RESTOREPG16K
curpg4000=$+1
        ld a,0
	SETPG16K
        endif

	pop de
	pop bc
	pop af
	
on_int_hl=$+1
	ld hl,0
        if MULTITASKING==0
on_int_sp2=$+1
	ld sp,0
        ei
on_int_jp=$+1
        jp 0
        
        else

        ld sp,tempintstack
        push de
        ex de,hl
;(intjp)=адрес выхода
;de="hl", в стеке "de"
        jp 0x0038+5

        dw 0
tempintstack=$

;вход в стандартный обработчик:
        ;ex de,hl ;de="hl", hl="de"
        ;ex (sp),hl ;hl=адрес выхода, de="hl", в стеке "de"
        ;ld (intjp),hl ;TODO писать не прямо в intjp, а в промежуточную локацию (иначе хвост обработчика нельзя с ei - он сам не может сменить режим обработки прерывания после jp)
;(intjp)=адрес выхода
;de="hl", в стеке "de"
        ;ld l,a
;user_fdvalue6=$+1
        ;ld a,fd_system
        ;out (0xfd),a ;10 b

on_int_q
;на выходе из стандартного обработчика в стеке "de"
;восстановим как надо
on_int_sp2=$+1
	ld sp,0
on_int_jp=$+1
	jp 0

        endif

SND_COUNTER
SND_DECAYVOL=$+1
        ds 4+4+4+2 ;sq1,sq2,tri,noise (2 bytes used from 4)
        
tvolume
        db 0,9,10,11, 12,12,13,13, 13,14,14,14, 15,15,15,15
        
;что-то не так с этой таблицей
tcounterload
        db 0x7f,0x05
        db 0x01,0x0a
        db 0x02,0x14
        db 0x03,0x28
        db 0x04,0x50
        db 0x05,0x1e
        db 0x06,0x07
        db 0x07,0x0d
        
        db 0x08,0x06
        db 0x09,0x0c
        db 0x0a,0x18
        db 0x0b,0x30
        db 0x0c,0x60
        db 0x0d,0x24
        db 0x0e,0x08
        db 0x0f,0x10
        
gettimer
;out: hl=timer
;суммируем оба таймера - вдруг было системное прерывание
	if OSCALLS
        OS_GETTIMER ;hlde=timer
	endif
curtimer=$+1
	ld hl,0
	if OSCALLS
        add hl,de
	endif
	ret

	;include "smbsound.asm"
        ;include "smbmusic.asm"
	
reservepage
;new page, set page in textpages, npages++, set page in #c000
;nz=error
        OS_NEWPAGE
        or a
        ret nz
npages=$+1
        ld hl,filepages
        ld (hl),e
        inc l
        ld (npages),hl
        ld a,e
        SETPG32KHIGH
        xor a
        ret ;z
	

DEMOLONGLINE=1

demooff
;выключение демы, играем и пишем с клавиатуры
	 ld a,55; ;scf ;201 ;ret
	 ld (readdemo),a
	 ;ld a,0x77
	 ;ld (getbyte_opcode),a
	 xor a
	 ld (InjurePlayer_PiranhaPlant),a
	 ;jp democontinue ;иначе будет вечная пауза
democontinue
;продолжение после брякпоинта
	xor a
	ld (readdemo_stopflag),a
	ret

        macro NEXTBYTEFAST
        inc l
        call z,getbyte_inch_pp
        endm
        macro NEXTBYTEEND
        ld (getbyte_addr),hl
        endm
        
writedemo
;сейчас указатель на разделителе после кнопок джойстика
;a=keys
;DEMOLONGLINE=1!!!
	push af
	call getbyte_setpg
        NEXTBYTEFAST
	ld (hl),'+'
        
	ld b,8
writedemo0
        NEXTBYTEFAST
	ld (hl),'.'
	djnz writedemo0
        
        NEXTBYTEFAST
	ld (hl),'|'
        NEXTBYTEFAST
	ld (hl),0x0d
        NEXTBYTEFAST
	ld (hl),0x0a
        NEXTBYTEFAST
	ld (hl),'|'
        NEXTBYTEFAST
	ld (hl),'.'
        NEXTBYTEFAST
	ld (hl),'.'
        NEXTBYTEFAST
	ld (hl),'|'
	
	pop af
	push af
	ld c,a

	if DEMOLONGLINE
	xor a
	ld b,c
	rr c
	rla
	rr c
	rla
	rr c
	rla
	rr c
	rla ;%0000UDLR
	xor b
	and 0x0f
	xor b
	ld c,a
	endif

	ld b,8
writedemo1
        NEXTBYTEFAST
	rrc c
	ld (hl),'.'
	jr nc,$+4
	ld (hl),'Z'
	djnz writedemo1
        
        NEXTBYTEEND

	call setpgs_code
	pop af
	ret

readdemo
	or a ;/scf
	jr c,writedemo
readdemo_stopflag=$
	nop ;/ret

        ;jr $
	call getbyte_setpg
        
	if 1==0 ;однобайтный формат дем
        ld a,(hl)
;a=buttons = %R?D?t?BA
	ld b,8
	rra
	rl c
	djnz $-3
        NEXTBYTEEND
        ld a,c
	
;a=buttons
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8)
	else
	
;"|0|RLDUTsBA|||",0x0a = 15 bytes, реально начинаем на 4 байта раньше
;"|.r|UDLRSsBA|........|",0x0d,0x0a = 24 bytes, реально начинаем на 12 байт раньше
;лучше перейти на короткий формат, а то 6000t после оптимизации (один байт = 194t)
	if DEMOLONGLINE
	ld d,12+4
	else
	ld d,3+4
	endif
        
readdemo0
        NEXTBYTEFAST
	ld a,(hl)
	add a,256-'A'
	rr e
        dec d
	jp nz,readdemo0

	ld d,0x80
readdemo1
        NEXTBYTEFAST
	ld a,(hl)
	add a,256-'A'
	rr d
	jp nc,readdemo1
        
        NEXTBYTEEND
	
	if DEMOLONGLINE
	 ;ld a,e
	 ;and 0x40 ;reset
	 ;cp 0
	 ;ld ($-1),a
	bit 6,e
	 jp z,readdemo_noreset
	;or a
	;jr nz,readdemo_noreset
	;pop af
	;jp Start
	if FASTDEMOBEFOREBREAKPOINT
	push de
	xor a
	ld (skipPPU),a
	call EmulatePPU
	call EmulatePPU
	pop de
	endif
	ld a,201
	ld (readdemo_stopflag),a
readdemo_noreset

	xor a
	ld b,d
	rr d
	rla
	rr d
	rla
	rr d
	rla
	rr d
	rla ;%0000UDLR
	xor b
	and 0x0f
	xor b
	
	else
	
	ld a,d
	
	endif
	
	endif
;a=buttons
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8)
	push af
	call setpgs_code
	pop af
	ret
	
getbyte_setpg
;портит hl,bc
;не портит de
;out: a=pg, hl=addr in pg
getbyte_addr=$+1 ;реально читать начнём со следующего адреса
	;ld hl,0xffe0+5 ;148974
;правдоподобно только 5..6, что-то не так с отскоком от врага?
	;ld hl,0xffe0+14 ;53672
	;ld hl,0xc260+4 ;53672
;было (когда старт нажимался слишком поздно - уже во встроенной деме)
;12..13 проход через трубу медленно, сдох на монстре
;14 (+4) проход через трубу с задержкой справа, потом застрял на лестнице
;15 не допрыгнул до трубы с бонусом
;16-20 ещё хуже
	;ld hl,0xd2c8-12-1+(15*24) ;1904330 (pg1)
;11..13 сбил кирпич, пропрыгал две трубы
;14 прошёл 1-1, сдох на черепахе в 1-2
;15 прошёл 1-1, сдох на грибе после черепахи в 1-2
;16 нырнул в трубу, но не собрал монетки, а застрял
;17..20 не стартует
	;ld hl,0xc111-4-1+(16*15) ;351918
;11..14 - застреваем после убийства второго монстра
;15 - перепрыгиваем его, застреваем дальше
;16 - пролезаем через трубу, застреваем на лестнице
;17..20- умираем на втором монстре
	;ld hl,0xc0f4-4-1+(7*15) ;307549
;7..8 - довольно быстро бежим, но попадаем на первого монстра
;9 прыжок явно мимо
;12 медленно
;16..20 не стартует
	ld hl,0xc090-12-1 +(4*24) ;1775978 (cropped)
;0,1 - проходим world 1-1 (при jr RImpd застреваем возле замка)
;2,3 - застреваем на конечной лестнице 1-1 (при jr RImpd застреваем в трубе)
;4 - доходим дальше в 1-2 (при jr RImpd застреваем возле замка)
;5,6,7,8,9,10,11,12,13,14,15,16,17,18 - не проходим 1-1 (18 при jr RImpd застреваем возле замка)
;19,20 - застреваем на конечной лестнице 1-1 (при jr RImpd застреваем возле замка)
;21,22 - проходим world 1-1
;23,24 - застреваем на конечной лестнице 1-1
;25 - доходим дальше в 1-2
getbyte_pg=$+1
	ld a,(filepages)
	SETPG32KHIGH
        ret
	
getbyte_inch_pp
;не портит bc, переустанавливает hl в начале новой страницы (тогда же щёлкает страницу)
;l=0
	inc h
        ret nz
	 ld hl,getbyte_pg
	 inc (hl)
        push bc
getbyte_inch_memoryretry_m
        ld c,(hl)
        ld b,filepages/256
getbyte_inch_memoryretry
        ld a,(bc)
	or a
        jr z,getbyte_inch_newpg
        SETPG32KHIGH
        pop bc
         ld hl,0xc000
        ret
getbyte_inch_newpg
         push bc
	 push de
	  halt ;чтобы не сработало системное прерывание
	 call reservepage ;nz=error ;портит все регистры (но нам hl не важен)
	  ld a,(imer_curscreen_value)
	  ld bc,0x7ffd
	  out (c),a
	 pop de
         pop bc
	 jr z,getbyte_inch_memoryretry
	 ld hl,getbyte_pg
	 dec (hl)
        jr getbyte_inch_memoryretry_m ;no more memory
	

savedemo
	ld de,filename2
        OS_CREATEHANDLE
;b=new file handle
	push af
        ld a,b
        ld (filehandle),a
	pop af
        ;or a
	;ret nz
	
        ld hl,0
        ld de,0
	ld a,0
nvview_save0
        ;push de
        ;push hl
        ;call reservepage
        ;pop hl
        ;pop de
        ;ret nz ;no memory
	push af
	ld c,a
        ld b,filepages/256
        ld a,(bc)
        SETPG32KHIGH
	
        push de
        push hl
	ld de,0xc000
	ld hl,0x4000
;DE = Buffer address, HL = Number of bytes to read
	push hl
	ld a,(filehandle)
	ld b,a
        OS_WRITEHANDLE
;hl=actual size
;hl=loaded bytes
	ld b,h
	ld c,l
	pop hl ;Number of bytes to read
	or a
	sbc hl,bc ;z=loaded as requested
;bc=loaded bytes
	pop hl
	pop de
	pop af
;hlde=size
;z=loaded as requested
        ;ex de,hl
        ;add hl,bc
        ;ex de,hl
        ;jr nc,$+3
        ;inc hl
        ;jr z,nvview_save0
	inc a
	ld ix,npages
	cp (ix)
        jr nz,nvview_save0
;hlde=true file size (for TRDOSFS)
        ;ld (fcb+FCB_FSIZE),de
        ;ld (fcb+FCB_FSIZE+2),hl

        call closestream_file
	jp setpgs_code

gfxfilename
        db "smb.nes",0
filename
	db "antipac.fm2",0
filename2
	db "demo.fm2",0
	include "../../_sdk/file.asm"
tnofile
        db "smb.nes not found",0x0d,0x0a,0

;oldtimer
;	ds 2

	display "free before 0x2000=",0x2000-$
        ds 0x2000-$
;tile gfx: 2 256-tile maps
;16bytes/tile: 8bytes low bit, 8bytes high bit
tilegfx
        ds 0x2000 ;incbin "smbtiles"
        
        include "SMBDIS.ASM"

end

	display "End=",end
	;display "Free after end=",/d,0xc000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "smb.com",begin,end-begin
	
	;LABELSLIST "user.l"
