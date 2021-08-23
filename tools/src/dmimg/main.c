#include <stdio.h>
#include <stdlib.h>
#include "ff.h"
#include <string.h>

FILE * img=NULL;
FILE * f1=NULL;
FATFS fs;
FIL f2;

FILE * fconf = NULL;
char strbuf[256];
char * cc="";
char buf[8*1024];
int imagemnt(char * imgname){
	int res;
	if((img=fopen(imgname,"rb+"))==NULL) {
		printf("Image file %s not open.\n",imgname);
		return 1;
	}
	if(res=f_mount(&fs, "0:", 1)){
		printf("f_mount error %d.\n",res);
		return 1;
	}
	return 0;
}

int runcmd(int argc, char * cmd, char * arg1, char * arg2){
	int res;
	if(strcmp(cmd,"mkdir")==0){
		if(argc!=2){
			puts("Error: wrong number of parameters\n");
			return 1;
		}
		if(res=f_mkdir(arg1)){
			if(res != 8){
				printf("%s %s %s ", cmd, arg1, arg2);
				printf("Error fatfs: %d\r\n",res);
				return 1;
			}
		}
	}else if(strcmp(cmd,"del")==0){
		if(argc!=2){
			puts("Error: wrong number of parameters\n");
			return 1;
		}
		if(res=f_unlink(arg1)){
			printf("%s %s %s ", cmd, arg1, arg2);
			printf("Error fatfs: %d\r\n",res);
			return 1;
		}
	}else if(strcmp(cmd,"put")==0){
		if(argc!=3){
			puts("Error: wrong number of parameters\n");
			return 1;
		}
		if((f1=fopen(arg1,"rb"))==NULL) {
			printf("%s %s %s ", cmd, arg1, arg2);
			printf("file %s not open.\r\n",arg1);
			return 1;
		}
		if(res=f_open(&f2,arg2,FA_CREATE_ALWAYS|FA_WRITE)) {
			printf("%s %s %s ", cmd, arg1, arg2);
			printf("Error fatfs: %d\r\n",res);
			return 1;
		}
		while(1){
			int len=0,len2=0;
			len=fread(buf, 1, sizeof(buf), f1);
			if(len<=0)break;
			f_write (&f2, buf, len, &len2);
		}
		fclose(f1);
		f_close(&f2);
	}else if(strcmp(cmd,"get")==0){
		if(argc!=3){
			puts("Error: wrong number of parameters\n");
			return 1;
		}
		if((f1=fopen(arg2,"w+b"))==NULL) {
			printf("%s %s %s ", cmd, arg1, arg2);
			printf("file %s not open.\r\n",arg1);
			return 1;
		}
		if(res=f_open(&f2,arg1,FA_OPEN_EXISTING|FA_READ)) {
			printf("%s %s %s ", cmd, arg1, arg2);
			printf("Error fatfs: %d\r\n",res);
			return 1;
		}
		while(1){
			int len=0,len2=0;
			f_read(&f2, buf, sizeof(buf), &len);
			if(len<=0)break;
			len2=fwrite(buf, 1, len, f1);
		}
		fclose(f1);
		f_close(&f2);
	}else if(strcmp(cmd,"dir")==0){
		DIR dr;
		FILINFO fi;
		puts("ok");
		cc="f_opendir";
		if(res=f_opendir (&dr,(argc > 1)?arg1:"")) {
			printf("%s %s %s ", cmd, arg1, arg2);
			printf("Error fatfs: %d\r\n",res);
			return 1;
		}
		while(1){
			cc="f_readdir";
			if(res=f_readdir (&dr, &fi)){
				printf("%s %s %s ", cmd, arg1, arg2);
				printf("Error fatfs: %d\r\n",res);
				return 1;
			}
			if(fi.fname[0]==0x00) break;
			puts(fi.fname);
		}	
	}else if(strcmp(cmd,"conf")==0){
		if(argc!=2){
			puts("Error: wrong number of parameters\n");
			return 1;
		}
		if((fconf=fopen(arg1,"r"))==NULL) {
			printf("%s %s %s ", cmd, arg1, arg2);
			printf("file %s not open.\r\n",arg1);
			return 1;
		}
		
	}
	return 0;
}

int main (int argc, char *argv[]){
	int res;
#ifdef WIN32
    SetConsoleCP(866);// установка кодовой страницы win-cp 1251 в поток ввода
    SetConsoleOutputCP(866); // установка кодовой страницы win-cp 1251 в поток вывода
#endif

	if(argc<3){
		puts("Error: Need more parameters.\n");
		exit(1);
	}
	if(imagemnt(argv[1])) exit(2);
	runcmd(argc-2, argv[2], argv[3], argv[4]);
	if(fconf){
		while(fgets(strbuf,sizeof(strbuf),fconf)){
			char * a1 = (void*)0;
			char * a2 = (void*)0;
			char * cmd = strbuf;
			a1=strpbrk(strbuf,"\r\n");
			if(a1) *a1 = 0x00;
			if(cmd){
				a1 = strchr(cmd, ' ');
				if(a1){
					*a1 = 0x00;
					a1++;
					a2 = strchr(a1, ' ');
					if(a2){
						*a2 = 0x00;
						a2++;
						runcmd(3, cmd, a1, a2);
					}
					else{
						runcmd(2, cmd, a1, a2);
					}
				}else{
					runcmd(1, cmd, a1, a2);
				}
			}
		}
	}
	
	if(fconf != NULL) fclose(fconf);
	if(img != NULL) fclose(img);
	exit(0);
errexit:
	printf("%s: %d\n",cc,res);
	fclose(img);
	exit(1);
}
