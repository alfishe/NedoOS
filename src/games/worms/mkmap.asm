MKMAP
        LD HL,sprpie
        LD (DrawPieaddr),HL

      if !ATM;!USELMNBUF
        call GenLMNList
        call CopyLMNGfx ;копируем графику выбранных элементов в LMNGFX (не более LMNGFXSZ)
      endif

       call DrawPie ;1

        call MKMAPPP ;generate map contour ;CY=error
        call CheckGroundExist ;проверяем, есть ли земля на ниж. линии (CY=error)
        jr c,MKMAP ;error

       call DrawPie ;2

        call EorFillInMap

       call DrawPie ;3

        call FindPlacesForGrass ;записывает в grassbuf

       call DrawPie ;4

        call MakeMaskFromMap

       call DrawPie ;5

        call TexturizeGroundInMap ;использует texture

       call DrawPie ;6

        call AddGrassInMap ;использует grassbuf

       call DrawPie ;7

;add elements:
      if ATM;USELMNBUF
        call GenLMNList
      endif
        LD C,3 ;initial X
      if !ATM;!USELMNBUF
        ld hl,LMNGFX
      else
        ld hl,LMNlist ;впритык к концу параграфа
      endif
LMN0    LD A,10
        CALL RNDA
        ADD A,C
        CP MASKWID-5 ;ширина элемента не более 10 знакомест
        JR NC,LMNQ ;X too big - no more elements
        LD C,A ;X
      if ATM;USELMNBUF
        ld b,(hl) ;N
      endif
;LMN00
;        push bc
      if ATM;USELMNBUF
       push hl
      endif
        CALL PRLMN
      if ATM;USELMNBUF
       pop hl
      endif
;        pop bc ;нельзя, PRLMN должен двигать C на ширину элемента
;        JR nc,LMN0
;;don't fit - next x ;а может, просто пропустить?
;        INC C ;don't fit, next x
;        LD A,C
;        CP MASKWID-5 ;ширина элемента не более 10 знакомест
;        JR C,LMN00;PRLMN00
      if !ATM;!USELMNBUF
        ld a,(hl)
        or a ;end of gfx?
      else
        inc l
      endif
        JR nz,LMN0
LMNQ

;clear table of y's (per column) usable for worms
        XOR A
        LD DE,TPLACES
        LD (DE),A
        INC E
        JR NZ,$-2
        LD LX,a;0
        call FindUsableYsInMask ;create table of usable y's and count them in LX

;place worms in TXY (x,y)
        LD A,LX ;usable columns count
       dec a
        LD BC,+(Nobjects-1)*256+0xff ;B=QUANTITY OF WORMS + quantity of mines -1 (for off by 1 disivion)
        INC C
        SUB B
        JR NC,$-2
        LD A,C ;(usablecolumns-1)/(quantityofworms-1) = xstep (first worm placed in first usable column)
        CP 7
         jp c,nowhere ;xstep too small
;C=WIDTH OF WORM PLACE = typically 7..11
        LD HL,TXY
        ld e,0 ;x ;e=0 (column 0 not used)
       ld b,1
       jr SETXgo ;first worm in leftmost position
SETX 
        LD B,C ;xstep
        ;SRL B ;first x = xstep/2
SETXgo
       PUSH BC
SETX0   INC E
         ;ld a,e
         ;cp MASKWID*4 -4
         ;jr z,$ ;проверка на вшивость FIXME
        LD A,(DE)
        OR A
        JR Z,SETX0 ;unusable column
        DJNZ SETX0 ;find usable column that far
        LD (HL),E ;x in TXY
        INC L
        LD A,(DE) ;y for this column
        add a,SKYMASKHGT-4 ;мы проверяли y по маске, но маска под ногами червя, высота червя=8, в маске =4
        RLCA 
        LD (HL),A ;y in TXY
        
       POP BC
       ; LD A,C ;xstep
       ; SUB B
       ; LD B,A ;xstep-1 ;xstep - (xstep/2)
SETX1  ; INC E
       ; LD A,(DE)
       ; OR A
       ; JR Z,SETX1
       ; DJNZ SETX1 ;skip so many usable columns

        INC L
        JR NZ,SETX

       call DrawPie ;8

        jp SETWMS ;make worm structures from TXY (x,y coords)

MKMAPPP
;generate map contour
;out: CY=error
        call ClearMap
        call PrepareXorPixInMap

        LD HL,DIRECTN
        LD DE,DTNTAB
        LD  C,32
        LDIR 

        LD E,0 ;SCREEN (X) NO. -1=NOPRINT
        LD C,E
        CALL RND
        AND 127
        add a,28;48
        LD B,A ;y?
        LD HL,DTNTAB+8   ;14
MKMAP0  LD A,2;4
        CALL RNDA
        CP 1;2
        SBC A,0;1
        ADD A,L
        LD D,L
        LD L,A
        CALL TESTL
        LD A,D
        SUB 5
        LD D,A
        LD A,L
        SUB 5
        XOR D
        AND 8
        CALL NZ,XorPixInMap ;b=y ;ec=x
        PUSH HL
        SLA L
        LD A,(HL)
        DEC A
        POP HL
        LD A,5
        JP P,$+5
        LD A,3
        CALL RNDA
        INC A
        LD D,A
MKMAP1  PUSH HL
        SLA L
        LD A,(HL)
        OR A
        CALL NZ,XorPixInMap ;b=y ;ec=x
        LD A,(HL)
        CP 128
        JR C,MKMAPFW
        ADD A,C
        LD C,A
        JR C,MKMAPBW
        DEC E
        JR MKMAPBW
MKMAPFW CP 2
        JR C,MKMAPN2
        INC C
        JR NZ,$+3
        INC E
        CALL XorPixInMap ;b=y ;ec=x
        LD A,1
MKMAPN2 ADD A,C
        LD C,A
        JR NC,$+3
        INC E
MKMAPBW INC L
        LD A,(HL)
        ADD A,B
        POP HL
        CP 208 +TERRAINHGT-MAPHGT
        JR C,MKMAPNY
        LD A,17
        SUB L
        LD L,A
        PUSH HL
       SLA L
       INC L
        LD A,(HL)
        ADD A,B
        POP HL
MKMAPNY LD B,A
        DEC D
        JR NZ,MKMAP1
        LD A,E
        CP 4 ;LAST SCREEN
        JR NZ,MKMAP0
        ret

TESTL
        LD A,L
        CP 2
        JR NC,TESTLNC
        SUB -3
        LD L,A
        RET 
TESTLNC
        CP 16
        RET C
        SUB 3
        LD L,A
        RET 

GenLMNList
       ld hl,LMNused
       ld de,LMNused+1
       ld bc,NLMN-1
       ld (hl),0xff
       ldir
;сначала генерируем список элементов, которые у нас будут использоваться (не более NLMNONMAP)
        ld de,LMNlist ;впритык к концу параграфа
genLMNlist0
retryLMN
        LD A,NLMN
        CALL RNDA
       ld l,a
       ld h,LMNused/256
       cp (hl)
       jr z,retryLMN
       ld (hl),a
        ld (de),a
        inc e
        jr nz,genLMNlist0
        ret

DIRECTN
        DW #100,#1FF,#FF,#FF
        DW -1,#FF00,#FF01,#FF02
        DW 2,2,#102,#101,#100,#1FF,#FF,#FF

FindUsableYsInMask
;create table of usable y's and count them in LX
;LX=0
       LD A,PGMASK
       CALL OUTME
        ld hl,MASK+MASKSZ-1 ;don't use last byte column
        LD C,64
        LD E,MASKWID*4-1 -4 ;don't use last byte column
SETF    RLC C
        RLC C
        JR NC,$+3
         DEC HL
        PUSH DE
        PUSH HL
;снизу вверх смотрим столбец маски (бит 0,2,4 или 6 в C)
        LD DE,-MASKWID
        LD B,MASKHGT-1 ;y
SETF0   ADD HL,DE
        LD A,C
        AND (HL)
        JR NZ,SETF1 ;pixel in column
        DJNZ SETF0
        JR SETFQ ;unusable column
SETF1   ADD HL,DE
        DEC B
        AND (HL)
        JR NZ,SETF1 ;снизу вверх ищем, когда пиксели кончатся (червь будет на уступе)
        INC LX ;usable columns count
SETFQ   POP HL
        POP DE
        LD A,B
        LD (DE),A ;y place for this column
        DEC E
        JR NZ,SETF ;column 0 not used
        ret
