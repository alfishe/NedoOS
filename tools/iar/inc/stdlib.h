/*                      - STDLIB.H -

   The ANSI-defined 'standard' functions.

   $Name: V3_34K V3_34J V3_34I V3_34H V3_34G $    

   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _STDLIB_INCLUDED
#define _STDLIB_INCLUDED

#include "sysmac.h"

#ifndef NULL
#define NULL    ((void*) 0 )
#endif

typedef struct
{
  int   quot;
  int   rem;
} div_t;

typedef struct
{
  long int      quot;
  long int      rem;
} ldiv_t;


#define RAND_MAX        32767

#define EXIT_SUCCESS    0
#define EXIT_FAILURE    1

#define MB_CUR_MAX      1

#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=intrinsic(0)
#endif
#endif

#ifndef MEMORY_ATTRIBUTE
#define MEMORY_ATTRIBUTE
#endif

#ifndef PTR_ATTRIBUTE
#define PTR_ATTRIBUTE
#endif

__INTRINSIC MEMORY_ATTRIBUTE void *malloc(size_t);

__INTRINSIC MEMORY_ATTRIBUTE void free(void *);

__INTRINSIC MEMORY_ATTRIBUTE void exit(int);

__INTRINSIC MEMORY_ATTRIBUTE void *calloc(unsigned int, size_t);

__INTRINSIC MEMORY_ATTRIBUTE void *realloc(void *, size_t);

__INTRINSIC MEMORY_ATTRIBUTE int  atoi(const char *);

__INTRINSIC MEMORY_ATTRIBUTE long atol(const char *);

__INTRINSIC MEMORY_ATTRIBUTE double atof(const char *);

__INTRINSIC MEMORY_ATTRIBUTE double strtod(const char *, char **);

__INTRINSIC MEMORY_ATTRIBUTE long int strtol(const char *, char **, int);

__INTRINSIC MEMORY_ATTRIBUTE unsigned long int strtoul(const char *, char **,
                                                       int);

__INTRINSIC MEMORY_ATTRIBUTE int rand(void);

__INTRINSIC MEMORY_ATTRIBUTE void srand(unsigned int);

__INTRINSIC MEMORY_ATTRIBUTE void abort(void);

__INTRINSIC MEMORY_ATTRIBUTE int abs(int);

__INTRINSIC MEMORY_ATTRIBUTE div_t div(int, int);

__INTRINSIC MEMORY_ATTRIBUTE long int labs(long int);

__INTRINSIC MEMORY_ATTRIBUTE ldiv_t ldiv(long int, long int);

__INTRINSIC MEMORY_ATTRIBUTE void *bsearch(const void *, const void *,
                                           size_t, size_t,
                                           int (*)(const void *,const void *));

__INTRINSIC MEMORY_ATTRIBUTE void qsort(void *, size_t, size_t,
                                        int (*)(const void *, const void *));

#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=default
#endif
#endif

#endif /* _STDLIB_INCLUDED */

