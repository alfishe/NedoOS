        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

emptyattr=7
FIGBUF_sz=100
scrx=4
scrbase=0x4000+scrx
bgcolor=13
bgcolorbyte=%11101101 ;color13
        
        org PROGSTART
begin

        ld e,0 ;EGA
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,e
        SETPG16K
        ld a,d
        SETPG32KLOW

        ld de,pal
        OS_SETPAL
        
        if 1==0
        ld de,block44
        ld hl,0x4000
        ld bc,0x2010
        call primgega_pixsz

        ld bc,0x0100
        ld hl,0x0408
        ld a,%11101101 ;color13
;a=color byte
;b=y/8
;c=x/8
;h=hgt/8
;l=wid/8
        call CLW     
        endif

        ;ld a,r
        ;add a,3
        ;jr nc,$-2
        ;ld (curlevel),a

	ld de,filename
	OS_OPENHANDLE
	or a
	jr nz,noloadini
	push bc
	ld de,SAVEDATA
	ld hl,SAVEDATAsz
	OS_READHANDLE
	pop bc
	OS_CLOSEHANDLE
	jr loadiniq
noloadini
	xor a
        ld (level),a

        ;jr loadiniq
restart
        ld a,(level)
        or a
        LD HL,FIG9
        jr z,gameinit_hl
        dec a
        LD HL,FIG10
        jr z,gameinit_hl
        LD HL,FIG11
gameinit_hl
        ;ld (curfield),hl
        ;ld hl,(curfield)
        ld a,(hl)
        inc hl
        ld (cur_nfigures),a
        ld a,(hl)
        inc hl
        ld (curtopmargin),a
        ld a,(hl)
        inc hl
        ld (curbottommargin),a
        ld a,(hl)
        inc hl
        ld (curleftmargin),a
        ld a,(hl)
        inc hl
        ld (currightmargin),a
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld (curtopleft),bc
        ld b,(hl)
        inc hl
        ld c,(hl)
        inc hl
        ld (curtarget),bc
        LD A,(HL)
        ADD A,A
        INC A
        ADD A,A
        INC HL
        ld d,a
        ld a,(HL)
        ADD A,A
        INC A
        ADD A,A
        ld e,a
         ld (curmainboxsizes),de
        INC HL
        CALL COPBUF ;тоже рисует
loadiniq

        call cls
        call drawfield
        
gameloop
        
        ;call prscore
        ld hl,(FIGBUF)
        ld de,(curtarget)
        or a
        sbc hl,de
        jr z,newlevel

        YIELD ;call delay

        GET_KEY
         cp key_esc
         jr z,quit
        cp 'r'
        jr z,restart
        cp 'a'
        jr c,$+4
        sub 0x20
        ;LD (STARTA_boxname),A
        CP 'A'
        JR C,$+4
        SUB 'A'-':'
        SUB '1'
        JR C,gameloop
        ld hl,cur_nfigures
        CP (hl);10
        JR NC,gameloop
         LD (STARTA_boxname),A
        PUSH AF
        CALL MOVFIG
        POP AF
        PUSH AF
        CALL MOVFIG
        POP AF
        PUSH AF
        CALL MOVFIG
        POP AF
        CALL MOVFIG
        jr gameloop
newlevel
        ld a,(level)
        inc a
        cp 3
        jr nz,$+3
        xor a
        ld (level),a
        jp restart
        
quit
	ld de,filename
	OS_CREATEHANDLE
	push bc
	ld de,SAVEDATA
	ld hl,SAVEDATAsz
	OS_WRITEHANDLE
	pop bc
	OS_CLOSEHANDLE
        QUIT



MOVFIG
;a=fig
        push af
        YIELD
        pop af
        LD HL,FIGBUF-4
FNDFIG  INC HL
        INC HL
        INC HL
        INC HL
        SUB 1
        JR NC,FNDFIG
        LD B,(HL)
        INC HL
        LD C,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD E,(HL)
        DEC HL
        DEC HL
        XOR A
        DEC B
        CALL MAYIGO
        JR NZ,NOUP
        CALL TOLIETO
        JR NZ,ICANGO
        INC A
NOUP    INC B
        INC B
        CALL MAYIGO
        JR NZ,NODN
        CALL TOLIETO
        JR NZ,ICANGO
        OR 2
NODN    DEC B
        DEC C
        CALL MAYIGO
        JR NZ,NOLT
        CALL TOLIETO
        JR NZ,ICANGO
        OR 4
NOLT    INC C
        INC C
        CALL MAYIGO
        JR NZ,NORT
ICANGO  PUSH BC
        PUSH DE
        PUSH HL
        LD HL,FIGBUF
        LD DE,FIGBUF2
        LD BC,FIGBUF_sz;100
        LDIR 
        POP HL
        POP DE
        POP BC
        PUSH DE
        PUSH BC
        LD A,(HL)
        LD (HL),C
        DEC HL
        LD C,(HL)
        LD (HL),B
        LD B,C
        LD C,A
        EX DE,HL
         ld a,bgcolorbyte
        CALL CLW
        POP BC
        POP HL
STARTA_boxname=$+1
        LD A,"A"
        jp BOX
NORT    LD C,(HL)
        DEC HL
        LD B,(HL)
        INC HL
        DEC B
        RRA 
        JR C,ICANGO
        INC B
        INC B
        RRA 
        JR C,ICANGO
        DEC B
        DEC C
        RRA 
        JR C,ICANGO
        RET 

TOLIETO
        PUSH BC
        LD (TOLIETO_A),A
        PUSH DE
        DEC HL
        LD A,(HL)
        LD (HL),B
        INC HL
        LD B,(HL)
        LD (HL),C
        INC HL
        LD C,A
        LD A,(HL)
        LD (HL),D
        INC HL
        LD D,(HL)
        LD (HL),E
        LD E,A
        PUSH BC
        PUSH DE
        PUSH HL
        LD HL,FIGBUF
        LD DE,FIGBUF2
        LD B,FIGBUF_sz;100
TOLI0   LD A,(DE)
        INC DE
        CP (HL)
        INC HL
        JR NZ,$+4
        DJNZ TOLI0
        POP HL
        POP DE
        POP BC
        LD (HL),D
        DEC HL
        LD (HL),E
        DEC HL
        LD (HL),B
        DEC HL
        LD (HL),C
        INC HL
        POP DE
TOLIETO_A=$+1
        LD A,0
        POP BC
        RET 

drawfield
        ld bc,(curtopleft)
        ld hl,(curmainboxsizes)
        ;XOR A
        ;CALL BOX
        ld a,bgcolorbyte
        call CLW
        ld hl,FIGBUF
        xor a ;LD A,"1"
drawfield0
        BIT 7,(HL)
         ret nz
        ld b,(hl)
        inc hl
        ld c,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld e,(hl)
        inc hl
        PUSH HL
        EX DE,HL
        CALL BOX
        POP HL
        INC A
        ;CP ":"
        ;JR NZ,$+4
        ;LD A,"A"
        JR drawfield0
        
COPBUF
        LD DE,FIGBUF
        ld bc,(curtopleft)
COPBUF0
        BIT 7,(HL)
        LD A,(HL)
         LD (DE),A
         ret nz
        INC HL
        ADD A,A
        ADD A,A
        ADD A,B
        INC A
        LD (DE),A
        INC DE
        LD A,(HL)
        INC HL
        ADD A,A
        ADD A,A
        ADD A,C
        INC A
        LD (DE),A
        INC DE
        LD A,(HL)
        INC HL
        ADD A,A
        ADD A,A
        LD (DE),A
        INC DE
        LD A,(HL)
        INC HL
        ADD A,A
        ADD A,A
        LD (DE),A
        INC DE
        JR COPBUF0

        if 1==0
EXBCHL
;b=y/8
;c=x/8
;h=hgt/8
;l=wid/8
        LD A,B ;y/8
        AND 24
        ADD A,64
        LD E,H ;hgt/8
        LD H,A
        LD A,B ;y/8
        RRCA 
        RRCA 
        RRCA 
         LD B,A ;???
        AND #E0
        OR C ;x/8
        LD C,L ;wid/8
        LD L,A
        LD A,E ;hgt/8
        ADD A,A
        ADD A,A
        ADD A,A
        LD B,A ;hgt
;hl=scr
;b=hgt
;c=wid/8
        RET 
        endif

BOX
;a=boxnum (kept)
;b=y/8
;c=x/8
;h=hgt/8
;l=wid/8
        ld (BOX_num),a
        call coords_to_scr
;hl=scr
;b=hgt
;c=wid/2
        ld a,b
        cp 4*8
        ld a,c
        jr z,BOXy4
BOXy8
        cp 4*4
        ld de,block48
        jr z,BOXok
        ld de,block88
        jr BOXok
BOXy4
        cp 4*4
        ld de,block44
        jr z,BOXok
        ld de,block84
BOXok
        push hl
        call primgega_pixsz
        pop hl
        ld de,40*8 + 1
        add hl,de
        push hl
BOX_num=$+1
        ld hl,0
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,digit1
        add hl,bc
        ex de,hl
        pop hl
        ld bc,0x0804
        call primgega_pixsz
        ld a,(BOX_num)
        RET 

MAYIGO  PUSH BC
        PUSH DE
        PUSH HL
        LD (MAYGO_A),A
        LD A,B
        push hl
        ld hl,curtopmargin
        CP (hl);4
        pop hl
        JR C,MAYGON
        ADD A,D
        push hl
        ld hl,curbottommargin
        CP (hl);21
        pop hl
        JR NC,MAYGON
        LD A,C
        push hl
        ld hl,curleftmargin
        CP (hl);6
        pop hl
        JR C,MAYGON
        ADD A,E
        push hl
        ld hl,currightmargin
        CP (hl);27 ;31 for 11
        pop hl
        JR NC,MAYGON
        DEC HL
        PUSH HL
        POP IX
        LD HL,FIGBUF
MAYGO0  BIT 7,(HL)
        JR NZ,MAYGOQ
        LD A,H
        CP HX
        LD A,LX
        JR NZ,$+5
        CP L
        JR Z,MAYGOK
        LD A,(HL)
        INC HL
        INC HL
        SUB B
        JR C,MAYGOX
        CP D
        JR NC,MAYGOK+2
        JR MAYGOXQ
MAYGOX  DEC A
        ADD A,(HL)
        JR NC,MAYGOK+2
MAYGOXQ DEC HL
        LD A,(HL)
        INC HL
        INC HL
        SUB C
        JR C,MAYGOY
        CP E
        JR NC,MAYGOK+3
        JR MAYGON
MAYGOY  DEC A
        ADD A,(HL)
        JR NC,MAYGOK+3
        JR MAYGON
MAYGOK  INC HL
        INC HL
        INC HL
        INC HL
        JR MAYGO0
MAYGOQ  XOR A
        JR $+3
MAYGON  OR H
        POP HL
        POP DE
MAYGO_A=$+1
        LD A,0
        POP BC
        RET 

DOWNHL  INC H
        LD A,H
        AND 7
        RET NZ
        LD A,L
        ADD A,32
        LD L,A
        RET C
        LD A,H
        ADD A,-8
        LD H,A
        RET 

FIG9
        db 9
        db 4,21,6,27 ;top,bottom,left,right margin
        dw 0x0305 ;topleft
        dw 0x0305 + 0x0101 + 0x000c;0x0804 ;target for first box
        dw #504 ;main box
        ;xy,wh
        dw 2,#202
        dw 0,#102
        dw #100,#102
        dw #200,#101
        dw #201,#101
        dw #300,#102
        dw #400,#102
        dw #302,#201
        dw #303,#201
        dw 255
FIG10
        db 10
        db 4,21,6,27 ;top,bottom,left,right margin
        dw 0x0305 ;topleft
        dw 0x0305 + 0x0101 + 0x040c ;target for first box
        dw #504 ;main box
        ;xy,wh
        dw 1,#202
        dw 0,#201
        dw #200,#201
        dw 3,#201
        dw #203,#201
        dw #400,#101
        dw #301,#101
        dw #302,#101
        dw #403,#101
        dw #201,#102
        dw 255
FIG11
        db 11
        db 4,21,6,31 ;top,bottom,left,right margin
        dw 0x0305 ;topleft
        dw 0x0305 + 0x0101 + 0x0010 ;target for first box
        dw #604 ;main box
        ;xy,wh
        dw 2,#202
        dw 0,#102
        dw #100,#102
        dw #200,#101
        dw #300,#101
        dw #400,#102
        dw #500,#102
        dw #402,#201
        dw #403,#201
        dw #302,#102
        dw #202,#102
        dw 255

cls
        ld e,9
        OS_CLS
        if 1==0
	ld hl,#4000
	ld de,#4001
        ld bc,#17ff
        ld (hl),0;#ff
        ldir
	ld hl,#5800
	ld de,#5801
	ld (hl),emptyattr
	ld bc,767
	ldir
        endif
        ret
        
      
prtext
;bc=координаты
;hl=text
        ld a,emptyattr
        ld (curattr),a
        ld a,(hl)
        or a
        ret z
        call prcharxy
        inc hl
        inc c
        jr prtext

prscore
        ld hl,(curscore)
        ld de,#4000
prnum
        ld bc,1000
        call prdig
        ld bc,100
        call prdig
        ld bc,10
        call prdig
        ld bc,1
prdig
        ld a,'0'-1
prdig0
        inc a
        or a
        sbc hl,bc
        jr nc,prdig0
        add hl,bc
        ;push hl
        ;call prchar
        ;pop hl
        ;ret
        
prchar
;a=code
;de=screen
        push de
        push hl
        call prcharin
        pop hl
        pop de
        inc e
        ret
        
calcscraddr
;de=#4000 + (y&#18)+((y*32)&#ff+x)
        ld a,b ;y
        and #18
        add a,#40
        ld d,a
        ld a,b ;y
        add a,a ;*2
        add a,a ;*4
        add a,a ;*8
        add a,a ;*16
        add a,a ;*32
        add a,c ;x
        ld e,a
        ret
        
calcattraddr
        call calcscraddr
        ;call calcattraddr_fromscr
calcattraddr_fromscr
;de=#5800 + (y&#18)/8+((y*32)&#ff+x)
        ld a,d
        ;sub #40
        rra
        rra
        rra
        and 3
        add a,#58
        ld d,a ;de=attraddr
        ret

prcharxy
;a=code
;bc=yx
        push bc
        push de
        push hl
        push af
        call calcscraddr
        pop af
        push de
        call prcharin
        pop de
        call calcattraddr_fromscr
curattr=$+1
        ld a,0
        ld (de),a
        pop hl
        pop de
        pop bc
        ret
        
prcharin
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font-256;#3c00
        add hl,bc
        ld b,8
prchar0
        ld a,(hl) ;font
        ld (de),a ;scr
        inc hl
        inc d ;+256
        djnz prchar0
        ret

coords_to_scr
;b=y/8
;c=x/8
;h=hgt/8
;l=wid/8
        ex de,hl
        ld h,0
        ld a,b ;y/8
        add a,a
        add a,a
        add a,a
        ld l,a
        ld a,c ;x/8
        ld b,h
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40
        ld bc,scrbase
        add a,c
        ld c,a
        add hl,bc
        ld a,d ;hgt/8
        add a,a
        add a,a
        add a,a
        ld b,a
        ld a,e ;wid/8
        add a,a
        add a,a
        ld c,a
;hl=scr
;b=hgt
;c=wid/2
        ret

CLW     
;a=color byte
;b=y/8
;c=x/8
;h=hgt/8
;l=wid/8
        ld (CLW_color),a
        call coords_to_scr
;hl=scr
;b=hgt
;c=wid/2
clw0
        push bc
        push hl
        ld de,40
CLW_color=$+1
        ld a,0
clwcolumn0
        ld (hl),a
        add hl,de
        djnz clwcolumn0
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,clw0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
clw0q
        pop bc
        dec c
        jr nz,clw0
        RET 

primgega_pixsz
;b=hgt,c=wid
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

;text
;        db "Hello world!",0
endtext
        db "Game over!",0
curxy 
        dw 0
oldcurxy 
        dw 0
    
curscore
        dw 0
font
        incbin "zx.fnt"

filename
	db "loyd.ini",0

        include "loydgfx.ast"
        
SAVEDATA
level
        db 0
cur_nfigures
        db 9
curtopmargin
        db 4
curbottommargin
        db 21
curleftmargin
        db 6
currightmargin
        db 27 ;31 for 11
curtopleft
        dw 0
curtarget
        dw 0
curmainboxsizes
        dw 0
FIGBUF
        DEFS FIGBUF_sz;100
FIGBUF2
        DEFS FIGBUF_sz;100
SAVEDATAsz=$-SAVEDATA

end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "loyd.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
