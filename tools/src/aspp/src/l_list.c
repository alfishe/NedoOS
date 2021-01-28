/* l_list.c - basic list structure.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#include "defs.h"

#include <stddef.h>
#include <stdlib.h>
#include "l_list.h"

void
    list_entry_clear
    (
        struct list_entry_t *self
    )
{
    self->next = NULL;
}

void
    list_entry_free
    (
        struct list_entry_t *self
    )
{
    list_entry_clear (self);
}

void
    list_clear
    (
        struct list_t *self
    )
{
    self->first = NULL;
    self->last = NULL;
    self->count = 0;
}

void
    list_add_entry
    (
        struct list_t *self,
        struct list_entry_t *p
    )
{
    if (self->first)
    {
        self->last->next = p;
        self->last = p;
    }
    else
    {
        self->first = p;
        self->last = p;
    }

    self->count++;
}

void
    list_free
    (
        struct list_t *self
    )
{
    struct list_entry_t *p, *n;

    p = self->first;
    while (p)
    {
        n = p->next;
        list_entry_free (p);
        free (p);
        p = n;
    }
    list_clear (self);
}
