// Подготовка текстов для НЛО-2
#include <stdio.h>
#include <alloc.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <process.h>
char x256[256];
int lenx256=0;
char cmpr[128][2];
unsigned cc=0;
int data[80-15][80-15];
char code[]="0123456789?-.,: "
	    "АБВГДЕЁЖЗИЙКЛМНО"
	    "ПРСТУФХЦЧШЩЬЫЭЮЯ"
	    "абвгдеёжзийклмно"
	    "прстуфхцчшщьыэюя"
	    "DFGIJLNQRSUVWYZ!"
	    "()_/%>\"$ФФФФФФФФ"
	    "ъ^'";
//-----------------------------------------------------------
void convert_word(char *m,int *len)
{
 char *mget=m;
 int l=*len;
 int j;
 for(;l>0;l--)
  {
   switch (*m)
    {
     case 13: *mget=126;l--;m++;(*len)--;lenx256++;break;
     case '#': *m=' ';
     default: for (j=0;j<115;j++)
		if(code[j]==*m) goto M1;
		printf("Неверный символ в словаре(%u,%c) \7\n",*m,*m);
		exit(1);
	  M1: *mget=j;
    }
   m++;
   mget++;
  }
}

//-----------------------------------------------------------
void convert_menu(char *m,int *len)
{
 char *mget=m;
 int l=*len;
 int j;
 for(;l>0;l--)
  {
   switch (*m)
    {
     case 13: *mget=127;l--;m++;(*len)--;break;
     case '¤': *mget=126;break;
     default: for (j=0;j<115;j++)
		if(code[j]==*m) goto M1;
		printf("Неверный символ в меню (%c,%u) \7\n",*m,*m);
		exit(1);
	  M1: *mget=j;
    }
   m++;
   mget++;
  }
}

//-----------------------------------------------------------
void convert_ufopedia(char *m,int *len)
{
 char *mget=m;
 int l=*len;
 int j;
 m[0]=' ';
 m[1]=' ';
 for(;l>0;l--)
  {
//   printf("%c",*m);
   switch (*m)
    {
     case 13: *mget=127;l--;m++;(*len)--;
	      if(m[1]>='0')
	       {
		m[1]=' '; //номер XX
		m[2]=' ';
	       }
	      break;
     case '&':mget--;(*len)--;break;
     case '#': *mget=126;break;
     default: for (j=0;j<115;j++)
		if(code[j]==*m) goto M1;
		printf("Неверный символ в энциклопедии(%c,%i) \7\n",*m,*m);
		exit(1);
	  M1: *mget=j;

    }
   m++;
   mget++;
  }
}
//-----------------------------------------------------------
void formatter(char *m,int len)
{
 int i,max=0,k=0,maxi=0;
 char *mj=m;
 for(i=0;i<len;i++)
  {
   switch (*mj)
    {
     case 126:
     case 127:  max=k;
     case 15:if(k>27)
		{
		 if(m[maxi]<126) m[maxi]=126;
		 max=k=k-max;
		 maxi=i;
		}
	     else
	       if (*mj<126)
		{max=k;k++;maxi=i;}
	       else
		{maxi=i;max=0;k=0;}
	     break;
     default:  k++;
    }
   mj++;
  }
  mj=m;
/*  for(i=0;i<len;i++,mj++)
   switch(*mj)
    {
     case 126: printf("\n");break;
     case 127: printf("\n************\n");break;
     default:printf("%c",code[*mj]);
    }*/
}
//-----------------------------------------------------------
void search(char *m,int len)
{
 int i;
 for(i=0;i<len-1;i++)
  {
   if(m[0]>=15 && m[0]<80 && m[1]>=15 && m[1]<80)
		data[m[0]-15][m[1]-15]++;
   m++;
  }
}
//-----------------------------------------------------------
void compress_ini()
{
 int i,j,k;
 int max,maxi,maxj;
 for(k=0;k<128;k++)
  {
   max=maxi=maxj=0;
   for(i=0;i<80-15;i++)
    for(j=0;j<80-15;j++)
     if(data[i][j]>max)
	{
	 max=data[i][j];
	 maxi=i;
	 maxj=j;
	}
   cmpr[k][0]=maxi+15;
   cmpr[k][1]=maxj+15;
   data[maxi][maxj]=-(k+1);
   printf("%c%c(%3u),",code[cmpr[k][0]],code[cmpr[k][1]],max);
  }
 for(i=0;i<80-15;i++)
   for(j=0;j<80-15;j++)
     if(data[i][j]>0) data[i][j]=0;
     else data[i][j]=-data[i][j];
}
//-----------------------------------------------------------
void compress(char *m, int *len)
{
 int l=*len;
 char *mget=m;
 int k;
 for(;l>0;l--)
   {
//    printf("%c",*m<126?code[*m]:'\n');
    if(m[0]>=15 && m[0]<80 && m[1]>=15 && m[1]<80
       && (k=data[m[0]-15][m[1]-15])>0)
       {
	*mget=k+127;
	m++;
	(*len)--;
	l--;
       }
    else *mget=*m;
    m++;
    mget++;
   }
}
//-----------------------------------------------------------

int main()
{
 char *b, *mw,*mm,*mP,*mN,*mE;
 unsigned i,j,k;
 int hw;
 int lenw;
 int hN;
 int lenN;
 int hm;
 int lenm;
 int hP;
 int lenP;
 int hE;
 int lenE;
 printf("\n\t(c)1995 Mednonogov bros.\n");
 printf("\tПодготовка компрессированых текстов для НЛО-2\n");
 printf("\tиз файлов xword.txt, xfopedia.txt, xmenu.txt\n");
 printf("\tв файлы xword.dat, xfopedia.dat, xmenu.dat, xcompres.dat\n\n");
 hw=open("xword.txt",O_BINARY | O_RDONLY);
 if (hw==-1){perror("Ошибка открытия файла слов \7\n");return -1;}
 lenw=filelength(hw);
 if(lenw==0){printf("Файл пуст!\n"); return -1;}
 if((mw=(char*)malloc(lenw))==0)
  {
   printf("Недостаточно памяти (необходимо %u Kb)!\n",lenw);
   return -1;
  }
 read(hw,mw,lenw);
 close(hw);
 hN=open("xname.txt",O_BINARY | O_RDONLY);
 if (hN==-1){perror("Ошибка открытия файла имён \7\n");return -1;}
 lenN=filelength(hN);
 if(lenN==0){printf("Файл пуст!\n"); return -1;}
 if((mN=(char*)malloc(lenN))==0)
  {
   printf("Недостаточно памяти (необходимо %u Kb)!\n",lenN);
   return -1;
  }
 read(hN,mN,lenN);
 close(hN);
 hm=open("xmenu.txt",O_BINARY | O_RDONLY);
 if (hm==-1){perror("Ошибка открытия файла меню \7\n");return -1;}
 lenm=filelength(hm);
 if(lenm==0){printf("Файл пуст!\n"); return -1;}
 if((mm=(char*)malloc(lenm))==0)
  {
   printf("Недостаточно памяти (необходимо %u Kb)!\n",lenm);
   return -1;
  }
 read(hm,mm,lenm);
 close(hm);
 hP=open("xfopedia.txt",O_BINARY | O_RDONLY);
 if (hP==-1){perror("Ошибка открытия файла энциклопедии \7\n");return -1;}
 lenP=filelength(hP);
 if(lenP==0){printf("Файл пуст!\n"); return -1;}
 if((mP=(char*)malloc(lenP))==0)
  {
   printf("Недостаточно памяти (необходимо %u Kb)!\n",lenP);
   return -1;
  }
 read(hP,mP,lenP);
 close(hP);
 hE=open("xend.txt",O_BINARY | O_RDONLY);
 if (hE==-1){perror("Ошибка открытия файла концовки \7\n");return -1;}
 lenE=filelength(hE);
 if(lenE==0){printf("Файл пуст!\n"); return -1;}
 if((mE=(char*)malloc(lenE))==0)
  {
   printf("Недостаточно памяти (необходимо %u Kb)!\n",lenE);
   return -1;
  }
 read(hE,mE,lenE);
 close(hE);
//---------------

 printf("Wr>%u  Mn>%u  Up>%u Nm>%u \n",lenw,lenm,lenP,lenN);
 convert_word(mw,&lenw);
 convert_word(mN,&lenN);
 convert_word(mE,&lenE);
 convert_menu(mm,&lenm);
 convert_ufopedia(mP,&lenP);
 formatter(mP,lenP);
 printf("Wr>%u  Mn>%u  Up>%u\n",lenw,lenm,lenP);
 search(mw,lenw);
 search(mN,lenN);
 search(mm,lenm);
 search(mP,lenP);
 compress_ini();
 compress(mw,&lenw);
 compress(mN,&lenN);
 compress(mP,&lenP);
 compress(mm,&lenm);
 hm=open("xmenu.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 if (hm==-1){perror("Ошибка создания файла меню \7\n");return -1;}
 write(hm,mm,lenm);
 printf("\nФайл меню: %ukb\n",lenm);
 close(hm);
 hm=open("xname.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 if (hm==-1){perror("Ошибка создания файла имён \7\n");return -1;}
 write(hm,mN,lenN);
 printf("Файл имён: %ukb\n",lenN);
 close(hm);
 hm=open("xfopedia.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 if (hm==-1){perror("Ошибка создания файла меню \7\n");return -1;}
 write(hm,mP,lenP);
 printf("Файл энциклопедии: %ukb\n",lenP);
 close(hm);
 hw=open("xword.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 if (hw==-1){perror("Ошибка создания файла cлов \7\n");return -1;}
 write(hw,mw,lenw);
 printf("Словарь: %ukb\n",lenw);
 close(hw);
 hw=open("xend.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 if (hw==-1){perror("Ошибка создания файла концовки \7\n");return -1;}
 write(hw,mE,lenE);
 close(hw);
 hw=open("xcompres.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 if (hw==-1){perror("Ошибка создания файла дешифрации словаря \7\n")
		;return -1;}
 write(hw,cmpr,256);
 close (hw);
 hw=open("x256.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 for (i=0;i<256;i++)x256[i]=i;
 if (hw==-1){perror("Ошибка создания файла дешифрации словаря \7\n")
		;return -1;}
 write(hw,x256,256);
 printf("O.K.\n");
 close(hw);
  return 0;
}