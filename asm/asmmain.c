#include <stdio.h>

#include "../_sdk/nedodefs.h" //C only

#include "../_sdk/emit.c" //нужно для compile и asm (иначе не вывести ошибки)

#include "../_sdk/fmttg.h" //нужно для token, asm, export

#include "asm.c"

#include "asmloop.c"

PROC writearray(PBYTE parray, UINT size, PCHAR filename)
{
VAR PBYTE file;
  file = fopen(filename, "wb");
  fwrite(parray, size, 1, file);
  fclose(file);
}

int main(int argc,char* argv[])
{
  int i;
  char *filename;

  _ferr = openwrite("asmerr.f");
  _errs = +TRUE;

  for (i=1; i<argc; i++) {
    filename = argv[i];
    asmcompile(filename);
    writearray((PBYTE)_labels0, _LABELPAGESIZE, "label0.f");
    //writearray((PBYTE)_labels1, _LABELPAGESIZE, "label1.f");
    //writearray((PBYTE)_labels2, _LABELPAGESIZE, "label2.f");
    //writearray((PBYTE)_labels3, _LABELPAGESIZE, "label3.f");
    //writearray((PBYTE)_labels4, _LABELPAGESIZE, "label4.f");
    //writearray((PBYTE)_labels5, _LABELPAGESIZE, "label5.f");
    //writearray((PBYTE)_labels6, _LABELPAGESIZE, "label6.f");
    //writearray((PBYTE)_labels7, _LABELPAGESIZE, "label7.f");
  }; //for

  closewrite(_ferr);

  return 0;
}
