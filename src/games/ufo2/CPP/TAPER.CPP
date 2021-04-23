#include <stdio.h>
#include <alloc.h>
#include <string.h>
#include <ctype.h>
#include <process.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>
#include <dos.h>
#include <conio.h>
#define b16len 16384
//cоздание ТАР файла
int HO,HI;
FILE * HASM;
char *fn[]={
  "m2","m3","m4","m5","m10","m7","m8","m9",
  "m6","m11","m12","m13","m14","m15","m16",
  "m17","m18","m19","m20",

  "l2","END","l3","l4","l5a","l5b","l5c","l5d",
  "l6a","l6b","l6c","l6d","X2","l7",
  "l8a","l8b","l8c","l8d","l9","X3",
  "l10a","l10b","l10c","l10d","l11",
  "l12","l13","l14","l15","l19",
  "l17","l18","l16","l20",

  "up1","up2","up3","up4","up5","up6","up7",
  "up8","up9","up10","up11","up12","up13","up14",
  "up15","up16","up17","up18","up19","up20",

  "0"};

int fnum=0 ;


int main() // ***MAIN***
{
 char *z,*b,*m,*name;
 unsigned i,j,k;
 char *Fname=(char*)malloc(80);
 for (;fn[fnum][0]!='0';fnum++);
 printf("\n\t (c)1995,96  Медноногов В.C.\t\t");
 printf("\n\tСоздание файла xcom.tap\n");
 printf("\tиз %u LPC-файлов\n\n",fnum);
 strcpy(Fname,"d:\\'ufo2'\\zx_disc\\xcom.tap");
 HO=open(Fname,O_BINARY | O_CREAT | O_TRUNC | O_RDWR,S_IWRITE);
 if (HO==-1) {perror("Ошибка создания ленточного файла\7\n");return 1;}
 strcpy(Fname,"d:\\'ufo2'\\Asm80\\xtap.a80");
 HASM=fopen(Fname,"w");
 #define IO_Buff_Size 512*16
 char IObuff[IO_Buff_Size]; //Буфер листинга
 if (HASM==0) {perror("Ошибка открытия файла листинга \n\7");return 1;}
 if(setvbuf(HASM,IObuff,_IOFBF,IO_Buff_Size))
		{printf("I/O error\7\n");return 1;}
 fputs("; Длины файлов для НЛО-2 ***** (c) 1996 Медноногов В.C.\n\n",HASM);

 for(i=1;i<fnum+1;i++)
  {
   sprintf(Fname,"d:\\'ufo2'\\zx_disc\\x%s.lpc",fn[i-1]);
   printf("d:\\'ufo2'\\zx_disc\\x%s.lpc",fn[i-1]);
   HI=open(Fname,O_RDONLY | O_BINARY);
   if(HI==-1) {perror("Fatal! \7");return 1;}
   unsigned blen=filelength(HI);
   printf("   Длина: %u\n",blen);
   char *mem=(char*)malloc(blen);
   if(mem==0){perror("No mem!\7");return 1;}
   read(HI,mem,blen);
   blen=blen;
   blen+=2;
   write(HO,&blen,2);
   write(HO,&i,1);
   blen-=2;
   write(HO,mem,blen);
   char ccr=(char)i;
   for(k=0;k<blen;k++)ccr^=mem[k];
   write(HO,&ccr,1);
   close (HI);
   free(mem);
   fprintf(HASM,"\tDEFW\t\%5u ;#%u (%s)\n",blen,i,fn[i-1]);
  }
  close(HO);
  fclose(HASM);
  return 0;
}