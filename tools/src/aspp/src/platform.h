/* platform.h - declarations for "platform.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _PLATFORM_H_INCLUDED
#define _PLATFORM_H_INCLUDED

#include "defs.h"

#include <stdbool.h>

#if defined (_WIN32) || defined(_WIN64)
# define PATHSEP '\\'
# define PATHSEPSTR "\\"
#else
# define PATHSEP '/'
# define PATHSEPSTR "/"
#endif

// Returns "true" on success.
bool check_path_abs (const char *path);

// Returns string on success and "NULL" on fail. Check "errno" on fail.
// Result must be freed by caller.
char *resolve_full_path (const char *path);

// Returns "true" on success. Check "errno" on fail.
bool check_path_exists (const char *path);

// Returns "true" on success. Check "errno" on fail.
bool check_file_exists (const char *path);

// Returns string on success and "NULL" on fail. Check "errno" on fail.
// Result must be freed by caller.
char *get_current_dir (void);

// Returns string on success and "NULL" on fail. Check "errno" on fail.
// Result must be freed by caller.
char *get_dir_name (const char *path);

#endif  // !_PLATFORM_H_INCLUDED
