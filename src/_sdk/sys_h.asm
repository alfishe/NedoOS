        opt -Wno-rdlow
        include "sysdefs.asm"
        
;*********************** QUIT **********************
;Закрывает текущий процесс, освобождая все используемые им страницы ОЗУ, 
;дескрипторы сокетов и файлов (кроме пайпов и TR-DOS'ных файлов), а также обработчик музыки.
;Переключает исполнение и фокус видеовывода на следующий активный процесс.
;    Аргумент: hl=результат программы (родитель его получает по WAITPID).
;    Возвращаемых значений нет.
;    
;Пример использования, а также минимальный исходный код программы:
;        DEVICE ZXSPECTRUM128
;        include "../_sdk/sys_h.asm"
;        ORG PROGSTART
;        ;исходный код программы
;        ld hl,0 ;result
;        QUIT
;        savebin "progname.com",PROGSTART,$-PROGSTART
        macro QUIT
        rst 0 ;close app
        endm

;*********************** CALLBDOS, CALLBDOS_NOPARAM_A **********************
;Внутренние макросы для вызова функций системы.
;(CALLBDOS - для функций системы, имеющих параметр в регистре A)
;(CALLBDOS_NOPARAM_A - для функций системы, не имеющих параметра в регистре A)
;Напрямую использовать не рекомендуется, см. макросы для каждой отдельной функции системы.
        macro CALLBDOS ;don't use directly CALLBDOS or call BDOS!!!
        ex af,af' ;'
        call BDOS ;c=CMD
        endm
        macro CALLBDOS_NOPARAM_A ;don't use directly CALLBDOS or call BDOS!!!
        call BDOS ;c=CMD
        endm

;*********************** OS_GETKEY **********************
;Возвращает нажатую кнопку клавиатуры, кнопки мыши и координаты мыши.
;Фактически чтение происходит только процессом с фокусом. При отсутствии фокуса возвращается 
;код символа NOKEY и флаг Z установлен в 0 (т.е. верно условие NZ).
;    Аргументов нет.
;    Возвращаемые значения в регистрах:
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется для обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус. 
;
;Пример ожидания символа:
;        ORG PROGSTART
;        LD E,6
;        OS_SETGFX
;        ...
;WAIT_LOOP:
;        YIELD    ;отдадим квант времени системе
;        OS_GETKEY
;        OR A
;        JR Z,WAIT_LOOP
;        CP key_esc
;        JP Z,CLOSE_PROC
;        ;получили код символа в A
;        ...
;CLOSE_PROC:
;        QUIT
;        
;        Примечание: желательна обработка кода key_esc для завершения программы
;и кода key_redraw для перерисовки экрана при получении фокуса.
        macro OS_GETKEY
        rst 0x08 ;out: a=key (NOKEY=no key), de=mouse position (y,x), l=mouse buttons (bits 0,1,2: 0=pressed)+mouse wheel (bits 7..4), h=high bits of key|register, bc=keynolang, lx=kempston joystick, nz=no focus (mouse position=0, ignore it!)
        endm
        macro GET_KEY
        OS_GETKEY
        endm

;*********************** OS_PRCHAR **********************
;Выводит символ на экран, используется только в текстовом видеорежиме.
;При отсутствии фокуса вывод игнорируется.
;    Все аргументы в регистрах:
;        A - символ (символ '\r'=0x0d = возврат каретки, символ '\n'=0x0a = перевод строки)
;    Возвращаемых значений нет.
;    
;Пример печати строки "Hello Work!":
;        DEVICE ZXSPECTRUM128
;        include "../_sdk/sys_h.asm"
;        ORG PROGSTART
;        LD E,6
;        OS_SETGFX
;        LD HL,STR_HELLO
;PRINT_LOOP:
;        LD A,(HL)
;        OR A
;        JR Z,PRINT_LOOP_END
;        PUSH HL
;        OS_PRCHAR
;        POP HL
;        INC HL
;        JR PRINT_LOOP
;PRINT_LOOP_END:
;<wait something to see the screen...>
;        QUIT
;STR_HELLO:
;        DEFB "Hello Work!",0
;        savebin "progname.com",PROGSTART,$-PROGSTART
        macro OS_PRCHAR
        rst 0x10 ;a=char ;spoils all registers!
        endm
        macro PRCHAR
        OS_PRCHAR
        endm

;*********************** SETPG4000 **********************
;Устанавливает страницу номер A в области адресов 0x4000..0x7fff.
;Быстрая функция (не включает контекст ядра).
;    Все аргументы в регистрах:
;        A - номер страницы
;    Возвращаемых значений нет (портится BC, остальные регистры не портятся)
;
;Примечание: не используйте номера страниц, не полученные из системы тем или иным образом
;(вызовы OS_NEWPAGE, OS_GETMAINPAGE, OS_GETMAINPAGES, OS_GETAPPMAINPAGES
;или чтение номеров страниц экрана из user_scr0_low, user_scr0_high, user_scr1_low, user_scr1_high),
;потому что на моделях памяти ATM2 и ATM3 номера страниц различаются!
;
;Примечание 2: для смены страницы в области адресов 0x0000..0x3fff см. OS_SETMAINPAGE
        macro SETPG4000
        rst 0x18 ;set page "a" in 0x4000 ;spoils BC
        endm
        macro SETPG16K ;don't use!
        SETPG4000
        endm
        
;*********************** SETPG8000 **********************
;Устанавливает страницу номер A в области адресов 0x8000..0xbfff.
;Быстрая функция (не включает контекст ядра).
;    Все аргументы в регистрах:
;        A - номер страницы
;    Возвращаемых значений нет (портится BC, остальные регистры не портятся)
;
;См. примечания к SETPG4000!
        macro SETPG8000
        rst 0x20 ;set page "a" in 0x8000 ;spoils BC
        endm
        macro SETPG32KLOW ;don't use!
        SETPG8000
        endm
        
;*********************** SETPGC000 **********************
;Устанавливает страницу номер A в области адресов 0xc000..0xffff.
;Быстрая функция (не включает контекст ядра).
;    Все аргументы в регистрах:
;        A - номер страницы
;    Возвращаемых значений нет (портится BC, остальные регистры не портятся)
;
;См. примечания к SETPG4000!
        macro SETPGC000
        rst 0x28 ;set page "a" in 0xc000 ;spoils BC
        endm
        macro SETPG32KHIGH ;don't use!
        SETPGC000
        endm

;*********************** YIELD **********************
;Отдаёт квант времени системе.
;В текущем кванте 50 Гц этой задаче не будет возвращено управление. И её кастомный обработчик прерывания не вызовется, если есть другие активные задачи.
;    Аргументы не используются.
;    Возвращаемых значений нет.
;    
;Пример использования смотрите в описании OS_GETKEY    
;    
;Примечание: обычно используется при ожидании какого-либо события, не критичного по времени отклика.
;Использование этого вызова ускоряет общую работу системы.
        macro YIELD ;use instead of HALT
        OS_YIELD
        endm
        
;*********************** YIELDKEEP **********************
;Отдаёт квант времени системе.
;В текущем кванте 50 Гц этой задаче будет возвращено управление, если останется время.
;    Аргументы не используются.
;    Возвращаемых значений нет.
;    
;Примечание: используется при записи в очередь, когда очередь переполнена (stdio.asm и term).
;В остальных случаях замедляет общую работу системы.
        macro YIELDKEEP ;if you want reentry in this frame
        OS_YIELDKEEP
        endm

;*********************** YIELDGETKEY **********************
;Отдаёт квант времени системе и опрашивает клавиатуру (не рекомендуется использовать для опроса мыши).
;    Аргументы не используются.
;    Возвращаемые значения в регистрах:
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется дляи обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        Флаг Z - если 1(Z), то клавиша не нажата
        macro YIELDGETKEY ;out: nz=nokey, a=keylang, c=keynolang
	YIELD ;halt ;если сделать просто di:rst 0x38, то 1.сдвинем таймер и 2.можем потерять кадровое прерывание, а если без ei, то будут глюки
        OS_GETKEY
        or a ;cp NOKEY ;keylang==0?
        jr nz,$+3
        cp c ;keynolang==0?
        endm

;*********************** YIELDGETKEYLOOP **********************
;Циклически опрашивает клавиатуру (не рекомендуется использовать для опроса мыши).
;    Аргументы не используются.
;    Возвращаемые значения в регистрах:
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется дляи обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
        macro YIELDGETKEYLOOP
__1=$
        YIELDGETKEY
        jr z,__1
        endm

;*********************** WAITPID **********************
;Ожидание завершения дочернего процесса.
;    Аргументы не используются.
;    Возвращаемые значения в регистрах:
;        HL - результат, который вернул дочерний процесс
;Как это работает:
;OS_SETWAITING замораживает текущий процесс, а YIELD передаёт время системе.
;Текущий процесс получит управление только тогда, когда дочерний процесс завершится или сделает OS_HIDEFROMPARENT
;(он автоматически размораживает родителя и записывает childresult в структуру родителя).
        macro WAITPID
        OS_SETWAITING ;не замораживает, если дочерний процесс уже завершился
        YIELD
        ld c,CMD_GETCHILDRESULT
	CALLBDOS_NOPARAM_A ;hl=result
        endm

;======================= from CP/M: =============================

;*********************** OS_SETDTA **********************
;Установить адрес передачи данных для следующей команды CP/M.
;    Все аргументы в регистрах:
;        DE - адрес передачи данных.
;    Возвращаемых значений нет.
        macro OS_SETDTA ;DE = data transfer address (DTA)
        ld c,CMD_SETDTA
        CALLBDOS_NOPARAM_A
        endm
;*********************** OS_FSEARCHFIRST **********************
;Прочитать первый элемент текущей директории (файл или каталог).
;Последующие элементы директории надо считывать командой OS_FSEARCHNEXT.
;Вся информация о файле или каталоге будет записана в FCB по адресу, установленному командой SET_DTA (этот адрес меняется после выполнения команды!).
;Полученную FCB можно будет открыть командой OS_FOPEN.
;Если возвращена ошибка, то ничего не записывается и адрес не сдвигается.
;    Все аргументы в регистрах:
;        DE - адрес FCB с маской имени файла или каталога (знак '?' в ней означает любой символ в имени).
;    Возвращаемые значения в регистрах:
;        A - код ошибки (если 0, то ошибки нет). Окончание директории - это ошибка.
;
;Примечания:
;NedoOS не проверяет номер экстента в FCB с маской.
;В NedoOS атрибуты файла возвращаются в обычном месте (не в поле S1).
;NedoOS не возвращает этой командой метку диска и date stamps.
;NedoOS не пропускает скрытые и системные файлы.
;NedoOS не возвращает коды ошибки в регистрах H,L,C.
;В NedoOS выходное значение A = 1..3 считается ошибкой.
        macro OS_FSEARCHFIRST ;de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA. DTA had to set every time
        ld c,CMD_FSEARCHFIRST
        CALLBDOS_NOPARAM_A
        endm
        
;*********************** OS_FSEARCHNEXT **********************
;Прочитать очередной (не первый) элемент текущей директории (файл или каталог).
;Вся информация о файле или каталоге будет записана в FCB по адресу, установленному командой SET_DTA (этот адрес меняется после выполнения команды!).
;Полученную FCB можно будет открыть командой OS_FOPEN.
;Если возвращена ошибка, то ничего не записывается и адрес не сдвигается.
;    Все аргументы в регистрах:
;        DE - адрес FCB с маской имени файла или каталога (знак '?' в ней означает любой символ в имени).
;    Возвращаемые значения в регистрах:
;        A - код ошибки (если 0, то ошибки нет). Окончание директории - это ошибка.
;
;Примечание: в отличие от CP/M, нужно обязательно передавать адрес маски!
;См. также примечания к OS_FSEARCHFIRST!
        macro OS_FSEARCHNEXT ;(NOT CP/M compatible!!!)de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA. DTA had to set every time
        ld c,CMD_FSEARCHNEXT
        CALLBDOS_NOPARAM_A
        endm
        
;Нижеследующие вызовы CP/M пользовать не рекомендуется!
;from CP/M (try to avoid use!)
        ;macro OS_PRCHAR ;e=char
        ;ld c,CMD_PRCHAR
        ;CALLBDOS_NOPARAM_A
        ;endm
        macro OS_SETDRV ;e=drive ;out: a!=0 => not mounted, [l=number of drives]
        ld c,CMD_SETDRV
        CALLBDOS_NOPARAM_A
        endm
        macro OS_FOPEN ;de = pointer to unopened FCB
        ld c,CMD_FOPEN
        CALLBDOS_NOPARAM_A
        endm
        macro OS_FCLOSE ;de = pointer to opened FCB
        ld c,CMD_FCLOSE
        CALLBDOS_NOPARAM_A
        endm
        macro OS_FDEL ;DEPRECATED!!!!! ;DE = Pointer to unopened FCB
        ld c,CMD_FDEL
        CALLBDOS_NOPARAM_A
        endm
        macro OS_FREAD ;DE = Pointer to opened FCB, read 128 bytes in DTA, out: a=128^bytes actually read (not CP/M!)
        ld c,CMD_FREAD
        CALLBDOS_NOPARAM_A
        endm
        macro OS_FWRITE ;DE = Pointer to opened FCB, write 128 bytes from DTA
        ld c,CMD_FWRITE
        CALLBDOS_NOPARAM_A
        endm
        macro OS_FCREATE ;DE = Pointer to unopened FCB
        ld c,CMD_FCREATE
        CALLBDOS_NOPARAM_A
        endm

;======================= from MSX-DOS: =============================

;*********************** OS_OPENHANDLE **********************
;Открывает существующий файл для чтения/записи. 
;    Все аргументы в регистрах:
;        DE - строка с именем файла, может содержать относительный или абсолютный путь к файлу.
;            в текущей реализации поддержан формат имен 8.3
;    Возвращаемые значения в регистрах:
;        А - ошибка. Если 0x00, то ошибки нет. 
;        B - хэндл файла, если нет ошибки.
;    
;Пример открытия файла "pyraster.txt", расположенного в директории "../fu/ckco":
;        ...
;        LD DE,FILE_NAME
;        OS_OPENHANDLE
;        OR A
;        JP NZ,ERR_EXIT    ;обработка ошибок
;        LD A,B
;        LD (FILE),A    ;сохраняем дескриптор
;        ...
;FILE_NAME:
;        DEFB "../fu/ckco/pyraster.txt",0
;        ...
;        
;Примечания:
;Необходимо закрывать все открытые файлы.
;Также желательно закрыть файл, как только он становится не нужен для чтения/записи.
;При открытии файла указатель чтения/записи этого файла устанавливается на первый байт в файле.
        macro OS_OPENHANDLE ;DE = Drive/path/file ASCIIZ string ;out: B = new file handle, A=error
        ld c,CMD_OPENHANDLE
        CALLBDOS_NOPARAM_A
        endm
        
;*********************** OS_CREATEHANDLE **********************
;Создать и открыть файл для чтения/записи.
;    Все аргументы в регистрах:
;        DE - строка с именем файла, может содержать относительный или абсолютный путь к файлу.
;            в текущей реализации поддержан формат имен 8.3
;    Возвращаемые значения в регистрах:
;        А - ошибка. Если 0x00, то ошибки нет. 
;        B - хэндл файла, если нет ошибки.
;    
;Пример создания файла "pyraster.txt", расположенного в директории "../fu/ckco":
;        ...
;        LD DE,FILE_NAME
;        OS_CREATEHANDLE
;        OR A
;        JP NZ,ERR_EXIT    ;обработка ошибок
;        LD A,B
;        LD (FILE),A    ;сохраняем дескриптор
;        ...
;FILE_NAME:
;        DEFB "../fu/ckco/pyraster.txt",0    
;        ...
;        
;Примечания:
;Необходимо закрывать все открытые файлы. 
;Также желательно закрыть файл, как только он становится не нужен для чтения/записи.
;При создании файла указатель чтения/записи этого файла устанавливается на первый байт в файле.
;Не рекомендуется читать файл, открытый через OS_CREATEHANDLE! Лучше закройте его и откройте через OS_OPENHANDLE.
        macro OS_CREATEHANDLE ;DE = Drive/path/file ASCIIZ string ;out: B = new file handle, A=error
        ld c,CMD_CREATEHANDLE
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_CLOSEHANDLE **********************
;Закрывает открытый файл. 
;    Все аргументы в регистрах:
;        B - хэндл файла.
;    Возвращаемые значения в регистрах:
;        А - ошибка. Если 0x00, то ошибки нет. 
;    
;Пример закрытия файла:
;        ...
;        LD A,(FILE)
;        LD B,A
;        OS_CLOSEHANDLE
;        OR A
;        JP NZ,ERR_EXIT    ;обработка ошибок
;        ...
;
;Примечания:
;Необходимо закрывать все открытые файлы. 
;Также желательно закрыть файл, как только он становится не нужен для чтения/записи.
        macro OS_CLOSEHANDLE ;B = file handle, out: A=error
        ld c,CMD_CLOSEHANDLE
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_READHANDLE **********************
;Читает массив байтов из открытого файла. 
;    Все аргументы в регистрах:
;        B - хэндл файла.
;        DE - указатель на буфер, куда следует прочитать массив байтов.
;        HL - количество байтов, которые следует прочитать.
;    Возвращаемые значения в регистрах:
;        А - ошибка. Если 0x00, то ошибки нет.
;        HL - если ошибки нет, то содержит количество прочитанных байтов (если 0, то файл кончился).
;    
;Пример чтения из открытого файла:
;        ...
;        LD A,(FILE)
;        LD B,A
;        LD DE,READ_BUF
;        LD HL,150
;        OS_READHANDLE
;        OR A
;        JP NZ,ERR_EXIT    ;обработка ошибок
;        LD A,H
;        OR L
;        JP Z,END_READ    ;данных для чтения нет, либо указатель чтения\записи указывает на конец файла
;        ...
;READ_BUF
;        DEFS 1000
;Примечание: при чтении сдвигается (на количество прочитанных байт) 
;указатель на данные в файле, следующее чтение начнётся с позиции этого указателя.
        macro OS_READHANDLE ;B = file handle, DE = Buffer address, HL = Number of bytes to read, out: HL = Number of bytes actually read, A=error
        ld c,CMD_READHANDLE
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_WRITEHANDLE **********************
;Запись массива байтов в открытый файл. 
;    Все аргументы в регистрах:
;        B - хэндл файла.
;        DE - указатель на буфер, содержащий массив байтов, которые следует записать в файл
;        HL - количество байтов, которые следует записать
;    Возвращаемые значения в регистрах:
;        А - ошибка. Если 0x00, то ошибки нет.
;        HL - если ошибки нет, то содержит количество записанных байтов.
;    
;Пример записи в открытый файл:
;        ...
;        LD A,(FILE)
;        LD B,A
;        LD DE,BUF
;        LD HL,BUF_SIZE
;        OS_WRITEHANDLE
;        OR A
;        JP NZ,ERR_EXIT    ;обработка ошибок
;        ...
;BUF        DEFB "Hello Work!"
;BUF_SIZE EQU $-BUF
;
;Примечание: при записи сдвигается (на количество записанных байтов) 
;указатель на данные в файле, следующая запись начнётся с позиции этого указателя.
        macro OS_WRITEHANDLE ;B = file handle, DE = Buffer address, HL = Number of bytes to write, out: HL = Number of bytes actually written, A=error
        ld c,CMD_WRITEHANDLE
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_SEEKHANDLE **********************
;Перемещение указателя чтения/записи в файле.
;    Все аргументы в регистрах:
;        B - хэндл файла.
;        DEHL - нужное смещение относительно начала файла.
;    Возвращаемых значений нет.
;
;Примечание: в отличие от MSX-DOS, смещение всегда относительно начала файла (регистр A не влияет).
;Для чтения положения указателя см. функцию OS_TELLHANDLE.
;Для чтения размера файла см. функцию OS_GETFILESIZE.
        macro OS_SEEKHANDLE ;b=file handle, dehl=offset
        ld c,CMD_SEEKHANDLE
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_CHDIR **********************
;Сменить текущую директорию (в рамках текущего процесса).
;    Все аргументы в регистрах:
;        DE - указатель на строку с полным или относительным путём (можно без конечной косой черты).
;    Возвращаемые значения в регистрах:
;        А - ошибка. Если 0x00, то ошибки нет.
;
;Примечание: В отличие от MSX-DOS, в пути используются только прямые косые черты.
;Например: "e:/bin/".
        macro OS_CHDIR ;DE = Pointer to ASCIIZ string. Out A=error
        ld c,CMD_CHDIR
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_GETPATH **********************
;Прочитать текущий путь (в рамках текущего процесса).
;    Все аргументы в регистрах:
;        DE - указатель на буфер размером MAXPATH_sz, куда будет помещён путь (ASCIIZ).
;    Возвращаемые значения в регистрах:
;        HL - указатель на последний элемент пути в этом буфере
;
;Примечания:
;В MSX-DOS был буфер размером 64 байта, а в текущей реализации NedoOS MAXPATH_sz = 256.
;Путь возвращается без конечной косой черты, кроме случая корня диска.
;В отличие от MSX-DOS, в пути используются только прямые косые черты.
        macro OS_GETPATH ;DE = Pointer to MAXPATH_sz byte buffer ;out: DE = Filled in with whole path string (WITH DRIVE! Finished by slash only if root dir), HL = Pointer to start of last item
        ld c,CMD_GETPATH
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_RENAME **********************
;Переименовать файл или директорию.
;    Все аргументы в регистрах:
;        DE - старое имя, возможно с полным или относительным путём (ASCIIZ).
;        HL - новое имя, пока что требуется такой же путь, как в DE.
;    Возвращаемые значения в регистрах:
;        HL - указатель на последний элемент пути в этом буфере
;
;Примечания:
;В отличие от MSX-DOS, в новом имени пока что требуется такой же путь, как в DE (если там не было пути, то и в новом не надо).
        macro OS_RENAME ;DE = Drive/path/file ASCIIZ string, HL = New filename ASCIIZ string (NOT MSXDOS compatible! with Drive/path!) ;RENAME OR MOVE FILE
        ld c,CMD_RENAME
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_DELETE **********************
;Удалить файл.
;    Все аргументы в регистрах:
;        DE - имя файла, возможно с полным или относительным путём (ASCIIZ).
;    Возвращаемые значения в регистрах:
;        А - ошибка. Если 0x00, то ошибки нет.
        macro OS_DELETE ;DE = Drive/path/file ASCIIZ string, out: A = Error
        ld c,CMD_DELETE
        CALLBDOS_NOPARAM_A
        endm

;*********************** OS_PARSEFNAME **********************
;Перекодировать имя файла в формат CP/M (8 байт имени, 3 байта расширения).
;    Все аргументы в регистрах:
;        DE - имя файла в ASCIIZ.
;        HL - указатель на буфер под имя файла в формате CP/M.
;    Возвращаемые значения в регистрах:
;        DE - указатель на терминатор имени файла
;        HL - указатель на буфер под имя файла в формате CP/M.
;        A - всегда 0.
;
;Примечание: в отличие от MSX-DOS, не возвращаются флаги результата в регистре B.
        macro OS_PARSEFNAME ;de(dotname) -> hl(cpmname) ;out: de=pointer to termination character, hl=buffer filled in
        ld c,CMD_PARSEFNAME
        CALLBDOS_NOPARAM_A
        endm

;invented  
        macro OS_OPENDIR ;de=path (must be empty ASCIIZ for now)
        ld c,CMD_OPENDIR
	CALLBDOS_NOPARAM_A
        endm
        macro OS_READDIR 	;de=buf for FILINFO (if no LNAME, use FNAME), 0x00 in FILINFO_FNAME = end dir
        ld c,CMD_READDIR
	CALLBDOS_NOPARAM_A		;out in A=error(0 - no error, 4 - no more files, other - critical error)
        endm
        macro OS_HIDEFROMPARENT ;for tasks with their own screen handling ;hl=результат программы (родитель его получает по WAITPID)
        ld c,CMD_HIDEFROMPARENT
	CALLBDOS_NOPARAM_A
        endm
        macro OS_SETSTDINOUT ;b=id, e=stdin, d=stdout, h=stderr
        ld c,CMD_SETSTDINOUT
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr, l=hgt of stdout
        ld c,CMD_GETSTDINOUT
	CALLBDOS_NOPARAM_A
        endm
        macro OS_PLAYCOVOX ;hl=data (0xc000+, 0x00=end), de=pagetable (0x0000+), hx=delay (18=11kHz, 7=22kHz, 1=44kHz)
        ld c,CMD_PLAYCOVOX
	CALLBDOS_NOPARAM_A
        endm
        macro OS_SETMUSIC ;hl=muzaddr (0x4000..0xffff), a=muzpg (pages in 0x8000, 0xc000 are taken from current user memory)
        ld c,CMD_SETMUSIC
	CALLBDOS
        endm
        macro OS_READSECTORS ;b=drive, de=buffer, ixhl=sector number, a=count ;out: a=error
        ld c,CMD_READSECTORS
	CALLBDOS
        endm
        macro OS_WRITESECTORS ;b=drive, de=buffer, ixhl=sector number, a=count ;out: a=error
        ld c,CMD_WRITESECTORS
	CALLBDOS
        endm
        macro OS_GETFILESIZE ;b=handle, out: dehl=file size
        ld c,CMD_GETFILESIZE
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETFILINFO ;de=filename, hl=buf[FILINFO_sz] to get FILINFO
        ld c,CMD_GETFILINFO
	CALLBDOS_NOPARAM_A
        endm
        macro OS_SETBORDER ;e=0..15
        ld c,CMD_SETBORDER
	CALLBDOS_NOPARAM_A
        endm
        macro OS_SETWAITING ;set WAITING state for current task ;don't use directly!
        ld c,CMD_SETWAITING
	CALLBDOS_NOPARAM_A
        endm
        macro OS_NETSOCKET ;D=address family (2=inet, 23=inet6), E=socket type (0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip) ;out: L=SOCKET (if L < 0 then A=error)
	ld l,0x01
        ld c,CMD_WIZNETOPEN
	CALLBDOS_NOPARAM_A
        endm
        macro OS_NETSHUTDOWN;A=SOCKET ; out: if HL < 0 then A=error
	ld l,0x02
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_NETCONNECT;A=SOCKET, DE=sockaddr ptr {unsigned char sin_family /*net type*/; unsigned short sin_port; struct in_addr sin_addr /*4 bytes IP*/; char sin_zero[8];}; out: if HL < 0 then A=error
	ld l,0x03
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_ACCEPT;A=SOCKET; out: HL
	ld l,0x04
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_BIND;A=SOCKET, DE=sockaddr ptr {unsigned char sin_family /*net type*/; unsigned short sin_port; struct in_addr sin_addr /*4 bytes IP*/; char sin_zero[8];}
	ld l,0x05
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_LISTEN;A=SOCKET
	ld l,0x06
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_GETDNS;DE= ptr to DNS buffer(4 bytes)
	ld l,0x08
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_WIZNETCLOSE;A=SOCKET
        ld c,CMD_WIZNETCLOSE
	CALLBDOS
        endm
        macro OS_WIZNETREAD;A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) ; out: HL=count if HL < 0 then A=error
        ld c,CMD_WIZNETREAD
	CALLBDOS
        endm
        macro OS_WIZNETWRITE;A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) ; out: HL=count if HL < 0 then A=error
        ld c,CMD_WIZNETWRITE
	CALLBDOS
        endm
        macro OS_DROPAPP ;e=id
        ld c,CMD_DROPAPP
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETAPPMAINPAGES ;e=id ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id, a=error
        ld c,CMD_GETAPPMAINPAGES
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETMEMPORTS ;out: ix=memport0000, bc=memport4000, de=memport8000, hl=memportc000
        ld c,CMD_GETMEMPORTS
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETCONFIG  ;out: H=system drive, L= 1-Evo 2-ATM2 3-ATM3 6-p2.666 ;E=pgsys(system page) D= TR-DOS page
        ld c,CMD_GETCONFIG
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETXY ;out: de=yx ;GET CURSOR POSITION
        ld c,CMD_GETXY
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETTIME ;out: ix=date, hl=time
        ld c,CMD_GETTIME
        CALLBDOS_NOPARAM_A
        endm
        macro OS_GETFILETIME ;de=Drive/path/file ASCIIZ string, out: ix=date, hl=time
        ld c,CMD_GETFILETIME
        CALLBDOS_NOPARAM_A
        endm
        macro OS_SETFILETIME ;de=Drive/path/file ASCIIZ string, ix=date, hl=time
        ld c,CMD_SETFILETIME
        CALLBDOS_NOPARAM_A
        endm
        
;*********************** OS_TELLHANDLE **********************
;Чтение указателя чтения/записи в файле.
;    Все аргументы в регистрах:
;        B - хэндл файла.
;    Возвращаемые значения в регистрах:
;        DEHL - смещение относительно начала файла.
;
;Примечание: для чтения размера файла см. функцию OS_GETFILESIZE.
        macro OS_TELLHANDLE ;b=file handle, out: dehl=offset ;GET POSITION IN FILE
        ld c,CMD_TELLHANDLE
        CALLBDOS_NOPARAM_A
        endm

        macro OS_SCROLLUP ;de=topyx, hl=hgt,wid ;x, wid even ;TEXTMODE ONLY
        ld c,CMD_SCROLLUP
        CALLBDOS_NOPARAM_A
        endm
        macro OS_SCROLLDOWN ;de=topyx, hl=hgt,wid ;x, wid even ;TEXTMODE ONLY
        ld c,CMD_SCROLLDOWN
        CALLBDOS_NOPARAM_A
        endm
        macro OS_SETMAINPAGE ;e=page for 0x0000
        ld c,CMD_SETMAINPAGE
        CALLBDOS_NOPARAM_A
        endm
        macro OS_SETSYSDRV ;out: a!=0 => not mounted, l=number of drives
        ld c,CMD_SETSYSDRV
        CALLBDOS_NOPARAM_A
        endm
        macro OS_MKDIR ;DE = Pointer to ASCIIZ string, out: a
        ld c,CMD_MKDIR
        CALLBDOS_NOPARAM_A
        endm
        macro OS_CHECKPID ;e=id ;check if this child(!) app exists, out: a!=0 => OK, or else a=0
        ld c,CMD_CHECKPID
        CALLBDOS_NOPARAM_A
        endm
        macro OS_FREEZEAPP ;e=id ;disable app and make non-graphic ;сейчас делает то же, что OS_SETWAITING делает себе
        ld c,CMD_FREEZEAPP
        CALLBDOS_NOPARAM_A
        endm
        macro OS_GETATTR ;DEPRECATED!!! ;out: a ;READ ATTR AT CURSOR POSITION
        ld c,CMD_GETATTR
        CALLBDOS_NOPARAM_A
        endm
        macro OS_MOUNT ;e=drive, out: a
        ld c,CMD_MOUNT
        CALLBDOS_NOPARAM_A
        endm
        macro OS_GETKEYMATRIX ;out: bcdehlix = halfrows cs...space
        ld c,CMD_GETKEYMATRIX
        CALLBDOS_NOPARAM_A
        endm
        macro OS_GETTIMER ;out: dehl=timer
        ld c,CMD_GETTIMER
	CALLBDOS_NOPARAM_A
        endm
        macro OS_YIELD ;schedule to another app (use YIELD macro instead of HALT!!!)
        ld c,CMD_YIELD
	CALLBDOS_NOPARAM_A
        endm
        macro OS_RUNAPP ;e=id ;ACTIVATE DISABLED APP
        ld c,CMD_RUNAPP
	CALLBDOS_NOPARAM_A
        endm
        macro OS_NEWAPP ;out: b=id, a=error, dehl=newapp pages in 0000,4000,8000,c000 ;MAKE NEW DISABLED APP
        ld c,CMD_NEWAPP
	CALLBDOS_NOPARAM_A
        endm
        macro OS_PRATTR ;e=color byte ;DRAW ATTR AT CURSOR POSITION
        ld c,CMD_PRATTR
	CALLBDOS_NOPARAM_A
        endm
        macro OS_CLS ;e=color byte
        ld c,CMD_CLS
	CALLBDOS_NOPARAM_A
        endm
        macro OS_SETCOLOR ;e=color byte
        ld c,CMD_SETCOLOR
	CALLBDOS_NOPARAM_A
        endm
        macro OS_SETXY ;de=yx ;SET CURSOR POSITION
        ld c,CMD_SETXY
	CALLBDOS_NOPARAM_A
        endm

;*********************** OS_SETGFX **********************
;Устанавливает видеорежим и переключает фокус на текущий процесс.
;При старте процесса вывод на экран, процессом, недоступен без установки видеорежима.
;    Все аргументы в регистрах:
;        E - видеорежим (+8, если нужно выключить турбо, +0x80, если нужно автоматически запоминать и восстанавливать экранные страницы), допустимы следующие значения:
;            0 - EGA 
;            2 - Аппаратный мультиколор
;            3 - 6912
;            6 - текстовый видеорежим
;            -1 - отключает видеовывод и переключает фокус на следующий процесс
;    Возвращаемые значения в регистрах:
;        E - видеорежим до вызова OS_SETGFX
;    
;Пример установки текстового видеорежима:
;        LD E,6
;        OS_SETGFX
        macro OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld c,CMD_SETGFX
	CALLBDOS_NOPARAM_A
        endm
        
        macro OS_SETPAL ;de=palette (32 bytes)
        ld c,CMD_SETPAL
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld c,CMD_GETMAINPAGES
	CALLBDOS_NOPARAM_A
        endm
        macro OS_NEWPAGE ;out: a=0 (OK)/!=0 (fail), e=page
        ld c,CMD_NEWPAGE
	CALLBDOS_NOPARAM_A
        endm
        macro OS_DELPAGE ;e=page ;GIVE SOME PAGE BACK TO THE OS
        ld c,CMD_DELPAGE
	CALLBDOS_NOPARAM_A
        endm
        macro OS_GETPAGEOWNER ;e=page ;out: e=owner id (0=free, 0xff=system)
        ld c,CMD_GETPAGEOWNER
	CALLBDOS_NOPARAM_A
        endm
        macro OS_SETSCREEN ;e=screen=0..1
        ld c,CMD_SETSCREEN
	CALLBDOS_NOPARAM_A
        endm
        macro OS_YIELDKEEP ;schedule to another app, can return in this frame
        ld c,CMD_YIELDKEEP
	CALLBDOS_NOPARAM_A
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        macro STANDARDPAL ;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
        dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;последующие макросы будут убраны (они временно для переделки программ под term)
        macro SETXY_ ;set cursor position (in: de=YX, top left is 0;0)
        ;OS_SETXY
        call setxy
        endm

        macro SETX_ ;set cursor X position (in: e=X, left is 0)
        call setx
        endm

        macro CLS_ ;clear visible area of terminal
        ;ld e,0
        ;OS_CLS
        call clearterm
        endm

        macro PRCHAR_ ;send char to stdout (in: A=char)
        ;OS_PRCHAR
        call sendchar
        endm

        macro GETCHAR_ ;read char from stdin (out: A=char, CY=error)
        ;OS_GETKEY
        call receivechar
        endm

        macro GETKEY_ ;read key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
        ;OS_GETKEY
        call getkey;receivekey
        endm

        macro SETCOLOR_ ;setcolor (macro SETCOLOR_) - set color attribute (in: d=paper, e=ink)
        ;ld a,d
        ;add a,a
        ;add a,a
        ;add a,a
        ;or e
        ;ld e,a
        ;OS_SETCOLOR
        call setcolor
        endm

