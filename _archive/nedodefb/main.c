#include <stdio.h>
#include <mem.h>
#include <string.h>

#define BYTE unsigned char
#define MAXDEFB 8

BYTE filebuf[65536];

void defbfile(char * finname, char * foutname, char * labelname, int skip, int limit)
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
      if (labelname[0]!='\0') {
        fputs(labelname, fout);
        fputs("\n", fout);
      };
      while (1) {
        size = fread(filebuf, 1, MAXDEFB, fin);
        if (size == 0) break;
        if (limit == 0) break;
        if (limit < size) size = limit;
        limit = limit - size;
        fputs("\tdb ", fout);
        i = 0;
        while (1) {
          //fputs("0x", fout);
          fprintf(fout, "0x%x%x", filebuf[i]>>4, filebuf[i]&0x0f);
          i++;
          if (i == size) break;
          fputs(",", fout);
        };
        fputs("\n", fout);
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
  char *labelname;
  char *strskip;
  char *strlimit;
  int skip;
  int limit;
  finname = "testmusic.pt3";
  foutname = "testmusic.asm";
  labelname = "";
  strskip = "0";
  strlimit = "65280";

  if (argc<6) {
    printf(
      "NedoDEFB\n"
      "\tnedodefb.exe file.bin file.asm label 6144 768\n"
    );
  }else {
    finname = argv[1];
    foutname = argv[2];
    labelname = argv[3];
    strskip = argv[4];
    strlimit = argv[5];
  };

  skip = atoi(strskip);
  limit = atoi(strlimit);
  defbfile(finname, foutname, labelname, skip, limit);

  return 0;
}