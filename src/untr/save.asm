untr_save
        ld de,tfilename
        OS_CREATEHANDLE
        ld a,b
        ld (curhandle),a
        
        ld de,theader
        ld hl,szheader
        call save_hlbytes_fromde
        
        call savesamples
        call savefragments ;includes track info
        call savetracks

curhandle=$+1
        ld b,0
        OS_CLOSEHANDLE
        
        ret

savesamples
        ld hy,0
savesamples0
        ld hl,tsamples+2
        ld e,hy
        ld d,0
        add hl,de
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl=sample address
       push hl
        ;db длина в строчках
        ;db длина зацикливания
        ;dw 0 ;reserved
        ;строчки по 8 байт (для возможности расширения)
;find sample length and loop line
        call findsamplelengthandloop ;out: e=length, d=loopsize
       push de
        ld (save_sampleheader),de
        ld de,save_sampleheader
        ld hl,sz_sampleheader
        call save_hlbytes_fromde
       pop de ;e=length
       pop hl
savesamplelines0
       push de
        ld de,save_sampleline
        push de
        ld bc,7
        ldir
        pop de
       push hl
        ld hl,sz_sampleline
        call save_hlbytes_fromde
       pop hl
       pop de
        dec e
        jr nz,savesamplelines0        
        inc hy
        ld a,(nsamples)
        cp hy
        jr nz,savesamples0
        ret

savefragments
;пока только один фрагмент
        ld hl,(songlength)
        ld (save_fragmentheader),hl
        ld de,save_fragmentheader
        ld hl,sz_fragmentheader
        call save_hlbytes_fromde

        ld hl,ttypes
        ld hy,0 ;track
savetracktypes0
        ld de,save_tracktype
        push de
        ld bc,8
        ldir
        pop de
       push hl
        ld hl,sz_tracktype
        call save_hlbytes_fromde
       pop hl
        inc hy
        ld a,(ntracks)
        cp hy
        jr nz,savetracktypes0

        ret

savetracks
        ld hy,0 ;track
savetracks0
        ld ly,0 ;part
savetrackparts0
;ly=part
        ld a,hy ;a=track
        call getendaddr ;de=end or 0
        inc de
        ld (save_trackheader),de
       push de
        ld de,save_trackheader
        ld hl,sz_trackheader
        call save_hlbytes_fromde
       pop bc
        ld hl,0
savetrackbytes0
        push bc
;hl=index
;ly=part
        ld a,hy ;a=track
        call peektrackpartindex
        push hl
        ld de,save_byte
        ld (de),a
        ld hl,1
        call save_hlbytes_fromde
        pop hl
        pop bc
        cpi
        jp pe,savetrackbytes0
        inc ly
        ld a,(nparts)
        cp ly
        jr nz,savetrackparts0
        
        inc hy
        ld a,(ntracks)
        cp hy
        jr nz,savetracks0
        ret

save_hlbytes_fromde
        push ix
        push iy
        ld a,(curhandle)
        ld b,a
        OS_WRITEHANDLE
        pop iy
        pop ix
        ret

save_byte
        db 0

save_sampleheader
        dw 0
        dw 0 ;reserved
        db 0 ;sample name
sz_sampleheader=$-save_sampleheader

save_fragmentheader
        dw 0
        db 0 ;fragment name
sz_fragmentheader=$-save_fragmentheader

save_sampleline
        ds 8
sz_sampleline=$-save_sampleline

save_tracktype
        ds 8
        db 0 ;track name
sz_tracktype=$-save_tracktype

save_trackheader
        dw 0 ;length=1..65536
sz_trackheader=$-save_trackheader

theader
        db "untr"
        db 0 ;ver
        db 0 ;subver

        db "song name",0
        db "author",0

        dw 8 ;смещение до сэмплов (сейчас =8)

songlength
        dw 65536&0xffff ;length =1..65536
songloop
        dw 0 ;loop

nsamples
        db 64 ;числосэмплов (сейчас =64)
nfragments
        db 1 ;числофрагментов F
ntracks
        db 14 ;числотреков N
nparts
        db 64 ;числочастей (сейчас =64)
szheader=$-theader

tfilename
        db "muz.unt",0
