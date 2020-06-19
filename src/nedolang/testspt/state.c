#include "script.h"
/**goto main;

CONST PCHAR str[2] = {"123","456"};

FUNC INT f(UINT p) {
  RETURN (INT)(3.1415926536e-4 + sin((FLOAT)(INT)p));
}

main:
VAR UINT a;
VAR UINT b;
VAR PCHAR s = str[0];
VAR PUINT arr = (PUINT)&Gotov1;
arr[25] = (UINT)f(0x12345678abcdef0);
if (Gotov1 != 0) {
  Gotov2 = Pusk;
  state = 2;
};
b = a;*/
state = 1;
