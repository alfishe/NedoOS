EXTERN UINT _TIMER;
EXTERN BYTE _SONGPG;
EXTERN BYTE _CURSCR;
EXTERN BYTE _PAUSED;
PROC setim FORWARD(UINT vectoraddr); //divisible by 0x100 //reserves 0x200 bytes
PROC setimffff FORWARD();
PROC im1 FORWARD(); //im 1:ld i,0x3f
PROC set7ffd FORWARD(BYTE pg); //out (0x7ffd),pg|_CURSCR
PROC setborder FORWARD(BYTE n); //out (0xfe),n
PROC halter FORWARD(); //halt

//do define:
//_IMSTACK
//_CURBORDER
//PROC _USERINT1 (before music)
//PROC _USERINT2 (after music)
