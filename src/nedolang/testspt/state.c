#include "script.h"
goto main;

FUNC FLOAT sin FORWARD(FLOAT x);
FUNC FLOAT cos FORWARD(FLOAT x);
FUNC FLOAT atan FORWARD(FLOAT x);
FUNC FLOAT atan2 FORWARD(FLOAT x,FLOAT y);
FUNC FLOAT exp FORWARD(FLOAT x);
FUNC FLOAT log FORWARD(FLOAT x);
FUNC FLOAT sqrt FORWARD(FLOAT x);
FUNC FLOAT abs FORWARD(FLOAT x);

FUNC INT f(UINT p) {
  RETURN (INT)(3.1415926536e-4 + sin((FLOAT)(INT)p));
}

main:
VAR UINT a;
VAR UINT b;
VAR PUINT arr = (PUINT)&Gotov1;
arr[25] = (UINT)f(0x12345678abcdef0);
if (Gotov1 != 0) {
  Gotov2 = Pusk;
  state = 2;
};
b = a;