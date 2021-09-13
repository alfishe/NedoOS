; ----------------------------------------------------------------------
; Распарсить данные из (_param_ip) и вывести на экран
; ----------------------------------------------------------------------

decode_line:

            xor     a
            ld      (_param_cnt), a
            ld      (_param_segpfx), a
            ld      ix, _start_ix_data

            ; Чтение опкода
.read:      call    read
            call    deb_setprefix   ; Вычисление префикса
            jr      z, .read        ; Перечитать, если это префикс
            ld      h, 0
            ld      l, a
            ld      (ix+0), a       ; _param_opcode
            and     3               ; Убрать лишние биты
            ld      (ix+1), a       ; _param_bitdir

            ; Получение кода мнемоники
            ld      de, opcodes_table
            add     hl, de
            ld      a, (hl)
            and     a
            jr      z, .ntskip

            ; Вывести мнемонику
            ld      de, name_table
            call    print_nt

            ; Префиксы LOCK, REPZ, REPNZ; перечитать
            ld      a, (_param_opcode)
            cp      $f0
            jr      z, .read
            cp      $f2
            jr      z, .read
            cp      $f3
            jr      z, .read

            ; Расширяет мнемонику до 7 символов
            call    spacexpand

            ; Получение ID номер функции операнда
.ntskip:    ld      hl, (_param_opcode)
            ld      h, 0
            ld      de, operand_table
            add     hl, de
            ld      a, (hl)
            and     a
            ret     z

            ; hl = 2*operand_proc[ opcode ]
            ld      l, a
            ld      h, 0
            ld      de, operand_proc
            add     hl, hl
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      a, (ix)
            jp      (hl)

; ----------------------------------------------------------------------
; Декодирование инструкции
; ----------------------------------------------------------------------

; Печать PUSH,POP,INC,DEC r16
show_405f:  and     7
            set     0, (ix+1)   ; Установит 16 бит
            call    print_register
            ret

; Печать инструкции АЛУ с Immediate8/16
show_aluim: xor     a
            call    print_register  ; al/ax
            ld      a, ','
            call    print_char
            call    read            ; 8/16 bit
            ld      c, a
            bit     0, (ix+1)       ; _param_bitdir[0]
            jr      nz, .p16bit
            call    print_uint8
            ret
.p16bit:    call    read
            ld      b, a
            call    print_uint16
            ret

; Относительный для переходов (8 бит)
show_rel8:  call    read
            call    signextend
            ld      hl, (_param_ip)
            add     hl, bc
            ld      b, h
            ld      c, l
            call    print_uint16
            ret

; PUSH/POP seg
show_pushpopseg:

            and     00011000b
            rrca
            rrca
            rrca
            ld      de, name_seg+2
            call    print_nt
            ret

; 80h, 82h Групповая операция
show_grp80: call    show_modrm_alu
            jp      show_i8

; 81h <GRP> r16, i16
show_grp81: call    show_modrm_alu
            jp      show_i16

; 83h <GRP> r16, i8
show_grp83: call    show_modrm_alu
            jp      show_i8sgn

; Загрузить и показать АЛУ-часть
show_modrm_alu:

            call    load_modrm
            ld      a, (_param_reg)
            ld      de, name_table+2
            call    print_nt            ; Мнемоника в modrm_reg
            call    spacexpand
            call    print_part_rm       ; Пишется modrm_rm
            ld      a, ','
            call    print_char
            ret

; MOV r8, i8
show_mov8:  and     7
            ld      de, name_r8
            call    print_nt
            ld      a, ','
            call    print_char          ; r8
            jp      show_i8

; MOV r16, i16
show_mov16: and     7
            ld      de, name_r16
            call    print_nt            ; r16,
            ld      a, ','
            call    print_char
            jp      show_i16

; XCHG ax, r16
show_xchgw: xor     a
            ld      de, name_r16
            call    print_nt            ; ax,
            ld      a, ','
            call    print_char
            ld      a, (ix)
            and     7
            call    print_nt            ; r16
            ret

; r16, rm BOUND
show_r16rm: set     0,(ix+1)            ; 16-бит
            set     1,(ix+1)            ; dir=1
            call    show_modrm
            ret

; rm, r16 ARPL
show_rmr16: set     0,(ix+1)            ; 16-бит
            res     1,(ix+1)            ; dir=0
            call    show_modrm
            ret

; i8 sign extend
show_i8sgn: call    read
            call    signextend
            call    print_uint16
            ret
; i8
show_i8:    call    read
            call    print_uint8
            ret
; i16
show_i16:   call    readword
            call    print_uint16
            ret

; imul r16,rm,i16
show_imulrm16:

            call    show_r16rm
            ld      a, ','
            call    print_char
            jp      show_i16

; imul r16,rm,i8
show_imulrm8:

            call    show_r16rm
            ld      a, ','
            call    print_char
            jp      show_i8sgn

; call|jmp far
show_segoff16:

            call    readword
            push    bc
            call    readword
            call    print_uint16
            ld      a, ':'
            call    print_char
            pop     bc
            call    print_uint16
            ret

; Относительный 16 битный
show_rel16: call    readword
            ld      hl, (_param_ip)
            add     hl, bc
            ld      b, h
            ld      c, l
            call    print_uint16
            ret

; enter i16, i8
show_enter: call    show_i16
            ld      a, ','
            call    print_char
            jp      show_i8

; mov al, [m16]
; -------------------------------------------
show_alm8:  ld      de, name_r8         ; mov al, [hhhh]
.m16:       xor     a
            call    print_nt
            ld      a, ','
            call    print_char
            jp      show_m16
show_m8al:  ld      de, name_r8         ; mov [hhhh], al
.m16:       call    show_m16
            ld      a, ','
            call    print_char
            xor     a
            call    print_nt
            ret
show_axm16: ld      de, name_r16        ; mov ax, [hhhh]
            jr      show_alm8.m16
show_m16ax: ld      de, name_r16        ; mov [hhhh], ax
            jp      show_m8al.m16
show_m16:   ld      a, '['
            call    print_char
            call    show_i16
            ld      a, ']'
            call    print_char
            ret
; -------------------------------------------

; mov rm, sreg
show_rmsreg:set     0, (ix+1)
            call    load_modrm
            call    print_part_rm
            ld      a, ','
            call    print_char
            ld      a, (_param_reg)
            ld      de, name_seg+2
            call    print_nt
            ret

; mov sreg, rm
show_segrm: set     0, (ix+1)
            call    load_modrm
            ld      a, (_param_reg)
            ld      de, name_seg+2
            call    print_nt
            ld      a, ','
            call    print_char
            call    print_part_rm
            ret
; pop rm16
show_rm16:  call    load_modrm
            call    print_part_rm
            ret
; rm8, i8
show_rmi8:  call    show_rmxx
            jp      show_i8
show_rmi16: call    show_rmxx
            jp      show_i16
show_rmxx:  call    load_modrm
            call    print_part_rm
            ld      a, ','
            call    print_char
            ret
; acc,i8
show_acimm: xor     a
            call    print_register
            ld      a, ','
            call    print_char
            jp      show_i8
; acc, dx
show_acdx:  xor     a
            call    print_register
            ld      a, ','
            call    print_char
            xor     a
            ld      de, name_r16+2*2
            call    print_nt
            ret
; imm, acc
show_immac: call    read
            call    print_uint8
            ld      a, ','
            call    print_char
            xor     a
            call    print_register
            ret
; dx, acc
show_dxac:  xor     a
            ld      de, name_r16+2*2
            call    print_nt
            ld      a, ','
            call    print_char
            xor     a
            call    print_register
            ret
; C0h-C1h
show_grpc0: call    show_grpsh
            jp      show_i8
; D0h-D1h
show_grpd0: call    show_grpsh
            ld      a, '1'
            call    print_char
            ret
; D2h-D3h
show_grpd2: call    show_grpsh
            xor     a
            ld      de, name_r8+2*1
            call    print_nt
            ret

; Мнемоника группы сдвигов
show_grpsh: call    load_modrm
            ld      a, (_param_reg)
            ld      de, name_shift
            call    print_nt
            call    spacexpand
            call    print_part_rm
            ld      a, ','
            call    print_char
            ret

; F6h <modrm>
show_grpf6: call    load_modrm
            ld      a, (_param_reg)
            push    af
            ld      de, name_f6
            call    print_nt
            call    spacexpand
            call    print_part_rm
            pop     af
            cp      2
            ret     nc
            ld      a, ','
            call    print_char
            bit     0, (ix+1)
            jp      nz, show_i16
            jp      show_i8

; FEh <modrm>
show_grpfe: call    load_modrm
            ld      a, (_param_reg)
            cp      2
            jr      c, .ok
            ld      a, 1                    ; DEC
.ok:        ld      de, name_f7             ; INC
            and     a
            jr      z, .prt
            inc     de                      ; DEC
            inc     de
.prt:       xor     a
            call    print_nt
            call    spacexpand
            call    print_part_rm
            ret

; FFh <modrm>
show_grpff: call    load_modrm
            ld      a, (_param_reg)
            ld      de, name_f7
            push    af
            call    print_nt
            call    spacexpand
            pop     af
            call    print_part_rm
            ret

            ; Задан A, показать мнемонику из `name_table_ext`
show_0fmnem:
            ld      de, name_table_ext
            call    print_nt
            call    spacexpand
            ret

; D8-DFh ESC/FPU: Все ESC-коды загружают modrm
show_fpu:   call    load_modrm
            ret

; Расширенный опкод
show_0fextend:

            call    read
            ld      (_param_opcode), a
            ld      h, 0
            ld      l, a
            ld      de, opcodes_0f_table
            add     hl, hl
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            or      h
            ret     z           ; Инструкция не реализована
            jp      (hl)

; 80h-8Fh J<ccc> near i16
ie80h:      ld      a, (_param_opcode)
            and     15
            add     37          ; Здесь мнемоники j<cccc>
            ld      de, name_table
            call    print_nt
            call    spacexpand
            jp      show_rel16

            ; RDTSC
ie31:       xor     a
            jp      show_0fmnem


            ; MOV<z|s>X r8/16, rm
ieb6:       ld      a, 1        ; movzx
            jr      ieb67
iebe:       ld      a, 2        ; movsx
ieb67:      call    show_0fmnem
            call    load_modrm
            ld      a, (ix+1)
            push    af
            set     0, (ix+1)
            call    print_part_reg
            ld      a, ','
            call    print_char
            pop     af
            ld      (ix+1),a
            call    print_part_rm
            ret

; 40-4F CMOV<ccc>
ie40:       ld      a, 3
            ld      de, name_table_ext
            call    print_nt
            ld      a, (_param_opcode)
            and     15
            ld      de, name_cmovccc
.show16:    call    print_nt
            call    spacexpand
            set     0, (ix+1)
            call    show_modrm
            ret

; IMUL r16, rm16
ieaf:       ld      a, 24
            ld      de, name_table
            jr      ie40.show16

; ----------------------------------------------------------------------
; Переменные
; ----------------------------------------------------------------------

video_cursor:   defw        0

; IX parameters
_start_ix_data:

; Порядок не менять (!)
_param_opcode:  defb        0   ; +0
_param_bitdir:  defb        0   ; +1 Битность=0 / Направление=1
_param_cnt:     defb        0   ; +2
_param_segpfx:  defb        0   ; +3
_param_mod:     defb        0   ; +4
_param_reg:     defb        0   ; +5
_param_r_m:     defb        0   ; +6
