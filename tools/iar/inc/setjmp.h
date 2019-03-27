/*                      - SETJMP.H -
 
   The ANSI "setjmp" and "longjmp" function declarations.
           
   $Name: V3_34K V3_34J $

   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _SETJMP_INCLUDED
#define _SETJMP_INCLUDED

#include "sysmac.h"

/*==========================*/
/* ICCH8500 ,ICCH83 and H8S */
/* have word alignment.     */
/*==========================*/
#if    ((__TID__ >> 8) & 0x7f) == 9 \
    || ((__TID__ >> 8) & 0x7f) == 10 \
    || ((__TID__ >> 8) & 0x7f) == 27
typedef short jmp_buf[__JMP_BUF_NUM_ELEMENTS__ >> 1];
#else
typedef __JMP_BUF_ELEMENT_TYPE__  jmp_buf[__JMP_BUF_NUM_ELEMENTS__];
#endif

#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=intrinsic(0)
#endif
#endif

#ifndef MEMORY_ATTRIBUTE
#define MEMORY_ATTRIBUTE
#endif


/*======================*/
/* ICCH83 can not be    */
/* completely ANSI for  */
/* the return value     */
/* type from 'setjump'. */
/*----------------------*/
/* Calls to 'longjmp'   */
/* and 'setjmp' must be */
/* calls to standard    */
/* functions.           */
/*======================*/
#if ((__TID__ & 0x7F00) >> 8) == 10

#if __IAR_SYSTEMS_ICC__ < 2
#pragma function=__standard_function
MEMORY_ATTRIBUTE short setjmp(jmp_buf);
MEMORY_ATTRIBUTE void longjmp(jmp_buf, short);
#pragma function=default
#else
#error Make sure this pragma is supported when upgrading!
#endif

/*======================*/
/* Nothing special with */
/* all the others.      */
/*======================*/
#else

__INTRINSIC MEMORY_ATTRIBUTE int setjmp(jmp_buf);
__INTRINSIC MEMORY_ATTRIBUTE void longjmp(jmp_buf, int);

#endif



#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=default
#endif
#endif

#endif /* _SETJMP_INCLUDED */
