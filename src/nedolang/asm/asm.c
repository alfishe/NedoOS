//// imported
#include "../_sdk/str.h"
#include "../_sdk/io.h"
#include "../_sdk/emit.h"

PROC asmorgword FORWARD(LONG addr);
PROC asmloop FORWARD();
PROC initmemmodel FORWARD();

FUNC UINT findlabel FORWARD(PBYTE labeltext);

////
///////переменные, сохраняемые в post (состояние ассемблера в середине строки):

EXTERN UINT _curlnbeg; //номер строки на момент начала токена //для read, emit

VAR BYTE _token; //текущий считанный токен
VAR BYTE _curdir; //токен текущей обрабатываемой директивы ассемблера (нужно для правильной обработки формата)

VAR BYTE _reg; //последний регистр
VAR BYTE _oldreg; //предыдущий регистр
VAR BYTE _base; //база кода команды
VAR BYTE _base2; //база2 кода команды (для условных переходов)

VAR BYTE _nvalues; //число значений в стеке

VAR UINT _curaddr; //адрес, куда пишем
VAR UINT _curshift; //$=(_curaddr+curshift), curshift=(disp-_curaddr)
VAR UINT _curbegin; //начальный адрес блока, куда пишем
//VAR BYTE _curpage0;
//VAR BYTE _curpage1;
//VAR BYTE _curpage2;
//VAR BYTE _curpage3;

VAR UINT _plabel_index; //после findlabel содержит указатель на начало данных метки
VAR UINT _curplabel_index; //временное хранилище _plabel_index при определении меток
VAR UINT _hash;
VAR UINT _curhash; //временное хранилище при определении меток

VAR BYTE _isaddr; //маска "в выражении использовался адрес" (обнуляется в начале команд, которые генерятся с записью слова или пишут метку (label, =, dw, jp, call, ld))
//todo пока нельзя $-label!!! но можно 1*($-label)

////////переменные, не сохраняемые в post:

VAR PBYTE _labelN; //указатель на текущую таблицу меток
VAR BOOL _labelchanged; //флаг "изменили метку" - нужно для ошибки по LABEL (но не по REEQU)
VAR UINT _passindex; //номер прохода
VAR BYTE _prefixedtoken; //расшифрованный токен с учётом \n и т.п.

VAR BYTE _ninclfiles; //число открытых файлов

//////////////////////////////////////////////////////////////////////////////

VAR PBYTE _forg;
VAR PBYTE _fpost;
VAR PBYTE _fincb;
VAR PBYTE _fdecl;
VAR BOOL _asms;

#define _MAXVALS 0x10
VAR LONG _value[_MAXVALS];
#define _MAXINCLUDES 0x08
VAR PBYTE _inclfile[_MAXINCLUDES];

VAR UINT _nlabels;
VAR UINT _lenlabels;

CONST BYTE _LABELPAGEMASK = 0x00; //0x07
#ifdef BIGMEM
#define _LABELPAGESIZE 0xfffffe
#else
#define _LABELPAGESIZE 0x6500 /**0x7300*/
#endif
#define _LABELPAGEMAXSHIFT (UINT)(_LABELPAGESIZE-_STRLEN-10)
//CONST UINT _LABELPAGEFREESTART = 0x0200;
VAR UINT _labelpagefreestart; //[1];
//CONST UINT _LABELPAGEDATASHIFT = 0x0202;
#ifdef BIGMEM
CONST UINT _LABELPAGEEOF = 0xffffffff;
#else
CONST UINT _LABELPAGEEOF = 0xffff;
#endif

//todo динамически выделить
VAR BYTE _labels0[_LABELPAGESIZE]; //0x4000
//VAR BYTE _labels1[0xc000]/**_LABELPAGESIZE*/;
//VAR BYTE _labels2[0xc000]/**_LABELPAGESIZE*/;
//VAR BYTE _labels3[0xc000]/**_LABELPAGESIZE*/;
//VAR BYTE _labels4[0xc000]/**_LABELPAGESIZE*/;
//VAR BYTE _labels5[0xc000]/**_LABELPAGESIZE*/;
//VAR BYTE _labels6[0xc000]/**_LABELPAGESIZE*/;
//VAR BYTE _labels7[0xc000]/**_LABELPAGESIZE*/;
VAR UINT _labelshift[0x400]; //todo 8 pages
VAR PBYTE _labelpage[1]; //8

VAR BYTE _m_curlabeltext[_STRLEN]; //там же fn?
VAR BYTE _m_evallabeltext[_STRLEN];

VAR PBYTE _curlabeltext;
VAR PBYTE _evallabeltext;
VAR UINT _labellen; //длина метки для findlabel //включая 0

//0x0000..0x01ff - адреса начала цепочек
//0x0200..0x0201 - адрес начала свободного места (freestart)
//дальше сами цепочки
//формат цепочки:
//2 байта - адрес следующей метки
//N байт - текст метки
//1 байт - '\0'
//1 байт - флаги метки (defined, accessed, macro)
//4 байта - значение метки

CONST BYTE _ASMLABEL_DEFINED = 0x01;
CONST BYTE _ASMLABEL_ACCESSED= 0x02;
CONST BYTE _ASMLABEL_MACRO   = 0x04;
CONST BYTE _ASMLABEL_ISADDR  = 0x08;

FUNC LONG getlabel FORWARD();

//как сохранять post labels?
//todo будем сохранять всё состояние ассемблера и строку до конца, а посты компилировать так же, как обычный токенизированный текст
//а пока просто два прохода с затиранием результата первого

PROC decltoken(BYTE bb)
{
  writebyte(_fdecl,bb);
}

PROC asmpushvalue(LONG value)
{
/**  IF ((value & 0xffffL) != value) {
    errstr("val>65536"); enderr();
  };*/
  IF (_nvalues != _MAXVALS) {
    _value[_nvalues] = value;
    INC _nvalues;
  }ELSE {errstr("maxvals"); enderr(); };
}

PROC asmpushbool(BOOL b)
{
  //IF (b) {asmpushvalue(1L);
  //}ELSE asmpushvalue(0L);
  asmpushvalue((LONG)(BYTE)b);
}

FUNC LONG asmpopvalue()
{
//VAR LONG tempvalue;
//  IF (_nvalues!=0x00) {
    DEC _nvalues;
    //tempvalue = _value[_nvalues];
//  }ELSE {
    //tempvalue = 0xDEADBEEFL;
//    errstr("no data"); enderr(); //debug (can't be error after tokenizer)
//  };
  RETURN _value[_nvalues]; //tempvalue;
}
/**
PROC asmwritestate()
{
  writebyte(_fpost, +_DIR_READSTATE);

  writebyte(_fpost, _token);
  writebyte(_fpost, _curdir);

  writebyte(_fpost, _reg);
  writebyte(_fpost, _oldreg);
  writebyte(_fpost, _base);
  writebyte(_fpost, _base2);

  writebyte(_fpost, _nvalues);
  WHILE (_nvalues!=0x00) {
    writelong(_fpost, asmpopvalue());
  };

  writeuint(_fpost, _curaddr);
  writeuint(_fpost, _curshift);
  writeuint(_fpost, _curbegin);

  writebyte(_fpost, _curpage0); //модель памяти
  writebyte(_fpost, _curpage1);
  writebyte(_fpost, _curpage2);
  writebyte(_fpost, _curpage3);

  //writepointer(_fpost, _labelN);
  //writeuint(_fpost, plabelqueuestart_index);
  writeuint(_fpost, _plabel_index);
  writeuint(_fpost, _curplabel_index);
  writeuint(_fpost, _hash);
  writeuint(_fpost, _curhash);

  writeuint(_fpost, _curlnbeg);

  writebyte(_fpost, _isaddr);
}
*/
/**
PROC asmreadstate()
{
VAR BYTE i;
  _token = readfin();
  _curdir = readfin();

  _reg = readfin();
  _oldreg = readfin();
  _base = readfin();
  _base2 = readfin();

  i = readfinbyte();
  WHILE (_nvalues!=i) {
    asmpushvalue(readfinlong());
  };

  _curaddr = readfinuint();
  _curshift = readfinuint();
  _curbegin = readfinuint();

  _curpage0 = readfin(); //модель памяти
  _curpage1 = readfin();
  _curpage2 = readfin();
  _curpage3 = readfin();

  //_labelN = readfinpointer();
  //plabelqueuestart_index = readfinuint();
  _curplabel_index = readfinuint();
  _plabel_index = readfinuint();
  _hash = readfinuint();
  _curhash = readfinuint();

  _curlnbeg = readfinuint();

  _isaddr = readfinbyte();
}
*/

//0x0000..0x01ff - адреса начала цепочек
//дальше сами цепочки
//формат цепочки:
//2 байта - адрес следующей метки
//N байт - текст метки
//1 байт - '\0'
//1 байт - флаги метки (defined, accessed, macro)
//4 байта - значение метки

PROC clearlabels(UINT labelblock, PBYTE labelpointer)
{
  _labelpage[labelblock] = labelpointer;
  _hash = 0x0400;
  REPEAT {
    DEC _hash;
    _labelshift[_hash] = _LABELPAGEEOF;
  }UNTIL (_hash == 0);
  _labelpagefreestart = 0;
}

PROC readlabel()
{
VAR PBYTE pevalstr; //метка в строке заканчивается TOK_ENDTEXT
VAR BYTE cstr; //символ из строки
VAR UINT labellen;
  _token = readfin(); //TOK_TEXT
  labellen = 0;
  REPEAT {
    cstr = readfin();
    IF ((CHAR)cstr == '#') { //evallabelname=123:labelname#evallabelname должно давать labelname123
      //с постами работать не будет!!!
      //прочитать evallabel в _evallabeltext - TODO fgets
      pevalstr = (PBYTE)_evallabeltext;
      REPEAT {
        cstr = readfin();
        POKE *(PBYTE)(pevalstr) = cstr; //метка в строке заканчивается TOK_ENDTEXT
        INC pevalstr;
      }UNTIL (cstr == +_TOKENDTEXT);
      ;;_labellen = (UINT)(pevalstr - _evallabeltext); //включая 0
      //вычислить evallabel
      //errstr("readevallabel "); errstr(_evallabeltext); enderr();
      _plabel_index = findlabel(_evallabeltext);
      emitn((UINT)getlabel());
      labellen = strjoin((PCHAR)_curlabeltext, labellen, _nbuf); //глобальная
      //cstr == +_TOKENDTEXT
    };
    _curlabeltext[labellen] = cstr;
    INC labellen; //TODO проверять переполнение длины
  }UNTIL (cstr == +_TOKENDTEXT);
  _labellen = labellen; //включая +_TOKENDTEXT
  //errstr("readlabel "); errstr(_curlabeltext); enderr();
}
/**
FUNC UINT findlabel(PBYTE labeltext)
{
//VAR PBYTE _labelN; //указатель на текущую таблицу меток
VAR PBYTE plabel; //метка в таблице заканчивается нулём
//VAR PBYTE pstr; //метка в строке заканчивается TOK_ENDTEXT
//VAR BYTE cstr; //символ из строки
//VAR BYTE clabel; //символ из таблицы меток
//VAR UINT pnext_index; //адрес следующей метки в таблице
//VAR UINT plabelqueuestart_index; //в (_labelN+plabelqueuestart_index) хранится адрес начала цепочки для метки
  _hash = hash(labeltext)&0x3ff;

  _labelN = _labels0; //_labelpage[(UINT)(_hashhigh&_LABELPAGEMASK)]; //set page (todo как определить? системный макрос?)
  //plabelqueuestart_index = ((UINT)(_hash))<<1; //todo разная разрядность UINT
  _plabel_index = _labelshift[_hash];
  //todo как сделать набор массивов в разных страничках? сдвиг индекса в одном массиве внизу?
  //_labelflag = 0x00; //"label not found"
  WHILE (_plabel_index != _LABELPAGEEOF) { //пока цепочка меток не закончилась
    plabel = &_labelN[_plabel_index]; //(PBYTE)((POINTER)_labelN + (POINTER)_plabel_index);
    _plabel_index = *(PUINT)(plabel);
    plabel = &plabel[+sizeof(UINT)]; //(PBYTE)((POINTER)plabel + (POINTER)2);
    IF (strcp((PCHAR)labeltext, (PCHAR)plabel)) { //метка найдена
      //plabel = (PBYTE)((POINTER)plabel + (POINTER)_labellen); //включая 0
        //errstr("found label "); errstr(labeltext); enderr();
      _plabel_index = (UINT)(plabel - _labelN) + _labellen; //включая 0 //указатель на начало данных создаваемой метки (надо обязательно запомнить!)
      //_labelflag = *(PBYTE)(plabel);
      //_labelvalue = *(PLONG)((POINTER)plabel + (POINTER)1);
      BREAK; //помнит _plabel_index начала данных найденной метки
    };
    //_plabel_index = pnext_index;
  }; //если не найдено, то _plabel_index==_LABELPAGEEOF
RETURN _plabel_index;
}
*/
PROC addlabel(LONG labelvalue) //вызывать непосредственно после findlabel!!!
{
//VAR PBYTE _labelN; //указатель на текущую таблицу меток
VAR PBYTE plabel;
//VAR PBYTE pstr; //метка в строке заканчивается TOK_ENDTEXT
//VAR BYTE cstr;
//VAR UINT plabelqueuestart_index; //в (_labelN+plabelqueuestart_index) хранится адрес начала цепочки для метки
//VAR UINT oldqueuestart_index; //старый указатель на начало цепочки
VAR UINT freestart_index;
VAR BYTE labelflag;
//VAR LONG oldlabelvalue;
  _labelchanged = +FALSE;
  _labelN = _labels0; //_labelpage[(UINT)(_hashhigh&_LABELPAGEMASK)]; //set page (todo как определить? системный макрос?)
  //IF (_labelflag!=0x00) { //метка есть
  IF (_plabel_index!=_LABELPAGEEOF) { //метка есть
    plabel = &_labelN[_plabel_index]; //(PBYTE)((POINTER)_labelN + (POINTER)_plabel_index); //указатель на начало данных метки
    labelflag = *(PBYTE)(plabel); //findlabel();
    IF ((labelflag&_ASMLABEL_MACRO)!=0x00) {
      errstr("redefmacro"); /**errstr((PCHAR)_curlabeltext);*/ enderr();
    }ELSE IF ((labelflag&_ASMLABEL_DEFINED)!=0x00) {
      IF (*(PLONG)&plabel[1] != labelvalue) { //если метка определена и значение не соответствует
        _labelchanged = +TRUE;
        //;;errstr("old "); erruint(*(PUINT)&plabel[1]); enderr();
        //;;errstr("new "); erruint((UINT)labelvalue); enderr();
      };
    }ELSE { //иначе (не определена) определяем
      POKE *(PBYTE)(plabel) = labelflag|_isaddr|_ASMLABEL_DEFINED;
      POKE *(PLONG)(&plabel[1]) = labelvalue;
    };
  }ELSE {//метки нет: пишем в начало цепочки адрес конца страницы и создаём метку там со ссылкой на старое начало цепочки
    //plabelqueuestart_index = (UINT)_hash + (UINT)_hash; //todo разная разрядность UINT
    //oldqueuestart_index = *(PUINT)((POINTER)_labelN + (POINTER)plabelqueuestart_index); //старый указатель на начало цепочки
    freestart_index = _labelpagefreestart; //[0] //начало свободного места
    _plabel_index = freestart_index; //указатель на начало данных создаваемой метки (надо обязательно запомнить!)
    IF (freestart_index < _LABELPAGEMAXSHIFT) { //есть место под метку
      plabel = &_labelN[_plabel_index]; //указатель на начало создаваемой метки
      //пишем метку
      POKE *(PUINT)(plabel) = _labelshift[_hash]; //oldqueuestart_index; //старый указатель на начало цепочки
      plabel = &plabel[+sizeof(UINT)];
      strcopy((PCHAR)_curlabeltext, _labellen /**-1*/, (PCHAR)plabel); //_labellen включая 0
      plabel = &plabel[_labellen]; //включая 0
      POKE *(PBYTE)(plabel) = _ASMLABEL_DEFINED;
      _plabel_index = (UINT)(plabel - _labelN); //указатель на начало данных создаваемой метки
      INC plabel;
      POKE *(PLONG)(plabel) = labelvalue;
      plabel = &plabel[+sizeof(LONG)];
      _labelshift[_hash] = freestart_index; //новый указатель на начало цепочки
      _labelpagefreestart = (UINT)(plabel - _labelN); //указатель на конец создаваемой метки
      _lenlabels = _lenlabels + _labelpagefreestart - freestart_index;
      INC _nlabels;
      //_plabel_index должен указывать на начало данных метки!
    }ELSE {errstr("mem"); enderr();
    };
  };
}

PROC changelabel(LONG labelvalue) //вызывается по данным старого findlabel (только в reequ - TODO внедрить)
{ //_plabel_index указывает на начало данных метки
//VAR PBYTE _labelN; //указатель на текущую таблицу меток
VAR PBYTE plabel;
//VAR BYTE labelflag;
  _labelN = _labels0; //_labelpage[(UINT)(_hashhigh&_LABELPAGEMASK)]; //set page (todo как определить? системный макрос?)
  plabel = &_labelN[_plabel_index];
  //labelflag = *(PBYTE)(plabel);
  POKE *(PBYTE)(plabel) = (*(PBYTE)(plabel)&~_ASMLABEL_ISADDR)|_isaddr|_ASMLABEL_DEFINED;
  POKE *(PLONG)(&plabel[1]) = labelvalue;
}

FUNC LONG getlabel() //вызывать непосредственно после findlabel!!!
{ //_plabel_index указывает на начало данных метки
//VAR PBYTE _labelN; //указатель на текущую таблицу меток
VAR PBYTE plabel;
VAR BYTE labelflag;
VAR LONG labelvalue; //=0L; //= 0xDEADBEEFL;
  _labelN = _labels0; //_labelpage[(UINT)(_hashhigh&_LABELPAGEMASK)]; //set page (todo как определить? системный макрос?)
  IF (_plabel_index!=_LABELPAGEEOF) { //метка есть
    plabel = &_labelN[_plabel_index];
    labelflag = *(PBYTE)(plabel);
//    IF ((labelflag&_ASMLABEL_MACRO)!=0x00) {
//      errstr("label=macro"); enderr();
//    }ELSE {
      POKE *(PBYTE)(plabel) = labelflag|_ASMLABEL_ACCESSED;
      labelvalue = *(PLONG)(&plabel[1]);
      _isaddr = labelflag&_ASMLABEL_ISADDR;
//    };
  }ELSE {//метки нет: ошибка //todo post
    //asmwritestate();
    //todo записать в пост весь текст до конца команды

    //todo по формату команды определить, сколько байт пропустить

    errstr("nolbl "); errstr((PCHAR)_curlabeltext); enderr();
  };
  RETURN labelvalue;
}

PROC asmdir_label() //неизвестно, просто метка или reequ
{
  readlabel();
  _plabel_index = findlabel(_curlabeltext);
  //нельзя сейчас переопределять! иначе нельзя label=label+1
  addlabel((LONG)(_curaddr+_curshift)); //юзает _plabel_index //установит _labelchanged, если изменили
  _curplabel_index = _plabel_index; //запомнить указатель данных метки для REEQU
  _curhash = _hash;
}

PROC asmfmt_reequ()
{
  _plabel_index = _curplabel_index; //достаточно одной вложенности на чтение меток в выражении
  _hash = _curhash;
  IF (_plabel_index!=_LABELPAGEEOF) { //метка есть
    changelabel(asmpopvalue()); /**вспомнить указатель метки и присвоить/переприсвоить ей value*/
  };
}
/**
PROC asmfmt_dir_label()
{
  //_plabel_index=_curplabel_index; //достаточно одной вложенности на чтение меток в выражении
  //_hash=_curhash;
  //addlabel((_curaddr+curshift)); //нельзя без findlabel непосредственно до!!!

  IF (_labelchanged) {
    errstr("redef "); errstr((PCHAR)_curlabeltext); enderr();
  };
}
*/
//////////////

PROC errwrongreg()
{
  errstr("badreg"); enderr();
}

PROC errwrongpar()
{
  errstr("badpar"); enderr();
}

PROC asmerrtext()
{
  loop:
  {
    _token = readfin();
    IF ((_token == +_TOKENDERR)||_waseof) goto end; //BREAK;
    //IF (_waseof) goto end; //BREAK; //на всякий случай
    IF (_token == +_TOKTEXT) {
      txtloop:
      {
        _token = readfin();
        IF ((_token == +_TOKENDTEXT)||_waseof) goto loop; //BREAK;
        //IF (_waseof) goto loop; //BREAK; //на всякий случай
        err((CHAR)_token);
        goto txtloop;
      };
    }ELSE err(' ');
    goto loop;
  };
  end:
  err('\"'); enderr();
}

PROC asmbyte(BYTE token)
{
  IF (_asms) writefout(token);
  INC _curaddr;
}

PROC asmemitblock() //записать адреса блока org
{
  IF (_curaddr != _curbegin) {
    asmorgword((LONG)_curbegin);
    asmorgword((LONG)(_curaddr-_curbegin));
  };
}

PROC asmreadprefixed()
{
  _token=readfin();
  IF ((CHAR)_token=='\\') { //todo вставить TOK_TEXT...TOK_ENDTEXT
    _token=readfin();
    IF       ((CHAR)_token=='n') {_prefixedtoken=0x0a;
    }ELSE IF ((CHAR)_token=='r') {_prefixedtoken=0x0d;
    }ELSE IF ((CHAR)_token=='t') {_prefixedtoken=0x09;
    }ELSE IF ((CHAR)_token=='0') {_prefixedtoken=0x00;
    }ELSE _prefixedtoken=_token; //остальные префиксные символы оставляем как есть
  }ELSE _prefixedtoken=_token;
}

PROC asmpass(PCHAR fn)
{
  initmemmodel();
  _curbegin = _curaddr;
  _curshift = 0;

  _nvalues = 0x00;
  _ninclfiles = 0x00;

  //;;errstr("pass "); erruint(_passindex); enderr();
  //setfin("tok.f");
  _fin = nfopen(fn, "rb");
  IF (_fin != (PBYTE)0) {
    _waseof = +FALSE;
    _curlnbeg = 1; //todo при include и потом восстанавливать

    asmloop();

    fclose(_fin); //closefin();
  }ELSE {
    errstr("no "); errstr(fn); enderr();
  };
  asmemitblock(); //записать адреса блока org
  INC _passindex;
}

FUNC UINT findlast(PCHAR s, CHAR eol)
{
VAR UINT len;
VAR UINT last;
VAR CHAR c;
  len = 0;
  last = 0; //после последнего терминатора
  loop: //REPEAT {
    c = *(PCHAR)s;
    IF (c == '\0') goto endloop; //BREAK; //терминатор не копируется
    IF (c == eol) last = len;
    INC s;
    INC len;
  goto loop; //}UNTIL ( (c==eol) || (len>=_STRMAX) ); //терминатор не копируется
  endloop:
RETURN last; //после последнего терминатора
}

FUNC PBYTE openext(PCHAR ext)
{
  _lenfn = findlast(_fn, '.');
  _lenfn = strjoin(_fn, _lenfn, ext);
  _fn[_lenfn] = '\0'; //strclose
RETURN openwrite(_fn);
}

PROC asmcompile(PCHAR fn)
{
  _curlabeltext = (PBYTE)_m_curlabeltext;
  _evallabeltext = (PBYTE)_m_evallabeltext;

  _fn = _m_fn;
  _lenfn = 0;

  _nlabels = 0;
  _lenlabels = 0;
  clearlabels(0, (PBYTE)_labels0);
  //clearlabels(1, (PBYTE)_labels1);
  //clearlabels(2, (PBYTE)_labels2);
  //clearlabels(3, (PBYTE)_labels3);
  //clearlabels(4, (PBYTE)_labels4);
  //clearlabels(5, (PBYTE)_labels5);
  //clearlabels(6, (PBYTE)_labels6);
  //clearlabels(7, (PBYTE)_labels7);

  _passindex = 1;

  _errs = +FALSE;
  _asms = +FALSE;
  asmpass(fn);

  _lenfn = strjoineol(_fn, 0, fn, '\0'); //длина без терминатора!
  _fn[_lenfn] = '\0'; //strclose
  _fout = openext(".bin");
  _forg = openext(".org");
  //_fpost = openext(".pst");
  _fdecl = openext(".D_");
  //_fout = openwrite( "bin.f" );
  //_forg = openwrite( "org.f" );
  //_fpost = openwrite( "post.f" );
  //_fdecl = openwrite( "decl.f" );
  //setferr("asmerr.f");
  _errs = +TRUE;
  _asms = +TRUE;
  asmpass(fn);
  errstr("lbls "); erruint(_nlabels); errstr(" buf "); erruint(_lenlabels); enderr();
  //closeferr();
  decltoken(+_TOKEOF);
  fclose(_fdecl);
  //fclose(_fpost);
  fclose(_forg);
  fclose(_fout);
}
