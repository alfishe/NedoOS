
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

; ----------------------------------------------------------------------
; Вход:  B(Y=0..23), C(X=0..31)
; Выход: HL(адрес)
; ----------------------------------------------------------------------

get_text_cursor_address:

            ld      a, c
            and     0x1f
            ld      l, a        ; L = X & 31
            ld      a, b
            and     0x07        ; Нужно ограничить 3 битами
            rrca                ; Легче дойти с [0..2] до позиции [5..7]
            rrca                ; Если вращать направо
            rrca                ; ... три раза
            or      l           ; Объединив с 0..4 уже готовыми ранее
            ld      l, a        ; Загрузить новый результат в L
            ld      a, b        ; Т.к. Y[3..5] уже на месте
            and     0x18        ; Его двигать даже не надо
            or      0x40        ; Ставим видеоадрес $4000
            ld      h, a        ; И загружаем результат
            ret

; ----------------------------------------------------------------------
; Вход:  A (символ)
; Выход: HL
; ----------------------------------------------------------------------

get_symbol_address:

            sub     0x20            ; A = Sym - 0x20
            ld      h, 0            ; HL = A
            ld      l, a
            add     hl, hl
            add     hl, hl
            add     hl, hl          ; HL = A << 3
            ld      a, h
            add     0x3d
            ld      h, a            ; HL += 0x3D00
            ret

; ----------------------------------------------------------------------
; Вход: A(символ)
; Печать символа в поток
; ----------------------------------------------------------------------

print_char: push    af
            ;push    bc
            ;push    de
            push    hl
            ld      hl, (video_cursor)
            ;cp      10
            ;jr      z, .pc2                 ; Код переноса на другую строку
            ld (hl),a                 ; Записать 8 бит
            inc hl
            ld (video_cursor),hl
            ; ------------
            ld      hl, _param_cnt
            inc     (hl)
            ; ------------
            pop     hl
            ;pop     de
            ;pop     bc
            pop     af
            ret

; ----------------------------------------------------------------------
; Печать строк из HL
; ----------------------------------------------------------------------

print:      ld      a, (hl)
            and     a
            ret     z
            call    print_char
            inc     hl
            jr      print

; ----------------------------------------------------------------------
; Задается некий NameTable = DE
; A = ID кода для пропечатки
; ----------------------------------------------------------------------

print_nt:   push    hl
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            call    print
            pop     hl
            ret

; ----------------------------------------------------------------------
; Вывод [unsigned] int hex 8 на-гора
; ----------------------------------------------------------------------

; === Печать signed int 16
print_int16:

            push    af
            ld      a, b
            cp      $80
            jr      c, .plus
            ld      a, '-'
            call    print_char
            ; BC = (BC ^ FFFF) + 1 = -BC
            ld      a, b
            xor     255
            ld      b, a
            ld      a, c
            xor     255
            add     1
            ld      c, a
            ld      a, b
            adc     0
            ld      b, a
            jr      .prt
.plus:      ld      a, '+'
            call    print_char
.prt:       call    print_uint16
            pop     af
            ret

; ==== Печать Signed A
print_int8: push    af
            cp      $80
            jr      c, .plus
            neg
            push    af
            ld      a, '-'
            call    print_char
            pop     af
            jr      .minus
.plus:      push    af
            ld      a, '+'
            call    print_char
            pop     af
.minus:     call    print_uint8
            pop     af
            ret

; ==== Печать BC
print_uint16:

            push    af
            push    bc
            ld      a, b
            call    print_uint8
            ld      a, c
            call    print_uint8
            pop     bc
            pop     af
            ret

; ==== Печать A[7:0]
print_uint8:

            push    af
            rlca
            rlca
            rlca
            rlca
            call    print_nibble
            pop     af
            call    print_nibble
            ret

; ==== Печать A[3:0]
print_nibble:

            push    af
            and     15              ; Получение только 3:0
            or      a               ; Сброс AF=0
            daa                     ; Коррекция если >9
            add     0xf0            ; Если больше чем >9, то CF=1
            adc     0x40            ; 0..9 => 30..39, а если CF=1, то с 41..46
            call    print_char
            pop     af
            ret

; Печать регистра A=0..7; 8/16
print_register:

            push    af
            ld      de, name_r8
            ld      a, (_param_bitdir)      ; Получим параметры bit/dir
            and     1
            jr      z, .is8bit
            ld      de, name_r16            ; Выбрать таблицу с 16 битными регистрами
.is8bit:    pop     af
            call    print_nt
            ret

; Расширение знака A -> BC
signextend: ld      b, 0
            ld      c, a
            bit     7, a
            ret     z
            dec     b
            ret

; Дополнение мнемоники пробелами
spacexpand: ld      a, (_param_cnt)
            sub     7
            jr      nc, .nopad
            neg                 ; a = 7-<cnt>
            ld      b, a
            ld      a, ' '
.sppad:     call    print_char
            djnz    .sppad

            ; Всегда печатать пробел после мнемоники
.nopad:     ld      a, ' '
            call    print_char
            ret

; Чтение слова в BC
readword:   call    read
            ld      c, a
            call    read
            ld      b, a
            ret

; ----------------------------------------------------------------------
; Вывести modrm в поток
; ----------------------------------------------------------------------

show_modrm: ; Читаем байт modrm
            call    load_modrm

            ; Проверяем направление
            ld      a, (ix+1)
            and     2
            jr      nz, .dir2

            ; DIR=0
            call    print_part_rm
            ld      a, ','
            call    print_char
            call    print_part_reg
            ret

            ; DIR=1
.dir2:      call    print_part_reg
            ld      a, ','
            call    print_char
            call    print_part_rm
            ret

; Печать r/m части modrm
print_part_rm:

            ld      de, name_modrm_table
            ld      a, (_param_mod)
            and     a
            jr      z, modrm_mod0
            dec     a
            jr      z, modrm_mod1
            dec     a
            jr      z, modrm_mod2
            jr      modrm_mod3

; ============ Нет Displacement
modrm_mod0: call    modrm_leader
            ld      a, (_param_r_m)
            cp      6
            jr      nz, .mm0s
            call    read            ; Режим 6 => 16-битный адрес
            ld      c, a
            call    read
            ld      b, a
            call    print_uint16
            jr      .mm1s
.mm0s:      call    print_nt
.mm1s:      ld      a, ']'
            call    print_char
            ret

; ============= Displacement 8
modrm_mod1: call    modrm_leader
            ld      a, (_param_r_m)
            call    print_nt
            call    read
            call    print_int8
            jr      modrm_mod0.mm1s

; ============= Displacement 16
modrm_mod2: call    modrm_leader
            ld      a, (_param_r_m)
            call    print_nt
            call    read            ; 16-битный адрес
            ld      c, a
            call    read
            ld      b, a
            call    print_int16
            jr      modrm_mod0.mm1s

; ============= Register
modrm_mod3: ld      a, (_param_r_m)
            call    print_register
            ret

; Печать сегментного префикса
modrm_leader:
            ld      de, name_modrm_table
            bit     0, (ix+1) ; bitdir
            ld      a, 8
            jr      z, .bytep
            ld      a, 9
.bytep:     call    print_nt
            ld      a, '['
            call    print_char
            ld      a, (_param_segpfx)
            and     a
            ret     z
            push    de
            ld      de, name_seg
            call    print_nt
            ld      a, ':'
            call    print_char
            pop     de
            ret

; ----------------------------------------------------------------------
; Загрузка modrm и разбор
; ----------------------------------------------------------------------

load_modrm:

            call    read
            push    bc
            ld      b, a
            and     7
            ld      (_param_r_m), a
            ld      a, b
            rrca
            rrca
            rrca
            ld      b, a
            and     7
            ld      (_param_reg), a
            ld      a, b
            rrca
            rrca
            rrca
            and     3
            ld      (_param_mod), a
            pop     bc
            ret

; Выдача регистра A в зависимости от DIR
print_part_reg:

            ld      a, (_param_reg)
            call    print_register
            ret

; ----------------------------------------------------------------------
; Вычисление сегментного префикса, если он есть
; ----------------------------------------------------------------------
deb_setprefix:

            ld      b, 1
            cp      $26
            jr      z, .set     ; es=1
            inc     b
            cp      $2e
            jr      z, .set     ; cs
            inc     b
            cp      $36
            jr      z, .set     ; ss
            inc     b
            cp      $3e
            jr      z, .set     ; ds
            inc     b
            cp      $64
            jr      z, .set     ; fs
            inc     b
            cp      $65
            jr      z, .set     ; gs
            cp      $66
            jr      z, .opsize
            cp      $67
            jr      z, .adsize
            ret                 ; ZF=0
.set:       ld      a, b
            ld      (_param_segpfx), a
            ret                 ; ZF=1
.opsize:    ret                 ; Расширение до 32-х бит не реализовано
.adsize:    ret                 ; Расширение до 32-х бит не реализовано
