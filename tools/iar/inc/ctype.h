/*                      - CTYPE.H -

   The ANSI character testing function declarations.
           
   Note: 7-bit ASCII or 8-bit ASCII may be supported by these functions.
         
   $Name: V3_34K V3_34J V3_34I V3_34H V3_34G $
                    
   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _CTYPE_INCLUDED
#define _CTYPE_INCLUDED

#include "sysmac.h"

#define _U      01
#define _L      02
#define _N      04
#define _S      010
#define _P      020
#define _C      040
#define _X      0100
#define _B      0200

#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=intrinsic(0)
#endif
#endif

#ifdef __8_BIT_ASCII_WANTED
extern const unsigned char _Large_Ctype[257];
#define _Ctype  _Large_Ctype
#else
extern const unsigned char _Small_Ctype[129];
#define _Ctype  _Small_Ctype
#endif

__INTRINSIC int isalpha(int);
__INTRINSIC int isupper(int);
__INTRINSIC int islower(int);
__INTRINSIC int isdigit(int);
__INTRINSIC int isxdigit(int);
__INTRINSIC int isspace(int);
__INTRINSIC int ispunct(int);
__INTRINSIC int isalnum(int);
__INTRINSIC int isprint(int);
__INTRINSIC int isgraph(int);
__INTRINSIC int iscntrl(int);
__INTRINSIC int toupper(int);
__INTRINSIC int tolower(int);

#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=default
#endif
#endif


#define isalpha(c)      ((_Ctype+1)[c]&(_U|_L))
#define isupper(c)      ((_Ctype+1)[c]&_U)
#define islower(c)      ((_Ctype+1)[c]&_L)
#define isdigit(c)      ((_Ctype+1)[c]&_N)
#define isxdigit(c)     ((_Ctype+1)[c]&(_N|_X))
#define isspace(c)      ((_Ctype+1)[c]&_S)
#define ispunct(c)      ((_Ctype+1)[c]&_P)
#define isalnum(c)      ((_Ctype+1)[c]&(_U|_L|_N))
#define isprint(c)      ((_Ctype+1)[c]&(_P|_U|_L|_N|_B))
#define isgraph(c)      ((_Ctype+1)[c]&(_P|_U|_L|_N))
#define iscntrl(c)      ((_Ctype+1)[c]&_C)
#define toupper(c)      (islower((c))? (c)&0x5F: (c))
#define tolower(c)      (isupper((c))? (c)|0x20: (c))

#endif

