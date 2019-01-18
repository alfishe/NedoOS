//// imported
#include "../_sdk/io.h"
#include "../_sdk/print.h"

VAR PBYTE _fin2;

////

PROC diff(PCHAR fn1, PCHAR fn2)
{
VAR BYTE b;
VAR BYTE b2;
VAR UINT errors;
VAR UINT addr;
VAR BOOL waswaseof;
  errors = 0;
  addr = 0;
  setxy(0x00,0x00);
  _fin = nfopen(fn1, "rb");
  IF (_fin != (PBYTE)0) {
    _waseof = +FALSE;
    _fin2 = nfopen(fn2, "rb");
    IF (_fin2 != (PBYTE)0) {
      WHILE (!_waseof) {
        b = readfin();
        waswaseof = _waseof;
        fread((PBYTE)&b2, +sizeof(BYTE), 1, _fin2);
        IF (waswaseof != _waseof) {
          nprintf("invalid file size!\n");
          goto quit;
        }ELSE IF (b != b2) {
          nprintf("addr=%x f1=%x f2=%x\n", addr, (UINT)b, (UINT)b2);
          INC errors;
          IF (errors == 8) goto quit;
        };
        INC addr;
      };
      IF (errors == 0) nprintf("files %s, %s are equal", (UINT)fn1, (UINT)fn2);
      quit:
      fclose(_fin2);
    };
    fclose(_fin);
  };
}
