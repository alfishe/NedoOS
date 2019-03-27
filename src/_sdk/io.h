FUNC PBYTE nfopen FORWARD(PCHAR filename, PCHAR mode);
/*FUNC INT fclose FORWARD(PBYTE file);*/
/*FUNC INT fputs FORWARD(PCHAR s, PBYTE file);*/
/*FUNC INT fwrite FORWARD(PBYTE buf, UINT size, UINT n, PBYTE file);*/
/*FUNC INT fread FORWARD(PBYTE buf, UINT size, UINT n, PBYTE file);*/

EXTERN PBYTE _fin;
EXTERN PBYTE _fout;
EXTERN BOOL _waseof;

PROC writefout FORWARD(BYTE c);
PROC writebyte FORWARD(PBYTE file, BYTE c);
//PROC writeuint FORWARD(PBYTE file, UINT i);
//PROC writelong FORWARD(PBYTE file, LONG l);
FUNC BYTE readf FORWARD(PBYTE file);
FUNC BYTE readfin FORWARD();
FUNC UINT readfinuint FORWARD();
FUNC LONG readfinlong FORWARD();
PROC writearray FORWARD(PBYTE parray, UINT size, PCHAR filename);
FUNC PBYTE openwrite FORWARD(PCHAR s);
//PROC closewrite FORWARD(PBYTE file);

FUNC PBYTE loadfile FORWARD(PCHAR filename, PBYTE addr);

FUNC UINT readsectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
FUNC UINT writesectors FORWARD(PBYTE buf, UINT trsec, BYTE count);

FUNC PCHAR findlastslash FORWARD(PCHAR s);
//FUNC BOOL comparedesc FORWARD(PCHAR filename, PBYTE desc);

//do define:
//FCB1 ;aligned ;len=0x0200*files
//DOSBUF ;aligned ;len=0x100
