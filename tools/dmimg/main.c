#include <stdio.h>
#include <stdlib.h>
#include "ff.h"

FILE * img=NULL;
FILE * f1=NULL;
FATFS fs;
FIL f2;
char * cc="";
char buf[8*1024];
int imagemnt(char * imgname){
	int res;
	if((img=fopen(imgname,"rb+"))==NULL) {
		printf("Image file %s not open.\n",imgname);
		return 1;
	}
	if(res=f_mount(&fs, "0:", 1)){
		printf("f_mount error %d.",res);
		return 1;
	}
	return 0;
}

int parsearg(char * arg){
	int res;
	if(arg[0] != '-') return imagemnt(arg);
	switch(arg[1]){
		case 'S':
			
			break;
	}
	return 0;
}

int main (int argc, char *argv[]){
	DIR dr;
	FILINFO fi;
	int res;
    SetConsoleCP(866);// установка кодовой страницы win-cp 1251 в поток ввода
    SetConsoleOutputCP(866); // установка кодовой страницы win-cp 1251 в поток вывода

	if(argc<3){
		puts("Error: Need more parameters.");
		exit(1);
	}
	if(imagemnt(argv[1])) exit(2);
	
	if(strcmp(argv[2],"mkdir")==0){
		//printf("mkdir ");
		if(argc!=4){
			puts("Error: wrong namber parameters");
			exit(1);
		}
		//puts(argv[3]);
		if(res=f_mkdir(argv[3])){
			printf("Error fatfs: %d",res);
			exit(1);
		}
	}else if(strcmp(argv[2],"del")==0){
		//printf("del ");
		if(argc!=4){
			puts("Error: wrong namber parameters");
			exit(1);
		}
		//puts(argv[3]);
		if(res=f_unlink(argv[3])){
			printf("Error fatfs: %d",res);
			exit(1);
		}
	}else if(strcmp(argv[2],"put")==0){
		//printf("put ");
		if(argc!=5){
			puts("Error: wrong namber parameters");
			exit(1);
		}
		//printf(argv[3]);putchar(' ');	puts(argv[4]);
		if((f1=fopen(argv[3],"rb"))==NULL) {
			printf("file %s not open.\n",argv[3]);
			return 1;
		}
		if(res=f_open(&f2,argv[4],FA_CREATE_ALWAYS|FA_WRITE)) {
			printf("Error fatfs: %d",res);
			exit(1);
		}
		while(1){
			int len=0,len2=0;
			len=fread(buf, 1, sizeof(buf), f1);
			if(len<=0)break;
			f_write (&f2, buf, len, &len2);
		}
		fclose(f1);
		f_close(&f2);
	}else if(strcmp(argv[2],"get")==0){
		//printf("get ");
		if(argc!=5){
			puts("Error: wrong namber parameters");
			exit(1);
		}
		//printf(argv[3]);putchar(' ');	puts(argv[4]);
		if((f1=fopen(argv[4],"w+b"))==NULL) {
			printf("file %s not open.\n",argv[3]);
			return 1;
		}
		if(res=f_open(&f2,argv[3],FA_OPEN_EXISTING|FA_READ)) {
			printf("Error fatfs: %d",res);
			exit(1);
		}
		while(1){
			int len=0,len2=0;
			f_read(&f2, buf, sizeof(buf), &len);
			if(len<=0)break;
			len2=fwrite(buf, 1, len, f1);
		}
		fclose(f1);
		f_close(&f2);
	}else if(strcmp(argv[2],"dir")==0){
		//printf("dir ");
		if(argc<3){
			puts("Error: wrong namber parameters");
			exit(1);
		}
		//puts(argv[3]);
		cc="f_opendir";
		if(res=f_opendir (&dr,(argc>=4)?argv[3]:"")) goto errexit;
		while(1){
			cc="f_readdir";
			if(res=f_readdir (&dr, &fi)) goto errexit;
			if(fi.fname[0]==0x00)break;
			puts(fi.fname);
		}	
	}
	//for(int ai=2;ai<argc;ai++){
		//puts(argv[ai]);
	//	if(parsearg(argv[ai])) goto errexit;
	//}
	//exit(0);
	
	
	
	
	fclose(img);
	exit(0);
errexit:
	printf("%s: %d",cc,res);
	fclose(img);
	exit(1);
}