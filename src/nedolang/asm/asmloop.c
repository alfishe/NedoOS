//// imported
#include "../_sdk/io.h"
#include "../_sdk/str.h" //stradd, strjoineol
#include "../_sdk/emit.h"

#ifdef TARGET_SCRIPT
#include <math.h>
#endif

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
FUNC UINT findlabel FORWARD(PBYTE labeltext);
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

EXTERN UINT _plabel_index; //после findlabel содержит указатель на начало данных метки

#ifdef TARGET_THUMB
#include "asmf_arm.c" //// машиннозависимые процедуры и объявления
#else
#include "asmf_z80.c" //// машиннозависимые процедуры и объявления
#endif

PROC rdnum()
{
VAR LONG tempvalue; //значение, считанное по popvalue и которое пишем по pushvalue
VAR UINT scale; //показатель системы счисления
        readfin(); //TOK_TEXT
        _token = readfin(); //first digit or prefix (0x, 0b, 0)
        tempvalue = 0L;
        scale = 10;
        IF ((CHAR)_token=='0'){
          _token=readfin(); //'x' (hex), 'b' (bin), 'o' (oct), else oct with error
          IF       ((CHAR)_token=='x') {
            scale=16;
            rdbase:
            IF (_token!=+_TOKENDTEXT) _token=readfin(); //first digit
          }ELSE IF ((CHAR)_token=='b') {
            scale=2;
            goto rdbase; //IF (_token!=+_TOKENDTEXT) _token=readfin(); //first digit
          }ELSE IF ((CHAR)_token=='o') {
            scale=8;
            goto rdbase; //IF (_token!=+_TOKENDTEXT) _token=readfin(); //first digit
          }ELSE IF ((CHAR)_token=='L') { //0L
          }ELSE IF ((CHAR)_token=='.') { //0.
          }ELSE IF (_token!=+_TOKENDTEXT) {
            scale=8;
            errstr("Use 0o oct"); enderr();
          };
        };
        IF (_token!=+_TOKENDTEXT) {
          rdnumloop: //WHILE (+TRUE)
          { //первая цифра числа уже прочитана
            IF ((_token==+_TOKENDTEXT)||_waseof) goto rdnumend; //BREAK;
            //IF (_waseof) goto rdnumend; //BREAK; //на всякий случай
            IF ((CHAR)_token!='L') {
              IF (_token>=(BYTE)'a') {_token = _token - 0x27/**- (BYTE)'a' + 0x0a + (BYTE)'0'*/; //todo error
              }ELSE IF (_token>=(BYTE)'A') {_token = _token - 0x07/**- (BYTE)'A' + 0x0a + (BYTE)'0'*/; //todo error
#ifdef TARGET_SCRIPT
              }ELSE IF (_token==(BYTE)'.') { //float
                fexp = 0L;
                fexpminus = +FALSE;
                ffraction = 0L;
                ffractionscale = 1L;
                _token = readfin();
                IF (_token!=+_TOKENDTEXT) {
                  rdfloatloop:
                  { //первая цифра числа уже прочитана
                    //printf("ffraction = %lf\n",(double)ffraction);
                    IF ((_token==+_TOKENDTEXT)||_waseof) goto rdfloatend; //BREAK;
                    //IF (_waseof) goto rdfloatend; //BREAK; //на всякий случай
                    IF ((CHAR)_token!='f') {
                      IF (_token==(BYTE)'e') { //TODO e12/e-12
                        _token = readfin();
                        IF (_token==+_TOKENDTEXT) goto rdfloatend; //BREAK;
                        IF (_token=='-') { //TODO
                          fexpminus = +TRUE;
                          _token = readfin();
                        };
                        //printf("fexp = %u, token = %c\n",(unsigned int)fexp, _token);
                        IF (_token!=+_TOKENDTEXT) {
                          rdexploop:
                          { //первая цифра экспоненты уже прочитана
                            //printf("fexp = %u\n",(unsigned int)fexp);
                            IF ((_token==+_TOKENDTEXT)||_waseof) goto rdfloatend; //BREAK;
                            fexp = fexp*10L + (LONG)(_token - (BYTE)'0');
                            _token = readfin();
                            goto rdexploop;
                          }
                        };
                        goto rdfloatend; //BREAK;
                      };
                    };
                    ffraction = ffraction*10L + (LONG)(_token - (BYTE)'0');
                    ffractionscale = ffractionscale*10L;
                    //ffraction += (float)(_token - (BYTE)'0')*ffractionscale;
                    _token = readfin();
                    goto rdfloatloop;
                  };
                };
                rdfloatend:
                fvalue = (double)tempvalue + (double)ffraction/(double)ffractionscale; //знак работает как операция, так что не учитываем
                IF (fexpminus) {
                  fvalue = fvalue/pow10(fexp);
                }ELSE {
                  fvalue = fvalue*pow10(fexp);
                };
                //fvalue = 0.1415926536;
                //printf("%ld\n",fexp);
                //printf("%20.20lf\n",fvalue);
                //printf("%20.20lf\n",0.1415926536);
                tempvalue = *(LONG*)(&fvalue);
                goto rdnumend;
#endif
              };//ELSE _token = _token - (BYTE)'0';
              tempvalue = (LONG)scale*tempvalue + (LONG)(_token - (BYTE)'0');
            };
            _token = readfin();
            goto rdnumloop;
          };
          rdnumend:;
        };
        asmpushvalue(tempvalue);
}

PROC doexpr RECURSIVE FORWARD();

PROC doval RECURSIVE() //читаем значение (число или метку, или TODO выражение в скобках)
{
VAR LONG tempvalue; //значение, считанное по popvalue и которое пишем по pushvalue
{
//;;printf("doval\n");
dovalloop:
  _token = readfin();
//  IF ((_token==+_TOKENDEXPR/**TODO _TOKENDTEXT*/)||_waseof) goto dovalq; //BREAK;
  IF (_token==+_TOKNUM) {
//;;printf("valTOKNUM\n");
        rdnum();
        //goto doexprlooptok;
  }ELSE IF (_token==+_TOKLABEL) {
//;;printf("valTOKLABEL\n");
        readlabel();
        _plabel_index = findlabel(_curlabeltext);
        asmpushvalue(getlabel());
        //goto doexprlooptok;
  }ELSE IF (_token==+_TOKMINUS) {
//;;printf("valTOKMINUS\n");
        doval();
        //asmpushvalue(0L-asmpopvalue()); //BUG!!! TODO fix!
        //asmpushvalue(-asmpopvalue()); //BUG!!! TODO fix!
        tempvalue=asmpopvalue(); asmpushvalue(0L-tempvalue);
        //asmpushvalue(0L); tempvalue=asmpopvalue(); asmpushvalue(asmpopvalue()-tempvalue);
  }ELSE IF (_token==+_TOKPLUS) {
//;;printf("valTOKPLUS\n");
        //doval();
        goto dovalloop;
  }ELSE IF (_token==+_TOKDOLLAR) {
//;;printf("valTOKDOLLAR\n");
        asmpushvalue((LONG)(_curaddr+_curshift)); _isaddr = +_ASMLABEL_ISADDR;
  }ELSE IF (_token==+_TOKPRIME) {
//;;printf("valTOKPRIME\n");
        readfin(); //text
        asmreadprefixed(); //читаем через readfin, раскрываем \n \r \t \0
        asmpushvalue((LONG)_prefixedtoken);
        readfin(); //endtext
        readfin(); //закрывающий апостроф
  }ELSE IF (_token==+_TOKOPEN) {
//;;printf("valTOKOPEN\n");
        doexpr();
  }ELSE IF (_token==+_TOKTILDE) {
//;;printf("valTOKTILDE\n");
//TODO _TOKEXCL
//TODO _TOKSTAR (PEEK)
        doval();
        asmpushvalue(~asmpopvalue());
  }ELSE {
;;printf("?valTOK %d\n",(UINT)_token);
        goto dovalloop;
  };
//;;printf("dovalq\n");
}
}

PROC doexpr RECURSIVE()
{
VAR LONG tempvalue; //значение, считанное по popvalue и которое пишем по pushvalue
{
  //goto doexprq;
//читаем до _TOKENDEXPR
//в первой версии считаем слева направо

//пробелы игнорируем (TODO откуда они в конце выражения перед комментарием?): +_TOKSPC0 ... +_TOKSPC0+_ASMMAXSPC-1
//скобки игнорируем: +_TOKOPEN, +_TOKCLOSE
//игнорируем операции: +_OPADD, +_OPSUB, +_OPMUL...
//число: +_TOKNUM, +_TOKTEXT, <данные>, +_TOKENDTEXT
//метка: +_TOKLABEL, +_TOKTEXT, <данные>, +_TOKENDTEXT
//закавыченный байт: +_TOKPRIME, <данные>, +_TOKPRIME
//$: +_TOKDOLLAR
//+: _TOKPLUS
//-: _TOKMINUS
//*: +_TOKSTAR
  //_token = readfin(); //_TOKTEXT //в будущем TODO
//;;printf("doexpr addr=%d\n",_curaddr);
  doval(); //первый параметр
doexprloop:
  _token = readfin(); //операция или конец
  IF ((_token==+_TOKENDEXPR/**TODO _TOKENDTEXT*/)||(_token==+_TOKCLOSE)||_waseof) goto doexprq; //BREAK;
  IF (_token==+_TOKPLUS) {
//;;printf("TOKPLUS\n");
        doval();
        asmpushvalue(asmpopvalue()+asmpopvalue());
  }ELSE IF (_token==+_TOKMINUS) {
//;;printf("TOKMINUS\n");
        doval();
        tempvalue=asmpopvalue(); asmpushvalue(asmpopvalue()-tempvalue);
  }ELSE IF (_token==+_TOKSTAR) {
//;;printf("TOKSTAR\n");
        doval();
        asmpushvalue(asmpopvalue()*asmpopvalue()); _isaddr = 0x00;
  }ELSE IF (_token==+_TOKSLASH) {
//;;printf("TOKSLASH\n");
        doval();
        tempvalue=asmpopvalue();
        {
        ;;IF (tempvalue!=0L)
          asmpushvalue(asmpopvalue()/tempvalue);
        }
  }ELSE IF (_token==+_TOKMORE) {
//;;printf("TOKMORE\n");
        readfin(); //+_TOKMORE (2-й)
//TODO >, >=
        doval();
        tempvalue=asmpopvalue(); asmpushvalue(asmpopvalue()>>tempvalue);
  }ELSE IF (_token==+_TOKLESS) {
//;;printf("TOKLESS\n");
//TODO <, <=
//TODO _TOKEQUAL, _TOKEXPL (!=)
        readfin(); //+_TOKLESS (2-й)
        doval();
        tempvalue=asmpopvalue(); asmpushvalue(asmpopvalue()<<tempvalue);
  }ELSE IF (_token==+_TOKAND) {
//;;printf("TOKAND\n");
//TODO также двойные
        doval();
        asmpushvalue(asmpopvalue()&asmpopvalue());
  }ELSE IF (_token==+_TOKPIPE) {
//;;printf("TOKPIPE\n");
//TODO также двойные
        doval();
        asmpushvalue(asmpopvalue()|asmpopvalue());
  }ELSE IF (_token==+_TOKCARON) {
//;;printf("TOKCARON\n");
//TODO также двойные
        doval();
        asmpushvalue(asmpopvalue()^asmpopvalue());
  }ELSE IF (_token==+_TOKSPC1) {
//;;printf("TOKSPC1\n",_curaddr);
  }ELSE {
;;printf("?TOK %d\n",(UINT)_token);
  };
  goto doexprloop;
doexprq:
//TODO в следующей версии все _TOK... выкинуть из выражения, оставить +_TOKEXPR, +_TOKTEXT(сейчас нет), <данные>, +_TOKENDTEXT(сейчас нет, только _TOKENDEXPR)
}
}

PROC fsm()
{
#ifdef TARGET_SCRIPT
VAR double fvalue;
VAR LONG ffraction;
VAR LONG ffractionscale;
VAR LONG fexp;
VAR BOOL fexpminus;
#endif
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

      default : {err((CHAR)_token); enderr(); goto loop;}
    };
  endloop:;
}

