        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

       MACRO rarrdbyte
        INC LY
        LD A,(IY)
        CALL Z,RDBYH
       ENDM 

INITIALMEMPAGES=6
       
STACK=0x4000
;TCRC=0x6800 ;size 0x400, divisible by 0x400
DISKBUF=0x6c00
DISKBUFsz=0x1000

depkbuf=0x7c00;0 for pages
;buf64k=0;0 for nopages

frmcnt=0mmc=0crc=1tcrc=0kb=0;1kINopt=1border=0hgt=24wdt=32;em3d13=1;при 1 что-то с пам€тью в big fileunexp=0masks=1v1="0"v2="6"v3="1"
COLOR=7
CURSORCOLOR=0x38

namln=100 ;#FACATBUF=#F800THEEND=#c000;#8000;#C000CODETOP=#7D00 ;константа-максимум,используетс€ только в DISPLAYs8=#7D00;#5B00 ;sysTAB44=#5B00;#7A3D ;#7F00 нельз€ (bufstor)stBUF=#7E00;#5800sec=stBUF      ;dirbufstor=THEEND-256
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
        ex de,hl
        
        call openstream_file
        or a
        jr nz,openerror
        
        ;ld a,(filehandle)
        ;ld b,a
        ;OS_GETFILESIZE ;dehl=filesize
        ;ld (ML_FLEN),hl
        ;ld a,e
        ;ld (ST_FLEN),a

        ;CALL initdepk;Z6629 ;»Ќ»÷»јЋ»«ј÷»я ƒ≈ѕAKEPA
       LD IY,DISKBUF+DISKBUFsz-1

       call GO
        ;call depack
        QUIT
        
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
        PRCHAR
        pop iy
        jp loop0
        endif
       
depack_gz_q
        call closestream_file
openerror
error
;nextfile ;TODO
quit
        QUIT

;readerror
;TODO restore stack
        ;call closestream_file
        ;jr error
        
readerror
        call SAVECLOSE
        jp GO

        if 1==0
SKIP        call SAVECLOSESKIP_noclose
KOL_F=$+1        ld bc,1;(KOL_F)        cpi        ld (KOL_F),bc
        ld sp,(exit_sp)        jp pe,nextfileE_ZIP
EXITexit_sp=$+1        LD SP,#3131         ret
        endif

copyname83
;hl->de
copyname83_element
        ld b,8
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
        ld b,3
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

PTABL
        ds 64 ;patched
OUTMEcu LD (curPG),A
        LD (curPG2),A
OUTcur  LD A,(curPG)
;depend of computer type
;TODO
OUTME
        PUSH BC
        
        if 1==1
       LD b,PTABL/256       ADD A,PTABL&0xff        LD c,A        LD A,(bc)        SETPG32KHIGH
        else
        
        CP 2
        SBC A,-1
        CP 5
        SBC A,-1
;000YYXXX->YY010XXX
        LD C,A
        RLA 
       RLA 
        RLA 
        AND #C0
        OR C
        AND #C7
        OR 16
        LD BC,32765
        OUT (C),A
        endif
        
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
        ;jr $
        exx
        push de
        exx
        ex af,af'
        push af
        ld a,(savefilehandle)
        ld b,a
        ex de,hl
        ;ld h,l ;h=l=number of sectors to save
        ;ld l,0
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

SAVECREATE
        push iy
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
;size = SAVErmn*256 (TODO учесть (uNPremn) как мл.байт)
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
       ;jr $
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
        ;LD A,(doSAVEk)
       ;CP "y"
       ;RET Z ;depack as trd
;создание файловых записей
       if 1==0
SAVE0
        if 1==0
        LD HL,s8
        LD DE,8
        LD BC,#105
        CALL DOD
      LD A,(s8+#E4)
      RLA 
      RET C
        endif
SAVEsz=$+1
       LD HL,0
      ;INC HL
      LD A,H
      LD (SAVEcp),A
      ADD A,-1
      SBC A,A
      OR L
       LD E,A
        LD (SAVEa),A
       XOR A
       LD D,A
       SBC HL,DE
       LD (SAVEsz),HL
       
       if 1==0
       
        LD HL,(s8+#E5)
       LD A,(doSAVEk)
       XOR "$"
       JR NZ,$+3
       INC HL
        SBC HL,DE
        LD (s8+#E5),HL
      RET C ;NE TAK
       LD HL,(s8+#E4)
       LD H,D
       ADD HL,HL
       add HL,HL
       add HL,HL
       add HL,HL
       LD E,H
       ld H,sec/256
       PUSH DE,HL
       LD L,D
        LD BC,#105
        CALL DOD
        LD DE,OUTNAM
fndbsl  LD H,D,L,E
fndbsl0 LD A,(DE)
        INC DE
        CP "\\"
        JR Z,fndbsl
        OR A
        JR NZ,fndbsl0
;найти посл.точку и заменить на #1
        LD D,H
        ld E,L
        CALL fnddot
        JR NZ,$+5
        LD A,1
        LD (BC),A
       POP DE

       LD A,(doSAVEk)
       XOR "$"
       JR NZ,nohobhea
;no 48K! (min 64k buf)
gegPG=$+1
        LD A,0
gegAD=$+1
        LD HL,0
        LD BC,15
SAVhext BIT 7,H
        JR NZ,$+5
        LD H,#C0
        INC A
_6      CP 6
        JR NZ,$+5
        XOR A
        LD H,THEEND/256
       PUSH AF
        CALL OUTME
       POP AF
        LDI 
        JP PE,SAVhext
       LD (SAVEsz),BC;0 ;for #FF11
        DEC DE
        LD A,(DE)
        DEC DE
        JR SAVextQ
nohobhea
        LD B,8
rrrrr   LD A,(HL)
        OR A
        JR Z,rrrEXT
        INC HL
        CP 1;"."
        JR Z,rrrEXT
        LD (DE),A
        INC DE
        DJNZ rrrrr
        JR rrrrrQ
rrrEXT  LD A," "
        LD (DE),A
        INC DE
        DJNZ $-2
rrrrrQ  LD A,(HL)
        DEC A;"."
        JR NZ,$+3
        INC HL
rrrE=$+1
       LD A,0
       INC A
       LD (rrrE),A
       CP 47
       JR NZ,rrrEE
        LD A,(HL)
        OR A
        JR NZ,$+4
        LD A," " ;no ext
rrrEE   LD (DE),A
        INC DE,HL
       LD A,(HL)
        LDI 
       OR A
       JR NZ,$+3
       DEC HL ;еще один #0
        LDI 
       EX DE,HL
SAVEcp=$+1
       LD A,0
       OR A ;0=LAST
;SAVElenLS1=$+1
       LD A,(uNPremn)
      JR Z,$+3
      XOR A ;NOT LAST
       LD (HL),A
       INC HL
       OR A
SAVEa=$+1
       LD A,0
       LD (HL),A
       JR Z,$+3
       DEC (HL)
       INC HL
       EX DE,HL
SAVextQ
        LD (DE),A
        INC DE
        LD HL,s8+#E1
        LDI 
        LDI 
       POP DE
       PUSH AF
        LD BC,#106
        LD HL,sec
        CALL DOD
        endif
        
        if 1==0
        LD HL,s8+#E4
        INC (HL)
    LD DE,(s8+#E1)
       POP AF ;secs in file
       LD L,A
       LD H,0
      ADD HL,HL,HL,HL,HL,HL,HL,HL
      SLA E,E,E,E
      ADD HL,DE
      SRL L,L,L,L
    LD (s8+#E1),HL
        LD HL,s8
        LD DE,8
        LD BC,#106
       CALL DOD
       endif
       
       LD HL,(SAVEsz)
       LD A,H
       OR L
       JP NZ,SAVE0
       
       endif ;создание файловых записей
       
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
        ;JR Z,rDDSK
        LD A,(IY)
         ccf ;CY=0: OK ;TODO переделать на CY=1 для скорости
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
        
tcrcerror
        db "CRC error"
tcrlf
        db 13,10,0

        include "../_sdk/file.asm"
        include "rarfile.asm"
        include "rardepk.asm"
        
defaultfilename
        db "0:/rar/acnews47.rar",0
;filename
;        db "depkfile.fil"
;        ds filename+256-$ ;дл€ длинных имЄн

CURFILE DS namln;DESCRIP DS 16 ;TODO убратьCURPOS  DS 4NXTPOS  DS 4
;;;;;32 bytes rar file headerCRCF    DW 0TYPEF   DB 0FLAGF   DW 0SIZEF   DW 0ADDSZF  DS 4UNPSIZE DS 4HOSTOS DB 0;NUFILECRC DS 4FTIME   DS 4UNPVER  DB 0METHOD  DB 0NAMSIZE DW 0ATTR    DS 4
;;;;;;;;;;;;;;;;;;;EXPTYP  DW 0 ;expected type&FLAGH;CRCLO   DW 0;YEFLAGH DB 0 ;TWICE;1=depk,0=view;FREXPT  DB 0 ;TWICE;FILEZ   DW 0;usable.FileCountERRORS  DW 0;ErrCount;unknown DW 0;NU=0.ExtrFileknown   DB 0 ;NOT unknown.MDCode;SCANres DW 0 ;TWICE.SCANres=HL.AllArgsUsed;CANTCR  DW 0;NU=0!can't create.UserReject;PASWFLG DW 0 ;(password?).TmpPassword;BEFEXTR DB 0 ;1=до EXTRACT.FirstFile;GDEIX   DW 0 ;ArcPtrVOLFLG  DB 0;ArcType,2=volSOLFLG  DB 0;SolidType(1)TSTARES DB 0;ArcFormatvolPKSZ DS 4volUNSZ DS 4pieces  DW 0 ;FileCount;zagol   DW 0;1=загол уже напечuNPremn DS 4;DestUnpSize IF crcCRCArea DS 4 ENDIF CRCA    DW 0 ;TWICE=BUF32TYPEA  DB 0;NUFLAGA   DW 0SIZEA   DW 0_62ae  DW 0;NU_62b0  DW 0;NU_62b2  DW 0;NU ;UnpCRC  DS 4 ;UnpFileCRC;YCOMM   DB 0;UnpVolume.4timesCOMSYM  DB 0
        align 256       IFN kbSECBUF  DS kb*1024       ELSE SECBUF  DS 256       ENDIF 
        ds 0x2000-$ ;DS -$&3
bd
ld      DS 298*4 ;должно быть выше 0x4000! TODO
dd      DS 48*4
rd      DS 28*4
OUTNAM  DS namln ;DestFileName
oldtimer
        dw 0        
cmd_end

        display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "unrar.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
