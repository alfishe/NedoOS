        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

scrbase=0x4000+4
sprmaxwid=32
sprmaxhgt=32
scrwid=128;160 ;double pixels
scrhgt=160;200

STACK=0x3ff0
tempsp=0x3f06 ;6 bytes for prspr
INTSTACK=0x3f00


fx=1 ;где было определено?

atm=1;0
msx=0;1
;ON16C=0;#01
re=1
border=0
WORLDS=8 ;потом повторяются
byting=1
wallcode=%11 ;для byting=0
maxlives=4
beglives=4
;       IF msx
;SCRHGT=17
;       ELSE 
;SCRHGT=20 ;24
;       ENDIF 
polY=#280; 368
fallY=1024
dieY=1280
potolY=48
demorec=0 ;записать демо уровня (ловить на LOOQ)
Lunit=11 ;длина информации о персонаже
       IF msx
HEROES=#0200
       ELSE 
HEROES=#9300 ;здесь обработчик прерыв-й двигает персонажей
       ENDIF 
LHEROES=#300    ;#200 bytes = max 46 персонажей
       IF msx
HEROESFROM=#0500
scrloadaddr=#0800 ;ends #4CXX
ballloadaddr=#6000-4726 ;=#4D8A
       ELSE 
;HEROESFROM=#9600 ;TODO
       ENDIF 
TNXTLN=#9900 ;256 bytes
IMVEC=#9A00
IMER=#9B9B
PROUTBUF=#9B9E ;32 bytes спрайт символа
SPROUTBUF=#9C00 ;#200 bytes = max 32*32 pix
                ;спрайт, вытащенный из страницы
TMASK=#9E00 ;256 bytes
;SPRS=#9F00 ;таблица выводимых спрайтов, создается offint
           ;256 bytes = max 51 спрайт видно одновременно
RARS=#6000 ;для распаковки экранов
addr=#9C00;9F00 ;для распаковки экранов (<#A000)
 IF re
REBUF1=#A002 ;для 1-го экрана
REBUF1WARNING=#AF00
REBUF2=#B002 ;для 2-го экрана
REBUF2WARNING=#BF00
                ;#FFE bytes = max 8 * 32*28 pix
 ENDIF 

;f88=#C000

pgspr=0;#10
pgspr2=1;#10
pgfnt=1;0;#10
pgpic=4;#14
pgmuz=6;#16
;p1C=#19 ;экр0 слой0 (выводится экр1)
        MACRO xy2adr
_a=_y*40+_x+#C004
        ENDM 
pgsp2=pgmuz
pgIQ=pgpic;pgspr
pgbmap=pgIQ ;ее юзает IQ.BOUNCE

BMAP=#F000 ;карта препятствий (pgbmap)



        org PROGSTART
begin
	jp GO ;patched by prspr
GO
        ld sp,STACK
        OS_HIDEFROMPARENT
        ld e,0+0x80 ;EGA
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode) +8=noturbo, +0x80=keep gfx pages
        ld de,emptypal
        OS_SETPAL ;включаем чёрную палитру, чтобы было незаметно переброску экрана
        ld e,0
        OS_CLS ;очистили текущий экран

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ld a,e
        ld (pgmain4000),a
        ld a,h
        ld (pgmain8000),a
        ld a,l
        ld (pgmainc000),a
        ld (tpgs+0),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+1),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+3),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+4),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+6),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+7),a 
        OS_NEWPAGE
        ld a,e
        ld (tpgscrdata+0),a 
        OS_NEWPAGE
        ld a,e
        ld (tpgscrdata+1),a 
        
        ld de,path
        OS_CHDIR
        
        ld a,pgpic
        call OUTA
        ld hl,wastileset
        ld de,tiledisp
        ld bc,sztileset
        ldir
        
        ld a,pgspr2
        call OUTA
        ld hl,wasspr2
        ld de,0xc000
        ld bc,spr2end-0xc000
        ldir

        LD A,pgmuz
        CALL OUTA

        LD de,muzbinNAME
        OS_OPENHANDLE
	push bc
	ld de,muz
	ld hl,0x4000
	OS_READHANDLE
	pop bc
	OS_CLOSEHANDLE

	call swapimer

       LD HL,AFXBANK
       CALL AFXINIT
        
        ld a,(pgmain4000)
        ld hl,music
        OS_SETMUSIC

        ld de,pal
        OS_SETPAL
        jp BEGIN
        
tpgscrdata
        ds 2;*(1+8) ;title+levels
        
loadpic
        ld a,'0'
        ld (de),a
        push de
        ld a,(tpgscrdata+0)
        call loadfile_in_ac000 ;загрузили один экранный файл в одну страницу A
        pop hl
        inc (hl) ;'1'
        ex de,hl ;this filename again, but "1..."
        ld a,(tpgscrdata+1)
        jp loadfile_in_ac000 ;загрузили один экранный файл в одну страницу A

showscrdata
        ld a,(tpgscrdata+0)
       ld (pgscrdata0),a
        SETPGC000 ;включили страницу с данными в c000
        ;ld a,(user_scr0_low) ;ok
        ;SETPG4000 ;включили пол-экрана в 4000
        ld de,emptypal
        OS_SETPAL ;включаем чёрную палитру, чтобы было незаметно переброску экрана
        halt
        call setpgscr_low_cur4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран

       if 0
        ld hl,0x4000+8000 ;там в картинке палитра (по байту на цвет)
        ld de,pal
        ld b,16
copypal0
        ld a,(hl)
        inc hl
        ld (de),a
        inc de
        ld (de),a
        inc de
        djnz copypal0 ;скопировали палитру в pal (по 2 байта на цвет)
       endif
        
        ld a,(tpgscrdata+1)
       ld (pgscrdata1),a
        SETPGC000 ;включили страницу с данными в c000
        ;ld a,(user_scr0_high) ;ok
        ;SETPG4000 ;включили другие пол-экрана в 4000
        call setpgscr_high_cur4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран
        ld de,pal
        OS_SETPAL ;включаем палитру
        ret

;x/2, xright/2 невключительно, y, ybottom невключительно
;-1 = end
sprlist1
        ds 4*128,-1
sprlist2
        ds 4*128,-1

pal
        ;ds 32 ;тут будет палитра картинки
        include "gfx/sprpal.ast"
emptypal
        ds 32,0xff ;палитра, где все цвета чёрные

loadfile_in_ac000
        ld hl,0xc000
loadfile_in_ahl
;de=имя файла
;hl=куда грузим (0xc000)
;a=в какой странице
        SETPGC000 ;включили страницу A в 0xc000
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld hl,0x4000 ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	jp setpgmainc000 ;включили страницу программы в c000, как было

primgega_onescreen
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
primgega0
        push bc
        ld hx,b
        push hl
        ld bc,40
primgegacolumn0
        ld a,(de)
        inc de
        ld (hl),a
        add hl,bc
        dec hx
        jr nz,primgegacolumn0
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,primgegacolumn0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
primgegacolumn0q
        pop bc
        dec c
        jr nz,primgega0
        ret



copyimgega_curtodefault
;d=hgt,e=wid (/8)
;hl=scr
        call getuser_scr_low_cur
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_low
        SETPGC000 ;set "to" page in c000
        call copyimgegalayer
        call getuser_scr_high_cur
        SETPG16K ;set "from" page in 4000
        call getuser_scr_high
copyimgegaq
        SETPGC000 ;set "to" page in c000
        call copyimgegalayer
        call setpgmainc000
        jp setpgsmain40008000

copyimgega_defaulttocur
;d=hgt,e=wid (/8)
;hl=scr
        call getuser_scr_low
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_low_cur
        SETPGC000 ;set "to" page in c000
        call copyimgegalayer
        call getuser_scr_high
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_high_cur
        jr copyimgegaq ;set "to" page in c000, copy

copyimgega_defaulttoshadow
;d=hgt,e=wid (/8)
;hl=scr
        ld a,(pgscrdata0)
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_low
        SETPGC000 ;set "to" page in c000
        call copyimgegalayer
        ld a,(pgscrdata1)
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_high
        jr copyimgegaq ;set "to" page in c000, copy

copyimgegalayer
        push hl
        ld hx,e ;wid/8
copyimgega0
        push de
        push hl
        ld b,d ;hgt
        ld de,40-0x8000
copyimgegacolumn0
        ld a,(hl)
        set 5,h
        ld c,(hl)
         set 7,h
        ld (hl),c
        res 5,h
        ld (hl),a
        add hl,de
        djnz copyimgegacolumn0
        pop hl
        pop de
        inc hl
        dec hx
        jr nz,copyimgega0
        pop hl
        ret 
        
pgscrdata0
        db 0
pgscrdata1
        db 0

curkey
        db 0
joystate
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8) 
        db 0

path
        db "bq",0
        
findpicfilename_a
        ld hl,picfilenames
findpicfilename_a0
        or a
        ret z
        dec a
        push af
        xor a
        ld b,-1
        cpir ;hl = after 0
        pop af
        jr findpicfilename_a0
        
titlefilename
        db "0title.bmpx",0
picfilenames
        db "0pic1.bmpx",0
        db "0pic2.bmpx",0
        db "0pic3.bmpx",0
        db "0pic4.bmpx",0
        db "0pic5.bmpx",0
        db "0pic6.bmpx",0
        db "0pic7.bmpx",0
        db "0pic8.bmpx",0
        ;db 0

	include "mem.asm"
	include "int.asm"

	;include "spr.ast"
	include "prspr.asm"
        
        include "BQGAME.asm"
        INCLUDE "PRSPR16.asm"
        INCLUDE "BQTAB.asm"
        INCLUDE "BQIQ.asm"

;------------------------------------------------
        align 256
mkeyqueue
        ds 256

ON_INT
        ;ld a,(pgmain4000)
        ;SETPG4000 ;чтобы иметь доступ к tuneON

       CALL OUTIQ
        CALL INKEY
        LD A,C
        ;LD (MKEY),A
mkeytail=$+1
        ld hl,mkeyqueue
        ld (hl),a
        inc l
        ld (mkeytail),hl
        
       ld a,(showdemo)
       rla
       jr c,ON_INTnoshowdemo
       xor a
       IN A,(#FE)
       cpl
       and 0x1f
       jr nz,ON_INTgameover
ON_INTnoshowdemo
       LD A,#FE
       IN A,(#FE)
       AND %01100 ;X+C
       ld a,2
       jr Z,ON_INTgameover_a
       LD A,#FE
       IN A,(#FE)
       AND %10010 ;Z+V
       jr NZ,nobreakkey
ON_INTgameover
       LD A,4 ;break
ON_INTgameover_a
       LD (gameover),A
nobreakkey
       LD A,#BF ;En..H
       IN A,(-2)
       AND 16 ;"H"
oldH=$+1
       CP -1
       LD (oldH),A
       jr Z,noH
        OR A
        jr NZ,noH
        LD HL,haltON
        LD A,(HL)
        XOR #80
        LD (HL),A
noH

haltON=$
        DB 55+128
        JP C,nogame

gamescf=$
        OR A
        JP NC,nogame

nogame
RETER   RET 

TIMEBACK
        LD HL,TTIME2+3-1
        DEC (HL)
       LD C,"0"
        LD A,(HL)
        CP C;"0"
        jr NC,PRCLK
        LD (HL),"9"
        DEC HL
        DEC (HL)
        LD A,(HL)
        CP C;"0"
        jr NC,PRCLK
        LD (HL),"9";"5"
        DEC HL
        DEC (HL)
        LD A,(HL)
        CP C;"0"
        jr NC,PRCLK
  ;time out!!!
        LD (HL),C;"0"
        INC HL
        LD (HL),C;"0"
        INC HL
        LD (HL),C;"0"
       LD A,(gameover)
       OR A
       LD A,fxtimeout
       CALL Z,AFXPRAY
        LD A,3
        LD (gameover),A
PRCLK
       IF msx
        LD A,1
        LD (fprtime),A
        RET 
SHOWTIME
       ENDIF 
        LD C,0
        LD HL,TTIME2
_y=176
_x=8
        xy2adr
       IF msx
        _a=136*3-160*128+_a
       ENDIF 
        LD DE,_a ;#D0CE
        CALL PRTXT88
OUTIQ
       LD A,pgIQ
OUTA
        ;LD (curpg),A ;TODO убрать
        push bc
        and 7
         ld c,a
         ld b,tpgs/256
         ld a,(bc)
        SETPGC000
        pop bc
        ret
        
;curscr
        ;db 0

        align 256
tcol8tocol0
       dup 256
;цвета в байте хранятся так: RLrrrlll
_b=$&0xff
_r=((_b&0x80)>>4)+((_b&0x38)>>3)
_l=((_b&0x40)>>3)+(_b&0x07)
       if _r==8
_r=0
       endif
       if _l==8
_l=0
       endif
        db ((_r&8)<<4)+((_r&7)<<3)+((_l&8)<<3)+(_l&7)
       edup

        display "tpgs=",$

        align 256
tpgs
        ds 8;256 

INCSCORE
;HL=сколько единиц прибавить к счету
        PUSH BC
        LD BC,(score)
        ADD HL,BC
        jr NC,$+5
        LD HL,-1
        ;LD (score),HL
        ;CALL SHOWSCORE
        call INVALIDATESCORE_hl
        POP BC
        RET 

INVALIDATEKEYS
        xor a ;"nop"
        ld (fkeys),a
        ret

INVALIDATESCORE_hl
        LD (score),HL
        xor a ;"nop"
        ld (fscore),a
        ret

PRHUD
        call PRSCORE
;PRKEYS
fkeys=$
        nop ;/ret
        ld a,0xc9 ;"ret"
        ld (fkeys),a
        ;PUSH BC,DE,IX
keys=$+1
        LD HL,0
_y=168+8
_x=15
        xy2adr
        LD DE,_a ;#D0B8
       ;LD A,(curpg)
       ;PUSH AF
        jp PR123
        ;JR INCSCQ
PRSCORE
fscore=$
        nop ;/ret
        ld a,0xc9 ;"ret"
        ld (fscore),a
        ;PUSH BC,DE,IX
score=$+1
        LD HL,0
_y=168+8
_x=22
        xy2adr
        LD DE,_a ;#D0B8
       ;LD A,(curpg)
       ;PUSH AF
        jp PR12345
;INCSCQ ;POP AF
        ;POP IX,DE,BC
        ;JP OUTA
;curpg
        ;db 0 ;TODO убрать
        


AFXPRAYVOL
        PUSH BC
        JR AFXPRAU
AFXPRAY
        PUSH BC
        LD C,0 ;относительная громкость
AFXPRAU PUSH DE,IX
        LD B,A
       ld a,(curpg32khigh) ;ok
       PUSH AF
        push bc
        LD A,pgmuz
        CALL OUTA
        pop bc
        PUSH HL
        LD A,B
        CALL AFXPLAY
        POP HL
       pop af
       SETPGC000
        POP IX,DE,BC
       ret

MKEY    DB 0 ;%11LRDUBF
thigh   DW 0
world   DB 0
SEED    DW 0

levNAME
        DB "LEV2.BIN",0
muzbinNAME
        DB "bqmuz.bin",0
muzNAME
        DB "MUZ2.pt3",0
muzmenuNAME
        DB "SMR_PLTS.pt3",0
picNAME
        DB "0pic1.bmpx",0

;2:gameovers
ANYKEY
       CALL OUTIQ
ANYKY0  HALT 
        CALL INKEY
        LD A,C
        CPL 
        AND %00111111
        jr Z,ANYKY0
        RET 

;2
INKEY
;C=11LRDUBF (B=break)
       IF msx
        IN A,(#AA)
        AND #F0
        OR 8 ;row
        OUT (#AA),A
        IN A,(#A9)
        LD C,#FF
        RRA ;space
        JC $+4
        RES 0,C
        RRA 
        RRA 
        RRA 
        RRA ;left
        JC $+4
        RES 5,C
        RRA ;up
        JC $+4
        RES 2,C
        RRA ;down
        JC $+4
        RES 3,C
        RRA ;right
        JC $+4
        RES 4,C
        IN A,(#AA)
        AND #F0
        OR 7 ;row
        OUT (#AA),A
        IN A,(#A9)
        BIT 2,A ;esc
        JNZ $+4
        RES 1,C

        LD A,15 ;joystick selection port
        OUT (#A0),A ;reg sel
        IN A,(#A2)
        AND %10101111 ;в Portar.txt перепутано
        OR %00000011
       ;LD A,%10001111 ;D6=0: joystick 1
        OUT (#A1),A ;reg sel
        LD A,14
        OUT (#A0),A
        IN A,(#A2)
       LD B,A
        LD A,15 ;joystick selection port
        OUT (#A0),A ;reg sel
        IN A,(#A2)
        AND %11011111
        OR %01001100
       ;LD A,%11001111 ;D6=1: joystick 2
        OUT (#A1),A ;reg sel
        LD A,14
        OUT (#A0),A
        IN A,(#A2)
       AND B
        RRA ;up
        JC $+4
        RES 2,C
        RRA ;down
        JC $+4
        RES 3,C
        RRA ;left
        JC $+4
        RES 5,C
        RRA ;right
        JC $+4
        RES 4,C
        RRA ;trigger A
        RET C
        RES 0,C
        RET 
       ELSE ;zx
        LD A,#FE
        IN A,(254)
        RRA 
        LD A,#EF
        IN A,(254)
        JR C,UANOCAP
        LD C,#FF
        RRA     ;CS+"0" = "0"
        jr C,$+3
        DEC C
        RRA 
        RRA     ;CS+"8"
        jr C,$+4
        RES 4,C
        RRA     ;CS+"7"
        jr C,$+4
        RES 2,C
        RRA     ;CS+"6"
        jr C,$+4
        RES 3,C
        LD A,#F7
        IN A,(254)
        BIT 4,A ;CS+"5"
        jr NZ,$+4
        RES 5,C
        RLA     ;CS+"1"
        jr C,INKEYF
        RES 1,C
        JR INKEYF
UANOCAP
        RRCA 
        RLA 
        RLA 
        OR #C2
        LD C,A
        LD A,#DF
        IN A,(254)
        RRA     ;"P"
        JR C,$+4
        RES 4,C
        RRA     ;"O"
        JR C,$+4
        RES 5,C
        LD A,#FB
        IN A,(254)
        RRA     ;"Q"
        JR C,$+4
        RES 2,C
        RRA 
        RRA     ;"E"
        JR C,$+4
        RES 1,C
        LD A,#FD
        IN A,(254)
        RRA     ;"A"
        jr C,$+4
        RES 3,C
INKEYF  LD A,#7F
        IN A,(254)
        CPL 
        AND 31
        RET Z
        RES 0,C
        RET 
       ENDIF 
TRUNLINE
       IF msx
        DB " PRESS SPACE OR FIRE TO START GAME ^ "
        DB "USE ",34,"F5",34," TO EXIT GAME ^ "
        DB "USE ",34,"F3",34," TO TURN MUSIC ON/OFF ^ "
        DB "USE ",34,"F1",34," FOR PAUSE"
       ELSE 
        DB " PRESS ",34,"S",34," TO START SLOW GAME ^ "
        DB "PRESS ",34,"F",34," TO START FAST GAME ^ "
        DB "USE ",34,"T",34," TO TURN MUSIC ON/OFF ^ "
        DB "USE ",34,"H",34," FOR PAUSE"
       ENDIF 
        DS 31,32
        DB -1
TRUNLINE2
       IF msx
        DB " IDEA & CODE: ALONE CODER ^ "
        DB "GFX: SHIRU, ALONE CODER, SURFIN' BIRD ^ "
        DB "MUSIC: JEFFIE, PROG MASTER, "
        DB "SHIRU, ALONE CODER, "
        DB "BASIL, "
        DB "JOHN SILVER, MACROS, FIRESTARTER, NIK-O ^ "
        DB "SFX PLAYER: SHIRU ^ "
        DB "LEVEL EDIT TOOL: SHIRU ^ "
        DB "LEVELS: ALONE CODER, JOHN SILVER ^ "
        DB "(ZX) 2006, (MSX) 2007 "
       ELSE 
        DB " IDEA & CODE: ALONE CODER ^ "
        DB "GFX: SHIRU OTAKU, ALONE CODER, SURFIN' BIRD ^ "
        DB "MUSIC COVERS: SHIRU OTAKU ^ "
        DB "SFX PLAYER: SHIRU OTAKU ^ "
        DB "LEVEL EDIT TOOL: SHIRU OTAKU ^ "
        DB "LEVELS: ALONE CODER, JOHN SILVER ^ "
        DB "2006 YEAR"
       ENDIF 
        DS 31,32
        DB -1
DEMOSTART
DEMO1
        INCBIN "l4dem.C"
DEMO2
        INCBIN "l2dem.C"
DEMOEND

SPRS
        ds 256

HEROESFROM
        incbin "LEV1.BIN" ;TODO load
        display $,"<0x3f00!!!!!!!!!!!!!!!!!!"
        ds 0x3f00-$
HEROESFROMsz=$-HEROESFROM

       ;ORG #C000,pgpic
        ds 0x4000-$
music
        ;LD A,pgmuz
        ;CALL OUTA
        CALL AYFE_ ;AY #2(1)
       LD A,#FB ;Q..T
       IN A,(#FE)
       AND 16 ;"T"
oldT=$+1
       CP -1
       LD (oldT),A
       jr Z,noT
        OR A
        jr NZ,noT
        LD HL,tuneON
        LD A,(HL)
        XOR #80
        LD (HL),A
        CALL SHUTAY_
noT
tuneON=$
        scf
        ;ld a,(tuneON)
        ;rla
        ;ccf
       PUSH AF
muzer=$+1
        CALL C,muzRETER;muz+5;muzzam+5
       POP AF
        CALL AYFF_ ;AY #1(0)
        CALL NC,SHUTAY_ ;если music off
       CALL AFXFRAME ;pgmuz!
muzRETER
        ret

SHUTAY_
        LD DE,#E00
SHUT0
        LD BC,#FFFD
        DEC D
        OUT (C),D
        LD B,#BF
        OUT (C),E
        jr NZ,SHUT0
        RET 

AYFE_
        LD A,#FE  ;AY #2(1))
       IF msx
       ;OUT (#A0),A ;хотя все равно на MSX нет TS
       ELSE 
        LD BC,#FFFD
        OUT (C),A ;AY #2(1)
       ENDIF 
        RET 

AYFF_
        LD A,#FF  ;AY #1(0)
       IF msx
       ;OUT (#A0),A ;хотя все равно на MSX нет TS
       ELSE 
        LD BC,#FFFD
        OUT (C),A ;AY #2(1)
       ENDIF 
        RET 

wastileset
tiledisp=#C000
       DISP tiledisp
tileset
        INCBIN "gfx/tileset.C"
sztileset=$-tileset
       ENT



        ORG #C000,pgmuz
muz
        ;ds 9,0xc9;INCBIN "PLAYTS" ;TODO
        include "../../_sdk/ptsplay.asm"
        INCLUDE "afxplay3.asm"
MDLADDR
muzmenu
Lmuz=$-#C000
_Lmuz=Lmuz+255&#FF00+5
 DISPLAY "SAVE ~BQMUZ.C~ pg",pgmuz," #C000,",#4000;Lmuz
 DISPLAY "&pack by HRUST1 то ~BQMUZ  *.C~:DI,buf=#BF00,JP #C000"
        DS #F8C0-$
maxmuz=$-muzmenu
AFXBANK INCBIN "sound/bqiwo.afb"
       DISPLAY "SFXEND=",$
	savebin "bq/bqmuz.bin",muz,$-muz
        DS 0x10000-$

fx=1
fxd=-1
fxbonus1=1+fxd
fxbonus2=2+fxd
fxanus1=3+fxd
fxbonus3=4+fxd
fxgirya=5+fxd
fxbottle=6+fxd
fxbottleend=7+fxd
fxcrack=8+fxd
fxdiamond=9+fxd
fxekill=10+fxd
fxfall2=11+fxd
fxfall=12+fxd
fxfood=13+fxd
fxglassbreak=14+fxd
fxgiryaend=15+fxd
fxglass=16+fxd
fxkeylast=17+fxd
fxscore2=18+fxd
fxscore=19+fxd
fxtimeout=20+fxd
fxkey=21+fxd
fxbeton=22+fxd
fxderewo=23+fxd
fxjump=24+fxd

        ;ORG #C000,pgspr2
        org 0x8000
wasspr2
        disp 0xc000
f88     ;INCBIN "gfx/fontgfx.C";,#800
         include "gfx/fontgfx.ast"
         include "gfx/bqcoll2.ast"
spr2end
        DISPLAY "spr2end=",$
        ent

        ORG #C000,pgspr
         include "gfx/bqcoll.ast"
         include "gfx/ball.ast"
        if 0
s2=s0
s4=s0
s6=s0
s8=s0
sA=s0
sC=s0
sE=s0
sG=s0
sI=s0
sK=s0
sM=s0
sO=s0
sQ=s0
sS=s0
sU=s0
       endif

sprend
        DISPLAY "sprend=",$


 DISPLAY "SAVE ~BQSPR.C~ pg",pgspr," #C000,",sprend-#C000
 DISPLAY "&pack by HRUST1 то ~BQSPR  *.C~:DI,buf=#BF00,JP #C000"
 DISPLAY "SAVE ~BQMUZ.C~ pg",pgmuz," #C000,",#4000;Lmuz
 DISPLAY "&pack by HRUST1 то ~BQMUZ  *.C~:DI,buf=#BF00,JP #C000"

end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "bq.com",begin,end-begin
	;savebin "bq/spr2.bin",0xc000,spr2end-0xc000
	
	LABELSLIST "../../../us/user.l",1
