renderPlainTextScreen:
    call prepareScreen
    ld b, PER_PAGE
.loop
    push bc
    ld a, PER_PAGE : sub b
    
    ld b, a, e, a, a, (page_offset) : add b : ld b, a : call Render.findLine
    ld a, h : or l : jr z, .exit
    ld a, e
    add CURSOR_OFFSET : ld d, a, e, 1 : call TextMode.gotoXY
    call print70Text
    pop bc 
    djnz .loop
    ret
.exit
    pop bc
    ret

plainTextLoop:
    call Console.getC

    cp '1' : jp z, History.back
    cp '2' : jp z, navigate
    cp '5' : jp z, textUp
    cp '8' : jp z, textDown
    cp Console.KEY_LT : jp z, textUp
    cp Console.KEY_RT : jp z, textDown

    cp Console.KEY_DN : jp z, textDown
    cp 'a' : jp z, textDown

    cp Console.KEY_UP : jp z, textUp
    cp 'q' : jp z, textUp
    
    cp 'h' : jp z, History.home
    cp 'H' : jp z, History.home

    cp 'b' : jp z, History.back
    cp 'B' : jp z, History.back
    
    cp 'd' : jp z, inputHost
    cp 'D' : jp z, inputHost


    cp Console.BACKSPACE : jp z, History.back
 
    IFDEF GS
    cp 'M' : call z, GeneralSound.toggleModule
    cp 'm' : call z, GeneralSound.toggleModule
    ENDIF

    IFDEF TIMEX80
    cp 'T' : call z, TextMode.toggleColor
    cp 't' : call z, TextMode.toggleColor
    ENDIF

    jp plainTextLoop


textDown:
    ;ld a, (page_offset) : add PER_PAGE : ld (page_offset), a
    ld hl,(page_offset)
    ld de,PER_PAGE
    add hl,de
    ld (page_offset), hl
    call renderPlainTextScreen
    jp plainTextLoop

textUp:
    ;ld hl, page_offset 
    ;ld a, (hl) : and a : jp z, plainTextLoop
    ld a, (page_offset) : cp 0 : jr nz, .textUp2
    ld a, (page_offset + 1) : cp 0 : jr nz, .textUp2
    jp plainTextLoop

.textUp2:
    ld hl,(page_offset)
    ld de,PER_PAGE
    sbc hl,de
    ld (page_offset), hl
    call renderPlainTextScreen
    jp plainTextLoop    
    
/*    
    sub PER_PAGE : ld (hl), a
    call renderPlainTextScreen
    jp plainTextLoop
*/    