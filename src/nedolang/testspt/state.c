#include "script.h"
FUNC INT f(UINT p) {
  RETURN (INT)(3.1415926536e-4 + sin((FLOAT)(INT)p));
}

//константные массивы писать в constarr.c, иначе они будут недоступны!
//здесь только импортируем ссылки на них
EXTERN UINT arr[5];

//константные строки можно здесь:
CONST PCHAR str = "123";

FUNC UINT main(UINT par) {
/**
VAR UINT a;
VAR UINT b;
VAR PUINT arr = (PUINT)&Gotov1;
arr[25] = (UINT)f(0x12345678abcdef0);
if (Gotov1 != 0) {
  Gotov2 = Pusk;
  state = 2;
};
b = a;*/
  state = arr[0];
  RETURN (UINT)f(2);
}
