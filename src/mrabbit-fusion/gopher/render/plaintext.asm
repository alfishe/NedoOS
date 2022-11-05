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

    cp '6' : jp z, cursorDown
    cp '3' : jp z, cursorDown
    cp '4' : jp z, cursorUp
    cp '7' : jp z, cursorUp
    cp '5' : jp z, navigate
    cp '1' : jp z, History.back

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
    ld a, (page_offset) : add PER_PAGE : ld (page_offset), a
    call renderPlainTextScreen
    jp plainTextLoop

textUp:
    ld hl, page_offset 
    ld a, (hl) : and a : jp z, plainTextLoop
    sub PER_PAGE : ld (hl), a
    call renderPlainTextScreen
    jp plainTextLoop
    