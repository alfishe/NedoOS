//// imported
#include "../_sdk/io.h"
#include "../_sdk/str.h"
////
EXPORT VAR BOOL _cmts;
EXPORT VAR UINT _curlnbeg; //номер строки на момент начала токена

EXPORT VAR PBYTE _ferr;

EXPORT VAR PBYTE _fvar;

EXPORT VAR BOOL _hints;
EXPORT VAR BOOL _errs;

VAR PBYTE _curfile;

PROC endhint FORWARD();

EXPORT VAR CHAR _m_fn[_STRLEN];
EXPORT VAR PCHAR _fn;
EXPORT VAR UINT _lenfn;

EXPORT VAR BOOL _wasdig;
EXPORT VAR CHAR _nbuf[6];
EXPORT VAR UINT _lennbuf;
VAR UINT _num;

EXPORT PROC emitdig(UINT d)
{
VAR BYTE dig;
  dig = +(BYTE)'0';
  WHILE (_num >= d) {
    _num = _num - d;
    INC dig;
    _wasdig = +TRUE;
  };
  IF (_wasdig) {
    //_lennbuf = stradd(_nbuf, _lennbuf, +(CHAR)dig);
    _nbuf[_lennbuf] = +(CHAR)dig;
    INC _lennbuf;
  };
}

EXPORT PROC emitn(UINT i)
{
  _num = i;
  _lennbuf = 0;
  _wasdig = +TRUE;
  IF (i != 0) {
    _wasdig = +FALSE;
    emitdig(10000);
    emitdig(1000);
    emitdig(100);
    emitdig(10);
  };
  emitdig(1);
  _nbuf[_lennbuf] = '\0'; //strclose(_nbuf, _lennbuf);
}

EXPORT PROC emituint(UINT i, PBYTE f)
{
  emitn(i);
  fputs(_nbuf, f);
}

/////////////////////////////////////
//процедуры низкого уровня, вызываемые кодогенератором

EXPORT PROC asmc(CHAR c)
{
  writefout(+(BYTE)c);
}

EXPORT PROC asmstr(PCHAR s)
{
  fputs(s, _fout);
}

EXPORT PROC asmuint(UINT i)
{
  emituint(i, _fout);
}

EXPORT PROC endasm()
{
  writefout(+(BYTE)'\n');
}

/////////////////////////////////////
//процедуры низкого уровня, вызываемые компилятором и кодогенератором

#ifdef USE_COMMENTS
;;EXPORT PROC cmt(CHAR c) {
;;  IF (_cmts) writefout(+(BYTE)c);
;;}

;;EXPORT PROC cmtstr(PCHAR s) {
;;  IF (_cmts) fputs(s, _fout);
;;}

;;EXPORT PROC cmtuint(UINT i) {
;;  IF (_cmts) emituint(i, _fout);
;;}

;;EXPORT PROC endcmt() {
;;  IF (_cmts) {
;;    fputs(" ;Line=", _fout);
;;    emituint(_curlnbeg, _fout);
;;    writefout(+(BYTE)'\n');
;;  };
;;}
#endif //USE_COMMENTS

#ifdef USE_HINTS
;;EXPORT PROC hint(CHAR c) {
;;  IF (_hints) writefout(+(BYTE)c);
;;}

;;EXPORT PROC hintstr(PCHAR s) {
;;  IF (_hints) fputs(s, _fout);
;;}

;;EXPORT PROC hintuint(UINT i) {
;;  IF (_hints) emituint(i, _fout);
;;}

;;EXPORT PROC endhint() {
;;  IF (_hints) {
;;    fputs(" ;Line=", _fout);
;;    emituint(_curlnbeg, _fout);
;;    writefout(+(BYTE)'\n');
;;  };
;;}

;;EXPORT PROC hinttype(PCHAR msg, BYTE t) {
;;  hintstr("//"); hintstr(msg); hintstr(" type="); hintuint(+(UINT)t); endhint();
;;}
#endif //USE_HINTS

EXPORT PROC err(CHAR c)
{
  IF (_errs) writebyte(_ferr, +(BYTE)c);
}

EXPORT PROC errstr(PCHAR s)
{
  IF (_errs) fputs(s, _ferr);
}

EXPORT PROC erruint(UINT i)
{
  IF (_errs) emituint(i, _ferr);
}

EXPORT PROC enderr()
{
  IF (_errs) {
    writebyte(_ferr, +(BYTE)';'); fputs(_fn, _ferr);
    fputs(" line=", _ferr); emituint(_curlnbeg, _ferr);
    writebyte(_ferr, +(BYTE)'\n');
  };
}

EXPORT PROC varc(CHAR c)
{
  writebyte(_fvar, +(BYTE)c);
}

EXPORT PROC varstr(PCHAR s)
{
  fputs(s, _fvar);
}

EXPORT PROC varuint(UINT i)
{
  emituint(i, _fvar);
}

EXPORT PROC endvar()
{
  writebyte(_fvar, +(BYTE)'\n');
}

