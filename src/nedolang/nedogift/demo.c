//// song = 18 positions

//// imported
PROC halt FORWARD();
PROC border FORWARD(BYTE col);
FUNC BYTE random FORWARD();

PROC pokenet FORWARD(BYTE row, BYTE col, BYTE data);
FUNC BYTE peeknet FORWARD(BYTE row, BYTE col);
PROC pokenetcolor FORWARD(BYTE row, BYTE col, BYTE data);
FUNC BYTE peeknetcolor FORWARD(BYTE row, BYTE col);
PROC testcube FORWARD();
PROC cubecolumn FORWARD();
FUNC BYTE getayreg FORWARD(BYTE reg);
PROC decay FORWARD();
PROC clearnet FORWARD();
PROC drawcubetexture FORWARD();
PROC jumpay FORWARD(BYTE tonereg, BYTE volreg, BYTE mask);

PROC prch FORWARD(UINT addr, CHAR c);

EXTERN UINT _timer;

////

VAR UINT _wastimer;
VAR UINT _curtimer;
VAR UINT _logicframes;
VAR UINT _textlogicframes;

VAR BOOL _frameready;

CONST BYTE _wid = 0x20;
CONST BYTE _hgt = 0x18;
CONST BYTE _scrhgt = 0x14;

CONST BYTE _netwid = 0x20;
CONST BYTE _nethgt = 0x20;

VAR PBYTE _net;
CONST BYTE _net35[768];
CONST BYTE _nettort[768];
/**= {
0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,B-L,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,
0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,LLL,0x4,BBB,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,
0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x0,0x4,0x3,0x4,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,
0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x0,0x4,0x2,0x2,0x2,0x4,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,
0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x0,0x4,0x1,0x1,0x1,0x1,0x1,0x4,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,
0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x0,0x4,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x4,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,
0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x0,0x4,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,
0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x0,0x4,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x4,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,
0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,LLL,0x4,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x4,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,
0x6,0x6,0x6,0x6,0x6,0x6,0x6,LLL,0x4,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x4,0x6,0x6,0x6,0x6,0x6,0x6,0x6,
0x0,0x0,0x0,0x0,0x0,0x0,T-L,0x4,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,
0x2,0x2,0x2,0x2,0x2,0x2,0x4,TTT,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x4,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,
0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x4,TTT,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x4,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,
0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x4,0x0,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x4,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,
0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x0,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,
0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x4,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x4,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,
0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x4,0x7,0x7,0x7,0x7,0x7,0x4,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,
0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x4,0x6,0x6,0x6,0x4,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,
0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x3,0x4,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,
0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x4,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,
0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,
0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,
0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,
0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6
};
*/
CONST UINT _netaddr = 0xd000; //запорчено ещё 256 байт ниже
//CONST UINT _net2addr = 0xd040;
CONST UINT _netcoloraddr = 0xd080;
CONST UINT _attrbuf = 0xf000;
CONST UINT _attrbuf2 = 0xf300;

VAR UINT _curattrbuf;
VAR UINT _readyattrbuf;

CONST BYTE _clBlue = 0x01;
CONST BYTE _clRed = 0x05;

VAR UINT _position;
VAR UINT _tact;
VAR UINT _quarter;
VAR BYTE _noteintact;
VAR BYTE _noteinquarter;

VAR BYTE _jump;
VAR BYTE _jumptime;
VAR BYTE _row;
VAR BYTE _picrow;
VAR BYTE _col;
//VAR BYTE _curhgt;
//VAR BOOL _backslash;
//VAR BOOL _rowstep;
//VAR BYTE _curcolor;
//VAR BYTE _oldcolor;
//VAR BYTE _y;
VAR UINT _addr;

VAR BYTE _stage;
VAR BYTE _wasstage;

VAR BYTE _dotext;

CONST PCHAR _text =
"It's a boy!!!                   "
"                       Ho-ho!   "
"        Hello, LVD!             "
"                                "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

" ALONE CODER, SAND, NQ & others "
"       WISH U ALL DA BEST!      "
"    b  happy, don't  worry      "
"          und HBD!!             "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

" This iz the first demo made in "
"            NedoLang            "
"da  programming  system         "
"            of  da  future ;)   "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"        okay                    "
"    some     wishes             "
"          right       now       "
"                 !!!            "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"SAND/MAYhEM:\n"
"Ну что!  С  Днюшечкой,   Бро!!! "
"Ты  стал   уже  совсем  большой "
" и сам знаешь,  что тебе нужно! "

" Вот именно этого тебе и желаю!!"
"А от себя  лично  пожелаю  тебе "
"стандартный  набор   из счастья,"
"успехов, здоровья и, конечно же,"

" какую-нибудь дельную хрень типа"
"лазерного   мешка    или  робота"
"   |   | на  батарейках,  |   | "
" | чтоб  пиликал  и   катался!  "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"NQ/SKRJU:                       "
"Вадя,   пишу  тебе  из  вот этих"
"своих  жарких  югов  в эту  твою"
"Москву!  Тебе   и твоим близким,"

"чтобы  хорошо  было  и  все друг"
"другу  улыбались  и  радовались,"
"потому  что  хорошие люди вокруг"
"и  ничего  не  болит ни  у кого,"

"а один  лишь достаток и радость,"
"  | вот  такая |   |   |   |   |"
"           прошивка-установка!  "
"  |   ! ! !|   |   |   |   |   |"

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"ALONE CODER/Conscience:         "
"   Желаю,    чтобы    схемы     "
"всегда  разводились  с  первой  "
"             попытки,           " 

"cигналы всегда успевали вовремя,"
"эффекты кодились  самые быстрые," 
"а  пакер  паковал  круче  всех! " 
"   |   |   |   | ...            "

"    ...            И на всё это "
"хватало времени до, после       "
"              и вместо работы :)"
"     ! ! !                      "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"LOUISA/Conscience:              "
"Поздравляю тебя с днём рождения,"
"     наш   дорогой   LVD!    :) "
"  Всего самого расчудесного  и  "

" привлекательного!   Счастья,   "
"     здоровья и всего того, что "
"пожелаешь  сам!  Достатка       "
"    финансов, творческих идей   "

"и  времени  на  их  исполнение! "
"Ах да, карапузиков в твой дом!:)"
"                 Ура!           "
"           ! ! !                "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"HIPPIMAN/Conscience:            "
" Я тоже  хочу  присоединиться  к"
"   всеобщим    поздравлениям.   "
" Не, ну  а  как  не  поздравить "

" человека, который  даровал миру"
" |   |   | BASECONF!  |   |   | "
" Вадим,   всяческих благ  тебе, "
"  здоровья  и  побольше денег.  "

"Денег столько, чтобы у тебя было"
" побольше свободного  времени и "
"ты мог посвятить  его творчеству"
"и  новым  разработкам,  которыми"

" |   радовал  бы  уже  нас,|   |"
" | простых любителей Спекки :)  "
" |   |   |  ! ! ! |   |   |   | "
"   |   |   |   |   |   |   |   |"

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"FYREX/MhM:                      "
"        Всего наилучшего!       " 
"   И поддерживай отечественную  " 
"          демосцену ! )         "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"DIMON\"ШМЕЛЕ\"MEDVED-ER:          "
"Сколково, инновации... руссиано "
"            ...                 "
"      НAHOтехнологии, знаете ли!"

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"-HBD---#-----#---#--###---------"
"-------#-----#---#--#--#--------"
"-------#------#-#---#---#-------"
"-------#####---#----####----!!!-"

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"idea .... ALONE CODER & SAND/MhM"
"kodes .............. ALONE CODER"
"soundtrakk ............ NQ/SKRJU"
"some gfx, etc ......... SAND/MhM"

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"

"                                "
"                                "
"                                "
"          read  again?!         "

"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
"   |   |   |   |   |   |   |   |"
;
//" Und now play-on da Allegrowa's "
//"song  'S Dnem Rozhdenija!' )))))"
//"  start  dancin' and boozein'   "
//"make volumemax! komon! doit now!"


/**
PROC pokenet(BYTE _row, BYTE _col, BYTE data)
{
  POKE *(PBYTE)(_netaddr + (+(UINT)_row<<8) + +(UINT)_col) = data;
}

FUNC BYTE peeknet(BYTE _row, BYTE _col)
{
  RETURN *(PBYTE)(_netaddr + (+(UINT)_row<<8) + +(UINT)_col);
}

PROC pokenetcolor(BYTE _row, BYTE _col, BYTE data)
{
  POKE *(PBYTE)(_netcoloraddr + (+(UINT)_row<<8) + +(UINT)_col) = data;
}

FUNC BYTE peeknetcolor(BYTE _row, BYTE _col)
{
  RETURN *(PBYTE)(_netcoloraddr + (+(UINT)_row<<8) + +(UINT)_col);
}
*/
/**
PROC testcube()
{
VAR BYTE hgt;

      //определяем цвет и двигаем _row (_col)
      //если hgt==_curhgt, то пол и _row++ (_col--)
      //если hgt>_curhgt, то стена
      //если hgt<_curhgt, то _row++ (_col--) и крутимся
      //_row,_col указывают на то, что мы видим в этой клетке, или на яму
        IF (_rowstep != _backslash) { //чётность не соответствует, так что границы не будет
          _curcolor = _oldcolor;
          //_curhgt++;
        }ELSE { //чётность соответствует

         invisloop:
          IF (_rowstep) { // \ - пересечение _row, дальше идём по _col
            hgt = peeknet(_row, _col);
            IF (hgt==_curhgt) { //пол (только при правильной чётности!)
              IF (_rowstep==_backslash) {
                _curcolor = peeknetcolor(_row, _col); //clWhite; //новый наравне
                DEC _col;
                _rowstep = !_rowstep;
              }ELSE {
                IF (_oldcolor != _clBlue) _curcolor = _clRed; //новый выше
              };
            }ELSE IF (hgt>_curhgt) { //стена пересечение _row
              IF (_oldcolor != _clBlue) _curcolor = _clRed; //новый выше
              IF (_rowstep==_backslash) INC _curhgt;
              //теперь чётность _rowstep может не соответствовать _backslash!
            }ELSE { //яма
              DEC _col;
              _rowstep = !_rowstep;
              IF (_rowstep==_backslash) {
                DEC _curhgt;
              };
              goto invisloop;
            };
          }ELSE { // / - пересечение _col, дальше идём по _row
            hgt = peeknet(_row, _col);
            IF (hgt==_curhgt) { //пол (только при правильной чётности!)
              IF (_rowstep==_backslash) {
                _curcolor = peeknetcolor(_row, _col); //clWhite; //новый наравне
                INC _row;
                _rowstep = !_rowstep;
              }ELSE {
                IF (_oldcolor != _clRed) _curcolor = _clBlue; //новый выше
              };
            }ELSE IF (hgt>_curhgt) { //стена пересечение _col
              IF (_oldcolor != _clRed) _curcolor = _clBlue; //новый выше
              IF (_rowstep==_backslash) INC _curhgt;
              //теперь чётность _rowstep может не соответствовать _backslash!
            }ELSE { //яма
              INC _row;
              _rowstep = !_rowstep;
              IF (_rowstep==_backslash) {
                DEC _curhgt;
              };
              goto invisloop;
            };
          }; //!_rowstep

        }; //_rowstep==_backslash
}
*/
/**
PROC cubecolumn()
{
VAR BYTE b;
    _curhgt = 0x00;
    _backslash = ((+(BYTE)_addr&0x02)==0x00); //_backslash - пересечение _row
    _rowstep = _backslash;
    _oldcolor = 0x07;
    _y = _hgt;
    REPEAT {
      testcube();
      //_row,_col указывают на то, что мы видим в следующей клетке, или на яму
      //чётность _rowstep должна соответствовать _backslash, кроме случая, когда нашли стену

      //рисуем цвет
      IF (_y <= _scrhgt) {
        b = (_curcolor<<0x03) + _oldcolor;
        POKE *(PBYTE)(_addr) = b;
        POKE *(PBYTE)(_addr+1) = b;
      };
      _addr = _addr - 0x0020;
      _oldcolor = _curcolor;
      _backslash = !_backslash; //привязано к "y"
      DEC _y;
    }UNTIL (_y == 0x00);
}
*/
PROC fillworm()
{
      _picrow = 0x04/**0x00*/;
      WHILE (_row < 0x15) {
	pokenet(_row, _col, 0x01);
	pokenetcolor(_row, _col, _net[(+(UINT)_picrow<<5)+ +(UINT)_col + 31]);
        INC _row;
	INC _picrow;
      };
};

PROC fillwormforth()
{
      _picrow = 0x00;
      WHILE (_row < 0x15) {
	pokenet(_row, _col, 0x01);
	pokenetcolor(_row, _col, _net[(+(UINT)_picrow<<5)+ +(UINT)_col + 31]);
        INC _row;
	INC _picrow;
      };
};

PROC fillwormback()
{
      _picrow = 0x13;
      WHILE (_row != 0xff) {
	pokenet(_row, _col, 0x01);
	pokenetcolor(_row, _col, _net[(+(UINT)_picrow<<5)+ +(UINT)_col + 31]);
        DEC _row;
	DEC _picrow;
      };
};

PROC clearworm()
{
      _row = 0x01;
      WHILE (_row < 0x16) {
	pokenet(_row, _col, 0x00);
	pokenetcolor(_row, _col, 0x00);
        INC _row;
      };
};

PROC unfillworm()
{
VAR BYTE c;
VAR BYTE cnew;
VAR BYTE h;
VAR BYTE hnew;
      _row = 0x00;
      h = 0x00;
      c = 0x00;
      WHILE (_row < 0x16) {
        hnew = peeknet(_row, _col);
        cnew = peeknetcolor(_row, _col)
	pokenet(_row, _col, h);
	pokenetcolor(_row, _col, c);
        h = hnew;
        c = cnew;
        INC _row;
      };
};

PROC unfillwormback()
{
VAR BYTE c;
VAR BYTE cnew;
VAR BYTE h;
VAR BYTE hnew;
      _row = 0x16;
      h = 0x00;
      c = 0x00;
      WHILE (_row != 0xff) {
        hnew = peeknet(_row, _col);
        cnew = peeknetcolor(_row, _col)
	pokenet(_row, _col, h);
	pokenetcolor(_row, _col, c);
        h = hnew;
        c = cnew;
        DEC _row;
      };
};
/**
PROC jumpay(BYTE tonereg, BYTE volreg, BYTE mask)
{
VAR UINT frq;
VAR BYTE vol;
VAR INT x;
VAR BYTE y;
VAR BYTE hgt;
  frq = +(UINT)getayreg(tonereg) + (+(UINT)getayreg(tonereg+0x01)<<8);
  IF ((getayreg(0x07)&mask)!=mask) {
    vol = getayreg(volreg);
    IF       (vol>=0x10) {vol = 0x04;
    }ELSE IF (vol==0x0f) {vol = 0x06;
    }ELSE IF (vol==0x0e) {vol = 0x05;
    }ELSE IF (vol==0x0d) {vol = 0x04;
    }ELSE IF (vol==0x0c) {vol = 0x03;
    }ELSE IF (vol==0x0b) {vol = 0x02;
    }ELSE IF (vol>=0x09) {vol = 0x01;
    }ELSE vol = 0x00;
  }ELSE vol = 0x00;
  IF (volreg!=0x09) vol = vol + vol; //low center, high left&right
  frq = frq + 8; //против бесконечного цикла
  y = 0x02;
  WHILE (frq < 1000) {
    frq = frq + (frq >> 2);
    INC y;
  };
  IF (volreg == 0x08) {
    x = - +(INT)(y>>0x02);
  }ELSE IF (volreg == 0x0a) {
    x = +(INT)(y>>0x02);
  }ELSE x = -0;
  _row = +(BYTE)(+(INT)y + x);
  //IF ((_row<0x02)||(_row>=0x40)) _row = 0x02;
  _col = 0x19 - +(BYTE)(+(INT)y - x);
  //IF ((_col<0x02)||(_col>=0x40)) _col = 0x02;
  hgt = peeknet(_row, _col);
  IF (hgt < vol) {
    pokenet(_row, _col+0x40, vol);
  }; //ELSE pokenet(_row, _col, hgt-0x01);
}
*/
PROC demo()
{
VAR PCHAR ptxt;
VAR CHAR c;
VAR UINT scrtxt;
VAR UINT addry;
VAR UINT addr;
VAR UINT addrbase;
VAR BYTE x;
VAR BYTE y;
VAR BYTE suby;
VAR BYTE b;
VAR UINT w;
VAR BYTE hgt;
VAR BOOL cleared;

  _readyattrbuf = _attrbuf;
  
  _wastimer = _timer;
//  border(0x00);
/**
  y = 0x00;
  WHILE (y < _scrhgt) {
    x = 0x00;
    WHILE (x < _wid) {
      addr = _attrbuf + (+(UINT)y<<5) + +(UINT)x;
      POKE *(PBYTE)(addr) = 0x00;
      INC x;
    };
    INC y;
  };
  WHILE (y < _hgt) {
    x = 0x00;
    WHILE (x < _wid) {
      addr = _attrbuf + (+(UINT)y<<5) + +(UINT)x;
      POKE *(PBYTE)(addr) = 0x07;
      INC x;
    };
    INC y;
  };
*/
/**
  addr = _netaddr;
  _row = 0x00;
  WHILE (_row < _nethgt) {
    _col = 0x00;
    WHILE (_col < _netwid) {
      pokenet(_row, _col, random()&0x03);
      pokenetcolor(_row, _col, (_row&0x07)|0x04);
      INC _col;
    };
    INC _row;
  };
*/
//draw cube texture  
  //drawcubetexture();
/**
  addr = 0x4000;
  y = 0x00;
  WHILE (y < _scrhgt) {
    addry = 0x4000 + (+(UINT)y<<5)&0x00e0 + (+(UINT)y<<8)&0x1800;
    x = 0x00;
    WHILE (x < _wid) {
      addr = addry + +(UINT)x;
      IF ((((x>>0x01)^y)&0x01) == 0x00) {
        w = 0x0001;
        suby = 0x00;
        WHILE (suby < 0x08) {
          POKE *(PBYTE)(addr) = +(BYTE)(w>>8);
          POKE *(PBYTE)(addr+1) = +(BYTE)w;
          w = (w<<2) + 0x0003;
          addr = addr + 0x0100;
          INC suby;
        };
      }ELSE {
        w = 0x8000;
        suby = 0x00;
        WHILE (suby < 0x08) {
          POKE *(PBYTE)(addr) = +(BYTE)(w>>8);
          POKE *(PBYTE)(addr+1) = +(BYTE)w;
          w = (w>>2) + 0xc000;
          addr = addr + 0x0100;
          INC suby;
        };
      };
      x = x + 0x02;
    };
    INC y;
  };
*/
  scrtxt = 0x5080;
  ptxt = _text;
  _dotext = 0x00;

//  _frameready = +FALSE;
  
  cleared = +TRUE;
  
  _jumptime = 0x00;
  
  _net = _net35;

  _stage = 0x00;

loop:
  
  //halter();

  IF (!_frameready) {
    x = 0x00;
    _curattrbuf = _attrbuf + _attrbuf2 - _readyattrbuf;
    addrbase = _curattrbuf + (+(UINT)(_scrhgt-0x01)<<5);
    IF (_jumptime!=0x00) {_jump = 0x01;
    }ELSE _jump = 0x00;
    WHILE (x < _wid) {
      _col = 0x12 + (x>>0x02) + _jump;
      _row = (x>>0x02) - _jump; //0
      _addr = addrbase + +(UINT)x;
      cubecolumn();
      x = x + 0x02;
    };
    IF (_jumptime!=0x00) DEC _jumptime;
    _frameready = +TRUE;
    _readyattrbuf = _curattrbuf;
  };
  
  _curtimer = _timer; //однократное чтение гарантирует синхронность
  _logicframes = _curtimer - _wastimer;
  _textlogicframes = _curtimer - _wastimer;
  WHILE (_logicframes != 0) {
    _wasstage = _stage;
    _quarter = _wastimer / 12;
    _tact = _quarter >> 2;
    _position = _tact >> 2;
    _stage = +(BYTE)(_position - (_position/18)*18);//(_tact >> 2)&0x0f; //song = 18 positions
    _noteintact = +(BYTE)(_wastimer - (_tact * 48)); //max 47
    _noteinquarter = +(BYTE)(_wastimer - (_quarter * 12)); //max 11
    IF (_stage == 0x00) { //очистка колбасками

      IF (cleared) {
        _row = 0x00;
        WHILE (_row < _nethgt) {
          _col = 0x00;
          WHILE (_col < _netwid) {
            pokenet(_row, _col, 0x01);
            INC _col;
          };
          INC _row;
        };
        cleared = +FALSE;
        _col = 0x06; 
        clearworm();
        _col = 0x07; 
        clearworm();
        IF (_net == _net35) {_net = _nettort;
        }ELSE _net = _net35;
      };
      _col = 0x08 + (+(BYTE)_quarter & 0x0f); 
      IF ((_col&0x01)==0x00) {
        _row = 0x0b - (_noteinquarter & 0x0f);
        unfillworm();
        unfillworm();
      }ELSE {
        _row = 0x08 + (_noteinquarter & 0x0f);
        unfillwormback();
        unfillwormback();
      };
      
    }ELSE IF (_stage < 0x04) { //очистка и заполнение кубиками
      IF (!cleared) {
        clearnet();
        cleared = +TRUE;
      };
      IF ((_noteinquarter == 0x00)&&((+(BYTE)_quarter&0x01)==0x00)) {
        badrnd:
        x = (random()&0x07) + 0x01;// + 0x01; // + (random()&0x01); //0x00..0x10
        y = (random()&0x07) + 0x01;// + 0x08; //0x08..0x18
        _row = 0x00 + y + x; // + random()&0x01;
        _col = 0x0f - y + x + random()&0x01;
        IF (peeknet(_row, _col) == 0x01) goto badrnd;
        IF (peeknet(_row+0x01, _col) == 0x01) goto badrnd;
        IF (peeknet(_row, _col+0x01) == 0x01) goto badrnd;
        IF (peeknet(_row-0x01, _col) == 0x01) goto badrnd;
        IF (peeknet(_row, _col-0x01) == 0x01) goto badrnd;
        pokenet(_row, _col, 0x01);
        pokenetcolor(_row, _col, 0x07);
      };
    }ELSE IF (_stage == 0x04) { //медленное заполнение колбасками
      //pokenet(0x0a, 0x07, 0x01); //top left
      //pokenetcolor(0x0a, 0x07, _netpic[(+(UINT)0x0a<<5)+ +(UINT)0x07]);
      IF (_wasstage != _stage) {
        _col = 0x06; 
        _row = 0x04/**0x00*/;
        fillworm();
        _col = 0x07; 
        _row = 0x04/**0x00*/;
        fillworm();
      };
      _col = 0x08 + (+(BYTE)_tact & 0x03); 
      _row = 0x0f/**0x0b*/ - ((_noteintact>>0x2) & 0x0f);
      fillworm();
    }ELSE IF (_stage == 0x05) { //быстрое дозаполнение колбасками
      _col = 0x08 + 0x04 + (+(BYTE)_quarter & 0x0f); 
      IF ((_col&0x01)==0x00) {
        _row = 0x0b - (_noteinquarter & 0x0f);
        fillwormforth();
      }ELSE {
        _row = 0x08 + (_noteinquarter & 0x0f);
        fillwormback();
      };
      cleared = +TRUE;
    }ELSE IF (_stage < 0x08) { //прыгающая доска
      IF (cleared) {
        _row = 0xff;
        WHILE (_row != _nethgt) {
          _col = 0x00;
          WHILE (_col != _netwid) {
            pokenet(_row, _col, 0x01);
            IF (_row == 0xff) pokenetcolor(_row, _col, 0x04);
            INC _col;
          };
          INC _row;
        };
        cleared = +FALSE;
      };
      IF ((_noteinquarter == 0x00)&&((+(BYTE)_quarter&0x01)==0x00)) {
        _jumptime = 0x04;
      };
    }ELSE IF (_stage < 0x0a) { //заваливание квадратами
        x = (random()&0x0f) + 0x01;// + 0x01; // + (random()&0x01); //0x00..0x10
        y = (random()&0x0f) + 0x00;// + 0x08; //0x08..0x18
        _row = 0x00 + y + x;
        _col = 0x10 - y + x;
        hgt = peeknet(_row, _col);
        IF ((random()&0x01) == 0x00) {
          IF (hgt!=0x00) DEC hgt;
        }ELSE INC hgt;
        pokenet(_row, _col, hgt);
        pokenet(_row+0x01, _col, hgt);
        pokenet(_row, _col+0x01, hgt);
        pokenet(_row+0x01, _col+0x01, hgt);
    }ELSE /**IF (_stage < 0x0f)*/ { //анализатор музыки

      IF (!cleared) {
        _row = 0x00;
        WHILE (_row < _nethgt) {
          _col = 0x00;
          WHILE (_col < _netwid) {
            pokenet(_row, _col+0x40, 0x01);
            pokenet(_row, _col+0xc0, 0x01);
            INC _col;
          };
          INC _row;
        };
        cleared = +TRUE;
      };
/**
  _row = 0x01;
  WHILE (_row < 0x13) {
    _col = 0x04;
    WHILE (_col < 0x18) {
      hgt = peeknet(_row, _col)+0x01;
      IF       (hgt < peeknet(_row+0x01, _col)) {pokenet(_row, _col+0x40, hgt);
      }ELSE IF (hgt < peeknet(_row, _col-0x01)) {pokenet(_row, _col+0x40, hgt);

      }ELSE IF (hgt < peeknet(_row-0x01, _col)) { pokenet(_row, _col+0x40, hgt);
      }ELSE IF (hgt < peeknet(_row, _col+0x01)) { pokenet(_row, _col+0x40, hgt);
      //}ELSE IF (hgt == peeknet(_row+0x01, _col)) {
      //}ELSE IF (hgt == peeknet(_row, _col-0x01)) {
      }ELSE IF (hgt != 0x01) {pokenet(_row, _col+0x40, hgt-0x02);
      }ELSE pokenet(_row, _col+0x40, hgt-0x01);
      INC _col;
    };
    INC _row;
  };
    
  _row = 0x01;
  WHILE (_row < 0x13) {
    _col = 0x04;
    WHILE (_col < 0x18) {
      pokenet(_row, _col, peeknet(_row, _col+0x40));
      INC _col;
    };
    INC _row;
  };
*/
      jumpay(0x00, 0x08, /**mask*/0x09);
      jumpay(0x02, 0x09, /**mask*/0x12);
      jumpay(0x04, 0x0a, /**mask*/0x24);
      IF ((_noteinquarter&0x01) == 0x00) {
        decay();
        goto quitlogic;
      };
    };
  
    
    INC _wastimer;
    DEC _logicframes;
    //_logicframes = 0;
  };
quitlogic:
  _wastimer = _curtimer;

  WHILE (_textlogicframes != 0) {
    INC _dotext;
    IF ((_dotext&0x03) == 0x00) {
  REPEAT {
    c = *(PCHAR)ptxt;
    IF (c == '\n') {
      scrtxt = (scrtxt&0xffe0) + 0x0020;
    }ELSE IF (c == '|') {
      prch(scrtxt, ' ');
      INC scrtxt;
    }ELSE {
      prch(scrtxt, c);
      INC scrtxt;
    };
    IF (scrtxt >= 0x5100) scrtxt = 0x5080;
    INC ptxt; IF (*(PCHAR)ptxt == '\0') ptxt = _text;
  }UNTIL (c != ' ');
    };
    DEC _textlogicframes;
  };
  
  goto loop;
}
