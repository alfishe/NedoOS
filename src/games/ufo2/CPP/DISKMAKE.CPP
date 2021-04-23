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
//cоздание образов диска 1 и 2 файла
int HO,HI;
FILE * HASM;
char *fn[]={
  "m2","m3","m4","m5","m10","m7","m8","m9",
  "m6","m11","m12","m13","m14","m15","m16",
  "m17","m18","m19","m20",

  "l2","end","l3","l4","l5a","l5b","l5c","l5d",
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
unsigned blen;

char *fn1[]={
"DANGEROU.LPC",
//;-----------------
"XBINSTR.LP0","XBINSTR.LP1",
//;-----------------
"XCOM3.PG7",
"XCOM3.PG0","XCOM3.PG1","XCOM3.PG3","XCOM3.PG4",
"XCOM3.PG5","XCOM3.PG2",
  "?","?","?",
//;-----------------
"XDEMO0.LPC","XDEMO1.LPC","XDEMO2.LPC","XDEMOS6.LPC",
"XDEMOS7.LPC","XDEMOTXT.LPC","XBEGIN.LPC",
//;-----------------
"0"};

int disk2() // ***MAIN***
{
 char *z,*b,*m,*name;
 unsigned i,j,k;
 char *Fname=(char*)malloc(80);
 for (;fn[fnum][0]!='0';fnum++);
 strcpy(Fname,"d:\\'ufo2'\\xd2\\DISK.BIN");
 HO=open(Fname,O_BINARY | O_CREAT | O_TRUNC | O_RDWR,S_IWRITE);
 if (HO==-1) {perror("Ошибка создания образа диска\7\n");return 1;}
 strcpy(Fname,"d:\\'ufo2'\\Asm80\\xdisk2.a80");
 HASM=fopen(Fname,"w");
 #define IO_Buff_Size 512*16
 char IObuff[IO_Buff_Size]; //Буфер листинга
 if (HASM==0) {perror("Ошибка открытия файла листинга \n\7");return 1;}
 if(setvbuf(HASM,IObuff,_IOFBF,IO_Buff_Size))
		{printf("I/O error\7\n");return 1;}
 fputs("; Длины файлов для НЛО-2 ***** (c) 1996 Медноногов В.C.\n",HASM);
 fputs("; Номер сектора (1), смещение в секторе/4 (1)\n\n",HASM);
   sprintf(Fname,"d:\\'ufo2'\\xd2\\xbstart2.bin");
   HI=open(Fname,O_RDONLY | O_BINARY);
   if(HI==-1) {perror("Fatal!!! \7");return 1;}
   blen=filelength(HI);
   if (blen>1024) {printf("Sec 9 fatal!\n");return 1;}
   blen=1024;
   printf("  Sec 9: 1024\n");
   char *mem=(char*)malloc(blen);
   if(mem==0){perror("No mem 1024!\7");return 1;}
   read(HI,mem,blen);
   write(HO,mem,blen);
   close (HI);
   free(mem);
   long unsigned sumlen=0;
   unsigned shift=0;
   unsigned secn=0;

 for(i=1;i<fnum+1;i++)
  {
   sprintf(Fname,"d:\\'ufo2'\\zx_disc\\x%s.lpc",fn[i-1]);
   printf("d:\\'ufo2'\\zx_disc\\x%s.lpc",fn[i-1]);
   HI=open(Fname,O_RDONLY | O_BINARY);
   if(HI==-1) {perror("Fatal! \7");return 1;}
   blen=filelength(HI);
   printf("   Длина: %u\r",blen);
   char *mem=(char*)malloc(blen);
   if(mem==0){perror("No mem!\7");return 1;}
   read(HI,mem,blen);
   j=blen%4;
   if (j!=0) blen=blen-j+4;
   write(HO,mem,blen);
   close (HI);
   free(mem);
   fprintf(HASM,"\tDEFB\t%u,%u ;#%u (%s)\n",secn,shift,i,fn[i-1]);
   sumlen+=(long unsigned)blen;
   shift=(sumlen%1024L)/4;
   secn=sumlen/1024L;
   if (secn>=256) secn-=256;
  }
  fprintf(HASM,"\tDEFB\t%u,%u ;the end\n\n",secn,shift);
  close(HO);
  fclose(HASM);
  return 0;
}

int disk1() // ***MAIN***
{
 char *z,*b,*m,*name;
 unsigned i,j,k;
 char *Fname=(char*)malloc(80);
 for (fnum=0;fn1[fnum][0]!='0';fnum++);
 strcpy(Fname,"d:\\'ufo2'\\xd1\\DISK.BIN");
 HO=open(Fname,O_BINARY | O_CREAT | O_TRUNC | O_RDWR,S_IWRITE);
 if (HO==-1) {perror("Ошибка создания образа диска\7\n");return 1;}
 strcpy(Fname,"d:\\'ufo2'\\Asm80\\xdisk1.a80");
 HASM=fopen(Fname,"w");
 #define IO_Buff_Size 512*16
 char IObuff[IO_Buff_Size]; //Буфер листинга
 if (HASM==0) {perror("Ошибка открытия файла листинга \n\7");return 1;}
 if(setvbuf(HASM,IObuff,_IOFBF,IO_Buff_Size))
		{printf("I/O error\7\n");return 1;}
 fputs("; Длины файлов на диске 1 *** (c) 1996 Медноногов В.C.\n",HASM);
 fputs(";  Cектор(1), трек(1), длина/512 (1) \n\n",HASM);

   sprintf(Fname,"d:\\'ufo2'\\xd1\\xbstart.bin");
   HI=open(Fname,O_RDONLY | O_BINARY);
   if(HI==-1) {perror("Fatal!!! \7");return 1;}
   blen=filelength(HI);
   if (blen>1024) {printf("Sec 9/disk1 fatal!\n");return 1;}
   blen=1024;
   printf("  Sec 9: 1024\n");
   char *mem=(char*)malloc(blen);
   if(mem==0){perror("No mem 1024!\7");return 1;}
   read(HI,mem,blen);
   write(HO,mem,blen);
   close (HI);
   free(mem);

 unsigned trk=1;
 unsigned sec=0;
 for(i=1;i<fnum+1;i++)
  {
   sprintf(Fname,"d:\\'ufo2'\\xd1\\%s",fn1[i-1]);
   printf("d:\\'ufo2'\\xd1\\%s",fn1[i-1]);
   if (fn1[i-1][0] != '?')
    {
     HI=open(Fname,O_RDONLY | O_BINARY);
     if(HI==-1) {perror("Fatal! \7");return 1;}
     blen=filelength(HI);
     printf(" * Длина: %u\n",blen);
     if (blen%512>0) blen=(blen/512+1)*512;
     char *mem=(char*)malloc(blen);
     if(mem==0){perror("No mem!\7");return 1;}
     read(HI,mem,blen);
     write(HO,mem,blen);
     close (HI);
     free(mem);
     blen/=512;
     fprintf(HASM,"\tDEFB\t%u,%u ; File #%u\n",sec+0xF5,trk,i);
     fprintf(HASM,"\tDEFB\t%u ; (%s)\n",blen,fn1[i-1]);
    }
   else
    {
     fprintf(HASM,"\tDEFB\t#F6,%u,32 ; none\n",i*3);
     blen=0;
    }
   for (;blen>0;blen--)
    {
     sec++;
     if (sec>8) {sec=0;trk++;}
    }
  }
  close(HO);
  fclose(HASM);
  return 0;
}

int main()
{
 printf("\n\t (c)1995,96  Медноногов В.C.\t\t");
 printf("\n\tСоздание файлов disk.bin\n");
 printf("\tдля дисков 1 и 2 игры\n");
 printf("\tиз %u LPC-файлов\n\n",fnum);
  disk2();
  disk1();
  return 0;
}