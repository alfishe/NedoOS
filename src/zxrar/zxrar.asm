        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

       MACRO rarrdbyte
        INC LY
        LD A,(IY)
        CALL Z,RDBYH
       ENDM 

INITIALMEMPAGES=32;6
       
STACK=0x4000
TCRC=0x6800 ;size 0x400, divisible by 0x400
DISKBUF=0x6c00
DISKBUFsz=0x1000

frmcnt=1;0mmc=1;0crc=1;0tcrc=0;1kb=0;1kINopt=1border=0;hgt=24;wdt=32;em3d13=1;при 1 что-то с пам€тью в big fileunexp=1;0masks=1;v1="0";v2="6";v3="1"
COLOR=7
CURSORCOLOR=0x38

namln=MAXPATH_sz;100 ;#FATHEEND=#c000;#8000;#C000CODETOP=#7D00 ;константа-максимум,используетс€ только в DISPLAYs8=#7D00;#5B00 ;sysTAB44=#5B00;#7A3D ;#7F00 нельз€ (bufstor)stBUF=#7E00;#5800 ;TODO;sec=stBUF      ;dirbufstor=THEEND-256
        org PROGSTART
cmd_begin
        ld sp,STACK
        
        ld e,6 ;textmode
        OS_SETGFX
        
        ;OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld hl,PTABL
        ld b,64 ;TODO меньше дл€ ATM2
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
        ld (curfilenameaddr),hl
        
curfilenameaddr=$+1
        ld de,0
;        call openstream_file
;        or a
;        jp nz,openerror
        
        ;CALL initdepk;Z6629 ;»Ќ»÷»јЋ»«ј÷»я ƒ≈ѕAKEPA

        ld a,'n';'c' ;"create" (not "new") ;new проверено - работает
       call SELCREA
        ;call depack
        QUIT

readerror ;TODO
        
openerror
error
quit
        QUIT

copyname83
;hl->de
;длина имени не увеличиваетс€ - можно поверх?
;перекодирует слэш в пр€мой
copyname83_element
        ld b,8
copyname83_0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '\'
        jr z,copyname83_endelement
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
        cp '\'
        jr z,copyname83_endelement
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr nz,copyname83_skipname0
copyname83_ext
        ld (de),a ;'.'
        inc de
        ld b,3
copyname83_ext0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '\'
        jr z,copyname83_endelement
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
        cp '\'
        jr z,copyname83_endelement
        cp '/'
        jr nz,copyname83_skipext0
copyname83_endelement
        ld a,'/'
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

PTABL
        ds 64 ;page numbers, patched
OUT0        LD A,16 ;TODOOUTME
       ;IF ramdisk       ; LD (BYTEPG),A       ;ENDIF 
OUTNO        PUSH BC
       LD b,PTABL/256       ADD A,PTABL&0xff        LD c,A        LD A,(bc)        SETPG32KHIGH
        POP BC
        RET 

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

        
SAVEBLOCK
;de=bytes to save
;hl=addr
         push bc
        exx
        push bc
        push de
        push hl
        exx
        ex af,af'
        push af
        ld a,(savefilehandle)
        ld b,a
        ex de,hl
         push ix
        push iy
tosave=$+1       LD A,0       OR A
       jr z,SAVEBLOCK_skip        OS_WRITEHANDLE
SAVEBLOCK_skip
        pop iy
         pop ix
        pop af
        ex af,af'
        exx
        pop hl
        pop de
        pop bc
        exx
         pop bc
        ret

strlen
;hl=str
;out: hl=length
        ld bc,0 ;чтобы точно найти терминатор
        xor a
        cpir ;найдЄм об€зательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret

SAVECREATE
        push iy

;сформировать filename 8.3 (во всех элементах):
        ld hl,OUTNAM;Z664A
        ld de,OUTNAM;filename        ;call strcopy
        call copyname83 ;заодно перекодирует слэш в /
;TODO если нет такой директории, то create directory (например, "md scr/1" без слеша в конце):

        ld hl,OUTNAM
SAVECREATE_dir0
;hl=текущий элемент пути
;1.проверить, что путь не кончилс€ (т.е. дальше есть /)
        push hl
        call strlen
        ld b,h
        ld c,l
        pop hl
        ld a,'/'
        cpir
        jr nz,SAVECREATE_dirq
        dec hl
;hl=at slash
;2.проверить, что есть i-й элемент пути (до слэша) - через CHDIR?
        ld (hl),0
        push hl
        ld de,pathbuf
        OS_GETPATH
        ld de,OUTNAM
        OS_CHDIR
        push af
        ld de,pathbuf
        OS_CHDIR
        pop af
        or a
        jr z,SAVECREATE_dirnomk ;така€ директори€ уже есть
;3.если нет, то создать 0..i-й (текущий путь не мен€ем)
        ld de,OUTNAM
        OS_MKDIR
SAVECREATE_dirnomk
        pop hl
        ld (hl),'/'
        inc hl
        jr SAVECREATE_dir0
SAVECREATE_dirq

        ld de,OUTNAM;filename
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
        
        
LBYTE  LD A,LBYTE
        if 1==0
                 push de
        push hl
        ld hl,bytebuf
        ld (hl),a
        ld de,1
;de=bytes to save
;hl=addr      
        call SAVEBLOCK
        pop hl
         pop de
        ret
bytebuf
        db 0

        else
                EXX XBYTE   LD (HL),A       LD A,H        INC L        EXX         RET NZ        EXX         INC H       LD A,HBYTEend=$+1       CP fout/256+2+(svbfsz/256)        EXX         RET CBYTEsv        EXX         PUSH BC        CALL BYTEsPP        POP BC        EXX        IF 0;ramdiskBYTEPG=$+1        LD A,0        JP OUTME       ELSE         RET        ENDIF 
        endif

SAVEREWIND
        push af
        ;push de
        ld hl,0
        ld d,h
        ld e,l
        ld a,(savefilehandle)
        ld b,a
        OS_SEEKHANDLE
        ;pop de
        pop af
        ret

BYTEsPP_endfile        if 1==1
;если hl<fout+512, то первые 2 сектора ещЄ не сохранены, надо сохранить сколько есть с адреса fout
;иначе сохранить hl-(fout+512) с адреса fout+512 (может быть 0)
        ld de,fout+512
        ld a,h
        cp d;+(fout+512)/256
        jr nc,BYTEsPP_endfile_headsaved
        ld de,fout
BYTEsPP_endfile_headsaved
        or a
        sbc hl,de
        ex de,hl
        ret z
;de=bytes to save
;hl=addr
        jp SAVEBLOCK
                else
        DEC HL        INC H        LD A,H        jp BYTEsPP
        endif

BYTEsPP_startfile
;сохранить или пропустить первые 2 сектора файла
;TODO
        if 1==0
        LD HL,(SAVE1st)        INC L,L        BIT 4,L        RES 4,L        JR Z,$+3        INC H        LD (BYTEsvTS),HL        endif
        ret

BYTsPPPfout
;вызываетс€ перед закрытием outfile
;de не важно
;если hl<fout+512, то выход (только что сохранили сколько есть, не надо сохран€ть два раза)
;иначе сохранить 512 байт с адреса fout
        ld a,h
        cp +(fout+512)/256
        ret c
        LD HL,fout        jr _BYTsPPP
        BYTEsPP
;a=H;первые 2сек.сохран€ютс€ в посл.очередь;чтобы успеть изменить paklen,CRC        LD HL,fout+512 ;begin of fout after sec2_BYTsPPP
;hl=fout+512 (обычно)/fout (в конце сохранени€)
;de=(SAVEsz)?       CP H        RET C        RET Z ;первые 2сек.сохран€ютс€ в посл.очередь ;в NedoOS их надо сохран€ть только первый раз! TODO       SUB h;fout/256 ;H ;в NedoOS не можем пропускать первые 2 сектора, всЄ равно сохран€ем        LD B,A ;b=sectors to save        ADD A,E        LD E,A        jr NC,$+3        INC D       PUSH HL        PUSH DE;BYTEsvTS=$+1;        LD DE,0        ;LD C,6;tosave=$+1;       LD A,0;       OR A;         jr Z,notosav       ;CALL NZ,DOD
       
         ;ld hl,fout ;в NedoOS не можем пропускать первые 2 сектора, всЄ равно сохран€ем
        ld d,b
        ld e,0
;de=bytes to save
;hl=addr
        call SAVEBLOCK
               ;LD HL,(#5CF4)        ;LD (BYTEsvTS),HL        ;POP HL        ;PUSH HL;+255*#       ;LD A,(ARCNAME+8)      ;CP "r      ;JZ BYsvN0ar       ;SUB 47       ; CP "r"-47       ; jr NC,BYsvN0ar       ;LD C,A       ;ADD A,H       ;LD H,A       ;LD A,L       ;SUB C       ;LD L,A       ;jr NC,$+3       ;DEC H;BYsvN0ar        ;LD DE,#5A41        ;CALL PR88DEC;notosav        POP DE       POP HL       LD A,H        RET 
        
;save b bytes from ix
;TODO через SAVEBLOCKBLOCK        LD A,(IX)        INC IX        CALL BYTE        DJNZ BLOCK        RET bit0        OR Abit        EXX         RL C        EXX         RET NC       PUSH AF        EXX         LD A,C        LD C,1
        CALL XBYTE       POP AF        RET PKNNpp        LD B,(HL)        INC H        LD C,(HL)        INC HPKLHPP        LD L,(HL)        LD H,CPKHLPP        ADD HL,HL        CALL bit        DJNZ $-4        RET PKBDpp        RLA         CALL bit        DJNZ $-4        RET  
        
RDBYTE
        INC LY
        LD A,(IY)
        RET NZ
RDBYH
        INC HY
        LD A,HY
;RDBYHend=$+1
        CP DISKBUF/256+(DISKBUFsz/256)
        LD A,(IY)
         ccf ;CY=0: OK ;TODO переделать на CY=1 для скорости
        RET nz
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
       ex af,af'
        POP IX
        pop BC
       POP DE
         pop hl
       ;ld iy,DISKBUF
       LD A,(IY)
       or a ;CY=0: OK ;TODO переделать на CY=1 для скорости
        RET 

prcrlf
        ld hl,tcrlf
prtext
        ld a,(hl)
        or a
        ret z
        push hl
        push iy
        PRCHAR
        pop iy
        pop hl
        inc hl
        jr prtext

PRCUR
PRFN
PR_B
PRTEXT
PRGFX
PRGFXHL
NXTLIN
PRTHI32
VIEGFX
CAT2GFX
PRHEADP
BEFOPR
CLS
        ret

fillmem
        LD D,H
        ld E,L        INC DE        LDIR        INC B        RET  

tcrcerror
        db "CRC error"
tcrlf
        db 13,10,0

        include "../_sdk/file.asm"
        include "zxrfile.asm"
        include "rarpack.asm"
        include "rarlz.asm"
        include "rarhuff.asm"
        
defaultfilename
        db "4:/nv.ext",0

CURFILE DS namln
;;;;;32 bytes rar file headerCRCF    DW 0TYPEF   DB 0FLAGF   DW 0SIZEF   DW 0 ;head size
;;^^^7 bytes also form archive footerADDSZF  DS 4 ;packed sizeUNPSIZE DS 4HOSTOS DB 0;NUFILECRC DS 4FTIME   DS 4UNPVER  DB 0METHOD  DB 0NAMSIZE DW 0ATTR    DS 4
;;;;;;;;;;;;;;;;;;;EXPTYP  DW 0 ;expected type&FLAGH;CRCLO   DW 0;YEFLAGH DB 0 ;TWICE;1=depk,0=view;FREXPT  DB 0 ;TWICE;FILEZ   DW 0;usable.FileCountERRORS  DW 0;ErrCount;unknown DW 0;NU=0.ExtrFileknown   DB 0 ;NOT unknown.MDCode;SCANres DW 0 ;TWICE.SCANres=HL.AllArgsUsed;CANTCR  DW 0;NU=0!can't create.UserReject;PASWFLG DW 0 ;(password?).TmpPassword;BEFEXTR DB 0 ;1=до EXTRACT.FirstFile;GDEIX   DW 0 ;ArcPtrVOLFLG  DB 0;ArcType,2=volSOLFLG  DB 0;SolidType(1)TSTARES DB 0;ArcFormatvolPKSZ DS 4volUNSZ DS 4pieces  DW 0 ;FileCount;zagol   DW 0;1=загол уже напечuNPremn DS 4;DestUnpSize IF crcCRCArea DS 4 ENDIF CRCA    DW 0 ;TWICE=BUF32TYPEA  DB 0;NUFLAGA   DW 0SIZEA   DW 0_62ae  DW 0;NU_62b0  DW 0;NU_62b2  DW 0;NU ;UnpCRC  DS 4 ;UnpFileCRC;YCOMM   DB 0;UnpVolume.4timesCOMSYM  DB 0
pathbuf
        ds MAXPATH_sz

oldtimer
        dw 0        
cmd_end

        display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "zxrar.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
