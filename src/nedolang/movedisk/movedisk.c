#include "../_sdk/io.h"
#include "../_sdk/str.h"

VAR PBYTE psystrk; //[0x900];
#define BUFSECTORS 0x40
#define BUFSIZE (UINT)(BUFSECTORS*0x100)
VAR PBYTE buf; //[BUFSIZE]

FUNC UINT copybody(UINT from, UINT to, BYTE count)
{
VAR UINT nextrdsector;
VAR UINT nextwrsector;
VAR BYTE wrsectors;
IF (from==to) {
  nextwrsector = ((to&0xff00) >> 4) + (UINT)((BYTE)to&0x0f) + (UINT)count;
  nextwrsector = ((nextwrsector << 4)&0xff00) + (UINT)((BYTE)nextwrsector&0x0f);
}ELSE {
  nextrdsector = from;
  nextwrsector = to;
  WHILE (count > 0x00) {
    IF (count >= BUFSECTORS) {
      wrsectors = BUFSECTORS;
    }ELSE {
      wrsectors = count;
    };
    nextrdsector = readsectors(buf, nextrdsector, wrsectors);
    nextwrsector = writesectors(buf, nextwrsector, wrsectors);
    count = count - wrsectors;
  };
};
RETURN nextwrsector;
}

PROC movedisk()
{
VAR UINT wasfreeplace; //
VAR UINT freeplace; //куда пишем тело файла
VAR PBYTE curfiledesc; //откуда читаем дескриптор
VAR PBYTE freefiledesc; //куда пишем дескриптор
VAR UINT nfreesectors;
VAR BYTE nfiles;
VAR BYTE count;
  buf = (PBYTE)0x8000;
  psystrk = (PBYTE)0xc000;

  //читаем системную дорожку
  readsectors((PBYTE)psystrk, 0x0000, 0x09);
  nfiles = 0x00; //psystrk[0x8e4];
  nfreesectors = *(PUINT)(&psystrk[0x8e5]);
  //начало свободного места = 0x0100
  freeplace = 0x0100;
  freefiledesc = (PBYTE)psystrk;
  //текущий файловый дескриптор = &psystrk[0x0000]
  curfiledesc = (PBYTE)psystrk;
  loop:
    //ищем неудалённый файл
    IF (*(PBYTE)curfiledesc == 0x00) goto quit;
    count = curfiledesc[0x0d]; //размер в секторах
    IF (*(PBYTE)curfiledesc == 0x01) {
      nfreesectors = nfreesectors + (UINT)count;
      goto next;
    };
    //перебрасываем тело файла в начало пустого места
    wasfreeplace = freeplace;
    freeplace = copybody(*(PUINT)(&curfiledesc[0x0e]), freeplace, count);
    //корректируем директорию
    memcopy(curfiledesc, 14, freefiledesc);
    POKE *(PUINT)(&freefiledesc[0x0e]) = wasfreeplace;
    freefiledesc = &freefiledesc[16];
    INC nfiles;
    next:
    //переходим к следующему дексриптору
    curfiledesc = &curfiledesc[16];
    //повторяем до 0
  goto loop;
  quit:
  
  WHILE (freefiledesc[0] != 0x00) {
    freefiledesc[0] = 0x00; //end of directory
    freefiledesc = &freefiledesc[16];
  };
  
  //корректируем системный сектор
  POKE *(PUINT)(&psystrk[0x8e1]) = freeplace;
  psystrk[0x8e4] = nfiles; //number of files
  POKE *(PUINT)(&psystrk[0x8e5]) = nfreesectors;
  psystrk[0x8f4] = 0x00; //number of erased files
  //пишем системную дорожку
  writesectors((PBYTE)psystrk, 0x0000, 0x09);
}
