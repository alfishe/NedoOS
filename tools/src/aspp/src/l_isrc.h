/* l_isrc.h - declarations for "l_isrc.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _L_ISRC_H_INCLUDED
#define _L_ISRC_H_INCLUDED

#include "defs.h"

#include <stdbool.h>
#include "l_list.h"
#include "l_isrc.h"

// Input sources list structure

// Entry

struct input_source_entry_t
{
    struct list_entry_t list_entry;
    char *real, *base, *user;
};

void
    input_source_entry_clear
    (
        struct input_source_entry_t *self
    );

void
    input_source_entry_free
    (
        struct input_source_entry_t *self
    );

// List

struct input_sources_t
{
    struct list_t list;
};

void
    input_sources_clear
    (
        struct input_sources_t *self
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    input_sources_add
    (
        struct input_sources_t *self,
        const char *real,
        const char *base,
        const char *user,
        struct input_source_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    input_sources_find_real
    (
        struct input_sources_t *self,
        const char *real,
        struct input_source_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    input_sources_find_user
    (
        struct input_sources_t *self,
        const char *user,
        struct input_source_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    input_sources_add_with_check
    (
        struct input_sources_t *self,
        const char *user,
        const char *base_path_real,
        struct input_source_entry_t **result
    );

#if DEBUG == 1
void
    _DBG_input_sources_dump
    (
        struct input_sources_t *self
    );
#else   // DEBUG != 1
# define _DBG_input_sources_dump(x)
#endif  // DEBUG 1= 1

void
    input_sources_free
    (
        struct input_sources_t *self
    );

#endif  // !_L_ISRC_H_INCLUDED
