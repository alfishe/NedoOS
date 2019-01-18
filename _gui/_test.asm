;OPERATION ++ ;Line=4
	LD HL,[a]
	INC HL
	LD [a],HL
;//VAR PBYTE pp = &(pzz1->ba); //скобки обязательны!
;PUSHVAR pzz1 ;Line=36
	LD HL,[pzz1]
;PUSHNUM zzz.ba ;Line=36
;OPERATION + ;Line=36
;PUSHCONST zzz.ba ;Line=36
	LD DE,zzz.ba
	ADD HL,DE
;OPERATION --byaddr ;Line=36
	DEC [HL]
strings.A.
	DB "str1"
	DB 0
strings.B.
	DB "str2"
	DB 0
;//"str3"
;PUSHNUM 1 ;Line=48
;POPVAR ui ;Line=49
;PUSHCONST 1 ;Line=49
	LD HL,1
	LD [ui],HL
;PUSHNUM 7 ;Line=49
;OPERATION cast 1>1 ;Line=49
;POPVAR ui ;Line=51
;PUSHCONST 7 ;Line=51
	LD HL,7
	LD [ui],HL
;//pb = (PBYTE)pcc
;PUSHVAR psss ;Line=64
	LD HL,[psss]
;PUSHNUM sss.lb ;Line=64
;OPERATION + ;Line=64
;PUSHCONST sss.lb ;Line=64
	LD DE,sss.lb
	ADD HL,DE
;PEEK ;Line=64
	LD E,[HL]
	INC HL
	LD D,[HL]
	INC HL
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
;POPVAR lb ;Line=64
	LD [lb],DE
	LD [lb+2],HL
;PUSHVAR psss ;Line=65
	LD HL,[psss]
;PUSHNUM sss.pzzz ;Line=65
;OPERATION + ;Line=65
;PUSHCONST sss.pzzz ;Line=65
	LD DE,sss.pzzz
	ADD HL,DE
;PEEK ;Line=65
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
;PUSHNUM zzz.ba ;Line=65
;OPERATION + ;Line=65
;PUSHCONST zzz.ba ;Line=65
	LD DE,zzz.ba
	ADD HL,DE
;PEEK ;Line=65
	LD A,[HL]
;OPERATION cast 0>2 ;Line=65
	LD L,A
	LD H,0
;POPVAR ia ;Line=65
	LD [ia],HL
;PUSHVAR psss ;Line=66
	LD HL,[psss]
;PUSHNUM sss.a ;Line=66
;OPERATION + ;Line=66
;PUSHCONST sss.a ;Line=66
	LD DE,sss.a
	ADD HL,DE
;PUSHNUM 7 ;Line=66
;OPERATION cast 1>2 ;Line=66
;POKE ;Line=66
;PUSHCONST 7 ;Line=66
	LD DE,7
	LD [HL],E
	INC HL
	LD [HL],D
;PUSHVAR pcc ;Line=67
	LD HL,[pcc]
;OPERATION cast 21>16 ;Line=67
;POPVAR pb ;Line=68
	LD [pb],HL
;PUSHVAR psss ;Line=68
	LD HL,[psss]
;PUSHNUM sss.pzzz ;Line=68
;OPERATION + ;Line=68
;PUSHCONST sss.pzzz ;Line=68
	LD DE,sss.pzzz
	ADD HL,DE
;PEEK ;Line=68
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
;PUSHNUM zzz.ba ;Line=68
;OPERATION + ;Line=68
;PUSHCONST zzz.ba ;Line=68
	LD DE,zzz.ba
	ADD HL,DE
;PUSHNUM 0x00 ;Line=68
;POKE ;Line=68
;PUSHCONST 0x00 ;Line=68
	LD A,0x00
	LD [HL],A
;PUSHVAR psss ;Line=69
	LD HL,[psss]
;PUSHNUM sss.psss ;Line=69
;OPERATION + ;Line=69
;PUSHCONST sss.psss ;Line=69
	LD DE,sss.psss
	ADD HL,DE
;PEEK ;Line=69
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
;PUSHNUM sss.a ;Line=69
;OPERATION + ;Line=69
;PUSHCONST sss.a ;Line=69
	LD DE,sss.a
	ADD HL,DE
;PUSHNUM 5 ;Line=69
;OPERATION cast 1>2 ;Line=69
;POKE ;Line=69
;PUSHCONST 5 ;Line=69
	LD DE,5
	LD [HL],E
	INC HL
	LD [HL],D
recpr
;FUNC ;Line=71
;ENDFUNC ;Line=75
	RET
prosto
;FUNC ;Line=75
;accesspar=recpr.A. ;Line=77
;PUSHPAR recpr.A. ;Line=77
	LD A,[recpr.A.]
;PUSHNUM 0x10 ;Line=77
;POPVAR recpr.A. ;Line=77
;PUSHCONST 0x10 ;Line=77
	LD E,0x10
	LD L,A
	LD A,E
	LD [recpr.A.],A
;CALL recpr ;Line=77
	PUSH HL
	CALL recpr
;POPPAR ;Line=77
	POP HL
	LD A,L
	LD [recpr.A.],A
;/// imported
;ENDFUNC ;Line=81
	RET
;//#define _T_FLOAT (TYPE)(0x06)
;//#define _T_FARPOI (TYPE)(0x30) /**накладывается на тип по OR (для переменных)
;//todo типность можно убрать в _istype (обнулять при старте и после тайпкаста)
;//тогда будет 2 свободных бита (0x08, 0x80)
;//длина без терминатора!
;/**, UINT s2len*/
;//длина без терминатора!
;//длина без терминатора!
;//PROC writeuint FORWARD(PBYTE file, UINT i);
;//PROC writelong FORWARD(PBYTE file, LONG l);
;//PROC closewrite FORWARD(PBYTE file);
;//FUNC BOOL comparedesc FORWARD(PCHAR filename, PBYTE desc);
;//do define:
;//FCB1 ;aligned ;len=0x0200*files
;//DOSBUF ;aligned ;len=0x100
;//EXTERN UINT _curlnbeg; //номер строки на момент начала токена //для read, emi
;//EXTERN BOOL _cmts; //для read, emit
;//#ifdef DOUBLES
;//размеры типов у таргета
;//CONST BYTE _SZ_REG;
;//#endif
;//пропускать строки, кроме начинающихся с #
;//текущее слово
;//префикс текущего слова (остаток - в _tword)
;//название текущей процедуры (с учётом модуля)
;//название вызываемой процедуры (с учётом модуля)
;//метка без префикса (для таблицы меток)
;//автометка
;//в addlbl нельзя объединить ncells с callee
;//префикс текущего слова (остаток - в _tword)
;//название текущей процедуры (с учётом модуля)
;//название вызываемой процедуры (с учётом модуля)
;//метка без префикса (для таблицы меток)
;//автометка
;//число элементов
;//число пробелов после прочитанной команды
;//текущий номер строки
;//сколько было EOL с прошлого раза
;//joined или callee
;//EXTERN BYTE _sz;
;//math (без машинного кода)
;//PROC cmdshl1 FORWARD();
;//PROC cmdshr1 FORWARD();
;//сдвигает соответственно типу и прибавляет
;//сравнения (без машинного кода)
;//генерация вызовов и переходов (без машинного кода)
;//для рекурсивных процедур (сохранение параметров внутри или снаружи)
;//после сохранения локальной переменной рекурсивной процедуры
;//для рекурсивных процедур (восстановление параметров внутри или снаружи)
;//восстановление результата после снятия локалов со стека и выход
;//костыль для константных массивов строк TODO
;//PROC var_dl FORWARD();
;//взять название типа структуры в joined (сразу после lbltype)
;//вернуть тип метки _name
;//удалить метку _name
;/**, PCHAR size, UINT lensize*/
;//(_name)
;//перед началом локальных меток
;//после локальных меток (забыть их)
;////
;/**максимальное число параметров в вызове функции*/
;//состояние компилятора (плюс ещё состояния commands и codetg):
;//номер автометки
;//номер автометки для выхода из цикла while/repeat
;//глубина вложенности пространства имён (число точек в префиксе)
;//глубина выражения (верхний уровень == 1)
;//текущая объявляемая процедура рекурсивная
;//была команда return (после неё нельзя команды в рекурсивной функции) //сохран
;//тип функции (для return) //сохраняются в func
;//текущий тип
;//локальная ли прочитанная переменная
;//текущая объявляемая переменная, константный массив/структура, процедура/функц
;//флаг "блок не окончен" в eatcmd
;//число открытых файлов
;//
err_tword
;FUNC ;Line=247
;accesspar=errstr.A. ;Line=249
;PUSHVAR err_tword.s ;Line=249
	LD HL,[err_tword.s]
;POPVAR errstr.A. ;Line=249
	LD [errstr.A.],HL
;CALL errstr ;Line=249
	CALL errstr
;accesspar=errstr.A. ;Line=250
;PUSHNUM err_tword.B. ;Line=250
;POPVAR errstr.A. ;Line=250
;PUSHCONST err_tword.B. ;Line=250
	LD HL,err_tword.B.
	LD [errstr.A.],HL
;CALL errstr ;Line=250
	CALL errstr
;accesspar=errstr.A. ;Line=250
;PUSHVAR _tword ;Line=250
	LD HL,[_tword]
;POPVAR errstr.A. ;Line=250
	LD [errstr.A.],HL
;CALL errstr ;Line=250
	CALL errstr
;accesspar=err.A. ;Line=250
;PUSHNUM '\'' ;Line=250
;POPVAR err.A. ;Line=250
;PUSHCONST '\'' ;Line=250
	LD A,'\''
	LD [err.A.],A
;CALL err ;Line=250
	CALL err
;CALL enderr ;Line=250
	CALL enderr
;ENDFUNC ;Line=253
	RET
doexp
;FUNC ;Line=253
;PUSHVAR _isexp ;Line=255
	LD A,[_isexp]
;JUMP IF FALSE doexp.B. ;Line=255
	OR A
	JP Z,doexp.B.
;accesspar=asmstr.A. ;Line=256
;PUSHNUM doexp.D. ;Line=256
;POPVAR asmstr.A. ;Line=256
;PUSHCONST doexp.D. ;Line=256
	LD HL,doexp.D.
	LD [asmstr.A.],HL
;CALL asmstr ;Line=256
	CALL asmstr
;accesspar=asmstr.A. ;Line=256
;PUSHVAR doexp.s ;Line=256
	LD HL,[doexp.s]
;POPVAR asmstr.A. ;Line=256
	LD [asmstr.A.],HL
;CALL asmstr ;Line=256
	CALL asmstr
;CALL endasm ;Line=256
	CALL endasm
doexp.B.
;ENDFUNC ;Line=260
	RET
eat
;FUNC ;Line=260
;PUSHVAR _tword ;Line=262
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=262
;PEEK ;Line=262
	LD A,[HL]
;PUSHVAR eat.c ;Line=262
	LD L,A
	LD A,[eat.c]
;OPERATION != ;Line=262
	SUB L
;JUMP IF FALSE eat.B. ;Line=262
	JP Z,eat.B.
;accesspar=err.A. ;Line=263
;PUSHVAR eat.c ;Line=263
	LD A,[eat.c]
;POPVAR err.A. ;Line=263
	LD [err.A.],A
;CALL err ;Line=263
	CALL err
;accesspar=errstr.A. ;Line=263
;PUSHNUM eat.D. ;Line=263
;POPVAR errstr.A. ;Line=263
;PUSHCONST eat.D. ;Line=263
	LD HL,eat.D.
	LD [errstr.A.],HL
;CALL errstr ;Line=263
	CALL errstr
;accesspar=errstr.A. ;Line=263
;PUSHVAR _tword ;Line=263
	LD HL,[_tword]
;POPVAR errstr.A. ;Line=263
	LD [errstr.A.],HL
;CALL errstr ;Line=263
	CALL errstr
;accesspar=err.A. ;Line=263
;PUSHNUM '\'' ;Line=263
;POPVAR err.A. ;Line=263
;PUSHCONST '\'' ;Line=263
	LD A,'\''
	LD [err.A.],A
;CALL err ;Line=263
	CALL err
;CALL enderr ;Line=263
	CALL enderr
;//err_tword(s);
eat.B.
;CALL rdword ;Line=266
	CALL rdword
;ENDFUNC ;Line=269
	RET
jdot
;FUNC ;Line=269
;accesspar=stradd.A. ;Line=271
;PUSHVAR _joined ;Line=271
	LD HL,[_joined]
;POPVAR stradd.A. ;Line=271
	LD [stradd.A.],HL
;accesspar=stradd.B. ;Line=271
;PUSHVAR _lenjoined ;Line=271
	LD HL,[_lenjoined]
;POPVAR stradd.B. ;Line=271
	LD [stradd.B.],HL
;accesspar=stradd.C. ;Line=271
;PUSHNUM '.' ;Line=271
;POPVAR stradd.C. ;Line=271
;PUSHCONST '.' ;Line=271
	LD A,'.'
	LD [stradd.C.],A
;CALL stradd ;Line=271
	CALL stradd
;POPVAR _lenjoined ;Line=271
	LD [_lenjoined],HL
;PUSHVAR _joined ;Line=272
	LD HL,[_joined]
;PUSHVAR _lenjoined ;Line=272
	LD DE,[_lenjoined]
;OPERATION +poi ;Line=272
	ADD HL,DE
;PUSHNUM '\0' ;Line=272
;POKE ;Line=272
;PUSHCONST '\0' ;Line=272
	LD A,'\0'
	LD [HL],A
;//strclose(_joined, _lenjoined);
;ENDFUNC ;Line=275
	RET
gendig
;FUNC ;Line=277
;PUSHNUM 'A' ;Line=280
;OPERATION cast 5>0 ;Line=280
;POPVAR gendig.dig ;Line=280
;PUSHCONST 'A' ;Line=280
	LD A,'A'
	LD [gendig.dig],A
gendig.B.
;PUSHVAR _genn ;Line=281
	LD HL,[_genn]
;PUSHVAR gendig.d ;Line=281
	LD DE,[gendig.d]
;OPERATION >= ;Line=281
	LD A,L
	SUB E
	LD A,H
	SBC A,D
;JUMP IF FALSE gendig.C. ;Line=281
	JP C,gendig.C.
;PUSHVAR _genn ;Line=282
	LD HL,[_genn]
;PUSHVAR gendig.d ;Line=282
	LD DE,[gendig.d]
;OPERATION - ;Line=282
	OR A
	SBC HL,DE
;POPVAR _genn ;Line=282
	LD [_genn],HL
;OPERATION ++ ;Line=283
;PUSHNUM gendig.dig ;Line=283
;PUSHCONST gendig.dig ;Line=283
	LD HL,gendig.dig
	INC [HL]
;PUSHNUM TRUE ;Line=284
;POPVAR _wasdig ;Line=284
;PUSHCONST TRUE ;Line=284
	LD A,TRUE
	LD [_wasdig],A
;JUMP gendig.B. ;Line=285
	JP gendig.B.
gendig.C.
;PUSHVAR _wasdig ;Line=286
	LD A,[_wasdig]
;JUMP IF FALSE gendig.D. ;Line=286
	OR A
	JP Z,gendig.D.
;accesspar=stradd.A. ;Line=287
;PUSHVAR _joined ;Line=287
	LD HL,[_joined]
;POPVAR stradd.A. ;Line=287
	LD [stradd.A.],HL
;accesspar=stradd.B. ;Line=287
;PUSHVAR _lenjoined ;Line=287
	LD HL,[_lenjoined]
;POPVAR stradd.B. ;Line=287
	LD [stradd.B.],HL
;accesspar=stradd.C. ;Line=287
;PUSHVAR gendig.dig ;Line=287
	LD A,[gendig.dig]
;OPERATION cast 0>5 ;Line=287
;POPVAR stradd.C. ;Line=287
	LD [stradd.C.],A
;CALL stradd ;Line=287
	CALL stradd
;POPVAR _lenjoined ;Line=287
	LD [_lenjoined],HL
gendig.D.
;ENDFUNC ;Line=291
	RET
jautonum
;FUNC ;Line=291
;PUSHVAR jautonum.n ;Line=293
	LD HL,[jautonum.n]
;POPVAR _genn ;Line=293
	LD [_genn],HL
;PUSHNUM TRUE ;Line=294
;POPVAR _wasdig ;Line=294
;PUSHCONST TRUE ;Line=294
	LD A,TRUE
	LD [_wasdig],A
;PUSHVAR jautonum.n ;Line=295
	LD HL,[jautonum.n]
;PUSHNUM 0 ;Line=295
;OPERATION != ;Line=295
;PUSHCONST 0 ;Line=295
	LD DE,0
	OR A
	SBC HL,DE
;JUMP IF FALSE jautonum.B. ;Line=295
	JP Z,jautonum.B.
;PUSHNUM FALSE ;Line=296
;POPVAR _wasdig ;Line=296
;PUSHCONST FALSE ;Line=296
	LD A,FALSE
	LD [_wasdig],A
;accesspar=gendig.A. ;Line=297
;PUSHNUM 676 ;Line=297
;POPVAR gendig.A. ;Line=297
;PUSHCONST 676 ;Line=297
	LD HL,676
	LD [gendig.A.],HL
;CALL gendig ;Line=297
	CALL gendig
;accesspar=gendig.A. ;Line=298
;PUSHNUM 26 ;Line=298
;POPVAR gendig.A. ;Line=298
;PUSHCONST 26 ;Line=298
	LD HL,26
	LD [gendig.A.],HL
;CALL gendig ;Line=298
	CALL gendig
jautonum.B.
;accesspar=gendig.A. ;Line=300
;PUSHNUM 1 ;Line=300
;POPVAR gendig.A. ;Line=300
;PUSHCONST 1 ;Line=300
	LD HL,1
	LD [gendig.A.],HL
;CALL gendig ;Line=300
	CALL gendig
;CALL jdot ;Line=301
	CALL jdot
;ENDFUNC ;Line=304
	RET
genjplbl
;FUNC ;Line=304
;accesspar=strcopy.A. ;Line=306
;PUSHVAR _title ;Line=306
	LD HL,[_title]
;POPVAR strcopy.A. ;Line=306
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=306
;PUSHVAR _lentitle ;Line=306
	LD HL,[_lentitle]
;POPVAR strcopy.B. ;Line=306
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=306
;PUSHVAR _joined ;Line=306
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=306
	LD [strcopy.C.],HL
;CALL strcopy ;Line=306
	CALL strcopy
;POPVAR _lenjoined ;Line=306
	LD [_lenjoined],HL
;accesspar=jautonum.A. ;Line=307
;PUSHVAR genjplbl.n ;Line=307
	LD HL,[genjplbl.n]
;POPVAR jautonum.A. ;Line=307
	LD [jautonum.A.],HL
;CALL jautonum ;Line=307
	CALL jautonum
;ENDFUNC ;Line=310
	RET
jtitletword
;FUNC ;Line=310
;accesspar=strcopy.A. ;Line=312
;PUSHVAR _title ;Line=312
	LD HL,[_title]
;POPVAR strcopy.A. ;Line=312
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=312
;PUSHVAR _lentitle ;Line=312
	LD HL,[_lentitle]
;POPVAR strcopy.B. ;Line=312
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=312
;PUSHVAR _joined ;Line=312
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=312
	LD [strcopy.C.],HL
;CALL strcopy ;Line=312
	CALL strcopy
;POPVAR _lenjoined ;Line=312
	LD [_lenjoined],HL
;//_lenjoined = strjoin(/**to=*/_joined, 0/**strclear(_joined)*/, _title);
;/**to=*/
;accesspar=strjoin.A. ;Line=313
;PUSHVAR _joined ;Line=313
	LD HL,[_joined]
;POPVAR strjoin.A. ;Line=313
	LD [strjoin.A.],HL
;accesspar=strjoin.B. ;Line=313
;PUSHVAR _lenjoined ;Line=313
	LD HL,[_lenjoined]
;POPVAR strjoin.B. ;Line=313
	LD [strjoin.B.],HL
;accesspar=strjoin.C. ;Line=313
;PUSHVAR _tword ;Line=313
	LD HL,[_tword]
;POPVAR strjoin.C. ;Line=313
	LD [strjoin.C.],HL
;CALL strjoin ;Line=313
	CALL strjoin
;POPVAR _lenjoined ;Line=313
	LD [_lenjoined],HL
;PUSHVAR _joined ;Line=314
	LD HL,[_joined]
;PUSHVAR _lenjoined ;Line=314
	LD DE,[_lenjoined]
;OPERATION +poi ;Line=314
	ADD HL,DE
;PUSHNUM '\0' ;Line=314
;POKE ;Line=314
;PUSHCONST '\0' ;Line=314
	LD A,'\0'
	LD [HL],A
;//strclose(_joined, _lenjoined);
;ENDFUNC ;Line=317
	RET
eattype
;FUNC ;Line=317
;//todo _t?
;accesspar=strcopy.A. ;Line=320
;PUSHVAR _tword ;Line=320
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=320
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=320
;PUSHVAR _lentword ;Line=320
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=320
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=320
;PUSHVAR _name ;Line=320
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=320
	LD [strcopy.C.],HL
;CALL strcopy ;Line=320
	CALL strcopy
;POPVAR _lenname ;Line=320
	LD [_lenname],HL
;CALL lbltype ;Line=321
	CALL lbltype
;PUSHNUM _T_TYPE ;Line=321
;INV ;Line=321
;PUSHCONST _T_TYPE ;Line=321
	LD E,_T_TYPE
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=321
	AND L
;POPVAR eattype.t ;Line=321
	LD [eattype.t],A
;PUSHVAR _cnext ;Line=322
	LD A,[_cnext]
;PUSHNUM '*' ;Line=322
;OPERATION == ;Line=322
	SUB '*'
;JUMP IF FALSE eattype.A. ;Line=322
	JP NZ,eattype.A.
;PUSHVAR eattype.t ;Line=323
	LD A,[eattype.t]
;PUSHNUM _T_POI ;Line=323
;OPERATION | ;Line=323
;PUSHCONST _T_POI ;Line=323
	LD E,_T_POI
	OR E
;POPVAR eattype.t ;Line=323
	LD [eattype.t],A
;PUSHNUM _SZ_REG ;Line=324
;OPERATION cast 0>1 ;Line=324
;PUSHCONST _SZ_REG ;Line=324
	LD A,_SZ_REG
	LD L,A
	LD H,0
;POPVAR _varsz ;Line=324
	LD [_varsz],HL
;CALL rdword ;Line=325
	CALL rdword
;//use *
eattype.A.
;CALL rdword ;Line=327
	CALL rdword
;PUSHVAR eattype.t ;Line=328
	LD A,[eattype.t]
;RESULT ;Line=328
;ENDFUNC ;Line=331
	RET
doprefix
;FUNC ;Line=331
;//склеить n слов типа 'word.' из title в prefix (name без префикса)
;PUSHNUM 0 ;Line=333
;POPVAR _lenprefix ;Line=333
;PUSHCONST 0 ;Line=333
	LD HL,0
	LD [_lenprefix],HL
;//strclear(_prefix)
doprefix.B.
;PUSHVAR doprefix.nb ;Line=334
	LD A,[doprefix.nb]
;PUSHNUM 0x00 ;Line=334
;OPERATION > ;Line=334
;PUSHCONST 0x00 ;Line=334
	LD E,0x00
	LD L,A
	LD A,E
	SUB L
;JUMP IF FALSE doprefix.C. ;Line=334
	JP NC,doprefix.C.
;//перебираем слова
;/**to=*/
;accesspar=strjoineol.A. ;Line=335
;PUSHVAR _prefix ;Line=335
	LD HL,[_prefix]
;POPVAR strjoineol.A. ;Line=335
	LD [strjoineol.A.],HL
;accesspar=strjoineol.B. ;Line=335
;PUSHVAR _lenprefix ;Line=335
	LD HL,[_lenprefix]
;POPVAR strjoineol.B. ;Line=335
	LD [strjoineol.B.],HL
;accesspar=strjoineol.C. ;Line=335
;PUSHVAR _title ;Line=335
	LD HL,[_title]
;PUSHVAR _lenprefix ;Line=335
	LD DE,[_lenprefix]
;OPERATION +poi ;Line=335
	ADD HL,DE
;POPVAR strjoineol.C. ;Line=335
	LD [strjoineol.C.],HL
;accesspar=strjoineol.D. ;Line=335
;PUSHNUM '.' ;Line=335
;POPVAR strjoineol.D. ;Line=335
;PUSHCONST '.' ;Line=335
	LD A,'.'
	LD [strjoineol.D.],A
;CALL strjoineol ;Line=335
	CALL strjoineol
;POPVAR _lenprefix ;Line=335
	LD [_lenprefix],HL
;accesspar=stradd.A. ;Line=336
;PUSHVAR _prefix ;Line=336
	LD HL,[_prefix]
;POPVAR stradd.A. ;Line=336
	LD [stradd.A.],HL
;accesspar=stradd.B. ;Line=336
;PUSHVAR _lenprefix ;Line=336
	LD HL,[_lenprefix]
;POPVAR stradd.B. ;Line=336
	LD [stradd.B.],HL
;accesspar=stradd.C. ;Line=336
;PUSHNUM '.' ;Line=336
;POPVAR stradd.C. ;Line=336
;PUSHCONST '.' ;Line=336
	LD A,'.'
	LD [stradd.C.],A
;CALL stradd ;Line=336
	CALL stradd
;POPVAR _lenprefix ;Line=336
	LD [_lenprefix],HL
;OPERATION -- ;Line=337
;PUSHNUM doprefix.nb ;Line=337
;PUSHCONST doprefix.nb ;Line=337
	LD HL,doprefix.nb
	DEC [HL]
;JUMP doprefix.B. ;Line=338
	JP doprefix.B.
doprefix.C.
;PUSHVAR _prefix ;Line=339
	LD HL,[_prefix]
;PUSHVAR _lenprefix ;Line=339
	LD DE,[_lenprefix]
;OPERATION +poi ;Line=339
	ADD HL,DE
;PUSHNUM '\0' ;Line=339
;POKE ;Line=339
;PUSHCONST '\0' ;Line=339
	LD A,'\0'
	LD [HL],A
;//strclose(_prefix, _lenprefix);
;accesspar=strcopy.A. ;Line=340
;PUSHVAR _prefix ;Line=340
	LD HL,[_prefix]
;POPVAR strcopy.A. ;Line=340
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=340
;PUSHVAR _lenprefix ;Line=340
	LD HL,[_lenprefix]
;POPVAR strcopy.B. ;Line=340
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=340
;PUSHVAR _joined ;Line=340
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=340
	LD [strcopy.C.],HL
;CALL strcopy ;Line=340
	CALL strcopy
;POPVAR _lenjoined ;Line=340
	LD [_lenjoined],HL
;/**to=*/
;accesspar=strjoin.A. ;Line=341
;PUSHVAR _joined ;Line=341
	LD HL,[_joined]
;POPVAR strjoin.A. ;Line=341
	LD [strjoin.A.],HL
;accesspar=strjoin.B. ;Line=341
;PUSHVAR _lenjoined ;Line=341
	LD HL,[_lenjoined]
;POPVAR strjoin.B. ;Line=341
	LD [strjoin.B.],HL
;accesspar=strjoin.C. ;Line=341
;PUSHVAR _tword ;Line=341
	LD HL,[_tword]
;/**, _lentword*/
;POPVAR strjoin.C. ;Line=341
	LD [strjoin.C.],HL
;CALL strjoin ;Line=341
	CALL strjoin
;POPVAR _lenjoined ;Line=341
	LD [_lenjoined],HL
;PUSHVAR _joined ;Line=342
	LD HL,[_joined]
;PUSHVAR _lenjoined ;Line=342
	LD DE,[_lenjoined]
;OPERATION +poi ;Line=342
	ADD HL,DE
;PUSHNUM '\0' ;Line=342
;POKE ;Line=342
;PUSHCONST '\0' ;Line=342
	LD A,'\0'
	LD [HL],A
;//strclose(_joined, _lenjoined);
;ENDFUNC ;Line=345
	RET
adddots
;FUNC ;Line=345
adddots.A.
;PUSHVAR _cnext ;Line=347
	LD A,[_cnext]
;PUSHNUM '.' ;Line=347
;OPERATION == ;Line=347
	SUB '.'
;JUMP IF FALSE adddots.B. ;Line=347
	JP NZ,adddots.B.
;CALL rdaddword ;Line=348
	CALL rdaddword
;//приклеить точку
;CALL rdaddword ;Line=349
	CALL rdaddword
;//приклеить следующее слово
;JUMP adddots.A. ;Line=350
	JP adddots.A.
adddots.B.
;ENDFUNC ;Line=353
	RET
joinvarname
;FUNC ;Line=353
;//идентификатор уже прочитан
;accesspar=strcopy.A. ;Line=358
;PUSHVAR _tword ;Line=358
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=358
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=358
;PUSHVAR _lentword ;Line=358
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=358
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=358
;PUSHVAR _name ;Line=358
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=358
	LD [strcopy.C.],HL
;CALL strcopy ;Line=358
	CALL strcopy
;POPVAR _lenname ;Line=358
	LD [_lenname],HL
;CALL lbltype ;Line=359
	CALL lbltype
;POPVAR joinvarname.t ;Line=359
	LD [joinvarname.t],A
;PUSHVAR _cnext ;Line=360
	LD A,[_cnext]
;PUSHNUM '*' ;Line=360
;OPERATION == ;Line=360
	SUB '*'
	SUB 1
	SBC A,A
;PUSHVAR joinvarname.t ;Line=360
	LD L,A
	LD A,[joinvarname.t]
;PUSHNUM _T_TYPE ;Line=360
;OPERATION & ;Line=360
;PUSHCONST _T_TYPE ;Line=360
	LD C,_T_TYPE
	AND C
;PUSHNUM 0x00 ;Line=360
;OPERATION != ;Line=360
	SUB 0x00
	JR Z,$+4
	LD A,-1
;OPERATION & ;Line=360
	AND L
;JUMP IF FALSE joinvarname.B. ;Line=360
	JP Z,joinvarname.B.
;//todo выделить в подпрограмму
;PUSHVAR joinvarname.t ;Line=361
	LD A,[joinvarname.t]
;PUSHNUM _T_POI ;Line=361
;OPERATION | ;Line=361
;PUSHCONST _T_POI ;Line=361
	LD E,_T_POI
	OR E
;POPVAR joinvarname.t ;Line=361
	LD [joinvarname.t],A
;PUSHNUM _SZ_REG ;Line=362
;OPERATION cast 0>1 ;Line=362
;PUSHCONST _SZ_REG ;Line=362
	LD A,_SZ_REG
	LD L,A
	LD H,0
;POPVAR _varsz ;Line=362
	LD [_varsz],HL
;CALL rdword ;Line=363
	CALL rdword
;//use *
joinvarname.B.
;//lvl = *(PBYTE)_tword; //todo убрать
;PUSHVAR _islocal ;Line=366
	LD A,[_islocal]
;INV ;Line=366
	CPL
;JUMP IF FALSE joinvarname.D. ;Line=366
	OR A
	JP Z,joinvarname.D.
;accesspar=strcopy.A. ;Line=367
;PUSHVAR _tword ;Line=367
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=367
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=367
;PUSHVAR _lentword ;Line=367
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=367
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=367
;PUSHVAR _joined ;Line=367
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=367
	LD [strcopy.C.],HL
;CALL strcopy ;Line=367
	CALL strcopy
;POPVAR _lenjoined ;Line=367
	LD [_lenjoined],HL
;JUMP joinvarname.E. ;Line=368
	JP joinvarname.E.
joinvarname.D.
;PUSHVAR _namespclvl ;Line=369
	LD A,[_namespclvl]
;POPVAR joinvarname.lvl ;Line=369
	LD [joinvarname.lvl],A
;PUSHVAR joinvarname.iscall ;Line=370
	LD A,[joinvarname.iscall]
;PUSHVAR joinvarname.lvl ;Line=370
	LD L,A
	LD A,[joinvarname.lvl]
;PUSHNUM 0x00 ;Line=370
;OPERATION != ;Line=370
	SUB 0x00
	JR Z,$+4
	LD A,-1
;OPERATION & ;Line=370
	AND L
;JUMP IF FALSE joinvarname.F. ;Line=370
	JP Z,joinvarname.F.
;OPERATION -- ;Line=371
;PUSHNUM joinvarname.lvl ;Line=371
;PUSHCONST joinvarname.lvl ;Line=371
	LD HL,joinvarname.lvl
	DEC [HL]
;//proc()
joinvarname.F.
;accesspar=doprefix.A. ;Line=373
;PUSHVAR joinvarname.lvl ;Line=373
	LD A,[joinvarname.lvl]
;POPVAR doprefix.A. ;Line=373
	LD [doprefix.A.],A
;CALL doprefix ;Line=373
	CALL doprefix
;//склеить n слов типа 'word.' из title в prefix (name без префикса)
;//todo проверить и этот тип (для модульности)?
joinvarname.E.
;PUSHVAR joinvarname.t ;Line=376
	LD A,[joinvarname.t]
;RESULT ;Line=376
;//(_name) //todo _t?
;ENDFUNC ;Line=379
	RET
eatvarname
;FUNC ;Line=379
;//для создания меток
;CALL eattype ;Line=382
	CALL eattype
;POPVAR eatvarname.t ;Line=382
	LD [eatvarname.t],A
;//тип был уже прочитан
;CALL adddots ;Line=383
	CALL adddots
;accesspar=strcopy.A. ;Line=384
;PUSHVAR _tword ;Line=384
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=384
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=384
;PUSHVAR _lentword ;Line=384
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=384
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=384
;PUSHVAR _name ;Line=384
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=384
	LD [strcopy.C.],HL
;CALL strcopy ;Line=384
	CALL strcopy
;POPVAR _lenname ;Line=384
	LD [_lenname],HL
;accesspar=doprefix.A. ;Line=385
;PUSHVAR _namespclvl ;Line=385
	LD A,[_namespclvl]
;POPVAR doprefix.A. ;Line=385
	LD [doprefix.A.],A
;CALL doprefix ;Line=385
	CALL doprefix
;//склеить n слов типа 'word.' из title в prefix (name без префикса)
;CALL rdword ;Line=386
	CALL rdword
;//'['
;PUSHVAR _tword ;Line=387
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=387
;PEEK ;Line=387
	LD A,[HL]
;PUSHNUM '[' ;Line=387
;OPERATION == ;Line=387
	SUB '['
;JUMP IF FALSE eatvarname.A. ;Line=387
	JP NZ,eatvarname.A.
;PUSHVAR eatvarname.t ;Line=388
	LD A,[eatvarname.t]
;PUSHNUM _T_ARRAY ;Line=388
;OPERATION | ;Line=388
;PUSHCONST _T_ARRAY ;Line=388
	LD E,_T_ARRAY
	OR E
;POPVAR eatvarname.t ;Line=388
	LD [eatvarname.t],A
eatvarname.A.
;PUSHVAR eatvarname.t ;Line=390
	LD A,[eatvarname.t]
;RESULT ;Line=390
;//////////////////////////////////////////
;// compiler
;//call вызывает _tword и expr
;ENDFUNC ;Line=397
	RET
;//вызывает call
;//вызывает call
;//возвращает тип функции
varstrz
;FUNC ;Line=402
;accesspar=varstr.A. ;Line=404
;PUSHVAR _joined ;Line=404
	LD HL,[_joined]
;POPVAR varstr.A. ;Line=404
	LD [varstr.A.],HL
;CALL varstr ;Line=404
	CALL varstr
;/**varc( ':' );*/
;CALL endvar ;Line=404
	CALL endvar
varstrz.A.
;PUSHNUM TRUE ;Line=405
;JUMP IF FALSE varstrz.B. ;Line=405
;PUSHCONST TRUE ;Line=405
	LD A,TRUE
	OR A
	JP Z,varstrz.B.
;accesspar=rdquotes.A. ;Line=406
;PUSHNUM '\"' ;Line=406
;POPVAR rdquotes.A. ;Line=406
;PUSHCONST '\"' ;Line=406
	LD A,'\"'
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=406
	CALL rdquotes
;CALL rdch ;Line=407
	CALL rdch
;//добавляем закрывающую кавычку
;PUSHVAR _tword ;Line=408
	LD HL,[_tword]
;PUSHVAR _lentword ;Line=408
	LD DE,[_lentword]
;OPERATION +poi ;Line=408
	ADD HL,DE
;PUSHNUM '\0' ;Line=408
;POKE ;Line=408
;PUSHCONST '\0' ;Line=408
	LD A,'\0'
	LD [HL],A
;//strclose(_tword, _lentword);
;CALL var_db ;Line=409
	CALL var_db
;accesspar=varstr.A. ;Line=409
;PUSHVAR _tword ;Line=409
	LD HL,[_tword]
;POPVAR varstr.A. ;Line=409
	LD [varstr.A.],HL
;CALL varstr ;Line=409
	CALL varstr
;CALL endvar ;Line=409
	CALL endvar
;PUSHVAR _cnext ;Line=410
	LD A,[_cnext]
;PUSHNUM '\"' ;Line=410
;OPERATION != ;Line=410
	SUB '\"'
;JUMP IF FALSE varstrz.C. ;Line=410
	JP Z,varstrz.C.
;JUMP varstrz.B. ;Line=410
	JP varstrz.B.
varstrz.C.
;CALL rdword ;Line=411
	CALL rdword
;//открывающая кавычка приклеенной строки
;JUMP varstrz.A. ;Line=412
	JP varstrz.A.
varstrz.B.
;CALL var_db ;Line=413
	CALL var_db
;accesspar=varc.A. ;Line=413
;PUSHNUM '0' ;Line=413
;POPVAR varc.A. ;Line=413
;PUSHCONST '0' ;Line=413
	LD A,'0'
	LD [varc.A.],A
;CALL varc ;Line=413
	CALL varc
;CALL endvar ;Line=413
	CALL endvar
;ENDFUNC ;Line=416
	RET
asmstrz
;FUNC ;Line=416
;//костыль для константных массивов строк
;accesspar=asmstr.A. ;Line=418
;PUSHVAR _title ;Line=418
	LD HL,[_title]
;/**_joined*/
;POPVAR asmstr.A. ;Line=418
	LD [asmstr.A.],HL
;CALL asmstr ;Line=418
	CALL asmstr
;/**varc( ':' );*/
;CALL endasm ;Line=418
	CALL endasm
asmstrz.A.
;PUSHNUM TRUE ;Line=419
;JUMP IF FALSE asmstrz.B. ;Line=419
;PUSHCONST TRUE ;Line=419
	LD A,TRUE
	OR A
	JP Z,asmstrz.B.
;accesspar=rdquotes.A. ;Line=420
;PUSHNUM '\"' ;Line=420
;POPVAR rdquotes.A. ;Line=420
;PUSHCONST '\"' ;Line=420
	LD A,'\"'
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=420
	CALL rdquotes
;CALL rdch ;Line=421
	CALL rdch
;//добавляем закрывающую кавычку
;PUSHVAR _tword ;Line=422
	LD HL,[_tword]
;PUSHVAR _lentword ;Line=422
	LD DE,[_lentword]
;OPERATION +poi ;Line=422
	ADD HL,DE
;PUSHNUM '\0' ;Line=422
;POKE ;Line=422
;PUSHCONST '\0' ;Line=422
	LD A,'\0'
	LD [HL],A
;//strclose(_tword, _lentword);
;CALL asm_db ;Line=423
	CALL asm_db
;accesspar=asmstr.A. ;Line=423
;PUSHVAR _tword ;Line=423
	LD HL,[_tword]
;POPVAR asmstr.A. ;Line=423
	LD [asmstr.A.],HL
;CALL asmstr ;Line=423
	CALL asmstr
;CALL endasm ;Line=423
	CALL endasm
;PUSHVAR _cnext ;Line=424
	LD A,[_cnext]
;PUSHNUM '\"' ;Line=424
;OPERATION != ;Line=424
	SUB '\"'
;JUMP IF FALSE asmstrz.C. ;Line=424
	JP Z,asmstrz.C.
;JUMP asmstrz.B. ;Line=424
	JP asmstrz.B.
asmstrz.C.
;CALL rdword ;Line=425
	CALL rdword
;//открывающая кавычка приклеенной строки
;JUMP asmstrz.A. ;Line=426
	JP asmstrz.A.
asmstrz.B.
;CALL asm_db ;Line=427
	CALL asm_db
;accesspar=asmc.A. ;Line=427
;PUSHNUM '0' ;Line=427
;POPVAR asmc.A. ;Line=427
;PUSHCONST '0' ;Line=427
	LD A,'0'
	LD [asmc.A.],A
;CALL asmc ;Line=427
	CALL asmc
;CALL endasm ;Line=427
	CALL endasm
;ENDFUNC ;Line=430
	RET
eatidx
;FUNC ;Line=430
;//для idxarray и switch
;OPERATION ++ ;Line=432
;PUSHNUM _exprlvl ;Line=432
;PUSHCONST _exprlvl ;Line=432
	LD HL,_exprlvl
	INC [HL]
;//no jump optimization
;CALL eatexpr ;Line=433
	CALL eatexpr
;//сравнения нельзя без скобок!!!
;OPERATION -- ;Line=434
;PUSHNUM _exprlvl ;Line=434
;PUSHCONST _exprlvl ;Line=434
	LD HL,_exprlvl
	DEC [HL]
;PUSHVAR _t ;Line=435
	LD A,[_t]
;PUSHNUM _T_BYTE ;Line=435
;OPERATION == ;Line=435
	SUB _T_BYTE
;JUMP IF FALSE eatidx.A. ;Line=435
	JP NZ,eatidx.A.
;accesspar=cmdcastto.A. ;Line=435
;PUSHNUM _T_UINT ;Line=435
;POPVAR cmdcastto.A. ;Line=435
;PUSHCONST _T_UINT ;Line=435
	LD A,_T_UINT
	LD [cmdcastto.A.],A
;CALL cmdcastto ;Line=435
	CALL cmdcastto
eatidx.A.
;PUSHVAR _t ;Line=436
	LD A,[_t]
;PUSHNUM _T_UINT ;Line=436
;OPERATION != ;Line=436
	SUB _T_UINT
;JUMP IF FALSE eatidx.C. ;Line=436
	JP Z,eatidx.C.
;accesspar=errstr.A. ;Line=436
;PUSHNUM eatidx.E. ;Line=436
;POPVAR errstr.A. ;Line=436
;PUSHCONST eatidx.E. ;Line=436
	LD HL,eatidx.E.
	LD [errstr.A.],HL
;CALL errstr ;Line=436
	CALL errstr
;accesspar=erruint.A. ;Line=436
;PUSHVAR _t ;Line=436
	LD A,[_t]
;OPERATION cast 0>1 ;Line=436
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=436
	LD [erruint.A.],HL
;CALL erruint ;Line=436
	CALL erruint
;CALL enderr ;Line=436
	CALL enderr
eatidx.C.
;ENDFUNC ;Line=439
	RET
idxarray
;FUNC ;Line=439
;CALL rdword ;Line=441
	CALL rdword
;//первое слово expr
;PUSHVAR idxarray.t ;Line=442
	LD A,[idxarray.t]
;PUSHNUM _T_ARRAY ;Line=442
;OPERATION & ;Line=442
;PUSHCONST _T_ARRAY ;Line=442
	LD E,_T_ARRAY
	AND E
;PUSHNUM 0x00 ;Line=442
;OPERATION != ;Line=442
	SUB 0x00
;JUMP IF FALSE idxarray.B. ;Line=442
	JP Z,idxarray.B.
;//массив
;PUSHVAR idxarray.t ;Line=443
	LD A,[idxarray.t]
;PUSHNUM _TYPEMASK ;Line=443
;OPERATION & ;Line=443
;PUSHCONST _TYPEMASK ;Line=443
	LD E,_TYPEMASK
	AND E
;POPVAR idxarray.t ;Line=443
	LD [idxarray.t],A
;//&(~(_T_ARRAY|_T_CONST)); //может быть _T_POI (если массив строк)
;PUSHNUM _T_POI ;Line=444
;PUSHNUM _T_BYTE ;Line=444
;PUSHCONST _T_POI ;Line=444
	LD A,_T_POI
;OPERATION | ;Line=444
;PUSHCONST _T_BYTE ;Line=444
	LD E,_T_BYTE
	OR E
;POPVAR _t ;Line=444
	LD [_t],A
;CALL cmdpushnum ;Line=444
	CALL cmdpushnum
;//использование обычного массива - берём его адрес
;JUMP idxarray.C. ;Line=445
	JP idxarray.C.
idxarray.B.
;PUSHVAR idxarray.t ;Line=445
	LD A,[idxarray.t]
;PUSHNUM _T_POI ;Line=445
;OPERATION & ;Line=445
;PUSHCONST _T_POI ;Line=445
	LD E,_T_POI
	AND E
;PUSHNUM 0x00 ;Line=445
;OPERATION != ;Line=445
	SUB 0x00
;JUMP IF FALSE idxarray.D. ;Line=445
	JP Z,idxarray.D.
;//указатель
;PUSHVAR idxarray.t ;Line=446
	LD A,[idxarray.t]
;POPVAR _t ;Line=446
	LD [_t],A
;CALL cmdpushvar ;Line=446
	CALL cmdpushvar
;//использование указателя в качестве массива - читаем его значение
;PUSHVAR idxarray.t ;Line=447
	LD A,[idxarray.t]
;PUSHNUM _T_POI ;Line=447
;INV ;Line=447
;PUSHCONST _T_POI ;Line=447
	LD E,_T_POI
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=447
	AND L
;POPVAR idxarray.t ;Line=447
	LD [idxarray.t],A
;JUMP idxarray.E. ;Line=448
	JP idxarray.E.
idxarray.D.
;accesspar=errstr.A. ;Line=448
;PUSHNUM idxarray.F. ;Line=448
;POPVAR errstr.A. ;Line=448
;PUSHCONST idxarray.F. ;Line=448
	LD HL,idxarray.F.
	LD [errstr.A.],HL
;CALL errstr ;Line=448
	CALL errstr
;accesspar=erruint.A. ;Line=448
;PUSHVAR idxarray.t ;Line=448
	LD A,[idxarray.t]
;OPERATION cast 0>1 ;Line=448
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=448
	LD [erruint.A.],HL
;CALL erruint ;Line=448
	CALL erruint
;CALL enderr ;Line=448
	CALL enderr
idxarray.E.
idxarray.C.
;CALL eatidx ;Line=449
	CALL eatidx
;PUSHVAR idxarray.t ;Line=450
	LD A,[idxarray.t]
;POPVAR _t ;Line=450
	LD [_t],A
;//тип элемента массива
;CALL cmdaddpoi ;Line=451
	CALL cmdaddpoi
;PUSHVAR idxarray.t ;Line=452
	LD A,[idxarray.t]
;RESULT ;Line=452
;//тип элемента массива
;ENDFUNC ;Line=455
	RET
numtype
;FUNC ;Line=455
;/**IF (_cnext == '.') { //дробное число (нельзя начинать с точки или заканчиват
;PUSHVAR _tword ;Line=465
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=465
;PEEK ;Line=465
	LD A,[HL]
;PUSHNUM '-' ;Line=465
;OPERATION == ;Line=465
	SUB '-'
;JUMP IF FALSE numtype.A. ;Line=465
	JP NZ,numtype.A.
;//в val уже есть, надо для define
;PUSHNUM _T_INT ;Line=466
;POPVAR _t ;Line=466
;PUSHCONST _T_INT ;Line=466
	LD A,_T_INT
	LD [_t],A
;JUMP numtype.B. ;Line=467
	JP numtype.B.
numtype.A.
;PUSHVAR _tword ;Line=467
	LD HL,[_tword]
;PUSHVAR _lentword ;Line=467
	LD DE,[_lentword]
;PUSHNUM 1 ;Line=467
;OPERATION - ;Line=467
;PUSHCONST 1 ;Line=467
	LD BC,1
	LD A,E
	SUB C
	LD E,A
	LD A,D
	SBC A,B
	LD D,A
;OPERATION +poi ;Line=467
	ADD HL,DE
;PEEK ;Line=467
	LD A,[HL]
;PUSHNUM 'L' ;Line=467
;OPERATION == ;Line=467
	SUB 'L'
;JUMP IF FALSE numtype.C. ;Line=467
	JP NZ,numtype.C.
;PUSHNUM _T_LONG ;Line=468
;POPVAR _t ;Line=468
;PUSHCONST _T_LONG ;Line=468
	LD A,_T_LONG
	LD [_t],A
;JUMP numtype.D. ;Line=469
	JP numtype.D.
numtype.C.
;PUSHVAR _tword ;Line=469
	LD HL,[_tword]
;PUSHNUM 1 ;Line=469
;OPERATION +poi ;Line=469
;PUSHCONST 1 ;Line=469
	LD DE,1
	ADD HL,DE
;PEEK ;Line=469
	LD A,[HL]
;OPERATION cast 5>0 ;Line=469
;PUSHNUM '9' ;Line=469
;OPERATION cast 5>0 ;Line=469
;OPERATION > ;Line=469
;PUSHCONST '9' ;Line=469
	LD E,'9'
	LD L,A
	LD A,E
	SUB L
;JUMP IF FALSE numtype.E. ;Line=469
	JP NC,numtype.E.
;//ускорение проверки числового формата
;PUSHVAR _lentword ;Line=470
	LD HL,[_lentword]
;PUSHNUM 4 ;Line=470
;OPERATION <= ;Line=470
;PUSHCONST 4 ;Line=470
	LD DE,4
	LD A,E
	SUB L
	LD A,D
	SBC A,H
	CCF
	SBC A,A
;PUSHVAR _tword ;Line=470
	LD DE,[_tword]
;PUSHNUM 1 ;Line=470
;OPERATION +poi ;Line=470
;PUSHCONST 1 ;Line=470
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
;PEEK ;Line=470
	LD L,A
	LD A,[DE]
;PUSHNUM 'x' ;Line=470
;OPERATION == ;Line=470
	SUB 'x'
	SUB 1
	SBC A,A
;OPERATION & ;Line=470
	AND L
;JUMP IF FALSE numtype.G. ;Line=470
	JP Z,numtype.G.
;PUSHNUM _T_BYTE ;Line=471
;POPVAR _t ;Line=471
;PUSHCONST _T_BYTE ;Line=471
	LD A,_T_BYTE
	LD [_t],A
;JUMP numtype.H. ;Line=472
	JP numtype.H.
numtype.G.
;PUSHVAR _lentword ;Line=472
	LD HL,[_lentword]
;PUSHNUM 10 ;Line=472
;OPERATION <= ;Line=472
;PUSHCONST 10 ;Line=472
	LD DE,10
	LD A,E
	SUB L
	LD A,D
	SBC A,H
	CCF
	SBC A,A
;PUSHVAR _tword ;Line=472
	LD DE,[_tword]
;PUSHNUM 1 ;Line=472
;OPERATION +poi ;Line=472
;PUSHCONST 1 ;Line=472
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
;PEEK ;Line=472
	LD L,A
	LD A,[DE]
;PUSHNUM 'b' ;Line=472
;OPERATION == ;Line=472
	SUB 'b'
	SUB 1
	SBC A,A
;OPERATION & ;Line=472
	AND L
;JUMP IF FALSE numtype.I. ;Line=472
	JP Z,numtype.I.
;PUSHNUM _T_BYTE ;Line=473
;POPVAR _t ;Line=473
;PUSHCONST _T_BYTE ;Line=473
	LD A,_T_BYTE
	LD [_t],A
;JUMP numtype.J. ;Line=474
	JP numtype.J.
numtype.I.
;PUSHNUM _T_UINT ;Line=475
;POPVAR _t ;Line=475
;PUSHCONST _T_UINT ;Line=475
	LD A,_T_UINT
	LD [_t],A
numtype.J.
numtype.H.
;JUMP numtype.F. ;Line=477
	JP numtype.F.
numtype.E.
;PUSHNUM _T_UINT ;Line=478
;POPVAR _t ;Line=478
;PUSHCONST _T_UINT ;Line=478
	LD A,_T_UINT
	LD [_t],A
numtype.F.
numtype.D.
numtype.B.
;ENDFUNC ;Line=482
	RET
val
;FUNC ;Line=482
;PUSHPAR val.t ;Line=484
	LD A,[val.t]
;//cast,peek
;//<val>::=
;//(<expr>) //выражение (вычисляется)
;//|<num> //десятичное число (передаётся целиком) INT/UINT/LONG
;//|<num>.<num>[e-<num>] //float число (передаётся целиком)
;//|<var> //переменная
;//|'CHAR' //символьная константа (передаётся целиком)
;//|"str" //строковая константа (передаётся целиком)
;//|+(<type>)<val> //вычислить val, потом сделать перевод в <type>
;//|+<boolconst>
;//|+_<enumconst> BYTE
;//|<lbl>([<val>,...]) //call
;//|-<val> //вычислить val, потом сделать NEG
;//|~<val> //вычислить val, потом сделать INV
;//|!<val> //вычислить val, потом сделать INV(BOOL)
;////|<<val> //вычислить val, потом сделать SHL1
;////|><val> //вычислить val, потом сделать SHR1
;//|*(<ptype>)<val> //прочитать память по адресу (вычислить val, потом сделать P
;//|&<var> //адрес переменной
;//команда уже прочитана
;//_t = _T_UNKNOWN; //debug (иначе может вылететь за таблицу typesz при обрыве ф
;//IF ( !_waseof )
;//защита от зацикливания в конце ошибочного файла (теперь в рекурсивных вызовах
;PUSHVAR _tword ;Line=511
	LD DE,[_tword]
;OPERATION cast 21>21 ;Line=511
;PEEK ;Line=511
	LD L,A
	LD A,[DE]
;POPVAR _opsym ;Line=511
	LD [_opsym],A
;PUSHVAR _opsym ;Line=512
	LD A,[_opsym]
;PUSHNUM '\'' ;Line=512
;OPERATION == ;Line=512
	SUB '\''
;JUMP IF FALSE val.A. ;Line=512
	PUSH HL
	JP NZ,val.A.
;accesspar=rdquotes.A. ;Line=513
;PUSHNUM '\'' ;Line=513
;POPVAR rdquotes.A. ;Line=513
;PUSHCONST '\'' ;Line=513
	LD A,'\''
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=513
	CALL rdquotes
;CALL rdch ;Line=514
	CALL rdch
;//добавляем закрывающую кавычку
;PUSHVAR _tword ;Line=515
	LD HL,[_tword]
;PUSHVAR _lentword ;Line=515
	LD DE,[_lentword]
;OPERATION +poi ;Line=515
	ADD HL,DE
;PUSHNUM '\0' ;Line=515
;POKE ;Line=515
;PUSHCONST '\0' ;Line=515
	LD A,'\0'
	LD [HL],A
;//strclose(_tword, _lentword);
;accesspar=strcopy.A. ;Line=516
;PUSHVAR _tword ;Line=516
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=516
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=516
;PUSHVAR _lentword ;Line=516
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=516
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=516
;PUSHVAR _joined ;Line=516
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=516
	LD [strcopy.C.],HL
;CALL strcopy ;Line=516
	CALL strcopy
;POPVAR _lenjoined ;Line=516
	LD [_lenjoined],HL
;PUSHNUM _T_CHAR ;Line=517
;POPVAR _t ;Line=517
;PUSHCONST _T_CHAR ;Line=517
	LD A,_T_CHAR
	LD [_t],A
;CALL cmdpushnum ;Line=517
	CALL cmdpushnum
;JUMP val.B. ;Line=518
	JP val.B.
val.A.
;PUSHVAR _opsym ;Line=518
	LD A,[_opsym]
;PUSHNUM '\"' ;Line=518
;OPERATION == ;Line=518
	SUB '\"'
;JUMP IF FALSE val.C. ;Line=518
	JP NZ,val.C.
;accesspar=strcopy.A. ;Line=519
;PUSHVAR _title ;Line=519
	LD HL,[_title]
;POPVAR strcopy.A. ;Line=519
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=519
;PUSHVAR _lentitle ;Line=519
	LD HL,[_lentitle]
;POPVAR strcopy.B. ;Line=519
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=519
;PUSHVAR _joined ;Line=519
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=519
	LD [strcopy.C.],HL
;CALL strcopy ;Line=519
	CALL strcopy
;POPVAR _lenjoined ;Line=519
	LD [_lenjoined],HL
;accesspar=jautonum.A. ;Line=520
;PUSHVAR _curlbl ;Line=520
	LD HL,[_curlbl]
;POPVAR jautonum.A. ;Line=520
	LD [jautonum.A.],HL
;CALL jautonum ;Line=520
	CALL jautonum
;OPERATION ++ ;Line=521
	LD HL,[_curlbl]
	INC HL
	LD [_curlbl],HL
;//_joined[_lenjoined] = '\0'; //strclose(_joined, _lenjoined);
;PUSHNUM _T_POI ;Line=523
;PUSHNUM _T_CHAR ;Line=523
;PUSHCONST _T_POI ;Line=523
	LD A,_T_POI
;OPERATION | ;Line=523
;PUSHCONST _T_CHAR ;Line=523
	LD E,_T_CHAR
	OR E
;POPVAR _t ;Line=523
	LD [_t],A
;CALL cmdpushnum ;Line=523
	CALL cmdpushnum
;CALL varstrz ;Line=524
	CALL varstrz
;//с меткой joined
;JUMP val.D. ;Line=525
	JP val.D.
val.C.
;PUSHVAR _opsym ;Line=525
	LD A,[_opsym]
;PUSHNUM '+' ;Line=525
;OPERATION == ;Line=525
	SUB '+'
;JUMP IF FALSE val.E. ;Line=525
	JP NZ,val.E.
;CALL rdword ;Line=526
	CALL rdword
;//'(' of type or +TRUE/+FALSE (BOOL) or +_CONSTANT or +__CONSTANT (BYTE)
;PUSHVAR _tword ;Line=527
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=527
;PEEK ;Line=527
	LD A,[HL]
;POPVAR _opsym ;Line=527
	LD [_opsym],A
;//|+(CHAR)0x20;
;PUSHVAR _opsym ;Line=528
	LD A,[_opsym]
;PUSHNUM '_' ;Line=528
;OPERATION == ;Line=528
	SUB '_'
;JUMP IF FALSE val.G. ;Line=528
	JP NZ,val.G.
;//+_CONSTANT or +__CONSTANT (BYTE)
;//начальная часть имени константы уже прочитана
;CALL adddots ;Line=530
	CALL adddots
;/**t=*/
;/**iscall*/
;accesspar=joinvarname.A. ;Line=531
;PUSHNUM FALSE ;Line=531
;POPVAR joinvarname.A. ;Line=531
;PUSHCONST FALSE ;Line=531
	LD A,FALSE
	LD [joinvarname.A.],A
;CALL joinvarname ;Line=531
	CALL joinvarname
;accesspar=strcopy.A. ;Line=532
;PUSHVAR _name ;Line=532
	LD HL,[_name]
;POPVAR strcopy.A. ;Line=532
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=532
;PUSHVAR _lenname ;Line=532
	LD HL,[_lenname]
;POPVAR strcopy.B. ;Line=532
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=532
;PUSHVAR _joined ;Line=532
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=532
	LD [strcopy.C.],HL
;CALL strcopy ;Line=532
	CALL strcopy
;POPVAR _lenjoined ;Line=532
	LD [_lenjoined],HL
;//глобальная
;PUSHNUM _T_BYTE ;Line=533
;POPVAR _t ;Line=533
;PUSHCONST _T_BYTE ;Line=533
	LD A,_T_BYTE
	LD [_t],A
;CALL cmdpushnum ;Line=533
	CALL cmdpushnum
;JUMP val.H. ;Line=534
	JP val.H.
val.G.
;PUSHVAR _opsym ;Line=534
	LD A,[_opsym]
;OPERATION cast 5>0 ;Line=534
;PUSHNUM '0' ;Line=534
;OPERATION cast 5>0 ;Line=534
;OPERATION - ;Line=534
	SUB '0'
;OPERATION cast 0>0 ;Line=534
;PUSHNUM 0x0a ;Line=534
;OPERATION < ;Line=534
;PUSHCONST 0x0a ;Line=534
	LD E,0x0a
	SUB E
;JUMP IF FALSE val.I. ;Line=534
	JP NC,val.I.
;//+num
;PUSHVAR _waseof ;Line=535
	LD A,[_waseof]
;INV ;Line=535
	CPL
;JUMP IF FALSE val.K. ;Line=535
	OR A
	JP Z,val.K.
;CALL val ;Line=535
	CALL val
val.K.
;//рекурсивный вызов val
;PUSHVAR _t ;Line=536
	LD A,[_t]
;PUSHNUM _T_UINT ;Line=536
;OPERATION == ;Line=536
	SUB _T_UINT
;JUMP IF FALSE val.M. ;Line=536
	JP NZ,val.M.
;accesspar=cmdcastto.A. ;Line=536
;PUSHNUM _T_INT ;Line=536
;POPVAR cmdcastto.A. ;Line=536
;PUSHCONST _T_INT ;Line=536
	LD A,_T_INT
	LD [cmdcastto.A.],A
;CALL cmdcastto ;Line=536
	CALL cmdcastto
val.M.
;//для знаковых констант типа +15
;JUMP val.J. ;Line=537
	JP val.J.
val.I.
;PUSHVAR _opsym ;Line=537
	LD A,[_opsym]
;PUSHNUM '(' ;Line=537
;OPERATION != ;Line=537
	SUB '('
;JUMP IF FALSE val.O. ;Line=537
	JP Z,val.O.
;//+TRUE/+FALSE (BOOL) //+sizeof
;PUSHVAR _opsym ;Line=538
	LD A,[_opsym]
;PUSHNUM 's' ;Line=538
;OPERATION == ;Line=538
	SUB 's'
;JUMP IF FALSE val.Q. ;Line=538
	JP NZ,val.Q.
;//+sizeof //TODO uppercase?
;CALL rdword ;Line=539
	CALL rdword
;//использовали sizeof
;accesspar=eat.A. ;Line=540
;PUSHNUM '(' ;Line=540
;/**, "\'(\'"*/
;POPVAR eat.A. ;Line=540
;PUSHCONST '(' ;Line=540
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=540
	CALL eat
;CALL eattype ;Line=541
	CALL eattype
;POPVAR _t ;Line=541
	LD [_t],A
;//eatexpr(); //на выходе из expr уже прочитана ')', но следующий символ или ком
;//eat(')', "\')\'");
;//          IF ((_t&_T_TYPE)!=0x00) {
;accesspar=emitn.A. ;Line=545
;PUSHVAR _varsz ;Line=545
	LD HL,[_varsz]
;POPVAR emitn.A. ;Line=545
	LD [emitn.A.],HL
;CALL emitn ;Line=545
	CALL emitn
;//gettypesz();
;accesspar=strcopy.A. ;Line=546
;PUSHNUM _nbuf ;Line=546
;POPVAR strcopy.A. ;Line=546
;PUSHCONST _nbuf ;Line=546
	LD HL,_nbuf
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=546
;PUSHVAR _lennbuf ;Line=546
	LD HL,[_lennbuf]
;POPVAR strcopy.B. ;Line=546
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=546
;PUSHVAR _joined ;Line=546
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=546
	LD [strcopy.C.],HL
;CALL strcopy ;Line=546
	CALL strcopy
;POPVAR _lenjoined ;Line=546
	LD [_lenjoined],HL
;//глобальная
;//          }ELSE { //не тип
;//- из переменной базового типа - будет ошибка, т.к. пуш значения переменной TO
;//- из переменной массива - будет ошибка, т.к. пуш адреса массива TODO
;//- из переменной структуры - будет ошибка, т.к. пуш адреса структуры TODO
;//- из выражения - будет ошибка, т.к. сгенерируются операции TODO
;//          };
;PUSHNUM _T_UINT ;Line=553
;POPVAR _t ;Line=553
;PUSHCONST _T_UINT ;Line=553
	LD A,_T_UINT
	LD [_t],A
;CALL cmdpushnum ;Line=553
	CALL cmdpushnum
;//(_joined)
;JUMP val.R. ;Line=554
	JP val.R.
val.Q.
;//+TRUE/+FALSE (BOOL)
;accesspar=strcopy.A. ;Line=555
;PUSHVAR _tword ;Line=555
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=555
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=555
;PUSHVAR _lentword ;Line=555
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=555
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=555
;PUSHVAR _joined ;Line=555
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=555
	LD [strcopy.C.],HL
;CALL strcopy ;Line=555
	CALL strcopy
;POPVAR _lenjoined ;Line=555
	LD [_lenjoined],HL
;//_lenjoined = strjoin(/**to=*/_joined, 0/**strclear(_joined)*/, _tword/**, _le
;//strclose(_joined, _lenjoined);
;PUSHNUM _T_BOOL ;Line=557
;POPVAR _t ;Line=557
;PUSHCONST _T_BOOL ;Line=557
	LD A,_T_BOOL
	LD [_t],A
;CALL cmdpushnum ;Line=557
	CALL cmdpushnum
;//(_joined)
val.R.
;JUMP val.P. ;Line=559
	JP val.P.
val.O.
;//'(': был typecast
;/**        rdword(); //type        t = eattype();        eat(')', "\')\'");    
;//rdword(); //первое слово expr
;//eatexpr(); //на выходе из expr уже прочитана ')', но следующий символ или ком
;PUSHVAR _waseof ;Line=567
	LD A,[_waseof]
;INV ;Line=567
	CPL
;JUMP IF FALSE val.S. ;Line=567
	OR A
	JP Z,val.S.
;CALL val ;Line=567
	CALL val
val.S.
;//рекурсивный вызов val
;//IF (_t == _T_UINT) cmdcastto(_T_INT); //для знаковых констант типа +15 (мешае
val.P.
val.J.
val.H.
;JUMP val.F. ;Line=570
	JP val.F.
val.E.
;PUSHVAR _opsym ;Line=570
	LD A,[_opsym]
;OPERATION cast 5>0 ;Line=570
;PUSHNUM '0' ;Line=570
;OPERATION cast 5>0 ;Line=570
;OPERATION - ;Line=570
	SUB '0'
;OPERATION cast 0>0 ;Line=570
;PUSHNUM 0x0a ;Line=570
;OPERATION < ;Line=570
;PUSHCONST 0x0a ;Line=570
	LD E,0x0a
	SUB E
;JUMP IF FALSE val.U. ;Line=570
	JP NC,val.U.
;//num
;CALL numtype ;Line=571
	CALL numtype
;//_t
;accesspar=strcopy.A. ;Line=572
;PUSHVAR _tword ;Line=572
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=572
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=572
;PUSHVAR _lentword ;Line=572
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=572
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=572
;PUSHVAR _joined ;Line=572
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=572
	LD [strcopy.C.],HL
;CALL strcopy ;Line=572
	CALL strcopy
;POPVAR _lenjoined ;Line=572
	LD [_lenjoined],HL
;CALL cmdpushnum ;Line=573
	CALL cmdpushnum
;JUMP val.V. ;Line=574
	JP val.V.
val.U.
;PUSHNUM _isalphanum ;Line=574
;PUSHVAR _opsym ;Line=574
;PUSHCONST _isalphanum ;Line=574
	LD HL,_isalphanum
	LD A,[_opsym]
;OPERATION cast 5>0 ;Line=574
;OPERATION cast 0>1 ;Line=574
	LD E,A
	LD D,0
;OPERATION +poi ;Line=574
	ADD HL,DE
;PEEK ;Line=574
	LD A,[HL]
;/**|| (_opsym=='.')*/
;JUMP IF FALSE val.W. ;Line=574
	OR A
	JP Z,val.W.
;//<var> //было isalpha
;CALL adddots ;Line=575
	CALL adddots
;//если вызов функции, то do_variable надо делать с namespclvl-1!!!
;PUSHVAR _cnext ;Line=577
	LD A,[_cnext]
;PUSHNUM '(' ;Line=577
;OPERATION == ;Line=577
	SUB '('
;JUMP IF FALSE val.Y. ;Line=577
	JP NZ,val.Y.
;//call
;accesspar=do_call.A. ;Line=578
;PUSHPAR do_call.A. ;Line=578
	LD A,[do_call.A.]
;PUSHNUM TRUE ;Line=578
;POPVAR do_call.A. ;Line=578
;PUSHCONST TRUE ;Line=578
	LD E,TRUE
	LD L,A
	LD A,E
	LD [do_call.A.],A
;CALL do_call ;Line=578
	PUSH HL
	CALL do_call
;POPPAR ;Line=578
	POP DE
	LD L,A
	LD A,E
	LD [do_call.A.],A
;POPVAR _t ;Line=578
	LD A,L
	LD [_t],A
;//isfunc
;JUMP val.Z. ;Line=579
	JP val.Z.
val.Y.
;accesspar=joinvarname.A. ;Line=580
;PUSHNUM FALSE ;Line=580
;POPVAR joinvarname.A. ;Line=580
;PUSHCONST FALSE ;Line=580
	LD A,FALSE
	LD [joinvarname.A.],A
;CALL joinvarname ;Line=580
	CALL joinvarname
;POPVAR _t ;Line=580
	LD [_t],A
;//iscall
;PUSHVAR _cnext ;Line=581
	LD A,[_cnext]
;PUSHNUM '[' ;Line=581
;OPERATION == ;Line=581
	SUB '['
;JUMP IF FALSE val.BA. ;Line=581
	JP NZ,val.BA.
;//<varname>[<idx>]
;CALL rdword ;Line=582
	CALL rdword
;//'['
;accesspar=idxarray.A. ;Line=583
;PUSHPAR idxarray.A. ;Line=583
	LD A,[idxarray.A.]
;PUSHVAR _t ;Line=583
	LD L,A
	LD A,[_t]
;POPVAR idxarray.A. ;Line=583
	LD [idxarray.A.],A
;CALL idxarray ;Line=583
	PUSH HL
	CALL idxarray
;POPPAR ;Line=583
	POP DE
	LD L,A
	LD A,E
	LD [idxarray.A.],A
;POPVAR _t ;Line=583
	LD A,L
	LD [_t],A
;CALL cmdpeek ;Line=584
	CALL cmdpeek
;JUMP val.BB. ;Line=585
	JP val.BB.
val.BA.
;//<varname>
;PUSHVAR _t ;Line=586
	LD A,[_t]
;PUSHNUM _T_TYPE ;Line=586
;OPERATION & ;Line=586
;PUSHCONST _T_TYPE ;Line=586
	LD E,_T_TYPE
	AND E
;PUSHNUM 0x00 ;Line=586
;OPERATION == ;Line=586
	SUB 0x00
;JUMP IF FALSE val.BC. ;Line=586
	JP NZ,val.BC.
;/**IF (_t==_T_STRUCT) {              _t = _T_POI|_T_BYTE;              cmdpushn
;PUSHVAR _t ;Line=590
	LD A,[_t]
;PUSHNUM _T_ARRAY ;Line=590
;OPERATION & ;Line=590
;PUSHCONST _T_ARRAY ;Line=590
	LD E,_T_ARRAY
	AND E
;PUSHNUM 0x00 ;Line=590
;OPERATION != ;Line=590
	SUB 0x00
;JUMP IF FALSE val.BE. ;Line=590
	JP Z,val.BE.
;//array without [] as a pointer
;PUSHVAR _t ;Line=591
	LD A,[_t]
;PUSHNUM _T_ARRAY ;Line=591
;PUSHNUM _T_CONST ;Line=591
;PUSHCONST _T_ARRAY ;Line=591
	LD E,_T_ARRAY
;OPERATION | ;Line=591
;PUSHCONST _T_CONST ;Line=591
	LD C,_T_CONST
	LD L,A
	LD A,E
	OR C
;INV ;Line=591
	CPL
;OPERATION & ;Line=591
	AND L
;PUSHNUM _T_POI ;Line=591
;OPERATION | ;Line=591
;PUSHCONST _T_POI ;Line=591
	LD E,_T_POI
	OR E
;POPVAR _t ;Line=591
	LD [_t],A
;CALL cmdpushnum ;Line=592
	CALL cmdpushnum
;//использование обычного массива - берём его адрес
;JUMP val.BF. ;Line=593
	JP val.BF.
val.BE.
;PUSHVAR _t ;Line=593
	LD A,[_t]
;PUSHNUM _T_CONST ;Line=593
;OPERATION & ;Line=593
;PUSHCONST _T_CONST ;Line=593
	LD E,_T_CONST
	AND E
;PUSHNUM 0x00 ;Line=593
;OPERATION == ;Line=593
	SUB 0x00
;JUMP IF FALSE val.BG. ;Line=593
	JP NZ,val.BG.
;CALL cmdpushvar ;Line=594
	CALL cmdpushvar
;//указатель (в том числе на структуру) или обычная переменная
;JUMP val.BH. ;Line=595
	JP val.BH.
val.BG.
;//константа (equ)
;PUSHVAR _t ;Line=596
	LD A,[_t]
;PUSHNUM _TYPEMASK ;Line=596
;OPERATION & ;Line=596
;PUSHCONST _TYPEMASK ;Line=596
	LD E,_TYPEMASK
	AND E
;POPVAR _t ;Line=596
	LD [_t],A
;//&(~_T_CONST);
;CALL cmdpushnum ;Line=597
	CALL cmdpushnum
val.BH.
val.BF.
val.BC.
val.BB.
val.Z.
;JUMP val.X. ;Line=602
	JP val.X.
val.W.
;PUSHVAR _opsym ;Line=602
	LD A,[_opsym]
;PUSHNUM '(' ;Line=602
;OPERATION == ;Line=602
	SUB '('
;JUMP IF FALSE val.BI. ;Line=602
	JP NZ,val.BI.
;CALL rdword ;Line=603
	CALL rdword
;//первое слово expr
;CALL eatexpr ;Line=604
	CALL eatexpr
;//на выходе из expr уже прочитана ')', но следующий символ или команда не прочи
;PUSHVAR _t ;Line=605
	LD A,[_t]
;PUSHNUM _T_TYPE ;Line=605
;OPERATION & ;Line=605
;PUSHCONST _T_TYPE ;Line=605
	LD E,_T_TYPE
	AND E
;PUSHNUM 0x00 ;Line=605
;OPERATION != ;Line=605
	SUB 0x00
;JUMP IF FALSE val.BK. ;Line=605
	JP Z,val.BK.
;//(type)val //нельзя в sizeof(expr)
;PUSHVAR _t ;Line=606
	LD A,[_t]
;PUSHNUM _T_TYPE ;Line=606
;INV ;Line=606
;PUSHCONST _T_TYPE ;Line=606
	LD E,_T_TYPE
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=606
	AND L
;POPVAR val.t ;Line=606
	LD [val.t],A
;PUSHVAR val.t ;Line=607
	LD A,[val.t]
;POPVAR _t ;Line=607
	LD [_t],A
;CALL rdword ;Line=608
	CALL rdword
;CALL val ;Line=609
	CALL val
;accesspar=cmdcastto.A. ;Line=610
;PUSHVAR val.t ;Line=610
	LD A,[val.t]
;POPVAR cmdcastto.A. ;Line=610
	LD [cmdcastto.A.],A
;CALL cmdcastto ;Line=610
	CALL cmdcastto
val.BK.
;JUMP val.BJ. ;Line=612
	JP val.BJ.
val.BI.
;PUSHVAR _opsym ;Line=612
	LD A,[_opsym]
;PUSHNUM '-' ;Line=612
;OPERATION == ;Line=612
	SUB '-'
;JUMP IF FALSE val.BM. ;Line=612
	JP NZ,val.BM.
;/**isnum(_cnext)*/
;PUSHVAR _cnext ;Line=613
	LD A,[_cnext]
;OPERATION cast 5>0 ;Line=613
;PUSHNUM '0' ;Line=613
;OPERATION cast 5>0 ;Line=613
;OPERATION - ;Line=613
	SUB '0'
;OPERATION cast 0>0 ;Line=613
;PUSHNUM 0x0a ;Line=613
;OPERATION < ;Line=613
;PUSHCONST 0x0a ;Line=613
	LD E,0x0a
	SUB E
;JUMP IF FALSE val.BO. ;Line=613
	JP NC,val.BO.
;//-<const>
;CALL rdaddword ;Line=614
	CALL rdaddword
;//todo float
;PUSHNUM _T_INT ;Line=616
;POPVAR _t ;Line=616
;PUSHCONST _T_INT ;Line=616
	LD A,_T_INT
	LD [_t],A
;accesspar=strcopy.A. ;Line=617
;PUSHVAR _tword ;Line=617
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=617
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=617
;PUSHVAR _lentword ;Line=617
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=617
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=617
;PUSHVAR _joined ;Line=617
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=617
	LD [strcopy.C.],HL
;CALL strcopy ;Line=617
	CALL strcopy
;POPVAR _lenjoined ;Line=617
	LD [_lenjoined],HL
;CALL cmdpushnum ;Line=618
	CALL cmdpushnum
;JUMP val.BP. ;Line=619
	JP val.BP.
val.BO.
;//-<var>
;CALL rdword ;Line=620
	CALL rdword
;//первое слово val
;PUSHVAR _waseof ;Line=621
	LD A,[_waseof]
;INV ;Line=621
	CPL
;JUMP IF FALSE val.BQ. ;Line=621
	OR A
	JP Z,val.BQ.
;CALL val ;Line=621
	CALL val
val.BQ.
;//рекурсивный вызов val
;CALL cmdneg ;Line=622
	CALL cmdneg
val.BP.
;JUMP val.BN. ;Line=624
	JP val.BN.
val.BM.
;PUSHVAR _opsym ;Line=624
	LD A,[_opsym]
;PUSHNUM '!' ;Line=624
;OPERATION == ;Line=624
	SUB '!'
;JUMP IF FALSE val.BS. ;Line=624
	JP NZ,val.BS.
;CALL rdword ;Line=625
	CALL rdword
;//первое слово val
;PUSHVAR _waseof ;Line=626
	LD A,[_waseof]
;INV ;Line=626
	CPL
;JUMP IF FALSE val.BU. ;Line=626
	OR A
	JP Z,val.BU.
;CALL val ;Line=626
	CALL val
val.BU.
;//рекурсивный вызов val
;CALL cmdinv ;Line=627
	CALL cmdinv
;//TODO invBOOL
;JUMP val.BT. ;Line=628
	JP val.BT.
val.BS.
;PUSHVAR _opsym ;Line=628
	LD A,[_opsym]
;PUSHNUM '~' ;Line=628
;OPERATION == ;Line=628
	SUB '~'
;JUMP IF FALSE val.BW. ;Line=628
	JP NZ,val.BW.
;CALL rdword ;Line=629
	CALL rdword
;//первое слово val
;PUSHVAR _waseof ;Line=630
	LD A,[_waseof]
;INV ;Line=630
	CPL
;JUMP IF FALSE val.BY. ;Line=630
	OR A
	JP Z,val.BY.
;CALL val ;Line=630
	CALL val
val.BY.
;//рекурсивный вызов val
;CALL cmdinv ;Line=631
	CALL cmdinv
;JUMP val.BX. ;Line=632
	JP val.BX.
val.BW.
;PUSHVAR _opsym ;Line=632
	LD A,[_opsym]
;PUSHNUM '*' ;Line=632
;OPERATION == ;Line=632
	SUB '*'
;JUMP IF FALSE val.CA. ;Line=632
	JP NZ,val.CA.
;CALL rdword ;Line=633
	CALL rdword
;//'(' of type
;accesspar=eat.A. ;Line=634
;PUSHNUM '(' ;Line=634
;/**, "\'(\'"*/
;POPVAR eat.A. ;Line=634
;PUSHCONST '(' ;Line=634
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=634
	CALL eat
;//IF (*(PCHAR)_tword != '(') err_tword("\'(\'");
;CALL eattype ;Line=635
	CALL eattype
;/**|_T_POI*/
;POPVAR val.t ;Line=635
	LD [val.t],A
;//tpoi //todo PPOINTER
;accesspar=eat.A. ;Line=636
;PUSHNUM ')' ;Line=636
;/**, "\')\'"*/
;POPVAR eat.A. ;Line=636
;PUSHCONST ')' ;Line=636
	LD A,')'
	LD [eat.A.],A
;CALL eat ;Line=636
	CALL eat
;//IF (*(PCHAR)_tword != ')') err_tword("\')\'");
;PUSHVAR _waseof ;Line=637
	LD A,[_waseof]
;INV ;Line=637
	CPL
;JUMP IF FALSE val.CC. ;Line=637
	OR A
	JP Z,val.CC.
;CALL val ;Line=637
	CALL val
val.CC.
;//здесь тип указателя не важен //рекурсивный вызов val
;PUSHVAR val.t ;Line=638
	LD A,[val.t]
;PUSHNUM _T_POI ;Line=638
;INV ;Line=638
;PUSHCONST _T_POI ;Line=638
	LD E,_T_POI
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=638
	AND L
;POPVAR _t ;Line=638
	LD [_t],A
;//&~_T_CONST;
;CALL cmdpeek ;Line=639
	CALL cmdpeek
;JUMP val.CB. ;Line=640
	JP val.CB.
val.CA.
;PUSHVAR _opsym ;Line=640
	LD A,[_opsym]
;PUSHNUM '&' ;Line=640
;OPERATION == ;Line=640
	SUB '&'
;JUMP IF FALSE val.CE. ;Line=640
	JP NZ,val.CE.
;CALL rdword ;Line=641
	CALL rdword
;CALL adddots ;Line=642
	CALL adddots
;/**iscall*/
;accesspar=joinvarname.A. ;Line=643
;PUSHNUM FALSE ;Line=643
;POPVAR joinvarname.A. ;Line=643
;PUSHCONST FALSE ;Line=643
	LD A,FALSE
	LD [joinvarname.A.],A
;CALL joinvarname ;Line=643
	CALL joinvarname
;POPVAR _t ;Line=643
	LD [_t],A
;PUSHVAR _cnext ;Line=644
	LD A,[_cnext]
;PUSHNUM '[' ;Line=644
;OPERATION == ;Line=644
	SUB '['
;JUMP IF FALSE val.CG. ;Line=644
	JP NZ,val.CG.
;//&<varname>[<idx>]
;CALL rdword ;Line=645
	CALL rdword
;//'['
;accesspar=idxarray.A. ;Line=646
;PUSHPAR idxarray.A. ;Line=646
	LD A,[idxarray.A.]
;PUSHVAR _t ;Line=646
	LD L,A
	LD A,[_t]
;POPVAR idxarray.A. ;Line=646
	LD [idxarray.A.],A
;CALL idxarray ;Line=646
	PUSH HL
	CALL idxarray
;POPPAR ;Line=646
	POP DE
	LD L,A
	LD A,E
	LD [idxarray.A.],A
;/**тип элемента массива*/
;PUSHNUM _T_POI ;Line=646
;OPERATION | ;Line=646
;PUSHCONST _T_POI ;Line=646
	LD A,_T_POI
	OR L
;POPVAR _t ;Line=646
	LD [_t],A
;JUMP val.CH. ;Line=647
	JP val.CH.
val.CG.
;//&<varname>
;//IF ((_t&_T_ARRAY)!=0x00) { //&<arrayname> - error
;//}ELSE IF ((_t&_T_CONST)!=0x00) { //&<constname> - error
;//}ELSE { //&<varname>
;PUSHVAR _t ;Line=651
	LD A,[_t]
;PUSHNUM _TYPEMASK ;Line=651
;OPERATION & ;Line=651
;PUSHCONST _TYPEMASK ;Line=651
	LD E,_TYPEMASK
	AND E
;PUSHNUM _T_POI ;Line=651
;OPERATION | ;Line=651
;PUSHCONST _T_POI ;Line=651
	LD E,_T_POI
	OR E
;POPVAR _t ;Line=651
	LD [_t],A
;CALL cmdpushnum ;Line=652
	CALL cmdpushnum
;//};
val.CH.
;JUMP val.CF. ;Line=655
	JP val.CF.
val.CE.
;accesspar=errstr.A. ;Line=656
;PUSHNUM val.CI. ;Line=656
;POPVAR errstr.A. ;Line=656
;PUSHCONST val.CI. ;Line=656
	LD HL,val.CI.
	LD [errstr.A.],HL
;CALL errstr ;Line=656
	CALL errstr
;accesspar=err.A. ;Line=656
;PUSHVAR _opsym ;Line=656
	LD A,[_opsym]
;POPVAR err.A. ;Line=656
	LD [err.A.],A
;CALL err ;Line=656
	CALL err
;CALL enderr ;Line=656
	CALL enderr
;PUSHNUM _T_UNKNOWN ;Line=657
;POPVAR _t ;Line=657
;PUSHCONST _T_UNKNOWN ;Line=657
	LD A,_T_UNKNOWN
	LD [_t],A
;//debug (иначе может вылететь за таблицу typesz при обрыве файла)
val.CF.
val.CB.
val.BX.
val.BT.
val.BN.
val.BJ.
val.X.
val.V.
val.F.
val.D.
val.B.
;POPPAR ;Line=664
	POP HL
	LD A,L
	LD [val.t],A
;ENDFUNC ;Line=666
	RET
eatmulval
;FUNC ;Line=666
;PUSHPAR eatmulval.opsym ;Line=668
	LD A,[eatmulval.opsym]
;PUSHPAR eatmulval.t1 ;Line=669
	LD L,A
	PUSH HL
	LD A,[eatmulval.t1]
;//<val>[<*|/><val>...] => push[push<*|/>...]
;//заканчивается по символу любой неописанной операции (например, ')' или ';')
;//команда уже прочитана
;CALL val ;Line=677
	LD L,A
	PUSH HL
	CALL val
;CALL rdword ;Line=678
	CALL rdword
eatmulval.A.
;PUSHVAR _tword ;Line=683
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=683
;PEEK ;Line=683
	LD A,[HL]
;POPVAR eatmulval.opsym ;Line=683
	LD [eatmulval.opsym],A
;//IF (opsym==')') BREAK; //fast exit
;PUSHVAR eatmulval.opsym ;Line=685
	LD A,[eatmulval.opsym]
;PUSHNUM '*' ;Line=685
;OPERATION != ;Line=685
	SUB '*'
;JUMP IF FALSE eatmulval.C. ;Line=685
	JP Z,eatmulval.C.
;PUSHVAR eatmulval.opsym ;Line=686
	LD A,[eatmulval.opsym]
;PUSHNUM '/' ;Line=686
;OPERATION != ;Line=686
	SUB '/'
;JUMP IF FALSE eatmulval.E. ;Line=686
	JP Z,eatmulval.E.
;PUSHVAR eatmulval.opsym ;Line=687
	LD A,[eatmulval.opsym]
;PUSHNUM '&' ;Line=687
;OPERATION != ;Line=687
	SUB '&'
;JUMP IF FALSE eatmulval.G. ;Line=687
	JP Z,eatmulval.G.
;JUMP eatmulval.B. ;Line=688
	JP eatmulval.B.
eatmulval.G.
eatmulval.E.
eatmulval.C.
;PUSHVAR _t ;Line=689
	LD A,[_t]
;POPVAR eatmulval.t1 ;Line=689
	LD [eatmulval.t1],A
;CALL rdword ;Line=690
	CALL rdword
;PUSHVAR eatmulval.opsym ;Line=691
	LD A,[eatmulval.opsym]
;PUSHNUM '&' ;Line=691
;OPERATION == ;Line=691
	SUB '&'
;JUMP IF FALSE eatmulval.I. ;Line=691
	JP NZ,eatmulval.I.
;PUSHVAR _tword ;Line=692
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=692
;PEEK ;Line=692
	LD A,[HL]
;PUSHVAR eatmulval.opsym ;Line=692
	LD L,A
	LD A,[eatmulval.opsym]
;OPERATION == ;Line=692
	SUB L
;JUMP IF FALSE eatmulval.K. ;Line=692
	JP NZ,eatmulval.K.
;CALL rdword ;Line=693
	CALL rdword
eatmulval.K.
eatmulval.I.
;//use '&' //C compatibility
;CALL val ;Line=694
	CALL val
;PUSHVAR _t ;Line=695
	LD A,[_t]
;PUSHNUM _TYPEMASK ;Line=695
;OPERATION & ;Line=695
;PUSHCONST _TYPEMASK ;Line=695
	LD E,_TYPEMASK
	AND E
;POPVAR _t ;Line=695
	LD [_t],A
;//&(~_T_CONST);
;CALL rdword ;Line=696
	CALL rdword
;PUSHVAR eatmulval.t1 ;Line=700
	LD A,[eatmulval.t1]
;PUSHVAR _t ;Line=700
	LD L,A
	LD A,[_t]
;OPERATION != ;Line=700
	SUB L
;JUMP IF FALSE eatmulval.M. ;Line=700
	JP Z,eatmulval.M.
;accesspar=errstr.A. ;Line=700
;PUSHNUM eatmulval.O. ;Line=700
;POPVAR errstr.A. ;Line=700
;PUSHCONST eatmulval.O. ;Line=700
	LD HL,eatmulval.O.
	LD [errstr.A.],HL
;CALL errstr ;Line=700
	CALL errstr
;accesspar=err.A. ;Line=700
;PUSHVAR eatmulval.opsym ;Line=700
	LD A,[eatmulval.opsym]
;POPVAR err.A. ;Line=700
	LD [err.A.],A
;CALL err ;Line=700
	CALL err
;accesspar=errstr.A. ;Line=700
;PUSHNUM eatmulval.P. ;Line=700
;POPVAR errstr.A. ;Line=700
;PUSHCONST eatmulval.P. ;Line=700
	LD HL,eatmulval.P.
	LD [errstr.A.],HL
;CALL errstr ;Line=700
	CALL errstr
;accesspar=erruint.A. ;Line=700
;PUSHVAR eatmulval.t1 ;Line=700
	LD A,[eatmulval.t1]
;OPERATION cast 0>1 ;Line=700
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=700
	LD [erruint.A.],HL
;CALL erruint ;Line=700
	CALL erruint
;accesspar=errstr.A. ;Line=700
;PUSHNUM eatmulval.Q. ;Line=700
;POPVAR errstr.A. ;Line=700
;PUSHCONST eatmulval.Q. ;Line=700
	LD HL,eatmulval.Q.
	LD [errstr.A.],HL
;CALL errstr ;Line=700
	CALL errstr
;accesspar=erruint.A. ;Line=700
;PUSHVAR _t ;Line=700
	LD A,[_t]
;OPERATION cast 0>1 ;Line=700
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=700
	LD [erruint.A.],HL
;CALL erruint ;Line=700
	CALL erruint
;CALL enderr ;Line=700
	CALL enderr
eatmulval.M.
;PUSHVAR eatmulval.opsym ;Line=701
	LD A,[eatmulval.opsym]
;PUSHNUM '&' ;Line=701
;OPERATION == ;Line=701
	SUB '&'
;JUMP IF FALSE eatmulval.R. ;Line=701
	JP NZ,eatmulval.R.
;CALL cmdand ;Line=701
	CALL cmdand
;JUMP eatmulval.S. ;Line=702
	JP eatmulval.S.
eatmulval.R.
;PUSHVAR eatmulval.opsym ;Line=702
	LD A,[eatmulval.opsym]
;PUSHNUM '*' ;Line=702
;OPERATION == ;Line=702
	SUB '*'
;JUMP IF FALSE eatmulval.T. ;Line=702
	JP NZ,eatmulval.T.
;CALL cmdmul ;Line=702
	CALL cmdmul
;JUMP eatmulval.U. ;Line=703
	JP eatmulval.U.
eatmulval.T.
;/**IF (opsym=='/')*/
;CALL cmddiv ;Line=703
	CALL cmddiv
eatmulval.U.
eatmulval.S.
;PUSHVAR _waseof ;Line=705
	LD A,[_waseof]
;JUMP IF FALSE eatmulval.A. ;Line=705
	OR A
	JP Z,eatmulval.A.
eatmulval.B.
;POPPAR ;Line=710
	POP HL
	LD A,L
	LD [eatmulval.t1],A
;POPPAR ;Line=710
	POP HL
	LD A,L
	LD [eatmulval.opsym],A
;ENDFUNC ;Line=712
	RET
eatsumval
;FUNC ;Line=712
;PUSHPAR eatsumval.opsym ;Line=714
	LD A,[eatsumval.opsym]
;PUSHPAR eatsumval.t1 ;Line=715
	LD L,A
	PUSH HL
	LD A,[eatsumval.t1]
;//<mulval>[<+|-><mulval>...] => push[push<+|->...]
;//команда уже прочитана
;CALL eatmulval ;Line=722
	LD L,A
	PUSH HL
	CALL eatmulval
eatsumval.A.
;PUSHVAR _tword ;Line=724
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=724
;PEEK ;Line=724
	LD A,[HL]
;POPVAR eatsumval.opsym ;Line=724
	LD [eatsumval.opsym],A
;//IF (opsym==')') BREAK; //fast exit
;PUSHVAR eatsumval.opsym ;Line=726
	LD A,[eatsumval.opsym]
;PUSHNUM '+' ;Line=726
;OPERATION != ;Line=726
	SUB '+'
;JUMP IF FALSE eatsumval.C. ;Line=726
	JP Z,eatsumval.C.
;PUSHVAR eatsumval.opsym ;Line=727
	LD A,[eatsumval.opsym]
;PUSHNUM '-' ;Line=727
;OPERATION != ;Line=727
	SUB '-'
;JUMP IF FALSE eatsumval.E. ;Line=727
	JP Z,eatsumval.E.
;PUSHVAR eatsumval.opsym ;Line=728
	LD A,[eatsumval.opsym]
;PUSHNUM '|' ;Line=728
;OPERATION != ;Line=728
	SUB '|'
;JUMP IF FALSE eatsumval.G. ;Line=728
	JP Z,eatsumval.G.
;PUSHVAR eatsumval.opsym ;Line=729
	LD A,[eatsumval.opsym]
;PUSHNUM '^' ;Line=729
;OPERATION != ;Line=729
	SUB '^'
;JUMP IF FALSE eatsumval.I. ;Line=729
	JP Z,eatsumval.I.
;JUMP eatsumval.B. ;Line=730
	JP eatsumval.B.
eatsumval.I.
eatsumval.G.
eatsumval.E.
eatsumval.C.
;PUSHVAR _t ;Line=731
	LD A,[_t]
;POPVAR eatsumval.t1 ;Line=731
	LD [eatsumval.t1],A
;CALL rdword ;Line=732
	CALL rdword
;PUSHVAR _tword ;Line=733
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=733
;PEEK ;Line=733
	LD A,[HL]
;PUSHNUM '>' ;Line=733
;OPERATION == ;Line=733
	SUB '>'
;JUMP IF FALSE eatsumval.K. ;Line=733
	JP NZ,eatsumval.K.
;//structinstancepointer->structfield
;//структура уже прочитана и адресована, тип _t = некий указатель
;CALL gettypename ;Line=735
	CALL gettypename
;//взять название типа структуры в joined
;CALL rdword ;Line=736
	CALL rdword
;//use '>'
;CALL jdot ;Line=737
	CALL jdot
;/**to=*/
;accesspar=strjoin.A. ;Line=738
;PUSHVAR _joined ;Line=738
	LD HL,[_joined]
;POPVAR strjoin.A. ;Line=738
	LD [strjoin.A.],HL
;accesspar=strjoin.B. ;Line=738
;PUSHVAR _lenjoined ;Line=738
	LD HL,[_lenjoined]
;POPVAR strjoin.B. ;Line=738
	LD [strjoin.B.],HL
;accesspar=strjoin.C. ;Line=738
;PUSHVAR _tword ;Line=738
	LD HL,[_tword]
;POPVAR strjoin.C. ;Line=738
	LD [strjoin.C.],HL
;CALL strjoin ;Line=738
	CALL strjoin
;POPVAR _lenjoined ;Line=738
	LD [_lenjoined],HL
;//structname.structfield
;PUSHVAR _joined ;Line=739
	LD HL,[_joined]
;PUSHVAR _lenjoined ;Line=739
	LD DE,[_lenjoined]
;OPERATION +poi ;Line=739
	ADD HL,DE
;PUSHNUM '\0' ;Line=739
;POKE ;Line=739
;PUSHCONST '\0' ;Line=739
	LD A,'\0'
	LD [HL],A
;//strclose(_joined, _lenjoined);
;//_t = _T_POI|_T_BYTE; //тип уже - некий указатель
;CALL cmdpushnum ;Line=741
	CALL cmdpushnum
;//structname.structfield
;CALL cmdadd ;Line=742
	CALL cmdadd
;accesspar=strcopy.A. ;Line=743
;PUSHVAR _joined ;Line=743
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=743
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=743
;PUSHVAR _lenjoined ;Line=743
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=743
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=743
;PUSHVAR _name ;Line=743
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=743
	LD [strcopy.C.],HL
;CALL strcopy ;Line=743
	CALL strcopy
;POPVAR _lenname ;Line=743
	LD [_lenname],HL
;//structname.structfield
;CALL lbltype ;Line=744
	CALL lbltype
;POPVAR _t ;Line=744
	LD [_t],A
;//(_name)
;CALL cmdpeek ;Line=745
	CALL cmdpeek
;//peek
;CALL rdword ;Line=746
	CALL rdword
;//использовали structfield
;JUMP eatsumval.L. ;Line=747
	JP eatsumval.L.
eatsumval.K.
;PUSHVAR eatsumval.opsym ;Line=748
	LD A,[eatsumval.opsym]
;PUSHNUM '|' ;Line=748
;OPERATION == ;Line=748
	SUB '|'
;JUMP IF FALSE eatsumval.M. ;Line=748
	JP NZ,eatsumval.M.
;//||(opsym=='^')
;PUSHVAR _tword ;Line=749
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=749
;PEEK ;Line=749
	LD A,[HL]
;PUSHVAR eatsumval.opsym ;Line=749
	LD L,A
	LD A,[eatsumval.opsym]
;OPERATION == ;Line=749
	SUB L
;JUMP IF FALSE eatsumval.O. ;Line=749
	JP NZ,eatsumval.O.
;CALL rdword ;Line=750
	CALL rdword
eatsumval.O.
eatsumval.M.
;//use '|' or '^' //C compatibility
;CALL eatmulval ;Line=751
	CALL eatmulval
;PUSHVAR _t ;Line=752
	LD A,[_t]
;PUSHNUM _TYPEMASK ;Line=752
;OPERATION & ;Line=752
;PUSHCONST _TYPEMASK ;Line=752
	LD E,_TYPEMASK
	AND E
;POPVAR _t ;Line=752
	LD [_t],A
;//&(~_T_CONST);
;PUSHVAR eatsumval.t1 ;Line=753
	LD A,[eatsumval.t1]
;PUSHVAR _t ;Line=753
	LD L,A
	LD A,[_t]
;OPERATION != ;Line=753
	SUB L
;JUMP IF FALSE eatsumval.Q. ;Line=753
	JP Z,eatsumval.Q.
;/**&& ((t&_T_POI)!=0x00)*/
;accesspar=errstr.A. ;Line=753
;PUSHNUM eatsumval.S. ;Line=753
;POPVAR errstr.A. ;Line=753
;PUSHCONST eatsumval.S. ;Line=753
	LD HL,eatsumval.S.
	LD [errstr.A.],HL
;CALL errstr ;Line=753
	CALL errstr
;accesspar=err.A. ;Line=753
;PUSHVAR eatsumval.opsym ;Line=753
	LD A,[eatsumval.opsym]
;POPVAR err.A. ;Line=753
	LD [err.A.],A
;CALL err ;Line=753
	CALL err
;accesspar=errstr.A. ;Line=753
;PUSHNUM eatsumval.T. ;Line=753
;POPVAR errstr.A. ;Line=753
;PUSHCONST eatsumval.T. ;Line=753
	LD HL,eatsumval.T.
	LD [errstr.A.],HL
;CALL errstr ;Line=753
	CALL errstr
;accesspar=erruint.A. ;Line=753
;PUSHVAR eatsumval.t1 ;Line=753
	LD A,[eatsumval.t1]
;OPERATION cast 0>1 ;Line=753
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=753
	LD [erruint.A.],HL
;CALL erruint ;Line=753
	CALL erruint
;accesspar=errstr.A. ;Line=753
;PUSHNUM eatsumval.U. ;Line=753
;POPVAR errstr.A. ;Line=753
;PUSHCONST eatsumval.U. ;Line=753
	LD HL,eatsumval.U.
	LD [errstr.A.],HL
;CALL errstr ;Line=753
	CALL errstr
;accesspar=erruint.A. ;Line=753
;PUSHVAR _t ;Line=753
	LD A,[_t]
;OPERATION cast 0>1 ;Line=753
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=753
	LD [erruint.A.],HL
;CALL erruint ;Line=753
	CALL erruint
;CALL enderr ;Line=753
	CALL enderr
eatsumval.Q.
;//todo addpointer
;PUSHVAR eatsumval.opsym ;Line=755
	LD A,[eatsumval.opsym]
;PUSHNUM '+' ;Line=755
;OPERATION == ;Line=755
	SUB '+'
;JUMP IF FALSE eatsumval.V. ;Line=755
	JP NZ,eatsumval.V.
;CALL cmdadd ;Line=755
	CALL cmdadd
;JUMP eatsumval.W. ;Line=756
	JP eatsumval.W.
eatsumval.V.
;PUSHVAR eatsumval.opsym ;Line=756
	LD A,[eatsumval.opsym]
;PUSHNUM '-' ;Line=756
;OPERATION == ;Line=756
	SUB '-'
;JUMP IF FALSE eatsumval.X. ;Line=756
	JP NZ,eatsumval.X.
;CALL cmdsub ;Line=756
	CALL cmdsub
;//из старого вычесть новое!
;JUMP eatsumval.Y. ;Line=757
	JP eatsumval.Y.
eatsumval.X.
;PUSHVAR eatsumval.opsym ;Line=757
	LD A,[eatsumval.opsym]
;PUSHNUM '|' ;Line=757
;OPERATION == ;Line=757
	SUB '|'
;JUMP IF FALSE eatsumval.Z. ;Line=757
	JP NZ,eatsumval.Z.
;CALL cmdor ;Line=757
	CALL cmdor
;JUMP eatsumval.BA. ;Line=758
	JP eatsumval.BA.
eatsumval.Z.
;/**IF (opsym == '^')*/
;CALL cmdxor ;Line=758
	CALL cmdxor
eatsumval.BA.
eatsumval.Y.
eatsumval.W.
eatsumval.L.
;PUSHVAR _waseof ;Line=761
	LD A,[_waseof]
;JUMP IF FALSE eatsumval.A. ;Line=761
	OR A
	JP Z,eatsumval.A.
eatsumval.B.
;POPPAR ;Line=766
	POP HL
	LD A,L
	LD [eatsumval.t1],A
;POPPAR ;Line=766
	POP HL
	LD A,L
	LD [eatsumval.opsym],A
;ENDFUNC ;Line=768
	RET
eatexpr
;FUNC ;Line=768
;PUSHPAR eatexpr.opsym ;Line=770
	LD A,[eatexpr.opsym]
;PUSHPAR eatexpr.t1 ;Line=771
	LD L,A
	PUSH HL
	LD A,[eatexpr.t1]
;PUSHPAR eatexpr.modified ;Line=772
	LD L,A
	PUSH HL
	LD A,[eatexpr.modified]
;PUSHPAR eatexpr.dbl ;Line=773
	LD L,A
	PUSH HL
	LD A,[eatexpr.dbl]
;//<sumval>[<=><sumval>...]
;//команда уже прочитана (нужно для do_call_par)
;OPERATION ++ ;Line=780
	LD L,A
	PUSH HL
;PUSHNUM _exprlvl ;Line=780
;PUSHCONST _exprlvl ;Line=780
	LD HL,_exprlvl
	INC [HL]
;CALL eatsumval ;Line=781
	CALL eatsumval
eatexpr.A.
;PUSHVAR _tword ;Line=783
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=783
;PEEK ;Line=783
	LD A,[HL]
;POPVAR eatexpr.opsym ;Line=783
	LD [eatexpr.opsym],A
;//IF (opsym==')') BREAK; //fast exit
;PUSHVAR eatexpr.opsym ;Line=785
	LD A,[eatexpr.opsym]
;PUSHNUM '<' ;Line=785
;OPERATION != ;Line=785
	SUB '<'
;JUMP IF FALSE eatexpr.C. ;Line=785
	JP Z,eatexpr.C.
;PUSHVAR eatexpr.opsym ;Line=786
	LD A,[eatexpr.opsym]
;PUSHNUM '>' ;Line=786
;OPERATION != ;Line=786
	SUB '>'
;JUMP IF FALSE eatexpr.E. ;Line=786
	JP Z,eatexpr.E.
;PUSHVAR eatexpr.opsym ;Line=787
	LD A,[eatexpr.opsym]
;PUSHNUM '=' ;Line=787
;OPERATION != ;Line=787
	SUB '='
;JUMP IF FALSE eatexpr.G. ;Line=787
	JP Z,eatexpr.G.
;PUSHVAR eatexpr.opsym ;Line=788
	LD A,[eatexpr.opsym]
;PUSHNUM '!' ;Line=788
;OPERATION != ;Line=788
	SUB '!'
;JUMP IF FALSE eatexpr.I. ;Line=788
	JP Z,eatexpr.I.
;JUMP eatexpr.B. ;Line=789
	JP eatexpr.B.
eatexpr.I.
eatexpr.G.
eatexpr.E.
eatexpr.C.
;PUSHVAR _t ;Line=790
	LD A,[_t]
;POPVAR eatexpr.t1 ;Line=790
	LD [eatexpr.t1],A
;CALL rdword ;Line=791
	CALL rdword
;PUSHVAR _tword ;Line=792
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=792
;PEEK ;Line=792
	LD A,[HL]
;PUSHNUM '=' ;Line=792
;OPERATION == ;Line=792
	SUB '='
	SUB 1
	SBC A,A
;POPVAR eatexpr.modified ;Line=792
	LD [eatexpr.modified],A
;PUSHVAR _tword ;Line=793
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=793
;PEEK ;Line=793
	LD A,[HL]
;PUSHVAR eatexpr.opsym ;Line=793
	LD L,A
	LD A,[eatexpr.opsym]
;OPERATION == ;Line=793
	SUB L
	SUB 1
	SBC A,A
;POPVAR eatexpr.dbl ;Line=793
	LD [eatexpr.dbl],A
;PUSHVAR eatexpr.modified ;Line=794
	LD A,[eatexpr.modified]
;PUSHVAR eatexpr.dbl ;Line=794
	LD L,A
	LD A,[eatexpr.dbl]
;OPERATION | ;Line=794
	OR L
;JUMP IF FALSE eatexpr.K. ;Line=794
	JP Z,eatexpr.K.
;CALL rdword ;Line=794
	CALL rdword
eatexpr.K.
;//use '=' or '>' or '<'
;CALL eatsumval ;Line=795
	CALL eatsumval
;PUSHVAR _t ;Line=796
	LD A,[_t]
;PUSHNUM _TYPEMASK ;Line=796
;OPERATION & ;Line=796
;PUSHCONST _TYPEMASK ;Line=796
	LD E,_TYPEMASK
	AND E
;POPVAR _t ;Line=796
	LD [_t],A
;//&(~_T_CONST);
;PUSHVAR eatexpr.t1 ;Line=797
	LD A,[eatexpr.t1]
;PUSHVAR _t ;Line=797
	LD L,A
	LD A,[_t]
;OPERATION != ;Line=797
	SUB L
;JUMP IF FALSE eatexpr.M. ;Line=797
	JP Z,eatexpr.M.
;accesspar=errstr.A. ;Line=797
;PUSHNUM eatexpr.O. ;Line=797
;POPVAR errstr.A. ;Line=797
;PUSHCONST eatexpr.O. ;Line=797
	LD HL,eatexpr.O.
	LD [errstr.A.],HL
;CALL errstr ;Line=797
	CALL errstr
;accesspar=err.A. ;Line=797
;PUSHVAR eatexpr.opsym ;Line=797
	LD A,[eatexpr.opsym]
;POPVAR err.A. ;Line=797
	LD [err.A.],A
;CALL err ;Line=797
	CALL err
;accesspar=errstr.A. ;Line=797
;PUSHNUM eatexpr.P. ;Line=797
;POPVAR errstr.A. ;Line=797
;PUSHCONST eatexpr.P. ;Line=797
	LD HL,eatexpr.P.
	LD [errstr.A.],HL
;CALL errstr ;Line=797
	CALL errstr
;accesspar=erruint.A. ;Line=797
;PUSHVAR eatexpr.t1 ;Line=797
	LD A,[eatexpr.t1]
;OPERATION cast 0>1 ;Line=797
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=797
	LD [erruint.A.],HL
;CALL erruint ;Line=797
	CALL erruint
;accesspar=errstr.A. ;Line=797
;PUSHNUM eatexpr.Q. ;Line=797
;POPVAR errstr.A. ;Line=797
;PUSHCONST eatexpr.Q. ;Line=797
	LD HL,eatexpr.Q.
	LD [errstr.A.],HL
;CALL errstr ;Line=797
	CALL errstr
;accesspar=erruint.A. ;Line=797
;PUSHVAR _t ;Line=797
	LD A,[_t]
;OPERATION cast 0>1 ;Line=797
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=797
	LD [erruint.A.],HL
;CALL erruint ;Line=797
	CALL erruint
;CALL enderr ;Line=797
	CALL enderr
eatexpr.M.
;PUSHVAR eatexpr.opsym ;Line=798
	LD A,[eatexpr.opsym]
;PUSHNUM '=' ;Line=798
;OPERATION == ;Line=798
	SUB '='
;JUMP IF FALSE eatexpr.R. ;Line=798
	JP NZ,eatexpr.R.
;PUSHVAR eatexpr.dbl ;Line=799
	LD A,[eatexpr.dbl]
;INV ;Line=799
	CPL
;JUMP IF FALSE eatexpr.T. ;Line=799
	OR A
	JP Z,eatexpr.T.
;accesspar=errstr.A. ;Line=799
;PUSHNUM eatexpr.V. ;Line=799
;POPVAR errstr.A. ;Line=799
;PUSHCONST eatexpr.V. ;Line=799
	LD HL,eatexpr.V.
	LD [errstr.A.],HL
;CALL errstr ;Line=799
	CALL errstr
;CALL enderr ;Line=799
	CALL enderr
eatexpr.T.
;CALL cmdeq ;Line=800
	CALL cmdeq
;//делает _t = _T_BOOL
;JUMP eatexpr.S. ;Line=801
	JP eatexpr.S.
eatexpr.R.
;PUSHVAR eatexpr.opsym ;Line=801
	LD A,[eatexpr.opsym]
;PUSHNUM '!' ;Line=801
;OPERATION == ;Line=801
	SUB '!'
;JUMP IF FALSE eatexpr.W. ;Line=801
	JP NZ,eatexpr.W.
;CALL cmdnoteq ;Line=802
	CALL cmdnoteq
;//делает _t = _T_BOOL
;JUMP eatexpr.X. ;Line=803
	JP eatexpr.X.
eatexpr.W.
;PUSHVAR eatexpr.opsym ;Line=803
	LD A,[eatexpr.opsym]
;PUSHNUM '<' ;Line=803
;OPERATION == ;Line=803
	SUB '<'
;JUMP IF FALSE eatexpr.Y. ;Line=803
	JP NZ,eatexpr.Y.
;PUSHVAR eatexpr.dbl ;Line=804
	LD A,[eatexpr.dbl]
;JUMP IF FALSE eatexpr.BA. ;Line=804
	OR A
	JP Z,eatexpr.BA.
;CALL cmdshl ;Line=805
	CALL cmdshl
;//старое сдвинуть столько раз, сколько гласит новое!
;JUMP eatexpr.BB. ;Line=806
	JP eatexpr.BB.
eatexpr.BA.
;PUSHVAR eatexpr.modified ;Line=806
	LD A,[eatexpr.modified]
;JUMP IF FALSE eatexpr.BC. ;Line=806
	OR A
	JP Z,eatexpr.BC.
;CALL cmdlesseq ;Line=807
	CALL cmdlesseq
;//делает _t = _T_BOOL
;JUMP eatexpr.BD. ;Line=808
	JP eatexpr.BD.
eatexpr.BC.
;CALL cmdless ;Line=808
	CALL cmdless
eatexpr.BD.
eatexpr.BB.
;//делает _t = _T_BOOL
;JUMP eatexpr.Z. ;Line=809
	JP eatexpr.Z.
eatexpr.Y.
;/**IF (opsym == '>')*/
;PUSHVAR eatexpr.dbl ;Line=810
	LD A,[eatexpr.dbl]
;JUMP IF FALSE eatexpr.BE. ;Line=810
	OR A
	JP Z,eatexpr.BE.
;CALL cmdshr ;Line=811
	CALL cmdshr
;//старое сдвинуть столько раз, сколько гласит новое!
;JUMP eatexpr.BF. ;Line=812
	JP eatexpr.BF.
eatexpr.BE.
;PUSHVAR eatexpr.modified ;Line=812
	LD A,[eatexpr.modified]
;JUMP IF FALSE eatexpr.BG. ;Line=812
	OR A
	JP Z,eatexpr.BG.
;CALL cmdmoreeq ;Line=813
	CALL cmdmoreeq
;//делает _t = _T_BOOL
;JUMP eatexpr.BH. ;Line=814
	JP eatexpr.BH.
eatexpr.BG.
;CALL cmdmore ;Line=814
	CALL cmdmore
eatexpr.BH.
eatexpr.BF.
;//делает _t = _T_BOOL
eatexpr.Z.
eatexpr.X.
eatexpr.S.
;PUSHVAR _waseof ;Line=816
	LD A,[_waseof]
;JUMP IF FALSE eatexpr.A. ;Line=816
	OR A
	JP Z,eatexpr.A.
eatexpr.B.
;//тут ожидается (в _tword) ')' или другой несоответствующий символ
;OPERATION -- ;Line=818
;PUSHNUM _exprlvl ;Line=818
;PUSHCONST _exprlvl ;Line=818
	LD HL,_exprlvl
	DEC [HL]
;POPPAR ;Line=824
	POP HL
	LD A,L
	LD [eatexpr.dbl],A
;POPPAR ;Line=824
	POP HL
	LD A,L
	LD [eatexpr.modified],A
;POPPAR ;Line=824
	POP HL
	LD A,L
	LD [eatexpr.t1],A
;POPPAR ;Line=824
	POP HL
	LD A,L
	LD [eatexpr.opsym],A
;ENDFUNC ;Line=826
	RET
eatpoke
;FUNC ;Line=826
;//poke*(<ptype>)(<pointerexpr>)=<expr>
;PUSHNUM 0x01 ;Line=833
;POPVAR _exprlvl ;Line=833
;PUSHCONST 0x01 ;Line=833
	LD A,0x01
	LD [_exprlvl],A
;//no jump optimization
;accesspar=eat.A. ;Line=834
;PUSHNUM '*' ;Line=834
;POPVAR eat.A. ;Line=834
;PUSHCONST '*' ;Line=834
	LD A,'*'
	LD [eat.A.],A
;CALL eat ;Line=834
	CALL eat
;accesspar=eat.A. ;Line=835
;PUSHNUM '(' ;Line=835
;POPVAR eat.A. ;Line=835
;PUSHCONST '(' ;Line=835
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=835
	CALL eat
;CALL eattype ;Line=836
	CALL eattype
;PUSHNUM _T_POI ;Line=836
;INV ;Line=836
;PUSHCONST _T_POI ;Line=836
	LD E,_T_POI
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=836
	AND L
;POPVAR eatpoke.t ;Line=836
	LD [eatpoke.t],A
;accesspar=eat.A. ;Line=837
;PUSHNUM ')' ;Line=837
;POPVAR eat.A. ;Line=837
;PUSHCONST ')' ;Line=837
	LD A,')'
	LD [eat.A.],A
;CALL eat ;Line=837
	CALL eat
;accesspar=eat.A. ;Line=838
;PUSHNUM '(' ;Line=838
;POPVAR eat.A. ;Line=838
;PUSHCONST '(' ;Line=838
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=838
	CALL eat
;//'=' может быть в выражении
;CALL eatexpr ;Line=839
	CALL eatexpr
;//todo проверить pointer
;accesspar=eat.A. ;Line=841
;PUSHNUM ')' ;Line=841
;POPVAR eat.A. ;Line=841
;PUSHCONST ')' ;Line=841
	LD A,')'
	LD [eat.A.],A
;CALL eat ;Line=841
	CALL eat
;//'=' может быть в выражении
;accesspar=eat.A. ;Line=842
;PUSHNUM '=' ;Line=842
;POPVAR eat.A. ;Line=842
;PUSHCONST '=' ;Line=842
	LD A,'='
	LD [eat.A.],A
;CALL eat ;Line=842
	CALL eat
;CALL eatexpr ;Line=843
	CALL eatexpr
;PUSHVAR eatpoke.t ;Line=844
	LD A,[eatpoke.t]
;PUSHVAR _t ;Line=844
	LD L,A
	LD A,[_t]
;OPERATION != ;Line=844
	SUB L
;JUMP IF FALSE eatpoke.A. ;Line=844
	JP Z,eatpoke.A.
;accesspar=errstr.A. ;Line=844
;PUSHNUM eatpoke.C. ;Line=844
;POPVAR errstr.A. ;Line=844
;PUSHCONST eatpoke.C. ;Line=844
	LD HL,eatpoke.C.
	LD [errstr.A.],HL
;CALL errstr ;Line=844
	CALL errstr
;accesspar=erruint.A. ;Line=844
;PUSHVAR eatpoke.t ;Line=844
	LD A,[eatpoke.t]
;OPERATION cast 0>1 ;Line=844
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=844
	LD [erruint.A.],HL
;CALL erruint ;Line=844
	CALL erruint
;accesspar=errstr.A. ;Line=844
;PUSHNUM eatpoke.D. ;Line=844
;POPVAR errstr.A. ;Line=844
;PUSHCONST eatpoke.D. ;Line=844
	LD HL,eatpoke.D.
	LD [errstr.A.],HL
;CALL errstr ;Line=844
	CALL errstr
;accesspar=erruint.A. ;Line=844
;PUSHVAR _t ;Line=844
	LD A,[_t]
;OPERATION cast 0>1 ;Line=844
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=844
	LD [erruint.A.],HL
;CALL erruint ;Line=844
	CALL erruint
;CALL enderr ;Line=844
	CALL enderr
eatpoke.A.
;CALL cmdpoke ;Line=845
	CALL cmdpoke
;ENDFUNC ;Line=851
	RET
eatlet
;FUNC ;Line=851
;//<var>[<[><expr><]>]=<expr>
;//<var>-><field>=<expr>
;PUSHNUM 0x01 ;Line=860
;POPVAR _exprlvl ;Line=860
;PUSHCONST 0x01 ;Line=860
	LD A,0x01
	LD [_exprlvl],A
;//no jump optimization
;/**iscall*/
;accesspar=joinvarname.A. ;Line=861
;PUSHNUM FALSE ;Line=861
;POPVAR joinvarname.A. ;Line=861
;PUSHCONST FALSE ;Line=861
	LD A,FALSE
	LD [joinvarname.A.],A
;CALL joinvarname ;Line=861
	CALL joinvarname
;POPVAR eatlet.t ;Line=861
	LD [eatlet.t],A
;//t!!!
;CALL rdword ;Line=862
	CALL rdword
;//'['
;PUSHNUM FALSE ;Line=863
;POPVAR eatlet.ispoke ;Line=863
;PUSHCONST FALSE ;Line=863
	LD A,FALSE
	LD [eatlet.ispoke],A
;PUSHVAR _tword ;Line=864
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=864
;PEEK ;Line=864
	LD A,[HL]
;/**_cnext*/
;PUSHNUM '[' ;Line=864
;OPERATION == ;Line=864
	SUB '['
;JUMP IF FALSE eatlet.A. ;Line=864
	JP NZ,eatlet.A.
;accesspar=idxarray.A. ;Line=865
;PUSHPAR idxarray.A. ;Line=865
	LD A,[idxarray.A.]
;PUSHVAR eatlet.t ;Line=865
	LD L,A
	LD A,[eatlet.t]
;POPVAR idxarray.A. ;Line=865
	LD [idxarray.A.],A
;CALL idxarray ;Line=865
	PUSH HL
	CALL idxarray
;POPPAR ;Line=865
	POP DE
	LD L,A
	LD A,E
	LD [idxarray.A.],A
;POPVAR eatlet.t ;Line=865
	LD A,L
	LD [eatlet.t],A
;//t = t&(~(_T_ARRAY|_T_POI));
;accesspar=eat.A. ;Line=866
;PUSHNUM ']' ;Line=866
;POPVAR eat.A. ;Line=866
;PUSHCONST ']' ;Line=866
	LD A,']'
	LD [eat.A.],A
;CALL eat ;Line=866
	CALL eat
;PUSHNUM TRUE ;Line=867
;POPVAR eatlet.ispoke ;Line=867
;PUSHCONST TRUE ;Line=867
	LD A,TRUE
	LD [eatlet.ispoke],A
;JUMP eatlet.B. ;Line=868
	JP eatlet.B.
eatlet.A.
eatlet.C.
;PUSHVAR _tword ;Line=869
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=869
;PEEK ;Line=869
	LD A,[HL]
;/**_cnext*/
;PUSHNUM '-' ;Line=869
;OPERATION == ;Line=869
	SUB '-'
;JUMP IF FALSE eatlet.D. ;Line=869
	JP NZ,eatlet.D.
;PUSHVAR eatlet.t ;Line=870
	LD A,[eatlet.t]
;POPVAR _t ;Line=870
	LD [_t],A
;PUSHVAR eatlet.ispoke ;Line=871
	LD A,[eatlet.ispoke]
;JUMP IF FALSE eatlet.E. ;Line=871
	OR A
	JP Z,eatlet.E.
;//не первый ->
;CALL cmdpeek ;Line=872
	CALL cmdpeek
;JUMP eatlet.F. ;Line=873
	JP eatlet.F.
eatlet.E.
;//первый ->
;CALL cmdpushvar ;Line=874
	CALL cmdpushvar
;//указатель (в том числе на структуру) или обычная переменная
eatlet.F.
;accesspar=eat.A. ;Line=876
;PUSHNUM '-' ;Line=876
;POPVAR eat.A. ;Line=876
;PUSHCONST '-' ;Line=876
	LD A,'-'
	LD [eat.A.],A
;CALL eat ;Line=876
	CALL eat
;//структура уже прочитана и адресована, тип _t = некий указатель
;CALL gettypename ;Line=878
	CALL gettypename
;//взять название типа структуры в joined
;accesspar=eat.A. ;Line=879
;PUSHNUM '>' ;Line=879
;POPVAR eat.A. ;Line=879
;PUSHCONST '>' ;Line=879
	LD A,'>'
	LD [eat.A.],A
;CALL eat ;Line=879
	CALL eat
;//rdword(); //use '>'
;CALL jdot ;Line=880
	CALL jdot
;/**to=*/
;accesspar=strjoin.A. ;Line=881
;PUSHVAR _joined ;Line=881
	LD HL,[_joined]
;POPVAR strjoin.A. ;Line=881
	LD [strjoin.A.],HL
;accesspar=strjoin.B. ;Line=881
;PUSHVAR _lenjoined ;Line=881
	LD HL,[_lenjoined]
;POPVAR strjoin.B. ;Line=881
	LD [strjoin.B.],HL
;accesspar=strjoin.C. ;Line=881
;PUSHVAR _tword ;Line=881
	LD HL,[_tword]
;POPVAR strjoin.C. ;Line=881
	LD [strjoin.C.],HL
;CALL strjoin ;Line=881
	CALL strjoin
;POPVAR _lenjoined ;Line=881
	LD [_lenjoined],HL
;//structname.structfield
;PUSHVAR _joined ;Line=882
	LD HL,[_joined]
;PUSHVAR _lenjoined ;Line=882
	LD DE,[_lenjoined]
;OPERATION +poi ;Line=882
	ADD HL,DE
;PUSHNUM '\0' ;Line=882
;POKE ;Line=882
;PUSHCONST '\0' ;Line=882
	LD A,'\0'
	LD [HL],A
;//strclose(_joined, _lenjoined);
;//_t = _T_POI|_T_BYTE; //тип уже - некий указатель
;CALL cmdpushnum ;Line=884
	CALL cmdpushnum
;//structname.structfield
;CALL cmdadd ;Line=885
	CALL cmdadd
;accesspar=strcopy.A. ;Line=886
;PUSHVAR _joined ;Line=886
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=886
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=886
;PUSHVAR _lenjoined ;Line=886
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=886
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=886
;PUSHVAR _name ;Line=886
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=886
	LD [strcopy.C.],HL
;CALL strcopy ;Line=886
	CALL strcopy
;POPVAR _lenname ;Line=886
	LD [_lenname],HL
;//structname.structfield
;CALL lbltype ;Line=887
	CALL lbltype
;POPVAR eatlet.t ;Line=887
	LD [eatlet.t],A
;//(_name)
;CALL rdword ;Line=888
	CALL rdword
;//использовали structfield
;PUSHNUM TRUE ;Line=889
;POPVAR eatlet.ispoke ;Line=889
;PUSHCONST TRUE ;Line=889
	LD A,TRUE
	LD [eatlet.ispoke],A
;JUMP eatlet.C. ;Line=890
	JP eatlet.C.
eatlet.D.
eatlet.B.
;accesspar=eat.A. ;Line=892
;PUSHNUM '=' ;Line=892
;POPVAR eat.A. ;Line=892
;PUSHCONST '=' ;Line=892
	LD A,'='
	LD [eat.A.],A
;CALL eat ;Line=892
	CALL eat
;accesspar=strpush.A. ;Line=893
;PUSHVAR _joined ;Line=893
	LD HL,[_joined]
;POPVAR strpush.A. ;Line=893
	LD [strpush.A.],HL
;accesspar=strpush.B. ;Line=893
;PUSHVAR _lenjoined ;Line=893
	LD HL,[_lenjoined]
;POPVAR strpush.B. ;Line=893
	LD [strpush.B.],HL
;CALL strpush ;Line=893
	CALL strpush
;CALL eatexpr ;Line=894
	CALL eatexpr
;//получает тип _t
;accesspar=strpop.A. ;Line=895
;PUSHVAR _joined ;Line=895
	LD HL,[_joined]
;POPVAR strpop.A. ;Line=895
	LD [strpop.A.],HL
;CALL strpop ;Line=895
	CALL strpop
;POPVAR _lenjoined ;Line=895
	LD [_lenjoined],HL
;PUSHVAR eatlet.t ;Line=896
	LD A,[eatlet.t]
;PUSHVAR _t ;Line=896
	LD L,A
	LD A,[_t]
;OPERATION != ;Line=896
	SUB L
;JUMP IF FALSE eatlet.G. ;Line=896
	JP Z,eatlet.G.
;accesspar=errstr.A. ;Line=897
;PUSHNUM eatlet.I. ;Line=897
;POPVAR errstr.A. ;Line=897
;PUSHCONST eatlet.I. ;Line=897
	LD HL,eatlet.I.
	LD [errstr.A.],HL
;CALL errstr ;Line=897
	CALL errstr
;accesspar=erruint.A. ;Line=897
;PUSHVAR eatlet.t ;Line=897
	LD A,[eatlet.t]
;OPERATION cast 0>1 ;Line=897
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=897
	LD [erruint.A.],HL
;CALL erruint ;Line=897
	CALL erruint
;accesspar=errstr.A. ;Line=897
;PUSHNUM eatlet.J. ;Line=897
;POPVAR errstr.A. ;Line=897
;PUSHCONST eatlet.J. ;Line=897
	LD HL,eatlet.J.
	LD [errstr.A.],HL
;CALL errstr ;Line=897
	CALL errstr
;accesspar=erruint.A. ;Line=897
;PUSHVAR _t ;Line=897
	LD A,[_t]
;OPERATION cast 0>1 ;Line=897
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=897
	LD [erruint.A.],HL
;CALL erruint ;Line=897
	CALL erruint
;CALL enderr ;Line=897
	CALL enderr
eatlet.G.
;PUSHVAR eatlet.ispoke ;Line=899
	LD A,[eatlet.ispoke]
;JUMP IF FALSE eatlet.K. ;Line=899
	OR A
	JP Z,eatlet.K.
;CALL cmdpoke ;Line=900
	CALL cmdpoke
;JUMP eatlet.L. ;Line=901
	JP eatlet.L.
eatlet.K.
;CALL cmdpopvar ;Line=902
	CALL cmdpopvar
eatlet.L.
;ENDFUNC ;Line=909
	RET
eatwhile
;FUNC ;Line=909
;//while<expr><cmd>[;]
;//; против ошибки "WHILE (expr);cmd"
;/**LOCAL ;генерирует уникальный_идентификаторTEMPWHILE: ;эквивалентно уникальны
;PUSHPAR eatwhile.beglbl ;Line=923
	LD HL,[eatwhile.beglbl]
;PUSHPAR eatwhile.wasendlbl ;Line=924
	PUSH HL
	LD HL,[eatwhile.wasendlbl]
;PUSHNUM 0x00 ;Line=929
;POPVAR _exprlvl ;Line=929
;PUSHCONST 0x00 ;Line=929
	LD A,0x00
	LD [_exprlvl],A
;//jump optimization possible
;PUSHVAR _tmpendlbl ;Line=930
	LD DE,[_tmpendlbl]
;POPVAR eatwhile.wasendlbl ;Line=930
	LD [eatwhile.wasendlbl],DE
;PUSHVAR _curlbl ;Line=931
	LD DE,[_curlbl]
;POPVAR eatwhile.beglbl ;Line=931
	LD [eatwhile.beglbl],DE
;OPERATION ++ ;Line=931
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
;PUSHVAR _curlbl ;Line=932
	LD DE,[_curlbl]
;POPVAR _tmpendlbl ;Line=932
	LD [_tmpendlbl],DE
;OPERATION ++ ;Line=932
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
;accesspar=genjplbl.A. ;Line=933
;PUSHVAR eatwhile.beglbl ;Line=933
	LD DE,[eatwhile.beglbl]
;POPVAR genjplbl.A. ;Line=933
	LD [genjplbl.A.],DE
;CALL genjplbl ;Line=933
	PUSH HL
	CALL genjplbl
;CALL cmdlabel ;Line=933
	CALL cmdlabel
;accesspar=eat.A. ;Line=934
;PUSHNUM '(' ;Line=934
;POPVAR eat.A. ;Line=934
;PUSHCONST '(' ;Line=934
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=934
	CALL eat
;CALL eatexpr ;Line=935
	CALL eatexpr
;//parentheses not included
;accesspar=genjplbl.A. ;Line=936
;PUSHVAR _tmpendlbl ;Line=936
	LD HL,[_tmpendlbl]
;POPVAR genjplbl.A. ;Line=936
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=936
	CALL genjplbl
;CALL cmdjpiffalse ;Line=936
	CALL cmdjpiffalse
;accesspar=eat.A. ;Line=937
;PUSHNUM ')' ;Line=937
;POPVAR eat.A. ;Line=937
;PUSHCONST ')' ;Line=937
	LD A,')'
	LD [eat.A.],A
;CALL eat ;Line=937
	CALL eat
;CALL eatcmd ;Line=938
	CALL eatcmd
;//тело while
;accesspar=genjplbl.A. ;Line=939
;PUSHVAR eatwhile.beglbl ;Line=939
	LD HL,[eatwhile.beglbl]
;POPVAR genjplbl.A. ;Line=939
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=939
	CALL genjplbl
;CALL cmdjp ;Line=939
	CALL cmdjp
;accesspar=genjplbl.A. ;Line=940
;PUSHVAR _tmpendlbl ;Line=940
	LD HL,[_tmpendlbl]
;POPVAR genjplbl.A. ;Line=940
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=940
	CALL genjplbl
;CALL cmdlabel ;Line=940
	CALL cmdlabel
;PUSHVAR eatwhile.wasendlbl ;Line=941
	LD HL,[eatwhile.wasendlbl]
;POPVAR _tmpendlbl ;Line=941
	LD [_tmpendlbl],HL
;//IF (*(PCHAR)_tword/**_cnext*/ != ';') {errstr("\';\' expected, but we have \'
;POPPAR ;Line=947
	POP HL
	LD [eatwhile.wasendlbl],HL
;POPPAR ;Line=947
	POP HL
	LD [eatwhile.beglbl],HL
;ENDFUNC ;Line=949
	RET
eatrepeat
;FUNC ;Line=949
;//repeat<cmd>until<expr>
;/**LOCAL ;генерирует уникальный_идентификаторTEMPREPEAT: ;эквивалентно уникальн
;PUSHPAR eatrepeat.beglbl ;Line=961
	LD HL,[eatrepeat.beglbl]
;PUSHPAR eatrepeat.wasendlbl ;Line=962
	PUSH HL
	LD HL,[eatrepeat.wasendlbl]
;PUSHVAR _tmpendlbl ;Line=967
	LD DE,[_tmpendlbl]
;POPVAR eatrepeat.wasendlbl ;Line=967
	LD [eatrepeat.wasendlbl],DE
;PUSHVAR _curlbl ;Line=968
	LD DE,[_curlbl]
;POPVAR eatrepeat.beglbl ;Line=968
	LD [eatrepeat.beglbl],DE
;OPERATION ++ ;Line=968
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
;PUSHVAR _curlbl ;Line=969
	LD DE,[_curlbl]
;POPVAR _tmpendlbl ;Line=969
	LD [_tmpendlbl],DE
;OPERATION ++ ;Line=969
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
;accesspar=genjplbl.A. ;Line=970
;PUSHVAR eatrepeat.beglbl ;Line=970
	LD DE,[eatrepeat.beglbl]
;POPVAR genjplbl.A. ;Line=970
	LD [genjplbl.A.],DE
;CALL genjplbl ;Line=970
	PUSH HL
	CALL genjplbl
;CALL cmdlabel ;Line=970
	CALL cmdlabel
;CALL eatcmd ;Line=971
	CALL eatcmd
;//тело repeat
;PUSHVAR _tword ;Line=972
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=972
;PEEK ;Line=972
	LD A,[HL]
;OPERATION cast 5>0 ;Line=972
;PUSHNUM 0x20 ;Line=972
;OPERATION | ;Line=972
;PUSHCONST 0x20 ;Line=972
	LD E,0x20
	OR E
;OPERATION cast 0>5 ;Line=972
;PUSHNUM 'u' ;Line=972
;/**"until"*/
;OPERATION != ;Line=972
	SUB 'u'
;JUMP IF FALSE eatrepeat.A. ;Line=972
	JP Z,eatrepeat.A.
;accesspar=err_tword.A. ;Line=972
;PUSHNUM eatrepeat.C. ;Line=972
;POPVAR err_tword.A. ;Line=972
;PUSHCONST eatrepeat.C. ;Line=972
	LD HL,eatrepeat.C.
	LD [err_tword.A.],HL
;CALL err_tword ;Line=972
	CALL err_tword
eatrepeat.A.
;CALL rdword ;Line=973
	CALL rdword
;accesspar=eat.A. ;Line=974
;PUSHNUM '(' ;Line=974
;POPVAR eat.A. ;Line=974
;PUSHCONST '(' ;Line=974
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=974
	CALL eat
;PUSHNUM 0x00 ;Line=975
;POPVAR _exprlvl ;Line=975
;PUSHCONST 0x00 ;Line=975
	LD A,0x00
	LD [_exprlvl],A
;//jump optimization possible
;CALL eatexpr ;Line=976
	CALL eatexpr
;//parentheses not included
;accesspar=eat.A. ;Line=977
;PUSHNUM ')' ;Line=977
;POPVAR eat.A. ;Line=977
;PUSHCONST ')' ;Line=977
	LD A,')'
	LD [eat.A.],A
;CALL eat ;Line=977
	CALL eat
;accesspar=genjplbl.A. ;Line=978
;PUSHVAR eatrepeat.beglbl ;Line=978
	LD HL,[eatrepeat.beglbl]
;POPVAR genjplbl.A. ;Line=978
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=978
	CALL genjplbl
;CALL cmdjpiffalse ;Line=978
	CALL cmdjpiffalse
;accesspar=genjplbl.A. ;Line=979
;PUSHVAR _tmpendlbl ;Line=979
	LD HL,[_tmpendlbl]
;POPVAR genjplbl.A. ;Line=979
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=979
	CALL genjplbl
;CALL cmdlabel ;Line=979
	CALL cmdlabel
;PUSHVAR eatrepeat.wasendlbl ;Line=980
	LD HL,[eatrepeat.wasendlbl]
;POPVAR _tmpendlbl ;Line=980
	LD [_tmpendlbl],HL
;POPPAR ;Line=985
	POP HL
	LD [eatrepeat.wasendlbl],HL
;POPPAR ;Line=985
	POP HL
	LD [eatrepeat.beglbl],HL
;ENDFUNC ;Line=987
	RET
eatbreak
;FUNC ;Line=987
;//todo inline
;//break
;accesspar=genjplbl.A. ;Line=990
;PUSHVAR _tmpendlbl ;Line=990
	LD HL,[_tmpendlbl]
;POPVAR genjplbl.A. ;Line=990
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=990
	CALL genjplbl
;CALL cmdjp ;Line=991
	CALL cmdjp
;ENDFUNC ;Line=994
	RET
eatif
;FUNC ;Line=994
;//if <expr> <cmd>[else<cmd>];
;//(; против ошибки "IF (expr);cmd" и ошибки вложенного if)
;/**<условие>LOCAL ;генерирует уникальный_идентификатор jp cc,TEMPELSE;эквивален
;PUSHPAR eatif.elselbl ;Line=1009
	LD HL,[eatif.elselbl]
;PUSHPAR eatif.endiflbl ;Line=1010
	PUSH HL
	LD HL,[eatif.endiflbl]
;PUSHNUM 0x00 ;Line=1015
;POPVAR _exprlvl ;Line=1015
;PUSHCONST 0x00 ;Line=1015
	LD A,0x00
	LD [_exprlvl],A
;//jump optimization possible
;PUSHVAR _curlbl ;Line=1016
	LD DE,[_curlbl]
;POPVAR eatif.elselbl ;Line=1016
	LD [eatif.elselbl],DE
;OPERATION ++ ;Line=1016
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
;PUSHVAR _curlbl ;Line=1017
	LD DE,[_curlbl]
;POPVAR eatif.endiflbl ;Line=1017
	LD [eatif.endiflbl],DE
;OPERATION ++ ;Line=1017
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
;accesspar=eat.A. ;Line=1018
;PUSHNUM '(' ;Line=1018
;POPVAR eat.A. ;Line=1018
;PUSHCONST '(' ;Line=1018
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=1018
	PUSH HL
	CALL eat
;CALL eatexpr ;Line=1019
	CALL eatexpr
;//parentheses not included
;accesspar=genjplbl.A. ;Line=1020
;PUSHVAR eatif.elselbl ;Line=1020
	LD HL,[eatif.elselbl]
;POPVAR genjplbl.A. ;Line=1020
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=1020
	CALL genjplbl
;CALL cmdjpiffalse ;Line=1020
	CALL cmdjpiffalse
;accesspar=eat.A. ;Line=1021
;PUSHNUM ')' ;Line=1021
;POPVAR eat.A. ;Line=1021
;PUSHCONST ')' ;Line=1021
	LD A,')'
	LD [eat.A.],A
;CALL eat ;Line=1021
	CALL eat
;//rdword();
;CALL eatcmd ;Line=1022
	CALL eatcmd
;//тело then
;PUSHVAR _tword ;Line=1023
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1023
;PEEK ;Line=1023
	LD A,[HL]
;/**_cnext*/
;PUSHNUM ';' ;Line=1023
;/**"endif"*/
;OPERATION != ;Line=1023
	SUB ';'
;JUMP IF FALSE eatif.A. ;Line=1023
	JP Z,eatif.A.
;PUSHVAR _tword ;Line=1024
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1024
;PEEK ;Line=1024
	LD A,[HL]
;OPERATION cast 5>0 ;Line=1024
;PUSHNUM 0x20 ;Line=1024
;OPERATION | ;Line=1024
;PUSHCONST 0x20 ;Line=1024
	LD E,0x20
	OR E
;OPERATION cast 0>5 ;Line=1024
;PUSHNUM 'e' ;Line=1024
;/**"else"*/
;OPERATION != ;Line=1024
	SUB 'e'
;JUMP IF FALSE eatif.C. ;Line=1024
	JP Z,eatif.C.
;accesspar=err_tword.A. ;Line=1024
;PUSHNUM eatif.E. ;Line=1024
;POPVAR err_tword.A. ;Line=1024
;PUSHCONST eatif.E. ;Line=1024
	LD HL,eatif.E.
	LD [err_tword.A.],HL
;CALL err_tword ;Line=1024
	CALL err_tword
eatif.C.
;accesspar=genjplbl.A. ;Line=1025
;PUSHVAR eatif.endiflbl ;Line=1025
	LD HL,[eatif.endiflbl]
;POPVAR genjplbl.A. ;Line=1025
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=1025
	CALL genjplbl
;CALL cmdjp ;Line=1025
	CALL cmdjp
;accesspar=genjplbl.A. ;Line=1026
;PUSHVAR eatif.elselbl ;Line=1026
	LD HL,[eatif.elselbl]
;POPVAR genjplbl.A. ;Line=1026
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=1026
	CALL genjplbl
;CALL cmdlabel ;Line=1026
	CALL cmdlabel
;CALL rdword ;Line=1027
	CALL rdword
;CALL eatcmd ;Line=1028
	CALL eatcmd
;//тело else
;accesspar=genjplbl.A. ;Line=1029
;PUSHVAR eatif.endiflbl ;Line=1029
	LD HL,[eatif.endiflbl]
;POPVAR genjplbl.A. ;Line=1029
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=1029
	CALL genjplbl
;CALL cmdlabel ;Line=1029
	CALL cmdlabel
;PUSHVAR _tword ;Line=1030
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1030
;PEEK ;Line=1030
	LD A,[HL]
;/**_cnext*/
;PUSHNUM ';' ;Line=1030
;/**"endif"*/
;OPERATION != ;Line=1030
	SUB ';'
;JUMP IF FALSE eatif.F. ;Line=1030
	JP Z,eatif.F.
;accesspar=errstr.A. ;Line=1030
;PUSHNUM eatif.H. ;Line=1030
;POPVAR errstr.A. ;Line=1030
;PUSHCONST eatif.H. ;Line=1030
	LD HL,eatif.H.
	LD [errstr.A.],HL
;CALL errstr ;Line=1030
	CALL errstr
;accesspar=err.A. ;Line=1030
;PUSHVAR _tword ;Line=1030
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1030
;PEEK ;Line=1030
	LD A,[HL]
;/**_cnext*/
;POPVAR err.A. ;Line=1030
	LD [err.A.],A
;CALL err ;Line=1030
	CALL err
;accesspar=err.A. ;Line=1030
;PUSHNUM '\'' ;Line=1030
;POPVAR err.A. ;Line=1030
;PUSHCONST '\'' ;Line=1030
	LD A,'\''
	LD [err.A.],A
;CALL err ;Line=1030
	CALL err
;CALL enderr ;Line=1030
	CALL enderr
eatif.F.
;//нельзя съедать ';', он нужен для вложенных if
;JUMP eatif.B. ;Line=1032
	JP eatif.B.
eatif.A.
;//ожидаем 'endif' (если IF без ELSE)
;accesspar=genjplbl.A. ;Line=1033
;PUSHVAR eatif.elselbl ;Line=1033
	LD HL,[eatif.elselbl]
;POPVAR genjplbl.A. ;Line=1033
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=1033
	CALL genjplbl
;CALL cmdlabel ;Line=1033
	CALL cmdlabel
eatif.B.
;POPPAR ;Line=1039
	POP HL
	LD [eatif.endiflbl],HL
;POPPAR ;Line=1039
	POP HL
	LD [eatif.elselbl],HL
;/**PROC eatmodule RECURSIVE()//module<lbl><cmd>{  _lentitle = strjoin(_title, _
;ENDFUNC ;Line=1056
	RET
eatreturn
;FUNC ;Line=1056
;//todo inline
;//todo проверить isfunc для вывода ошибки
;PUSHNUM 0x01 ;Line=1062
;POPVAR _exprlvl ;Line=1062
;PUSHCONST 0x01 ;Line=1062
	LD A,0x01
	LD [_exprlvl],A
;//no jump optimization
;CALL eatexpr ;Line=1063
	CALL eatexpr
;//сравнения нельзя без скобок!!!
;PUSHVAR _t ;Line=1064
	LD A,[_t]
;PUSHVAR _curfunct ;Line=1064
	LD L,A
	LD A,[_curfunct]
;PUSHNUM _T_RECURSIVE ;Line=1064
;INV ;Line=1064
;PUSHCONST _T_RECURSIVE ;Line=1064
	LD C,_T_RECURSIVE
	LD E,A
	LD A,C
	CPL
;OPERATION & ;Line=1064
	AND E
;OPERATION != ;Line=1064
	SUB L
;JUMP IF FALSE eatreturn.A. ;Line=1064
	JP Z,eatreturn.A.
;accesspar=errstr.A. ;Line=1064
;PUSHNUM eatreturn.C. ;Line=1064
;POPVAR errstr.A. ;Line=1064
;PUSHCONST eatreturn.C. ;Line=1064
	LD HL,eatreturn.C.
	LD [errstr.A.],HL
;CALL errstr ;Line=1064
	CALL errstr
;accesspar=erruint.A. ;Line=1064
;PUSHVAR _curfunct ;Line=1064
	LD A,[_curfunct]
;OPERATION cast 0>1 ;Line=1064
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=1064
	LD [erruint.A.],HL
;CALL erruint ;Line=1064
	CALL erruint
;accesspar=errstr.A. ;Line=1064
;PUSHNUM eatreturn.D. ;Line=1064
;POPVAR errstr.A. ;Line=1064
;PUSHCONST eatreturn.D. ;Line=1064
	LD HL,eatreturn.D.
	LD [errstr.A.],HL
;CALL errstr ;Line=1064
	CALL errstr
;accesspar=erruint.A. ;Line=1064
;PUSHVAR _t ;Line=1064
	LD A,[_t]
;OPERATION cast 0>1 ;Line=1064
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=1064
	LD [erruint.A.],HL
;CALL erruint ;Line=1064
	CALL erruint
;CALL enderr ;Line=1064
	CALL enderr
eatreturn.A.
;CALL cmdresult ;Line=1065
	CALL cmdresult
;PUSHNUM TRUE ;Line=1069
;POPVAR _wasreturn ;Line=1069
;PUSHCONST TRUE ;Line=1069
	LD A,TRUE
	LD [_wasreturn],A
;//установить проверку "оператор после return"
;ENDFUNC ;Line=1072
	RET
eatinc
;FUNC ;Line=1072
;//начальная часть имени переменной уже прочитана
;CALL adddots ;Line=1078
	CALL adddots
;//дочитать имя
;/**iscall*/
;accesspar=joinvarname.A. ;Line=1079
;PUSHNUM FALSE ;Line=1079
;POPVAR joinvarname.A. ;Line=1079
;PUSHCONST FALSE ;Line=1079
	LD A,FALSE
	LD [joinvarname.A.],A
;CALL joinvarname ;Line=1079
	CALL joinvarname
;POPVAR _t ;Line=1079
	LD [_t],A
;//doprefix(_namespclvl); //prefix:=title[FIRST to...];
;CALL cmdinc ;Line=1080
	CALL cmdinc
;CALL rdword ;Line=1081
	CALL rdword
;ENDFUNC ;Line=1084
	RET
eatdec
;FUNC ;Line=1084
;//начальная часть имени переменной уже прочитана
;CALL adddots ;Line=1090
	CALL adddots
;//дочитать имя
;/**iscall*/
;accesspar=joinvarname.A. ;Line=1091
;PUSHNUM FALSE ;Line=1091
;POPVAR joinvarname.A. ;Line=1091
;PUSHCONST FALSE ;Line=1091
	LD A,FALSE
	LD [joinvarname.A.],A
;CALL joinvarname ;Line=1091
	CALL joinvarname
;POPVAR _t ;Line=1091
	LD [_t],A
;//doprefix(_namespclvl); //prefix:=title[FIRST to...];
;CALL cmddec ;Line=1092
	CALL cmddec
;CALL rdword ;Line=1093
	CALL rdword
;ENDFUNC ;Line=1096
	RET
var_num
;FUNC ;Line=1096
;PUSHVAR var_num.t ;Line=1098
	LD A,[var_num.t]
;PUSHNUM _T_ARRAY ;Line=1098
;INV ;Line=1098
;PUSHCONST _T_ARRAY ;Line=1098
	LD E,_T_ARRAY
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=1098
	AND L
;POPVAR var_num.tmasked ;Line=1098
	LD [var_num.tmasked],A
;/**  IF ( (t&_T_POI)!=0x00 ) { //используется для строк (нельзя equ)    varstr_
;PUSHVAR var_num.t ;Line=1101
	LD A,[var_num.t]
;PUSHNUM _T_CONST ;Line=1101
;OPERATION & ;Line=1101
;PUSHCONST _T_CONST ;Line=1101
	LD E,_T_CONST
	AND E
;PUSHNUM 0x00 ;Line=1101
;OPERATION != ;Line=1101
	SUB 0x00
;JUMP IF FALSE var_num.C. ;Line=1101
	JP Z,var_num.C.
;accesspar=varstr.A. ;Line=1102
;PUSHVAR _title ;Line=1102
	LD HL,[_title]
;/**_joined*/
;POPVAR varstr.A. ;Line=1102
	LD [varstr.A.],HL
;CALL varstr ;Line=1102
	CALL varstr
;accesspar=varc.A. ;Line=1102
;PUSHNUM '=' ;Line=1102
;POPVAR varc.A. ;Line=1102
;PUSHCONST '=' ;Line=1102
	LD A,'='
	LD [varc.A.],A
;CALL varc ;Line=1102
	CALL varc
;accesspar=varstr.A. ;Line=1102
;PUSHVAR var_num.s ;Line=1102
	LD HL,[var_num.s]
;POPVAR varstr.A. ;Line=1102
	LD [varstr.A.],HL
;CALL varstr ;Line=1102
	CALL varstr
;CALL endvar ;Line=1102
	CALL endvar
;JUMP var_num.D. ;Line=1103
	JP var_num.D.
var_num.C.
;PUSHVAR var_num.t ;Line=1104
	LD A,[var_num.t]
;PUSHVAR var_num.tmasked ;Line=1104
	LD L,A
	LD A,[var_num.tmasked]
;/**(t&_T_ARRAY)==0x00*/
;OPERATION == ;Line=1104
	SUB L
;JUMP IF FALSE var_num.E. ;Line=1104
	JP NZ,var_num.E.
;accesspar=varstr.A. ;Line=1105
;PUSHVAR _joined ;Line=1105
	LD HL,[_joined]
;POPVAR varstr.A. ;Line=1105
	LD [varstr.A.],HL
;CALL varstr ;Line=1105
	CALL varstr
;/**varc( ':' );*/
;CALL endvar ;Line=1105
	CALL endvar
var_num.E.
;accesspar=var_def.A. ;Line=1107
;PUSHVAR var_num.tmasked ;Line=1107
	LD A,[var_num.tmasked]
;POPVAR var_def.A. ;Line=1107
	LD [var_def.A.],A
;accesspar=var_def.B. ;Line=1107
;PUSHVAR var_num.s ;Line=1107
	LD HL,[var_num.s]
;POPVAR var_def.B. ;Line=1107
	LD [var_def.B.],HL
;CALL var_def ;Line=1107
	CALL var_def
var_num.D.
;//TODO выражения(отдать асму?) + таблицу констант в компиляторе?
;//надо как минимум &funcname, &structinstancename, (c1+c2 работает через асм)
;ENDFUNC ;Line=1113
	RET
do_const_num
;FUNC ;Line=1113
;PUSHVAR _tword ;Line=1115
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1115
;PEEK ;Line=1115
	LD A,[HL]
;PUSHNUM '-' ;Line=1115
;OPERATION == ;Line=1115
	SUB '-'
	SUB 1
	SBC A,A
;PUSHVAR _tword ;Line=1115
	LD DE,[_tword]
;OPERATION cast 21>21 ;Line=1115
;PEEK ;Line=1115
	LD L,A
	LD A,[DE]
;PUSHNUM '+' ;Line=1115
;OPERATION == ;Line=1115
	SUB '+'
	SUB 1
	SBC A,A
;OPERATION | ;Line=1115
	OR L
;JUMP IF FALSE do_const_num.B. ;Line=1115
	JP Z,do_const_num.B.
;CALL rdaddword ;Line=1116
	CALL rdaddword
;//приклеить число
;accesspar=var_num.A. ;Line=1117
;PUSHVAR do_const_num.t ;Line=1117
	LD A,[do_const_num.t]
;POPVAR var_num.A. ;Line=1117
	LD [var_num.A.],A
;accesspar=var_num.B. ;Line=1117
;PUSHVAR _tword ;Line=1117
	LD HL,[_tword]
;POPVAR var_num.B. ;Line=1117
	LD [var_num.B.],HL
;CALL var_num ;Line=1117
	CALL var_num
;JUMP do_const_num.C. ;Line=1118
	JP do_const_num.C.
do_const_num.B.
;PUSHVAR _tword ;Line=1118
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1118
;PEEK ;Line=1118
	LD A,[HL]
;PUSHNUM '\'' ;Line=1118
;OPERATION == ;Line=1118
	SUB '\''
;JUMP IF FALSE do_const_num.D. ;Line=1118
	JP NZ,do_const_num.D.
;accesspar=rdquotes.A. ;Line=1119
;PUSHNUM '\'' ;Line=1119
;POPVAR rdquotes.A. ;Line=1119
;PUSHCONST '\'' ;Line=1119
	LD A,'\''
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=1119
	CALL rdquotes
;CALL rdch ;Line=1120
	CALL rdch
;//добавляем закрывающую кавычку
;PUSHVAR _tword ;Line=1121
	LD HL,[_tword]
;PUSHVAR _lentword ;Line=1121
	LD DE,[_lentword]
;OPERATION +poi ;Line=1121
	ADD HL,DE
;PUSHNUM '\0' ;Line=1121
;POKE ;Line=1121
;PUSHCONST '\0' ;Line=1121
	LD A,'\0'
	LD [HL],A
;//strclose(_tword, _lentword);
;accesspar=var_num.A. ;Line=1122
;PUSHVAR do_const_num.t ;Line=1122
	LD A,[do_const_num.t]
;POPVAR var_num.A. ;Line=1122
	LD [var_num.A.],A
;accesspar=var_num.B. ;Line=1122
;PUSHVAR _tword ;Line=1122
	LD HL,[_tword]
;POPVAR var_num.B. ;Line=1122
	LD [var_num.B.],HL
;CALL var_num ;Line=1122
	CALL var_num
;JUMP do_const_num.E. ;Line=1123
	JP do_const_num.E.
do_const_num.D.
;PUSHVAR _tword ;Line=1123
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1123
;PEEK ;Line=1123
	LD A,[HL]
;PUSHNUM '&' ;Line=1123
;OPERATION == ;Line=1123
	SUB '&'
;JUMP IF FALSE do_const_num.F. ;Line=1123
	JP NZ,do_const_num.F.
;//&<var>
;CALL rdword ;Line=1124
	CALL rdword
;//использовать &, прочитать начало имени
;CALL adddots ;Line=1125
	CALL adddots
;//дочитать имя
;accesspar=var_num.A. ;Line=1126
;PUSHNUM _T_ARRAY ;Line=1126
;PUSHNUM _T_UINT ;Line=1126
;PUSHCONST _T_ARRAY ;Line=1126
	LD A,_T_ARRAY
;OPERATION | ;Line=1126
;PUSHCONST _T_UINT ;Line=1126
	LD E,_T_UINT
	OR E
;POPVAR var_num.A. ;Line=1126
	LD [var_num.A.],A
;accesspar=var_num.B. ;Line=1126
;PUSHVAR _tword ;Line=1126
	LD HL,[_tword]
;POPVAR var_num.B. ;Line=1126
	LD [var_num.B.],HL
;CALL var_num ;Line=1126
	CALL var_num
;//_T_ARRAY не даёт создать метку
;JUMP do_const_num.G. ;Line=1127
	JP do_const_num.G.
do_const_num.F.
;PUSHVAR _tword ;Line=1127
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1127
;PEEK ;Line=1127
	LD A,[HL]
;PUSHNUM '\"' ;Line=1127
;OPERATION == ;Line=1127
	SUB '\"'
;JUMP IF FALSE do_const_num.H. ;Line=1127
	JP NZ,do_const_num.H.
;PUSHVAR do_const_num.t ;Line=1128
	LD A,[do_const_num.t]
;PUSHNUM _T_ARRAY ;Line=1128
;OPERATION & ;Line=1128
;PUSHCONST _T_ARRAY ;Line=1128
	LD E,_T_ARRAY
	AND E
;PUSHNUM 0x00 ;Line=1128
;OPERATION != ;Line=1128
	SUB 0x00
;JUMP IF FALSE do_const_num.J. ;Line=1128
	JP Z,do_const_num.J.
;//строка внутри массива
;accesspar=strcopy.A. ;Line=1129
;PUSHVAR _title ;Line=1129
	LD HL,[_title]
;POPVAR strcopy.A. ;Line=1129
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1129
;PUSHVAR _lentitle ;Line=1129
	LD HL,[_lentitle]
;POPVAR strcopy.B. ;Line=1129
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1129
;PUSHVAR _joined ;Line=1129
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=1129
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1129
	CALL strcopy
;POPVAR _lenjoined ;Line=1129
	LD [_lenjoined],HL
;CALL jdot ;Line=1130
	CALL jdot
;accesspar=jautonum.A. ;Line=1131
;PUSHVAR _curlbl ;Line=1131
	LD HL,[_curlbl]
;POPVAR jautonum.A. ;Line=1131
	LD [jautonum.A.],HL
;CALL jautonum ;Line=1131
	CALL jautonum
;OPERATION ++ ;Line=1132
	LD HL,[_curlbl]
	INC HL
	LD [_curlbl],HL
;//_joined[_lenjoined] = '\0'; //strclose(_joined, _lenjoined);
;accesspar=var_num.A. ;Line=1134
;PUSHNUM _T_ARRAY ;Line=1134
;PUSHNUM _T_UINT ;Line=1134
;PUSHCONST _T_ARRAY ;Line=1134
	LD A,_T_ARRAY
;OPERATION | ;Line=1134
;PUSHCONST _T_UINT ;Line=1134
	LD E,_T_UINT
	OR E
;POPVAR var_num.A. ;Line=1134
	LD [var_num.A.],A
;accesspar=var_num.B. ;Line=1134
;PUSHVAR _joined ;Line=1134
	LD HL,[_joined]
;POPVAR var_num.B. ;Line=1134
	LD [var_num.B.],HL
;CALL var_num ;Line=1134
	CALL var_num
;//_T_ARRAY не даёт создать метку
do_const_num.J.
;CALL asmstrz ;Line=1136
	CALL asmstrz
;//с меткой title //костыль вместо varstrz
;JUMP do_const_num.I. ;Line=1137
	JP do_const_num.I.
do_const_num.H.
;accesspar=var_num.A. ;Line=1137
;PUSHVAR do_const_num.t ;Line=1137
	LD A,[do_const_num.t]
;POPVAR var_num.A. ;Line=1137
	LD [var_num.A.],A
;accesspar=var_num.B. ;Line=1137
;PUSHVAR _tword ;Line=1137
	LD HL,[_tword]
;POPVAR var_num.B. ;Line=1137
	LD [var_num.B.],HL
;CALL var_num ;Line=1137
	CALL var_num
do_const_num.I.
do_const_num.G.
do_const_num.E.
do_const_num.C.
;ENDFUNC ;Line=1140
	RET
eatextern
;FUNC ;Line=1140
;//extern<type><variable>[<[><expr><]>]
;PUSHNUM 0x01 ;Line=1147
;POPVAR _exprlvl ;Line=1147
;PUSHCONST 0x01 ;Line=1147
	LD A,0x01
	LD [_exprlvl],A
;//no jump optimization
;CALL eatvarname ;Line=1148
	CALL eatvarname
;POPVAR eatextern.t ;Line=1148
	LD [eatextern.t],A
;//без срубания вложенностей по _ (создаёт _name)
;PUSHVAR _tword ;Line=1149
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1149
;PEEK ;Line=1149
	LD A,[HL]
;PUSHNUM '[' ;Line=1149
;OPERATION == ;Line=1149
	SUB '['
;JUMP IF FALSE eatextern.A. ;Line=1149
	JP NZ,eatextern.A.
;//t = t|_T_ARRAY; //уже в eatvarname
;//rdbrackets(); //_tword='[' //TODO evaluate expr (в нём нельзя переменные и вы
;PUSHNUM 0 ;Line=1152
;POPVAR _lentword ;Line=1152
;PUSHCONST 0 ;Line=1152
	LD HL,0
	LD [_lentword],HL
;//strclear(_tword); //читаем с пустой строки
;accesspar=rdquotes.A. ;Line=1153
;PUSHNUM ']' ;Line=1153
;POPVAR rdquotes.A. ;Line=1153
;PUSHCONST ']' ;Line=1153
	LD A,']'
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=1153
	CALL rdquotes
;CALL rdch ;Line=1154
	CALL rdch
;//пропустить ']'
;//_lenncells = strcopy(_tword, _lentword, _ncells); //n = _tword;
;//}ELSE {
;//n ="1";
;//_lenncells = stradd(_ncells, strclear(_ncells), '1'); //n = n + '1';
;//strclose(_ncells, _lenncells);
;CALL rdword ;Line=1160
	CALL rdword
eatextern.A.
;accesspar=addlbl.A. ;Line=1162
;PUSHVAR eatextern.t ;Line=1162
	LD A,[eatextern.t]
;POPVAR addlbl.A. ;Line=1162
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1162
;PUSHNUM FALSE ;Line=1162
;POPVAR addlbl.B. ;Line=1162
;PUSHCONST FALSE ;Line=1162
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1162
;PUSHNUM _typesz ;Line=1162
;PUSHVAR eatextern.t ;Line=1162
;PUSHCONST _typesz ;Line=1162
	LD HL,_typesz
	LD A,[eatextern.t]
;PUSHNUM _TYPEMASK ;Line=1162
;OPERATION & ;Line=1162
;PUSHCONST _TYPEMASK ;Line=1162
	LD C,_TYPEMASK
	AND C
;OPERATION cast 0>1 ;Line=1162
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1162
	ADD HL,DE
;PEEK ;Line=1162
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1162
	LD L,A
	LD H,0
;/**, _ncells, _lenncells*/
;POPVAR addlbl.C. ;Line=1162
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1162
	CALL addlbl
;//(_name) //TODO размер массива (структуры не бывают extern?)!
;ENDFUNC ;Line=1168
	RET
eatvar
;FUNC ;Line=1168
;//если var, то body==+TRUE, иначе body==!forward
;//var<type><variable>[<[><expr><]>][=<expr>]
;//или в параметрах при объявлении функции <type><variable>
;PUSHNUM 0x01 ;Line=1176
;POPVAR _exprlvl ;Line=1176
;PUSHCONST 0x01 ;Line=1176
	LD A,0x01
	LD [_exprlvl],A
;//no jump optimization
;CALL eatvarname ;Line=1177
	CALL eatvarname
;POPVAR eatvar.t ;Line=1177
	LD [eatvar.t],A
;//без срубания вложенностей по _ (создаёт _name)
;PUSHVAR _tword ;Line=1178
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1178
;PEEK ;Line=1178
	LD A,[HL]
;PUSHNUM '[' ;Line=1178
;OPERATION == ;Line=1178
	SUB '['
;JUMP IF FALSE eatvar.C. ;Line=1178
	JP NZ,eatvar.C.
;//t = t|_T_ARRAY; //уже в eatvarname
;//strpush(_joined,_lenjoined);
;//TODO evaluate expr (в нём нельзя переменные и вызовы, т.е. не запарывается jo
;PUSHNUM 0 ;Line=1182
;POPVAR _lentword ;Line=1182
;PUSHCONST 0 ;Line=1182
	LD HL,0
	LD [_lentword],HL
;//strclear(_tword); //читаем с пустой строки
;accesspar=rdquotes.A. ;Line=1183
;PUSHNUM ']' ;Line=1183
;POPVAR rdquotes.A. ;Line=1183
;PUSHCONST ']' ;Line=1183
	LD A,']'
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=1183
	CALL rdquotes
;//_lenjoined = strpop(_joined);
;accesspar=strcopy.A. ;Line=1185
;PUSHVAR _tword ;Line=1185
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=1185
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1185
;PUSHVAR _lentword ;Line=1185
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=1185
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1185
;PUSHVAR _ncells ;Line=1185
	LD HL,[_ncells]
;POPVAR strcopy.C. ;Line=1185
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1185
	CALL strcopy
;POPVAR _lenncells ;Line=1185
	LD [_lenncells],HL
;//n = _tword;
;CALL rdch ;Line=1186
	CALL rdch
;//пропустить ']'
;CALL rdword ;Line=1187
	CALL rdword
;JUMP eatvar.D. ;Line=1188
	JP eatvar.D.
eatvar.C.
;//n ="1";
;accesspar=stradd.A. ;Line=1190
;PUSHVAR _ncells ;Line=1190
	LD HL,[_ncells]
;POPVAR stradd.A. ;Line=1190
	LD [stradd.A.],HL
;accesspar=stradd.B. ;Line=1190
;PUSHNUM 0 ;Line=1190
;/**strclear(_ncells)*/
;POPVAR stradd.B. ;Line=1190
;PUSHCONST 0 ;Line=1190
	LD HL,0
	LD [stradd.B.],HL
;accesspar=stradd.C. ;Line=1190
;PUSHNUM '1' ;Line=1190
;POPVAR stradd.C. ;Line=1190
;PUSHCONST '1' ;Line=1190
	LD A,'1'
	LD [stradd.C.],A
;CALL stradd ;Line=1190
	CALL stradd
;POPVAR _lenncells ;Line=1190
	LD [_lenncells],HL
;//n = n + '1';
;PUSHVAR _ncells ;Line=1191
	LD HL,[_ncells]
;PUSHVAR _lenncells ;Line=1191
	LD DE,[_lenncells]
;OPERATION +poi ;Line=1191
	ADD HL,DE
;PUSHNUM '\0' ;Line=1191
;POKE ;Line=1191
;PUSHCONST '\0' ;Line=1191
	LD A,'\0'
	LD [HL],A
;//strclose(_ncells, _lenncells);
eatvar.D.
;PUSHVAR eatvar.body ;Line=1193
	LD A,[eatvar.body]
;JUMP IF FALSE eatvar.E. ;Line=1193
	OR A
	JP Z,eatvar.E.
;accesspar=addlbl.A. ;Line=1193
;PUSHVAR eatvar.t ;Line=1193
	LD A,[eatvar.t]
;POPVAR addlbl.A. ;Line=1193
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1193
;PUSHVAR _namespclvl ;Line=1193
	LD A,[_namespclvl]
;PUSHNUM 0x00 ;Line=1193
;OPERATION != ;Line=1193
	SUB 0x00
	JR Z,$+4
	LD A,-1
;POPVAR addlbl.B. ;Line=1193
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1193
;PUSHNUM _typesz ;Line=1193
;PUSHVAR eatvar.t ;Line=1193
;PUSHCONST _typesz ;Line=1193
	LD HL,_typesz
	LD A,[eatvar.t]
;PUSHNUM _TYPEMASK ;Line=1193
;OPERATION & ;Line=1193
;PUSHCONST _TYPEMASK ;Line=1193
	LD C,_TYPEMASK
	AND C
;OPERATION cast 0>1 ;Line=1193
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1193
	ADD HL,DE
;PEEK ;Line=1193
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1193
	LD L,A
	LD H,0
;/**, _ncells, _lenncells*/
;POPVAR addlbl.C. ;Line=1193
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1193
	CALL addlbl
eatvar.E.
;//(_name) //TODO размер массива или структуры!
;PUSHVAR eatvar.ispar ;Line=1194
	LD A,[eatvar.ispar]
;JUMP IF FALSE eatvar.G. ;Line=1194
	OR A
	JP Z,eatvar.G.
;//parameter of func/proc
;PUSHVAR eatvar.body ;Line=1195
	LD A,[eatvar.body]
;JUMP IF FALSE eatvar.I. ;Line=1195
	OR A
	JP Z,eatvar.I.
;accesspar=varstr.A. ;Line=1196
;PUSHVAR _joined ;Line=1196
	LD HL,[_joined]
;POPVAR varstr.A. ;Line=1196
	LD [varstr.A.],HL
;CALL varstr ;Line=1196
	CALL varstr
;/**varc( ':' );*/
;CALL endvar ;Line=1196
	CALL endvar
eatvar.I.
;accesspar=strcopy.A. ;Line=1198
;PUSHVAR _prefix ;Line=1198
	LD HL,[_prefix]
;POPVAR strcopy.A. ;Line=1198
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1198
;PUSHVAR _lenprefix ;Line=1198
	LD HL,[_lenprefix]
;POPVAR strcopy.B. ;Line=1198
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1198
;PUSHVAR _joined ;Line=1198
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=1198
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1198
	CALL strcopy
;POPVAR _lenjoined ;Line=1198
	LD [_lenjoined],HL
;//_lenjoined = strjoin(/**to=*/_joined, 0/**strclear(_joined)*/, _prefix/**, _l
;accesspar=jautonum.A. ;Line=1199
;PUSHVAR _parnum ;Line=1199
	LD HL,[_parnum]
;POPVAR jautonum.A. ;Line=1199
	LD [jautonum.A.],HL
;CALL jautonum ;Line=1199
	CALL jautonum
;OPERATION ++ ;Line=1200
	LD HL,[_parnum]
	INC HL
	LD [_parnum],HL
;//!!! todo написать почему
;OPERATION ++ ;Line=1201
	LD HL,[_curlbl]
	INC HL
	LD [_curlbl],HL
;//!!! todo написать почему
;//_joined[_lenjoined] = '\0'; //strclose(_joined, _lenjoined);
;accesspar=strcopy.A. ;Line=1203
;PUSHVAR _joined ;Line=1203
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1203
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1203
;PUSHVAR _lenjoined ;Line=1203
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1203
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1203
;PUSHVAR _name ;Line=1203
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1203
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1203
	CALL strcopy
;POPVAR _lenname ;Line=1203
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1204
;PUSHVAR eatvar.t ;Line=1204
	LD A,[eatvar.t]
;POPVAR addlbl.A. ;Line=1204
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1204
;PUSHNUM FALSE ;Line=1204
;POPVAR addlbl.B. ;Line=1204
;PUSHCONST FALSE ;Line=1204
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1204
;PUSHNUM _typesz ;Line=1204
;PUSHVAR eatvar.t ;Line=1204
;PUSHCONST _typesz ;Line=1204
	LD HL,_typesz
	LD A,[eatvar.t]
;PUSHNUM _TYPEMASK ;Line=1204
;OPERATION & ;Line=1204
;PUSHCONST _TYPEMASK ;Line=1204
	LD C,_TYPEMASK
	AND C
;OPERATION cast 0>1 ;Line=1204
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1204
	ADD HL,DE
;PEEK ;Line=1204
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1204
	LD L,A
	LD H,0
;/**, "0", _lenncells*/
;POPVAR addlbl.C. ;Line=1204
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1204
	CALL addlbl
;//отметили в таблице, что не выделять память //(_name) //TODO размер массива ил
eatvar.G.
;PUSHVAR eatvar.body ;Line=1206
	LD A,[eatvar.body]
;JUMP IF FALSE eatvar.K. ;Line=1206
	OR A
	JP Z,eatvar.K.
;PUSHVAR eatvar.t ;Line=1207
	LD A,[eatvar.t]
;PUSHNUM _T_ARRAY ;Line=1207
;OPERATION & ;Line=1207
;PUSHCONST _T_ARRAY ;Line=1207
	LD E,_T_ARRAY
	AND E
;PUSHNUM 0x00 ;Line=1207
;OPERATION != ;Line=1207
	SUB 0x00
;JUMP IF FALSE eatvar.M. ;Line=1207
	JP Z,eatvar.M.
;accesspar=varstr.A. ;Line=1208
;PUSHVAR _joined ;Line=1208
	LD HL,[_joined]
;POPVAR varstr.A. ;Line=1208
	LD [varstr.A.],HL
;CALL varstr ;Line=1208
	CALL varstr
;/**varc( ':' );*/
;CALL endvar ;Line=1208
	CALL endvar
;accesspar=varstr.A. ;Line=1209
;PUSHNUM eatvar.O. ;Line=1209
;POPVAR varstr.A. ;Line=1209
;PUSHCONST eatvar.O. ;Line=1209
	LD HL,eatvar.O.
	LD [varstr.A.],HL
;CALL varstr ;Line=1209
	CALL varstr
;accesspar=varuint.A. ;Line=1209
;PUSHNUM _typesz ;Line=1209
;PUSHVAR eatvar.t ;Line=1209
;PUSHCONST _typesz ;Line=1209
	LD HL,_typesz
	LD A,[eatvar.t]
;PUSHNUM _TYPEMASK ;Line=1209
;OPERATION & ;Line=1209
;PUSHCONST _TYPEMASK ;Line=1209
	LD C,_TYPEMASK
	AND C
;OPERATION cast 0>1 ;Line=1209
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1209
	ADD HL,DE
;PEEK ;Line=1209
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1209
	LD L,A
	LD H,0
;POPVAR varuint.A. ;Line=1209
	LD [varuint.A.],HL
;CALL varuint ;Line=1209
	CALL varuint
;accesspar=varc.A. ;Line=1209
;PUSHNUM '*' ;Line=1209
;POPVAR varc.A. ;Line=1209
;PUSHCONST '*' ;Line=1209
	LD A,'*'
	LD [varc.A.],A
;CALL varc ;Line=1209
	CALL varc
;accesspar=varstr.A. ;Line=1209
;PUSHVAR _ncells ;Line=1209
	LD HL,[_ncells]
;POPVAR varstr.A. ;Line=1209
	LD [varstr.A.],HL
;CALL varstr ;Line=1209
	CALL varstr
;CALL endvar ;Line=1209
	CALL endvar
;JUMP eatvar.N. ;Line=1210
	JP eatvar.N.
eatvar.M.
;accesspar=var_num.A. ;Line=1211
;PUSHVAR eatvar.t ;Line=1211
	LD A,[eatvar.t]
;POPVAR var_num.A. ;Line=1211
	LD [var_num.A.],A
;accesspar=var_num.B. ;Line=1211
;PUSHNUM eatvar.P. ;Line=1211
;POPVAR var_num.B. ;Line=1211
;PUSHCONST eatvar.P. ;Line=1211
	LD HL,eatvar.P.
	LD [var_num.B.],HL
;CALL var_num ;Line=1211
	CALL var_num
eatvar.N.
;accesspar=doexp.A. ;Line=1213
;PUSHVAR _joined ;Line=1213
	LD HL,[_joined]
;POPVAR doexp.A. ;Line=1213
	LD [doexp.A.],HL
;CALL doexp ;Line=1213
	CALL doexp
eatvar.K.
;PUSHVAR _tword ;Line=1215
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1215
;PEEK ;Line=1215
	LD A,[HL]
;PUSHNUM '=' ;Line=1215
;OPERATION == ;Line=1215
	SUB '='
;JUMP IF FALSE eatvar.Q. ;Line=1215
	JP NZ,eatvar.Q.
;CALL rdword ;Line=1216
	CALL rdword
;//'='
;//TODO проверить, что мы внутри функции (нерекурсивной!)
;accesspar=strpush.A. ;Line=1218
;PUSHVAR _joined ;Line=1218
	LD HL,[_joined]
;POPVAR strpush.A. ;Line=1218
	LD [strpush.A.],HL
;accesspar=strpush.B. ;Line=1218
;PUSHVAR _lenjoined ;Line=1218
	LD HL,[_lenjoined]
;POPVAR strpush.B. ;Line=1218
	LD [strpush.B.],HL
;CALL strpush ;Line=1218
	CALL strpush
;CALL eatexpr ;Line=1219
	CALL eatexpr
;accesspar=strpop.A. ;Line=1220
;PUSHVAR _joined ;Line=1220
	LD HL,[_joined]
;POPVAR strpop.A. ;Line=1220
	LD [strpop.A.],HL
;CALL strpop ;Line=1220
	CALL strpop
;POPVAR _lenjoined ;Line=1220
	LD [_lenjoined],HL
;PUSHVAR eatvar.t ;Line=1221
	LD A,[eatvar.t]
;PUSHVAR _t ;Line=1221
	LD L,A
	LD A,[_t]
;OPERATION != ;Line=1221
	SUB L
	JR Z,$+4
	LD A,-1
;PUSHVAR eatvar.t ;Line=1221
	LD L,A
	LD A,[eatvar.t]
;PUSHNUM _T_POI ;Line=1221
;OPERATION & ;Line=1221
;PUSHCONST _T_POI ;Line=1221
	LD C,_T_POI
	AND C
;PUSHNUM 0x00 ;Line=1221
;OPERATION != ;Line=1221
	SUB 0x00
	JR Z,$+4
	LD A,-1
;/**(texpr==_T_UINT)||*/
;PUSHVAR _t ;Line=1221
	LD E,A
	LD A,[_t]
;PUSHNUM _T_POI ;Line=1221
;OPERATION & ;Line=1221
;PUSHCONST _T_POI ;Line=1221
	LD LX,_T_POI
	AND LX
;PUSHNUM 0x00 ;Line=1221
;OPERATION != ;Line=1221
	SUB 0x00
	JR Z,$+4
	LD A,-1
;OPERATION & ;Line=1221
	AND E
;INV ;Line=1221
	CPL
;OPERATION & ;Line=1221
	AND L
;JUMP IF FALSE eatvar.S. ;Line=1221
	JP Z,eatvar.S.
;accesspar=errstr.A. ;Line=1221
;PUSHNUM eatvar.U. ;Line=1221
;POPVAR errstr.A. ;Line=1221
;PUSHCONST eatvar.U. ;Line=1221
	LD HL,eatvar.U.
	LD [errstr.A.],HL
;CALL errstr ;Line=1221
	CALL errstr
;accesspar=errstr.A. ;Line=1221
;PUSHVAR _joined ;Line=1221
	LD HL,[_joined]
;POPVAR errstr.A. ;Line=1221
	LD [errstr.A.],HL
;CALL errstr ;Line=1221
	CALL errstr
;accesspar=errstr.A. ;Line=1221
;PUSHNUM eatvar.V. ;Line=1221
;POPVAR errstr.A. ;Line=1221
;PUSHCONST eatvar.V. ;Line=1221
	LD HL,eatvar.V.
	LD [errstr.A.],HL
;CALL errstr ;Line=1221
	CALL errstr
;accesspar=erruint.A. ;Line=1221
;PUSHVAR eatvar.t ;Line=1221
	LD A,[eatvar.t]
;OPERATION cast 0>1 ;Line=1221
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=1221
	LD [erruint.A.],HL
;CALL erruint ;Line=1221
	CALL erruint
;accesspar=errstr.A. ;Line=1221
;PUSHNUM eatvar.W. ;Line=1221
;POPVAR errstr.A. ;Line=1221
;PUSHCONST eatvar.W. ;Line=1221
	LD HL,eatvar.W.
	LD [errstr.A.],HL
;CALL errstr ;Line=1221
	CALL errstr
;accesspar=erruint.A. ;Line=1221
;PUSHVAR _t ;Line=1221
	LD A,[_t]
;OPERATION cast 0>1 ;Line=1221
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=1221
	LD [erruint.A.],HL
;CALL erruint ;Line=1221
	CALL erruint
;CALL enderr ;Line=1221
	CALL enderr
eatvar.S.
;//_t = t; //todo проверить
;CALL cmdpopvar ;Line=1223
	CALL cmdpopvar
eatvar.Q.
;PUSHVAR _isrecursive ;Line=1225
	LD A,[_isrecursive]
;PUSHVAR eatvar.ispar ;Line=1225
	LD L,A
	LD A,[eatvar.ispar]
;INV ;Line=1225
	CPL
;OPERATION & ;Line=1225
	AND L
;JUMP IF FALSE eatvar.X. ;Line=1225
	JP Z,eatvar.X.
;//local variable of recursive func/proc
;PUSHVAR eatvar.t ;Line=1226
	LD A,[eatvar.t]
;POPVAR _t ;Line=1226
	LD [_t],A
;CALL cmdpushpar ;Line=1227
	CALL cmdpushpar
;//todo что делать с массивами?
;accesspar=strpush.A. ;Line=1228
;PUSHVAR _joined ;Line=1228
	LD HL,[_joined]
;POPVAR strpush.A. ;Line=1228
	LD [strpush.A.],HL
;accesspar=strpush.B. ;Line=1228
;PUSHVAR _lenjoined ;Line=1228
	LD HL,[_lenjoined]
;POPVAR strpush.B. ;Line=1228
	LD [strpush.B.],HL
;CALL strpush ;Line=1228
	CALL strpush
eatvar.Z.
;PUSHVAR _tword ;Line=1229
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1229
;PEEK ;Line=1229
	LD A,[HL]
;PUSHNUM ';' ;Line=1229
;OPERATION == ;Line=1229
	SUB ';'
;JUMP IF FALSE eatvar.BA. ;Line=1229
	JP NZ,eatvar.BA.
;CALL rdword ;Line=1230
	CALL rdword
;JUMP eatvar.Z. ;Line=1231
	JP eatvar.Z.
eatvar.BA.
;//C compatibility
;CALL eatcmd ;Line=1232
	CALL eatcmd
;//recursive function body must be in {} after vars!
;accesspar=strpop.A. ;Line=1233
;PUSHVAR _joined ;Line=1233
	LD HL,[_joined]
;POPVAR strpop.A. ;Line=1233
	LD [strpop.A.],HL
;CALL strpop ;Line=1233
	CALL strpop
;POPVAR _lenjoined ;Line=1233
	LD [_lenjoined],HL
;PUSHVAR eatvar.t ;Line=1234
	LD A,[eatvar.t]
;POPVAR _t ;Line=1234
	LD [_t],A
;CALL cmdpoppar ;Line=1235
	CALL cmdpoppar
;//todo что делать с массивами?
eatvar.X.
;//TODO выражения(отдать асму?) + таблицу констант?
;ENDFUNC ;Line=1243
	RET
eatconst
;FUNC ;Line=1243
;//<constnum>::=[-]<num>|'<char>'|"<str>"["<str>"...]
;//const<type><variable>[=<constnum>]
;//|const<type><variable><[><expr><]>[<[><expr><]>...][={<constnum>[,<constnum>.
;//|const pchar<variable><[><expr><]><[><expr><]>={"<str>"[,"<str>"...]}
;PUSHNUM 0 ;Line=1250
;POPVAR eatconst.i ;Line=1250
;PUSHCONST 0 ;Line=1250
	LD HL,0
	LD [eatconst.i],HL
;PUSHNUM 0x01 ;Line=1254
;POPVAR _exprlvl ;Line=1254
;PUSHCONST 0x01 ;Line=1254
	LD A,0x01
	LD [_exprlvl],A
;//no jump optimization
;CALL eattype ;Line=1255
	CALL eattype
;PUSHNUM _T_CONST ;Line=1255
;OPERATION | ;Line=1255
;PUSHCONST _T_CONST ;Line=1255
	LD E,_T_CONST
	OR E
;POPVAR eatconst.t ;Line=1255
	LD [eatconst.t],A
;//тип был уже прочитан
;CALL adddots ;Line=1256
	CALL adddots
;accesspar=doprefix.A. ;Line=1257
;PUSHVAR _namespclvl ;Line=1257
	LD A,[_namespclvl]
;POPVAR doprefix.A. ;Line=1257
	LD [doprefix.A.],A
;CALL doprefix ;Line=1257
	CALL doprefix
;//склеить n слов типа 'word.' из title в prefix (name без префикса)
;CALL rdword ;Line=1258
	CALL rdword
;//'['
;PUSHVAR _tword ;Line=1259
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1259
;PEEK ;Line=1259
	LD A,[HL]
;PUSHNUM '[' ;Line=1259
;OPERATION == ;Line=1259
	SUB '['
;JUMP IF FALSE eatconst.A. ;Line=1259
	JP NZ,eatconst.A.
;PUSHVAR eatconst.t ;Line=1260
	LD A,[eatconst.t]
;PUSHNUM _T_ARRAY ;Line=1260
;OPERATION | ;Line=1260
;PUSHCONST _T_ARRAY ;Line=1260
	LD E,_T_ARRAY
	OR E
;POPVAR eatconst.t ;Line=1260
	LD [eatconst.t],A
eatconst.A.
;//_joined содержит имя константы
;//_name содержит тип
;accesspar=strcopy.A. ;Line=1264
;PUSHVAR _joined ;Line=1264
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1264
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1264
;PUSHVAR _lenjoined ;Line=1264
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1264
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1264
;PUSHVAR _title ;Line=1264
	LD HL,[_title]
;POPVAR strcopy.C. ;Line=1264
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1264
	CALL strcopy
;POPVAR _lentitle ;Line=1264
	LD [_lentitle],HL
;//для уникальности имён строковых констант
;OPERATION ++ ;Line=1265
;PUSHNUM _namespclvl ;Line=1265
;PUSHCONST _namespclvl ;Line=1265
	LD HL,_namespclvl
	INC [HL]
;//добавляем слово к title
;//нам нужно получить имя типа
;CALL lbltype ;Line=1268
	CALL lbltype
;accesspar=strcopy.A. ;Line=1269
;PUSHVAR _joined ;Line=1269
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1269
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1269
;PUSHVAR _lenjoined ;Line=1269
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1269
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1269
;PUSHVAR _name ;Line=1269
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1269
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1269
	CALL strcopy
;POPVAR _lenname ;Line=1269
	LD [_lenname],HL
;//имя константы
;CALL gettypename ;Line=1270
	CALL gettypename
;//взять название типа структуры в joined (сразу после lbltype)
;accesspar=strcopy.A. ;Line=1271
;PUSHVAR _joined ;Line=1271
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1271
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1271
;PUSHVAR _lenjoined ;Line=1271
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1271
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1271
;PUSHVAR _callee ;Line=1271
	LD HL,[_callee]
;POPVAR strcopy.C. ;Line=1271
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1271
	CALL strcopy
;POPVAR _lencallee ;Line=1271
	LD [_lencallee],HL
;//n ="1";
;//_lenncells=strclear(_ncells); //n ="";
;//_lenncells=stradd(_ncells, _lenncells, '1'); //n = n + '1';
;//strclose(_ncells, _lenncells);
;//IF (_cnext == '[') { //[size]
;//  t = t|_T_ARRAY;
;//};
;//title содержит имя константы
;accesspar=addlbl.A. ;Line=1282
;PUSHVAR eatconst.t ;Line=1282
	LD A,[eatconst.t]
;POPVAR addlbl.A. ;Line=1282
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1282
;PUSHNUM FALSE ;Line=1282
;POPVAR addlbl.B. ;Line=1282
;PUSHCONST FALSE ;Line=1282
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1282
;PUSHNUM _typesz ;Line=1282
;PUSHVAR eatconst.t ;Line=1282
;PUSHCONST _typesz ;Line=1282
	LD HL,_typesz
	LD A,[eatconst.t]
;PUSHNUM _TYPEMASK ;Line=1282
;OPERATION & ;Line=1282
;PUSHCONST _TYPEMASK ;Line=1282
	LD C,_TYPEMASK
	AND C
;OPERATION cast 0>1 ;Line=1282
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1282
	ADD HL,DE
;PEEK ;Line=1282
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1282
	LD L,A
	LD H,0
;/**, _ncells, _lenncells*/
;POPVAR addlbl.C. ;Line=1282
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1282
	CALL addlbl
;//(_name) //TODO размер массива или структуры!
eatconst.C.
;PUSHVAR _tword ;Line=1283
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1283
;PEEK ;Line=1283
	LD A,[HL]
;PUSHNUM '[' ;Line=1283
;OPERATION == ;Line=1283
	SUB '['
;JUMP IF FALSE eatconst.D. ;Line=1283
	JP NZ,eatconst.D.
;//[size]
;//rdbrackets(); //_tword='['
;PUSHNUM 0 ;Line=1285
;POPVAR _lentword ;Line=1285
;PUSHCONST 0 ;Line=1285
	LD HL,0
	LD [_lentword],HL
;//strclear(_tword); //читаем с пустой строки
;accesspar=rdquotes.A. ;Line=1286
;PUSHNUM ']' ;Line=1286
;POPVAR rdquotes.A. ;Line=1286
;PUSHCONST ']' ;Line=1286
	LD A,']'
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=1286
	CALL rdquotes
;CALL rdch ;Line=1287
	CALL rdch
;//пропустить ']'
;CALL rdword ;Line=1288
	CALL rdword
;JUMP eatconst.C. ;Line=1289
	JP eatconst.C.
eatconst.D.
;PUSHVAR _tword ;Line=1290
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1290
;PEEK ;Line=1290
	LD A,[HL]
;PUSHNUM '=' ;Line=1290
;OPERATION == ;Line=1290
	SUB '='
;JUMP IF FALSE eatconst.E. ;Line=1290
	JP NZ,eatconst.E.
;CALL rdword ;Line=1291
	CALL rdword
;//num or '{'
;PUSHVAR _tword ;Line=1292
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1292
;PEEK ;Line=1292
	LD A,[HL]
;PUSHNUM '{' ;Line=1292
;OPERATION == ;Line=1292
	SUB '{'
;JUMP IF FALSE eatconst.G. ;Line=1292
	JP NZ,eatconst.G.
;//array or struct
;accesspar=varstr.A. ;Line=1293
;PUSHVAR _title ;Line=1293
	LD HL,[_title]
;/**_joined*/
;POPVAR varstr.A. ;Line=1293
	LD [varstr.A.],HL
;CALL varstr ;Line=1293
	CALL varstr
;/**varc( ':' );*/
;CALL endvar ;Line=1293
	CALL endvar
;accesspar=doexp.A. ;Line=1294
;PUSHVAR _title ;Line=1294
	LD HL,[_title]
;POPVAR doexp.A. ;Line=1294
	LD [doexp.A.],HL
;CALL doexp ;Line=1294
	CALL doexp
;//надо ли экспортировать константы? только константные массивы/структуры
eatconst.I.
;CALL rdword ;Line=1296
	CALL rdword
;//num
;PUSHVAR eatconst.t ;Line=1298
	LD A,[eatconst.t]
;PUSHNUM _T_STRUCT ;Line=1298
;PUSHNUM _T_CONST ;Line=1298
;PUSHCONST _T_STRUCT ;Line=1298
	LD E,_T_STRUCT
;OPERATION | ;Line=1298
;PUSHCONST _T_CONST ;Line=1298
	LD C,_T_CONST
	LD L,A
	LD A,E
	OR C
;OPERATION == ;Line=1298
	SUB L
;JUMP IF FALSE eatconst.K. ;Line=1298
	JP NZ,eatconst.K.
;//структура (у неё нет атомарного типа)
;accesspar=strcopy.A. ;Line=1299
;PUSHVAR _callee ;Line=1299
	LD HL,[_callee]
;POPVAR strcopy.A. ;Line=1299
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1299
;PUSHVAR _lencallee ;Line=1299
	LD HL,[_lencallee]
;POPVAR strcopy.B. ;Line=1299
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1299
;PUSHVAR _joined ;Line=1299
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=1299
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1299
	CALL strcopy
;POPVAR _lenjoined ;Line=1299
	LD [_lenjoined],HL
;//callee содержит имя типа константы
;accesspar=stradd.A. ;Line=1300
;PUSHVAR _joined ;Line=1300
	LD HL,[_joined]
;POPVAR stradd.A. ;Line=1300
	LD [stradd.A.],HL
;accesspar=stradd.B. ;Line=1300
;PUSHVAR _lenjoined ;Line=1300
	LD HL,[_lenjoined]
;POPVAR stradd.B. ;Line=1300
	LD [stradd.B.],HL
;accesspar=stradd.C. ;Line=1300
;PUSHNUM '.' ;Line=1300
;POPVAR stradd.C. ;Line=1300
;PUSHCONST '.' ;Line=1300
	LD A,'.'
	LD [stradd.C.],A
;CALL stradd ;Line=1300
	CALL stradd
;POPVAR _lenjoined ;Line=1300
	LD [_lenjoined],HL
;accesspar=jautonum.A. ;Line=1301
;PUSHVAR eatconst.i ;Line=1301
	LD HL,[eatconst.i]
;POPVAR jautonum.A. ;Line=1301
	LD [jautonum.A.],HL
;CALL jautonum ;Line=1301
	CALL jautonum
;accesspar=strcopy.A. ;Line=1302
;PUSHVAR _joined ;Line=1302
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1302
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1302
;PUSHVAR _lenjoined ;Line=1302
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1302
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1302
;PUSHVAR _name ;Line=1302
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1302
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1302
	CALL strcopy
;POPVAR _lenname ;Line=1302
	LD [_lenname],HL
;CALL lbltype ;Line=1303
	CALL lbltype
;POPVAR _t ;Line=1303
	LD [_t],A
;accesspar=do_const_num.A. ;Line=1304
;CALL lbltype ;Line=1304
	CALL lbltype
;PUSHNUM _T_TYPE ;Line=1304
;INV ;Line=1304
;PUSHCONST _T_TYPE ;Line=1304
	LD E,_T_TYPE
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=1304
	AND L
;PUSHNUM _T_ARRAY ;Line=1304
;OPERATION | ;Line=1304
;PUSHCONST _T_ARRAY ;Line=1304
	LD E,_T_ARRAY
	OR E
;POPVAR do_const_num.A. ;Line=1304
	LD [do_const_num.A.],A
;CALL do_const_num ;Line=1304
	CALL do_const_num
;//_T_ARRAY не даёт создать метку
;OPERATION ++ ;Line=1305
	LD HL,[eatconst.i]
	INC HL
	LD [eatconst.i],HL
;JUMP eatconst.L. ;Line=1306
	JP eatconst.L.
eatconst.K.
;//не структура
;accesspar=do_const_num.A. ;Line=1307
;PUSHVAR eatconst.t ;Line=1307
	LD A,[eatconst.t]
;PUSHNUM _T_CONST ;Line=1307
;INV ;Line=1307
;PUSHCONST _T_CONST ;Line=1307
	LD E,_T_CONST
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=1307
	AND L
;POPVAR do_const_num.A. ;Line=1307
	LD [do_const_num.A.],A
;CALL do_const_num ;Line=1307
	CALL do_const_num
;//_T_ARRAY не даёт создать метку
eatconst.L.
;CALL rdword ;Line=1310
	CALL rdword
;//',' or '}'
;PUSHVAR _tword ;Line=1311
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1311
;PEEK ;Line=1311
	LD A,[HL]
;PUSHNUM '}' ;Line=1311
;OPERATION == ;Line=1311
	SUB '}'
;JUMP IF FALSE eatconst.I. ;Line=1311
	JP NZ,eatconst.I.
eatconst.J.
;JUMP eatconst.H. ;Line=1312
	JP eatconst.H.
eatconst.G.
;//not array
;accesspar=do_const_num.A. ;Line=1313
;PUSHVAR eatconst.t ;Line=1313
	LD A,[eatconst.t]
;POPVAR do_const_num.A. ;Line=1313
	LD [do_const_num.A.],A
;CALL do_const_num ;Line=1313
	CALL do_const_num
eatconst.H.
;CALL rdword ;Line=1315
	CALL rdword
eatconst.E.
;OPERATION -- ;Line=1318
;PUSHNUM _namespclvl ;Line=1318
;PUSHCONST _namespclvl ;Line=1318
	LD HL,_namespclvl
	DEC [HL]
;accesspar=doprefix.A. ;Line=1318
;PUSHVAR _namespclvl ;Line=1318
	LD A,[_namespclvl]
;POPVAR doprefix.A. ;Line=1318
	LD [doprefix.A.],A
;CALL doprefix ;Line=1318
	CALL doprefix
;accesspar=strcopy.A. ;Line=1318
;PUSHVAR _prefix ;Line=1318
	LD HL,[_prefix]
;POPVAR strcopy.A. ;Line=1318
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1318
;PUSHVAR _lenprefix ;Line=1318
	LD HL,[_lenprefix]
;POPVAR strcopy.B. ;Line=1318
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1318
;PUSHVAR _title ;Line=1318
	LD HL,[_title]
;POPVAR strcopy.C. ;Line=1318
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1318
	CALL strcopy
;POPVAR _lentitle ;Line=1318
	LD [_lentitle],HL
;/**title =prefix;*/
;//отрезаем добавленное слово
;//_isexp = +FALSE; //надо ли экспортировать константы? только константные масси
;ENDFUNC ;Line=1327
	RET
eatfunc
;FUNC ;Line=1327
;//proc<procname>[recursive][forward](<type><par>,...])[<cmd>]
;//|func<type><funcname>[recursive][forward]([<type><par>,...])[<cmd>]
;PUSHNUM 0 ;Line=1332
;POPVAR _curlbl ;Line=1332
;PUSHCONST 0 ;Line=1332
	LD HL,0
	LD [_curlbl],HL
;//сбрасываем нумерацию автометок, т.к. у них префикс функции
;PUSHVAR eatfunc.isfunc ;Line=1333
	LD A,[eatfunc.isfunc]
;JUMP IF FALSE eatfunc.D. ;Line=1333
	OR A
	JP Z,eatfunc.D.
;CALL eattype ;Line=1334
	CALL eattype
;POPVAR _curfunct ;Line=1334
	LD [_curfunct],A
;JUMP eatfunc.E. ;Line=1335
	JP eatfunc.E.
eatfunc.D.
;PUSHNUM _T_PROC ;Line=1335
;POPVAR _curfunct ;Line=1335
;PUSHCONST _T_PROC ;Line=1335
	LD A,_T_PROC
	LD [_curfunct],A
eatfunc.E.
;accesspar=strcopy.A. ;Line=1339
;PUSHVAR _tword ;Line=1339
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=1339
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1339
;PUSHVAR _lentword ;Line=1339
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=1339
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1339
;PUSHVAR _name ;Line=1339
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1339
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1339
	CALL strcopy
;POPVAR _lenname ;Line=1339
	LD [_lenname],HL
;CALL jtitletword ;Line=1340
	CALL jtitletword
;CALL rdword ;Line=1341
	CALL rdword
;//'(' or "recursive" or "forward"
;PUSHVAR _tword ;Line=1342
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1342
;PEEK ;Line=1342
	LD A,[HL]
;OPERATION cast 5>0 ;Line=1342
;PUSHNUM 0x20 ;Line=1342
;OPERATION | ;Line=1342
;PUSHCONST 0x20 ;Line=1342
	LD E,0x20
	OR E
;OPERATION cast 0>5 ;Line=1342
;PUSHNUM 'r' ;Line=1342
;OPERATION == ;Line=1342
	SUB 'r'
;JUMP IF FALSE eatfunc.F. ;Line=1342
	JP NZ,eatfunc.F.
;PUSHVAR _curfunct ;Line=1343
	LD A,[_curfunct]
;PUSHNUM _T_RECURSIVE ;Line=1343
;OPERATION | ;Line=1343
;PUSHCONST _T_RECURSIVE ;Line=1343
	LD E,_T_RECURSIVE
	OR E
;POPVAR _curfunct ;Line=1343
	LD [_curfunct],A
;PUSHNUM TRUE ;Line=1344
;POPVAR _isrecursive ;Line=1344
;PUSHCONST TRUE ;Line=1344
	LD A,TRUE
	LD [_isrecursive],A
;CALL rdword ;Line=1345
	CALL rdword
;//'('
;JUMP eatfunc.G. ;Line=1346
	JP eatfunc.G.
eatfunc.F.
;PUSHNUM FALSE ;Line=1346
;POPVAR _isrecursive ;Line=1346
;PUSHCONST FALSE ;Line=1346
	LD A,FALSE
	LD [_isrecursive],A
eatfunc.G.
;PUSHVAR _tword ;Line=1347
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1347
;PEEK ;Line=1347
	LD A,[HL]
;OPERATION cast 5>0 ;Line=1347
;PUSHNUM 0x20 ;Line=1347
;OPERATION | ;Line=1347
;PUSHCONST 0x20 ;Line=1347
	LD E,0x20
	OR E
;OPERATION cast 0>5 ;Line=1347
;PUSHNUM 'f' ;Line=1347
;OPERATION == ;Line=1347
	SUB 'f'
;JUMP IF FALSE eatfunc.H. ;Line=1347
	JP NZ,eatfunc.H.
;PUSHNUM TRUE ;Line=1348
;POPVAR eatfunc.isforward ;Line=1348
;PUSHCONST TRUE ;Line=1348
	LD A,TRUE
	LD [eatfunc.isforward],A
;CALL rdword ;Line=1349
	CALL rdword
;//'('
;JUMP eatfunc.I. ;Line=1350
	JP eatfunc.I.
eatfunc.H.
;PUSHNUM FALSE ;Line=1350
;POPVAR eatfunc.isforward ;Line=1350
;PUSHCONST FALSE ;Line=1350
	LD A,FALSE
	LD [eatfunc.isforward],A
eatfunc.I.
;accesspar=addlbl.A. ;Line=1351
;PUSHVAR _curfunct ;Line=1351
	LD A,[_curfunct]
;POPVAR addlbl.A. ;Line=1351
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1351
;PUSHNUM FALSE ;Line=1351
;POPVAR addlbl.B. ;Line=1351
;PUSHCONST FALSE ;Line=1351
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1351
;PUSHNUM 0 ;Line=1351
;/**, _ncells"0", 1*/
;POPVAR addlbl.C. ;Line=1351
;PUSHCONST 0 ;Line=1351
	LD HL,0
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1351
	CALL addlbl
;//(_name) //todo выяснить, почему нельзя if (!isforward)
;PUSHVAR eatfunc.isforward ;Line=1352
	LD A,[eatfunc.isforward]
;INV ;Line=1352
	CPL
;JUMP IF FALSE eatfunc.J. ;Line=1352
	OR A
	JP Z,eatfunc.J.
;CALL cmdlabel ;Line=1353
	CALL cmdlabel
;//(_joined)
;CALL cmdfunc ;Line=1354
	CALL cmdfunc
;//делает initrgs
;accesspar=doexp.A. ;Line=1355
;PUSHVAR _joined ;Line=1355
	LD HL,[_joined]
;POPVAR doexp.A. ;Line=1355
	LD [doexp.A.],HL
;CALL doexp ;Line=1355
	CALL doexp
eatfunc.J.
;CALL jdot ;Line=1357
	CALL jdot
;accesspar=strcopy.A. ;Line=1358
;PUSHVAR _joined ;Line=1358
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1358
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1358
;PUSHVAR _lenjoined ;Line=1358
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1358
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1358
;PUSHVAR _title ;Line=1358
	LD HL,[_title]
;POPVAR strcopy.C. ;Line=1358
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1358
	CALL strcopy
;POPVAR _lentitle ;Line=1358
	LD [_lentitle],HL
;OPERATION ++ ;Line=1359
;PUSHNUM _namespclvl ;Line=1359
;PUSHCONST _namespclvl ;Line=1359
	LD HL,_namespclvl
	INC [HL]
;//добавляем слово к title
;accesspar=eat.A. ;Line=1360
;PUSHNUM '(' ;Line=1360
;POPVAR eat.A. ;Line=1360
;PUSHCONST '(' ;Line=1360
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=1360
	CALL eat
;PUSHNUM 0 ;Line=1361
;POPVAR _parnum ;Line=1361
;PUSHCONST 0 ;Line=1361
	LD HL,0
	LD [_parnum],HL
eatfunc.L.
;PUSHVAR _waseof ;Line=1362
	LD A,[_waseof]
;INV ;Line=1362
	CPL
;JUMP IF FALSE eatfunc.M. ;Line=1362
	OR A
	JP Z,eatfunc.M.
;PUSHVAR _tword ;Line=1363
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1363
;PEEK ;Line=1363
	LD A,[HL]
;PUSHNUM ')' ;Line=1363
;OPERATION == ;Line=1363
	SUB ')'
;JUMP IF FALSE eatfunc.N. ;Line=1363
	JP NZ,eatfunc.N.
;JUMP eatfunc.M. ;Line=1363
	JP eatfunc.M.
eatfunc.N.
;/**ispar*/
;accesspar=eatvar.A. ;Line=1364
;PUSHNUM TRUE ;Line=1364
;POPVAR eatvar.A. ;Line=1364
;PUSHCONST TRUE ;Line=1364
	LD A,TRUE
	LD [eatvar.A.],A
;/**body*/
;accesspar=eatvar.B. ;Line=1364
;PUSHVAR eatfunc.isforward ;Line=1364
	LD A,[eatfunc.isforward]
;INV ;Line=1364
	CPL
;POPVAR eatvar.B. ;Line=1364
	LD [eatvar.B.],A
;CALL eatvar ;Line=1364
	CALL eatvar
;PUSHVAR _tword ;Line=1365
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1365
;PEEK ;Line=1365
	LD A,[HL]
;PUSHNUM ')' ;Line=1365
;OPERATION == ;Line=1365
	SUB ')'
;JUMP IF FALSE eatfunc.P. ;Line=1365
	JP NZ,eatfunc.P.
;JUMP eatfunc.M. ;Line=1365
	JP eatfunc.M.
eatfunc.P.
;//иначе ','
;CALL rdword ;Line=1366
	CALL rdword
;//type or ')'
;JUMP eatfunc.L. ;Line=1367
	JP eatfunc.L.
eatfunc.M.
;CALL rdword ;Line=1368
	CALL rdword
;CALL keepvars ;Line=1370
	CALL keepvars
;PUSHVAR eatfunc.isforward ;Line=1372
	LD A,[eatfunc.isforward]
;INV ;Line=1372
	CPL
;JUMP IF FALSE eatfunc.R. ;Line=1372
	OR A
	JP Z,eatfunc.R.
;CALL eatcmd ;Line=1373
	CALL eatcmd
;//тело функции
;PUSHVAR _curfunct ;Line=1374
	LD A,[_curfunct]
;PUSHNUM _T_RECURSIVE ;Line=1374
;INV ;Line=1374
;PUSHCONST _T_RECURSIVE ;Line=1374
	LD E,_T_RECURSIVE
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=1374
	AND L
;POPVAR _t ;Line=1374
	LD [_t],A
;accesspar=cmdendfunc.A. ;Line=1375
;PUSHVAR eatfunc.isfunc ;Line=1375
	LD A,[eatfunc.isfunc]
;POPVAR cmdendfunc.A. ;Line=1375
	LD [cmdendfunc.A.],A
;CALL cmdendfunc ;Line=1375
	CALL cmdendfunc
;PUSHVAR eatfunc.isfunc ;Line=1376
	LD A,[eatfunc.isfunc]
;PUSHVAR _wasreturn ;Line=1376
	LD L,A
	LD A,[_wasreturn]
;INV ;Line=1376
	CPL
;OPERATION & ;Line=1376
	AND L
;JUMP IF FALSE eatfunc.T. ;Line=1376
	JP Z,eatfunc.T.
;accesspar=errstr.A. ;Line=1376
;PUSHNUM eatfunc.V. ;Line=1376
;POPVAR errstr.A. ;Line=1376
;PUSHCONST eatfunc.V. ;Line=1376
	LD HL,eatfunc.V.
	LD [errstr.A.],HL
;CALL errstr ;Line=1376
	CALL errstr
;CALL enderr ;Line=1376
	CALL enderr
eatfunc.T.
eatfunc.R.
;CALL undovars ;Line=1382
	CALL undovars
;OPERATION -- ;Line=1384
;PUSHNUM _namespclvl ;Line=1384
;PUSHCONST _namespclvl ;Line=1384
	LD HL,_namespclvl
	DEC [HL]
;accesspar=doprefix.A. ;Line=1384
;PUSHVAR _namespclvl ;Line=1384
	LD A,[_namespclvl]
;POPVAR doprefix.A. ;Line=1384
	LD [doprefix.A.],A
;CALL doprefix ;Line=1384
	CALL doprefix
;accesspar=strcopy.A. ;Line=1384
;PUSHVAR _prefix ;Line=1384
	LD HL,[_prefix]
;POPVAR strcopy.A. ;Line=1384
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1384
;PUSHVAR _lenprefix ;Line=1384
	LD HL,[_lenprefix]
;POPVAR strcopy.B. ;Line=1384
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1384
;PUSHVAR _title ;Line=1384
	LD HL,[_title]
;POPVAR strcopy.C. ;Line=1384
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1384
	CALL strcopy
;POPVAR _lentitle ;Line=1384
	LD [_lentitle],HL
;/**title =prefix;*/
;//отрезаем добавленное слово
;PUSHVAR eatfunc.oldfunct ;Line=1385
	LD A,[eatfunc.oldfunct]
;POPVAR _curfunct ;Line=1385
	LD [_curfunct],A
;//возвратить внешний тип функции
;PUSHVAR eatfunc.oldwasreturn ;Line=1386
	LD A,[eatfunc.oldwasreturn]
;POPVAR _wasreturn ;Line=1386
	LD [_wasreturn],A
;//сбросить проверку "оператор после return"
;PUSHNUM FALSE ;Line=1387
;POPVAR _isexp ;Line=1387
;PUSHCONST FALSE ;Line=1387
	LD A,FALSE
	LD [_isexp],A
;ENDFUNC ;Line=1390
	RET
do_callpar
;FUNC ;Line=1390
;PUSHPAR do_callpar.t ;Line=1392
	LD A,[do_callpar.t]
;PUSHVAR _tword ;Line=1397
	LD DE,[_tword]
;OPERATION cast 21>21 ;Line=1397
;PEEK ;Line=1397
	LD L,A
	LD A,[DE]
;PUSHNUM ')' ;Line=1397
;OPERATION != ;Line=1397
	SUB ')'
	JR Z,$+4
	LD A,-1
;PUSHVAR _waseof ;Line=1397
	LD E,A
	LD A,[_waseof]
;INV ;Line=1397
	CPL
;OPERATION & ;Line=1397
	AND E
;JUMP IF FALSE do_callpar.C. ;Line=1397
	PUSH HL
	JP Z,do_callpar.C.
;accesspar=strcopy.A. ;Line=1398
;PUSHVAR _callee ;Line=1398
	LD HL,[_callee]
;POPVAR strcopy.A. ;Line=1398
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1398
;PUSHVAR _lencallee ;Line=1398
	LD HL,[_lencallee]
;POPVAR strcopy.B. ;Line=1398
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1398
;PUSHVAR _joined ;Line=1398
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=1398
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1398
	CALL strcopy
;POPVAR _lenjoined ;Line=1398
	LD [_lenjoined],HL
;CALL jdot ;Line=1399
	CALL jdot
;accesspar=jautonum.A. ;Line=1400
;PUSHVAR do_callpar.parnum ;Line=1400
	LD HL,[do_callpar.parnum]
;POPVAR jautonum.A. ;Line=1400
	LD [jautonum.A.],HL
;CALL jautonum ;Line=1400
	CALL jautonum
;//INC _curlbl; //не нужно, т.к. это вызов (т.е. другой префикс)
;//_joined[_lenjoined] = '\0'; //strclose(_joined, _lenjoined);
;;;    cmtstr("//accesspar="); cmtstr(_joined); endcmt();
;accesspar=strcopy.A. ;Line=1404
;PUSHVAR _joined ;Line=1404
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1404
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1404
;PUSHVAR _lenjoined ;Line=1404
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1404
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1404
;PUSHVAR _name ;Line=1404
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1404
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1404
	CALL strcopy
;POPVAR _lenname ;Line=1404
	LD [_lenname],HL
;CALL lbltype ;Line=1405
	CALL lbltype
;POPVAR do_callpar.t ;Line=1405
	LD [do_callpar.t],A
;//(_name)
;PUSHVAR do_callpar.funct ;Line=1406
	LD A,[do_callpar.funct]
;PUSHNUM _T_RECURSIVE ;Line=1406
;OPERATION & ;Line=1406
;PUSHCONST _T_RECURSIVE ;Line=1406
	LD E,_T_RECURSIVE
	AND E
;PUSHNUM 0x00 ;Line=1406
;/**isstacked*/
;OPERATION != ;Line=1406
	SUB 0x00
;JUMP IF FALSE do_callpar.E. ;Line=1406
	JP Z,do_callpar.E.
;PUSHVAR do_callpar.t ;Line=1407
	LD A,[do_callpar.t]
;POPVAR _t ;Line=1407
	LD [_t],A
;CALL cmdpushpar ;Line=1408
	CALL cmdpushpar
;//(_joined)
do_callpar.E.
;accesspar=strpush.A. ;Line=1410
;PUSHVAR _joined ;Line=1410
	LD HL,[_joined]
;POPVAR strpush.A. ;Line=1410
	LD [strpush.A.],HL
;accesspar=strpush.B. ;Line=1410
;PUSHVAR _lenjoined ;Line=1410
	LD HL,[_lenjoined]
;POPVAR strpush.B. ;Line=1410
	LD [strpush.B.],HL
;CALL strpush ;Line=1410
	CALL strpush
;OPERATION ++ ;Line=1411
;PUSHNUM _exprlvl ;Line=1411
;PUSHCONST _exprlvl ;Line=1411
	LD HL,_exprlvl
	INC [HL]
;//no jump optimization
;CALL eatexpr ;Line=1412
	CALL eatexpr
;//может рекурсивно вызвать do_call и затереть callee (если он глобальный)! //ср
;OPERATION -- ;Line=1413
;PUSHNUM _exprlvl ;Line=1413
;PUSHCONST _exprlvl ;Line=1413
	LD HL,_exprlvl
	DEC [HL]
;PUSHVAR do_callpar.t ;Line=1414
	LD A,[do_callpar.t]
;PUSHVAR _t ;Line=1414
	LD L,A
	LD A,[_t]
;OPERATION != ;Line=1414
	SUB L
;JUMP IF FALSE do_callpar.G. ;Line=1414
	JP Z,do_callpar.G.
;accesspar=errstr.A. ;Line=1414
;PUSHNUM do_callpar.I. ;Line=1414
;POPVAR errstr.A. ;Line=1414
;PUSHCONST do_callpar.I. ;Line=1414
	LD HL,do_callpar.I.
	LD [errstr.A.],HL
;CALL errstr ;Line=1414
	CALL errstr
;accesspar=erruint.A. ;Line=1414
;PUSHVAR do_callpar.t ;Line=1414
	LD A,[do_callpar.t]
;OPERATION cast 0>1 ;Line=1414
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=1414
	LD [erruint.A.],HL
;CALL erruint ;Line=1414
	CALL erruint
;accesspar=errstr.A. ;Line=1414
;PUSHNUM do_callpar.J. ;Line=1414
;POPVAR errstr.A. ;Line=1414
;PUSHCONST do_callpar.J. ;Line=1414
	LD HL,do_callpar.J.
	LD [errstr.A.],HL
;CALL errstr ;Line=1414
	CALL errstr
;accesspar=erruint.A. ;Line=1414
;PUSHVAR _t ;Line=1414
	LD A,[_t]
;OPERATION cast 0>1 ;Line=1414
	LD L,A
	LD H,0
;POPVAR erruint.A. ;Line=1414
	LD [erruint.A.],HL
;CALL erruint ;Line=1414
	CALL erruint
;CALL enderr ;Line=1414
	CALL enderr
do_callpar.G.
;accesspar=strpop.A. ;Line=1415
;PUSHVAR _joined ;Line=1415
	LD HL,[_joined]
;POPVAR strpop.A. ;Line=1415
	LD [strpop.A.],HL
;CALL strpop ;Line=1415
	CALL strpop
;POPVAR _lenjoined ;Line=1415
	LD [_lenjoined],HL
;CALL cmdpopvar ;Line=1416
	CALL cmdpopvar
;//(_joined)
;PUSHVAR _tword ;Line=1417
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1417
;PEEK ;Line=1417
	LD A,[HL]
;PUSHNUM ',' ;Line=1417
;OPERATION == ;Line=1417
	SUB ','
;JUMP IF FALSE do_callpar.K. ;Line=1417
	JP NZ,do_callpar.K.
;CALL rdword ;Line=1417
	CALL rdword
do_callpar.K.
;//parameter or ')'
;PUSHVAR do_callpar.parnum ;Line=1418
	LD HL,[do_callpar.parnum]
;PUSHNUM _MAXPARS ;Line=1418
;OPERATION < ;Line=1418
;PUSHCONST _MAXPARS ;Line=1418
	LD DE,_MAXPARS
	LD A,L
	SUB E
	LD A,H
	SBC A,D
;JUMP IF FALSE do_callpar.M. ;Line=1418
	JP NC,do_callpar.M.
;accesspar=strpush.A. ;Line=1419
;PUSHVAR _joined ;Line=1419
	LD HL,[_joined]
;POPVAR strpush.A. ;Line=1419
	LD [strpush.A.],HL
;accesspar=strpush.B. ;Line=1419
;PUSHVAR _lenjoined ;Line=1419
	LD HL,[_lenjoined]
;POPVAR strpush.B. ;Line=1419
	LD [strpush.B.],HL
;CALL strpush ;Line=1419
	CALL strpush
;/**isfunc,*/
;accesspar=do_callpar.A. ;Line=1420
;PUSHPAR do_callpar.A. ;Line=1420
	LD A,[do_callpar.A.]
;PUSHVAR do_callpar.funct ;Line=1420
	LD L,A
	LD A,[do_callpar.funct]
;POPVAR do_callpar.A. ;Line=1420
	LD [do_callpar.A.],A
;/**isstacked,*/
;accesspar=do_callpar.B. ;Line=1420
;PUSHPAR do_callpar.B. ;Line=1420
	PUSH HL
	LD HL,[do_callpar.B.]
;PUSHVAR do_callpar.parnum ;Line=1420
	LD DE,[do_callpar.parnum]
;PUSHNUM 1 ;Line=1420
;OPERATION + ;Line=1420
;PUSHCONST 1 ;Line=1420
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
;POPVAR do_callpar.B. ;Line=1420
	LD [do_callpar.B.],DE
;CALL do_callpar ;Line=1420
	PUSH HL
	CALL do_callpar
;POPPAR ;Line=1420
	POP HL
	LD [do_callpar.B.],HL
;POPPAR ;Line=1420
	POP HL
	LD A,L
	LD [do_callpar.A.],A
;//рекурсивно
;accesspar=strpop.A. ;Line=1421
;PUSHVAR _joined ;Line=1421
	LD HL,[_joined]
;POPVAR strpop.A. ;Line=1421
	LD [strpop.A.],HL
;CALL strpop ;Line=1421
	CALL strpop
;POPVAR _lenjoined ;Line=1421
	LD [_lenjoined],HL
;/**ELSE {errstr("too many parameters"); enderr(); }*/
do_callpar.M.
;PUSHVAR do_callpar.funct ;Line=1423
	LD A,[do_callpar.funct]
;PUSHNUM _T_RECURSIVE ;Line=1423
;OPERATION & ;Line=1423
;PUSHCONST _T_RECURSIVE ;Line=1423
	LD E,_T_RECURSIVE
	AND E
;PUSHNUM 0x00 ;Line=1423
;/**isstacked*/
;OPERATION != ;Line=1423
	SUB 0x00
;JUMP IF FALSE do_callpar.O. ;Line=1423
	JP Z,do_callpar.O.
;PUSHVAR do_callpar.t ;Line=1424
	LD A,[do_callpar.t]
;POPVAR _t ;Line=1424
	LD [_t],A
;CALL cmdpoppar ;Line=1425
	CALL cmdpoppar
;//(_joined)
do_callpar.O.
;JUMP do_callpar.D. ;Line=1427
	JP do_callpar.D.
do_callpar.C.
;PUSHVAR do_callpar.funct ;Line=1428
	LD A,[do_callpar.funct]
;PUSHNUM _T_RECURSIVE ;Line=1428
;INV ;Line=1428
;PUSHCONST _T_RECURSIVE ;Line=1428
	LD E,_T_RECURSIVE
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=1428
	AND L
;POPVAR _t ;Line=1428
	LD [_t],A
;CALL cmdcall ;Line=1429
	CALL cmdcall
do_callpar.D.
;POPPAR ;Line=1435
	POP HL
	LD A,L
	LD [do_callpar.t],A
;ENDFUNC ;Line=1437
	RET
do_call
;FUNC ;Line=1437
;//<lbl>([recursive][(<type>)<val>,...])
;PUSHPAR do_call.t ;Line=1440
	LD A,[do_call.t]
;OPERATION ++ ;Line=1442
	LD L,A
	PUSH HL
;PUSHNUM _exprlvl ;Line=1442
;PUSHCONST _exprlvl ;Line=1442
	LD HL,_exprlvl
	INC [HL]
;//no jump optimization
;/**iscall*/
;accesspar=joinvarname.A. ;Line=1443
;PUSHNUM TRUE ;Line=1443
;POPVAR joinvarname.A. ;Line=1443
;PUSHCONST TRUE ;Line=1443
	LD A,TRUE
	LD [joinvarname.A.],A
;CALL joinvarname ;Line=1443
	CALL joinvarname
;POPVAR do_call.t ;Line=1443
	LD [do_call.t],A
;PUSHVAR do_call.t ;Line=1444
	LD A,[do_call.t]
;PUSHNUM _T_UNKNOWN ;Line=1444
;OPERATION == ;Line=1444
	SUB _T_UNKNOWN
;JUMP IF FALSE do_call.B. ;Line=1444
	JP NZ,do_call.B.
;accesspar=errstr.A. ;Line=1444
;PUSHNUM do_call.D. ;Line=1444
;POPVAR errstr.A. ;Line=1444
;PUSHCONST do_call.D. ;Line=1444
	LD HL,do_call.D.
	LD [errstr.A.],HL
;CALL errstr ;Line=1444
	CALL errstr
;accesspar=errstr.A. ;Line=1444
;PUSHVAR _joined ;Line=1444
	LD HL,[_joined]
;POPVAR errstr.A. ;Line=1444
	LD [errstr.A.],HL
;CALL errstr ;Line=1444
	CALL errstr
;CALL enderr ;Line=1444
	CALL enderr
do_call.B.
;PUSHVAR do_call.isfunc ;Line=1448
	LD A,[do_call.isfunc]
;INV ;Line=1448
	CPL
;JUMP IF FALSE do_call.E. ;Line=1448
	OR A
	JP Z,do_call.E.
;PUSHVAR do_call.t ;Line=1448
	LD A,[do_call.t]
;PUSHNUM _T_RECURSIVE ;Line=1448
;OPERATION & ;Line=1448
;PUSHCONST _T_RECURSIVE ;Line=1448
	LD E,_T_RECURSIVE
	AND E
;PUSHNUM _T_PROC ;Line=1448
;OPERATION | ;Line=1448
;PUSHCONST _T_PROC ;Line=1448
	LD E,_T_PROC
	OR E
;POPVAR do_call.t ;Line=1448
	LD [do_call.t],A
do_call.E.
;//чтобы можно было вызывать функции как процедуры
;accesspar=strpush.A. ;Line=1449
;PUSHVAR _callee ;Line=1449
	LD HL,[_callee]
;POPVAR strpush.A. ;Line=1449
	LD [strpush.A.],HL
;accesspar=strpush.B. ;Line=1449
;PUSHVAR _lencallee ;Line=1449
	LD HL,[_lencallee]
;POPVAR strpush.B. ;Line=1449
	LD [strpush.B.],HL
;CALL strpush ;Line=1449
	CALL strpush
;//на случай вложенных вызовов
;accesspar=strcopy.A. ;Line=1450
;PUSHVAR _joined ;Line=1450
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1450
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1450
;PUSHVAR _lenjoined ;Line=1450
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1450
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1450
;PUSHVAR _callee ;Line=1450
	LD HL,[_callee]
;POPVAR strcopy.C. ;Line=1450
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1450
	CALL strcopy
;POPVAR _lencallee ;Line=1450
	LD [_lencallee],HL
;//без точки
;CALL jdot ;Line=1451
	CALL jdot
;CALL rdword ;Line=1452
	CALL rdword
;//'('
;accesspar=eat.A. ;Line=1453
;PUSHNUM '(' ;Line=1453
;POPVAR eat.A. ;Line=1453
;PUSHCONST '(' ;Line=1453
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=1453
	CALL eat
;accesspar=do_callpar.A. ;Line=1454
;PUSHPAR do_callpar.A. ;Line=1454
	LD A,[do_callpar.A.]
;PUSHVAR do_call.t ;Line=1454
	LD L,A
	LD A,[do_call.t]
;POPVAR do_callpar.A. ;Line=1454
	LD [do_callpar.A.],A
;/**parnum*/
;accesspar=do_callpar.B. ;Line=1454
;PUSHPAR do_callpar.B. ;Line=1454
	PUSH HL
	LD HL,[do_callpar.B.]
;PUSHNUM 0 ;Line=1454
;POPVAR do_callpar.B. ;Line=1454
;PUSHCONST 0 ;Line=1454
	LD DE,0
	LD [do_callpar.B.],DE
;CALL do_callpar ;Line=1454
	PUSH HL
	CALL do_callpar
;POPPAR ;Line=1454
	POP HL
	LD [do_callpar.B.],HL
;POPPAR ;Line=1454
	POP HL
	LD A,L
	LD [do_callpar.A.],A
;//сохранение [call]title, [сохранение переменной], присваивание, рекурсия, [вос
;accesspar=strpop.A. ;Line=1455
;PUSHVAR _callee ;Line=1455
	LD HL,[_callee]
;POPVAR strpop.A. ;Line=1455
	LD [strpop.A.],HL
;CALL strpop ;Line=1455
	CALL strpop
;POPVAR _lencallee ;Line=1455
	LD [_lencallee],HL
;//на случай вложенных вызовов
;OPERATION -- ;Line=1456
;PUSHNUM _exprlvl ;Line=1456
;PUSHCONST _exprlvl ;Line=1456
	LD HL,_exprlvl
	DEC [HL]
;//no jump optimization
;PUSHVAR do_call.t ;Line=1457
	LD A,[do_call.t]
;PUSHNUM _T_RECURSIVE ;Line=1457
;INV ;Line=1457
;PUSHCONST _T_RECURSIVE ;Line=1457
	LD E,_T_RECURSIVE
	LD L,A
	LD A,E
	CPL
;OPERATION & ;Line=1457
	AND L
;RESULT ;Line=1457
;POPPAR ;Line=1459
	POP DE
	LD L,A
	LD A,E
	LD [do_call.t],A
;ENDFUNC ;Line=1461
	LD A,L
	RET
eatcallpoi
;FUNC ;Line=1461
;//call(<poi>)
;//начальная часть имени переменной уже прочитана
;CALL adddots ;Line=1465
	CALL adddots
;//дочитать имя
;/**iscall*/
;accesspar=joinvarname.A. ;Line=1466
;PUSHNUM FALSE ;Line=1466
;POPVAR joinvarname.A. ;Line=1466
;PUSHCONST FALSE ;Line=1466
	LD A,FALSE
	LD [joinvarname.A.],A
;CALL joinvarname ;Line=1466
	CALL joinvarname
;POPVAR _t ;Line=1466
	LD [_t],A
;//doprefix(_namespclvl); //prefix:=title[FIRST to...];
;accesspar=eat.A. ;Line=1467
;PUSHNUM '(' ;Line=1467
;POPVAR eat.A. ;Line=1467
;PUSHCONST '(' ;Line=1467
	LD A,'('
	LD [eat.A.],A
;CALL eat ;Line=1467
	CALL eat
;CALL eatexpr ;Line=1468
	CALL eatexpr
;//todo проверить pointer
;accesspar=eat.A. ;Line=1470
;PUSHNUM ')' ;Line=1470
;POPVAR eat.A. ;Line=1470
;PUSHCONST ')' ;Line=1470
	LD A,')'
	LD [eat.A.],A
;CALL eat ;Line=1470
	CALL eat
;CALL cmdcallval ;Line=1471
	CALL cmdcallval
;CALL rdword ;Line=1472
	CALL rdword
;ENDFUNC ;Line=1475
	RET
eatlbl
;FUNC ;Line=1475
;//todo inline
;//_lbl<lblname><:>
;CALL jtitletword ;Line=1478
	CALL jtitletword
;CALL cmdlabel ;Line=1479
	CALL cmdlabel
;CALL rdword ;Line=1480
	CALL rdword
;//skip ':' for C compatibility
;CALL rdword ;Line=1481
	CALL rdword
;//нужно!
;ENDFUNC ;Line=1484
	RET
eatgoto
;FUNC ;Line=1484
;//переход только внутри текущей процедуры //todo inline
;//goto<lblname>
;//rdword(); //lbl
;CALL jtitletword ;Line=1488
	CALL jtitletword
;CALL cmdjp ;Line=1489
	CALL cmdjp
;CALL rdword ;Line=1490
	CALL rdword
;ENDFUNC ;Line=1493
	RET
eatasm
;FUNC ;Line=1493
;//asm("asmtext")
;//rdword(); //'('
;CALL rdword ;Line=1497
	CALL rdword
;//'\"'
eatasm.A.
;PUSHVAR _waseof ;Line=1498
	LD A,[_waseof]
;INV ;Line=1498
	CPL
;JUMP IF FALSE eatasm.B. ;Line=1498
	OR A
	JP Z,eatasm.B.
;PUSHNUM 0 ;Line=1499
;/**strclear(_tword)*/
;POPVAR _lentword ;Line=1499
;PUSHCONST 0 ;Line=1499
	LD HL,0
	LD [_lentword],HL
;//читаем с пустой строки
;accesspar=rdquotes.A. ;Line=1500
;PUSHNUM '\"' ;Line=1500
;/**, +FALSE*/
;POPVAR rdquotes.A. ;Line=1500
;PUSHCONST '\"' ;Line=1500
	LD A,'\"'
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=1500
	CALL rdquotes
;accesspar=asmstr.A. ;Line=1501
;PUSHVAR _tword ;Line=1501
	LD HL,[_tword]
;POPVAR asmstr.A. ;Line=1501
	LD [asmstr.A.],HL
;CALL asmstr ;Line=1501
	CALL asmstr
;CALL endasm ;Line=1501
	CALL endasm
;CALL rdch ;Line=1502
	CALL rdch
;//пропустить закрывающую кавычку
;PUSHVAR _cnext ;Line=1503
	LD A,[_cnext]
;PUSHNUM '\"' ;Line=1503
;OPERATION != ;Line=1503
	SUB '\"'
;JUMP IF FALSE eatasm.C. ;Line=1503
	JP Z,eatasm.C.
;JUMP eatasm.B. ;Line=1503
	JP eatasm.B.
eatasm.C.
;CALL rdword ;Line=1504
	CALL rdword
;//'\"' открывающая кавычка приклеенной строки
;JUMP eatasm.A. ;Line=1505
	JP eatasm.A.
eatasm.B.
;CALL rdword ;Line=1506
	CALL rdword
;//')'
;CALL rdword ;Line=1507
	CALL rdword
;ENDFUNC ;Line=1510
	RET
eatenum
;FUNC ;Line=1510
;//enum{<constname0>,<constname1>...}
;PUSHNUM 0 ;Line=1513
;POPVAR eatenum.i ;Line=1513
;PUSHCONST 0 ;Line=1513
	LD HL,0
	LD [eatenum.i],HL
;//rdword(); //'{'
eatenum.A.
;PUSHVAR _waseof ;Line=1515
	LD A,[_waseof]
;INV ;Line=1515
	CPL
;JUMP IF FALSE eatenum.B. ;Line=1515
	OR A
	JP Z,eatenum.B.
;CALL rdword ;Line=1516
	CALL rdword
;//метка
;accesspar=varstr.A. ;Line=1517
;PUSHVAR _tword ;Line=1517
	LD HL,[_tword]
;POPVAR varstr.A. ;Line=1517
	LD [varstr.A.],HL
;CALL varstr ;Line=1517
	CALL varstr
;/**varc('.');*/
;accesspar=varc.A. ;Line=1517
;PUSHNUM '=' ;Line=1517
;POPVAR varc.A. ;Line=1517
;PUSHCONST '=' ;Line=1517
	LD A,'='
	LD [varc.A.],A
;CALL varc ;Line=1517
	CALL varc
;accesspar=varuint.A. ;Line=1517
;PUSHVAR eatenum.i ;Line=1517
	LD HL,[eatenum.i]
;POPVAR varuint.A. ;Line=1517
	LD [varuint.A.],HL
;CALL varuint ;Line=1517
	CALL varuint
;CALL endvar ;Line=1517
	CALL endvar
;CALL rdword ;Line=1518
	CALL rdword
;//',' или '}'
;PUSHVAR _tword ;Line=1519
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1519
;PEEK ;Line=1519
	LD A,[HL]
;PUSHNUM ',' ;Line=1519
;OPERATION != ;Line=1519
	SUB ','
;JUMP IF FALSE eatenum.C. ;Line=1519
	JP Z,eatenum.C.
;JUMP eatenum.B. ;Line=1519
	JP eatenum.B.
eatenum.C.
;OPERATION ++ ;Line=1520
	LD HL,[eatenum.i]
	INC HL
	LD [eatenum.i],HL
;JUMP eatenum.A. ;Line=1521
	JP eatenum.A.
eatenum.B.
;CALL rdword ;Line=1522
	CALL rdword
;ENDFUNC ;Line=1525
	RET
eatstruct
;FUNC ;Line=1525
;//struct<name>{<type1><field1>[;]<type2><field2>[;]...}
;PUSHNUM 0 ;Line=1528
;POPVAR eatstruct.shift ;Line=1528
;PUSHCONST 0 ;Line=1528
	LD HL,0
	LD [eatstruct.shift],HL
;PUSHNUM 0 ;Line=1530
;POPVAR eatstruct.i ;Line=1530
;PUSHCONST 0 ;Line=1530
	LD HL,0
	LD [eatstruct.i],HL
;/**to=*/
;accesspar=strjoin.A. ;Line=1531
;PUSHVAR _title ;Line=1531
	LD HL,[_title]
;POPVAR strjoin.A. ;Line=1531
	LD [strjoin.A.],HL
;accesspar=strjoin.B. ;Line=1531
;PUSHVAR _lentitle ;Line=1531
	LD HL,[_lentitle]
;POPVAR strjoin.B. ;Line=1531
	LD [strjoin.B.],HL
;accesspar=strjoin.C. ;Line=1531
;PUSHVAR _tword ;Line=1531
	LD HL,[_tword]
;/**, _lentword*/
;POPVAR strjoin.C. ;Line=1531
	LD [strjoin.C.],HL
;CALL strjoin ;Line=1531
	CALL strjoin
;POPVAR _lentitle ;Line=1531
	LD [_lentitle],HL
;PUSHVAR _title ;Line=1532
	LD HL,[_title]
;PUSHVAR _lentitle ;Line=1532
	LD DE,[_lentitle]
;OPERATION +poi ;Line=1532
	ADD HL,DE
;PUSHNUM '\0' ;Line=1532
;POKE ;Line=1532
;PUSHCONST '\0' ;Line=1532
	LD A,'\0'
	LD [HL],A
;//strclose(_title, _lentitle);
;//strpush(_title,_lentitle); //без точки
;accesspar=strcopy.A. ;Line=1534
;PUSHVAR _title ;Line=1534
	LD HL,[_title]
;POPVAR strcopy.A. ;Line=1534
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1534
;PUSHVAR _lentitle ;Line=1534
	LD HL,[_lentitle]
;POPVAR strcopy.B. ;Line=1534
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1534
;PUSHVAR _name ;Line=1534
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1534
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1534
	CALL strcopy
;POPVAR _lenname ;Line=1534
	LD [_lenname],HL
;//без точки
;accesspar=addlbl.A. ;Line=1535
;PUSHNUM _T_STRUCT ;Line=1535
;PUSHNUM _T_TYPE ;Line=1535
;PUSHCONST _T_STRUCT ;Line=1535
	LD A,_T_STRUCT
;OPERATION | ;Line=1535
;PUSHCONST _T_TYPE ;Line=1535
	LD E,_T_TYPE
	OR E
;POPVAR addlbl.A. ;Line=1535
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1535
;PUSHNUM FALSE ;Line=1535
;POPVAR addlbl.B. ;Line=1535
;PUSHCONST FALSE ;Line=1535
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1535
;PUSHNUM 0 ;Line=1535
;/**, "0", _lenncells*/
;POPVAR addlbl.C. ;Line=1535
;PUSHCONST 0 ;Line=1535
	LD HL,0
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1535
	CALL addlbl
;//(_name) //предварительно создали, чтобы ссылаться
;PUSHVAR _varszaddr ;Line=1536
	LD HL,[_varszaddr]
;POPVAR eatstruct.varszaddr ;Line=1536
	LD [eatstruct.varszaddr],HL
;accesspar=stradd.A. ;Line=1538
;PUSHVAR _title ;Line=1538
	LD HL,[_title]
;POPVAR stradd.A. ;Line=1538
	LD [stradd.A.],HL
;accesspar=stradd.B. ;Line=1538
;PUSHVAR _lentitle ;Line=1538
	LD HL,[_lentitle]
;POPVAR stradd.B. ;Line=1538
	LD [stradd.B.],HL
;accesspar=stradd.C. ;Line=1538
;PUSHNUM '.' ;Line=1538
;POPVAR stradd.C. ;Line=1538
;PUSHCONST '.' ;Line=1538
	LD A,'.'
	LD [stradd.C.],A
;CALL stradd ;Line=1538
	CALL stradd
;POPVAR _lentitle ;Line=1538
	LD [_lentitle],HL
;PUSHVAR _title ;Line=1539
	LD HL,[_title]
;PUSHVAR _lentitle ;Line=1539
	LD DE,[_lentitle]
;OPERATION +poi ;Line=1539
	ADD HL,DE
;PUSHNUM '\0' ;Line=1539
;POKE ;Line=1539
;PUSHCONST '\0' ;Line=1539
	LD A,'\0'
	LD [HL],A
;//strclose(_title, _lentitle);
;OPERATION ++ ;Line=1540
;PUSHNUM _namespclvl ;Line=1540
;PUSHCONST _namespclvl ;Line=1540
	LD HL,_namespclvl
	INC [HL]
;//добавляем слово к title
;CALL rdword ;Line=1541
	CALL rdword
;//использовали имя
;accesspar=eat.A. ;Line=1542
;PUSHNUM '{' ;Line=1542
;POPVAR eat.A. ;Line=1542
;PUSHCONST '{' ;Line=1542
	LD A,'{'
	LD [eat.A.],A
;CALL eat ;Line=1542
	CALL eat
eatstruct.A.
;PUSHVAR _waseof ;Line=1544
	LD A,[_waseof]
;INV ;Line=1544
	CPL
;JUMP IF FALSE eatstruct.B. ;Line=1544
	OR A
	JP Z,eatstruct.B.
;//rdword(); //тип
;CALL eattype ;Line=1546
	CALL eattype
;POPVAR _t ;Line=1546
	LD [_t],A
;//использовали тип
;//rdword(); //метка
;CALL jtitletword ;Line=1549
	CALL jtitletword
;//asmstr(_joined); asmc('='); asmuint(shift); endasm();
;accesspar=varstr.A. ;Line=1551
;PUSHVAR _joined ;Line=1551
	LD HL,[_joined]
;POPVAR varstr.A. ;Line=1551
	LD [varstr.A.],HL
;CALL varstr ;Line=1551
	CALL varstr
;accesspar=varc.A. ;Line=1551
;PUSHNUM '=' ;Line=1551
;POPVAR varc.A. ;Line=1551
;PUSHCONST '=' ;Line=1551
	LD A,'='
	LD [varc.A.],A
;CALL varc ;Line=1551
	CALL varc
;accesspar=varuint.A. ;Line=1551
;PUSHVAR eatstruct.shift ;Line=1551
	LD HL,[eatstruct.shift]
;POPVAR varuint.A. ;Line=1551
	LD [varuint.A.],HL
;CALL varuint ;Line=1551
	CALL varuint
;CALL endvar ;Line=1551
	CALL endvar
;accesspar=strcopy.A. ;Line=1552
;PUSHVAR _joined ;Line=1552
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1552
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1552
;PUSHVAR _lenjoined ;Line=1552
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1552
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1552
;PUSHVAR _name ;Line=1552
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1552
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1552
	CALL strcopy
;POPVAR _lenname ;Line=1552
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1553
;PUSHVAR _t ;Line=1553
	LD A,[_t]
;POPVAR addlbl.A. ;Line=1553
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1553
;PUSHNUM FALSE ;Line=1553
;POPVAR addlbl.B. ;Line=1553
;PUSHCONST FALSE ;Line=1553
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1553
;PUSHNUM _typesz ;Line=1553
;PUSHVAR _t ;Line=1553
;PUSHCONST _typesz ;Line=1553
	LD HL,_typesz
	LD A,[_t]
;PUSHNUM _TYPEMASK ;Line=1553
;OPERATION & ;Line=1553
;PUSHCONST _TYPEMASK ;Line=1553
	LD C,_TYPEMASK
	AND C
;OPERATION cast 0>1 ;Line=1553
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1553
	ADD HL,DE
;PEEK ;Line=1553
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1553
	LD L,A
	LD H,0
;/**, "0", _lenncells*/
;POPVAR addlbl.C. ;Line=1553
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1553
	CALL addlbl
;//(_name)
;accesspar=genjplbl.A. ;Line=1555
;PUSHVAR eatstruct.i ;Line=1555
	LD HL,[eatstruct.i]
;POPVAR genjplbl.A. ;Line=1555
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=1555
	CALL genjplbl
;accesspar=strcopy.A. ;Line=1556
;PUSHVAR _joined ;Line=1556
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1556
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1556
;PUSHVAR _lenjoined ;Line=1556
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1556
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1556
;PUSHVAR _name ;Line=1556
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1556
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1556
	CALL strcopy
;POPVAR _lenname ;Line=1556
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1557
;PUSHVAR _t ;Line=1557
	LD A,[_t]
;POPVAR addlbl.A. ;Line=1557
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1557
;PUSHNUM FALSE ;Line=1557
;POPVAR addlbl.B. ;Line=1557
;PUSHCONST FALSE ;Line=1557
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1557
;PUSHNUM _typesz ;Line=1557
;PUSHVAR _t ;Line=1557
;PUSHCONST _typesz ;Line=1557
	LD HL,_typesz
	LD A,[_t]
;PUSHNUM _TYPEMASK ;Line=1557
;OPERATION & ;Line=1557
;PUSHCONST _TYPEMASK ;Line=1557
	LD C,_TYPEMASK
	AND C
;OPERATION cast 0>1 ;Line=1557
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1557
	ADD HL,DE
;PEEK ;Line=1557
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1557
	LD L,A
	LD H,0
;/**, "0", _lenncells*/
;POPVAR addlbl.C. ;Line=1557
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1557
	CALL addlbl
;//автонумерованная (_name)
;OPERATION ++ ;Line=1558
	LD HL,[eatstruct.i]
	INC HL
	LD [eatstruct.i],HL
;PUSHVAR eatstruct.shift ;Line=1560
	LD HL,[eatstruct.shift]
;PUSHNUM _typesz ;Line=1560
;PUSHVAR _t ;Line=1560
;PUSHCONST _typesz ;Line=1560
	LD DE,_typesz
	LD A,[_t]
;PUSHNUM _TYPEMASK ;Line=1560
;OPERATION & ;Line=1560
;PUSHCONST _TYPEMASK ;Line=1560
	LD LX,_TYPEMASK
	AND LX
;OPERATION cast 0>1 ;Line=1560
	LD C,A
	LD B,0
;OPERATION +poi ;Line=1560
	EX DE,HL
	ADD HL,BC
	EX DE,HL
;PEEK ;Line=1560
	LD A,[DE]
;OPERATION cast 0>1 ;Line=1560
	LD E,A
	LD D,0
;OPERATION + ;Line=1560
	ADD HL,DE
;POPVAR eatstruct.shift ;Line=1560
	LD [eatstruct.shift],HL
;CALL rdword ;Line=1562
	CALL rdword
;//тип или ';' или '}' //использовали метку
;PUSHVAR _tword ;Line=1563
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1563
;PEEK ;Line=1563
	LD A,[HL]
;PUSHNUM ';' ;Line=1563
;OPERATION == ;Line=1563
	SUB ';'
;JUMP IF FALSE eatstruct.C. ;Line=1563
	JP NZ,eatstruct.C.
;CALL rdword ;Line=1563
	CALL rdword
eatstruct.C.
;//тип
;PUSHVAR _tword ;Line=1564
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1564
;PEEK ;Line=1564
	LD A,[HL]
;PUSHNUM '}' ;Line=1564
;OPERATION == ;Line=1564
	SUB '}'
;JUMP IF FALSE eatstruct.E. ;Line=1564
	JP NZ,eatstruct.E.
;JUMP eatstruct.B. ;Line=1564
	JP eatstruct.B.
eatstruct.E.
;JUMP eatstruct.A. ;Line=1565
	JP eatstruct.A.
eatstruct.B.
;//_lenname = strpop(_name);
;//addlbl(_T_STRUCT|_T_TYPE, /**islocal*/+FALSE/**, "0", _lenncells*/); //отмети
;//там же сохранить sizeof_structname (=shift)
;//при этом всё ещё разрешить ссылаться на эту же структуру (т.е. определить её 
;accesspar=setvarsz.A. ;Line=1571
;PUSHVAR eatstruct.varszaddr ;Line=1571
	LD HL,[eatstruct.varszaddr]
;POPVAR setvarsz.A. ;Line=1571
	LD [setvarsz.A.],HL
;accesspar=setvarsz.B. ;Line=1571
;PUSHVAR eatstruct.shift ;Line=1571
	LD HL,[eatstruct.shift]
;POPVAR setvarsz.B. ;Line=1571
	LD [setvarsz.B.],HL
;CALL setvarsz ;Line=1571
	CALL setvarsz
;OPERATION -- ;Line=1573
;PUSHNUM _namespclvl ;Line=1573
;PUSHCONST _namespclvl ;Line=1573
	LD HL,_namespclvl
	DEC [HL]
;accesspar=doprefix.A. ;Line=1574
;PUSHVAR _namespclvl ;Line=1574
	LD A,[_namespclvl]
;POPVAR doprefix.A. ;Line=1574
	LD [doprefix.A.],A
;CALL doprefix ;Line=1574
	CALL doprefix
;//to prefix
;accesspar=strcopy.A. ;Line=1575
;PUSHVAR _prefix ;Line=1575
	LD HL,[_prefix]
;POPVAR strcopy.A. ;Line=1575
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1575
;PUSHVAR _lenprefix ;Line=1575
	LD HL,[_lenprefix]
;POPVAR strcopy.B. ;Line=1575
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1575
;PUSHVAR _title ;Line=1575
	LD HL,[_title]
;POPVAR strcopy.C. ;Line=1575
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1575
	CALL strcopy
;POPVAR _lentitle ;Line=1575
	LD [_lentitle],HL
;//title = prefix //отрезаем добавленное слово
;CALL rdword ;Line=1576
	CALL rdword
;ENDFUNC ;Line=1579
	RET
eatswitch
;FUNC ;Line=1579
;//процедура теоретически рекурсивная, но практически вложенность switch запреще
;//'J' в нумерованных метках можно убрать, т.к. автометки теперь без цифр и не п
;//switch (<byteexpr>){...};
;//case <byteconst>: //генерируется автометка с числом (не пересечётся ни с чем)
;//default: //генерируется автометка с точкой (не пересечётся ни с чем)
;//rdword(); //'('
;PUSHVAR _tmpendlbl ;Line=1588
	LD HL,[_tmpendlbl]
;POPVAR eatswitch.wastmpendlbl ;Line=1588
	LD [eatswitch.wastmpendlbl],HL
;PUSHVAR _curlbl ;Line=1589
	LD HL,[_curlbl]
;POPVAR _tmpendlbl ;Line=1589
	LD [_tmpendlbl],HL
;OPERATION ++ ;Line=1589
	LD HL,[_curlbl]
	INC HL
	LD [_curlbl],HL
;//pushvar <title>.J
;accesspar=strcopy.A. ;Line=1592
;PUSHVAR _title ;Line=1592
	LD HL,[_title]
;POPVAR strcopy.A. ;Line=1592
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1592
;PUSHVAR _lentitle ;Line=1592
	LD HL,[_lentitle]
;POPVAR strcopy.B. ;Line=1592
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1592
;PUSHVAR _joined ;Line=1592
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=1592
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1592
	CALL strcopy
;POPVAR _lenjoined ;Line=1592
	LD [_lenjoined],HL
;accesspar=stradd.A. ;Line=1593
;PUSHVAR _joined ;Line=1593
	LD HL,[_joined]
;POPVAR stradd.A. ;Line=1593
	LD [stradd.A.],HL
;accesspar=stradd.B. ;Line=1593
;PUSHVAR _lenjoined ;Line=1593
	LD HL,[_lenjoined]
;POPVAR stradd.B. ;Line=1593
	LD [stradd.B.],HL
;accesspar=stradd.C. ;Line=1593
;PUSHNUM 'J' ;Line=1593
;POPVAR stradd.C. ;Line=1593
;PUSHCONST 'J' ;Line=1593
	LD A,'J'
	LD [stradd.C.],A
;CALL stradd ;Line=1593
	CALL stradd
;POPVAR _lenjoined ;Line=1593
	LD [_lenjoined],HL
;PUSHVAR _joined ;Line=1594
	LD HL,[_joined]
;PUSHVAR _lenjoined ;Line=1594
	LD DE,[_lenjoined]
;OPERATION +poi ;Line=1594
	ADD HL,DE
;PUSHNUM '\0' ;Line=1594
;POKE ;Line=1594
;PUSHCONST '\0' ;Line=1594
	LD A,'\0'
	LD [HL],A
;//strclose(_joined , _lenjoined);
;PUSHNUM _T_UINT ;Line=1595
;PUSHNUM _T_POI ;Line=1595
;PUSHCONST _T_UINT ;Line=1595
	LD A,_T_UINT
;OPERATION | ;Line=1595
;PUSHCONST _T_POI ;Line=1595
	LD E,_T_POI
	OR E
;POPVAR _t ;Line=1595
	LD [_t],A
;CALL cmdpushnum ;Line=1596
	CALL cmdpushnum
;//использование указателя в качестве массива - читаем его значение
;CALL eatidx ;Line=1598
	CALL eatidx
;PUSHNUM _T_UINT ;Line=1599
;POPVAR _t ;Line=1599
;PUSHCONST _T_UINT ;Line=1599
	LD A,_T_UINT
	LD [_t],A
;//тип элемента массива
;CALL cmdaddpoi ;Line=1600
	CALL cmdaddpoi
;CALL cmdpeek ;Line=1601
	CALL cmdpeek
;CALL cmdjpval ;Line=1603
	CALL cmdjpval
;//генерировать список начальных значений нумерованных меток перехода
;//procname.aab.<num> = procname.aab.default (пока без aab TODO)
;//генерировать таблицу переходов, заполненную нумерованными метками перехода
;//DW procname.aab.1 (пока без aab TODO)
;accesspar=varstr.A. ;Line=1609
;PUSHVAR _title ;Line=1609
	LD HL,[_title]
;POPVAR varstr.A. ;Line=1609
	LD [varstr.A.],HL
;CALL varstr ;Line=1609
	CALL varstr
;accesspar=varc.A. ;Line=1609
;PUSHNUM 'J' ;Line=1609
;POPVAR varc.A. ;Line=1609
;PUSHCONST 'J' ;Line=1609
	LD A,'J'
	LD [varc.A.],A
;CALL varc ;Line=1609
	CALL varc
;CALL endvar ;Line=1609
	CALL endvar
;PUSHNUM 0x00 ;Line=1610
;POPVAR eatswitch.ib ;Line=1610
;PUSHCONST 0x00 ;Line=1610
	LD A,0x00
	LD [eatswitch.ib],A
eatswitch.A.
;accesspar=asmstr.A. ;Line=1612
;PUSHVAR _title ;Line=1612
	LD HL,[_title]
;POPVAR asmstr.A. ;Line=1612
	LD [asmstr.A.],HL
;CALL asmstr ;Line=1612
	CALL asmstr
;accesspar=asmuint.A. ;Line=1612
;PUSHVAR eatswitch.ib ;Line=1612
	LD A,[eatswitch.ib]
;OPERATION cast 0>1 ;Line=1612
	LD L,A
	LD H,0
;POPVAR asmuint.A. ;Line=1612
	LD [asmuint.A.],HL
;CALL asmuint ;Line=1612
	CALL asmuint
;accesspar=asmc.A. ;Line=1612
;PUSHNUM '=' ;Line=1612
;POPVAR asmc.A. ;Line=1612
;PUSHCONST '=' ;Line=1612
	LD A,'='
	LD [asmc.A.],A
;CALL asmc ;Line=1612
	CALL asmc
;accesspar=asmstr.A. ;Line=1612
;PUSHVAR _title ;Line=1612
	LD HL,[_title]
;POPVAR asmstr.A. ;Line=1612
	LD [asmstr.A.],HL
;CALL asmstr ;Line=1612
	CALL asmstr
;accesspar=asmstr.A. ;Line=1612
;PUSHNUM eatswitch.C. ;Line=1612
;POPVAR asmstr.A. ;Line=1612
;PUSHCONST eatswitch.C. ;Line=1612
	LD HL,eatswitch.C.
	LD [asmstr.A.],HL
;CALL asmstr ;Line=1612
	CALL asmstr
;CALL endasm ;Line=1612
	CALL endasm
;//до кода! поэтому asm
;CALL var_dw ;Line=1613
	CALL var_dw
;accesspar=varstr.A. ;Line=1613
;PUSHVAR _title ;Line=1613
	LD HL,[_title]
;POPVAR varstr.A. ;Line=1613
	LD [varstr.A.],HL
;CALL varstr ;Line=1613
	CALL varstr
;accesspar=varuint.A. ;Line=1613
;PUSHVAR eatswitch.ib ;Line=1613
	LD A,[eatswitch.ib]
;OPERATION cast 0>1 ;Line=1613
	LD L,A
	LD H,0
;POPVAR varuint.A. ;Line=1613
	LD [varuint.A.],HL
;CALL varuint ;Line=1613
	CALL varuint
;CALL endvar ;Line=1613
	CALL endvar
;//TODO "DP", т.е. на ширину POINTER?
;OPERATION ++ ;Line=1614
;PUSHNUM eatswitch.ib ;Line=1614
;PUSHCONST eatswitch.ib ;Line=1614
	LD HL,eatswitch.ib
	INC [HL]
;PUSHVAR eatswitch.ib ;Line=1615
	LD A,[eatswitch.ib]
;PUSHNUM 0x00 ;Line=1615
;OPERATION == ;Line=1615
	SUB 0x00
;JUMP IF FALSE eatswitch.A. ;Line=1615
	JP NZ,eatswitch.A.
eatswitch.B.
;CALL eatcmd ;Line=1617
	CALL eatcmd
;//{...}
;accesspar=genjplbl.A. ;Line=1619
;PUSHVAR _tmpendlbl ;Line=1619
	LD HL,[_tmpendlbl]
;POPVAR genjplbl.A. ;Line=1619
	LD [genjplbl.A.],HL
;CALL genjplbl ;Line=1619
	CALL genjplbl
;CALL cmdlabel ;Line=1619
	CALL cmdlabel
;PUSHVAR eatswitch.wastmpendlbl ;Line=1620
	LD HL,[eatswitch.wastmpendlbl]
;POPVAR _tmpendlbl ;Line=1620
	LD [_tmpendlbl],HL
;ENDFUNC ;Line=1623
	RET
eatcase
;FUNC ;Line=1623
;//case <byteconst>:
;//rdword(); //byteconst
;//заполнить нумерованную метку перехода
;//procname.aab.#<_tword> = $ (пока без aab TODO)
;accesspar=asmstr.A. ;Line=1630
;PUSHVAR _title ;Line=1630
	LD HL,[_title]
;POPVAR asmstr.A. ;Line=1630
	LD [asmstr.A.],HL
;CALL asmstr ;Line=1630
	CALL asmstr
;accesspar=asmc.A. ;Line=1630
;PUSHNUM '#' ;Line=1630
;POPVAR asmc.A. ;Line=1630
;PUSHCONST '#' ;Line=1630
	LD A,'#'
	LD [asmc.A.],A
;CALL asmc ;Line=1630
	CALL asmc
;accesspar=asmstr.A. ;Line=1630
;PUSHVAR _tword ;Line=1630
	LD HL,[_tword]
;POPVAR asmstr.A. ;Line=1630
	LD [asmstr.A.],HL
;CALL asmstr ;Line=1630
	CALL asmstr
;accesspar=asmc.A. ;Line=1630
;PUSHNUM '=' ;Line=1630
;POPVAR asmc.A. ;Line=1630
;PUSHCONST '=' ;Line=1630
	LD A,'='
	LD [asmc.A.],A
;CALL asmc ;Line=1630
	CALL asmc
;accesspar=asmc.A. ;Line=1630
;PUSHNUM '$' ;Line=1630
;POPVAR asmc.A. ;Line=1630
;PUSHCONST '$' ;Line=1630
	LD A,'$'
	LD [asmc.A.],A
;CALL asmc ;Line=1630
	CALL asmc
;CALL endasm ;Line=1630
	CALL endasm
;CALL rdword ;Line=1632
	CALL rdword
;//skip ':' for C compatibility
;CALL rdword ;Line=1633
	CALL rdword
;//нужно!
;ENDFUNC ;Line=1636
	RET
eatcmd
;FUNC ;Line=1636
;//возвращает +FALSE, если конец блока
;//начальная часть имени переменной уже прочитана
;CALL adddots ;Line=1640
	CALL adddots
;//дочитать имя
;PUSHVAR _tword ;Line=1641
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1641
;PEEK ;Line=1641
	LD A,[HL]
;POPVAR _c0 ;Line=1641
	LD [_c0],A
;PUSHVAR _c0 ;Line=1642
	LD A,[_c0]
;PUSHNUM '}' ;Line=1642
;OPERATION == ;Line=1642
	SUB '}'
	SUB 1
	SBC A,A
;PUSHVAR _waseof ;Line=1642
	LD L,A
	LD A,[_waseof]
;OPERATION | ;Line=1642
	OR L
;JUMP IF FALSE eatcmd.A. ;Line=1642
	JP Z,eatcmd.A.
;CALL rdword ;Line=1643
	CALL rdword
;PUSHNUM FALSE ;Line=1644
;POPVAR _morecmd ;Line=1644
;PUSHCONST FALSE ;Line=1644
	LD A,FALSE
	LD [_morecmd],A
;JUMP eatcmd.B. ;Line=1645
	JP eatcmd.B.
eatcmd.A.
;//    IF (_wasreturn) {
;//      IF (_c0!=';') {errstr("cmd after return!"); enderr(); };
;//    };
;PUSHVAR _cnext ;Line=1649
	LD A,[_cnext]
;PUSHNUM '=' ;Line=1649
;OPERATION == ;Line=1649
	SUB '='
;JUMP IF FALSE eatcmd.C. ;Line=1649
	JP NZ,eatcmd.C.
;//let
;CALL eatlet ;Line=1650
	CALL eatlet
;JUMP eatcmd.D. ;Line=1651
	JP eatcmd.D.
eatcmd.C.
;PUSHVAR _cnext ;Line=1651
	LD A,[_cnext]
;PUSHNUM '[' ;Line=1651
;OPERATION == ;Line=1651
	SUB '['
;JUMP IF FALSE eatcmd.E. ;Line=1651
	JP NZ,eatcmd.E.
;//let []
;CALL eatlet ;Line=1652
	CALL eatlet
;JUMP eatcmd.F. ;Line=1653
	JP eatcmd.F.
eatcmd.E.
;PUSHVAR _cnext ;Line=1653
	LD A,[_cnext]
;PUSHNUM '-' ;Line=1653
;OPERATION == ;Line=1653
	SUB '-'
;JUMP IF FALSE eatcmd.G. ;Line=1653
	JP NZ,eatcmd.G.
;//let ->
;CALL eatlet ;Line=1654
	CALL eatlet
;JUMP eatcmd.H. ;Line=1655
	JP eatcmd.H.
eatcmd.G.
;PUSHVAR _cnext ;Line=1655
	LD A,[_cnext]
;PUSHNUM '(' ;Line=1655
;OPERATION == ;Line=1655
	SUB '('
	SUB 1
	SBC A,A
;PUSHVAR _spcsize ;Line=1655
	LD DE,[_spcsize]
;PUSHNUM 0 ;Line=1655
;OPERATION == ;Line=1655
;PUSHCONST 0 ;Line=1655
	LD BC,0
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
;OPERATION & ;Line=1655
	AND L
;JUMP IF FALSE eatcmd.I. ;Line=1655
	JP Z,eatcmd.I.
;//call
;/**isfunc*/
;accesspar=do_call.A. ;Line=1656
;PUSHPAR do_call.A. ;Line=1656
	LD A,[do_call.A.]
;PUSHNUM FALSE ;Line=1656
;POPVAR do_call.A. ;Line=1656
;PUSHCONST FALSE ;Line=1656
	LD E,FALSE
	LD L,A
	LD A,E
	LD [do_call.A.],A
;CALL do_call ;Line=1656
	PUSH HL
	CALL do_call
;POPPAR ;Line=1656
	POP HL
	LD A,L
	LD [do_call.A.],A
;CALL rdword ;Line=1656
	CALL rdword
;JUMP eatcmd.J. ;Line=1657
	JP eatcmd.J.
eatcmd.I.
;PUSHVAR _cnext ;Line=1657
	LD A,[_cnext]
;PUSHNUM ':' ;Line=1657
;OPERATION == ;Line=1657
	SUB ':'
;JUMP IF FALSE eatcmd.K. ;Line=1657
	JP NZ,eatcmd.K.
;//lbl
;CALL eatlbl ;Line=1658
	CALL eatlbl
;JUMP eatcmd.L. ;Line=1659
	JP eatcmd.L.
eatcmd.K.
;PUSHVAR _c0 ;Line=1660
	LD A,[_c0]
;PUSHNUM ';' ;Line=1660
;OPERATION == ;Line=1660
	SUB ';'
;JUMP IF FALSE eatcmd.M. ;Line=1660
	JP NZ,eatcmd.M.
;CALL rdword ;Line=1661
	CALL rdword
;//C compatibility
;JUMP eatcmd.N. ;Line=1662
	JP eatcmd.N.
eatcmd.M.
;PUSHVAR _c0 ;Line=1662
	LD A,[_c0]
;PUSHNUM '{' ;Line=1662
;OPERATION == ;Line=1662
	SUB '{'
;JUMP IF FALSE eatcmd.O. ;Line=1662
	JP NZ,eatcmd.O.
;CALL rdword ;Line=1663
	CALL rdword
eatcmd.Q.
;CALL eatcmd ;Line=1663
	CALL eatcmd
;JUMP IF FALSE eatcmd.R. ;Line=1663
	OR A
	JP Z,eatcmd.R.
;JUMP eatcmd.Q. ;Line=1663
	JP eatcmd.Q.
eatcmd.R.
;JUMP eatcmd.P. ;Line=1664
	JP eatcmd.P.
eatcmd.O.
;PUSHVAR _c0 ;Line=1665
	LD A,[_c0]
;OPERATION cast 5>0 ;Line=1665
;PUSHNUM 0x20 ;Line=1665
;OPERATION | ;Line=1665
;PUSHCONST 0x20 ;Line=1665
	LD E,0x20
	OR E
;OPERATION cast 0>5 ;Line=1665
;POPVAR _c0 ;Line=1665
	LD [_c0],A
;PUSHVAR _tword ;Line=1666
	LD HL,[_tword]
;PUSHNUM 2 ;Line=1666
;OPERATION +poi ;Line=1666
;PUSHCONST 2 ;Line=1666
	LD DE,2
	ADD HL,DE
;PEEK ;Line=1666
	LD A,[HL]
;OPERATION cast 5>0 ;Line=1666
;PUSHNUM 0x20 ;Line=1666
;OPERATION | ;Line=1666
;PUSHCONST 0x20 ;Line=1666
	LD E,0x20
	OR E
;OPERATION cast 0>5 ;Line=1666
;POPVAR _c2 ;Line=1666
	LD [_c2],A
;PUSHVAR _c0 ;Line=1667
	LD A,[_c0]
;PUSHNUM 'v' ;Line=1667
;OPERATION == ;Line=1667
	SUB 'v'
;JUMP IF FALSE eatcmd.S. ;Line=1667
	JP NZ,eatcmd.S.
;//var
;CALL rdword ;Line=1668
	CALL rdword
;/**ispar*/
;accesspar=eatvar.A. ;Line=1668
;PUSHNUM FALSE ;Line=1668
;POPVAR eatvar.A. ;Line=1668
;PUSHCONST FALSE ;Line=1668
	LD A,FALSE
	LD [eatvar.A.],A
;/**body*/
;accesspar=eatvar.B. ;Line=1668
;PUSHNUM TRUE ;Line=1668
;POPVAR eatvar.B. ;Line=1668
;PUSHCONST TRUE ;Line=1668
	LD A,TRUE
	LD [eatvar.B.],A
;CALL eatvar ;Line=1668
	CALL eatvar
;PUSHNUM FALSE ;Line=1669
;POPVAR _isexp ;Line=1669
;PUSHCONST FALSE ;Line=1669
	LD A,FALSE
	LD [_isexp],A
;//нельзя внутрь, иначе не экспортируются параметры процедуры
;JUMP eatcmd.T. ;Line=1670
	JP eatcmd.T.
eatcmd.S.
;PUSHVAR _c0 ;Line=1670
	LD A,[_c0]
;PUSHNUM 'e' ;Line=1670
;OPERATION == ;Line=1670
	SUB 'e'
;JUMP IF FALSE eatcmd.U. ;Line=1670
	JP NZ,eatcmd.U.
;//enum //extern //export
;PUSHVAR _c2 ;Line=1671
	LD A,[_c2]
;PUSHNUM 't' ;Line=1671
;OPERATION == ;Line=1671
	SUB 't'
;JUMP IF FALSE eatcmd.W. ;Line=1671
	JP NZ,eatcmd.W.
;//extern
;CALL rdword ;Line=1672
	CALL rdword
;CALL eatextern ;Line=1672
	CALL eatextern
;JUMP eatcmd.X. ;Line=1673
	JP eatcmd.X.
eatcmd.W.
;PUSHVAR _c2 ;Line=1673
	LD A,[_c2]
;PUSHNUM 'p' ;Line=1673
;OPERATION == ;Line=1673
	SUB 'p'
;JUMP IF FALSE eatcmd.Y. ;Line=1673
	JP NZ,eatcmd.Y.
;//export
;CALL rdword ;Line=1674
	CALL rdword
;PUSHNUM TRUE ;Line=1674
;POPVAR _isexp ;Line=1674
;PUSHCONST TRUE ;Line=1674
	LD A,TRUE
	LD [_isexp],A
;JUMP eatcmd.Z. ;Line=1675
	JP eatcmd.Z.
eatcmd.Y.
;//enum
;CALL rdword ;Line=1676
	CALL rdword
;CALL eatenum ;Line=1676
	CALL eatenum
eatcmd.Z.
eatcmd.X.
;JUMP eatcmd.V. ;Line=1678
	JP eatcmd.V.
eatcmd.U.
;PUSHVAR _c0 ;Line=1678
	LD A,[_c0]
;PUSHNUM 'c' ;Line=1678
;OPERATION == ;Line=1678
	SUB 'c'
;JUMP IF FALSE eatcmd.BA. ;Line=1678
	JP NZ,eatcmd.BA.
;//const //case //call
;PUSHVAR _c2 ;Line=1679
	LD A,[_c2]
;PUSHNUM 'n' ;Line=1679
;OPERATION == ;Line=1679
	SUB 'n'
;JUMP IF FALSE eatcmd.BC. ;Line=1679
	JP NZ,eatcmd.BC.
;//const
;CALL rdword ;Line=1680
	CALL rdword
;CALL eatconst ;Line=1680
	CALL eatconst
;JUMP eatcmd.BD. ;Line=1681
	JP eatcmd.BD.
eatcmd.BC.
;PUSHVAR _c2 ;Line=1681
	LD A,[_c2]
;PUSHNUM 'l' ;Line=1681
;OPERATION == ;Line=1681
	SUB 'l'
;JUMP IF FALSE eatcmd.BE. ;Line=1681
	JP NZ,eatcmd.BE.
;//call
;CALL rdword ;Line=1682
	CALL rdword
;CALL eatcallpoi ;Line=1682
	CALL eatcallpoi
;JUMP eatcmd.BF. ;Line=1683
	JP eatcmd.BF.
eatcmd.BE.
;//case
;CALL rdword ;Line=1684
	CALL rdword
;CALL eatcase ;Line=1684
	CALL eatcase
eatcmd.BF.
eatcmd.BD.
;JUMP eatcmd.BB. ;Line=1686
	JP eatcmd.BB.
eatcmd.BA.
;PUSHVAR _c0 ;Line=1686
	LD A,[_c0]
;PUSHNUM 'f' ;Line=1686
;OPERATION == ;Line=1686
	SUB 'f'
;JUMP IF FALSE eatcmd.BG. ;Line=1686
	JP NZ,eatcmd.BG.
;//func
;CALL rdword ;Line=1687
	CALL rdword
;accesspar=eatfunc.A. ;Line=1687
;PUSHNUM TRUE ;Line=1687
;POPVAR eatfunc.A. ;Line=1687
;PUSHCONST TRUE ;Line=1687
	LD A,TRUE
	LD [eatfunc.A.],A
;accesspar=eatfunc.B. ;Line=1687
;PUSHVAR _curfunct ;Line=1687
	LD A,[_curfunct]
;POPVAR eatfunc.B. ;Line=1687
	LD [eatfunc.B.],A
;accesspar=eatfunc.C. ;Line=1687
;PUSHVAR _wasreturn ;Line=1687
	LD A,[_wasreturn]
;POPVAR eatfunc.C. ;Line=1687
	LD [eatfunc.C.],A
;CALL eatfunc ;Line=1687
	CALL eatfunc
;JUMP eatcmd.BH. ;Line=1688
	JP eatcmd.BH.
eatcmd.BG.
;PUSHVAR _c0 ;Line=1688
	LD A,[_c0]
;PUSHNUM 'p' ;Line=1688
;OPERATION == ;Line=1688
	SUB 'p'
;JUMP IF FALSE eatcmd.BI. ;Line=1688
	JP NZ,eatcmd.BI.
;//proc //poke
;PUSHVAR _c2 ;Line=1689
	LD A,[_c2]
;PUSHNUM 'o' ;Line=1689
;OPERATION == ;Line=1689
	SUB 'o'
;JUMP IF FALSE eatcmd.BK. ;Line=1689
	JP NZ,eatcmd.BK.
;//proc
;CALL rdword ;Line=1690
	CALL rdword
;accesspar=eatfunc.A. ;Line=1690
;PUSHNUM FALSE ;Line=1690
;POPVAR eatfunc.A. ;Line=1690
;PUSHCONST FALSE ;Line=1690
	LD A,FALSE
	LD [eatfunc.A.],A
;accesspar=eatfunc.B. ;Line=1690
;PUSHVAR _curfunct ;Line=1690
	LD A,[_curfunct]
;POPVAR eatfunc.B. ;Line=1690
	LD [eatfunc.B.],A
;accesspar=eatfunc.C. ;Line=1690
;PUSHVAR _wasreturn ;Line=1690
	LD A,[_wasreturn]
;POPVAR eatfunc.C. ;Line=1690
	LD [eatfunc.C.],A
;CALL eatfunc ;Line=1690
	CALL eatfunc
;JUMP eatcmd.BL. ;Line=1691
	JP eatcmd.BL.
eatcmd.BK.
;//poke
;CALL rdword ;Line=1692
	CALL rdword
;CALL eatpoke ;Line=1692
	CALL eatpoke
eatcmd.BL.
;JUMP eatcmd.BJ. ;Line=1694
	JP eatcmd.BJ.
eatcmd.BI.
;PUSHVAR _c0 ;Line=1694
	LD A,[_c0]
;PUSHNUM 'r' ;Line=1694
;OPERATION == ;Line=1694
	SUB 'r'
;JUMP IF FALSE eatcmd.BM. ;Line=1694
	JP NZ,eatcmd.BM.
;//return //repeat
;PUSHVAR _c2 ;Line=1695
	LD A,[_c2]
;PUSHNUM 't' ;Line=1695
;OPERATION == ;Line=1695
	SUB 't'
;JUMP IF FALSE eatcmd.BO. ;Line=1695
	JP NZ,eatcmd.BO.
;//return
;CALL rdword ;Line=1696
	CALL rdword
;CALL eatreturn ;Line=1696
	CALL eatreturn
;JUMP eatcmd.BP. ;Line=1697
	JP eatcmd.BP.
eatcmd.BO.
;//repeat
;CALL rdword ;Line=1698
	CALL rdword
;CALL eatrepeat ;Line=1698
	CALL eatrepeat
eatcmd.BP.
;JUMP eatcmd.BN. ;Line=1700
	JP eatcmd.BN.
eatcmd.BM.
;PUSHVAR _c0 ;Line=1700
	LD A,[_c0]
;PUSHNUM 'w' ;Line=1700
;OPERATION == ;Line=1700
	SUB 'w'
;JUMP IF FALSE eatcmd.BQ. ;Line=1700
	JP NZ,eatcmd.BQ.
;//while
;CALL rdword ;Line=1701
	CALL rdword
;CALL eatwhile ;Line=1701
	CALL eatwhile
;JUMP eatcmd.BR. ;Line=1702
	JP eatcmd.BR.
eatcmd.BQ.
;PUSHVAR _c0 ;Line=1702
	LD A,[_c0]
;PUSHNUM 'b' ;Line=1702
;OPERATION == ;Line=1702
	SUB 'b'
;JUMP IF FALSE eatcmd.BS. ;Line=1702
	JP NZ,eatcmd.BS.
;//break
;CALL rdword ;Line=1703
	CALL rdword
;CALL eatbreak ;Line=1703
	CALL eatbreak
;//no parameters (rds nothing)
;JUMP eatcmd.BT. ;Line=1704
	JP eatcmd.BT.
eatcmd.BS.
;PUSHVAR _c0 ;Line=1704
	LD A,[_c0]
;PUSHNUM 'd' ;Line=1704
;OPERATION == ;Line=1704
	SUB 'd'
;JUMP IF FALSE eatcmd.BU. ;Line=1704
	JP NZ,eatcmd.BU.
;//dec
;CALL rdword ;Line=1705
	CALL rdword
;CALL eatdec ;Line=1705
	CALL eatdec
;JUMP eatcmd.BV. ;Line=1706
	JP eatcmd.BV.
eatcmd.BU.
;PUSHVAR _c0 ;Line=1706
	LD A,[_c0]
;PUSHNUM 'i' ;Line=1706
;OPERATION == ;Line=1706
	SUB 'i'
;JUMP IF FALSE eatcmd.BW. ;Line=1706
	JP NZ,eatcmd.BW.
;//inc //if
;PUSHVAR _c2 ;Line=1707
	LD A,[_c2]
;PUSHNUM 'c' ;Line=1707
;OPERATION == ;Line=1707
	SUB 'c'
;JUMP IF FALSE eatcmd.BY. ;Line=1707
	JP NZ,eatcmd.BY.
;//inc
;CALL rdword ;Line=1708
	CALL rdword
;CALL eatinc ;Line=1708
	CALL eatinc
;JUMP eatcmd.BZ. ;Line=1709
	JP eatcmd.BZ.
eatcmd.BY.
;//if
;CALL rdword ;Line=1710
	CALL rdword
;CALL eatif ;Line=1710
	CALL eatif
eatcmd.BZ.
;JUMP eatcmd.BX. ;Line=1712
	JP eatcmd.BX.
eatcmd.BW.
;PUSHVAR _c0 ;Line=1712
	LD A,[_c0]
;PUSHNUM 'g' ;Line=1712
;OPERATION == ;Line=1712
	SUB 'g'
;JUMP IF FALSE eatcmd.CA. ;Line=1712
	JP NZ,eatcmd.CA.
;//goto
;CALL rdword ;Line=1713
	CALL rdword
;CALL eatgoto ;Line=1713
	CALL eatgoto
;JUMP eatcmd.CB. ;Line=1714
	JP eatcmd.CB.
eatcmd.CA.
;PUSHVAR _c0 ;Line=1714
	LD A,[_c0]
;PUSHNUM 'a' ;Line=1714
;OPERATION == ;Line=1714
	SUB 'a'
;JUMP IF FALSE eatcmd.CC. ;Line=1714
	JP NZ,eatcmd.CC.
;//asm
;CALL rdword ;Line=1715
	CALL rdword
;CALL eatasm ;Line=1715
	CALL eatasm
;JUMP eatcmd.CD. ;Line=1716
	JP eatcmd.CD.
eatcmd.CC.
;PUSHVAR _c0 ;Line=1716
	LD A,[_c0]
;PUSHNUM 's' ;Line=1716
;OPERATION == ;Line=1716
	SUB 's'
;JUMP IF FALSE eatcmd.CE. ;Line=1716
	JP NZ,eatcmd.CE.
;//struct //switch
;PUSHVAR _c2 ;Line=1717
	LD A,[_c2]
;PUSHNUM 'r' ;Line=1717
;OPERATION == ;Line=1717
	SUB 'r'
;JUMP IF FALSE eatcmd.CG. ;Line=1717
	JP NZ,eatcmd.CG.
;//struct
;CALL rdword ;Line=1718
	CALL rdword
;CALL eatstruct ;Line=1718
	CALL eatstruct
;JUMP eatcmd.CH. ;Line=1719
	JP eatcmd.CH.
eatcmd.CG.
;//switch
;CALL rdword ;Line=1720
	CALL rdword
;CALL eatswitch ;Line=1720
	CALL eatswitch
eatcmd.CH.
;//        }ELSE IF ( _c0=='m' ) { //module
;//          rdword(); eatmodule();
;JUMP eatcmd.CF. ;Line=1724
	JP eatcmd.CF.
eatcmd.CE.
;PUSHVAR _c0 ;Line=1724
	LD A,[_c0]
;PUSHNUM 't' ;Line=1724
;OPERATION == ;Line=1724
	SUB 't'
;JUMP IF FALSE eatcmd.CI. ;Line=1724
	JP NZ,eatcmd.CI.
;//typedef <type> <name>
;CALL rdword ;Line=1725
	CALL rdword
;CALL eattype ;Line=1726
	CALL eattype
;POPVAR _t ;Line=1726
	LD [_t],A
;accesspar=strcopy.A. ;Line=1727
;PUSHVAR _tword ;Line=1727
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=1727
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1727
;PUSHVAR _lentword ;Line=1727
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=1727
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1727
;PUSHVAR _name ;Line=1727
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1727
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1727
	CALL strcopy
;POPVAR _lenname ;Line=1727
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1728
;PUSHNUM _T_TYPE ;Line=1728
;PUSHVAR _t ;Line=1728
;PUSHCONST _T_TYPE ;Line=1728
	LD A,_T_TYPE
	LD L,A
	LD A,[_t]
;OPERATION + ;Line=1728
	ADD A,L
;POPVAR addlbl.A. ;Line=1728
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1728
;PUSHNUM FALSE ;Line=1728
;POPVAR addlbl.B. ;Line=1728
;PUSHCONST FALSE ;Line=1728
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1728
;PUSHNUM _typesz ;Line=1728
;PUSHVAR _t ;Line=1728
;PUSHCONST _typesz ;Line=1728
	LD HL,_typesz
	LD A,[_t]
;OPERATION cast 0>1 ;Line=1728
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1728
	ADD HL,DE
;PEEK ;Line=1728
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1728
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1728
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1728
	CALL addlbl
;CALL rdword ;Line=1729
	CALL rdword
;//использовали имя
;JUMP eatcmd.CJ. ;Line=1730
	JP eatcmd.CJ.
eatcmd.CI.
;PUSHVAR _c0 ;Line=1730
	LD A,[_c0]
;PUSHNUM '#' ;Line=1730
;OPERATION == ;Line=1730
	SUB '#'
;JUMP IF FALSE eatcmd.CK. ;Line=1730
	JP NZ,eatcmd.CK.
;//define, include... (сюда попадаем даже в неактивных ветках условной компиляци
;CALL rdword ;Line=1731
	CALL rdword
;//define, undef, include, if, else, [elif], ifdef, ifndef, endif, [import], [li
;//todo как можно сделать вложенную условную компиляцию:
;//_doskipcond в битовом виде помнит, сколько уровней активных ifdef и сколько у
;//(внутри неактивного могут быть только неактивные)
;//если (_doskipcond&1) == 0 (т.е. мы в неактивной ветке), то текущий ifdef игно
;//неактивность текущей ветки ifdef лежит в _doskip
;//на верхнем уровне _doskipcond = 1, _doskip = +FALSE
;//если ifdef, то:
;//_doskipcond = _doskipcond+_doskipcond
;//если !_doskip, то:
;//если ifdef годен, то INC _doskipcond
;//иначе _doskip = +TRUE
;//если else и ((_doskipcond&1) == 0), то _doskip = !_doskip
;//если endif, то _doskip = ((_doskipcond&1) == 0); _doskipcond = _doskipcond>>1
;PUSHVAR _tword ;Line=1745
	LD HL,[_tword]
;PUSHNUM 2 ;Line=1745
;OPERATION +poi ;Line=1745
;PUSHCONST 2 ;Line=1745
	LD DE,2
	ADD HL,DE
;PEEK ;Line=1745
	LD A,[HL]
;PUSHNUM 'c' ;Line=1745
;OPERATION == ;Line=1745
	SUB 'c'
	SUB 1
	SBC A,A
;PUSHVAR _doskip ;Line=1745
	LD L,A
	LD A,[_doskip]
;INV ;Line=1745
	CPL
;OPERATION & ;Line=1745
	AND L
;JUMP IF FALSE eatcmd.CM. ;Line=1745
	JP Z,eatcmd.CM.
;//include
;CALL rdword ;Line=1746
	CALL rdword
;//"
;PUSHNUM 0 ;Line=1747
;POPVAR _lentword ;Line=1747
;PUSHCONST 0 ;Line=1747
	LD HL,0
	LD [_lentword],HL
;accesspar=rdquotes.A. ;Line=1748
;PUSHNUM '\"' ;Line=1748
;/**, +FALSE*/
;POPVAR rdquotes.A. ;Line=1748
;PUSHCONST '\"' ;Line=1748
	LD A,'\"'
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=1748
	CALL rdquotes
;//IF (_c0 == '\"') { rdquotes('>'); }ELSE rdquotes('\"');
;PUSHNUM _hinclfile ;Line=1749
;PUSHVAR _nhinclfiles ;Line=1749
;PUSHCONST _hinclfile ;Line=1749
	LD HL,_hinclfile
	LD A,[_nhinclfiles]
;OPERATION cast 0>1 ;Line=1749
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1749
	ADD HL,DE
	ADD HL,DE
;PUSHVAR _fin ;Line=1749
	LD DE,[_fin]
;POKE ;Line=1749
	LD [HL],E
	INC HL
	LD [HL],D
;PUSHNUM _hnline ;Line=1750
;PUSHVAR _nhinclfiles ;Line=1750
;PUSHCONST _hnline ;Line=1750
	LD HL,_hnline
	LD A,[_nhinclfiles]
;OPERATION cast 0>1 ;Line=1750
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1750
	ADD HL,DE
	ADD HL,DE
;PUSHVAR _curline ;Line=1750
	LD DE,[_curline]
;POKE ;Line=1750
	LD [HL],E
	INC HL
	LD [HL],D
;OPERATION ++ ;Line=1751
;PUSHNUM _nhinclfiles ;Line=1751
;PUSHCONST _nhinclfiles ;Line=1751
	LD HL,_nhinclfiles
	INC [HL]
;accesspar=compfile.A. ;Line=1752
;PUSHPAR compfile.A. ;Line=1752
	LD HL,[compfile.A.]
;PUSHVAR _tword ;Line=1752
	LD DE,[_tword]
;POPVAR compfile.A. ;Line=1752
	LD [compfile.A.],DE
;CALL compfile ;Line=1752
	PUSH HL
	CALL compfile
;POPPAR ;Line=1752
	POP HL
	LD [compfile.A.],HL
;OPERATION -- ;Line=1753
;PUSHNUM _nhinclfiles ;Line=1753
;PUSHCONST _nhinclfiles ;Line=1753
	LD HL,_nhinclfiles
	DEC [HL]
;PUSHNUM _hinclfile ;Line=1754
;PUSHVAR _nhinclfiles ;Line=1754
;PUSHCONST _hinclfile ;Line=1754
	LD HL,_hinclfile
	LD A,[_nhinclfiles]
;OPERATION cast 0>1 ;Line=1754
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1754
	ADD HL,DE
	ADD HL,DE
;PEEK ;Line=1754
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
;POPVAR _fin ;Line=1754
	LD [_fin],HL
;PUSHNUM _hnline ;Line=1755
;PUSHVAR _nhinclfiles ;Line=1755
;PUSHCONST _hnline ;Line=1755
	LD HL,_hnline
	LD A,[_nhinclfiles]
;OPERATION cast 0>1 ;Line=1755
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1755
	ADD HL,DE
	ADD HL,DE
;PEEK ;Line=1755
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
;POPVAR _curline ;Line=1755
	LD [_curline],HL
;PUSHNUM FALSE ;Line=1756
;POPVAR _waseof ;Line=1756
;PUSHCONST FALSE ;Line=1756
	LD A,FALSE
	LD [_waseof],A
;CALL rdch ;Line=1757
	CALL rdch
;//пропустить закрывающую кавычку
;JUMP eatcmd.CN. ;Line=1758
	JP eatcmd.CN.
eatcmd.CM.
;PUSHVAR _tword ;Line=1758
	LD HL,[_tword]
;PUSHNUM 2 ;Line=1758
;OPERATION +poi ;Line=1758
;PUSHCONST 2 ;Line=1758
	LD DE,2
	ADD HL,DE
;PEEK ;Line=1758
	LD A,[HL]
;PUSHNUM 'd' ;Line=1758
;OPERATION == ;Line=1758
	SUB 'd'
;JUMP IF FALSE eatcmd.CO. ;Line=1758
	JP NZ,eatcmd.CO.
;//ifdef/endif/undef
;PUSHVAR _tword ;Line=1759
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1759
;PEEK ;Line=1759
	LD A,[HL]
;PUSHNUM 'e' ;Line=1759
;OPERATION == ;Line=1759
	SUB 'e'
;JUMP IF FALSE eatcmd.CQ. ;Line=1759
	JP NZ,eatcmd.CQ.
;//endif
;PUSHNUM FALSE ;Line=1760
;POPVAR _doskip ;Line=1760
;PUSHCONST FALSE ;Line=1760
	LD A,FALSE
	LD [_doskip],A
;//todo вложенность (подсчёт числа ифов)
;JUMP eatcmd.CR. ;Line=1761
	JP eatcmd.CR.
eatcmd.CQ.
;PUSHVAR _tword ;Line=1761
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1761
;PEEK ;Line=1761
	LD A,[HL]
;PUSHNUM 'i' ;Line=1761
;OPERATION == ;Line=1761
	SUB 'i'
;JUMP IF FALSE eatcmd.CS. ;Line=1761
	JP NZ,eatcmd.CS.
;//ifdef
;CALL rdword ;Line=1762
	CALL rdword
;//имя
;accesspar=strcopy.A. ;Line=1763
;PUSHVAR _tword ;Line=1763
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=1763
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1763
;PUSHVAR _lentword ;Line=1763
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=1763
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1763
;PUSHVAR _name ;Line=1763
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1763
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1763
	CALL strcopy
;POPVAR _lenname ;Line=1763
	LD [_lenname],HL
;CALL lbltype ;Line=1764
	CALL lbltype
;POPVAR _t ;Line=1764
	LD [_t],A
;//если нету, то _T_UNKNOWN
;PUSHVAR _t ;Line=1765
	LD A,[_t]
;PUSHNUM _T_UNKNOWN ;Line=1765
;OPERATION == ;Line=1765
	SUB _T_UNKNOWN
;JUMP IF FALSE eatcmd.CU. ;Line=1765
	JP NZ,eatcmd.CU.
;//нет метки - пропустить тело
;PUSHNUM TRUE ;Line=1766
;POPVAR _doskip ;Line=1766
;PUSHCONST TRUE ;Line=1766
	LD A,TRUE
	LD [_doskip],A
;//включить пропуск строк, кроме начинающихся с #, а здесь обрабатывать только и
eatcmd.CU.
;JUMP eatcmd.CT. ;Line=1768
	JP eatcmd.CT.
eatcmd.CS.
;//undef
;CALL rdword ;Line=1769
	CALL rdword
;//имя
;accesspar=strcopy.A. ;Line=1770
;PUSHVAR _tword ;Line=1770
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=1770
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1770
;PUSHVAR _lentword ;Line=1770
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=1770
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1770
;PUSHVAR _name ;Line=1770
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1770
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1770
	CALL strcopy
;POPVAR _lenname ;Line=1770
	LD [_lenname],HL
;CALL dellbl ;Line=1771
	CALL dellbl
eatcmd.CT.
eatcmd.CR.
;JUMP eatcmd.CP. ;Line=1773
	JP eatcmd.CP.
eatcmd.CO.
;PUSHVAR _tword ;Line=1773
	LD HL,[_tword]
;PUSHNUM 2 ;Line=1773
;OPERATION +poi ;Line=1773
;PUSHCONST 2 ;Line=1773
	LD DE,2
	ADD HL,DE
;PEEK ;Line=1773
	LD A,[HL]
;PUSHNUM 'n' ;Line=1773
;OPERATION == ;Line=1773
	SUB 'n'
;JUMP IF FALSE eatcmd.CW. ;Line=1773
	JP NZ,eatcmd.CW.
;//ifndef
;CALL rdword ;Line=1774
	CALL rdword
;//имя
;accesspar=strcopy.A. ;Line=1775
;PUSHVAR _tword ;Line=1775
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=1775
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1775
;PUSHVAR _lentword ;Line=1775
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=1775
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1775
;PUSHVAR _name ;Line=1775
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1775
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1775
	CALL strcopy
;POPVAR _lenname ;Line=1775
	LD [_lenname],HL
;CALL lbltype ;Line=1776
	CALL lbltype
;POPVAR _t ;Line=1776
	LD [_t],A
;//если нету, то _T_UNKNOWN
;PUSHVAR _t ;Line=1777
	LD A,[_t]
;PUSHNUM _T_UNKNOWN ;Line=1777
;OPERATION != ;Line=1777
	SUB _T_UNKNOWN
;JUMP IF FALSE eatcmd.CY. ;Line=1777
	JP Z,eatcmd.CY.
;//есть метка - пропустить тело
;PUSHNUM TRUE ;Line=1778
;POPVAR _doskip ;Line=1778
;PUSHCONST TRUE ;Line=1778
	LD A,TRUE
	LD [_doskip],A
;//включить пропуск строк, кроме начинающихся с #, а здесь обрабатывать только и
eatcmd.CY.
;JUMP eatcmd.CX. ;Line=1780
	JP eatcmd.CX.
eatcmd.CW.
;PUSHVAR _tword ;Line=1780
	LD HL,[_tword]
;PUSHNUM 2 ;Line=1780
;OPERATION +poi ;Line=1780
;PUSHCONST 2 ;Line=1780
	LD DE,2
	ADD HL,DE
;PEEK ;Line=1780
	LD A,[HL]
;PUSHNUM 's' ;Line=1780
;OPERATION == ;Line=1780
	SUB 's'
;JUMP IF FALSE eatcmd.DA. ;Line=1780
	JP NZ,eatcmd.DA.
;//else
;PUSHVAR _doskip ;Line=1781
	LD A,[_doskip]
;INV ;Line=1781
	CPL
;POPVAR _doskip ;Line=1781
	LD [_doskip],A
;JUMP eatcmd.DB. ;Line=1782
	JP eatcmd.DB.
eatcmd.DA.
;PUSHVAR _tword ;Line=1782
	LD HL,[_tword]
;PUSHNUM 2 ;Line=1782
;OPERATION +poi ;Line=1782
;PUSHCONST 2 ;Line=1782
	LD DE,2
	ADD HL,DE
;PEEK ;Line=1782
	LD A,[HL]
;PUSHNUM 'f' ;Line=1782
;OPERATION == ;Line=1782
	SUB 'f'
	SUB 1
	SBC A,A
;PUSHVAR _doskip ;Line=1782
	LD L,A
	LD A,[_doskip]
;INV ;Line=1782
	CPL
;OPERATION & ;Line=1782
	AND L
;JUMP IF FALSE eatcmd.DC. ;Line=1782
	JP Z,eatcmd.DC.
;//define
;CALL rdword ;Line=1783
	CALL rdword
;//имя
;accesspar=strcopy.A. ;Line=1784
;PUSHVAR _tword ;Line=1784
	LD HL,[_tword]
;POPVAR strcopy.A. ;Line=1784
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1784
;PUSHVAR _lentword ;Line=1784
	LD HL,[_lentword]
;POPVAR strcopy.B. ;Line=1784
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1784
;PUSHVAR _joined ;Line=1784
	LD HL,[_joined]
;POPVAR strcopy.C. ;Line=1784
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1784
	CALL strcopy
;POPVAR _lenjoined ;Line=1784
	LD [_lenjoined],HL
;CALL rdword ;Line=1785
	CALL rdword
;PUSHVAR _tword ;Line=1786
	LD HL,[_tword]
;OPERATION cast 21>21 ;Line=1786
;PEEK ;Line=1786
	LD A,[HL]
;PUSHNUM '(' ;Line=1786
;OPERATION == ;Line=1786
	SUB '('
;JUMP IF FALSE eatcmd.DE. ;Line=1786
	JP NZ,eatcmd.DE.
;//TODO эту конструкцию применить и в const
;CALL rdword ;Line=1787
	CALL rdword
;//eat('(');
;CALL eattype ;Line=1788
	CALL eattype
;//_t
;accesspar=eat.A. ;Line=1789
;PUSHNUM ')' ;Line=1789
;POPVAR eat.A. ;Line=1789
;PUSHCONST ')' ;Line=1789
	LD A,')'
	LD [eat.A.],A
;CALL eat ;Line=1789
	CALL eat
;//eat('(');
;accesspar=rdquotes.A. ;Line=1791
;PUSHNUM ')' ;Line=1791
;POPVAR rdquotes.A. ;Line=1791
;PUSHCONST ')' ;Line=1791
	LD A,')'
	LD [rdquotes.A.],A
;CALL rdquotes ;Line=1791
	CALL rdquotes
;CALL rdch ;Line=1792
	CALL rdch
;//добавляем закрывающую скобку
;PUSHVAR _tword ;Line=1793
	LD HL,[_tword]
;PUSHVAR _lentword ;Line=1793
	LD DE,[_lentword]
;OPERATION +poi ;Line=1793
	ADD HL,DE
;PUSHNUM '\0' ;Line=1793
;POKE ;Line=1793
;PUSHCONST '\0' ;Line=1793
	LD A,'\0'
	LD [HL],A
;//strclose(_tword, _lentword);
;JUMP eatcmd.DF. ;Line=1794
	JP eatcmd.DF.
eatcmd.DE.
;//rdword(); //значение
;CALL numtype ;Line=1796
	CALL numtype
;//_t
eatcmd.DF.
;accesspar=strcopy.A. ;Line=1798
;PUSHVAR _joined ;Line=1798
	LD HL,[_joined]
;POPVAR strcopy.A. ;Line=1798
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1798
;PUSHVAR _lenjoined ;Line=1798
	LD HL,[_lenjoined]
;POPVAR strcopy.B. ;Line=1798
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1798
;PUSHVAR _name ;Line=1798
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1798
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1798
	CALL strcopy
;POPVAR _lenname ;Line=1798
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1799
;PUSHVAR _t ;Line=1799
	LD A,[_t]
;PUSHNUM _T_CONST ;Line=1799
;OPERATION | ;Line=1799
;PUSHCONST _T_CONST ;Line=1799
	LD E,_T_CONST
	OR E
;POPVAR addlbl.A. ;Line=1799
	LD [addlbl.A.],A
;/**islocal*/
;accesspar=addlbl.B. ;Line=1799
;PUSHNUM FALSE ;Line=1799
;POPVAR addlbl.B. ;Line=1799
;PUSHCONST FALSE ;Line=1799
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1799
;PUSHNUM _typesz ;Line=1799
;PUSHVAR _t ;Line=1799
;PUSHCONST _typesz ;Line=1799
	LD HL,_typesz
	LD A,[_t]
;/**&_TYPEMASK*/
;OPERATION cast 0>1 ;Line=1799
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1799
	ADD HL,DE
;PEEK ;Line=1799
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1799
	LD L,A
	LD H,0
;/**, _ncells, _lenncells*/
;POPVAR addlbl.C. ;Line=1799
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1799
	CALL addlbl
;//(_name) //TODO размер массива или структуры!
;accesspar=varstr.A. ;Line=1800
;PUSHVAR _name ;Line=1800
	LD HL,[_name]
;/**_joined*/
;POPVAR varstr.A. ;Line=1800
	LD [varstr.A.],HL
;CALL varstr ;Line=1800
	CALL varstr
;accesspar=varc.A. ;Line=1800
;PUSHNUM '=' ;Line=1800
;POPVAR varc.A. ;Line=1800
;PUSHCONST '=' ;Line=1800
	LD A,'='
	LD [varc.A.],A
;CALL varc ;Line=1800
	CALL varc
;accesspar=varstr.A. ;Line=1800
;PUSHVAR _tword ;Line=1800
	LD HL,[_tword]
;POPVAR varstr.A. ;Line=1800
	LD [varstr.A.],HL
;CALL varstr ;Line=1800
	CALL varstr
;CALL endvar ;Line=1800
	CALL endvar
eatcmd.DC.
eatcmd.DB.
eatcmd.CX.
eatcmd.CP.
eatcmd.CN.
;//rdchcmt(); //rdaddword(); //используем первый символ знака комментария, читае
eatcmd.DG.
;PUSHVAR _waseols ;Line=1804
	LD HL,[_waseols]
;PUSHNUM 0 ;Line=1804
;/** && !_waseof*/
;OPERATION == ;Line=1804
;PUSHCONST 0 ;Line=1804
	LD DE,0
	OR A
	SBC HL,DE
;JUMP IF FALSE eatcmd.DH. ;Line=1804
	JP NZ,eatcmd.DH.
;CALL rdchcmt ;Line=1805
	CALL rdchcmt
;//пропускает все ентеры
;JUMP eatcmd.DG. ;Line=1806
	JP eatcmd.DG.
eatcmd.DH.
;PUSHVAR _tword ;Line=1807
	LD HL,[_tword]
;PUSHVAR _lentword ;Line=1807
	LD DE,[_lentword]
;OPERATION +poi ;Line=1807
	ADD HL,DE
;PUSHNUM '\0' ;Line=1807
;POKE ;Line=1807
;PUSHCONST '\0' ;Line=1807
	LD A,'\0'
	LD [HL],A
;//strclose(_tword, _lentword); //todo нарушена парность clear..close
;PUSHVAR _cnext ;Line=1808
	LD A,[_cnext]
;OPERATION cast 5>0 ;Line=1808
;PUSHNUM '!' ;Line=1808
;OPERATION cast 5>0 ;Line=1808
;OPERATION < ;Line=1808
;PUSHCONST '!' ;Line=1808
	LD E,'!'
	SUB E
;JUMP IF FALSE eatcmd.DI. ;Line=1808
	JP NC,eatcmd.DI.
;CALL rdch ;Line=1809
	CALL rdch
;//используем последний символ комментария, читаем следующий символ (TODO унифиц
eatcmd.DI.
;CALL rdword ;Line=1811
	CALL rdword
;JUMP eatcmd.CL. ;Line=1812
	JP eatcmd.CL.
eatcmd.CK.
;accesspar=errstr.A. ;Line=1813
;PUSHNUM eatcmd.DK. ;Line=1813
;POPVAR errstr.A. ;Line=1813
;PUSHCONST eatcmd.DK. ;Line=1813
	LD HL,eatcmd.DK.
	LD [errstr.A.],HL
;CALL errstr ;Line=1813
	CALL errstr
;accesspar=errstr.A. ;Line=1813
;PUSHVAR _tword ;Line=1813
	LD HL,[_tword]
;POPVAR errstr.A. ;Line=1813
	LD [errstr.A.],HL
;CALL errstr ;Line=1813
	CALL errstr
;CALL enderr ;Line=1813
	CALL enderr
;CALL rdword ;Line=1814
	CALL rdword
eatcmd.CL.
eatcmd.CJ.
eatcmd.CF.
eatcmd.CD.
eatcmd.CB.
eatcmd.BX.
eatcmd.BV.
eatcmd.BT.
eatcmd.BR.
eatcmd.BN.
eatcmd.BJ.
eatcmd.BH.
eatcmd.BB.
eatcmd.V.
eatcmd.T.
eatcmd.P.
eatcmd.N.
eatcmd.L.
eatcmd.J.
eatcmd.H.
eatcmd.F.
eatcmd.D.
;//not a headless cmd
;PUSHNUM TRUE ;Line=1818
;POPVAR _morecmd ;Line=1818
;PUSHCONST TRUE ;Line=1818
	LD A,TRUE
	LD [_morecmd],A
eatcmd.B.
;//not '{'
;PUSHVAR _morecmd ;Line=1820
	LD A,[_morecmd]
;RESULT ;Line=1820
;ENDFUNC ;Line=1824
	RET
compfile
;FUNC ;Line=1824
;accesspar=nfopen.A. ;Line=1826
;PUSHVAR compfile.fn ;Line=1826
	LD HL,[compfile.fn]
;POPVAR nfopen.A. ;Line=1826
	LD [nfopen.A.],HL
;accesspar=nfopen.B. ;Line=1826
;PUSHNUM compfile.B. ;Line=1826
;POPVAR nfopen.B. ;Line=1826
;PUSHCONST compfile.B. ;Line=1826
	LD HL,compfile.B.
	LD [nfopen.B.],HL
;CALL nfopen ;Line=1826
	CALL nfopen
;POPVAR _fin ;Line=1826
	LD [_fin],HL
;PUSHNUM FALSE ;Line=1827
;POPVAR _waseof ;Line=1827
;PUSHCONST FALSE ;Line=1827
	LD A,FALSE
	LD [_waseof],A
;PUSHNUM 1 ;Line=1829
;POPVAR _curline ;Line=1829
;PUSHCONST 1 ;Line=1829
	LD HL,1
	LD [_curline],HL
;CALL initrd ;Line=1830
	CALL initrd
;CALL rdword ;Line=1831
	CALL rdword
compfile.C.
;CALL eatcmd ;Line=1833
	CALL eatcmd
;JUMP IF FALSE compfile.D. ;Line=1833
	OR A
	JP Z,compfile.D.
;JUMP compfile.C. ;Line=1833
	JP compfile.C.
compfile.D.
;accesspar=fclose.A. ;Line=1835
;PUSHVAR _fin ;Line=1835
	LD HL,[_fin]
;POPVAR fclose.A. ;Line=1835
	LD [fclose.A.],HL
;CALL fclose ;Line=1835
	CALL fclose
;ENDFUNC ;Line=1838
	RET
zxc
;FUNC ;Line=1838
;ENDFUNC ;Line=1842
	RET
compile
;FUNC ;Line=1842
;PUSHNUM _s1 ;Line=1845
;POPVAR _prefix ;Line=1845
;PUSHCONST _s1 ;Line=1845
	LD HL,_s1
	LD [_prefix],HL
;//заполняется в doprefix: module/func/const/var/extern - локально, joinvarname
;PUSHNUM _s2 ;Line=1846
;OPERATION cast 21>21 ;Line=1846
;POPVAR _title ;Line=1846
;PUSHCONST _s2 ;Line=1846
	LD HL,_s2
	LD [_title],HL
;PUSHNUM _s3 ;Line=1847
;OPERATION cast 21>21 ;Line=1847
;POPVAR _callee ;Line=1847
;PUSHCONST _s3 ;Line=1847
	LD HL,_s3
	LD [_callee],HL
;PUSHNUM _s4 ;Line=1848
;OPERATION cast 21>21 ;Line=1848
;POPVAR _name ;Line=1848
;PUSHCONST _s4 ;Line=1848
	LD HL,_s4
	LD [_name],HL
;PUSHNUM _s5 ;Line=1849
;OPERATION cast 21>21 ;Line=1849
;POPVAR _joined ;Line=1849
;PUSHCONST _s5 ;Line=1849
	LD HL,_s5
	LD [_joined],HL
;PUSHNUM _s6 ;Line=1850
;OPERATION cast 21>21 ;Line=1850
;POPVAR _ncells ;Line=1850
;PUSHCONST _s6 ;Line=1850
	LD HL,_s6
	LD [_ncells],HL
;PUSHNUM 0 ;Line=1852
;POPVAR _tmpendlbl ;Line=1852
;PUSHCONST 0 ;Line=1852
	LD HL,0
	LD [_tmpendlbl],HL
;//чтобы никогда не совпало (break вне функции выдаст ошибку в асме)
;PUSHNUM 0 ;Line=1853
;POPVAR _lenstrstk ;Line=1853
;PUSHCONST 0 ;Line=1853
	LD HL,0
	LD [_lenstrstk],HL
;PUSHNUM 0 ;Line=1854
;POPVAR _curlbl ;Line=1854
;PUSHCONST 0 ;Line=1854
	LD HL,0
	LD [_curlbl],HL
;//сбрасываем нумерацию автометок (для массивов строк)
;CALL initlblbuf ;Line=1856
	CALL initlblbuf
;accesspar=strcopy.A. ;Line=1858
;PUSHNUM compile.B. ;Line=1858
;POPVAR strcopy.A. ;Line=1858
;PUSHCONST compile.B. ;Line=1858
	LD HL,compile.B.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1858
;PUSHNUM 3 ;Line=1858
;POPVAR strcopy.B. ;Line=1858
;PUSHCONST 3 ;Line=1858
	LD HL,3
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1858
;PUSHVAR _name ;Line=1858
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1858
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1858
	CALL strcopy
;POPVAR _lenname ;Line=1858
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1859
;PUSHNUM _T_TYPE ;Line=1859
;PUSHNUM _T_INT ;Line=1859
;PUSHCONST _T_TYPE ;Line=1859
	LD A,_T_TYPE
;OPERATION + ;Line=1859
	ADD A,_T_INT
;POPVAR addlbl.A. ;Line=1859
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1859
;PUSHNUM FALSE ;Line=1859
;POPVAR addlbl.B. ;Line=1859
;PUSHCONST FALSE ;Line=1859
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1859
;PUSHNUM _typesz ;Line=1859
;PUSHNUM _T_INT ;Line=1859
;PUSHCONST _typesz ;Line=1859
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1859
;PUSHCONST _T_INT ;Line=1859
	LD A,_T_INT
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1859
	ADD HL,DE
;PEEK ;Line=1859
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1859
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1859
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1859
	CALL addlbl
;accesspar=strcopy.A. ;Line=1860
;PUSHNUM compile.C. ;Line=1860
;POPVAR strcopy.A. ;Line=1860
;PUSHCONST compile.C. ;Line=1860
	LD HL,compile.C.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1860
;PUSHNUM 4 ;Line=1860
;POPVAR strcopy.B. ;Line=1860
;PUSHCONST 4 ;Line=1860
	LD HL,4
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1860
;PUSHVAR _name ;Line=1860
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1860
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1860
	CALL strcopy
;POPVAR _lenname ;Line=1860
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1861
;PUSHNUM _T_TYPE ;Line=1861
;PUSHNUM _T_UINT ;Line=1861
;PUSHCONST _T_TYPE ;Line=1861
	LD A,_T_TYPE
;OPERATION + ;Line=1861
	ADD A,_T_UINT
;POPVAR addlbl.A. ;Line=1861
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1861
;PUSHNUM FALSE ;Line=1861
;POPVAR addlbl.B. ;Line=1861
;PUSHCONST FALSE ;Line=1861
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1861
;PUSHNUM _typesz ;Line=1861
;PUSHNUM _T_UINT ;Line=1861
;PUSHCONST _typesz ;Line=1861
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1861
;PUSHCONST _T_UINT ;Line=1861
	LD A,_T_UINT
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1861
	ADD HL,DE
;PEEK ;Line=1861
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1861
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1861
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1861
	CALL addlbl
;accesspar=strcopy.A. ;Line=1862
;PUSHNUM compile.D. ;Line=1862
;POPVAR strcopy.A. ;Line=1862
;PUSHCONST compile.D. ;Line=1862
	LD HL,compile.D.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1862
;PUSHNUM 4 ;Line=1862
;POPVAR strcopy.B. ;Line=1862
;PUSHCONST 4 ;Line=1862
	LD HL,4
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1862
;PUSHVAR _name ;Line=1862
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1862
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1862
	CALL strcopy
;POPVAR _lenname ;Line=1862
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1863
;PUSHNUM _T_TYPE ;Line=1863
;PUSHNUM _T_BYTE ;Line=1863
;PUSHCONST _T_TYPE ;Line=1863
	LD A,_T_TYPE
;OPERATION + ;Line=1863
	ADD A,_T_BYTE
;POPVAR addlbl.A. ;Line=1863
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1863
;PUSHNUM FALSE ;Line=1863
;POPVAR addlbl.B. ;Line=1863
;PUSHCONST FALSE ;Line=1863
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1863
;PUSHNUM _typesz ;Line=1863
;PUSHNUM _T_BYTE ;Line=1863
;PUSHCONST _typesz ;Line=1863
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1863
;PUSHCONST _T_BYTE ;Line=1863
	LD A,_T_BYTE
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1863
	ADD HL,DE
;PEEK ;Line=1863
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1863
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1863
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1863
	CALL addlbl
;accesspar=strcopy.A. ;Line=1864
;PUSHNUM compile.E. ;Line=1864
;POPVAR strcopy.A. ;Line=1864
;PUSHCONST compile.E. ;Line=1864
	LD HL,compile.E.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1864
;PUSHNUM 4 ;Line=1864
;POPVAR strcopy.B. ;Line=1864
;PUSHCONST 4 ;Line=1864
	LD HL,4
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1864
;PUSHVAR _name ;Line=1864
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1864
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1864
	CALL strcopy
;POPVAR _lenname ;Line=1864
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1865
;PUSHNUM _T_TYPE ;Line=1865
;PUSHNUM _T_BOOL ;Line=1865
;PUSHCONST _T_TYPE ;Line=1865
	LD A,_T_TYPE
;OPERATION + ;Line=1865
	ADD A,_T_BOOL
;POPVAR addlbl.A. ;Line=1865
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1865
;PUSHNUM FALSE ;Line=1865
;POPVAR addlbl.B. ;Line=1865
;PUSHCONST FALSE ;Line=1865
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1865
;PUSHNUM _typesz ;Line=1865
;PUSHNUM _T_BOOL ;Line=1865
;PUSHCONST _typesz ;Line=1865
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1865
;PUSHCONST _T_BOOL ;Line=1865
	LD A,_T_BOOL
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1865
	ADD HL,DE
;PEEK ;Line=1865
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1865
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1865
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1865
	CALL addlbl
;accesspar=strcopy.A. ;Line=1866
;PUSHNUM compile.F. ;Line=1866
;POPVAR strcopy.A. ;Line=1866
;PUSHCONST compile.F. ;Line=1866
	LD HL,compile.F.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1866
;PUSHNUM 4 ;Line=1866
;POPVAR strcopy.B. ;Line=1866
;PUSHCONST 4 ;Line=1866
	LD HL,4
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1866
;PUSHVAR _name ;Line=1866
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1866
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1866
	CALL strcopy
;POPVAR _lenname ;Line=1866
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1867
;PUSHNUM _T_TYPE ;Line=1867
;PUSHNUM _T_LONG ;Line=1867
;PUSHCONST _T_TYPE ;Line=1867
	LD A,_T_TYPE
;OPERATION + ;Line=1867
	ADD A,_T_LONG
;POPVAR addlbl.A. ;Line=1867
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1867
;PUSHNUM FALSE ;Line=1867
;POPVAR addlbl.B. ;Line=1867
;PUSHCONST FALSE ;Line=1867
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1867
;PUSHNUM _typesz ;Line=1867
;PUSHNUM _T_LONG ;Line=1867
;PUSHCONST _typesz ;Line=1867
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1867
;PUSHCONST _T_LONG ;Line=1867
	LD A,_T_LONG
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1867
	ADD HL,DE
;PEEK ;Line=1867
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1867
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1867
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1867
	CALL addlbl
;accesspar=strcopy.A. ;Line=1868
;PUSHNUM compile.G. ;Line=1868
;POPVAR strcopy.A. ;Line=1868
;PUSHCONST compile.G. ;Line=1868
	LD HL,compile.G.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1868
;PUSHNUM 4 ;Line=1868
;POPVAR strcopy.B. ;Line=1868
;PUSHCONST 4 ;Line=1868
	LD HL,4
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1868
;PUSHVAR _name ;Line=1868
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1868
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1868
	CALL strcopy
;POPVAR _lenname ;Line=1868
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1869
;PUSHNUM _T_TYPE ;Line=1869
;PUSHNUM _T_CHAR ;Line=1869
;PUSHCONST _T_TYPE ;Line=1869
	LD A,_T_TYPE
;OPERATION + ;Line=1869
	ADD A,_T_CHAR
;POPVAR addlbl.A. ;Line=1869
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1869
;PUSHNUM FALSE ;Line=1869
;POPVAR addlbl.B. ;Line=1869
;PUSHCONST FALSE ;Line=1869
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1869
;PUSHNUM _typesz ;Line=1869
;PUSHNUM _T_CHAR ;Line=1869
;PUSHCONST _typesz ;Line=1869
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1869
;PUSHCONST _T_CHAR ;Line=1869
	LD A,_T_CHAR
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1869
	ADD HL,DE
;PEEK ;Line=1869
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1869
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1869
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1869
	CALL addlbl
;//_lenname = strcopy("FLOAT", 5, _name);
;//addlbl(_T_TYPE + _T_FLOAT, +FALSE, (UINT)_typesz[_T_FLOAT]);
;accesspar=strcopy.A. ;Line=1872
;PUSHNUM compile.H. ;Line=1872
;POPVAR strcopy.A. ;Line=1872
;PUSHCONST compile.H. ;Line=1872
	LD HL,compile.H.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1872
;PUSHNUM 4 ;Line=1872
;POPVAR strcopy.B. ;Line=1872
;PUSHCONST 4 ;Line=1872
	LD HL,4
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1872
;PUSHVAR _name ;Line=1872
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1872
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1872
	CALL strcopy
;POPVAR _lenname ;Line=1872
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1873
;PUSHNUM _T_TYPE ;Line=1873
;PUSHNUM _T_POI ;Line=1873
;PUSHCONST _T_TYPE ;Line=1873
	LD A,_T_TYPE
;OPERATION + ;Line=1873
	ADD A,_T_POI
;PUSHNUM _T_INT ;Line=1873
;OPERATION + ;Line=1873
	ADD A,_T_INT
;POPVAR addlbl.A. ;Line=1873
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1873
;PUSHNUM FALSE ;Line=1873
;POPVAR addlbl.B. ;Line=1873
;PUSHCONST FALSE ;Line=1873
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1873
;PUSHNUM _typesz ;Line=1873
;PUSHNUM _T_POI ;Line=1873
;PUSHCONST _typesz ;Line=1873
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1873
;PUSHCONST _T_POI ;Line=1873
	LD A,_T_POI
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1873
	ADD HL,DE
;PEEK ;Line=1873
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1873
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1873
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1873
	CALL addlbl
;accesspar=strcopy.A. ;Line=1874
;PUSHNUM compile.I. ;Line=1874
;POPVAR strcopy.A. ;Line=1874
;PUSHCONST compile.I. ;Line=1874
	LD HL,compile.I.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1874
;PUSHNUM 5 ;Line=1874
;POPVAR strcopy.B. ;Line=1874
;PUSHCONST 5 ;Line=1874
	LD HL,5
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1874
;PUSHVAR _name ;Line=1874
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1874
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1874
	CALL strcopy
;POPVAR _lenname ;Line=1874
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1875
;PUSHNUM _T_TYPE ;Line=1875
;PUSHNUM _T_POI ;Line=1875
;PUSHCONST _T_TYPE ;Line=1875
	LD A,_T_TYPE
;OPERATION + ;Line=1875
	ADD A,_T_POI
;PUSHNUM _T_UINT ;Line=1875
;OPERATION + ;Line=1875
	ADD A,_T_UINT
;POPVAR addlbl.A. ;Line=1875
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1875
;PUSHNUM FALSE ;Line=1875
;POPVAR addlbl.B. ;Line=1875
;PUSHCONST FALSE ;Line=1875
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1875
;PUSHNUM _typesz ;Line=1875
;PUSHNUM _T_POI ;Line=1875
;PUSHCONST _typesz ;Line=1875
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1875
;PUSHCONST _T_POI ;Line=1875
	LD A,_T_POI
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1875
	ADD HL,DE
;PEEK ;Line=1875
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1875
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1875
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1875
	CALL addlbl
;accesspar=strcopy.A. ;Line=1876
;PUSHNUM compile.J. ;Line=1876
;POPVAR strcopy.A. ;Line=1876
;PUSHCONST compile.J. ;Line=1876
	LD HL,compile.J.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1876
;PUSHNUM 5 ;Line=1876
;POPVAR strcopy.B. ;Line=1876
;PUSHCONST 5 ;Line=1876
	LD HL,5
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1876
;PUSHVAR _name ;Line=1876
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1876
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1876
	CALL strcopy
;POPVAR _lenname ;Line=1876
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1877
;PUSHNUM _T_TYPE ;Line=1877
;PUSHNUM _T_POI ;Line=1877
;PUSHCONST _T_TYPE ;Line=1877
	LD A,_T_TYPE
;OPERATION + ;Line=1877
	ADD A,_T_POI
;PUSHNUM _T_BYTE ;Line=1877
;OPERATION + ;Line=1877
	ADD A,_T_BYTE
;POPVAR addlbl.A. ;Line=1877
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1877
;PUSHNUM FALSE ;Line=1877
;POPVAR addlbl.B. ;Line=1877
;PUSHCONST FALSE ;Line=1877
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1877
;PUSHNUM _typesz ;Line=1877
;PUSHNUM _T_POI ;Line=1877
;PUSHCONST _typesz ;Line=1877
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1877
;PUSHCONST _T_POI ;Line=1877
	LD A,_T_POI
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1877
	ADD HL,DE
;PEEK ;Line=1877
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1877
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1877
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1877
	CALL addlbl
;accesspar=strcopy.A. ;Line=1878
;PUSHNUM compile.K. ;Line=1878
;POPVAR strcopy.A. ;Line=1878
;PUSHCONST compile.K. ;Line=1878
	LD HL,compile.K.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1878
;PUSHNUM 5 ;Line=1878
;POPVAR strcopy.B. ;Line=1878
;PUSHCONST 5 ;Line=1878
	LD HL,5
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1878
;PUSHVAR _name ;Line=1878
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1878
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1878
	CALL strcopy
;POPVAR _lenname ;Line=1878
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1879
;PUSHNUM _T_TYPE ;Line=1879
;PUSHNUM _T_POI ;Line=1879
;PUSHCONST _T_TYPE ;Line=1879
	LD A,_T_TYPE
;OPERATION + ;Line=1879
	ADD A,_T_POI
;PUSHNUM _T_BOOL ;Line=1879
;OPERATION + ;Line=1879
	ADD A,_T_BOOL
;POPVAR addlbl.A. ;Line=1879
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1879
;PUSHNUM FALSE ;Line=1879
;POPVAR addlbl.B. ;Line=1879
;PUSHCONST FALSE ;Line=1879
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1879
;PUSHNUM _typesz ;Line=1879
;PUSHNUM _T_POI ;Line=1879
;PUSHCONST _typesz ;Line=1879
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1879
;PUSHCONST _T_POI ;Line=1879
	LD A,_T_POI
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1879
	ADD HL,DE
;PEEK ;Line=1879
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1879
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1879
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1879
	CALL addlbl
;accesspar=strcopy.A. ;Line=1880
;PUSHNUM compile.L. ;Line=1880
;POPVAR strcopy.A. ;Line=1880
;PUSHCONST compile.L. ;Line=1880
	LD HL,compile.L.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1880
;PUSHNUM 5 ;Line=1880
;POPVAR strcopy.B. ;Line=1880
;PUSHCONST 5 ;Line=1880
	LD HL,5
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1880
;PUSHVAR _name ;Line=1880
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1880
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1880
	CALL strcopy
;POPVAR _lenname ;Line=1880
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1881
;PUSHNUM _T_TYPE ;Line=1881
;PUSHNUM _T_POI ;Line=1881
;PUSHCONST _T_TYPE ;Line=1881
	LD A,_T_TYPE
;OPERATION + ;Line=1881
	ADD A,_T_POI
;PUSHNUM _T_LONG ;Line=1881
;OPERATION + ;Line=1881
	ADD A,_T_LONG
;POPVAR addlbl.A. ;Line=1881
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1881
;PUSHNUM FALSE ;Line=1881
;POPVAR addlbl.B. ;Line=1881
;PUSHCONST FALSE ;Line=1881
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1881
;PUSHNUM _typesz ;Line=1881
;PUSHNUM _T_POI ;Line=1881
;PUSHCONST _typesz ;Line=1881
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1881
;PUSHCONST _T_POI ;Line=1881
	LD A,_T_POI
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1881
	ADD HL,DE
;PEEK ;Line=1881
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1881
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1881
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1881
	CALL addlbl
;accesspar=strcopy.A. ;Line=1882
;PUSHNUM compile.M. ;Line=1882
;POPVAR strcopy.A. ;Line=1882
;PUSHCONST compile.M. ;Line=1882
	LD HL,compile.M.
	LD [strcopy.A.],HL
;accesspar=strcopy.B. ;Line=1882
;PUSHNUM 5 ;Line=1882
;POPVAR strcopy.B. ;Line=1882
;PUSHCONST 5 ;Line=1882
	LD HL,5
	LD [strcopy.B.],HL
;accesspar=strcopy.C. ;Line=1882
;PUSHVAR _name ;Line=1882
	LD HL,[_name]
;POPVAR strcopy.C. ;Line=1882
	LD [strcopy.C.],HL
;CALL strcopy ;Line=1882
	CALL strcopy
;POPVAR _lenname ;Line=1882
	LD [_lenname],HL
;accesspar=addlbl.A. ;Line=1883
;PUSHNUM _T_TYPE ;Line=1883
;PUSHNUM _T_POI ;Line=1883
;PUSHCONST _T_TYPE ;Line=1883
	LD A,_T_TYPE
;OPERATION + ;Line=1883
	ADD A,_T_POI
;PUSHNUM _T_CHAR ;Line=1883
;OPERATION + ;Line=1883
	ADD A,_T_CHAR
;POPVAR addlbl.A. ;Line=1883
	LD [addlbl.A.],A
;accesspar=addlbl.B. ;Line=1883
;PUSHNUM FALSE ;Line=1883
;POPVAR addlbl.B. ;Line=1883
;PUSHCONST FALSE ;Line=1883
	LD A,FALSE
	LD [addlbl.B.],A
;accesspar=addlbl.C. ;Line=1883
;PUSHNUM _typesz ;Line=1883
;PUSHNUM _T_POI ;Line=1883
;PUSHCONST _typesz ;Line=1883
	LD HL,_typesz
;OPERATION cast 0>1 ;Line=1883
;PUSHCONST _T_POI ;Line=1883
	LD A,_T_POI
	LD E,A
	LD D,0
;OPERATION +poi ;Line=1883
	ADD HL,DE
;PEEK ;Line=1883
	LD A,[HL]
;OPERATION cast 0>1 ;Line=1883
	LD L,A
	LD H,0
;POPVAR addlbl.C. ;Line=1883
	LD [addlbl.C.],HL
;CALL addlbl ;Line=1883
	CALL addlbl
;//_lenname = strcopy("PFLOAT", 5, _name);
;//addlbl(_T_TYPE + _T_POI + _T_FLOAT, +FALSE, (UINT)_typesz[_T_POI]);
;//  _lenname = strcopy("POINTER", 7, _name);
;//  addlbl(_T_TYPE + _T_POI, +FALSE);
;//_lenname = strcopy("PPROC", 5, _name);
;//addlbl(_T_TYPE + _T_POI + _T_PROC, +FALSE, (UINT)_typesz[_T_POI]);
;PUSHNUM 0 ;Line=1891
;/**strclear(_title)*/
;POPVAR _lentitle ;Line=1891
;PUSHCONST 0 ;Line=1891
	LD HL,0
	LD [_lentitle],HL
;PUSHVAR _title ;Line=1892
	LD HL,[_title]
;OPERATION cast 21>21 ;Line=1892
;PUSHNUM '\0' ;Line=1892
;POKE ;Line=1892
;PUSHCONST '\0' ;Line=1892
	LD A,'\0'
	LD [HL],A
;//strclose(_title, _lentitle);
;PUSHNUM 0x00 ;Line=1893
;POPVAR _namespclvl ;Line=1893
;PUSHCONST 0x00 ;Line=1893
	LD A,0x00
	LD [_namespclvl],A
;//_exprlvl = 0x00; //сейчас везде расставлено 0 (можно оптимизировать сравнения
;CALL initcmd ;Line=1896
	CALL initcmd
;CALL initcode ;Line=1897
	CALL initcode
;//вызывает emitregs
;PUSHNUM FALSE ;Line=1899
;POPVAR _isexp ;Line=1899
;PUSHCONST FALSE ;Line=1899
	LD A,FALSE
	LD [_isexp],A
;PUSHNUM _T_UNKNOWN ;Line=1900
;POPVAR _curfunct ;Line=1900
;PUSHCONST _T_UNKNOWN ;Line=1900
	LD A,_T_UNKNOWN
	LD [_curfunct],A
;//на всякий случай
;PUSHNUM FALSE ;Line=1901
;POPVAR _wasreturn ;Line=1901
;PUSHCONST FALSE ;Line=1901
	LD A,FALSE
	LD [_wasreturn],A
;//сбросить проверку "оператор после return"
;accesspar=strjoineol.A. ;Line=1903
;PUSHVAR _joined ;Line=1903
	LD HL,[_joined]
;POPVAR strjoineol.A. ;Line=1903
	LD [strjoineol.A.],HL
;accesspar=strjoineol.B. ;Line=1903
;PUSHNUM 0 ;Line=1903
;POPVAR strjoineol.B. ;Line=1903
;PUSHCONST 0 ;Line=1903
	LD HL,0
	LD [strjoineol.B.],HL
;accesspar=strjoineol.C. ;Line=1903
;PUSHVAR compile.fn ;Line=1903
	LD HL,[compile.fn]
;POPVAR strjoineol.C. ;Line=1903
	LD [strjoineol.C.],HL
;accesspar=strjoineol.D. ;Line=1903
;PUSHNUM '.' ;Line=1903
;POPVAR strjoineol.D. ;Line=1903
;PUSHCONST '.' ;Line=1903
	LD A,'.'
	LD [strjoineol.D.],A
;CALL strjoineol ;Line=1903
	CALL strjoineol
;POPVAR _lenjoined ;Line=1903
	LD [_lenjoined],HL
;accesspar=strjoin.A. ;Line=1904
;PUSHVAR _joined ;Line=1904
	LD HL,[_joined]
;POPVAR strjoin.A. ;Line=1904
	LD [strjoin.A.],HL
;accesspar=strjoin.B. ;Line=1904
;PUSHVAR _lenjoined ;Line=1904
	LD HL,[_lenjoined]
;POPVAR strjoin.B. ;Line=1904
	LD [strjoin.B.],HL
;accesspar=strjoin.C. ;Line=1904
;PUSHNUM compile.N. ;Line=1904
;POPVAR strjoin.C. ;Line=1904
;PUSHCONST compile.N. ;Line=1904
	LD HL,compile.N.
	LD [strjoin.C.],HL
;CALL strjoin ;Line=1904
	CALL strjoin
;POPVAR _lenjoined ;Line=1904
	LD [_lenjoined],HL
;PUSHVAR _joined ;Line=1905
	LD HL,[_joined]
;PUSHVAR _lenjoined ;Line=1905
	LD DE,[_lenjoined]
;OPERATION +poi ;Line=1905
	ADD HL,DE
;PUSHNUM '\0' ;Line=1905
;POKE ;Line=1905
;PUSHCONST '\0' ;Line=1905
	LD A,'\0'
	LD [HL],A
;//strclose(_joined, _lenjoined);
;accesspar=openwrite.A. ;Line=1906
;PUSHVAR _joined ;Line=1906
	LD HL,[_joined]
;POPVAR openwrite.A. ;Line=1906
	LD [openwrite.A.],HL
;CALL openwrite ;Line=1906
	CALL openwrite
;POPVAR _fout ;Line=1906
	LD [_fout],HL
;accesspar=strjoineol.A. ;Line=1908
;PUSHVAR _joined ;Line=1908
	LD HL,[_joined]
;POPVAR strjoineol.A. ;Line=1908
	LD [strjoineol.A.],HL
;accesspar=strjoineol.B. ;Line=1908
;PUSHNUM 0 ;Line=1908
;POPVAR strjoineol.B. ;Line=1908
;PUSHCONST 0 ;Line=1908
	LD HL,0
	LD [strjoineol.B.],HL
;accesspar=strjoineol.C. ;Line=1908
;PUSHVAR compile.fn ;Line=1908
	LD HL,[compile.fn]
;POPVAR strjoineol.C. ;Line=1908
	LD [strjoineol.C.],HL
;accesspar=strjoineol.D. ;Line=1908
;PUSHNUM '.' ;Line=1908
;POPVAR strjoineol.D. ;Line=1908
;PUSHCONST '.' ;Line=1908
	LD A,'.'
	LD [strjoineol.D.],A
;CALL strjoineol ;Line=1908
	CALL strjoineol
;POPVAR _lenjoined ;Line=1908
	LD [_lenjoined],HL
;accesspar=strjoin.A. ;Line=1909
;PUSHVAR _joined ;Line=1909
	LD HL,[_joined]
;POPVAR strjoin.A. ;Line=1909
	LD [strjoin.A.],HL
;accesspar=strjoin.B. ;Line=1909
;PUSHVAR _lenjoined ;Line=1909
	LD HL,[_lenjoined]
;POPVAR strjoin.B. ;Line=1909
	LD [strjoin.B.],HL
;accesspar=strjoin.C. ;Line=1909
;PUSHNUM compile.O. ;Line=1909
;POPVAR strjoin.C. ;Line=1909
;PUSHCONST compile.O. ;Line=1909
	LD HL,compile.O.
	LD [strjoin.C.],HL
;CALL strjoin ;Line=1909
	CALL strjoin
;POPVAR _lenjoined ;Line=1909
	LD [_lenjoined],HL
;PUSHVAR _joined ;Line=1910
	LD HL,[_joined]
;PUSHVAR _lenjoined ;Line=1910
	LD DE,[_lenjoined]
;OPERATION +poi ;Line=1910
	ADD HL,DE
;PUSHNUM '\0' ;Line=1910
;POKE ;Line=1910
;PUSHCONST '\0' ;Line=1910
	LD A,'\0'
	LD [HL],A
;//strclose(_joined, _lenjoined);
;accesspar=openwrite.A. ;Line=1911
;PUSHVAR _joined ;Line=1911
	LD HL,[_joined]
;POPVAR openwrite.A. ;Line=1911
	LD [openwrite.A.],HL
;CALL openwrite ;Line=1911
	CALL openwrite
;POPVAR _fvar ;Line=1911
	LD [_fvar],HL
;PUSHNUM 0x00 ;Line=1913
;POPVAR _nhinclfiles ;Line=1913
;PUSHCONST 0x00 ;Line=1913
	LD A,0x00
	LD [_nhinclfiles],A
;accesspar=compfile.A. ;Line=1915
;PUSHPAR compfile.A. ;Line=1915
	LD HL,[compfile.A.]
;PUSHVAR compile.fn ;Line=1915
	LD DE,[compile.fn]
;POPVAR compfile.A. ;Line=1915
	LD [compfile.A.],DE
;CALL compfile ;Line=1915
	PUSH HL
	CALL compfile
;POPPAR ;Line=1915
	POP HL
	LD [compfile.A.],HL
;accesspar=fclose.A. ;Line=1917
;PUSHVAR _fvar ;Line=1917
	LD HL,[_fvar]
;POPVAR fclose.A. ;Line=1917
	LD [fclose.A.],HL
;CALL fclose ;Line=1917
	CALL fclose
;accesspar=fclose.A. ;Line=1918
;PUSHVAR _fout ;Line=1918
	LD HL,[_fout]
;POPVAR fclose.A. ;Line=1918
	LD [fclose.A.],HL
;CALL fclose ;Line=1918
	CALL fclose
;ENDFUNC ;Line=1921
	RET
