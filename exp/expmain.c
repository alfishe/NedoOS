#include <stdio.h>

#include "../_sdk/nedodefs.h" //C only

#include "../_sdk/emit.c" //нужно дл€ compile и asm (иначе не вывести ошибки)

#include "../_sdk/read.c" //нужно дл€ compile и token

#include "../_sdk/fmttg.h" //нужно дл€ token, asm, export

#include "exporttg.c"
#include "export.c"

int main(int argc,char* argv[])
{
  int i;
  char *filename;

  for (i=1; i<argc; i++) {
    filename = argv[i];
    asmexport(filename);
  }; //for

  return 0;
}
