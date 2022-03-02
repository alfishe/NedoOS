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

Debugger_set7ffd
        ld a,(_fd)
        jp eout7FFD ;не будет проблем с de и 0x4000?

