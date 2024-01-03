        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
FR_EXIST=8 ;fatfs4os/ff.h

       MACRO ziprdbyte
        INC LY
        LD A,(IY)
        CALL Z,RDBYH
       ENDM 

STACK=0x4000
ziptrees=0x4000;0x8000;0x4000 ;чтобы было bit 6 ;size = 0xa60 + 2*288?
TCRC=0x6800 ;size 0x400, divisible by 0x400
DISKBUF=0x6c00
DISKBUFsz=0x1000
READZIPDIR=1;0 пока не работает
;в обычном заголовке файла длина имени файла в другом месте и вообще заголовок другой!
;READ не должна будет содержать позиционирование
;надо не проверять число файлов. выход по какому-то другому условию - любой заголовок, кроме PK,3,4 (в директории PK,1,2. Archive decryption header, Archive extra data record наверняка имеют другие заголовки, примеров нет)

SEEK32BIT=1

depkbuf=0x7c00;0 for pages
buf64k=0;0 for nopages

        org PROGSTART
cmd_begin
        ld sp,STACK
        call initstdio
        ;ld e,6 ;textmode
        ;OS_SETGFX
        
        ;OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        if depkbuf==0
        ld hl,PTABL
        ld b,4;6
getpgs0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
        ld (hl),e
        inc hl
        pop bc
        djnz getpgs0
        endif
        
        ld hl,COMMANDLINE
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr nz,$+5
         ld hl,defaultfilename
        ex de,hl
        
        call openstream_file
        or a
        jr nz,openerror
        
        ld a,(filehandle)
        ld b,a
        OS_GETFILESIZE ;dehl=filesize
        ld (ML_FLEN),hl
       if SEEK32BIT
        ld (ST_FLENw),de
       else
        ld a,e
        ld (ST_FLEN),a
       endif

        CALL initdepk;Z6629 ;ИНИЦИАЛИЗАЦИЯ ДЕПAKEPA
       LD IY,DISKBUF+DISKBUFsz-1

;0x1f,0x8b = *.gz
;"PK" = *.zip
        call RDBYTE
        cp 'P'
        jr nz,depack_gz

        call depack
        
        if 1==0
        ld de,0
        ld hl,1
        ;dehl=shift
        ld a,(filehandle)
        ld b,a
        OS_SEEKHANDLE
       
       LD IY,DISKBUF+DISKBUFsz-1

loop0
        ziprdbyte
        push iy
        PRCHAR_
        pop iy
        jp loop0
        endif

depack_gz_q
        call closestream_file
openerror
mkdirerror
error
        QUIT

;readerror
;TODO restore stack
        ;call closestream_file
        ;jr error

depack_gz
        call RDBYTE ;rest of magic header 0x8b
        call RDBYTE ;method (TODO 0=store)
        call RDBYTE ;flags (bit 3 set: original file name present)
        push af

        ld b,6 ;4time+1extraflags+1os
        call RDBYTE
        djnz $-3

        pop af
        bit 3,a
        jr z,depack_gz_skipname ;TODO делать из имени архива
;сформировать filename:
        ld hl,filename
depack_gz_getfn0
        call RDBYTE
        ld (hl),a
        inc hl
        or a
        jr nz,depack_gz_getfn0
        ld hl,filename
        ld de,filename
        call copyname83
depack_gz_skipname
        call SAVECREATE
        ld hl,1
        ld (KOL_F),hl        call depack_gz_pp
        jr depack_gz_q
depack_gz_pp
        LD (exit_sp),SP        call INFLATING
        jp SKIP ;call SAVECLOSE
        
copyname83
;hl->de
copyname83_element
        ld b,64;8
copyname83_0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr z,copyname83_ext
        ld (de),a
        inc de
        djnz copyname83_0
;8 chars of name copied, wait for dot or slash or terminator
copyname83_skipname0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr nz,copyname83_skipname0
copyname83_ext
        ld (de),a ;'.'
        inc de
        ld b,64;3
copyname83_ext0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr z,copyname83_skipext0
        ld (de),a
        inc de
        djnz copyname83_ext0
copyname83_skipext0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr nz,copyname83_skipext0
copyname83_endelement
        ld (de),a ;'/'
        inc de
        jr copyname83_element
copyname83_q
        ld (de),a ;0
        ret

skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces
        

strcopy
;hl->de
strcopy0
        ld a,(hl)
        ldi
        or a
        jr nz,strcopy0
        ret

        if depkbuf==0
PTABL
        ;DB #11,#13,#14,#17,#10,#16
        ds 4;6 ;patched
        endif;T61F7   DS 14 ;???T6221   DS 4 ;time(2), date(2) of depacked fileCRC_ISH DS 4ML_LEN_ISH DB 0T622A   DB 0ST_LEN_ISH DB 0T622C   DB 0;T622D   DB 0;T622E   DB 0;T622F   DB 0ML_CRC32 DW 0ST_CRC32 DW 0
;текущий размер файла для процентомера;B1      DB 0;B2      DB 0;B3      DB 0
        if depkbuf==0
;a=4: for Z631F
;a=5: default
;a=0..3: for keep byte
;не должна портить hl,de, a' (а что насчёт bc?)
ON_BANK        ;CP 0        ;RET Z ;для такого поведения надо перед каждой распаковкой делать паразитное переключение, чтобы потом сработало фактическое?        ;LD (TPAGE),A
        push bc
       LD b,PTABL/256       ADD A,PTABL&0xff        LD c,A        LD A,(bc)        SETPG32KHIGH
        pop bc
        RET 
        endif;TPAGE=ON_BANK+1
;ЧTEHИE ЧACTИ ФAЙЛА
;de=len
;ix=buffer
;ahl=position in file
;SEEK32BIT: bchl=position in fileREAD    
        PUSH IX,DE,BC,HL,AF

        push de ;len
        push ix ;buf
        
       if SEEK32BIT
        ld d,b
        ld e,c
       else
        ld d,0
        ld e,a
       endif
        ;dehl=shift
        ld a,(filehandle)
        ld b,a
        OS_SEEKHANDLE
        
        pop de ;buf
        pop hl ;len
        call readstream_file
        ;CALL LOAD        ;LD HL,0        ;LD (OSTAT),HL        ;LD (SMEV),HL        POP AF,HL,BC,DE,IX        RET 
;процентомер?
COUNT        LD A,0NOPR=$-1        INC A        AND 3        LD (NOPR),A        RET NZ        ;EXX         ;CALL P_IND        ;EXX         RET 
        if 1==0
P_IND   DI         LD (P_IND1+1),SP        LD SP,TABLICA        LD B,48        LD HL,(Z6546)        LD DE,(B2)        ADD HL,DE        EX DE,HL        LD A,(B1)        ADC A,0        LD C,API2     POP HL,AF        OR A        SBC HL,DE        SBC A,C        JR C,PI1        JR NZ,NE_0        OR H        OR L        JR Z,PI1NE_0    DJNZ PI2PI1     DEC SP,SP        POP HLP_IND1  LD SP,0        LD A,L        CP -1PNP=$-1        RET Z        LD (PNP),A        LD HL,#0A08        LD (COR),HL        LD E,A        LD D,0        LD HL,SKAL        OR A        SBC HL,DE        LD A,#4F        LD (TEKATR+1),A        JP PRINTS;?       DS 48,#0A0ASKAL=$-1        NOP 
        endif
minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

; HL = ДЛИНА ФАЙЛА
;de=0
;имя файла лежит в filename
;out: hl=0SAVE        ;LD A,4        ;CALL ON_BANK        ;LD A,3        ;LD (NOPR),A ;форсировать процентомер?        ;CALL COUNT ;процентомер?        ;LD (#5CE8),HL ;length
        ld de,0        LD (IST),DE
        
        ld a,h
        or l
        ret z
        
        if depkbuf
        ex de,hl
IST=$+1
        LD HL,0;(IST)
        ld bc,depkbuf
        add hl,bc
        ex de,hl
        ld a,(savefilehandle)
        ld b,a
        push iy
       inc a
       jr z,skipbadsave
        OS_WRITEHANDLE
skipbadsave
        pop iy
        
        else;RE_READ
        ;push hl
        ;call SAVECREATE
        ;pop hl ;size
SAVE_pg
        push hl
IST=$+1
        LD HL,0;(IST)        LD A,H        RLCA         RLCA         AND 3        CALL ON_BANK
        pop hl
        ld bc,0x4000
        call minhl_bc_tobc ;bc=block size
        or a
        sbc hl,bc
        push hl ;remaining size
        ld h,b
        ld l,c
        ld de,0xc000
        ld a,(savefilehandle)
        ld b,a
        push iy
       inc a
       jr z,skipbadsave
        OS_WRITEHANDLE
skipbadsave
        pop iy
                LD DE,#4000        LD HL,(IST)        ADD HL,DE        LD (IST),HL        pop hl ;remaining size
        ld a,h
        or l        jr nz,SAVE_pg
        ;call SAVECLOSE
        
        endif
        
        ;LD A,5        ;call ON_BANK 
        ld hl,0 ;OK
        ret

findslash_or_zero
;hl=filename
;out: hl=at slash or zero, a=code
findslash_or_zero0
        ld a,(hl)
        or a
        ret z
        cp '/'
        ret z
        inc hl
        jr findslash_or_zero0
        
SAVECREATE
        ;jr $
        push iy
;SAVECREATE_retry
        ld de,filename
        OS_CREATEHANDLE
         or a
         jr z,SAVECREATE_nomkdir
;5=FR_NO_PATH
;надо создать путь элемент за элементом: md 1, md 1/2, md 1/2/3...
        ld hl,filename
SAVECREATE_mkdir0
        call findslash_or_zero ;hl=at slash or zero, a=code
        or a
        jr z,SAVECREATE_aftermd;SAVECREATE_retry ;path created
        push hl ;hl=at slash or zero
        ld (hl),0 ;end path at this slash
        ld de,filename
        OS_MKDIR ;возможно, такая директория уже есть!
        pop hl ;hl=at slash or zero
        ld (hl),'/' ;restore slash
         cp FR_EXIST
         jr z,SAVECREATE_mkdir_exist
         or a
         jp nz,mkdirerror
SAVECREATE_mkdir_exist
        inc hl ;after slash
        jr SAVECREATE_mkdir0
SAVECREATE_aftermd
        ld de,filename
        OS_CREATEHANDLE
         or a
         jr z,SAVECREATE_nomkdir
         ld b,0xff ;badsavehandle
SAVECREATE_nomkdir
;b=new file handle
        ld a,b
        ld (savefilehandle),a
        pop iy
        ret

SAVECLOSE
        push iy
savefilehandle=$+1
        ld b,0
        OS_CLOSEHANDLE
        pop iy
        ret
        
        
RDBYTE
        INC LY
        LD A,(IY)
        RET NZ
RDBYH
        INC HY
        LD A,HY
;RDBYHend=$+1
        CP DISKBUF/256+(DISKBUFsz/256)
        ;JR Z,rDDSK
        LD A,(IY)
         ccf ;CY=0: OK
        RET nz
;rDDSK
       PUSH HL
       PUSH DE
        PUSH BC
        push IX
       ;CALL rdCS
       ex af,af' ;'
       PUSH AF
        exx
        push bc
        push de
        push hl
        ld de,DISKBUF
        ld hl,DISKBUFsz
         push de
        call readstream_file
         pop de
         push de ;addr
;hl=actual size
         ld a,h
         or l
         jp z,readerror
;move block to end of buf:
        ld b,h
        ld c,l
        dec de ;ld de,DISKBUF-1
        add hl,de ;end of data
        ld de,DISKBUF+DISKBUFsz-1
        sbc hl,de
        add hl,de
        jr z,ZIPRDBYHq
         pop af
        lddr
        inc de ;begin of data
         push de
ZIPRDBYHq
         pop iy ;addr = DISKBUF+
        
        pop hl
        pop de
        pop bc
        exx
       POP AF
       ex af,af' ;'
        POP IX
        pop BC
       POP DE
         pop hl
       ;ld iy,DISKBUF
       LD A,(IY)
       or a ;CY=0: OK
        RET 

;Z61B7   LD A,#2E;        LD (DE),A;        INC DE;Z61BB   LDI ;        RET PO;        JR Z61BB
ML_FLEN DW 0
       if SEEK32BIT
ST_FLENw DW 0 
       elseST_FLEN DB 0 
       endif

prcrlf
        ld hl,tcrlf
prtext
        ld a,(hl)
        or a
        ret z
        push hl
        push iy
        PRCHAR_
        pop iy
        pop hl
        inc hl
        jr prtext
        
tcrcerror
        db "CRC error"
tcrlf
        db 13,10,0

        include "../_sdk/file.asm"
        include "../_sdk/stdio.asm"
        include "zipfile.asm"
        include "depk.asm"
        
defaultfilename
        db "0:/12345/DOWNLOAD.ZIP",0
filename
        db "depkfile.fil"
        ds filename+256-$ ;для длинных имён

CAT
;каждый файл по 16 байт:
;11 байт имя, 3 байта длина, 2 байта пропускаем
        ds 0x900 ;TODO убрать
        
cmd_end

;BUFER используется при парсинге архива и при печати комментария, не используется при распаковке
BUFER=0x8000;$;B_LEN=0x3f00-BUFERB_LEN=0xbfff-BUFER
T6624=BUFER+8 ;flagsT6626=BUFER+#0A ;T6626=METOД CЖATИЯ: 0:STORED, 8:DEFLATE, others unknownT6628=BUFER+#0C ;file last modification timeZ6630=BUFER+#14Z6632=BUFER+#16Z6634=BUFER+#18Z6636=BUFER+#1AZ6638=BUFER+#1C ;file name lengthZ663A=BUFER+#1E ;extra field lengthZ663C=BUFER+#20 ;file comment lengthZ6646=BUFER+#2A ;(4)Relative offset of local file header. This is the number of bytes between the start of the first disk on which the file occurs, and the start of the local file header. This allows software reading the central directory to locate the position of the file inside the ZIP file.Z6648=BUFER+#2CZ664A=BUFER+#2E ;сюда кладётся имя файла
	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "pkunzip.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l",1
