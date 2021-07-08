DEBUGGER_REGSY=0
DEBUGGER_REGSX=0
DEBUGGER_DISASMY=0
DEBUGGER_DISASMX=8
DEBUGGER_MEMY=0
DEBUGGER_MEMX=0x2b
DEBUGGER_MEMLINES=24
DEBUGGER_DISASMLINES=24
DEBUGGER_REGSLINES=13

Debugger
        ld e,6+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS

        call Debugger_Redraw
Debugger0
        call Debugger_drawcursor
        YIELDGETKEYLOOP
        push af
        call Debugger_undrawcursor
        pop af
        cp key_esc
        jr z,DebuggerQuit

        ld hl,Debugger0
        push hl
        cp key_pgup
        jr z,DebuggerPgUp
        cp key_pgdown
        jr z,DebuggerPgDown
        cp key_up
        jr z,DebuggerUp
        cp key_down
        jr z,DebuggerDown
        cp key_left
        jp z,DebuggerLeft
        cp key_right
        jp z,DebuggerRight
        cp key_tab
        jp z,DebuggerTab
        cp '0'
        ret c
        cp '9'+1
        jr c,DebuggerDigit
        cp 'a'
        ret c
        cp 'f'+1
        ret nc
        sub 'a'-('9'+1)
DebuggerDigit
        sub '0'
        call Debugger_editaddr
        jp Debugger_Redraw

DebuggerQuit
        ld a,(oldcurvideomode)
        call setvideomode
        ld a,(oldcurscr7ffd)
        call setscreen
;TODO wait key unpress
        ret

DebuggerUp
        call Debugger_decy ;m=overflow
        ret p
;TODO scroll
        call Debugger_getcuraddr16_de
        ld hl,-8
        add hl,de
        call Debugger_putcuraddr16_hl
        jp Debugger_Redraw
DebuggerDown
        call Debugger_incy ;z=overflow
        ret nz
;TODO scroll (use nextaddr16)
        call Debugger_getcuraddr16_de
        ld hl,8
        add hl,de
        call Debugger_putcuraddr16_hl
        jp Debugger_Redraw

DebuggerTab
        call Debugger_inctab
        jp Debugger_Redraw

DebuggerPgUp
        call Debugger_getcuraddr16_de
        ld a,(debugger_curtab)
        dec a
        ld hl,-(DEBUGGER_MEMLINES*8)
        jr nz,$+5
        ld hl,-DEBUGGER_MEMLINES
        add hl,de
        call Debugger_putcuraddr16_hl
        jp Debugger_Redraw

DebuggerPgDown
        call Debugger_getnextaddr16_de
        ex de,hl
        call Debugger_putcuraddr16_hl
        jp Debugger_Redraw

Debugger_undrawcursor
        ld c,0x0f;0x07
        jr Debugger_drawcursor_colorc
Debugger_drawcursor
        ld c,0x38
Debugger_drawcursor_colorc
        call Debugger_getcurxy_de_widb
        ld l,c
drawcursor_sizeb0
        push bc
        push de
        push hl ;color
        OS_SETXY
        pop de ;color
        push de ;color
        OS_PRATTR
        pop hl ;color
        pop de
        pop bc
        inc e ;x
        djnz drawcursor_sizeb0
        ret


Debugger_editbyte_c_keya
hexeditor_half=$
        or a ;/scf
        jr c,hexeditor_symbol_right
        add a,a
        add a,a
        add a,a
        add a,a;a=XXXX0000
        xor c
        and 0xf0
        jr hexeditor_symbol_rightq
hexeditor_symbol_right
        xor c
        and 0x0f
hexeditor_symbol_rightq
        xor c
        ld c,a
        ld a,(hexeditor_half)
        xor 0x80
        ld (hexeditor_half),a
        ret

Debugger_editaddr
       ld lx,a
        call Debugger_getcurxypos_de
        ld a,(debugger_curtab)
        dec a
        jr z,Debugger_calcaddr_disasm
        jp p,Debugger_calcaddr_mem
        ld hl,curregs
        ld a,d
        add a,a
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        dec e
        jr z,$+3
        inc hl
       ld a,lx
        ld c,(hl) ;
        call Debugger_editbyte_c_keya
        ld (hl),c
        ret
Debugger_calcaddr_disasm
       ld a,e
       or a
       ret z ;TODO edit addr
       dec e
       cp 4
       ret nc ;TODO edit asm
        ld hl,(debugger_curdisasmaddr)
       push de
        ld a,d
        or a
        jr z,Debugger_calcaddr_disasm0q
Debugger_calcaddr_disasm0
        push hl
        call Disasm_GetCmdLen_bc
        pop hl
        add hl,bc
        dec d
        jr nz,Debugger_calcaddr_disasm0
Debugger_calcaddr_disasm0q
       pop de
       ld d,0
       add hl,de
;TODO проверить длину и не редактировать невидимые байты (которые e>=len)
        jr Debugger_editaddr_inmem
Debugger_calcaddr_mem
       ld a,e
       or a
       ret z ;TODO edit addr
       dec e
       cp 9
       ret nc ;TODO edit text
        ld l,d
        ld h,0
        ld d,h;0
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,de
        ld de,(debugger_curmemaddr)
        add hl,de
Debugger_editaddr_inmem
        call Debugger_GetMem_hl_to_a
        ld c,a
       ld a,lx
        call Debugger_editbyte_c_keya
        ld a,c
        jp Debugger_PutMem_hl_a

Debugger_Redraw
        ;ld de,0x0000
        ;OS_SETXY
        ;ld hl,tdebugger
        ;call Debugger_PrText
        ld a,(debugger_curtab)
        or a
        call Debugger_setcolorz
        ld de,DEBUGGER_REGSY*256+DEBUGGER_REGSX
        call Debugger_PrRegs

        ld a,(debugger_curtab)
        cp 1
        call Debugger_setcolorz
        ld hl,(debugger_curdisasmaddr)
        ld de,DEBUGGER_DISASMY*256+DEBUGGER_DISASMX
        call Debugger_Disasm_hl

        ld a,(debugger_curtab)
        cp 2
        call Debugger_setcolorz
        ld hl,(debugger_curmemaddr)
        ld de,DEBUGGER_MEMY*256+DEBUGGER_MEMX
        call Debugger_PrMem_hl

        ld e,0x07
        OS_SETCOLOR
        ret

Debugger_setcolorz
        ld e,0x0f
        jr z,$+4
        ld e,0x07
        OS_SETCOLOR
        ret

Debugger_PrRegs
        ld bc,tregs
        ld hl,curregs
Debugger_PrRegs0
        ld a,(bc)
        or a
        jr z,Debugger_PrRegs0q
      push de
       push hl
        push bc
        OS_SETXY
        pop bc
        call Debugger_PrChar_bc
        call Debugger_PrChar_bc
        call Debugger_PrChar_bc
       pop hl
        ld e,(hl)
        inc hl
       ;push hl
        ld d,(hl)
        ;push bc
        call Debugger_PrWord_de
        ;pop bc
       ;pop hl
        inc hl
      pop de
        inc d
        jr Debugger_PrRegs0
Debugger_PrRegs0q
        OS_SETXY
        ld a,(curaf) ;flags
        ld hl,tflags
        scf
Debugger_PrFlags0
        adc a,a
        ret z
        push af
        ld a,(hl)
        inc hl
        jr c,Debugger_PrFlags_nooff
        add a,0x20
        cp 'a'
        jr nc,Debugger_PrFlags_nooff
        ld a,'.'
Debugger_PrFlags_nooff
        call Debugger_PrChar
        pop af
        or a
        jr Debugger_PrFlags0
tflags
        db "SZ5H3PNC"

Debugger_PrMem_hl
        ld b,DEBUGGER_MEMLINES
Debugger_PrMem0
        push bc
        push de
        push hl
        OS_SETXY
        pop hl
        call Debugger_PrMemLine_hl
        pop de
        inc d
        pop bc
        djnz Debugger_PrMem0
        ld (debugger_nextmemaddr),hl
        ret
        
Debugger_PrMemLine_hl ;return hl = hl+8
        push hl
        ex de,hl
        call Debugger_PrWord_de
        call Debugger_PrSpace
        pop hl
        push hl
        ld b,8
Debugger_PrMemLine0
        push bc
        call Debugger_GetMem_hl_to_a
        inc hl
        ;push hl
        call Debugger_PrHex_a
        call Debugger_PrSpace
        ;pop hl
        pop bc
        djnz Debugger_PrMemLine0
        pop hl
        ld b,8
Debugger_PrMemLine1
        push bc
        call Debugger_GetMem_hl_to_a
        inc hl
        ;push hl
       ld bc,t866toatm+'?'
       cp 0x0d
       jr z,Debugger_PrMemLine_skipchar
       cp 0x0a
       jr z,Debugger_PrMemLine_skipchar
       cp 0x08
       jr z,Debugger_PrMemLine_skipchar
       cp 0x09
       jr z,Debugger_PrMemLine_skipchar
       ld c,a
Debugger_PrMemLine_skipchar
       ld a,(bc)
        call Debugger_PrChar
        ;pop hl
        pop bc
        djnz Debugger_PrMemLine1
        ret

Debugger_Disasm_hl
        ld b,DEBUGGER_DISASMLINES
Debugger_Disasm0
        push bc
        push de
        push hl
        OS_SETXY
        pop hl
        call Debugger_DisasmLine_hl
        pop de
        inc d
        pop bc
        djnz Debugger_Disasm0
        ld (debugger_nextdisasmaddr),hl
        ret
        
Debugger_DisasmLine_hl ;return hl = next cmd
       push hl
       ld (disasmcmdaddr),hl
        ld d,h
        ld e,l
        call Debugger_PrWord_de
        call Debugger_PrSpace
        call Disasm_GetCmdLen_bc
        
       push bc

       push hl
        ld b,4
Debugger_DisasmLine_hl0
;4-b = n = номер печатаемого байта
       ld a,4
       sub b
;n >= c печатать нельзя, вместо этого пробелы
       cp c
        ld a,(hl)
        inc hl
        jr c,Debugger_DisasmLine_hl_nospaces
        call Debugger_PrSpace
        call Debugger_PrSpace
        or a
Debugger_DisasmLine_hl_nospaces
        call c,Debugger_PrHex_a
        djnz Debugger_DisasmLine_hl0
        
        ld hl,disasmtextbuf
       push hl
        ld de,disasmtextbuf+1
        ld bc,disasmtextbuf_sz-1
        ld (hl),' '
        ldir
       pop ix
        
       pop hl ;cmdbuf       
        call Disasm_COMMAND
        
        ld hl,disasmtextbuf
        ld b,disasmtextbuf_sz
Debugger_DisasmLine_pr0
        ld a,(hl)
        inc hl
        call Debugger_PrChar
        djnz Debugger_DisasmLine_pr0
       
       pop bc
       pop hl
        add hl,bc
        ret

Disasm_GetCmdLen_bc
        ld de,disasmcmdbuf
       push de
        call Debugger_CopyMem_hl_to_de_4bytes
       pop hl
        call Disasm_LEN ;keep hl ;return b=len
        LD A,B
        DEC A
        CP 4
        JR C,$+4
         LD B,1 ;если много префиксов, оставляем один
        ld c,b
        ld b,0
        ret

Debugger_CopyMem_hl_to_de_4bytes
        call Debugger_CopyMem_hl_to_de_2bytes
Debugger_CopyMem_hl_to_de_2bytes
        call Debugger_CopyMem_hl_to_de
Debugger_CopyMem_hl_to_de
        call Debugger_GetMem_hl_to_a
        ld (de),a
        inc hl
        inc de
        ret

disasmcmdbuf
        ds 4
disasmtextbuf
        ds 21
disasmtextbuf_sz=$-disasmtextbuf

Debugger_PrText
        ld a,(hl)
        inc hl
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        jr Debugger_PrText
        
Debugger_PrChar_bc
        ld a,(bc)
        inc bc
        jr Debugger_PrChar

Debugger_PrWord_de
;de=word
        ld a,d
        call Debugger_PrHex_a
        ld a,e
Debugger_PrHex_a
        push af
        rra
        rra
        rra
        rra
        call Debugger_PrHexDig
        pop af
Debugger_PrHexDig
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
Debugger_PrChar
       push bc
       push de
       push hl
        PRCHAR
       pop hl
       pop de
       pop bc
        ret

Debugger_PrSpace
        ld a,' '
        jr Debugger_PrChar
        
tregs
        db "af:"
        db "bc:"
        db "de:"
        db "hl:"
        db "af'"
        db "bc'"
        db "de'"
        db "hl'"
        db "sp:"
        db "pc:"
        db "ix:"
        db "iy:"
        db "ir:"
        db 0
        
;tdebugger
;        db "Debugger",0

Debugger_inctab
        ld hl,debugger_curtab
        inc (hl)
        ld a,(hl)
        sub 3
        ret nz
        ld (hl),a
        ret

Debugger_getcuraddr16_de
        call Debugger_getcurtab_hl_curaddr16_a_ys_d_y
        ld e,(hl)
        inc hl
        ld d,(hl) ;curaddr16
        ret
Debugger_putcuraddr16_hl
        push hl
        call Debugger_getcurtab_hl_curaddr16_a_ys_d_y
        pop de
        ld (hl),e
        inc hl
        ld (hl),d ;curaddr16
        ret

Debugger_getnextaddr16_de
        call Debugger_getcurtab_hl_cury_a_ys_d_y
        dec hl
        ld d,(hl)
        dec hl
        ld e,(hl) ;nextaddr16
        ret
Debugger_putnextaddr16_hl
        push hl
        call Debugger_getcurtab_hl_cury_a_ys_d_y
        pop de
        dec hl
        ld (hl),d
        dec hl
        ld (hl),e ;nextaddr16
        ret

Debugger_getcurtab_hl_curaddr16_a_ys_d_y
        ld a,(debugger_curtab)
;Debugger_getatab_hl_curaddr16_a_ys_d_y
        add a,a
        ld hl,tdebuggertabs
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl=tab
        ld d,(hl) ;y
        inc hl
        ld a,(hl) ;ys
        inc hl
        ret

Debugger_getcurtab_hl_cury_a_ys_d_y
        ;ld a,(debugger_curtab)
;Debugger_getatab_hl_cury_a_ys_d_y
        ;call Debugger_getatab_hl_curaddr16_a_ys_d_y
        call Debugger_getcurtab_hl_curaddr16_a_ys_d_y
        inc hl ;
        inc hl ;skip curaddr16
        inc hl ;
        inc hl ;skip nextaddr16
        ret

Debugger_incy
;z=overflow
        call Debugger_getcurtab_hl_cury_a_ys_d_y 
        inc (hl) ;cury
        cp (hl)
        ret nz
        dec (hl);ld (hl),0 ;TODO scroll
        xor a ;z
        ret

Debugger_decy
;m=overflow
        call Debugger_getcurtab_hl_cury_a_ys_d_y 
        dec a
        dec (hl) ;cury
        ret p
        inc (hl);ld (hl),a ;TODO scroll
        xor a
        dec a ;m
        ret

Debugger_incx
        call Debugger_getcurtab_hl_cury_a_ys_d_y 
        inc hl ;skip cury
        ld a,(hl) ;xs
        inc hl
        inc (hl) ;curx
        cp (hl)
        ret nz
        ld (hl),0
        ret

Debugger_decx
        call Debugger_getcurtab_hl_cury_a_ys_d_y 
        inc hl ;skip cury
        ld a,(hl) ;xs
        inc hl
        dec a
        dec (hl) ;curx
        ret p
        ld (hl),a
        ret

Debugger_getcurxy_de_widb
        call Debugger_getcurtab_hl_cury_a_ys_d_y 
        ld a,d
        add a,(hl) ;cury
        ld d,a
        inc hl
        inc hl ;skip xs
        ld a,(hl) ;curx
        inc hl
        add a,a
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        ld e,(hl)
        inc hl
        ld b,(hl)
        ret

Debugger_getcurxypos_de
        call Debugger_getcurtab_hl_cury_a_ys_d_y 
        ld d,(hl) ;cury
        inc hl
        inc hl ;skip xs
        ld e,(hl) ;curx
        ret

debugger_curtab ;regs, disasm, mem
        db 0
tdebuggertabs
        dw tdebuggertab_regs
        dw tdebuggertab_disasm
        dw tdebuggertab_mem
;y,ys
;curaddr16
;nextaddr16
;cury
;xs
;curx
;x0,x0wid,x1,x1wid,...
tdebuggertab_regs
        db DEBUGGER_REGSY,DEBUGGER_REGSLINES
        dw 0,0
        db 0
        db 2
        db 0
        db DEBUGGER_REGSX+3,2
        db DEBUGGER_REGSX+5,2
tdebuggertab_disasm
        db DEBUGGER_DISASMY,DEBUGGER_DISASMLINES
debugger_curdisasmaddr
        dw 0
debugger_nextdisasmaddr
        dw 0
        db 0
        db 6
        db 0
        db DEBUGGER_DISASMX,4
        db DEBUGGER_DISASMX+5,2
        db DEBUGGER_DISASMX+7,2
        db DEBUGGER_DISASMX+9,2
        db DEBUGGER_DISASMX+11,2
        db DEBUGGER_DISASMX+13,disasmtextbuf_sz
tdebuggertab_mem
        db DEBUGGER_MEMY,DEBUGGER_MEMLINES
debugger_curmemaddr
        dw 0
debugger_nextmemaddr
        dw 0
        db 0
        db 1+8+8;3
        db 0
        db DEBUGGER_MEMX,4
        ;db DEBUGGER_MEMX+5,8*3-1
        ;db DEBUGGER_MEMX+5+(8*3),8
_=DEBUGGER_MEMX+5
       dup 8
        db _,2
_=_+3
       edup
       dup 8
        db _,1
_=_+1
       edup

DebuggerLeft=Debugger_decx
DebuggerRight=Debugger_incx
