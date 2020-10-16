//---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>
#pragma hdrstop

#include "nedodefs.h"

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

#define FLOAT int

#define SQRTFIXK 256L
#define FIXK (SQRTFIXK*SQRTFIXK)

#define spheres 2
FLOAT cx[spheres] = {
        (FLOAT)(-30*FIXK/100), (FLOAT)(90*FIXK/100)
};
FLOAT cy[spheres] = {
        (FLOAT)(-80*FIXK/100), (FLOAT)(-110*FIXK/100)
};
FLOAT cz[spheres] = {
        (FLOAT)(300*FIXK/100), (FLOAT)(200*FIXK/100)
};
FLOAT r[spheres] = {(FLOAT)(60*FIXK/100), (FLOAT)(20*FIXK/100)};
FLOAT q[spheres];

    FLOAT projx[spheres];
    FLOAT projy[spheres];
    FLOAT projr[spheres];

TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

FLOAT umul(FLOAT a,FLOAT b)
{
  RETURN ((a>>8) * (b>>8));
}

FLOAT mul(FLOAT a,FLOAT b)
{
  FLOAT res;
  FLOAT ia;
  FLOAT ib;
  ia = a;
  ib = b;
  IF (ia < 0 /*>= 0x80000000L*/) {ia = -ia;};
  IF (ib < 0 /*>= 0x80000000L*/) {ib = -ib;};
  res = umul(ia, ib);
  IF ((a^b) < 0 /*>= 0x80000000L*/) {res = -res;};
  RETURN res;
}

FLOAT udiv(FLOAT a,FLOAT b)
{
  FLOAT ib;
  ib = b>>8;///SQRTFIXK;
  if (ib == 0L) {
    ib = 1L;
  };
  RETURN ((a / ib)<<8/**SQRTFIXK*/);
}

FLOAT idiv(FLOAT a,FLOAT b)
{
  FLOAT res;
  FLOAT ia;
  FLOAT ib;
  ia = a;
  ib = b;
  IF (ia < 0 /*>= 0x80000000L*/) {ia = -ia;};
  IF (ib < 0 /*>= 0x80000000L*/) {ib = -ib;};
  res = udiv(ia, ib);
  IF ((a^b) < 0 /*>= 0x80000000L*/) {res = -res;};
  RETURN res;
}

FLOAT add(FLOAT a,FLOAT b)
{
  RETURN (a + b);
}

FLOAT mul2(FLOAT a)
{
  RETURN add(a,a);
}

FLOAT sub(FLOAT a,FLOAT b)
{
  RETURN (a - b);
}

FLOAT neg(FLOAT a)
{
  RETURN (-a);
}

UINT lsqrt(FLOAT arg)
{
  BYTE count=0x10;
  UINT res=0;
  UINT tmp=0;
  IF (arg!=0L) {
/*    IF (!(arg&0xFF000000L)) {
      arg = arg<<8;
      count-=4;
    };*/
    res = 1;
    WHILE ((tmp<1)&&(count!=0x00)){
      DEC count;
      IF (arg&0x80000000L) {tmp|=2;};
      IF (arg&0x40000000L) {tmp|=1;};
      arg = arg << 2L;
    };//поиск первой 1-ы
    DEC tmp;

    WHILE (count!=0x00) {
      tmp = tmp << 2;
      res = res + res; //res << 1;
      DEC count;
      IF (arg&0x80000000L) {tmp = tmp | 2;};
      IF (arg&0x40000000L) {tmp = tmp | 1;};
      arg = arg << 2L;
      IF (tmp >= ((res<<1)|1)) {
        tmp = tmp - ((res<<1)|1);
        res = res | 1;
      };
    };
  };
  RETURN res;
}

FLOAT root(FLOAT a)
{
  RETURN ((FLOAT)lsqrt(a)*SQRTFIXK);
}

FLOAT fract(FLOAT a)
{
  RETURN ( a & (FIXK/2) /*!= 0L*/ );
}

BOOL positive(FLOAT a)
{
  RETURN (a >= 0 /*< 0x80000000L*/);
}

BOOL less(FLOAT a, FLOAT b)
{
  RETURN ((unsigned int)a < (unsigned int)b);
}


void TForm1::prhex(AnsiString name, int a)
{
  AnsiString s = "";
  AnsiString sc = " ";
  char c;
  for (int i = 0; i < 8; i++) {
    c = (a & 0x0f) + '0';
    if (c>=('0'+10)) c = c+'a'-('0'+10);
    sc[1] = c;
    s = sc + s;
    a = a >> 4;
  };
  Memo1->Lines->Add(name+s);
}

PROC TForm1::tracepixel(int i,int j)
{
  BYTE n;
  BYTE k;
  FLOAT s;
  FLOAT px;
  FLOAT py;
  FLOAT pz;
  FLOAT sc;
  FLOAT aa;
  FLOAT bb;
  FLOAT pp;
  FLOAT nx;
  FLOAT ny;
  FLOAT nz;
  FLOAT nn;
  FLOAT u;
  FLOAT v;
  FLOAT l;

  FLOAT x;
  FLOAT y;
  FLOAT z;
  FLOAT dx;
  FLOAT dy;
  FLOAT dz;
  FLOAT dd;

#define GROUND 0xfe
#define SKY 0xff
#define EYEX (FLOAT)(30*FIXK/100)
#define EYEY (FLOAT)(-50*FIXK/100)
#define EYEZ (FLOAT)(0*FIXK/100)

  x = EYEX;
  y = EYEY;
  z = EYEZ;
#define KVECTOR 64L
//  dx = (FLOAT)((FLOAT)(j-128)*FIXK/KVECTOR);
//  dy = (FLOAT)((FLOAT)(88-i)*FIXK/KVECTOR);
//  dz = (FLOAT)((FLOAT)(300)*FIXK/KVECTOR);
#define MULVECTOR 0x0400L
  dx = mul(((FLOAT)(j)-(FLOAT)(128))*FIXK, MULVECTOR);
  dy = mul(((FLOAT)(88)-(FLOAT)(i))*FIXK, MULVECTOR);
  dz = mul((FLOAT)(256)*FIXK, MULVECTOR);
  //prhex("dx=",dx);
  //prhex("dy=",dy);
  //prhex("dz=",dz);

  dd = add(mul(dx,dx),add(mul(dy,dy),mul(dz,dz))); //dx*dx+dy*dy+dz*dz;
  //prhex("dx*dx=",mul(dx,dx));
  //prhex("dy*dy=",mul(dy,dy));
  //prhex("dz*dz=",mul(dz,dz));
  //prhex("dd=",dd);

L100:
  IF (positive(y) || !positive(dy)) {
    n = SKY;
    s = 0x7fffffffL;
  }ELSE {
    n = GROUND;
    s = neg(idiv(y, dy)); //-y/dy; //???
  };
  //prhex("s=",s);

  k = 0x00;
  REPEAT { //ищем сферу, на которую смотрим (если есть)
    px = sub(cx[k], x); //c[k][0]-x;
    //prhex("px=",px);
    py = sub(cy[k], y); //c[k][1]-y;
    //prhex("py=",py);
    pz = sub(cz[k], z); //c[k][2]-z;
    //prhex("pz=",pz);

#define FIXX 256
#define SCRX (((FLOAT)(j)-(FLOAT)(128))*FIXX)
#define SCRY (((FLOAT)(88)-(FLOAT)(i))*FIXX)
    IF (!(
        (SCRX >= sub(projx[k],projr[k]))
      &&(SCRX < add(projx[k],projr[k]))
      &&(SCRY >= sub(projy[k],projr[k]))
      &&(SCRY < add(projy[k],projr[k]))
//      &&((i^j)&1)
       )) {
      //Image1->Canvas->Pixels[j][175-i] = 0xff7fff;
      goto L200; //не та сфера
      //goto RETURNME;
    };

    pp = add(mul(px,px),add(mul(py,py),mul(pz,pz))); //px*px+py*py+pz*pz;
  //prhex("px*px=",mul(px,px));
  //prhex("py*py=",mul(py,py));
  //prhex("pz*pz=",mul(pz,pz));
    //prhex("pp=",pp);
    sc = add(mul(px,dx),add(mul(py,dy),mul(pz,dz))); //px*dx+py*dy+pz*dz;
    //prhex("sc=",sc);
    IF (!positive(sc)) {
      goto L200; //не та сфера
    };
    bb = idiv(mul(sc,sc),dd); //sc*sc/dd;
    //prhex("bb=",bb);
    aa = q[k]-pp+bb; //add(sub(q[k],pp),bb); //q[k]-pp+bb;
    //prhex("aa=",aa);
    IF (!positive(aa)) {
      goto L200; //не та сфера
    };
    sc = idiv(sub(root(bb),root(aa)),root(dd)); //(sqrt(bb)-sqrt(aa))/sqrt(dd);
    //prhex("scp=",sub(root(bb),root(aa)));
    //prhex("scq=",root(dd));
    //prhex("sc=",sc);
//    IF (less(sc,s) /*|| (n >= 0x80)*/) { //нашли сферу
      n = k;
      s = sc;
      goto LFOUND;
//    };
L200:
    INC k;
  }UNTIL (k == spheres);
  IF (n == SKY) {goto RETURNME;}; //небо
LFOUND:
//    Image1->Canvas->Pixels[j][175-i] = 0x007fff;
//    goto RETURNME;
  dx = mul(dx,s); //dx*s;
  dy = mul(dy,s); //dy*s;
  dz = mul(dz,s); //dz*s;
  //prhex("dx=",dx);
  //prhex("dy=",dy);
  //prhex("dz=",dz);
  dd = mul(dd,mul(s,s)); //dd*s*s;
  //prhex("dd=",dd);
  x = add(x,dx);  //x+dx;
  y = add(y,dy); //y+dy;
  z = add(z,dz); //z+dz;
  IF (n == GROUND) {goto L300;}; //земля
  nx = sub(x,cx[n]); //x-c[n][0];
  ny = sub(y,cy[n]); //y-c[n][1];
  nz = sub(z,cz[n]); //z-c[n][2];
  nn = add(mul(nx,nx),add(mul(ny,ny),mul(nz,nz))); //nx*nx+ny*ny+nz*nz;
  //prhex("nn=",nn);
  l = idiv(mul2(add(mul(dx,nx),add(mul(dy,ny),mul(dz,nz)))),nn); //2*(dx*nx+dy*ny+dz*nz)/nn;
  //prhex("l=",l);
  dx = sub(dx,mul(nx,l)); //dx-nx*l;
  dy = sub(dy,mul(ny,l)); //dy-ny*l;
  dz = sub(dz,mul(nz,l)); //dz-nz*l;
  //prhex("dx=",dx);
  //prhex("dy=",dy);
  //prhex("dz=",dz);
  goto L100; //отражение

L300: //земля
  k = 0x00;
  REPEAT {
    u = sub(cx[k],x); //c[k][0]-x;
    v = sub(cz[k],z); //c[k][2]-z;
    IF (add(mul(u,u),mul(v,v)) <= q[k]) {goto RETURNME;};  //(u*u+v*v)
    INC k;
  }UNTIL (k == spheres);
  IF (fract(x) != fract(z)) {Image1->Canvas->Pixels[j][175-i] = 0xffffff;};   //((x+100)-(int)(x+100))  //(z-(int)(z))
RETURNME:
}

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  BYTE i;
  BYTE j;
  BYTE k;

  k = 0x00;
  REPEAT {
    q[k] = mul(r[k],r[k]); //r[k]*r[k];
    INC k;
  }UNTIL (k == spheres);

  k = 0x00;
  REPEAT {
    projx[k] = idiv(sub(cx[k],EYEX), sub(cz[k],EYEZ));
    projy[k] = idiv(sub(cy[k],EYEY), sub(cz[k],EYEZ));
    projr[k] = idiv(r[k]*17/16, sub(cz[k],EYEZ)); //больше, потому что "бок" сферы торчит за проекцию
  prhex("projx=",projx[k]);
  prhex("projy=",projy[k]);
  prhex("projr=",projr[k]);
    INC k;
  }UNTIL (k == spheres);

  i = 0x00;
  REPEAT {
    j = 0x00;
    REPEAT {
      Image1->Canvas->Pixels[j][175-i] = 0x000000;
      tracepixel(i,j);
      INC j;
    }UNTIL (j == (BYTE)255);
    INC i;
  }UNTIL (i == (BYTE)175);

  cx[0] = cx[0]+(FLOAT)(10*FIXK/100);
  cz[1] = cz[1]+(FLOAT)(30*FIXK/100);

  Memo1->Lines->Add(IntToStr(0x100000000000000 >> 16));

}
//---------------------------------------------------------------------------
