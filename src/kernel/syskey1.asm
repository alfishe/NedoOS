KEYQUEUEINCHL
        INC HL
        LD A,L
        CP tkeyqueueend&0xff
        RET NZ
        LD HL,tkeyqueue
        RET 
        
tkeyqueue
        DS 4*keyqueuemax
tkeyqueueend

        if 1==0
PEEKKEY
        LD A,(keyqueueN)
        OR A
        ld h,a
        RET Z ;a=NOKEY, h=0
        LD HL,(keyqueuetail)
        LD a,(HL)
        INC HL
        LD h,(HL)
        ret
        endif
        
GETKEY
;out: ha=key (NOKEY=none), bc=keynolang keeps de,l
;H0=1 for control codes, H0=0 for symbols
;TODO add somewhere in H bits for keyboard register
        LD A,(keyqueueN)
        OR A
        ld h,a
         ld b,a
         ld c,a
        RET Z ;a=NOKEY, h=0, bc=0
        PUSH de
        PUSH HL
keyqueuetail=$+1
        LD HL,tkeyqueue
;2 bytes with language
;2 bytes without language
        LD e,(HL)
        INC HL
        LD d,(HL) ;keylang
        CALL KEYQUEUEINCHL
        LD c,(HL)
        INC HL
        LD b,(HL) ;keynolang
        CALL KEYQUEUEINCHL
        LD (keyqueuetail),HL
        LD HL,keyqueueN
        DEC (HL) ;atomic!!! (or we can miss keyqueueN increase)
                 ;after reading!!! (or it might be overwritten while reading)
        POP HL
        ld h,d ;keylang HSB
        ld a,e ;keylang LSB
        pop de
        RET 

KEY_PUTREDRAW
;clear jeyboard queue
        call GETKEY
        or c
        jr nz,KEY_PUTREDRAW
;store redraw key if it's absent in queue
         ;;ld a,key_redraw
         ;;ld (curkey),a
         ;call PEEKKEY ;ld a,(curkey) ;TODO seek queue head, not tail
         ;cp key_redraw
         ;ret z
	 ld bc,key_redraw
	 ld (keyqueueput_codenolang),bc
	 ;jp KEYQUEUEPUT ;if we switched to an inactive task, nobody can read the keycode!!
;BC=code (B=1 => control key)
KEYQUEUEPUT
keyqueueN=$+1
        LD A,0 ;decreased AFTER reading from queue
        CP keyqueuemax
        RET Z ;no room
        INC A
        LD (keyqueueN),A
;ALTGR codes: b=0, c=0..255
;letters: b=0, c>=32
;control codes: b=1, c=0..31, 0xbx, 0xcx, 0xdx, 0xfx
        
;result: TODO b=1, c=0x8x, 0x9x for ALTGR codes 0..31???
keyqueuehead=$+1
        LD HL,tkeyqueue
        LD (HL),C
        INC HL
        LD (HL),B ;B=0: letter, B=1: control key
        CALL KEYQUEUEINCHL
keyqueueput_codenolang=$+1
        ld bc,0
        LD (HL),C
        INC HL
        LD (HL),B ;B=0: symbol from ALTGR, B=1: other keys
        CALL KEYQUEUEINCHL
        LD (keyqueuehead),HL
        RET
