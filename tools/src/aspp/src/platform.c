/* platform.c - platform-specific library.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#include "defs.h"

#include <stdbool.h>
#include <limits.h>
#include <sys/stat.h>
#include <unistd.h>
#include <libgen.h>
#include <ctype.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include "platform.h"

#include "debug.h"

bool check_path_abs (const char *path)
{
#if !defined (_WIN32) && !defined(_WIN64)
    return (path && (path[0] == '/' || path[0] == '\\'));
#else
    return (path && (isalpha (path[0])) && path[1] == ':' && (path[2] == '/' || path[2] == '\\'));
#endif
}

#if defined (_WIN32) || defined(_WIN64)
# define ROOT_START 2    // skip disk name "A:"
#else
# define ROOT_START 0
#endif

char *resolve_full_path (const char *path)
{
    char *s;
    unsigned len, i, j;
    bool last_sep, f;

    if (!path || path[0] == '\0')
    {
        errno = path ? ENOENT : EINVAL;
        return (char *) NULL;
    }
    if (!check_path_abs (path))
    {
        errno = EINVAL;
        return (char *) NULL;
    }

    len = strlen (path);
    s = malloc (len+3); // + terminating zero + 2 chars (=3)
    if (!s)
        return (char *) NULL;
    strcpy (s, path);   // fine (sizeof (s) > sizeof (path))

    // Replace '\\' or '/' with PATHSEP. From here all '/' in comments must be treated as PATHSEP.
    for (i = ROOT_START; s[i] != '\0'; i++)
#if defined (_WIN32) || defined(_WIN64)
        if (s[i] == '/')
#else
        if (s[i] == '\\')
#endif
            s[i] = PATHSEP;

    last_sep = s[len-1] == PATHSEP;     // remember if last char is PATHSEP to keep it

    // Replace multiple '/' with single '/'
    i = ROOT_START;
    j = ROOT_START;
    while (s[j] != '\0')
    {
        if (s[j] == PATHSEP)
            while (s[j+1] == PATHSEP)
                j++;    // skip one char
        s[i] = s[j];
        i++;
        j++;
    }
    s[i] = '\0';
    len = i;

    // Replace '/.' with '/./', and '/..' with '/../' at end
    if (len >= (ROOT_START+2) && s[len-1] == '.')
    {
        if ((len >= (ROOT_START+3) && s[len-3] == PATHSEP && s[len-2] == '.')
        ||  (s[len-2] == PATHSEP))
        {
            s[len] = PATHSEP;
            len++;
            s[len] = '\0';
        }
    }

    // Replace "/./" with '/'
    i = ROOT_START;
    j = ROOT_START;
    while (s[j] != '\0')
    {
        if (s[j] == PATHSEP && s[j+1] == '.' && s[j+2] == PATHSEP)
            j += 2;     // skip two chars
        s[i] = s[j];
        i++;
        j++;
    }
    s[i] = '\0';
    len = i;

    // Remove all "/../"
    do
    {
        f = false;
        i = ROOT_START;
        while (s[i] != '\0'
        &&     (!(s[i] == PATHSEP && s[i+1] == '.' && s[i+2] == '.' && s[i+3] == PATHSEP)))
            i++;
        if (s[i] != '\0')
        {
            // check bad path at start: "/../", "A:/../"
            if (i == ROOT_START)
            {
                free (s);
                errno = EINVAL;
                return (char *) NULL;
            }
            j = i - 1;
            while (j > ROOT_START && s[j] != PATHSEP)
                j--;
            // remove part of string [j, i+2]
            i += 3;
            while (s[i] != '\0')
            {
                s[j] = s[i];
                i++;
                j++;
            }
            s[j] = '\0';
            f = true;
        }
    } while (f);

    // Restore '/' at end if it was and remove it if there wasn't
    len = strlen (s);
    if (last_sep && len > ROOT_START && s[len-1] != PATHSEP)
    {
        s[len] = PATHSEP;
        len++;
        s[len] = '\0';
    }
    else if (!last_sep && len > ROOT_START && len != ROOT_START+1 && s[len-1] == PATHSEP)
    {
        len--;
        s[len] = '\0';
    }

    return realloc (s, len+1);  // + terminating zero (strlen (s) <= strlen (path))
}

bool check_path_exists (const char *path)
{
    char *s;
    struct stat st;
    bool ok;

    s = resolve_full_path (path);
    if (!s)
        return false;

    ok = stat (s, &st) >= 0;

    free (s);

    if (!ok)
        return false;

    return (S_ISDIR (st.st_mode)) != 0;
}

bool check_file_exists (const char *path)
{
    char *s;
    struct stat st;
    bool ok;

    s = resolve_full_path (path);
    if (!s)
        return false;

    ok = stat (s, &st) >= 0;

    free (s);

    if (!ok)
        return false;

    return (S_ISREG (st.st_mode)) || ((st.st_mode & S_IFMT) == 0);
}

char *get_current_dir (void)
{
    return getcwd (NULL, 0);
}

char *get_dir_name (const char *path)
{
    char *pathc, *d, *result;

    pathc = strdup (path);
    if (!pathc)
        return (char *) NULL;
    d = dirname (pathc);
    result = strdup (d);
    free (pathc);
    return result;
}