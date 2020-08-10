        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
begin
        ;ld e,6 ;textmode
        ;OS_SETGFX
        call initstdio
        
        ld hl,thello
        call prtext
        ld hl,thello
        call prtext
        ld hl,thello
        call prtext
        ld hl,thello
        call prtext
        
        QUIT

prtext
;hl=text
        push hl
        call strlen ;hl=length
        pop de ;de=text
        jp sendchars

strlen
;hl=str
;out: hl=length
        xor a
        ld b,a
        ld c,a ;чтобы точно найти терминатор
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret

thello
        ;db "Hello, world!",0x0d,0x0a,0
        db "Select drive:\r\n[0] Nemo master\r\n[1] Nemo slave\r\n[2] ATM master(not tested!)\r\n[3] ATM slave(not tested!)",0
        
        include "../_sdk/stdio.asm"
end
	savebin "hello.com",begin,end-begin

	LABELSLIST "../../us/user.l"
