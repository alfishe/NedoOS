#include <stdio.h>
char *alloc(nbytes)
unsigned nbytes;
{
	struct _header *p, *q, *cp;
	int nunits; 
	nunits = 1 + (nbytes + (sizeof (_base) - 1)) / sizeof (_base);
	if ((q = _allocp) == NULL) {
		_base._ptr = _allocp = q = &_base;
		_base._size = 0;
	 }
	for (p = q -> _ptr; ; q = p, p = p -> _ptr) {
		if (p -> _size >= nunits) {
			_allocp = q;
			if (p -> _size == nunits)
				_allocp->_ptr = p->_ptr;
			else {
				q = _allocp->_ptr = p + nunits;
				q->_ptr = p->_ptr;
				q->_size = p->_size - nunits;
				p -> _size = nunits;
			 }
			return p + 1;
		 }
		if (p == _allocp) {
			if ((cp = sbrk(nunits *	 sizeof (_base))) == ERROR)
				return NULL;
			cp -> _size = nunits; 
			free(cp+1);	/* remember: pointer arithmetic! */
			p = _allocp;
		}
	 }
}

free(ap)
struct _header *ap;
{
	struct _header *p, *q;

	p = ap - 1;	/* No need for the cast when "ap" is a struct ptr */

	for (q = &_base; q->_ptr != &_base; q = q -> _ptr)
		if (p > q && p < q -> _ptr)
			break;

	if (p + p -> _size == q -> _ptr) {
		p -> _size += q -> _ptr -> _size;
		p -> _ptr = q -> _ptr -> _ptr;
	 }
	else p -> _ptr = q -> _ptr;

	if (q + q -> _size == p) {
		q -> _size += p -> _size;
		q -> _ptr = p -> _ptr;
	 }
	else q -> _ptr = p;

	_allocp = q;
}

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
		return seek(fp->_fd, -1, 1); /* ??? */
	 }

	fp->_nleft = (NSECTS * SECSIZ);
	fp->_nextp = fp->_buff;
	return OK;
}

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
		cnt = (n_togo <= fp->_nleft) ? n_togo : fp->_nleft; /* how many bytes we can get from buffer at once */
		movmem(fp->_nextp, buf, cnt); /* get them */
		fp->_nextp += cnt; /* source pointer */
		buf += cnt; /* destination pointer */
		fp->_nleft -= cnt; /* how many bytes remained loaded in buffer */
		n_togo -= cnt; /* how many bytes we still need */
		n_read += cnt;
		if (n_togo) /* we need more bytes */
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
char loadbuf[LOADBUFSZ];
FILE g_fpout;
int i;

main(argc,argv)
char **argv;
{
FILE *fp;
FILE *fpout;
printf("Hello world!\n");

for (i = 1; i < argc; i++) printf("Arg #%d = %s\n",i,argv[i]);

/*fp = fopen("ex.c","rb");*/
if ((fp = alloc(sizeof(*fp))) == NULL) return NULL;
fp->_nextp = fp->_buff;
fp->_nleft = 0;
fp->_flags = _READ;
fp->_fd = open("ex.c", 0);

/*fpout = fopen("myfile3.a","wb");*/
if ((fpout = alloc(sizeof(*fp))) == NULL) return NULL;
fpout->_nextp = fpout->_buff;
fpout->_nleft = (NSECTS * SECSIZ);
fpout->_flags = _WRITE;
fpout->_fd = creat("myfile1.a");

while (1) {
 i = fread(loadbuf, 1, LOADBUFSZ, fp);
 /*read(fp->_fd, loadbuf, LOADBUFSZ/SECSIZ);*/
 /*while (1);*/
 if (!i) break;
 fwrite(loadbuf, 1, i, fpout);
 /*write(fpout->_fd, loadbuf, LOADBUFSZ/SECSIZ);*/
}

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
