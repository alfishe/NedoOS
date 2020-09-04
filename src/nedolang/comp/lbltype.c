VAR BYTE _lblhash;

EXPORT PROC initlblbuf()
{
  _lblhash = 0x00;
  REPEAT {
    _lblshift[_lblhash] = _LBLBUFEOF;
    INC _lblhash;
  }UNTIL (_lblhash == 0x00);
  _lblbuffreeidx = 0;
};

EXPORT FUNC TYPE lbltype() //вернуть тип метки _name и _typeaddr
{
VAR PBYTE plbl; //метка в таблице заканчивается нулём
VAR TYPE t;
VAR UINT plbl_idx;
  t = _T_UNKNOWN;
  _lblhash = (BYTE)hash((PBYTE)_name);
  plbl_idx = _lblshift[_lblhash];
  WHILE (plbl_idx != _LBLBUFEOF) { //пока цепочка меток не закончилась
    plbl = &_lbls[plbl_idx];
    plbl_idx = *(PUINT)(plbl);
    plbl = &plbl[+sizeof(UINT)+1]; //skip string size
    IF (strcp((PCHAR)_name, (PCHAR)plbl)) { //метка найдена
      _typeaddr = (UINT)(plbl - _lbls); //для запоминания типа в будущей переменной //в C индексы, в асме указатели (лезут в UINT)
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
  _lblhash = (BYTE)hash((PBYTE)_name);
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

EXPORT FUNC UINT gettypename(PCHAR s) //взять название типа структуры в joined (сразу после lbltype)
{
RETURN strcopy((PCHAR)&_lbls[_typeaddr], (UINT)*(PBYTE)&_lbls[_typeaddr-1], s); //в C индексы, в асме указатели (лезут в UINT)
}

EXPORT PROC addlbl(TYPE t, BOOL isloc, UINT varsz) //(_name)
{
VAR PBYTE plbl;
VAR UINT freeidx;
VAR TYPE oldt;
  oldt = lbltype(); //(_name) //устанавливает _isloc (если найдена) и _typeaddr (адрес, если найдена)
  IF ((oldt == _T_UNKNOWN)||isloc) { //если не было метки или локальная поверх глобальной или другой локальной (параметра)
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
      _lblbuffreeidx = (UINT)(plbl - _lbls) + +sizeof(UINT); //указатель конец создаваемой метки
      _lblshift[_lblhash] = freeidx; //новый указатель на начало цепочки
    }ELSE {errstr("nomem"); enderr();
    };
  }ELSE IF (oldt != t) {
    errstr("addvar type doesn't match previous declaration:"); errstr(_name); enderr();
  };
}

EXPORT PROC setvarsz(UINT addr, UINT shift)
{
  POKE *(PUINT)(&_lbls[addr]) = shift;
}

