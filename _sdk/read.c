//// imported
#include "../_sdk/str.h"

VAR PCHAR _tword; //текущее слово
VAR UINT _lentword;
VAR CHAR _s0[_STRLEN]; //текущее слово
//VAR PCHAR _tstr; //текущая строка
//VAR UINT _lentstr;
//VAR CHAR _ss[_STRLEN]; //текущая строка

EXTERN PBYTE _fin;
EXTERN BOOL _waseof;

EXTERN UINT  _curlnbeg; //номер строки на момент начала токена

FUNC BYTE readfin FORWARD();
//FUNC UINT readfinstr FORWARD(PBYTE pstr);

////

VAR UINT  _curline; //текущий номер строки
VAR CHAR _cnext; //следующий символ
VAR CHAR _c; //текущий символ (глобальный, чтобы не сохранять в рекурсии)
VAR UINT _spcsize; //число пробелов после прочитанной команды
VAR UINT _waseols; //сколько было EOL с прошлого раза

VAR BOOL _doskip; //пропускать строки, кроме начинающихся с #

PROC rdword FORWARD();
PROC rdaddword FORWARD(); //join next word

CONST BOOL _isalphanum[256]={
  +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, //0X
  +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, //1X
  +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, //2X
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, //3X
  +FALSE,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //4X
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+FALSE,+FALSE,+FALSE,+FALSE,+TRUE , //5X
  +FALSE,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //6X
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, //7X

  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //8X..FX
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //8X..FX
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //8X..FX
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //8X..FX
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //8X..FX
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //8X..FX
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , //8X..FX
  +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE , +TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE ,+TRUE   //8X..FX
};

//надо начать пропуск строк в тот момент, когда _cnext = первый символ строки, а _waseols!=0
//на выходе из пропуска надо то же состояние: _cnext = первый символ строки, а _waseols!=0

PROC skiplines() //пропускать строки до # (на выходе _cnext == '#')
{
 //_curline = _curline; //сейчас _cnext = первый символ строки, а _waseols!=0
  skipline:
 //пропустить строку, если она не начинается с # (иначе на выходе _cnext == '#')
 //сейчас _cnext == первый символ строки
 //если не #, то пропустить строку
  WHILE ((_cnext != '#')&&(!_waseof)) {
    INC _curline;
    INC _waseols;
    loop:
    _cnext = +(CHAR)readfin();
    IF ((+(BYTE)_cnext != 0x0a)&&(!_waseof)) {
      goto loop;
    };
    _cnext = +(CHAR)readfin();
    //сейчас _cnext == первый символ строки
  };
 //_curline = _curline; //сейчас _cnext == '#' или EOF
}

//пропускает пробелы и ентеры
PROC rdch()
//читаем всю группу диерезисов + символ как один символ
//добавляет cnext в tword
//и читает всю группу диерезисов + символ как один символ cnext
{
//  _lentword = stradd(_tword, _lentword, _cnext);
  IF (_lentword < _STRMAX) {
    _tword[_lentword] = _cnext;
    INC _lentword;
  };
  loop:
    _cnext = +(CHAR)readfin();
    IF (+(BYTE)_cnext < +(BYTE)'!') { //ускорение выхода
      INC _spcsize; //spaces after tword
      IF (+(BYTE)_cnext == 0x0a) {
        INC _curline;
        _spcsize = 0;
        INC _waseols;
      }ELSE IF (_cnext == '\t') {
        _spcsize = _spcsize + 7; //TODO связать с X
      };
      //_wasdieresis = +TRUE;
      IF (!_waseof) goto loop; //todo в ветке 0a
    };
  IF (_doskip)
    IF (_waseols!=0) {
      skiplines();
      //сейчас _cnext == '#'
    };
}

//пропускает ентеры
PROC rdchcmt()
//добавляет cnext в tword
//и читает всю группу диерезисов + символ как один символ cnext
{
//  _lentword = stradd(_tword, _lentword, _cnext);
  IF (_lentword < _STRMAX) {
    _tword[_lentword] = _cnext;
    INC _lentword;
  };
  loop:
    _cnext = +(CHAR)readfin();
    IF (+(BYTE)_cnext == 0x0a) {
      INC _curline;
      _spcsize = 0;
      INC _waseols;
      IF (!_waseof) goto loop;
    }ELSE IF (+(BYTE)_cnext == 0x0d) {
      IF (!_waseof) goto loop;
    };
  IF (_doskip) //todo надо ли тут?
    IF (_waseols!=0) {
      skiplines();
      //сейчас _cnext == '#'
    };
}

PROC rdaddword() //подклеить следующую команду к текущей
{
    IF (_doskip)
      IF (_waseols!=0) {
        skiplines();
        //сейчас _cnext == '#'
      };
  beg:
  _spcsize = 0; //число пробелов после прочитанной команды
  _waseols = 0;
  _curlnbeg = _curline;
  IF (_isalphanum[+(BYTE)_cnext] ) {
    loop1: //REPEAT { //ждём нецифробукву (EOF не цифробуква)
      IF (_lentword < _STRMAX) {
        _tword[_lentword] = _cnext;
        INC _lentword;
      };
      _cnext = +(CHAR)readfin();
    IF (_isalphanum[+(BYTE)_cnext]) goto loop1; //}UNTIL (!_isalphanum[+(BYTE)_cnext]/** || _waseof*/ );
    goto loopgo;
    loop2: //REPEAT { //ждём недиерезис или EOF
      _cnext = +(CHAR)readfin();
    loopgo:
      IF (+(BYTE)_cnext < +(BYTE)'!') { //ускорение выхода
        INC _spcsize; //spaces after tword
        IF (+(BYTE)_cnext == 0x0a) {
          INC _curline;
          _spcsize = 0;
          INC _waseols;
        };
        IF (!_waseof) goto loop2;
      };
    //}UNTIL (_wasdieresis || _waseof );
  }ELSE { //слово из нецифробуквенного символа
    rdch(); //читаем всю группу диерезисов + символ как один символ
  }; //нельзя подклеить это условие к циклу, т.к. оно для изначального cnext и один раз

  _tword[_lentword] = (CHAR)0x00; //strclose(_tword, _lentword); //todo нарушена парность clear..close

  IF (_lentword==1) {
    _c = *(PCHAR)_tword;
    IF (+(BYTE)_c < +(BYTE)'<') { //ускорение
      IF (
          (
           ((_c=='/')&&(_cnext=='*'))
         ||((_c=='*')&&(_cnext=='/'))
          )
         ) { //игнорируем /* и */
        rdch(); //rdaddword(); //используем первый символ знака комментария, читаем следующий символ после пробелов
        IF ( _cnext=='*' ) { ///** */ надо как комментарий
          rdchcmt(); //rdaddword(); //используем второй символ знака комментария
          WHILE ( !( ( (_cnext=='/')&&(_c=='*') ) || _waseof ) ) {
            _c = _cnext;
            rdchcmt(); //пропускает все ентеры
          };
          rdch(); //используем последний символ комментария, читаем следующий символ после пробелов
          _tword[_lentword] = (CHAR)0x00; //strclose(_tword, _lentword); //todo нарушена парность clear..close
  //#ifdef USE_COMMENTS
  ;;        //cmt(';'); cmtstr(_tword); endcmt();
  ;;        IF (_cmts) {writebyte(_fout, +(BYTE)';'); fputs(_tword, _fout); writebyte(_fout, +(BYTE)'\n'); };
  //#endif
        };
        //читаем слово после комментария или недокомментария /* или */
        _lentword = 0/**strclear(_tword)*/; //todo нарушена парность clear..close
        goto beg; //rdaddword();
      }ELSE IF ( //(_lentword==1)&&
                (
                 (_c=='/')&&(_cnext=='/')
//               ||(_c=='#')
               ||(_c==';')&&(_cnext==';')
                )
               ) { //
        _waseols = 0; //чтобы ;; работало после строки, заканчивающейся на ; (TODO не помогает)
        rdchcmt(); //rdaddword(); //используем первый символ знака комментария, читаем следующий символ
        WHILE (_waseols==0/** && !_waseof*/ ) {
          rdchcmt(); //пропускает все ентеры
        };
        _tword[_lentword] = (CHAR)0x00; //strclose(_tword, _lentword); //todo нарушена парность clear..close
  //#ifdef USE_COMMENTS
  ;;        //cmt(';'); cmtstr(_tword); endcmt();
  ;;        IF (_cmts) {writebyte(_fout, +(BYTE)';'); fputs(_tword, _fout); writebyte(_fout, +(BYTE)'\n'); };
  //#endif
        IF (+(BYTE)_cnext < +(BYTE)'!') {
          rdch(); //используем последний символ комментария, читаем следующий символ (TODO унифицировать как выше)
        };
        //читаем слово после комментария
        _lentword = 0/**strclear(_tword)*/; //todo нарушена парность clear..close
        goto beg; //rdaddword();
      };
    }; //ускорение
  }; //check cmt
}

PROC rdword()
//читаем слово _tword (из текста с диерезисами вместо пробелов, ентеров, табуляций)
//слово заканчивается, когда диерезис или нецифробуквенный символ (он попадёт в cnext, а курсор в файле после него)
{
  _lentword = 0/**strclear(_tword)*/; //todo нарушена парность clear..close
  rdaddword();
}

PROC rdquotes(CHAR eol) //считывает до кавычки невключительно
{
  WHILE (_spcsize != 0) { //добавить съеденные пробелы
    _lentword = stradd(_tword, _lentword, ' ');
    DEC _spcsize;
  };
  WHILE ( (_cnext!=eol) && !_waseof) {
    IF ( _cnext=='\\' ) {
      _lentword = stradd(_tword, _lentword, _cnext);
      _cnext = +(CHAR)readfin();
    };
    _lentword = stradd(_tword, _lentword, _cnext);
    _cnext = +(CHAR)readfin();
  };
  _tword[_lentword] = (CHAR)0x00; //strclose(_tword, _lentword);
}

PROC initrd()
{
  _doskip = +FALSE;
  _tword = (PCHAR)_s0;
//  _tstr = (PCHAR)_ss;
  _waseols = 0;
  _spcsize = 0;
  _lentword = 0/**strclear(_tword)*/; //todo нарушена парность clear..close
  rdch(); //читаем всю группу диерезисов + символ как один символ
}

