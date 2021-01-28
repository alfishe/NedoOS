/* debug.c - library for logging debug messages.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#include "defs.h"

#include <stdarg.h>
#include <stdio.h>
#include "debug.h"

void _DEBUG (const char *file, int line, const char *func, const char *format, ...)
{
    va_list ap;

    va_start (ap, format);

    fprintf (stderr, "%s", "DEBUG");

    if (file)
        fprintf (stderr, ":%s", file);

    if (line)
        fprintf (stderr, ":%d", line);

    if (func)
        fprintf (stderr, ":%s()", func);

    fprintf (stderr, "%s", ": ");

    if (format)
        vfprintf (stderr, format, ap);

    va_end (ap);

    fprintf (stderr, NL);
}

void _PERROR (const char *file, int line, const char *func, const char *text)
{
    _DEBUG (file, line, func, "%s() failed.", text);
}
