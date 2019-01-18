//// imported
#include "../_sdk/io.h"

//#include "../_sdk/print.h"

EXTERN PCHAR _texttoken[256];

PROC asmfilltokens FORWARD();

////

//перед EOF может быть/не быть EOL

PROC asmexport_line()
{
VAR BYTE token;
VAR CHAR c;
//VAR PCHAR pin;
//VAR PCHAR pout;
VAR PCHAR pintoken;

  WHILE (+TRUE) {
    //token=*pin;
    //pin=pin+1;
    token = readfin();
    IF (_waseof) BREAK;
    IF (token == +(BYTE)(+_TOKTEXT)) { //anytext
      WHILE (+TRUE) {
        //c=*pin;
        //pin=pin+1;
        c = +(CHAR)readfin();
        IF (c == +(CHAR)(+(BYTE)(+_TOKENDTEXT))) BREAK;
        //*pout=c;
        //pout=pout+1;
        writefout(+(BYTE)c);
      };
    }ELSE {          //token
      fputs(_texttoken[token], _fout);
/**      pintoken = _texttoken[token];
      WHILE (+TRUE) {
        c = *(PCHAR)(pintoken);
        IF (c == '\0') BREAK;
        INC pintoken;
        //*pout=*pintoken;
        //pout=pout+1;
        writebyte(_fexp, +(BYTE)c);
      };*/
    };
    IF (token == +(BYTE)(+_TOKEOL)) BREAK;
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
  //_texttoken[+_TOKEOF]="";
  //_texttoken[+_TOKSPC0]="";
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
  //_texttoken[+_TOKDIRECT]="#";
  _texttoken[+_TOKPRIME]="\'";
  _texttoken[+_TOKPRIMESYM]="\'"; //используется для символьных констант типа 'c'
  _texttoken[+_TOKDBLQUOTESYM]="\"";
  _texttoken[+_TOKDOLLAR]="$";
  //_texttoken[+_TOKREEQU]="=";

  _texttoken[+_TOKPLUS]="+";
  _texttoken[+_TOKMINUS]="-";
  _texttoken[+_TOKSTAR]="*";
  _texttoken[+_TOKSLASH]="/";
  _texttoken[+_TOKLESS]="<";
  _texttoken[+_TOKMORE]=">";
  _texttoken[+_TOKEQUAL]="=";
  _texttoken[+_TOKAND]="&";
  _texttoken[+_TOKPIPE/**'|'*/]="|";
  _texttoken[+_TOKCARON/**'^'*/]="^";
  _texttoken[+_TOKTILDE/**'~'*/]="~";
  _texttoken[+_TOKEXCL]="!";

  //_texttoken[+_TOKTEXT]="";
  //_texttoken[+_TOKENDTEXT]="";
  _texttoken[+_TOKCOMMENT]=";";
  //_texttoken[+_TOKENDCOMMENT]="";
  //_texttoken[+_TOKNUM]="";
  //_texttoken[+_TOKLABEL]="";
  //_texttoken[+_ERR_]="";

  //_texttoken[+_CMDLABEL   ]="";
  //_texttoken[+_CMDREEQU   ]="";
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
  //_texttoken[+_CMDUSEMACRO]="usemacro";
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

    //_waseof = +FALSE; //уже есть в setfin

    WHILE (!_waseof) {
      asmexport_line();
    };
    //todo поддержать TOK_EOF

    fclose(_fout);
    fclose(_fin); //closefin();
  };
}
