getword
;hl=string
;de=wordbuf
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        jr z,getwordq
        sub ' '
        jr z,getwordq
        ldi
        jp getword0
getwordq
        ;xor a
        ld (de),a
        ret

skipword
;hl=string
;out: hl=terminator/space addr
skipword0
        ld a,(hl)
        or a
        ret z ;jr z,skipwordq
        sub ' '
        ret z ;jr z,skipwordq
        inc hl ;ldi
        jr skipword0
        
skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

strcopy
;hl->de
strcopy0
        ld a,(hl)
        ldi
        or a
        jr nz,strcopy0
        ret

strcp
;hl=s1
;de=s2
;out: Z (equal, hl=terminator of s1+1, de=terminator of s2+1), NZ (not equal, hl=erroraddr in s1, de=erroraddr in s2)
strcp0.
	ld a,[de] ;s2
	cp [hl] ;s1
	ret nz
	inc hl
	inc de
	or a
	jp nz,strcp0.
	ret ;z

strlen
;hl=str
;out: hl=length
        ld bc,0 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret
