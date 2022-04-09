_fin
	EXPORT _fin
	DW 0
_fout
	EXPORT _fout
	DW 0
_waseof
	EXPORT _waseof
	DB 0

FCB=0
	;db 0 ;0 = free, 'r' = read, 'w' = write
FCB=FCB+1
;;;;;;;;;;;;;;; copy of TR-DOS descriptor ;;;;;;;;;;;;;;
FCB.fn=FCB
	;db "12345678c" ;filename
FCB=FCB+9
FCB.block=FCB
	;db 0 ;cur block for write, next block for read
	;db 0x60 ;(padding for "start")
FCB=FCB+2
FCB.lastlen=FCB
	;dw 0 ;length of block
FCB=FCB+2
FCB.secinblk=FCB
	;db 0 ;sectors remained in block (for read), block size (for write)
FCB=FCB+1
FCB.firstsector=FCB
	;dw 0 ;first sector of block (for write)
FCB=FCB+2
;;;;;;;;;;;;;;; end of TR-DOS descriptor ;;;;;;;;;;;;;;
FCB.cursector=FCB
	;dw 0 ;cur sector for write, next sector for read
FCB=FCB+2
FCB.remain=FCB
	;db 0xff ;remaining bytes in buf (for read)
FCB=FCB+1
FCB.secwritten=FCB
	;db 0 ;sectors written (for write)
FCB=FCB+1
FCB.descpos=FCB
	;db 0 ;position of descriptor (for write) 0..127
FCB=FCB+1
FCB.buf=256;$-FCB
	;ds 256 ;buffer for last sector

;FCB1.=0x4800 ;aligned
;FCB2.=0x4a00 ;aligned
;FCB3.=0x4c00 ;aligned
;FCB4.=0x4e00 ;aligned
;FCB5.=0x5000 ;aligned
;DOSBUF=0xff00 ;aligned

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

topenwr.
	db "wb"
	db 0

openwrite
	EXPORT openwrite
	ld hl,topenwr.
	ld [nfopen.B.],hl
openwrite.A.=$+1
	EXPORT openwrite.A.
	ld hl,0 ;filename
	ld [nfopen.A.],hl
nfopen
	EXPORT nfopen
	xor a
	ld hl,FCB1-0x0200

	inc h
	inc h
	cp [hl]
	jr nz,$-3

;nfopenFCB
nfopen.B.=$+1
	EXPORT nfopen.B.
	ld a,[0] ;poi to mode ("wb"/"rb")
	ld [hl],a ;mode in FCB
	inc hl ;poi to fn in FCB
	push hl ;poi to fn in FCB
	ld d,h
	ld e,l
	inc de
	ld [hl],' '
	ld bc,8
	ldir ;empty filename
nfopen.A.=$+1
	EXPORT nfopen.A.
	ld hl,0 ;poi to filename in string
	call findlastslash.
;de = after last slash
	pop hl ;poi to fn in FCB
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
	djnz $-1 ;hl points to extension in FCB
	dec hl
	ld a,[de] ;extension in string
	ld [hl],a ;extension in FCB
nfopenfnq.

        xor a
	ld l,FCB.block
	ld [hl],a;0 ;cur block (for write!)
	inc hl
	ld [hl],0x60 ;(padding for "start")

        ld l,a;0
        ld a,(hl)
        cp 'w'
        jr z,nfopen_nofindfile. ;TODO удалить, если есть
;проверить, что файл существует, иначе вернуть ошибку и освободить FCB
        ld c,9 ;FILENAMESZ
        call findfile
        or a
        jr nz,nfopen_fail.
;hl,de = after filename
;open for read!
	ld l,FCB.block
        ld a,(de)
        inc de
	ld [hl],a;0 ;cur block for write, next block for read
	inc hl
        ld a,(de)
        inc de
	ld [hl],a;0x60 ;(padding for "start")
       ;ld a,FALSE
       ;ld [_waseof],a
nfopen_nofindfile.

	xor a
	;ld l,FCB.block
	;ld [hl],a;0 ;cur block for write, next block for read
	;inc hl
	;ld [hl],0x60 ;(padding for "start")
	;inc hl
        ld l,FCB.lastlen
	ld [hl],a;0 ;lastlen LSB ;???
	inc hl
	ld [hl],a;0 ;lastlen HSB ;???
	inc hl
	ld [hl],a;0 ;sectors remained in block (for read), block size (for write)
	ld l,FCB.remain
	ld [hl],0xff ;remain (0xff = no data) for read
	inc hl
	ld [hl],a;0 ;sectors written (for write)
	ld l,a;0;FCB.mode
	ret ;hl = poi to FCB

nfopen_fail.
        ld l,0
        ld (hl),l;0 ;empty FCB
        ld h,l ;hl=0
        ret

closewrite
	EXPORT closewrite
fclose
	EXPORT fclose
closewrite.A.=$+1
	EXPORT closewrite.A.
fclose.A.=$+1
	EXPORT fclose.A.
	ld hl,0 ;poi to FCB
	ld a,[hl]
	ld [hl],l;0
	cp 'w'
	ret nz ;hl!=0
;hl = poi to FCB
	call flush.
	;следующая проверка не годится, если будет ручной flush:
	ld l,FCB.secwritten
	ld a,[hl]
	or a
	ret z ;no sectors written - descriptor already saved
	;call flushdesc.
	;ld l,1 ;OK TODO
	;ret ;hl!=0
;write descriptor
;if created or finished
flushdesc.
;hl = poi to FCB
	push hl ;poi to FCB

	push hl ;poi to FCB
	ld l,FCB.descpos
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
	pop hl ;poi to FCB
	ld l,FCB.fn
	push bc ;track,sector of descriptor
	ld bc,16
	ldir
	pop de ;track,sector of descriptor
	;ld hl,DOSBUF
	call wrsecDOSBUF

	pop hl ;poi to FCB
	ret

;FUNC LONG getfiletime FORWARD(PCHAR filename);
getfiletime
	EXPORT getfiletime
getfiletime.A.=$+1
	EXPORT getfiletime.A.
        ld de,0
        ld c,9 ;c=FILENAMESZ
        call findfile
;carry = off, a = 0, de = DOSBUF after filename, b = 8-sector
        ld a,e
       and 0xf0
        ld e,a
        ld a,8
        sub b
        ld d,a
        ld hl,0
;out: hlde=datetime
        ret

findfile
;find new block if exists
;find Nth block of file with hl pointed filename (10 bytes: name, ext, block N)
;c=FILENAMESZ
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
	ld l,FCB.fn ;poi to fn
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
	ld a,e
	or 15;add a,16-FILENAMESZ;6
	ld e,a
        inc e
	jr nz,findfilecp0. ;next descriptor
	djnz findfile0. ;next sector
;not found
        ld a,0xff ;fail
        ret

;length 0 while reading means either absence of files of zero length file (any sector length)

readf
	EXPORT readf
readf.A.=$+1
	EXPORT readf.A.
	ld hl,0 ;poi to FCB
	jr fread1. ;a=data ;keeps bc
readfin
	EXPORT readfin
	ld hl,[_fin] ;poi to FCB
fread1.
;a=data
 ;;if ok then inc de?
;keeps bc
	ld l,FCB.remain ;0xff = no data, 0xfe = 1 byte, ... 0x00 = 255 bytes
	ld e,[hl]
	ld d,h
	inc d
	inc e
	ld a,[de]
	ld [hl],e ;inc [hl] ;remain
	ret nz

	push bc
	 ;push de
;read new buf (if exists)
	ld l,FCB.secinblk
	xor a
	cp [hl] ;sectors remained in block (0 means none)
	jr nz,fread1sec. ;a = 0
        ld c,10 ;FILENAMESZ
        call findfile
        jr z,fread1blkq. ;found (carry = off, a = 0, hl,de = after filename)
;not found
;EOF - next block doesn't exist
fread1EOF.
	 ;pop de
	pop bc
       ld a,TRUE
       ld [_waseof],a
       ld a,'\n' ;EOF returns '\n'
;set vars as they were (next time EOF again)
	ld l,FCB.remain
	dec [hl] ;remain = 0xff
	ret
fread1blkq.
;de = poi to descriptor + 10
;hl = poi to fn + 10
;a = 0
	;ld l,FCB.fn + 10
	ex de,hl
;hl = poi to descriptor + 10
;de = poi to filename + 10
	ld bc,16-10 ;padding, len(LSB), len(HSB), secinblk, sec, track
	ldir
	ex de,hl
	ld l,FCB.firstsector
	ld e,[hl]
	inc hl
	ld d,[hl]
	ld l,FCB.cursector
	ld [hl],e
	inc hl
	ld [hl],d
;secinblk = (lastlen+255)/256 = (lastlen-1)/256 + 1
;иначе нельзя будет выделять блоки навырост (как делает TR-DOS)
	ld l,FCB.lastlen
	ld e,[hl]
	inc hl
	ld d,[hl]
	dec de
	inc d ;only for 16 sectors in block!
	inc hl ;ld l,FCB.secinblk
	ld [hl],d
	jr z,fread1EOF. ;(secinblk == 0)
	ld l,FCB.block
	inc [hl] ;cur block for write, next block for read
fread1sec.
;read next sector
;a = 0
	ld l,FCB.cursector
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
	ld l,FCB.secinblk
	dec [hl] ;sectors remained in block
	jr nz,fread1nlast.
;last sector in block: shift data to the end of buf
	ld l,FCB.lastlen
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
	;h = poi to FCB
	ld a,e ;0xfe (1 byte) ... -1 (256 bytes)
	inc a ;remain = 0xff (read + no data) ... 0 (read + 255 bytes)
fread1nlast.
	ld l,FCB.remain
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
	EXPORT fread
fread.A.=$+1
	EXPORT fread.A.
	ld hl,0 ;poi to data
	 ;ld de,0 ;total processed bytes
fread.C.=$+1
	EXPORT fread.C.
	ld bc,0 ;count
fread0.
	push bc
fread.B.=$+1
	EXPORT fread.B.
	ld bc,0 ;size
fread00.
	push hl
fread.D.=$+1
	EXPORT fread.D.
	ld hl,0 ;poi to FCB
	call fread1. ;a=data ;keeps bc
	pop hl
	ld [hl],a
       ld a,[_waseof]
       or a ;FALSE
       jr nz,freadpopret.
	;cpi
	db 0xed,0xa1
	jp pe,fread00.
	pop bc
	dec hl
	;cpi
	db 0xed,0xa1
	jp pe,fread0.
	 ;ex de,hl ;hl = total processed bytes
	ret
freadpopret.
	pop bc
	ret

writebyte
	EXPORT writebyte
writebyte.A.=$+1
	EXPORT writebyte.A.
	ld hl,0 ;file
writebyte.B.=$+1
	EXPORT writebyte.B.
	ld a,0
	jp fwrite1.
writefout
	EXPORT writefout
	ld hl,[_fout]
writefout.A.=$+1
	EXPORT writefout.A.
	ld a,0
;hl = poi to FCB
;a=data
;keeps bc
fwrite1.
	ld l,FCB.lastlen
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
;hl = poi to FCB
	push bc

;if secwritten == 0 then reserve sectors, reserve descriptor
	ld l,FCB.secwritten
	ld a,[hl]
	or a
	jr nz,flushnnew.
;глючит, если последний блок <256
;потому что fclose второй раз вызывает flush
	ld l,FCB.secinblk
	ld [hl],16 ;TR-DOS reserves 16 sectors per block
;update sec8
	push hl ;poi to FCB
	ld de,0x0008
	push de
	call rdsecDOSBUF
	pop de ;0x0008
	ld hl,[DOSBUF+0xe5] ;free sectors
	ld bc,-16
	add hl,bc
	 ;bit 7,h
	 ;jr nz,$ ;no free sectors
	ld [DOSBUF+0xe5],hl ;free sectors

	ld hl,DOSBUF+0xe4 ;files
	ld a,[hl] ;descriptor position 0..127
	 ;or a
	 ;jp m,$ ;128 files, can't add
	inc [hl] ;files

	ld l,0xe1 ;free sector
	ld c,[hl]
	inc hl
	ld b,[hl]
	inc [hl] ;add 16 sectors = add 1 track

	pop hl ;poi to FCB
	ld l,FCB.descpos
	ld [hl],a ;descriptor position 0..127
	ld l,FCB.firstsector
	ld [hl],c
	inc hl
	ld [hl],b
	ld l,FCB.cursector
	ld [hl],c
	inc hl
	ld [hl],b

	push hl ;poi to FCB
	;ld de,0x0008
	;ld hl,DOSBUF
	call wrsecDOSBUF ;write sec8
	pop hl ;poi to FCB
flushnnew.

;write buf
	ld l,FCB.cursector
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
	ld l,FCB.secinblk
	ld a,[hl]
	ld l,FCB.secwritten
	inc [hl]
	sub [hl]
	jr nz,flushnblk. ;not filled up
;block is filled up
;zero secwritten
	;ld l,FCB.secwritten
	ld [hl],a;0 ;block not created
;write descriptor
	call flushdesc.
;increase block number (after flushdesc!!!)
	ld l,FCB.block
	inc [hl] ;cur block for write, next block for read
;теперь дескриптор невалидный, пока не создадим его в начале другого flush
;zero lastlen (after flushdesc!!!)
	ld l,FCB.lastlen+1 ;(HSB), LSB is already 0 if not fclose
	ld [hl],0
flushnblk.

	pop bc
	ret

fwrite
	EXPORT fwrite
fwrite.A.=$+1
	EXPORT fwrite.A.
	ld hl,0 ;poi to data
	 ;ld de,0 ;total processed bytes TODO
fwrite.C.=$+1
	EXPORT fwrite.C.
	ld bc,0 ;count
fwrite0.
	push bc
fwrite.B.=$+1
	EXPORT fwrite.B.
	ld bc,0 ;size
fwrite00.
	ld a,[hl]
	push hl
	 ;push de
fwrite.D.=$+1
	ld hl,0 ;poi to FCB
	call fwrite1. ;a=data ;keeps bc
	 ;pop de
	 ;inc de
	pop hl
	;cpi
	db 0xed,0xa1
	jp pe,fwrite00.
	pop bc
	dec hl
	;cpi
	db 0xed,0xa1
	jp pe,fwrite0.
	 ;ex de,hl ;hl = total processed bytes
	ret

fputs
	EXPORT fputs
;todo optimize
fputs.A.=$+1
	EXPORT fputs.A.
	ld bc,0 ;poi to string
	jp fputsgo.
fputs0.
fputs.B.=$+1
	EXPORT fputs.B.
	ld hl,0 ;poi to FCB
	call fwrite1. ;a=data
	inc bc
fputsgo.
	ld a,[bc]
	or a
	jp nz,fputs0.
	ret ;end of string ;(TODO hl = non-negative value)

loadfile
loadfile.A.=$+1 ;filename
	ld hl,0
	ld [nfopen.A.],hl
	ld hl,loadfile.mode.
	ld [nfopen.B.],hl
	call nfopen
         ld a,h
         or l
         ret z
	ld [fclose.A.],hl ;FCB
	ld [fread.D.],hl ;FCB
loadfile.B.=$+1 ;addr
	ld hl,0
	ld [fread.A.],hl ;addr
	ld hl,1
	ld [fread.B.],hl ;size
	ld hl,0xffff
	ld [fread.C.],hl ;count
       ld a,FALSE
       ld [_waseof],a
	call fread
	push hl
	call fclose
	pop hl
	ret
loadfile.mode.
	db "rb"
	db 0

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
dos3d13.
	call 0x3d13
	ld hl,[0x5cf4] ;return hl=next sector
	ret

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
	ld c,0x06
	jr dos3d13.
