/* l_src.h - declarations for "l_src.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _L_SRC_H_INCLUDED
#define _L_SRC_H_INCLUDED

#include "defs.h"

#include <stdbool.h>
#include "l_list.h"
#include "l_ifile.h"

// Sources list structure

// Entry

struct source_entry_t
{
    struct list_entry_t list_entry;
    char *real, *base, *user;
    unsigned flags;
    struct included_files_t included;
};

void
    source_entry_clear
    (
        struct source_entry_t *self
    );

void
    source_entry_free
    (
        struct source_entry_t *self
    );

// List

struct sources_t
{
    struct list_t list;
};

void
    sources_clear
    (
        struct sources_t *self
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    sources_add
    (
        struct sources_t *self,
        const char *real,
        const char *base,
        const char *user,
        unsigned flags,
        struct source_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    sources_find_real
    (
        struct sources_t *self,
        const char *real,
        struct source_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    sources_find_user
    (
        struct sources_t *self,
        const char *user,
        struct source_entry_t **result
    );

void
    sources_free
    (
        struct sources_t *self
    );

#endif  // !_L_SRC_H_INCLUDED
