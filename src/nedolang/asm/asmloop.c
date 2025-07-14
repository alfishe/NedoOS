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

#ifdef TARGET_SCRIPT
VAR double fvalue;
VAR LONG fexp;
VAR BOOL fexpminus;
VAR LONG ffraction;
VAR LONG ffractionscale;
#endif

#ifdef TARGET_THUMB
#include "asmf_arm.c" //// машиннозависимые процедуры и объявления
#else
#include "asmf_z80.c" //// машиннозависимые процедуры и объявления
#endif

PROC rdnum_()
{
VAR LONG tempvalue; //значение, считанное по popvalue и которое пишем по pushvalue
VAR UINT scale; //показатель системы счисления
        //readfin(); //_TOKTEXT (TODO до входа)
        //_token = readfin(); //first digit or prefix (0x, 0b, 0)
        tempvalue = 0L;
        scale = 10;
        IF ((CHAR)_token=='0'){
          _token=readfin(); //'x' (hex), 'b' (bin), 'o' (oct), else oct with error
          IF       ((CHAR)_token=='x') {
            scale=16;
            rdbase:
            /**IF (_token!=+_TOKENDTEXT)*/ _token=readfin(); //first digit
          }ELSE IF ((CHAR)_token=='b') {
            scale=2;
            goto rdbase; //IF (_token!=+_TOKENDTEXT) _token=readfin(); //first digit
          }ELSE IF ((CHAR)_token=='o') {
            scale=8;
            goto rdbase; //IF (_token!=+_TOKENDTEXT) _token=readfin(); //first digit
          //}ELSE IF ((CHAR)_token=='L') { //0L
          //}ELSE IF ((CHAR)_token=='.') { //0.
          }ELSE IF ((BYTE)((BYTE)_token - (BYTE)'0') < 0x0a) { //0..9
            scale=8;
            errstr("Use 0o oct"); enderr();
          };
        };
        //IF (_token!=+_TOKENDTEXT) { //TODO 0..9a..f (L обслужить вне цикла)
          rdnumloop: //WHILE (+TRUE)
          //{ //первая цифра числа уже прочитана
            //IF ((_token==+_TOKENDTEXT)||_waseof) goto rdnumend; //BREAK;
            IF (_waseof) goto rdnumend; //BREAK; //на всякий случай
            IF ((CHAR)_token!='L')
            {
              IF ((BYTE)((BYTE)_token - (BYTE)'0') < 0x0a) {_token = _token - 0x30;
              }ELSE IF ((BYTE)(((BYTE)_token|0x20) - (BYTE)'a') < 0x06) {_token = (_token|0x20) - 0x57;
//              IF ((_token>=0x30)&&(_token<0x3a)) {_token = _token - 0x30;
//              }ELSE IF ((_token>=(BYTE)'a')&&(_token<0x7b)) {_token = _token - 0x57;
//              }ELSE IF ((_token>=(BYTE)'A')&&(_token<0x5b)) {_token = _token - 0x37;
#ifdef TARGET_SCRIPT
              }ELSE IF (_token==(BYTE)'.') { //float
            //printf("float %d",_token);
                fexp = 0L;
                fexpminus = +FALSE;
                ffraction = 0L;
                ffractionscale = 1L;
                _token = readfin();
                //IF (_token!=+_TOKENDTEXT) { //TODO 0..9a..f
                IF ((BYTE)((BYTE)_token - (BYTE)'0') < 0x0a) {
                  rdfloatloop:
            //printf("float: %d",_token);
                  //{ //первая цифра числа уже прочитана
                    //printf("ffraction = %lf\n",(double)ffraction);
                    //IF ((_token==+_TOKENDTEXT)||_waseof) goto rdfloatend; //BREAK; //TODO 0..9
                    IF (_waseof) goto rdfloatend; //BREAK; //на всякий случай
                    //IF ((CHAR)_token!='f') { //???
                      IF (_token==(BYTE)'e') { //TODO e12/e-12
                        _token = readfin();
                        //IF (_token==+_TOKENDTEXT) goto rdfloatend; //BREAK; //TODO 0..9, +-
                        IF (_waseof) goto rdfloatend; //BREAK; //на всякий случай
                        IF (_token=='-') { //TODO
                          fexpminus = +TRUE;
                          _token = readfin();
                        };
                        //printf("fexp = %u, token = %c\n",(unsigned int)fexp, _token);
                        //IF (_token!=+_TOKENDTEXT) { //TODO 0..9
                          rdexploop:
                          //{ //первая цифра экспоненты уже прочитана
                            //printf("fexp = %u\n",(unsigned int)fexp);
                            //IF ((_token==+_TOKENDTEXT)||_waseof) goto rdfloatend; //BREAK;
                            IF (_waseof) goto rdfloatend; //BREAK; //на всякий случай
                            IF ((BYTE)((BYTE)_token - (BYTE)'0') >= 0x0a) goto rdfloatend; //BREAK;
                            fexp = fexp*10L + (LONG)(_token - (BYTE)'0');
                            _token = readfin();
                            goto rdexploop;
                          //}
                        //};
                        goto rdfloatend; //BREAK;
                      }ELSE IF ((BYTE)((BYTE)_token - (BYTE)'0') >= 0x0a) {
                        goto rdfloatend; //BREAK;
                      };
                    //}; //!='f'
                    ffraction = ffraction*10L + (LONG)(_token - (BYTE)'0');
                    ffractionscale = ffractionscale*10L;
                    //ffraction += (float)(_token - (BYTE)'0')*ffractionscale;
                    _token = readfin();
                    goto rdfloatloop;
                  //};
                }; //0..9
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
              }ELSE { //не цифра и не .
                goto rdnumend;
              };
              //tempvalue = (LONG)scale*tempvalue + (LONG)(_token - (BYTE)'0');
              tempvalue = (LONG)scale*tempvalue + (LONG)_token;
            }; //IF ((CHAR)_token!='L')
            _token = readfin();
            goto rdnumloop;
          //};
          rdnumend:;
        //};
        //IF ((CHAR)_token=='L') {_token = readfin();}; //так не работает (почему?)
        asmpushvalue(tempvalue);
}

PROC doexpr_ RECURSIVE FORWARD();

PROC doval_ RECURSIVE() //читаем значение (число или метку, или TODO выражение в скобках)
{
VAR LONG tempvalue; //значение, считанное по popvalue и которое пишем по pushvalue
{
//;;printf("doval\n");
dovalloop:
  IF (_token==(BYTE)'-') {
//;;printf("valTOKMINUS\n");
        _token = readfin(); //(до входа)
        doval_();
        //asmpushvalue(0L-asmpopvalue()); //BUG!!! TODO fix!
        //asmpushvalue(-asmpopvalue()); //BUG!!! TODO fix!
        tempvalue=asmpopvalue(); asmpushvalue(0L-tempvalue);
        //asmpushvalue(0L); tempvalue=asmpopvalue(); asmpushvalue(asmpopvalue()-tempvalue);
  }ELSE IF (_token==(BYTE)'+') {
//;;printf("valTOKPLUS\n");
        _token = readfin(); //(до входа)
        goto dovalloop;
  }ELSE IF (_token==(BYTE)'$') {
//;;printf("valTOKDOLLAR\n");
        asmpushvalue((LONG)(_curaddr+_curshift)); _isaddr = +_ASMLABEL_ISADDR;
        _token = readfin(); //(до входа)
  }ELSE IF (_token==+_TOKPRIME) {
//;;printf("valTOKPRIME\n");
        asmreadprefixed(); //читаем через readfin, раскрываем \n \r \t \0
        asmpushvalue((LONG)_prefixedtoken);
        readfin(); //закрывающий апостроф
        _token = readfin(); //(до входа)
  }ELSE IF (_token==+_TOKOPEN) {
//;;printf("valTOKOPEN\n");
        _token = readfin(); //(до входа)
        doexpr_();
        _token = readfin(); //(после скобки)
  }ELSE IF (_token==(BYTE)'~') {
//;;printf("valTOKTILDE\n");
        _token = readfin(); //(до входа)
        doval_();
        asmpushvalue(~asmpopvalue());
  }ELSE IF (_token==(BYTE)'!') {
//;;printf("valTOKEXCL\n");
//TODO _TOKSTAR (PEEK)
        _token = readfin(); //(до входа)
        doval_();
        asmpushvalue(!asmpopvalue());
/**  }ELSE IF (_token==+_TOKNUM) { //TODO убрать
        _token = readfin(); //(до входа)
        goto dovalloop;
  }ELSE IF (_token==+_TOKTEXT) { //TODO убрать
        _token = readfin(); //(до входа)
        goto dovalloop;*/
  }ELSE IF ((BYTE)((BYTE)_token - (BYTE)'0') < 0x0a) {
//;;printf("valTOKNUM\n");
        //readfin(); //_TOKTEXT (до входа)
        rdnum_();
        //goto doexprlooptok;
  }ELSE IF (_token==+_TOKDIRECT) { //for ARM
        _token = readfin(); //(до входа)
        goto dovalloop;
  }ELSE /**IF (_token==+_TOKLABEL)*/ {
//;;printf("valTOKLABEL\n");
        readlabel();
        _plabel_index = findlabel(_curlabeltext);
        asmpushvalue(getlabel());
  }/**ELSE {
;;printf("?valTOK %d\n",(UINT)_token);
;;printf("addr=%d\n",_curaddr);
        _token = readfin(); //(до входа)
        goto dovalloop;
  }*/;
//;;printf("dovalq\n");
}
}

PROC doexpr_ RECURSIVE()
{
VAR LONG tempvalue; //значение, считанное по popvalue и которое пишем по pushvalue
{
//читаем до _TOKENDEXPR
//в первой версии считаем слева направо
//TODO switch? или при нескольких уровнях вложенности останется в каждом мало

//пробелы игнорируем (TODO откуда они в конце выражения перед комментарием?): +_TOKSPC0 ... +_TOKSPC0+_ASMMAXSPC-1
//число: <данные>
//метка: <данные>
//закавыченный байт: +_TOKPRIME, <данные>, +_TOKPRIME
//$: +_TOKDOLLAR
//+: _TOKPLUS
//-: _TOKMINUS
//*: +_TOKSTAR
//;;printf("doexpr addr=%d\n",_curaddr);
  doval_(); //первый параметр
doexprloop:
//;;printf("exprTOK %d\n",(UINT)_token);
  IF ((_token==+_TOKENDEXPR/**TODO _TOKENDTEXT*/)||(_token==+_TOKCLOSE)||_waseof) goto doexprq; //BREAK;
  IF (_token==(BYTE)'+') {
//;;printf("TOKPLUS\n");
        _token = readfin(); //(до входа)
        doval_();
        asmpushvalue(asmpopvalue()+asmpopvalue());
  }ELSE IF (_token==(BYTE)'-') {
//;;printf("TOKMINUS\n");
        _token = readfin(); //(до входа)
        doval_();
        tempvalue=asmpopvalue(); asmpushvalue(asmpopvalue()-tempvalue);
  }ELSE IF (_token==(BYTE)'*') {
//;;printf("TOKSTAR\n");
        _token = readfin(); //(до входа)
        doval_();
        asmpushvalue(asmpopvalue()*asmpopvalue()); _isaddr = 0x00;
  }ELSE IF (_token==(BYTE)'/') {
//;;printf("TOKSLASH\n");
        _token = readfin(); //(до входа)
        doval_();
        tempvalue=asmpopvalue();
        {
        ;;IF (tempvalue!=0L)
          asmpushvalue(asmpopvalue()/tempvalue);
        }
  }ELSE IF (_token==(BYTE)'>') {
//;;printf("TOKMORE\n");
        readfin(); //+_TOKMORE (2-й)
//TODO >, >=
        _token = readfin(); //(до входа)
        doval_();
        tempvalue=asmpopvalue(); asmpushvalue(asmpopvalue()>>tempvalue);
  }ELSE IF (_token==(BYTE)'<') {
//;;printf("TOKLESS\n");
//TODO <, <=
//TODO _TOKEQUAL, _TOKEXPL (!=)
        readfin(); //+_TOKLESS (2-й)
        _token = readfin(); //(до входа)
        doval_();
        tempvalue=asmpopvalue(); asmpushvalue(asmpopvalue()<<tempvalue);
  }ELSE IF (_token==(BYTE)'&') {
//;;printf("TOKAND\n");
//TODO также двойные
        _token = readfin(); //(до входа)
        doval_();
        asmpushvalue(asmpopvalue()&asmpopvalue());
  }ELSE IF (_token==(BYTE)'|') {
//;;printf("TOKPIPE\n");
//TODO также двойные
        _token = readfin(); //(до входа)
        doval_();
        asmpushvalue(asmpopvalue()|asmpopvalue());
  }ELSE IF (_token==(BYTE)'^') {
//;;printf("TOKCARON\n");
//TODO также двойные
        _token = readfin(); //(до входа)
        doval_();
        asmpushvalue(asmpopvalue()^asmpopvalue());
  }ELSE IF ((_token-+_TOKSPC1) < 0x08) {
//;;printf("TOKSPC1\n",_curaddr);
        _token = readfin(); //(до входа)
  }ELSE {
//TODO ==, !=
;;printf("?TOK %d\n",(UINT)_token);
;;printf("addr=%d\n",_curaddr);
        _token = readfin(); //(до входа)
  };
  goto doexprloop;
doexprq:
//;;printf("doexprq\n");
}
}

PROC fsm()
{
VAR LONG tempvalue; //значение, считанное по popvalue и которое пишем по pushvalue
VAR UINT i;
  loop:
    _token = readfin();
  looptok:
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

