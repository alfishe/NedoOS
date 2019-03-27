/*                      - STDIO.H -

   Subset of ANSI standard I/O function declarations.

   $Name: V3_34K V3_34J V3_34I V3_34H V3_34G $    

   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _STDIO_INCLUDED
#define _STDIO_INCLUDED

#include "stdarg.h"

#ifndef NULL
#define NULL    ((void *) 0)
#endif

#ifndef EOF
#define EOF     (-1)
#endif

#ifndef MEMORY_ATTRIBUTE
#define MEMORY_ATTRIBUTE
#endif

MEMORY_ATTRIBUTE int  puts(const char *);
MEMORY_ATTRIBUTE int  putchar(int);
MEMORY_ATTRIBUTE int  getchar(void);
MEMORY_ATTRIBUTE int  sprintf(char *,const char *,...);
MEMORY_ATTRIBUTE int  vsprintf(char *,const char *,va_list);
MEMORY_ATTRIBUTE int  printf(const char *,...);
MEMORY_ATTRIBUTE int  vprintf(const char *,va_list);
MEMORY_ATTRIBUTE int  scanf(const char *,...);
MEMORY_ATTRIBUTE int  sscanf(const char *, const char *,...);
MEMORY_ATTRIBUTE char *gets(char *);


#endif /* _STDIO_INCLUDED */



