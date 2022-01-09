#ifndef OSFS_H
#define OSFS_H
extern unsigned char errno;
//extern unsigned char syspath[8];

typedef unsigned int FILE;

#ifndef FILINFO_TYPE
typedef struct {
	unsigned long int	fsize;			/* File size */
	unsigned int		fdate;			/* Last modified date */
	unsigned int		ftime;			/* Last modified time */
	unsigned char		fattrib;		/* Attribute */
	unsigned char		fname[13];		/* Short file name (8.3 format) */
	unsigned char		lfname[64];			/* Pointer to the LFN buffer */
} FILINFO;
#endif

FILE *		 	OS_CREATEHANDLE(unsigned char * path, unsigned char flags);
unsigned int 	OS_WRITEHANDLE(unsigned char * buffer, FILE * hnd, unsigned int count);
unsigned int 	OS_READHANDLE(unsigned char * buffer, FILE * hnd, unsigned int count);
FILE *		 	OS_OPENHANDLE(unsigned char * path, unsigned char flags);
unsigned int 	OS_CLOSEHANDLE(FILE * hnd);
unsigned long	OS_GETFILESIZE(FILE * hnd);
void			OS_SEEKHANDLE(FILE * hnd, unsigned long ofset);
unsigned char	OS_GETFILINFO(unsigned char * path, FILINFO*);
unsigned char * OS_GETPATH(unsigned char * path);
unsigned char	OS_OPENDIR(unsigned char * path);
unsigned char	OS_READDIR(FILINFO*);
unsigned char	OS_CHDIR(const unsigned char * path);
unsigned char	OS_CHDRV(unsigned char drive);
unsigned char	OS_MKDIR(unsigned char * path);
unsigned char	OS_DELETE(unsigned char * path);
void			OS_SETSYSDRV(void);
unsigned char * fs_get_err_str(void);

#endif