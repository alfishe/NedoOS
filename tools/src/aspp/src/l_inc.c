/* l_inc.c -- include paths list structure.

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
#include "l_inc.h"

void
    include_path_entry_clear
    (
        struct include_path_entry_t *self
    )
{
    list_entry_clear (&self->list_entry);
    self->real = NULL;
    self->base = NULL;
    self->user = NULL;
}

void
    include_path_entry_free
    (
        struct include_path_entry_t *self
    )
{
    list_entry_free (&self->list_entry);
    if (self->real)
        free (self->real);
    if (self->base)
        free (self->base);
    if (self->user)
        free (self->user);
    include_path_entry_clear (self);
}

void
    include_paths_clear
    (
        struct include_paths_t *self
    )
{
    list_clear (&self->list);
}

bool
    include_paths_add
    (
        struct include_paths_t *self,
        const char *real,
        const char *base,
        const char *user,
        struct include_path_entry_t **result
    )
{
    bool ok;
    struct include_path_entry_t *p;
    char *p_real, *p_base, *p_user;
#if DEBUG == 1
    unsigned i;
#endif  // DEBUG == 1

    ok = false;
    p = (struct include_path_entry_t *) NULL;
    p_real = (char *) NULL;
    p_base = (char *) NULL;
    p_user = (char *) NULL;

    if (!self || !real || !base || !user)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = malloc (sizeof (struct include_path_entry_t));
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

    include_path_entry_clear (p);
    p->real = p_real;
    p->base = p_base;
    p->user = p_user;

#if DEBUG == 1
    i = self->list.count;
#endif  // DEBUG == 1
    list_add_entry (& self->list, & p->list_entry);

    _DBG_ ("Added new include path #%u:", i);
    _DBG_ ("Include path #%u: user path = '%s'", i, p->user);
    _DBG_ ("Include path #%u: base path = '%s'", i, p->base);
    _DBG_ ("Include path #%u: real path = '%s'", i, p->real);

    ok = true;

_local_exit:
    if (!ok)
    {
        if (p)
        {
            free (p);
            p = (struct include_path_entry_t *) NULL;
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
    include_paths_find_real
    (
        struct include_paths_t *self,
        const char *real,
        struct include_path_entry_t **result
    )
{
    bool ok;
    struct include_path_entry_t *p;
    unsigned i;

    ok = false;
    p = (struct include_path_entry_t *) NULL;

    if (!self || !real)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = (struct include_path_entry_t *) self->list.first;
    i = 0;
    while (p)
    {
        if (!strcmp (p->real, real))
        {
            // Success
            _DBG_ ("Found user path '%s' (real path '%s') at #%u.", p->user, p->real, i);
            ok = true;
            goto _local_exit;
        }
        p = (struct include_path_entry_t *) p->list_entry.next;
        i++;
    }

    // Fail
    //p = (struct include_path_entry_t *) NULL;
    _DBG_ ("Failed to find real path '%s'.", real);

_local_exit:
    if (result)
        *result = p;
    return !ok;
}

bool
    include_paths_find_user
    (
        struct include_paths_t *self,
        const char *user,
        struct include_path_entry_t **result
    )
{
    bool ok;
    struct include_path_entry_t *p;
    unsigned i;

    ok = false;
    p = (struct include_path_entry_t *) NULL;

    if (!self || !user)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = (struct include_path_entry_t *) self->list.first;
    i = 0;
    while (p)
    {
        if (!strcmp (p->user, user))
        {
            // Success
            _DBG_ ("Found user path '%s' (real path '%s') at #%u.", p->user, p->real, i);
            ok = true;
            goto _local_exit;
        }
        p = (struct include_path_entry_t *) p->list_entry.next;
        i++;
    }

    // Fail
    //p = (struct include_paths_t *) NULL;
    _DBG_ ("Failed to find user path '%s'.", user);

_local_exit:
    if (result)
        *result = p;
    return !ok;
}

bool
    include_paths_add_with_check
    (
        struct include_paths_t *self,
        const char *user,
        const char *base_path_real,
        struct include_path_entry_t **result
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
        if (include_paths_find_real (self, real, result))
        {
            if (include_paths_add (self, real, "", user, result))
            {
                // Fail
                _perror ("include_paths_add");
                goto _local_exit;
            }
        }
        // Success
        ok = true;
        //goto _local_exit;
    }
    else
    {
        // relative path
        // first - check if it is already added
        if (!include_paths_find_user (self, user, result))
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
            if (check_path_exists (real))
            {
                if (!include_paths_add (self, real, base_path_real, user, result))
                {
                    // Success
                    ok = true;
                    goto _local_exit;
                }
                // Fail
            }
            // Fail
            _DBG_ ("Failed to find user path '%s'.", user);
            //goto _local_exit;
        }
    }
    // Success or Fail

_local_exit:
    if (real)
        free (real);
    if (!ok)
        if (result)
            *result = (struct include_path_entry_t *) NULL;
    return !ok;
}

// Returns "false" on success ("result" if presents is set to list entry).
bool
    include_paths_resolve_file
    (
        struct include_paths_t *self,
        const char *user,
        struct include_path_entry_t **result
    )
{
    bool ok;
    char *real;
    struct include_path_entry_t *p;
    unsigned len;
#if DEBUG == 1
    unsigned i;
#endif  // DEBUG == 1

    ok = false;
    real = (char *) NULL;
    p = (struct include_path_entry_t *) NULL;

    if (!self || !user)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    len = PATH_MAX + 1 + strlen (user) + 1;
    real = malloc (len);
    if (!real)
    {
        // Fail
        _perror ("malloc");
        goto _local_exit;
    }

    p = (struct include_path_entry_t *) self->list.first;
#if DEBUG == 1
    i = 0;
#endif  // DEBUG == 1
    while (p)
    {
        snprintf (real, len, "%s" PATHSEPSTR "%s", p->real, user);
        _DBG_ ("Checking user file '%s' at path '%s'...", user, p->real);
        if (check_file_exists (real))
        {
            // Success
#if DEBUG == 1
            _DBG_ ("Found user file '%s' (real file '%s') at #%u.", user, real, i);
#endif  // DEBUG == 1
            ok = true;
            goto _local_exit;
        }
        else
        {
            _DBG_ ("User file '%s' not found, skipped.", user);
        }
        p = (struct include_path_entry_t *) p->list_entry.next;
#if DEBUG == 1
        i++;
#endif  // DEBUG == 1
    }

    // Fail
    //p = (struct include_path_entry_t *) NULL;
    _DBG_ ("User file '%s' not resolved.", user);

_local_exit:
    if (real)
        free (real);
    if (result)
        *result = p;
    return !ok;
}

#if DEBUG == 1
void
    _DBG_include_paths_dump
    (
        struct include_paths_t *self
    )
{
    struct include_path_entry_t *p;
    unsigned i;

    if (!self)
    {
        _DBG ("Bad arguments.");
        return;
    }

    p = (struct include_path_entry_t *) self->list.first;
    if (p)
    {
        i = 0;
        do
        {
            _DBG_ ("Include path #%u: user path = '%s'", i, ((struct include_path_entry_t *) p)->user);
            _DBG_ ("Include path #%u: base path = '%s'", i, ((struct include_path_entry_t *) p)->base);
            _DBG_ ("Include path #%u: real path = '%s'", i, ((struct include_path_entry_t *) p)->real);
            p = (struct include_path_entry_t *) ((struct include_path_entry_t *) p)->list_entry.next;
            i++;
        }
        while (p);
    }
    else
        _DBG ("No include paths.");
}
#endif  // DEBUG == 1

void
    include_paths_free
    (
        struct include_paths_t *self
    )
{
    struct include_path_entry_t *p, *n;

    p = (struct include_path_entry_t *) self->list.first;
    while (p)
    {
        n = (struct include_path_entry_t *) p->list_entry.next;
        include_path_entry_free (p);
        free (p);
        p = n;
    }
    include_paths_clear (self);
}
