/// imported
#include "../_sdk/typecode.h"
#include "../_sdk/str.h"
#include "../_sdk/io.h"
#include "../_sdk/emit.h"

CONST BYTE _typesz[32];

#ifdef TARGET_THUMB
#include "sizesarm.h"
#else
#ifdef TARGET_SCRIPT
#include "sizesspt.h"
#else
#ifdef TARGET_386
#include "sizes386.h"
#else
#include "sizesz80.h"
#endif
#endif
#endif

CONST BOOL _isalphanum[256];

EXTERN BOOL _doskip; //пропускать строки, кроме начинающихся с #

EXTERN PCHAR _tword; //текущее слово
EXTERN UINT  _lentword;
VAR PCHAR _prefix; //префикс текущего слова (остаток - в _tword)
VAR UINT  _lenprefix;
VAR PCHAR _title; //название текущей процедуры (с учётом модуля)
VAR UINT  _lentitle;
EXTERN PCHAR _callee; //название вызываемой процедуры (с учётом модуля)
EXTERN UINT  _lencallee;
EXTERN PCHAR _callee2; //название вызываемой процедуры - отложенное
EXTERN UINT  _lencallee2;
EXTERN PCHAR _name; //метка без префикса (для таблицы меток)
EXTERN UINT  _lenname;
EXTERN PCHAR _joined; //автометка
EXTERN UINT  _lenjoined;
VAR PCHAR _ncells; //в addlbl нельзя объединить ncells с callee //там же временно прошлая метка для enum
VAR UINT  _lenncells;
VAR CHAR  _s1[_STRLEN]; //префикс текущего слова (остаток - в _tword)
VAR CHAR  _s2[_STRLEN]; //название текущей процедуры (с учётом модуля)
VAR CHAR  _s3[_STRLEN]; //название вызываемой процедуры (с учётом модуля)
VAR CHAR  _s4[_STRLEN]; //метка без префикса (для таблицы меток)
VAR CHAR  _s5[_STRLEN]; //автометка
VAR CHAR  _s6[_STRLEN]; //число элементов
VAR CHAR  _s7[_STRLEN]; //название вызываемой процедуры - отложенное

EXTERN CHAR _cnext;
EXTERN UINT _spcsize; //число пробелов после прочитанной команды

EXTERN UINT _curline; //текущий номер строки

EXTERN UINT _waseols; //сколько было EOL с прошлого раза

EXTERN UINT _typeaddr;

PROC rdch FORWARD();
PROC rdchcmt FORWARD();
PROC rdquotes FORWARD(CHAR eol);
PROC rdaddword FORWARD();
PROC rdword FORWARD();
PROC initrd FORWARD();

PROC strpush FORWARD(PCHAR s, UINT len); //joined или callee
FUNC UINT strpop FORWARD(PCHAR s);
EXTERN UINT _lenstrstk;

PROC initlblbuf FORWARD();

//math (без машинного кода)
PROC cmdneg FORWARD();
PROC cmdinv FORWARD();
PROC cmdpoke FORWARD();
PROC cmdpeek FORWARD();
PROC cmdpushvar FORWARD();
PROC cmdpopvar FORWARD();
PROC cmdpushnum FORWARD();
PROC cmdmul FORWARD();
PROC cmddiv FORWARD();
PROC cmdshl FORWARD();
PROC cmdshr FORWARD();
PROC cmdadd FORWARD();
PROC cmdsub FORWARD();
PROC cmdaddpoi FORWARD(); //сдвигает соответственно типу и прибавляет
PROC cmdand FORWARD();
PROC cmdor FORWARD();
PROC cmdxor FORWARD();
PROC cmdinc FORWARD();
PROC cmddec FORWARD();
PROC cmdincbyaddr FORWARD();
PROC cmddecbyaddr FORWARD();

//сравнения (без машинного кода)
PROC cmdless FORWARD();
PROC cmdmore FORWARD();
PROC cmdlesseq FORWARD();
PROC cmdmoreeq FORWARD();
PROC cmdeq FORWARD();
PROC cmdnoteq FORWARD();

//генерация вызовов и переходов (без машинного кода)
PROC cmdjpval FORWARD();
PROC cmdcallval FORWARD();
PROC cmdjp FORWARD();
PROC cmdjpiffalse FORWARD();
PROC cmdcall FORWARD();
PROC cmdfunc FORWARD();
PROC cmdpushpar FORWARD(); //для рекурсивных процедур (сохранение параметров внутри или снаружи)
PROC cmdstorergs FORWARD(); //после сохранения локальной переменной рекурсивной процедуры
PROC cmdpoppar FORWARD(); //для рекурсивных процедур (восстановление параметров внутри или снаружи)
PROC cmdresult FORWARD();
PROC cmdret FORWARD(BOOL isfunc); //восстановление результата после снятия локалов со стека и выход

PROC cmdcastto FORWARD(TYPE t2);
PROC cmdlabel FORWARD();
PROC var_alignwsz_label FORWARD(TYPE t);
PROC var_def FORWARD(TYPE t, PCHAR s);

PROC initcmd FORWARD();

PROC initcode FORWARD();
PROC endcode FORWARD();
PROC emitasmlabel FORWARD(PCHAR s);
PROC emitfunclabel FORWARD(PCHAR s);
PROC emitvarlabel FORWARD(PCHAR s);
PROC emitexport FORWARD(PCHAR s);
PROC emitvarpreequ FORWARD(PCHAR s);
PROC emitvarpostequ FORWARD();
PROC varequ FORWARD(PCHAR s);
PROC asm_db FORWARD(); //костыль для константных массивов строк TODO
PROC var_db FORWARD();
PROC var_dw FORWARD();
PROC var_ds FORWARD();
FUNC UINT varshift FORWARD(UINT shift, UINT sz);

FUNC UINT gettypename FORWARD(PCHAR s); //взять название типа структуры в s (сразу после lbltype)
PROC setvarsz FORWARD(UINT addr, UINT shift);
FUNC TYPE lbltype FORWARD(); //вернуть тип метки _name
PROC dellbl FORWARD(); //удалить метку _name
PROC addlbl FORWARD(TYPE t, BOOL isloc, UINT varsz/**, PCHAR size, UINT lensize*/); //(_name)
PROC keepvars FORWARD(); //перед началом локальных меток
PROC undovars FORWARD(); //после локальных меток (забыть их)
EXTERN UINT _varszaddr;
EXTERN UINT _varsz;

EXTERN BYTE _exprlvl; //глубина выражения (верхний уровень == 1)
EXTERN TYPE _t; //текущий тип
EXTERN BOOL _isloc; //локальная ли прочитанная переменная

////
CONST UINT _MAXPARS = 16; /**максимальное число параметров в вызове функции*/
//todo ограничить глубину рекурсии f(g(h(...()...)

//состояние компилятора (плюс ещё состояния commands и codetg):
VAR UINT _curlbl; //номер автометки в функции
VAR UINT _jplbl; //номер автометки переходов (без префикса)
VAR UINT _tmpendlbl; //номер автометки для выхода из цикла while/repeat

VAR BYTE _namespclvl; //глубина вложенности пространства имён (число точек в префиксе)

VAR BOOL _isrecursive; //текущая объявляемая процедура рекурсивная
VAR BOOL _wasreturn; //была команда return (после неё нельзя команды в рекурсивной функции) //сохраняются в func
VAR BOOL _waswasreturn; //была команда return до }
VAR TYPE _curfunct; //тип функции (для return) //сохраняются в func
VAR BOOL _isexp; //текущая объявляемая переменная, константный массив/структура, процедура/функция экспортируется (но не константа, т.к. это не адрес и не нужно)

VAR CHAR _c0;
VAR CHAR _c2;

VAR UINT _parnum;
VAR BYTE _pushlvl;

VAR UINT _doskipcond;
//_doskipcond в битовом виде помнит, сколько уровней активных ifdef и сколько уровней неактивных (кроме текущего)
//(внутри неактивного могут быть только неактивные)
//если (_doskipcond&1) == 0 (т.е. мы в неактивной ветке), то текущий ifdef игнорируется со всеми входящими (т.е. else не работает)
//неактивность текущей ветки ifdef лежит в _doskip
//на верхнем уровне _doskipcond = 1, _doskip = +FALSE

VAR BOOL _morecmd; //флаг "блок не окончен" в eatcmd

VAR CHAR _opsym;

VAR BOOL _addrexpr; //выражение с & для &(<structname>-><field>) (TODO вложенно?)

#define _MAXHINCLUDES 0x08
VAR PBYTE _hinclfile[_MAXHINCLUDES];
VAR UINT _hnline[_MAXHINCLUDES];
VAR BYTE _nhinclfiles; //число открытых файлов
//

#ifdef USE_HINTS
;;PROC hint_tword() {
;;  hintstr("//_tword=\""); hintstr(_tword); hintstr("\", cnext=\""); hint(_cnext); hint('\"'); endhint();
;;}
#endif

PROC err_type_enderr(UINT t)
{
  errstr(" type="); erruint(t); errstr(", but expr type="); erruint((UINT)_t); enderr();
}

PROC err_tword_enderr()
{
  errstr(" expected, but we have \'"); errstr(_tword); err('\''); enderr();
}

PROC err_tword(PCHAR s)
{
  errstr(s); err_tword_enderr();
}

PROC doexp() //всегда _joined
{
  IF (_isexp) emitexport(_joined);
}

PROC eat(CHAR c)
{
  IF (*(PCHAR)_tword!=c) {
    err(c); err_tword_enderr();
  };
  rdword();
}

PROC jdot()
{
  _lenjoined = stradd(_joined, _lenjoined,'.');
  _joined[_lenjoined] = '\0';
}

VAR UINT _genn;

PROC gendig(UINT d)
{
VAR BYTE dig;
  dig = (BYTE)'A';
  WHILE (_genn >= d) {
    _genn = _genn - d;
    INC dig;
    _wasdig = +TRUE;
  };
  IF (_wasdig) {
    _lenjoined = stradd(_joined, _lenjoined, (CHAR)dig);
  };
}

PROC jautonum(UINT n)
{
  _genn = n;
  _wasdig = +TRUE;
  IF (n != 0) {
    _wasdig = +FALSE;
    gendig(676);
    gendig(26);
  };
  gendig(1);
  jdot();
}

PROC genjplbl(UINT n)
{
  _joined[0] = '_'; _lenjoined = 1;//_lenjoined = strcopy(_title, _lentitle, _joined);
  jautonum(n);
}

PROC jtitletword()
{
  _lenjoined = strcopy(_title, _lentitle, _joined);
  _lenjoined = strjoin(/**to=*/_joined, _lenjoined, _tword);
  _joined[_lenjoined] = '\0';
}

PROC do_type()
{
loop:
  _lenname = strcopy(_tword, _lentword, _name);
  _t = lbltype();
  IF ((_t&_T_TYPE)!=(TYPE)0x00) { //если это не переменная, а тип
    IF (_t == (_T_TYPE+_T_STRUCTWORD)) {
      rdword(); //use STRUCT
      goto loop;
    };
    IF (_cnext == '*') {
      _t = _t|_T_POI;
      _varsz = (UINT)_SZ_REG;
      rdword(); //use *
    };
  };
}

PROC eattype()
{
  do_type();
  _t = _t&~_T_TYPE;
  rdword();
}

PROC doprefix(BYTE nb) //склеить n слов типа 'word.' из title в prefix (name без префикса)
{
  _lenprefix = 0;
  WHILE (nb > 0x00) { //перебираем слова
    _lenprefix = strjoineol(/**to=*/_prefix, _lenprefix, &_title[_lenprefix], '.');
    _lenprefix = stradd(_prefix, _lenprefix, '.');
    DEC nb;
  };
  _prefix[_lenprefix] = '\0';
  _lenjoined = strcopy(_prefix, _lenprefix, _joined);
  _lenjoined = strjoin(/**to=*/_joined, _lenjoined, _tword);
  _joined[_lenjoined] = '\0';
}

PROC adddots()
{
/**  WHILE (_cnext == '.') {
    rdaddword(); //приклеить точку
    rdaddword(); //приклеить следующее слово
  };*/
}

PROC twordtojoined()
{
  _lenjoined = strcopy(_tword, _lentword, _joined);
}

PROC joinvarname(BOOL iscall) //возвращает _t = тип(_name)???
{ //идентификатор уже прочитан
VAR BYTE lvl;
  do_type();
  IF (!_isloc) {
    twordtojoined();
  }ELSE {
    lvl = _namespclvl;
    IF (iscall && (lvl != 0x00)) {
      DEC lvl; //proc()
    };
    doprefix(lvl); //склеить n слов типа 'word.' из title в prefix (name без префикса)
    //todo проверить и этот тип (для модульности)?
    //или todo превратить stru1->f1.f2 в tstru1.f1+tstru2.f2
  };
}

PROC eatvarname() //для создания меток
{
  eattype(); //t = _t; //тип был уже прочитан
  adddots();
  _lenname = strcopy(_tword, _lentword, _name);
  doprefix(_namespclvl); //склеить n слов типа 'word.' из title в prefix (name без префикса)
  rdword(); //'['
  IF (*(PCHAR)_tword == '[') {
    _t = _t|_T_ARRAY;
  };
}

PROC getstructfield() //возвращает _t = тип поля
{ //структура уже прочитана и адресована _typeaddr (в lbltype или addlbl), тип _t = некий указатель???
  _lenjoined = gettypename(_joined); //взять название типа структуры в joined
  eat('>'); //use '>'
  jdot();
  _lenjoined = strjoin(/**to=*/_joined, _lenjoined, _tword); //structname.structfield
  _joined[_lenjoined] = '\0';
  cmdpushnum(); //structname.structfield
  cmdadd();
  _lenname = strcopy(/**from=*/_joined, _lenjoined, _name); //structname.structfield
  _t = lbltype(); //(_name)
}

//////////////////////////////////////////
// compiler

//call вызывает _tword и expr
PROC eatexpr RECURSIVE FORWARD();  //вызывает call
FUNC BOOL eatcmd RECURSIVE FORWARD();  //вызывает call
FUNC TYPE do_call RECURSIVE FORWARD(BOOL isfunc); //возвращает тип функции
PROC compfile RECURSIVE FORWARD(PCHAR fn);

PROC varstrz() //для строковых констант в выражениях
{
  emitvarlabel(_joined);
  WHILE (+TRUE) {
    rdquotes('\"');
    rdch(); //добавляем закрывающую кавычку
    _tword[_lentword] = '\0';
    var_db(); varstr(_tword); endvar();
    IF (_cnext != '\"') BREAK;
    rdword(); //открывающая кавычка приклеенной строки
  };
  var_db(); varc('0'); endvar();
}

PROC asmstrz() //все CONST строки теперь в коде (раньше было только для константных массивов строк)
{
  emitasmlabel(_joined);
  WHILE (+TRUE) {
    rdquotes('\"');
    rdch(); //добавляем закрывающую кавычку
    _tword[_lentword] = '\0';
    asm_db(); asmstr(_tword); endasm();
    IF (_cnext != '\"') BREAK;
    rdword(); //открывающая кавычка приклеенной строки
  };
  asm_db(); asmc('0'); endasm();
}

PROC eatidx() //для idxarray и switch
{
  INC _exprlvl; //no jump optimization
  eatexpr(); //сравнения нельзя без скобок!!!
  DEC _exprlvl;
  IF (_t==_T_BYTE) cmdcastto(_T_UINT);
  IF (_t!=_T_UINT) {errstr("idx bad type "); erruint((UINT)_t); enderr(); };
}

FUNC TYPE idxarray RECURSIVE(TYPE t)
{
  rdword(); //первое слово expr
  IF ((t&_T_ARRAY) != (TYPE)0x00) { //массив
    t = t&_TYPEMASK; //&(~(_T_ARRAY|_T_CONST)); //может быть _T_POI (если массив строк)
    _t = _T_POI|_T_BYTE; cmdpushnum(); //использование обычного массива - берём его адрес
  }ELSE IF ((t&_T_POI) != (TYPE)0x00) { //указатель
    _t = t; cmdpushvar(); //использование указателя в качестве массива - читаем его значение
    t = t&(~_T_POI);
  }ELSE {errstr("[] not in array "); erruint((UINT)t); enderr(); };
  eatidx();
  _t = t; //тип элемента массива
  cmdaddpoi();
RETURN t; //тип элемента массива
}

PROC numtype()
{
  IF (_cnext == '.') { //дробное число (нельзя начинать с точки или заканчивать точкой)
    rdaddword(); //приклеить точку
    rdaddword(); //приклеить дробную часть
    IF ( (_tword[_lentword-1]=='e') && (_cnext=='-') ) {
      rdaddword(); //приклеить '-' отрицательной экспоненты
      rdaddword(); //приклеить отрицательную экспоненту
    };
    _t = _T_FLOAT;
  }ELSE IF (*(PCHAR)_tword == '-') { //в val уже есть, надо для define
    _t = _T_INT;
  }ELSE IF (_tword[_lentword-1]=='L') {
    _t = _T_LONG;
  }ELSE IF ((BYTE)_tword[1] > (BYTE)'9') { //ускорение проверки числового формата
    IF ((_lentword<=4)&&(_tword[1]=='x')) {
      _t = _T_BYTE;
    }ELSE IF ((_lentword<=10)&&(_tword[1]=='b')) {
      _t = _T_BYTE;
    }ELSE {
      _t = _T_UINT;
    };
  }ELSE {
    _t = _T_UINT;
  };
}

PROC val RECURSIVE()
{
VAR TYPE t; //для cast,peek
VAR UINT typeaddr; //для cast
{
//<val>::=
//(<expr>) //выражение (вычисляется)
//|<num> //десятичное число (передаётся целиком) INT/UINT/LONG
//|<num>.<num>[e-<num>] //float число (передаётся целиком)
//|<var> //переменная
//|'CHAR' //символьная константа (передаётся целиком)
//|"str" //строковая константа (передаётся целиком)
//|(<type>)<val> //вычислить val, потом сделать перевод в <type>
//|+<boolconst>
//|+_<enumconst> BYTE
//|+(constexpr) //тип по левому контексту
//|<lbl>([<val>,...]) //call
//|-<val> //вычислить val, потом сделать NEG
//|~<val> //вычислить val, потом сделать INV
//|!<val> //вычислить val, потом сделать INV(BOOL)
//|*(<ptype>)<val> //прочитать память по адресу (вычислить val, потом сделать PEEK)
//|&<var> //адрес переменной
 //команда уже прочитана
#ifdef USE_HINTS
;;  hintstr("//val: word=\""); hintstr(_tword); hintstr("\", cnext=\""); hint(_cnext); hint('\"'); endhint();
#endif
  _opsym = *(PCHAR)_tword;
  IF (_opsym == '~') {
    rdword(); //первое слово val
    IF (!_waseof) val(); //рекурсивный вызов val
    cmdinv();
  }ELSE IF ((BYTE)_opsym >= 0x41) { //<var>
    adddots();
   //если вызов функции, то do_variable надо делать с namespclvl-1!!!
    IF (_cnext == '(') { //call
      _t = do_call(+TRUE); //isfunc
    }ELSE {
      joinvarname(+FALSE); //iscall
      IF (_cnext == '[') { //<varname>[<idx>]
        rdword();
        _t = idxarray(_t);
        cmdpeek();
      }ELSE { //<varname>
        IF ((_t&_T_TYPE)==(TYPE)0x00) {
          /**IF (_t==_T_STRUCT) {
            _t = _T_POI|_T_BYTE;
            cmdpushnum(); //берём адрес структуры (для .)
          }ELSE*/ IF ((_t&_T_ARRAY)!=(TYPE)0x00) { //array without [] as a pointer
            _t = _t&(~(_T_ARRAY|_T_CONST))|_T_POI;
            cmdpushnum(); //использование обычного массива - берём его адрес
          }ELSE IF ((_t&_T_CONST)==(TYPE)0x00) {
            cmdpushvar(); //указатель (в том числе на структуру) или обычная переменная
          }ELSE { //константа (equ)
            _t = _t&_TYPEMASK; //&(~_T_CONST);
            cmdpushnum();
          };
        };
      };
    };
  }ELSE IF (_opsym == '\'') {
    rdquotes('\'');
    rdch(); //добавляем закрывающую кавычку
    _tword[_lentword] = '\0';
    twordtojoined();
    _t = _T_CHAR; cmdpushnum();
  }ELSE IF (_opsym == '\"') {
    _lenjoined = strcopy(_title, _lentitle, _joined);
    jautonum(_curlbl); INC _curlbl;
    _t = _T_POI|_T_CHAR; cmdpushnum();
    varstrz(); //с меткой joined
  }ELSE IF (_opsym == '+') {
    rdword(); //'(' of type or +TRUE/+FALSE (BOOL) or +_CONSTANT or +__CONSTANT (BYTE)
    _opsym = *(PCHAR)_tword;
    IF (_opsym=='_') { //+_CONSTANT
      //начальная часть имени константы уже прочитана
      adddots();
      joinvarname(/**iscall*/+FALSE);
      _lenjoined = strcopy(_name, _lenname, _joined); //глобальная
      _t = _T_BYTE; cmdpushnum();
    }ELSE IF ((BYTE)((BYTE)_opsym - (BYTE)'0') < 0x0a) { //+num //extra BYTE for C bug
      IF (!_waseof) val(); //рекурсивный вызов val
      IF (_t == _T_UINT) cmdcastto(_T_INT); //для знаковых констант типа +15
    }ELSE IF (_opsym!='(') { //+TRUE/+FALSE (BOOL) //+sizeof
      IF (_opsym=='s') { //+sizeof //TODO uppercase?
        rdword(); //использовали sizeof
        eat('('/**, "\'(\'"*/);
        eattype();
//        IF ((_t&_T_TYPE)!=0x00) {
          emitn(_varsz); //gettypesz();
          _lenjoined = strcopy(_nbuf, _lennbuf, _joined); //глобальная
//        }ELSE { //не тип
          //- из переменной базового типа - будет ошибка, т.к. пуш значения переменной TODO (сделать состояние _issizeof)
          //- из переменной массива - будет ошибка, т.к. пуш адреса массива TODO
          //- из переменной структуры - будет ошибка, т.к. пуш адреса структуры TODO
          //- из выражения - будет ошибка, т.к. сгенерируются операции TODO
//        };
        _t = _T_UINT; cmdpushnum(); //(_joined)
      }ELSE { //+TRUE/+FALSE (BOOL)
        twordtojoined();
        _t = _T_BOOL; cmdpushnum(); //(_joined)
      };
    }ELSE { //'(': был typecast
#ifdef USE_COMMENTS
;;  cmtstr(";+(val)"); endcmt();
#endif
      rdword(); //(
      rdquotes(')');
      twordtojoined();
      rdword(); //)
      cmdpushnum(); //(_joined) //type from left context!!!
    };
  }ELSE IF ((BYTE)((BYTE)_opsym - (BYTE)'0') < 0x0a) { //num //extra BYTE for C bug
    numtype(); //_t
    twordtojoined();
    cmdpushnum();
  }ELSE IF (_opsym == '(') {
    rdword(); //первое слово expr
    eatexpr(); //на выходе из expr уже прочитана ')'???, но следующий символ или команда не прочитаны
    typeaddr = _typeaddr;
    IF ((_t&_T_TYPE)!=(TYPE)0x00) { //(type)val typecast//нельзя в sizeof(expr)
      t = _t&~_T_TYPE;
      _t = t;
      rdword();
      val();
      _typeaddr = typeaddr;
      cmdcastto(t);
    };
  }ELSE IF (_opsym == '-') {
    IF ((BYTE)((BYTE)_cnext - (BYTE)'0') < 0x0a) { //-<const>
      rdaddword();
      //todo float
      _t = _T_INT;
      twordtojoined();
      cmdpushnum();
    }ELSE { //-<var>
      rdword(); //первое слово val
      IF (!_waseof) val(); //рекурсивный вызов val
      cmdneg();
    };
  }ELSE IF (_opsym == '!') {
    rdword(); //первое слово val
    IF (!_waseof) val(); //рекурсивный вызов val
    cmdinv(); //TODO invBOOL
  }ELSE IF (_opsym == '*') {
    rdword(); //'(' of type
    IF (!_waseof) val(); //здесь тип указателя не важен //рекурсивный вызов val
    _t = _t&~_T_POI; //&~_T_CONST;
    cmdpeek();
  }ELSE IF (_opsym == '&') {
    IF (_cnext == '(') { //&(<structname>-><field>)
      _addrexpr = +TRUE;
      rdword(); //'('
      val();
      _t = _t|_T_POI;
    }ELSE {
      rdword();
      adddots();
      joinvarname(/**iscall*/+FALSE);
      IF (_cnext == '[') { //&<varname>[<idx>]
        rdword(); //'['
        _t = idxarray(_t)/**тип элемента массива*/|_T_POI;
      }ELSE { //&<varname>
        //IF ((_t&_T_ARRAY)!=0x00) { //&<arrayname> - error
        //}ELSE IF ((_t&_T_CONST)!=0x00) { //&<constname> - error
        //}ELSE { //&<varname>
          _t = _t&_TYPEMASK|_T_POI;
          cmdpushnum();
        //};
      };
    };
  }ELSE {
    errstr("WRONG PREFIX "); err(_opsym); enderr();
    _t = _T_UNKNOWN; //debug (иначе может вылететь за таблицу typesz при обрыве файла)
  };
#ifdef USE_HINTS
;;  hinttype("end val",_t);
#endif
}
}

PROC eatmulval RECURSIVE()
{
VAR CHAR opsym;
VAR TYPE t1;
{
//<val>[<*|/><val>...] => push[push<*|/>...]
//заканчивается по символу любой неописанной операции (например, ')' или ';')
 //команда уже прочитана
#ifdef USE_HINTS
;;  hintstr("//mulval"); endhint();
#endif
  val();
  rdword();
#ifdef USE_HINTS
;;  hintstr("//mulval after val"); hint_tword();
#endif
  REPEAT {
    opsym = *(PCHAR)_tword;
    IF (opsym!='*')
      IF (opsym!='/')
        IF (opsym!='&')
          BREAK;
    t1 = _t;
    rdword();
    IF (opsym=='&')
      IF (*(PCHAR)_tword==opsym)
        rdword(); //use '&' //C compatibility
    val();
    _t = _t&_TYPEMASK; //&(~_T_CONST);
    rdword();
#ifdef USE_HINTS
;;    hintstr("//mulval after val2"); hint_tword();
#endif
    IF (t1 != _t) {errstr("opsym "); err(opsym); errstr(" type "); erruint((UINT)t1); errstr("!="); erruint((UINT)_t); enderr(); };
    IF       (opsym=='&') {cmdand();
    }ELSE IF (opsym=='*') {cmdmul();
    }ELSE /**IF (opsym=='/')*/ {cmddiv();
    };
  }UNTIL (_waseof);
#ifdef USE_HINTS
;;  hinttype("end mulval",_t);
#endif
}
}

PROC eatsumval RECURSIVE()
{
VAR CHAR opsym;
VAR TYPE t1;
{
//<mulval>[<+|-><mulval>...] => push[push<+|->...]
 //команда уже прочитана
#ifdef USE_HINTS
;;  hintstr("//sumval"); endhint();
#endif
  eatmulval();
  REPEAT {
    opsym = *(PCHAR)_tword;
    IF (opsym!='+')
      IF (opsym!='-')
        IF (opsym!='|')
          IF (opsym!='^')
            BREAK;
    t1 = _t;
    rdword();
    IF (*(PCHAR)_tword=='>') { //structinstancepointer->structfield
      //структура уже прочитана и адресована _typeaddr, тип _t = некий указатель
      IF (_t == _T_UNKNOWN) {errstr("nolbl:"); errstr(_name); enderr(); };
      getstructfield(); //_t = тип поля
      IF (!_addrexpr) cmdpeek(); //peek
      rdword(); //использовали structfield
    }ELSE {
      IF (opsym=='|') //||(opsym=='^')
        IF (*(PCHAR)_tword==opsym)
          rdword(); //use '|' or '^' //C compatibility
      eatmulval();
      _t = _t&_TYPEMASK; //&(~_T_CONST);
      IF (t1 != _t) /**&& ((t&_T_POI)!=0x00)*/ {errstr("opsym "); err(opsym); errstr(" type "); erruint((UINT)t1); errstr("!="); erruint((UINT)_t); enderr(); };
      //todo addpointer
      IF       (opsym == '+') {cmdadd();
      }ELSE IF (opsym == '-') {cmdsub(); //из старого вычесть новое!
      }ELSE IF (opsym == '|') {cmdor();
      }ELSE /**IF (opsym == '^')*/ {cmdxor();
      };
    };
  }UNTIL (_waseof);
#ifdef USE_HINTS
;;  hinttype("end sumval",_t);
#endif
}
}

PROC eatexpr RECURSIVE()
{
VAR CHAR opsym;
VAR TYPE t1;
VAR BOOL modified;
VAR BOOL dbl;
{
//<sumval>[<=><sumval>...]
 //команда уже прочитана (нужно для do_call_par)
#ifdef USE_HINTS
;;  hintstr("//expr"); endhint();
#endif
  INC _exprlvl;
  eatsumval();
  REPEAT {
    opsym = *(PCHAR)_tword;
    IF (opsym!='<')
      IF (opsym!='>')
        IF (opsym!='=')
          IF (opsym!='!')
            BREAK;
    t1 = _t;
    rdword();
    modified = (*(PCHAR)_tword=='=');
    dbl = (*(PCHAR)_tword==opsym);
    IF ( modified||dbl ) rdword(); //use '=' or '>' or '<'
    eatsumval();
    _t = _t&_TYPEMASK; //&(~_T_CONST);
    IF (t1 != _t) {errstr("opsym "); err(opsym); errstr(" type "); erruint((UINT)t1); errstr("!="); erruint((UINT)_t); enderr(); };
    IF (opsym == '=') {
      IF (!dbl) {errstr( "assign in expr" ); enderr(); };
      cmdeq(); //делает _t = _T_BOOL
    }ELSE IF (opsym == '!') {
      cmdnoteq(); //делает _t = _T_BOOL
    }ELSE IF (opsym == '<') {
      IF (dbl) {
        cmdshl(); //старое сдвинуть столько раз, сколько гласит новое!
      }ELSE IF (modified) {
        cmdlesseq(); //делает _t = _T_BOOL
      }ELSE cmdless(); //делает _t = _T_BOOL
    }ELSE /**IF (opsym == '>')*/ {
      IF (dbl) {
        cmdshr(); //старое сдвинуть столько раз, сколько гласит новое!
      }ELSE IF (modified) {
        cmdmoreeq(); //делает _t = _T_BOOL
      }ELSE cmdmore(); //делает _t = _T_BOOL
    };
  }UNTIL (_waseof);
  //в _tword ожидается ')' или другой несоответствующий символ
  DEC _exprlvl;
  _addrexpr = +FALSE; //не выражение с &
#ifdef USE_HINTS
;;  hinttype("end expr",_t);
;;  hint_tword();
#endif
}
}

PROC eatpoke()
//poke*(<ptype>)(<pointerexpr>)=<expr>
{
VAR TYPE t;
#ifdef USE_HINTS
;;  hintstr("//poke"); endhint();
#endif
  _exprlvl = 0x01; //no jump optimization
  eat('*');
  val(); t = _t&~_T_POI;
  rdword();
  eat('=');
  eatexpr();
  IF (t != _t) {errstr("poke var"); err_type_enderr((UINT)t); };
  cmdpoke();
#ifdef USE_HINTS
;;  hintstr("//end poke"); endhint();
#endif
}

PROC eatlet()
//<var>[<[><expr><]>]=<expr>
//<var>-><field>=<expr>
{
VAR TYPE t;
VAR BOOL ispoke;
#ifdef USE_HINTS
;;  hintstr("//let"); endhint();
#endif
  _exprlvl = 0x01; //no jp optimization
  joinvarname(/**iscall*/+FALSE); t = _t; //t!!!
  rdword(); //'['
  ispoke = +FALSE;
  IF (*(PCHAR)_tword == '[') {
    t = idxarray(t); //t = t&(~(_T_ARRAY|_T_POI));
    eat(']');
    ispoke = +TRUE;
  }ELSE {
    WHILE (*(PCHAR)_tword == '-') {
      _t = t;
      IF (ispoke) { //не первый ->
        cmdpeek();
      }ELSE { //первый ->
        cmdpushvar(); //указатель (в том числе на структуру) или обычная переменная
      };
      eat('-');
      //структура уже прочитана и адресована _typeaddr, тип _t = некий указатель
      IF (_t == _T_UNKNOWN) {errstr("nolbl:"); errstr(_name); enderr(); };
      getstructfield(); //_t = тип поля
      t = _t; //todo
      rdword(); //использовали structfield
      ispoke = +TRUE;
    };
  };
  eat('=');
 strpush(_joined,_lenjoined);
  eatexpr(); //получает тип _t
 _lenjoined = strpop(_joined);
  IF (t!=_t) {
    errstr("let var"); err_type_enderr((UINT)t);
  };
  IF (ispoke) {
    cmdpoke();
  }ELSE {
    cmdpopvar();
  };
#ifdef USE_HINTS
;;  hintstr("//end let"); hint_tword();
#endif
}

PROC eatwhile RECURSIVE()
//while<expr><cmd>
{
VAR UINT beglbl;
VAR UINT wasendlbl;
{
#ifdef USE_HINTS
;;  hintstr("//while"); endhint();
#endif
  _exprlvl = 0x00; //jp optimization possible
  wasendlbl = _tmpendlbl;
  beglbl = _jplbl; INC _jplbl;
  _tmpendlbl = _jplbl; INC _jplbl;
  genjplbl(beglbl); cmdlabel();
  eat('(');
  eatexpr(); //parentheses not included
  genjplbl(_tmpendlbl); cmdjpiffalse();
  eat(')');
  eatcmd(); //тело while
  genjplbl(beglbl); cmdjp();
  genjplbl(_tmpendlbl); cmdlabel();
  _tmpendlbl = wasendlbl;
#ifdef USE_HINTS
;;  hintstr("//end while"); endhint();
#endif
}
}

PROC eatrepeat RECURSIVE()
//repeat<cmd>until<expr>
{
VAR UINT beglbl;
VAR UINT wasendlbl;
{
#ifdef USE_HINTS
;;  hintstr("//repeat"); endhint();
#endif
  wasendlbl = _tmpendlbl;
  beglbl = _jplbl; INC _jplbl;
  _tmpendlbl = _jplbl; INC _jplbl;
  genjplbl(beglbl); cmdlabel();
  eatcmd(); //тело repeat
  IF ( (CHAR)((BYTE)(*(PCHAR)_tword)|0x20)!='u'/**"until"*/ ) err_tword("UNTIL");
  rdword();
  eat('(');
  _exprlvl = 0x00; //jp optimization possible
  eatexpr(); //parentheses not included
  eat(')');
  genjplbl(beglbl); cmdjpiffalse();
  genjplbl(_tmpendlbl); cmdlabel();
  _tmpendlbl = wasendlbl;
#ifdef USE_HINTS
;;  hintstr("//end repeat"); endhint();
#endif
}
}

PROC eatbreak() //todo inline
//break
{
  genjplbl(_tmpendlbl);
  cmdjp();
}

PROC eatif RECURSIVE()
//if <expr> <cmd>[else<cmd>];
//(; против ошибки "IF (expr);cmd" и ошибки вложенного if)
{
VAR UINT elselbl;
VAR UINT endiflbl;
{
#ifdef USE_HINTS
;;  hintstr("//if"); endhint();
#endif
  _exprlvl = 0x00; //jp optimization possible
  elselbl = _jplbl; INC _jplbl;
  endiflbl = _jplbl; INC _jplbl;
  eat('(');
  eatexpr(); //parentheses not included
  genjplbl(elselbl); cmdjpiffalse();
  eat(')');
  eatcmd(); //тело then
  IF (*(PCHAR)_tword != ';'/**"endif"*/) {
    IF ( (CHAR)((BYTE)(*(PCHAR)_tword)|0x20)!='e'/**"else"*/ ) err_tword("ELSE or \';\'");
    genjplbl(endiflbl); cmdjp();
    genjplbl(elselbl); cmdlabel();
    rdword();
    eatcmd(); //тело else
    genjplbl(endiflbl); cmdlabel();
    IF (*(PCHAR)_tword != ';'/**"endif"*/) { errstr( "\';\' expected, but we have \'"); err(*(PCHAR)_tword); err('\''); enderr(); };
    //нельзя съедать ';', он нужен для вложенных if
  }ELSE { //ожидаем 'endif' (если IF без ELSE)
    genjplbl(elselbl); cmdlabel();
  };
#ifdef USE_HINTS
;;  hintstr("//end if"); endhint();
#endif
}
}
/**
PROC eatmodule RECURSIVE()
//module<lbl><cmd>
{
  _lentitle = strjoin(_title, _lentitle, _tword);
  _lentitle = stradd(_title, _lentitle, '.');
  INC _namespclvl; //добавляем слово к title

  rdword();
  eatcmd();

  DEC _namespclvl;
  doprefix(_namespclvl); //to prefix
  _lentitle = strcopy(_prefix, _lenprefix, _title); //title = prefix //отрезаем добавленное слово
}
*/
PROC eatreturn()
{
//todo проверить isfunc (что мы в функции) для вывода ошибки
#ifdef USE_HINTS
;;  hintstr("//return"); endhint();
#endif
  _exprlvl = 0x01; //no jp optimization
  eatexpr(); //сравнения нельзя без скобок!!!
  IF ( _t != (_curfunct&(~_T_RECURSIVE)) ) {errstr("return"); err_type_enderr((UINT)_curfunct); };
  cmdresult();
#ifdef USE_HINTS
;;  hintstr("//end return"); endhint();
#endif
  IF (_pushlvl != 0x00) {errstr("ret inside recursive func!"); enderr(); };
  _t = _curfunct&(~_T_RECURSIVE);
  cmdret(+TRUE);
  _wasreturn = +TRUE;
}

PROC eatinc()
{
#ifdef USE_HINTS
;;  hintstr("//inc"); endhint();
#endif
  IF (*(PCHAR)_tword == '*') {
    rdword(); //'('
    eatexpr();
    _t = _t&~_T_POI;
    cmdincbyaddr();
  }ELSE {
    //начальная часть имени переменной уже прочитана
    adddots(); //дочитать имя
    joinvarname(/**iscall*/+FALSE); //doprefix(_namespclvl); //prefix:=title[FIRST to...];
    cmdinc();
    rdword();
  };
}

PROC eatdec()
{
#ifdef USE_HINTS
;;  hintstr("//dec"); endhint();
#endif
  IF (*(PCHAR)_tword == '*') {
    rdword(); //'('
    eatexpr();
    _t = _t&~_T_POI;
    cmddecbyaddr();
  }ELSE {
    //начальная часть имени переменной уже прочитана
    adddots(); //дочитать имя
    joinvarname(/**iscall*/+FALSE); //doprefix(_namespclvl); //prefix:=title[FIRST to...];
    cmddec();
    rdword();
  };
}

PROC var_num(TYPE t, PCHAR s)
{
VAR TYPE tmasked = t&(~_T_ARRAY);
/**  IF ( (t&_T_POI)!=(TYPE)0x00 ) { //используется для строк (нельзя equ)
    varstr_tword(); //DB "str"
  }ELSE*/ IF ( (t&_T_CONST)!=(TYPE)0x00 ) {
    varequ(_title); /**varstr(_title); varc( '=' );*/ varstr(s); endvar();
  }ELSE {
    IF (t==tmasked/**(t&_T_ARRAY)==(TYPE)0x00*/) {
      var_alignwsz_label(t);
      //emitvarlabel(_joined); //varstr(_joined); /**varc( ':' );*/ endvar();
    };
    var_def(tmasked, s);
  };
}

//TODO выражения(отдать асму?) + таблицу констант в компиляторе?
PROC do_const_num(TYPE t)
{
  IF ((*(PCHAR)_tword == '-') || (*(PCHAR)_tword == '+')) {
    rdaddword(); //приклеить число
    var_num(t, _tword);
  }ELSE IF (*(PCHAR)_tword == '\'') {
    rdquotes('\'');
    rdch(); //добавляем закрывающую кавычку
    _tword[_lentword] = '\0'; //strclose(_tword, _lentword);
    var_num(t, _tword);
  }ELSE IF (*(PCHAR)_tword == '&') { //&<var>, &<func>, &<structinstance>
    rdword(); //использовать &, прочитать начало имени
    adddots(); //дочитать имя
    var_num(_T_ARRAY|_T_UINT, _tword); //_T_ARRAY не даёт создать метку
  }ELSE IF (*(PCHAR)_tword == '\"') {
    _lenjoined = strcopy(_title, _lentitle, _joined);
    IF ((t&_T_ARRAY)!=(TYPE)0x00) { //строка внутри массива
      jdot();
      jautonum(_curlbl); INC _curlbl;
      //_joined[_lenjoined] = '\0'; //strclose(_joined, _lenjoined);
      var_num(_T_ARRAY|_T_UINT, _joined); //_T_ARRAY не даёт создать метку
      asmstrz(); //с меткой _joined //костыль вместо varstrz //todo целиком заполнить указатели, потом генерировать строки? (нельзя будет &str в const pchar arr[]?)
    }ELSE {
      asmstrz(); //varstrz(); //с меткой joined
    };
  }ELSE var_num(t, _tword);
}

PROC eatextern()
//extern<type><variable>[<[><expr><]>]
{
VAR TYPE t;
#ifdef USE_HINTS
;;  hintstr("//extern"); endhint();
#endif
  _exprlvl = 0x01; //no jump optimization
  eatvarname(); t = _t; //без срубания вложенностей по _ (создаёт _name)
  IF (*(PCHAR)_tword == '[') {
    //t = t|_T_ARRAY; //уже в eatvarname
    //rdbrackets(); //_tword='[' //TODO evaluate expr (в нём нельзя переменные и вызовы, т.е. не запарывается joined?)
    _lentword = 0; //читаем с пустой строки
    rdquotes(']');
    rdch(); //пропустить ']'
    //_lenncells = strcopy(_tword, _lentword, _ncells); //n = _tword;
  //}ELSE {
    //n ="1";
    //_lenncells = stradd(_ncells, 0, '1'); //n = n + '1';
    //strclose(_ncells, _lenncells);
    rdword();
  };
  addlbl(t, /**isloc*/+FALSE, (UINT)_typesz[t&_TYPEMASK]/**, _ncells, _lenncells*/); //(_name) //TODO размер массива (структуры не бывают extern?)!
#ifdef USE_HINTS
;;  hintstr("//end extern"); endhint();
#endif
}

PROC eatvar RECURSIVE(BOOL ispar, BOOL body) //если var, то body==+TRUE, иначе body==!forward
//var<type><variable>[<[><expr><]>][=<expr>]
//или в параметрах при объявлении функции <type><variable>
{
VAR TYPE t;
{
#ifdef USE_HINTS
;;  hintstr("//var"); endhint();
#endif
  _exprlvl = 0x01; //no jump optimization
  eatvarname(); t = _t; //без срубания вложенностей по _ (создаёт _name)
  IF (*(PCHAR)_tword == '[') {
    //t = t|_T_ARRAY; //уже в eatvarname
   //strpush(_joined,_lenjoined);
    //TODO evaluate expr (в нём нельзя переменные и вызовы, т.е. не запарывается joined?)
    _lentword = 0; //читаем с пустой строки
    rdquotes(']');
   //_lenjoined = strpop(_joined);
    _lenncells = strcopy(_tword, _lentword, _ncells); //n = _tword;
    rdch(); //пропустить ']'
    rdword();
  }ELSE { //n = "1"
    _lenncells = stradd(_ncells, 0, '1'); //n = n + '1';
    _ncells[_lenncells] = '\0'; //strclose(_ncells, _lenncells);
  };
  IF (body) addlbl(t, /**isloc*/(_namespclvl!=0x00), (UINT)_typesz[t&_TYPEMASK]); //(_name) //TODO размер массива или структуры!
  IF (ispar) { //parameter of func/proc
    IF (body) {
      var_alignwsz_label(t);
      //emitvarlabel(_joined); //varstr(_joined); /**varc( ':' );*/ endvar();
    };
    _lenjoined = strcopy(_prefix, _lenprefix, _joined); //_lenjoined = strjoin(/**to=*/_joined, 0, _prefix); //prefix остался от doprefix/eatvarname выше
    jautonum(_parnum);
    INC _parnum; //!!! todo написать почему
    INC _curlbl; //!!! todo написать почему
    //_joined[_lenjoined] = '\0'; //strclose(_joined, _lenjoined);
    _lenname = strcopy(_joined, _lenjoined, _name);
    addlbl(t, /**isloc*/+FALSE, (UINT)_typesz[t&_TYPEMASK]/**, "0", _lenncells*/); //отметили в таблице, что не выделять память //(_name) //TODO размер массива или структуры!
  };
  //printf("%s \n",_joined);
  IF (body) {
    IF ((t&_T_ARRAY)!=(TYPE)0x00) {
      var_alignwsz_label(t);
      //emitvarlabel(_joined); //varstr(_joined); /**varc( ':' );*/ endvar();
      var_ds(); /**varstr( "\tDS " );*/ varuint((UINT)_typesz[t&_TYPEMASK]); varc('*'); varstr(_ncells); endvar(); //todo рассчитать размер уже в addlbl, тогда можно будет делать +sizeof(<array>)
      //printf("%s ds \n",_joined);
    }ELSE {
      var_num(t, "0");
    };
    doexp(); //_joined
  };
  IF (*(PCHAR)_tword == '=') { //TODO проверить, что мы внутри функции (нерекурсивной!)
    rdword(); //'='
   strpush(_joined,_lenjoined);
    eatexpr();
   _lenjoined = strpop(_joined);
    //IF ( (t!=_t) && !( ((t&_T_POI)!=(TYPE)0x00) && (/**(texpr==_T_UINT)||*/((_t&_T_POI)!=(TYPE)0x00)) ) ) {errstr("let var="); errstr(_joined); err_type_enderr((UINT)t); };
    IF (t!=_t) {errstr("let var="); errstr(_joined); err_type_enderr((UINT)t); };
    cmdpopvar();
  };
  IF (_isrecursive && !ispar) { //local variable of recursive func/proc
    _t = t;
    cmdpushpar(); INC _pushlvl; //todo что делать с массивами?
   strpush(_joined,_lenjoined);
    WHILE (*(PCHAR)_tword==';') {
      rdword();
    }; //C compatibility
    eatcmd(); //recursive function body must be in {} after vars!
   _lenjoined = strpop(_joined);
    _t = t;
    cmdpoppar(); DEC _pushlvl; //todo что делать с массивами?
  };
#ifdef USE_HINTS
;;  hintstr("//end var"); endhint();
#endif
}
}

//TODO выражения(отдать асму?) + таблицу констант?
PROC eatconst()
//<constnum>::=[-]<num>|'<char>'|"<str>"["<str>"...]
//const<type><variable>[=<constnum>]
//|const<type><variable><[><expr><]>[<[><expr><]>...][={<constnum>[,<constnum>...]}] - вложенные {} запрещены (todo сделать или игнорировать с автопересчётом многомерных массивов в одномерные)
//|const pchar<variable><[><expr><]><[><expr><]>={"<str>"[,"<str>"...]}
{
VAR TYPE t;
VAR UINT i = 0;
#ifdef USE_HINTS
;;  hintstr("//const"); endhint();
#endif
  _exprlvl = 0x01; //no jump optimization
  eattype(); t = _t|_T_CONST; //тип был уже прочитан
  adddots();
  doprefix(_namespclvl); //склеить n слов типа 'word.' из title в prefix (name без префикса)
  rdword(); //'['
  IF (*(PCHAR)_tword == '[') {
    t = t|_T_ARRAY;
  };
  //_joined содержит имя константы
  //_name содержит тип
  _lentitle = strcopy(_joined, _lenjoined, _title); //для уникальности имён строковых констант
  INC _namespclvl; //добавляем слово к title

  //нам нужно получить имя типа
  lbltype();
  _lenname = strcopy(_joined, _lenjoined, _name); //имя константы
  _lencallee = gettypename(_callee); //взять название типа структуры в callee (сразу после lbltype)

  //title содержит имя константы (нужно для уникальности имён строковых констант в массиве в do_const_num)
  //_joined тоже содержит имя константы
  addlbl(t, /**isloc*/+FALSE, (UINT)_typesz[t&_TYPEMASK]/**, _ncells, _lenncells*/); //(_name) //TODO размер массива или структуры!
  WHILE (*(PCHAR)_tword == '[') { //[size]
    _lentword = 0; //читаем с пустой строки
    rdquotes(']');
    rdch(); //пропустить ']'
    rdword();
  };
  IF (*(PCHAR)_tword == '=') {
    rdword(); //num or '{'
    IF (*(PCHAR)_tword == '{') { //array or struct
      var_alignwsz_label(t);
      doexp(); //_joined //надо ли экспортировать константы? только константные массивы/структуры
      REPEAT{ //этот цикл запортит _joined, но использует _title
        rdword(); //num

        IF (t == (_T_STRUCT|_T_CONST)) { //структура (у неё нет атомарного типа)
          _lenjoined = strcopy(_callee, _lencallee, _joined); //callee содержит имя типа константы
          _lenjoined = stradd(_joined, _lenjoined, '.');
          jautonum(i);
          _lenname = strcopy(_joined, _lenjoined, _name);
          _t = lbltype();
          do_const_num(lbltype()&(~_T_TYPE)|_T_ARRAY); //_T_ARRAY не даёт создать метку //TODO _t
          INC i;
        }ELSE { //не структура
          do_const_num(t&(~_T_CONST)); //_T_ARRAY не даёт создать метку
        };

        rdword(); //',' or '}'
      }UNTIL (*(PCHAR)_tword == '}');
    }ELSE { //not array
      do_const_num(t);
    };
    rdword();
  };

  DEC _namespclvl; doprefix(_namespclvl); _lentitle=strcopy(_prefix,_lenprefix,_title);/**title =prefix;*/ //отрезаем добавленное слово

  //_isexp = +FALSE; //надо ли экспортировать константы? только константные массивы/структуры

#ifdef USE_HINTS
;;  hintstr("//end const"); endhint();
#endif
}

PROC eatfunc(BOOL isfunc, TYPE oldfunct, BOOL oldwasreturn)
//proc<procname>[recursive][forward](<type><par>,...])[<cmd>]
//|func<type><funcname>[recursive][forward]([<type><par>,...])[<cmd>]
{
VAR BOOL isforward;
  _curlbl = 0; //сбрасываем нумерацию автометок, т.к. у них префикс функции
  IF ( isfunc ) {
    eattype(); _curfunct = _t;
  }ELSE _curfunct = _T_PROC;
#ifdef USE_HINTS
;;    hintstr("//func "); hinttype(_title,_curfunct);
#endif
  _lenname = strcopy(_tword, _lentword, _name);
  jtitletword();
  rdword(); //'(' or "recursive" or "forward"
  IF ((CHAR)((BYTE)(*(PCHAR)_tword)|0x20) == 'r') {
    _curfunct = _curfunct|_T_RECURSIVE;
    _isrecursive = +TRUE;
    rdword(); //'('
  }ELSE _isrecursive = +FALSE;
  IF ((CHAR)((BYTE)(*(PCHAR)_tword)|0x20) == 'f') {
    isforward = +TRUE;
    rdword(); //'('
  }ELSE isforward = +FALSE;
  addlbl(_curfunct, /**isloc*/+FALSE, 0/**, _ncells"0", 1*/); //(_name) //нельзя if (!isforward), потому что надо запомнить тип функции в forward
  IF (!isforward) {
    cmdlabel(); //_joined
    cmdfunc(); //делает initrgs
    doexp(); //_joined
  };
  jdot();
  _lentitle = strcopy(_joined, _lenjoined, _title);
  INC _namespclvl; //добавляем слово к title

  eat('(');
  _parnum = 0;
  WHILE (!_waseof) {
    IF (*(PCHAR)_tword == ')') BREAK;
    eatvar(/**ispar*/+TRUE, /**body*/!isforward); //метка параметра создаётся без префикса и с флагом isloc, ещё создаётся f.A.
    IF (*(PCHAR)_tword == ')') BREAK; //иначе ','
    rdword(); //type or ')'
  };
  rdword();

  keepvars(); //нельзя перед параметрами, т.к. f.A. надо помнить после тела функции

  IF (!isforward) {
    eatcmd(); //тело функции (включая {})
//eatreturn: _wasreturn = +TRUE
//}: _waswasreturn = _wasreturn; _wasreturn = +FALSE (т.к. все return в ветках)
    _t = _curfunct&(~_T_RECURSIVE);
    if (!isfunc) { cmdret(isfunc); };
    IF (isfunc && !_waswasreturn) {errstr("return expected"); enderr(); };
#ifdef USE_HINTS
;;    hintstr("/////end func"); endhint();
#endif
  };

  undovars(); //TODO уничтожить короткие метки параметров, иначе они затрут глобалы навечно. Надо хранить адреса таких меток в таблице

  DEC _namespclvl; doprefix(_namespclvl); _lentitle=strcopy(_prefix,_lenprefix,_title);/**title =prefix;*/ //отрезаем добавленное слово
  _curfunct = oldfunct; //возвратить внешний тип функции
  _wasreturn = oldwasreturn; //состояние проверки "оператор после return" - как было (для вложенных определений функций?)
  _isexp = +FALSE;
}

PROC do_callpar RECURSIVE(TYPE funct, UINT parnum)
{
VAR TYPE t;
{
#ifdef USE_HINTS
;;  hintstr("//call_par"); endhint();
#endif
  IF ( (*(PCHAR)_tword!=')') && !_waseof ) {
    _lenjoined = strcopy(_callee, _lencallee, _joined);
    jdot();
    jautonum(parnum);
    //INC _curlbl; //не нужно, т.к. это вызов (т.е. другой префикс)
    //_joined[_lenjoined] = '\0'; //strclose(_joined, _lenjoined);
;;    cmtstr(";accesspar="); cmtstr(_joined); endcmt();
    _lenname = strcopy(_joined, _lenjoined, _name);
    t = lbltype(); //(_name)
    IF ((funct&_T_RECURSIVE)!=(TYPE)0x00) {
      _t = t;
      cmdpushpar(); INC _pushlvl; //(_joined)
    };
    strpush(_joined,_lenjoined);
    INC _exprlvl; //no jump optimization
    eatexpr(); //может рекурсивно вызвать do_call и затереть callee (если он глобальный)! //сравнения нельзя без скобок!!!
    DEC _exprlvl;
    IF (t != _t) {errstr("callpar"); err_type_enderr((UINT)t); };
    _lenjoined = strpop(_joined);
    cmdpopvar(); //(_joined)
    IF (*(PCHAR)_tword == ',') rdword(); //parameter or ')'
    IF (parnum < _MAXPARS) {
      strpush(_joined,_lenjoined);
      do_callpar(/**isfunc,*/ funct, parnum+1); //рекурсивно
      _lenjoined = strpop(_joined);
    }/**ELSE {errstr("too many params"); enderr(); }*/;
    IF ((funct&_T_RECURSIVE)!=(TYPE)0x00) {
      _t = t;
      cmdpoppar(); DEC _pushlvl; //(_joined)
    };
  }ELSE {
    _t = funct&(~_T_RECURSIVE);
    cmdcall();
  };
#ifdef USE_HINTS
;;  hintstr("//end call_par"); endhint();
#endif
}
}

FUNC TYPE do_call RECURSIVE(BOOL isfunc)
//<lbl>([recursive][(<type>)<val>,...])
{
VAR TYPE t;
{
  INC _exprlvl; //no jump optimization
  joinvarname(/**iscall*/+TRUE); t = _t; //t!!!
  IF (t == _T_UNKNOWN) {errstr("unknown func "); errstr(_joined); enderr(); };
#ifdef USE_HINTS
;;    hinttype("call",t);
#endif
  IF (!isfunc) t = (t&_T_RECURSIVE)|_T_PROC; //чтобы можно было вызывать функции как процедуры
  strpush(_callee, _lencallee); //на случай вложенных вызовов
  _lencallee = strcopy(_joined, _lenjoined, _callee); //без точки
  jdot();
  rdword(); //'('
  eat('(');
  do_callpar(t, /**parnum*/0); //сохранение [call]title, [сохранение переменной], присваивание, рекурсия, [восстановление переменной], восстановление [call]title
  _lencallee = strpop(_callee); //на случай вложенных вызовов
  DEC _exprlvl; //no jump optimization
  _t = t&(~_T_RECURSIVE);
} //pop old t
RETURN _t;
}

PROC eatcallpoi()
//call(<poi>)
{
 //начальная часть имени переменной уже прочитана
  adddots(); //дочитать имя
  joinvarname(/**iscall*/+FALSE); //doprefix(_namespclvl); //prefix:=title[FIRST to...];
  eat('(');
  eatexpr();
  //todo проверить pointer
  eat(')');
  cmdcallval();
  rdword();
}

PROC eatlbl() //todo inline
//_lbl<lblname><:>
{
  jtitletword();
  cmdlabel();
  rdword(); //skip ':' for C compatibility
  rdword(); //нужно!
}

PROC eatgoto() //переход только внутри текущей процедуры //todo inline
//goto<lblname>
{
  //rdword(); //lbl
  jtitletword();
  cmdjp();
  rdword();
}

PROC eatasm()
//asm("asmtext")
{
  //rdword(); //'('
  rdword(); //'\"'
  WHILE (!_waseof) {
    _lentword = 0; //читаем с пустой строки
    rdquotes('\"'/**, +FALSE*/);
    asmstr(_tword); endasm();
    rdch(); //пропустить закрывающую кавычку
    IF (_cnext != '\"') BREAK;
    rdword(); //'\"' открывающая кавычка приклеенной строки
  };
  rdword(); //')'
  rdword();
}

PROC eatenum()
//enum{<constname0>[=<num>],<constname1>...[,]}
{
  //rdword(); //'{'
_lenncells = strcopy("-1", 2, _ncells);
  WHILE (!_waseof) {
    rdword(); //метка
    IF (*(PCHAR)_tword=='}') BREAK; //BREAK работает, а goto qqq не работает ('}' не съедена)
    varequ(_tword); /**varstr(_tword); varc('=');*/

//костыль для script: создаём переменную UINT с адресом, как текущее число в enum:
//    _lenname = strcopy(_tword, _lentword, _name);
//    addlbl(_T_UINT, /**isloc*/+FALSE, /**varsz*/0/**, "0", _lenncells*/); //отметили в таблице, что не выделять память
//    rdword(); //',' или '}'
//    IF (*(PCHAR)_tword=='=') {
    IF (_cnext=='=') {
      rdword(); //съели =
      rdword(); //первое слово expr
      //eatexpr(); //parentheses not included
      //rdword(); //',' или '}'
      varstr(_tword);
    }ELSE {
      varstr(_ncells); varc('+'); varc('1'); /**varuint(i);*/
    };
_lenncells = strcopy(_tword, _lentword, _ncells);
    endvar();
    rdword(); //',' или '}'
    IF (*(PCHAR)_tword!=',') BREAK; //}
  };
  rdword(); //слово после }
}

PROC eatevar()
//evar{<type><varname0>[=<addr>],<type><varname1>...[,]}
{
  //rdword(); //'{'
_lenncells = strcopy("-1", 2, _ncells);
  WHILE (!_waseof) {
    rdword(); //type
    IF (*(PCHAR)_tword=='}') BREAK; //BREAK работает, а goto qqq не работает ('}' не съедена)
    eattype(); //_t //делает rdword(); //метка
    varequ(_tword); /**varstr(_tword); varc('=');*/
//создаём переменную типа _t с адресом, как текущее число в evar:
    _lenname = strcopy(_tword, _lentword, _name);
    addlbl(_t/**_T_UINT*/, /**isloc*/+FALSE, /**varsz*/0/**, "0", _lenncells*/); //отметили в таблице, что не выделять память
//    rdword(); //',' или '}'
//    IF (*(PCHAR)_tword=='=') {
    IF (_cnext=='=') {
      rdword(); //съели =
      rdword(); //первое слово expr
      //eatexpr(); //parentheses not included
      //rdword(); //',' или '}'
      varstr(_tword);
    }ELSE {
      varstr(_ncells); varc('+'); varc('1'); /**varuint(i);*/
    };
_lenncells = strcopy(_tword, _lentword, _ncells);
    endvar();
    rdword(); //',' или '}'
    IF (*(PCHAR)_tword!=',') BREAK; //}
  };
  rdword(); //слово после }
}

PROC eatstruct()
//struct<name>{<type1><field1>[;]<type2><field2>[;]...}
{
VAR UINT shift = 0;
VAR UINT varszaddr;
VAR UINT i = 0;
VAR UINT sz;
  _lentitle = strjoin(/**to=*/_title, _lentitle, _tword);
  _title[_lentitle] = '\0'; //strclose(_title, _lentitle);
  //strpush(_title,_lentitle); //без точки
  _lenname = strcopy(_title, _lentitle, _name); //без точки
  addlbl(_T_STRUCT|_T_TYPE, /**isloc*/+FALSE, 0/**, "0", _lenncells*/); //(_name) //предварительно создали, чтобы ссылаться
  varszaddr = _varszaddr;

  _lentitle = stradd(_title, _lentitle, '.');
  _title[_lentitle] = '\0'; //strclose(_title, _lentitle);
  INC _namespclvl; //добавляем слово к title
  rdword(); //использовали имя
  eat('{');

  WHILE (!_waseof) {
    eattype(); //использовали тип
    sz = (UINT)_typesz[_t&_TYPEMASK];
    //rdword(); //метка
    jtitletword();
    shift = varshift(shift, sz);

    _lenname = strcopy(_joined, _lenjoined, _name);
    addlbl(_t, /**isloc*/+FALSE, sz/**, "0", _lenncells*/); //(_name)

    _lenjoined = strcopy(_title, _lentitle, _joined);
    jautonum(i); //genjplbl(i);
    _lenname = strcopy(_joined, _lenjoined, _name);
    addlbl(_t, /**isloc*/+FALSE, sz/**, "0", _lenncells*/); //автонумерованная (_name)
    INC i;

    shift = shift + sz;
    rdword(); //тип или ';' или '}' //использовали метку
    IF (*(PCHAR)_tword==';') rdword(); //тип
    IF (*(PCHAR)_tword=='}') BREAK;
  };

  //_lenname = strpop(_name);
  //addlbl(_T_STRUCT|_T_TYPE, /**isloc*/+FALSE/**, "0", _lenncells*/); //отметили в таблице, что не выделять память //(_name)
  //там же сохранить sizeof_structname (=shift)
  //при этом всё ещё разрешить ссылаться на эту же структуру (т.е. определить её раньше, а заполнить данные потом; создать заново нельзя - другой адрес)
  setvarsz(varszaddr, shift);

  DEC _namespclvl;
  doprefix(_namespclvl); //to prefix
  _lentitle = strcopy(_prefix, _lenprefix, _title); //title = prefix //отрезаем добавленное слово
  rdword();
}

PROC eatswitch() //процедура теоретически рекурсивная, но практически вложенность switch запрещена
//'J' в нумерованных метках можно убрать, т.к. автометки теперь без цифр и не пересекутся (можно склеивать '.' с числом)
//switch (<byteexpr>){...};
//case <byteconst>: //генерируется автометка с числом (не пересечётся ни с чем)
//default: //генерируется автометка с точкой (не пересечётся ни с чем)
{
VAR BYTE ib;
VAR UINT wastmpendlbl;
  //rdword(); //'('
  wastmpendlbl = _tmpendlbl;
  _tmpendlbl = _jplbl; INC _jplbl;

  //pushvar <title>.J
  _lenjoined = strcopy(_title, _lentitle, _joined);
  _lenjoined = stradd(_joined, _lenjoined, 'J');
  _joined[_lenjoined] = '\0'; //strclose(_joined , _lenjoined);
  _t = _T_UINT|_T_POI;
  cmdpushnum(); //использование указателя в качестве массива - читаем его значение

  eatidx();
  _t = _T_UINT; //тип элемента массива
  cmdaddpoi();
  cmdpeek();

  cmdjpval();

  //генерировать список начальных значений нумерованных меток перехода
  //procname.aab.<num> = procname.aab.default (пока без aab TODO)
  //генерировать таблицу переходов, заполненную нумерованными метками перехода
  //DW procname.aab.1 (пока без aab TODO)
  varstr(_title); varc('J'); endvar();
  ib = 0x00;
  REPEAT {
    asmstr(_title); asmuint((UINT)ib); asmc('='); asmstr(_title); asmstr("default"); endasm(); //до кода! поэтому asm
    var_dw(); varstr(_title); varuint((UINT)ib); endvar(); //TODO "DP", т.е. на ширину POINTER?
    INC ib;
  }UNTIL (ib == 0x00);

  eatcmd(); //{...}

  genjplbl(_tmpendlbl); cmdlabel();
  _tmpendlbl = wastmpendlbl;
}

PROC eatcase()
//case <byteconst>:
{
  //rdword(); //byteconst

  //заполнить нумерованную метку перехода
  //procname.aab.#<_tword> = $ (пока без aab TODO)
  asmstr(_title); asmc('#'); asmstr(_tword); asmc('='); asmc('$'); endasm();

  rdword(); //skip ':' for C compatibility
  rdword(); //нужно!
}

FUNC BOOL eatcmd RECURSIVE() //возвращает +FALSE, если конец блока
{
{
 //начальная часть имени переменной уже прочитана
  adddots(); //дочитать имя
//чтобы реализовать объявления без VAR и FUNC, надо уже сейчас проверить тип метки TODO FAST!!!
  _c0 = *(PCHAR)_tword;
  IF ((_c0=='}') || _waseof) {
    rdword();
    _morecmd = +FALSE;
    _waswasreturn = _wasreturn;
    _wasreturn = +FALSE;
  }ELSE {
//    IF (_wasreturn) {
//      IF (_c0!=';') {errstr("cmd after return!"); enderr(); };
//    };
    IF (_cnext=='=') { //let
      eatlet();
    }ELSE IF ( (((BYTE)_cnext-0x28/**'('*/) | ((BYTE)_spcsize/**==0x00*/)) == 0x00) { //call
      do_call(/**isfunc*/+FALSE); rdword();
    }ELSE IF (_cnext=='[') { //let []
      eatlet();
    }ELSE IF ( _cnext==':' ) { //lbl
      eatlbl();
    }ELSE IF (_cnext=='-') { //let ->
      eatlet();
    }ELSE {
      IF (_c0==';') {
        rdword(); //C compatibility
      }ELSE IF (_c0=='{') {
        rdword(); WHILE (eatcmd()) {};
      }ELSE {
        _c0 = (CHAR)((BYTE)_c0|0x20);
        IF       (_c0=='v') { //var
          rdword(); eatvar(/**ispar*/+FALSE, /**body*/+TRUE);
          _isexp = +FALSE; //нельзя внутрь, иначе не экспортируются параметры процедуры
        }ELSE IF (_c0=='f') { //func
          rdword(); eatfunc(+TRUE, _curfunct, _wasreturn);
        }ELSE IF ( _c0=='w' ) { //while
          rdword(); eatwhile();
        }ELSE IF ( _c0=='b' ) { //break
          rdword(); eatbreak(); //no parameters (rds nothing)
        }ELSE {
        _c2 = (CHAR)((BYTE)_tword[2]|0x20);
        IF (_c0=='c') { //const //case //call
          IF (_c2=='n') { //const
            rdword(); eatconst();
          }ELSE IF (_c2=='l') { //call
            rdword(); eatcallpoi();
          }ELSE { //case
            rdword(); eatcase();
          };
        }ELSE IF (_c0=='p') { //proc //poke
          IF (_c2=='o') { //proc
            rdword(); eatfunc(+FALSE, _curfunct, _wasreturn);
          }ELSE { //poke
            rdword(); eatpoke();
          };
        }ELSE IF (_c0=='r') { //return //repeat
          IF (_c2=='t') { //return
            rdword(); eatreturn();
          }ELSE { //repeat
            rdword(); eatrepeat();
          };
        }ELSE IF ( _c0=='d' ) { //dec
          rdword(); eatdec();
        }ELSE IF ( _c0=='i' ) { //inc //if
          IF ( _c2=='c' ) { //inc
            rdword(); eatinc();
          }ELSE { //if
            rdword(); eatif();
          };
        }ELSE IF (_c0=='e') { //enum //extern //export //evar
          IF (_c2=='t') { //extern
            rdword(); eatextern();
          }ELSE IF (_c2=='p') { //export
            rdword(); _isexp = +TRUE;
          }ELSE IF (_c2=='a') { //evar
            rdword(); eatevar();
          }ELSE { //enum
            rdword(); eatenum();
          };
        }ELSE IF ( _c0=='g' ) { //goto
          rdword(); eatgoto();
        }ELSE IF ( _c0=='a' ) { //asm
          rdword(); eatasm();
        }ELSE IF ( _c0=='s' ) { //struct //switch
          IF (_c2=='r') { //struct
            rdword(); eatstruct();
          }ELSE { //switch
            rdword(); eatswitch();
          };
//        }ELSE IF ( _c0=='m' ) { //module
//          rdword(); eatmodule();
        }ELSE IF ( _c0=='t' ) { //typedef <type> <name>
          rdword();
          eattype();
          _lenname = strcopy(_tword, _lentword, _name);
          addlbl(_T_TYPE + _t, /**isloc*/+FALSE, (UINT)_typesz[_t]);
          rdword(); //использовали имя
        }ELSE IF ( _c0=='#' ) { //define, include... (сюда попадаем даже в неактивных ветках условной компиляции)
          rdword(); //define, undef, include, if, else, [elif], ifdef, ifndef, endif, [import], [line], [error], [pragma]
//вложенная условная компиляция:
//_doskipcond в битовом виде помнит, сколько уровней активных ifdef и сколько уровней неактивных (кроме текущего)
//(внутри неактивного могут быть только неактивные)
//если (_doskipcond&1) == 0 (т.е. мы в неактивной ветке), то текущий ifdef игнорируется со всеми входящими (т.е. else не работает)
//неактивность текущей ветки ifdef лежит в _doskip
//на верхнем уровне _doskipcond = 1, _doskip = +FALSE
//если ifdef, то:
  //_doskipcond = _doskipcond+_doskipcond
  //если !_doskip, то:
    //INC _doskipcond;
    //если ifdef не годен, то _doskip = +TRUE
//если else и ((_doskipcond&1) != 0), то _doskip = !_doskip
//если endif, то _doskip = ((_doskipcond&1) == 0); _doskipcond = _doskipcond>>1
          _c2 = _tword[2];
          IF ((_c2 == 'c')&&(!_doskip)) { //include
            rdword(); //"
            _lentword = 0;
            rdquotes('\"'/**, +FALSE*/); //IF (_c0 == '\"') { rdquotes('>'); }ELSE rdquotes('\"');
            _hinclfile[_nhinclfiles] = _fin;
            _hnline[_nhinclfiles] = _curline;
            INC _nhinclfiles; compfile(_tword); DEC _nhinclfiles;
            _fin = _hinclfile[_nhinclfiles];
            _curline = _hnline[_nhinclfiles];
            _waseof = +FALSE;
            rdch(); //пропустить закрывающую кавычку
          }ELSE IF (_c2 == 'd') { //ifdef/endif/undef
            IF (*(PCHAR)_tword == 'e') { //endif
              //_doskip = +FALSE; //todo вложенность (подсчёт числа ифов)
              _doskip = ((_doskipcond&1) == 0);
              _doskipcond = _doskipcond>>1;
//erruint(_doskipcond); errstr("#endif "); erruint((UINT)_doskip); enderr();
            }ELSE IF (*(PCHAR)_tword == 'i') { //ifdef
              _doskipcond = _doskipcond+_doskipcond;
              rdword(); //имя
              _lenname = strcopy(_tword, _lentword, _name);
              //_t = lbltype(); //если нету, то _T_UNKNOWN
              IF (!_doskip) {
                INC _doskipcond; //не игнорируем этот ifdef
                //нет метки - пропустить тело
                _doskip = (lbltype() == _T_UNKNOWN); //включить пропуск строк, кроме начинающихся с #, а здесь обрабатывать только их
              };
//erruint(_doskipcond); errstr("#ifdef "); erruint((UINT)_doskip); enderr();
            }ELSE { //undef
              rdword(); //имя
              _lenname = strcopy(_tword, _lentword, _name);
              dellbl();
            };
          }ELSE IF (_c2 == 'n') { //ifndef
              _doskipcond = _doskipcond+_doskipcond;
              rdword(); //имя
              _lenname = strcopy(_tword, _lentword, _name);
              //_t = lbltype(); //если нету, то _T_UNKNOWN
              IF (!_doskip) {
                INC _doskipcond; //не игнорируем этот ifndef
                //есть метка - пропустить тело
                _doskip = (lbltype() != _T_UNKNOWN); //включить пропуск строк, кроме начинающихся с #, а здесь обрабатывать только их
              };
          }ELSE IF (_c2 == 's') { //else
            //_doskip = !_doskip;
            IF ((_doskipcond&1) != 0) _doskip = !_doskip; //не игнорируем этот ifdef
//erruint(_doskipcond); errstr("#else "); erruint((UINT)_doskip); enderr();
          }ELSE IF ((_c2 == 'f')&&(!_doskip)) { //define
            rdword(); //имя
            twordtojoined(); //_lenjoined = strcopy(_tword, _lentword, _joined);
            rdword(); //значение или (
            IF (*(PCHAR)_tword == '(') { //TODO эту конструкцию применить и в const
              rdword(); //eat('(');
              eattype();
              eat(')');
              rdquotes(')');
              rdch(); //добавляем закрывающую скобку
              _tword[_lentword] = '\0'; //strclose(_tword, _lentword);
            }ELSE {
              numtype(); //_t
            };
            _lenname = strcopy(_joined, _lenjoined, _name);
            addlbl(_t|_T_CONST, /**isloc*/+FALSE, (UINT)_typesz[_t/**&_TYPEMASK*/]/**, _ncells, _lenncells*/); //(_name) //TODO размер массива или структуры!
            emitvarpreequ(_name);
            varequ(_name); /**varstr(_name); varc( '=' );*/ varstr(_tword); endvar();
            emitvarpostequ();
          };

          //rdchcmt(); //rdaddword(); //используем первый символ знака комментария, читаем следующий символ
          WHILE (_waseols==0/** && !_waseof*/ ) {
            rdchcmt(); //пропускает все ентеры
          };
          _tword[_lentword] = '\0'; //strclose(_tword, _lentword); //todo нарушена парность clear..close
          IF ((BYTE)_cnext < (BYTE)'!') {
            rdch(); //используем последний символ комментария, читаем следующий символ (TODO унифицировать как /* */)
          };
          rdword();
        }ELSE {
          errstr("WRONG CMD "); errstr(_tword); enderr();
          rdword();
        };
        };
      };
    }; //not a headless cmd
    _morecmd = +TRUE;
  }; //not '{'
}
RETURN _morecmd;
}

PROC compfile RECURSIVE(PCHAR fn)
{
  _fin = nfopen(fn, "rb");
  IF (_fin != (PBYTE)0) {
    strpush(_fn,_lenfn);
    _lenfn = strjoineol(_fn, 0/**_lenfn*/, fn, '\0');
    _fn[_lenfn] = '\0';
    _waseof = +FALSE;

    _curline = 1;
    initrd();
    rdword();

    WHILE (eatcmd()) {};

    fclose(_fin);
    _lenfn = strpop(_fn);
  }ELSE {
    errstr("no file "); errstr(fn); enderr();
  };
}

FUNC UINT strjoineollast(PCHAR to, UINT tolen, PCHAR s2/**, UINT s2len*/, CHAR eol) //длина без терминатора!
{ //to = to + s2;
VAR UINT len;
VAR UINT last;
VAR CHAR c;
  to = &to[tolen];
  len = tolen; //длина без терминатора!
  last = 0; //после последнего терминатора
  loop:
    c = *(PCHAR)s2;
    IF ((c == '\0') || (len>=_STRMAX)) goto endloop; //терминатор не копируется
    POKE *(PCHAR)(to) = c;
    INC s2;
    IF (c == eol) last = len;
    INC to;
    INC len;
  goto loop; //терминатор не копируется
  endloop:
RETURN last; //после последнего терминатора
}

PROC compile(PCHAR fn)
{
  //_jplbl = 0; //не сбрасываем нумерацию автометок переходов (без префикса), т.к. может быть несколько файлов
  _doskipcond = 1;

  _prefix = (PCHAR)_s1; //заполняется в doprefix: module/func/const/var/extern - локально, joinvarname
  _title  = (PCHAR)_s2;
  _callee = (PCHAR)_s3;
  _name   = (PCHAR)_s4;
  _joined = (PCHAR)_s5;
  _ncells = (PCHAR)_s6;
  _callee2= (PCHAR)_s7;

  _fn = (PCHAR)_m_fn;
  _lenfn = 0;

  _tmpendlbl = 0; //чтобы никогда не совпало (break вне функции выдаст ошибку в асме)
  _lenstrstk = 0;
  _curlbl = 0; //сбрасываем нумерацию автометок (для массивов строк)

  initlblbuf();

  _lenname = strcopy("INT", 3, _name);
  addlbl(_T_TYPE + _T_INT, +FALSE, (UINT)_typesz[_T_INT]);
  _lenname = strcopy("UINT", 4, _name);
  addlbl(_T_TYPE + _T_UINT, +FALSE, (UINT)_typesz[_T_UINT]);
  _lenname = strcopy("BYTE", 4, _name);
  addlbl(_T_TYPE + _T_BYTE, +FALSE, (UINT)_typesz[_T_BYTE]);
  _lenname = strcopy("BOOL", 4, _name);
  addlbl(_T_TYPE + _T_BOOL, +FALSE, (UINT)_typesz[_T_BOOL]);
  _lenname = strcopy("LONG", 4, _name);
  addlbl(_T_TYPE + _T_LONG, +FALSE, (UINT)_typesz[_T_LONG]);
  _lenname = strcopy("CHAR", 4, _name);
  addlbl(_T_TYPE + _T_CHAR, +FALSE, (UINT)_typesz[_T_CHAR]);
  _lenname = strcopy("FLOAT", 5, _name);
  addlbl(_T_TYPE + _T_FLOAT, +FALSE, (UINT)_typesz[_T_FLOAT]);
  _lenname = strcopy("STRUCT", 6, _name);
  addlbl(_T_TYPE + _T_STRUCTWORD, +FALSE, (UINT)_typesz[_T_STRUCT]);
  _lenname = strcopy("PINT", 4, _name);
  addlbl(_T_TYPE + _T_POI + _T_INT, +FALSE, (UINT)_typesz[_T_POI]);
  _lenname = strcopy("PUINT", 5, _name);
  addlbl(_T_TYPE + _T_POI + _T_UINT, +FALSE, (UINT)_typesz[_T_POI]);
  _lenname = strcopy("PBYTE", 5, _name);
  addlbl(_T_TYPE + _T_POI + _T_BYTE, +FALSE, (UINT)_typesz[_T_POI]);
  _lenname = strcopy("PBOOL", 5, _name);
  addlbl(_T_TYPE + _T_POI + _T_BOOL, +FALSE, (UINT)_typesz[_T_POI]);
  _lenname = strcopy("PLONG", 5, _name);
  addlbl(_T_TYPE + _T_POI + _T_LONG, +FALSE, (UINT)_typesz[_T_POI]);
  _lenname = strcopy("PCHAR", 5, _name);
  addlbl(_T_TYPE + _T_POI + _T_CHAR, +FALSE, (UINT)_typesz[_T_POI]);
  _lenname = strcopy("PFLOAT", 6, _name);
  addlbl(_T_TYPE + _T_POI + _T_FLOAT, +FALSE, (UINT)_typesz[_T_POI]);
  //_lenname = strcopy("PPROC", 5, _name);
  //addlbl(_T_TYPE + _T_POI + _T_PROC, +FALSE, (UINT)_typesz[_T_POI]);

  _lentitle = 0;
  POKE *(PCHAR)(_title) = '\0'; //strclose(_title, _lentitle);
  _namespclvl = 0x00;
  //_exprlvl = 0x00; //сейчас везде расставлено 0 (можно оптимизировать сравнения) или 1 (нельзя) или inc-dec (для вложенных вычислений тоже нельзя)

 _addrexpr = +FALSE;
  _isexp = +FALSE;
  _curfunct = _T_UNKNOWN; //на всякий случай
  _pushlvl = 0x00;
  _wasreturn = +FALSE;

   _lenjoined = strjoineollast(_joined, 0, fn, '.');
   _lenjoined = strjoin(_joined, _lenjoined, ".ast");
   _joined[_lenjoined] = '\0';
  _fout = openwrite(_joined);

   _lenjoined = strjoineollast(_joined, 0, fn, '.');
   _lenjoined = strjoin(_joined, _lenjoined, ".var");
   _joined[_lenjoined] = '\0';
  _fvar = openwrite(_joined);

  _nhinclfiles = 0x00;

  initcmd();
  initcode(); //вызывает emitregs
  compfile(fn);
  endcode();

  fclose(_fvar);
  fclose(_fout);
}
