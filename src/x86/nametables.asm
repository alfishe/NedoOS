
; Таблица имен
; ----------------------------------------------------------------------
name_table:

    defw        0
    defw        name_add,   name_or,    name_adc,   name_sbb        ; 1
    defw        name_and,   name_sub,   name_xor,   name_cmp        ; 5
    defw        name_push,  name_pop,   name_daa,   name_das        ; 9
    defw        name_aaa,   name_aas,   name_lock,  name_repnz      ; 13
    defw        name_repz,  name_inc,   name_dec,   name_pusha      ; 17
    defw        name_popa,  name_bound, name_arpl,  name_imul       ; 21
    defw        name_insb,  name_insw,  name_outsb, name_outsw      ; 25
    defw        name_hlt,   name_cmc,   name_clc,   name_stc        ; 29
    defw        name_cli,   name_sti,   name_cld,   name_std        ; 33
    defw        name_jo,    name_jno,   name_jb,    name_jnb        ; 37
    defw        name_je,    name_jne,   name_jbe,   name_ja         ; 41
    defw        name_js,    name_jns,   name_jp,    name_jnp        ; 45
    defw        name_jl,    name_jnl,   name_jle,   name_jg         ; 49
    defw        name_test,  name_xchg,  name_mov,   name_nop        ; 53
    defw        name_lea,   name_cbw,   name_cwd,   name_call       ; 57
    defw        name_fwait, name_pushf, name_popf,  name_sahf       ; 61
    defw        name_lahf,  name_movsb, name_movsw, name_cmpsb      ; 65
    defw        name_cmpsw, name_stosb, name_stosw, name_lodsb      ; 69
    defw        name_lodsw, name_scasb, name_scasw, name_ret        ; 73
    defw        name_retf,  name_iret,  name_aam,   name_aad        ; 77
    defw        name_salc,  name_xlat,  name_les,   name_lds        ; 81
    defw        name_enter, name_leave, name_int3,  name_int1       ; 85
    defw        name_int,   name_into,  name_loopnz,name_loopz      ; 89
    defw        name_loop,  name_jcxz,  name_in,    name_out        ; 93
    defw        name_jmp

name_table_ext:

    defw        name_rdtsc, name_movzx, name_movsx, name_cmov

name_cmovccc:

    defw        name_o,     name_no,    name_b,     name_nb
    defw        name_z,     name_nz,    name_be,    name_a
    defw        name_s,     name_ns,    name_p,     name_np
    defw        name_l,     name_ge,    name_le,    name_g

name_modrm_table:

    defw        name_r_m0, name_r_m1, name_r_m2, name_r_m3
    defw        name_r_m4, name_r_m5, name_r_m6, name_r_m7
    defw        name_byte, name_word

name_r8:

    defw        name_r8_0, name_r8_1, name_r8_2, name_r8_3
    defw        name_r8_4, name_r8_5, name_r8_6, name_r8_7

name_r16:

    defw        name_r16_0, name_r16_1, name_r16_2, name_r16_3
    defw        name_r16_4, name_r16_5, name_r16_6, name_r16_7

name_seg:

    defw        0
    defw        name_es, name_cs, name_ss, name_ds, name_fs, name_gs

name_shift:

    defw        name_rol, name_ror, name_rcl, name_rcr
    defw        name_shl, name_shr, name_sal, name_sar

name_f6:

    defw        name_test, name_test, name_not, name_neg
    defw        name_mul,  name_imul, name_div, name_idiv

name_f7:

    defw        name_inc, name_dec,  name_call, name_callf
    defw        name_jmp, name_jmpf, name_push, name_inv

operand_proc:

    defw        0
    defw        show_modrm          ; 1
    defw        show_aluim          ; 2
    defw        show_405f           ; 3
    defw        show_rel8           ; 4 Относительный переход 8 bit
    defw        show_pushpopseg     ; 5
    defw        show_grp80          ; 6
    defw        show_grp81          ; 7
    defw        show_grp83          ; 8
    defw        show_mov8           ; 9
    defw        show_mov16          ; 10
    defw        show_xchgw          ; 11
    defw        show_r16rm          ; 12
    defw        show_rmr16          ; 13
    defw        show_i16            ; 14
    defw        show_i8             ; 15
    defw        show_i8sgn          ; 16
    defw        show_imulrm16       ; 17
    defw        show_imulrm8        ; 18
    defw        show_segoff16       ; 19 jmp far
    defw        show_rel16          ; 20
    defw        show_enter          ; 21
    defw        show_alm8           ; 22
    defw        show_axm16          ; 23
    defw        show_m8al           ; 24
    defw        show_m16ax          ; 25
    defw        show_rmsreg         ; 26
    defw        show_segrm          ; 27
    defw        show_rm16           ; 28
    defw        show_rmi8           ; 29
    defw        show_rmi16          ; 30
    defw        show_acimm          ; 31
    defw        show_acdx           ; 32
    defw        show_immac          ; 33
    defw        show_dxac           ; 34
    defw        show_grpc0          ; 35
    defw        show_grpd0          ; 36
    defw        show_grpd2          ; 37
    defw        show_grpf6          ; 38
    defw        show_grpfe          ; 39
    defw        show_grpff          ; 40
    defw        show_0fextend       ; 41
    defw        show_fpu            ; 42

; Таблица мнемоник
; ----------------------------------------------------------------------
name_add:       defb    "add",0     ; 1
name_or:        defb    "or",0      ; 2
name_adc:       defb    "adc",0     ; 3
name_sbb:       defb    "sbb",0     ; 4
name_and:       defb    "and",0     ; 5
name_sub:       defb    "sub",0     ; 6
name_xor:       defb    "xor",0     ; 7
name_cmp:       defb    "cmp",0     ; 8
name_push:      defb    "push",0    ; 9
name_pop:       defb    "pop",0     ; 10
name_daa:       defb    "daa",0     ; 11
name_das:       defb    "das",0     ; 12
name_aaa:       defb    "aaa",0     ; 13
name_aas:       defb    "aas",0     ; 14
name_lock:      defb    "lock ",0   ; 15
name_repnz:     defb    "repnz ",0  ; 16
name_repz:      defb    "repz ",0   ; 17
name_inc:       defb    "inc",0     ; 18
name_dec:       defb    "dec",0     ; 19
name_pusha:     defb    "pusha",0   ; 20
name_popa:      defb    "popa",0    ; 21
name_bound:     defb    "bound",0   ; 22
name_arpl:      defb    "arpl",0    ; 23
name_imul:      defb    "imul",0    ; 24
name_insb:      defb    "insb",0    ; 25
name_insw:      defb    "insw",0    ; 26
name_outsb:     defb    "outsb",0   ; 27
name_outsw:     defb    "outsw",0   ; 28
name_hlt:       defb    "hlt",0     ; 29
name_cmc:       defb    "cmc",0     ; 30
name_clc:       defb    "clc",0     ; 31
name_stc:       defb    "stc",0     ; 32
name_cli:       defb    "cli",0     ; 33
name_sti:       defb    "sti",0     ; 34
name_cld:       defb    "cld",0     ; 35
name_std:       defb    "std",0     ; 36
name_jo:        defb    "jo",0      ; 37
name_jno:       defb    "jno",0     ; 38
name_jb:        defb    "jb",0      ; 39
name_jnb:       defb    "jnb",0     ; 40
name_je:        defb    "je",0      ; 41
name_jne:       defb    "jne",0     ; 42
name_jbe:       defb    "jbe",0     ; 43
name_ja:        defb    "ja",0      ; 44
name_js:        defb    "js",0      ; 45
name_jns:       defb    "jns",0     ; 46
name_jp:        defb    "jp",0      ; 47
name_jnp:       defb    "jnp",0     ; 48
name_jl:        defb    "jl",0      ; 49
name_jnl:       defb    "jnl",0     ; 50
name_jle:       defb    "jle",0     ; 51
name_jg:        defb    "jg",0      ; 52
name_test:      defb    "test",0    ; 53
name_xchg:      defb    "xchg",0    ; 54
name_mov:       defb    "mov",0     ; 55
name_nop:       defb    "nop",0     ; 56
name_lea:       defb    "lea",0     ; 57
name_cbw:       defb    "cbw",0     ; 58
name_cwd:       defb    "cwd",0     ; 59
name_call:      defb    "call",0    ; 60
name_fwait:     defb    "fwait",0   ; 61
name_pushf:     defb    "pushf",0   ; 62
name_popf:      defb    "popf",0    ; 63
name_sahf:      defb    "sahf",0    ; 64
name_lahf:      defb    "lahf",0    ; 65
name_movsb:     defb    "movsb",0   ; 66
name_movsw:     defb    "movsw",0   ; 67
name_cmpsb:     defb    "cmpsb",0   ; 68
name_cmpsw:     defb    "cmpsw",0   ; 69
name_stosb:     defb    "stosb",0   ; 70
name_stosw:     defb    "stosw",0   ; 71
name_lodsb:     defb    "lodsb",0   ; 72
name_lodsw:     defb    "lodsw",0   ; 73
name_scasb:     defb    "scasb",0   ; 74
name_scasw:     defb    "scasw",0   ; 75
name_ret:       defb    "ret",0     ; 76
name_retf:      defb    "retf",0    ; 77
name_iret:      defb    "iret",0    ; 78
name_aam:       defb    "aam",0     ; 79
name_aad:       defb    "aad",0     ; 80
name_salc:      defb    "salc",0    ; 81
name_xlat:      defb    "xlatb",0   ; 82
name_les:       defb    "les",0     ; 83
name_lds:       defb    "lds",0     ; 84
name_enter:     defb    "enter",0   ; 85
name_leave:     defb    "leave",0   ; 86
name_int3:      defb    "int3",0    ; 87
name_int1:      defb    "int1",0    ; 88
name_int:       defb    "int",0     ; 89
name_into:      defb    "into",0    ; 90
name_loopnz:    defb    "loopnz",0  ; 91
name_loopz:     defb    "loopz",0   ; 92
name_loop:      defb    "loop",0    ; 93
name_jcxz:      defb    "jcxz",0    ; 94
name_in:        defb    "in",0      ; 95
name_out:       defb    "out",0     ; 96
name_jmp:       defb    "jmp",0     ; 97
; В группах
name_not:       defb    "not",0     ; 98
name_neg:       defb    "neg",0     ; 99
name_mul:       defb    "mul",0     ; 100
name_div:       defb    "div",0     ; 101
name_idiv:      defb    "idiv",0    ; 102
name_callf:     defb    "callf",0   ; 103
name_jmpf:      defb    "jmpf",0    ; 104
name_inv:       defb    "<inv>",0   ; 105

; Дополнительные 0Fh xxx
name_rdtsc:     defb    "rdtsc",0   ; 0
name_movzx:     defb    "movzx",0   ; 1
name_movsx:     defb    "movsx",0   ; 2
name_cmov:      defb    "cmov",0   ; 3

; Таблица для modrm: rm-часть
name_r_m0:      defb    "bx+si",0
name_r_m1:      defb    "bx+di",0
name_r_m2:      defb    "bp+si",0
name_r_m3:      defb    "bp+di",0
name_r_m4:      defb    "si",0
name_r_m5:      defb    "di",0
name_r_m6:      defb    "bp",0
name_r_m7:      defb    "bx",0
name_byte:      defb    "byte",0
name_word:      defb    "word",0

; 8-битные регистры
name_r8_0:      defb    "al",0
name_r8_1:      defb    "cl",0
name_r8_2:      defb    "dl",0
name_r8_3:      defb    "bl",0
name_r8_4:      defb    "ah",0
name_r8_5:      defb    "ch",0
name_r8_6:      defb    "dh",0
name_r8_7:      defb    "bh",0

; 16-битные регистры
name_r16_0:     defb    "ax",0
name_r16_1:     defb    "cx",0
name_r16_2:     defb    "dx",0
name_r16_3:     defb    "bx",0
name_r16_4:     defb    "sp",0
name_r16_5:     defb    "bp",0
name_r16_6:     defb    "si",0
name_r16_7:     defb    "di",0

; Сегментные префиксы
name_es:        defb    "es",0
name_cs:        defb    "cs",0
name_ss:        defb    "ss",0
name_ds:        defb    "ds",0
name_fs:        defb    "fs",0
name_gs:        defb    "gs",0

; Сдвиговые
name_rol:       defb    "rol",0
name_ror:       defb    "ror",0
name_rcl:       defb    "rcl",0
name_rcr:       defb    "rcr",0
name_shl:       defb    "shl",0
name_shr:       defb    "shr",0
name_sal:       defb    "sal",0
name_sar:       defb    "sar",0

; Условия
name_o:         defb    "o",0       ; 0
name_no:        defb    "no",0      ; 1
name_b:         defb    "b",0       ; 2
name_nb:        defb    "nb",0      ; 3
name_z:         defb    "z",0       ; 4
name_nz:        defb    "nz",0      ; 5
name_be:        defb    "be",0      ; 6
name_a:         defb    "a",0       ; 7
name_s:         defb    "s",0       ; 8
name_ns:        defb    "ns",0      ; 9
name_p:         defb    "p",0       ; a
name_np:        defb    "np",0      ; b
name_l:         defb    "l",0       ; c
name_ge:        defb    "ge",0      ; d
name_le:        defb    "le",0      ; e
name_g:         defb    "g",0       ; f

