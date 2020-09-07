FUNC UINT findlabel(PBYTE labeltext)
{
//VAR PBYTE _labelN; //указатель на текущую таблицу меток
VAR PBYTE plabel; //метка в таблице заканчивается нулём
//VAR PBYTE pstr; //метка в строке заканчивается TOK_ENDTEXT
//VAR BYTE cstr; //символ из строки
//VAR BYTE clabel; //символ из таблицы меток
//VAR UINT pnext_index; //адрес следующей метки в таблице
//VAR UINT plabelqueuestart_index; //в (_labelN+plabelqueuestart_index) хранится адрес начала цепочки для метки
  _hash = hash(labeltext)&0x3ff;

  _labelN = _labels0; //_labelpage[(UINT)(_hashhigh&_LABELPAGEMASK)]; //set page (todo как определить? системный макрос?)
  //plabelqueuestart_index = ((UINT)(_hash))<<1; //todo разная разрядность UINT
  _plabel_index = _labelshift[_hash];
  //todo как сделать набор массивов в разных страничках? сдвиг индекса в одном массиве внизу?
  //_labelflag = 0x00; //"label not found"
  WHILE (_plabel_index != _LABELPAGEEOF) { //пока цепочка меток не закончилась
    plabel = &_labelN[_plabel_index]; //(PBYTE)((POINTER)_labelN + (POINTER)_plabel_index);
    _plabel_index = *(PUINT)(plabel);
    plabel = &plabel[+sizeof(UINT)]; //(PBYTE)((POINTER)plabel + (POINTER)2);
    IF (strcp((PCHAR)labeltext, (PCHAR)plabel)) { //метка найдена
      //plabel = (PBYTE)((POINTER)plabel + (POINTER)_labellen); //включая 0
        //errstr("found label "); errstr(labeltext); enderr();
      _plabel_index = (UINT)(plabel - _labelN) + _labellen; //включая 0 //указатель на начало данных создаваемой метки (надо обязательно запомнить!)
      //_labelflag = *(PBYTE)(plabel);
      //_labelvalue = *(PLONG)((POINTER)plabel + (POINTER)1);
      BREAK; //помнит _plabel_index начала данных найденной метки
    };
    //_plabel_index = pnext_index;
  }; //если не найдено, то _plabel_index==_LABELPAGEEOF
RETURN _plabel_index;
}
