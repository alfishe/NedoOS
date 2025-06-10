//токенизатор не знает коды команд
//токенизатор не подглядывает вперёд и не отматывает назад
//_asmwaseol генерируется в asmrdword_tokspc(), а eol выводится после команды

//// imported
#include "../_sdk/str.h"
#include "../_sdk/io.h"

VAR UINT _curlnbeg; //номер строки на момент начала токена //для read, emit
VAR BOOL _cmts; //для read, emit

CONST BOOL _isalphanum[256];
VAR CHAR txt_low[10];

EXTERN PCHAR _tword; //текущее слово
EXTERN UINT _lentword;
//EXTERN CHAR _s0[_STRLEN]; //текущее слово

EXTERN BOOL _waseof;
EXTERN PBYTE _fin;
EXTERN PBYTE _fout;
FUNC BYTE readfin FORWARD();

EXTERN UINT _curline; //текущий номер строки
EXTERN UINT _waseols; //число EOL с прошлого раза
EXTERN UINT _spcsize; //число пробелов после прочитанной команды
EXTERN CHAR _cnext;

FUNC UINT stradd FORWARD(PCHAR s, UINT len, CHAR c);
FUNC BOOL strcplow FORWARD(PCHAR s1, PCHAR s2);

PROC rdchcmt FORWARD();
PROC rdch FORWARD();
PROC rdquotes FORWARD(CHAR eol);
PROC initrd FORWARD();

CONST BYTE _ASMMAXSPC;

PROC tokpre FORWARD(); //заполнить таблицу меток

////
VAR CHAR _c1small;
VAR CHAR _c2small;
VAR BOOL _asmwaseof;
VAR UINT _asmwaseols; //число EOL с прошлого раза
VAR UINT _asmspcsize;

VAR CHAR _stokfn[_STRLEN]; //текущее слово
VAR PCHAR _tokfn; //текущее слово
VAR UINT _lentokfn;

VAR BYTE _temppar;

#define _TOKLBLBUFSIZE 0x1200
VAR UINT _toklblbuffreestart; //[1];
//VAR UINT _tokoldlblbuffreestart; //[1];
CONST UINT _TOKLBLBUFEOF = 0xffff;
//CONST UINT _TOKLBLBUFMAXSHIFT  = 0x1fb0/**(_LBLBUFSIZE-0x0100)*/; //0x3f00
#define _TOKLBLBUFMAXSHIFT (UINT)(_TOKLBLBUFSIZE-_STRLEN-10)
//todo динамически выделить
VAR UINT _toklblshift[0x100];
//VAR UINT _tokoldlblshift[0x100];
VAR BYTE _toklbls[_TOKLBLBUFSIZE]; //0x4000
VAR BYTE _toklblhash;

PROC rdaddwordall() //подклеить следующую команду к текущей
{
  _spcsize = 0; //число пробелов после прочитанной команды
  _waseols = 0;
  _curlnbeg = _curline;

  IF (_isalphanum[(BYTE)_cnext] ) { //слово с цифробуквы
    REPEAT { //ждём нецифробукву (EOF не цифробуква)
      IF ((BYTE)_lentword != (BYTE)_STRMAX) { //в асме из компилятора все слова короче, но не в ручном асме
        _tword[_lentword] = _cnext;
        INC _lentword;
      };
      _cnext = (CHAR)readfin();
    }UNTIL (!_isalphanum[(BYTE)_cnext]/** || _waseof*/ );
  }ELSE { //слово из нецифробуквенного символа - читаем одну нецифробукву (иначе бы не читали)
    //rdch(); //читаем всю группу диерезисов + символ как один символ
    IF ((BYTE)_lentword != (BYTE)_STRMAX) { //в асме из компилятора все слова короче, но не в ручном асме
      _tword[_lentword] = _cnext;
      INC _lentword;
    };
    _cnext = (CHAR)readfin();
  }; //нельзя подклеить это условие к циклу, т.к. оно для изначального cnext и один раз

  goto loopgo;
  loop: //REPEAT { //ждём недиерезис или EOF
    _cnext = (CHAR)readfin();
  loopgo:
    IF ((BYTE)_cnext < (BYTE)'!') { //ускорение выхода
      INC _spcsize; //spaces after tword
      IF ((BYTE)_cnext == 0x0a) {
        INC _curline;
        _spcsize = 0;
        INC _waseols;
      }ELSE IF ((BYTE)_cnext == 0x09) {
        _spcsize = _spcsize + 7;
      };
      IF (!_waseof) goto loop;
    };
  //}UNTIL (_wasdieresis || _waseof );
  _tword[_lentword] = '\0';
}
/**
PROC rdwordall()
//читаем слово _tword (из текста с диерезисами вместо пробелов, ентеров, табуляций)
//слово заканчивается, когда диерезис или нецифробуквенный символ (он попадёт в cnext, а курсор в файле после него)
{
  _lentword = 0; //strclear(_tword); //todo нарушена парность clear..close
  rdaddwordall();
}
*/
//////////////////

PROC asmtoken(BYTE token)
{
  writebyte(_fout, token);
}

PROC tokspc()
{
//IF (!_waseol) { //глюк на командах из одного слова
  WHILE (_asmspcsize > (UINT)_ASMMAXSPC) { //число пробелов после прочитанной команды
    asmtoken(+_TOKSPC0+_ASMMAXSPC);
    _asmspcsize = _asmspcsize - (UINT)_ASMMAXSPC;
  };
  IF (_asmspcsize!=0) asmtoken(+_TOKSPC0 + (BYTE)_asmspcsize);
//};
}

PROC asmrdword_tokspc() //токенизирует пробелы после прошлой команды и читает новую
//todo выдавать eol как команду?
{
  _asmwaseof = _waseof;
  _asmwaseols = _waseols;
  _asmspcsize = _spcsize; //число пробелов после прочитанной команды
  IF (_waseols==0) tokspc(); //токенизируем пробелы после прошлой команды (иначе откладываем на после eol)
  //rdwordall();
  _lentword = 0/**strclear(_tword)*/; //todo нарушена парность clear..close
  rdaddwordall();
  _c1small = (CHAR)((BYTE)(*(PCHAR)_tword)|0x20);
  _c2small = (CHAR)((BYTE)_tword[1]|0x20);
}

PROC toktext() //генерирует <text>text<endtext>
{
  asmtoken(+_TOKTEXT);
  fputs(_tword, _fout);
  asmtoken(+_TOKENDTEXT);
}

//сгенерировать токен ошибки с текстами отсюда до конца инструкции/строки (включая _tword)
//включая последнюю команду в строке, которая с waseol или которая ':'
PROC tokerr(BYTE token)
{
  asmtoken(+_ERR);
  asmtoken(token);
  WHILE (+TRUE) {
    toktext(); //генерирует <text>text<endtext>
    IF ((_waseols!=0)||(_waseof)||(*(PCHAR)_tword==':')) BREAK;
    asmrdword_tokspc();
  }; //TODO в одну строку
  asmtoken(+_TOKENDERR);
  asmrdword_tokspc(); //[токенизирует конечные пробелы или EOL,] берёт следующую команду (после инструкции)
  //todo asmfmt_err?
}

//сгенерировать токен ошибки с текстом отсюда до конца строки (включая _tword)
//или до конца команды???
PROC tokerrcmd()
{
  tokerr(+_ERRCMD); //todo сделать asmcmd_err...asmfmt_err вокруг?
}

PROC tokinitlblbuf()
{
  _toklblhash = 0x00;
  REPEAT {
    _toklblshift[_toklblhash] = _TOKLBLBUFEOF;
    INC _toklblhash;
  }UNTIL (_toklblhash == 0x00);
  _toklblbuffreestart = 0;
};

PROC tokcalllbl()
{
VAR PBYTE plbl; //метка в таблице заканчивается нулём
//VAR PBYTE pstr; //метка в строке заканчивается нулём
//VAR BYTE cstr; //символ из строки
//VAR BYTE clbl; //символ из таблицы меток
//VAR BOOL res;
VAR UINT plbl_idx;
VAR PBYTE calladdr;
  //res = +FALSE;
  _toklblhash = (BYTE)hash((PBYTE)_tword);

  plbl_idx = _toklblshift[_toklblhash];
  WHILE (plbl_idx != _TOKLBLBUFEOF) { //пока цепочка меток не закончилась
    plbl = &_toklbls[plbl_idx];
    plbl_idx = *(PUINT)(plbl);
    plbl = &plbl[+sizeof(UINT)/**+1*/]; //skip string size
    IF (strcp((PCHAR)_tword, (PCHAR)plbl)) { //метка найдена
      plbl = &plbl[10/**_lenname+1*/];
      calladdr = (PBYTE)*(PLONG)(plbl); //todo PPOI
      plbl = &plbl[+sizeof(LONG)]; //todo POI
      _temppar = *(PBYTE)(plbl);
      //INC plbl;
      CALL (calladdr);
      //res = +TRUE;
      //BREAK;
      goto e;
    };
  };
  tokerrcmd(); //not found
  e: ; //RETURN res;
//asmtoken(0xfd);
}

PROC tokaddlbl1(PCHAR txt, PBYTE proc, BYTE data)
{
VAR PBYTE plbl;
//VAR UINT freestart_idx;
//VAR UINT plbl_idx;
  _toklblhash = (BYTE)hash((PBYTE)txt);

  //метки нет: пишем в начало цепочки адрес конца страницы и создаём метку там со ссылкой на старое начало цепочки
  //freestart_idx = _toklblbuffreestart; //[0] //начало свободного места
  //plbl_idx = _toklblbuffreestart; //[0] //freestart_idx; //указатель на начало данных создаваемой метки (надо обязательно запомнить!) //начало свободного места
  plbl = &_toklbls[_toklblbuffreestart]; //[0] [plbl_idx]; //указатель на начало создаваемой метки //начало свободного места
  //пишем метку
  POKE *(PUINT)(plbl) = _toklblshift[_toklblhash]; //старый указатель на начало цепочки
  _toklblshift[_toklblhash] = _toklblbuffreestart; //[0] //freestart_idx; //новый указатель на начало цепочки //начало свободного места
  plbl = &plbl[+sizeof(UINT)];
  //POKE *(PBYTE)(plbl) = (BYTE)10/**(BYTE)_lenname*/;
  //INC plbl;
  strcopy(txt, 9/**_lenname*/, (PCHAR)plbl);
  plbl = &plbl[10/**_lenname+1*/];
  POKE *(PLONG)(plbl) = (LONG)proc; //todo PPOI
  plbl = &plbl[+sizeof(LONG)]; //todo POI
  POKE *(PBYTE)(plbl) = data;
  //INC plbl;
  //plbl_idx = (UINT)(plbl - _toklbls); //указатель конец создаваемой метки
  //_toklblshift[_toklblhash] = freestart_idx; //новый указатель на начало цепочки
  //_toklblbuflen = _toklblbuflen + plbl_idx - freestart_idx;
  _toklblbuffreestart = (UINT)(plbl - _toklbls) + 1; //указатель конец создаваемой метки //plbl_idx; /**[0]*/
  //INC _toklblcount;
}

PROC stringdecapitalize(PCHAR s1, PCHAR s2)
{
VAR CHAR c;
  loop:
    c = *(PCHAR)s1;
    IF (((BYTE)c>=(BYTE)'A') && ((BYTE)c<=(BYTE)'Z')) {
      c = (CHAR)((BYTE)c | 0x20);
    };
    POKE *(PCHAR)(s2) = c;
    INC s1;
    INC s2;
    IF (c != '\0') goto loop;
}

PROC tokaddlbl(PCHAR txt, PBYTE proc, BYTE data)
{
  tokaddlbl1(txt, proc, data);
  stringdecapitalize(txt, txt_low);
  tokaddlbl1(txt_low, proc, data);
}

//////////////////////////////////////
//если match сработал, то _tword съедается (читается следующая) и выводится соответствующий токен
//если не сработал, то _tword не съедается, ошибка не выдаётся (только флаг +FALSE)
//если ошибка, то ошибка не выдаётся (только флаг +FALSE)

    //reg и rp могут встретиться в одной позиции в inc,dec,[ld],[add],[adc],[sbc]
    //иначе либо reg (b,c,d,e,h,l,a,hx,lx,hy,ly, но не i,r!), либо rp (bc,de,hl,sp,ix,iy, но не af!)
    //i,r и af обрабатывать отдельно, т.к. надо только для некоторых команд, остальные команды не должны проверять эту ошибку при самой компиляции

FUNC BOOL matchdirect()
{
  IF (*(PCHAR)_tword=='#') {
    asmtoken(+_TOKDIRECT);
    asmrdword_tokspc();
    RETURN +TRUE;
  };
RETURN +FALSE;
}

FUNC BOOL matchcomma()
{
  IF (*(PCHAR)_tword==',') {
    asmtoken(+_TOKCOMMA);
    asmrdword_tokspc();
    RETURN +TRUE;
  };
RETURN +FALSE;
}

FUNC BOOL matchprime()
{
  IF (*(PCHAR)_tword=='\'') {
    asmtoken(+_TOKPRIMESYM);
    asmrdword_tokspc();
    RETURN +TRUE;
  };
RETURN +FALSE;
}

FUNC BOOL matchquote()
{
  IF (*(PCHAR)_tword=='\"') {
    asmtoken(+_TOKDBLQUOTESYM);
    //asmrdword_tokspc();
    RETURN +TRUE;
  };
RETURN +FALSE;
}

FUNC BOOL matchreequ()
{
  IF ( (*(PCHAR)_tword=='=') || ((_c1small=='e')&&(_c2small=='q')) ) {
    asmtoken(+_TOKEQUAL/**'='*/);
    asmrdword_tokspc();
    RETURN +TRUE;
  };
RETURN +FALSE;
}

FUNC BOOL matchopen()
{
  IF       (*(PCHAR)_tword=='(') {asmtoken(+_TOKOPEN); asmrdword_tokspc(); RETURN +TRUE;
  }ELSE IF (*(PCHAR)_tword=='[') {asmtoken(+_TOKOPENSQ); asmrdword_tokspc(); RETURN +TRUE;
  };
RETURN +FALSE;
}

FUNC BOOL matchclose()
{
  IF       (*(PCHAR)_tword==')') {asmtoken(+_TOKCLOSE); asmrdword_tokspc(); RETURN +TRUE;
  }ELSE IF (*(PCHAR)_tword==']') {asmtoken(+_TOKCLOSESQ); asmrdword_tokspc(); RETURN +TRUE;
  };
RETURN +FALSE;
}

//////////////////////////////////////
FUNC BOOL tokexpr RECURSIVE FORWARD();

PROC eatlabel(BYTE token)
{
  WHILE ((_cnext=='.')||(_cnext=='#')) {
    rdaddwordall(); //приклеить точку
    IF (_spcsize==0)
      IF (_isalphanum[(BYTE)_cnext]) //было isalpha
        IF (_waseols==0)
          //IF (!_waseof)
            rdaddwordall(); //приклеить следующее слово
  };
  asmtoken(token/**_TOKLABEL или _CMDLABEL*/);
  asmtoken(+_TOKTEXT);
  fputs(_tword, _fout);
  asmtoken(+_TOKENDTEXT);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  //если метка была последним словом в строке, тогда этой токенизацией мы забыли бы про ентер (он теперь в _asmwaseol)
}

PROC eatval RECURSIVE() //должен читать, но не съедать символ конца выражения (скобка, запятая, конец строки)
//<val>::=
//(<expr>) //выражение (вычисляется)
//|<num> //десятичное число (передаётся целиком)
//|<var> //метка или параметр макроса (TODO не соответствует языку: там это &<var>)
//|$
//|'CHAR' //символьная константа
//|-<val> //вычислить val, потом сделать NEG
//|+<val> //вычислить val
//|~<val> //вычислить val, потом сделать INV
//|!<val> //вычислить val, потом сделать INV(BOOL)
//|*<val> //прочитать память по адресу (вычислить val, потом сделать PEEK)
{ //команда уже прочитана
VAR CHAR opsym;
{
  opsym = *(PCHAR)_tword;
  IF (!_asmwaseof) { //защита от зацикливания в конце ошибочного файла
    IF ((BYTE)((BYTE)opsym - (BYTE)'0') < 0x0a) { //<num> //выдаёт <num><text>digits<endtext> //extra BYTE for C bug
      asmtoken(+_TOKNUM);
      asmtoken(+_TOKTEXT);
//for float:
      IF (_cnext=='.') {
        rdaddwordall(); //приклеить точку
        rdaddwordall(); //приклеить дробную часть
        IF ( (_tword[_lentword-1]=='e') && (_cnext=='-') ) {
          rdaddwordall(); //приклеить '-' отрицательной экспоненты
          rdaddwordall(); //приклеить отрицательную экспоненту
        };
/*        asmrdword_tokspc();
        fputs(_tword, _fout);
        asmrdword_tokspc();*/ //todo e-12
      };
      fputs(_tword, _fout);
      asmtoken(+_TOKENDTEXT);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
      //если число было последним словом в строке, тогда этой токенизацией мы забыли бы про ентер (он теперь в _asmwaseol)
    }ELSE IF (_isalphanum[(BYTE)opsym] || (opsym=='.') ) { //todo убрать '.', если запретить начинать метки с точки //было isalpha
      eatlabel(+_TOKLABEL);
    }ELSE IF ( opsym=='$' ) {
      asmtoken(+_TOKDOLLAR);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
    }ELSE IF ( opsym=='(' ) {
      asmtoken(+_TOKOPEN);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
      tokexpr(); //рекурсия //на выходе из expr уже прочитана ')', но следующий символ или команда не прочитаны
      asmtoken(+_TOKCLOSE);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
    }ELSE IF ( opsym=='\'' ) { //todo вставить TOK_TEXT...TOK_ENDTEXT
      asmtoken(+_TOKPRIME);
      _lentword = 0/**strclear(_tword)*/; //читаем с пустой строки
      rdquotes('\''/**, +FALSE*/);
      toktext(); //генерирует <text>text<endtext>
      rdch(); //пропустить закрывающую кавычку
      asmtoken(+_TOKPRIME);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
    }ELSE IF ( opsym=='-' ) {
      asmtoken(+_OPPUSH0); asmtoken(+_TOKMINUS/**'-'*/);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
      eatval(); //рекурсивный вызов val
      asmtoken(+_OPSUB);
    }ELSE IF ( opsym=='+' ) {
      asmtoken(+_OPPUSH0); asmtoken(+_TOKPLUS/**'+'*/);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
      eatval(); //рекурсивный вызов val
      asmtoken(+_OPADD);
    }ELSE IF ( opsym=='*' ) {
      asmtoken(+_OPPUSH0); asmtoken(+_TOKSTAR/**'*'*/);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
      eatval(); //рекурсивный вызов val
      asmtoken(+_OPPEEK);
    }ELSE IF ( opsym=='~' ) {
      asmtoken(+_OPPUSH0); asmtoken(+_TOKTILDE);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
      eatval(); //рекурсивный вызов val
      asmtoken(+_OPINV);
    }ELSE IF ( opsym=='!' ) {
      asmtoken(+_OPPUSH0); asmtoken(+_TOKEXCL);
      asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
      eatval(); //рекурсивный вызов val
      asmtoken(+_OPINV); //todo BOOL
    }ELSE { tokerr(+_ERREXPR);/**errstr( ">>>WRONG PREFIX " ); err( opsym ); enderr();*/ };
  };
}
}

PROC eatmul()
{
  /**asmtoken(_ASMOPPUSHSKIP1);*/ asmtoken(+_TOKSTAR/**'*'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPMUL);
}

PROC eatdiv()
{
  /**asmtoken(_ASMOPPUSHSKIP1);*/ asmtoken(+_TOKSLASH/**'/'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPDIV);
}

PROC eatand()
{
  /**asmtoken(_ASMOPPUSHSKIP1);*/ asmtoken(+_TOKAND/**'&'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPAND);
}

PROC eatandbool()
{
  /**asmtoken(_ASMOPPUSHSKIP2);*/ asmtoken(+_TOKAND/**'&'*/); asmtoken(+_TOKAND/**'&'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPAND);
}

PROC eatmulval RECURSIVE() //должен читать, но не съедать символ конца выражения (скобка, запятая, конец строки)
{ //команда уже прочитана
VAR CHAR opsym;
VAR BOOL dbl;
{
  eatval(); //должен читать, но не съедать символ конца выражения
  WHILE ((!_asmwaseof)&&(_asmwaseols==0)) { //уже прочитана операция и пробелы-ентеры после неё (_asmwaseol - ентер после val)
    opsym=*(PCHAR)_tword;
    dbl = (opsym=='&')&&(_cnext==opsym); //C compatibility
    IF (dbl) asmrdword_tokspc(); //use '&' //C compatibility
    IF       (opsym=='*') {eatmul();
    }ELSE IF (opsym=='/') {eatdiv();
    }ELSE IF (opsym=='&') {
      IF (dbl) {eatandbool();
      }ELSE eatand();
    }ELSE BREAK;
  };
}
}

PROC eatadd()
{
  /**asmtoken(_ASMOPPUSHSKIP1);*/ asmtoken(+_TOKPLUS/**'+'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatmulval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPADD);
}

PROC eatsub()
{
  /**asmtoken(_ASMOPPUSHSKIP1);*/ asmtoken(+_TOKMINUS/**'-'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatmulval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPSUB);
}

PROC eator()
{
  /**asmtoken(_ASMOPPUSHSKIP1);*/ asmtoken(+_TOKPIPE/**'|'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatmulval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPOR);
}

PROC eatorbool()
{
  /**asmtoken(_ASMOPPUSHSKIP2);*/ asmtoken(+_TOKPIPE/**'|'*/); asmtoken(+_TOKPIPE/**'|'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatmulval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPOR);
}

PROC eatxor()
{
  /**asmtoken(_ASMOPPUSHSKIP1);*/ asmtoken(+_TOKCARON/**'^'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatmulval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPXOR);
}

PROC eatxorbool()
{
  /**asmtoken(_ASMOPPUSHSKIP2);*/ asmtoken(+_TOKCARON/**'^'*/); asmtoken(+_TOKCARON/**'^'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatmulval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPXOR);
}

PROC eatsumval RECURSIVE() //должен читать, но не съедать символ конца выражения (скобка, запятая, конец строки)
{ //команда уже прочитана
VAR CHAR opsym;
VAR BOOL dbl;
{
  eatmulval(); //должен читать, но не съедать символ конца выражения
  WHILE ((!_asmwaseof)&&(_asmwaseols==0)) { //уже прочитана операция и пробелы-ентеры после неё (_asmwaseol - ентер после val)
    opsym=*(PCHAR)_tword;
    dbl = ( (opsym=='|')||(opsym=='^') )&&(_cnext==opsym); //C compatibility
    IF (dbl) asmrdword_tokspc(); //use '|' or '^' //C compatibility
    IF (opsym=='+') {eatadd();
    }ELSE IF (opsym=='-') {eatsub();
    }ELSE IF (opsym=='|') {
      IF (dbl) {eatorbool();
      }ELSE eator();
    }ELSE IF (opsym=='^') {
      IF (dbl) {eatxorbool();
      }ELSE eatxor();
    }ELSE BREAK;
  };
}
}

PROC eatshl()
{
  /**asmtoken(_ASMOPPUSHSKIP2);*/ asmtoken(+_TOKLESS/**'<'*/); asmtoken(+_TOKLESS/**'<'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatsumval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPSHL);
}

PROC eatshr()
{
  /**asmtoken(_ASMOPPUSHSKIP2);*/ asmtoken(+_TOKMORE/**'>'*/); asmtoken(+_TOKMORE/**'>'*/);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatsumval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPSHR);
}

PROC eatless()
{
  asmtoken(+_TOKLESS);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatsumval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPLESS);
}

PROC eatlesseq()
{
  asmtoken(+_TOKLESS); asmtoken(+_TOKEQUAL);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatsumval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPLESSEQ);
}

PROC eatmore()
{
  asmtoken(+_TOKMORE);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatsumval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPMORE);
}

PROC eatmoreeq()
{
  asmtoken(+_TOKMORE); asmtoken(+_TOKEQUAL);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatsumval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPMOREEQ);
}

PROC eateq()
{
  asmtoken(+_TOKEQUAL); asmtoken(+_TOKEQUAL);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatsumval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPEQ);
}

PROC eatnoteq()
{
  asmtoken(+_TOKEXCL); asmtoken(+_TOKEQUAL);
  asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  eatsumval(); //должен читать, но не съедать символ конца выражения
  asmtoken(+_OPNOTEQ);
}

FUNC BOOL tokexpr RECURSIVE() //должен читать, но не съедать символ конца выражения (скобка, запятая, конец строки)
{ //команда уже прочитана
VAR CHAR opsym;
VAR BOOL modified;
VAR BOOL dbl;
//VAR BOOL ok;
{
  //ok = +TRUE;
  matchdirect(); //пропуск '#'
  eatsumval(); //должен читать, но не съедать символ конца выражения
  WHILE ((!_asmwaseof)&&(_asmwaseols==0)) { //уже прочитана операция и пробелы-ентеры после неё (_asmwaseol - ентер после val)
    opsym = *(PCHAR)_tword;
    modified = (_cnext=='=');
    dbl = (_cnext==opsym);
    IF (modified||dbl) asmrdword_tokspc(); //use '=' or '>' or '<'
    IF (opsym=='<') {
      IF (dbl) {eatshl(); //старое сдвинуть столько раз, сколько гласит новое!
      }ELSE IF (modified) {eatlesseq();
      }ELSE {eatless();
      };
    }ELSE IF (opsym=='>') {
      IF (dbl) {eatshr(); //старое сдвинуть столько раз, сколько гласит новое!
      }ELSE IF (modified) {eatmoreeq();
      }ELSE {eatmore();
      };
    }ELSE IF (opsym=='=') {eateq();
    }ELSE IF (opsym=='!') {eatnoteq();
    }ELSE BREAK;
  };
}
RETURN +TRUE; //ok; //todo err
}

FUNC BOOL tokexpr_close() //после него ничего больше нельзя проверять, т.к. курсор мог сдвинуться
{
  IF (tokexpr()) { RETURN matchclose(); };
  RETURN +FALSE;
}

PROC asm_direct_expr_close_token(BYTE token)
{
  //if(matchdirect()) {
    IF (tokexpr()) {
      IF (matchclose()) {asmtoken(token);
      }ELSE tokerr(+_ERRCLOSE); //no closing bracket
    }ELSE tokerr(+_ERREXPR); //wrong expr
  //}else tokerr(_ERRPAR); //no direct
}

PROC tokcomment()
{
  asmtoken(+_TOKCOMMENT);
  _lentword = 0/**strclear(_tword)*/; //читаем с пустой строки
  IF (_waseols==0) { //обход на случай конечного ; перед командой
    WHILE (_spcsize != 0) { //добавить съеденные пробелы
      _lentword = stradd(_tword, _lentword, ' ');
      DEC _spcsize;
    };
    WHILE (_waseols==0/**&&(!_waseof)*//**&&(_cnext!=_DIERESIS)*/) {
      rdchcmt(); //пропускает все ентеры
    };
  };
  _tword[_lentword] = '\0';
  toktext(); //генерирует <text>text<endtext>
  asmtoken(+_TOKENDCOMMENT);
  IF ((BYTE)_cnext < (BYTE)'!') {
    IF (_cnext == '\t') {
      _spcsize = _spcsize + 8;
    }ELSE {
      INC _spcsize;
    };
    rdch(); //читаем всю группу диерезисов + символ как один символ
  };
  asmrdword_tokspc(); //[токенизирует конечные пробелы или EOL,] берёт следующую команду (после инструкции)
}

PROC tokorg()
{
  asmtoken(+_CMDORG);
  asmrdword_tokspc(); //съедаем команду
  IF (tokexpr()) {asmtoken(+_FMTCMD);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokalign()
{
  asmtoken(+_CMDALIGN);
  asmrdword_tokspc(); //съедаем команду
  IF (tokexpr()) {asmtoken(+_FMTCMD);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}
/**
PROC tokpage()
{
  tokerrcmd();
}

PROC tokif()
{
  asmtoken(+_CMDIF);
  asmrdword_tokspc(); //съедаем команду
  IF (tokexpr()) {asmtoken(+_FMTCMD);
  }ELSE tokerr(+_ERREXPR); //wrong expr
  //tokerrcmd();
}

PROC tokelse()
{
  asmtoken(+_CMDELSE);
  asmrdword_tokspc(); //съедаем команду
  //tokerrcmd();
}

PROC tokendif()
{
  asmtoken(+_CMDENDIF);
  asmrdword_tokspc(); //съедаем команду
  //tokerrcmd();
}

PROC tokdup()
{
  tokerrcmd();
}

PROC tokedup()
{
  tokerrcmd();
}

PROC tokmacro()
{
  tokerrcmd();
}

PROC tokendm()
{
  tokerrcmd();
}
*/
PROC tokexport()
{
  asmtoken(+_CMDEXPORT);
  asmrdword_tokspc(); //съедаем call
  eatlabel(+_TOKLABEL);
  //asmmtoken(+_TOKTEXT);
  //fputs(_tword, _fout);
  //asmtoken(+_TOKENDTEXT);
  //asmrdword_tokspc(); //токенизирует пробелы после прошлой (обработанной) команды и читает новую
  asmtoken(+_FMTCMD); //чтобы использовать label
}
/**
PROC toklocal()
{
  tokerrcmd();
}

PROC tokendl()
{
  tokerrcmd();
}

PROC tokdisp()
{
  asmtoken(+_CMDDISP);
  asmrdword_tokspc(); //съедаем команду
  IF (tokexpr()) {asmtoken(+_FMTCMD);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokent()
{
  asmtoken(+_CMDENT);
  asmrdword_tokspc(); //съедаем команду
  asmtoken(+_FMTCMD);
}
*/
PROC tokinclude()
{
  asmtoken(+_CMDINCLUDE);
  asmrdword_tokspc(); //съедаем команду
  IF (matchquote()) {
    //asmtoken(+_OPWRSTR);
    _lentword = 0/**strclear(_tword)*/; //читаем с пустой строки
    rdquotes('\"');
    toktext(); //генерирует <text>text<endtext>
    rdch(); //пропустить закрывающую кавычку
    asmtoken(+_TOKDBLQUOTESYM);
    asmrdword_tokspc();
  }ELSE tokerr(+_ERREXPR);
  //asmtoken(+_FMTCMD); //todo?
}

PROC tokincbin()
{
  asmtoken(+_CMDINCBIN);
  asmrdword_tokspc(); //съедаем команду
  IF (matchquote()) {
    //asmtoken(+_OPWRSTR);
    _lentword = 0/**strclear(_tword)*/; //читаем с пустой строки
    rdquotes('\"');
    toktext(); //генерирует <text>text<endtext>
    rdch(); //пропустить закрывающую кавычку
    asmtoken(+_TOKDBLQUOTESYM);
    asmrdword_tokspc();
  }ELSE tokerr(+_ERREXPR);
  //todo параметры (пропуск, длина)
  //asmtoken(+_FMTCMD); //todo?
}

PROC tokdb()
{
  asmtoken(+_CMDDB);
  asmrdword_tokspc(); //съедаем команду
  REPEAT {
    IF (matchquote()) {
      asmtoken(+_OPWRSTR);
      _lentword = 0/**strclear(_tword)*/; //читаем с пустой строки
      rdquotes('\"');
      toktext(); //генерирует <text>text<endtext>
      rdch(); //пропустить закрывающую кавычку
      asmtoken(+_TOKDBLQUOTESYM);
      asmrdword_tokspc();
    }ELSE IF (tokexpr()) {
      asmtoken(+_OPWRVAL);
    }ELSE tokerr(+_ERREXPR);
  }UNTIL (!matchcomma());
  asmtoken(+_FMTCMD);
}

PROC tokdw()
{
  asmtoken(+_CMDDW);
  asmrdword_tokspc(); //съедаем команду
  REPEAT {
    tokexpr();
    asmtoken(+_OPWRVAL);
  }UNTIL (!matchcomma());
  asmtoken(+_FMTCMD);
}

PROC tokdl()
{
  asmtoken(+_CMDDL);
  asmrdword_tokspc(); //съедаем команду
  REPEAT {
    tokexpr();
    asmtoken(+_OPWRVAL);
  }UNTIL (!matchcomma());
  asmtoken(+_FMTCMD);
}

PROC tokds()
{
  asmtoken(+_CMDDS);
  asmrdword_tokspc(); //съедаем команду
  tokexpr();
  WHILE (matchcomma()) {
    tokexpr();
  };
  asmtoken(+_FMTCMD);
}
/**
PROC tokdisplay()
{
  tokerrcmd();
}

PROC tokrepeat()
{
  tokerrcmd();
}

PROC tokuntil()
{
  tokerrcmd();
}

PROC tokstruct()
{
  tokerrcmd();
}

PROC tokendstruct()
{
  tokerrcmd();
}
*/
PROC tokcolon()
{
  asmtoken(+_TOKCOLON);
  asmrdword_tokspc(); //съедаем ':'
}

///////////////////////

PROC tokcmd()
{
  //_asmwaseof=_waseof;
  //rdword_tokspc(); //прочитано в предыдущей инструкции
  //stringdecapitalize(_tword,_lentword);
  IF (*(PCHAR)_tword==';') {tokcomment();
/**  }ELSE IF (*(PCHAR)_tword==':') {
    asmtoken(+_TOKCOLON);
    asmrdword_tokspc(); //съедаем ':'
*/
  }ELSE IF (_asmspcsize!=0) {
    //tokasm(); //assembly mnemonic or directive
    tokcalllbl();
/**    IF (!tokcalllbl(_tword)) {
      tokerrcmd(); //wrong _tword
    };*/
  }ELSE { //<label> или <label>=<expr>
    //asmtoken(0xff);
    eatlabel(+_CMDLABEL); //съедаем метку
    IF (matchreequ()) { //<label>=<expr>
      IF (tokexpr()) {
        asmtoken(+_FMTREEQU);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE //IF ((_asmwaseols!=0)||(_asmwaseof)||(*(PCHAR)_tword==':')||(*(PCHAR)_tword==';')){ //<label>
      asmtoken(+_FMTCMD); //<label>
    //}ELSE tokerrcmd(); //wrong _tword
  };
  //пишем eol и пробелы, которые не записали при чтении конечного слова
  IF (_asmwaseols!=0) {
    WHILE (_asmwaseols!=0) {
      asmtoken(+_TOKEOL);
      DEC _asmwaseols;
    };
    tokspc(); //токенизируем пробелы после
  };
}

PROC tokinit()
{
  _tokfn = (PCHAR)_stokfn;
  tokinitlblbuf();
  tokpre(); //заполнить таблицу меток
}

PROC tokenize(PCHAR fn)
{
VAR UINT i;
  _fin = nfopen(fn, "rb");
  IF (_fin != (PBYTE)0) {
    _waseof = +FALSE;
    _curline = 1;
    initrd();

    _lentokfn = 0;
    i = 0;
    WHILE (fn[_lentokfn] != '\0') {
      _tokfn[_lentokfn] = fn[_lentokfn];
      IF (fn[_lentokfn] == '.') i = _lentokfn;
      INC _lentokfn;
    };
    //_lentokfn = strjoineol(_tokfn, 0, fn, '.'); //terminator is not copied
    //_lentokfn = stradd(_tokfn, _lentokfn, '.');
    _lentokfn = i+1; //after last dot
    _lentokfn = stradd(_tokfn, _lentokfn, (CHAR)((BYTE)fn[_lentokfn]&0xdf));
    _lentokfn = stradd(_tokfn, _lentokfn, '_');
    _tokfn[_lentokfn] = '\0';
    _fout = openwrite(_tokfn);

    _asmwaseols = 0;
    _asmwaseof = +FALSE;
    asmrdword_tokspc(); //читаем первую команду

    WHILE (!_asmwaseof) { //todo или endasm ('}')
      tokcmd();
    };

    asmtoken(+_TOKEOF);
    fclose(_fout); //closewrite(_fout); //closefout();

    fclose(_fin); //closefin();
  };
}

PROC tokenize_end()
{
}
