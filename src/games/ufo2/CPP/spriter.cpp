// Подготовка спрайтов для НЛО-2
#include <stdio.h>
#include <alloc.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>


int main(int n,char *arg[])
{
#define TIFF 194
 char *b,/*huge*/ *m,*name;
 unsigned i,j,k;
 int h;
 long len;
 int h2;
 unsigned ws,hs,xs,ys;
 char *spr;
 char *sprt;
 printf("\n\t(c)1995 Mednonogov bros.\n");
 printf("\tПодготовка спрайтов для НЛО-2\n");
 printf("\tиз файла .tif (256x192)\n");
 printf("\tс сохранением в формате .dat\n\n");
 if (n==1)
	{
	 b=(char*)malloc(60);
 inp:	 printf("Входной экранный файл : ");
	 gets(b);
	 if (strlen(b)==0) goto inp;
	}
 else b=arg[1];
 for(i=strlen (b);i>0;)
  {
   i--;
   if (b[i]=='\\') break;
   if (b[i]=='.')
     {
      b[i]=0;
      if(b[i+1]!='t' || b[i+2]!='i' || b[i+3]!='f' || b[i+4]!=0)
	{printf("Неверное расширение входного файла!\n");return -1;}
      break;
     }
  }
 name=(char*)(malloc(70));
 strcpy(name,b);
 strcat(name,".tif");
 h=open(name,O_BINARY | O_RDONLY);
 if (h==-1){perror("Ошибка открытия исходного файла (tif)\7\n");return -1;}
 len=filelength(h);
 if(len==0){printf("Файл пуст!\n"); return -1;}
 if((m=(char*)malloc(len))==0)
  {
   printf("Недостаточно памяти (необходимо %u Kb)!\n",len);
   return -1;
  }
 read(h,m,len);
 close(h);
 strcpy(name,b);
 strcat(name,".dat");
 h2=open(name,O_BINARY | O_CREAT | O_RDWR | O_TRUNC,S_IWRITE);
 if (h2==-1){perror("Ошибка открытия исходного файла (dat)\7\n");return -1;}
 m=m+TIFF;  //TIFF prefix
//---------------
 printf("Укажите:\n ширину спрайта: ");
 scanf("%u",&ws);
 printf(" высоту спрайта: ");
 scanf("%u",&hs);
 printf(" начальную строку: ");
 scanf("%u",&ys);
 printf(" начальную колонку: ");
 scanf("%u",&xs);
 spr=(char *)malloc(ws*hs*8);
 sprt=spr;
 for (i=0;i<hs;i++)
  for (k=0;k<8;k++)
  for (j=0;j<ws;j++)
   {
    *sprt=~m[(xs+j)+k*32+(ys+i)*256];
    sprt++;
//    printf("%5u%5u%5u\r",i,j,k);
   }
 write(h2,spr,ws*hs*8);
 printf("\nCохранён спрайт длиной %u байт.\n",ws*hs*8);
 return 0;
}