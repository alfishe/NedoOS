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

frmcnt=1;0mmc=1;0crc=1;0tcrc=0;1 ;не работало из-за A!=0, fix 25.08.23kb=0;1kINopt=1border=0unexp=1;0masks=1
retree=1 ;работает? (генератор кода для разгребания дерева Хаффмана) ;требуется reld длиной 0x0b08 (298*19/2-7)
;v1="0";v2="6";v3="1"
COLOR=7
CURSORCOLOR=0x38

namln=MAXPATH_sz;100 ;#FATHEEND=#c000;#8000;#C000CODETOP=#7D00 ;константа-максимум,используется только в DISPLAYs8=#7D00;#5B00 ;sysTAB44=#5B00;#7A3D ;#7F00 нельзя (bufstor)stBUF=#7E00;#5800 ;TODO;sec=stBUF      ;dirbufstor=THEEND-256
TREES=0x2000
bd=TREES
ld=bd ;должно быть выше 0x4000! TODO
dd=ld+(298*4)
rd=dd+(48*4)
TREES_SZ=rd+(28*4)-TREES

        org PROGSTART
cmd_begin
        ld sp,STACK
        call initstdio
        ;ld e,6 ;textmode
        ;OS_SETGFX
        
        ;OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld hl,PTABL
        ld b,64 ;TODO меньше для ATM2
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
        
;curfilenameaddr=$+1
;        ld de,0
;        call openstream_file
;        or a
;        jp nz,openerror
        
        ;CALL initdepk;Z6629 ;ИНИЦИАЛИЗАЦИЯ ДЕПAKEPA

       call GO
        ;call depack
        QUIT
        
openerror
error
quit
        QUIT

copyname83
;hl->de
;длина имени не увеличивается - можно поверх?
;перекодирует слэш в прямой
copyname83_element
        ld b,8
copyname83_0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp 0x5c;'\'
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
        cp 0x5c;'\'
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
        cp 0x5c;'\'
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
        cp 0x5c;'\'
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
OUTMEcu LD (curPG),A
        LD (curPG2),A
OUTcur  LD A,(curPG)
OUTME
        PUSH BC
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
        exx
        push de
        exx
        ex af,af'
        push af
        ld a,(savefilehandle)
        ld b,a
        ex de,hl
         push ix
        push iy
        OS_WRITEHANDLE
        pop iy
         pop ix
        pop af
        ex af,af'
        exx
        pop de
        exx
        ret

strlen
;hl=str
;out: hl=length
        ld bc,0 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
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
;1.проверить, что путь не кончился (т.е. дальше есть /)
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
        jr z,SAVECREATE_dirnomk ;такая директория уже есть
;3.если нет, то создать 0..i-й (текущий путь не меняем)
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
        
;;;
SAVbeg
stAD=$+1
        LD HL,0
stPG=$+1
        LD A,0
        ;BIT 7,H
        ;JR NZ,$+3
        ;INC A
       PUSH AF
        CALL OUTME
       POP AF
        EXA 
        RET 

SAVE
;size = SAVErmn*256 (чуть меньше, т.к. учитываем (uNPremn) как мл.байт)
doSAVEk=$+1
        LD A,0
        CP "N"
        JR NZ,NLISTERLAST ;??? TODO
;LISTERLAST
       LD HL,(DEPADR)
       LD (stAD),HL
       LD A,(curPG)
       LD (stPG),A
        RET 
NLISTERLAST
       CALL SAVbeg
savePG0
        LD A,H
        INC A
        JR NZ,nRASLOM
        LD DE,bufstor
        PUSH DE
        LD B,A
        SUB L
        LD C,A
       DEC C
       INC BC
        LDIR 
        LD H,#C0
        EXA 
        INC A
       PUSH AF
        CALL OUTME
       POP AF
        EXA 
        XOR A
        SUB E
        JR Z,$+5
        LD C,A
        LDIR 
       DEC H
        LD A,1
        JR yRASLOM
nRASLOM
        PUSH HL
        NEG 
yRASLOM LD E,A
        LD BC,(SAVErmn)
        LD A,C
        SUB E
        LD C,A
        JR NC,nKON
        DEC B
        JP P,nKON
        ADD A,E
        LD E,A
        LD BC,0
nKON
        LD (SAVErmn),BC
        LD A,E
        ADD A,H
        LD H,A
       EX (SP),HL
       PUSH BC
;e=number of sectors to save
;hl=addr
        if 1==1
        ld d,e
        ld e,0
        ld a,b
        or c
        jr nz,SAVE_notlastblock
        ld a,(uNPremn)
        or a
        jr z,SAVE_notlastblock
        ld e,a
        dec d
SAVE_notlastblock
        call SAVEBLOCK
        else
       
        LD C,6
        LD B,E
        LD DE,(stsec)
        CALL DOD
        LD HL,(#5CF4)
        LD (stsec),HL
        endif
        
       POP BC
       POP HL
        LD A,B
        OR C
       JR NZ,savePG0
       LD HL,(DEPADR)
       LD (stAD),HL
       LD A,(curPG)
       LD (stPG),A
        RET 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
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
         ;ccf ;CY=0: OK ;TODO переделать на CY=1 длЯ скорости
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
       scf;or a ;CY=0: OK ;TODO переделать на CY=1 длЯ скорости (нужно для retree, там add a,a:call z,bitik ... bitik:rarrdbyte(CY=1):rla:ret)
        RET 

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
        include "rarfile.asm"
        include "rardepk.asm"
        
defaultfilename
        db "0:/rar/acnews47.rar",0
;filename
;        db "depkfile.fil"
;        ds filename+256-$ ;для длинных имён

CURFILE DS namln;DESCRIP DS 16 ;TODO убратьCURPOS  DS 4NXTPOS  DS 4
;;;;;32 bytes rar file headerCRCF    DW 0TYPEF   DB 0FLAGF   DW 0SIZEF   DW 0 ;head size
;;^^^7 bytes also form archive footerADDSZF  DS 4 ;packed sizeUNPSIZE DS 4HOSTOS DB 0;NUFILECRC DS 4FTIME   DS 4UNPVER  DB 0METHOD  DB 0NAMSIZE DW 0ATTR    DS 4
;;;;;;;;;;;;;;;;;;;EXPTYP  DW 0 ;expected type&FLAGH;CRCLO   DW 0;YEFLAGH DB 0 ;TWICE;1=depk,0=view;FREXPT  DB 0 ;TWICE;FILEZ   DW 0;usable.FileCountERRORS  DW 0;ErrCount;unknown DW 0;NU=0.ExtrFileknown   DB 0 ;NOT unknown.MDCode;SCANres DW 0 ;TWICE.SCANres=HL.AllArgsUsed;CANTCR  DW 0;NU=0!can't create.UserReject;PASWFLG DW 0 ;(password?).TmpPassword;BEFEXTR DB 0 ;1=до EXTRACT.FirstFile;GDEIX   DW 0 ;ArcPtrVOLFLG  DB 0;ArcType,2=volSOLFLG  DB 0;SolidType(1)TSTARES DB 0;ArcFormatvolPKSZ DS 4volUNSZ DS 4pieces  DW 0 ;FileCount;zagol   DW 0;1=загол уже напечuNPremn DS 4;DestUnpSize IF crcCRCArea DS 4 ENDIF CRCA    DW 0 ;TWICE=BUF32TYPEA  DB 0;NUFLAGA   DW 0SIZEA   DW 0_62ae  DW 0;NU_62b0  DW 0;NU_62b2  DW 0;NU ;UnpCRC  DS 4 ;UnpFileCRC;YCOMM   DB 0;UnpVolume.4timesCOMSYM  DB 0
;        align 256;       IFN kb;SECBUF  DS kb*1024;       ELSE ;SECBUF  DS 256;       ENDIF 
        ds TREES-$ ;DS -$&3
        ds TREES_SZ
OUTNAM  DS namln ;DestFileNamepathbuf
        ds MAXPATH_sz

;oldtimer
;        dw 0
        if retree
reld
        ds (298*19/2-7) ;0x0b08
        endif
        
cmd_end

        display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "unrar.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
