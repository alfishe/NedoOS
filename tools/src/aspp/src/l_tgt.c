/* l_tgt.c - target names list structure.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#include "defs.h"

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "debug.h"
#include "l_list.h"
#include "l_tgt.h"

void
    target_name_entry_clear
    (
        struct target_name_entry_t *self
    )
{
    list_entry_clear (&self->list_entry);
    self->name = NULL;
}

void
    target_name_entry_free
    (
        struct target_name_entry_t *self
    )
{
    list_entry_free (&self->list_entry);
    if (self->name)
        free (self->name);
    target_name_entry_clear (self);
}

void
    target_names_clear
    (
        struct target_names_t *self
    )
{
    list_clear (&self->list);
}

bool
    target_names_add
    (
        struct target_names_t *self,
        const char *name,
        struct target_name_entry_t **result
    )
{
    bool ok;
    struct target_name_entry_t *p;
    char *p_name;
#if DEBUG == 1
    unsigned i;
#endif  // DEBUG == 1

    ok = false;
    p = (struct target_name_entry_t *) NULL;
    p_name = (char *) NULL;

    if (!self || !name)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = malloc (sizeof (struct target_name_entry_t));
    if (!p)
    {
        _perror ("malloc");
        goto _local_exit;
    }
    p_name = strdup (name);
    if (!p_name)
    {
        _perror ("strdup");
        goto _local_exit;
    }

    target_name_entry_clear (p);
    p->name = p_name;

#if DEBUG == 1
    i = self->list.count;
#endif  // DEBUG == 1
    list_add_entry ((struct list_t *) self, (struct list_entry_t *) p);

    _DBG_ ("Added new target name #%u: '%s'", i, p->name);

    ok = true;

_local_exit:
    if (!ok)
    {
        if (p)
        {
            free (p);
            p = (struct target_name_entry_t *) NULL;
        }
        if (p_name)
            free (p_name);
    }
    if (result)
        *result = p;
    return !ok;
}

bool
    target_names_print
    (
        struct target_names_t *self,
        FILE *stream
    )
{
    const struct target_name_entry_t *p;
    bool padding;

    if (!self || !stream)
    {
        _DBG ("Bad arguments.");
        return true;
    }

    padding = false;
    for (p = (struct target_name_entry_t *) self->list.first; p;
         p = (struct target_name_entry_t *) p->list_entry.next)
    {
        if (fprintf (stream, padding ? " %s" : "%s", p->name) < 0)
        {
            _perror ("fprintf");
            return true;
        }
        padding = true;
    }

    return false;
}

#if DEBUG == 1
void
    _DBG_target_names_dump
    (
        struct target_names_t *self
    )
{
    struct target_name_entry_t *p;
    unsigned i;

    if (!self)
    {
        _DBG ("Bad arguments.");
        return;
    }

    p = (struct target_name_entry_t *) self->list.first;
    if (p)
    {
        i = 0;
        do
        {
            _DBG_ ("Target #%u: user file = '%s'", i, ((struct target_name_entry_t *) p)->name);
            p = (struct target_name_entry_t *) ((struct target_name_entry_t *) p)->list_entry.next;
            i++;
        }
        while (p);
    }
    else
        _DBG ("No target names.");
}
#endif  // DEBUG == 1

void
    target_names_free
    (
        struct target_names_t *self
    )
{
    struct target_name_entry_t *p, *n;

    p = (struct target_name_entry_t *) self->list.first;
    while (p)
    {
        n = (struct target_name_entry_t *) p->list_entry.next;
        target_name_entry_free (p);
        free (p);
        p = n;
    }
    target_names_clear (self);
}
