//// imported
#include "../_sdk/emit.h"

#include "sizes386.h"

//везде, где нужен строковый параметр, используется _joined
//(кроме call - там _callee, и кроме loadrg/b - там _const)
//в конце любого вычисления (put, call, jpiffalse) делал _jpflag = 0x00 (иначе предыдущее "оптимизированное" сравнение может испортить новый условный переход)
//оставил только в jpiffalse, т.к. остальные не могут быть "оптимизированными"
EXPORT VAR PCHAR _callee; //название вызываемой процедуры (с учётом модуля)
EXPORT VAR UINT  _lencallee;
EXTERN PCHAR _joined; //автометка
EXTERN UINT  _lenjoined;
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
CONST BYTE _RMAIN = 0x01; /**EAX*/ /**регистр результата и первого параметра стандартных функций*/
CONST BYTE _RMAIN2= 0x02; /**EBX*/ /**регистр второго слова результата и второго параметра стандартных функций*/
CONST BYTE _RMAIN3= 0x03;
CONST BYTE _RMAIN4= 0x04;

CONST PCHAR _RNAME[_RGBUFSZ] = {
  "", //0 пустой
  "EAX",
  "EBX",
  "ECX",
  "EDX"
};
/**
CONST PCHAR _RHIGH[_RGBUFSZ] = {
  "", //0 пустой
  "H",
  "D",
  "B",
  "HX"
};*/
CONST PCHAR _RLOW[_RGBUFSZ] = {
  "", //0 пустой
  "AL",
  "BL",
  "CL",
  "DL"
};

VAR BYTE _rproxy;
VAR BOOL _fused;
//VAR BOOL _azused; //A содержит правильный 0/не0 после сравнения

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

//////////// мелкие процедуры для сокращения числа констант

EXPORT PROC var_alignwsz()
{
}

PROC asm_comma()
{
  asmc(',');
}

PROC asm_open()
{
  asmc('[');
}

PROC asm_close()
{
  asmc(']');
}

PROC asm_rname(BYTE r)
{
  asmstr( _RNAME[(UINT)r] );
}

PROC asm_mrgname(BYTE r)
{
  asm_open(); asm_rname(r); asm_close();
}

PROC asm_rlow(BYTE r)
{
  asmstr( _RLOW[(UINT)r] );
}
/**
PROC asm_rhigh(BYTE r)
{
  asmstr( _RHIGH[(UINT)r] );
}
*/
PROC asm_close_eol()
{
  asm_close(); endasm();
}

EXPORT PROC var_db() //доступно из compile!
{
  varstr( "\tDB " );
}

EXPORT PROC asm_db() //костыль для константных массивов строк TODO
{
  asmstr( "\tDB " );
}

EXPORT PROC var_dw() //доступно из compile!
{
  varstr( "\tDW " );
}

PROC var_dl()
{
  varstr( "\tDL " );
}

EXPORT PROC var_ds() //доступно из compile!
{
  varstr( "\tDS " );
}

PROC asm_and()
{
  asmstr( "\tAND " );
}

PROC asm_or()
{
  asmstr( "\tOR " );
}

PROC asm_xor()
{
  asmstr( "\tXOR " );
}

PROC asm_sub()
{
  asmstr( "\tSUB " );
}

PROC asm_sbc()
{
  asmstr( "\tSBB " );
}

PROC asm_add()
{
  asmstr( "\tADD " );
}

PROC asm_adc()
{
  asmstr( "\tADC " );
}

PROC asm_inc()
{
  asmstr( "\tINC " );
}

PROC asm_dec()
{
  asmstr( "\tDEC " );
}

PROC asm_not()
{
  asmstr( "\tNOT " );
}

PROC asm_ld()
{
  asmstr( "\tMOV " );
}

PROC asm_jp()
{
  asmstr( "\tJMP " );
}

PROC asm_jnz()
{
  asmstr( "\tJNZ " );
}

PROC asm_jz()
{
  asmstr( "\tJZ " );
}

PROC asm_jnc()
{
  asmstr( "\tJNC " );
}

PROC asm_jc()
{
  asmstr( "\tJC " );
}

PROC asm_push()
{
  asmstr( "\tPUSH " );
}

PROC asm_pop()
{
  asmstr( "\tPOP " );
}

PROC emitccf()
{
  asmstr( "\tCMC" ); endasm();
}

PROC emitcall(PCHAR s)
{
  asmstr( "\tCALL " ); asmstr( s ); endasm();
}

///////////////////////////////////
//доступны из commands
PROC unproxy()
{
  //IF (_rproxy != 0x00) { //в прокси что-то было
  //  asm_ld(); /**rganame*/asm_rlow(_rproxy); asm_comma_a_eol();
  //  _rproxy = 0x00;
  //};
}

PROC proxy(BYTE r)
{
  //IF (_rproxy != r) {
  //  unproxy();
  //  asm_lda_comma(); /**rganame*/asm_rlow(r); endasm();
  //  _rproxy = r;
  //};
}

///////////////////////////////////////////////////////////
//процедуры с машинным кодом для rgs

PROC emitpushrg(BYTE rnew)
{
  unproxy(); //todo оптимизировать
  asm_push(); asm_rname(rnew); endasm();
  INC _funcstkdepth;
}

PROC emitpoprg(BYTE rnew) //регистр уже помечен в getrfree/getrg
{
  asm_pop(); asm_rname(rnew); endasm();
  DEC _funcstkdepth;
}

PROC emitmovrg(BYTE rsrc, BYTE rdest) //не заказывает и не освобождает (см. emitmoverg)
{
  IF (rsrc!=rdest) { //todo или сравнивать rsrc!=rdest снаружи?
      asm_ld(); asm_rname(rdest); asm_comma(); asm_rname(rsrc); endasm();
  };
}

///////////////////////////////////////////////////////////////////////////////////////
//эти процедуры генерируют код
//недоступны из компилятора, доступны из commands

EXPORT PROC emitasmlabel(PCHAR s)
{
  asmstr(s); /**asmc( ':' );*/ endasm();
}

EXPORT PROC emitfunclabel(PCHAR s)
{
  asmstr(s); /**asmc( ':' );*/ endasm();
}

EXPORT PROC emitvarlabel(PCHAR s)
{
  varstr(s); /**varc( ':' );*/ endvar();
}

EXPORT PROC emitexport(PCHAR s) //todo всегда _joined
{
  asmstr("\tEXPORT "); asmstr(s); endasm();
}

EXPORT PROC emitvarpreequ(PCHAR s)
{
}

EXPORT PROC emitvarpostequ()
{
}

EXPORT PROC varequ(PCHAR s)
{
  varstr(s); varc('=');
}

EXPORT FUNC UINT varshift(UINT shift, UINT sz)
{
  //IF (sz >= 4) shift = (shift+3)&(UINT)(-4);
  //asmstr(_joined); asmc('='); asmuint(shift); endasm();
  varequ(_joined); /**varstr(_joined); varc('=');*/ varuint(shift); endvar();
RETURN shift;
}

PROC emitret()
{
  //unproxy();
  asmstr( "\tRET" ); endasm();
}

PROC emitjpmainrg() //"jp (hl)"
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  unproxy();
  getnothing(); //getnothingword();
  //asm_jp(); asm_mhl(); endasm();
  emitpushrg(0x01);
  emitret();
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
  asm_jp(); asmstr(_joined); endasm();
}

PROC emitbtoz() //перед jp!
{
  //сразу после сравнения не надо, но вдруг мы читаем BOOL
  //IF (_jpflag == 0x00) {
  IF (!_fused) { //результата нет во флагах
    //proxy(_rnew); //todo оптимизировать
    //IF (anew==_RGA) {
      //asm_or(); asmrname(_rnew); asm_comma(); asmrname(_rnew); endasm();
    //}ELSE {
      asm_inc(); asm_rlow(_rnew); endasm();
      asm_dec(); asm_rlow(_rnew); endasm();
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
  IF       (_jpflag == 0x02) {asm_jnz();
  }ELSE IF (_jpflag == 0x03) {asm_jnc();
  }ELSE IF (_jpflag == 0x04) {asm_jc();
  }ELSE                      {asm_jz();
  };
  asmstr(_joined);
  endasm();
  _fused = +FALSE;
  _jpflag = 0x00;
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
  emitcall(_callee);
}

PROC emitloadrg(BOOL high) //регистр уже занят через getrfree
{
  asm_ld();
  asm_rname(_rnew);
  asm_comma();
  asmstr(_const);
  IF (high) {asmstr( ">>32"/**WORDBITS*/ );
  //}ELSE {asmstr( "&0xffff"/**WORDMASK*/ );
  };
  endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitloadrg0() //регистр уже занят через getrfree
{
  asm_ld(); asm_rname(_rnew); asm_comma(); asmc('0'); endasm();
}

PROC emitloadb() //аккумулятор уже занят через getfreea
{
  asm_ld();
  asm_rlow(_rnew);
  asm_comma();
  asmstr(_const);
  endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitgetrg(BOOL high) //регистр уже занят через getrfree
{
  asm_ld();
  asm_rname(_rnew);
  asm_comma();
  asm_open();
  asmstr(_joined);
  IF (high) {asmc('+'); asmc('4');
  };
  asm_close();
  endasm();
}

PROC emitgetb() //аккумулятор уже занят через getfreea
{
  asm_ld();
  asm_rlow(_rnew);
  asm_comma();
  asm_open();
  asmstr(_joined);
  asm_close();
  endasm();
}

PROC emitputrg(BOOL high) //ld [],new
{
  //_jpflag = 0x00;
  asm_ld(); asm_open();
  asmstr(_joined);
  IF (high) {asmc('+'); asmc('4');
  };
  asm_close(); asm_comma();
  asm_rname(_rnew); endasm();
  endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitputb()
{
  //_jpflag = 0x00;
//  proxy(_rnew);
  asm_ld(); asm_open();
  asmstr(_joined);
  asm_close(); asm_comma();
  asm_rlow(_rnew); endasm();
//  _rproxy = 0x00;
  _fused = +FALSE; //конец вычисления
}

PROC emitshl1rg()
{
  asmstr( "\tSHL " ); asm_rname(_rnew); endasm();
}

PROC emitshl1b()
{
  asmstr( "\tSHL " ); asm_rlow(_rnew); endasm();
//    proxy(_rnew);
  //IF (_rproxy==_rnew) {
//    asm_add(); asm_a(); asm_comma_a_eol();
  //}ELSE {
  //  asmstr( "\tSLA " ); /**rganame*/asm_rlow(anew); endasm();
  //};
}
/**
PROC emitshr1rg(BYTE rnew)
{
  asmstr( "\tSRL " ); asm_rhigh(rnew); endasm();
  asmstr( "\tRR " ); asm_rlow(rnew); endasm();
}

PROC emitshr1signedrg(BYTE rnew)
{
  asmstr( "\tSRA " ); asm_rhigh(rnew); endasm();
  asmstr( "\tRR " ); asm_rlow(rnew); endasm();
}
*/
//PROC emitshr1b(BYTE anew)
//{
//  asmstr( "\tSRL " ); /**rganame*/asm_rlow(anew] ); endasm();
//}

PROC emitinvb() //~A -> A
{
//  proxy(_rnew);
//  asmstr( "\tCPL" ); endasm();
  asm_not(); asm_rlow(_rnew); endasm();
  _fused = +FALSE; //иначе глюк if (!(a||b))
}

PROC emitinvrg()
{
//  unproxy();
  asm_not(); asm_rname(_rnew); endasm();
}

PROC emitnegrg()
{
//  unproxy();
  asm_not(); asm_rname(_rnew); endasm();
  asm_inc(); asm_rname(_rnew); endasm();
}

PROC emitztob()
{
  //asmstr(";emitztoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a == b)
    asm_ld(); asm_rlow(_rnew); asm_comma(); asmc('0'); endasm();
    asmstr( "\tJNZ $+3" ); endasm();
    asm_dec(); asm_rlow(_rnew); endasm();
    _fused = +FALSE; //иначе глюк при if ((a==b))
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x02;
  };
}

PROC emitinvztob()
{
  //asmstr(";emitinvztoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a != b)
    asm_ld(); asm_rlow(_rnew); asm_comma(); asmc('0'); endasm();
    asmstr( "\tJZ $+3" ); endasm();
    asm_dec(); asm_rlow(_rnew); endasm();
    _fused = +FALSE; //иначе глюк при if ((a!=b))? todo test //возможен глюк ifnot ((a!=b))
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x01;
  };
}

PROC emitcytob()
{
  //asmstr(";emitcytoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a < b)
//    unproxy();
    asm_sbc(); asm_rlow(_rnew); asm_comma(); asm_rlow(_rnew); endasm();
//    _rproxy = _rnew;
    //_fused = +FALSE;
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x03;
  };
}

PROC emitinvcytob()
{
  //asmstr(";emitinvcytoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a >= b)
    emitccf();
//    unproxy();
    asm_sbc(); asm_rlow(_rnew); asm_comma(); asm_rlow(_rnew); endasm();
//    _rproxy = _rnew;
    //_fused = +FALSE;
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x04;
  };
}

PROC emitSxorVtob() //после subflags, разрезервирует A
{ //todo проверить
  asm_ld(); asm_rname(_rnew); asm_comma(); asmc('0'); endasm();
  asmstr( "\tJG $+4" ); endasm();
  asm_not(); asm_rlow(_rnew); endasm();
}

PROC emitinvSxorVtob() //после subflags, разрезервирует A
{ //todo проверить
  asm_ld(); asm_rname(_rnew); asm_comma(); asmc('0'); endasm();
  asmstr( "\tJLE $+4" ); endasm();
  asm_not(); asm_rlow(_rnew); endasm();
}

PROC emitxorrg() //old^new => old
{
//  unproxy();
  asm_xor(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
}

PROC getxorb() //RGA^RGA2 -> RGA
{
  asm_xor(); asm_rlow(_rold); asm_comma(); asm_rlow(_rnew); endasm();
  _fused = +TRUE; //^^
}

PROC emitorrg() //old|new => old
{
//  unproxy();
  asm_or(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
}

PROC getorb() //RGA|RGA2 -> RGA
{
  asm_or(); asm_rlow(_rold); asm_comma(); asm_rlow(_rnew); endasm();
  _fused = +TRUE; //||
}

PROC emitandrg() //old&new => old
{
//  unproxy();
  asm_and(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
}

PROC getandb() //RGA&RGA2 -> RGA
{
  asm_and(); asm_rlow(_rold); asm_comma(); asm_rlow(_rnew); endasm();
  _fused = +TRUE; //&&
}

PROC emitaddrg() //old+new => old
{
//  unproxy();
  asm_add(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
}

PROC emitadcrg() //old+new => old
{
//  unproxy();
  asm_adc(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
}

PROC emitaddb() //old+new
{
  asm_add(); asm_rlow(_rold); asm_comma(); asm_rlow(_rnew); endasm();
}

PROC emitaddbconst() //new8+<const>
{
  asm_add(); asm_rlow(_rnew); asm_comma(); asmstr(_const); endasm();
}

PROC emitsubrg() //old-new => old
{
//  unproxy();
  asm_sub(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
}

PROC emitsbcrg() //old-new => old
{
//  unproxy();
  asm_sbc(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
}

PROC emitsubb() //old-new
{
  asm_sub(); asm_rlow(_rold); asm_comma(); asm_rlow(_rnew); endasm();
}

PROC emitsubbconst() //new8-<const>
{
  asm_sub(); asm_rlow(_rnew); asm_comma(); asmstr(_const); endasm();
}

PROC emitsubflags(BYTE rnew, BYTE rold) //r2-r1 => CY,sign,overflow
{
//  unproxy();
  asm_sub(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
  _fused = +TRUE;
}

PROC emitsubbflags(BYTE anew, BYTE aold) //a2-a1 => CY
{ //sign,overflow не нужен!
//  proxy(aold);
  asm_sub(); asm_rlow(_rold); asm_comma(); asm_rlow(_rnew); endasm();
  _fused = +TRUE;
}

PROC emitsubz() //old-new => Z
{
// unproxy();
  asm_sub(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasm();
//    _azused = +TRUE; //A содержит правильный 0/не0 после сравнения
  _fused = +TRUE;
}

PROC emitsubbz() //old-new => Z
{
  asm_sub(); asm_rlow(_rold); asm_comma(); asm_rlow(_rnew); endasm();
//  _rproxy = 0x00;
//  _azused = +TRUE; //A содержит правильный 0/не0 после сравнения
  _fused = +TRUE;
}

PROC emitsubbzconst() //new-<const> => Z
{
//  proxy(_rnew);
  asm_sub(); asm_rlow(_rnew); asm_comma(); asmstr(_const); endasm();
//  _rproxy = 0x00;
//  _azused = +TRUE; //A содержит правильный 0/не0 после сравнения
  _fused = +TRUE;
}

PROC emitsublongz() //old2-new, old3-old => Z
{
//  unproxy();
  asm_sub(); asm_rname(_rold2); asm_comma(); asm_rname(_rnew); endasm();
  asmstr( "\tJNZ $+4" ); endasm();
  asm_sub(); asm_rname(_rold3); asm_comma(); asm_rname(_rold); endasm();
  _fused = +TRUE;
}

PROC emitpokerg() //новое записываем в старую локацию памяти
{
  asm_ld(); asm_mrgname(_rold); asm_comma(); asm_rname(_rnew); endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitpokeb() //новое записываем в старую локацию памяти
//в rnew может не быть данных, если rproxy==rnew!!!
{
  asm_ld(); asm_mrgname(_rold); asm_comma(); asm_rlow(_rnew); endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitpokelong() //old2(addr), old(high), new(low)
{
  asm_ld(); asm_mrgname(_rold2); asm_comma(); asm_rname(_rold); endasm();
  asm_ld(); asm_open(); asm_rname(_rold2); asmc('+'); asmc('4'); asm_close(); asm_comma(); asm_rname(_rnew); endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitpeekrg() //[new] => new
{
  asm_ld(); asm_rname(_rnew); asm_comma(); asm_mrgname(_rnew); endasm();
}

PROC emitpeekb()
{
  asm_ld(); asm_rlow(_rnew); asm_comma(); asm_mrgname(_rold); endasm();
}

PROC emitpeeklong() //[old] => old(high),new(low)
{
  asm_ld(); asm_rname(_rnew); asm_comma(); asm_mrgname(_rold); endasm();
  asm_ld(); asm_rname(_rold); asm_comma(); asm_open(); asm_rname(_rold); asmc('+'); asmc('4'); asm_close(); endasm();
}

PROC emitrgtob() //нельзя убирать - специфично
{
  asm_and(); asm_rname(_rnew); asm_comma(); asmstr("0xff"); endasm();
}

PROC emitbtorg() //нельзя убирать - специфично
{
}

PROC emitincrg_byname()
{
  emitgetrg(+FALSE);
  asm_inc(); asm_rname(_rnew); endasm();
  emitputrg(+FALSE);
  _fused = +FALSE; //конец вычисления
}

PROC emitincb_bypoi()
{
  asm_inc(); asm_open(); asm_rname(_rnew); asm_close(); endasm();
  _fused = +FALSE; //конец вычисления
}
/**
PROC emitinclong() //todo
{
  asm_inc(); asm_open(); asm_rname(_rnew); asm_close(); endasm();
  _fused = +FALSE; //конец вычисления
}
*/
PROC emitdecrg_byname()
{
  emitgetrg(+FALSE);
  asm_dec(); asm_rname(_rnew); endasm();
  emitputrg(+FALSE);
  _fused = +FALSE; //конец вычисления
}

PROC emitdecb_bypoi()
{
  asm_dec(); asm_open(); asm_rname(_rnew); asm_close(); endasm();
  _fused = +FALSE; //конец вычисления
}
/**
PROC emitdeclong() //todo
{
  asm_dec(); asm_open(); asm_rname(_rnew); asm_close(); endasm();
  _fused = +FALSE; //конец вычисления
}
*/

PROC emitincrg_bypoi() //[old], new free
{
  asm_ld(); asm_rname(_rnew); asm_comma(); asm_open(); asm_rname(_rold); asm_close(); endasm();
  asm_inc(); asm_rname(_rnew); endasm();
  asm_ld(); asm_open(); asm_rname(_rold); asm_close(); asm_comma(); asm_rname(_rnew); endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitdecrg_bypoi() //[old], new free
{
  asm_ld(); asm_rname(_rnew); asm_comma(); asm_open(); asm_rname(_rold); asm_close(); endasm();
  asm_dec(); asm_rname(_rnew); endasm();
  asm_ld(); asm_open(); asm_rname(_rold); asm_close(); asm_comma(); asm_rname(_rnew); endasm();
  _fused = +FALSE; //конец вычисления
}

/////////////
EXPORT PROC initcode()
{
  _jpflag = 0x00;
}

EXPORT PROC endcode()
{
}

PROC initrgs()
{
  rgs_initrgs();
//  _azused = +FALSE;
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
