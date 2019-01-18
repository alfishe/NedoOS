_timer=23672

	org 0x6000
;startup
        xor a
        ld (_frameready),a
        
        ld hl,0x5800
        ld de,0x5801
        ld bc,767
        ld (hl),0
        ldir
        ld hl,_logo
        ld de,0x4000
        ld bc,0x1800
        ldir
        halt
        ld a,1
        out (0xfe),a
        ld bc,0x300
        ldir
        ld hl,0x5800
        ld de,_attrbuf
        ld bc,768
        ldir

        ld hl,0
        ld (_timer),hl
        ld hl,song
        call INIT
        ld a,0x18 ;jr
        ld (0xffff),a
        ld a,0xc3 ;jp
        ld (0xfff4),a
        ld hl,on_int
        ld (0xfff5),hl
        ld a,59
        ld i,a
        im 2
        
        ld hl,_netaddr
        ld de,_netaddr+1
        ld bc,0x1fff
        ld (hl),0
        ldir
        
waitstart0
        ld hl,(_timer)
        ld de,192-8
        or a
        sbc hl,de
        jr c,waitstart0
        
        xor a
        out (0xfe),a
        ld hl,0x5800
        ld de,0x5801
        ld bc,767
        ld (hl),0
        ldir
	ld hl,_attrbuf
	ld de,_attrbuf+1
	ld bc,767
	ld (hl),0
	ldir
        ;ld hl,0x4000
        ;ld de,0x4001
        ;ld bc,0x17ff
        ;ld (hl),l;0
        ;ldir
        call drawcubetexture
        ld hl,_attrbuf+(32*20)
        ld de,_attrbuf+(32*20)+1
        ld bc,32*4-1
        ld (hl),7
        ldir ;раньше нельзя
        ld hl,_attrbuf
        ld de,_attrbuf2
        ld bc,768
        ldir
waitstart1
        ld hl,(_timer)
        ld de,192-1
        or a
        sbc hl,de
        jr c,waitstart1
        jp demo ;там halt

	include "../_sdk/pt3play.i"
song
	incbin "testmusic.pt3"
font
	incbin "font.bin"
_net35
	incbin "net35.bin"
_nettort
	incbin "nettort.bin"
	include "demo.asm"
	include "demo.var"
	include "demoproc.s"
	include "../_sdk/lib.i"
_logo
	incbin "logo" ;must be last
