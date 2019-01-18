#include <stdio.h>

#include "../_sdk/nedodefs.h" //C only

#define USE_HINTS
#define USE_COMMENTS

#include "../_sdk/emit.c" //нужно дл€ compile и asm (иначе не вывести ошибки)

#include "../_sdk/read.c" //нужно дл€ compile и token

//#include "codetg.c"
//#include "regs.c"
#include "commands.c"
#include "compile.c"

//#include "fmttg.h" //нужно дл€ token, asm, export
/**
struct zzz{
  BYTE ba;
  LONG lb;
  STRUCT zzz* pc;
};

CONST struct zzz zuzu={
  0x03,
  5L,
  &zuzu
};
*/
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
//VAR STRUCT zzz* pzz1 = &zuzu;
//VAR PBYTE pp = &(pzz1->ba);

  _ferr = openwrite("err.f");
  _errs = +TRUE;

  //filename = "_test.c";
  //_asms = +TRUE;
  _cmts = +FALSE;
  _hints = +FALSE;

  for (i=1; i<argc; i++) {
    if      ((argv[i][0]=='-')&&(argv[i][1]=='C')) {_cmts = +TRUE;
    }else if((argv[i][0]=='-')&&(argv[i][1]=='H')) {_hints = +TRUE;
    }else {
      filename = argv[i];
      compile(filename);
      writearray((PBYTE)/**_lblbuf*/_lbls, /**_lblbufindex*//**_lblbuflen+0x200*/_LBLBUFSZ, "label.f");
  /**
      system("del asm.f");
      system("copy _test.asm asm.f");

      _fout = openwrite("tok.f"); //setfout( "ftok" ); //AssignFile(fout,'fout'); Rewrite(fout);
      _curline = 1;
      tokenize("asm.f");
      tokenize_end();
      closewrite(_fout); //closefout(); //CloseFile(fout);

      asmcompile();
    writearray((PBYTE)_labels0, _LABELPAGESIZE, "label0.f");
  */
    };
  }; //for

  closewrite(_ferr);

  return 0;
}
