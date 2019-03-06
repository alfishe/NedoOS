/*                      - LIMITS.H -

   Integral ANSI element sizes.

   $Name: V3_34K V3_34J V3_34I V3_34H V3_34G $

   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _LIMITS_INCLUDED
#define _LIMITS_INCLUDED

#include "sysmac.h"

#define CHAR_BIT         8              /* Number of bits in any "char" */

#if defined(__CHAR_MAX__)

#define CHAR_MAX         __CHAR_MAX__
#define CHAR_MIN         __CHAR_MIN__

#define MB_LEN_MAX       1              /* No of bytes in multibyte char */

#define SCHAR_MAX        __SIGNED_CHAR_MAX__
#define SCHAR_MIN        __SIGNED_CHAR_MIN__
#define UCHAR_MAX        __UNSIGNED_CHAR_MAX__

#define SHRT_MAX         __SIGNED_SHORT_MAX__
#define SHRT_MIN         __SIGNED_SHORT_MIN__
#define USHRT_MAX        __UNSIGNED_SHORT_MAX__

#define INT_MAX          __SIGNED_INT_MAX__
#define INT_MIN          __SIGNED_INT_MIN__
#define UINT_MAX         __UNSIGNED_INT_MAX__

#define LONG_MAX         __SIGNED_LONG_MAX__
#define LONG_MIN         __SIGNED_LONG_MIN__
#define ULONG_MAX        __UNSIGNED_LONG_MAX__

#else /* !defined(__CHAR_MAX__) */

#if _argt$(char)==1                     /* "char" = "unsigned" "char" */
#define CHAR_MAX         255
#define CHAR_MIN         0
#else
#define CHAR_MAX         127            /* Maximum "char" value */
#define CHAR_MIN        (-128)          /* Mimimum "char" value */
#endif

#define MB_LEN_MAX       1              /* No of bytes in multibyte char */

#define SCHAR_MAX        127            /* Maximum "signed" "char" value */
#define SCHAR_MIN       (-128)          /* Minimum "signed" "char" value */

#define UCHAR_MAX        255            /* Maximum "unsigned" "char" value */

#define SHRT_MAX         32767          /* Maximum ("signed") "short" value */
#define SHRT_MIN        (-32767-1)      /* Minimum ("signed") "short" value */
#define USHRT_MAX        0xFFFFU        /* Maximum "unsigned" "short" value */

#if __INT_SIZE__ == 2                   /* For 32-bit CPU's usually not */
#define INT_MAX          32767          /* Maximum ("signed") "int" value */
#define INT_MIN         (-32767-1)      /* Minimum ("signed") "int" value */
#define UINT_MAX         0xFFFFU        /* Maximum "unsigned" "int" value */
#else
#define INT_MAX          2147483647
#define INT_MIN         (-2147483647-1)
#define UINT_MAX         0xFFFFFFFFU
#endif

#define LONG_MAX         2147483647     /* Maximum ("signed") "long" value */
#define LONG_MIN        (-2147483647-1) /* Minimum ("signed") "long" value */
#define ULONG_MAX        0xFFFFFFFFU    /* Maximum "unsigned" "long" value */

#endif /* defined(__CHAR_MAX__) */

#endif
