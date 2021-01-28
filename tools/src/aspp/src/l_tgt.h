/* l_tgt.h - declarations for "l_tgt.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _L_TGT_H_INCLUDED
#define _L_TGT_H_INCLUDED

#include "defs.h"

#include <stdbool.h>
#include <stdio.h>
#include "l_list.h"

// Target names list structure

// Entry

struct target_name_entry_t
{
    struct list_entry_t list_entry;
    char *name;
};

void
    target_name_entry_clear
    (
        struct target_name_entry_t *self
    );

void
    target_name_entry_free
    (
        struct target_name_entry_t *self
    );

// List

struct target_names_t
{
    struct list_t list;
};

void
    target_names_clear
    (
        struct target_names_t *self
    );

// Returns "false" on success.
bool
    target_names_add
    (
        struct target_names_t *self,
        const char *name,
        struct target_name_entry_t **result
    );

// Returns "false" on success.
bool
    target_names_print
    (
        struct target_names_t *self,
        FILE *stream
    );

#if DEBUG == 1
void
    _DBG_target_names_dump
    (
        struct target_names_t *self
    );
#else   // DEBUG != 1
# define _DBG_target_names_dump(x)
#endif  // DEBUG 1= 1

void
    target_names_free
    (
        struct target_names_t *self
    );

#endif  // !_L_TGT_H_INCLUDED
