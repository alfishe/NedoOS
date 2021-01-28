/* l_src.c - sources list structure.

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
#include "l_src.h"

void
    source_entry_clear
    (
        struct source_entry_t *self
    )
{
    list_entry_clear (&self->list_entry);
    self->real = NULL;
    self->base = NULL;
    self->user = NULL;
    self->flags = 0;
    included_files_clear (&self->included);
}

void
    source_entry_free
    (
        struct source_entry_t *self
    )
{
    list_entry_free (&self->list_entry);
    if (self->real)
        free (self->real);
    if (self->base)
        free (self->base);
    if (self->user)
        free (self->user);
    included_files_free (&self->included);
    source_entry_clear (self);
}

void
    sources_clear
    (
        struct sources_t *self
    )
{
    list_clear (&self->list);
}

bool
    sources_add
    (
        struct sources_t *self,
        const char *real,
        const char *base,
        const char *user,
        unsigned flags,
        struct source_entry_t **result
    )
{
    bool ok;
    struct source_entry_t *p;
    char *p_real, *p_base, *p_user;
#if DEBUG == 1
    unsigned i;
#endif  // DEBUG == 1

    ok = false;
    p = (struct source_entry_t *) NULL;
    p_real = (char *) NULL;
    p_base = (char *) NULL;
    p_user = (char *) NULL;

    if (!self || !real || !base || !user)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = malloc (sizeof (struct source_entry_t));
    if (!p)
    {
        _perror ("malloc");
        goto _local_exit;
    }
    p_real = strdup (real);
    if (!p_real)
    {
        _perror ("strdup");
        goto _local_exit;
    }
    p_base = strdup (base);
    if (!p_base)
    {
        _perror ("strdup");
        goto _local_exit;
    }
    p_user = strdup (user);
    if (!p_user)
    {
        _perror ("strdup");
        goto _local_exit;
    }

    source_entry_clear (p);
    p->real = p_real;
    p->base = p_base;
    p->user = p_user;
    p->flags = flags;

#if DEBUG == 1
    i = self->list.count;
#endif  // DEBUG == 1
    list_add_entry ((struct list_t *) self, (struct list_entry_t *) p);

    _DBG_ ("Added new source #%u:", i);
    _DBG_ ("Source #%u: flags = 0x%x", i, p->flags);
    _DBG_ ("Source #%u: user file = '%s'", i, p->user);
    _DBG_ ("Source #%u: base path = '%s'", i, p->base);
    _DBG_ ("Source #%u: real file = '%s'", i, p->real);

    ok = true;

_local_exit:
    if (!ok)
    {
        if (p)
        {
            free (p);
            p = (struct source_entry_t *) NULL;
        }
        if (p_real)
            free (p_real);
        if (p_base)
            free (p_base);
        if (p_user)
            free (p_user);
    }
    if (result)
        *result = p;
    return !ok;
}

bool
    sources_find_real
    (
        struct sources_t *self,
        const char *real,
        struct source_entry_t **result
    )
{
    bool ok;
    struct source_entry_t *p;
    unsigned i;

    ok = false;
    p = (struct source_entry_t *) NULL;

    if (!self || !real)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = (struct source_entry_t *) self->list.first;
    i = 0;
    while (p)
    {
        if (!strcmp (p->real, real))
        {
            // Success
            _DBG_ ("Found user file '%s' (real file '%s') at #%u.", p->user, p->real, i);
            ok = true;
            goto _local_exit;
        }
        p = (struct source_entry_t *) p->list_entry.next;
        i++;
    }

    // Fail
    //p = (struct source_entry_t *) NULL;
    _DBG_ ("Failed to find real file '%s'.", real);

_local_exit:
    if (result)
        *result = p;
    return !ok;
}

bool
    sources_find_user
    (
        struct sources_t *self,
        const char *user,
        struct source_entry_t **result
    )
{
    bool ok;
    struct source_entry_t *p;
    unsigned i;

    ok = false;
    p = (struct source_entry_t *) NULL;

    if (!self || !user)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = (struct source_entry_t *) self->list.first;
    i = 0;
    while (p)
    {
        if (!strcmp (p->user, user))
        {
            // Success
            _DBG_ ("Found user file '%s' (real file '%s') at #%u.", p->user, p->real, i);
            ok = true;
            goto _local_exit;
        }
        p = (struct source_entry_t *) p->list_entry.next;
        i++;
    }

    // Fail
    //p = (struct source_entry_t *) NULL;
    _DBG_ ("Failed to find user file '%s'.", user);

_local_exit:
    if (result)
        *result = p;
    return !ok;
}

void
    sources_free
    (
        struct sources_t *self
    )
{
    struct source_entry_t *p, *n;

    p = (struct source_entry_t *) self->list.first;
    while (p)
    {
        n = (struct source_entry_t *) p->list_entry.next;
        source_entry_free (p);
        free (p);
        p = n;
    }
    sources_clear (self);
}
