#include "../_sdk/io.h"
#include "../_sdk/str.h"

VAR BYTE psystrk[0x900];

FUNC BOOL comparedesc(PCHAR filename, PBYTE desc)
{
VAR CHAR c;
VAR BOOL res;
VAR BYTE i = 0x08;
  filename = findlastslash(filename);
  loop:
    c = *(PCHAR)filename;
    INC filename;
    IF (c == '.') { //todo test '\0', descbuf all spaces
      dot:
      //desc = (PBYTE)((UINT)desc + (UINT)i);
      res = (*(PCHAR)((UINT)desc + (UINT)i) == *(PCHAR)filename);
      goto quit;
    };
    IF (c != *(PCHAR)desc) {
      res = +FALSE;
      goto quit;
    };
    INC desc;
    DEC i;
    IF (i == 0x00) {
      c = *(PCHAR)filename;
      INC filename;
      //IF (c == '.') 
              goto dot;
      //res = (*(PCHAR)desc == ' '); //filenam8 (without ext) //TODO
      //goto quit;
    };
    goto loop;
  quit:
RETURN res;
}

PROC main(PCHAR fn)
{
VAR BYTE nerased;
//VAR BYTE nfiles;
VAR PBYTE curfiledesc;
  //читаем системную дорожку
  readsectors((PBYTE)psystrk, 0x0000, 0x09);
  //nfiles = psystrk[0x8e4];
  nerased = psystrk[0x8f4];
  
  //текущий файловый дескриптор = &psystrk[0x0000]
  curfiledesc = (PBYTE)psystrk;
  loop:
    //ищем неудалённый файл
    IF (*(PBYTE)curfiledesc == 0x00) goto quit;
    IF (comparedesc(fn, curfiledesc)) {
      //корректируем директорию
      curfiledesc[0] = 0x01; //erased
      //DEC nfiles;
      INC nerased;
    };
    //переходим к следующему дексриптору
    curfiledesc = &curfiledesc[16];
    //повторяем до 0
  goto loop;
  quit:

  //корректируем системный сектор
  //psystrk[0x8e4] = nfiles; //number of files
  psystrk[0x8f4] = nerased; //number of erased files
  //пишем системную дорожку
  writesectors((PBYTE)psystrk, 0x0000, 0x09);
}
