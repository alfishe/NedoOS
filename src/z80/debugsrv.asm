Debugger_GetMem_hl_to_a
       push hl
        getmem;ld a,(hl)
       pop hl
        ret

Debugger_PutMem_hl_a
       push hl
        putmem;ld a,(hl)
       pop hl
        ret
