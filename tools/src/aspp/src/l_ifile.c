/* l_ifile.c -- include files list structure.

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
#include "l_ifile.h"

void
    included_file_entry_clear
    (
        struct included_file_entry_t *self
    )
{
    list_entry_clear (&self->list_entry);
    self->line = 0;     // invalid
    self->flags = 0;
    self->name = NULL;
}

void
    included_file_entry_free
    (
        struct included_file_entry_t *self
    )
{
    list_entry_free (&self->list_entry);
    if (self->name)
        free (self->name);
    included_file_entry_clear (self);
}

void
    included_files_clear
    (
        struct included_files_t *self
    )
{
    list_clear (&self->list);
}

bool
    included_files_add
    (
        struct included_files_t *self,
        unsigned line,
        unsigned flags,
        const char *name,
        struct included_file_entry_t **result
    )
{
    bool ok;
    struct included_file_entry_t *p;
    char *p_name;
#if DEBUG == 1
    unsigned i;
#endif  // DEBUG == 1

    ok = false;
    p = (struct included_file_entry_t *) NULL;
    p_name = (char *) NULL;

    if (!self || !name)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = malloc (sizeof (struct included_file_entry_t));
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

    included_file_entry_clear (p);
    p->line = line;
    p->flags = flags;
    p->name = p_name;

#if DEBUG == 1
    i = self->list.count;
#endif  // DEBUG == 1
    list_add_entry ((struct list_t *) self, (struct list_entry_t *) p);

    _DBG_ ("Added new included file #%u:", i);
    _DBG_ ("Included file #%u line = %u", i, p->line);
    _DBG_ ("Included file #%u flags = 0x%X", i, p->flags);
    _DBG_ ("Included file #%u user file = '%s'", i, p->name);

    ok = true;

_local_exit:
    if (!ok)
    {
        if (p)
        {
            free (p);
            p = (struct included_file_entry_t *) NULL;
        }
        if (p_name)
            free (p_name);
    }
    if (result)
        *result = p;
    return !ok;
}

bool
    included_files_find
    (
        struct included_files_t *self,
        const char *name,
        struct included_file_entry_t **result
    )
{
    bool ok;
    struct included_file_entry_t *p;
    unsigned i;

    ok = false;
    p = (struct included_file_entry_t *) NULL;

    if (!self || !name)
    {
        _DBG ("Bad arguments.");
        goto _local_exit;
    }

    p = (struct included_file_entry_t *) self->list.first;
    i = 0;
    while (p)
    {
        if (!strcmp (p->name, name))
        {
            // Success
            _DBG_ ("Found included file '%s' at #%u.", p->name, i);
            ok = true;
            goto _local_exit;
        }
        p = (struct included_file_entry_t *) p->list_entry.next;
        i++;
    }

    // Fail
    //p = (struct included_file_entry_t *) NULL;
    _DBG_ ("Failed to find included file '%s'.", name);

_local_exit:
    if (result)
        *result = p;
    return !ok;
}

void
    included_files_free
    (
        struct included_files_t *self
    )
{
    struct included_file_entry_t *p, *n;

    p = (struct included_file_entry_t *) self->list.first;
    while (p)
    {
        n = (struct included_file_entry_t *) p->list_entry.next;
        included_file_entry_free (p);
        free (p);
        p = n;
    }
    included_files_clear (self);
}
