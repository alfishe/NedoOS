//// imported
#include "../_sdk/io.h"

//#include "../_sdk/print.h"

EXTERN PCHAR _texttoken[256];

PROC asmfilltokens FORWARD();

////

CONST BOOL _isalphand[256]={ //включая точку (в отличие от read.c/_isalphanum)
  +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, //0X
  +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, //1X
  +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE, +FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+FALSE,+TRUE/**FALSE*/,+FALSE, //2X
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

//перед EOF может быть/не быть EOL

PROC asmexport_line()
{
VAR BYTE token;
//VAR PCHAR pintoken;

  WHILE (+TRUE) {
    token = readfin();
reinterpret:
    IF (_waseof) BREAK;
    IF (token == (BYTE)(+_TOKTEXT)) { //anytext
      WHILE (+TRUE) {
        token = readfin();
        IF (token == +_TOKENDTEXT) BREAK;
        writefout(token);
      };
    }ELSE IF (token == +_TOKEXPR) {
      WHILE (+TRUE) {
        token = readfin();
        IF (token == +_TOKENDEXPR) BREAK;
        writefout(token);
      };
    }ELSE IF ((token == +_TOKLABEL)||(token == +_CMDLABEL)) {
      WHILE (+TRUE) {
        token = readfin();
        IF (!_isalphand[token]) goto reinterpret;
        writefout(token);
      };
    }ELSE IF (token == +_TOKCOMMENT) {
      writefout(token);
      WHILE (+TRUE) {
        token = readfin();
        IF ((token == +_TOKEOL)||(token == +_TOKEOF)) goto reinterpret;
        writefout(token);
      };
    }ELSE { //simple token
      fputs(_texttoken[token], _fout);
/**      pintoken = _texttoken[token];
      WHILE (+TRUE) {
        c = *(PCHAR)(pintoken);
        IF (c == '\0') BREAK;
        INC pintoken;
        writebyte(_fexp, (BYTE)c);
      };*/
    };
    IF (token == +_TOKEOL) BREAK;
  };
}

PROC asmexport(PCHAR fn)
{
VAR BYTE b;
  //setxy(0x05,0x00);
  //prchar('@');
  //nprintf("Hello %s %d world!",(UINT)"ZX Spectrum",(UINT)48);

  b = 0x00;
  REPEAT { //на всякий случай чистим все токены
    _texttoken[b] = "";
    INC b;
  }UNTIL (b == 0x00);

  _texttoken[+_TOKEOL]="\n";
  _texttoken[+_TOKSPC1]=" ";
  _texttoken[+_TOKSPC2]="  ";
  _texttoken[+_TOKSPC3]="   ";
  _texttoken[+_TOKSPC4]="    ";
  _texttoken[+_TOKSPC5]="     ";
  _texttoken[+_TOKSPC6]="      ";
  _texttoken[+_TOKSPC7]="       ";
  _texttoken[+_TOKSPC8]="        ";

  _texttoken[+_TOKCOMMA]=",";
  _texttoken[+_TOKOPEN]="(";
  _texttoken[+_TOKOPENSQ]="[";
  _texttoken[+_TOKCLOSE]=")";
  _texttoken[+_TOKCLOSESQ]="]";
  _texttoken[+_TOKCOLON]=":";
  _texttoken[+_TOKDIRECT]="#";
  _texttoken[+_TOKPRIME]="\'"; //для af'
  _texttoken[+_TOKDBLQUOTE]="\"";
  _texttoken[+_TOKEQUAL]="=";

  _texttoken[+_TOKCOMMENT]=";";

  _texttoken[+_CMDORG     ]="org";
  _texttoken[+_CMDALIGN   ]="align";
  _texttoken[+_CMDPAGE    ]="page";
  _texttoken[+_CMDIF      ]="if";
  _texttoken[+_CMDELSE    ]="else";
  _texttoken[+_CMDENDIF   ]="endif";
  _texttoken[+_CMDDUP     ]="dup";
  _texttoken[+_CMDEDUP    ]="edup";
  _texttoken[+_CMDMACRO   ]="macro";
  _texttoken[+_CMDENDM    ]="endm";
  _texttoken[+_CMDEXPORT  ]="export";
  _texttoken[+_CMDLOCAL   ]="local";
  _texttoken[+_CMDENDL    ]="endl";
  _texttoken[+_CMDDISP    ]="disp";
  _texttoken[+_CMDENT     ]="ent";
  _texttoken[+_CMDINCLUDE ]="include";
  _texttoken[+_CMDINCBIN  ]="incbin";
  _texttoken[+_CMDDB      ]="db";
  _texttoken[+_CMDDW      ]="dw";
  _texttoken[+_CMDDL      ]="dl";
  _texttoken[+_CMDDS      ]="ds";
  _texttoken[+_CMDDISPLAY ]="display";
  _texttoken[+_CMDREPEAT  ]="repeat";
  _texttoken[+_CMDUNTIL   ]="until";
  _texttoken[+_CMDSTRUCT  ]="struct";
  _texttoken[+_CMDENDSTRUCT]="endstruct";

  asmfilltokens();

  //setfin( "tok.f" );
  _fin = nfopen(fn, "rb");
  IF (_fin != (PBYTE)0) {
    _waseof = +FALSE;
    _fout = openwrite( "exp.f" );

    WHILE (!_waseof) {
      asmexport_line();
    };

    fclose(_fout);
    fclose(_fin); //closefin();
  };
}
