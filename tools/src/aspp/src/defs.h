/* defs.h - common definitions.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _DEFS_H_INCLUDED
#define _DEFS_H_INCLUDED

// DEBUG is set by "make"

#if DEBUG != 1
# define PROGRAM_VERSION_SUFFIX
#else   // DEBUG == 1
# define PROGRAM_VERSION_SUFFIX "-DEBUG"
#endif  // DEBUG == 1

#define NL "\n"

#endif  /* !_DEFS_H_INCLUDED */
