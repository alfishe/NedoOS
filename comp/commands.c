//// imported
//везде, где нужен строковый параметр, используется _joined (кроме call - там _callee)
#include "../_sdk/typecode.h"
#include "../_sdk/str.h"
#include "../_sdk/emit.h"

#ifdef TARGET_THUMB
#include "sizesarm.h"
#else
#include "sizesz80.h"
#endif

CONST BYTE _typeshift[32]; //log размер типа (n для 2^n байт)
CONST BYTE _typesz[32];

CONST BYTE _RMAIN; //регистр результата и 1-го параметра стандартных функций
//#endif

EXPORT VAR TYPE _t; //текущий тип (для cmds)
EXPORT VAR BOOL _isloc; //локальная ли прочитанная переменная

//EXTERN PCHAR _tword; //текущее слово
//EXTERN UINT _lentword;
EXPORT VAR PCHAR _name; //метка без префикса (для таблицы меток)
EXPORT VAR UINT  _lenname;
EXPORT VAR PCHAR _joined; //автометка
EXPORT VAR UINT  _lenjoined;

#ifdef TARGET_THUMB
#include "codearm.c"
#else
#include "codez80.c"
#endif

#include "regs.c"

////

VAR PCHAR _const; //старая константа
VAR UINT  _lenconst;
//VAR PCHAR _wastword; //старая константа
//VAR UINT  _lenwastword;
VAR BOOL _wasconst;
VAR CHAR  _sc[_STRLEN]; //старая константа
//VAR CHAR  _sw[_STRLEN]; //старый tword
VAR TYPE _wast;

VAR BYTE _sz; //временно размер типа - используется в разных процедурах

#define _STRSTKMAX 256
VAR CHAR _strstk[_STRSTKMAX]; //str1+<len>+str2+<len>...+strN+<len> //было ' '+str1+' '+str2+...+' '+strN
EXPORT VAR UINT _lenstrstk;

#ifdef BIGMEM
#define _LBLBUFSZ 0xffff
#else
#define _LBLBUFSZ 0x2300 /**0x2100*/
#endif
VAR UINT _lblbuffreeidx; //[1];
VAR UINT _oldlblbuffreeidx; //[1];
CONST UINT _LBLBUFEOF = 0xffff;
#define _LBLBUFMAXSHIFT (UINT)(_LBLBUFSZ-_STRLEN-20)
//todo динамически выделить
VAR UINT _lblshift[0x100];
VAR UINT _oldlblshift[0x100];
VAR BYTE _lbls[_LBLBUFSZ];
VAR BYTE _lblhash;

VAR UINT _typeaddr;
EXPORT VAR UINT _varszaddr;
EXPORT VAR UINT _varsz;

PROC cmdshl1 FORWARD();

PROC errtype(PCHAR msg, TYPE t)
{
  errstr("operation "); errstr(msg); errstr(" bad type="); erruint(+(UINT)t); enderr();
}

EXPORT PROC strpush(PCHAR s, UINT len) //joined или callee
{ //str1+<len>+str2+<len>...+strN+<len> (с терминаторами)
  IF ((_lenstrstk+len+2) > _STRSTKMAX) {
    errstr("STRING STACK OVERFLOW"); enderr();
  }ELSE {
    strcopy(s, len, &_strstk[_lenstrstk]);
    _lenstrstk = _lenstrstk + len + 1;
    _strstk[_lenstrstk] = +(CHAR)(+(BYTE)len);
    INC _lenstrstk;
  };
}

EXPORT FUNC UINT strpop(PCHAR s)
{ //str1+<len>+str2+<len>...+strN+<len> (с терминаторами)
VAR UINT len;
  DEC _lenstrstk;
  len = +(UINT)(+(BYTE)(_strstk[_lenstrstk]));
  _lenstrstk = _lenstrstk - len - 1;
  strcopy((PCHAR)(&_strstk[_lenstrstk]), len, s);
RETURN len;
}

EXPORT PROC initlblbuf()
{
  _lblhash = 0x00;
  REPEAT {
    _lblshift[_lblhash] = _LBLBUFEOF;
    INC _lblhash;
  }UNTIL (_lblhash == 0x00);
  _lblbuffreeidx = 0;
};

EXPORT FUNC UINT gettypename(PCHAR s) //взять название типа структуры в joined (сразу после lbltype)
{
RETURN strcopy((PCHAR)&_lbls[_typeaddr], (UINT)*(PBYTE)&_lbls[_typeaddr-1], s);
}

EXPORT PROC setvarsz(UINT addr, UINT shift)
{
  POKE *(PUINT)(&_lbls[addr]) = shift;
}

EXPORT FUNC TYPE lbltype() //вернуть тип метки _name
{
VAR PBYTE plbl; //метка в таблице заканчивается нулём
VAR TYPE t;
VAR UINT plbl_idx;
  t = _T_UNKNOWN;
  _lblhash = +(BYTE)hash((PBYTE)_name);
  plbl_idx = _lblshift[_lblhash];
  WHILE (plbl_idx != _LBLBUFEOF) { //пока цепочка меток не закончилась
    plbl = &_lbls[plbl_idx];
    plbl_idx = *(PUINT)(plbl);
    plbl = &plbl[+sizeof(UINT)+1]; //skip string size
    IF (strcp((PCHAR)_name, (PCHAR)plbl)) { //метка найдена
      _typeaddr = (UINT)(plbl - _lbls); //для запоминания типа в будущей переменной
      plbl = &plbl[_lenname+1];
      t = *(TYPE*)(plbl);
      plbl = &plbl[+sizeof(TYPE)]; //INC plbl;
      _isloc = (BOOL)*(PBYTE)(plbl);
      INC plbl;
      IF ((t&_T_TYPE)==(TYPE)0x00) _typeaddr = *(PUINT)(plbl); //вспоминаем адрес типа, если это переменная, а не объявление типа
      plbl = &plbl[+sizeof(UINT)];
      _varsz = *(PUINT)(plbl);
      break;
    };
  };
RETURN t;
}

EXPORT PROC dellbl() //для undef
{
VAR PBYTE plbl; //метка в таблице заканчивается нулём
VAR UINT plbl_idx;
  _lblhash = +(BYTE)hash((PBYTE)_name);
  plbl_idx = _lblshift[_lblhash];
  WHILE (plbl_idx != _LBLBUFEOF) { //пока цепочка меток не закончилась
    plbl = &_lbls[plbl_idx];
    plbl_idx = *(PUINT)(plbl);
    plbl = &plbl[+sizeof(UINT)+1]; //skip string size
    IF (strcp((PCHAR)_name, (PCHAR)plbl)) { //метка найдена
      POKE *(PCHAR)(plbl) = '\0';
      break;
    };
  };
}

EXPORT PROC addlbl(TYPE t, BOOL isloc, UINT varsz/**, PCHAR size, UINT lensize*/) //(_name)
{
VAR PBYTE plbl;
VAR UINT freeidx;
VAR TYPE oldt;
  oldt = lbltype(); //(_name) //устанавливает _isloc (если найдена) и _typeaddr (адрес, если найдена)
  IF ((oldt == _T_UNKNOWN)||isloc/**(isloc&&!_isloc)*/) { //если не было метки или локальная поверх глобальной или другой локальной (параметра)
    //метки нет: пишем в начало цепочки адрес конца страницы и создаём метку там со ссылкой на старое начало цепочки
    freeidx = _lblbuffreeidx; //[0] //начало свободного места
    IF (freeidx < _LBLBUFMAXSHIFT) { //есть место под метку
      plbl = &_lbls[freeidx]; //указатель на начало создаваемой метки
      //пишем метку
      POKE *(PUINT)(plbl) = _lblshift[_lblhash]; //старый указатель на начало цепочки
      plbl = &plbl[+sizeof(UINT)];
      POKE *(PBYTE)(plbl) = (BYTE)_lenname;
      INC plbl;
      strcopy(_name, _lenname, (PCHAR)plbl);
      plbl = &plbl[_lenname+1];
      POKE *(TYPE*)(plbl) = t;
      plbl = &plbl[+sizeof(TYPE)]; //INC plbl;
      POKE *(PBYTE)(plbl) = (BYTE)isloc;
      INC plbl;
      POKE *(PUINT)(plbl) = _typeaddr; //ссылка на название типа (для структуры)
      plbl = &plbl[+sizeof(UINT)];
      _varszaddr = (UINT)(plbl - _lbls); //чтобы потом можно было менять
      POKE *(PUINT)(plbl) = varsz;
      _lblbuffreeidx = +(UINT)(plbl - _lbls) + +sizeof(UINT); //указатель конец создаваемой метки
      _lblshift[_lblhash] = freeidx; //новый указатель на начало цепочки
    }ELSE {errstr("nomem"); enderr();
    };
  }ELSE IF (oldt != t) {
    errstr("addvar type doesn't match previous declaration:"); errstr(_name); enderr();
  };
}

//#define _LBLBUFSZ (UINT)(+sizeof(UINT)*0x100) /**нельзя sizeof в асме*/
EXPORT PROC keepvars() //перед началом локальных меток
{
  memcopy((PBYTE)_lblshift, +sizeof(UINT)*0x100 /**todo const*/, (PBYTE)_oldlblshift);
  _oldlblbuffreeidx = _lblbuffreeidx;
}

EXPORT PROC undovars() //после локальных меток (забыть их)
{
  memcopy((PBYTE)_oldlblshift, +sizeof(UINT)*0x100 /**todo const*/, (PBYTE)_lblshift);
  _lblbuffreeidx = _oldlblbuffreeidx;
}

//////////////////////////////// MATH ///////////////////////////////////////
//процедуры не знают и не трогают режимы регистров

EXPORT PROC var_alignwsz_label(TYPE t)
{
  IF (_typesz[t&_TYPEMASK]!=_SZ_BYTE) {
    var_alignwsz();
  };
  emitvarlabel(_joined);
}

EXPORT PROC var_def(TYPE t, PCHAR s) //доступно из compile!
{
VAR BYTE sz = _typesz[t];
  IF (sz==_SZ_BYTE/**(tmasked==_T_BYTE)||(tmasked==_T_CHAR)||(tmasked==_T_BOOL)*/) {
    var_db(); varstr(s); endvar();
  }ELSE IF (sz==_SZ_REG/**(tmasked==_T_INT)||(tmasked==_T_UINT)*/) {
    var_dw(); varstr(s); endvar(); //ширина DW равна uint
  }ELSE IF (sz==_SZ_LONG/**tmasked==_T_LONG*/) {
    var_dl(); varstr(s); endvar();
  }ELSE { errstr( "const bad type " ); erruint(+(UINT)t); enderr(); };
}

PROC pushconst() //сохраняет число, которое не сохранили при pushnum
{ //нельзя затирать joined
#ifdef USE_COMMENTS
;;  cmtstr( ";PUSHCONST " ); cmtstr( _const ); endcmt();
#endif
  //_lenwastword = strcopy(_joined, _lenjoined, _wastword);
  //_lenjoined = strcopy(_const, _lenconst, _joined);
  _sz = _typesz[_wast];
  IF (_sz==_SZ_BYTE) { //(_wast==_T_BYTE)||(_wast==_T_CHAR)||(_wast==_T_BOOL)
    getrfree(); //_rnew
    emitloadb();
  }ELSE IF (_sz==_SZ_REG) { //(_wast==_T_INT)||(_wast==_T_UINT)||(_wast>=_T_POI)
    getrfree(); //_rnew
    emitloadrg(+FALSE);
  }ELSE IF (_sz==_SZ_LONG) { //_wast==_T_LONG
    getrfree(); //_rnew
    emitloadrg(+TRUE); //high
    getrfree(); //_rnew
    emitloadrg(+FALSE); //low
  }ELSE errtype("pushconst",_wast);
  //_lenjoined = strcopy(_wastword, _lenwastword, _joined);
  _wasconst = +FALSE;
}

EXPORT PROC cmdpushnum()
{
#ifdef USE_COMMENTS
;;  cmtstr(";PUSHNUM "); cmtstr(_joined); endcmt();
#endif
  IF (_wasconst) pushconst();
  _lenconst = strcopy(_joined, _lenjoined, _const);
  _wast = _t;
  _wasconst = +TRUE;
}

EXPORT PROC cmdpushvar()
{
#ifdef USE_COMMENTS
;;  cmtstr(";PUSHVAR "); cmtstr(_joined); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE/**(_t==_T_BYTE)||(_t==_T_CHAR)||(_t==_T_BOOL)*/) {
    getrfree(); //_rnew
    emitgetb();
  }ELSE IF (_sz==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
    getrfree(); //_rnew
    emitgetrg(+FALSE);
  }ELSE IF (_sz==_SZ_LONG/**_t==_T_LONG*/) {
    getrfree(); //_rnew
    emitgetrg(+TRUE); //high
    getrfree(); //_rnew
    emitgetrg(+FALSE); //low
  }ELSE errtype("pushvar",_t);
}

EXPORT PROC cmdpopvar()
{
#ifdef USE_COMMENTS
;;  cmtstr(";POPVAR "); cmtstr(_joined); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE/**(_t==_T_BYTE)||(_t==_T_CHAR)||(_t==_T_BOOL)*/) {
    getrnew();
    emitputb();
    freernew();
  }ELSE IF (_sz==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
    getrnew();
    emitputrg(+FALSE);
    freernew();
  }ELSE IF (_sz==_SZ_LONG/**_t==_T_LONG*/) {
    getrnew();
    emitputrg(+FALSE); //low
    freernew();
    getrnew();
    emitputrg(+TRUE); //high
    freernew();
  }ELSE errtype("popvar",_t);
}

EXPORT PROC cmdcastto(TYPE t2)
{
VAR BYTE tsz;
VAR BYTE t2sz;
#ifdef USE_COMMENTS
;;  cmtstr(";OPERATION cast "); cmtuint(+(UINT)_t); cmt('>'); cmtuint(+(UINT)t2); endcmt();
#endif
  tsz = _typesz[_t];
  t2sz = _typesz[t2];
  IF (tsz==t2sz/**_t == t2*/) { //типы одного размера - не портим константу
    //todo badcast LONG<=>FLOAT
  }ELSE {
    IF (_wasconst) pushconst(); //не портим константу при BYTE<=>CHAR
    IF (tsz==_SZ_BYTE/**_t==_T_BYTE*/) { //BYTE =>
      IF (t2sz==_SZ_REG/**(t2==_T_INT)||(t2==_T_UINT)*/) { //BYTE => INT|UINT
        getrnew();
        emitbtorg();
      }ELSE /**IF (t2sz==_SZ_LONG)*/ { //BYTE => LONG
        getrnew();
        emitbtorg();
        getrfree(); //_rnew
        emitloadrg0(); //теперь old = rg, new = 0
        swaptop(); //теперь old = 0, new = rg
      //}ELSE IF (t2==_T_CHAR) { //BYTE => CHAR
      //}ELSE IF (t2==_T_BOOL) { //BYTE => BOOL (for serialization)
      };//ELSE goto bad;
    }ELSE IF (tsz==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)*/) {
      IF (t2sz==_SZ_BYTE/**t2==_T_BYTE*/) { //INT|UINT => BYTE
        getrnew();
        emitrgtob();
      }ELSE /**IF (t2sz==_SZ_LONG)*/ { //INT|UINT => LONG
        getrfree(); //_rnew
        //IF (_t==_T_UINT) { //UINT => LONG
          emitloadrg0(); //теперь old = rg, new = 0
        //}ELSE IF (_t==_T_UINT) { //INT => LONG
        //};
        swaptop(); //теперь old = 0, new = rg
      //}ELSE IF (t2>=_T_POI) { //UINT => POINTER (INT possible but not desirable)
      };//ELSE goto bad;
    }ELSE IF (tsz==_SZ_LONG) { //LONG =>
      IF (t2sz==_SZ_REG/**(t2==_T_INT)||(t2==_T_UINT)*/) { //LONG => INT|UINT
        swaptop(); //теперь old = low, new = high
        freernew(); //high
      }ELSE /**IF (t2sz==_SZ_BYTE)*/ { //LONG => BYTE
        swaptop(); //теперь old = low, new = high
        freernew(); //high
        getrnew();
        emitrgtob();
/**      }ELSE { //LONG<=>FLOAT
        bad:
        errstr("bad cast: "); erruint(+(UINT)_t); err('>'); erruint(+(UINT)t2); enderr();*/
      };
    //}ELSE IF ( (_t==_T_CHAR) && (t2==_T_BYTE) ) { //CHAR => BYTE
    //}ELSE IF ( (_t==_T_BOOL) && (t2==_T_BYTE) ) { //BOOL => BYTE (for serialization)
    //}ELSE IF ( (_t>=_T_POI) && ((t2==_T_UINT)||(t2>=_T_POI)) ) { //POINTER => UINT|POINTER (conversion between pointers)
    //}ELSE IF ((t2&_T_POI)!=0x00) { // anything (i.e. array) => POINTER
//    }ELSE {goto bad; //по идее никогда не произойдёт
    };
  };
  _t = t2;
}

EXPORT PROC cmdadd()
{
#ifdef USE_COMMENTS
;;  cmtstr(";OPERATION +"); endcmt();
#endif
  IF (_t==_T_BYTE) {
    IF (_wasconst) {
      getrnew();
      emitaddbconst();
      _wasconst = +FALSE;
    }ELSE {
      getrnew();
      getrold();
      emitaddb();
      freernew();
    };
  }ELSE {
    IF (_wasconst) pushconst();
    IF (_typesz[_t]==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
      getrold(); //берём раньше, чтобы получить быстрый регистр
      getrnew();
      emitaddrg(); //rold+rnew => rold
      freernew();
    }ELSE IF (_t==_T_LONG) { //не float
      getrold2(); //oldlow //берём раньше, чтобы получить быстрый регистр
      getrnew(); //newlow
      emitaddrg(); //old2+new => old2
      freernew();
      //теперь new=newhigh, old=(oldlow+newlow)
      getrold2(); //oldhigh из стека //берём раньше, чтобы получить быстрый регистр
      getrnew(); //newhigh
      emitadcrg(); //old2+new+CY => old2
      freernew();
      //теперь new=(oldlow+newlow), old=(oldhigh+newhigh+CY)
    }ELSE errtype("+",_t);
  };
}

EXPORT PROC cmdsub() //из старого вычесть новое!
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION -" ); endcmt();
#endif
  IF (_t==_T_BYTE) {
    IF (_wasconst) {
      getrnew();
      emitsubbconst();
      _wasconst = +FALSE;
    }ELSE {
      getrnew();
      getrold();
      emitsubb();
      freernew();
    };
  }ELSE {
    IF (_wasconst) pushconst();
    IF (_typesz[_t]==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
      getrold(); //берём раньше, чтобы получить быстрый регистр
      getrnew();
      emitsubrg(); //rold-rnew => rold
      freernew();
      //IF(_t>=_T_POI) {t = _T_INT;};
    }ELSE IF (_t==_T_LONG) { //не float
      getrold2(); //oldlow //берём раньше, чтобы получить быстрый регистр
      getrnew(); //newlow
      emitsubrg(); //old2-new => old2
      freernew();
      //теперь new=newhigh, old=(oldlow-newlow)
      getrold2(); //oldhigh из стека //берём раньше, чтобы получить быстрый регистр
      getrnew(); //newhigh
      emitsbcrg(); //old2-new-CY => old2
      freernew();
      //теперь new=(oldlow-newlow), old=(oldhigh-newhigh-CY)
    }ELSE errtype("-",_t);
  };
}

EXPORT PROC cmdaddpoi() //_t содержит тип ячейки массива
{
VAR BYTE i;
#ifdef USE_COMMENTS
;;  cmtstr(";OPERATION +poi"); endcmt();
#endif
  IF (_wasconst) pushconst();
/**  i = _typeshift[_t&_TYPEMASK];
  WHILE (i != 0x00) {
    _t = _T_INT;
    cmdshl1();
    DEC i;
  };*/
  getrold(); //берём раньше, чтобы получить быстрый регистр
  getrnew();
  i = _typesz[_t&_TYPEMASK];
  WHILE (i != 0x00) {
    emitaddrg(); //rold+rnew => rold
    DEC i;
  };
  freernew();
}

EXPORT PROC cmdmul()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION *" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {emitcall2rgs("_MULB.");
  }ELSE IF (_t==_T_UINT) {emitcall2rgs("_MUL.");
  }ELSE IF (_t==_T_INT) {emitcall2rgs("_MULSIGNED.");
  }ELSE IF (_t==_T_LONG) {emitcall4rgs("_MULLONG.");
  }ELSE errtype("*",_t);
}

EXPORT PROC cmddiv() //старое разделить на новое!
{
#ifdef USE_COMMENTS
;;  cmtstr(";OPERATION /"); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {emitcall2rgs("_DIVB.");
  }ELSE IF (_t==_T_UINT) {emitcall2rgs("_DIV.");
  }ELSE IF (_t==_T_INT) {emitcall2rgs("_DIVSIGNED.");
  }ELSE IF (_t==_T_LONG) {emitcall4rgs("_DIVLONG.");
  }ELSE errtype("/",_t);
}

EXPORT PROC cmdshl() //старое сдвинуть столько раз, сколько гласит новое!
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION shl" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {emitcall2rgs("_SHLB.");
  }ELSE IF ( (_t==_T_INT)||(_t==_T_UINT) ) {emitcall2rgs("_SHL.");
  }ELSE IF (_t==_T_LONG) {emitcall4rgs("_SHLLONG.");
  }ELSE errtype("<<",_t);
}

EXPORT PROC cmdshr() //старое сдвинуть столько раз, сколько гласит новое!
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION shr" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {emitcall2rgs("_SHRB.");
  }ELSE IF (_t==_T_UINT) {emitcall2rgs("_SHR.");
  }ELSE IF (_t==_T_INT) {emitcall2rgs("_SHRSIGNED.");
  }ELSE IF (_t==_T_LONG) {emitcall4rgs("_SHRLONG.");
  }ELSE errtype(">>",_t);
}

EXPORT PROC cmdshl1()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";SHL1" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {
    getrnew();
    emitshl1b();
  }ELSE IF ( (_t==_T_INT)||(_t==_T_UINT) ) {
    getrnew();
    emitshl1rg();
  //}ELSE IF (_t==_T_LONG) { //todo
  }ELSE errtype("shl1",_t);
}
/**
EXPORT PROC cmdshr1()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";SHR1" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF ( (_t==_T_BYTE)||(_t==_T_CHAR) ) {emitshr1rgb(getrnew());
  }ELSE IF (_t==_T_INT) {emitshr1signedrg(getrnew());
  }ELSE IF (_t==_T_UINT) {emitshr1rg(getrnew());
  }ELSE errtype("shr1",_t);
}
*/
EXPORT PROC cmdand()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION &" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
    getrnew();
    getrold();
    getandb();
    freernew();
  }ELSE IF (_sz==_SZ_REG) {
    getrnew();
    getrold();
    emitandrg();
    freernew();
  }ELSE /**IF (_sz==_SZ_LONG)*/ {
    getrnew();
    getrold2();
    emitandrg(); //low
    freernew();
    getrnew();
    getrold2();
    emitandrg(); //high
    freernew();
  };//ELSE errtype("&",_t);
}

EXPORT PROC cmdor()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION |" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
    getrnew();
    getrold();
    getorb();
    freernew();
  }ELSE IF (_sz==_SZ_REG) {
    getrnew();
    getrold();
    emitorrg();
    freernew();
  }ELSE /**IF (_sz==_SZ_LONG)*/ {
    getrnew();
    getrold2();
    emitorrg(); //low
    freernew();
    getrnew();
    getrold2();
    emitorrg(); //high
    freernew();
  };//ELSE errtype("|",_t);
}

EXPORT PROC cmdxor()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION ^" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
    getrnew();
    getrold();
    getxorb();
    freernew();
  }ELSE IF (_sz==_SZ_REG) {
    getrnew();
    getrold();
    emitxorrg();
    freernew();
  }ELSE /**IF (_sz==_SZ_LONG)*/ {
    getrnew();
    getrold2();
    emitxorrg(); //low
    freernew();
    getrnew();
    getrold2();
    emitxorrg(); //high
    freernew();
  };//ELSE errtype("^",_t);
}

EXPORT PROC cmdpoke() //новое записываем в старую локацию памяти
{ //_t = тип данных под указателем
#ifdef USE_COMMENTS
;;  cmtstr(";POKE"); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE/**(_t==_T_BYTE)||(_t==_T_CHAR)||(_t==_T_BOOL)*/) {
    getrnew();
    getrold();
    emitpokeb();
    freernew();
    freernew();
  }ELSE IF (_sz==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
    getrnew();
    getrold();
    emitpokerg();
    freernew();
    freernew();
  }ELSE /**IF (_sz==_SZ_LONG)*/ {
    getrnew();
    getrold2(); _rold2 = _rold;
    getrold();
    emitpokelong();
    freernew();
    freernew();
    freernew();
  };//ELSE errtype("poke",_t); //по идее никогда
}

EXPORT PROC cmdpeek() //_t = тип данных под указателем, не const
{
#ifdef USE_COMMENTS
;;  cmtstr( ";PEEK" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE/**(_t==_T_BYTE)||(_t==_T_CHAR)||(_t==_T_BOOL)*/) {
    getrnew();
    emitpeekb();
  }ELSE IF (_sz==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
    getrnew();
    emitpeekrg();
  }ELSE /**IF (_sz==_SZ_LONG)*/ {
    getrfree(); //_rnew
    getrnew();
    getrold();
    emitpeeklong();
  };//ELSE errtype("peek",_t); //по идее никогда
}

EXPORT PROC cmdneg()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";NEG" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF ( (_t==_T_INT)||(_t==_T_UINT) ) {
    getrnew();
    emitnegrg();
  }ELSE errtype("neg",_t);
}

EXPORT PROC cmdinv()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";INV" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
    getrnew();
    emitinvb();
  }ELSE IF (_sz == _SZ_REG) {
    getrnew();
    emitinvrg();
  }ELSE /**IF (_t==_T_LONG)*/ {
    getrnew();
    emitinvrg();
    getrold(); _rnew = _rold;
    emitinvrg();
  };//ELSE errtype("inv",_t);
}

EXPORT PROC cmdinc()
{
#ifdef USE_COMMENTS
;;  cmtstr(";OPERATION ++"); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {
    prefernoregs(); //только [hl]
    _t = _T_POI|_T_BYTE; cmdpushnum();
    IF (_wasconst) pushconst();
    getrnew();
    emitincb_bypoi();
    freernew();
  }ELSE IF (_typesz[_t]==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
    getrfree(); //_rnew
    //emitgetrg(+FALSE);
    emitincrg_byname();
    //emitputrg(+FALSE);
    freernew();
/**  }ELSE IF (_t==_T_LONG) {
    emitinclong();
*/
  }ELSE errtype("inc",_t);
}

EXPORT PROC cmddec()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION --" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {
    prefernoregs(); //только [hl]
    _t = _T_POI|_T_BYTE; cmdpushnum();
    IF (_wasconst) pushconst();
    getrnew();
    emitdecb_bypoi();
    freernew();
  }ELSE IF (_typesz[_t]==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
    getrfree(); //_rnew
    //emitgetrg(+FALSE);
    emitdecrg_byname();
    //emitputrg(+FALSE);
    freernew();
/**  }ELSE IF (_t==_T_LONG) {
    emitdeclong();
*/
  }ELSE errtype("dec",_t);
}

EXPORT PROC cmdincbyaddr()
{
#ifdef USE_COMMENTS
;;  cmtstr(";OPERATION ++byaddr"); endcmt();
#endif
  IF (_wasconst) pushconst();
  getrnew();
  IF (_t==_T_BYTE) {
    emitincb_bypoi(); //[new]
  }ELSE IF (_typesz[_t]==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
    getrfree();
    getrold();
    emitincrg_bypoi(); //[old]
    freernew();
/**  }ELSE IF (_t==_T_LONG) {
    emitinclong();
*/
  }ELSE errtype("incbypoi",_t);
  freernew();
}

EXPORT PROC cmddecbyaddr()
{
#ifdef USE_COMMENTS
;;  cmtstr(";OPERATION --byaddr"); endcmt();
#endif
  IF (_wasconst) pushconst();
  getrnew();
  IF (_t==_T_BYTE) {
    emitdecb_bypoi(); //[new]
  }ELSE IF (_typesz[_t]==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
    getrfree();
    getrold();
    emitdecrg_bypoi(); //[old]
    freernew();
/**  }ELSE IF (_t==_T_LONG) {
    emitdeclong();
*/
  }ELSE errtype("decbypoi",_t);
  freernew();
}

//////////////////////////////////
//сравнения

EXPORT PROC cmdless() //старое меньше нового
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION <" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {
    getrnew();
    getrold();
    emitsubbflags(_rnew, _rold); //old-new
    freernew();
    freernew();
    getrfree(); //_rnew
    emitcytob();
  }ELSE IF (_t==_T_UINT) {
    getrnew();
    getrold();
    emitsubflags(_rnew, _rold); //old-new
    freernew();
    freernew();
    getrfree(); //_rnew
    emitcytob();
  }ELSE IF (_t==_T_INT) {
    getrnew();
    getrold();
    emitsubflags(_rnew, _rold); //old-new
    freernew();
    freernew();
    getrfree(); //_rnew
    emitSxorVtob(); //S xor overflow
  //}ELSE IF (_t==_T_LONG) {
  }ELSE errtype("<",_t);
  _t = _T_BOOL;
}

EXPORT PROC cmdmore() //старое больше нового
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION >" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {
    getrold();
    getrnew();
    emitsubbflags(_rold, _rnew); //new-old
    freernew();
    freernew();
    getrfree(); //_rnew
    emitcytob();
  }ELSE IF (_t==_T_UINT) {
    getrold();
    getrnew();
    emitsubflags(_rold, _rnew); //new-old
    freernew();
    freernew();
    getrfree(); //_rnew
    emitcytob();
  }ELSE IF (_t==_T_INT) {
    getrold();
    getrnew();
    emitsubflags(_rold, _rnew); //new-old
    freernew();
    freernew();
    getrfree(); //_rnew
    emitSxorVtob(); //S xor overflow
  //}ELSE IF (_t==_T_LONG) {
  }ELSE errtype(">",_t);
  _t = _T_BOOL;
}

EXPORT PROC cmdlesseq() //старое <= нового
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION <=" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {
    getrold();
    getrnew();
    emitsubbflags(_rold, _rnew); //new-old
    freernew();
    freernew();
    getrfree(); //_rnew
    emitinvcytob();
  }ELSE IF (_t==_T_UINT) {
    getrold();
    getrnew();
    emitsubflags(_rold, _rnew); //new-old
    freernew();
    freernew();
    getrfree(); //_rnew
    emitinvcytob();
  }ELSE IF (_t==_T_INT) {
    getrold();
    getrnew();
    emitsubflags(_rold, _rnew); //new-old
    freernew();
    freernew();
    getrfree(); //_rnew
    emitinvSxorVtob(); //S xor overflow + инверсия флага результата
  //}ELSE IF (_t==_T_LONG) {
  }ELSE errtype("<=",_t);
  _t = _T_BOOL;
}

EXPORT PROC cmdmoreeq() //старое >= нового
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION >=" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  IF (_t==_T_BYTE) {
    getrnew();
    getrold();
    emitsubbflags(_rnew, _rold); //old-new
    freernew();
    freernew();
    getrfree(); //_rnew
    emitinvcytob();
  }ELSE IF (_t==_T_UINT) {
    getrnew();
    getrold();
    emitsubflags(_rnew, _rold); //old-new
    freernew();
    freernew();
    getrfree(); //_rnew
    emitinvcytob();
  }ELSE IF (_t==_T_INT) {
    getrnew();
    getrold();
    emitsubflags(_rnew, _rold); //old-new
    freernew();
    freernew();
    getrfree(); //_rnew
    emitinvSxorVtob(); //S xor overflow + инверсия флага результата
  //}ELSE IF (_t==_T_LONG) {
  }ELSE errtype(">=",_t);
  _t = _T_BOOL;
}

EXPORT PROC cmdeq()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION ==" ); endcmt();
#endif
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
    IF (_wasconst) {
      getrnew();
      emitsubbzconst(); //new-<const>
      _wasconst = +FALSE;
      freernew();
    }ELSE {
      getrnew();
      getrold();
      emitsubbz(); //old-new
      freernew();
      freernew();
    };
    getrfree(); //_rnew
    emitztob();
  }ELSE {
    IF (_wasconst) pushconst();
    IF (_sz==_SZ_REG) {
      getrnew();
      getrold();
      emitsubz(); //old-new
      freernew();
      freernew();
      getrfree(); //_rnew
      emitztob();
    }ELSE /**IF (_sz==_SZ_LONG)*/ {
      getrold2(); _rold2 = _rold; //oldlow //берём раньше, чтобы получить быстрый регистр
      getrold3(); _rold3 = _rold; //oldhigh из стека //берём раньше, чтобы получить быстрый регистр
      getrnew(); //newlow
      getrold(); //newhigh
      emitsublongz(); //old2-new, old3-old
      freernew();
      freernew();
      freernew();
      freernew();
      getrfree(); //_rnew
      emitztob();
    };//ELSE errtype("==",_t); //по идее никогда
  };
  _t = _T_BOOL;
}

EXPORT PROC cmdnoteq()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";OPERATION !=" ); endcmt();
#endif
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
    IF (_wasconst) {
      getrnew();
      emitsubbzconst(); //new-<const>
      _wasconst = +FALSE;
      freernew();
    }ELSE {
      getrnew();
      getrold();
      emitsubbz(); //old-new
      freernew();
      freernew();
    };
    getrfree(); //_rnew
    emitinvztob();
  }ELSE {
    IF (_wasconst) pushconst();
    IF (_sz==_SZ_REG) {
      getrnew();
      getrold();
      emitsubz(); //old-new
      freernew();
      freernew();
      getrfree(); //_rnew
      emitinvztob();
    }ELSE /**IF (_sz==_SZ_LONG)*/ {
      getrold2(); _rold2 = _rold; //oldlow //берём раньше, чтобы получить быстрый регистр
      getrold3(); _rold3 = _rold; //oldhigh из стека //берём раньше, чтобы получить быстрый регистр
      getrnew(); //newlow
      getrold(); //newhigh
      emitsublongz(); //old2-new, old3-old
      freernew();
      freernew();
      freernew();
      freernew();
      getrfree(); //_rnew
      emitinvztob();
    };//ELSE errtype("!=",_t); //по идее никогда
  };
  _t = _T_BOOL;
}

///////////////////////////////////
//генерация вызовов и переходов

EXPORT PROC cmdlabel()
{
  //IF (_wasconst) pushconst(); //вычисление закончено
  //на этот момент для предсказуемости все регистры должны быть свободны
  //(сейчас это получится автоматически, но без storergs и с резервированием регистров надо освобождать вручную)
  getnothing();
  emitfunclabel(_joined);
}

EXPORT PROC cmdjpval()
{
  //IF (_wasconst) pushconst();
  getmainrg();
  freernew();
  emitjpmainrg(); //"jp (hl)" //делает getnothing
}

EXPORT PROC cmdcallval()
{
  IF (_wasconst) pushconst();
  getmainrg();
  freernew();
  emitcallmainrg(); //"call (hl)" //делает getnothing //todo вариант с константой
}

EXPORT PROC cmdjp()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";JUMP " ); cmtstr(_joined); endcmt();
#endif
  //IF (_wasconst) pushconst();
  emitjp();
}

EXPORT PROC cmdjpiffalse()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";JUMP IF FALSE " ); cmtstr(_joined); endcmt();
#endif
  IF (_wasconst) pushconst(); //может быть не присвоено в IF (+TRUE)
  getrnew();
  emitbtoz();
  freernew();
  emitjpiffalse();
}

EXPORT PROC cmdcall()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";CALL " ); cmtstr(_callee); endcmt();
#endif
  //IF (_wasconst) pushconst();
  unproxy();
  getnothing(); //сохранить регистры в стеке в стандартном порядке и освободить регистры
  emitcallproc();
  IF (_t!=_T_PROC) {
    _sz = _typesz[_t];
    IF (_sz==_SZ_BYTE/**(_t==_T_BYTE)||(_t==_T_CHAR)||(_t==_T_BOOL)*/) {
      setmainb(); //результат в RMAIN
    }ELSE IF (_sz==_SZ_REG/**(_t==_T_INT)||(_t==_T_UINT)||(_t>=_T_POI)*/) {
      setmainrg(); //результат в RMAIN
    }ELSE IF (_sz==_SZ_LONG/**_t==_T_LONG*/) {
      setmain2rgs(); //результат в RMAIN,RMAIN2
    }ELSE errtype("call",_t); //по идее никогда
  };
}

EXPORT PROC cmdfunc()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";FUNC" ); endcmt();
#endif
  //IF (_wasconst) pushconst();
  _funcstkdepth = +(INT)0;
  emitfunchead();
}

EXPORT PROC cmdstorergs() //после сохранения локальной переменной рекурсивной процедуры
{
#ifdef USE_COMMENTS
;;  cmtstr(";STOREREGS"); endcmt();
#endif
  //IF (_wasconst) pushconst();
  getnothing(); //чтобы использовать hl //todo убрать (когда будет резервирование регистров) - тогда локальные параметры будут не в стеке, а в регистрах
}

EXPORT PROC cmdpushpar() //для рекурсивных процедур (сохранение параметров внутри или снаружи)
{
#ifdef USE_COMMENTS
;;  cmtstr(";PUSHPAR "); cmtstr(_joined); endcmt();
#endif
  //IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
    getnothing(); //чтобы использовать A //todo убрать (когда будет резервирование регистров) - тогда локальные параметры будут не в стеке, а в регистрах
    getrfree(); //_rnew
    emitgetb(); //cmdpushvarb(s); //невыгодно, хотя заменяет всё вышенаписанное
  }ELSE IF (_sz==_SZ_REG) {
    getnothing(); //чтобы использовать hl //todo убрать (когда будет резервирование регистров) - тогда локальные параметры будут не в стеке, а в регистрах
    getrfree(); //_rnew
    emitgetrg(+FALSE);
  }ELSE /**IF (_sz==_SZ_LONG)*/ {
    getnothing(); //чтобы использовать hl //todo убрать (когда будет резервирование регистров) - тогда локальные параметры будут не в стеке, а в регистрах
    getrfree(); //_rnew
    emitgetrg(+TRUE); //high
    getnothing(); //чтобы использовать hl //todo убрать (когда будет резервирование регистров) - тогда локальные параметры будут не в стеке, а в регистрах
    getrfree(); //_rnew
    emitgetrg(+FALSE); //low
  };//ELSE errtype("pushpar",_t); //по идее никогда
}

EXPORT PROC cmdpoppar() //для рекурсивных процедур (восстановление параметров внутри или снаружи)
{ //может быть занято 1-2 регистра (результат)
#ifdef USE_COMMENTS
;;  cmtstr(";POPPAR"); endcmt();
#endif
  //IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
    getrfree(); //_rnew
    emitpoprg(_rnew);
    emitputb();
    freernew();
  }ELSE IF (_sz==_SZ_REG) {
    getrfree(); //_rnew
    emitpoprg(_rnew);
    emitputrg(+FALSE); //low
    freernew();
  }ELSE /**IF (_sz==_SZ_LONG)*/ {
    getrfree(); //_rnew
    emitpoprg(_rnew);
    emitputrg(+FALSE); //low
    freernew();
    getrfree(); //_rnew
    emitpoprg(_rnew);
    emitputrg(+TRUE); //high
    freernew();
  };//ELSE errtype("poppar",_t); //по идее никогда
} //теперь в регистрах может быть пусто, всё в стеке (перед ret надо забрать результат из стека)

EXPORT PROC cmdresult()
{
#ifdef USE_COMMENTS
;;  cmtstr( ";RESULT" ); endcmt();
#endif
  IF (_wasconst) pushconst();
  _sz = _typesz[_t];
  IF (_sz==_SZ_BYTE) {
  }ELSE IF (_sz==_SZ_REG) {
    getmainrg(); //todo резервировать с перестановкой регистров
  }ELSE /**IF (_sz==_SZ_LONG)*/ {
    getmain2rgs(); //todo резервировать с перестановкой регистров
  };//ELSE errtype("result",_t); //по идее никогда
}

EXPORT PROC cmdret(BOOL isfunc)
{
#ifdef USE_COMMENTS
;;  cmtstr( ";ENDFUNC" ); endcmt();
#endif
  //IF (_wasconst) pushconst();
  IF ( isfunc ) {
    _sz = _typesz[_t];
    IF (_sz==_SZ_BYTE) {
      getrnew();
      proxy(_rnew);
    }ELSE IF (_sz==_SZ_REG) {
      getmainrg();
    }ELSE /**IF (_sz==_SZ_LONG)*/ {
      getmain2rgs();
    };//ELSE errtype("endfunc",_t); //по идее никогда
  };
  emitret();
  IF (+(UINT)_funcstkdepth!=0) { errstr("funcstkdepth=" ); erruint(+(UINT)_funcstkdepth); enderr(); };
  initrgs();
}

EXPORT PROC initcmd()
{
  _const  = (PCHAR)_sc;
  //_wastword  = (PCHAR)_sw;
  _wasconst = +FALSE;
}
