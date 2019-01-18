EXTERN BOOL _errs;
EXTERN PBYTE _fvar;

EXTERN PCHAR _fn;
EXTERN UINT _lenfn;
EXTERN CHAR _m_fn[_STRLEN];

PROC varc FORWARD(CHAR c);
PROC varstr FORWARD(PCHAR s);
PROC varuint FORWARD(UINT i);
PROC endvar FORWARD();

EXTERN BOOL _wasdig;
EXTERN CHAR _nbuf[6];
EXTERN UINT _lennbuf;
EXTERN UINT _num;

PROC emitn FORWARD(UINT i);
PROC emituint FORWARD(UINT i, PBYTE f);
PROC asmc FORWARD(CHAR c);
PROC asmstr FORWARD(PCHAR s);
PROC asmuint FORWARD(UINT i);
PROC endasm FORWARD();
#ifdef USE_COMMENTS
;;PROC cmt FORWARD(CHAR c);
;;PROC cmtstr FORWARD(PCHAR s);
;;PROC cmtuint FORWARD(UINT i);
;;PROC endcmt FORWARD();
#endif
#ifdef USE_HINTS
;;PROC hint FORWARD(CHAR c);
;;PROC hintstr FORWARD(PCHAR s);
;;PROC hintuint FORWARD(UINT i);
;;PROC endhint FORWARD();
;;PROC hinttype FORWARD(PCHAR msg, BYTE t);
#endif
PROC err FORWARD(CHAR c);
PROC errstr FORWARD(PCHAR s);
PROC erruint FORWARD(UINT i);
PROC enderr FORWARD();

