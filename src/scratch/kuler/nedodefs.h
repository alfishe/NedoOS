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


