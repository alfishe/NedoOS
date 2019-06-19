getkey
;out: c=%???lrduf (0=нажато)
;fire = A
        if 1==1
        OS_GETKEYMATRIX ;out: bcdehlix = полуряды cs...space
        xor a
	bit 4,e ;5
	jr z,$+3
	inc a ;Left
	add a,a
	bit 2,h ;8
	jr z,$+3
	inc a ;Right
	add a,a
	bit 4,h ;6
	jr z,$+3
	inc a ;Down
	add a,a
	bit 3,h ;7
	jr z,$+3
	inc a ;Up
	rr c ;'a'
	rla ;fire
        ld c,a
        ret
        
        else
        
        ld c,#ff
        ld a,#ef
        in a,(#fe) ;'0'..'6'
        rra ;'0'
        jr c,$+4
        res 0,c ;f
        rra
        rra ;'8'
        jr c,$+4
        res 3,c ;r
        rra ;'7'
        jr c,$+4
        res 1,c ;u
        rra ;'6'
        jr c,$+4
        res 2,c ;d
        ld a,#f7
        in a,(#fe) ;'1'..'5'
        bit 4,a ;'5'
        jr nz,$+4
        res 4,c ;l
        ld a,#7f
        in a,(#fe) ;
        rra ;' '
        ret c
        res 0,c ;f
        ret
        endif
