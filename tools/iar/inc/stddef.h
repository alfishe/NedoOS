/*                      - STDDEF.H -

   The ANSI 'common' definitions.

   $Name: V3_34K V3_34J V3_34I V3_34H V3_34G $           

   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _STDDEF_INCLUDED
#define _STDDEF_INCLUDED

#include "sysmac.h"

#ifndef NULL
#define NULL            ((void *) 0)
#endif

#ifndef offsetof
#if __IAR_SYSTEMS_ICC__ >= 2
#define offsetof(type,member)   (__INTADDR__((&((type *)0)->member)))
#else
#define offsetof(type,member)   ((size_t)(&((type *)0)->member))
#endif
#endif

#ifndef wchar_t
#if __IAR_SYSTEMS_ICC__ >= 2 && defined(__WCHAR_T_TYPE__)
#define wchar_t __WCHAR_T_TYPE__
#else
#define wchar_t char
#endif
#endif

#endif

