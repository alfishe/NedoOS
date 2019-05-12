compareattrib
	push hl
	push de
	ld bc,FCB_FATTRIB
	ex de,hl
	add hl,bc
	ex de,hl
	add hl,bc
	ld a,(hl)
	and #10
	ld c,a
	ld a,(de)	
	and #10
	cp c
findmin_ccf=$
	ccf
	pop de  
	pop hl
	ret

comparedate
	call compareattrib
	ret nz
	ld bc,FCB_FDATE+1
	ex de,hl
	add hl,bc
	ex de,hl
	add hl,bc
	ld a,(de)
	cp (hl)
	ret nz
	dec hl
	dec de
	ld a,(de)
	cp (hl)
	ret nz

	ld bc,FCB_FTIME+1-FCB_FDATE
	ex de,hl
	add hl,bc
	ex de,hl
	add hl,bc
	ld a,(de)
	cp (hl)
	ret nz
	dec hl
	dec de
	ld a,(de)
	cp (hl)
	ret nz

	ld bc,-FCB_FTIME
	ex de,hl
	add hl,bc
	ex de,hl
	add hl,bc
	jr compareext_go

comparesize
	call compareattrib
	ret nz
	ld bc,FCB_FSIZE+3
	ex de,hl
	add hl,bc
	ex de,hl
	add hl,bc
	ld a,(de)
	cp (hl)
	ret nz
	dec hl
	dec de
	ld a,(de)
	cp (hl)
	ret nz
        dec hl
        dec de
	ld a,(de)
	cp (hl)
	ret nz
	dec hl
	dec de
	ld a,(de)
	cp (hl)
	ret nz
        ld bc,-FCB_FSIZE
	ex de,hl
	add hl,bc
	ex de,hl
	add hl,bc
	jr compareext_go

compareext
	call compareattrib
	ret nz
compareext_go
	ld bc,8
	ex de,hl
	add hl,bc
	ex de,hl
	add hl,bc
	ld b,3
compareext0
	inc hl
	inc de
	ld a,(de)
	cp (hl)
	ret nz
	djnz compareext0
	ld bc,-11
	ex de,hl
	add hl,bc
	ex de,hl
	add hl,bc
	;jr $
	ld b,8
	jp comparefilename0

comparefilename
;hl=fcb1
;de=fcb2	
;out: NC = *de>=*hl 
	call compareattrib
	ret nz	
	ld b,11
comparefilename0
	inc hl
	inc de
	ld a,(de)
	cp (hl)
	ret nz
	djnz comparefilename0
	ret
        
compareempty
        scf
        ret

comparer
;hl = FCB1, de = FCB2
findmin_proc=$+1
	call compareext
;NC = *de>=*hl
findmin_ccf2=$
	ccf ;/nop
	ret

sortfiles
;ix=panel
        ld l,(ix+PANEL.dirsortproc)
        ld h,(ix+PANEL.dirsortproc+1)
        ld (findmin_proc),hl
        
        ld a,(ix+PANEL.dirsortmode)
        or a
        ld bc,#3f38
        jr z,$+5
        ld bc,#0030
        ;ld a,c
        ;ld (findmin_jrc),a
        ld a,b
        ld (findmin_ccf),a
        ld (findmin_ccf2),a
       
	;jp (ix)

sorter2
	;jr $
	call	HPSRT_init
	
	ld c,(ix+PANEL.files)
	ld b,(ix+PANEL.files+1)
        ld a,b
        or c
        ret z
	;ld l,(ix+PANEL.pointers)
	;ld h,(ix+PANEL.pointers+1)
	ld e,(ix+PANEL.catbuf)
	ld d,(ix+PANEL.catbuf+1)
sorter2_add0
	push bc
	push de
        ;call getfilepointer_de_fromhl
	;push hl ;hl=next pointer
;de=fcb (mangled addr)
	;exd
	;push hl
	;ld d,h
	;ld e,l
	;res 6,d
	;ld a,3 ;TODO remove copy
	;PGW2strpg
;в c000 PANEL.pg
	;ld bc,32
	;ldir
	;pop hl
	;ld	de,0
;hl=addr to add
	;exd
	call	HPSRT_add
	;pop hl
	pop de
	ex de,hl
	ld bc,32
	add hl,bc
	ex hl,de
	 jr nc,$+3
	 inc de ;next page
	 set 7,d
	 set 6,d
	pop bc
	dec bc
	ld a,b
	or c
	jr nz,sorter2_add0
	
	jp HPSRT_sort

	if 1==0
sorter1
	
	;ld a,(ix+PANEL.pg)
	;SETPG32KHIGH
	
	ld c,(ix+PANEL.files)
	ld b,(ix+PANEL.files+1)
        ld a,b
        or c
        ret z
	ld l,(ix+PANEL.pointers)
	ld h,(ix+PANEL.pointers+1)
;при обратной сортировке в режиме "без сортировки" на каждом проходе в конец списка попадёт первый файл, а на следующем он попадёт в очередное начало, т.е. перестановка в обратном порядке не выйдет
sortfiles_pass0
	push bc
	push hl ;hl=start (in pointers)
;bc=files!=0
	call findmin
;de=min (pointer)
         ld hl,(findmin_proc)
         ld bc,compareempty
         or a
         sbc hl,bc
	pop hl ;hl=start (in pointers)
;copy pointer into hl, move to next pointer
        push af
        call swapfilepointers_hl_de ;out: hl=next pointer
        pop af
	pop bc
         jr nz,$+6 ;not compareempty
	 dec bc ;если compareempty
	 ld a,b
	 or c
         ret z
	dec bc
	ld a,b
	or c
	jr nz,sortfiles_pass0
	ret

findmin
;hl=start (in pointers)
;bc=files!=0
;out: de=min (pointer)
	ld e,l
	ld d,h ;de=current min (pointer)
findmin0
;de=current min (pointer)
	dec bc
	ld a,b
	or c
	ret z
	inc hl
	inc hl
        
	push bc
	push de ;de=current min (pointer)
	push hl
        
	push de ;de=current min (pointer)
        call getfilepointer_de_fromhl
	 SETPG32KLOW ;а то сейчас по current min включается PG32KHIGH
	 res 6,d
        ex de,hl ;hl=FCB
        ex (sp),hl ;hl=current min (pointer)
        call getfilepointer_de_fromhl

;de=current min (FCB)
        pop hl ;hl=FCB

	call comparer
        
	pop hl
	pop de ;de=current min (pointer)
	pop bc
;NC = *de>=*hl
;findmin_jrc=$
	jr nc,findmin0;findmin_nomin
	ld e,l
	ld d,h ;de=current min (pointer)
findmin_nomin
	jr findmin0

	endif