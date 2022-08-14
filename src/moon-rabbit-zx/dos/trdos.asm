    MODULE Dos
; API methods
ESX_GETSETDRV = #89
ESX_FOPEN = #9A
ESX_FCLOSE = #9B
ESX_FSYNC = #9C
ESX_FREAD = #9D
ESX_FWRITE = #9E

; File modes
FMODE_READ = #01
FMODE_WRITE = #06
FMODE_CREATE = #0E

    ; MACRO esxCall func
    ; rst #8 : db func
    ; ENDM
	
;id = 0 файл не открыт
;id = 1 файл для чтения
;id = 2 файл для записи
;id = 3 файл для записи тип TRD
;id = 4 файл для записи тип SCL

; HL - filename in ASCIIZ
loadBuffer:
    ld b, Dos.FMODE_READ: call Dos.fopen
    push af
        ld hl, outputBuffer, bc, #ffff - outputBuffer : call Dos.fread
        ld hl, outputBuffer : add hl, bc : xor a : ld (hl), a : inc hl : ld (hl), a
    pop af
    call Dos.fclose
    ret


; Returns: 
;  A - current drive
; getDefaultDrive: ;нигде не используется
    ; ld a, 0 : esxCall ESX_GETSETDRV
    ; ret



; Opens file on default drive
; B - File mode
; HL - File name
; Returns:
;  A - file stream id
fopen:
    ; push bc : push hl 
    ; call getDefaultDrive
    ; pop ix : pop bc
    ; esxCall ESX_FOPEN
    ; ret
	ld a,b
	cp FMODE_READ ;если режим открытие файла
	jr z,fopen_r
	cp FMODE_CREATE
	jr z,fopen_c ;если режим создание файла
	jr fopen_err ;иначе выход
	
fopen_r	;открытие существующего файла на чтение (id=1)
			call format_name ;
			ld      c,#13 ;move file info to syst var
            call    #3d13
            ld      c,#0a ;find file
            call    #3d13
            ld      a,c
			cp 		#ff
			jr 		z,fopen_err ;если не нашли файла
            ld      c,#08 ;read file title
            call    #3d13
            ;ld      hl,loadadr ;куда
            ld      de,(#5ceb) ;начало файла сектор дорожка
            ld      (f_r_cur_trk),de

            ld      a,(#5cea)
            ld      (f_r_len_sec),a ;длина в секторах
            ;or      a
            ;ret     z    ;выход если пустой

            ; ld      de,(fcurtrk) ;текущие сектор дорожка
            ; ld      (#5cf4),de ;восстановим
			xor a
			ld 		a,1
			ld (f_r_flag),a ;флаг что файл для чтения открыт
			;id канала будет 1
	ret
	
fopen_err
	xor a ;если никакой файл не открыли, то id = 0
	scf ;флаг ошибки
	ret


fopen_c	;создание нового файла (id=2-4)
	call format_name ;
	ld a,(de) ;выясним, не образ ли это для разворачивания
	cp "t"
	jr nz,fopen_c_s
	inc de
	ld a,(de)
	cp "r"
	jr nz,fopen_c_2
	inc de
	ld a,(de)
	cp "d"
	jr nz,fopen_c_2	
	jr fopen_c_trd
	
fopen_c_s
	ld a,(de)
	cp "s"	
	jr nz,fopen_c_2
	inc de
	ld a,(de)
	cp "c"
	jr nz,fopen_c_2		
	inc de
	ld a,(de)
	cp "l"
	jr nz,fopen_c_2		
	jr fopen_c_scl
	
fopen_c_2	;создание произвольного файла
	jr 		fopen_err ;пока отключено

	ld      c,#13 ;move file info to syst var
    call    #3d13
	ld de,256 ;запишем пока 1 сектор
	ld hl,#4000 ;возьмём случайные данные из экрана
    ld      c,#0b ;запись файла CODE
    call    #3d13
    ld      a,c
	cp 		#ff
	jr 		z,fopen_err ;если ошибка
		
    ld      de,(#5ceb) ;начало файла сектор дорожка
    ld      (f_w_cur_trk),de
    ld      a,(#5cea)
    ld      (f_w_len_sec),a ;длина в секторах
	xor a ;id канала будет 2
	ld a,2
	ld (f_w_flag),a ;флаг что файл для записи открыт
	ret		
	




fopen_c_trd	;разворачивание образа trd (id=3)
	ld a,(#5D19) ;номер дисковода по умолчанию
	add a,"A"
	ld (write_trd_d),a ;подставим букву в запросе
    ld hl, write_trd
    call DialogBox.msgBox ;предуреждение
WAITKEY_trd	
	ld 		a,(23556)
	cp 255
	JR Z,WAITKEY_trd	;ждём любую клавишу
	
	ld      de,0 ;начало сектор дорожка
    ld      (#5cf4),de
	xor a 
	ld (sec_shift),a ;переменная
	ld hl,0
	ld (f_w_len+0),hl
	ld (f_w_len+2),hl
	ld a,3 ;id канала
	ld (f_w_flag),a ;флаг что trd для записи открыт
	ret




fopen_c_scl	;разворачивание образа scl (id=4)
	jp 		fopen_err ;пока отключено

	ld      de,0 ;начало сектор дорожка
    ld      (f_w_cur_trk),de
	xor a 
	ld a,4 ;id канала
	ld (f_w_flag),a ;флаг что scl для записи открыт
	ret	



; A - file stream id
fclose:
    ;esxCall ESX_FCLOSE
	xor a ;как бы закрываем все файлы
	ld (f_r_flag),a
	ld (f_w_flag),a
    ret




; A - file stream id
; BC - length
; HL - buffer
; Returns
;  BC - length(how much was actually read) 
fread: ;(id=1)
    ; push hl : pop ix
    ; esxCall ESX_FREAD
	; push af
	; ld a,4
	; out (254),a
; WAITKEY	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY
	; xor a
	; out (254),a
	; pop af

	cp 1 ;id = 1?
	jr nz,fread_no_chek ;выход если номер потока не = 1
	ld a,(f_r_flag)
	or a
	jr nz,fread_chek ;файл уже открыт?
fread_no_chek ;выход с ошибкой
	xor a
	scf ;флаг ошибки
	ld bc,0 ;ничего мы не считали
	ret
	
fread_chek
	push bc
	ld bc,(f_r_len_sec-1) ;загружаем файл целиком, не смотря на то, сколько байт было запрошено
    ld      c,5 ;read читаем целыми секторами
	ld de,(f_r_cur_trk)
    call    #3d13	
	pop bc ;возвратим, что сколько запрашивали, столько и считали байт
	xor a ;флаги сбросим
    ret

; A - file stream id
; BC - length
; HL - buffer
; Returns:
;   BC - actually written bytes
fwrite: ;
    ; push hl : pop ix
    ; esxCall ESX_FWRITE
	
	; push af
	; ld a,2
	; out (254),a
; WAITKEY1	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY1
	; xor a
	; out (254),a
	; pop af

	cp 2 ;id = 2?
	jr z,fwrite_chek ;проверка id потока
	cp 3 ;id = 3?
	jr z,fwrite_chek_trd ;проверка id потока
	cp 4 ;id = 4?
	jp z,fwrite_chek_scl ;проверка id потока

	
fwrite_no_chek ;выход с ошибкой
	xor a
	scf ;флаг ошибки
	ld bc,0 ;ничего мы не записали
	ret
	
fwrite_chek ;запись произвольного типа файла
	jr fwrite_no_chek ;пока отключено
	ld a,(f_w_flag)
	or a
	jr z,fwrite_no_chek ;файл уже открыт?
	ld (temp_bc),bc
	;ld bc,(f_r_len_sec-1) ;
    ld      c,6 ;пишем целыми секторами
	ld de,(f_w_cur_trk)
    call    #3d13	
	ld bc,(temp_bc) ;возвратим, что сколько запрашивали, столько и считали байт
	xor a ;флаги сбросим
    ret



fwrite_chek_trd ;запись trd файла (разворачивание образа)
	ld a,(f_w_flag)
	or a
	jr z,fwrite_no_chek ;файл уже открыт?
	ld (temp_bc),bc
	ld (temp_hl),hl
	ld a,b
	or c
	jr z,fwrite_no_chek ; если длина 0, то выход
	
	ld a,b
	or a
	jr nz,testt1
	nop
	
testt1
	
	xor a
	ld (sec_part),a ;обнулить переменные
	ld (sec_shift2),a
	ld (sec_shift2+1),a
	ld (sec_shift_flag),a
	

	ld a,(sec_shift)
	or a
	jr z,fwrite_trd3 ;если смещения нет, то первую часть пропустим
	
	ld c,a
	ld b,0
	ld hl,(temp_bc) ;проверка заполнится ли целый сектор
	add hl,bc
	ld a,h
	or a
	jr nz,fwrite_trd4
	ld a,1
	ld (sec_shift_flag),a ;флаг что не заполнен сектор
	
fwrite_trd4	
	ld hl,sec_buf ;буфер последнего сектора	
	add hl,bc ;на этой точке остановились
	ex de,hl
	ld hl,(temp_hl) ;присоединим начало данных в конец предыдущих
	ld a,c
	or a
	jr nz,fwrite_trd2
	inc b ;коррекция
fwrite_trd2		
	ld c,a
	xor a
	sub c
	ld c,a ;сколько осталось перенести до заполнения сектора
	ld (sec_shift2),bc ;сохраним сколько добавили байт
	ldir
	
	ld hl,sec_buf
	ld de,(#5cf4)
	ld (f_w_cur_trk),de	;запомним позицию
    ld      bc,#0106 ;пишем 1 сектор из буфера
    call    #3d13	
	ld a,c
	cp 255
	jp z,fwrite_no_chek ;выход если ошибка	
	ld a,(sec_shift_flag)
	or a
	jr z,fwrite_trd3
	ld de,(f_w_cur_trk) ;если сектор ещё не заполнен, останемся на старой позиции
	ld (#5cf4),de
	; ld b,1 ;на сектор вперёд
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de	

fwrite_trd3	
	ld hl,(temp_hl) ;запишем остаток данных
	;ld a,(sec_shift)
	;ld c,a
	;ld b,0
	ld bc,(sec_shift2)
	add hl,bc ;с этой точки пишем
	ld (temp_hl2),hl ;сохраним начало записи второго сектора
	
	ld hl,(temp_bc) ;вычисление на чём остановимся в этот раз
	and a
	sbc hl,bc ;вычтем то, что добавили к первому сектору
	ld c,l
	ld b,h
	jr nc,fwrite_trd5
	ld b,0 ;коррекция если вышел минус
fwrite_trd5
	ld hl,(temp_hl)
	add hl,bc 
	
	ld a,l
	ld (sec_shift),a ;смещение на следующий раз
	;ld hl,(temp_hl)	
	
	
	; or a
	; jr z,fwrite_trd1
	; inc b  ;коррекция количества секторов
	
	ld a,b ;нужна проверка на количество секторов!!!
	ld (sec_part),a ;запомним сколько секторов во второй части
	or a
	jr z,fwrite_trd_ex ;если размер данных меньше сектора, то пропустим второй этап
	
	ld hl,(temp_hl2)
	;push bc
	ld de,(#5cf4)
    ld      c,6 ;пишем целыми секторами
    call    #3d13	
	ld a,c
	;pop bc
	cp 255
	jp z,fwrite_no_chek ;выход если ошибка
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de
	
fwrite_trd1	
	ld hl,(temp_hl2) ;сохраним последний сектор
	ld a,(sec_part)
	ld b,a
	ld c,0
	add hl,bc
	ld bc,256
	ld de,sec_buf
	ldir
	
	
fwrite_trd_ex	
	ld bc,(temp_bc) ;возвратим, что сколько запрашивали, столько и считали байт
	;посчитаем общую длину записанного
	ld hl,(f_w_len)
	add hl,bc
	ld (f_w_len),hl
	jr nc,fwrite_trd_ex1
	ld hl,(f_w_len+2)
	inc hl
	ld (f_w_len+2),hl
	
fwrite_trd_ex1
	xor a ;флаги сбросим
    ret



fwrite_chek_scl ;запись scl файла ---------------
	jp fwrite_no_chek ;пока отключено
	ld a,(f_w_flag)
	or a
	jp z,fwrite_no_chek ;файл уже открыт?
	ld (temp_bc),bc
	;ld bc,(f_r_len_sec-1) ;
    ld      c,6 ;пишем целыми секторами
	ld de,(f_w_cur_trk)
    call    #3d13	
	ld bc,(temp_bc) ;возвратим, что сколько запрашивали, столько и считали байт
	xor a ;флаги сбросим
    ret	

    
; A - file stream id
; fsync:
;     esxCall ESX_FSYNC
    ; ret


; HL - name (name.ext)
; Returns:
; HL - name (name    e)	
format_name ;подгоняет имя файла под стандарт trdos (8+1)
	push hl ;сначала очистим место
	ld hl,f_name
	ld de,f_name+1
	ld (hl)," "
	ld bc,8
	ldir
	pop hl

	ld bc,#09ff ;длина имени 9 символов
	ld de,f_name ;куда
format_name2	
	ld a,(hl)
	cp "."
	jr nz,format_name1
	inc hl
	ld a,(hl)
	ld (f_name+8),a ; и в конце первую букву расширения
	ex de,hl ;сохраним адрес исходного расширения
	jr format_name_e
format_name1
	ldi
	djnz format_name2
format_name_e
	ld hl,f_name ;вернём результат
	ret

; DE - trk/sec
; B - sectors step
; Returns:
; DE - trk/sec	
calc_next_pos		;вперёд на N секторов	
			;ld b,4 
			;ld  de,(#5ceb) 
calc_next_pos2		
			inc e
			ld a,e
			cp 16
			jr c,calc_next_pos1
			inc d
			ld e,0
calc_next_pos1
			;ld (#5ceb),de
			djnz calc_next_pos2
			ret
			

;testt db "123.trd"
write_trd db "Insert disk to drive "
write_trd_d db "A. "
		db "All data will be lost!",0

f_name ds 9 ;имя файла
f_r_cur_trk dw 	 0 ;текущие сектор-дорожка файла на чтение
f_r_len_sec db 0 ;длина файла на чтение в секторах
f_r_flag db 0 ;флаг что открыт файл на чтение

f_w_cur_trk dw 	 0 ;текущие сектор-дорожка файла на запись
f_w_len_sec db 0 ;длина файла на запись в секторах
f_w_flag db 0 ;флаг что открыт файл на запись
f_w_len ds 4 ;длина записанных данных

temp_bc dw 0 ;хранение регистра 
temp_hl dw 0 ;хранение регистра 
temp_hl2 dw 0 ;хранение регистра 

sec_shift db 0 ;указатель на каком байте остановлена запись
sec_shift2 db 0 ;указатель на каком байте остановлена запись (остаток)
sec_part db 0 ;сколько секторов во второй порции для записи
sec_shift_flag db 0 ;флаг что буфер сектора не заполнен

	align 256 ;временно
sec_buf ds 256 ;буфер сектора для записи
    ENDMODULE