;_lblhash = 0x00;
;REPEAT {
;  _lblshift[_lblhash] = _LBLBUFEOF;
;  INC _lblhash;
;}UNTIL (_lblhash == 0x00);
;_lblbuffreeidx = 0;
initlblbuf
	EXPORT initlblbuf
	xor a
	LD HL,_lblshift
	LD DE,_LBLBUFEOF
initlblbuf.A.
	LD [HL],E
	INC HL
	LD [HL],D
	INC HL
	INC a
	JP NZ,initlblbuf.A.
	LD HL,_lbls
	LD [_lblbuffreeidx],HL
	RET

;вернуть тип метки _name и _typeaddr
;t = _T_UNKNOWN;
;_lblhash = (BYTE)hash((PBYTE)_name);
;plbl_idx = _lblshift[_lblhash];
;WHILE (plbl_idx != _LBLBUFEOF) { //пока цепочка меток не закончилась
;  plbl = &_lbls[plbl_idx];
;  plbl_idx = *(PUINT)(plbl);
;  plbl = &plbl[+sizeof(UINT)+1]; //skip string size
;  IF (strcp((PCHAR)_name, (PCHAR)plbl)) { //метка найдена
;    _typeaddr = (UINT)(plbl - _lbls); //для запоминания типа в будущей переменной //в C индексы, в асме указатели (лезут в UINT)
;    plbl = &plbl[_lenname+1];
;    t = *(TYPE*)(plbl);
;    plbl = &plbl[+sizeof(TYPE)]; //INC plbl;
;    _isloc = (BOOL)*(PBYTE)(plbl);
;    INC plbl;
;    IF ((t&_T_TYPE)==(TYPE)0x00) _typeaddr = *(PUINT)(plbl); //вспоминаем адрес типа, если это переменная, а не объявление типа
;    plbl = &plbl[+sizeof(UINT)];
;    _varsz = *(PUINT)(plbl);
;    break;
;  };
;};
;RETURN t;
lbltype
	EXPORT lbltype
	LD de,[_name]
	xor a
	ld h,a
	ld l,a
lbltype.hash0.
	xor l
	add hl,hl
	add a,l
	ld l,a
	ld a,[de]
	inc de
	or a
	jp nz,lbltype.hash0.
	ld h,a;0
	add hl,hl
	LD de,_lblshift
	ADD HL,DE
	ld [_lblhashaddr],hl
	LD e,[HL]
	INC HL
	LD d,[HL]
lbltype.A.
	ld a,d
	and e
	inc a ;de==_LBLBUFEOF?
	jr Z,lbltype.B.
	ex de,hl
	LD e,[HL]
	INC HL
	LD d,[HL]
	inc hl
	LD [_typeaddr],hl ;для запоминания типа в будущей переменной
	LD bc,[_name]
lbltype.strcp0.
	ld a,[bc] ;s2
	cp [hl] ;s1
	jr nz,lbltype.A.
	inc hl
	inc bc
	or a
	jp nz,lbltype.strcp0.
	LD a,[HL]
	ld c,a
	inc hl ;sizeof(TYPE)
	AND _T_TYPE
	LD A,[HL]
	LD [_isloc],A
	INC HL
	LD e,[HL]
	INC HL
	LD d,[HL]
	inc hl
	jr NZ,lbltype.E.
	LD [_typeaddr],de ;вспоминаем адрес типа, если это переменная, а не объявление типа
lbltype.E.
	LD e,[HL]
	INC HL
	LD d,[HL]
	LD [_varsz],de
	ld a,c
	ret
lbltype.B.
	LD A,_T_UNKNOWN
	RET

;_lblhash = (BYTE)hash((PBYTE)_name);
;plbl_idx = _lblshift[_lblhash];
;WHILE (plbl_idx != _LBLBUFEOF) { //пока цепочка меток не закончилась
;  plbl = &_lbls[plbl_idx];
;  plbl_idx = *(PUINT)(plbl);
;  plbl = &plbl[+sizeof(UINT)+1]; //skip string size
;  IF (strcp((PCHAR)_name, (PCHAR)plbl)) { //метка найдена
;    POKE *(PCHAR)(plbl) = '\0';
;    break;
;  };
;};
dellbl
	EXPORT dellbl
	LD de,[_name]
	xor a
	ld h,a
	ld l,a
dellbl.hash0.
	xor l
	add hl,hl
	add a,l
	ld l,a
	ld a,[de]
	inc de
	or a
	jp nz,dellbl.hash0.
	ld h,a;0
	add hl,hl
	LD de,_lblshift
	ADD HL,DE
	LD e,[HL]
	INC HL
	LD d,[HL]
dellbl.A.
	ld a,d
	and e
	inc a ;de==_LBLBUFEOF?
	ret z
	ex de,hl
	LD e,[HL]
	INC HL
	LD d,[HL]
	inc hl
	LD [dellbl.plbl],HL
	LD bc,[_name]
dellbl.strcp0.
	ld a,[bc] ;s2
	cp [hl] ;s1
	jr nz,dellbl.A.
	inc hl
	inc bc
	or a
	jp nz,dellbl.strcp0.
dellbl.plbl=$+1
	LD [0],a
	RET

;взять название типа структуры (сразу после lbltype)
;RETURN strcopy((PCHAR)&_lbls[_typeaddr], (UINT)*(PBYTE)&_lbls[_typeaddr-1], s); //в C индексы, в асме указатели (лезут в UINT)
gettypename
	EXPORT gettypename
	EXPORT gettypename.A.
	LD hl,[_typeaddr]
gettypename.A.=$+1
	ld de,0 ;to
	xor a
	ld b,a
	ld c,a
gettypename0
	cp [hl]
	ldi
	jp nz,gettypename0
	ld h,a
	ld l,a
	scf ;len without terminator
	sbc hl,bc
	RET

;oldt = lbltype(); //(_name) //устанавливает _isloc (если найдена) и _typeaddr (адрес, если найдена)
;IF ((oldt == _T_UNKNOWN)||isloc) { //если не было метки или локальная поверх глобальной или другой локальной (параметра)
;  //метки нет: пишем в начало цепочки адрес конца страницы и создаём метку там со ссылкой на старое начало цепочки
;  freeidx = _lblbuffreeidx; //[0] //начало свободного места
;  IF (freeidx < _LBLBUFMAXSHIFT) { //есть место под метку
;    plbl = &_lbls[freeidx]; //указатель на начало создаваемой метки
;    //пишем метку
;    POKE *(PUINT)(plbl) = _lblshift[_lblhash]; //старый указатель на начало цепочки
;    plbl = &plbl[+sizeof(UINT)];
;    POKE *(PBYTE)(plbl) = (BYTE)_lenname;
;    INC plbl;
;    strcopy(_name, _lenname, (PCHAR)plbl);
;    plbl = &plbl[_lenname+1];
;    POKE *(TYPE*)(plbl) = t;
;    plbl = &plbl[+sizeof(TYPE)]; //INC plbl;
;    POKE *(PBYTE)(plbl) = (BYTE)isloc;
;    INC plbl;
;    POKE *(PUINT)(plbl) = _typeaddr; //ссылка на название типа (для структуры)
;    plbl = &plbl[+sizeof(UINT)];
;    _varszaddr = (UINT)(plbl - _lbls); //чтобы потом можно было менять
;    POKE *(PUINT)(plbl) = varsz;
;    _lblbuffreeidx = (UINT)(plbl - _lbls) + +sizeof(UINT); //указатель конец создаваемой метки
;    _lblshift[_lblhash] = freeidx; //новый указатель на начало цепочки
;  }ELSE {errstr("nomem"); enderr();
;  };
;}ELSE IF (oldt != t) {
;  errstr("addvar type doesn't match previous declaration:"); errstr(_name); enderr();
;};
addlbl
	EXPORT addlbl
	EXPORT addlbl.A.
	EXPORT addlbl.B.
	EXPORT addlbl.C.
	CALL lbltype
	LD [addlbl.oldt],A
addlbl.B.=$+1
	ld b,0
	inc b
	jr z,addlbl.islocon
	SUB _T_UNKNOWN
	JP nz,addlbl.D.
addlbl.islocon
	LD HL,[_lblbuffreeidx]
	LD DE,_lbls+_LBLBUFMAXSHIFT
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,addlbl.F.
	ex de,hl
	LD hl,[_lblhashaddr]
	ldi
	ldi
	LD bc,[_lenname]
	LD HL,[_name]
	inc bc ;copy with terminator
	ldir
	ex de,hl
addlbl.A.=$+1
	LD [HL],0 ;t
	inc hl
	LD A,[addlbl.B.] ;isloc
	LD [HL],A
	INC HL
	LD DE,[_typeaddr]
	LD [HL],E
	INC HL
	LD [HL],D
	INC HL
	LD [_varszaddr],HL
addlbl.C.=$+1
	LD DE,0 ;varsz
	LD [HL],E
	INC HL
	LD [HL],D
	INC HL
        ex de,hl
	LD hl,[_lblbuffreeidx]
	LD [_lblbuffreeidx],de
_lblhashaddr=$+1
	LD [0],hl
	ret
addlbl.F.
	LD HL,addlbl.H.
	LD [errstr.A.],HL
	CALL errstr
	jp enderr
addlbl.D.
	LD A,[addlbl.A.] ;t
addlbl.oldt=$+1
	SUB 0
	ret z
	LD HL,addlbl.K.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_name]
	LD [errstr.A.],HL
	CALL errstr
	jp enderr
addlbl.H.
	db "nomem",0
addlbl.K.
	db "addvar type doesn't match previous declaration:",0

;POKE *(PUINT)(&_lbls[addr]) = shift;
setvarsz
	EXPORT setvarsz
	EXPORT setvarsz.A.
	EXPORT setvarsz.B.
setvarsz.B.=$+1
	LD hl,0 ;shift
setvarsz.A.=$+1
	LD [0],hl ;addr
	RET
