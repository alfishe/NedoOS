playmusic_hl
	ret

	display "showpicture ",showpicture
showpicture
	call setgraphpages
;	ld a,(screenpage1)
;	SETPG16K
	ld a,(picbufpage1)
	SETPG32KLOW
	ld hl,0x8000
	ld de,0x4000
	ld bc,0x4000
	ldir
	call setgraphpages
;	ld a,(screenpage2)
;	SETPG16K
	ld a,(picbufpage2)
;	SETPG32KLOW
	SETPG16K
	ld hl,0x4000
	ld de,0x8000
	ld bc,0x4000
	ldir
	call setpal
	call setscreen
	call setgraphpages
	ld hl,0xB400 ;clear botton 20 lines (all pictures are 320*180)
	call cleartoend_hl
	ret

loadpicture
	ld de,buf ;fn
	OS_OPENHANDLE
	or a
	jp nz,fileopenerror
	ld de,0x4000
	ld hl,0x8000
	push bc
	OS_READHANDLE
	pop bc
	or a
	jp nz,filereaderror
	ld hl,32 ;load palette
	ld de,pal
	push bc
	OS_READHANDLE
	pop bc
	OS_CLOSEHANDLE
	ret

setpal
	call makefadepixel
	call makewhitepixel
	call makefonttable
	ld de,(fadecolor)
	OS_SETBORDER
	ld de,pal
	OS_SETPAL
	ret

	display "setpal: ", setpal

nextscreen
	ld a,(screen)
	xor 1
	ld (screen),a
	ret

setscreen0
	ld de,0
	ld (screen),de
	OS_SETSCREEN
	ret

setscreen1
	ld de,1
	ld (screen),de
	OS_SETSCREEN
	ret

setscreen
	ld de,(screen)
	OS_SETSCREEN
	ret

get2pixeladdr ; hl - h=y (0-199) l=x(0-159). out hl=mem
	ld a,0x40
	srl l
	jr nc,get2pixeladdr_no4000
	xor 0xC0
get2pixeladdr_no4000
	srl l
	jr nc,get2pixeladdr_no2000
	or 0x20
get2pixeladdr_no2000
	ld e,l
	ld d,a
	push de
	ld e,h
	ld d,0
	ld hl,ytable
	sla e
	rl d
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	pop hl
	add hl,de
	ret

setcursor_hl ;h=y l=x sets plane and cursor offset
	ld (cursorx),hl
	push hl
	ld a,l ; a=x
	ld hl,setcursor_offset ; return address
	push hl
	and 0b00000011
	cp 3
	jp z,setplane4
	cp 2
	jp z,setplane3
	cp 1
	jp z,setplane2
	jp setplane1
setcursor_offset
	pop hl
	push hl 
	ld e,h
	ld d,0
	ld hl,ytable
	sla e ;*2
	rl d
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl) ; got y address by table
	pop hl
	srl l ; 2 bits shift
	srl l
	ld h,0
	add hl,de
	ld (cursoroffset),hl
	ret

	display "setcursor_hl: ",setcursor_hl

putpixel ; a-color, hl=x e=y
	;and 0b00001111
	srl h
	rr l
	jr c,putpixel_odd
	bit 3,a
	jr z,$+4
	or 64
	and 0b01000111
	ld b,a
	ld h,l
	ld l,e
	call get2pixeladdr
	ld (hl),b
	ret
putpixel_odd
	.3 sla a
	bit 6,a
	jr z,$+4
	or 128
	and 0b10111000
	ld b,a
	ld h,l
	ld l,e
	call get2pixeladdr
	ld a,(hl)
	or b
	ld (hl),a
	ret

setgraphpages
	ld a,(screen)
	or a
	jp nz,setgraphpages_screen1
setgraphpages_screen0
	ld a,(screenpage1)
	SETPG16K
	ld a,(screenpage2)
	SETPG32KLOW
	ret
setgraphpages_screen1
	ld a,(screenpage3)
	SETPG16K
	ld a,(screenpage4)
	SETPG32KLOW
	ret

setgamepages
	ld a,(win2page)
	SETPG16K
	ld a,(win3page)
	SETPG32KLOW
	ret

setpicbufpages
	ld a,(picbufpage1)
	SETPG16K
	ld a,(picbufpage2)
	SETPG32KLOW
	ret

printgr_hl
	ld a,(hl)
	or a
	ret z
	cp 0x0D
	jr nz,printgr_print
	call nextline
	jr printgr_skip
printgr_print
	push hl
	call printchar
	pop hl
printgr_skip
	inc hl
	jr printgr_hl

printchar ;a=char print char at current cursor position (draw to down-right)
	call get_char_address
	ld de,s_20 ;first symbol
	push hl
	pop ix
	inc ix
	inc ix
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld de,0x0028 ;one screen line
printchar_line
	push bc
	ld hl,(cursoroffset)
	push de
	call addplane
	pop de
	ld b,c
printchar_dot
	ld a,(ix)
	push hl
	push bc
	call convertpixel
	pop bc
	pop hl
	ld (hl),a
	inc ix
	add hl,de ; output by cols
	djnz printchar_dot
	call nextrow
	pop bc
	djnz printchar_line
	ret

convertpixel
	ld hl,fonttable
	ld bc,4
	cpir
	.3 inc hl
	ld a,(hl)
	ret

get_char_address ;a=char ;returns in hl addres of char matrix
	ld hl,font_table
	sub 0x20
	ld d,0
	ld e,a
	sla e ;*2
	rl d
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ret

setplane1_incoffset
	ld hl,(cursoroffset)
	inc hl
	ld (cursoroffset),hl

setplane1
	ld hl,plane1
	ld (nextplane0),hl
	ret

setplane2
	ld hl,plane2
	ld (nextplane0),hl
	ret

setplane3
	ld hl,plane3
	ld (nextplane0),hl
	ret

setplane4
	ld hl,plane4
	ld (nextplane0),hl
	ret

addplane ; adds plane offset to hl
nextplane0=$+2
	ld de,(plane1)
	add hl,de
	ret

nextrow
	ld hl,(nextplane0)
	inc hl
	inc hl
	ld a,(hl)
	inc hl
	ld h,(hl) ; loads next plane proc
	ld l,a
	push hl
	ret

	display "scroll:", scroll

scroll
	call getlinescount
	ld hl,(textstart)
	call get2pixeladdr
	push hl
	call scroll_copy
	pop hl
	ld de,0x2000
	add hl,de
	push hl
	call scroll_copy
	pop hl
	ld de,0x2000
	add hl,de
	push hl
	call scroll_copy
	pop hl
	ld de,0x2000
	add hl,de
	call scroll_copy
	ld a,190
	ld (cursory),a
	call cleartoend
	ld hl,(cursor)
	ld l,0
	call setcursor_hl
	ret
scroll_copy
	push hl
	ld de,0x28*10 ; высота строки
	add hl,de
	pop de
	ld bc,(linescount) ; насколько строк скролить
	ldir
	ret

getlinescount
	or a
	ld de,(textstarty)
	ld d,0
	ld hl,190
	sbc hl,de
	add hl,hl
	add hl,hl
	add hl,hl
	push hl
	add hl,hl
	add hl,hl
	pop de
	add hl,de
	ld (linescount),hl
	ret

printdelay
	ld b,1
printdelay0
	push af
	push de
	push hl
	push bc
	YIELD
	pop bc
	pop hl
	pop de
	pop af
	djnz printdelay0
	ret

cleartext
	ld hl,(textstart)
	call cleartoend_hl
	ret

cleartoend ;from y to bottom
	ld hl,(cursor)
cleartoend_hl
	call get2pixeladdr
	push hl
	ld de,0x5FFF
	ex hl,de
	xor a;TODO change to color
	sbc hl,de
	push hl
	pop bc
	pop hl
cleartoend_do
	ld a,(fadepixel)
	ld de,0x2000
	ld (hl),a
	add hl,de
	ld (hl),a
	add hl,de
	ld (hl),a
	add hl,de
	ld (hl),a
	ld de,0x5FFF
	sbc hl,de
	dec bc
	ld a,b
	or c
	jr nz,cleartoend_do
	ret

nextline
	ld a,(cursory)
	cp 190
	jp z,scroll
	add a,10
;	ld (cursory),a
	ld h,a
	ld l,0
	call setcursor_hl
	ret

fadeblack
	ld hl,fadepixel
	ld (fadeout0+1),hl
	jr fadeout

fadewhite
	ld hl,whitepixel
	ld (fadeout0+1),hl
	jr fadeout

fadeout
	ld hl,0x4000
	ld bc,7
fadeout1
	push bc
	ld bc,4680
	ld de,7
	xor a
fadeout0
	ld a,(fadepixel)
	ld (hl),a
	add hl,de
	dec bc
	push bc
	call fadedelay
	pop bc
	ld a,b
	or c
	jr nz,fadeout0
	ld de,0x7FF7
	sbc hl,de
	pop bc
	dec bc
	ld a,b
	or c
	jr nz,fadeout1
	ret

fadedelay
	ld b,0x10
fadedelay0
	nop
	djnz fadedelay0
	ret

bigdelay
	ld b,0x50
bigdelay0
	push bc
	YIELD
	pop bc
	djnz bigdelay0
	ret

fadein ;fade in from picbuf to graphpages
	ld hl,0x4000
	ld bc,7
	xor a
fadein1
	push bc
	ld bc,4680
	ld de,7
fadein0
	push bc
	call setpicbufpages
	ld a,(hl)
	push af
	call setgraphpages
	pop af
	pop bc
	ld (hl),a
	add hl,de
	dec bc
	ld a,b
	or c
	jr nz,fadein0
	ld de,0x7FF7
	sbc hl,de
	pop bc
	dec bc
	ld a,b
	or c
	jr nz,fadein1
	ret

makefonttable
	ld hl,fontcolors
	ld a,(whitepixel)
	ld c,a
	ld a,(fadepixel)
	ld b,a
	ld (hl),a
	inc hl
	and 0b10111000
	ld d,a
	ld a,c
	and 0b01000111
	or d
	ld (hl),a
	.2 inc hl
	ld a,c
	ld (hl),a
	dec hl
	and 0b10111000
	ld d,a
	ld a,b
	and 0b01000111
	or d
	ld (hl),a
	ret


makefadepixel ;e=result
	call findfadecolor
	ld bc,fadepixel
	ld (makecolorpixel0),bc
	jr makecolorpixel
makewhitepixel ;e=result
	call findwhitecolor
	ld bc,whitepixel
	ld (makecolorpixel0),bc
makecolorpixel
	push de
	ld a,0b00000111
	and e
	ld e,a
	.3 sla a
	or e
	ld e,a
	pop bc
	ld a,c
	bit 3,a
	jr z,$+6
	set 6,e
	set 7,e
makecolorpixel0=$+2
	ld (fadepixel),de
	ret

countcolorbits_hl ;hl=color
	ld bc,0x0800
	ld a,(hl)
	and 0b11110011
countcolorbits0
	srl a
	call c,countcolorbits1
	djnz countcolorbits0
	ld a,c
	ret
countcolorbits1
	inc c
	ret

findfadecolor ;e=result
	ld bc,0x0000
	ld de,0
	ld hl,pal
findfadecolor1
	push bc
	call countcolorbits_hl
	pop bc
	cp c
	jr c,findfadecolor0
	ld e,b
	ld c,a
findfadecolor0
	inc hl
	inc hl
	inc b
	ld a,b
	cp 16
	jr nz,findfadecolor1
	ld (fadecolor),de
	ret

findwhitecolor ;e=result
	ld bc,0x00FF
	ld de,0
	ld hl,pal
findwhitecolor1
	push bc
	call countcolorbits_hl
	pop bc
	cp c
	jr nc,findwhitecolor0
	ld e,b
	ld c,a
findwhitecolor0
	inc hl
	inc hl
	inc b
	ld a,b
	cp 16
	jr nz,findwhitecolor1
	ld (whitecolor),de
	ret

ytable
CNT=0x0000
	DUP 200
	dw CNT*40
CNT=CNT+1
	EDUP

fonttable
	db 0;font 
	db 2
	db 16
	db 18
fontcolors
	db 0;color
	db 2
	db 16
	db 18

plane1 dw 0x4000,setplane2
plane2 dw 0x8000,setplane3
plane3 dw 0x6000,setplane4
plane4 dw 0xA000,setplane1_incoffset
inactivegpage1	db 0
inactivegpage2	db 0

fadepixel	dw 0
fadecolor	dw 0
whitepixel	dw 0
whitecolor	dw 0
linescount	dw 0
textstart
textstartx	db 0
textstarty	db 170
cursor
cursorx		db 0 ;0-159
cursory		db 0 ;0-199
cursoroffset 	dw 0
screen		dw 0 ;Screen to draw
scrollpause 	db 0

	include font.asm