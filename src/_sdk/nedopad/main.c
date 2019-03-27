#include <stdio.h>
#include <mem.h>
#include <string.h>

#define BYTE unsigned char
#define MAXDEFB 8

BYTE filebuf[65536];

void padfile(char * finname, char * foutname, int skip, int limit)
{
FILE* fin;
FILE* fout;
int i;
int size;

  fin = fopen(finname, "rb");
  if (fin) {
    fread(filebuf, 1, skip, fin);
    fout = fopen(foutname, "wb");
    if (fout) {
      while (1) {
        size = fread(filebuf, 1, MAXDEFB, fin);
        if (size == 0) {
          size = MAXDEFB;
          i = 0;
          while (1) {
            filebuf[i] = 0x00;
            i++;
            if (i == size) break;
          };
        };
        if (limit == 0) break;
        if (limit < size) size = limit;
        limit = limit - size;
        i = 0;
        while (1) {
          fputc(filebuf[i], fout);
          i++;
          if (i == size) break;
        };
      };
      fclose(fout);
    };
    fclose(fin);
  };
}

int main(int argc,char* argv[])
{
//  int i;
  char *finname;
  char *foutname;
  char *strskip;
  char *strlimit;
  int skip;
  int limit;
  finname = "tokarm.bin";
  foutname = "out.bin";
  strskip = "0";
  strlimit = "65536";

  if (argc<5) {
    printf(
      "NedoPAD\n"
      "\tnedopad.exe file.in file.out <skip> <size>\n"
    );
  }else {
    finname = argv[1];
    foutname = argv[2];
    strskip = argv[3];
    strlimit = argv[4];
  };

  skip = atoi(strskip);
  limit = atoi(strlimit);
  padfile(finname, foutname, skip, limit);

  return 0;
}