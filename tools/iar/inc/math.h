/*                      - MATH.H -

   The ANSI-defined (+ a few additional) mathematical functions.
           
   $Name: V3_34K V3_34J V3_34I V3_34H V3_34G $
           
   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _MATH_INCLUDED
#define _MATH_INCLUDED

#include "sysmac.h"

#ifndef HUGE_VAL
#if __FLOAT_SIZE__ == __DOUBLE_SIZE__
#define HUGE_VAL 3.402823466e+38
#else
#define HUGE_VAL 1.7976931348623158e+308
#endif
#endif

/* What is returned if a domain error occurred */ 
#define __EDOM_VALUE    HUGE_VAL

/* PI, PI/2, PI/4, 1/PI, 2/PI */
#define __PI            3.141592653589793238462643
#define __PIO2          1.570796326794896619231
#define __PIO4          .785398163397448309615
#define __INVPI         0.31830988618379067154
#define __TWOOPI        0.63661977236758134308

/* SQRT(2), SQRT(2) + 1, SQRT(2) - 1,SQRT(2) / 2 */
#define __SQRT2         1.4142135623730950488016887
#define __SQ2P1         2.414213562373095048802
#define __SQ2M1         .414213562373095048802
#define __SQRTO2        0.707106781186547524

/* LN(10), TWO-LOG(e), LN(2) e */
#define __LN10          2.302585092994045684
#define __LOG2E         1.4426950408889634073599247
#define __LOG2          0.693147180559945309417232
#define __E             2.718281828459045235360287


#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=intrinsic(0)
#endif
#endif

#ifndef MEMORY_ATTRIBUTE
#define MEMORY_ATTRIBUTE
#endif

__INTRINSIC MEMORY_ATTRIBUTE double atan(double);

__INTRINSIC MEMORY_ATTRIBUTE double atan2(double, double);

__INTRINSIC MEMORY_ATTRIBUTE double cos(double);

__INTRINSIC MEMORY_ATTRIBUTE double cosh(double);

__INTRINSIC MEMORY_ATTRIBUTE double fabs(double);

__INTRINSIC MEMORY_ATTRIBUTE double fmod(double, double);

__INTRINSIC MEMORY_ATTRIBUTE double exp(double);

__INTRINSIC MEMORY_ATTRIBUTE double ldexp(double, int);

__INTRINSIC MEMORY_ATTRIBUTE double log(double);

__INTRINSIC MEMORY_ATTRIBUTE double log10(double);

__INTRINSIC MEMORY_ATTRIBUTE double modf(double, double *);

__INTRINSIC MEMORY_ATTRIBUTE double pow(double , double);

__INTRINSIC MEMORY_ATTRIBUTE double sin(double);

__INTRINSIC MEMORY_ATTRIBUTE double sinh(double);

__INTRINSIC MEMORY_ATTRIBUTE double sqrt(double);

__INTRINSIC MEMORY_ATTRIBUTE double tan(double);

__INTRINSIC MEMORY_ATTRIBUTE double tanh(double);

__INTRINSIC MEMORY_ATTRIBUTE double floor(double);

__INTRINSIC MEMORY_ATTRIBUTE double ceil(double);

__INTRINSIC MEMORY_ATTRIBUTE double frexp(double, int *);

__INTRINSIC MEMORY_ATTRIBUTE double acos(double);

__INTRINSIC MEMORY_ATTRIBUTE double asin(double);

#if __IAR_SYSTEMS_ICC__ < 2
#if __TID__ & 0x8000
#pragma function=default
#endif
#endif

#endif /* _MATH_INCLUDED */





