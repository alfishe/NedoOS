/* l_isrc.c - input sources list structure.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#include "defs.h"

#include <stdbool.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "debug.h"
#include "platform.h"
#include "l_list.h"
#include "l_isrc.h"

void
    input_source_entry_clear
    (
        struct input_source_entry_t *self
    )
{
    list_entry_clear (&self->list_entry);
    self->real = NULL;
    self->base = NULL;
    self->user = NULL;
}

void
    input_source_entry_free
    (
        struct input_source_entry_t *self
    )
{
    list_entry_free (&self->list_entry);
    if (self->real)
        free (self->real);
    if (self->base)
        free (self->base);
    if (self->user)
        free (self->user);
    input_source_entry_clear (self);
}

void
    input_sources_clear
    (
        struct input_sources_t *self
    )
{
    list_clear (&self->list);
}

bool
    input_sources_add
    (
        struct input_sources_t *self,
        const char *real,
        const char *base,
        const char *user,
        struct input_source_entry_t **result
    )
{
    bool ok;
    struct input_source_entry_t *p;
    char *p_real, *p_base, *p_user;
#if DEBUG == 1
    unsigned i;
#endif  // DEBUG == 1

    ok = false;
    p = (struct input_source_entry_t *) NULL;
    p_real = (char *) NULL;
    p_base = (char *) NULL;
    p_user = (char *) NULL;

    if (!self || !real || !base || !user)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = malloc (sizeof (struct input_source_entry_t));
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

    input_source_entry_clear (p);
    p->real = p_real;
    p->base = p_base;
    p->user = p_user;

#if DEBUG == 1
    i = self->list.count;
#endif  // DEBUG == 1
    list_add_entry ((struct list_t *) self, (struct list_entry_t *) p);

    _DBG_ ("Added new input source #%u:", i);
    _DBG_ ("Input source #%u: user file = '%s'", i, p->user);
    _DBG_ ("Input source #%u: base path = '%s'", i, p->base);
    _DBG_ ("Input source #%u: real file = '%s'", i, p->real);

    ok = true;

_local_exit:
    if (!ok)
    {
        if (p)
        {
            free (p);
            p = (struct input_source_entry_t *) NULL;
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
    input_sources_find_real
    (
        struct input_sources_t *self,
        const char *real,
        struct input_source_entry_t **result
    )
{
    bool ok;
    struct input_source_entry_t *p;
    unsigned i;

    ok = false;
    p = (struct input_source_entry_t *) NULL;

    if (!self || !real)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = (struct input_source_entry_t *) self->list.first;
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
        p = (struct input_source_entry_t *) p->list_entry.next;
        i++;
    }

    // Fail
    //p = (struct input_source_entry_t *) NULL;
    _DBG_ ("Failed to find real file '%s'.", real);

_local_exit:
    if (result)
        *result = p;
    return !ok;
}

bool
    input_sources_find_user
    (
        struct input_sources_t *self,
        const char *user,
        struct input_source_entry_t **result
    )
{
    bool ok;
    struct input_source_entry_t *p;
    unsigned i;

    ok = false;
    p = (struct input_source_entry_t *) NULL;

    if (!self || !user)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = (struct input_source_entry_t *) self->list.first;
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
        p = (struct input_source_entry_t *) p->list_entry.next;
        i++;
    }

    // Fail
    //p = (struct input_source_entry_t *) NULL;
    _DBG_ ("Failed to find user file '%s'.", user);

_local_exit:
    if (result)
        *result = p;
    return !ok;
}

bool
    input_sources_add_with_check
    (
        struct input_sources_t *self,
        const char *user,
        const char *base_path_real,
        struct input_source_entry_t **result
    )
{
    bool ok;
    char *real, *tmp;
    unsigned len;

    ok = false;
    real = NULL;

    if (!self || !user || !base_path_real)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    if (check_path_abs (user))
    {
        // absolute path
        // first - check if it is already added
        real = resolve_full_path (user);
        if (!real)
        {
            // Fail
            _perror ("resolve_full_path");
            goto _local_exit;
        }
        if (input_sources_find_real (self, real, result))
        {
            if (input_sources_add (self, real, "", user, result))
            {
                // Fail
                goto _local_exit;
            }
            // Success
            //ok = true;
            //goto _local_exit;
        }
        // Success
        ok = true;
        //goto _local_exit;
    }
    else
    {
        // relative path
        // first - check if it is already added
        if (!input_sources_find_user (self, user, result))
        {
            // Success
            ok = true;
            //goto _local_exit;
        }
        else
        {
            len = strlen (base_path_real) + 1 + strlen (user) + 1;
            tmp = malloc (len);
            if (!tmp)
            {
                // Fail
                _perror ("malloc");
                goto _local_exit;
            }
            snprintf (tmp, len, "%s" PATHSEPSTR "%s", base_path_real, user);
            real = resolve_full_path (tmp);
            free (tmp);
            if (!real)
            {
                // Fail
                _perror ("resolve_full_path");
                goto _local_exit;
            }
            // trying real path - we are lucky
            if (check_file_exists (real))
            {
                if (!input_sources_add (self, real, base_path_real, user, result))
                {
                    // Success
                    ok = true;
                    //goto _local_exit;
                }
                // Fail
                //goto _local_exit;
            }
            else
            {
                // Fail
                _DBG_ ("Failed to find user file '%s'.", user);
                //goto _local_exit;
            }
        }
    }

_local_exit:
    if (real)
        free (real);
    if (!ok)
        if (result)
            *result = NULL;
    return !ok;
}

#if DEBUG == 1
void
    _DBG_input_sources_dump
    (
        struct input_sources_t *self
    )
{
    void *p;
    unsigned i;

    if (!self)
    {
        _DBG ("Bad arguments.");
        return;
    }

    p = (struct input_source_entry_t *) self->list.first;
    if (p)
    {
        i = 0;
        do
        {
            _DBG_ ("Input source #%u: user file = '%s'", i, ((struct input_source_entry_t *) p)->user);
            _DBG_ ("Input source #%u: base path = '%s'", i, ((struct input_source_entry_t *) p)->base);
            _DBG_ ("Input source #%u: real file = '%s'", i, ((struct input_source_entry_t *) p)->real);
            p = (struct input_source_entry_t *) ((struct input_source_entry_t *) p)->list_entry.next;
            i++;
        }
        while (p);
    }
    else
        _DBG ("No input sources.");
}
#endif  // DEBUG == 1

void
    input_sources_free
    (
        struct input_sources_t *self
    )
{
    struct input_source_entry_t *p, *n;

    p = (struct input_source_entry_t *) self->list.first;
    while (p)
    {
        n = (struct input_source_entry_t *) p->list_entry.next;
        input_source_entry_free (p);
        free (p);
        p = n;
    }
    input_sources_clear (self);
}
