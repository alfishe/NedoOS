//// imported
#ifdef TARGET_THUMB
#include "sizesarm.h"
#else
#include "sizesz80.h"
#endif

//#ifdef DOUBLES
//CONST BYTE _NRGS; //число регистров

  //приоритеты регистров:
CONST BYTE _RMAIN; //регистр результата и 1-го параметра стандартных функций
CONST BYTE _RMAIN2; //регистр второго слова результата и 2-го параметра стандартных функций
CONST BYTE _RMAIN3;
CONST BYTE _RMAIN4;
//#endif

PROC emitpoprg FORWARD(BYTE rnew);
PROC emitpushrg FORWARD(BYTE rnew);
PROC emitmovrg FORWARD(BYTE rsrc, BYTE rdest); //не заказывает и не освобождает (см. moverg)

//#ifdef USE_COMMENTS
//;;PROC cmt FORWARD(CHAR c);
//;;PROC cmtstr FORWARD(PCHAR s);
//;;PROC cmtuint FORWARD(UINT i);
//;;PROC endcmt FORWARD();
//#endif
#ifdef USE_HINTS
;;PROC hint FORWARD(CHAR c);
;;PROC hintstr FORWARD(PCHAR s);
;;PROC hintuint FORWARD(UINT i);
;;PROC endhint FORWARD();
#endif
PROC err FORWARD(CHAR c);
PROC errstr FORWARD(PCHAR s);
PROC erruint FORWARD(UINT i);
PROC enderr FORWARD();

////
VAR BYTE _usedrg[16]/**_NRGS*/;
VAR BYTE _usedrgs;
VAR BOOL _usedr1; //todo массив
VAR BOOL _usedr2;
VAR BOOL _usedr3;
VAR BOOL _usedr4;

VAR BYTE _rnew;
VAR BYTE _rold;
VAR BYTE _rold2;
VAR BYTE _rold3;

#ifdef USE_HINTS
;;PROC hintrg(PCHAR text, BYTE data) {
;;  hintstr("//"); hintstr(text); hintuint(+(UINT)data);
;;}

;;PROC hintrgstate() {
;;  hintrg("_fastrg4used=", +(BYTE)_usedr4); //bool!
;;  hintrg("_fastrg3used=", +(BYTE)_usedr3); //bool!
;;  hintrg("_fastrg2used=", +(BYTE)_usedr2); //bool!
;;  hintrg("_fastrgused=" , +(BYTE)_usedr1); //bool!
;;  endhint();
;;  hintrg("[0]=", _usedrg[0]); //#!
;;  hintrg("[1]=", _usedrg[1]); //#!
;;  hintrg("[2]=", _usedrg[2]); //#!
;;  hintrg("[3]=", _usedrg[3]); //#!
;;  endhint();
;;  hintrg("_usedrgs=", _usedrgs); //byte!
;;  endhint();
;;}
#endif

//////////////////////////////////////////////////////////////////////////////////////////
//rg pool
//(в регистрах может быть пусто, всё в стеке)
//процедуры, недоступные из commands

PROC nouserg FORWARD(BYTE rnew);  //только сбрасывает флаг использования регистра и двигает счётчик!
FUNC BYTE userg FORWARD(BYTE rnew);  //только устанавливает флаг использования регистра и двигает счётчик!
PROC popgetrg FORWARD(BYTE rnew);  //userg + добавление в очередь _usedrg снизу + pop

//////////////////////////////////////////
//без машинного кода

//переместить данные в заданный регистр rdest
PROC moverg(BYTE rsrcindex, BYTE rdest) //заодно заказывает и освобождает регистры
{
VAR BYTE rsrc;
  rsrc = _usedrg[rsrcindex];
  emitmovrg(rsrc,rdest); //todo или сравнивать rsrc!=rdest тут?
  _usedrg[rsrcindex] = rdest; //там было rsrc
  nouserg( rsrc ); //только сбрасывает флаг использования регистра и двигает счётчик!
  userg( rdest ); //только устанавливает флаг использования регистра и двигает счётчик!
}

PROC pushtailrg()
{
VAR BYTE rnew;
VAR BYTE i;
#ifdef USE_HINTS
;;  hintstr( "//pusholdestrg" ); endhint();
#endif
;;  IF (_usedrgs<0x01) { errstr( "pusholdestrg _usedrgs=" ); erruint(+(UINT)_usedrgs); enderr();
;;  }ELSE
  {
    rnew = _usedrg[ 0 ];
    emitpushrg( rnew );
    i = 0x01;
    WHILE (i < _usedrgs/**_NRGS*/) { //счётчик ещё не сдвинут
      _usedrg[i-0x01] = _usedrg[i];
      INC i;
    };
    nouserg( rnew ); //только сбрасывает флаг использования регистра и двигает счётчик!
  };
#ifdef USE_HINTS
;;  hintrgstate();
#endif
}

FUNC BYTE findrfree() //найти свободный (как можно более быстрый) регистр и вернуть его код
{
VAR BYTE result;
  IF (_usedrgs==_NRGS) pushtailrg();
  IF       (!_usedr1) {result = 0x01;
  }ELSE IF (!_usedr2) {result = 0x02;
  }ELSE IF (!_usedr3) {result = 0x03;
  }ELSE result = 0x04;
  RETURN result;
}

PROC nouserg(BYTE rnew) //только сбрасывает флаг использования регистра и двигает счётчик!
{
;;  IF (_usedrgs==0x00) { errstr( "nouserg _usedrgs=" ); erruint(+(UINT)_usedrgs); enderr();
;;  }ELSE
  {
    IF       (rnew==0x01) {_usedr1 = +FALSE;
    }ELSE IF (rnew==0x02) {_usedr2 = +FALSE;
    }ELSE IF (rnew==0x03) {_usedr3 = +FALSE;
    }ELSE _usedr4 = +FALSE;
    DEC _usedrgs;
  };
}

FUNC BYTE userg(BYTE rnew) //только устанавливает флаг использования регистра и двигает счётчик!
{
;;  IF (_usedrgs>=_NRGS) { errstr( "userg _usedrgs=" ); erruint(+(UINT)_usedrgs); enderr();
;;  }ELSE
  {
    IF       (rnew==0x01) {_usedr1 = +TRUE;
    }ELSE IF (rnew==0x02) {_usedr2 = +TRUE;
    }ELSE IF (rnew==0x03) {_usedr3 = +TRUE;
    }ELSE _usedr4 = +FALSE;
    INC _usedrgs;
  };
  RETURN rnew;
}

FUNC BYTE getrg(BYTE rnew) //userg + добавление в очередь _usedrg
{
#ifdef USE_HINTS
;;  hintrg("getrg ",rnew); endhint();
;;  hintrgstate();
#endif
  _usedrg[_usedrgs] = rnew;
  userg( rnew ); //только устанавливает флаг использования регистра и двигает счётчик!
#ifdef USE_HINTS
;;  hintrgstate();
#endif
  RETURN rnew;
}

PROC popgetrg(BYTE rnew) //userg + добавление в очередь _usedrg снизу + pop
{
VAR BYTE i;
#ifdef USE_HINTS
;;  hintstr( "//getoldestrg" ); endhint();
#endif
  i = _usedrgs; //счётчик ещё не сдвинут //_NRGS-0x01;
  WHILE (i>0x00) {
    _usedrg[i] =_usedrg[i-0x01];
    DEC i;
  };
  _usedrg[ 0 ] =rnew;
  userg( rnew ); //только устанавливает флаг использования регистра и двигает счётчик!
#ifdef USE_HINTS
;;  hintrgstate();
#endif
  emitpoprg(rnew);
}

//поменять местами два регистра на вершине "стека" (чисто логически)
PROC swaptop()
{
VAR BYTE rtmp;
  IF ( _usedrgs==0x00 ) popgetrg(0x02);
  IF ( _usedrgs==0x01 ) popgetrg( findrfree() );
  rtmp = _usedrg[_usedrgs-0x02]; //old
  _usedrg[_usedrgs-0x02] = _usedrg[_usedrgs-0x01]; //new => old
  _usedrg[_usedrgs-0x01] = rtmp; //=> new
}

////////////////////////////////////////////////////////////////////////////////
//недоступны из компилятора, доступны из commands
//без машинного кода
//не пишут в ...used (кроме initrgs)

//rg pool

PROC rgs_initrgs()
{
  _usedr1 = +FALSE;
  _usedr2 = +FALSE;
  _usedr3 = +FALSE;
  _usedr4 = +FALSE;
  _usedrgs = 0x00;
}

PROC getrnew() //старается брать new=FASTRG
//здесь нельзя делать getnothing (из-за bytetoint, inttobyte)
{
#ifdef USE_HINTS
;;  hintstr( "//getrnew" ); endhint();
#endif
  IF ( _usedrgs==0x00 ) popgetrg(0x01);
  _rnew = _usedrg[_usedrgs-0x01];
}

PROC getrold() //старается брать old=FASTRG (выгодно вызывать до getrnew для +,-)
{
#ifdef USE_HINTS
;;  hintstr( "//getrold" ); endhint();
#endif
  IF ( _usedrgs==0x00 ) popgetrg(0x02);
  IF ( _usedrgs==0x01 ) popgetrg( findrfree() );
  _rold = _usedrg[_usedrgs-0x02];
}

PROC getrold2() //старается брать old2=FASTRG (выгодно вызывать до getrnew для +,-)
{
#ifdef USE_HINTS
;;  hintstr( "//getrold2" ); endhint();
#endif
  IF ( _usedrgs==0x00 ) popgetrg(0x03);
  IF ( _usedrgs==0x01 ) { //пытаемся взять old=_RFAST2
    IF ( _usedrg[0]!=0x02 ) {popgetrg(0x02);
    }ELSE popgetrg( findrfree() );
  };
  IF ( _usedrgs==0x02 ) popgetrg( findrfree() );
  _rold = _usedrg[_usedrgs-0x03];
}

PROC getrold3()
{
#ifdef USE_HINTS
;;  hintstr( "//getrold3" ); endhint();
#endif
  IF ( _usedrgs==0x00 ) popgetrg(0x03);
  IF ( _usedrgs==0x01 ) popgetrg( findrfree() );
  IF ( _usedrgs==0x02 ) popgetrg( findrfree() );
  IF ( _usedrgs==0x03 ) popgetrg( findrfree() );
  _rold = _usedrg[_usedrgs-0x04];
}

PROC freernew() //освободить регистр с вершины стека
{
#ifdef USE_HINTS
;;  hintstr( "//freernew" ); endhint();
;;  hintrgstate();
#endif
  getrnew(); //а то вдруг нет в регистрах
  //очередь usedrgs можно не трогать, просто сдвинуть голову очереди (счётчик)
  nouserg( _usedrg[_usedrgs-0x01] ); //только сбрасывает флаг использования регистра и двигает счётчик!
#ifdef USE_HINTS
;;  hintrgstate();
;;  hintstr( "//end freernew" ); endhint();
#endif
}

//
//следующие процедуры не обращаются явно к ...used
//
PROC getnothing() //сохранить регистры и байты в стеке и освободить
{
  WHILE (_usedrgs>0x00) pushtailrg();
}

PROC getrfree() //занять свободный регистр и вернуть его код
//здесь нельзя делать getnothing (из-за bytetoint, inttobyte)
{
#ifdef USE_HINTS
;;  hintstr( "//getrfree" ); endhint();
#endif
  _rnew = getrg(findrfree());
}

PROC getmainrg() //взять RMAIN=new и освободить остальные регистры (todo если всё в регистрах, то вставить RMAIN в oldestrg)
{
#ifdef USE_HINTS
;;  hintstr( "//getmainrg" ); endhint();
#endif
  IF ( _usedrgs==0x00 ) popgetrg( _RMAIN ); //emitpopoldestrg(RMAIN);
  WHILE ( _usedrgs>0x01 ) pushtailrg();
  //теперь занят ровно 1 регистр
  moverg( (0x00), _RMAIN ); //todo оптимизировать через ex de,hl
#ifdef USE_HINTS
;;  hintstr( "//end getmainrg" ); endhint();
#endif
}

PROC getmain2rgs() //взять RMAIN=old, RMAIN2=new и освободить остальные регистры (todo если всё в регистрах, то вставить RMAIN, RMAIN2 в oldestrg)
{
#ifdef USE_HINTS
;;  hintstr( "//getmain2rgs" ); endhint();
#endif
  IF ( _usedrgs==0x00 ) popgetrg( _RMAIN2 );
  IF ( _usedrgs==0x01 ) {
    moverg( (0x00), _RMAIN2 ); //todo оптимизировать через ex de,hl
    popgetrg( _RMAIN );
  };
  WHILE ( _usedrgs>0x02 ) pushtailrg();
  //теперь занято ровно 2 регистра
  //RMAIN, XXX: moverg((1),RMAIN2);
  IF (_usedrg[0]==_RMAIN) {moverg( (0x01), _RMAIN2 );
  }ELSE IF (_usedrg[1]==_RMAIN ) {
    //RMAIN2, RMAIN: pusholdestrg;moverg((0),RMAIN2);popoldestrg(RMAIN);
    IF (_usedrg[0]==_RMAIN2) {
      pushtailrg();
      moverg( (0x00), _RMAIN2 ); //todo оптимизировать через ex de,hl
      popgetrg( _RMAIN );
    }ELSE { //XXX, RMAIN: moverg((1),RMAIN2);moverg((0),RMAIN);
     moverg( (0x01), _RMAIN2 ); //todo оптимизировать через ex de,hl //moverg((0),RMAIN) см. ниже
    };
  };
  //XXX, YYY: moverg((0),RMAIN);moverg((1),RMAIN2);
  moverg( (0x00), _RMAIN ); //todo оптимизировать через ex de,hl
  moverg( (0x01), _RMAIN2 ); //todo оптимизировать через ex de,hl
#ifdef USE_HINTS
;;  hintstr( "//end getmain2rgs" ); endhint();
#endif
}
/**
PROC getmain3rgs()
{
#ifdef USE_HINTS
;;  hintstr( "//getmain3rgs" ); endhint();
#endif
  getmain2rgs();
  getrold2();
#ifdef USE_HINTS
;;  hintstr( "//end getmain3rgs" ); endhint();
#endif
}
*/
PROC getmain4rgs()
{
#ifdef USE_HINTS
;;  hintstr( "//getmain4rgs" ); endhint();
#endif
  IF ( (_usedrgs!=0x04)
    || (_usedrg[0]!=_RMAIN)
    || (_usedrg[1]!=_RMAIN2)
    || (_usedrg[2]!=_RMAIN3)
    || (_usedrg[3]!=_RMAIN4)
     ) {
    getnothing(); //todo по одному, с проверкой на соответствие
    popgetrg(_RMAIN4);
    popgetrg(_RMAIN3);
    popgetrg(_RMAIN2);
    popgetrg(_RMAIN);
  };
#ifdef USE_HINTS
;;  hintstr( "//end getmain4rgs" ); endhint();
#endif
}

PROC setmainrg() //установить признаки, как будто мы получили результат в регистре
{ //сейчас все регистры считаются свободными
  getrg( _RMAIN );
}

PROC setmain2rgs() //установить признаки, как будто мы получили результат в регистрах
{ //сейчас все регистры считаются свободными
  getrg( _RMAIN );
  getrg( _RMAIN2 );
}

