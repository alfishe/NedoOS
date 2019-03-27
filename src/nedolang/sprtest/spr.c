//// imported
#include "../_sdk/sprite.h"
#include "../_sdk/ayfxplay.h"
#include "../_sdk/runtime.h"

VAR BYTE _CURBORDER;
CONST UINT _IMSTACK = 0x5f00;

PROC halter FORWARD();
PROC border FORWARD(BYTE col);
FUNC BYTE random FORWARD();
PROC prch FORWARD(UINT addr, CHAR c);
PROC testscr FORWARD();

PROC readkeys FORWARD(PBYTE pkeys);
VAR BYTE pkeys[40];
ENUM {
  _KEY_CAPS,
  _KEY_Z,
  _KEY_X,
  _KEY_C,
  _KEY_V,
  
  _KEY_A,
  _KEY_S,
  _KEY_D,
  _KEY_F,
  _KEY_G,
  
  _KEY_Q,
  _KEY_W,
  _KEY_E,
  _KEY_R,
  _KEY_T,
  
  _KEY_1,
  _KEY_2,
  _KEY_3,
  _KEY_4,
  _KEY_5,
  
  _KEY_0,
  _KEY_9,
  _KEY_8,
  _KEY_7,
  _KEY_6,
  
  _KEY_P,
  _KEY_O,
  _KEY_I,
  _KEY_U,
  _KEY_Y,
  
  _KEY_ENTER,
  _KEY_L,
  _KEY_K,
  _KEY_J,
  _KEY_H,
  
  _KEY_SPACE,
  _KEY_SYMBOL,
  _KEY_M,
  _KEY_N,
  _KEY_B
};

EXTERN UINT _emptytile;

CONST UINT tilepic;

CONST UINT doska;
CONST UINT beton;
CONST UINT cherry;
CONST UINT arrspr;
CONST UINT ballspr;
CONST UINT bigspr;
CONST UINT bigspr32;

////

STRUCT sprpos{
  BYTE x;
  BYTE y;
  PBYTE data;
}; //4

VAR UINT _wastimer;
VAR UINT _curtimer;
VAR UINT _logicframes;

CONST BYTE scrx   = 0x01;
CONST BYTE scry   = 0x01;
CONST BYTE scrwid = 0x1e;
CONST BYTE scrhgt = 0x14;

VAR BYTE sprposbuf[1024];
VAR sprpos* psprpos;
VAR UINT nsprpos;

PROC begin_sprites()
{
  psprpos = (sprpos*)sprposbuf;
  nsprpos = 0;
}

PROC prspr_memorize(BYTE x, BYTE y, PBYTE data) //draw sprite in scrbuf, memorize its position in sprpos
{
  prspr(x, y, data);
  psprpos->x = x;
  psprpos->y = y;
  psprpos->data = data;
  psprpos = (sprpos*)((UINT)psprpos + +sizeof(sprpos));
  INC nsprpos;
}

PROC restore_sprites()
{
  psprpos = (sprpos*)sprposbuf;
  WHILE (nsprpos!=0) {
    respr(psprpos->x, psprpos->y, psprpos->data);
    //todo перепечатать ещё нетайловые объекты фона в этом прямоугольнике
    psprpos = (sprpos*)((UINT)psprpos + +sizeof(sprpos));
    DEC nsprpos;
  };
}

PROC demo()
{
VAR BYTE x;
VAR BYTE y;
VAR BYTE xshift;
//  setborder(0x00);

  //clearscrbuf(0x07); //attr
  cleartilemap((PBYTE)emptytile);
  //prtilebox(0x01, 0x01, 0x05, 0x05); //update scrbuf from portion of tilemap

  pretile(0x01, 0x01, 0x1c, 0x08, (PBYTE)((UINT)tilepic+((/**x_in_tilemap*/0/8)*9)+((/**y_in_tilemap*/0/8)*0x100)));
  
  //pretile(0x02, 0x02, 0x04, 0x01, (PBYTE)doska);
  //pretile(0x02, 0x02, 0x04, 0x01, (PBYTE)((UINT)tilepic+((/**x_in_tilemap*/112/8)*9)+((/**y_in_tilemap*/0/8)*0x100)));

  //pretile(0x03, 0x04, 0x04, 0x01, (PBYTE)beton);
  //pretile(0x03, 0x04, 0x04, 0x01, (PBYTE)((UINT)tilepic+((/**x_in_tilemap*/80/8)*9)+((/**y_in_tilemap*/0/8)*0x100)));

  pretile(0x03, 0x10, 0x05, 0x02, (PBYTE)((UINT)tilepic+((/**x_in_tilemap*/0/8)*9)+((/**y_in_tilemap*/72/8)*0x100)));
  
  prtilebox(scrx, scry, scrwid, scrhgt); //update scrbuf from tilemap

  xshift = 0x00;
  
  _curtimer = _TIMER;
loop:
  
  _wastimer = _curtimer;

  readkeys(pkeys);
  
  begin_sprites();
  
  x = 0x00 + xshift;
  y = 0x00;
  prspr_memorize(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;

  x = 0x40 - xshift;
  y = 0x00;
  prspr_memorize(x, y, (PBYTE)cherry); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)ballspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)cherry); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)cherry); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)ballspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)ballspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)ballspr); INC x; y = y + 0x11;
  prspr_memorize(x, y, (PBYTE)ballspr); INC x; y = y + 0x11;

  x = 0x80 + xshift;
  y = 0x00;
  prspr_memorize(x, y, (PBYTE)bigspr); INC x; y = y + 0x17;
  prspr_memorize(x, y, (PBYTE)bigspr); INC x; y = y + 0x17;
  prspr_memorize(x, y, (PBYTE)bigspr); INC x; y = y + 0x17;
  prspr_memorize(x, y, (PBYTE)bigspr); INC x; y = y + 0x17;
  prspr_memorize(x, y, (PBYTE)bigspr); INC x; y = y + 0x17;
  prspr_memorize(x, y, (PBYTE)bigspr); INC x; y = y + 0x17;
  prspr_memorize(x, y, (PBYTE)bigspr); INC x; y = y + 0x17;
  prspr_memorize(x, y, (PBYTE)bigspr); INC x; y = y + 0x17;

  x = 0xc0 - xshift;
  y = 0x00;
  prspr_memorize(x, y, (PBYTE)bigspr32); INC x; y = y + 0x15;
  prspr_memorize(x, y, (PBYTE)bigspr32); INC x; y = y + 0x15;
  prspr_memorize(x, y, (PBYTE)bigspr32); INC x; y = y + 0x15;
  prspr_memorize(x, y, (PBYTE)bigspr32); INC x; y = y + 0x15;
  prspr_memorize(x, y, (PBYTE)bigspr32); INC x; y = y + 0x15;
  prspr_memorize(x, y, (PBYTE)bigspr32); INC x; y = y + 0x15;
  prspr_memorize(x, y, (PBYTE)bigspr32); INC x; y = y + 0x15;
  prspr_memorize(x, y, (PBYTE)bigspr32); INC x; y = y + 0x15;

  halter();
  showscr();
  testscr();
  
  //prtilebox(scrx, scry, scrwid, scrhgt); //update scrbuf from tilemap
  restore_sprites(); //update portions of scrbuf from tilemap
/**
  x = 0x00 + xshift;
  y = 0x00;
  respr(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  respr(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  respr(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  respr(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
  respr(x, y, (PBYTE)arrspr); INC x; y = y + 0x11;
*/
  _curtimer = _TIMER;
  _logicframes = _curtimer - _wastimer;
  IF (_logicframes > 4) _logicframes = 4;
  WHILE (_logicframes != 0) {
    
    IF (pkeys[+_KEY_P]==0x00) {
            INC xshift;
            IF ((xshift&0x03) == 0x00) afxPLAY((xshift>>0x02)&0x0f, 0x00);
    };
    IF (pkeys[+_KEY_O]==0x00) DEC xshift;
    DEC _logicframes;
  };
  
  goto loop;
}
