#include <stdio.h>
#include <stdlib.h>
//#include <mem.h>
#include <string.h>

#define BYTE unsigned char
#define BOOL unsigned char
#define FALSE 0x00
#define TRUE 0xff
#define TRDSIZE 655360
#define BLOCKSIZE 65280/*32768*/
#define DESCSIZE 16

BYTE trd[TRDSIZE];
BYTE filebuf[TRDSIZE];
BYTE descbuf[DESCSIZE+1]; //for hobeta

const BYTE trdheader[0x20] = {
0x00,0x00,0x01,0x16,0x00,0xf0,0x09,0x10, 0x00,0x00,0x20,0x20,0x20,0x20,0x20,0x20,
0x20,0x20,0x20,0x00,0x00,0x20,0x20,0x20, 0x20,0x20,0x20,0x20,0x20,0x00,0x00,0x00
};

BOOL verbose;
BOOL ishobeta;

int readtrd(char * trdname)
{
FILE* file;
int result;
  file = fopen(trdname, "rb");
  if (file) {
    if (verbose) {printf("opened trd: %s\n",trdname); };
    fread(trd, 1, TRDSIZE, file);
    fclose(file);
    result = 1;
  }else {
    printf("trd not found: %s\n",trdname);
    result = 0;
  };
return result;
}

void writetrd(char * trdname)
{
FILE* file;
  file = fopen(trdname, "wb");
  if (file) {
    fwrite(trd, 1, TRDSIZE, file);
    fclose(file);
  };
}

void genname(char * filename)
{
int i;
int j;
char c;
  j = 0;
  while (j<9) {
    descbuf[j] = ' ';
    j++;
  };
  descbuf[9] = 0x00;
  descbuf[10] = 0x00;
  //find last backslash
  i = 0;
  j = 0;
  while (filename[i] != '\0') {
    if ((filename[i] == '\\') || (filename[i] == '/')) j = i + 1; //after backslash
    i++;
  };
  i = j; //after last backslash
  //copy to descbuf: [i] => [j]
  j = 0;
  while (j<9) {
    c = filename[i]; if (c=='\0') break;
    i++;
    if (c=='.') {
      c = filename[i]; if (c=='\0') break;
      if (ishobeta) if (c=='$') i++;
      c = filename[i]; if (c=='\0') break;
      i++;
      descbuf[8] = c;
      c = filename[i]; if (c=='\0') break;
      i++;
      descbuf[9] = c;
      c = filename[i]; if (c=='\0') break;
      i++;
      descbuf[10] = c;
      break;
    };
    descbuf[j] = c;
    j++;
  };
}

long finddesc(int namelen, int ignorereg) //return descriptor address or -1 if not found
{
long descaddr;
long result;
int i;
BYTE err;
  result = -1;
  descaddr = 0;
  while (trd[descaddr] != 0) {
    err = 0;
    i = 0;
    while (i < namelen) { //name, ext, block
      if (ignorereg) {
        err = err | ( ((BYTE)trd[descaddr+i]|(BYTE)0x20) ^ ((BYTE)descbuf[i]|(BYTE)0x20) );
      }else {
        err = err | (trd[descaddr+i]^descbuf[i]);
      };
      i++;
    };
    if (err == 0) {
      result = descaddr;
      break;
    };
    descaddr = descaddr + DESCSIZE;
  };
/**  if (result == -1) printf("\"%c%c%c%c%c%c%c%c.%c\" not found\n",
    descbuf[0],
    descbuf[1],
    descbuf[2],
    descbuf[3],
    descbuf[4],
    descbuf[5],
    descbuf[6],
    descbuf[7],
    descbuf[8]
  );*/
return result;
}

void extractfile(char * trdname, char * filename)
{
FILE* fout;
int descaddr;
int addr; //in sectors
BYTE block;
int wrsize;
  if (readtrd(trdname)) {
    fout = fopen(filename, "wb");
    if (fout) {
      genname(filename);

      block = 0;
      do {
        //descbuf[9] = block;
        descaddr = finddesc(10, 0); //name, ext, block
        wrsize = 0;
        if (descaddr != -1) {
          wrsize = trd[descaddr+11] + trd[descaddr+12]*256;
          addr = trd[descaddr+14] + trd[descaddr+15]*16;
          block++;
          descbuf[9] = (BYTE)descbuf[9]+(BYTE)0x01;
        };
        if (wrsize != 0) {
          fwrite(trd+(addr<<8), 1, wrsize, fout);
        };
      }while (wrsize != 0);

      if (block == 0) {
        printf("%s not found\n",filename);
      }else {
        printf("extracted %s\n",filename);
      };

      fclose(fout);
    };
  };
}

void extractbinary(char * trdname, char * filename)
{
FILE* fout;
int descaddr;
int addr; //in sectors
int wrsize;
  if (readtrd(trdname)) {
    fout = fopen(filename, "wb");
    if (fout) {
      genname(filename);

      descaddr = finddesc(9, 0); //name, ext, block
      wrsize = 0;
      if (descaddr != -1) {
        wrsize = trd[descaddr+11] + trd[descaddr+12]*256;
        addr = trd[descaddr+14] + trd[descaddr+15]*16;
        printf("extracted %s\n",filename);
      }else {
        printf("%s not found\n",filename);
      };
      if (wrsize != 0) {
        fwrite(trd+(addr<<8), 1, wrsize, fout);
      };

      fclose(fout);
    };
  };
}

void extracthobeta(char * trdname, char * filename)
{
FILE* fout;
int descaddr;
int addr; //in sectors
int wrsize;
unsigned int checksum;
int i;
  if (readtrd(trdname)) {
    fout = fopen(filename, "wb");
    if (fout) {
      genname(filename);
  /**
  Пеpвые 13 байт - точная копия тpдосного заголовка. Далее два байта длины
  в сектоpах; т.к. она кpатна 256, то пеpвый всегда ноль, а втоpой -
  число сектоpов. А последние два байта - контpольная сумма. Считается
  она пpосто - суммиpуются все пpедыдущие 15 байт, число умножается на
  257 и пpибавляется сумма_чисел_от_0_до_14 т.е. 105.
  Вот пpоцедуpка на Z80 Asm:
  ; на вход de = адpес заголовка
  ld hl,0
  ld b,15
  m1: ld a,(de)
  add a,l
  ld l,a
  jr nc,m2
  inc h
  m2: inc de
  djnz m1
  add a,h
  ld h,a
  ld c,105
  add hl,bc ; hl = Hobeta sum
  */
      descaddr = finddesc(9, 1); //name, ext
      if (descaddr != -1) {
        memcpy(descbuf, trd+descaddr, DESCSIZE); //descriptor
        wrsize = trd[descaddr+13]*256;
        addr = trd[descaddr+14] + trd[descaddr+15]*16;
        descbuf[14] = descbuf[13];
        descbuf[13] = 0;
        for (i=0; i<=14; checksum = checksum + (descbuf[i] * 257) + i, i++);
        descbuf[15] = (BYTE)checksum;
        descbuf[16] = (BYTE)(checksum>>8);
        fwrite(descbuf, 1, 17, fout);
        fwrite(trd+(addr<<8), 1, wrsize, fout);
        printf("extracted %s\n",filename);
      }else {
        printf("%s not found\n",filename);
      };

      fclose(fout);
    };
  };
}

void addfile(char * trdname, char * filename, int iscode, int startaddr)
{
FILE* fin;
long descaddr;
long addr; //in sectors
long size;
long wrsize;
long secsize;
long index;
long free;
BYTE block;
long maxsize;
  if (readtrd(trdname)) {
    fin = fopen(filename, "rb");
    if (fin) {
      size = fread(filebuf, 1, TRDSIZE, fin);

      genname(filename);
      if (iscode) {
        descbuf[8] = 'C';
        maxsize = 65280;
      }else {
        maxsize = BLOCKSIZE;
      };

      index = 0;
      if (iscode) {
        block = (BYTE)startaddr;
      }else {
        block = descbuf[9];
      };
      while (size > 0) {

        if (size > maxsize) {
          wrsize = maxsize;
        }else {
          wrsize = size;
        };
        descbuf[9] = block;
        if (iscode) {
          descbuf[10] = (BYTE)(startaddr>>8);
        };
        descbuf[11] = (BYTE)wrsize;
        descbuf[12] = (BYTE)(wrsize>>8);
        secsize = (wrsize+255)>>8;
        descbuf[13] = (BYTE)secsize;

        addr = trd[0x08e1] + (((long)trd[0x08e2])<<4); //first free sector, track
        memcpy(trd+(addr<<8), filebuf+index, wrsize); //data
        descbuf[14] = (BYTE)(addr&0x0f); //sector
        descbuf[15] = (BYTE)(addr>>4); //track
        addr = addr + secsize;
        trd[0x08e1] = (BYTE)(addr&0x0f); //first free sector
        trd[0x08e2] = (BYTE)(addr>>4); //first free track

        descaddr = ((long)trd[0x08e4])<<4; //files
        trd[0x08e4]++; //files
        free = trd[0x08e5] + 256*trd[0x08e6]; //free
        free = free - secsize;
        trd[0x08e5] = (BYTE)free;
        trd[0x08e6] = (BYTE)(free>>8);

        memcpy(trd+descaddr, descbuf, DESCSIZE); //descriptor

        size = size - maxsize;
        index = index + maxsize;
        block++;
      };
      fclose(fin);
    };
    writetrd(trdname);
  };
}

void addhobeta(char * trdname, char * filename)
{
FILE* fin;
long descaddr;
long addr; //in sectors
long size;
long wrsize;
long secsize;
long index;
long free;
int i;
  if (readtrd(trdname)) {
    fin = fopen(filename, "rb");
    if (fin) {
      size = fread(filebuf, 1, TRDSIZE, fin);
      if (size >= 17) {
        wrsize = size - 17;
        index = 17;

        i = 0;
        while (i<13) {
          descbuf[i] = filebuf[i];
          i++;
        };
        secsize = filebuf[14];
        descbuf[13] = (BYTE)secsize;

        addr = trd[0x08e1] + (((long)trd[0x08e2])<<4); //first free sector, track
        memcpy(trd+(addr<<8), filebuf+index, wrsize); //data
        descbuf[14] = (BYTE)(addr&0x0f); //sector
        descbuf[15] = (BYTE)(addr>>4); //track
        addr = addr + secsize;
        trd[0x08e1] = (BYTE)(addr&0x0f); //first free sector
        trd[0x08e2] = (BYTE)(addr>>4); //first free track

        descaddr = ((long)trd[0x08e4])<<4; //files
        trd[0x08e4]++; //files
        free = trd[0x08e5] + 256*trd[0x08e6]; //free
        free = free - secsize;
        trd[0x08e5] = (BYTE)free;
        trd[0x08e6] = (BYTE)(free>>8);

        memcpy(trd+descaddr, descbuf, DESCSIZE); //descriptor
      };
      fclose(fin);
    };
    writetrd(trdname);
  };
}

void newtrd(char * trdname)
{
  memset(trd, 0x00, TRDSIZE);
  memcpy(trd+0x08e0, trdheader, 0x0020);
  writetrd(trdname);
}

int main(int argc,char* argv[])
{
int i;
int startaddr;
char *trdname;
char *filename;
  startaddr = 24576;
  trdname = "test.trd";
  verbose = FALSE;

  if (argc<2) {
    printf(
      "NedoTRD\n"
      "add partitioned file:\n"
      "\tnedotrd.exe trdname.trd -a file.f\n"
      "add code file with default start address (24576):\n"
      "\tnedotrd.exe trdname.trd -ac file.c\n"
      "add code file with start address 32768:\n"
      "\tnedotrd.exe trdname.trd -s 32768 -ac file.c\n"
      "add hobeta file:\n"
      "\tnedotrd.exe trdname.trd -ah file.$b\n"
      "extract partitioned file:\n"
      "\tnedotrd.exe trdname.trd -e file.f\n"
      "extract binary file:\n"
      "\tnedotrd.exe trdname.trd -eb file.c\n"
      "extract hobeta file:\n"
      "\tnedotrd.exe trdname.trd -eh file.$b\n"
      "new trd file:\n"
      "\tnedotrd.exe trdname.trd -n\n"
      "verbose: -v\n"
    );
  };

  for (i=1; i<argc; i++) {
    ishobeta = FALSE;
    if       (!strcmp(argv[i],"-a")) { //add
      i++;
      filename = argv[i];
      addfile(trdname, filename, 0, startaddr);
    }else if (!strcmp(argv[i],"-ac")) { //add code
      i++;
      filename = argv[i];
      addfile(trdname, filename, 1, startaddr);
    }else if (!strcmp(argv[i],"-ah")) { //add hobeta
      i++;
      filename = argv[i];
      ishobeta = TRUE;
      addhobeta(trdname, filename);
    }else if (!strcmp(argv[i],"-e")) { //extract partitioned
      i++;
      filename = argv[i];
      extractfile(trdname, filename);
    }else if (!strcmp(argv[i],"-eb")) { //extract binary
      i++;
      filename = argv[i];
      extractbinary(trdname, filename);
    }else if (!strcmp(argv[i],"-eh")) { //extract hobeta
      i++;
      filename = argv[i];
      ishobeta = TRUE;
      extracthobeta(trdname, filename);
    }else if (!strcmp(argv[i],"-n")) { //new trd
      newtrd(trdname);
    }else if (!strcmp(argv[i],"-v")) { //verbose
      verbose = TRUE;
    }else if (!strcmp(argv[i],"-s")) { //use start address
      i++;
      filename = argv[i];
      startaddr = atoi(filename);
    }else {
      trdname = argv[i];
    };
  }
return 0;
}