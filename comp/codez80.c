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

CONST PCHAR _RNAME[_RGBUFSZ] = {
  "", //0 пустой
  "HL",
  "DE",
  "BC",
  "IX"
};
CONST PCHAR _RHIGH[_RGBUFSZ] = {
  "", //0 пустой
  "H",
  "D",
  "B",
  "HX"
};
CONST PCHAR _RLOW[_RGBUFSZ] = {
  "", //0 пустой
  "L",
  "E",
  "C",
  "LX"
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
  asmstr( _RNAME[+(UINT)r] );
}

PROC asm_mrgname(BYTE r)
{
  asm_open(); asm_rname(r); asm_close();
}

PROC asm_rlow(BYTE r)
{
  asmstr( _RLOW[+(UINT)r] );
}

PROC asm_rhigh(BYTE r)
{
  asmstr( _RHIGH[+(UINT)r] );
}
/**
PROC asm_raname(BYTE r)
{
  asmstr( _RLOW[+(UINT)r] );
  //asmstr( _RGANAME[+(UINT)r] );
}
*/
PROC asm_close_eol()
{
  asm_close(); endasm();
}

PROC asm_a()
{
  asmc('A');
}

PROC asm_hl()
{
  asm_rname(0x01);
}

PROC asm_mhl()
{
  asm_mrgname(0x01);
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
  asmstr( "\tSBC " );
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

PROC asm_ld()
{
  asmstr( "\tLD " );
}

PROC asm_jp()
{
  asmstr( "\tJP " );
}

PROC emitjrnz(CHAR c)
{
  asmstr("\tJR NZ,$+0x");
  asmc(c);
  endasm();
}

PROC asm_ex()
{
  asmstr( "\tEX " );
}

PROC asm_push()
{
  asmstr( "\tPUSH " );
}

PROC asm_pop()
{
  asmstr( "\tPOP " );
}

PROC asm_lda_comma()
{
  asm_ld(); asm_a(); asm_comma();
}

PROC asm_ldmhl_comma()
{
  asm_ld(); asm_mhl(); asm_comma();
}

PROC asm_comma_a_eol()
{
  asm_comma(); asm_a(); endasm();
}

PROC asm_comma_mhl_eol()
{
  asm_comma(); asm_mhl(); endasm();
}

PROC emitinchl()
{
  asm_inc(); asm_rname(0x01); endasm();
}

PROC emitexa()
{
  asm_ex(); asmstr("AF,AF\'"); endasm();
}

PROC emitexd()
{
  asm_ex(); asmstr("DE,HL"); endasm();
}

PROC emitccf()
{
  asmstr( "\tCCF" ); endasm();
}

PROC emitcall(PCHAR s)
{
  asmstr( "\tCALL " ); asmstr( s ); endasm();
}

///////////////////////////////////
//доступны из commands
PROC unproxy()
{
  IF (_rproxy != 0x00) { //в прокси что-то было
    asm_ld(); /**rganame*/asm_rlow(_rproxy); asm_comma_a_eol();
    _rproxy = 0x00;
  };
}

PROC proxy(BYTE r)
{
  IF (_rproxy != r) {
    unproxy();
    asm_lda_comma(); /**rganame*/asm_rlow(r); endasm();
    _rproxy = r;
  };
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
    //rdest не может быть FASTRG4? если сделать функцию getslowrg, то может :(
    IF ( ((rdest==0x04)&&(rsrc==0x01))
       ||((rdest==0x01)&&(rsrc==0x04))
       ) {
      asm_push(); asm_rname(rsrc); endasm();
      asm_pop(); asm_rname(rdest); endasm();
    }ELSE {
      asm_ld(); asm_rhigh(rdest); asm_comma(); asm_rhigh(rsrc); endasm();
      asm_ld(); asm_rlow(rdest); asm_comma(); asm_rlow(rsrc); endasm();
    };
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

PROC emitjpmainrg() //"jp (hl)"
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  unproxy();
  getnothing(); //getnothingword();
  asm_jp(); asm_mhl(); endasm();
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
    proxy(_rnew); //todo оптимизировать
    //IF (anew==_RGA) {
      asm_or(); asm_a(); endasm();
    //}ELSE {
    //  asm_inc(); /**rganame*/asm_rlow(anew); endasm();
    //  asm_dec(); /**rganame*/asm_rlow(anew); endasm();
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
  IF       (_jpflag == 0x02) {asmstr("NZ");
  }ELSE IF (_jpflag == 0x03) {asmstr("NC");
  }ELSE IF (_jpflag == 0x04) {asmc('C');
  }ELSE                      {asmc('Z');
  };
  asm_comma();
  asmstr(_joined);
  endasm();
  _fused = +FALSE;
  _jpflag = 0x00;
}

PROC emitret()
{
  //unproxy();
  asmstr( "\tRET" ); endasm();
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
  IF (high) {asmstr( ">>16"/**WORDBITS*/ );
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
  IF (_rproxy == 0x00) {
    _rproxy = _rnew;
    asm_lda_comma();
  }ELSE {
    asm_ld();
    /**rganame*/asm_rlow(_rnew);
    asm_comma();
  };
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
  IF (high) {asmc('+'); asmc('2');
  };
  asm_close();
  endasm();
}

PROC emitgetb() //аккумулятор уже занят через getfreea
{
  unproxy();
  _rproxy = _rnew;
  asm_lda_comma();
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
  IF (high) {asmc('+'); asmc('2'); //asmstr( "+2"/**WORDSIZE*/ );
  };
  asm_close(); asm_comma();
  asm_rname(_rnew);
  endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitputb()
{
  //_jpflag = 0x00;
  proxy(_rnew);
  asm_ld(); asm_open();
  asmstr(_joined);
  asm_close();
  asm_comma_a_eol();
  _rproxy = 0x00;
  _fused = +FALSE; //конец вычисления
}

PROC emitshl1rg()
{
  IF ((_rnew == 0x01)||(_rnew == 0x04)) {
    asm_add(); asm_hl(); asm_comma(); asm_hl(); endasm();
  }ELSE {
    asmstr( "\tSLA " ); asm_rlow(_rnew); endasm();
    asmstr( "\tRL " ); asm_rhigh(_rnew); endasm();
  };
}

PROC emitshl1b()
{
    proxy(_rnew);
  //IF (_rproxy==_rnew) {
    asm_add(); asm_a(); asm_comma_a_eol();
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
  proxy(_rnew);
  asmstr( "\tCPL" ); endasm();
  _fused = +FALSE; //иначе глюк if (!(a||b))
}

PROC emitinvrg()
{
  unproxy();
  asm_lda_comma(); asm_rhigh(_rnew); endasm();
  asmstr( "\tCPL" ); endasm();
  asm_ld(); asm_rhigh(_rnew); asm_comma_a_eol();
  emitinvb();
  unproxy(); //иначе глюк перед poke
  //asm_lda_comma(); asm_rlow(_rnew); endasm();
  //asmstr( "\tCPL" ); endasm();
  //asm_ld(); asm_rlow(_rnew); asm_comma_a_eol();
  //unreserverg( _RGA );
}

PROC emitnegrg()
{
  unproxy();
  asm_xor(); asm_a(); endasm();
  asm_sub(); asm_rlow(_rnew); endasm();
  asm_ld(); asm_rlow(_rnew); asm_comma_a_eol();
  asm_sbc(); asm_a(); asm_comma(); asm_rhigh(_rnew); endasm();
  asm_sub(); asm_rlow(_rnew); endasm();
  asm_ld(); asm_rhigh(_rnew); asm_comma_a_eol();
}

PROC emitztob()
{
  //asmstr(";emitztoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a == b)
    IF (_azused) { //A содержит правильный 0/не0 после сравнения
      //unproxy();
      asm_sub(); asmc('1'); endasm();
      asm_sbc(); asm_a(); asm_comma_a_eol();
      _rproxy = _rnew;
      _azused = +FALSE;
    }ELSE {
      asm_ld(); asm_rlow(_rnew); asm_comma(); asmc('0'); endasm();
      IF (_rnew != 0x04) {emitjrnz('3');
      }ELSE emitjrnz('4'); //ix
      asm_dec(); asm_rlow(_rnew); endasm();
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
  //asmstr(";emitinvztoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a != b)
    IF (_azused) { //A содержит правильный 0/не0 после сравнения
      //unproxy();
      asmstr("\tJR Z,$+4"); endasm();
      asm_lda_comma(); asmstr("-1"); endasm();
      _rproxy = _rnew;
      _azused = +FALSE;
    }ELSE {
      asm_ld(); asm_rlow(_rnew); asm_comma(); asmc('0'); endasm();
      IF (_rnew != 0x04) {asmstr( "\tJR Z,$+3" );
      }ELSE asmstr( "\tJR Z,$+4" ); //ix
      endasm();
      asm_dec(); asm_rlow(_rnew); endasm();
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
  //asmstr(";emitcytoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a < b)
    unproxy();
    asm_sbc(); asm_a(); asm_comma_a_eol();
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
  //asmstr(";emitinvcytoa exprlvl="); asmuint(_exprlvl); endasm();
  IF (_exprlvl != 0x01) { //if (a >= b)
    emitccf();
    unproxy();
    asm_sbc(); asm_a(); asm_comma_a_eol();
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
  asmstr( "\tRLA" ); endasm(); //sign
  asm_jp(); asmstr( "PO,$+4" ); endasm();
  emitccf();
  emitcytob();
}

PROC emitinvSxorVtob() //после subflags, разрезервирует A
{
  asmstr( "\tRLA" ); endasm(); //sign
  asm_jp(); asmstr( "PE,$+4" ); endasm();
  emitccf();
  emitcytob();
}

PROC emitxorrg() //old^new => old
{
  unproxy();
  asm_lda_comma(); asm_rhigh(_rnew); endasm();
  asm_xor(); asm_rhigh(_rold); endasm();
  asm_ld(); asm_rhigh(_rold); asm_comma_a_eol();
  asm_lda_comma(); asm_rlow(_rnew); endasm();
  asm_xor(); asm_rlow(_rold); endasm();
  asm_ld(); asm_rlow(_rold); asm_comma_a_eol();
}

PROC getxorb() //RGA^RGA2 -> RGA
{
  IF (_rproxy == _rnew) {
    asm_xor();
    /**rganame*/asm_rlow(_rold);
    _rproxy = _rold;
  }ELSE {
    proxy(_rold);
    asm_xor();
    /**rganame*/asm_rlow(_rnew);
  };
   endasm();
  _fused = +TRUE; //^^
}

PROC emitorrg() //old|new => old
{
  unproxy();
  asm_lda_comma(); asm_rhigh(_rnew); endasm();
  asm_or(); asm_rhigh(_rold); endasm();
  asm_ld(); asm_rhigh(_rold); asm_comma_a_eol();
  asm_lda_comma(); asm_rlow(_rnew); endasm();
  asm_or(); asm_rlow(_rold); endasm();
  asm_ld(); asm_rlow(_rold); asm_comma_a_eol();
}

PROC getorb() //RGA|RGA2 -> RGA
{
  IF (_rproxy == _rnew) {
    asm_or();
    /**rganame*/asm_rlow(_rold);
    _rproxy = _rold;
  }ELSE {
    proxy(_rold);
    asm_or();
    /**rganame*/asm_rlow(_rnew);
  };
  endasm();
  _fused = +TRUE; //||
}

PROC emitandrg() //old&new => old
{
  unproxy();
  asm_lda_comma(); asm_rhigh(_rnew); endasm();
  asm_and(); asm_rhigh(_rold); endasm();
  asm_ld(); asm_rhigh(_rold); asm_comma_a_eol();
  asm_lda_comma(); asm_rlow(_rnew); endasm();
  asm_and(); asm_rlow(_rold); endasm();
  asm_ld(); asm_rlow(_rold); asm_comma_a_eol();
}

PROC getandb() //RGA&RGA2 -> RGA
{
  IF (_rproxy == _rnew) {
    asm_and();
    /**rganame*/asm_rlow(_rold);
    _rproxy = _rold;
  }ELSE {
    proxy(_rold);
    asm_and();
    /**rganame*/asm_rlow(_rnew);
  };
  endasm();
  _fused = +TRUE; //&&
}

PROC emitaddrg() //old+new => old
{ //add ix ни разу не потребовался
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    asm_add(); asm_hl(); asm_comma(); asm_rname(_rnew); endasm();
  }ELSE IF ((_rold==0x02)&&(_rnew!=0x04)) {
    emitexd(); //todo через swaprgs?
    asm_add(); asm_hl(); asm_comma();
    IF (_rnew==0x01) {asm_rname(0x02); //de+hl
    }ELSE asm_rname(_rnew);
    endasm();
    emitexd(); //todo через swaprgs?
  }ELSE {
    unproxy();
    asm_lda_comma(); asm_rlow(_rold); endasm();
    asm_add(); asm_a(); asm_comma(); asm_rlow(_rnew); endasm();
    asm_ld(); asm_rlow(_rold); asm_comma_a_eol();
    asm_lda_comma(); asm_rhigh(_rold); endasm();
    asm_adc(); asm_a(); asm_comma(); asm_rhigh(_rnew); endasm();
    asm_ld(); asm_rhigh(_rold); asm_comma_a_eol();
  };
}

PROC emitadcrg() //old+new => old
{
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    asm_adc(); asm_hl(); asm_comma(); asm_rname(_rnew); endasm();
  }ELSE IF ((_rold==0x02)&&(_rnew!=0x04)) {
    emitexd(); //todo через swaprgs?
    asm_adc(); asm_hl(); asm_comma();
    IF (_rnew==0x01) {asm_rname(0x02); //de+hl
    }ELSE asm_rname(_rnew);
    endasm();
    emitexd(); //todo через swaprgs?
  }ELSE {
    unproxy();
    asm_lda_comma(); asm_rlow(_rold); endasm();
    asm_adc(); asm_a(); asm_comma(); asm_rlow(_rnew); endasm();
    asm_ld(); asm_rlow(_rold); asm_comma_a_eol();
    asm_lda_comma(); asm_rhigh(_rold); endasm();
    asm_adc(); asm_a(); asm_comma(); asm_rhigh(_rnew); endasm();
    asm_ld(); asm_rhigh(_rold); asm_comma_a_eol();
  };
}

PROC emitaddb() //old+new
{
  IF (_rproxy == _rnew) {
    asm_add(); asm_a(); asm_comma(); /**rganame*/asm_rlow(_rold); endasm();
    _rproxy = _rold;
  }ELSE {
    proxy(_rold);
    asm_add(); asm_a(); asm_comma(); /**rganame*/asm_rlow(_rnew); endasm();
  };
}

PROC emitaddbconst() //new8+<const>
{
  proxy(_rnew);
  asm_add(); asm_a(); asm_comma(); asmstr(_const); endasm();
}

PROC emitsubrg() //old-new => old
{
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    asm_or(); asm_a(); endasm();
    asm_sbc(); asm_hl(); asm_comma(); asm_rname(_rnew); endasm();
/**  }ELSE IF ((_rold==0x02)&&(_rnew!=0x04)) {
    asmstr("\tOR A"); endasm();
    emitexd(); //todo через swaprgs?
    asmstr("\tSBC HL,"); asm_rname(rnew); endasm();
    emitexd(); //todo через swaprgs?
    //невыгодно 27 тактов (если через перенумерацию регистров, то будет 23)
*/
  }ELSE {
    unproxy();
    asm_lda_comma(); asm_rlow(_rold); endasm();
    asm_sub(); asm_rlow(_rnew); endasm();
    asm_ld(); asm_rlow(_rold); asm_comma_a_eol();
    asm_lda_comma(); asm_rhigh(_rold); endasm();
    asm_sbc(); asm_a(); asm_comma(); asm_rhigh(_rnew); endasm();
    asm_ld(); asm_rhigh(_rold); asm_comma_a_eol();
  };
}

PROC emitsbcrg() //old-new => old
{
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    asm_sbc(); asm_hl(); asm_comma(); asm_rname(_rnew); endasm();
  }ELSE IF ((_rold==0x02)&&(_rnew!=0x04)) {
    emitexd(); //todo через swaprgs?
    asm_sbc(); asm_hl(); asm_comma();
    IF (_rnew==0x01) {asm_rname(0x02); //de-hl
    }ELSE asm_rname(_rnew);
    endasm();
    emitexd(); //todo через swaprgs?
  }ELSE {
    unproxy();
    asm_lda_comma(); asm_rlow(_rold); endasm();
    asm_sbc(); asm_a(); asm_comma(); asm_rlow(_rnew); endasm();
    asm_ld(); asm_rlow(_rold); asm_comma_a_eol();
    asm_lda_comma(); asm_rhigh(_rold); endasm();
    asm_sbc(); asm_a(); asm_comma(); asm_rhigh(_rnew); endasm();
    asm_ld(); asm_rhigh(_rold); asm_comma_a_eol();
  };
}

PROC emitsubb() //old-new
{
  proxy(_rold);
  asm_sub(); asm_rlow(_rnew); endasm();
}

PROC emitsubbconst() //new8-<const>
{
  proxy(_rnew);
  asm_sub(); asmstr(_const); endasm();
}

PROC emitsubflags(BYTE rnew, BYTE rold) //r2-r1 => CY,sign,overflow
{
  unproxy();
  asm_lda_comma(); asm_rlow(rold); endasm();
  asm_sub(); asm_rlow(rnew); endasm();
  asm_lda_comma(); asm_rhigh(rold); endasm();
  asm_sbc(); asm_a(); asm_comma(); asm_rhigh(rnew); endasm();
  _fused = +TRUE;
}

PROC emitsubbflags(BYTE anew, BYTE aold) //a2-a1 => CY
{ //sign,overflow не нужен!
  proxy(aold);
  asm_sub(); /**rganame*/asm_rlow(anew); endasm();
  _rproxy = 0x00;
  _fused = +TRUE;
}

PROC emitsubz() //old-new => Z
{
  IF (_rold == 0x01) {
    emitsubrg();
  }ELSE {
    unproxy();
    asm_lda_comma(); asm_rlow(_rold); endasm();
    asm_sub(); asm_rlow(_rnew); endasm();
    IF ((_rold!=0x04)&&(_rnew!=0x04)) {emitjrnz('4');
    }ELSE emitjrnz('5'); //ix
    asm_lda_comma(); asm_rhigh(_rold); endasm();
    asm_sub(); asm_rhigh(_rnew); endasm();
    _azused = +TRUE; //A содержит правильный 0/не0 после сравнения
  };
  _fused = +TRUE;
}

PROC emitsubbz() //old-new => Z
{
  IF (_rproxy == _rnew) {
    asm_sub();
    /**rganame*/asm_rlow(_rold);
  }ELSE {
    proxy(_rold);
    asm_sub();
    /**rganame*/asm_rlow(_rnew);
  };
  endasm();
  _rproxy = 0x00;
  _azused = +TRUE; //A содержит правильный 0/не0 после сравнения
  _fused = +TRUE;
}

PROC emitsubbzconst() //new-<const> => Z
{
  proxy(_rnew);
  asm_sub(); asmstr(_const); endasm();
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
  asm_lda_comma(); asm_rlow(_rold2); endasm();
  asm_sub(); asm_rlow(_rnew); endasm();
  IF ((_rold3!=0x04)&&(_rold!=0x04)) {emitjrnz('d'); //5+4+4//ix в rold2 или rnew
  }ELSE emitjrnz('e'); //4+5+5//ix в rold3 или rold
  asm_lda_comma(); asm_rhigh(_rold2); endasm();
  asm_sub(); asm_rhigh(_rnew); endasm();
  IF ((_rold3!=0x04)&&(_rold!=0x04)) {emitjrnz('8');
  }ELSE emitjrnz('a'); //ix
  asm_lda_comma(); asm_rlow(_rold3); endasm();
  asm_sub(); asm_rlow(_rold); endasm();
  IF ((_rold3!=0x04)&&(_rold!=0x04)) {emitjrnz('4');
  }ELSE emitjrnz('5'); //ix
  asm_lda_comma(); asm_rhigh(_rold3); endasm();
  asm_sub(); asm_rhigh(_rold); endasm();
  _fused = +TRUE;
}

PROC emitpokerg() //новое записываем в старую локацию памяти
{
  IF ((_rold == 0x01)&&(_rnew!=0x04)) {
    asm_ldmhl_comma(); asm_rlow(_rnew); endasm();
    emitinchl();
    asm_ldmhl_comma(); asm_rhigh(_rnew); endasm();
  }ELSE {
    unproxy();
    asm_lda_comma(); asm_rlow(_rnew); endasm();
    asm_ld(); asm_mrgname(_rold); asm_comma_a_eol();
    asm_inc(); asm_rname(_rold); endasm();
    asm_lda_comma(); asm_rhigh(_rnew); endasm();
    asm_ld(); asm_mrgname(_rold); asm_comma_a_eol();
  };
  _fused = +FALSE; //конец вычисления
}

PROC emitpokeb() //новое записываем в старую локацию памяти
//в rnew может не быть данных, если rproxy==rnew!!!
{
  IF ((_rold==0x01) && (_rnew!=0x04) && (_rproxy!=_rnew)) {
    asm_ld(); asm_mhl(); asm_comma(); asm_rlow(_rnew); endasm();
  }ELSE {
    proxy(_rnew); //иначе нет команды ld [rp],rg
    asm_ld(); asm_mrgname(_rold); asm_comma_a_eol();
  };
  _rproxy = 0x00;
  _fused = +FALSE; //конец вычисления
}

PROC emitpokelong() //old2(addr), old(high), new(low)
{
  IF ((_rold2==0x01)&&(_rnew!=0x04)) {
    asm_ldmhl_comma(); asm_rlow(_rnew); endasm();
    emitinchl();
    asm_ldmhl_comma(); asm_rhigh(_rnew); endasm();
    emitinchl();
    asm_ldmhl_comma(); asm_rlow(_rold); endasm();
    emitinchl();
    asm_ldmhl_comma(); asm_rhigh(_rold); endasm();
  }ELSE {
    unproxy();
    asm_lda_comma(); asm_rlow(_rnew); endasm();
    asm_ld(); asm_mrgname(_rold2); asm_comma_a_eol();
    asm_inc(); asm_rname(_rold2); endasm();
    asm_lda_comma(); asm_rhigh(_rnew); endasm();
    asm_ld(); asm_mrgname(_rold2); asm_comma_a_eol();
    asm_inc(); asm_rname(_rold2); endasm();
    asm_lda_comma(); asm_rlow(_rold); endasm();
    asm_ld(); asm_mrgname(_rold2); asm_comma_a_eol();
    asm_inc(); asm_rname(_rold2); endasm();
    asm_lda_comma(); asm_rhigh(_rold); endasm();
    asm_ld(); asm_mrgname(_rold2); asm_comma_a_eol();
  };
  _fused = +FALSE; //конец вычисления
}

PROC asm_lda_mrgname_eol(BYTE r)
{
  asm_lda_comma(); asm_mrgname(r); endasm();
}

PROC emitpeekrg() //[new] => new
{
  unproxy();
  IF (_rnew==0x01) {
    asm_lda_comma(); asm_mhl(); endasm();
    emitinchl();
    asm_ld(); asmc('H'); asm_comma_mhl_eol();
    asm_ld(); asmc('L'); asm_comma_a_eol();
  }ELSE {
    asm_lda_mrgname_eol(_rnew);
    asm_inc(); asm_rname(_rnew); endasm();
    emitexa();
    asm_lda_mrgname_eol(_rnew);
    asm_ld(); asm_rhigh(_rnew); asm_comma_a_eol();
    emitexa();
    asm_ld(); asm_rlow(_rnew); asm_comma_a_eol();
  };
}

PROC emitpeekb()
{
//  IF (_rnew == 0x01) {
//    asm_ld(); asmc('L'); asm_comma_mhl_eol(); //невыгодно
//  }ELSE {
    unproxy();
    _rproxy = _rnew;
    asm_lda_mrgname_eol(_rnew);
//  };
}

PROC emitpeeklong() //[old] => old(high),new(low)
{
  unproxy();
  IF ((_rold==0x01)&&(_rnew!=0x04)) {
    asm_ld(); asm_rlow(_rnew); asm_comma_mhl_eol();
    emitinchl();
    asm_ld(); asm_rhigh(_rnew); asm_comma_mhl_eol();
    emitinchl();
    asm_lda_comma(); asm_mhl(); endasm();
    emitinchl();
    asm_ld(); asmc('H'); asm_comma_mhl_eol();
    asm_ld(); asmc('L'); asm_comma_a_eol();
  }ELSE {
    asm_lda_mrgname_eol(_rold);
    asm_inc(); asm_rname(_rold); endasm();
    asm_ld(); asm_rlow(_rnew); asm_comma_a_eol();
    asm_lda_mrgname_eol(_rold);
    asm_inc(); asm_rname(_rold); endasm();
    asm_ld(); asm_rhigh(_rnew); asm_comma_a_eol();
    asm_lda_mrgname_eol(_rold);
    asm_inc(); asm_rname(_rold); endasm();
    emitexa();
    asm_lda_mrgname_eol(_rold);
    asm_ld(); asm_rhigh(_rold); asm_comma_a_eol();
    emitexa();
    asm_ld(); asm_rlow(_rold); asm_comma_a_eol();
  };
}

PROC emitrgtob() //нельзя убирать - специфично
{
}

PROC emitbtorg()
{
  unproxy();
  asm_ld(); asm_rhigh(_rnew); asm_comma(); asmc('0'); endasm();
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
  IF ((_rnew==0x01)||(_rnew==0x04)) { //hl/ix
    asm_inc(); asm_open(); asm_rname(_rnew); asm_close(); endasm();
  }ELSE IF (_rnew==0x02) { //de
    emitexd(); //todo через swaprgs?
    asm_inc(); asm_mhl(); endasm();
    emitexd(); //todo через swaprgs?
  }ELSE /**IF (_rnew==0x03)*/ { //bc
    unproxy();
    asm_lda_mrgname_eol(_rnew);
    asm_inc(); asm_a(); endasm();
    asm_ld(); asm_open(); asm_rname(_rnew); asm_close(); asm_comma_a_eol();
  };
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
  IF ((_rnew==0x01)||(_rnew==0x04)) { //hl/ix
    asm_dec(); asm_open(); asm_rname(_rnew); asm_close(); endasm();
  }ELSE IF (_rnew==0x02) { //de
    emitexd(); //todo через swaprgs?
    asm_dec(); asm_mhl(); endasm();
    emitexd(); //todo через swaprgs?
  }ELSE /**IF (_rnew==0x03)*/ { //bc
    unproxy();
    asm_lda_mrgname_eol(_rnew);
    asm_dec(); asm_a(); endasm();
    asm_ld(); asm_open(); asm_rname(_rnew); asm_close(); asm_comma_a_eol();
  };
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
  IF (_rold==0x01) {
    asm_ld(); asm_rlow(_rnew); asm_comma_mhl_eol();
    emitinchl();
    asm_ld(); asm_rhigh(_rnew); asm_comma_mhl_eol();

    asm_inc(); asm_rname(_rnew); endasm();

    asm_ld(); asm_mhl(); asm_comma(); asm_rhigh(_rnew); endasm();
    asm_dec(); asm_hl(); endasm();
    asm_ld(); asm_mhl(); asm_comma(); asm_rlow(_rnew); endasm();
  }ELSE {
    unproxy();
    asm_lda_mrgname_eol(_rold);
    asm_ld(); asm_rlow(_rnew); asm_comma_a_eol();
    asm_inc(); asm_rname(_rold); endasm();
    asm_lda_mrgname_eol(_rold);
    asm_ld(); asm_rhigh(_rnew); asm_comma_a_eol();

    asm_inc(); asm_rname(_rnew); endasm();

    asm_lda_comma(); asm_rhigh(_rnew); endasm();
    asm_ld(); asm_mrgname(_rold); asm_comma_a_eol();
    asm_dec(); asm_rname(_rold); endasm();
    asm_lda_comma(); asm_rlow(_rnew); endasm();
    asm_ld(); asm_mrgname(_rold); asm_comma_a_eol();
  };
  _fused = +FALSE; //конец вычисления
}

PROC emitdecrg_bypoi() //[old], new free
{
  IF (_rold==0x01) {
    asm_ld(); asm_rlow(_rnew); asm_comma_mhl_eol();
    emitinchl();
    asm_ld(); asm_rhigh(_rnew); asm_comma_mhl_eol();

    asm_dec(); asm_rname(_rnew); endasm();

    asm_ld(); asm_mhl(); asm_comma(); asm_rhigh(_rnew); endasm();
    asm_dec(); asm_hl(); endasm();
    asm_ld(); asm_mhl(); asm_comma(); asm_rlow(_rnew); endasm();
  }ELSE {
    unproxy();
    asm_lda_mrgname_eol(_rold);
    asm_ld(); asm_rlow(_rnew); asm_comma_a_eol();
    asm_inc(); asm_rname(_rold); endasm();
    asm_lda_mrgname_eol(_rold);
    asm_ld(); asm_rhigh(_rnew); asm_comma_a_eol();

    asm_dec(); asm_rname(_rnew); endasm();

    asm_lda_comma(); asm_rhigh(_rnew); endasm();
    asm_ld(); asm_mrgname(_rold); asm_comma_a_eol();
    asm_dec(); asm_rname(_rold); endasm();
    asm_lda_comma(); asm_rlow(_rnew); endasm();
    asm_ld(); asm_mrgname(_rold); asm_comma_a_eol();
  };
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
