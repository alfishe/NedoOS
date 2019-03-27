//токенизатор не знает коды команд
//токенизатор не подглядывает вперёд и не отматывает назад
//_asmwaseol генерируется в asmrdword_tokspc(), а eol выводится после команды

//// imported
#include "../_sdk/str.h"
#include "../_sdk/io.h"

CONST PUINT LED_DSETTX;
CONST PUINT LED_DCLRTX;

VAR UINT _curlnbeg; //номер строки на момент начала токена //для read, emit
VAR BOOL _cmts; //для read, emit

CONST BOOL _isalphanum[256];

EXTERN PCHAR _tword; //текущее слово
EXTERN UINT _lentword;
//EXTERN CHAR _s0[_STRLEN]; //текущее слово

EXTERN BOOL _waseof;
EXTERN PBYTE _fin;
EXTERN PBYTE _fout;
FUNC BYTE readfin FORWARD();

EXTERN UINT _curline; //текущий номер строки
EXTERN UINT _waseols; //число EOL с прошлого раза
EXTERN UINT _spcsize; //число пробелов после прочитанной команды
EXTERN CHAR _cnext;

FUNC UINT stradd FORWARD(PCHAR s, UINT len, CHAR c);
FUNC BOOL strcplow FORWARD(PCHAR s1, PCHAR s2);

PROC rdchcmt FORWARD();
PROC rdch FORWARD();
PROC rdquotes FORWARD(CHAR eol);
PROC initrd FORWARD();

CONST BYTE _ASMMAXSPC;

PROC tokpre FORWARD(); //заполнить таблицу меток

////
VAR CHAR _c1small;
VAR CHAR _c2small;
VAR BOOL _asmwaseof;
VAR UINT _asmwaseols; //число EOL с прошлого раза
VAR UINT _asmspcsize;

VAR CHAR _stokfn[_STRLEN]; //текущее слово
VAR PCHAR _tokfn; //текущее слово
VAR UINT _lentokfn;

VAR BYTE _temppar;

PROC migalka(PCHAR fn)
{
VAR UINT i;
  _tokfn = (PCHAR)_stokfn;
  _fin = nfopen(fn, "rb");
  IF (_fin != (PBYTE)0) {
    _waseof = +FALSE;
    _curline = 1;
    initrd();

    _lentokfn = 0;
    i = 0;
    WHILE (fn[_lentokfn] != '\0') {
      _tokfn[_lentokfn] = fn[_lentokfn];
      IF (fn[_lentokfn] == '.') i = _lentokfn;
      INC _lentokfn;
    };
    //_lentokfn = strjoineol(_tokfn, 0, fn, '.'); //terminator is not copied
    //_lentokfn = stradd(_tokfn, _lentokfn, '.');
    _lentokfn = i+1; //after last dot
    _lentokfn = stradd(_tokfn, _lentokfn, (CHAR)((BYTE)fn[_lentokfn]&0xdf));
    _lentokfn = stradd(_tokfn, _lentokfn, '_');
    _tokfn[_lentokfn] = '\0';
    _fout = openwrite(_tokfn);

    loop: //WHILE (!_waseof) { //todo или endasm ('}')
      _cnext = (CHAR)readfin();
      IF (_waseof) goto quit;
      writebyte(_fout, (BYTE)_cnext);
    goto loop; //};
    quit:
    
    fclose(_fout); //closefout();

    fclose(_fin); //closefin();
    
    led:
      //POKE *(PUINT)(LED_DSETTX) = 1<<7;
      POKE *(PUINT)(LED_DRXTX) = 1<<7;
      //POKE *(PUINT)(LED_DCLRTX) = 1<<7;
      POKE *(PUINT)(LED_DRXTX) = 0<<7;
    goto led;
  };
}
