_fin
	EXPORT _fin
	DW 0
_fout
	EXPORT _fout
	DW 0
_waseof
	EXPORT _waseof
	DB 0

IOFCB=0
	;db 0 ;0 = free, 'r' = read, 'w' = write
IOFCB=IOFCB+1
;;;;;;;;;;;;;;; copy of TR-DOS descriptor ;;;;;;;;;;;;;;
IOFCB.fn=IOFCB
	;db "12345678c" ;filename
IOFCB=IOFCB+9
IOFCB.block=IOFCB
	;db 0 ;cur block for write, next block for read
	;db 0x60 ;(padding for "start")
IOFCB=IOFCB+2
IOFCB.lastlen=IOFCB
	;dw 0 ;length of block
IOFCB=IOFCB+2
IOFCB.secinblk=IOFCB
	;db 0 ;sectors remained in block (for read), block size (for write)
IOFCB=IOFCB+1
IOFCB.firstsector=IOFCB
	;dw 0 ;first sector of block (for write)
IOFCB=IOFCB+2
;;;;;;;;;;;;;;; end of TR-DOS descriptor ;;;;;;;;;;;;;;
IOFCB.cursector=IOFCB
	;dw 0 ;cur sector for write, next sector for read
IOFCB=IOFCB+2
IOFCB.remain=IOFCB
	;db 0xff ;remaining bytes in buf (for read)
IOFCB=IOFCB+1
IOFCB.secwritten=IOFCB
	;db 0 ;sectors written (for write)
IOFCB=IOFCB+1
IOFCB.descpos=IOFCB
	;db 0 ;position of descriptor (for write) 0..127
IOFCB=IOFCB+1
IOFCB.buf=256;$-IOFCB
	;ds 256 ;buffer for last sector

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
nfopen.A.=$+1
	EXPORT nfopen.A.
	ld de,0 ;poi to filename in string
;проверить, что файл существует, иначе вернуть ошибку и освободить FCB
        push hl
        ld l,0
        ld a,(hl)
        cp 'w'
        jr nz,nfopen_noopenwrite
        ;OS_CREATEHANDLE
        ld c,CMD_CREATEHANDLE;0x44
        call BDOS;0x0005
        jr nfopen_openwriteq
nfopen_noopenwrite
        ;OS_OPENHANDLE
        ld c,CMD_OPENHANDLE;0x43
        call BDOS;0x0005
nfopen_openwriteq
        pop hl
        or a
        jr nz,nfopen_fail.

        ld l,0x80
        ld [hl],b ;handle

	xor a
        ld l,IOFCB.lastlen
	ld [hl],a;0 ;lastlen LSB ;for write
	inc hl
	ld [hl],a;0 ;lastlen HSB ;for write
	inc hl
	ld [hl],a;0 ;sectors remained in block (for read), block size (for write)
	ld l,IOFCB.remain
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
	;jr nz,fcloseq ;ret nz ;hl!=0
;hl = poi to FCB
        call z,fwriteflush
;fcloseq
        ld l,0x80
        ld b,[hl]
        ;OS_CLOSEHANDLE
        ld c,CMD_CLOSEHANDLE;0x45
        call BDOS;0x0005
        ret

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
	ld l,IOFCB.remain ;0xff = no data, 0xfe = 1 byte, ... 0x00 = 255 bytes
	ld e,[hl]
	ld d,h
	inc d
	inc e
	ld a,[de]
	ld [hl],e ;inc [hl] ;remain
	ret nz
        ;ld e,0
        ld [hl],e

        ;de=IOFCB+256
        push bc
        push hl
        ld l,0x80
        ld b,[hl]
        ld hl,256 ;TODO 512
        ;OS_READHANDLE
        ld c,CMD_READHANDLE;0x48
        call BDOS;0x0005
        ex de,hl
        pop hl
        pop bc
        ;or a
        ;jr z,fread1ok.
        ld a,d
        or e
        jr z,fread1EOF.
          dec d
          jr z,fread1ok.
         ld a,e ;1..256
;a=len
;last sector in block: shift data to the end of buf
	ld l,IOFCB.lastlen ;???
        ld [hl],a
        push bc
	ld c,[hl] ;1..256
	ld b,0
	dec c ;0..255 for 1..256
	ld l,c ;end of data
	inc h
	inc bc ;1..256
	ld d,h
	ld e,0xff
	lddr
        pop bc
        ld l,IOFCB.remain
        ld [hl],e
        jr fread1.
fread1ok.
        ld l,0
	inc h
	ld a,[hl]
        ret
fread1EOF.
       ld a,TRUE
       ld [_waseof],a
       ld a,'\n' ;EOF returns '\n'
;set vars as they were (next time EOF again)
	ld l,IOFCB.remain
	dec [hl] ;remain = 0xff
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
;hl = poi to IOFCB
;a=data
;keeps bc
fwrite1.
	ld l,IOFCB.lastlen
	ld e,[hl]
	ld d,h
	inc d
	ld [de],a
	inc [hl] ;lastlen (LSB)
	ret nz
        inc e ;ld e,0 ;de=IOFCB+256
        push bc
        push hl
        ld l,0x80
        ld b,[hl]
        ld hl,256
fwrite1q
        ;OS_WRITEHANDLE
        ld c,CMD_WRITEHANDLE;0x49
        call BDOS;0x0005
        pop hl
        pop bc
        ret
fwriteflush
;hl = poi to IOFCB
;de undefined
	ld l,IOFCB.lastlen
        
        ;push hl
        ; ld a,[hl] ;0..255
        ; rst 16
        ; ld a,0x0d
        ; rst 16
        ; ld a,0x0a
        ; rst 16
        ;pop hl
        
         ld a,[hl] ;0..255
         or a
         ret z
	ld d,h
	inc d
        ld e,0
        ld [hl],e ;lastlen=0
        
        ;de=IOFCB+256
        ;a=lastlen = 0..255
        push bc
        push hl
        ld l,0x80
        ld b,[hl]
        ld l,a
        ld h,0 ;hl=0..255
        jr fwrite1q
       

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
	ld hl,0 ;poi to IOFCB
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
	ld hl,0 ;poi to IOFCB
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
	ld [fclose.A.],hl ;IOFCB
	ld [fread.D.],hl ;IOFCB
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
