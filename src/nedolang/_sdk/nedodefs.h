//#ifdef __BORLANDC__
//typedef unsigned long intptr_t;
//#else
//#include <stdint.h>
//#endif

#define BIGMEM

#define TRUE 0xff
#define FALSE 0x00
#define CONST const
#define CHAR char
#define BYTE unsigned char
#ifdef TARGET_THUMB
#define INT int
#else
#define INT short int
#endif
#define UINT unsigned INT
#ifdef TARGET_THUMB
#define LONG unsigned long
#else
#define LONG unsigned int
#endif
//#define FLOAT double
#define BOOL unsigned char
#define PBYTE BYTE*
#define PCHAR CHAR*
#define PBOOL BOOL*
#define PINT INT*
#define PUINT UINT*
#define PLONG LONG*
//#define PFLOAT FLOAT*
//#define POINTER intptr_t
//#define PPROC void*
//#define PPOI void**
#define EXTERN extern
#define FORWARD /**/
#define FUNC /**/
#define PROC void
#define BREAK break
#define RETURN return
#define VAR /**/
#define RECURSIVE /**/
#define POKE /**/
#define IF(x) if(x)
//#define IFNOT(x) if(!(x))
//#define IFZ(x) if(!(x))
//#define IFNZ(x) if(x)
#define ELSE else
#define WHILE(x) while(x)
//#define WHILENOT(x) while(!(x))
//#define WHILEZ(x) while(!(x))
//#define WHILENZ(x) while(x)
#define REPEAT do
#define UNTIL(x) while(!(x));
//#define UNTILNOT(x) while(x);
//#define UNTILZ(x) while(x);
//#define UNTILNZ(x) while(!(x));
#define ENUM enum
#define INC ++
#define DEC --
#define CALL(x) ((void(*)(void))(x))() /**если просто x, то нельзя выражение*/
#define STRUCT struct
#define TYPEDEF struct
#define EXPORT /**/

#include "../_sdk/str.h"

VAR PBYTE _fin;
VAR PBYTE _fout;
VAR BOOL _waseof;
//CONST UINT _STRLEN; /**включая 0*/
//CONST UINT _STRMAX; /**не включая 0*/

FUNC BYTE readfin()
{
VAR BYTE c;
  //rd(handle, &c, 1);
  IF (+(UINT)fread(/*+*/(PBYTE)&c, +sizeof(BYTE), 1, (FILE*)_fin) == 0) {
    _waseof = +TRUE;
    c = '\n'; //EOF returns '\n'
  };
  RETURN c;
}

FUNC BYTE readf(PBYTE file)
{
VAR BYTE c;
  //rd(handle, &c, 1);
  IF (+(UINT)fread(/*+*/(PBYTE)&c, +sizeof(BYTE), 1, (FILE*)file) == 0) {
    _waseof = +TRUE;
    c = '\n'; //EOF returns '\n'
  };
  RETURN c;
}

PROC writefout(BYTE c)
{
  //writebyte(_fout, token);
  fwrite(/*+*/(PBYTE)&c, +sizeof(BYTE), 1, (FILE*)_fout);
}

FUNC PBYTE nfopen(PCHAR s, PCHAR mode)
{
/**UINT i;
CHAR __fn[256];
  i = 0;
  WHILE (s[i] != '\0') {
    IF (s[i] == '/') {
      __fn[i] = '\\';
    }ELSE {
      __fn[i] = s[i];
    };
    INC i;
  };
  __fn[i] = '\0';*/
  RETURN (PBYTE)fopen(s/**__fn*/, mode);
}

FUNC PBYTE openwrite(PCHAR s)
{
  RETURN nfopen(s, "wb");
}

PROC closewrite(PBYTE file)
{
  fclose((FILE*)file);
}

PROC writebyte(PBYTE file, BYTE c)
{
  //fprintf(file,"%c",c);
  fwrite(/*+*/(PBYTE)&c, +sizeof(BYTE), 1, (FILE*)file);
}

#include "../_sdk/str.c"

FUNC UINT readfinstr(PBYTE pstr)
{
VAR UINT len;
VAR BYTE c;
  len = 0;
readfinstr0:
  c = readfin(); //EOF даёт '\n'
  IF (c==0x0d) goto readfinstr0; //skip 0x0d
  IF (c==+(BYTE)'\n') goto readfinstrq; //EOL or EOF
  POKE *(PBYTE)pstr = c;
  INC pstr;
  INC len;
  IF (len<_STRMAX) goto readfinstr0;
readfinstrq:
  POKE *(PBYTE)pstr = 0x00;
  INC len;
  RETURN len;
};
