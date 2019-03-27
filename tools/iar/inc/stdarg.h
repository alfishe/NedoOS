/*                      - STDARG.H -
   The ANSI macros for reading variable argument lists (...).

   $Name: V3_34K V3_34J V3_34I V3_34H $    

   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _STDARG_H_
#define _STDARG_H_

#include "sysmac.h"


#if __IAR_SYSTEMS_ICC__ >= 2

typedef void *va_list[1];

__INTRINSIC void __va_start(va_list);

#define va_start(ap, parmN) __va_start(ap)
#define va_end(ap)            ((void) 0)

#ifdef __VA_STACK_DECREASING__
#if __VA_STACK_DECREASING__
#define va_arg(ap,type) (*(*(type **)ap)++)
#else
#define va_arg(ap,type) (*--(*(type **)ap))
#endif
#endif


#else /* __IAR_SYSTEMS_ICC__ >= 2 */


/*=====================================*/
/*     ICCZ80 version 1.00 - 3.xx      */
/*=====================================*/
#if ((__TID__ >> 8) & 0x7f) == 4                

#define _NOT_DEFAULT_BEHAVIOR

typedef struct
{
  char        *parm;
  char        *addr;
  char        argc;
} va_list[1];

#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=intrinsic(0)
#endif
#endif

#ifndef MEMORY_ATTRIBUTE
#define MEMORY_ATTRIBUTE
#endif

__INTRINSIC MEMORY_ATTRIBUTE char *_get_varg(va_list ap, char type, char size);

#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=default
#endif
#endif

#define va_start(ap,parmN) ((ap[0].addr = ((char *) &parmN) + sizeof(parmN)),\
                                        (ap[0].parm = _args$))
#define va_arg(ap,mode) *(mode *) _get_varg (ap, _argt$(mode), sizeof(mode))

#define va_end(ap)      ((void)0) 
#endif


/*=====================================*/
/*  Stack grows in positiv direction.  */
/*  CG-driver designed ICC only!       */
/* - - - - - - - - - - - - - - - - - - */
/*     ICC251  version 1.00 -          */
/*=====================================*/
#if ((__TID__ >> 8) & 0x7f) == 36  

#define _NOT_DEFAULT_BEHAVIOR

typedef void *va_list[1];

#define va_start(ap,parmN) (ap[0] = ((char *) &parmN) - 1)
#define va_arg(ap,mode) (*--(*(mode **)ap))

#define va_end(ap)      ((void)0) 
#endif


/*=====================================*/
/*  Stack grows in positiv direction.  */
/* - - - - - - - - - - - - - - - - - - */
/*     ICC8051 version 1.00 - 3.10     */
/*     Single chip memory model        */
/*                                     */
/*     ICC7700 version 1.00 -          */
/*=====================================*/
#if ((__TID__ >> 8) == 1 && (__TID__ & 15) == 0) ||             \
    ((__TID__ >> 8) & 0x7f) == 19

#define _NOT_DEFAULT_BEHAVIOR

typedef void *va_list[1];

#define va_start(ap,parmN) (ap[0] = (void*)&parmN)
#define va_arg(ap,mode) (*--(*(mode **)ap))

#define va_end(ap)      ((void)0) 
#endif


/*=====================================*/
/*  These targets has char pushed as   */
/*  word on stack.                     */
/*  Stack grows in negativ direction.  */
/*  (Old type of code-generators)      */
/* - - - - - - - - - - - - - - - - - - */
/*     ICCH8500 version 1.xx -         */
/*     ICCH83   version 3.xx -         */
/*     ICC78000 version 1.xx           */
/*     ICC78300 version 1.xx           */
/*     ICC78300 version 2.00 -         */
/*     ICC78000 version 2.xx           */
/*     ICCZ80   version 4.00 -         */
/*=====================================*/
#if ((__TID__ >> 8) & 0x7f) == 9  || /* IANB 97.06.26 */        \
    ((__TID__ >> 8) & 0x7f) == 10 || /* IANB 97.06.26 */        \
    ((__TID__ >> 8) & 0x7f) == 15 ||                            \
    ((__TID__ >> 8) & 0x7f) == 16 ||                            \
    ((__TID__ >> 8) & 0x7f) == 20 ||                            \
    ((__TID__ >> 8) & 0x7f) == 21 || /* IERA 94.01.16 */        \
    ((__TID__ >> 8) & 0x7f) == 23    /* IHAT 94.04.18 */ 

#define _NOT_DEFAULT_BEHAVIOR

typedef void *va_list[1];

#define va_start(ap,parmN) \
  ap[0] = ((char *) &parmN) + (sizeof(parmN) > 1 ? sizeof(parmN) : 2)
#define va_arg(ap,mode) \
  (sizeof(mode) == 1 ? (*(mode *)(*(int **)ap)++) : \
                       *(*(mode **) ap)++) 

#define va_end(ap)      ((void)0) 
#endif


/*=====================================*/
/*  These targets has char pushed as   */
/*  word on stack.                     */
/*  Stack grows in negativ direction.  */
/*  (New type of code-generators)      */
/* - - - - - - - - - - - - - - - - - - */
/*     ICC78400 version 1.00 -         */
/*     ICC78000 version 3.xx           */
/*     ICCCR16  -                      */
/*     ICCCR32  -                      */
/*=====================================*/
#if ((__TID__ >> 8) & 0x7f) == 29 ||                          \
    ((__TID__ >> 8) & 0x7f) == 30 || /* IBEV 97.07.14 */      \
    ((__TID__ >> 8) & 0x7f) == 41 || /* IASL 97.06.09 */      \
    ((__TID__ >> 8) & 0x7f) == 42    /* IBEV 97.12.18 */

#define _NOT_DEFAULT_BEHAVIOR

typedef void *va_list[1];

#define va_start(ap,parmN) ap[0] = ((char *) &parmN) + sizeof(parmN)
#define va_arg(ap,mode) \
  (sizeof(mode) < sizeof(int) ? (*(mode *)(*(int **)ap)++) : \
                       *(*(mode **) ap)++) 

#define va_end(ap)      ((void)0) 
#endif


/*=====================================*/
/*  8096 has char packed as low byte   */
/*  in word on the stack.              */
/* - - - - - - - - - - - - - - - - - - */
/*     ICC8096 version 1.00 -          */
/*=====================================*/
#if ((__TID__ >> 8) & 0x7f) == 6   /* ICLM 93.11.01 */

#define _NOT_DEFAULT_BEHAVIOR

typedef void *va_list[1];

#define va_start(ap,parmN) ap[0] = ((char *) &parmN) + (sizeof(parmN) > 1 ? sizeof(parmN) : 2)

#define va_arg(ap,mode) (*(*(mode **) ap)++)

#define va_end(ap)      ((void)0) 
#endif


/*=====================================*/
/*    All ICC compilers except those   */
/*    listed above.                    */
/*=====================================*/
#ifndef _NOT_DEFAULT_BEHAVIOR

typedef void *va_list[1];

#define va_start(ap,parmN) ap[0] = ((char *) &parmN) + sizeof(parmN)
#define va_arg(ap,mode) (*(*(mode **) ap)++)

#define va_end(ap)      ((void)0) 
#endif

#endif /* __IAR_SYSTEMS_ICC__ >= 2 */
#endif /* _STDARG_H_ */

