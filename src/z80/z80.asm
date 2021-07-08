        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

PROFI=512;1024
	if PROFI=512
PGATTR0=0x18
PGATTR1=0x1a
	else
PGATTR0=0x38
PGATTR1=0x3a
	endif

;emul=в 0000
;основной набор регистров=в альтернативном наборе
;PC=в DE
;текущий индексный=в IX
;не текущий индексный=в _IZ
;SP=в _SP (todo в (SP)? но там сейчас jpiyer для выхода из DOSER. сделать в DOSER 2-байтный патч?)

STACK=0x4000

stats=0 ;статистика по опкодам

margins=1 ;1=хранить в de уже пересчитанный PC ;8000,c000 - всегда замапленные страницы ;4000 - страница ПЗУ или текущая PC
;MEM48C0=1 ;8000,c000 - всегда замапленные страницы ;4000 - страница ПЗУ или текущая 4000 (каждый раз включать)

extpg5=1 ;1=перехват экрана

skipIM1=1 ;1=вместо трассировки #38 вызываем ее (если IY=23610)

        MACRO OUTPG
        SETPGC000
        ENDM 

       if margins
        MACRO OUTPGCOM
        SETPG4000
        ENDM
       endif

        MACRO OUTPG4000
        SETPG4000
        ENDM 

        MACRO _Loop_
       ;OUTcom
        JP (IY) ;EMULOOP
        ENDM 

;если вместо стр.команд включили др.стр.
        MACRO _LoopC
        OUTcom
        JP (IY)
        ENDM 

;если вместо стр.команд включили др.стр. и до этого момента не трогали флаги
        MACRO _LoopCimmediately
        OUTcomCY15
        JP (IY)
        ENDM 

;если резко сменился PC (полный DE)
        MACRO _LoopJP
        CALCiypgcom
        jp DOSER
        ENDM 
        MACRO _LoopJP_NODOS
        CALCiypgcom
        JP (IY)
        ENDM 

;если эмулятор щёлкал страницу и резко сменился PC (полный DE)
        MACRO _LoopC_JP
        CALCiypgcom
        jp DOSER
        ENDM 
        MACRO _LoopC_JP_NODOS
        CALCiypgcom
        JP (IY)
        ENDM 

;если IN/OUT (могла измениться конфигурация памяти - но внутри out7ffd уже есть CALCpgcom)
        MACRO _LoopSWI
        JP (IY)
        ENDM 

;берем смещение d
;результат HL=IX+d
        MACRO getdIXtoHL
        get
        next
        LD L,A
        RLA 
        SBC A,A
        LD H,A
        PUSH IX
        POP BC
        ADD HL,BC
        ENDM 

       if margins
        include "mem_marg.asm"
       else
       ;if MEM48C0
       ; include "mem_48c0.asm"
       ;else
        include "mem_c000.asm"
       ;endif
       endif

        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT
        ld e,3+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ;ld e,0 ;color byte
        ;OS_CLS

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
       push hl
        ld hl,temulpgs
        ld a,d
        ld (deadpg),a
        ld (hl),d
        ld d,h
        ld e,l
        inc de
        ld bc,64-1
        ldir
        ;OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
       pop hl
        ld a,h
        ld (temulpgs+2),a
        ld a,l
        ld (temulpgs+0),a

        ld a,(user_scr0_low) ;ok
        call clearpg
        ld a,(user_scr1_low) ;ok
        call clearpg

       if extpg5
        OS_NEWPAGE
        ld a,e
       else
        ld a,(user_scr0_high) ;ok
       endif
        ld (temulpgs+5),a
       if extpg5
        OS_NEWPAGE
        ld a,e
       else
        ld a,(user_scr1_high) ;ok
       endif
        ld (temulpgs+7),a

        OS_NEWPAGE
        ld a,e
        ld (temulpgs+1),a
        OS_NEWPAGE
        ld a,e
        ld (temulpgs+4),a
        OS_NEWPAGE
        ld a,e
        ld (temulpgs+6),a
        OS_NEWPAGE
        ld a,e
        ld (temulpgs+PGATTR0),a;0x38
        OS_NEWPAGE
        ld a,e
        ld (temulpgs+PGATTR1),a;0x3a

        OS_NEWPAGE
        ld a,e
        ld (temulpgs+3),a
        OS_NEWPAGE
        ld a,e
        ld (temulpgs+8),a
        OS_NEWPAGE
        ld a,e
        ld (temulpgs+9),a
        OS_NEWPAGE
        ld a,e
        ld (temulpgs+10),a

        ld de,path
        OS_CHDIR      
        ld de,diskname
        OS_OPENHANDLE
        ld a,b
        ld (diskhandle),a
       
        OS_NEWPAGE
        ld a,e
        LD (pgrom48),a
        LD (pgrom48_im1check),a
        ld de,trom48
;de=имя файла
;a=в какой странице
        call loadfile_in_ahl

        OS_NEWPAGE
        ld a,e
        LD (pgrom128),a
        ld de,trom128
;de=имя файла
;a=в какой странице
        call loadfile_in_ahl

        OS_NEWPAGE
        ld a,e
        LD (pgromDOS),a
        ld de,tromDOS
;de=имя файла
;a=в какой странице
        call loadfile_in_ahl

        OS_NEWPAGE
        ld a,e
        LD (pgromSYS),a
        ld de,tromSYS
;de=имя файла
;a=в какой странице
        call loadfile_in_ahl

        call swapimer

Reset
        ld sp,STACK

;хотя бы одно прерывание, чтобы захватить матрицу клавиатуры
        ld b,25
waitstart0
        halt ;не YIELD, иначе наш обработчик не вызовется!
        djnz waitstart0

       if 0;extpg5
        xor a
        ld (screenin4000_flag),a
        ld a,0xc9
        ld (screenin0000_flag),a
        ld (screenin8000_flag),a
        ld (screeninc000_flag),a
       endif

        ;ld a,5
        ;ld (_logicpg4000),a
        ;ld a,(temulpgs+5)
        ;ld (emulcurpg4000),a
        ;SETPG4000 ;TODO убрать
        ;ld a,2
        ;ld (_logicpg8000),a
        ;ld a,(temulpgs+2)
        ;ld (emulcurpg8000),a
        ;SETPG8000

        ld a,-1 ;impossible value
        ld (oldcurvideomode),a
        ld (oldcurscr7ffd),a

       ;ld a,-1
       ;ld (doson0),a ;for basic48
        xor a
        ld (doson0),a
        ;ld a,0x10 ;for basic48
        ld (_fd),a
        ;xor a
        ld (_dffd),a
        CALL eoutDFFD;дальше идёт на eout7FFD

       if 0
        LD HL,0
        ld d,h
        ld e,l
        ld b,h
        ld c,l
        PUSH HL
        POP AF
        ld (immode),a
        PUSH HL
        POP ix
        ld (_IZ),hl
        ld (_AF),hl
        ld (_BC),hl
        ld (_DE),hl
        ld (_HL),hl
        EXX 
        EXA
       endif

        LD DE,0x0000 ;=PC
Jumpin
      IF margins
       ;LD HL,emulcurpg0000
       ;LD (curquart),HL
       ; LD A,(HL)
       ; OUTPGCOM
       ; ld de,0x4000 ;пересчитанный PC
        CALCiypgcom
      endif

        ld a,0xdd
        ld (oldprefix),a ;ix содержит ix

        xor a
        ld (immode),a

        LD IY,EMUCHECKQ
       ;EMUDATABUS ;ШД0..2 на бордюр
       ;EMUADDRBUS ;ША8..10 ма бордюр
       ;EMUCHECKPOINT ;проверка адреса или условия
                      ;проверка числа тактов до INT?
jpiyer
        ld hl,jpiyer
        push hl
        jp (iy)

Quit
        call swapimer
        QUIT

Loadsnapshot
        ld sp,STACK

        ld de,snapshotram3name
        ld a,(temulpgs+3)
        call loadfile_in_ahl
        ld de,snapshotram5name
        ld a,(temulpgs+5)
        call loadfile_in_ahl
        ld de,snapshotram8name
        ld a,(temulpgs+8)
        call loadfile_in_ahl
        ld de,snapshotram9name
        ld a,(temulpgs+9)
        call loadfile_in_ahl
        ld de,snapshotramaname
        ld a,(temulpgs+10)
        call loadfile_in_ahl

        ld de,snapshotscrname
        ld a,(temulpgs+6)
        call loadfile_in_ahl
        ld de,snapshotattrname
        ld a,(temulpgs+PGATTR1);0x3a
        call loadfile_in_ahl

        ld de,snapshotname
        OS_OPENHANDLE
        ld a,(temulpgs+0)
        call loadsnappg
        ld a,(temulpgs+1)
        call loadsnappg
        ld a,(temulpgs+2)
        call loadsnappg
        ld a,(temulpgs+7)
        call loadsnappg
        OS_CLOSEHANDLE

       if 0;extpg5
        ld a,0xc9
        ld (screenin4000_flag),a
        ld a,0xc9
        ld (screenin0000_flag),a
        ld a,0xc9
        ld (screenin8000_flag),a
        ld a,0xc9
        ld (screeninc000_flag),a
       endif

        ;ld a,(temulpgs+1)
        ;ld (emulcurpg4000),a
        ;SETPG4000 ;TODO убрать
        ;ld a,(temulpgs+2)
        ;ld (emulcurpg8000),a
        ;SETPG8000

        ld hl,0xe6fb
        ld (_SP),hl

        ld a,-1 ;impossible value
        ld (oldcurvideomode),a
        ld (oldcurscr7ffd),a

       ;ld a,-1
       ;ld (doson0),a
        xor a
        ld (doson0),a
        ld a,0x09 ;screen 1
        ld (_fd),a
        ld a,0xb8
        CALL eoutDFFD;дальше идёт на eout7FFD
        
        ld a,0xff
        ex af,af' ;'
        ld bc,0xff00
        ld de,0x321f ;важно!!!
        ld hl,0xffff
        ld ix,0x001d ;?0038?
        exx
        
        ld de,0x07a2
        jp Jumpin

;oldpc
;        dw 0

EMUCHECKQ
       ;ld a,(0x4000)
       ;or a
       ;jr z,$
       ;ld a,d
       ;sub 0x7c
       ;cp 2
       ;jr nc,$
       ;ld (oldpc),de
        get
        next
       IF stats
       PUSH HL
        LD L,A
        LD H,comstats/256-1
        INC H
        INC (HL)
        jr Z,$-2
       POP HL
       ENDIF 
        LD L,A
        ld H,MAINCOMS/256
        LD C,(HL)
        INC H
        LD H,(HL)
        ld L,C
        JP (HL)
;можно выиграть 11(-JP=1) тактов:
       ;LD L,A
       ;AND 3 ;3 для JP, а можно(?) целые п/п: 7/15/31
       ;ADD A,'MAINCOMS
       ;LD H,A
       ;JP (HL) ;L=код команды, если надо ;но надо менять обработчики, они сейчас ждут код в A!
;или ld l,a:ld h,NN:ld h,(hl):jp (hl)
;или ld l,a:or 0xc0:ld h,a:jp (hl)

CBPREFIX
        get
        next
        LD L,A
        ld H,CBCOMS/256
        LD C,(HL)
        INC H
        LD H,(HL)
        ld L,C
        JP (HL)

EDPREFIX
        get
        next
        LD L,A
        ld H,EDCOMS/256
        LD C,(HL)
        INC H
        LD H,(HL)
        ld L,C
        JP (HL)

FDPREFIX
DDPREFIX
oldprefix=$+1
        CP #DD
        jr Z,DDFDold
        LD (oldprefix),A
;сменили префикс! меняем местами IX и _IZ
        LD HL,(_IZ)
        LD (_IZ),IX
        PUSH HL
        POP IX
DDFDold
        get
        next
        LD L,A
        ld H,DDCOMS/256
        LD C,(HL)
        INC H
        LD H,(HL)
        ld L,C
        JP (HL)

DDCBPREFIX
        getdIXtoHL
       PUSH HL
        get
        next
        LD L,A
        ld H,DDCBCOMS/256
        LD C,(HL)
        INC H
        LD H,(HL)
        ld L,C
       EX (SP),HL
       RET 

EMUDATABUS
        LD A,(DE)
       OUT (-2),A
        JP EMUCHECKQ

EMUADDRBUS
        LD A,D
       OUT (-2),A
        JP EMUCHECKQ

EMUCHECKPOINT
retfromim=$+1
        LD HL,0
        XOR A
        SBC HL,DE
        JP NZ,EMUCHECKQ
        LD A,(_fe)
       OUT (-2),A
        JP EMUCHECKQ

clearpg
        OUTPG4000
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x3fff
        ld (hl),l
        ldir
        ret

keymatrix
        ds 8,0xff

DOSrdindex
        LD A,E
        cp #08
        jr z,DOSsetheadwait
        CP #b2 ;#3eb2
        jr nz,jpiy;ret nz
;Адрес #3EB2. Проверка индексной области дорожки. Установите #5CD1 и поместите в B время перемещения головки дисковода. Выбирается верхняя сторона и при ошибке в #5D17 помещается #FF. В регистр H помещается номер текущей дорожки. Используется также с адреса: #3EE7 (обработка ошибки NO DISC).
       ld a,(dos3F) ;trk
       exx
       ld h,a
       exx
        jp imitret
DOSsetheadwait
        ld a,3
        ld (fddstatemask),a ;костыль!!!
        jp imitret

DOSER
;после каждой команды, меняющей PC ;выход по jp (iy)
;если мы не в досе, то проверяем, что D=#3D
;если мы в досе, то проверяем, что D<=#40
;если мы в 128K (TODO или в ОЗУ 0000), то ничего не делаем
DOSSTATE_FROM48=0x18 ;jr DOSERny
DOSSTATE_FROMDOS=0x3e ;ld a,N (skip jr)
DOSSTATE_FROM128=0xc9 ;ret
        ;LD A,(doson0)
        ;OR A
        ;jr NZ,DOSERny
DOSER_state=$
        jr DOSERny
       if margins
        ld a,(curquart)
        cp 3 ;0000?
        jr z,DOSDOS ;DOS -> DOS
       else
        LD A,D
        CP #40
        jr C,DOSDOS ;DOS -> DOS
       endif
;DOS -> неDOS
;выкл. стр. доса
        LD A,-1
        LD (doson0),A ;DOS ports off
        ld a,DOSSTATE_FROM48
        ld (DOSER_state),a
        LD A,(_fd)
        call eout7FFD
jpiy
        jp (iy)
DOSDOS
  ;для SYS не перехватываем!
        LD A,(_fd)
        AND 16
        jr z,jpiy;RET Z
        ld a,d
;перехваты процедур доса
       if margins
        cp 0x3e+0x40
       else
        cp 0x3e
       endif
        jr z,DOSrdindex
       if margins
        cp 0x3f+0x40
       else
        cp 0x3f
       endif
        jr nz,jpiy;RET NZ ;не перехватываем
;имитировать RET после неё
        LD A,E
        CP #D5 ;#3fd5
        jr Z,DOSRD
        CP #E5 ;#3fe5
        jr Z,DOSRD
        CP #BA ;#3fba
        jr z,DOSWR
        jp (iy) ;RET NZ
DOSRD
        xor a
        ld (fddstatemask),a ;костыль!!! иначе читает через раз
     PUSH DE,IX,IY
        EXX 
        PUSH HL
        INC H
        EXX 
        POP HL
        LD C,5
        LD A,(dos3F) ;trk
        ADD A,A
        LD D,A
        LD A,(dosFF)
        BIT 4,A
        jr nz,$+3
        INC D
        LD A,(dos5F) ;sec
        DEC A
        LD E,A
        CALL DOSrdsec
     POP IY,IX,DE
DOSWR
;TODO
        jp imitret

DOSERny
;from 48/RAM
       if margins
        ld a,d
        cp 0x3d+0x40
        jr nz,jpiy;RET NZ
        ld a,(curquart)
        cp 3 ;0000?
        jr nz,jpiy;RET NZ
       else
        LD A,D
        CP #3D
        jr nz,jpiy;RET NZ
       endif
  ;для 128 васика запрещено! иначе глючит калькулятор
        ;LD A,(_fd)
        ;AND 16
        ;RET Z
;неDOS -> DOS
       LD A,E
       CP #13
       jr Z,DOS3D13 ;если убрать, будет значительно медленнее
DOSSWON
;вкл. стр. доса
;имитация RET не катит для точки #3D2F
        XOR A
        LD (doson0),A ;DOS ports on
        ld a,DOSSTATE_FROMDOS
        ld (DOSER_state),a
        LD A,(_fd)
        call eout7FFD
        jp (iy)
DOS3D13
        exx
        ld a,c
        exx
        cp 6
        jr z,DOSWRSEC
        cp 5
        jr nz,DOSSWON ;(for other functions)
DOSRDSEC
DOSWRSEC
        exx
D3D5S0
        CALL DOSrdsec ;c=5(read)/6(write)
        inc h
        inc e
        bit 4,e
        jr z,$+5
        inc d
        ld e,0
        DJNZ D3D5S0
;write de to virtual 23796:
        ld hl,23796
        ld b,d
        ld c,e
        putmemBC
        exx
       jp imitret ;имитировать RET после неё

DOSrdsec
;hl=addr
;d=track
;e=sector
;c=5(read)/6(write)
       PUSH BC
       PUSH de
       PUSH HL
       EXX 
       EXA 
        PUSH AF
        PUSH BC,DE,HL
        push ix,iy
       EXA 
       EXX 
        push hl ;addr
        ld a,e ;de=trsec
        add a,a
        add a,a
        add a,a
        add a,a
        ld l,d ;track
        ld h,0 ;0la=trsec*16
        dup 4
        add a,a
        adc hl,hl
        edup ;hl0=trsec*256
        ld d,a;0
        ld e,h
        ld h,l
        ld l,a;0 ;dehl=shift in file
diskhandle=$+1
        ld b,0
       push bc ;c=5/6
        OS_SEEKHANDLE
       pop bc ;c=5/6, b=handle
        pop hl ;addr
       bit 0,c
       jr nz,DOSrdsec5
        ld de,secbuf
        push bc
        push de
        ld b,0
DOSwrseccopy0
        push bc
        push hl
        getmem
        ld (de),a
        pop hl
        pop bc
        inc hl
        inc de
        djnz DOSwrseccopy0
        pop de ;secbuf
        pop bc ;b=handle
        ld hl,256 ;de=phys addr ;hl=size
        OS_WRITEHANDLE
       jr DOSrdsec5ok
DOSrdsec5
         push hl ;addr
         ld de,secbuf
         push de
        ld hl,256 ;size
        OS_READHANDLE
         pop hl ;secbuf
         pop de ;addr
        ex de,hl ;de->hl
        ld b,0
DOSrdseccopy0
        push bc
        push hl
        ld a,(de)
        putmem
        pop hl
        pop bc
        inc hl
        inc de
        djnz DOSrdseccopy0
DOSrdsec5ok
       exx
       EXA 
        pop iy,ix
        pop hl,de,bc
        pop af
       EXA 
       EXX 
        pop hl,de,bc    
        ret

        include "debugsrv.asm"
        include "debugger.asm"
        INCLUDE "disasm.asm"

        INCLUDE "ports.asm"

        INCLUDE "z80cmd.asm"
        align 256
        INCLUDE "z80table.asm"
        align 256
t866toatm
        incbin "../kernel/866toatm"
        DISPLAY $
       IF stats
        align 256
comstats
        DISPLAY "comstats=",$
        DS #400
       ENDIF 

        include "rst38.asm"

on_int
        PUSH AF,HL

        ex af,af' ;'
        push af

        push bc,de
        exx
        push bc
        push de
        push hl
        push ix
        push iy

        ld a,(curscr)
oldcurscr=$+1
        cp 0
        jr z,IMERnoscr
        ld (oldcurscr),a
        rrca
        rrca
        rrca
        ld e,a
        OS_SETSCREEN
IMERnoscr

        ld a,(_fe)
        and 7
oldcurborder=$+1
        cp 0
        jr z,IMERnoborder
        ld (oldcurborder),a
        ld e,a
        OS_SETBORDER
IMERnoborder
        call oldimer

       if 0
        ld bc,0x7ffe
        in a,(c)
        ld lx,a  ;lx=%???bnmS_
        ld b,0xbf
        in a,(c)
        ld hx,a  ;hx=%???hjklE
        ld b,0xdf
        in l,(c)  ;l=%???yuiop
        ld b,0xef
        in h,(c)  ;h=%???67890
        ld b,0xf7
        in e,(c)  ;e=%???54321
        ld b,0xfb
        in d,(c)  ;d=%???trewq
        ld a,0xfd
        in a,(0xfe);c=%???gfdsa
        ld b,c;0xfe
        in b,(c)  ;b=%???vcxzC
        ld c,a
       else
        OS_GETKEYMATRIX ;out: bcdehlix = halfrows cs...space
       endif
        ld (keymatrix),ix
        ld (keymatrix+2),hl
        ld (keymatrix+4),de
        ld (keymatrix+6),bc
        OS_GETKEY
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется дляи обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус. 
        jr nz,IMERnofocus
        ld a,e
        ld (mousex),a
        ld a,d
        ld (mousey),a
        ld a,l
        ld (mousebuttons),a
        ld a,lx
        ld (kempston),a
IMERnofocus

        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        exx
        pop de,bc       

        pop af
        ex af,af' ;'

debugon=$
        or a
        jr c,imerskipdebug

;здесь опрос клавиш эмулятора
       ld a,0xef
       in a,(0xfe)
       and 0b10101 ;6+8+0
       jp z,Reset
       ld a,0xf7
       in a,(0xfe)
       push af
       and 0b10101 ;1+3+5
       jp z,Quit
       pop af
       push af
       and 0b10011 ;1+2+5
       jp z,Loadsnapshot
       pop af
       and 0b11000 ;4+5
       jp z,GotoDebugger

       LD A,(iff1)
       OR A
       jr NZ,IMEREI
imerskipdebug
        POP HL,AF
        EI 
        RET        
IMEREI
        XOR A
        LD (iff1),A
        LD (iff2),A ;для NMI надо только iff1!
;перед эмуляцией INT завершаем тек.команду (перехват на EMULOOP)
        LD (keepemuchecker),IY
        LD IY,IMINT
        POP HL,AF
        RET  ;di!
GotoDebugger
;перед входом в отладчик завершаем тек.команду (перехват на EMULOOP)
        LD (keepemuchecker),IY
        LD IY,IMDEBUG
        POP HL,AF
        EI 
        RET 
IMDEBUG
       ld a,55 ;scf
       ld (debugon),a

;запоминаем регистры в переменные
       CALCpc ;de=old PC
       ld (curpc),de
       exx
       ld (curbc),bc
       ld (curde),de
       ld (curhl),hl
       ex af,af' ;'
       push af
       pop hl
       ld (curaf),hl
;ставим, что был префикс #dd, кладём curix,curiy
        ld a,(oldprefix)
        CP #DD
        jr Z,IMDEBUGwasdd
;был префикс #fd, ix содержит "iy"
        ld a,#dd
        LD (oldprefix),A
        LD HL,(_IZ) ;=curiy
        ld (curiy),ix ;=_IZ
        ld (curix),hl
        jr IMDEBUGwasddq
IMDEBUGwasdd
        ld (curix),ix
        ;ld (curiy),hl ;=_IZ
IMDEBUGwasddq

        call Debugger

;берём регистры из переменных (уже установлено "был префикс #dd")
        ld ix,(curix)
        ;ld hl,(curiy) ;=_IZ
        ;ld (_IZ),hl
       ld hl,(curaf)
       push hl
       pop af
       ex af,af' ;'
       ld hl,(curhl)
       ld de,(curde)
       ld bc,(curbc)
       exx
       
       ld a,55+128 ;or a
       ld (debugon),a
        ld iy,(keepemuchecker)
       ld de,(curpc)
       _LoopC_JP
IMINT
keepemuchecker=$+2
        LD IY,0
       LD (retfromim),DE ;для индикации времени обработки прерыв
       LD A,(immode)
       CP #18 ;IM2
        LD HL,#38 ;new PC
       jr NZ,IMERIM1
        LD HL,(_I-1)
        LD L,#FF ;состояние пассивной ШД
        getmemBC
        ld h,b
        ld l,c
        JR IMERIM
GETIY
        LD HL,(_IZ)
        LD A,(oldprefix)
        CP #DD
        RET Z
        PUSH IX
        POP HL
        RET 
IMERIM1
     IF skipIM1
        ;ld a,(romstate_flag)
        ;cp ROMSTATE_ON
        ld a,(emulcurpg0000)
pgrom48_im1check=$+1
        cp 0
        jr nz,IMERIM
       PUSH HL
        CALL GETIY
        LD BC,23610
        OR A
        SBC HL,BC
       POP HL
        JR NZ,IMERIM
;вообще-то надо и SP проверить...
      push ix
      PUSH IY
     if margins;MEM48C0
        call setmem4000
     endif
      LD IY,23610
      call L0038;basicrst38
      LD A,-1
      LD (iff1),A
      LD (iff2),A
      POP IY
      pop ix
     _LoopC ;RET уже был (адрес со стека снят)
     ENDIF 
IMERIM
;hl=new PC
        EI 
       CALCpc ;de=old PC
        ex de,hl ;DE=new PC
        LD B,H
        ld C,L ;BC=old PC
        LD HL,(_SP)
        DEC HL,HL
        LD (_SP),HL
        putmemBC
       _LoopC_JP

writescreen_6912
        bit 1,a
        ld a,(user_scr0_high) ;ok
        jr z,$+5
        ld a,(user_scr1_high) ;ok
;curscreenc000pgaddr=$+1
        ;ld a,(user_scr1_high) ;ok
       push bc
        OUTPG4000
       pop bc
       ld (hl),c
        ret

writescreen_profi
;hl=0x4000+ (keep)
;c=data (keep bc)
;a=logicpg
      push hl
       push bc
;y=%TTYYYyyy
;hl=%010TTyyy YYYxxxxx
       push af
        ld a,h
        xor l
        and 0x1f
        xor l
       ld c,l
        ld l,a
       ld a,c
       and 0x1f
       ld b,0
       bit 5,h
       jr nz,$+4
       ld b,0x20
        ld h,tprofiy/256
        ld c,(hl)
        inc h
        ld h,(hl)
        ld l,a
        add hl,bc
;addr=0x4000+(half*0x2000)+y*40+x
       pop af
       bit 4,a
       jr z,writescreen_profi_outpg_pix
        bit 1,a
        ld a,(user_scr0_low) ;ok
        jr z,writescreen_profi_outpg
        ld a,(user_scr1_low) ;ok
        jr writescreen_profi_outpg
writescreen_profi_outpg_pix
        bit 1,a
        ld a,(user_scr0_high) ;ok
        jr z,writescreen_profi_outpg
        ld a,(user_scr1_high) ;ok
writescreen_profi_outpg
        OUTPG4000
       pop bc
       ld (hl),c
      pop hl
        ret

       if margins;MEM48C0    

       if extpg5
setmem8000c000writec
;CY=1, keep CY (keep A for rra:ld h,a)
        jp m,setmemc000writec
        ld (hl),c
screenin8000_flag=$
        ret ;/nop for screen in 8000
       ld a,(_logicpg8000)
SCREEN8000_VIDEOMODE_6912=0x30 ;jr nc
SCREEN8000_VIDEOMODE_PROFI=0x38 ;jr c
screen8000_videomode=$
        jr nc,screen8000_profi
        bit 5,h
        jr nz,setmem8000writec_skip
        res 7,h
        set 6,h
        call writescreen_6912
       push bc
        LD bc,(curquart)
        LD A,(bc)
        OUTPGCOM ;надо именно тут, т.к. OUTcomCY15 работает только после обращения к <0x8000
       pop bc
        set 7,h
        res 6,h
setmem8000writec_skip
       ld a,h
       add a,a
        ret
screen8000_profi
        res 7,h
        set 6,h
        call writescreen_profi
       push bc
        LD bc,(curquart)
        LD A,(bc)
        OUTPGCOM ;надо именно тут, т.к. OUTcomCY15 работает только после обращения к <0x8000
       pop bc
        set 7,h
        res 6,h
       ld a,h
       add a,a
        ret
setmemc000writec
        ld (hl),c
screeninc000_flag=$
        ret ;/nop for screen in c000
       ld a,(_logicpgc000)
;screenc000_branchvideomode
SCREENC000_VIDEOMODE_6912=0x30 ;jr nc
SCREENC000_VIDEOMODE_PROFI=0x38 ;jr c
screenc000_videomode=$
        jr nc,screenc000_profi
        bit 5,h
        jr nz,setmemc000writec_skip
        res 7,h
        call writescreen_6912
       push bc
        LD bc,(curquart)
        LD A,(bc)
        OUTPGCOM ;надо именно тут, т.к. OUTcomCY15 работает только после обращения к <0x8000
       pop bc
        set 7,h
setmemc000writec_skip
       ld a,h
       add a,a
        ret
screenc000_profi
        res 7,h
        call writescreen_profi
       push bc
        LD bc,(curquart)
        LD A,(bc)
        OUTPGCOM ;надо именно тут, т.к. OUTcomCY15 работает только после обращения к <0x8000
       pop bc
        set 7,h
       ld a,h
       add a,a
        ret
       endif
       
setmem00004000writec
;NC, keep CY (keep A for rra:ld h,a)
       if !extpg5
ROMSTATE_ON=0xf2 ;jp p
ROMSTATE_OFF=0xda ;jp c
       else
ROMSTATE_ON=0xf0 ;ret p
ROMSTATE_OFF=0xd8 ;ret c
       endif
        jp m,setmem4000writec
       if !extpg5
romstate_flag=$
       jp p,setmem00004000writec_skip
       else
romstate_flag=$
        ret p
       endif
        set 6,h
        ld a,0x3e
        ld (set4000com),a
        ld a,(emulcurpg0000) ;0000
       push bc
        OUTPG4000
       pop bc
       if extpg5
       ld (hl),c
       endif
       ld a,h
       sub 64
       add a,a
screenin0000_flag=$
        ret ;/nop for screen in 0000
;TODO write C to screen if screen in 0000
       if extpg5
       
        ret
       endif
setmem4000writec
        ld a,0x3e
        ld (set4000com),a
        ld a,(emulcurpg4000) ;4000
       push bc
        OUTPG4000
       pop bc
       if extpg5
       ld (hl),c
       endif
       ld a,h
       add a,a
screenin4000_flag=$
        ret ;/nop for screen in 4000
;CY=0
       if extpg5
       ld a,(_logicpg4000)
screen4000_branchvideomode
SCREEN4000_VIDEOMODE_6912=0x38 ;jr c
SCREEN4000_VIDEOMODE_PROFI=0x30 ;jr nc
screen4000_videomode=$
        jr c,screen4000_profi
        bit 5,h
        call z,writescreen_6912
setmem4000writec_skip
       ld a,h
       add a,a
        ret
screen4000_profi
        call writescreen_profi
       ld a,h
       add a,a
        ret
       endif

       if !extpg5
setmem00004000writec_skip
        ld h,secbuf/256
        ret
       endif

;for read
setmem00004000
        jp m,setmem4000
        set 6,h
        ld a,0x3e
        ld (set4000com),a
        ld a,(emulcurpg0000) ;0000
       push bc
        OUTPG4000
       pop bc
       ld a,h
       sub 64
       add a,a
        ret
setmem4000
        ld a,0x3e
        ld (set4000com),a
        ld a,(emulcurpg4000) ;4000
       push bc
        OUTPG4000
       pop bc
       ld a,h
       add a,a
        ret

;for PC
set4000com
        ld a,0xc9 ;/RET
        ld (set4000com),a
        LD HL,(curquart)
        LD A,(HL)
        OUTPGCOM
        ret
       
next_incd
        inc d
        ret nz
        ld d,0xc0
        ld hl,(curquart)
        inc l
        res 2,l
        ld (curquart),hl
        ld a,(hl)
        OUTPGCOM
        ret
       endif

        align 256
tprofiy
_chr=0
        dup 32
;_chr=%000YYYTT
_Y=((_chr*8)&0x18)+((_chr/4)&0x07) ;_Y=%000TTYYY
        ;db 200 ;invisible line
_egay=_Y*8;7 ;- 4
        dup 8;7
       if (_egay >= 200) || (_egay < 0)
        ;db 200 ;invisible line
        DCOM (0x4000+4+(200*40))
       else
        ;db _egay
        DCOM (0x4000+4+(_egay*40))
       endif
_egay=_egay+1
        edup
_chr=_chr+1
        edup
        ;ds (-$)&0xff,200 ;invisible line
        org $+256
        align 256
temulpgs
        ds 64 ;пока используем 8

pgrom48
        db 0
pgrom128
        db 0
pgromDOS
        db 0
pgromSYS
        db 0

curregs ;for debugger
curaf   dw 0 ;for debugger
curbc   dw 0 ;for debugger
curde   dw 0 ;for debugger
curhl   dw 0 ;for debugger
_AF     DW 0 ;AF'
_BC     DW 0 ;BC'
_DE     DW 0 ;DE'
_HL     DW 0 ;HL'
_SP     DW 0
curpc   dw 0 ;for debugger
curix   dw 0 ;for debugger
;curiy   dw 0 ;for debugger
curiy ;for debugger
_IZ     DW 0
_R      DB 0
_I      DB 0

iff1    DB 0
iff2    DB 0
immode  DB 0 ;#18=IM2, иначе IM1
_fd     DB 0;#10 ;с точки зрения эмулимой проги
_dffd   db 0
_logicpg0000 db 0 ;TODO
_logicpg4000 db 0
_logicpg8000 db 0
_logicpgc000 db 0
_fe     DB 0
dos3F   DB 0
dos5F   DB 0
dosFF   DB 0

       if margins
curquart
        DW emulcurpg0000
        align 256
       endif

;реальные банки (лежат подряд для margins)
emulcurpg4000  DB 0 ;for 4000
emulcurpg8000  DB 0 ;for 8000
emulcurpgc000  DB 0 ;for c000
emulcurpg0000  DB 0 ;for 0000

curscr  DB 0 ;0/8

;romon0  DB 0 ;#C0=ОЗУ, 0=ПЗУ в нижних 16k ;теперь в romstate
doson0  DB 0;-1 ;0=SYS/DOS, -1=48/128

loadfile_in_ahl
;de=имя файла
;[hl=куда грузим (0xc000)]
;a=в какой странице
        SETPGC000 ;включили страницу A в 0xc000
        ;push hl ;куда грузим
        OS_OPENHANDLE
        ;pop de ;куда грузим
        ;push bc ;b=handle
        ;ld hl,0x4000 ;столько грузим (если столько есть в файле)
        ;OS_READHANDLE
        ;pop bc ;b=handle
        call loadpg
        OS_CLOSEHANDLE
	ret;jp setpgmainc000 ;включили страницу программы в c000, как было

loadsnappg
;b=handle
        push bc
        SETPGC000 ;включили страницу A в 0xc000
        pop bc
loadpg
        ld de,0xc000 ;куда грузим
        ld hl,0x4000 ;столько грузим (если столько есть в файле)
        push bc ;b=handle
        OS_READHANDLE
        pop bc ;b=handle
        ret

path
        db "z80",0

diskname
        db "SYS.TRD",0
snapshotname
        db "SOLI",0
snapshotscrname
        db "ram6",0
snapshotattrname
        db "ram3a",0
snapshotram3name
        db "ram3",0
snapshotram5name
        db "ram5",0
snapshotram8name
        db "ram8",0
snapshotram9name
        db "ram9",0
snapshotramaname
        db "rama",0
        
trom48
        ;DB "2006.ROM",0
        ;DB "1982.ROM",0
        DB "48for128.rom",0
        ;DB "testatm.rom",0
trom128
        DB "128tr.rom",0
        ;DB "testatm.rom",0
tromSYS
        DB "GLUKPEN.ROM",0
        ;DB "testatm.rom",0
tromDOS
        DB "DOS6_10E.ROM",0
        ;DB "testatm.rom",0

swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int
        jp 0x0038+3

end

        align 256 ;for setmem00004000forwrite
secbuf
        ds 256
        display secbuf+256

	savebin "z80.com",begin,end-begin

	LABELSLIST "../../us/user.l"
