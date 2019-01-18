//// imported
#include "../_sdk/io.h"
#include "../_sdk/str.h" //stradd, strjoineol
#include "../_sdk/emit.h"

EXTERN BYTE _token; //текущий считанный токен
EXTERN BYTE _prefixedtoken; //расшифрованный токен с учётом \n и т.п.
EXTERN BYTE _curdir; //токен текущей обрабатываемой директивы ассемблера (нужно для правильной обработки формата)
EXTERN BOOL _labelchanged; //флаг "изменили метку" - нужно для ошибки по LABEL (но не по REEQU)
EXTERN LONG _value[_MAXVALS];
EXTERN PBYTE _inclfile[_MAXINCLUDES];

EXTERN UINT _curlnbeg; //номер строки на момент начала токена

EXTERN BYTE _reg; //последний регистр
EXTERN BYTE _oldreg; //предыдущий регистр
EXTERN BYTE _base; //база кода команды
EXTERN BYTE _base2; //база2 кода команды (для условных переходов)

EXTERN BYTE _nvalues; //число значений в стеке
EXTERN BYTE _ninclfiles; //число открытых файлов

EXTERN UINT _curaddr; //адрес, куда пишем
EXTERN UINT _curshift; //$=(_curaddr+curshift), curshift=(disp-_curaddr)
EXTERN UINT _curbegin; //начальный адрес блока, куда пишем
//EXTERN BYTE _curpage0;
//EXTERN BYTE _curpage1;
//EXTERN BYTE _curpage2;
//EXTERN BYTE _curpage3;

EXTERN PBYTE _pstr; //метка в строке заканчивается TOK_ENDTEXT
EXTERN PBYTE _curlabeltext;
EXTERN PBYTE _evallabeltext;
EXTERN PCHAR _fn;
EXTERN UINT _lenfn;

PROC asmpushvalue FORWARD(LONG value);
PROC asmpushbool FORWARD(BOOL b);
FUNC LONG asmpopvalue FORWARD();
//PROC asmwritestate FORWARD();
//PROC asmreadstate FORWARD();
PROC readlabel FORWARD();
PROC findlabel FORWARD(PBYTE labeltext);
FUNC LONG getlabel FORWARD(); //вызывать непосредственно после findlabel!!!
PROC errwrongreg FORWARD();
PROC errwrongpar FORWARD();
PROC asmerrtext FORWARD();
PROC asmbyte FORWARD(BYTE _token);
PROC asmemitblock FORWARD(); //записать адреса блока org
PROC asmdir_label FORWARD();
PROC asmfmt_reequ FORWARD();

PROC asmreadprefixed FORWARD();

EXTERN PBYTE _fincb;
EXTERN BOOL _asms;

PROC decltoken FORWARD(BYTE bb);
PROC decldig FORWARD(UINT d);

EXTERN PBYTE _forg;
EXTERN PBYTE _fdecl;

EXTERN BYTE _isaddr; //маска "в выражении использовался адрес"

#ifdef TARGET_THUMB
#include "asmf_arm.c" //// машиннозависимые процедуры и объявления
#else
#include "asmf_z80.c" //// машиннозависимые процедуры и объявления
#endif

PROC asmloop()
{
VAR UINT scale; //показатель системы счисления
VAR LONG tempvalue; //значение, считанное по popvalue и которое пишем по pushvalue
VAR UINT i;
  loop:
    _token = readfin();
    switch (_token) {

#include "asmj.c" //// стандартные ветки

#ifdef TARGET_THUMB
#include "asmj_arm.c" //// машиннозависимые ветки
#else
#include "asmj_z80.c" //// машиннозависимые ветки
#endif

      default : {err(+(CHAR)_token); enderr(); goto loop;}
    };
  endloop:;
}

