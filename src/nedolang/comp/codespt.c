//// imported
#include "../_sdk/emit.h"

//для script надо в ассемблере по команде DW писать uint64_t в файл, но указатель инкрементировать только на 1

//#include "sizesz80.h"

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

EXPORT PROC var_db() //доступно из compile для строк!
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

PROC asm_add_eol()
{
  asmstr( "\tDW CMD_ADD" ); endasm();
}

PROC asm_sub_eol()
{
  asmstr( "\tDW CMD_SUB" ); endasm();
}

PROC asm_mul_eol()
{
  asmstr( "\tDW CMD_MUL" ); endasm();
}

PROC asm_div_eol()
{
  asmstr( "\tDW CMD_DIV" ); endasm();
}

PROC asm_addfloat_eol()
{
  asmstr( "\tDW CMD_ADDFLOAT" ); endasm();
}

PROC asm_subfloat_eol()
{
  asmstr( "\tDW CMD_SUBFLOAT" ); endasm();
}

PROC asm_mulfloat_eol()
{
  asmstr( "\tDW CMD_MULFLOAT" ); endasm();
}

PROC asm_divfloat_eol()
{
  asmstr( "\tDW CMD_DIVFLOAT" ); endasm();
}

PROC asm_divsigned_eol()
{
  asmstr( "\tDW CMD_DIVSIGNED" ); endasm();
}

PROC asm_negfloat_eol()
{
  asmstr( "\tDW CMD_NEGFLOAT" ); endasm();
}

PROC asm_if0goto()
{
  asmstr( "\tDW CMD_IF0GOTO," );
}

PROC asm_goto()
{
  asmstr( "\tDW CMD_GOTO," );
}

PROC asm_dup_eol()
{
  asmstr( "\tDW CMD_DUP" ); endasm();
}

PROC asm_drop_eol()
{
  asmstr( "\tDW CMD_DROP" ); endasm();
}

PROC asm_swap_eol()
{
  asmstr( "\tDW CMD_SWAP" ); endasm();
}

PROC asm_readvar_eol()
{
  asmstr( "\tDW CMD_READVAR" ); endasm();
}

PROC asm_writevar_eol()
{
  asmstr( "\tDW CMD_WRITEVAR" ); endasm();
}

PROC asm_const()
{
  asmstr( "\tDW CMD_CONST," );
}

PROC asm_ret_eol()
{
  asmstr( "\tDW CMD_RET" ); endasm();
}

PROC asm_call()
{
  asmstr( "\tDW CMD_CALL," );
}

PROC asm_and_eol()
{
  asmstr( "\tDW CMD_AND" ); endasm();
}

PROC asm_or_eol()
{
  asmstr( "\tDW CMD_OR" ); endasm();
}

PROC asm_xor_eol()
{
  asmstr( "\tDW CMD_XOR" ); endasm();
}

PROC asm_eq_eol()
{
  asmstr( "\tDW CMD_EQ" ); endasm();
}

PROC asm_moreeq_eol()
{
  asmstr( "\tDW CMD_MOREEQ" ); endasm();
}

PROC asm_moreeqsigned_eol()
{
  asmstr( "\tDW CMD_MOREEQSIGNED" ); endasm();
}

PROC asm_eqfloat_eol()
{
  asmstr( "\tDW CMD_EQFLOAT" ); endasm();
}

PROC asm_moreeqfloat_eol()
{
  asmstr( "\tDW CMD_MOREEQFLOAT" ); endasm();
}

PROC asm_inv_eol()
{
  asmstr( "\tDW CMD_INV" ); endasm();
}

PROC asm_rst()
{
  asmstr( "\tDW CMD_RST," );
}

PROC asm_shr_eol()
{
  asmstr( "\tDW CMD_SHR" ); endasm();
}

PROC asm_shrsigned_eol()
{
  asmstr( "\tDW CMD_SHRSIGNED" ); endasm();
}

PROC asm_shl_eol()
{
  asmstr( "\tDW CMD_SHL" ); endasm();
}

PROC asm_mod_eol()
{
  asmstr( "\tDW CMD_MOD" ); endasm();
}

PROC asm_done_eol()
{
  asmstr( "\tDW CMD_DONE" ); endasm();
}

PROC asm_1_eol()
{
  asmstr( "\tDW CMD_CONST,1" ); endasm();
}

PROC asm_floattoint_eol()
{
  asmstr( "\tDW CMD_FLOATTOINT" ); endasm();
}

PROC asm_inttofloat_eol()
{
  asmstr( "\tDW CMD_INTTOFLOAT" ); endasm();
}

PROC emitinc()
{
  asm_1_eol();
  asm_add_eol();
}

PROC emitdec()
{
  asm_1_eol();
  asm_sub_eol();
}

PROC emitcall(PCHAR s)
{
  asm_call(); asmstr( s ); endasm();
}

///////////////////////////////////
//доступны из commands
PROC unproxy()
{
}

PROC proxy(BYTE r)
{
}

///////////////////////////////////////////////////////////
//процедуры с машинным кодом для rgs

PROC emitpushrg(BYTE rnew)
{
  //unproxy(); //todo оптимизировать
  //asm_push(); asm_rname(rnew); endasm();
  //INC _funcstkdepth;
}

PROC emitpoprg(BYTE rnew) //регистр уже помечен в getrfree/getrg
{
  //asm_pop(); asm_rname(rnew); endasm();
  //DEC _funcstkdepth;
}

PROC emitmovrg(BYTE rsrc, BYTE rdest) //не заказывает и не освобождает (см. emitmoverg)
{
   //asm_push(); asm_rname(rsrc); endasm();
   //asm_pop(); asm_rname(rdest); endasm();
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
  asmstr("unsupported: emitjpmainrg()"); endasm();
}

PROC emitcallmainrg() //"call (hl)"
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  unproxy();
  getnothing(); //getnothingword();
  asmstr("unsupported: emitcallmainrg()"); endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitjp()
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  unproxy();
  getnothing(); //getnothingword();
  asm_goto(); asmstr(_joined); endasm();
}

PROC emitbtoz() //перед jp!
{
  //сразу после сравнения не надо, но вдруг мы читаем BOOL
}

PROC emitless()
{
  asm_moreeq_eol();
  asm_inv_eol();
  _jpflag = 0x00;
}

PROC emitlesssigned()
{
  asm_moreeqsigned_eol();
  asm_inv_eol();
  _jpflag = 0x00;
}

PROC emitlessb()
{
  emitless();
}

PROC emitlessfloat()
{
  asm_moreeqfloat_eol();
  asm_inv_eol();
  _jpflag = 0x00;
}

PROC emitlesseq()
{
  asm_swap_eol();
  asm_moreeq_eol();
  _jpflag = 0x00;
}

PROC emitlesseqsigned()
{
  asm_swap_eol();
  asm_moreeqsigned_eol();
  _jpflag = 0x00;
}

PROC emitlesseqb()
{
  emitlesseq();
}

PROC emitlesseqfloat()
{
  asm_swap_eol();
  asm_moreeqfloat_eol();
  _jpflag = 0x00;
}

PROC emitmore()
{
  asm_swap_eol();
  asm_moreeq_eol();
  asm_inv_eol();
  _jpflag = 0x00;
}

PROC emitmoresigned()
{
  asm_swap_eol();
  asm_moreeqsigned_eol();
  asm_inv_eol();
  _jpflag = 0x00;
}

PROC emitmoreb()
{
  emitmore();
}

PROC emitmorefloat()
{
  asm_swap_eol();
  asm_moreeqfloat_eol();
  asm_inv_eol();
  _jpflag = 0x00;
}

PROC emitmoreeq()
{
  asm_moreeq_eol();
  _jpflag = 0x00;
}

PROC emitmoreeqsigned()
{
  asm_moreeqsigned_eol();
  _jpflag = 0x00;
}

PROC emitmoreeqb()
{
  emitmoreeq();
}

PROC emitmoreeqfloat()
{
  asm_moreeqfloat_eol();
  _jpflag = 0x00;
}

PROC emiteqfloat()
{
  asm_eqfloat_eol();
  _jpflag = 0x00;
}

PROC emitneqfloat()
{
  asm_eqfloat_eol();
  asm_inv_eol();
  _jpflag = 0x00;
}

PROC emitjpiffalse()
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  //unproxy();
  getnothing(); //getnothingword();
  IF       (_jpflag == 0x02) {asm_eq_eol(); //asmstr("NZ");
  }ELSE IF (_jpflag == 0x03) {asm_moreeq_eol(); asm_inv_eol(); //asmstr("NC");
  }ELSE IF (_jpflag == 0x04) {asm_moreeq_eol(); //asmc('C');
  }ELSE IF (_jpflag == 0x01) {asm_eq_eol(); asm_inv_eol(); //asmc('Z');
  };
  asm_if0goto();
  asmstr(_joined);
  endasm();
  _fused = +FALSE;
  _jpflag = 0x00;
}

PROC emitret()
{
  //unproxy();
  asm_ret_eol();
}

PROC emitaddfloat()
{
  asm_addfloat_eol();
}
PROC emitsubfloat()
{
  asm_subfloat_eol();
}

PROC emitmulbyte()
{
  asm_mul_eol();
}
PROC emitmuluint()
{
  asm_mul_eol();
}
PROC emitmullong()
{
  asm_mul_eol();
}
PROC emitmulfloat()
{
  asm_mulfloat_eol();
}

PROC emitdivbyte()
{
  asm_div_eol();
}
PROC emitdivint()
{
  asm_divsigned_eol();
}
PROC emitdivuint()
{
  asm_div_eol();
}
PROC emitdivlong()
{
  asm_div_eol();
}
PROC emitdivfloat()
{
  asm_divfloat_eol();
}

PROC emitnegfloat()
{
  asm_negfloat_eol();
}

PROC emitshlbyte()
{
  asm_shl_eol();
}
PROC emitshluint()
{
  asm_shl_eol();
}
PROC emitshllong()
{
  asm_shl_eol();
}

PROC emitshrbyte()
{
  asm_shr_eol();
}
PROC emitshrint()
{
  asm_shrsigned_eol();
}
PROC emitshruint()
{
  asm_shr_eol();
}
PROC emitshrlong()
{
  asm_shr_eol();
}

PROC emitcallproc()
{
  _jpflag = 0x00;
  emitcall(_callee);
}

PROC emitloadrg(BOOL high) //регистр уже занят через getrfree
{
  asm_const();
  asmstr(_const);
  //IF (high) {asmstr( ">>32"/**WORDBITS*/ );
  //}ELSE {asmstr( "&0xffffffff"/**WORDMASK*/ );
  //};
  endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitloadrg0() //регистр уже занят через getrfree
{
  asm_const(); asmc('0'); endasm();
}

PROC emitloadb() //аккумулятор уже занят через getfreea
{
  asm_const(); asmstr(_const); endasm();
  _fused = +FALSE; //конец вычисления
}

PROC emitgetrg(BOOL high) //регистр уже занят через getrfree
{
  asm_const(); asmstr(_joined);
  //IF (high) {asmc('+'); asmc('1');
  //};
  endasm();
  asm_readvar_eol();
}

PROC emitgetb() //аккумулятор уже занят через getfreea
{
  asm_const(); asmstr(_joined); endasm();
  asm_readvar_eol();
}

PROC emitputrg(BOOL high) //ld [],new
{
  //_jpflag = 0x00;
  asm_const(); asmstr(_joined);
  //IF (high) {asmc('+'); asmc('1');
  //};
  endasm();
  asm_swap_eol();
  asm_writevar_eol();
  _fused = +FALSE; //конец вычисления
}

PROC emitputb()
{
  //_jpflag = 0x00;
  asm_const(); asmstr(_joined); endasm();
  asm_swap_eol();
  asm_writevar_eol();
  _fused = +FALSE; //конец вычисления
}

PROC emitshl1rg()
{
  asm_1_eol();
  asm_shl_eol();
}

PROC emitshl1b()
{
  asm_1_eol();
  asm_shl_eol();
}

PROC emitinvb() //~A -> A
{
  asm_inv_eol();
}

PROC emitinvrg()
{
  asm_inv_eol();
}

PROC emitnegrg()
{
  asm_inv_eol();
  emitinc();
}

PROC emitztob()
{
  IF (_exprlvl != 0x01) { //if (a == b)
    asm_eq_eol();
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
    asm_eq_eol();
    asm_inv_eol();
    _fused = +FALSE; //иначе глюк при if ((a!=b))? todo test //возможен глюк ifnot ((a!=b))
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x01;
  };
}
/*
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
*/
/**
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
*/
/**
PROC emitSxorVtob() //после subflags, разрезервирует A
{
  asmstr( "\tRLA" ); endasm(); //sign
  asm_jp(); asmstr( "PO,$+4" ); endasm();
  emitccf();
  emitcytob();
}
*/
/**
PROC emitinvSxorVtob() //после subflags, разрезервирует A
{
  asmstr( "\tRLA" ); endasm(); //sign
  asm_jp(); asmstr( "PE,$+4" ); endasm();
  emitccf();
  emitcytob();
}
*/
PROC emitxorrg() //old^new => old
{
  asm_xor_eol();
}

PROC getxorb() //RGA^RGA2 -> RGA
{
  asm_xor_eol();
  _fused = +TRUE; //^^
}

PROC emitorrg() //old|new => old
{
  asm_or_eol();
}

PROC getorb() //RGA|RGA2 -> RGA
{
  asm_or_eol();
  _fused = +TRUE; //||
}

PROC emitandrg() //old&new => old
{
  asm_and_eol();
}

PROC getandb() //RGA&RGA2 -> RGA
{
  asm_and_eol();
  _fused = +TRUE; //&&
}

PROC emitaddrg() //old+new => old
{
  asm_add_eol();
}

PROC emitadcrg() //old+new => old
{
  //asm_add_eol();
  asmstr("unsupported: emitadcrg()"); endasm();
}

PROC emitaddb() //old+new
{
  asm_add_eol();
}

PROC emitaddbconst() //new8+<const>
{
  emitloadb();
  asm_add_eol();
}

PROC emitsubrg() //old-new => old
{
  asm_sub_eol();
}

PROC emitsbcrg() //old-new => old
{
  //asm_sub_eol();
  asmstr("unsupported: emitsbcrg()"); endasm();
}

PROC emitsubb() //old-new
{
  asm_sub_eol();
}

PROC emitsubbconst() //new8-<const>
{
  emitloadb();
  asm_sub_eol();
}

PROC emitsubflags(BYTE rnew, BYTE rold) //r2-r1 => CY,sign,overflow
{
  asm_sub_eol();
//TODO!!!

  _fused = +TRUE;
}

PROC emitsubbflags(BYTE anew, BYTE aold) //a2-a1 => CY
{ //sign,overflow не нужен!
  asm_sub_eol();
//TODO!!!

  _fused = +TRUE;
}

PROC emitsubz() //old-new => Z
{
  //_fused = +TRUE;
}

PROC emitsubbz() //old-new => Z
{
  //_fused = +TRUE;
}

PROC emitsubbzconst() //new-<const> => Z
{
  emitloadb();
  emitsubbz();
}

PROC emitsublongz() //old2-new, old3-old => Z
{
//TODO!!!
  asm_drop_eol();
  asm_drop_eol();
  asm_drop_eol();

  _fused = +TRUE;
}

PROC emitpokerg() //новое записываем в старую локацию памяти
{
  asm_writevar_eol();
  _fused = +FALSE; //конец вычисления
}

PROC emitpokeb() //новое записываем в старую локацию памяти
{
  asm_writevar_eol();
  _fused = +FALSE; //конец вычисления
}

PROC emitpokelong() //old2(addr), old(high), new(low)
{
//TODO!!!
  asm_drop_eol();
  asm_writevar_eol();

  _fused = +FALSE; //конец вычисления
}
/**
PROC asm_lda_mrgname_eol(BYTE r)
{
  asm_lda_comma(); asm_mrgname(r); endasm();
}
*/
PROC emitpeekrg() //[new] => new
{
  asm_readvar_eol();
}

PROC emitpeekb()
{
  asm_readvar_eol();
}

PROC emitpeeklong() //[old] => old(high),new(low)
{
//TODO!!!
  asm_readvar_eol();
  asm_dup_eol();

}

PROC emitrgtob() //нельзя убирать - специфично
{
}

PROC emitbtorg()
{
}

PROC emitinttofloat()
{
  asm_inttofloat_eol();
}

PROC emitfloattoint()
{
  asm_floattoint_eol();
}

PROC emitincrg_byname()
{
  asm_const(); asmstr(_joined); endasm();
  asm_dup_eol();
  asm_readvar_eol();
  emitinc();
  asm_writevar_eol();
  _fused = +FALSE; //конец вычисления
}

PROC emitincb_bypoi()
{
  asm_dup_eol();
  asm_readvar_eol();
  emitinc();
  asm_writevar_eol();
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
  asm_const(); asmstr(_joined); endasm();
  asm_dup_eol();
  asm_readvar_eol();
  emitdec();
  asm_writevar_eol();
  _fused = +FALSE; //конец вычисления
}

PROC emitdecb_bypoi()
{
  asm_dup_eol();
  asm_readvar_eol();
  emitdec();
  asm_writevar_eol();
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
  asm_dup_eol();
  asm_readvar_eol();
  emitinc();
  asm_writevar_eol();
  _fused = +FALSE; //конец вычисления
}

PROC emitdecrg_bypoi() //[old], new free
{
  asm_dup_eol();
  asm_readvar_eol();
  emitdec();
  asm_writevar_eol();
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
  //setmainrg(); //результат в RMAIN
  //_rproxy = _RMAIN;
}

PROC prefernoregs()
{
  getnothing(); //так выгоднее inc/dec
}
