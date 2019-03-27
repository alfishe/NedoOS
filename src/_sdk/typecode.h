typedef BYTE TYPE;

#define _T_BYTE  (TYPE)(0x00)
#define _T_UINT  (TYPE)(0x01)
#define _T_INT   (TYPE)(0x02)
#define _T_BOOL  (TYPE)(0x03)
#define _T_LONG  (TYPE)(0x04)
#define _T_CHAR  (TYPE)(0x05) /**размер не обязательно равен байту*/
//#define _T_FLOAT (TYPE)(0x06)

#define _T_POI   (TYPE)(0x10) /**накладывается на тип по OR (для переменных)*/
#define _T_ARRAY (TYPE)(0x20) /**накладывается на тип по OR (для переменных/констант)*/
//#define _T_FARPOI (TYPE)(0x30) /**накладывается на тип по OR (для переменных)*/

#define _T_RECURSIVE (TYPE)(0x40) /**накладывается на тип по OR (для вызовов)*/
#define _T_CONST (TYPE)(0x40) /**накладывается на тип по OR (для переменных/констант)*/

#define _T_STRUCT (TYPE)(0x0f) /**накладывается на _T_POI, не равен _T_UNKNOWN*/
#define _T_STRUCTWORD (TYPE)(0x0e) /**накладывается на _T_POI, не равен _T_STRUCT - только для пропуска слова STRUCT*/
#define _T_UNKNOWN (TYPE)(0x2f) /**не накладывается*/
#define _T_PROC (TYPE)(0x3f) /**не накладывается, не равен _T_UNKNOWN. или накладывать для PPROC?*/

#define _T_TYPE (TYPE)(0x80) /**накладывается на тип по OR (для typedef, там может быть что угодно, кроме _T_PROC, _T_RECURSIVE)*/
//todo типность можно убрать в _istype (обнулять при старте и после тайпкаста)
//тогда будет 2 свободных бита (0x08, 0x80)

#define _TYPEMASK (TYPE)(0x1f) /**выделяет базовый тип и признак POI*/

