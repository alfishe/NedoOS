dos3d13.
        push iy
        exx
        ld e,(iy+app.gfxmode)
        ld iy,23610
;dos3d13_waitnospace0
        ;ld a,#7f
        ;in a,(#fe)
        ;rra
        ;jr nc,dos3d13_waitnospace0
        call dos3d13_resident
        pop iy
        ret

trdos_fread
        ld hl,FCB.FFSFCB
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl = poi to TRDOSFCB
        
        ;ld de,(dma_addr) ;de=poi to data
        call BDOS_getdta
        call BDOS_preparedepage

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
        pop bc ;Number of bytes to read
        ex de,hl
;hl=poi to data
;de=poi to TRDOSFCB
;bc=size
        jp fread ;hl=total processed bytes

        
trdos_fwrite
        ld bc,128 ;bc=size
trdos_fwrite_nbytes
        ld hl,FCB.FFSFCB
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl = poi to TRDOSFCB

        push bc
        ;ld de,(dma_addr) ;de=poi to data
        call BDOS_getdta
        call BDOS_preparedepage
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
        push hl ;Number of bytes to write
        ld h,b
        ld l,0
        call BDOS_preparedepage
        pop bc ;Number of bytes to write
        ex de,hl
;hl=poi to data
;de=poi to TRDOSFCB
;bc=size
        jp fwrite ;hl=total processed bytes
        
trdos_searchnext
;hl=адрес в директории
;de=FCB, куда класть описатель
;out: hl=следующий адрес в директории, z=error
         ld a,' '
         ld (de),a
        ld a,(hl)
        or a
        ret z ;jr z,BDOS_fsearch_loadloop_noFATFS_empty
        ld bc,11
        ldir
        ld de,fcb2+FCB.FSIZE
        ldi
        ldi
        xor a
        ld (de),a
        inc de
        ld (de),a
        ld de,fcb2+FCB.FDATE
        ld (de),a
        inc de
        ld (de),a
        ld de,fcb2+FCB.FTIME
        ld (de),a
        inc de
        ld (de),a
        ld de,fcb2+FCB.FATTRIB
        ld (de),a
        ld bc,16-11-2
        add hl,bc
        inc a ;nz
        ret

trdos_fopen
        push de ;FCB
        inc de ;filename
        ld c,'r'
trdos_fopen_go
        call nfopen ;out: a (0=success, 0xff=fail), hl=TRDOSFCB
        pop bc ;bc = pointer to opened FCB (TODO чем отличается от unopened?)
        or a
        ret nz ;error
        ex de,hl ;de=TRDOSFCB
        ld hl,FCB.FFSFCB
        add hl,bc
        ld (hl),e
        inc hl
        ld (hl),d
        ret

trdos_fcreate
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
        ld hl,FCB.FFSFCB
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl = poi to TRDOSFCB
trdos_fclose_hl
        call fclose
        xor a ;success
        ret

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
        
trdos_tempfilename
        ds 11
trdos_tempfilename2
        ds 11
        
        
