FALSE	equ	0
TRUE	equ	not FALSE

CPM:	EQU 1		;true if running under CP/M or MP/M II; else 0
MPM2:	EQU 0		;true only if running under MP/M II
NEDOOS EQU 1


        macro FUNCTION name
_org=$
        org _
        dc name
        dw _org-begin
_=$
        org _org
        endm
        
        macro FUNCHEAD sz
        db 0
        dw sz
__=$
        disp 0
        endm

        macro ENDFUNC sz,npars
        ent
sz=$-__
        dw npars
        if npars >= 1
        dw _1
        endif
        if npars >= 2
        dw _2
        endif
        if npars >= 3
        dw _3
        endif
        if npars >= 4
        dw _4
        endif
        if npars >= 5
        dw _5
        endif
        if npars >= 6
        dw _6
        endif
        if npars >= 7
        dw _7
        endif
        if npars >= 8
        dw _8
        endif
        if npars >= 9
        dw _9
        endif
        if npars >= 10
        dw _10
        endif
        if npars >= 11
        dw _11
        endif
        if npars >= 12
        dw _12
        endif
        if npars >= 13
        dw _13
        endif
        if npars >= 14
        dw _14
        endif
        if npars >= 15
        dw _15
        endif
        if npars >= 16
        dw _16
        endif
        if npars >= 17
        dw _17
        endif
        if npars >= 18
        dw _18
        endif
        if npars >= 19
        dw _19
        endif
        if npars >= 20
        dw _20
        endif
        if npars >= 21
        dw _21
        endif
        if npars >= 22
        dw _22
        endif
        if npars >= 23
        dw _23
        endif
        if npars >= 24
        dw _24
        endif
        if npars >= 25
        dw _25
        endif
        if npars >= 26
        dw _26
        endif
        if npars >= 27
        dw _27
        endif
        if npars >= 28
        dw _28
        endif
        if npars >= 29
        dw _29
        endif
        if npars >= 30
        dw _30
        endif
        if npars >= 31
        dw _31
        endif
        if npars >= 32
        dw _32
        endif
        if npars >= 33
        dw _33
        endif
        if npars >= 34
        dw _34
        endif
        if npars >= 35
        dw _35
        endif
        if npars >= 36
        dw _36
        endif
        if npars >= 37
        dw _37
        endif
        if npars >= 38
        dw _38
        endif
        if npars >= 39
        dw _39
        endif
        if npars >= 40
        dw _40
        endif
        if npars >= 41
        dw _41
        endif
        if npars >= 42
        dw _42
        endif
        if npars >= 43
        dw _43
        endif
        if npars >= 44
        dw _44
        endif
        if npars >= 45
        dw _45
        endif
        if npars >= 46
        dw _46
        endif
        if npars >= 47
        dw _47
        endif
        if npars >= 48
        dw _48
        endif
        if npars >= 49
        dw _49
        endif
        if npars >= 50
        dw _50
        endif
        if npars >= 51
        dw _51
        endif
        if npars >= 52
        dw _52
        endif
        if npars >= 53
        dw _53
        endif
        if npars >= 54
        dw _54
        endif
        if npars >= 55
        dw _55
        endif
        if npars >= 56
        dw _56
        endif
        if npars >= 57
        dw _57
        endif
        if npars >= 58
        dw _58
        endif
        if npars >= 59
        dw _59
        endif
        if npars >= 60
        dw _60
        endif
        if npars >= 61
        dw _61
        endif
        if npars >= 62
        dw _62
        endif
        if npars >= 63
        dw _63
        endif
        if npars >= 64
        dw _64
        endif
        if npars >= 65
        dw _65
        endif
        if npars >= 66
        dw _66
        endif
        if npars >= 67
        dw _67
        endif
        if npars >= 68
        dw _68
        endif
        if npars >= 69
        dw _69
        endif
        if npars >= 70
        dw _70
        endif
        if npars >= 71
        dw _71
        endif
        if npars >= 72
        dw _72
        endif
        if npars >= 73
        dw _73
        endif
        if npars >= 74
        dw _74
        endif
        endm

        macro EXTERNAL name
        dc name
        endm

        org 0x100
        include "CCC.ASM"

	include "BDS.LIB"

        ;align 128 ;doesn't help
begin
_=$
        ds 512,0x80 ;end=0x80
        db 0x80
        dw 0x0205
        dw 0x4646
