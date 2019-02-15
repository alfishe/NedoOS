        
;взять b=R/G/Bmin, hl установить на начало буфера R/G/B:
        ;pop bc ;ld bc,(maxdistaxis) ;b=maxaxis
        ;ld l,0xff&chrbuf
        ;ld a,(Rminmax) ;Rmin
        ;djnz $+2+2+3
        ;ld l,0xff&(chrbuf+8)
        ;ld a,(Gminmax) ;Gmin
        ;djnz $+2+2+3
        ;ld l,0xff&(chrbuf+16)
        ;ld a,(Bminmax) ;Bmin
        ;ld b,a ;b=R/G/Bmin
        ;ld a,c ;c=maxdist
        ;rra
        ;rra
        ; and 0x3f
        ; add a,tmaxdistdiv/256
        ;ld d,a ;d=maxdistdiv

;потом выбираем лучшую ось:
        ;ld de,(Bminmax)
        ld a,d ;Bmax
        sub e ;Bmin
        ld c,a ;maxdist
        ld b,2 ;maxaxis
        pop de ;ld de,(Gminmax)
        ld a,d ;Gmax
        sub e ;Gmin
        cp c ;>=maxdist?
        ld hl,(Bminmaxcolor)
        jr c,$+2+1+1
         ld c,a ;maxdist
         ;dec b ;maxaxis=1
         ld hl,(Gminmaxcolor)
        pop de ;ld de,(Rminmax)
        ld a,d ;Rmax
        sub e ;Rmin
        cp c ;>=maxdist?
        jr c,$+2+4;2
         ;ld b,0 ;maxaxis
         ld hl,(Rminmaxcolor)
        ex de,hl

;потом берём положение рекордных цветов:
        ;pop de ;ld de,(Rminmaxcolor)
        ;djnz $+2+4
        ;ld de,(Gminmaxcolor)
        ;djnz $+2+4
        ;ld de,(Bminmaxcolor)


        if 1==0;0:03CNVTOGR        LD HL,#C000        LD BC,#7FFD        LD E,1        CALL SETPG       LD D,GRF/256 ;таблица brightness/contract/dithering level        LD A,(MAXV8)        LD B,AYSGOOP        PUSH BC        LD BC,(LSZX) ;<256?      ;LD A,C      ;DEC BC      ;INC B      ;LD C,B ;1..256 => 1, 257..512 => 2      ;LD B,AXSGOOP        LD E,(HL)        LD A,(DE)        LD (HL),A      ;INC HL      ;DJNZ XSGOOP      ;DEC C      ;JNZ XSGOOP       CPI        JP PE,XSGOOP        POP BC       ;hgt<256        DJNZ YSGOOP        RET 
        endif
        if 1==0;0:26CNVTORGB        LD HL,#C000        LD BC,#7FFD        LD DE,#7FDF        EXX         LD E,1        CALL SETPG        LD A,(MAXV8)        LD B,AYSLOOP        PUSH BC        LD BC,(LSZX)XSLOOP        PUSH BC;once+ini;/168900 CALLS;20t=1s!!!;SCONV        EXX         LD A,#1B        OUT (C),A        LD A,(HL)        LD (pCB+1),A        LD A,#1C        OUT (C),A        LD A,(HL)       EXA         LD A,#19        OUT (C),A        LD A,(HL)        LD (pY+1),A       EXA         EXX        LD L,A       LD H,'G716C        LD E,(HL)        INC H        LD D,(HL)       INC H        LD C,(HL)        INC H        LD B,(HL)pY      LD HL,PTAB       EX DE,HL        ADD HL,DE        LD A,(HL)       LD (RC+1),ApCB    LD HL,G7170       DEC H       LD A,(HL)       DEC H       LD L,(HL)       LD H,A        ADD HL,BC        ADD HL,DE        LD A,(HL)       LD (GC+1),A       LD HL,(pCB+1)        LD C,(HL)        INC H        LD B,(HL)       EX DE,HL        ADD HL,BC        LD C,(HL)       LD B,'GRF       LD A,(BC)       LD (BCL+1),A       LD A,(RC+1)       LD C,A       LD A,(BC)       LD (RC+1),A       LD A,(GC+1)       LD C,A       LD A,(BC)       LD (GC+1),A;считали все, а берем одну....pCLRS   LD A,(0)        EXX         LD (HL),A        INC HL        EXX         POP BC        DEC BC        LD A,B        OR C        JP NZ,XSLOOP        POP BC        DEC B ;hgt<256        JP NZ,YSLOOP        RET 
        endif

RC      OR 0GC      OR 0BCL     OR 0