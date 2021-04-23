// Подготовка инструкции для НЛО-2

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
int data[100][100];
char code[]=" яазвсьедцрфжтгб"
	    "ыхнуймиколпЧэЭюШ"
	    "ёЯАЗВЕСДЬЦЖФРТГБ"
	    "ХЫУЙНМКИОЛПъшщчЩ"
	    "ZЮVNSDFGJLWQRYUI"
	    "2513460987,.:;-/"
	    ")(!$%\"+?Ё#++++++";

//-----------------------------------------------------------
void convert_INSTR(char *m,unsigned *len)
{
 char *mget=m;
 unsigned l=*len;
 unsigned j;
 for(;l>0;l--)
  {
  if (*m=='*') *m=' '; //  * заменяем на пробел
  if (*m==' ' && m[1]==13){l--;m++;(*len)--;}
  switch (*m)
    {
     case 13: *mget=126;l--;m++;(*len)--;break;
     case '=': *mget=127;break;
     default: for (j=0;j<111;j++)
		if(code[j]==*m) goto M1;
		printf("Неверный символ в тексте (%c,%u) \7\n",*m,*m);
		exit(1);
	  M1: *mget=j;
    }
   m++;
   mget++;
  }
}

//-----------------------------------------------------------
void search(char *m,unsigned len)
{
 for(unsigned i=0;i<len-1;i++)
  {
   if (m[0]<100 && m[1]<100)
		data[m[0]][m[1]]++;
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
   for(i=0;i<100;i++)
    for(j=0;j<100;j++)
     if(data[i][j]>max)
	{
	 max=data[i][j];
	 maxi=i;
	 maxj=j;
	}
   cmpr[k][0]=maxi;
   cmpr[k][1]=maxj;
   data[maxi][maxj]=-(k+1);
   printf("%c%c(%3u),",code[cmpr[k][0]],code[cmpr[k][1]],max);
  }
 for(i=0;i<100;i++)
   for(j=0;j<100;j++)
     if(data[i][j]>0) data[i][j]=0;
     else data[i][j]=-data[i][j];
}
//-----------------------------------------------------------
void compress(char *m, unsigned *len)
{
 unsigned l=*len;
 char *mget=m;
 int k;
 for(;l>0;l--)
   {
//    printf("%c",*m<126?code[*m]:'\n');
    if(m[0]<100 && m[1]<100
       && (k=data[m[0]][m[1]])>0)
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
 char *b, *mw,*mm,*mP,*mN;
 unsigned i,j,k;
 printf("\n\t(c)1995 Mednonogov bros.\n");
 printf("\tПодготовка компрессированой иструкции для НЛО-2\n");
 printf("\tиз файлa xinstr.txt в файл xinstr.dat\n\n");
 int hw=open("xinstr.txt",O_BINARY | O_RDONLY);
 if (hw==-1){perror("Ошибка открытия файла слов \7\n");return -1;}
 unsigned lenw=filelength(hw);
 if(lenw==0){printf("Файл пуст!\n"); return -1;}
 if((mw=(char*)malloc(lenw))==0)
  {
   printf("Недостаточно памяти (необходимо %u Kb)!\n",lenw);
   return -1;
  }
 read(hw,mw,lenw);
 close(hw);
//---------------

 printf("Instr>%u \n",lenw);
 convert_INSTR(mw,&lenw);
 printf("Instr>%u \n",lenw);
 search(mw,lenw);
 compress_ini();
 compress(mw,&lenw);

 hw=open("xinstr.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 if (hw==-1){perror("Ошибка создания файла cлов \7\n");return -1;}
 write(hw,mw,lenw);
 printf("\nТекст иннструкции: %ukb\n",lenw);
 close(hw);
 hw=open("xinstrcm.dat",O_BINARY | O_RDWR | O_CREAT | O_TRUNC,S_IWRITE);
 if (hw==-1){perror("Ошибка создания файла дешифрации словаря \7\n")
		;return -1;}
 write(hw,cmpr,256);
 close (hw);
 printf("O.K.\n");
  return 0;
}