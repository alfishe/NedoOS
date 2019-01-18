on_int
        push af
        push bc
        push de
        push hl
        push ix
        push iy
        ex af,af'
        push af
        ld a,(_frameready)
        or a
        jr z,on_int_notready
	ld hl,(_readyattrbuf) ;_attrbuf
	ld de,0x5800
	ld bc,768
	ldir
        xor a
        ld (_frameready),a
on_int_notready
        call PLAY
	ld hl,(_timer)
	inc hl
	ld (_timer),hl
        pop af
        ex af,af'
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ei
        ret

border
border.A.=$+1
        ld a,0
        out (0xfe),a
        ret

halter
        halt
        ret

random
seed=$+1
        ld hl,0x0564;0x0562
        ld bc,0x0305
        add hl,bc
        ld a,(hl)
        inc h
        rrca
        rrca
        rrca
        rrca
        xor (hl)
        inc h
        rrca
        xor (hl)
        res 5,h
        ld (seed),hl
        ret

pokenet
pokenet.A.=$+2 ;row
pokenet.B.=$+1 ;col
        ld hl,0
        ld bc,_netaddr
        add hl,bc
pokenet.C.=$+1 ;data
        ld (hl),0
        ret

peeknet
peeknet.A.=$+2 ;row
peeknet.B.=$+1 ;col
        ld hl,0
        ld bc,_netaddr
        add hl,bc
        ld a,(hl)
        ret

pokenetcolor
pokenetcolor.A.=$+2 ;row
pokenetcolor.B.=$+1 ;col
        ld hl,0
        ld bc,_netcoloraddr
        add hl,bc
pokenetcolor.C.=$+1 ;data
        ld (hl),0
        ret

peeknetcolor
peeknetcolor.A.=$+2 ;row
peeknetcolor.B.=$+1 ;col
        ld hl,0
        ld bc,_netcoloraddr
        add hl,bc
        ld a,(hl)
        ret

prch
prch.A.=$+1 ;addr
        ld de,0
prch.B.=$+1 ;ch
        ld hl,0
	ld bc,font;-32
	add hl,bc
        ;add a,a
        ;ld l,a
        ;ld h,15
        ;add hl,hl
        ;add hl,hl
        ld b,8
prch0.
        ld a,(hl)
        ;rrca
        ;or (hl)
        ld (de),a
        inc h;l
        inc d
        djnz prch0.
        ret

;определяем цвет и двигаем _row (_col)
;если hgt==_curhgt, то пол и _row++ (_col--)
;если hgt>_curhgt, то стена
;если hgt<_curhgt, то _row++ (_col--) и крутимся
;_row,_col указывают на то, что мы видим в этой клетке, или на яму
;c=rowstep
;b=curcolor
;a=curhgt
;hl=rowcol
testcube.crosscolnc
;curhgt > hgt ;яма
        inc h;row
	dec c ;rowstep=TRUE
testcube.crossrow
;\ - пересечение _row, дальше идём по _col
;rowstep == TRUE
        cp (hl);hgt
;curhgt <= hgt ;стена пересечение row
	LD b,_clRed ;curcolor
	ret z
	ret c
;curhgt > hgt ;яма
        dec l;col
	inc c ;rowstep=FALSE
        dec a;d;curhgt
	;JP testcube.crosscol
testcube_s
;backslash==FALSE
	;inc c;SUB c;[_rowstep.]
	;dec c
	;ret nz ;чётность не соответствует, так что границы не будет
testcube.crosscol
;/ - пересечение _col, дальше идём по _row
;rowstep == FALSE
	cp (hl);hgt
	jr NZ,testcube.crosscolnz
;curhgt == hgt ;пол (только при правильной чётности!)
        set 7,l
        ld b,(hl);curcolor
        res 7,l
        inc h;row
	dec c ;rowstep=TRUE
	ret
testcube.crosscolnz
	jr NC,testcube.crosscolnc
;curhgt < hgt ;стена пересечение _col
        inc a;d;curhgt ;теперь чётность _rowstep не соответствует _backslash!
	LD b,_clBlue ;curcolor
        ret

testcube_bs.crossrownc
;curhgt > hgt ;яма
        dec l;col
	inc c ;rowstep=FALSE
testcube_bs.crosscol
;/ - пересечение _col, дальше идём по _row
;rowstep == FALSE
	cp (hl);hgt
;curhgt <= hgt ;стена пересечение _col
	LD b,_clBlue ;curcolor
	ret z
	ret c
;testcube_bs.ba
;curhgt > hgt ;яма
        inc h;row
	dec c ;rowstep=TRUE
        dec a;d;curhgt
	;JP testcube_bs.crossrow
testcube_bs
;backslash==TRUE
	;inc c;SUB c;[_rowstep.]
	;dec c
	;ret z ;чётность не соответствует, так что границы не будет
testcube_bs.crossrow
;\ - пересечение _row, дальше идём по _col
;rowstep == TRUE
        cp (hl);hgt
	jr NZ,testcube_bs.crossrownz
;curhgt == hgt ;пол (только при правильной чётности!)
        set 7,l
        ld b,(hl);curcolor
        res 7,l
        dec l;col
	inc c ;rowstep=FALSE
	ret
testcube_bs.crossrownz
	jr NC,testcube_bs.crossrownc
;curhgt < hgt ;стена пересечение row
        inc a;d;curhgt ;теперь чётность _rowstep не соответствует _backslash!
	LD b,_clRed ;curcolor
	ret
 
cubecolumn
;lx=y
;hx=oldcolor
;b=curcolor
;c=rowstep
;hl=rowcol
;de=addr
        ld hl,(_col)
        ld a,(_row)
        add a,_netaddr>>8
        ld h,a
	;ld hx,0x07;oldcolor
	ld b,0x07;curcolor
	LD A,[_addr]
	AND 0x02
	JR Z,cubecolumn_bs.
	LD c,0;[_rowstep],A
	xor a ;curhgt
	LD lx,+(_hgt-_scrhgt)/2 ;y
cubecolumn0
	inc c
	dec c
	CALL z,testcube_s
	LD hx,b;oldcolor=curcolor
	inc c
	dec c
	CALL nz,testcube_bs
	LD hx,b;oldcolor=curcolor
	dec lx ;y
	JP NZ,cubecolumn0
	LD de,[_addr]
	LD lx,_scrhgt/2 ;y
cubecolumn1
	inc c
	dec c
	CALL z,testcube_s
	ex af,af'
	LD A,b;[_curcolor]
	add a,a
	add a,a
	add a,a
	ADD A,hx;oldcolor
	LD [de],A
	inc e
	LD [de],A
        res 5,e
	LD hx,b;oldcolor=curcolor
	ex af,af'
	inc c
	dec c
	CALL nz,testcube_bs
	ex af,af'
	LD A,b;[_curcolor]
	add a,a
	add a,a
	add a,a
	ADD A,hx;oldcolor
	LD [de],A
	dec e
	LD [de],A
	ld a,e
	sub 0x20
	ld e,a
	jr nc,$+3
	dec d
	LD hx,b;oldcolor=curcolor
	ex af,af'
	dec lx ;y
	JP NZ,cubecolumn1
	RET 

cubecolumn_bs.
	LD c,0xff;[_rowstep],A
	xor a ;curhgt
	LD lx,+(_hgt-_scrhgt)/2 ;y
cubecolumn_bs0
	inc c
	dec c
	CALL nz,testcube_bs
	LD hx,b;oldcolor=curcolor
	inc c
	dec c
	CALL z,testcube_s
	LD hx,b;oldcolor=curcolor
	dec lx ;y
	JP NZ,cubecolumn_bs0
	LD de,[_addr]
	LD lx,_scrhgt/2 ;y
cubecolumn_bs1
	inc c
	dec c
	CALL nz,testcube_bs
	ex af,af'
	LD A,b;[_curcolor]
	add a,a
	add a,a
	add a,a
	ADD A,hx;oldcolor
	LD [de],A
	inc e
	LD [de],A
        res 5,e
	LD hx,b;oldcolor=curcolor
	ex af,af'
	inc c
	dec c
	CALL z,testcube_s
	ex af,af'
	LD A,b;[_curcolor]
	add a,a
	add a,a
	add a,a
	ADD A,hx;oldcolor
	LD [de],A
	dec e
	LD [de],A
	ld a,e
	sub 0x20
	ld e,a
	jr nc,$+3
	dec d
	LD hx,b;oldcolor=curcolor
	ex af,af'
	dec lx ;y
	JP NZ,cubecolumn_bs1
	RET 

getayreg
getayreg.A.=$+1
	ld a,0x00
getayrega.
	ld bc,0xfffd
	out (c),a
	in a,(c)
	ret

jumpay
jumpay.A.=$+1
jumpay.tonereg=$+1
	LD A,0
	CALL getayrega.
	LD L,A
	LD A,[jumpay.tonereg]
	inc a
	CALL getayrega.
	LD h,A
	push hl;LD [jumpay.frq],hl
	LD A,0x07 ;tone/noise mask reg
	CALL getayrega.
	cpl
jumpay.C.=$+1
jumpay.mask=$+1
	AND 0
	JP Z,jumpay.e. ;both masked
jumpay.B.=$+1
jumpay.volreg=$+1
	LD A,0
	CALL getayrega.
	LD lx,A
	cp 0x10
	JP C,jumpay.g.
	LD lx,0x04
	JP jumpay.h.
jumpay.g.
	cp 0x0f
	JP NZ,jumpay.i.
	LD lx,0x06
	JP jumpay.j.
jumpay.i.
	cp 0x0e
	JP NZ,jumpay.k.
	LD lx,0x05
	JP jumpay.l.
jumpay.k.
	cp 0x0d
	JP NZ,jumpay.m.
	LD lx,0x04
	JP jumpay.n.
jumpay.m.
	cp 0x0c
	JP NZ,jumpay.o.
	LD lx,0x03
	JP jumpay.p.
jumpay.o.
	cp 0x0b
	JP NZ,jumpay.q.
	LD lx,0x02
	JP jumpay.r.
jumpay.q.
	cp 0x09
	JP C,jumpay.s.
	LD lx,0x01
	JP jumpay.t.
jumpay.s.
	LD lx,0x00
jumpay.t.
jumpay.r.
jumpay.p.
jumpay.n.
jumpay.l.
jumpay.j.
jumpay.h.
	JP jumpay.f.
jumpay.e.
	LD lx,0x00
jumpay.f.
	;LD A,[jumpay.volreg]
	;SUB 0x09
	;JP Z,jumpay.u.
	LD A,lx
	ADD A,a
	LD lx,A
jumpay.u.
	pop hl;LD HL,[jumpay.frq]
	LD DE,8
	ADD HL,DE
	;LD [jumpay.frq],HL
	;LD A,0x02
	LD hx,0x02;[jumpay.y],A
	;LD HL,[jumpay.frq]
jumpay.w.
	LD DE,1000
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,jumpay.x.
        ld d,h
        ld e,l
        srl d
        rr e
        srl d
        rr e
	ADD HL,DE
	;LD HL,jumpay.y
	;INC [HL]
        inc hx;y
	JP jumpay.w.
jumpay.x.
	LD A,[jumpay.volreg]
	SUB 0x08
	JP NZ,jumpay.y.
	LD A,hx;[jumpay.y]
        srl a
        srl a
	LD L,A
	LD H,0
	XOR A
	SUB L
	LD L,A
	SBC A,H
	SUB L
	LD H,A
	LD [jumpay.x],HL
	JP jumpay.ba.
jumpay.y.
	LD A,[jumpay.volreg]
	SUB 0x0a
	JP NZ,jumpay.bb.
	LD A,hx;[jumpay.y]
        srl a
        srl a
	LD L,A
	LD H,0
	LD [jumpay.x],HL
	JP jumpay.bc.
jumpay.bb.
	LD HL,-0
	LD [jumpay.x],HL
jumpay.bc.
jumpay.ba.
	LD a,[jumpay.x]
	add a,hx;[jumpay.y]
	LD [_row],A
	LD E,hx;y
	LD D,0
	LD BC,[jumpay.x]
	LD A,E
	SUB C
	LD E,A
	LD A,D
	SBC A,B
	LD D,A
	LD A,0x19
	SUB E
	LD [_col],A
	LD [peeknet.B.],A
	LD A,[_row]
	LD [peeknet.A.],A
	CALL peeknet
	SUB lx
	ret nc
	LD A,[_row]
	LD [pokenet.A.],A
	LD A,[_col]
	ADD A,0x40
	LD [pokenet.B.],A
	LD A,lx
	LD [pokenet.C.],A
	jp pokenet
jumpay.x
        dw 0

decay
;спадение анализатора 80000 тактов (+ ниже копирование)
;можно ускорить в 2 раза, потому что половина не попадает в экран (но сложная форма)
	ld h,0x01+(_netaddr>>8)
	ld c,0x15
decay0
	ld l,0x41
        ld d,h
        ld e,l
        set 7,e
	ld b,0x19
decay00
	ld a,(hl)
	inc a
	inc h
	cp (hl)
	dec h
	jr C,decaypoke ;up
	dec l
	cp (hl)
	inc l
	jr C,decaypoke ;up
	dec h
	cp (hl)
	inc h
	jr C,decaypoke ;up
	inc l
	cp (hl)
	dec l
	jr C,decaypoke ;up
        dec a
	jr Z,decaypoke ;as is
	dec a ;decay
decaypoke
	;set 7,l
        ;or a
        ;jr nz,$+3
        ;inc a
	ld (de),a
	;res 7,l
        inc e
	inc l
	djnz decay00
	inc h
	dec c
	jp nz,decay0

;копирование 40000 тактов - можно ускорить в 2 раза, потому что половина не попадает в экран (но сложная форма)
	ld h,0x01+(_netaddr>>8)
	ld hx,0x15
decaycopyback0
	ld l,0x41
	ld d,h
	ld e,l
	set 7,l
	ld bc,0x19
	ldir
        ld l,0x41
        ld e,0x01
        ld bc,0x193f
decaycopyback00
        ld a,(hl)
        rra;sra a
        rra;sra a
        and c ;0x3f
        inc a
        ld (de),a
        inc l
        inc e
        djnz decaycopyback00
	inc h
	dec hx
	jp nz,decaycopyback0
	ret

clearnet
        ld hl,_netaddr
        ld d,h
        ld e,l
        inc de
        ld bc,0x15ff
        ld (hl),l;0
        ldir
        ret

drawcubetexture
        ;halt
        ;ld hl,0x5800
        ;ld d,h
        ;ld e,l
        ;inc de
        ;ld bc,0x2ff
        ;ld (hl),l;0
        ;ldir
        ld hl,0x4000
        ld d,h
        ld e,l
        inc de
        ld bc,0x17ff
        ld (hl),l;0
        ldir
	;LD HL,0x4000
	;LD [drawcubetexture.addr],HL
	LD hx,0x00 ;y
drawcubetexture.j.
	LD A,hx;[drawcubetexture.y]
	cp _scrhgt
	JP NC,drawcubetexture.k.
	LD a,hx ;y
        add a,a
        add a,a
        add a,a
        add a,a
        add a,a
	LD L,A
	LD A,0x18
	AND hx ;y
        add a,0x40
	LD H,A
	LD [drawcubetexture.addry],hl
	LD lx,0x00 ;x
drawcubetexture.l.
	LD A,lx;[drawcubetexture.x]
	SUB _wid
	JP NC,drawcubetexture.m.
drawcubetexture.addry=$+1
	LD HL,0
	;LD A,[drawcubetexture.x]
	LD E,lx ;x
	LD D,0
	ADD HL,DE
	LD b,0x08
	LD A,lx;[drawcubetexture.x]
        rra
	XOR hx;[drawcubetexture.y]
	rra
	JP c,drawcubetexture.n.
	LD de,0x0001
drawcubetexture.p.
	LD [hl],d
        inc l
	LD [HL],E
        dec l
        scf
        rl e
        rl d
        scf
        rl e
        rl d
        inc h
	djnz drawcubetexture.p.
drawcubetexture.q.
	JP drawcubetexture.o.
drawcubetexture.n.
	LD de,0x8000
drawcubetexture.r.
        ld (hl),d
        inc l
	LD [HL],E
        dec l
        scf
        rr d
        rr e
        scf
        rr d
        rr e
        inc h
	djnz drawcubetexture.r.
drawcubetexture.o.
	;LD A,[drawcubetexture.x]
	;ADD A,0x02
	;LD [drawcubetexture.x],A
        inc lx ;x
        inc lx ;x
	JP drawcubetexture.l.
drawcubetexture.m.
	;LD HL,drawcubetexture.y
	;INC [HL]
        inc hx ;y
	JP drawcubetexture.j.
drawcubetexture.k.
        ret
