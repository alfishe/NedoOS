//// машиннозависимые процедуры и объ€влени€

//регистр по маске 0x3f приводит ix/iy к hl
CONST BYTE _ASMRBIXADD = 0x40;
CONST BYTE _ASMRBCODE_B = 0x00;
CONST BYTE _ASMRBCODE_C = 0x08;
CONST BYTE _ASMRBCODE_D = 0x10;
CONST BYTE _ASMRBCODE_E = 0x18;
CONST BYTE _ASMRBCODE_H = 0x20;
CONST BYTE _ASMRBCODE_L = 0x28;
CONST BYTE _ASMRBCODE_A = 0x38;
CONST BYTE _ASMRBCODE_HX = 0x60;
CONST BYTE _ASMRBCODE_LX = 0x68;
CONST BYTE _ASMRBCODE_HY = 0xa0;
CONST BYTE _ASMRBCODE_LY = 0xa8;
CONST BYTE _ASMRBCODE_I = 0x00;
CONST BYTE _ASMRBCODE_R = 0x08;

CONST BYTE _ASMRPIXADD = 0x40;
CONST BYTE _ASMRPCODE_BC = 0x00;
CONST BYTE _ASMRPCODE_DE = 0x10;
CONST BYTE _ASMRPCODE_HL = 0x20;
CONST BYTE _ASMRPCODE_SP = 0x30;
CONST BYTE _ASMRPCODE_AF = 0x30;
CONST BYTE _ASMRPCODE_IX = 0x60;
CONST BYTE _ASMRPCODE_IY = 0xa0;

//CONST UINT _BASEADDR = 0x6000;
//VAR UINT _baseaddr;

PROC asmbytepopvalue()
{
  DEC _nvalues;
  IF (_asms) {
    ;;writefout((BYTE)_value[_nvalues]/**+(BYTE)asmpopvalue()*/); //compatible version
    /*writefout(*(PBYTE)&_value[_nvalues]);*/ //fast version (little endian)
  };
  INC _curaddr;
}

PROC asmwordpopvalue() //разна€ разр€дность UINT/DW
{
VAR UINT uinttempvalue;
  DEC _nvalues;
  IF (_asms) {
    //пишем данные релокации при ненулевом _isaddr!
    IF (_isaddr!=0x00) {
      uinttempvalue = _curaddr+_curshift-_curbegin; //_curaddr+_curshift-_BASEADDR;
      fwrite((PBYTE)&uinttempvalue, 2, 1, _forg);
    }; //
    ;;uinttempvalue = +(UINT)_value[_nvalues]; //+(UINT)asmpopvalue()
    ;;writefout(+(BYTE)uinttempvalue); //compatible version (не _SIZEOF_UINT, т.к. тут надо размер дл€ таргета!)
    ;;writefout(+(BYTE)(uinttempvalue>>8)); //compatible version (не _SIZEOF_UINT, т.к. тут надо размер дл€ таргета!)
    /*fwrite((PBYTE)&_value[_nvalues], 2, 1, _fout);*/ //fast version (little endian) (не _SIZEOF_UINT, т.к. тут надо размер дл€ таргета!)
  };
  _curaddr = _curaddr + 2; //не _SIZEOF_UINT, т.к. тут надо размер дл€ таргета!
}

PROC asmlong(LONG value) //разна€ разр€дность LONG/DL
{
  ;;asmbyte(+(BYTE)value); //compatible version
  ;;asmbyte(+(BYTE)(+(UINT)value>>8)); //compatible version
  ;;asmbyte(+(BYTE)(value>>16L)); //compatible version
  ;;asmbyte(+(BYTE)(value>>24L)); //compatible version
  /*fwrite(+(PBYTE)&value, 4, 1, _fout);*/ //fast version (little endian) (не _SIZEOF_LONG, т.к. тут надо размер дл€ таргета!)
  /*_curaddr = _curaddr + 4;*/ //fast version (little endian) (не _SIZEOF_LONG, т.к. тут надо размер дл€ таргета!)
}

PROC asmorgword(LONG addr) //разна€ разр€дность POINTER
{
//todo ORG
//  IF (_asms) {
//    ;;writebyte(_forg, +(BYTE)addr); //compatible version
//    ;;writebyte(_forg, +(BYTE)(+(UINT)addr>>8)); //compatible version
//    /*fwrite(+(PBYTE)&addr, 2, 1, _forg);*/ //fast version (little endian) (не _SIZEOF_UINT, т.к. тут надо размер дл€ таргета!)
//  };
}

PROC asmdisp(INT ivalue) //дл€ $+d и ix+d
{
  IF (+(UINT)(ivalue + +(INT)0x0080) >= 0x0100) {
    errstr("far +d"); enderr();
  };
  asmbyte(+(BYTE)ivalue); //об€зательно записать, иначе поедут адреса!
}

PROC asmdisppopvalue() //дл€ jr и ix+d
{
  asmdisp(+(INT)asmpopvalue());
}

PROC asmrb_ixiyprefix() //сгенерировать префикс dd/fd и привести _reg к h/l
{
//  IF       (_reg==+_ASMRBCODE_HX) {asmbyte(0xdd); //_reg = +_ASMRBCODE_H;
//  }ELSE IF (_reg==+_ASMRBCODE_LX) {asmbyte(0xdd); //_reg = +_ASMRBCODE_L;
//  }ELSE IF (_reg==+_ASMRBCODE_HY) {asmbyte(0xfd); //_reg = +_ASMRBCODE_H;
//  }ELSE /**IF (_reg==+_ASMRBCODE_LY)*/{asmbyte(0xfd); //_reg = +_ASMRBCODE_L;
//  };
  IF (_reg < +_ASMRBCODE_HY) {asmbyte(0xdd);
  }ELSE asmbyte(0xfd);
  _reg = _reg&0x3f;
}

PROC asmoldrb_ixiyprefix() //сгенерировать префикс dd/fd и привести _reg к h/l
{
//  IF       (_oldreg==+_ASMRBCODE_HX) {asmbyte(0xdd); //_oldreg = +_ASMRBCODE_H;
//  }ELSE IF (_oldreg==+_ASMRBCODE_LX) {asmbyte(0xdd); //_oldreg = +_ASMRBCODE_L;
//  }ELSE IF (_oldreg==+_ASMRBCODE_HY) {asmbyte(0xfd); //_oldreg = +_ASMRBCODE_H;
//  }ELSE /**IF (_oldreg==+_ASMRBCODE_LY)*/{asmbyte(0xfd); //_oldreg = +_ASMRBCODE_L;
//  };
  IF (_oldreg < +_ASMRBCODE_HY) {asmbyte(0xdd);
  }ELSE asmbyte(0xfd);
  _oldreg = _oldreg&0x3f;
}

PROC asmrbrb_ixiyprefix() //сгенерировать префикс dd/fd и привести _oldreg,_reg к h/l
//с проверкой ошибок ?x,?y / ?y,?x / ?x/y,h/l / h/l,?x/y
{
VAR BYTE prefix1;
  prefix1 = 0x00; //needed
  IF (_oldreg >= +_ASMRBCODE_HY) {
    prefix1=0xfd;
    goto test1;
  }ELSE IF (_oldreg >= +_ASMRBCODE_HX) {
    prefix1=0xdd;
    test1:
    IF (_reg==+_ASMRBCODE_H) errwrongreg(); //?x/y, h
    IF (_reg==+_ASMRBCODE_L) errwrongreg(); //?x/y, l
    asmbyte(prefix1);
  };
  IF (_reg >= +_ASMRBCODE_HY) {
    IF (prefix1!=0xfd) {
      asmbyte(0xfd);
      IF (prefix1==0xdd) errwrongreg();
    };
    goto test2;
  }ELSE IF (_reg >= +_ASMRBCODE_HX) {
    IF (prefix1!=0xdd) {
      asmbyte(0xdd);
      IF (prefix1==0xfd) errwrongreg();
    };
    test2:
    IF (_oldreg==+_ASMRBCODE_H) errwrongreg(); //h, ?x/y
    IF (_oldreg==+_ASMRBCODE_L) errwrongreg(); //l, ?x/y
    _reg = _reg&0x3f;
  };
  _oldreg = _oldreg&0x3f;
}

PROC asmrp_ixiyprefix() //сгенерировать префикс dd/fd и привести _reg к hl
{
  IF (_reg==+_ASMRPCODE_IX) {asmbyte(0xdd); //_reg = +_ASMRPCODE_HL;
  }ELSE /*IF (_reg==+_ASMRPCODE_IY)*/{asmbyte(0xfd); //_reg = +_ASMRPCODE_HL;
  };
  _reg = +_ASMRPCODE_HL;
}

PROC asmoldrp_ixiyprefix() //сгенерировать префикс dd/fd и привести _reg к hl
{
  IF (_oldreg==+_ASMRPCODE_IX) {asmbyte(0xdd); //_oldreg = +_ASMRPCODE_HL;
  }ELSE /*IF (_oldreg==+_ASMRPCODE_IY)*/{asmbyte(0xfd); //_oldreg = +_ASMRPCODE_HL;
  };
  _oldreg = +_ASMRPCODE_HL;
}

PROC asmrprp_ixiyprefix() //сгенерировать префикс dd/fd и привести _oldreg,_reg к hl
//с проверкой ошибок ix,iy / iy,ix / ix/iy,hl / hl,ix/iy
{
VAR BYTE prefix1;
  prefix1=0x00; //needed
  IF (_oldreg==+_ASMRPCODE_IX) {
    prefix1=0xdd;
    goto test1;
  }ELSE IF (_oldreg==+_ASMRPCODE_IY) {
    prefix1=0xfd;
    test1:
    IF (_reg==+_ASMRPCODE_HL) errwrongreg(); //ix/iy, hl
    asmbyte(prefix1);
  };//ELSE prefix1=0x00;
  IF (_reg==+_ASMRPCODE_IX) {
    IF (prefix1!=0xdd) {
      asmbyte(0xdd);
      IF (prefix1==0xfd) errwrongreg();
    };
    goto test2;
  }ELSE IF (_reg==+_ASMRPCODE_IY) {
    IF (prefix1!=0xfd) {
      asmbyte(0xfd);
      IF (prefix1==0xdd) errwrongreg();
    };
    test2:
    IF (_oldreg==+_ASMRPCODE_HL) errwrongreg(); //hl, ix/iy
    _reg = +_ASMRPCODE_HL;
  };//ELSE prefix2=0x00;
  _oldreg = _oldreg&0x3f;
}

PROC asmbyte_ed()
{
  asmbyte(0xed);
}

PROC err_rbix()
{
  IF (_reg>=_ASMRBIXADD) errwrongreg();
}

PROC err_oldrbix()
{
  IF (_oldreg>=_ASMRBIXADD) errwrongreg();
}

PROC err_rpix()
{
  IF (_reg>=_ASMRPIXADD) errwrongreg();
}

PROC asmcheckrb_ixiyprefix()
{
  IF (_reg>=_ASMRBIXADD) asmrb_ixiyprefix();
}

PROC asmcheckrp_ixiyprefix()
{
  IF (_reg>=_ASMRPIXADD) asmrp_ixiyprefix();
}

PROC asmcheckoldrp_ixiyprefix()
{
  IF (_oldreg>=_ASMRPIXADD) asmoldrp_ixiyprefix();
}

PROC initmemmodel()
{
  //_curaddr = _BASEADDR; //0x0100;
  //_curpage0 = 0x00;
  //_curpage1 = 0x05;
  //_curpage2 = 0x02;
  //_curpage3 = 0x07;
}

