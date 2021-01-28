/* l_list.h - declarations for "l_list.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _L_LIST_H_INCLUDED
#define _L_LIST_H_INCLUDED

#include "defs.h"

// List structure

// Entry

struct list_entry_t
{
    struct list_entry_t *next;
};

void
    list_entry_clear
    (
        struct list_entry_t *self
    );

// Free contents, but not the variable itself
void
    list_entry_free
    (
        struct list_entry_t *self
    );

// List

struct list_t
{
    struct list_entry_t *first, *last;
    unsigned count;
};

void
    list_clear
    (
        struct list_t *self
    );

void
    list_add_entry
    (
        struct list_t *self,
        struct list_entry_t *p
    );

// Free contents, but not the variable itself
void
    list_free
    (
        struct list_t *self
    );

#endif  // !_L_LIST_H_INCLUDED
