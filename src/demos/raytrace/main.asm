        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

EGA=1;0

COLOR_SKY=0b11101101
COLOR_SKYDARK=0b00101101
COLOR_SHADOW=0
COLOR_SQUARE0=0b00001001
COLOR_SQUARE1=0b11110110

;GO=0x6001;0x8001

SCRHGT=176
YMID88=88

SQUAREMUL=1
SQUARESQR=1
showtime=0;1
fastest=1
original_coords=1

;IMVEC=0x7d00;0xae00;0xbe00
;IMER=(IMVEC/256+1)*257
        
SQRTFIXK=256
FIXK=(SQRTFIXK*SQRTFIXK)
FIXKDIV2=(FIXK/2)

spheres=0x02

cx0=-(30*FIXK/100>>8) ;-30
cy0=-(80*FIXK/100>>8) ;-80
cz0=(300*FIXK/100>>8) ;300
r0=(60*FIXK/100>>8) ;60

        if original_coords
cx1=(83*FIXK/100>>8) ;90 ;88
cy1=-(120*FIXK/100>>8) ;-110 ;-114
cz1=(200*FIXK/100>>8)
r1=(20*FIXK/100>>8)
        else
cx1=(87*FIXK/100>>8) ;90
cy1=-(100*FIXK/100>>8) ;-110 (100 оптимизируется MegaLZ)
cz1=(200*FIXK/100>>8) ;200 (200 оптимизируется MegaLZ)
r1=(20*FIXK/100>>8) ;20
        endif

q0=(r0*r0>>8)
q1=(r1*r1>>8)
        
GROUND=0x3e;0x7f ;код команды ld a,N
SKY=0xff
EYEX=(30*FIXK/100)
EYEY=-(50*FIXK/100)
EYEZ=(0*FIXK/100)
KVECTOR=64
;EYEDZ=(300*FIXK/KVECTOR)
EYEDZ=(256*FIXK/KVECTOR)
EYEDZDIVFIXK=(EYEDZ/SQRTFIXK)
SQEYEDZ=(EYEDZDIVFIXK*EYEDZDIVFIXK) 

        include "math.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        org PROGSTART
begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        ld hl,1234
        OS_HIDEFROMPARENT
       if EGA
        ld e,0+0x80 ;EGA + keep gfx pages
       else
        ld e,3+0x80 ;6912 + keep gfx pages
       endif
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ld e,0
        OS_CLS

        if EGA == 0
        ld a,(user_scr0_high) ;ok
        SETPG16K
        xor a
        ;out (0xfe),a
        ld de,0x5801
        ld h,d
        ld l,a
        ld bc,767
        ld (hl),7
        ldir
        endif

        if SQUAREMUL
;d.e * b.c = 0.5*(d.e+b.c)^2 - 0.5*d.e^2 - 0.5*b.c^2
;адрес в таблице: %1hhhhhhh.lllllll0
;максимум = 127^2/2 = #1f80
	;ex de,hl ;hl=0 after dehrum
        ld de,#8000
        ;ld sp,hl
        xor a ;сумма мл
        ld h,a
        ld l,a
        ;ld d,a
        ;ld e,a
        ;ld b,a
        ;ld c,a
        ;ld de,0 ;сумма
        ld bc,0 ;счётчик
        ld lx,a ;счётчик мл
mksquare
        ex de,hl
        ld (hl),e
        inc l
        ld (hl),d
        inc lx
        inc lx
        inc lx
        inc lx
        jr nz,$+3
        inc bc
        add a,lx
        ex de,hl ;тут лучше
        adc hl,bc
        ;ex de,hl
        
        ;inc hl
        ;inc h
        ;dec h
	inc de
	inc d
	dec d
        jr nz,mksquare
        endif

        if !SQUARESQR
        ld bc,1
        ld de,tsqr
        ;ld hl,0 ;выгоднее на MegaLZ и Hrum (после dehrum уже hl=0, de=rnd, bc=#1010)
mksqr0
        ex de,hl
        ld (hl),e
        inc h
        ld (hl),d
        dec h
        ex de,hl
        add hl,bc
        inc bc
        inc bc
        inc e
        jr nz,mksqr0
;e=0
;hl=0
;bc=0x201
        endif

        if showtime
        ld de,IMVEC;0xbe00 ;выгоднее на MegaLZ
        ld a,d
        ld i,a
        inc a
        ;ld a,IMER/256
        ld (de),a
        inc e
        jr nz,$-2
        inc d
        ld (de),a
        ld e,d
        ld hl,on_int.
         ld b,1
        ldir
        im 2
        ei
        else
        ;di
raytrace_begin
        ;ld a,0xaf
        endif

        if 1==1
        ld l,2*(spheres-1)+1
mkbounding0
        push hl
         dec l
        ld h,cz/256
        ld c,(hl)
        inc l
        ld b,(hl)
;de=cz
        ;ld hl,-EYEZ ;0
        ;add hl,de
        ;ld b,h
        ;ld c,l
;bc=sub(cz[k],EYEZ) >= 0
        ;pop hl
        ;push hl
        inc h ;ld h,rad/256
        ld d,(hl)
        dec l
        ld e,(hl)
        ld a,d
        or a
        ex af,af' ;'
        DIVDEBC_AXSIGN_NONEGBC ;(keep bc)
        pop hl
        ld h,projr/256
        push hl
        ld (hl),e
        
        ld h,cx/256
        ld d,(hl)
        dec l
        ld e,(hl)
        ld hl,-((EYEX>>8)&0xffff)&0xffff
        add hl,de
        ex de,hl
        ld a,d
        or a
        ex af,af' ;'
        DIVDEBC_AXSIGN_NONEGBC ;(keep bc)
        pop hl
        inc h
        push hl
        ;ld h,projx/256
        ld (hl),e
        
        ld h,cy/256
        ld d,(hl)
        dec l
        ld e,(hl)
        ld hl,-((EYEY>>8)&0xffff)&0xffff
        add hl,de
        ex de,hl
        ld a,d
        or a
        ex af,af' ;'
        DIVDEBC_AXSIGN_NONEGBC ;(keep bc)
        pop hl
        ;inc h
        ;ld h,projy/256
         dec l
        ld (hl),e

        dec l
        jp p,mkbounding0
        
        endif
        
;  i = 0x00;
;  REPEAT {
;    //eyedy = ((FLOAT)(88)-(FLOAT)(i))<<10L;
;    //eyedy = mul(((FLOAT)(88)-(FLOAT)(i))*FIXK, MULVECTOR);
;    //sqeyedy = sq(eyedy);
;    count_eyedy();
;    j = 0x00;
;    REPEAT {
;      tracepixel(i,j);
;      INC j;
;    }UNTIL (j == 0x00);
;    INC i;
;  }UNTIL (i == 0xb0);
        ld a,SCRHGT-1;0xaf
raytrace_lines0        
;//eyedy = ((FLOAT)(88)-(FLOAT)(i))<<10L;
;//eyedy = mul(((FLOAT)(88)-(FLOAT)(i))*FIXK, MULVECTOR);
        ld (tracepixel.i),a
        sub YMID88
         ld (scryHSB),a
        ld l,a
        SBC A,a
        ld h,a
        add hl,hl
        add hl,hl
        LD [eyedyUINT],hl
        SQHL
        LD hl,+(SQEYEDZ>>8)&0xffff
        add hl,de
	LD [sqeyedyUINT],HL
        
       if EGA
        xor a ;X
raytrace_pixels0
       push af ;X
        and 2
        ld a,(user_scr0_high) ;ok
        jr nz,$+5
        ld a,(user_scr0_low) ;ok
        SETPG16K
       pop af
       push af
        call tracepixel ;A=pixel color
        ex af,af' ;'
        ld hl,(tracepixel.i) ;Y
        ld h,0x40/32
        ld b,0
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc ;*5
        add hl,hl
        add hl,hl
        add hl,hl ;Y*40
       pop af ;X
        ld c,a
        ex af,af' ;'
        srl c ;X0 TODO
        jr c,raytrace_pixel_right
        and 0b01000111
        jr raytrace_pixel_leftq
raytrace_pixel_right
        and 0b10111000
raytrace_pixel_leftq
        srl c
        srl c
        jr nc,$+4
         set 5,h
        inc c
        inc c
        inc c
        inc c
        ld b,0
        add hl,bc
        or (hl)
        ld (hl),a
        ex af,af' ;'

        inc a
        jr nz,raytrace_pixels0
        
       else
        ld a,(tracepixel.i) ;Y
        ld c,0
        ;call 8880
        ld b,a
        and a
        rra
        scf
        rra
        and a
        rra
        xor b
        and 0xf8
        xor b
        ld h,a
        ld a,c
        rlca
        rlca
        rlca
        xor b
        and 0xc7
        xor b
        rlca
        rlca
        ld l,a
        xor a ;X
raytrace_pixels0
        push af
         push hl
        call tracepixel ;CY=pixel color
         pop hl
        rl (hl)
        pop af
        inc a
        push af
        and 7
        jr nz,nonextbyte
        inc l
nonextbyte
        pop af
        jr nz,raytrace_pixels0
       endif
tracepixel.i=$+1
        ld a,0
        dec a;sub 1
        jp nz,raytrace_lines0
        
        YIELDGETKEYLOOP
        QUIT
        
        if showtime
        ld iy,23610
        ld hl,10072
        exx
        im 1
_TIMER=$+1
        ld bc,0
        sla c
        rl b
        ld sp,0x5fe8
        ;ret

on_int.
        push hl
;_TIMER=$+1+IMER-on_int.
	ld hl,(_TIMER);0
	inc hl
	ld (_TIMER),hl
        pop hl
        ei
        ret
        else
	if 1==1
        halt
	else
        ;ld hl,cz
        ;ld a,(hl)
        ;sub 5
        ;ld (hl),a
        ;ld hl,cz+2
        ;ld a,(hl)
        ;add a,5
        ;ld (hl),a
        
        ld hl,cy
        inc (hl)
        ;inc hl
        ;inc hl
        ;dec (hl)
        jp raytrace_begin
	endif
        endif

tracepixel
;//x = EYEX;
;//y = EYEY;
;//z = EYEZ;
;//dx = ((FLOAT)(j)-(FLOAT)(128))<<10L; //dx = mul(((FLOAT)(j)-(FLOAT)(128))*FIX
;//dy = eyedy;
;//dz = EYEDZ; //mul((FLOAT)(300)*FIXK, MULVECTOR);
;//dd = sq(dx) + sqeyedy + SQEYEDZ; //sq(dz); //dx*dx+dy*dy+dz*dz;
;a = j
eyedyUINT=$+1
        LD hl,0 ;+(EYEDZ>>8)&0xffff и т.п. невыгодно
        LD [tracepixel.dyUINT],HL
        LD HL,+(EYEDZ>>8)&0xffff
        LD [tracepixel.dzUINT],HL
        LD hl,+(EYEX>>8)&0xffff
        LD [tracepixel.xUINT],hl
        LD hl,+(EYEZ>>8)&0xffff ;ld l,h проигрывает 2 байта в MegaLZ, 1 байт в Hrum
        LD [tracepixel.zUINT],hl
        LD hl,+(EYEY>>8)&0xffff
        LD [tracepixel.yUINT],hl
        sub l;128
         ld (scrxHSB),a
        ld l,a
        SBC A,a
        ld h,a
        add hl,hl
        add hl,hl
        ld (tracepixel.dxUINT),hl
        SQHL ;out: de
sqeyedyUINT=$+1
        LD hl,+(SQEYEDZ>>8)&0xffff;0
        add hl,de
        LD [tracepixel.ddUINT],HL
tracepixel.L100
;//IF (positive(y) || negative(dy)) { n = SKY; s = 0x7fffffffL; }ELSE { n = GROUND; s = neg(idiv(y, dy)); };

        LD BC,[tracepixel.dyUINT] ;лучшая перестановка
       ld hl,[tracepixel.yUINT]
       ld a,h
       cpl
       or b
        LD [tracepixel.sUINT+1],a
        JP M,skyorground_count_s.q
;P
         ex de,hl ;de=y
       DIVDEBC_ASIGN ;de / bc
        LD [tracepixel.sUINT],de
        LD A,GROUND
skyorground_count_s.q
        LD [tracepixel.n],A
        
        ld l,2*(spheres-1)+1
checkbounding0
        ld h,projr/256
        ld e,(hl) ;projr
        inc h;ld h,projx/256
scrxHSB=$+1
        ld a,GROUND;0
        sub (hl) ;a = SCRX - projx
        dec l
        add a,e ;a = SCRX - (projx-projr)
        jp m,tracepixel.NOTFOUNDb
        srl a
        cp e
        jp nc,tracepixel.NOTFOUNDb
        ;inc h;ld h,projy/256
scryHSB=$+1
        ld a,GROUND;0
        sub (hl) ;a = SCRY - projy
        add a,e ;a = SCRY - (projy-projr)
        jp m,tracepixel.NOTFOUNDb
        srl a
        cp e
        ;jr nc,tracepixel.NOTFOUNDb
        jr c,checkspheres
         ;ld a,(scrxHSB)
         ;ld hl,scryHSB
         ;xor (hl)
         ;rra
         ;ret c
tracepixel.NOTFOUNDb
        dec l
        jp p,checkbounding0
        jp checkspheresq
        
checkspheres
         ;jp tracepixel.NOTFOUND
	ld a,2*(spheres-1)
tracepixel.checkspheres0
	LD [tracepixel.k],A
;//ищем сферу, на которую смотрим (если есть)
;//px = cx[k] - x;
;//py = cy[k] - y;
;//pz = cz[k] - z;
;//pp = sq(px) + sq(py) + sq(pz);
;//sc = mul(px,dx) + mul(py,dy) + mul(pz,dz); 
       ld (count_pxpypzppsc_cxaddr),a
       ld (count_pxpypzppsc_cyaddr),a
       ld (count_pxpypzppsc_czaddr),a
       
;центр проекции сферы: cx[k]/pz, cy[k]/pz
;радиус проекции сферы: r[k]/pz
;    IF (!(
;        (SCRX >= sub(projx[k],projr[k]))
;      &&(SCRX < add(projx[k],projr[k]))
;      &&(SCRY >= sub(projy[k],projr[k]))
;      &&(SCRY < add(projy[k],projr[k]))
;       )) {
;      goto L200; //не та сфера
;    };
        
count_pxpypzppsc_czaddr=$+1
        ld hl,(cz)
tracepixel.zUINT=$+1
        LD bc,0;x0101
        ;or a
        SBC HL,bc
        push hl ;pz=cz[k]-z
        SQHL ;out: de
        ld hy,d
        ld ly,e ;sq(pz)
count_pxpypzppsc_cyaddr=$+1
        ld hl,(cy)
tracepixel.yUINT=$+1
        LD bc,0;x0101
        ;or a
        SBC HL,bc
        push hl ;py=cy[k]-y
        SQHL ;out: de
        add iy,de ;sq(pz) + sq(py)
count_pxpypzppsc_cxaddr=$+1
        ld hl,(cx)
tracepixel.xUINT=$+1
        LD bc,0;x0101
        SBC HL,bc
        push hl ;px=cx[k]-x
        SQHL ;out: de
        add iy,de
        LD [tracepixel.ppUINT],iy ;pp = sq(px) + sq(py) + sq(pz)
        
        pop bc ;px=cx[k]-x
tracepixel.dxUINT=$+1
        LD de,0;x1111
        MULDEBC_TOIY
        pop bc ;py=cy[k]-y
tracepixel.dyUINT=$+1
        LD de,0;x1111
        MULDEBC
        add iy,de
        pop bc ;pz=cz[k]-z
tracepixel.dzUINT=$+1
        LD de,0;x1111
        MULDEBC
        add iy,de ;sc = mul(px,dx) + mul(py,dy) + mul(pz,dz)
;//IF (negative(sc)) { goto L200; }; //не та сфера
;//bb = idiv(sq(sc),dd); //sc*sc/dd;
;//aa = q[k]-pp+bb; //add(sub(q[k],pp),bb); //q[k]-pp+bb;
;//IF (negative(aa)) { goto L200; }; //не та сфера
;//s = idiv(root(bb)-root(aa), root(dd)); //(sqrt(bb)-sqrt(aa))/sqrt(dd);
;//n = k;
;//goto LFOUND;
;//L200:
       ld d,hy
       ld e,ly ;de = sc = mul(px,dx) + mul(py,dy) + mul(pz,dz) ;ниже невыгодно в MegaLZ (2 байта)
	LD a,d
        or a;rla
	JP M,tracepixel.NOTFOUND ;выгоднее в MegaLZ
	if SQUARESQR
        set 7,d
        res 0,e
        ex de,hl
        ld e,(hl)
        inc l
        ld d,(hl)
	;ld a,l
	;cp 8 ;костыль для младшего бита
        rl e;sla e
        rl d
	else
        SQDE
	endif
tracepixel.ddUINT=$+1
	LD bc,0
        DIVDEBC_POSITIVE ;de = bb
        ld hl,(q)
tracepixel.k=$-2
checksphereradius_qaddr=$-2
        add hl,de ;q[k]+bb ;CY=0, т.к. q[k] (>=0) + bb (>=0)
tracepixel.ppUINT=$+1
	LD bc,0;x0101
        ;or a
        sbc hl,bc ;q[k]+bb-pp
	JP M,tracepixel.NOTFOUND
         push de ;bb
        ROOTHL
         ex (sp),hl ;push sqrt(aa), pop bb
        ROOTHL;call root0hl0
         pop bc ;sqrt(aa)
        ;or a
	SBC HL,bc ;hl = sqrt(bb)-sqrt(aa)
         push hl
	LD hl,[tracepixel.ddUINT]
        ROOTHL
        ld b,h
        ld c,l ;bc = sqrt(dd)
         pop de ;de = sqrt(bb)-sqrt(aa)
        DIVDEBC_POSITIVE ;sqrt(bb)-sqrt(aa) >= 0
	LD [tracepixel.sUINT],de ;s = (sqrt(bb)-sqrt(aa))/sqrt(dd)
	LD A,(tracepixel.k);0x3e
	LD [tracepixel.n],A
        ;de = s
	jr tracepixel.FOUND
tracepixel.NOTFOUND ;не та сфера
        ld a,(tracepixel.k)
	sub 2
	JP nc,tracepixel.checkspheres0
checkspheresq

	LD A,[tracepixel.n]
	or a ;SUB 0x80
       if EGA
tracepixel.sUINT=$+1
        LD de,0
	jp M,tracepixel.sky ;//небо
       else
	ret M ;nc ;//небо
tracepixel.sUINT=$+1
        LD de,0
       endif
tracepixel.FOUND
;de = s
;//dx = mul(dx,s); //dx*s;
;//dy = mul(dy,s); //dy*s;
;//dz = mul(dz,s); //dz*s;
;//dd = mul(sq(s),dd); //dd*s*s;
;//x = x + dx;  //x+dx;
;//y = y + dy; //y+dy;
;//z = z + dz; //z+dz;
        if SQUAREMUL
        set 7,d
        res 0,e
        endif
	LD bc,(tracepixel.dxUINT)
	MULDEBC_TOHL_DEPOSITIVE
        if SQUAREMUL
        dec e
        endif
	LD [tracepixel.dxUINT],hl ;dx = dx*s
	LD bc,[tracepixel.xUINT]
        add hl,bc
	LD [tracepixel.xUINT],hl ;x = x+dx
	LD bc,[tracepixel.dyUINT]
	MULDEBC_TOHL_DEPOSITIVE
        if SQUAREMUL
        dec e
        endif
	LD [tracepixel.dyUINT],hl ;dy = dy*s
	LD bc,[tracepixel.yUINT]
        add hl,bc
	LD [tracepixel.yUINT],hl ;y = y+dy
	LD bc,[tracepixel.dzUINT]
	MULDEBC_TOHL_DEPOSITIVE
        if SQUARESQR&SQUAREMUL
        dec e ;выигрыш 1 байт по сравнению с dec l
	endif
	LD [tracepixel.dzUINT],hl ;dz = dz*s
	LD bc,[tracepixel.zUINT]
        add hl,bc
	LD [tracepixel.zUINT],hl ;z = z+dz

        if SQUARESQR&SQUAREMUL
        ex de,hl
        ld e,(hl)
        inc l
        ld d,(hl)
	ld a,l
	cp 8 ;костыль для младшего бита
        rl e;sla e
        rl d
        else
	LD HL,[tracepixel.sUINT]
        SQHL ;out: de
        endif
	LD bc,[tracepixel.ddUINT]
        MULDEBC_TOHL_POSITIVE
	LD [tracepixel.ddUINT],hl ;dd = dd*s*s

tracepixel.n=$+1
	LD A,0x3e
	cp GROUND
	JP z,tracepixel.ground ;//земля
;//nx = x - cx[n];
;//ny = y - cy[n];
;//nz = z - cz[n];
;//l = idiv(mul2( mul(dx,nx) + mul(dy,ny) + mul(dz,nz)), /**nn*/sq(nx) + sq(ny) 
;//dx = dx - mul(nx,l); //dx-nx*l;
;//dy = dy - mul(ny,l); //dy-ny*l;
;//dz = dz - mul(nz,l);  //dz-nz*l;
        ld (count_reflection_cxaddr),a
        ld (count_reflection_cyaddr),a
        ld l,a
	LD h,cz/256
        ld c,(hl)
        inc l
        ld b,(hl)
	LD HL,[tracepixel.zUINT]
	SBC HL,BC
	LD [tracepixel.nz],HL ;z-cz[n]
        SQHL ;out: de
	ld hy,d
        ld ly,e
count_reflection_cyaddr=$+2
	LD bc,(cy)
	LD HL,[tracepixel.yUINT]
	SBC HL,BC
	LD [tracepixel.ny],HL ;y-cy[n]
        SQHL ;out: de
        add iy,de
count_reflection_cxaddr=$+2
	LD bc,(cx)
	LD HL,[tracepixel.xUINT]
	SBC HL,BC
	LD [tracepixel.nx],HL ;x-cx[n]
        SQHL ;out: de
        add iy,de
         push iy ;делитель = sq(nx)+sq(ny)+sq(nz)

tracepixel.nx=$+1
        LD bc,0;x0101
	LD de,[tracepixel.dxUINT]
	MULDEBC_TOIY
tracepixel.ny=$+1
        LD bc,0;x0101
	LD de,[tracepixel.dyUINT]
	MULDEBC
        add iy,de
tracepixel.nz=$+1
        LD bc,0;x0101
	LD de,[tracepixel.dzUINT]
	MULDEBC
        add iy,de
        ld d,hy
        ld e,ly
        rl e
        rl d ;for sign ;de = делимое = 2*(dx*nx+dy*ny+dz*nz)
         pop bc ;bc = делитель = sq(nx)+sq(ny)+sq(nz)
        ;ld a,d
        ;xor b
        ex af,af' ;'
	DIVDEBC_AXSIGN_NONEGBC ;de / bc
         push de ;tracepixel.l = 2*(dx*nx+dy*ny+dz*nz)/(sq(nx)+sq(ny)+sq(nz)) ;со знаком

	LD bc,[tracepixel.nx] ;со знаком
	MULDEBC
        ld hl,(tracepixel.dxUINT)
        ;or a
        sbc hl,de;bc
        ld (tracepixel.dxUINT),hl ;dx-nx*l
         pop de
         push de ;tracepixel.l
	LD bc,[tracepixel.ny] ;со знаком
	MULDEBC
        ld hl,(tracepixel.dyUINT)
        ;or a
        sbc hl,de;bc
        ld (tracepixel.dyUINT),hl ;dy-ny*l
         pop de ;tracepixel.l
	LD bc,[tracepixel.nz] ;со знаком
	MULDEBC
        ld hl,(tracepixel.dzUINT)
        ;or a
        sbc hl,de;bc
        ld (tracepixel.dzUINT),hl ;dz-nz*l
	JP tracepixel.L100 ;//отражение
        
        if EGA
tracepixel.sky
        if SQUAREMUL
        set 7,d
        res 0,e
        endif
	LD bc,[tracepixel.dyUINT] ;<0
	;MULDEBC_TOHL_DEPOSITIVE
        ;if SQUAREMUL
        ;dec e
        ;endif
	;LD [tracepixel.dyUINT],hl ;dy = dy*s
         srl b
         rr c
         srl b
         rr c
        ;c=яркость

         ld a,(scrxHSB)
         and 3
         ld b,a
         ld a,(tracepixel.i)
         and 3
         add a,a
         add a,a
         add a,b
         ld hl,tchunk
         add a,l
         ld l,a
         jr nc,$+3
         inc h
        ld a,(hl)
        cp c

       ld a,COLOR_SKY
        ret c
       ld a,COLOR_SKYDARK
        ret

tchunk
        db 0x08, 0x88, 0x28, 0xa8
        db 0xc8, 0x48, 0xe8, 0x68
        db 0x38, 0xb8, 0x18, 0x98
        db 0xf8, 0x58, 0xd8, 0x58
        endif
        
        
tracepixel.ground
;//земля
;//k = 0x00;
;//REPEAT {
;//  IF (less((sq(/**u*/cx[k]-x) + sq(/**v*/cz[k]-z)), q[k])) {goto RETURNME;}; 
;//  INC k;
;//}UNTIL (k == spheres);
;//IF (fract(x) != fract(z)) {
;//  invpix(j,i)
;//};   //((x+100)-(int)(x+100))  //(z-(int)(z))
	ld a,2*(spheres-1)
drawground_findshadow0
	LD [tracepixel.k],A
        ld (drawground_findshadow_qaddr),a
        ld (drawground_findshadow_cxaddr),a
	LD l,A
	LD h,cz/256
	LD E,[HL]
	INC L
	LD D,[HL]
	LD hl,[tracepixel.zUINT]
        sbc hl,de
        SQHL ;out: de
        ld hy,d
        ld ly,e
drawground_findshadow_cxaddr=$+2
        ld de,(cx)
	LD HL,[tracepixel.xUINT]
        sbc hl,de
        SQHL ;out: de
        add iy,de
	 ld d,hy
         ld e,ly
drawground_findshadow_qaddr=$+1
        ld hl,(q)
        sbc hl,de
       if EGA
       ld a,COLOR_SHADOW
       endif
        ret nc ;shadow
	LD a,[tracepixel.k]
	sub 2
	JP nc,drawground_findshadow0

        ld a,(tracepixel.xUINT) ;дробная часть
        ld hl,tracepixel.zUINT
        xor (hl)
        rla
       if EGA
       ld a,COLOR_SQUARE0
       ret nc
       ld a,COLOR_SQUARE1
       endif
        ret
        
        if !fastest
muldebc
;+de0 * +bc0 -> .de.
        ld a,d
        xor b
        ex af,af' ;M=разные знаки '
        ld a,d
        rla
        jr nc,mul_noneghld0
        xor a
        sub e
        ld e,a
        sbc a,d
        sub e
        ld d,a
mul_noneghld0
        ld a,b
        rla
        jr nc,mul_nonegbcx0
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a
mul_nonegbcx0
        if SQUAREMUL
        set 7,d
        res 0,e
        endif
        MULDEBC_POSITIVE
        ex af,af' ;M=разные знаки '
        ret p
        xor a
        sub e
        ld e,a
        sbc a,d
        sub e
        ld d,a
        ret
        endif
        
        if !SQUARESQR
        ;ds (-$)&255
tsqr=0x7b00;0x7a00 ;код команды ld a,d (не помогает)
        ;ds 512 ;incbin "tsqr"
        endif

        align 256
q ;такой порядок выгоднее в MegaLZ
	DW q1
	DW q0
        align 256
cx
	DW cx1
	DW cx0
        align 256
cy
	DW cy1
	DW cy0
        align 256
cz
	DW cz1
	DW cz0
        align 256 ;сразу после cz
rad
	DW r1*17/16 ; //больше, потому что бок сферы торчит за проекцию
	DW r0*17/16
end
        align 256
projr
        dw 0 ;используется только старший байт
        dw 0
        align 256 ;projx и projy сразу после rad
projx
        dw 0 ;используется только старший байт
        dw 0
;        align 256
;projy
;        dw 0 ;используется только младший байт
;        dw 0

;end

	display "End=",end
	display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "raytrace.com",begin,end-begin
	
	LABELSLIST "../../../us/user.l"
