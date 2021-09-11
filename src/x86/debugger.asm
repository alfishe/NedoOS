MAXCMDBYTES=10

DEBUGGER_MEMLINES=12;24
DEBUGGER_DISASMLINES=13;24
DEBUGGER_REGSLINES=15;13
DEBUGGER_REGSY=0
DEBUGGER_REGSX=0
DEBUGGER_FLAGSY=DEBUGGER_REGSY+DEBUGGER_REGSLINES
DEBUGGER_FLAGSX=DEBUGGER_REGSX
DEBUGGER_DISASMY=0
DEBUGGER_DISASMX=9;8
DEBUGGER_MEMY=13;0
DEBUGGER_MEMX=15;0x2b

DEBUGGER_COLORACTIVE=0x0f
DEBUGGER_COLOR=0x07
DEBUGGER_COLORCURSOR=0x38

Debugger
        ld e,6+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0
        OS_SETSCREEN
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
        cp key_enter
        jp z,DebuggerEnter
        call Debugger_edit
        jp Debugger_Redraw

DebuggerQuit
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

DebuggerEnter
        ld a,(debugger_curtab)
        dec a
        ret nz
        call Debugger_getcurxypos_de
        ld a,e
        cp 5
        ret nz
        
        ld hl,(debugger_curdisasmaddr) ;TODO current line
      push hl
        ;call Debugger_GetCmd_to_disasmcmdbuf
        call Debugger_Disasm_hl_to_textbuf
        
        ld e,DEBUGGER_COLORACTIVE
        OS_SETCOLOR
        call Debugger_getcurxy_de_widb
        ld hl,disasmtextbuf
        call EditLine_xyde_widb
        
        ld de,disasmtextbuf
        ld hl,asmcmdbuf;disasmcmdbuf
;de=cmd text
;hl=code generated ;out: after the code
;out: NZ=error
        xor a;call asmcmd ;TODO

        ld e,2
        jr nz,DebuggerEnter_error
        ld e,0
DebuggerEnter_error
       push hl
        OS_SETBORDER
       pop hl ;after the code
        ld de,asmcmdbuf;disasmcmdbuf
        ld a,l
        sub e
     pop hl ;hl=(debugger_curdisasmaddr)+
        jr z,DebuggerEnter_nocmd
        ld b,a ;b=generated code len
        ;de=disasmcmdbuf
DebuggerEnter_writecmd0
        push bc
        ld a,(de)
        inc de
        call Debugger_PutMem_hl_a
        inc hl
        pop bc
        djnz DebuggerEnter_writecmd0
DebuggerEnter_nocmd
        jp Debugger_Redraw

Debugger_undrawcursor
        ld c,DEBUGGER_COLORACTIVE;0x0f;0x07
        jr Debugger_drawcursor_colorc
Debugger_drawcursor
        ld c,DEBUGGER_COLORCURSOR;0x38
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
       if 1
        sla c
        sla c
        sla c
        sla c
        or c
        ld c,a
       else
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
       endif
        ret

countdigit
;C=error
        cp '0'
        ret c
        cp '9'+1
        jr c,DebuggerDigit
        cp 'a'
        ret c
        cp 'f'+1
        ccf
        ret c
        sub 'a'-('9'+1)
DebuggerDigit
        sub '0'
        ret

Debugger_edit
       ld lx,a
        call Debugger_getcurxypos_de
        ld a,(debugger_curtab)
        dec a
        jr z,Debugger_edit_disasm
        jp p,Debugger_edit_mem
        ld hl,_AX;curregs
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
        call countdigit ;C=error
        ret c
        ld c,(hl) ;
        call Debugger_editbyte_c_keya
        ld (hl),c
        ret
Debugger_edit_disasm
       ld a,e
       or a
       jr z,Debugger_edit_disasm_newaddr
       dec e
       cp 1+4
       ret nc ;TODO edit asm
        ld hl,(debugger_curdisasmaddr)
       push de ;e=x
        ld a,d ;y
        or a
        jr z,Debugger_edit_disasm0q
Debugger_edit_disasm0
        push de
        push hl
        ;call Debugger_GetCmd_to_disasmcmdbuf
        ;ld hl,disasmcmdbuf
        call Disasm_GetCmdLen_bc
        pop hl
        pop de
        add hl,bc
        dec d
        jr nz,Debugger_edit_disasm0
Debugger_edit_disasm0q
       pop de ;e=x
       ld d,0
       add hl,de
;TODO проверить длину и не редактировать невидимые байты (которые e>=len)
        jr Debugger_edit_inmem
Debugger_edit_disasm_newaddr
        xor a
        ld (debugger_curdisasmy),a
        ld hl,debugger_curdisasmaddr
        jr Debugger_edit16bit
Debugger_edit_mem
       ld a,e
       or a
       jr z,Debugger_edit_mem_newaddr
       dec e
       sub 9
       jr nc,Debugger_edit_mem_edittext
        call Debugger_memaddr_from_de
Debugger_edit_inmem
        call Debugger_GetMem_hl_to_a
        ld c,a
       ld a,lx
        call countdigit ;C=error
        ret c
        call Debugger_editbyte_c_keya
        ld a,c
        jp Debugger_PutMem_hl_a
Debugger_edit_mem_newaddr
        xor a
        ld (debugger_curmemy),a
        ld hl,debugger_curmemaddr
Debugger_edit16bit
        ld a,lx
        call countdigit ;C=error
        ret c
        ld c,a
        ld a,(hl)
        inc hl
       dup 4
        add a,a
        rl (hl)
       edup
        dec hl
        or c
        ld (hl),a
        ret
Debugger_edit_mem_edittext
        ld e,a
        call Debugger_memaddr_from_de
        ld a,lx
        ld (hl),a
        ret

Debugger_memaddr_from_de
        ld l,d
        ld h,0
        ld d,h;0
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,de
        ld de,(debugger_curmemaddr)
        add hl,de
        ret

Debugger_Redraw
        ;ld de,0x0000
        ;OS_SETXY
        ;ld hl,tdebugger
        ;call Debugger_PrText
        xor a
        call Debugger_setcolorz
        ld de,DEBUGGER_REGSY*256+DEBUGGER_REGSX
        call Debugger_PrRegs
        
        call Debugger_setcolor_normal
        ld de,DEBUGGER_FLAGSY*256+DEBUGGER_FLAGSX
        call Debugger_PrFlags

        ld a,1
        call Debugger_setcolorz
        ld hl,(debugger_curdisasmaddr)
        ld de,DEBUGGER_DISASMY*256+DEBUGGER_DISASMX
        call Debugger_Disasm_hl

        ld a,2
        call Debugger_setcolorz
        ld hl,(debugger_curmemaddr)
        ld de,DEBUGGER_MEMY*256+DEBUGGER_MEMX
        call Debugger_PrMem_hl

        jr Debugger_setcolor_normal

Debugger_setcolorz
        ld hl,debugger_curtab
        cp (hl)
        ld e,DEBUGGER_COLORACTIVE;0x0f
        jr z,$+4
Debugger_setcolor_normal
        ld e,DEBUGGER_COLOR;0x07
        OS_SETCOLOR
        ret

Debugger_PrRegs
        ld bc,tregs
        ld hl,_AX;curregs
Debugger_PrRegs0
        ld a,(bc)
        or a
        ret z
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

Debugger_PrFlags
        OS_SETXY
        ld a,(curflags) ;flags
        ld c,a
       ;call getflags_bc
        ld hl,tflags
        scf
Debugger_PrFlags0
        rl c
        ret z
        ld a,(hl)
        inc hl
        jr c,Debugger_PrFlags_nooff
        add a,0x20
        cp 'a'
        jr nc,Debugger_PrFlags_nooff
        ld a,'.'
Debugger_PrFlags_nooff
        call Debugger_PrChar
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
       jr c,Debugger_PrMemLine_prchar ;неполная таблица
       ld c,a
Debugger_PrMemLine_skipchar
       ld a,(bc)
Debugger_PrMemLine_prchar
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
        ld d,h
        ld e,l
        call Debugger_PrWord_de
        call Debugger_PrSpace
        ;call Debugger_GetCmd_to_disasmcmdbuf
        ;ld hl,disasmcmdbuf
        push hl
        call Disasm_GetCmdLen_bc
        pop hl
        
       push bc

       push hl
        ld b,MAXCMDBYTES;10
Debugger_DisasmLine_hl0
;MAXCMDBYTES-b = n = номер печатаемого байта
       ld a,MAXCMDBYTES
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
       pop hl

        call Debugger_Disasm_hl_to_textbuf
        
        ld hl,disasmtextbuf
        ld b,disasmtextbuf_sz
        call Debugger_PrChars_hl_b
       
       pop bc
       pop hl
        add hl,bc
        ret

Debugger_PrChars_hl_b
Debugger_DisasmLine_pr0
        ld a,(hl)
        inc hl
        call Debugger_PrChar
        djnz Debugger_DisasmLine_pr0
        ret

Debugger_Disasm_hl_to_textbuf
       push hl
        ld hl,disasmtextbuf
       push hl
        ld de,disasmtextbuf+1
        ld bc,disasmtextbuf_sz-1
        ld (hl),' '
        ldir
       pop ix
       pop hl
        ;ld hl,disasmcmdbuf;pop hl ;cmdbuf       
        jp Disasm_COMMAND

Disasm_COMMAND
;hl=addr
        ld (_param_ip),hl
       ld hl,disasmtextbuf
       ld (video_cursor),hl
        jp decode_line ;addr=(_param_ip)

Disasm_GetCmdLen_bc
;hl=addr
        ld (_param_ip),hl
       push hl
       ld hl,disasmtextbuf
       ld (video_cursor),hl
        call decode_line
        ;call read
       pop bc
        ld hl,(_param_ip)
        or a
        sbc hl,bc
        ld b,h
        ld c,l
        ret

asmcmdbuf
        ds MAXCMDBYTES;4
disasmtextbuf
        ds 40;21
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
        db "ax:"
        db "cx:"
        db "dx:"
        db "bx:"
        db "sp:"
        db "bp:"
        db "si:"
        db "di:"
        db "es:"
        db "cs:"
        db "ds:"
        db "es:"
        db "fs:"
        db "gs:"
        db "pc:"
        db 0
        
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
        ;dec a
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
        db 1
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
debugger_curdisasmy
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
debugger_curmemy
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
