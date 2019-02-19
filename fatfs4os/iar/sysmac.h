/*                      - SYSMAC.H -

   Defines system macros to maintain source compatibility
   with different IAR compilers.

   $Name: V3_34K V3_34J V3_34I V3_34H $

   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _SYSMAC_H_
#define _SYSMAC_H_


#if defined(__IAR_SYSTEMS_ICC) && !defined(__IAR_SYSTEMS_ICC__)
#define __IAR_SYSTEMS_ICC__ 1
#endif

#if __IAR_SYSTEMS_ICC__ > 4
#error __IAR_SYSTEMS_ICC__ > 4 not available yet!
#endif

#ifndef __CHAR_SIZE__
#define __CHAR_SIZE__ sizeof(char)
#endif

#ifndef __SHORT_SIZE__
#define __SHORT_SIZE__ sizeof(short)
#endif

#ifndef __INT_SIZE__
#define __INT_SIZE__ sizeof(int)
#endif

#ifndef __LONG_SIZE__
#define __LONG_SIZE__ sizeof(long)
#endif

#ifndef __FLOAT_SIZE__
#define __FLOAT_SIZE__ sizeof(float)
#endif

#ifndef __DOUBLE_SIZE__
#define __DOUBLE_SIZE__ sizeof(double)
#endif

#ifndef __LONG_DOUBLE_SIZE__
#define __LONG_DOUBLE_SIZE__ sizeof(long double)
#endif

#ifndef __SIZE_T_TYPE__
#if     sizeof((char*)0 - (char*)0) <= sizeof(int)
#define __SIZE_T_TYPE__ unsigned int
#else
#define __SIZE_T_TYPE__ unsigned long 
#endif
#endif

#ifndef __PTRDIFF_T_TYPE__
#if     sizeof((char*)0 - (char*)0) <= sizeof(int)
#define __PTRDIFF_T_TYPE__ unsigned int
#else
#define __PTRDIFF_T_TYPE__ unsigned long 
#endif
#endif

#ifndef __JMP_BUF_ELEMENT_TYPE__
#ifndef __JMP_BUF_NUM_ELEMENTS__
#define __JMP_BUF_ELEMENT_TYPE__  char
#ifndef __JMP_BUF__
#define __JMP_BUF_NUM_ELEMENTS__  8
#else
#define __JMP_BUF_NUM_ELEMENTS__  __JMP_BUF__
#endif
#endif
#endif


#define __INTRINSIC
#if __IAR_SYSTEMS_ICC__ >= 2
#undef  __INTRINSIC
#define __INTRINSIC __intrinsic
#endif

/* Macro for frmwri and frmrd */
#define VAPTR(T) (va_arg(ap, T *))

/* Typedefs put here to appear only once */
typedef __SIZE_T_TYPE__    size_t;
typedef __PTRDIFF_T_TYPE__ ptrdiff_t;

#endif /* _SYSMAC_H_ */
