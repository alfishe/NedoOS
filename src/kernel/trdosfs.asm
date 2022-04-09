trdosgetdirfcb
        ld hl,fcb2+FCB_FNAME
        call dotname_to_cpmname ;de -> hl
        ld hl,mfilinfo+FILINFO_FSIZE
        ld de,fcb2+FCB_FSIZE
        ld bc,4
        ldir
        ld hl,(mfilinfo+FILINFO_FDATE)
        ld (fcb2+FCB_FDATE),hl
        ld hl,(mfilinfo+FILINFO_FTIME)
        ld (fcb2+FCB_FTIME),hl       
     	ld a,(mfilinfo+FILINFO_FATTRIB)
	;and 0x10
	ld (fcb2+FCB_FATTRIB),a
        ret

dos3d13.
;hl=addr
;de=track,sector
;b=size/256
;c=5 (read), 6 (write)
	;push bc
	;ex de,hl
        ;call BDOS_preparedepage
        ;call BDOS_setdepage ;TODO убрать в драйвер
	;ex de,hl
	;pop bc
dos3d13nopg.
;bc,de,hl,a (for c=1)
        push iy
        exx
        ld e,(iy+app.gfxmode)
        ld iy,23610
	push af
dos3d13_waitnospace0
        ld a,0x7f
        in a,(0xfe)
        rra
        jr nc,dos3d13_waitnospace0
	pop af
        call dos3d13_resident
        pop iy
        ret

trdos_fread
        ld hl,FCB_FFSFCB
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl = poi to TRDOSFCB
        
        ;ld de,(dma_addr) ;de=poi to data
        call BDOS_getdta
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер

        ex de,hl ;hl=poi to data, de=poi to TRDOSFCB
        ld bc,128 ;bc=size
         push bc ;blocksize
        call fread ;hl=total processed bytes
         pop bc ;blocksize
        call movedma_addr ;+bc
        ld a,l
        xor 0x80 ;!=, если прочитали не 128 байт
;a=0: OK (прочитали 128 байт)
;a=128: fail (прочитали 0 байт)
;a=???: OK (последний блок файла меньше 128 байт)
        ;ld a,(_waseof)
        ;and 128 ;EOF (чтобы было как в FatFS)
        ;xor a ;success
        ret
trdos_fread_b
;b=trdosfcb high
;de=poi to data
;hl=size
        push hl ;Number of bytes to read
        ld h,b
        ld l,0
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        pop bc ;Number of bytes to read
        ex de,hl
;hl=poi to data
;de=poi to TRDOSFCB
;bc=size
        jp fread ;hl=total processed bytes, a=error

        
trdos_fwrite
        ld bc,128 ;bc=size
;trdos_fwrite_nbytes
        ld hl,FCB_FFSFCB
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl = poi to TRDOSFCB

        push bc
        ;ld de,(dma_addr) ;de=poi to data
        call BDOS_getdta
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        pop bc
        ex de,hl ;hl=poi to data, de=poi to TRDOSFCB
         push bc ;blocksize
        call fwrite
         pop bc ;blocksize
        call movedma_addr ;+bc
        xor a ;success
        ret
trdos_fwrite_b
;b=trdosfcb high
;de=poi to data
;hl=size
	;jr $
        push hl ;Number of bytes to write
        ld h,b
        ld l,0
        call BDOS_preparedepage
        call BDOS_setdepage ;TODO убрать в драйвер
        pop bc ;Number of bytes to write
        ex de,hl
;hl=poi to data
;de=poi to TRDOSFCB
;bc=size
        jp fwrite ;hl=total processed bytes, a=0: no error
        
trdos_searchnext
;hl=адрес в директории
;de=FCB, куда класть описатель
;out: hl=следующий адрес в директории, z=error
         ld a,' '
         ld (de),a
        ld a,(hl)
        or a
        ret z ;jr z,BDOS_fsearch_loadloop_noFATFS_empty
        ld bc,8
        ldir
        ld a,(hl)
        ldi
        cp 'B'
        jr nz,trdos_searchnext_nobas
;basic, если start < 0x4100 (чтобы можно было .BAT)
         inc hl
         ld a,(hl)
         cp 0x41
         jr nc,trdos_searchnext_decnobas
         inc hl
        ld a,' '
        ld (de),a
        inc de
        ld (de),a
        inc de
        jr trdos_searchnext_basq
trdos_searchnext_decnobas
         dec hl
trdos_searchnext_nobas
        ldi
        ldi
trdos_searchnext_basq
        ld de,fcb2+FCB_FSIZE
        ldi
        ldi
        xor a
        ld (de),a
        inc de
        ld (de),a
        ld de,fcb2+FCB_FDATE
        ld (de),a
        inc de
        ld (de),a
        ld de,fcb2+FCB_FATTRIB
        ld (de),a
        ld de,fcb2+FCB_FTIME
       ld a,l ;file pos in sector
       and 0xf0
        ld (de),a
        inc de
       ld a,h
       sub trdos_catbuf/256 ;sector
        ld (de),a
        ld bc,16-11-2
        add hl,bc
        inc a ;nz
        ret

trdos_fopen
;a=drive 0..3
        push de ;FCB
        inc de ;filename
        ld c,'r'
trdos_fopen_go
;a=drive 0..3
        call nfopen ;out: a (0=success, 0xff=fail), hl=TRDOSFCB
        pop bc ;bc = pointer to opened FCB (TODO чем отличается от unopened?)
        or a
        ret nz ;error
        ex de,hl ;de=TRDOSFCB
        ld hl,FCB_FFSFCB
        add hl,bc
        ld (hl),e
        inc hl
        ld (hl),d
        ret

trdos_fcreate
;a=drive 0..3
        push de ;FCB
        inc de ;filename
        ld c,'w'
        jr trdos_fopen_go
        ;call nfopen
        ;pop bc ;bc = pointer to opened FCB (TODO чем отличается от unopened?)
        ;xor a ;success ;TODO ошибка создания
        ;ret

trdos_fclose
        ;ld hl,TRDOSFCB1
        ld hl,FCB_FFSFCB
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl = poi to TRDOSFCB
trdos_fclose_hl
        call fclose
        xor a ;success
        ret

trdos_getfilesize
;b=handle
;out: dehl=filesize
        xor a
        ld h,a
        ld l,a
        ld (trdos_getfilesizeLSW),hl
        ld (trdos_getfilesizeHSB),a
        
        ld h,b
        ld l,1 ;TRDOSFCB filename
        
        ld c,9 ;c=FILENAMESZ
        call findfile
        jr nz,trdos_getfilesize_q
;hl,de=after filename
trdos_getfilesize_0
        ;push bc
        push de
        push hl
;de=after filename on disk
        ex de,hl
        inc hl
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl) ;length
trdos_getfilesizeLSW=$+1
        ld hl,0
        add hl,de
        ld (trdos_getfilesizeLSW),hl
        ld hl,trdos_getfilesizeHSB
        jr nc,$+3
        inc (hl)
        pop hl
        pop de
        ;pop bc
        call findfile_continue
        jr z,trdos_getfilesize_0
trdos_getfilesize_q
        ld hl,(trdos_getfilesizeLSW)
trdos_getfilesizeHSB=$+1
        ld de,0
        xor a
        ret

trdos_getfiletime
;de=path/file ASCIIZ string
;out: ix=date, hl=time (counted from file index)
        ld c,9 ;c=FILENAMESZ
        call findfile
;carry = off, a = 0, de = DOSBUF after filename, b = 8-sector
        ld a,e
       and 0xf0
        ld l,a
        ld a,8
        sub b
        ld h,a
        ld ix,0
        ret

trdos_seekhandle_bof
;b=file handle
        ld h,b
        call nfopen_reopen ;переоткрываем файл
        jr trdos_seekhandle_q
        ;pop hl
        ;pop de
        ;xor a
        ;ret
        
trdos_seekhandle
;                    B = File handle
;                    [A = Method code: 0=begin,1=cur,2=end]
;                DE:HL = Signed offset
;     Results:       A = Error
;                DE:HL = New file pointer
;только для чтения!!!
        push de
        push hl

        ld a,e
        or h
        or l
        jr z,trdos_seekhandle_bof ;если addr=0, то переоткрыть файл
;addrm1=addr-1, т.к. все указатели и номера в TRDOSFCB при чтении рассчитаны на предыдущий байт
        ld a,e
        ld de,1
        ;or a
        sbc hl,de
        sbc a,d;0
        ld (trdos_seekhandleaddrLSW),hl
        ld (trdos_seekhandleaddrHSB),a        
        
        xor a
        ld h,a
        ld l,a
        ld (trdos_seekhandlesizeLSW),hl
        ld (trdos_seekhandlesizeHSB),a
        
        ld h,b
        ld l,1 ;TRDOSFCB filename
        
        ld c,9 ;c=FILENAMESZ
        call findfile
        jr nz,trdos_seekhandle_q
;пройти блоки файла, суммировать totalsize+=blocksize и остановиться на том, где addrm1 < totalsize+blocksize ((addrm1-totalsize) < blocksize)
;hl,de=after filename
trdos_seekhandle_0
        push bc
        push de
        push hl
;de=after filename on disk
        ex de,hl
        ld a,(hl)
        ld (trdos_seekhandle_blocknumber),a
        inc hl
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl) ;length
        ld (trdos_seekhandle_length),de
        inc hl
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl) ;track,sector
        ld (trdos_seekhandle_trsec),bc
trdos_seekhandleaddrLSW=$+1
        ld hl,0
        ld c,l ;addrm1&0xff
trdos_seekhandleaddrHSB=$+1
        ld a,0
trdos_seekhandlesizeLSW=$+1
        ld de,0
        or a
        sbc hl,de
trdos_seekhandlesizeHSB=$+1
        sbc a,0
;ahl=addrm1-totalsize
;keep h
        ld (trdos_seekhandle_shiftinblock),hl
;остановиться на том блоке, где addrm1 < totalsize+blocksize ((addrm1-totalsize) < blocksize)
trdos_seekhandle_length=$+1
        ld de,0 ;blocksize = length блока
        or a
        sbc hl,de
        sbc a,0
        jp m,trdos_seekhandle_blockfound
        
        ld hl,(trdos_seekhandlesizeLSW)
        ld a,(trdos_seekhandlesizeHSB)
        add hl,de
        adc a,0 ;ahl=totalsize+blocksize
        ld (trdos_seekhandlesizeLSW),hl
        ld (trdos_seekhandlesizeHSB),a
        pop hl
        pop de
        pop bc
        call findfile_continue
        jr z,trdos_seekhandle_0
;TODO error
trdos_seekhandle_q
        pop hl
        pop de
        xor a
        ret

trdos_seekhandle_blockfound
        pop hl ;TRDOSFCB
        push hl
;установить TRDOSFCB.remain = addrm1&0xff
        ld l,TRDOSFCB.remain
        ld (hl),c
;установить TRDOSFCB.firstsector = первый сектор блока
trdos_seekhandle_trsec=$+1
        ld bc,0
        ld l,TRDOSFCB.firstsector
        ld (hl),c
        inc l
        ld (hl),b
;установить TRDOSFCB.lastlen = length блока
        ld l,TRDOSFCB.lastlen
        ld (hl),e
        inc l
        ld (hl),d
;установить TRDOSFCB.secinblk = число оставшихся секторов в блоке = размер блока - (addrm1-totalsize)/256 - 1 (может получиться 0, если последний сектор блока уже загружен)
        dec de
        inc d
        ld a,d
trdos_seekhandle_shiftinblock=$+1
        ld de,0
        sub d
        dec a
        ld l,TRDOSFCB.secinblk
        ld (hl),a
;установить TRDOSFCB.cursector = первый сектор блока + (addrm1-totalsize)/256, прочитать этот сектор и инкрементировать
        ld lx,d
        call addsectors
        ld d,b
        ld e,c
	inc h
	ld l,0 ;poi to buf
	call rdsec.
        ;hl=next sector
        ex de,hl
        pop hl
        ld l,TRDOSFCB.cursector
        ld (hl),e
        inc l
        ld (hl),d
;установить TRDOSFCB.block = номер блока + 1(!), т.е. всегда следующий блок
        ld l,TRDOSFCB.block
trdos_seekhandle_blocknumber=$+1
        ld (hl),0
        inc (hl)
        pop de
        pop bc
        jr trdos_seekhandle_q

trdos_delete
;DE = Drive/path/file ASCIIZ string
        ex de,hl
        call findlastslash. ;de=last slash
        ld hl,trdos_tempfilename
        push hl
        call dotname_to_cpmname ;de -> hl
        pop de
        jp nfdel_filename
        ;xor a
        ;ret
        
trdos_rename
;DE = Drive/path/file ASCIIZ string, HL = New filename ASCIIZ string
        push de

        call findlastslash. ;de=last slash
        ld hl,trdos_tempfilename2
        call dotname_to_cpmname ;de -> hl
       
        pop hl ;hl = poi to filename in string

        call findlastslash. ;de=last slash
        ld hl,trdos_tempfilename
        push hl
        call dotname_to_cpmname ;de -> hl
        pop hl ;hl=filename
        ld c,9 ;c=FILENAMESZ
         ;jr $
        call findfile
        jr nz,trdos_rename_q
;hl,de=after filename
        push hl
        ld a,(de)
        ld hl,trdos_tempfilename2+9 ;&newext[1]
        sub (hl) ;ext[1] - newext[1]
        ld (trdos_rename_ext1diff),a
        pop hl
trdos_rename_0
        push bc
        push de
        push hl
         push bc
;de=after filename
        ld hl,trdos_tempfilename2
        ld a,e
        and 0xf0
        ld e,a
        ld bc,9
        ldir
        ld a,(de) ;block # + ext[1]
trdos_rename_ext1diff=$+1
        sub 0
        ld (de),a ;block # + newext[1]
        inc hl
        inc de
        ld a,(hl)
        ld (de),a ;newext[2]
         pop bc
	ld d,0 ;track
	ld a,8
	sub b
	ld e,a ;sector
	call wrsecDOSBUF
        pop hl
        pop de
        pop bc
        call findfile_continue
        jr z,trdos_rename_0
trdos_rename_q
        xor a
        ret

dotname_to_cpmname
;de -> hl
;out: de=pointer to termination character
        ;push hl ;buffer
        
        push de ;ASCIIZ string for parsing
        push hl ;Pointer to 11 byte buffer
	ld d,h
	ld e,l
	inc de
	ld [hl],' '
	ld bc,11-1
	ldir ;empty filename
        pop hl ;Pointer to 11 byte buffer
        pop de ;ASCIIZ string for parsing

;change dots to 1, except the last
        ld a,(de)
        cp '.'
        jr z,parse_filename_changedots
        push de
        jr parse_filename_changedots0getgo
parse_filename_changedots0get
         ld a,1
         ld (de),a
parse_filename_changedots0getgo
        ld b,d
        ld c,e
parse_filename_changedots0
        ld a,(de)
        cp '.'
        jr z,parse_filename_changedots0get
        inc de
        or a
        jr nz,parse_filename_changedots0
        ld a,(bc)
        cp 1
        jr nz,$+5
         ld a,'.'
         ld (bc),a
        pop de
parse_filename_changedots

        ld b,9
	
	ld a,(de)
	cp '.'
	jr nz,parse_filename0.
	ld (hl),a
	inc de
	ld a,(de)
	cp '.'
	jr nz,parse_filenameq_findterminator.
	inc hl
	ld (hl),a
	jr parse_filenameq_findterminator.
parse_filename0.
	ld a,[de]
	or a
	ret z ;jr z,parse_filenameq. ;no extension in string
	cp '.'
	jr z,parse_filenamedot. ;можем уже быть на терминаторе
         ;cp 0x80
         ;jr nc,$+4
         ;or 0x20
         cp 1
         jr nz,$+5
          ld a,'.'
	  ld [de],a
	ld [hl],a
	inc de
	inc hl
	djnz parse_filename0.
;9 bytes in filename, no dot (9th byte goes to extension)
;возможно, длинное имя, надо найти, что раньше - точка или терминатор
;можем уже быть на терминаторе или на точке
        dec hl
        ld [hl],' '
parse_filenamelongname0.
        ld a,[de]
        or a
        ret z ;jr z,parse_filenameq. ;a=0
        inc de
        cp '.'
        jr z,parse_filenameLONGnamedot. ;можем уже быть на терминаторе
        jr parse_filenamelongname0.
parse_filenamedot.
	inc de
	inc hl
	djnz $-1 ;hl points to extension in FCB
	dec hl
parse_filenameLONGnamedot.
	ld a,[de] ;extension in string
        or a
        ret z ;jr z,parse_filenameq. ;a=0
         ;cp 0x80
         ;jr nc,$+4
         ;or 0x20
	ld [hl],a ;extension in FCB
        inc hl
        inc de
	ld a,[de] ;extension in string
        or a
        ret z ;jr z,parse_filenameq. ;a=0
         ;cp 0x80
         ;jr nc,$+4
         ;or 0x20
	ld [hl],a ;extension in FCB
        inc hl
        inc de
	ld a,[de] ;extension in string
        or a
        ret z ;jr z,parse_filenameq. ;a=0
         ;cp 0x80
         ;jr nc,$+4
         ;or 0x20
	ld [hl],a ;extension in FCB
parse_filenameq_findterminator.
        inc de
        ld a,[de]
        or a
        jr nz,parse_filenameq_findterminator.
;parse_filenameq. ;de на терминаторе
        ;pop hl ;buffer
        ret ;a=0
        
trdos_tempfilename
        ds 11
trdos_tempfilename2
        ds 11
BDOS_parse_filename_cpmnamebuf
        ds 11 ;TODO объединить с одним из tempfilename
