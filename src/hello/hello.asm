        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
begin
        ;ld e,6 ;textmode
        ;OS_SETGFX
        call initstdio
        
        ld hl,thello
        call prtext
        
        QUIT

prtext
prtext0
        ld a,(hl)
        or a
        ret z
        cp 8
        jr c,prtext_color
        push hl
        ;PRCHAR
        PRCHAR_
        pop hl
        inc hl
        jr prtext0
prtext_color
        push hl
        ld e,a
        ;OS_SETCOLOR
        ld d,0
        SETCOLOR_
        pop hl
        inc hl
        jr prtext0

thello
        db "Hello, ",3,"world!",0x0d,0x0a,0
        
        include "../_sdk/stdio.asm"
end
	savebin "hello.com",begin,end-begin

	LABELSLIST "../../us/user.l"
