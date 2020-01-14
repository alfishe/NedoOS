;stored                LD HL,(T622A) ;длина файла/256?Z6369  LD DE,#3F ;???       OR A       SBC HL,DE        JR C,_Z637B        PUSH HL        LD BC,#3F00        CALL Z6383        POP HL        JR Z6369_Z637B   ADD HL,DE        LD B,L        LD A,(ML_LEN_ISH)        LD C,A        OR B        RET Z        XOR A        LD (PROV1),AZ6383   LD HL,BUFER        PUSH BC,HL        CALL Z631F        POP HL,BC        PUSH BC        LD DE,(ST_LEN)        PUSH DE        CALL COPYB        POP HL,BC        ADD HL,BC        LD (ST_LEN),HL        ;LD A,4        ;CALL ON_BANK        LD A,#FC        CP HPROV1   RET NZ        LD DE,0        PUSH DE        CALL SAVE        POP DE        LD (ST_LEN),DE        LD A,#C0;RET NZ        LD (PROV1),A        ;LD A,4        ;JP ON_BANK
        ret
        
;HL= HAЧAЛO УПAKOBAHНOГO ФAЙЛA??? неправда!        PUSH AF,HLZ605D   LD A,(IX-1)        CP "/"        JR Z,_Z6068        DEC IX        DJNZ Z605D_Z6068  PUSH IX        POP DE ;de=после последнего слеша или в начале имени        LD HL,#5CE8        LD B,#BZ6070   DEC HL        LD (HL),#20        DJNZ Z6070        LD BC,#72EZ6078   LD A,(DE)        INC DE        OR A        JR Z,Z6091        CP C        JR Z,Z6089        BIT 7,B        JR NZ,Z6078        DEC B        CP "A"        JR C,OK1        CP #5B        JR NC,OK1        SET 5,AOK1     LD (HL),A        INC HL        JR Z6078Z6089   LD HL,#5CE5        LD BC,#200        JR Z6078Z6091   LD HL,#5CDD ;TODO fix        LD DE,T61F7        LD BC,8        CALL Z61BB ;LDIR        ADD HL,BC        LD A,(HL)        CP #20        LD C,3        CALL NZ,Z61B7 ;#2e, потом LDIR        XOR A        LD (DE),A ;???
        
        if 1==0
;fill the rest of buffer with zeros
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

        if 1==0COPYB   LD A,D        RLCA         RLCA         AND 3        CALL ON_BANK        PUSH DE        LD A,D        OR #C0        LD D,A        LD A,(HL)        CALL CRC32_        LDI         POP DE        INC DE        JP PE,COPYB;COPYB1  ;LD A,5        ;JP ON_BANK        ret        endif