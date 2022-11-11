TRUE=0xff
FALSE=0x00

SECINBLK=32;16 ;TR-DOS reserves 16 sectors per block
;FILENAMESZ=9;10 for multi-block files (block # in +9)

_fin
	;EXPORT _fin
	DW 0
_fout
	;EXPORT _fout
	DW 0
;_waseof
	;EXPORT _waseof
	;DB 0

TRDOSFCB=0
	;db 0 ;0 = free, 'r' = read, 'w' = write
TRDOSFCB=TRDOSFCB+1
;;;;;;;;;;;;;;; copy of TR-DOS descriptor ;;;;;;;;;;;;;;
TRDOSFCB.fn=TRDOSFCB
	;db "12345678c" ;filename
TRDOSFCB=TRDOSFCB+9
TRDOSFCB.block=TRDOSFCB
	;db 0 ;cur block for write, next block for read
	;db 0x60 ;(padding for "start")
TRDOSFCB=TRDOSFCB+2
TRDOSFCB.lastlen=TRDOSFCB
	;dw 0 ;length of block
TRDOSFCB=TRDOSFCB+2
TRDOSFCB.secinblk=TRDOSFCB
	;db 0 ;sectors remained in block (for read), block size (for write)
TRDOSFCB=TRDOSFCB+1
TRDOSFCB.firstsector=TRDOSFCB
	;dw 0 ;first sector of block (for write)
TRDOSFCB=TRDOSFCB+2
;;;;;;;;;;;;;;; end of TR-DOS descriptor ;;;;;;;;;;;;;;
TRDOSFCB.cursector=TRDOSFCB
	;dw 0 ;cur sector for write, next sector for read
TRDOSFCB=TRDOSFCB+2
TRDOSFCB.remain=TRDOSFCB
	;db 0xff ;remaining bytes in buf (for read)
TRDOSFCB=TRDOSFCB+1
TRDOSFCB.secwritten=TRDOSFCB
	;db 0 ;sectors written (for write)
TRDOSFCB=TRDOSFCB+1
TRDOSFCB.descpos=TRDOSFCB
	;db 0 ;position of descriptor (for write) 0..127
TRDOSFCB=TRDOSFCB+1
TRDOSFCB.waseof=TRDOSFCB
	;db 0 ;-1 = waseof
TRDOSFCB=TRDOSFCB+1
TRDOSFCB.drive=TRDOSFCB
	;db 0 ;-1 = waseof
TRDOSFCB.buf=256;$-TRDOSFCB
	;ds 256 ;buffer for last sector

        ;align 256
TRDOSFCB1=trdos_fcbbuf
        ;ds 0x200*trdos_MAXFILES ;max 8 files
DOSBUF=trdos_sectorbuf
        ;ds 0x100
;TRDOSFCB2.=0x4a00 ;aligned
;TRDOSFCB3.=0x4c00 ;aligned
;TRDOSFCB4.=0x4e00 ;aligned
;TRDOSFCB5.=0x5000 ;aligned
;DOSBUF=0xff00 ;aligned

        if 1==0
;hl = poi to filename in string
findlastslash.
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
;find last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	jr z,nfopenfnslashq.
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.
nfopenfnslashq.
;de = after last slash
	ret
        endif

nfdel
;de=FCB
;TODO mask
        inc de ;filename
nfdel_filename
        ld lx,0 ;number of files just deleted
;TODO extra buffer for tr0sec8 and read number of files
	ld b,8 ;sectors
nfdelsectors0.
        ld hx,0 ;number of files just deleted in this sector
	push bc
	push de ;filename
        push ix
	ld d,0 ;track
	ld a,8
	sub b
	ld e,a ;sector
	call rdsecDOSBUF
        pop ix
	pop de ;filename
	pop bc
;de=filename
;b=sectors
	ld hl,DOSBUF
nfdelcp0.
	push bc
        push de ;filename
        push hl ;DOSBUF+
	ld bc,0x900 ;b=bytes to compare, c=errors
nfdelcp00.
	ld a,[de]
	sub [hl]
	or c
	ld c,a ;errors
	inc hl
	inc de
	djnz nfdelcp00.
        pop hl ;DOSBUF+
        pop de ;filename
	pop bc
        jr nz,nfdelcp_notthatfile
        inc hx ;number of files just deleted in this sector
       ;how to check last file? quick fix: if next file is 0 or end of dir ((b==1) && (l==0xf0))
       push de
       push hl
	ld a,l
	add a,13
	ld l,a
        ld a,(hl) ;sectors in deleted file
        ld (nfdel_addfree),a
        inc l
        ld e,(hl)
        inc l
        ld d,(hl) ;trsec of deleted file
        ld (nfdel_firstfree),de
        inc l
        jr nz,nfdelcp_delnolastinsector
        ld a,b
        dec a
        jr z,nfdelcp_delchecklastq
nfdelcp_delnolastinsector
        ld a,(hl)
        or a
nfdelcp_delchecklastq
       pop hl
       pop de
       ld (hl),a;0 if last file (once!!!)
       ld a,128 ;add flag for number of files just deleted (once!!!)
       jr z,nfdelcp_notdel1 ;set flag "last file deleted"
       ld a,1 ;add for number of files just deleted
        ld (hl),1 ;deleted
nfdelcp_notdel1
        add a,lx
        ld lx,a ;number of files just deleted
nfdelcp_notthatfile
	ld a,l
	add a,16
	ld l,a
	jr nz,nfdelcp0. ;next descriptor
;was sector changed?
        ld a,hx ;number of files just deleted in this sector
        or a
        jr z,nfdelcp_nodeletedinthissector
        push bc
        push de
        push ix
	ld d,0 ;track
	ld a,8
	sub b
	ld e,a ;sector
	call wrsecDOSBUF
        pop ix
        pop de
        pop bc
nfdelcp_nodeletedinthissector
	djnz nfdelsectors0. ;next sector
        xor a
        cp lx
        jr nz,nfdel_correctsystemsector
;not found
        ld a,0xff ;fail
        ret
nfdel_correctsystemsector
        push ix
        ld de,0x0008
        push de
        call rdsecDOSBUF
        pop de
        pop ix
;lx=1..127: deletion with 1
;lx=128..255: last deletion with 0
       ld a,lx
       add a,a
       jr nc,nfdel_correctsystemsector_nodelwith0
;if deletion with 0:
       rrca
       ld lx,a ;files just deleted 0..127
        ld hl,DOSBUF+0xe4 ;total files (including deleted ones)
        dec (hl)
nfdel_firstfree=$+1
        ld hl,0
        ld (DOSBUF+0xe1),hl ;first free sector
nfdel_addfree=$+1
        ld bc,0
        ld hl,(DOSBUF+0xe5) ;free sectors
        add hl,bc
        ld (DOSBUF+0xe5),hl ;free sectors
nfdel_correctsystemsector_nodelwith0
	ld hl,DOSBUF+0xf4 ;del files
        ld a,(hl)
        add a,lx
        ld (hl),a
        ;ld de,0x0008
        call wrsecDOSBUF
        xor a ;success
        ret
        
openwrite
        ld c,'w'
nfopen
;de=filename
;c=mode
;a=drive 0..3
	;EXPORT nfopen
        push af
       ld (trdoscurdrive),a
         push bc
         push de
         ld a,c
         cp 'w'
         call z,nfdel_filename
         pop de
         pop bc
	xor a
	ld hl,TRDOSFCB1-0x0200

	inc h
	inc h
	cp [hl]
	jr nz,$-3
;TODO check trdos_MAXFILES

	ld [hl],c ;mode in TRDOSFCB
        
        pop af
        ld l,TRDOSFCB.drive
        ld (hl),a
        call trdossetdrvfromtrdosfcb ;l=0
	
        inc hl;ld l,TRDOSFCB.fn ;poi to fn in TRDOSFCB
        
        if 1==1
;de=filename
        ex de,hl
        ld bc,11
        ldir
        ex de,hl
        else
        
	push hl ;poi to fn in TRDOSFCB
	ld d,h
	ld e,l
	inc de
	ld [hl],' '
	ld bc,8
	ldir ;empty filename
nfopen.A.=$+1
	;EXPORT nfopen.A.
	ld hl,0 ;poi to filename in string
	call findlastslash.
;de = after last slash
	pop hl ;poi to fn in TRDOSFCB
	ld b,9
nfopenfn0.
	ld a,[de]
	or a
	jr z,nfopenfnq. ;no extension in string
	inc de
	cp '.'
	jr z,nfopenfndot.
	ld [hl],a
	inc hl
	djnz nfopenfn0.
;9 bytes in filename, no dot (9th byte goes to extension)
	jr nfopenfnq.
nfopenfndot.
	inc hl
	djnz $-1 ;hl points to extension in TRDOSFCB
	dec hl
	ld a,[de] ;extension in string
	ld [hl],a ;extension in TRDOSFCB
nfopenfnq.
        endif

nfopen_reopen
;h-TRDOSFCB/256
	;xor a
	;ld l,TRDOSFCB.block
	;ld [hl],a;0 ;cur block for write, next block for read ;TODO брать из имени (тупо закомментировать)
	;inc hl
	;ld [hl],0x60 ;(padding for "start") ;TODO брать из имени (тупо закомментировать)
        
        ld l,0
        ld a,(hl)
        cp 'w'
        jr z,nfopen_nofindfile ;TODO удалить, если есть
;проверить, что файл существует, иначе вернуть ошибку и освободить FCB
        ld c,9 ;FILENAMESZ
	 ld l,TRDOSFCB.fn ;poi to fn
        call findfile
        or a
        jr nz,nfopen_fail
;hl,de = after filename
;open for read!
	ld l,TRDOSFCB.block
        ld a,(de)
        inc de
	ld [hl],a;0 ;cur block for write, next block for read
	inc hl
        ld a,(de)
        inc de
	ld [hl],a;0x60 ;(padding for "start")
       ;ld a,FALSE
       ;ld [_waseof],a
       ld l,TRDOSFCB.waseof
       ld [hl],FALSE
nfopen_nofindfile

        xor a
        ld l,TRDOSFCB.lastlen
	ld [hl],a;0 ;lastlen LSB ;???
	inc hl
	ld [hl],a;0 ;lastlen HSB ;???
	inc hl
	ld [hl],a;0 ;sectors remained in block (for read), block size (for write)
	ld l,TRDOSFCB.remain
	ld [hl],0xff ;remain (0xff = no data) for read
	inc hl
	ld [hl],a;0 ;sectors written (for write)
	ld l,a;0;TRDOSFCB.mode
	ret ;hl = poi to TRDOSFCB ;a=0 (success)

nfopen_fail
        ld l,0
        ld (hl),l;0 ;empty FCB
        ;ld a,0xff
        ret
        
trdossetdrvfromtrdosfcb
       ld l,TRDOSFCB.drive
       ld a,(hl)
       ld (trdoscurdrive),a
       ld l,0
       ret

;closewrite
	;EXPORT closewrite
fclose
;hl=poi to TRDOSFCB
	;EXPORT fclose
;closewrite.A.=$+1
	;EXPORT closewrite.A.
;fclose.A.=$+1
	;EXPORT fclose.A.
	;ld hl,0 ;poi to TRDOSFCB
       call trdossetdrvfromtrdosfcb
	ld a,[hl]
	ld [hl],l;0
	cp 'w'
	ret nz ;hl!=0
;hl = poi to TRDOSFCB
	call flush.
	;следующая проверка не годится, если будет ручной flush:
	ld l,TRDOSFCB.secwritten
	ld a,[hl]
	or a
	ret z ;no sectors written - descriptor already saved (??? TODO)
	;call flushdesc.
	;ld l,1 ;OK TODO
	;ret ;hl!=0
;write descriptor
;if created or finished
flushdesc.
;hl = poi to TRDOSFCB
	push hl ;poi to TRDOSFCB

	push hl ;poi to TRDOSFCB
	ld l,TRDOSFCB.descpos
	ld l,[hl]
	ld d,0 ;track of descriptor
	ld h,d;0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,h ;sector of descriptor
	ld h,DOSBUF>>8
	push hl ;hl = poi to descriptor
	push de ;track,sector of descriptor
	call rdsecDOSBUF
	pop bc ;track,sector of descriptor
	pop de ;poi to descriptor
	pop hl ;poi to TRDOSFCB
	push bc ;track,sector of descriptor
       ld l,TRDOSFCB.fn+8
       ld a,[hl]
       cp 'B'
       jr nz,flushdesc_nobasic
       ld l,TRDOSFCB.fn+12
       ld b,[hl]
       dec hl
       ld c,[hl] ;length
       dec hl
       ld [hl],b
       dec hl
       ld [hl],c ;start for basic
flushdesc_nobasic
	ld l,TRDOSFCB.fn
	ld bc,16
	ldir
	pop de ;track,sector of descriptor
	call wrsecDOSBUF

	pop hl ;poi to TRDOSFCB
	ret

        if 1==0
;FUNC BOOL comparedesc FORWARD(PCHAR filename, PBYTE desc);
comparedesc
comparedesc.A.=$+1 ;filename
	ld hl,0
	call findlastslash.
;de = after last slash
comparedesc.B.=$+1 ;desc
	ld hl,0
;compare until '.' or '\0' or 8 loops
	ld b,8
comparedesc0.
	ld a,[de] ;filename
	;or a
	;jr z,comparedesctrue. ;filename ended without ext (descriptor not ended)
	inc de
	cp '.'
	jr z,comparedescdot.
	cp [hl] ;descriptor
	jr nz,comparedescfalse.
	inc hl
	djnz comparedesc0.
	ld a,[de] ;filename
	inc de
	cp '.'
	jr z,comparedescdot8. ;filenam8.ext
	;filenam8 (without ext)
	ld a,[hl]
	cp ' '
	jr nz,comparedescfalse.
comparedesctrue.
	ld a,0xff ;TRUE
	ret
comparedescdot.
	inc hl
	djnz $-1 ;hl = descriptor ext
comparedescdot8.
	ld a,[de] ;filename ext
	cp [hl] ;descriptor ext
	jr z,comparedesctrue.
comparedescfalse.
	xor a ;FALSE
	ret
        endif

findfile
;find new block if exists
;find Nth block of file with hl pointed filename (10 bytes: name, ext, block N)
;hl=filename
;c=FILENAMESZ
;out: z=found (carry = off, a = 0, hl,de = after filename)
	 ;ld l,TRDOSFCB.fn ;poi to fn
	ld b,8 ;sectors
findfile0.
	push bc
	push hl
	ld d,0 ;track
	ld a,8
	sub b
	ld e,a ;sector
	call rdsecDOSBUF
	pop hl
	pop bc
;hl=filename
;b=sectors
	ld de,DOSBUF
findfilecp0.
	 ;ld l,TRDOSFCB.fn ;poi to fn
	push bc
        ld b,c ;FILENAMESZ
	ld c,0 ;b=bytes to compare, c=errors
findfilecp00.
	ld a,[de]
	sub [hl]
	or c
	ld c,a ;errors
	inc hl
	inc de
	djnz findfilecp00.
	pop bc
	ret z ;found (carry = off, a = 0, hl,de = after filename)
findfile_continue
         ld a,l
         sub c
         ld l,a
         sbc a,l
         add a,h
         ld h,a
         ;ld b,a
         ;sbc hl,bc
	ld a,e
	or 15;add a,16-FILENAMESZ;6
	ld e,a
        inc e
	jr nz,findfilecp0. ;next descriptor
	djnz findfile0. ;next sector
;not found
        xor a
        dec a ;nz=fail
        ret

;length 0 while reading means either absence of files or zero length file (any sector length)

;readf
	;EXPORT readf
;readf.A.=$+1
	;EXPORT readf.A.
	;ld hl,0 ;poi to TRDOSFCB
	;jr fread1. ;a=data ;keeps bc
;readfin
;	;EXPORT readfin
;	ld hl,[_fin] ;poi to TRDOSFCB
fread1.
;a=data
 ;;if ok then inc de?
;keeps bc
	ld l,TRDOSFCB.remain ;0xff = no data, 0xfe = 1 byte, ... 0x00 = 255 bytes
	ld e,[hl]
	ld d,h
	inc d
	inc e
	ld a,[de]
	ld [hl],e ;inc [hl] ;remain
	ret nz
fread1noremain.
	push bc
	 ;push de
;read new buf (if exists)
	ld l,TRDOSFCB.secinblk
	xor a
	cp [hl] ;sectors remained in block (0 means none)
	jr nz,fread1sec. ;a = 0
        ld c,10 ;FILENAMESZ
	 ld l,TRDOSFCB.fn ;poi to fn
        call findfile
        jr z,fread1blkq. ;found (carry = off, a = 0, hl,de = after filename)
;not found
;EOF - next block doesn't exist
fread1EOF.
	 ;pop de
	pop bc
       ;ld a,TRUE
       ;ld [_waseof],a
       ld l,TRDOSFCB.waseof
       ld [hl],TRUE
       ld a,0x0a;'\n' ;EOF returns '\n'
;set vars as they were (next time EOF again)
	ld l,TRDOSFCB.remain
	dec [hl] ;remain = 0xff
	ret
fread1blkq.
;de = poi to descriptor + 10
;hl = poi to fn + 10
;a = 0
	;ld l,TRDOSFCB.fn + 10
	ex de,hl
;hl = poi to descriptor + 10
;de = poi to filename + 10
	ld bc,16-10 ;padding, len(LSB), len(HSB), secinblk, sec, track
	ldir
	ex de,hl
	ld l,TRDOSFCB.firstsector
	ld e,[hl]
	inc hl
	ld d,[hl]
	ld l,TRDOSFCB.cursector
	ld [hl],e
	inc hl
	ld [hl],d
;secinblk = (lastlen+255)/256 = (lastlen-1)/256 + 1
;иначе нельзя будет выделять блоки навырост (как делает TR-DOS)
	ld l,TRDOSFCB.lastlen
	ld e,[hl]
	inc hl
	ld d,[hl]
	dec de
	inc d
	inc hl ;ld l,TRDOSFCB.secinblk
	ld [hl],d
	jr z,fread1EOF. ;(secinblk == 0)
	ld l,TRDOSFCB.block
	inc [hl] ;cur block for write, next block for read
fread1sec.
;read next sector
;a = 0
	ld l,TRDOSFCB.cursector
	push hl ;poi to cursector
	ld e,[hl]
	inc hl
	ld d,[hl]
	inc h
	ld l,a;0 ;poi to buf
	call rdsec.
	ex de,hl ;ld de,[0x5cf4] ;de=next sector
	pop hl ;poi to cursector
	ld [hl],e
	inc hl
	ld [hl],d
;if last sector of block, then remain = -lastlen and shift data in buf to the end
;else remain = 0 (read + 255 bytes)
	xor a
	ld l,TRDOSFCB.secinblk
	dec [hl] ;sectors remained in block
	jr nz,fread1nlast.
;last sector in block: shift data to the end of buf
	ld l,TRDOSFCB.lastlen
	ld c,[hl] ;1..256
	ld b,a;0
	dec c ;0..255
	ld l,c ;end of data
	inc h
	inc bc ;1..256
	ld d,h
	ld e,0xff
	lddr
	;hl = poi to buf - 1
	;h = poi to TRDOSFCB
	ld a,e ;0xfe (1 byte) ... -1 (256 bytes)
	inc a ;remain = 0xff (read + no data) ... 0 (read + 255 bytes)
fread1nlast.
	ld l,TRDOSFCB.remain
	ld [hl],a
	 ;pop de
	pop bc
fread1ok.
;hl = poi to remain
	ld l,[hl]
	inc h
	ld a,[hl]
	 ;inc de
	ret

fread
;hl=poi to data
;de=poi to TRDOSFCB
;bc=size
;out: hl=total processed bytes
	;EXPORT fread
;fread.A.=$+1
	;EXPORT fread.A.
	;ld hl,0 ;poi to data
	 ;ld de,0 ;total processed bytes
;fread.C.=$+1
	;EXPORT fread.C.
	;ld bc,0 ;count
;fread0.
	;push bc
;fread.B.=$+1
	;EXPORT fread.B.
	;ld bc,0 ;size
       ex de,hl
       call trdossetdrvfromtrdosfcb
       ex de,hl
        ;ld (fread00size),bc
        ld (fread00addr),hl
        if 1==1
;read by sectors:
       ld e,TRDOSFCB.waseof
       ld a,[de]
       ;ld a,[_waseof]
       or a ;FALSE
       jp nz,fread00q;freadbysector0q
	ld e,TRDOSFCB.remain ;0xff = no data, 0xfe = 1 byte, ... 0x00 = 255 bytes
	ld a,[de]
        inc a
        jr nz,fread00. ;not at sector margin (TODO read the beginning by bytes)
        ld a,b
        or a
        jr z,fread00. ;length < 256
       dec bc
       inc b ;b=number of loops

;TODO if full block, read it with one dos call
;de=poi to TRDOSFCB
;hl=read addr
;bc="remaining size" (not quite)

;if secinblk-1 < b, read secinblk-1 sectors, b-=(secinblk-1), secinblk = 1
	ld e,TRDOSFCB.secinblk
        ld a,[de] ;sectors remained in block
        dec a
	jr z,fread1nfulblock.
         cp 63
         jr nc,fread1nfulblock.
        sub b
	jr nc,fread1nfulblock. ;secinblk-1 >= b, a = (secinblk-1) - b
        neg ;a = b - (secinblk-1)
        ld b,a
        push bc
        ex de,hl
        ld b,[hl] ;secinblk
        dec b ;secinblk-1
        ld [hl],1 ;secinblk
	ld l,TRDOSFCB.cursector
	push hl ;poi to cursector
;de=read addr
	ld a,[hl]
	inc hl
	ld h,[hl] ;trsec
        ld l,a
        ex de,hl
;hl=read addr
;de=trsec
       push bc
       push hl
	call rdsectors. ;b = secinblk-1 sectors
	ld b,h
        ld c,l ;ld bc,[0x5cf4] ;bc=next sector
       pop de
       pop af ;"b"
       add a,d
       ld d,a
;de=read addr
	pop hl ;poi to cursector
	ld [hl],c
	inc hl
	ld [hl],b
        ex de,hl
;de=poi to TRDOSFCB
;hl=read addr
        pop bc
fread1nfulblock.

;de=poi to TRDOSFCB
;hl=read addr
;bc=remaining size
freadbysector0.
        push de
	push hl
        ld h,d
	ld e,0
	inc d ;de=TRDOSFCB+256 (i.e. sector buffer)
        call fread1noremain.
	pop hl
        pop de
       ld e,TRDOSFCB.waseof
       ld a,[de]
       ;ld a,[_waseof]
       or a ;FALSE
       jr nz,fread00q
        push bc
        push de
        ex de,hl ;data is at the end of buf
        ld l,TRDOSFCB.remain ;0xff = 1 byte, 0xfe = 2 bytes, ... 0x00 = 256 bytes (including the returned byte that we've ignored)
        ld l,[hl]
        inc h ;hl=buf with data
        ld b,a;0
        ld a,l ;0xff..0x00
        cpl
        ld c,a ;0..255
        inc bc ;1..256
        ldir
        ex de,hl
        pop de
        pop bc
       inc a
       jr nz,EOFfread00q ;last (short) sector in file
        djnz freadbysector0.
;bc=remaining size < 256
       ld e,TRDOSFCB.remain ;0xff = no data, 0xfe = 1 byte, ... 0x00 = 255 bytes
       ld a,0xff
       ld [de],a
        jr fread00q
EOFfread00q
       ld e,TRDOSFCB.waseof
       ld a,TRUE
       ld [de],a
        jr fread00q
        endif
;de=poi to TRDOSFCB
;hl=read addr
;bc=remaining size
;read by bytes:
fread00.
        push de
	push hl
;fread.D.=$+1
	;EXPORT fread.D.
	ex de,hl ;ld hl,0 ;hl=poi to TRDOSFCB
	call fread1. ;a=data ;keeps bc
	pop hl
        pop de
	ld [hl],a ;may be EOF!
       ld e,TRDOSFCB.waseof
       ld a,[de]
       ld e,0
       ;ld a,[_waseof]
       or a ;FALSE
       jr nz,fread00q ;jr nz,freadpopret.
	;cpi
	db 0xed,0xa1
	jp pe,fread00.
	;pop bc
	;dec hl
	;cpi
	;db 0xed,0xa1
	;jp pe,fread0.
	 ;ex de,hl ;hl = total processed bytes
fread00q
;bc=size-processedbytes
;fread00size=$+1
;        ld hl,0
;        xor a ;a=0: no error
;        sbc hl,bc ;hl=processedbytes
;hl=addr+processedbytes
fread00addr=$+1
        ld bc,0
        xor a ;a=0: no error
        sbc hl,bc ;hl=processedbytes
	ret
;freadpopret.
	;pop bc
	;ret

        if 1==0
fwritebyte
	;EXPORT fwritebyte
fwritebyte.A.=$+1
	;EXPORT writebyte.A.
	ld hl,0 ;file
fwritebyte.B.=$+1
	;EXPORT writebyte.B.
	ld a,0
	jp fwrite1.
        endif
;writefout
	;EXPORT writefout
	;ld hl,[_fout]
;writefout.A.=$+1
	;EXPORT writefout.A.
	;ld a,0
;hl = poi to TRDOSFCB
;a=data
;keeps bc
fwrite1.
        ;jr $
	ld l,TRDOSFCB.lastlen
	ld e,[hl]
	ld d,h
	inc d
	ld [de],a
	inc [hl] ;lastlen (LSB)
	;Z = end of buf
	ret nz
	inc l
	inc [hl] ;lastlen (HSB)
flush.
;ручной flush пока невозможен!!!
;can create zero length file
;hl = poi to TRDOSFCB
	push bc

;if secwritten == 0 then reserve sectors, reserve descriptor
	ld l,TRDOSFCB.secwritten
	ld a,[hl]
	or a
	jr nz,flushnnew.
;глючит, если последний блок <256 TODO
;потому что fclose второй раз вызывает flush
	ld l,TRDOSFCB.secinblk
	ld [hl],SECINBLK;16 ;TR-DOS reserves 16 sectors per block
;update sec8
	push hl ;poi to TRDOSFCB
	ld de,0x0008
	push de
	call rdsecDOSBUF
	pop de ;0x0008
	ld hl,[DOSBUF+0xe5] ;free sectors
	ld bc,-SECINBLK;16
	add hl,bc
	 ;bit 7,h
	 ;jr nz,$ ;no free sectors
	ld [DOSBUF+0xe5],hl ;free sectors
        ;jr $
	ld hl,DOSBUF+0xe4 ;files
	ld a,[hl] ;descriptor position 0..127
	 ;or a
	 ;jp m,$ ;128 files, can't add
	inc [hl] ;files

	ld l,0xe1 ;free sector
	ld c,[hl]
	inc hl
	ld b,[hl]
	;inc [hl] ;add 16 sectors = add 1 track
        push bc
        ld lx,SECINBLK
        call addsectors
        ld (hl),b
        dec hl
        ld (hl),c
        pop bc

	pop hl ;poi to TRDOSFCB
	ld l,TRDOSFCB.descpos
	ld [hl],a ;descriptor position 0..127
	ld l,TRDOSFCB.firstsector
	ld [hl],c
	inc hl
	ld [hl],b
	ld l,TRDOSFCB.cursector
	ld [hl],c
	inc hl
	ld [hl],b

	push hl ;poi to TRDOSFCB
	;ld de,0x0008
	call wrsecDOSBUF ;write sec8
	pop hl ;poi to TRDOSFCB
flushnnew.

;write buf
	ld l,TRDOSFCB.cursector
	push hl ;poi to cursector
	ld e,[hl]
	inc hl
	ld d,[hl]
	ld l,0
	inc h ;poi to buf
	call wrsec.
	ex de,hl ;ld de,(0x5cf4) ;de=next sector
	pop hl ;poi to cursector
	ld [hl],e
	inc hl
	ld [hl],d

;increase secwritten
;get new block if this block filled up
	ld l,TRDOSFCB.secinblk
	ld a,[hl]
	ld l,TRDOSFCB.secwritten
	inc [hl]
	sub [hl]
	jr nz,flushnblk. ;not filled up
;block is filled up
;zero secwritten
	;ld l,TRDOSFCB.secwritten
	ld [hl],a;0 ;block not created
;write descriptor
	call flushdesc.
;increase block number (after flushdesc!!!)
	ld l,TRDOSFCB.block
	inc [hl] ;cur block for write, next block for read
;теперь дескриптор невалидный, пока не создадим его в начале другого flush
;zero lastlen (after flushdesc!!!)
	ld l,TRDOSFCB.lastlen+1 ;(HSB), LSB is already 0 if not fclose
	ld [hl],0
flushnblk.

	pop bc
	ret

addsectors
;bc=trsec
;lx=number of sectors
;keeps a
        inc lx
        jr flush_addsectors_go
flush_addsectors0
        inc c
        bit 4,c
        jr z,$+2+3
        ld c,0
        inc b
flush_addsectors_go
        dec lx
        jr nz,flush_addsectors0
        ret

fwrite
;hl=poi to data
;de=poi to TRDOSFCB
;bc=size
	;EXPORT fwrite
;fwrite.A.=$+1
	;EXPORT fwrite.A.
	;ld hl,0 ;poi to data
	 ;ld de,0 ;total processed bytes TODO
;fwrite.C.=$+1
	;EXPORT fwrite.C.
	;ld bc,0 ;count
;fwrite0.
	;push bc
;fwrite.B.=$+1
	;EXPORT fwrite.B.
	;ld bc,0 ;size
       ex de,hl
       call trdossetdrvfromtrdosfcb
       ex de,hl
        ;ld (fread00size),bc
        ld (fread00addr),hl
fwrite00.
	ld a,[hl]
        push de
	push hl
	 ;push de
;fwrite.D.=$+1
	ex de,hl ;ld hl,0 ;poi to TRDOSFCB
	call fwrite1. ;a=data ;keeps bc
	 ;pop de
	 ;inc de
	pop hl
        pop de
	;cpi
	db 0xed,0xa1
	jp pe,fwrite00.
	;pop bc
	;dec hl
	;cpi
	;db 0xed,0xa1
	;jp pe,fwrite0.
	 ;ex de,hl ;hl = total processed bytes
	jp fread00q ;ret

;FUNC UINT readsectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
readsectors
readsectors.A.=$+1 ;buf
	ld hl,0
readsectors.B.=$+1 ;trsec
	ld de,0
readsectors.C.=$+1 ;count
	ld b,0
	jr rdsectors.
rdsecDOSBUF
	ld hl,DOSBUF
rdsec.
	ld b,1
rdsectors.
	ld c,0x05
        ;push hl ;read address
        ;ld hl,0x8000 ;pgkillable
        ;push bc
        ;push hl
        jp iodos. ;hl=next sector
        ;pop hl
        ;pop bc
        ;ld c,0
        ;pop de ;read address
        ;ldir
        ;ld hl,(0x5cf4);(sysvars+0x00f4) ;next sector
        ;ret

;FUNC UINT writesectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
writesectors
writesectors.A.=$+1 ;buf
	ld hl,0
writesectors.B.=$+1 ;trsec
	ld de,0
writesectors.C.=$+1 ;count
	ld b,0
	jr wrsectors.
wrsecDOSBUF
	ld hl,DOSBUF
wrsec.
	ld b,1
wrsectors.
        ;push bc
        ;push de ;track,sector
        ;ld c,0
        ;ld de,0x8000 ;pgkillable
        ;push de
        ;ldir
        ;pop hl
        ;pop de ;track,sector
        ;pop bc
	ld c,0x06
iodos.
trdoscurdrive=$+1
        ld a,0xff
	call iodos_setdrive
        ;ld iy,23610
	call dos3d13. ;returns a=error (from 0x5d0f)
        ld hl,(0x5cf4);(sysvars+0x00f4) ;next sector
        ret

iodos_setdrive_okq
        xor a
        ret
iodos_setdrive
trdosolddrive=$+1
		cp 0xff
		jr z,iodos_setdrive_okq
		ld (trdoscurdrive),a
		push bc
		push de
		push hl
		ld a,(trdoscurdrive)
		ld c,1
		call dos3d13nopg.
		;call iodos_chd_cherr
		ld c,0x18
		call dos3d13nopg.
		call iodos_chd_cherr
		;ld bc,0x0105
		;ld hl,trdos_sectorbuf
		;ld de,0x0008
		;call dos3d13nopg.
		;call iodos_chd_cherr
		ld a,(trdoscurdrive)
		ld (trdosolddrive),a
		xor a
		jr iodos_chd_noerr
iodos_chd_cherr
		or a
		ret z
		ld a,0xff
		ld (trdosolddrive),a
        dec a ;Alone Coder: чтобы были не равны в следующий заход, тогда опять будем пытаться включить драйв
        ld (trdoscurdrive),a
		ld a,0xff
		pop hl
iodos_chd_noerr
        pop hl
        pop de
        pop bc
		ret