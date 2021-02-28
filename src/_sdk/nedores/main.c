#include <stdio.h>
#include <stdlib.h>
#include <mem.h>
#include <string.h>

#define _STRMAX 79

#define BYTE unsigned char
#define UINT unsigned int
#define MAXDEFB 8

#define MASKCOLOR 0x00

BYTE filebuf[65536];
char labelbuf[_STRMAX+1];
char formatlabelbuf[_STRMAX+1];
BYTE sizeword[4];
BYTE pic[1024][1024];
BYTE pixrow[1024/8][1024+1024];
#define PIXROWSHIFT 1024
BYTE maskrow[1024/8][1024];
//BYTE pixrowshift[1024/8][1024]; //>>4
BYTE attrrow[1024/8];
BYTE pal[64];

#define CONVORDERSZ 1024

int convorderx[CONVORDERSZ]; //для каждого номера тайла координаты
int convordery[CONVORDERSZ]; //для каждого номера тайла координаты

BYTE ink;
BYTE paper;
BYTE curink;
BYTE curpaper;
BYTE defaultcolor;

char sprformat;

int hgt;
int wid;
int bpp;

void skiplf(FILE * fin)
{ //возможно, 0x0d уже прочитан, теперь пропускаем 0x0a
char c;
  do{
    if (!fread(&c,1,1,fin)) break;
  }while (c!=0x0a);
}

int readnum(FILE * fin)
{
char c;
int num;
int sign=1;
  num = 0;
  do{
    if (!fread(&c,1,1,fin)) break;
    if (c==' ') goto skip;
    //if (c == 0x0d) goto skip;
    //if (c == 0x0a) break;
    if (c=='-') {sign = -1; goto skip;};
    if ((c<'0')||(c>'9')) break; //в том числе 0x0a
    num = num*10 + (int)(c-'0');
skip:
	;
  }while(1);
  num = num*sign;
return num;
}

unsigned int readlabel(FILE * fin, char * s)
{
char c;
unsigned int i;
int iscomment;
  do{
    i = 0;
    iscomment = 0;
    do{
      if (!fread(&c,1,1,fin)) break;
      if (c == ';') iscomment = -1;
      if ((c=='=')||(c==',')) {
        if (iscomment) continue; //в комментах можно =
        break;
      };
      if (c == 0x0d) continue;
      if (c == 0x0a) {
        if (iscomment) break; //комменты кончаются по концу строки
        continue;
      };
      if (i==_STRMAX) break;
      s[i] = c;
      i++;
    }while(1);
    s[i] = '\0';
  }while(iscomment);
return i;
}

int read4b(FILE * fin)
{
  fread(sizeword, 4, 1, fin);
return sizeword[0] + (sizeword[1]<<8) + (sizeword[2]<<16) + (sizeword[3]<<24);
}

BYTE colstat[256];

void findinkpaper(int x, int y) //маска 0x00 не считается цветом
{
//BYTE b;
int i;
int j;
BYTE col1;
BYTE col1stat;
BYTE col2;
BYTE col2stat;
BYTE col3;
BYTE col3stat;
BYTE col4;
BYTE col4stat; //на случай такой статистики: MASKCOLOR, RED, red, anothercolor
  i = 0; do {colstat[i] = 0x00; i++;}while (i!=256);

  //col1 = pic[x][y];
  j = y;
  while (j < (y+8)) {
//    b = 0x00;
    i = x;
    while (i < (x+8)) {
      colstat[pic[i][j]]++;
      //b = pic[i][j];
      //if (b!=col1) col2 = b;
      i++;
    };
    j++;
  };

//маска MASKCOLOR не считается цветом
  col1 = MASKCOLOR; col1stat = 0; //fix 27.12.2018
  col2 = MASKCOLOR; col2stat = 0; //fix 27.12.2018
  col3 = MASKCOLOR; col3stat = 0; //fix 27.12.2018
  col4 = MASKCOLOR; col3stat = 0; //fix 27.12.2018
  i = 0; do { //fix 27.12.2018 (на случай MASKCOLOR!=0)
    if (colstat[i] > col1stat) {
      col4 = col3;
      col4stat = col3stat;
      col3 = col2;
      col3stat = col2stat;
      col2 = col1;
      col2stat = col1stat;
      col1 = (BYTE)i;
      col1stat = colstat[i];
    }else if (colstat[i] > col2stat) {
      col4 = col3;
      col4stat = col3stat;
      col3 = col2;
      col3stat = col2stat;
      col2 = (BYTE)i;
      col2stat = colstat[i];
    }else if (colstat[i] > col3stat) {
      col4 = col3;
      col4stat = col3stat;
      col3 = (BYTE)i;
      col3stat = colstat[i];
    }else if (colstat[i] > col4stat) {
      col4 = (BYTE)i;
      col4stat = colstat[i];
    };
    i++;
  }while (i!=16); //fix 27.12.2018

//MASKCOLOR нельзя самым частым, сортируем его в конец
  if (col1==MASKCOLOR) {
    col1 = col2;
    col2 = MASKCOLOR;
  };
  if (col2==MASKCOLOR) {
    col2 = col3;
    col3 = MASKCOLOR;
  };
  if (col3==MASKCOLOR) {
    col3 = col4;
    col4 = MASKCOLOR;
  };

//col1 может быть MASKCOLOR только для знакоместа, полностью залитого MASKCOLOR
//маска 0x00 не считается цветом, поэтому 0x08 переводится в 0x00 с дефолтной яркостью (чтобы не влиять на bright)
  //if ((col1&0x07)==0x00) col1 = (BYTE)(defaultcolor&0x08); //fix 27.12.2018
  //if ((col2&0x07)==0x00) col2 = (BYTE)(defaultcolor&0x08); //fix 27.12.2018
/**  if (col2 == MASKCOLOR) {
    if (col1 == MASKCOLOR) {
      col2 = (BYTE)((col1&0x08) | (defaultcolor&0x07));
    }else {
      col2 = (BYTE)((col1&0x08) | (defaultcolor&0x07));
    };
  };*/ //fix 27.12.2018
  if (((col2&0x07)==(col1&0x07)) /**&& (col2!=0x00)*/) col2 = col3; //same colour with another bright
  ink = col1;
  paper = col2; //реже
  //paper реже и может быть MASKCOLOR (нет второго цвета, надо брать дефолтный)
  //ink может быть MASKCOLOR только для знакоместа, полностью залитого MASKCOLOR
}

void setcurinkpaper(BYTE* pcurink, BYTE* pcurpaper)
//paper реже и может быть MASKCOLOR (нет второго цвета, надо брать дефолтный)
//ink может быть MASKCOLOR только для знакоместа, полностью залитого MASKCOLOR
//*pcurink, *curpaper изначально содержат атрибуты предыдущего знакоместа
//возвращает *pcurink, *curpaper, причём вместо 0x08 ставит 0x00 (чтобы не влияло на яркость)
{
BYTE t;
  if ((sprformat == 's')||(sprformat == 'w')) {
    paper = 0x08;
    ink = 0x0f;
  }; //для спрайтов фон чёрный (а маска 0x00)
//27.02.2019:
//фон для залитых знакомест начиная с зелёного теперь чёрный[или надо предыдущий?]
//фон для чёрных знакомест берёт яркость от defaultcolor, а для залитых знакомест менее зелёного не берёт
#define MINCOLORWITHBLACKBG 0x04
//fix 27.12.2018:
  if (((ink&0x07)==(*pcurink&0x07)) && (ink!=MASKCOLOR)) { //ink соответствует предыдущему
    *pcurink = ink;
    if (paper==MASKCOLOR) {
      *pcurpaper = ((ink&0x07)<MINCOLORWITHBLACKBG) ? ((ink&0x07)?((defaultcolor&0x07)|(ink&0x08)):defaultcolor) : 0x00;
    }else {
      *pcurpaper = paper;
    };
  }else if (((paper&0x07)==(*pcurpaper&0x07)) && (paper!=MASKCOLOR)) { //paper соответствует предыдущему
    *pcurpaper = paper;
    if (ink==MASKCOLOR) {
      *pcurink = ((paper&0x07)<MINCOLORWITHBLACKBG) ? ((paper&0x07)?((defaultcolor&0x07)|(paper&0x08)):defaultcolor) : 0x00;
    }else {
      *pcurink = ink;
    };
  }else if (((paper&0x07)==(*pcurink&0x07)) && (paper!=MASKCOLOR)) { //paper соответствует предыдущему ink
    *pcurink = paper;
    if (ink==MASKCOLOR) {
      *pcurpaper = ((paper&0x07)<MINCOLORWITHBLACKBG) ? ((paper&0x07)?((defaultcolor&0x07)|(paper&0x08)):defaultcolor) : 0x00;
    }else {
      *pcurpaper = ink;
    };
  }else if (((ink&0x07)==(*pcurpaper&0x07)) && (ink!=MASKCOLOR)) { //ink соответствует предыдущему paper
    *pcurpaper = ink;
    if (paper==MASKCOLOR) {
      *pcurink = ((ink&0x07)<MINCOLORWITHBLACKBG) ? ((ink&0x07)?((defaultcolor&0x07)|(ink&0x08)):defaultcolor) : 0x00;
    }else {
      *pcurink = paper;
    };
  }else if ((ink==MASKCOLOR)&&(paper==MASKCOLOR)) { //оба цвета MASKCOLOR
    ink = defaultcolor;
    paper = 0x08;
  }else { //оба цвета не соответствуют предыдущему знакоместу, но не оба MASKCOLOR
    if (ink == MASKCOLOR) ink = ((paper&0x07)<MINCOLORWITHBLACKBG) ? ((paper&0x07)?((defaultcolor&0x07)|(paper&0x08)):defaultcolor) : 0x00;
    if (paper == MASKCOLOR) paper = ((ink&0x07)<MINCOLORWITHBLACKBG) ? ((ink&0x07)?((defaultcolor&0x07)|(ink&0x08)):defaultcolor) : 0x00;
    if (ink > paper) {
      *pcurink = ink;
      *pcurpaper = paper;
    }else {
      *pcurink = paper;
      *pcurpaper = ink;
    };
  };
  if (*pcurpaper==0x08) *pcurpaper = 0x00; //чтобы не влияло на яркость //fix 27.12.2018
  if (*pcurink==0x08) *pcurink = 0x00; //чтобы не влияло на яркость //fix 27.12.2018
  //на чёрном/синем фоне ink должен быть ярче paper'а (отдельный случай, т.к. остальные, даже пустые, знакоместа могут участвовать в отрисовке скроллируемых фонов с непрерывными цепочками ink-paper)
  //то есть нельзя ink=0, а 1 только в случае paper=0
  if (((*pcurink&0x07)<=0x01) && ((*pcurpaper&0x07)>(*pcurink&0x07))) { //чёрное/синее пустое знакоместо (отдельный случай, т.к. остальные пустые могут участвовать в отрисовке скроллируемых фонов с непрерывными цепочками ink-paper)
    t = *pcurpaper;
    *pcurpaper = *pcurink;
    *pcurink = t;
  };
}

void emitdb(BYTE b, FILE * fout)
{
  fputs("\tdb ", fout);
  fprintf(fout, "0x%x%x", b>>4, b&0x0f);
  fputs("\n", fout);
}

void emitdw(UINT u, FILE * fout)
{
  fputs("\tdw ", fout);
  fprintf(fout, "0x%x%x%x%x", (u>>12)&0x0f, (u>>8)&0x0f, (u>>4)&0x0f, u&0x0f);
  fputs("\n", fout);
}

void emitnops(BYTE count, FILE * fout)
{
  fputs("\tds ", fout);
  fprintf(fout, "0x%x%x", count>>4, count&0x0f);
  fputs("\n", fout);
}

void emitspr(int xchr, int y, int sprwid8, int sprhgt, FILE * fout)
{
BYTE b;
int i;
int j;
  j = y;
  while (1) {
    fputs("\tdb ", fout);
    i = xchr;
    while (1) {
      b = maskrow[i][j];
      fprintf(fout, "0x%x%x", b>>4, b&0x0f);
      fputs(",", fout);
      b = b^pixrow[i][j];
      fprintf(fout, "0x%x%x", b>>4, b&0x0f);
      i++;
      if (i >= (xchr+sprwid8)) break;
      fputs(",", fout);
    };
    fputs("\n", fout);
    j++;
    if (j >= (y+sprhgt)) break;
  };
}

void emitsprw(int xchr, int y, int sprwid8, int sprhgt, FILE * fout)
{ //antipixelsw, antimaskw
BYTE b;
int i;
int j;
  j = y;
  while (1) {
    fputs("\tdb ", fout);
    i = xchr+sprwid8;
    while (1) {
      i--;
      b = ~maskrow[i][j];
      fprintf(fout, "0x%x%x", b>>4, b&0x0f);
      if (i == xchr) break;
      fputs(",", fout);
    };
    fputs("\n", fout);
    fputs("\tdb ", fout);
    i = xchr+sprwid8;
    while (1) {
      i--;
      b = ~maskrow[i][j];
      b ^= pixrow[i][j];
      fprintf(fout, "0x%x%x", b>>4, b&0x0f);
      if (i == xchr) break;
      fputs(",", fout);
    };
    fputs("\n", fout);
    j++;
    if (j >= (y+sprhgt)) break;
  };
}

void emitchr_(int xchr, int y, FILE * fout)
{
BYTE b;
int j;
  fputs("\tdb ", fout);
  j = y;
  while (1) {
    b = pixrow[xchr][j];
    fprintf(fout, "0x%x%x", b>>4, b&0x0f);
    j++;
    if (j >= (y+8)) break;
    fputs(",", fout);
  };
  if (sprformat < 'a') { //capital letter format => attr used
    b = attrrow[xchr]; //0x07;
    fputs(",", fout);
    fprintf(fout, "0x%x%x", b>>4, b&0x0f);
  };
  fputs("\n", fout);
}

void emitchr(int xchr, int y, FILE * fout)
{
  emitchr_(xchr, y, fout);
}

void emitchrshift(int xchr, int y, FILE * fout)
{
  emitchr_(xchr, y+PIXROWSHIFT, fout);
}

//сдвигаем ряд знакомест >>shiftbits, результат в pixrow[sprx][y+PIXROWSHIFT]
void shiftrow(int sprx, int y, int sprwid, int rowhgt, int pixrowshift, BYTE shiftbits)
{
int j;
int x;
BYTE b;
BYTE b0;
BYTE shiftmask;
  shiftmask = (BYTE)(0xff>>(0x08-shiftbits)); //если shiftbits==0x01, то shiftmask==0x01
  j = y;
  while (j < (y+rowhgt)) {
    b = 0x00;
    x = sprx;
    while (x < (sprx+sprwid+8)) {
      b0 = pixrow[x/8][j];
      pixrow[x/8][j+pixrowshift] = (BYTE)((b<<(0x08-shiftbits)) + (b0>>shiftbits));
      b = (BYTE)(b0&shiftmask/**0x0f*/); //если shiftbits==0x01, то shiftmask==0x01
      x = x+8;
    };
    j++;
  };
}

//data: wid8, hgt8, chrgfx, chrgfx...
void resfile(char * finname, char * fintxtname, char * foutname)
{
FILE* fin;
FILE* fintxt;
FILE* fout;
int i;
int j;
int size;
int y;
int x;
int n;
int tiles;

BYTE b;
BYTE bmask;
BYTE b0;

int sprx;
int spry;
int sprwid;
int sprhgt;
int rowhgt; //8 for tiles, sprhgt for sprites

UINT color;

  fin = fopen(finname, "rb");
  if (fin) {
    fread(filebuf, 10, 1, fin); //skip to 10 (header size)
    size = read4b(fin); //10 (header size)
    fread(filebuf, 4, 1, fin); //skip to 18
    wid = read4b(fin); //18
    hgt = read4b(fin); //22
    fread(filebuf, 2, 1, fin); //skip to 28
    fread(&bpp, 1, 1, fin); //28
    fread(filebuf, 1, 54-29, fin); //skip to pal
    fread(pal, 1, 64, fin); //палитра (B, G, R, 0)
    if (size > (54+64)) {fread(filebuf, 1, size-(54+64), fin);}; //skip to pic
    if ((wid>0)&&(wid<=1024)&&(hgt>0)&&(hgt<=1024)&&((wid&7)==0)&&((hgt&7)==0)) {
      y = hgt;
      while (y>0) {
        y--;
        x = 0;
        while (x<wid) {
          fread(&b, 1, 1, fin);
          if (bpp == 8) {
            pic[x][y] = b;
            x++;
          }else {
            pic[x][y] = (BYTE)((b&0xf0)>>4);
            x++;
            pic[x][y] = (BYTE)(b&0x0f);
            x++;
          };
        };
      };

      fintxt = fopen(fintxtname, "rb");
      if (fintxt) {
        fout = fopen(foutname, "wb");
        if (fout) {
/**          if (labelname[0]!='\0') {
            fputs(labelname, fout);
            fputs("\n", fout);
          };*/
          while (1) {
            size = readlabel(fintxt, labelbuf); //fread(filebuf, 1, MAXDEFB, fin);
            if (size == 0) break;
            readlabel(fintxt, formatlabelbuf); //format
            sprformat = *formatlabelbuf;
            sprx = readnum(fintxt);
            spry = readnum(fintxt);
            sprwid = readnum(fintxt);
            sprhgt = readnum(fintxt);
            tiles = readnum(fintxt); //отсутствует в x
            defaultcolor = (BYTE)tiles; //для всех, кроме L

            if (sprformat == 'B') {
              fputs(labelbuf, fout);
              fputs("\n", fout);
              emitdb((BYTE)(sprwid>>3), fout);
              emitdb((BYTE)(sprhgt>>3), fout);
              rowhgt = 8;
            }else if (sprformat == 'T') { //набор тайлов
              fputs("\tds (-$)&0xff\n", fout);
              fputs(labelbuf, fout);
              fputs("\n", fout);
              rowhgt = 8;
            }else if (sprformat == 'x') { //спрайт 16c
              fputs("\n", fout);
              fputs(labelbuf, fout);
              fputs("=$+4\n", fout);
              fputs("\n", fout);
              emitdb((BYTE)(sprwid>>1), fout);
              emitdb((BYTE)(sprhgt), fout);
              rowhgt = sprhgt;
            }else if (sprformat == 'i') { //картинка 16c по столбцам
              fputs("\n", fout);
              fputs(labelbuf, fout);
              fputs("\n", fout);
              rowhgt = sprhgt;
            }else if (sprformat == 'L') { //LAND как в ЧВ, дальше следует таблица - номер тайла для каждой клетки
              fputs("\n", fout);
              fputs(labelbuf, fout);
              fputs("\n", fout);
              rowhgt = sprhgt;
            }else if (sprformat == 'P') { //DDp palette
              fputs("\n", fout);
              fputs(labelbuf, fout);
              fputs("\n", fout);
              i = 0;
              while (i < 64) { //DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные //color = highlow
                color = 0; //pal = палитра (B, G, R, 0)
                if (pal[i]&0x80) color = color | 0x0100;
                if (pal[i]&0x40) color = color | 0x2000;
                if (pal[i]&0x20) color = color | 0x0001;
                if (pal[i]&0x10) color = color | 0x0020;
                i++;
                if (pal[i]&0x80) color = color | 0x1000;
                if (pal[i]&0x40) color = color | 0x8000;
                if (pal[i]&0x20) color = color | 0x0010;
                if (pal[i]&0x10) color = color | 0x0080;
                i++;
                if (pal[i]&0x80) color = color | 0x0200;
                if (pal[i]&0x40) color = color | 0x4000;
                if (pal[i]&0x20) color = color | 0x0002;
                if (pal[i]&0x10) color = color | 0x0040;
                i++;
                emitdw(~color, fout);
                i++;
              };
              fputs("\n", fout);
              rowhgt = sprhgt;
            }else if (sprformat == 'w') {
              fputs(labelbuf, fout);
              fputs("\n", fout);
              rowhgt = sprhgt;
            }else { //'s'
              fputs(labelbuf, fout);
              fputs("\n", fout);
              emitdb((BYTE)(sprwid>>3), fout);
              emitdb((BYTE)(sprhgt), fout);
              rowhgt = sprhgt;
            };

            y = spry;
            while (y < (spry+sprhgt)) {
              //перекодируем ряд знакомест высотой rowhgt
              curink = 0x0f;
              curpaper = 0x08;
              x = sprx;
              while (x < (sprx+sprwid)) {
                findinkpaper(x, y);
                setcurinkpaper(&curink, &curpaper);
              //curink = 0x0f;
              //curpaper = 0x08;
                j = y;
                while (j < (y+rowhgt)) {
                  b = 0x00;
                  bmask = 0x00;
                  i = x;
                  while (i < (x+8)) {
                    b = (BYTE)(b<<1);
                    bmask = (BYTE)(bmask<<1);
                    //if (sprformat != 'B') {fprintf(fout, "0x%x%x\n", (pic[i][j])>>4, (pic[i][j])&0x0f);};
                    if (pic[i][j]==curink) b++;
                    if (pic[i][j]!=0x00) bmask++;
                    i++;
                  };
                  pixrow[x/8][j] = b;
                  maskrow[x/8][j] = bmask;
                  pixrow[(x/8)+1][j] = 0x00; //чтобы сдвигать
                  j++;
                };
//маска 0x00 не считается цветом, поэтому 0x08 переводится в 0x00 (чтобы не влиять на bright)
                b = 0x00; if (curink!=0x08) b = curink;
                b0 = 0x00; if (curpaper!=0x08) b0 = curpaper;
                attrrow[x/8    ] = (BYTE)( (((b|b0)&0x08)<<3)+((curpaper&0x07)<<3)+(curink&0x07) );
                attrrow[(x/8)+1] = (BYTE)( (((b|b0)&0x08)<<3)+((curpaper&0x07)<<3)+(curink&0x07) ); //чтобы сдвигать
                x = x+8;
              };
  //            shiftrow(sprx, y, sprwid, rowhgt, PIXROWSHIFT, 0x04); //сдвигаем ряд знакомест >>4, результат в pixrow[sprx][y+PIXROWSHIFT]

              //выводим в асм
              if (sprformat == 'B') { //tiles
                x = sprx;
                while (x < (sprx+sprwid)) {
  //                emitchrshift(x/8,y,fout);
                  emitchr(x/8,y,fout);
                  x = x+8;
                };
  //              emitchrshift(x/8,y,fout);
              }else if (sprformat == 'T') {
                x = sprx;
                while (x < (sprx+sprwid)) {
                  emitchr(x/8,y,fout);
                  x = x+8;
                };
                emitnops((BYTE)(0x100-((BYTE)(sprwid>>3)*0x09)),fout);
              }else if (sprformat == 's') { //sprite
                emitspr(sprx/8,y,sprwid/8,sprhgt,fout);
              }else if (sprformat == 'w') { //sprite antipixels16, antimask16
                emitsprw(sprx/8,y,sprwid/8,sprhgt,fout);
              };
              y = y+rowhgt;
            }; //while y

            if (sprformat == 'x') {
              x = sprx;
              while (x < (sprx+sprwid)) {
                y = spry;
                while (y < (spry+sprhgt)) {
                  b = pic[x][y]; //L
                  b0 = pic[x+1][y]; //R
                  bmask = 0; //0x47(L) и 0xb8(R) в тех местах, где цвет=16:
                  if (b == 16) {bmask = bmask + 0x47; b = 0x00;};
                  if (b0 == 16) {bmask = bmask + 0xb8; b0 = 0x00;};
                  b = ((b&0x08)<<3) + (b&0x07) + ((b0&0x08)<<4) + ((b0&0x07)<<3);
                  fputs("\tdb ", fout);
                  fprintf(fout, "0x%x%x", bmask>>4, bmask&0x0f);
                  fprintf(fout, ",0x%x%x", b>>4, b&0x0f);
                  fputs("\n", fout);
                  y = y+1;
                };
                x = x+2;
                if (x < (sprx+sprwid)) {
                  emitdw(0x4000-((sprhgt-1)*40), fout);
                }else {
                  emitdw(0xffff, fout);
                };
                fputs("\n", fout);
              };
              fputs("\tdw prsprqwid\n", fout);
            };

            if (sprformat == 'i') {
              x = sprx;
              while (x < (sprx+sprwid)) {
                y = spry;
                while (y < (spry+sprhgt)) {
                  b = pic[x][y]; //L
                  b0 = pic[x+1][y]; //R
                  b = ((b&0x08)<<3) + (b&0x07) + ((b0&0x08)<<4) + ((b0&0x07)<<3);
                  fprintf(fout, "\tdb 0x%x%x", b>>4, b&0x0f);
                  fputs("\n", fout);
                  y = y+1;
                };
                x = x+2;
                fputs("\n", fout);
              };
            };

            if (sprformat == 'L') { //далее текст типа (-1=пропуск):
//   -1, -1, -1,114,116,119,121,124,126,-1,-1,-1,-1,-1,-1,-1,
//  113,118,123,115,117,120,122,125,127,-1,-1,-1,-1,-1,-1,-1
//для каждой ячейки картинки указан номер тайла
//а нам надо заполнить массивы convorderx,y - координаты для каждого номера тайла
//все должны быть в одной картинке, иначе не получится (перемешаны номера тайлов общие для всех локаций и для конкретной)
              n = 0;
              while (n < CONVORDERSZ) {
                convorderx[n] = 0;
                convordery[n] = 0;
                n = n+1;
              };

                skiplf(fintxt);
              //tiles = 0;

              y = spry;
              while (y < (spry+sprhgt)) {
                x = sprx;
                while (x < (sprx+sprwid)) {
                  n = readnum(fintxt);
                  if (n != -1) {
                    convorderx[n] = x;
                    convordery[n] = y;
                  };
                  //fprintf(fout, "\tdb %d\n", n);
                  //tiles = tiles + 1;
                  x = x+16;
                };
                skiplf(fintxt);
                //fputs("\n", fout);
                y = y+16;
              };

              n = 0;
              while (n < tiles) {
                x = convorderx[n];
                while (x < (convorderx[n]+16)) {
                  fputs(" db ", fout);
                  y = convordery[n];
                  while (1) {
                    b = pic[x][y]; //L
                    b0 = pic[x+1][y]; //R
                    b = ((b&0x08)<<3) + (b&0x07) + ((b0&0x08)<<4) + ((b0&0x07)<<3);
                    fprintf(fout, "0x%x%x", b>>4, b&0x0f);
                    y = y+1;
                    if (y == (convordery[n]+16)) break;
                    fputs(",", fout);
                  };
                  fputs("\n", fout);
                  x = x+2;
                };
                n = n+1;
              };

            };

          }; //while (1)
          fclose(fout);
        }else {printf("can't open %s",foutname);};
        fclose(fintxt);
      }else {printf("can't open %s",fintxtname);};
    };
    fclose(fin);
  }else {printf("can't open %s",finname);};
}

int main(int argc,char* argv[])
{
//  int i;
  char *finname;
  char *fintxtname;
  char *foutname;
  finname = "testpic.bmp";
  fintxtname = "testpic.txt";
  foutname = "testpic.asm";

  if (argc<4) {
    printf(
      "NedoRes\n"
      "\tnedores.exe file.bmp file.dat(=txt) file.ast(=asm)\n"
      "4bpp or 8bpp\n"
    );
  }else {
    finname = argv[1];
    fintxtname = argv[2];
    foutname = argv[3];
  };

  resfile(finname, fintxtname, foutname);

  return 0;
}
