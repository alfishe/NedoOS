        MACRO SETANIM n
        ld (ix+obj_anim),n
        ld (ix+obj_animcounter),1
        ld (ix+obj_animphase),0
        ENDM
        
        MACRO GETXDE_YHL
        ld e,(ix+obj_x)
        ld d,(ix+(obj_x+1))
        ld l,(ix+obj_y)
        ld h,(ix+(obj_y+1))
        ENDM
        
        MACRO PUTXDE_YHL
        ld (ix+obj_x),e
        ld (ix+(obj_x+1)),d
        ld (ix+obj_y),l
        ld (ix+(obj_y+1)),h
        ENDM

        MACRO COORDSBC_TOSCRHL
	ld a,b
	rra
	rra
	rra
	xor b
	and 0xf8
	xor b
	and 0x1f
	add a,scrbuf/256
	ld h,a
	ld a,c
	rlca
	rlca
	rlca
	xor b
	and 0xc7
	xor b
	rlca
	rlca
	ld l,a
        ENDM
        
        MACRO COORDSBC_TOSCRDE
	ld a,b
	rra
	rra
	rra
	xor b
	and 0xf8
	xor b
	and 0x1f
	add a,scrbuf/256
	ld d,a
	ld a,c
	rlca
	rlca
	rlca
	xor b
	and 0xc7
	xor b
	rlca
	rlca
	ld e,a
        ENDM
        
        MACRO CALCvalidmapaddr_hlyx_tohl
;hl=yx (в пикселях)
;%YYYYYyyy XXXXXxxx
        ld a,h
        rra
        rra
        rra
;%???YYYYY XXXXXxxx
        rra
        rr l
        rra
        rr l
        rra
        rr l
        and 0x03
        add a,validmap/256
        ld h,a
;%tttttYY YYYXXXXX
        ENDM

        MACRO CALCvalidmapaddr_bcyx_tohl
;bc=yx (в пикселях)
;%YYYYYyyy XXXXXxxx
        ld a,b
        rra
        rra
        rra
;%???YYYYY XXXXXxxx
        ld l,c
        rra
        rr l
        rra
        rr l
        rra
        rr l
        and 0x03
        add a,validmap/256
        ld h,a
;%tttttYY YYYXXXXX
        ENDM

        macro STRUCT
_=0
        endm
        macro BYTE addr
addr=_
_=_+1
        endm
        macro WORD addr
addr=_
_=_+2
        endm

        STRUCT
        WORD obj_x
        WORD obj_y
        WORD obj_objaddr
        BYTE obj_energy
        BYTE obj_dir
        BYTE obj_speed
        BYTE obj_anim
        BYTE obj_animphase
        BYTE obj_animcounter
        BYTE obj_delaycounter
        BYTE obj_gundelaycounter
objsize=_

