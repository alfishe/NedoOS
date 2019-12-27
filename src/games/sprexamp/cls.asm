cls
        call setpgsscr40008000
        ld ix,scrbase+clswid
        call CLSlayer
        ld ix,scrbase+0x4000+clswid
        call CLSlayer
        ld ix,scrbase+0x2000+clswid
        call CLSlayer
        ld ix,scrbase+0x6000+clswid
        ld hl,setpgsmain40008000
        push hl
CLSlayer
	LD (CLSlayerSP),SP
        LD bc,40
        ld d,b
        ld e,b
	LD a,clshgt
CLSlayer0
	LD SP,ix
	dup clswid/2-1
        push de
        edup
        ld (ix-(clswid-1)),d
        ld (ix-clswid),e
        add ix,bc
        dec a
	jr nz,CLSlayer0
CLSlayerSP=$+1
        ld sp,0
        ret
