/* l_inc.h - declarations for "l_inc.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _L_INC_H_INCLUDED
#define _L_INC_H_INCLUDED

#include "defs.h"

#include <stdbool.h>
#include "l_list.h"

// Include paths list structure

// Entry

struct include_path_entry_t
{
    struct list_entry_t list_entry;
    char *real, *base, *user;
};

void
    include_path_entry_clear
    (
        struct include_path_entry_t *self
    );

void
    include_path_entry_free
    (
        struct include_path_entry_t *self
    );

// List

struct include_paths_t
{
    struct list_t list;
};

void
    include_paths_clear
    (
        struct include_paths_t *self
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    include_paths_add
    (
        struct include_paths_t *self,
        const char *real,
        const char *base,
        const char *user,
        struct include_path_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    include_paths_find_real
    (
        struct include_paths_t *self,
        const char *real,
        struct include_path_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    include_paths_find_user
    (
        struct include_paths_t *self,
        const char *user,
        struct include_path_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    include_paths_add_with_check
    (
        struct include_paths_t *self,
        const char *user,
        const char *base_path_real,
        struct include_path_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    include_paths_resolve_file
    (
        struct include_paths_t *self,
        const char *user,
        struct include_path_entry_t **result
    );

#if DEBUG == 1
void
    _DBG_include_paths_dump
    (
        struct include_paths_t *self
    );
#else   // DEBUG != 1
# define _DBG_include_paths_dump(x)
#endif  // DEBUG 1= 1

void
    include_paths_free
    (
        struct include_paths_t *self
    );

#endif  // !_L_INC_H_INCLUDED
