DEBUGGER_MEMLINES=24

Debugger
        ld e,6+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS

        call Debugger_Redraw
Debugger0
        YIELDGETKEYLOOP
        cp key_esc
        jr z,DebuggerQuit

        ld hl,Debugger0
        push hl
        cp key_pgup
        jr z,DebuggerPgUp
        cp key_pgdown
        jr z,DebuggerPgDown
        ret

DebuggerQuit
        ld a,(oldcurvideomode)
        call setvideomode
        ld a,(oldcurscr7ffd)
        call setscreen
;TODO wait key unpress
        ret

DebuggerPgUp
DebuggerPgDown
        ld hl,(debugger_curmemaddr)
        ld bc,DEBUGGER_MEMLINES*8
        add hl,bc
        ld (debugger_curmemaddr),hl
        ld (debugger_curdisasmaddr),hl
        jp Debugger_Redraw

Debugger_Redraw
        ld de,0x0000
        OS_SETXY
        ld hl,tdebugger
        call Debugger_PrText
        ld de,0x0100
        call Debugger_PrRegs
debugger_curmemaddr=$+1
        ld hl,0
        ld de,0x0108
        call Debugger_PrMem_hl
debugger_curdisasmaddr=$+1
        ld hl,0
        ld de,0x012e
        call Debugger_Disasm_hl
        ret

Debugger_PrRegs
        ld bc,tregs
        ld hl,curregs
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
       push hl
        ld d,(hl)
        push bc
        call Debugger_PrWord_de
        pop bc
       pop hl
        inc hl
      pop de
        inc d
        jr Debugger_PrRegs0

Debugger_PrMem_hl
        ld b,24
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
        ret
        
Debugger_PrMemLine_hl ;return hl = hl+8
        push hl
        ex de,hl
        call Debugger_PrWord_de
        ld a,' '
        PRCHAR
        pop hl
        push hl
        ld b,8
Debugger_PrMemLine0
        push bc
        call Debugger_GetMem_hl_to_a
        inc hl
        push hl
        call Debugger_PrHex_a
        ld a,' '
        PRCHAR
        pop hl
        pop bc
        djnz Debugger_PrMemLine0
        pop hl
        ld b,8
Debugger_PrMemLine1
        push bc
        call Debugger_GetMem_hl_to_a
        inc hl
        push hl
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
        PRCHAR
        pop hl
        pop bc
        djnz Debugger_PrMemLine1
        ret

Debugger_Disasm_hl
        ld b,24
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
        ret
        
Debugger_DisasmLine_hl ;return hl = next cmd
       push hl
       ld (disasmcmdaddr),hl
        ld d,h
        ld e,l
        call Disasm_PrWord_de
        call Disasm_PrSpace
        ld de,disasmlinebuf
       push de
        call Debugger_CopyMem_hl_to_de
        call Debugger_CopyMem_hl_to_de
        call Debugger_CopyMem_hl_to_de
        call Debugger_CopyMem_hl_to_de
       pop hl
        call Disasm_LEN ;keep hl ;return b=len
        LD A,B
        DEC A
        CP 4
        JR C,$+4
        LD B,1 ;если много префиксов, оставляем один

        ld c,b
        ld b,0
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
        call Disasm_PrSpace
        call Disasm_PrSpace
        or a
Debugger_DisasmLine_hl_nospaces
        call c,Disasm_PrHex_a
        djnz Debugger_DisasmLine_hl0
       pop hl
       
        call Disasm_COMMAND
;TODO печатать пробелы после команды
       
       pop bc
       pop hl
        add hl,bc
        ret

Debugger_CopyMem_hl_to_de
        call Debugger_GetMem_hl_to_a
        ld (de),a
        inc hl
        inc de
        ret

disasmlinebuf
        ds 4

Debugger_GetMem_hl_to_a
       push hl
        getmem;ld a,(hl)
       pop hl
        ret

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
        push bc
        PRCHAR
        pop bc
        ret

Debugger_PrWord_de
Disasm_PrWord_de
;de=word
;used in disasm!
        ;push de
        ld a,d
        call Debugger_PrHex_a
        ;pop de
        ld a,e
Debugger_PrHex_a
Disasm_PrHex_a
;used in disasm!
        push af
        rra
        rra
        rra
        rra
        call Disasm_PrHexDig
        pop af
Disasm_PrHexDig
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
Disasm_PrChar
       push bc
       push de
       push hl
        PRCHAR
       pop hl
       pop de
       pop bc
        ret
Disasm_PrSpace
        ld a,' '
        jr Disasm_PrChar
        
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
        
tdebugger
        db "Debugger",0
