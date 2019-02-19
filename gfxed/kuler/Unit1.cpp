//---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>
#include <stdio.h>
#pragma hdrstop

//#include "nedodefs.h"

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

int chunkpixelnumber[16] = {
/*  0x0, 0xc, 0x2, 0xe,
  0x8, 0x4, 0xa, 0x6,
  0x3, 0xf, 0x1, 0xd,
  0xb, 0x7, 0x9, 0x5*/
  0x0, 0xc, 0x6, 0xa,
  0x9, 0x4, 0x1, 0xd,
  0xe, 0x7, 0xb, 0x3,
  0x5, 0x2, 0x8, 0xf
};

int chunkpixelnumberdiamond[16] = {
  0x1, 0xd, 0x3, 0xf,
  0x9, 0x5, 0xb, 0x7,
  0x4, 0x10, 0x2, 0xe,
  0xc, 0x8, 0xa, 0x6
};

#define PALCOEFF 85/3
unsigned char pal[768];

unsigned char zxpal[16*2];

unsigned char maxdistdiv_fromattr[256];
unsigned char min_fromattr[256];
unsigned char maxaxis_fromattr[256];

unsigned char tdiv[16384];

#define PALEXTRA 5
char palextra[3*PALEXTRA] = {
  //18*PALCOEFF/2, 15*PALCOEFF/2, 13*PALCOEFF/2,
  17*PALCOEFF/2, 13*PALCOEFF/2, 10*PALCOEFF/2,
  16*PALCOEFF/2, 11*PALCOEFF/2,  9*PALCOEFF/2,
  15*PALCOEFF/2,  9*PALCOEFF/2,  8*PALCOEFF/2,
  17*PALCOEFF/2, 11*PALCOEFF/2,  6*PALCOEFF/2,
  11*PALCOEFF/2,  7*PALCOEFF/2,  5*PALCOEFF/2,
};

unsigned char pal16[16*3]; //act(r,g,b)

unsigned char t64to16[64];

unsigned char t64to16ink[64];

unsigned char t64to16paper[64];

char colorexist[1000] = {
//x=g(0..9), y=b(9..0)
//R=9:
1,0,0,1,0,0,1,0,0,1, //W
0,0,0,0,0,0,0,0,1,1,
0,0,0,0,0,0,0,1,1,1,
1,0,0,1,0,0,1,1,1,1, //YW
0,0,0,0,0,0,1,1,1,1,
0,0,0,0,0,0,1,1,0,0,
1,0,0,1,0,0,1,1,0,1, //Y
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
1,0,0,1,0,0,1,0,0,1,

//R=8:
0,0,0,0,0,0,0,0,0,1,
0,0,0,0,0,0,0,0,1,1,
0,0,0,0,0,0,0,1,1,1,
0,0,0,0,0,0,1,1,1,1,
0,0,0,0,0,1,1,1,1,1,
0,0,0,0,0,1,1,1,1,0,
0,0,0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,

//R=7:
0,0,0,0,0,0,0,0,0,1,
0,0,0,0,0,0,0,1,1,1,
0,0,0,0,0,0,1,1,1,1,
0,0,0,0,0,1,1,1,1,0,
0,0,0,0,0,1,1,1,1,0,
0,0,0,0,1,1,1,1,0,0,
0,0,0,0,1,1,1,1,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,

//R=6:
1,0,0,1,0,0,1,0,0,1, //CW
0,0,0,0,0,0,0,1,1,0,
0,0,0,0,0,0,1,1,1,0,
1,0,0,1,0,1,1,1,0,1,
0,0,0,0,0,1,1,1,0,0,
0,0,0,0,1,1,1,0,0,0,
1,0,0,1,1,1,1,0,0,1,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
1,0,0,1,0,0,1,0,0,1,

//R=5:
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,1,1,0,0,
0,0,0,0,0,1,1,1,0,0,
0,0,0,0,1,1,1,1,1,0,
0,0,0,0,1,1,1,1,0,0,
0,0,0,1,1,1,1,1,0,0,
0,0,0,1,1,1,1,0,0,0,
0,0,1,1,1,1,1,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,

//R=4:
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,1,0,0,0,0,
0,0,0,0,1,1,0,0,0,0,
0,0,0,1,1,1,1,0,0,0,
0,0,0,1,1,1,1,0,0,0,
0,0,1,1,1,1,1,1,0,0,
0,0,1,1,1,1,1,0,0,0,
0,1,1,1,1,1,1,0,0,0,
0,0,0,0,0,0,0,0,0,0,

//R=3:
1,0,0,1,0,0,1,0,0,1,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
1,0,0,1,0,0,1,0,0,1,
0,0,0,1,0,0,0,0,0,0,
0,0,1,1,1,0,0,0,0,0,
1,0,1,1,1,0,1,0,0,1,
0,1,1,1,1,1,0,0,0,0,
0,1,0,0,0,1,0,0,0,0,
1,1,0,1,0,1,1,0,0,1,

//R=2:
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,1,0,0,0,0,0,0,0,
0,0,1,1,0,0,0,0,0,0,
0,1,1,1,0,0,0,0,0,0,
0,1,1,1,1,0,0,0,0,0,
1,1,1,0,1,0,0,0,0,0,
1,1,0,0,0,1,0,0,0,0,

//R=1:
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,1,0,0,0,0,0,0,0,0,
0,1,1,0,0,0,0,0,0,0,
1,1,1,1,0,0,0,0,0,0,
1,1,1,1,0,0,0,0,0,0,
1,1,1,1,1,0,0,0,0,0,

//R=0:
1,0,0,1,0,0,1,0,0,1,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
1,0,0,1,0,0,1,0,0,1,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
1,0,0,1,0,0,1,0,0,1,
1,1,0,0,0,0,0,0,0,0,
1,1,1,0,0,0,0,0,0,0,
1,1,1,1,0,0,1,0,0,1
};

int tsin[256];


TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void TForm1::setColorChunkyR(int x, int y, int n)
{
  curColorChunky->Canvas->Pixels[x][y] = (curColorChunky->Canvas->Pixels[x][y] & 0xffff00) + n;
}

void TForm1::setColorChunkyG(int x, int y, int n)
{
  curColorChunky->Canvas->Pixels[x][y] = (curColorChunky->Canvas->Pixels[x][y] & 0xff00ff) + (n<<8);
}

void TForm1::setColorChunkyB(int x, int y, int n)
{
  curColorChunky->Canvas->Pixels[x][y] = (curColorChunky->Canvas->Pixels[x][y] & 0x00ffff) + (n<<16);
}

void TForm1::setHSpaletteR(int x, int y, int n)
{
  Image1->Canvas->Pixels[x][y] = (Image1->Canvas->Pixels[x][y] & 0xffff00) + n;
}

void TForm1::setHSpaletteG(int x, int y, int n)
{
  Image1->Canvas->Pixels[x][y] = (Image1->Canvas->Pixels[x][y] & 0xff00ff) + (n<<8);
}

void TForm1::setHSpaletteB(int x, int y, int n)
{
  Image1->Canvas->Pixels[x][y] = (Image1->Canvas->Pixels[x][y] & 0x00ffff) + (n<<16);
}

void TForm1::showHSpalette()
{
//#define BYTE int
#define REPEAT do
#define UNTIL(x) while(!(x))
  int x;
  int xsize = Image1->Width; //128;
  int y;
  int ysize = Image1->Height; //192;

  float h,s;

  y = 0x00;
  REPEAT {
    h = (float)y/ysize;
    x = 0x00;
    REPEAT {
      s = (float)(x&0xfffffffc)/xsize;

      TColor color = calcHSVtoRGB(h,s,curV);
      //Image1->Canvas->Pixels[x][y] = color;

      int chunkpixel = (x&3) + ((y&3)<<2);
      int ir = (color&0xff)/15;
      int ig = ((color>>8)&0xff)/15;
      int ib = ((color>>16)&0xff)/15;

      setHSpaletteR(x, y, (ir > chunkpixelnumber[chunkpixel])*255&0xff );
      setHSpaletteG(x, y, (ig > chunkpixelnumber[chunkpixel])*255&0xff );
      setHSpaletteB(x, y, (ib > chunkpixelnumber[chunkpixel])*255&0xff );

      x++;
    }UNTIL (x == xsize);
    y++;
  }UNTIL (y == ysize);
}

int getR(TColor rgb)
{
  return (rgb)&0xff;
}

int getG(TColor rgb)
{
  return (rgb>>8)&0xff;
}

int getB(TColor rgb)
{
  return (rgb>>16)&0xff;
}

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  int colindex;

  Image2->Picture->LoadFromFile("../lanscape.bmp");
  //Image2->Picture->LoadFromFile("seversta.bmp");
  //Image2->Picture->LoadFromFile("melnchud.bmp");
  //Image2->Picture->LoadFromFile("hippiman.bmp");

  FILE* fin;
  fin = fopen("softe16.act", "rb");
  fread(pal16, 16*3, 1, fin);
  fclose(fin);

  for (int i = 0; i<64; i++) {
    int r = (i>>0)&0x03;
    int g = (i>>2)&0x03;
    int b = (i>>4)&0x03; //BBGGRR
    int mindist = 10000;
    for (int j = 0; j<16; j++) {
      int r16 = (pal16[j*3+0]>>6)&0x03;
      int g16 = (pal16[j*3+1]>>6)&0x03;
      int b16 = (pal16[j*3+2]>>6)&0x03;
      int dist = 3*abs(r-r16) +4*abs(g-g16) + 2*abs(b-b16);
      //избегать замены серых цветов окрашенными:
      if ((r==g)&&(g==b)&&!((r16==g16)&&(g16==b16))) dist = 10000;
      if (dist < mindist) {
        mindist = dist;
        t64to16[i] = j;
      };

    };
  };

  for (int i = 0; i<64; i++) { //BBGGRR
    //Memo1->Lines->Add(IntToStr(t64to16[i]));
    t64to16paper[i] = ((t64to16[i]&8)<<4) | ((t64to16[i]&7)<<3);
    int rdown = (i&3) - 1; if (rdown<0) rdown = 0;
    int gdown = ((i>>2)&3) - 1; if (gdown<0) gdown = 0;
    int bdown = ((i>>4)&3) - 1; if (bdown<0) bdown = 0;
    int j = (bdown<<4) + (gdown<<2) + rdown;
    //t64to16ink[i] = ((t64to16[j]&8)<<3) | (t64to16[j]&7);
    t64to16ink[i] = ((t64to16[i]&8)<<3) | (t64to16[i]&7);
  };

  FILE* foutink;
  foutink = fopen("t64to16i", "wb");
  fwrite(t64to16ink, 64, 1, foutink);
  fclose(foutink);

  FILE* foutpaper;
  foutpaper = fopen("t64to16p", "wb");
  fwrite(t64to16paper, 64, 1, foutpaper);
  fclose(foutpaper);

  for (int i = 0; i<16; i++) {
    unsigned char b;
    int r16 = (pal16[i*3+0]>>6)&0x03;
    int g16 = (pal16[i*3+1]>>6)&0x03;
    int b16 = (pal16[i*3+2]>>6)&0x03;
    //DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
    b = ((g16&1)<<7) | ((g16&2)<<3);
    b |= ((r16&1)<<6) | ((r16&2)<<0);
    b |= ((b16&1)<<5) | ((b16&2)>>1);
    zxpal[i*2] = 255-b;
    zxpal[i*2+1] = 255-b;
  };

  FILE* foutzxpal;
  foutzxpal = fopen("zxpal", "wb");
  fwrite(zxpal, 16*2, 1, foutzxpal);
  fclose(foutzxpal);

  for (int attr = 0; attr<256; attr++) {
    int paper = ((attr&0x80)>>4) + ((attr&0x38)>>3);
    int ink = ((attr&0x40)>>3) + (attr&0x07);
    int Rmin = pal16[ink*3+0];
    int Gmin = pal16[ink*3+1];
    int Bmin = pal16[ink*3+2];
    int Rmax = pal16[paper*3+0];
    int Gmax = pal16[paper*3+1];
    int Bmax = pal16[paper*3+2];

    int dist,maxdist;
    int maxaxis;
      //ищем ось с максимальным (max-min) и берём оттуда maxcolor и mincolor
      dist = Rmax-Rmin;
      maxdist = dist; maxaxis = 0;
      dist = Gmax-Gmin;
      if (dist > maxdist) {maxdist = dist; maxaxis = 1;}
      dist = Bmax-Bmin;
      if (dist > maxdist) {maxdist = dist; maxaxis = 2;}

    if (maxaxis == 0) {min_fromattr[attr] = Rmin;};
    if (maxaxis == 1) {min_fromattr[attr] = Gmin;};
    if (maxaxis == 2) {min_fromattr[attr] = Bmin;};

    maxdistdiv_fromattr[attr] = maxdist/4 + 0x40; //tdiv addr = 0x4000

    maxaxis_fromattr[attr] = maxaxis*8 + 64;
  };

  FILE* foutmaxaxis;
  foutmaxaxis = fopen("tmaxaxis", "wb");
  fwrite(maxdistdiv_fromattr, 256, 1, foutmaxaxis);
  fwrite(min_fromattr, 256, 1, foutmaxaxis);
  fwrite(maxaxis_fromattr, 256, 1, foutmaxaxis);
  fclose(foutmaxaxis);

  for (int dist = 0; dist<64; dist++) {
    for (int delta = 0; delta<256; delta++) {
      float dist_f = dist/64.;
      float delta_f = delta/128.;
      float result = 0;
      if (dist != 0) result = delta_f/dist_f;
      if (result > 1) result = 1;
      if (delta >= 128) result = 0; //negative
      tdiv[dist*256 + delta] = (unsigned char)(int)(result*16+.5);
    };
  };

  FILE* fdiv;
  fdiv = fopen("tdiv", "wb");
  fwrite(tdiv, 16384, 1, fdiv);
  fclose(fdiv);



#define PICHGT 200
#define PICWID8 80

  TColor rgb,rgb1,rgb2,rgb1attr,rgb2attr; //BBGGRR
  //int color64;
  //int color1;
  //int color2;
  int lowx;
  int paper;
  int ink;
  int dist,maxdist;
  int maxaxis; //0..2
  int Rmin,Rmax;
  int Gmin,Gmax;
  int Bmin,Bmax;
  int Rmincolor,Rmaxcolor;
  int Gmincolor,Gmaxcolor;
  int Bmincolor,Bmaxcolor;
  int nRmincolor,nRmaxcolor;
  int nGmincolor,nGmaxcolor;
  int nBmincolor,nBmaxcolor;

  for (int y = 0; y < PICHGT; y++) {
    for (int x8 = 0; x8 < PICWID8; x8++) {
      paper = -1;
      ink = -1;
         //найти два color64, самые дальние друг от друга
         //для этого ищем по всем осям min,max,mincolor,maxcolor
         //потом ищем ось с максимальным (max-min) и берём оттуда maxcolor и mincolor
      Rmin = 0xff; Rmax = 0x00;
      Gmin = 0xff; Gmax = 0x00;
      Bmin = 0xff; Bmax = 0x00;
      for (lowx = 0; lowx < 8; lowx++) {
         rgb = Image2->Canvas->Pixels[x8*8+lowx][y*2];
          //rgb = (rgb&0xff)*0x010101;
         //color64 = ((rgb>>(16+6-4))&0x30) | ((rgb>>(8+6-2))&0x0c) | ((rgb>>(0+6-0))&0x03);
         if (getR(rgb) < Rmin) {Rmin = getR(rgb); Rmincolor = rgb; nRmincolor = lowx;};
         if (getR(rgb) >= Rmax) {Rmax = getR(rgb); Rmaxcolor = rgb; nRmaxcolor = lowx;};
         if (getG(rgb) < Gmin) {Gmin = getG(rgb); Gmincolor = rgb; nGmincolor = lowx;};
         if (getG(rgb) >= Gmax) {Gmax = getG(rgb); Gmaxcolor = rgb; nGmaxcolor = lowx;};
         if (getB(rgb) < Bmin) {Bmin = getB(rgb); Bmincolor = rgb; nBmincolor = lowx;};
         if (getB(rgb) >= Bmax) {Bmax = getB(rgb); Bmaxcolor = rgb; nBmaxcolor = lowx;};
      };
      //ищем ось с максимальным (max-min) и берём оттуда maxcolor и mincolor
      dist = Bmax-Bmin;
      maxdist = dist; maxaxis = 2;
      dist = Gmax-Gmin;
      if (dist >= maxdist) {maxdist = dist; maxaxis = 1;}
      dist = Rmax-Rmin;
      if (dist >= maxdist) {maxdist = dist; maxaxis = 0;}
      if (maxaxis == 0) {rgb1 = Rmincolor; rgb2 = Rmaxcolor;};
      if (maxaxis == 1) {rgb1 = Gmincolor; rgb2 = Gmaxcolor;};
      if (maxaxis == 2) {rgb1 = Bmincolor; rgb2 = Bmaxcolor;};
    if (y==1) {
      Memo1->Lines->Add(IntToStr(y)+':'+IntToStr(x8)+":Bmax="+IntToStr(Bmax)+",Bmin="+IntToStr(Bmin)+",Gmax="+IntToStr(Gmax)+",Gmin="+IntToStr(Gmin)+",Rmax="+IntToStr(Rmax)+",Rmin="+IntToStr(Rmin));
      Memo1->Lines->Add(IntToStr(y)+':'+IntToStr(x8)+":nBmax="+IntToStr(nBmaxcolor)+",nBmin="+IntToStr(nBmincolor)+",nGmax="+IntToStr(nGmaxcolor)+",nGmin="+IntToStr(nGmincolor)+",nRmax="+IntToStr(nRmaxcolor)+",nRmin="+IntToStr(nRmincolor));
      Memo1->Lines->Add(IntToStr(y)+':'+IntToStr(x8)+":maxaxis="+IntToStr(maxaxis));
    };

      int r,g,b;
      int i,p;
//#define ROUNDDOWN 64
#define ROUNDDOWN 32
      r = (((int)getR(rgb1)-16/*-ROUNDDOWN*/)>>6);
      g = (((int)getG(rgb1)-ROUNDDOWN)>>6);
      b = (((int)getB(rgb1)-ROUNDDOWN)>>6);
      if (r<0) r = 0;
      if (g<0) g = 0;
      if (b<0) b = 0;
      //i = t64to16[(b<<4) | (g<<2) | (r<<0)];
    if (y==1) {
      Memo1->Lines->Add(IntToStr(y)+':'+IntToStr(x8)+":r2="+IntToStr(getR(rgb2))+",g2="+IntToStr(getG(rgb2))+",b2="+IntToStr(getB(rgb2)));
      Memo1->Lines->Add(IntToStr(y)+':'+IntToStr(x8)+":inkindex64="+IntToStr((b<<4) | (g<<2) | (r<<0)));
    };
      int reali = t64to16ink[(b<<4) | (g<<2) | (r<<0)];
      i = ((reali&0x40)>>3) | (reali&7);
      r = pal16[i*3+0];
      g = pal16[i*3+1];
      b = pal16[i*3+2];
      rgb1attr = (b<<16) | (g<<8) | r;

#define ROUNDUP 32
      r = (((int)getR(rgb2)+16/*ROUNDUP*/)>>6);
      g = (((int)getG(rgb2)+ROUNDUP)>>6);
      b = (((int)getB(rgb2)+ROUNDUP)>>6);
      if (r>=4) r = 3;
      if (g>=4) g = 3;
      if (b>=4) b = 3;
      p = t64to16[(b<<4) | (g<<2) | (r<<0)];
      int realp = t64to16paper[(b<<4) | (g<<2) | (r<<0)];
      r = pal16[p*3+0];
      g = pal16[p*3+1];
      b = pal16[p*3+2];
      rgb2attr = (b<<16) | (g<<8) | r;

    //int realattr = ((p&8)<<4) | ((i&8)<<3) | ((p&7)<<3) | (i&7);
    int realattr = reali | realp;
    if (y==1) {
      Memo1->Lines->Add(IntToStr(y)+':'+IntToStr(x8)+':'+IntToStr(p)+','+IntToStr(i)+'='+IntToStr(realattr));
    };

      rgb1 = rgb1attr;
      rgb2 = rgb2attr;
/*
    dist = abs(getR(rgb2)-getR(rgb1));
    maxdist = dist; maxaxis = 0;
    dist = abs(getG(rgb2)-getG(rgb1));
    if (dist > maxdist) {maxdist = dist; maxaxis = 1;}
    dist = abs(getB(rgb2)-getB(rgb1));
    if (dist > maxdist) {maxdist = dist; maxaxis = 2;}
*/
    maxdist = (maxdistdiv_fromattr[realattr]&0x3f)*4;
    maxaxis = (maxaxis_fromattr[realattr]&0x3f) /8;
    int min = min_fromattr[realattr];
    //maxaxis = 2-maxaxis;

    /**/
    /*
    if (maxaxis == 0) maxdist = getR(rgb2)-getR(rgb1);
    if (maxaxis == 1) maxdist = getG(rgb2)-getG(rgb1);
    if (maxaxis == 2) maxdist = getB(rgb2)-getB(rgb1);
    /**/

      for (lowx = 0; lowx < 8; lowx++) {
         rgb = Image2->Canvas->Pixels[x8*8+lowx][y*2];
          //rgb = (rgb&0xff)*0x010101;

         float intlevel = 0;
         if (maxdist > 10)
         {
           if (maxaxis == 0) intlevel = (getR(rgb)-getR(rgb1))/(float)(maxdist);
           if (maxaxis == 1) intlevel = (getG(rgb)-getG(rgb1))/(float)(maxdist);
           if (maxaxis == 2) intlevel = (getB(rgb)-getB(rgb1))/(float)(maxdist);
         };
         //if (intlevel < 0) intlevel = 0;
         //if (intlevel > 1) intlevel = 1;

      int delta;
      if (maxaxis == 0) delta = (getR(rgb)-min/*getR(rgb1)*/);
      if (maxaxis == 1) delta = (getG(rgb)-min/*getG(rgb1)*/);
      if (maxaxis == 2) delta = (getB(rgb)-min/*getB(rgb1)*/);

      delta = delta / 2;
      //if (delta < 0) delta = 0;
      delta = delta&0xff;

      /*float dist_f = maxdist/256.;
      float delta_f = delta/128.;
      float result = 0;
      if (dist > 10) result = delta_f/dist_f;
      if (result > 1) result = 1;
      if (delta >= 128) result = 0; //negative
      int intintlevel = (unsigned char)(int)(result*16+.5);
      */
      int intintlevel = tdiv[256*(maxdist/4) + delta];

      int chunkpixel = (lowx&3) + ((y&3)<<2);
      //if ((int)(intlevel*16+.5) >= chunkpixelnumberdiamond[chunkpixel]) {
      if (intintlevel >= chunkpixelnumberdiamond[chunkpixel]) {
        rgb = rgb2attr;
      }else {
        rgb = rgb1attr;
      };
          //rgb =            (unsigned char)((1-intlevel)*getB(rgb1attr) + (intlevel)*getB(rgb2attr));
          //rgb = (rgb<<8) + (unsigned char)((1-intlevel)*getG(rgb1attr) + (intlevel)*getG(rgb2attr));
          //rgb = (rgb<<8) + (unsigned char)((1-intlevel)*getR(rgb1attr) + (intlevel)*getR(rgb2attr));
         ImageOut->Canvas->Pixels[x8*8+lowx][y*2] = rgb;
         ImageOut->Canvas->Pixels[x8*8+lowx][y*2+1] = rgb;

         if (realattr == 0xf1) {
           Memo1->Lines->Add(IntToStr(intintlevel));
         };
      };
    };
  };



  for (int i = 0; i<3*PALEXTRA ;i++) {
    pal[i] = palextra[i];
  };

  colindex = 3*PALEXTRA;

  for (int r = 0; r<10 ;r++) {
  for (int g = 0; g<10 ;g++) {
  for (int b = 0; b<10 ;b++) {
    if (colorexist[(9-r)*100 + (9-b)*10 + g]) {
      pal[colindex++] = r*PALCOEFF;
      pal[colindex++] = g*PALCOEFF;
      pal[colindex++] = b*PALCOEFF;
    };
  };
  };
  };

  Memo1->Lines->Add(IntToStr(colindex));

  FILE* fout;
  fout = fopen("pal256.act", "wb");
  fwrite(pal, 768, 1, fout);
  fclose(fout);

  curH = .2;
  curS = .2;
  curV = .4;

#define PI 3.14159
  for (int i=0; i<256; i++) {
    float a = (float)i/128*PI;
    tsin[i] = 127*sin(a);
  }

  showHSpalette();
  showVpalette();
  showcolor();

}

float fabs(float a)
{
  if (a>0) return a; else return -a;
}

int TForm1::calcHSVtoRGB(float h,float s,float v){
#define minC 64
#define maxC 96
#define kC 8
//#define BYTE unsigned char
  unsigned char ir,ig,ib;

  int ih,is,iv;
  ih = h*256;
  is = s*256;
  //v = 1;
  iv = v*256/kC;

  int scoeff = (1 - fabs((v-.5)*2) )*256;

  is = is*scoeff/256;

  int isi = 2*is*tsin[ih]/kC/256;
  int ic = 2*is*tsin[(64-ih)&0xff]/kC/256;

  //h=0..32
  //si,c=+-0..32

  ir = iv + 2*isi + ic + minC;
  ig = iv +       - ic + minC;
  ib = iv - 2*isi + ic + minC;

//  if (ig >= 256) {ir = ir + (ig-256); ib = ib + (ig-256); }

  if (ir<minC) ir=minC; if (ir>=maxC) ir=maxC-1;
  if (ig<minC) ig=minC; if (ig>=maxC) ig=maxC-1;
  if (ib<minC) ib=minC; if (ib>=maxC) ib=maxC-1;

  ir = (ir-minC)*kC;
  ig = (ig-minC)*kC;
  ib = (ib-minC)*kC;

  return (ib<<16) + (ig<<8) + (ir);
}

void TForm1::showcolor()
{
  int x,y;

  TColor color = calcHSVtoRGB(curH,curS,curV);
  lbR->Caption = IntToStr(color & 0xff);
  lbG->Caption = IntToStr((color>>8) & 0xff);
  lbB->Caption = IntToStr((color>>16) & 0xff);

  int hgt = curColor->Height-1;
  int wid = curColor->Width-1;

  for (y=0; y<=hgt; y++)
       for (x=0; x<=wid; x++)
          curColor->Canvas->Pixels[x][y] = color;

  hgt = curColorChunky->Height-1;
  wid = curColorChunky->Width-1;

  for (y=0; y<=hgt; y++)
       for (x=0; x<=wid; x++)
       {
          int chunkpixel = (x&3) + ((y&3)<<2);
          int ir = (color&0xff)/15;
          int ig = ((color>>8)&0xff)/15;
          int ib = ((color>>16)&0xff)/15;

          setColorChunkyR(x, y, (ir > chunkpixelnumber[chunkpixel])*255&0xff );
          setColorChunkyG(x, y, (ig > chunkpixelnumber[chunkpixel])*255&0xff );
          setColorChunkyB(x, y, (ib > chunkpixelnumber[chunkpixel])*255&0xff );
//          setColorChunkyR(x, y, (ir >= chunkpixelnumber[(x&3) + ((y&3)<<2)])*255&0xff );
//          setColorChunkyG(x, y, (ig >= chunkpixelnumber[((x+1)&3) + ((y&3)<<2)])*255&0xff );
//          setColorChunkyB(x, y, (ib >= chunkpixelnumber[(x&3) + (((y+1)&3)<<2)])*255&0xff );
       }
}

void TForm1::showVpalette()
{
  int hgt = changV->Height-1;
  int wid = changV->Width-1;
  for (int y=0;y<=hgt;y++)
  {
       for (int x=0;x<=wid;x++)
       {
          changV->Canvas->Pixels[x][y] = calcHSVtoRGB(curH,curS,(float)(hgt-1-y)/hgt);
       }
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::Image1MouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{

  curmouseH = (float)Y/(Image1->Height);
  curmouseS = (float)X/(Image1->Width);

  TColor color = calcHSVtoRGB(curmouseH,curmouseS,curV); //Image1->Canvas->Pixels[X][Y];

  lbR->Caption = IntToStr(color & 0xff);
  lbG->Caption = IntToStr((color>>8) & 0xff);
  lbB->Caption = IntToStr((color>>16) & 0xff);

}
//---------------------------------------------------------------------------


void __fastcall TForm1::Image1Click(TObject *Sender)
{
  curH = curmouseH;
  curS = curmouseS;

  showcolor();
  showVpalette();

}
//---------------------------------------------------------------------------


void __fastcall TForm1::changVMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  curmouseV = 1-(float)(Y)/(changV->Height-1);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::changVClick(TObject *Sender)
{
  curV = curmouseV;
  //showHSpalette();
  showcolor();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::curColorClick(TObject *Sender)
{
  TColor color = calcHSVtoRGB(curH,curS,curV); //Image1->Canvas->Pixels[X][Y];
//#define PI 3.14159
  float si,c;
  float h,s,v;
  float r,g,b;
  r = (float)(color & 0xff)/256;
  g = (float)((color>>8) & 0xff)/256;
  b = (float)((color>>16) & 0xff)/256;
  si = r/2-b/2;
  c = r/2+b/2-g;
  float rad = sqrt(si*si + c*c);
  Memo1->Lines->Add("r="+FloatToStr(r));
  Memo1->Lines->Add("g="+FloatToStr(g));
  Memo1->Lines->Add("b="+FloatToStr(b));
  Memo1->Lines->Add("si="+FloatToStr(si));
  Memo1->Lines->Add("c="+FloatToStr(c));
  Memo1->Lines->Add("rad="+FloatToStr(rad));

  //TODO if (rad==0) ...

  //float a=atan2(si,c);
  float a = asin(si/rad);
  if (c<0) a = PI - a;
  Memo1->Lines->Add("a="+FloatToStr(a));
  h=a/(2*PI);
  if (h<0)
     {h=h+1;}
  Memo1->Lines->Add("oldH="+FloatToStr(curH));
  Memo1->Lines->Add("H="+FloatToStr(h));
  curH=h;

  v = g/2 + r/4 + b/4;

  Memo1->Lines->Add("oldV="+FloatToStr(curV));
  Memo1->Lines->Add("V="+FloatToStr(v));
  curV=v;

  float scoeff = (1 - fabs((v-.5)*2) );
  Memo1->Lines->Add("scoeff="+FloatToStr(scoeff));
  s = rad/scoeff/1.7;
  //if (s>1) s = 1;
  Memo1->Lines->Add("oldS="+FloatToStr(curS));
  Memo1->Lines->Add("S="+FloatToStr(s));
  curS=s;

  showVpalette();
  showcolor();
}
//---------------------------------------------------------------------------

