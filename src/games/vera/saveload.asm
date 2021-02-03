;Загрузка/запись состояния игры

;Загрузка отложенного состояния
LOAD
;Ищем файл
        CALL FILE
        LD C,#18
        CALL TRDOS
        JP NZ,ERROR
        LD C,10
        CALL TRDOS
        LD A,C
        INC C
        JP Z,ERROR ;Нет файла
;Высчитываем адрес файла (сектор,дорожка)
        LD C,8
        CALL TRDOS
        LD A,(#5CDD+13)
        CP 57 ;размер состояния в секторах
        JP NZ,ERROR
        LD DE,(#5CDD+14)
;Считываем карту и массив
        LD HL,VIDEOS
        LD BC,#3005
        CALL TRDOS
        JP NZ,ERROR ;ошибка
;Считываем переменные
        LD DE,(#5CF4)
        LD HL,VARS
        LD BC,#0605
        CALL TRDOS
        JP NZ,ERROR ;ошибка
;Считываем спрайт дня/ночи
;      LD A,PG_VIEW
        CALL PAGE_PG_VIEW
        LD DE,(#5CF4)
        LD HL,NG
        LD BC,#0305
        CALL TRDOS
        JP NZ,ERROR ;ошибка
        JP GAME

;Сохранение состояния
SAVE
;Ищем файл
        LD A,PG_MAP
        CALL PAGE
        CALL FILE
        LD C,#18
        CALL TRDOS
        JP NZ,ERROR2
        LD C,10
        CALL TRDOS
        LD A,C
        INC C
        JR Z,NOFILE
;Высчитываем адрес файла (сектор,дорожка)
        LD C,8
        CALL TRDOS
        LD A,(#5CDD+13)
        CP 57 ;размер состояния в секторах
        JP NZ,ERROR2
        LD DE,(#5CDD+14)
;Записываем карту и массив
        LD HL,MAP
        LD BC,#3006
        CALL TRDOS
        JP NZ,ERROR2 ;ошибка
;Записываем переменные
        LD DE,(#5CF4)
SAVE2   LD HL,VARS
        LD BC,#0606
        CALL TRDOS
        JP NZ,ERROR2 ;ошибка
;Записываем спрайт дня/ночи
;      LD A,PG_VIEW
        CALL PAGE_PG_VIEW
        LD DE,(#5CF4)
        LD HL,NG
        LD BC,#0306
        CALL TRDOS
        JP NZ,ERROR2 ;ошибка
        JP SAVE_OK

;Читаем системный сектор
NOFILE  LD DE,#0008
        LD HL,CAT
        LD BC,#0105
        CALL TRDOS
        JP NZ,ERROR2   ;ошибка
        LD A,(CAT+228) ;кол-во файлов
        CP 128
        JP NC,ERROR2
        LD HL,(CAT+229);кол-во своб. секторов
        LD DE,57
        AND A
        SBC HL,DE
        JP C,ERROR2

;Записываем карту и массив+мусор
        LD HL,MAP
        LD DE,#3900
        LD C,#0B
        CALL TRDOS
        JP NZ,ERROR2 ;ошибка
;Увеличиваем адрес на диске вперед на 48 секторов (3 трека)
        LD DE,(CAT+225)
        INC D,D,D

        JR SAVE2

FILE    LD HL,FILENAM
        LD DE,#5CDD
        LD BC,9
        LDIR 
        RET 

TRDOS   EX AF,AF' ;'
        XOR A
        LD (23823),A  ;Обнуляем код
        LD (23824),A  ;ошибки TR-DOS
        LD (23570),A  ;Блокируем поток
        EX AF,AF' ;'
        PUSH HL
        LD HL,(23613)
        LD (DOS_ERR+1),HL
        LD HL,DOS_ERR ;Устанавливаем
        EX (SP),HL    ;свой обработчик
        LD (23613),SP
        JP #3D13
DOS_ERR LD HL,0
        LD (23613),HL
        LD A,6        ;Восстанавливаем
        LD (23570),A  ;поток
        LD A,(23838)
        LD B,A
        LD A,(23823)  ;Проверяем
        AND A         ;была ли ошибка
        RET Z
        CP B
        RET Z
        INC A
        RET Z
ERR     LD B,10
        LD A,2
        OUT (254),A
        HALT 
        DJNZ $-1
        XOR A
        OUT (254),A
        RET 

FILENAM DB "VERASAVEC" ;TODO HDD

CAT
