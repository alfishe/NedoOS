/*                      - ERRNO.H -

   The ANSI 'error' constants and 'errno' variable declarations.

   $Name: V3_34K V3_34J V3_34I V3_34H V3_34G $
                    
   Copyright 1986 - 1999 IAR Systems. All rights reserved.
*/

#ifndef _ERRNO_INCLUDED
#define _ERRNO_INCLUDED

#define  EZERO      0
#define  EPERM      1
#define  ENOENT     2
#define  ESRCH      3
#define  EINTR      4
#define  EIO        5
#define  ENXIO      6
#define  E2BIG      7
#define  ENOEXEC    8
#define  EBADF      9
#define  ECHILD    10
#define  EAGAIN    11
#define  ENOMEM    12
#define  EACCES    13
#define  EFAULT    14
#define  ENOTBLK   15
#define  EBUSY     16
#define  EEXIST    17
#define  EXDEV     18
#define  ENODEV    19
#define  ENOTDIR   20
#define  EISDIR    21
#define  EINVAL    22
#define  ENFILE    23
#define  EMFILE    24
#define  ENOTTY    25
#define  ETXTBSY   26
#define  EFBIG     27
#define  ENOSPC    28
#define  ESPIPE    29
#define  EROFS     30
#define  EMLINK    31
#define  EPIPE     32
#define  EDOM      33
#define  ERANGE    34
#define  EUCLEAN   35
#define  EDEADLOCK 36
#define  EILSEQ    37

extern int errno;

#endif
