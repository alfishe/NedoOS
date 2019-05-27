getkey
;TODO через OS_GETKEYMATRIX
;out: c=%???lrduf (0=нажато)
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
      
