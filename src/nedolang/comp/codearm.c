//// imported
#include "../_sdk/emit.h"

#include "sizesarm.h"

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

PROC getrfree FORWARD(); //занять свободный регистр и вернуть его код
PROC freernew FORWARD(); //освободить регистр с вершины стека

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

CONST PCHAR _RNAME [_RGBUFSZ] = {
  "R0", //0 пустой, rtemp
  "R1",
  "R2",
  "R3",
  "R4",
//  "R5",
//  "R6"
};

VAR BOOL _fused;

VAR INT _funcstkdepth;

VAR BYTE _jpflag; //0=OR A:JZ, 1=JZ, 2=JNZ, 3=JNC, 4=JC

EXPORT CONST BYTE _typesz[32] = { //размер типа в байтах для таргета
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

CONST BYTE _typeshift[32] = { //log размер типа (n для 2^n байт) для таргета
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

//VAR CHAR  _swass[_STRLEN]; //todo убрать?
//VAR PCHAR _wass; //todo убрать
//VAR UINT  _lenwass; //todo убрать

VAR UINT constindex;
//VAR UINT wasconstindex; //todo убрать

VAR UINT asmcmds; //сколько команд прошло с момента последней выгрузки меток

PROC initrgs FORWARD(); //очистить состояния регистров и байтов (используется в cemitfunc)

VAR CHAR asmlblbuf[65536];
VAR UINT lenasmlblbuf;

PROC asm_dw FORWARD();
PROC asm_b FORWARD();

FUNC UINT mystrlen(PCHAR s) //длина без терминатора!
{
VAR UINT len;
VAR CHAR c;
  len = 0; //длина без терминатора!
  loop:
    c = *(PCHAR)s;
    IF (c == '\0') goto endloop; //BREAK;
    INC s;
    INC len;
  goto loop;
  endloop:
RETURN len; //длина без терминатора!
}

FUNC UINT mystrcopy(PCHAR from, PCHAR to)
{
VAR UINT len;
VAR CHAR c;
  len = 0; //длина без терминатора!
  loop:
    c = from[len];
    to[len] = c;
    IF (c == '\0') goto endloop; //BREAK;
    INC len;
  goto loop;
  endloop:
RETURN len; //длина без терминатора!
}

PROC varmangledstr(PCHAR s)
{
VAR CHAR c;
  IF (*(PCHAR)s == '\'') { //'c'
    varstr(s);
  }ELSE {
    loop:
      c = *(PCHAR)s;
      IF (c == '\0') goto quit;
      IF ((c == '.')||(c == '/')) {
        varstr("__");
      }ELSE varc(c);
      INC s;
    goto loop;
    quit:
  }
}

PROC asmmangledstr(PCHAR s)
{
VAR CHAR c;
  IF (*(PCHAR)s == '\'') { //'c'
    asmstr(s);
  }ELSE {
    loop:
      c = *(PCHAR)s;
      IF (c == '\0') goto quit;
      IF ((c == '.')||(c == '/')) {
        asmstr("__");
      }ELSE asmc(c);
      INC s;
    goto loop;
    quit:
  }
}

PROC asm_pc4_eol()
{
  asmstr("__"); asmuint(constindex); asmmangledstr(_fn); endasm(); //fn нужен, чтобы автометки для разных модулей не совпали
}

PROC asm_endpc4()
{
  asmstr("__"); asmuint(constindex); asmmangledstr(_fn); endasm(); //fn нужен, чтобы автометки для разных модулей не совпали
  INC constindex;
}

PROC asm_align4b()
{
  asmstr("\tALIGN 4"); endasm();
}

EXPORT PROC emitasmlabel(PCHAR s)
{
  asmmangledstr(s); /**asmc( ':' );*/ endasm();
}

EXPORT PROC emitfunclabel(PCHAR s)
{
  asmmangledstr(s); asmstr("\tEQU $+1"); endasm();
}

EXPORT PROC emitvarlabel(PCHAR s)
{
  varmangledstr(s); /**varc( ':' );*/ endvar();
}

PROC asmaddlabel(PCHAR s, UINT constindex)
{
VAR UINT len;
  POKE *(PUINT)(&asmlblbuf[lenasmlblbuf]) = constindex;
  lenasmlblbuf = lenasmlblbuf + +sizeof(UINT);
  len = mystrcopy(s, &asmlblbuf[lenasmlblbuf]);
  lenasmlblbuf = lenasmlblbuf + len + 1;
  asmstr("__"); asmuint(constindex); asmmangledstr(_fn); //fn нужен, чтобы автометки для разных модулей не совпали
  asmstr("__"); asmmangledstr(s); //для наглядности
//  IF (high) {asmstr( ">>32"/**WORDBITS*/ );  }; //todo long
}

PROC asmflushlabels()
{
VAR UINT i;
VAR UINT len;
  IF (lenasmlblbuf != 0) asm_align4b();
  i = 0;
  WHILE (i != lenasmlblbuf) {
    asmstr("__"); asmuint(*(PUINT)(&asmlblbuf[i])); asmmangledstr(_fn); //fn нужен, чтобы автометки для разных модулей не совпали
    i = i + +sizeof(UINT);
    asmstr("__"); emitasmlabel(&asmlblbuf[i]); //для наглядности
    //len = mystrcopy(&asmlblbuf[i], _wass);
    asm_dw(); asmmangledstr(&asmlblbuf[i]); endasm();
    i = i + mystrlen(&asmlblbuf[i]) + 1;
  };
  lenasmlblbuf = 0;
  asmcmds = 0;
}

PROC asmjpflushlabels()
{
  asm_b();
  asm_pc4_eol();
  asmflushlabels(); //не трогает constindex
  asm_endpc4();
}

//////////// мелкие процедуры для сокращения числа констант

PROC endasmcmd()
{
  endasm();
  INC asmcmds;
  IF (asmcmds >= 250) asmjpflushlabels();
}

PROC asm_direct()
{
  asmc('#');
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

PROC asm_opcurl()
{
  asmc('{');
}

PROC asm_clcurl()
{
  asmc('}');
}

PROC asm_rname(BYTE r)
{
  asmstr( _RNAME[(UINT)r] );
}

PROC asm_mrname(BYTE r)
{
  asm_open(); asm_rname(r); asm_close();
}

PROC asm_rtemp()
{
  asmstr("R0");
}

PROC asm_mrtemp()
{
  asmstr("[R0]");
}

PROC asm_rzero()
{
  asmstr("R8");
}

PROC asm_rff()
{
  asmstr("R7");
}

PROC asm_rmain()
{
  asm_rname(_RMAIN);
}

PROC asm_close_eol()
{
  asm_close(); endasmcmd();
}

PROC var_alignwsz()
{
  varstr("\tALIGN 4"); endvar();
}

EXPORT PROC var_db() //доступно из compile!
{
  varstr( "\tDCB " );
}

EXPORT PROC asm_db() //костыль для константных массивов строк TODO
{
  asmstr( "\tDCB " );
}

EXPORT PROC var_dw() //доступно из compile!
{
//  var_align4b();
  varstr( "\tDCD " );
}

EXPORT PROC asm_dw() //костыль для автогенерируемых констант
{
//  asm_align4b();
  asmstr( "\tDCD " );
}

PROC var_dl()
{
//  var_align4b();
  varstr( "\tDCQ " );
}

EXPORT PROC var_ds() //доступно из compile!
{
  varstr( "\tSPACE " );
}

PROC asm_ands() //с установкой флагов
{
  asmstr( "\tANDS " );
}

PROC asm_ors() //с установкой флагов
{
  asmstr( "\tORRS " );
}

PROC asm_eors() //с установкой флагов
{
  asmstr( "\tEORS " );
}

PROC asm_rsbs() //с установкой флагов
{
  asmstr( "\tRSBS " );
}

PROC asm_subs() //с установкой флагов
{
  asmstr( "\tSUBS " );
}

PROC asm_sbcs() //с установкой флагов
{
  asmstr( "\tSBCS " );
}

PROC asm_adds() //с установкой флагов
{
  asmstr( "\tADDS " );
}

PROC asm_adcs() //с установкой флагов
{
  asmstr( "\tADCS " );
}

PROC asm_ldr()
{
  asmstr( "\tLDR " );
}

PROC asm_ldrb()
{
  asmstr( "\tLDRB " );
}

PROC asm_str()
{
  asmstr( "\tSTR " );
}

PROC asm_strb()
{
  asmstr( "\tSTRB " );
}

PROC asm_mov() //БЕЗ установки флагов
{
  asmstr( "\tMOV " );
}

PROC asm_movs() //с установкой флагов
{
  asmstr( "\tMOVS " );
}

PROC asm_mvns() //с установкой флагов
{
  asmstr( "\tMVNS " );
}

PROC asm_b() //jr
{
  asmstr( "\tB " );
}

PROC asm_bl() //jp/call
{
  asmstr( "\tBL " );
  INC asmcmds; //long cmd
}

PROC asm_beq() //jp z
{
  asmstr( "\tBEQ " );
}

PROC asm_bne() //jp nz
{
  asmstr( "\tBNE " );
}

PROC asm_bcs() //jp c
{
  asmstr( "\tBCS " );
}

PROC asm_bcc() //jp nc
{
  asmstr( "\tBCC " );
}

PROC asm_bpl() //jp p
{
  asmstr( "\tBPL " );
}

PROC asm_bvc() //jp pe? (no overflow)
{
  asmstr( "\tBVC " );
}

PROC asm_bvs() //jp po? (overflow)
{
  asmstr( "\tBVS " );
}

PROC asm_blt() //< (знаковое сравнение)
{
  asmstr( "\tBLT " );
}

PROC asm_bgt() //> (знаковое сравнение)
{
  asmstr( "\tBGT " );
}

PROC asm_bx() //jp reg
{
  asmstr( "\tBX " );
}

PROC asm_blx() //call reg???
{
  asmstr( "\tBLX " );
}

PROC asm_nop_eol()
{
  asmstr("\tNOP"); endasmcmd();
}

PROC asm_push()
{
  asmstr( "\tPUSH " );
}

PROC asm_pop()
{
  asmstr( "\tPOP " );
}

PROC emit0(BYTE reg) //без установки флагов
{
  asm_mov(); asm_rname(reg); asm_comma(); asm_rzero(); endasmcmd();
  //asm_mov(); asm_rname(reg); asm_comma(); asm_direct(); asmc('0'); endasmcmd();
  //asm_sub(); asm_rname(reg); asm_comma(); asm_rname(reg); endasmcmd();
}

PROC emitmaskb(BYTE reg)
{
  asm_ands(); asm_rname(reg); asm_comma(); asm_rff(); endasmcmd();
}

PROC asm_call_eol(PCHAR s)
{
  asm_bl(); asmmangledstr(s); endasmcmd();
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
  asm_push(); asm_opcurl(); asm_rname(rnew); asm_clcurl(); endasmcmd();
  INC _funcstkdepth;
}

PROC emitpoprg(BYTE rnew) //регистр уже помечен в getrfree/getrg
{
  asm_pop(); asm_opcurl(); asm_rname(rnew); asm_clcurl(); endasmcmd();
  DEC _funcstkdepth;
}

PROC emitmovrg(BYTE rsrc, BYTE rdest) //не заказывает и не освобождает (см. emitmoverg)
{
  asm_movs(); asm_rname(rdest); asm_comma(); asm_rname(rsrc); endasmcmd(); //не mov, потому что оба регистра r0..r7
}

///////////////////////////////////////////////////////////////////////////////////////
//эти процедуры генерируют код
//недоступны из компилятора, доступны из commands

EXPORT PROC emitexport(PCHAR s)
{
  asmstr("\tEXPORT "); asmmangledstr(s); endasmcmd();
}

EXPORT PROC emitvarpreequ(PCHAR s)
{
//  varstr("\tIF :LNOT: :DEF: "); varmangledstr(s); endvar(); //todo убрать (Keil)
}

EXPORT PROC emitvarpostequ()
{
//  varstr("\tENDIF"); endvar(); //todo убрать (Keil)
}

EXPORT PROC varequ(PCHAR s)
{
  varmangledstr(s); varstr("\tEQU ");
}

EXPORT FUNC UINT varshift(UINT shift, UINT sz)
{
  IF (sz >= 4) shift = (shift+3)&(UINT)(-4);
  //asmstr(_joined); asmc('='); asmuint(shift); endasm();
  varequ(_joined); /**varstr(_joined); varc('=');*/ varuint(shift); endvar();
RETURN shift;
}

PROC emitjpmainrg() //"jp (hl)"
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  getnothing(); //getnothingword();
  asm_bx(); asm_rmain(); endasmcmd();
}

PROC emitcallmainrg() //"call (hl)"
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  getnothing(); //getnothingword();
/**  //asm_blx(); asm_rmain(); endasmcmd();
  asm_add(); asm_rtemp(); asm_comma(); asmstr("PC"); asm_comma(); asmstr("#8"); endasmcmd();
  asm_mov(); asmstr("LR"); asm_comma(); asm_rtemp(); endasmcmd();
  asm_bx(); asm_rmain(); endasmcmd();
  asm_nop_eol();
*/
  asm_call_eol("_JPHL.");
  _fused = +FALSE; //конец вычисления
}

PROC emitjp()
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  unproxy();
  getnothing(); //getnothingword();
  asm_b(); asmmangledstr(_joined); endasmcmd();
}

PROC emitbtoz() //перед jp!
{
  //сразу после сравнения не надо, но вдруг мы читаем BOOL
  //IF (_jpflag == 0x00) {
  IF (!_fused) { //результата нет во флагах
    asm_ors(); asm_rname(_rnew); asm_comma(); asm_rname(_rnew); endasmcmd();
  };
}

PROC emitjpiffalse()
{
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  getnothing(); //getnothingword();
  IF       (_jpflag == 0x02) {asm_beq(); //asm_bne();
  }ELSE IF (_jpflag == 0x03) {asm_bcc(); //asm_bcs();
  }ELSE IF (_jpflag == 0x04) {asm_bcs(); //asm_bcc();
  }ELSE                      {asm_bne(); //asm_beq();
  };
  asm_pc4_eol();

  asm_bl(); //long jp
  asmmangledstr(_joined);
  endasmcmd();

  asm_endpc4();
  _fused = +FALSE;
  _jpflag = 0x00;
}

PROC emitret()
{
  asm_pop(); asmstr( "{PC}" ); endasmcmd();
  asmflushlabels();
}

PROC emitcall2rgs(PCHAR s)
{
  unproxy();
  getmain2rgs();
  initrgs();
  asm_call_eol(s);
  setmainrg(); //результат в RMAIN
}
/**
PROC emitcall3rgs(PCHAR s) //todo проверить
{
  unproxy();
  getmain3rgs();
  initrgs();
  asm_call_eol(s);
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
  asm_call_eol(s);
  //сейчас все регистры отмечены как свободные
  //setwordcontext();
  setmain2rgs(); //результат в RMAIN,RMAIN2
}

PROC emitcallproc()
{
  //_jpflag = 0x00;
  asm_call_eol(_callee);
}

PROC emitloadrtemp(BYTE r, PCHAR s)
{
  asm_ldr(); asm_rname(r); asm_comma();
  //asmc('L'); asmstr(s); //todo подпрограмма с выделением константы, с исключением повторного присваивания (rtemp присваивается только здесь и в inc/dec)
  asmaddlabel(s, constindex);
  INC constindex;
  endasmcmd();
}

PROC emitloadrg(BOOL high) //регистр уже занят через getrfree
{
  emitloadrtemp(_rnew,_const);
//  asm_ldr(); asm_rname(_rnew); asm_comma(); asm_mrtemp(); endasmcmd(); //todo long
  _fused = +FALSE; //конец вычисления
}

PROC emitloadrg0() //регистр уже занят через getrfree
{
  emit0(_rnew); //флаги не важны
}

PROC emitloadb() //аккумулятор уже занят через getfreea
{
  asm_movs(); asm_rname(_rnew); asm_comma(); asm_direct(); asmmangledstr(_const); endasmcmd();
}

PROC emitgetrg(BOOL high) //регистр уже занят через getrfree
{
  emitloadrtemp(0x00,_joined);
  asm_ldr(); asm_rname(_rnew); asm_comma(); asm_mrtemp(); endasmcmd(); //todo long
}

PROC emitgetb() //аккумулятор уже занят через getfreea
{
  emitloadrtemp(0x00,_joined);
  asm_ldrb(); asm_rname(_rnew); asm_comma(); asm_mrtemp(); endasmcmd();
}

PROC emitputrg(BOOL high) //ld [],new
{
  //_jpflag = 0x00;
  emitloadrtemp(0x00,_joined);
  asm_str(); asm_rname(_rnew); asm_comma(); asm_mrtemp(); endasmcmd(); //todo long
  _fused = +FALSE; //конец вычисления
}

PROC emitputb()
{
  //_jpflag = 0x00;
  emitloadrtemp(0x00,_joined);
  asm_strb(); asm_rname(_rnew); asm_comma(); asm_mrtemp(); endasmcmd();
  _fused = +FALSE; //конец вычисления
}

PROC emitshl1rg()
{
  asm_adds(); asm_rname(_rnew); asm_comma(); asm_rname(_rnew); endasmcmd();
}

PROC emitshl1b()
{
  asm_adds(); asm_rname(_rnew); asm_comma(); asm_rname(_rnew); endasmcmd();
  emitmaskb(_rnew);
}
/**
PROC emitshr1rg(BYTE rnew)
{
  asmstr( "\tSRL " ); asm_rhigh(rnew); endasmcmd();
  asmstr( "\tRR " ); asm_rlow(rnew); endasmcmd();
}

PROC emitshr1signedrg(BYTE rnew)
{
  asmstr( "\tSRA " ); asm_rhigh(rnew); endasmcmd();
  asmstr( "\tRR " ); asm_rlow(rnew); endasmcmd();
}
*/
//PROC emitshr1b(BYTE anew)
//{
//  asmstr( "\tSRL " ); /**rganame*/asm_rlow(anew] ); endasmcmd();
//}

PROC emitinvb() //~A -> A
{
  asm_eors(); asm_rname(_rnew); asm_comma(); asm_rff(); endasmcmd();
}

PROC emitinvrg()
{
  asm_mvns(); asm_rname(_rnew); asm_comma(); asm_rname(_rnew); endasmcmd();
}

PROC emitnegrg()
{
  asm_rsbs(); asm_rname(_rnew); asm_comma(); asm_rname(_rnew); asm_comma(); asm_direct(); asmc('0'); endasmcmd();
}

PROC emitSxorVtob() //после subflags (less), разрезервирует A
{ //todo проверить
  emit0(_rnew); //без установки флагов
  asm_bgt(); asm_pc4_eol();
  asm_eors(); asm_rname(_rnew); asm_comma(); asm_rff(); endasmcmd();
  asm_endpc4();
}

PROC emitinvSxorVtob() //после subflags (moreeq), разрезервирует A
{ //todo проверить
  emit0(_rnew); //без установки флагов
  asm_blt(); asm_pc4_eol();
  asm_eors(); asm_rname(_rnew); asm_comma(); asm_rff(); endasmcmd();
  asm_endpc4();
}

PROC emitxorrg() //old^new => old
{
  asm_eors(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  _fused = +TRUE; //^^
}

PROC getxorb() //RGA^RGA2 -> RGA
{
  asm_eors(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  _fused = +TRUE; //^^
}

PROC emitorrg() //old|new => old
{
  asm_ors(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  _fused = +TRUE; //||
}

PROC getorb() //RGA|RGA2 -> RGA
{
  asm_ors(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  _fused = +TRUE; //||
}

PROC emitandrg() //old&new => old
{
  asm_ands(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  _fused = +TRUE; //&&
}

PROC getandb() //RGA&RGA2 -> RGA
{
  asm_ands(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  _fused = +TRUE; //&&
}

PROC emitaddrg() //old+new => old
{
  asm_adds(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
}

PROC emitadcrg() //old+new => old
{
  asm_adcs(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
}

PROC emitaddb() //old+new
{
  asm_adds(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  emitmaskb(_rold);
}

PROC emitaddbconst() //new8+<const>
{
  asm_adds(); asm_rname(_rnew); asm_comma(); asm_direct(); asmmangledstr(_const); endasmcmd();
  emitmaskb(_rnew);
}

PROC emitsubrg() //old-new => old
{
  asm_subs(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
}

PROC emitsbcrg() //old-new => old
{
  asm_sbcs(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
}

PROC emitsubb() //old-new
{
  asm_subs(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  emitmaskb(_rold);
}

PROC emitsubbconst() //new8-<const>
{
  asm_subs(); asm_rname(_rnew); asm_comma(); asm_direct(); asmmangledstr(_const); endasmcmd();
  emitmaskb(_rnew);
}

PROC emitsubflags(BYTE rnew, BYTE rold) //r2-r1 => CY,sign,overflow
{
  asm_subs(); asm_rname(rold); asm_comma(); asm_rname(rnew); endasmcmd();
  _fused = +TRUE;
}

PROC emitsubbflags(BYTE anew, BYTE aold) //a2-a1 => CY
{ //sign,overflow не нужен!
  asm_subs(); asm_rname(aold); asm_comma(); asm_rname(anew); endasmcmd();
  _fused = +TRUE;
}

PROC emitsubz() //old-new => Z
{
  asm_subs(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  _fused = +TRUE;
}

PROC emitsubbz() //old-new => Z
{
  asm_subs(); asm_rname(_rold); asm_comma(); asm_rname(_rnew); endasmcmd();
  _fused = +TRUE;
}

PROC emitsubbzconst() //new-<const> => Z
{
  asm_subs(); asm_rname(_rnew); asm_comma(); asm_direct(); asmmangledstr(_const); endasmcmd();
  _fused = +TRUE;
}

PROC emitsublongz() //old2-new, old3-old => Z
{ //todo
  _fused = +TRUE;
}

PROC emitpokerg() //новое записываем в старую локацию памяти
{
  asm_str(); asm_rname(_rnew); asm_comma(); asm_mrname(_rold); endasmcmd();
  _fused = +FALSE; //конец вычисления
}

PROC emitpokeb() //новое записываем в старую локацию памяти
{
  asm_strb(); asm_rname(_rnew); asm_comma(); asm_mrname(_rold); endasmcmd();
  _fused = +FALSE; //конец вычисления
}

PROC emitpokelong() //old2(addr), old(high), new(low)
{
  asm_str(); asm_rname(_rnew); asm_comma(); asm_mrname(_rold2); endasmcmd();
  asm_adds(); asm_rname(_rold2); asm_comma(); asmstr("#4"); endasmcmd();
  asm_str(); asm_rname(_rold); asm_comma(); asm_mrname(_rold2); endasmcmd();
  _fused = +FALSE; //конец вычисления
}

PROC emitpeekrg() //[new] => new
{
  asm_ldr(); asm_rname(_rnew); asm_comma(); asm_mrname(_rnew); endasmcmd();
}

PROC emitpeekb()
{
  asm_ldrb(); asm_rname(_rnew); asm_comma(); asm_mrname(_rnew); endasmcmd();
}

PROC emitpeeklong() //[old] => old(high),new(low)
{
  asm_ldr(); asm_rname(_rnew); asm_comma(); asm_mrname(_rold); endasmcmd();
  asm_adds(); asm_rname(_rold); asm_comma(); asmstr("#4"); endasmcmd();
  asm_ldr(); asm_rname(_rold); asm_comma(); asm_mrname(_rold); endasmcmd();
}

PROC emitztob()
{
  //asmstr(";emitztoa exprlvl="); asmuint(_exprlvl); endasmcmd();
  IF (_exprlvl != 0x01) { //if (a == b)
    emit0(_rnew); //без установки флагов
    asm_bne(); asm_pc4_eol();
    emitinvb();
    asm_endpc4();
    _fused = +FALSE; //иначе глюк при if ((a==b))
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x02;
  };
}

PROC emitinvztob()
{
  //asmstr(";emitinvztoa exprlvl="); asmuint(_exprlvl); endasmcmd();
  IF (_exprlvl != 0x01) { //if (a != b)
    emit0(_rnew); //без установки флагов
    asm_beq(); asm_pc4_eol();
    emitinvb();
    asm_endpc4();
    _fused = +FALSE; //иначе глюк при if ((a!=b))? todo test //возможен глюк ifnot ((a!=b))
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x01;
  };
}

PROC emitcytob()
{
  //asmstr(";emitcytoa exprlvl="); asmuint(_exprlvl); endasmcmd();
  IF (_exprlvl != 0x01) { //if (a < b)
    asm_sbcs(); asm_rname(_rnew); asm_comma(); asm_rname(_rnew); endasmcmd();
    //_fused = +FALSE;
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x03;
  };
}

PROC emitinvcytob()
{
  //asmstr(";emitinvcytoa exprlvl="); asmuint(_exprlvl); endasmcmd();
  IF (_exprlvl != 0x01) { //if (a >= b)
    asm_sbcs(); asm_rname(_rnew); asm_comma(); asm_rname(_rnew); endasmcmd();
    asm_eors(); asm_rname(_rnew); asm_comma(); asm_rff(); endasmcmd();
    //_fused = +FALSE;
    //_jpflag = 0x00;
  }ELSE {
    //_fused = +TRUE;
    _jpflag = 0x04;
  };
}

PROC emitrgtob() //нельзя убирать - специфично
{
  emitmaskb(_rnew); //todo наоборот, игнорировать ст.часть слова, кроме сравнений
}

PROC emitbtorg()
{
}

PROC emitincrg_byname()
{
  emitloadrtemp(_rnew,_joined);
  asm_ldr(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  asm_adds(); asm_rtemp(); asm_comma(); asmstr("#1"); endasmcmd();
  asm_str(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  //asm_adds(); asm_rname(_rnew); asm_comma(); asm_direct(); asmc('1'); endasmcmd();
  _fused = +FALSE; //конец вычисления
}

PROC emitincb_bypoi()
{
  asm_ldrb(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  asm_adds(); asm_rtemp(); asm_comma(); asmstr("#1"); endasmcmd();
  asm_strb(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  _fused = +FALSE; //конец вычисления
}
/**
PROC emitinclong() //todo
{
  asm_inc(); asm_open(); asm_rname(_rnew); asm_close(); endasmcmd();
  _fused = +FALSE; //конец вычисления
}
*/
PROC emitdecrg_byname()
{
  emitloadrtemp(_rnew,_joined);
  asm_ldr(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  asm_subs(); asm_rtemp(); asm_comma(); asmstr("#1"); endasmcmd();
  asm_str(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  //asm_subs(); asm_rname(_rnew); asm_comma(); asmstr("#1"); endasmcmd();
  _fused = +FALSE; //конец вычисления
}

PROC emitdecb_bypoi()
{
  asm_ldrb(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  asm_subs(); asm_rtemp(); asm_comma(); asmstr("#1"); endasmcmd();
  asm_strb(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  _fused = +FALSE; //конец вычисления
}
/**
PROC emitdeclong() //todo
{
  asm_dec(); asm_open(); asm_rname(_rnew); asm_close(); endasmcmd();
  _fused = +FALSE; //конец вычисления
}
*/

PROC emitincrg_bypoi() //[old], new free
{
  asm_ldr(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  asm_adds(); asm_rtemp(); asm_comma(); asmstr("#1"); endasmcmd();
  asm_str(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  _fused = +FALSE; //конец вычисления
}

PROC emitdecrg_bypoi() //[old], new free
{
  asm_ldr(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  asm_subs(); asm_rtemp(); asm_comma(); asmstr("#1"); endasmcmd();
  asm_str(); asm_rtemp(); asm_comma(); asm_mrname(_rnew); endasmcmd();
  _fused = +FALSE; //конец вычисления
}

/////////////
EXPORT PROC initcode()
{
//  _wass = (PCHAR)_swass;
  _jpflag = 0x00;
  constindex = 0;
  asmcmds = 0;
  asmstr("\tALIGN 2"); endasm();
}

EXPORT PROC endcode()
{
  asmflushlabels();
  asmstr("\tEND"); endasmcmd();
  varstr("\tEND"); endvar();
}

PROC initrgs()
{
  rgs_initrgs();
  _fused = +FALSE; //можно сделать одну процедуру initif для этого (вызывать в начале if, while, until)
}

PROC emitfunchead()
{
  asm_push(); asmstr( "{LR}" ); endasmcmd();
  initrgs();
}

PROC setmainb()
{
  setmainrg(); //результат в RMAIN
}

PROC prefernoregs()
{
}

