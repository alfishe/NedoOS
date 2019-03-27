//// imported
#include "../_sdk/io.h"

//CONST PCHAR CH_ADD;
CONST PCHAR fn;

CONST PBYTE RUNADDR;
CONST PBYTE PARADDR;

////

PROC batch()
{
VAR CHAR c;
VAR PCHAR pfn;
VAR PCHAR ppar;
VAR BOOL waswaseof;
  _fin = nfopen(fn, "rb");
  IF (_fin != (PBYTE)0) {
    _waseof = +FALSE;

    WHILE (!_waseof) {
//read command to (fn), (eol = ' ' or '\n' or EOF, skip 0x0d), end with '\0'
      pfn = fn;
      ppar = (PCHAR)PARADDR; //(PCHAR)(*(PUINT)CH_ADD);
      //POKE *(PCHAR)(ppar) = (CHAR)0xea; //REM
      //INC ppar;
      readcmd:
        c = (CHAR)readfin();
        IF (c == ' ') goto readcmdq; //read parameters
        IF ((c == '\n') || _waseof) goto readparq; //skip parameters
        IF ((BYTE)c != 0x0d) {
          POKE *(PCHAR)(pfn) = c;
          INC pfn;
        };
        goto readcmd;
      readcmdq:
//read parameters to (CH_ADD), (eol = '\n' or EOF, skip 0x0d), end with 0x0d
      readpar:
        c = (CHAR)readfin();
        IF ((c == '\n') || _waseof) goto readparq;
        IF ((BYTE)c != 0x0d) {
          POKE *(PCHAR)(ppar) = c;
          INC ppar;
        };
        goto readpar;
      readparq:
      POKE *(PCHAR)(pfn) = '\0';
      POKE *(PCHAR)(ppar) = (CHAR)0x0d;
//run command: load file (fn) to RUNADDR
      waswaseof = _waseof;
      IF ((UINT)loadfile(fn, RUNADDR) != 0/**RUNADDR*/) {
        CALL (RUNADDR);
      };
      _waseof = waswaseof;
//next line
    };
    fclose(_fin); //closefin();
  };
}
