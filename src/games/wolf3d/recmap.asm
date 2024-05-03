RECMAP
        LD HL,WASMAP
        LD DE,0x4000
       PUSH DE
        LD BC,szMAP
        LDIR 
       POP HL
        LD DE,level
        LD BC,endlev-level
        LDIR 
        
          ld de,MONSTRS
        
       if invmap;atm
       LD A,(YX+1) ;Y
       SUB 0xA0
       SUB map/256+31
       CPL 
       LD (IMcurYy+1),A
       LD A,(YX) ;X
       INC A
       LD (IMcurXx+1),A
       endif
INImons LD A,(HL) ;x
        LDI
        AND (HL) ;X
        LDI 
        INC A
        JR Z,INImonsQ
        ldi ;y
        ldi ;Y
;перекодируем PHASE_type (type, PHASE) в TYPEphase_dir (dir, TYPEphase) ;TYPEphase=TYPE*8+phase
        xor a
        ld (de),a ;dir (nomove)
        ld a,(hl) ;type=1...
        cp 7
        jr nc,INImons_nolive
        cp 3
        jr c,INImons_nomove
        ld (hl),3
        sub 3 ;0..3
        rlca
        rlca
        inc a
        ld (de),a ;dir
INImons_nomove
INImons_nolive
        ld a,(hl)
        cp 7
        jr c,$+4
        sub 3
        add a,a
        add a,a
        add a,a
        inc hl
        ;add a,(hl) ;phase
        inc hl
        inc de
        ld (de),a
        inc de
        ;ldi ;energy
        ;ldi ;time
        inc hl
        inc hl
        ld a,100
        ld (de),a ;energy
        inc de
        ld a,1
        ld (de),a ;time
        inc de
        JR INImons
INImonsQ ;
       ex de,hl;EXD 
       if invmap;atm 
        LD H,map/256+31
       else
        LD H,map/256
       endif
       IF invmap
       LD L,map&0xff
       LD C,1
       JR GETMAPL
       ENDIF 
GETMAP0
       IF invmap
        LD L,0xff&(map+32)
       ELSE 
        LD L,map&0xff
       ENDIF 
        LD C,2
GETMAPL LD B,32;33
GETMAP1 LD A,(DE)
        INC DE
        LD (HL),0 ;пустое место в памяти
        CP 13
        JR Z,GETMCR
       IF invmap;atm
       jr NC,GMNRLE
        LD A,(DE)
        INC DE
       DEC A
GMRLE
        INC L
        LD (HL),0 ;пустое место в памяти
        DEC B
        DEC A
        jr NZ,GMRLE
        LD A,32 ;пустое место в формате карты
GMNRLE
       ENDIF 
        CP 32 ;пустое место в формате карты
        JR Z,GETMAPE
        cp 0xc1 ;зеркальное пустое место в формате карты
        JR Z,GETMAPE
      if invmap
      CP 64    ;
      jr NC,$+4  ;
      ADD A,64 ;todo kill
       ADD A,128-64
      endif
      IF !atm
       if invmap
       sub 128
 ;в примере используются стены 16..39. они уже домножены на 2 (младший бит=зеркальность)
        sub 16*2
       else
       add a,a
       SUB "1";+128
       endif
      if doublescr
       cp texturesinpg*2*2
       jr c,$+4
       ld a,(texturesinpg*2-1)*2
       cp texturesinpg*2
       jr c,$+4
       sub texturesinpg*2+0x40
      else
       cp texturesinpg*2
       jr c,$+4
       ld a,(texturesinpg-1)*2
      endif
     add a,0xc0 ;хранится ID>=128, чтобы делать двери
      ENDIF 
       LD (HL),A
GETMAPE INC L
        DJNZ GETMAP1
        JR GETMOK
GETMCR  LD (HL),0
        INC L
        DJNZ GETMCR
GETMOK
       IF invmap
       LD L,map&0xff
       ENDIF 
        DEC C
        jr NZ,GETMAPL
       if invmap;atm
        LD A,H
        DEC H
        CP map/256
        JR NZ,GETMAP0
       else
        INC H
        BIT 6,H
        JR Z,GETMAP0
       endif

        if invmap
        LD HL,MONSTRS+1 ;1+начало табл.монстров/предметов
remons0
        LD A,(HL) ;X
         inc (hl)
        INC A
       jr Z,remonsq
        ;ld a,0xff&(map+32+map+0)
        ;sub (hl)
        ;ld (hl),a ;???
        INC L
        inc L
        LD A,(HL) ;Y
       SUB 0xA0
       SUB map/256+31
       CPL 
        ld (hl),a
        LD A,L
        ADD A,6
        LD L,A
        JP NC,remons0
        INC H
        JP remons0
remonsq
        endif

       IF atm == 0
        LD HL,#4000
        CALL INICLS
       IF doublescr
        LD A,#17
        CALL SETPG
        LD HL,#C000
        CALL INICLS
       ENDIF 

        XOR A
        LD H,scrbuf/256
        LD C,scrwid
PRECLS  LD L,scrbuf&0xff
        LD B,scrhgtpix
        LD (HL),A
        INC L
        DJNZ $-2
        INC H
        DEC C
        jr NZ,PRECLS
       ENDIF 	
        ret
        
       if atm==0
INICLS
        LD D,H
        ld E,1
        LD BC,#1800
        LD (HL),L
        LDIR 
        LD BC,767
        LD (HL),colour
        LDIR 
        RET 
       endif
