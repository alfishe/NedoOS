	device pentagon1024 ;don't trust this line, it's for ATM2 :)
        include "../_sdk/sys_h.asm"

       MACRO rdbyte
        INC LY
        LD A,(IY)
        CALL Z,RDBYH
       ENDM 

DISKBUF=0x7000
DISKBUFsz=0x1000
STACK=0x4000

TCRC=0x6c00 ;size 0x400, divisible by 0x400

        org PROGSTART
cmd_begin
        ld sp,STACK
        
        ld e,6 ;textmode
        OS_SETGFX
        
        ;OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000

        ld hl,PTABL
        ld b,6
getpgs0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
        ld (hl),e
        inc hl
        pop bc
        djnz getpgs0
        
        ld hl,COMMANDLINE
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr nz,$+5
         ld hl,defaultfilename
        ex de,hl
        
        ;ld de,filename
        call openstream_file
        or a
        jr nz,openerror
        
        ld a,(filehandle)
        ld b,a
        OS_GETFILESIZE ;dehl=filesize
        ld (ML_FLEN),hl
        ld a,e
        ld (ST_FLEN),a
        ;jr $
        
        call depack
       
        if 1==0
       LD IY,DISKBUF+DISKBUFsz-1
       
loop0
        rdbyte
        push iy
        PRCHAR
        pop iy
        jp loop0
        endif
       
        call closestream_file
openerror
error
        QUIT

readerror
;TODO restore stack
        call closestream_file
        jr error

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

        
PTABL
        ;DB #11,#13,#14,#17,#10,#16
        ds 6 ;patchedT61F7   DS 14T6221   DS 4 ;time(2), date(2) of depacked fileCRC_ISH DS 4ML_LEN_ISH DB 0T622A   DB 0ST_LEN_ISH DB 0T622C   DB 0;T622D   DB 0;T622E   DB 0;T622F   DB 0ML_CRC32 DW 0ST_CRC32 DW 0
;текущий размер файла для процентомера;B1      DB 0;B2      DB 0;B3      DB 0
;a=4: for Z631F
;a=5: default
;a=0..3: for keep byte
;не должна портить hl,de, a' (а что насчёт bc?)
ON_BANK        CP 0        RET Z        LD (TPAGE),A
        push bc
       LD b,PTABL/256       ADD A,PTABL&0xff        LD c,A        LD A,(bc)        SETPG32KHIGH
        pop bc
        
        if 1==0        EXX         LD BC,#7FFD       LD H,PTABL/256       ADD A,PTABL        LD L,A        LD A,(HL)        OUT (C),A        EXX 
        endif        RET TPAGE=ON_BANK+1
        if 1==0
;3AГPУ3KA ЧACTИ ЗИПALBLOKZIP PUSH HL        PUSH DE,BC,IX        LD HL,BUFER        LD (ZD11F),HL        LD A,4        CALL ON_BANK        LD BC,B_LEN        CALL Z631F        LD A,5        CALL ON_BANK        POP IX,BC,DE,HL        RET 
        endif
;ЧTEHИE ЧACTИ ФAЙЛА
;de=len
;ix=buffer
;ahl=position in fileREAD    
        PUSH IX,DE,BC,HL,AF

        push de ;len
        push ix ;buf
        
        ld d,0
        ld e,a
        ;ld hl,1
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
;где имя файла? TODO в filename
;out: hl=0SAVE        LD A,4        CALL ON_BANK        LD A,3        LD (NOPR),A ;форсировать процентомер?        CALL COUNT ;процентомер?        ;LD (#5CE8),HL ;length
        ld de,0        LD (IST),DE
        
        ld a,h
        or l
        ret z
        ;RE_READ
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
        OS_WRITEHANDLE
        pop iy
                LD DE,#4000        LD HL,(IST)        ADD HL,DE        LD (IST),HL        pop hl ;remaining size
        ld a,h
        or l        jr nz,SAVE_pg
        ;call SAVECLOSE
        
        LD A,5        call ON_BANK 
        ld hl,0 ;OK
        ret

SAVECREATE
        push iy
        ld de,filename
        OS_CREATEHANDLE
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
        
        if 1==0LP5     LD A,E        SUB #40        JR C,ONE_BANK        LD E,A        PUSH DE        LD HL,0IST=$-2        LD A,H        RLCA         RLCA         AND 3        CALL ON_BANK        LD BC,#4006        LD DE,(#5CF4)        LD HL,#C000        CALL TRDOS        LD DE,#4000        LD HL,(IST)        ADD HL,DE        LD (IST),HL        POP DE        JR LP5
        endif         
        
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
       ex af,af'
       PUSH AF
        exx
        push bc
        push de
        push hl
        ld de,DISKBUF
        ld hl,DISKBUFsz
        call readstream_file
;hl=actual size
         ld a,h
         or l
         jp z,readerror
;fill the rest of buffer with zeros
;move block to end of buf:
        ld b,h
        ld c,l
        ld de,DISKBUF-1
        add hl,de ;end of data
        ld de,DISKBUF+DISKBUFsz-1
        lddr
        inc de ;begin of data
        push de
        pop iy ;DISKBUF+
        
        if 1==0
        ld de,DISKBUF
        add hl,de
        ex de,hl ;de=start of zeros
        ld hl,DISKBUF+DISKBUFsz
        xor a
        sbc hl,de
        ld b,h
        ld c,l ;bc=length of zeros (Z=no zeros)
        jr z,readdiskbuf_nozeros
        ld h,d
        ld l,e ;start of zeros
        ld (hl),a;0
        inc de
        dec bc
        ld a,b
        or c
        jr z,readdiskbuf_nozeros
        ldir
readdiskbuf_nozeros
        endif

        pop hl
        pop de
        pop bc
        exx
       POP AF
       ex af,af'
        POP IX
        pop BC
       POP DE
         pop hl
       ;ld iy,DISKBUF
       LD A,(IY)
       or a ;CY=0: OK
        RET 

Z61B7   LD A,#2E        LD (DE),A        INC DEZ61BB   LDI         RET PO        JR Z61BB
ML_FLEN DW 0ST_FLEN DB 0 

        include "file.asm"
        include "depk.asm"
        
defaultfilename
        db "0:/pkunzip.zip",0
filename
        db "depkfile.fil"
        ds 128

CAT
;каждый файл по 16 байт:
;11 байт имя, 3 байта длина, 2 байта пропускаем
        ds 0x900 ;TODO убрать
        
cmd_end

;BUFER используется при парсинге архива и при печати комментария, не используется при распаковке
BUFER=0x8000;$;B_LEN=0x3f00-BUFERB_LEN=0xbfff-BUFER
T6624=BUFER+8 ;flagsT6626=BUFER+#0AT6628=BUFER+#0C ;file last modification timeZ6630=BUFER+#14Z6632=BUFER+#16Z6634=BUFER+#18Z6636=BUFER+#1AZ6638=BUFER+#1C ;file name lengthZ663A=BUFER+#1E ;extra field lengthZ663C=BUFER+#20 ;file comment lengthZ6646=BUFER+#2A ;(4)Relative offset of local file header. This is the number of bytes between the start of the first disk on which the file occurs, and the start of the local file header. This allows software reading the central directory to locate the position of the file inside the ZIP file.Z6648=BUFER+#2CZ664A=BUFER+#2E ;сюда кладётся имя файла
	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "pkunzip.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
