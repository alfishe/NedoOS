#include <stdio.h>
int fflush(fp)
FILE *fp;
{
	int i; char *p;

	if (fp <= 4)
		return OK;
	if (!(fp->_flags & _WRITE))
		return ERROR;

	if (fp->_nleft == (NSECTS * SECSIZ))
		return OK;

	i = NSECTS - (fp->_nleft / SECSIZ);
	if (write(fp->_fd, fp->_buff, i) != i)
	{
		fp->_flags |= _ERR;
		return ERROR;
	}
	i = (i-1) * SECSIZ;
	if (fp->_nleft % SECSIZ) {
		movmem(fp->_buff + i, fp->_buff, SECSIZ);
		fp->_nleft += i;
		fp->_nextp -= i;
		return seek(fp->_fd, -1, 1);
	 }

	fp->_nleft = (NSECTS * SECSIZ);
	fp->_nextp = fp->_buff;
	return OK;
}
/*
int fread(buf, size, count, fp)
char *buf;
unsigned size, count;
FILE *fp;
{
	int n_read, n_togo, cnt, i;

	n_togo = size * count;
	n_read = 0;
	if (fp->_flags & _EOF)
		return NULL;

	while (n_togo)
	{
		cnt = (n_togo <= fp->_nleft) ? n_togo : fp->_nleft;
		movmem(fp->_nextp, buf, cnt);
		fp->_nextp += cnt;
		buf += cnt;
		fp->_nleft -= cnt;
		n_togo -= cnt;
		n_read += cnt;
		if (n_togo)
		{
			if ((cnt = read(fp->_fd, fp->_buff, NSECTS)) <=0)
			{
				fp->_flags |= _EOF;
				goto text_test;
			}
			fp->_nleft = cnt * SECSIZ;
			fp->_nextp = fp->_buff;
		}
	}
 text_test:
	if (fp->_flags & _TEXT)
	{
		i = min(n_read, SECSIZ);
		while (i--)
			if (*(buf-i) == CPMEOF)		   
			{
				fp->_flags |= _EOF;
				return (n_read - i);
			}
	}
	return (n_read/size);
}
*/
int fwrite(buf, size, count, fp)
char *buf;
unsigned size, count;
FILE *fp;
{
	int n_done, n_togo, cnt;

	n_togo = size * count;
	n_done = 0;

	if (fp->_flags & _ERR)
		return NULL;

	while (n_togo)
	{
		cnt = (n_togo <= fp->_nleft) ? n_togo : fp->_nleft;
		movmem(buf, fp->_nextp, cnt);
		fp->_nextp += cnt;
		buf += cnt;
		fp->_nleft -= cnt;
		n_togo -= cnt;
		n_done += cnt;
		if (n_togo)
		{
			if ((cnt = write(fp->_fd, fp->_buff, NSECTS)) <= 0)
			{
				fp->_flags |= _ERR;
				return ERROR;
			}
			fp->_nleft = (NSECTS * SECSIZ);
			fp->_nextp = fp->_buff;
		}
	}
	return (n_done/size);
}

#define LOADBUFSZ 4096
char *loadbuf[LOADBUFSZ];

main(argc,argv)
char **argv;
{
int i;
FILE *fp;
FILE *fpout;
printf("Hello world!\n");

for (i = 1; i < argc; i++) printf("Arg #%d = %s\n",i,argv[i]);

/*fp = fopen("ex.c","rb");*/
if ((fp = alloc(sizeof(*fp))) == NULL) return NULL;
fp->_nextp = fp->_buff;
fp->_nleft = (NSECTS * SECSIZ);
fp->_flags = _READ;
fp->_fd = open("ex.c", 0);

/*fpout = fopen("myfile3.a","wb");*/
if ((fpout = alloc(sizeof(*fp))) == NULL) return NULL;
fpout->_nextp = fpout->_buff;
fpout->_nleft = (NSECTS * SECSIZ);
fpout->_flags = _WRITE;
fpout->_fd = creat("myfile1.a");

/*i = fread(loadbuf, LOADBUFSZ, 1, fp);
fwrite(loadbuf, i, 1, fpout);*/

/*fclose(fpout);*/
if (fflush(fpout) == ERROR) return ERROR;
close(fpout->_fd);
free(fpout);

/*fclose(fp);*/
close(fp->_fd);
free(fp);
/*getchar();
setgfx();
cls();
putpixel(100,100,3);
putpixel(101,102,3);
getchar();*/
/*while(1) {
 i = 0;
 i = 1;
}*/
}
