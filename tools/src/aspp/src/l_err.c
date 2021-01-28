/* l_err.c - errors list structure.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#include "defs.h"

#include <stdbool.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "debug.h"
#include "l_list.h"
#include "l_err.h"

void
    error_entry_clear
    (
        struct error_entry_t *self
    )
{
    list_entry_clear (&self->list_entry);
    self->msg = NULL;
}

void
    error_entry_free
    (
        struct error_entry_t *self
    )
{
    list_entry_free (&self->list_entry);
    if (self->msg)
        free (self->msg);
    error_entry_clear (self);
}

void
    errors_clear
    (
        struct errors_t *self
    )
{
    list_clear (&self->list);
}

bool
    errors_add
    (
        struct errors_t *self,
        const char *msg,
        struct error_entry_t **result
    )
{
    bool ok;
    struct error_entry_t *p;
    char *p_msg;

    ok = false;
    p = (struct error_entry_t *) NULL;
    p_msg = (char *) NULL;

    if (!self || !msg)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = malloc (sizeof (struct error_entry_t));
    if (!p)
    {
        _perror ("malloc");
        goto _local_exit;
    }

    p_msg = strdup (msg);
    if (!p)
    {
        _perror ("strdup");
        goto _local_exit;
    }

    error_entry_clear (p);
    p->msg = p_msg;

    list_add_entry (&self->list, &p->list_entry);
    ok = true;

_local_exit:
    if (!ok)
    {
        if (p)
        {
            free (p);
            p = (struct error_entry_t *) NULL;
        }
        if (p_msg)
            free (p_msg);
    }
    if (result)
        *result = p;
    return !ok;
}

bool
    errors_add_vfmt
    (
        struct errors_t *self,
        struct error_entry_t **result,
        unsigned bufsize,
        const char *format,
        va_list ap
    )
{
    bool ok;
    char *s;

    ok = false;
    s = (char *) NULL;

    if (!self || !bufsize || !format)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    s = malloc (bufsize);
    if (!s)
    {
        _perror ("malloc");
        goto _local_exit;
    }
    vsnprintf (s, bufsize, format, ap);
    if (!errors_add (self, s, result))
        ok = true;

_local_exit:
    if (s)
        free (s);
    if (!ok)
        if (result)
            *result = (struct error_entry_t *) NULL;
    return !ok;
}

bool
    errors_add_fmt
    (
        struct errors_t *self,
        struct error_entry_t **result,
        unsigned bufsize,
        const char *format,
        ...
    )
{
    bool ok;
    va_list ap;

    va_start (ap, format);

    ok = false;

    if (!self || !bufsize || !format)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    if (!errors_add_vfmt (self, result, bufsize, format, ap))
        ok = true;

_local_exit:
    va_end (ap);
    if (!ok)
        if (result)
            *result = (struct error_entry_t *) NULL;
    return !ok;
}

void
    errors_free
    (
        struct errors_t *self
    )
{
    struct error_entry_t *p, *n;

    p = (struct error_entry_t *) self->list.first;
    while (p)
    {
        n = (struct error_entry_t *) p->list_entry.next;
        error_entry_free (p);
        free (p);
        p = n;
    }
    errors_clear (self);
}
