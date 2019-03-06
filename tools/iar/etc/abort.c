/*                      - ABORT.C -

   The ANSI "abort" function.
           
   $Name: V3_34K V3_34J V3_34I V3_34H V3_34G $    

   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#include "stdlib.h"
 
void abort(void)
{
  exit(EXIT_FAILURE);
}     




