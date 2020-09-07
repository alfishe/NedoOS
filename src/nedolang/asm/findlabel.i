;PROC findlabel(PBYTE labeltext)
;{
;VAR PBYTE plabel; //метка в таблице заканчивается нулём
;  _hash = hash(labeltext)&0x3ff;
;  _labelN = _labels0; //_labelpage[(UINT)(_hashhigh&_LABELPAGEMASK)]; //set page (todo как определить? системный макрос?)
;  _plabel_index = _labelshift[_hash];
;  WHILE (_plabel_index != _LABELPAGEEOF) { //пока цепочка меток не закончилась
;    plabel = &_labelN[_plabel_index]; //(PBYTE)((POINTER)_labelN + (POINTER)_plabel_index);
;    _plabel_index = *(PUINT)(plabel);
;    plabel = &plabel[+sizeof(UINT)]; //(PBYTE)((POINTER)plabel + (POINTER)2);
;    IF (strcp((PCHAR)labeltext, (PCHAR)plabel)) { //метка найдена
;      _plabel_index = (UINT)(plabel - _labelN) + _labellen; //включая 0 //указатель на начало данных создаваемой метки (надо обязательно запомнить!)
;      BREAK; //помнит _plabel_index начала данных найденной метки
;    };
;  }; //если не найдено, то _plabel_index==_LABELPAGEEOF
;}
findlabel
	;LD HL,_labels0
	;LD [_labelN],HL
	LD de,[findlabel.A.]
        xor a
        ld h,a
        ld l,a
findlabel.hash0.
        add hl,hl
        add a,l
        ld l,a
        ld a,[de]
        inc de
        or a
        jp nz,findlabel.hash0.
	LD A,h
	AND 3
	LD H,A
	LD [_hash],HL
        add hl,hl
	LD de,_labelshift
	ADD HL,DE
	LD e,[HL]
	INC HL
	LD d,[HL]
findlabel.B.
        ld a,d
        and e
        inc a ;de==_LABELPAGEEOF?
	jr z,findlabel.returnde
	LD HL,_labels0;[_labelN]
	ADD HL,DE
	LD e,[HL]
	INC HL
	LD d,[HL]
        inc hl
	;LD [findlabel.plabel],HL
findlabel.A.=$+1
	ld bc,0
findlabel.strcp0.
	ld a,[bc] ;s2
	cp [hl] ;s1
	jr nz,findlabel.B.
	inc hl
	inc bc
	or a
	jp nz,findlabel.strcp0.
;hl=findlabel.plabel+_labellen
;findlabel.plabel=$+1
	;LD HL,0
	LD DE,-_labels0;-[_labelN]
	add HL,DE
	;LD DE,[_labellen]
	;ADD HL,DE
	ret
findlabel.returnde
	ex de,hl
	ret
