//// imported
#include "../_sdk/emit.h"

#include "sizesz80.h"

//везде, где нужен строковый параметр, используется _joined
//(кроме call - там _callee, и кроме loadrg/b - там _const)
//в конце любого вычисления (put, call, jpiffalse) делал _jpflag = 0x00 (иначе предыдущее "оптимизированное" сравнение может испортить новый условный переход)
//оставил только в jpiffalse, т.к. остальные не могут быть "оптимизированными"
EXPORT VAR PCHAR _callee; //название вызываемой процедуры (с учётом модуля)
EXPORT VAR UINT  _lencallee;
EXTERN PCHAR _joined; //автометка
EXTERN UINT  _lenjoined;
VAR UINT _oldlen;
EXTERN PCHAR _const; //старая константа
EXTERN UINT  _lenconst;

EXPORT VAR BYTE _exprlvl; //глубина выражения (верхний уровень == 1)

//внешние процедуры (из rgs) - todo в codegen не использовать rgs
EXTERN BYTE _rnew;
EXTERN BYTE _rold;
EXTERN BYTE _rold2;
EXTERN BYTE _rold3;

//rg pool
PROC getnothing FORWARD(); //сохранить регистры и байты в стеке и освободить
//PROC getmainrg FORWARD(); //взять RMAIN=new и освободить остальные регистры
PROC getmain2rgs FORWARD(); //взять RMAIN=old, RMAIN2=new и освободить остальные регистры //для call2rgs
//PROC getmain3rgs FORWARD(); //для call3rgs
PROC getmain4rgs FORWARD(); //для call4rgs
PROC setmainrg FORWARD(); //установить признаки, как будто мы получили результат в регистре //для call2rgs
PROC setmain2rgs FORWARD(); //установить признаки, как будто мы получили результат в регистрах //для call4rgs

PROC rgs_initrgs FORWARD();

////
#define _RGBUFSZ (BYTE)(_NRGS+0x01)

  //приоритеты регистров:
CONST BYTE _RMAIN = 0x01; /**HL*/ /**регистр результата и первого параметра стандартных функций*/
CONST BYTE _RMAIN2= 0x02; /**DE*/ /**регистр второго слова результата и второго параметра стандартных функций*/
CONST BYTE _RMAIN3= 0x03;
CONST BYTE _RMAIN4= 0x04;

CONST BYTE _RNAME[_RGBUFSZ] = {
  0x00, //0 пустой
  +_RG_HL,
  +_RG_DE,
  +_RG_BC,
  +_RG_IX
};
CONST BYTE _RHIGH[_RGBUFSZ] = {
  0x00, //0 пустой
  +_RG_H,
  +_RG_D,
  +_RG_B,
  +_RG_HX
};
CONST BYTE _RLOW[_RGBUFSZ] = {
  0x00, //0 пустой
  +_RG_L,
  +_RG_E,
  +_RG_C,
  +_RG_LX
};

VAR BYTE _rproxy;
VAR BOOL _fused;
VAR BOOL _azused; //A содержит правильный 0/не0 после сравнения

VAR INT _funcstkdepth;

VAR BYTE _jpflag; //0=OR A:JZ, 1=JZ, 2=JNZ, 3=JNC, 4=JC

EXPORT CONST BYTE _typesz[32] = { //размер типа в байтах для таргета //здесь не используется
  _SZ_BYTE/**T_BYTE */, //для всех таргетов
  _SZ_REG/**T_UINT */, //для всех таргетов
  _SZ_REG/**T_INT  */, //для всех таргетов
  _SZ_BOOL/**T_BOOL */,
  _SZ_LONG/**T_LONG */,
  _SZ_BYTE/**T_CHAR */,
  _SZ_LONG/**T_FLOAT*/,
  0x00/**unknown*/,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  _SZ_REG/**T_PBYTE */,
  _SZ_REG/**T_PUINT */,
  _SZ_REG/**T_PINT  */,
  _SZ_REG/**T_PBOOL */,
  _SZ_REG/**T_PLONG */,
  _SZ_REG/**T_PCHAR */,
  _SZ_REG/**T_PFLOAT*/,
  _SZ_REG/**        */,
  _SZ_REG, _SZ_REG, _SZ_REG, _SZ_REG, _SZ_REG, _SZ_REG, _SZ_REG, _SZ_REG //pointer to...
};

CONST BYTE _typeshift[32] = { //log размер типа (n для 2^n байт) для таргета //здесь не используется
  _RL_BYTE/**T_BYTE */, //для всех таргетов
  _RL_REG/**T_UINT */, //для всех таргетов
  _RL_REG/**T_INT  */, //для всех таргетов
  _RL_BOOL/**T_BOOL */,
  _RL_LONG/**T_LONG */,
  _RL_BYTE/**T_CHAR */,
  _RL_LONG/**T_FLOAT*/,
  0x00/**unknown*/,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  _RL_REG/**T_BYTE  */,
  _RL_REG/**T_UINT  */,
  _RL_REG/**T_INT   */,
  _RL_REG/**T_BOOL  */,
  _RL_REG/**T_LONG  */,
  _RL_REG/**T_CHAR  */,
  _RL_REG/**T_PFLOAT*/,
  _RL_REG/**        */,
  _RL_REG, _RL_REG, _RL_REG, _RL_REG, _RL_REG, _RL_REG, _RL_REG, _RL_REG //pointer to...
};

PROC initrgs FORWARD(); //очистить состояния регистров и байтов (используется в cemitfunc)

EXPORT PROC asm_label()
{
  asmc(+_CMDLABEL); //TODO определять по первой букве команды?
}

EXPORT PROC asm_equal()
{
  asmc((BYTE)'='); asmc(+_TOKEXPR); //TODO без _TOKEXPR? (убрать в саму обработку _CMDLABEL) (усложнит экспорт)
}

EXPORT PROC endasm_label()
{
  asmc(+_FMTCMD); endasm(); //там только проверка переопределённости, TODO убрать в саму обработку _CMDLABEL
}

EXPORT PROC endasm_reequ()
{
  asmc(+_TOKENDEXPR); asmc(+_FMTREEQU); endasm(); //TODO убрать
}

EXPORT PROC var_label()
{
  varc(+_CMDLABEL); //TODO определять по первой букве команды?
}

EXPORT PROC endvar_label()
{
  varc(+_FMTCMD); endvar(); //там только проверка переопределённости, TODO убрать в саму обработку _CMDLABEL
}

EXPORT PROC varequ(PCHAR s)
{
  varc(+_CMDLABEL); varstr(s); varc((BYTE)'='); varc(+_TOKEXPR); //TODO без _TOKEXPR? (убрать в саму обработку _CMDLABEL) (усложнит экспорт)
}

EXPORT PROC endvar_reequ()
{
  varc(+_TOKENDEXPR); varc(+_FMTREEQU); endvar(); //TODO убрать
}

EXPORT PROC endasm_db()
{
  asmc(+_TOKENDEXPR); asmc(+_OPWRVAL); asmc(+_FMTCMD); endasm(); //TODO убрать
}

EXPORT PROC endasm_dbstr()
{
  asmc(+_TOKENDTEXT); asmc((BYTE)'\"'); asmc(+_FMTCMD); endasm(); //TODO убрать
}

EXPORT PROC endvar_db()
{
  varc(+_TOKENDEXPR); varc(+_OPWRVAL); varc(+_FMTCMD); endvar(); //TODO убрать
}

EXPORT PROC endvar_dbstr()
{
  varc(+_TOKENDTEXT); varc((BYTE)'\"'); varc(+_FMTCMD); endvar(); //TODO убрать
}

EXPORT PROC endvar_dw()
{
  varc(+_TOKENDEXPR); varc(+_OPWRVAL); varc(+_FMTCMD); endvar(); //TODO убрать
}

EXPORT PROC endvar_dl()
{
  varc(+_TOKENDEXPR); varc(+_OPWRVAL); varc(+_FMTCMD); endvar(); //TODO убрать
}

EXPORT PROC endvar_ds()
{
  varc(+_TOKENDEXPR); varc(+_FMTCMD); endvar();
}

PROC asmexprstr(PCHAR s)
{
  asmc(+_TOKEXPR); asmstr(s); asmc(+_TOKENDEXPR);
}

PROC asmcmd(BYTE c)
{
  asmc(+_TOKSPC8); asmc(c); asmc(+_TOKSPC1);
}

PROC asmcmdfull(BYTE c)
{
  asmc(+_TOKSPC8); asmc(c); asmc(+_FMTXX); endasm(); //TODO писать код в самих командах
}

//////////// мелкие процедуры для сокращения числа констант

EXPORT PROC var_alignwsz()
{
}

PROC flushcall()
{
  if (_wascall) {
    asmcmd(+_ASMCALL); asmexprstr( _callee2 ); asmc(+_FMTJPNN); endasm();
    _wascall = +FALSE;
  };
}

PROC losea()
{
  _callee2[0] = '\0'; //_lencallee2 = 0; //забываем состояние A (запись в память не из A или вычисление)
}

PROC asmexprstr_joined_keep()
{
  asmexprstr(_joined);
  _lencallee2 = strcopy(_joined, _lenjoined, _callee2);
}

PROC asm_comma()
{
  asmc(+_TOKCOMMA);
}

PROC asm_open()
{
  asmc(+_TOKOPENSQ);
}

PROC asm_close()
{
  asmc(+_TOKCLOSESQ);
}

PROC asm_rname(BYTE r){  asmc( _RNAME[(UINT)r] );}
PROC asm_mrgname(BYTE r){  asm_open(); asm_rname(r); asm_close();}

PROC asm_rlow(BYTE r){  asmc( _RLOW[(UINT)r] );}
PROC asm_rhigh(BYTE r){  asmc( _RHIGH[(UINT)r] );}

FUNC BYTE rlow_rnew(){  RETURN _RLOW[(UINT)_rnew];}
FUNC BYTE rhigh_rnew(){  RETURN _RHIGH[(UINT)_rnew];}
FUNC BYTE rlow_rold(){  RETURN _RLOW[(UINT)_rold];}
FUNC BYTE rhigh_rold(){  RETURN _RHIGH[(UINT)_rold];}

PROC asm_rlow_rnew()
{
  asm_rlow(_rnew);
}

PROC asm_rhigh_rnew()
{
  asm_rhigh(_rnew);
}

PROC asm_rlow_rold()
{
  asm_rlow(_rold);
}

PROC asm_rhigh_rold()
{
  asm_rhigh(_rold);
}

PROC asm_close_eol()
{
  asm_close(); endasm();
}

PROC asm_a()
{
  asmc(+_RG_A);
}

PROC asm_hl()
{
  asm_rname(0x01);
}

PROC asm_mhl()
{
  asm_mrgname(0x01);
}

EXPORT PROC asm_db() //костыль для константных массивов строк TODO
{
  asmc(+_TOKSPC8); asmc(+_CMDDB); asmc(+_TOKSPC1); asmc(+_TOKEXPR); //TODO без _TOKEXPR? (убрать в саму обработку команды) (усложнит экспорт)
}

EXPORT PROC asm_dbstr() //костыль для константных массивов строк TODO
{
  asmc(+_TOKSPC8); asmc(+_CMDDB); asmc(+_TOKSPC1); asmc((BYTE)'\"'); asmc(+_OPWRSTR); asmc(+_TOKTEXT); //TODO убрать в саму обработку команды (усложнит экспорт)
}

EXPORT PROC var_db() //доступно из compile!
{
  varc(+_TOKSPC8); varc(+_CMDDB); varc(+_TOKSPC1); varc(+_TOKEXPR); //TODO без _TOKEXPR? (убрать в саму обработку команды) (усложнит экспорт)
}

EXPORT PROC var_dbstr()
{
  varc(+_TOKSPC8); varc(+_CMDDB); varc(+_TOKSPC1); varc((BYTE)'\"'); varc(+_OPWRSTR); varc(+_TOKTEXT); //TODO убрать в саму обработку команды (усложнит экспорт)
}

EXPORT PROC var_dw() //доступно из compile!
{
  varc(+_TOKSPC8); varc(+_CMDDW); varc(+_TOKSPC1); varc(+_TOKEXPR); //TODO без _TOKEXPR? (убрать в саму обработку команды) (усложнит экспорт)
}

PROC var_dl()
{
  varc(+_TOKSPC8); varc(+_CMDDL); varc(+_TOKSPC1); varc(+_TOKEXPR); //TODO без _TOKEXPR? (убрать в саму обработку команды) (усложнит экспорт)
}

EXPORT PROC var_ds() //доступно из compile!
{
  varc(+_TOKSPC8); varc(+_CMDDS); varc(+_TOKSPC1); varc(+_TOKEXPR); //TODO без _TOKEXPR? (убрать в саму обработку команды) (усложнит экспорт)
}

PROC asm_and()
{
  flushcall();
  asmcmd(+_ASMAND);
  losea();
}

PROC asm_or()
{
  flushcall();
  asmcmd(+_ASMOR);
  losea();
}

PROC asm_xor()
{
  flushcall();
  asmcmd(+_ASMXOR);
  losea();
}

PROC asm_inc()
{
  flushcall();
  asmcmd(+_ASMINC);
  losea();
}

PROC asm_dec()
{
  flushcall();
  asmcmd(+_ASMDEC);
  losea();
}

PROC asm_ld()
{
  flushcall();
  asmcmd(+_ASMLD);
}

PROC asm_jp()
{
  flushcall();
  asmcmd(+_ASMJP);
}

PROC emitjrnz(CHAR c)
{
  flushcall();
  asmcmd(+_ASMJR);
  asmc(+_ASMNZ);
  asm_comma();
  asmc(+_TOKEXPR); asmstr( "$+0x" ); asmc((BYTE)c); asmc(+_TOKENDEXPR);
  asmc(+_FMTJRDD);
  endasm();
}

PROC emitjrz(CHAR c)
{
  flushcall();
  asmcmd(+_ASMJR);
  asmc(+_ASMZ);
  asm_comma();
  asmc(+_TOKEXPR); asmstr( "$+0x" ); asmc((BYTE)c); asmc(+_TOKENDEXPR);
  asmc(+_FMTJRDD);
  endasm();
}

PROC asm_ex()
{
  flushcall();
  asmcmd(+_ASMEX);
}

PROC asm_push()
{
  flushcall();
  asmcmd(+_ASMPUSH);
}

PROC asm_pop()
{
  flushcall();
  asmcmd(+_ASMPOP);
}

PROC asm_lda_comma()
{
  asm_ld(); asm_a(); asm_comma();
  losea();
}

PROC asm_ldmhl_comma()
{
  asm_ld(); asm_mhl(); asm_comma();
}

PROC asm_comma_a()
{
  asm_comma(); asm_a();
}

PROC asm_comma_mhl()
{
  asm_comma(); asm_mhl();
}

PROC emitexa()
{
  asm_ex(); asmc(+_RG_AF); asm_comma(); asmc(+_RG_AF); asmc(+_TOKPRIME); asmc(+_FMTEXRPRP); endasm(); //TODO в самом обработчике EX
}

PROC emitexd()
{
  asm_ex(); asmc(+_RG_DE); asm_comma(); asmc(+_RG_HL); asmc(+_FMTEXRPRP); endasm(); //TODO в самом обработчике EX
}

PROC emitccf()
{
  flushcall();
  asmcmdfull(+_ASMCCF);
}

PROC emitrla()
{
  flushcall();
  asmcmdfull(+_ASMRLA);
  losea();
}

PROC emitcpl()
{
  flushcall();
  asmcmdfull(+_ASMCPL);
  losea();
}

PROC emitcall(PCHAR s)
{
  flushcall();
  asmcmd(+_ASMCALL); asmexprstr(s); asmc(+_FMTJPNN); endasm();
}

PROC emitrb0(BYTE r)
{
  asm_ld(); asmc(r); asm_comma(); asmexprstr("0"); asmc(+_FMTLDRBN); endasm();
}

PROC emitarb(BYTE r)
{
  asm_lda_comma(); /**losea*/ asmc(r); asmc(+_FMTMOVRBRB); endasm();
}

PROC emitrba(BYTE r)
{
  asm_ld(); asmc(r); asm_comma_a(); asmc(+_FMTMOVRBRB); endasm();
}

PROC emitamrgn(BYTE r)
{
  asm_lda_comma(); /**losea*/ asm_mrgname(r);
  IF (r==0x01) {asmc(+_FMTGETRBMHL);
  }ELSE asmc(+_FMTGETAMRP);
  endasm();
}

PROC emitmrgna(BYTE r)
{
  asm_ld(); asm_mrgname(r); asm_comma_a();
  IF (r==0x01) {asmc(+_FMTPUTMHLRB);
  }ELSE asmc(+_FMTPUTMRPA);
  endasm();
}

PROC emitrbmhl(BYTE r)
{
  asm_ld(); asmc(r); asm_comma(); asm_mhl(); asmc(+_FMTGETRBMHL); endasm();
}

PROC emitmhlrb(BYTE r)
{
  asm_ld(); asm_mhl(); asm_comma(); asmc(r); asmc(+_FMTPUTMHLRB); endasm();
}

PROC emitincrgn(BYTE r)
{
  flushcall();
  asmcmd(+_ASMINC); asm_rname(r); asmc(+_FMTINCRP); endasm();
}

PROC emitdecrgn(BYTE r)
{
  flushcall();
  asmcmd(+_ASMDEC); asm_rname(r); asmc(+_FMTDECRP); endasm();
}

PROC emitinchl(){  emitincrgn(0x01);}
PROC emitdechl(){  emitdecrgn(0x01);}

PROC emitsubn(PCHAR s)
{
  flushcall();
  asmcmd(+_ASMSUB); asmexprstr(s); asmc(+_FMTALUCMDN); endasm();
  losea();
}

PROC emitsubrb(BYTE r)
{
  flushcall();
  asmcmd(+_ASMSUB); asmc(r); asmc(+_FMTALUCMDRB); endasm();
  losea();
}

PROC emitsbcrgn(BYTE r)
{
  flushcall();
  asmcmd(+_ASMSBC); asm_hl(); asm_comma(); asm_rname(r); asmc(+_FMTSBCHLRP); endasm();
}

PROC emitsbcrb(BYTE r)
{
  flushcall();
  asmcmd(+_ASMSBC); asm_a(); asm_comma(); asmc(r); asmc(+_FMTALUCMDRB); endasm();
  losea();
}

PROC emitaddrgn(BYTE r)
{
  flushcall();
  asmcmd(+_ASMADD);
  IF (r==0x04) {asmc(+_RG_IX); }ELSE asm_hl();
  asm_comma(); asm_rname(r); asmc(+_FMTADDHLRP); endasm();
}

PROC emitaddrb(BYTE r)
{
  flushcall();
  asmcmd(+_ASMADD); asm_a(); asm_comma(); asmc(r); asmc(+_FMTALUCMDRB); endasm();
  losea();
}

PROC emitadcrgn(BYTE r)
{
  flushcall();
  asmcmd(+_ASMADC); asm_hl(); asm_comma(); asm_rname(r); asmc(+_FMTADCHLRP); endasm();
}

PROC emitadcrb(BYTE r)
{
  flushcall();
  asmcmd(+_ASMADC); asm_a(); asm_comma(); asmc(r); asmc(+_FMTALUCMDRB); endasm();
  losea();
}

///////////////////////////////////
//доступны из commands
PROC unproxy() //A возвращает результат в регистр
{
  IF (_rproxy != 0x00) { //в прокси что-то было
    emitrba( _RLOW[_rproxy] );
    _rproxy = 0x00;
  };
}

PROC proxy(BYTE r) //A дублирует регистр
{
  IF (_rproxy != r) {
    unproxy();
    emitarb( _RLOW[r] );
    _rproxy = r;
    losea();
  };
}

///////////////////////////////////////////////////////////
//процедуры с машинным кодом для rgs

PROC emitpushrg(BYTE rnew)
{
  unproxy(); //todo оптимизировать
  asm_push(); asm_rname(rnew); asmc(+_FMTPUSHPOPRP); endasm();
  INC _funcstkdepth;
}

PROC emitpoprg(BYTE rnew) //регистр уже помечен в getrfree/getrg
{
  asm_pop(); asm_rname(rnew); asmc(+_FMTPUSHPOPRP); endasm();
  DEC _funcstkdepth;
}

PROC emitmovrg(BYTE rsrc, BYTE rdest) //не заказывает и не освобождает (см. emitmoverg)
{
  IF (rsrc!=rdest) { //todo или сравнивать rsrc!=rdest снаружи?
    //rdest не может быть FASTRG4? если сделать функцию getslowrg, то может :(
    IF ( ((rdest==0x04)&&(rsrc==0x01))
       ||((rdest==0x01)&&(rsrc==0x04))
       ) {
      asm_push(); asm_rname(rsrc); asmc(+_FMTPUSHPOPRP); endasm();
      asm_pop(); asm_rname(rdest); asmc(+_FMTPUSHPOPRP); endasm();
    }ELSE {
      asm_ld(); asm_rhigh(rdest); asm_comma(); asm_rhigh(rsrc); asmc(+_FMTMOVRBRB); endasm();
      asm_ld(); asm_rlow(rdest); asm_comma(); asm_rlow(rsrc); asmc(+_FMTMOVRBRB); endasm();
    };
  };
}

///////////////////////////////////////////////////////////////////////////////////////
//эти процедуры генерируют код
//недоступны из компилятора, доступны из commands

EXPORT PROC emitasmlabel(PCHAR s)
{
  flushcall();
  asm_label(); asmstr(s); /**asmc( ':' );*/ endasm_label();
  losea();
}

EXPORT PROC emitfunclabel(PCHAR s)
{
  flushcall();
  asm_label(); asmstr(s); /**asmc( ':' );*/ endasm_label();
  losea();
}

EXPORT PROC emitvarlabel(PCHAR s)
{
  var_label(); varstr(s); /**varc( ':' );*/ endvar_label();
}

EXPORT PROC emitexport(PCHAR s) //todo всегда _joined
{
  flushcall();
  asmcmd(+_CMDEXPORT); asmc(+_TOKLABEL); asmstr(s); asmc(+_FMTCMD); endasm(); //TODO убрать +_FMTCMD
}

EXPORT PROC emitvarpreequ(PCHAR s)
{
}

EXPORT PROC emitvarpostequ()
{
}

EXPORT FUNC UINT varshift(UINT shift, UINT sz)
{
  //IF (sz >= 4) shift = (shift+3)&(UINT)(-4);
  //asmexprstr_joined_keep(); asmc('='); asmuint(shift); endasm();
  varequ(_joined); /**varstr(_joined); varc('=');*/ varuint(shift); endvar_reequ();
RETURN shift;
}

PROC emitjpmainrg() //"jp (hl)"
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  unproxy();
  getnothing(); //getnothingword();
  asm_jp(); asm_mhl(); asmc(+_FMTJPRP); endasm();
}

PROC emitcallmainrg() //"call (hl)"
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  unproxy();
  getnothing(); //getnothingword();
  emitcall("_JPHL.");
  _fused = +FALSE; //конец вычисления
}

PROC emitjp()
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  unproxy();
  getnothing(); //getnothingword();
  asm_jp(); asmexprstr(_joined); asmc(+_FMTJPNN); endasm();
}

PROC emitbtoz() //перед jp!
{
  //сразу после сравнения не надо, но вдруг мы читаем BOOL
  //IF (_jpflag == 0x00) {
  IF (!_fused) { //результата нет во флагах
    proxy(_rnew); //todo оптимизировать
    //IF (anew==_RGA) {
      asm_or(); asm_a(); asmc(+_FMTALUCMDRB); endasm();
    //}ELSE {
    //  asm_inc(); /**rganame*/asm_rlow(anew); asmc(+_FMTINCDECRB); endasm();
    //  asm_dec(); /**rganame*/asm_rlow(anew); asmc(+_FMTINCDECRB); endasm();
    //};
  };
  _rproxy = 0x00;
}

PROC emitjpiffalse()
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  //unproxy();
  getnothing(); //getnothingword();
  asm_jp();
  IF       (_jpflag == 0x02) {asmc(+_ASMNZ);
  }ELSE IF (_jpflag == 0x03) {asmc(+_ASMNC);
  }ELSE IF (_jpflag == 0x04) {asmc(+_ASMC);
  }ELSE                      {asmc(+_ASMZ);
  };
  asm_comma();
  asmexprstr(_joined);
  asmc(+_FMTJPNN);
  endasm();
  _fused = +FALSE;
  _jpflag = 0x00;
}

PROC emitret()
{
  //unproxy();
  if (_wascall) {
    asmcmd(+_ASMJP); asmexprstr(_callee2); asmc(+_FMTJPNN); endasm();
    _wascall = +FALSE;
  }else {
    //flushcall();
    asmcmdfull(+_ASMRET);
  };
}

PROC emitcall2rgs(PCHAR s)
{
  unproxy();
  getmain2rgs();
  initrgs();
  emitcall(s);
  setmainrg(); //результат в RMAIN
}
/**
PROC emitcall3rgs(PCHAR s) //todo проверить
{
  unproxy();
  getmain3rgs();
  initrgs();
  emitcall(s);
  //сейчас все регистры отмечены как свободные
  //setwordcontext();
  setmain2rgs(); //результат в RMAIN,RMAIN2
}
*/
PROC emitcall4rgs(PCHAR s) //todo проверить
{
  unproxy();
  getmain4rgs();
  initrgs();
  emitcall(s);
  //сейчас все регистры отмечены как свободные
  //setwordcontext();
  setmain2rgs(); //результат в RMAIN,RMAIN2
}

PROC emitcallproc()
{
  //_jpflag = 0x00;
  flushcall();
  _lencallee2 = strcopy(_callee, _lencallee, _callee2);
  _wascall = +TRUE;
}

PROC emitloadrg(BOOL high) //регистр уже занят через getrfree
{
  IF (high) {
    _lenconst = strjoin(/**to=*/_const, 4, ">>16");
    _joined[_lenjoined] = '\0';
  };
  asm_ld();
  asm_rname(_rnew);
  asm_comma();
  asmexprstr(_const);
  asmc(+_FMTLDRPNN);
  endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitloadrg0() //регистр уже занят через getrfree
{
  asm_ld();
  asm_rname(_rnew);
  asm_comma();
  asmexprstr("0");
  asmc(+_FMTLDRPNN);
  endasm();
}

PROC emitloadb() //аккумулятор уже занят через getfreea
{
  IF (_rproxy == 0x00) {
    _rproxy = _rnew;
    asm_lda_comma();
  }ELSE {
    asm_ld();
    /**rganame*/asmc(rlow_rnew());
    asm_comma();
  };
  asmexprstr(_const);
  asmc(+_FMTLDRBN);
  endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitgetrg(BOOL high) //регистр уже занят через getrfree
{
  _oldlen = _lenjoined;
  IF (high) { //TODO наружу
    joinedadd('+');
    joinedadd('2');
  };
  asm_ld();
  asm_rname(_rnew);
  asm_comma();
  asm_open();
  asmexprstr(_joined);
  asm_close();
  asmc(+_FMTGETRPMNN);
  endasm();
  _lenjoined = _oldlen; _joined[_lenjoined] = '\0';
}

PROC emitgetb() //аккумулятор уже занят через getfreea
{
//если аккумулятор не прокси? и недавно (до другого именованного обращения (сюда также входят вычисление и переход), метки) сохранялся в именованную ячейку через emitputb(), то ничего не делать
  unproxy();
  _rproxy = _rnew;
  if (!strcp(_joined, _callee2)) { //криво!
    asm_lda_comma();
    asm_open();
    asmexprstr_joined_keep();
    asm_close();
    asmc(+_FMTGETAMNN);
    endasm();
  };
}

PROC emitputrg(BOOL high) //ld [],new
{
  //_jpflag = 0x00;
  IF (high) { //TODO наружу
    joinedadd('+');
    joinedadd('2');
  };
  asm_ld(); asm_open();
  asmexprstr(_joined);
  asm_close(); asm_comma();
  asm_rname(_rnew);
  asmc(+_FMTPUTMNNRP);
  endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitputb()
{
  //_jpflag = 0x00;
  proxy(_rnew);
  asm_ld(); asm_open();
  asmexprstr_joined_keep();
  asm_close();
  asm_comma_a();
  asmc(+_FMTPUTMNNA);
  endasm();
  _rproxy = 0x00;
  _fused = +FALSE; //конец вычисления
}

PROC emitshl1rg()
{
  IF ((_rnew==0x01)||(_rnew==0x04)) {
    emitaddrgn(_rnew); //add hl,ix уже там генерируется как add ix,ix
  }ELSE {
    flushcall();
    asmcmd(+_ASMSLA); asmc(rlow_rnew()); asmc(+_FMTCBCMDRB); endasm();
    asmcmd(+_ASMRL); asmc(rhigh_rnew()); asmc(+_FMTCBCMDRB); endasm();
  };
}

PROC emitshl1b()
{
    proxy(_rnew);
  //IF (_rproxy==_rnew) {
    emitaddrb(+_RG_A);
  //}ELSE {
  //  flushcall();
  //  asmcmd(+_ASMSLA); /**rganame*/asm_rlow(anew); asmc(+_FMTCBCMDRB); endasm();
  //};
}
/**
PROC emitshr1rg(BYTE rnew)
{
  flushcall();
  asmcmd(+_ASMSRL); asm_rhigh(rnew); asmc(+_FMTCBCMDRB); endasm();
  asmcmd(+_ASMRR); asm_rlow(rnew); asmc(+_FMTCBCMDRB); endasm();
}

PROC emitshr1signedrg(BYTE rnew)
{
  flushcall();
  asmcmd(+_ASMSRA); asm_rhigh(rnew); asmc(+_FMTCBCMDRB); endasm();
  asmcmd(+_ASMRR); asm_rlow(rnew); asmc(+_FMTCBCMDRB); endasm();
}
*/
//PROC emitshr1b(BYTE anew)
//{
//  flushcall();
//  asmcmd(+_ASMSRL); /**rganame*/asm_rlow(anew] ); asmc(+_FMTCBCMDRB); endasm();
//}

PROC emitinvb() //~A -> A
{
  proxy(_rnew);
  emitcpl();
  _fused = +FALSE; //иначе глюк if (!(a||b))
}

PROC emitinvrg()
{
  unproxy();
  emitarb( rhigh_rnew() );
  emitcpl();
  emitrba( rhigh_rnew() );
  emitinvb(); //_rlow
  unproxy(); //иначе глюк перед poke
}

PROC emitnegrg()
{
  unproxy();
  asm_xor(); asm_a(); asmc(+_FMTALUCMDRB); endasm();
  emitsubrb(rlow_rnew());
  emitrba( rlow_rnew() );
  emitsbcrb(rhigh_rnew());
  emitsubrb(rlow_rnew());
  emitrba( rhigh_rnew() );
}

PROC emitztob()
{
  //asmexprstr(";emitztoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a == b)
    IF (_azused) { //A содержит правильный 0/не0 после сравнения
      //unproxy();
      emitsubn("1");
      emitsbcrb(+_RG_A);
      _rproxy = _rnew;
      _azused = +FALSE;
    }ELSE {
      emitrb0(rlow_rnew());
      IF (_rnew != 0x04) {emitjrnz('3');
      }ELSE emitjrnz('4'); //ix
      asm_dec(); asmc(rlow_rnew()); asmc(+_FMTINCDECRB); endasm();
    };
    _fused = +FALSE; //иначе глюк при if ((a==b))
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x02;
  };
}

PROC emitinvztob()
{
  //asmexprstr(";emitinvztoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a != b)
    IF (_azused) { //A содержит правильный 0/не0 после сравнения
      //unproxy();
      emitjrz('4');
      asm_lda_comma(); asmexprstr("-1"); asmc(+_FMTLDRBN); endasm();
      _rproxy = _rnew;
      _azused = +FALSE;
    }ELSE {
      emitrb0(rlow_rnew());
      IF (_rnew != 0x04) {emitjrz('3');
      }ELSE emitjrz('4'); //ix
      asm_dec(); asmc(rlow_rnew()); asmc(+_FMTINCDECRB); endasm();
    };
    _fused = +FALSE; //иначе глюк при if ((a!=b))? todo test //возможен глюк ifnot ((a!=b))
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x01;
  };
}

PROC emitcytob()
{
  //asmexprstr(";emitcytoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a < b)
    unproxy();
    emitsbcrb(+_RG_A);
    _rproxy = _rnew;
    //_fused = +FALSE;
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x03;
  };
}

PROC emitinvcytob()
{
  //asmexprstr(";emitinvcytoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a >= b)
    emitccf();
    unproxy();
    emitsbcrb(+_RG_A);
    _rproxy = _rnew;
    //_fused = +FALSE;
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x04;
  };
}

PROC emitSxorVtob() //после subflags, разрезервирует A
{
  emitrla(); //sign
  asm_jp(); asmc(+_ASMPO); asm_comma(); asmexprstr( "$+4" ); asmc(+_FMTJPNN); endasm();
  emitccf();
  emitcytob();
}

PROC emitinvSxorVtob() //после subflags, разрезервирует A
{
  emitrla(); //sign
  asm_jp(); asmc(+_ASMPE); asm_comma(); asmexprstr( "$+4" ); asmc(+_FMTJPNN); endasm();
  emitccf();
  emitcytob();
}

PROC emitxorrg() //old^new => old
{
  unproxy();
  emitarb( rhigh_rnew() );
  asm_xor(); asm_rhigh_rold(); asmc(+_FMTALUCMDRB); endasm();
  emitrba( rhigh_rold() );
  emitarb( rlow_rnew() );
  asm_xor(); asm_rlow_rold(); asmc(+_FMTALUCMDRB); endasm();
  emitrba( rlow_rold() );
}

PROC getxorb() //RGA^RGA2 -> RGA
{
  IF (_rproxy == _rnew) {
    asm_xor();
    /**rganame*/asm_rlow_rold();
    _rproxy = _rold;
  }ELSE {
    proxy(_rold);
    asm_xor();
    /**rganame*/asmc(rlow_rnew());
  };
  asmc(+_FMTALUCMDRB);
  endasm();
  _fused = +TRUE; //^^
}

PROC emitorrg() //old|new => old
{
  unproxy();
  emitarb( rhigh_rnew() );
  asm_or(); asm_rhigh_rold(); asmc(+_FMTALUCMDRB); endasm();
  emitrba( rhigh_rold() );
  emitarb( rlow_rnew() );
  asm_or(); asm_rlow_rold(); asmc(+_FMTALUCMDRB); endasm();
  emitrba( rlow_rold() );
}

PROC getorb() //RGA|RGA2 -> RGA
{
  IF (_rproxy == _rnew) {
    asm_or();
    /**rganame*/asm_rlow_rold();
    _rproxy = _rold;
  }ELSE {
    proxy(_rold);
    asm_or();
    /**rganame*/asmc(rlow_rnew());
  };
  asmc(+_FMTALUCMDRB);
  endasm();
  _fused = +TRUE; //||
}

PROC emitandrg() //old&new => old
{
  unproxy();
  emitarb( rhigh_rnew() );
  asm_and(); asm_rhigh_rold(); asmc(+_FMTALUCMDRB); endasm();
  emitrba( rhigh_rold() );
  emitarb( rlow_rnew() );
  asm_and(); asm_rlow_rold(); asmc(+_FMTALUCMDRB); endasm();
  emitrba( rlow_rold() );
}

PROC getandb() //RGA&RGA2 -> RGA
{
  IF (_rproxy == _rnew) {
    asm_and();
    /**rganame*/asm_rlow_rold();
    _rproxy = _rold;
  }ELSE {
    proxy(_rold);
    asm_and();
    /**rganame*/asmc(rlow_rnew());
  };
  asmc(+_FMTALUCMDRB);
  endasm();
  _fused = +TRUE; //&&
}

PROC emitaddrg() //old+new => old
{ //add ix ни разу не потребовался
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    emitaddrgn(_rnew);
  }ELSE IF ((_rold==0x02)&&(_rnew!=0x04)) {
    emitexd(); //todo через swaprgs?
    IF (_rnew==0x01) {emitaddrgn(0x02); //de+hl
    }ELSE emitaddrgn(_rnew);
    emitexd(); //todo через swaprgs?
  }ELSE {
    unproxy();
    emitarb(rlow_rold());
    emitaddrb(rlow_rnew());
    emitrba(rlow_rold());
    emitarb(rhigh_rold());
    emitadcrb(rhigh_rnew());
    emitrba(rhigh_rold());
  };
}

PROC emitadcrg() //old+new => old
{
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    emitadcrgn(_rnew);
  }ELSE IF ((_rold==0x02)&&(_rnew!=0x04)) {
    emitexd(); //todo через swaprgs?
    IF (_rnew==0x01) {emitadcrgn(0x02); //de+hl
    }ELSE emitadcrgn(_rnew);
    emitexd(); //todo через swaprgs?
  }ELSE {
    unproxy();
    emitarb(rlow_rold());
    emitadcrb(rlow_rnew());
    emitrba(rlow_rold());
    emitarb(rhigh_rold());
    emitadcrb(rhigh_rnew());
    emitrba(rhigh_rold());
  };
}

PROC emitaddb() //old+new
{
  IF (_rproxy == _rnew) {
    emitaddrb(rlow_rold());
    _rproxy = _rold;
  }ELSE {
    proxy(_rold);
    emitaddrb(rlow_rnew());
  };
}

PROC emitaddbconst() //new8+<const>
{
  proxy(_rnew);
  flushcall();
  asmcmd(+_ASMADD); asm_a(); asm_comma(); asmexprstr(_const); asmc(+_FMTALUCMDN); endasm();
  losea();
}

PROC emitsubrg() //old-new => old
{
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    asm_or(); asm_a(); asmc(+_FMTALUCMDRB); endasm();
    emitsbcrgn(_rnew);
//exd..exd невыгодно 27 тактов (если через перенумерацию регистров, то будет 23)
  }ELSE {
    unproxy();
    emitarb(rlow_rold());
    emitsubrb(rlow_rnew());
    emitrba(rlow_rold());
    emitarb(rhigh_rold());
    emitsbcrb(rhigh_rnew());
    emitrba(rhigh_rold());
  };
}

PROC emitsbcrg() //old-new => old
{
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    emitsbcrgn(_rnew);
  }ELSE IF ((_rold==0x02)&&(_rnew!=0x04)) {
    emitexd(); //todo через swaprgs?
    IF (_rnew==0x01) {emitsbcrgn(0x02); //de-hl
    }ELSE emitsbcrgn(_rnew);
    emitexd(); //todo через swaprgs?
  }ELSE {
    unproxy();
    emitarb(rlow_rold());
    emitsbcrb(rlow_rnew());
    emitrba(rlow_rold());
    emitarb(rhigh_rold());
    emitsbcrb(rhigh_rnew());
    emitrba(rhigh_rold());
  };
}

PROC emitsubb() //old-new
{
  proxy(_rold);
  emitsubrb(rlow_rnew());
}

PROC emitsubbconst() //new8-<const>
{
  proxy(_rnew);
  emitsubn(_const);
}

PROC emitsubflags(BYTE rnew, BYTE rold) //r2-r1 => CY,sign,overflow
{
  unproxy();
  emitarb(_RLOW[(UINT)rold]);
  emitsubrb(_RLOW[(UINT)rnew]);
  emitarb(_RHIGH[(UINT)rold]);
  emitsbcrb(_RHIGH[(UINT)rnew]);
  _fused = +TRUE;
}

PROC emitsubbflags(BYTE anew, BYTE aold) //a2-a1 => CY
{ //sign,overflow не нужен!
  proxy(aold);
  emitsubrb(_RLOW[(UINT)anew]);
  _rproxy = 0x00;
  _fused = +TRUE;
}

PROC emitsubz() //old-new => Z
{
  IF (_rold == 0x01) {
    emitsubrg();
  }ELSE {
    unproxy();
    emitarb(rlow_rold());
    emitsubrb(rlow_rnew());
    IF ((_rold!=0x04)&&(_rnew!=0x04)) {emitjrnz('4');
    }ELSE emitjrnz('5'); //ix
    emitarb(rhigh_rold());
    emitsubrb(rhigh_rnew());
    _azused = +TRUE; //A содержит правильный 0/не0 после сравнения
  };
  _fused = +TRUE;
}

PROC emitsubbz() //old-new => Z
{
  IF (_rproxy == _rnew) {
    emitsubrb(rlow_rold());
  }ELSE {
    proxy(_rold);
    emitsubrb(rlow_rnew());
  };
  _rproxy = 0x00;
  _azused = +TRUE; //A содержит правильный 0/не0 после сравнения
  _fused = +TRUE;
}

PROC emitsubbzconst() //new-<const> => Z
{
  proxy(_rnew);
  emitsubn(_const);
  _rproxy = 0x00;
  _azused = +TRUE; //A содержит правильный 0/не0 после сравнения
  _fused = +TRUE;
}

PROC emitsublongz() //old2-new, old3-old => Z
//ld a,low(_rold2)
//sub low(_rnew)
//jr nz,$+2+2(1)+1 + 2+1(2)+1 + 2+1(2)+1
//ld a,high(_rold2)
//sub high(_rnew)
//jr nz,$+2+1(2)+1 + 2+1(2)+1
//ld a,low(_rold3)
//sub low(_rold)
//jr nz,$+2+1(2)+1
//ld a,high(_rold3)
//sub high(_rold)
{
  unproxy();
  emitarb(_RLOW[(UINT)_rold2]);
  emitsubrb(rlow_rnew());
  IF ((_rold3!=0x04)&&(_rold!=0x04)) {emitjrnz('d'); //5+4+4//ix в rold2 или rnew
  }ELSE emitjrnz('e'); //4+5+5//ix в rold3 или rold
  emitarb(_RHIGH[(UINT)_rold2]);
  emitsubrb(rhigh_rnew());
  IF ((_rold3!=0x04)&&(_rold!=0x04)) {emitjrnz('8');
  }ELSE emitjrnz('a'); //ix
  emitarb(_RLOW[(UINT)_rold3]);
  emitsubrb(rlow_rold());
  IF ((_rold3!=0x04)&&(_rold!=0x04)) {emitjrnz('4');
  }ELSE emitjrnz('5'); //ix
  emitarb(_RHIGH[(UINT)_rold3]);
  emitsubrb(rhigh_rold());
  _fused = +TRUE;
}

PROC emitpokerg() //новое записываем в старую локацию памяти
{
  IF ((_rold == 0x01)&&(_rnew!=0x04)) {
    emitmhlrb(rlow_rnew());
    emitinchl();
    emitmhlrb(rhigh_rnew());
  }ELSE {
    unproxy();
    emitarb(rlow_rnew());
    emitmrgna(_rold);
    emitincrgn(_rold);
    emitarb(rhigh_rnew());
    emitmrgna(_rold);
  };
  _fused = +FALSE; //конец вычисления
  losea();
}

PROC emitpokeb() //новое записываем в старую локацию памяти
//в rnew может не быть данных, если rproxy==rnew!!!
{
  IF ((_rold==0x01) && (_rnew!=0x04) && (_rproxy!=_rnew)) {
    emitmhlrb(rlow_rnew());
    losea(); //если специально записали в ячейку, которую хранит A
  }ELSE {
    proxy(_rnew); //иначе нет команды ld [rp],rg
    emitmrgna(_rold);
  };
  _rproxy = 0x00;
  _fused = +FALSE; //конец вычисления
}

PROC emitpokelong() //old2(addr), old(high), new(low)
{
  IF ((_rold2==0x01)&&(_rnew!=0x04)) {
    emitmhlrb(rlow_rnew());
    emitinchl();
    emitmhlrb(rhigh_rnew());
    emitinchl();
    emitmhlrb(rlow_rold());
    emitinchl();
    emitmhlrb(rhigh_rold());
  }ELSE {
    unproxy();
    emitarb(rlow_rnew());
    emitmrgna(_rold2);
    emitincrgn(_rold2);
    emitarb(rhigh_rnew());
    emitmrgna(_rold2);
    emitincrgn(_rold2);
    emitarb(rlow_rold());
    emitmrgna(_rold2);
    emitincrgn(_rold2);
    emitarb(rhigh_rold());
    emitmrgna(_rold2);
  };
  _fused = +FALSE; //конец вычисления
  losea();
}

PROC emitpeekrg() //[new] => new
{
  unproxy();
  IF (_rnew==0x01) { //hl
    emitamrgn(0x01);
    emitinchl();
    emitrbmhl(+_RG_H);
    emitrba(+_RG_L);
  }ELSE {
    emitamrgn(_rnew);
    emitincrgn(_rnew);
    emitexa();
    emitamrgn(_rnew);
    emitrba(rhigh_rnew());
    emitexa();
    emitrba(rlow_rnew());
  };
}

PROC emitpeekb()
{
//  IF (_rnew==0x01) {
//    emitrbmhl(+_RG_L); //невыгодно
//  }ELSE {
    unproxy();
    _rproxy = _rnew;
    emitamrgn(_rnew);
//  };
}

PROC emitpeeklong() //[old] => old(high),new(low)
{
  unproxy();
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    emitrbmhl(rlow_rnew());
    emitinchl();
    emitrbmhl(rhigh_rnew());
    emitinchl();
    emitamrgn(0x01);
    emitinchl();
    emitrbmhl(+_RG_H);
    emitrba(+_RG_L);
  }ELSE {
    emitamrgn(_rold);
    emitincrgn(_rold);
    emitrba(rlow_rnew());
    emitamrgn(_rold);
    emitincrgn(_rold);
    emitrba(rhigh_rnew());
    emitamrgn(_rold);
    emitincrgn(_rold);
    emitexa();
    emitamrgn(_rold);
    emitrba(rhigh_rold());
    emitexa();
    emitrba(rlow_rold());
  };
}

PROC emitrgtob() //нельзя убирать - специфично
{
}

PROC emitbtorg()
{
  unproxy();
  emitrb0(rhigh_rnew());
}

PROC emitincrg_byname()
{
  emitgetrg(+FALSE);
  emitincrgn(_rnew);
  emitputrg(+FALSE);
  _fused = +FALSE; //конец вычисления
}

PROC emitincb_bypoi()
{
  IF (_rnew==0x01) { //hl
    asm_inc(); asm_open(); asm_rname(0x01); asm_close(); asmc(+_FMTINCDECMHL); endasm();
  }ELSE IF (_rnew==0x04) { //ix
    asm_inc(); asm_open(); asm_rname(0x04); asm_close(); asmc(+_FMTINCDECIDX); endasm();
  }ELSE IF (_rnew==0x02) { //de
    emitexd(); //todo через swaprgs?
    asm_inc(); asm_mhl(); asmc(+_FMTINCDECMHL); endasm();
    emitexd(); //todo через swaprgs?
  }ELSE /**IF (_rnew==0x03)*/ { //bc
    unproxy();
    emitamrgn(_rnew);
    asm_inc(); asm_a(); asmc(+_FMTINCDECRB); endasm();
    asm_ld(); asm_open(); asm_rname(_rnew); asm_close(); asm_comma_a(); asmc(+_FMTPUTMRPA); endasm();
  };
  _fused = +FALSE; //конец вычисления
  losea();
}
/**
PROC emitinclong() //todo
{
  asm_inc(); asm_open(); asm_rname(_rnew); asm_close(); asmc(+_FMTINCDECMHL); endasm();
  _fused = +FALSE; //конец вычисления
}
*/
PROC emitdecrg_byname()
{
  emitgetrg(+FALSE);
  emitdecrgn(_rnew);
  emitputrg(+FALSE);
  _fused = +FALSE; //конец вычисления
}

PROC emitdecb_bypoi()
{
  IF (_rnew==0x01) { //hl
    asm_dec(); asm_open(); asm_rname(0x01); asm_close(); asmc(+_FMTINCDECMHL); endasm();
  }ELSE IF (_rnew==0x04) { //ix
    asm_dec(); asm_open(); asm_rname(0x04); asm_close(); asmc(+_FMTINCDECIDX); endasm();
  }ELSE IF (_rnew==0x02) { //de
    emitexd(); //todo через swaprgs?
    asm_dec(); asm_mhl(); asmc(+_FMTINCDECMHL); endasm();
    emitexd(); //todo через swaprgs?
  }ELSE /**IF (_rnew==0x03)*/ { //bc
    unproxy();
    emitamrgn(_rnew);
    asm_dec(); asm_a(); asmc(+_FMTINCDECRB); endasm();
    asm_ld(); asm_open(); asm_rname(_rnew); asm_close(); asm_comma_a(); asmc(+_FMTPUTMRPA); endasm();
  };
  _fused = +FALSE; //конец вычисления
  losea();
}
/**
PROC emitdeclong() //todo
{
  asm_dec(); asm_open(); asm_rname(_rnew); asm_close(); asmc(+_FMTINCDECMHL); endasm();
  _fused = +FALSE; //конец вычисления
}
*/

PROC emitincrg_bypoi() //[old], new free
{
  IF (_rold==0x01) { //hl
    emitrbmhl(rlow_rnew());
    emitinchl();
    emitrbmhl(rhigh_rnew());

    emitincrgn(_rnew);

    emitmhlrb(rhigh_rnew());
    emitdechl();
    emitmhlrb(rlow_rnew());
  }ELSE {
    unproxy();
    emitamrgn(_rold);
    emitrba(rlow_rnew());
    emitincrgn(_rold);
    emitamrgn(_rold);
    emitrba(rhigh_rnew());

    emitincrgn(_rnew);

    emitarb(rhigh_rnew());
    emitmrgna(_rold);
    emitdecrgn(_rold);
    emitarb(rlow_rnew());
    emitmrgna(_rold);
  };
  _fused = +FALSE; //конец вычисления
  losea();
}

PROC emitdecrg_bypoi() //[old], new free
{
  IF (_rold==0x01) { //hl
    emitrbmhl(rlow_rnew());
    emitinchl();
    emitrbmhl(rhigh_rnew());

    emitdecrgn(_rnew);

    emitmhlrb(rhigh_rnew());
    emitdechl();
    emitmhlrb(rlow_rnew());
  }ELSE {
    unproxy();
    emitamrgn(_rold);
    emitrba(rlow_rnew());
    emitincrgn(_rold);
    emitamrgn(_rold);
    emitrba(rhigh_rnew());

    emitdecrgn(_rnew);

    emitarb(rhigh_rnew());
    emitmrgna(_rold);
    emitdecrgn(_rold);
    emitarb(rlow_rnew());
    emitmrgna(_rold);
  };
  _fused = +FALSE; //конец вычисления
  losea();
}

/////////////
EXPORT PROC initcode()
{
  _jpflag = 0x00;
}

EXPORT PROC endcode()
{
  asmc(+_TOKEOF);
  varc(+_TOKEOF);
}

PROC initrgs()
{
  rgs_initrgs();
  _azused = +FALSE;
  _fused = +FALSE; //можно сделать одну процедуру initif для этого (вызывать в начале if, while, until)
  _rproxy = 0x00;
}

PROC emitfunchead()
{
  initrgs();
}

PROC setmainb()
{
  setmainrg(); //результат в RMAIN
  _rproxy = _RMAIN;
}

PROC prefernoregs()
{
  getnothing(); //так выгоднее inc/dec
}
