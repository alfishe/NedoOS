/* l_ifile.h - declarations for "l_ifile.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _L_IFILE_H_INCLUDED
#define _L_IFILE_H_INCLUDED

#include "defs.h"

#include <stdbool.h>
#include "l_list.h"

// Include files list structure

#define SRCFL_NONE  0
#define SRCFL_PARSE (1 << 0)

// Entry

struct included_file_entry_t
{
    struct list_entry_t list_entry;
    unsigned line;
    unsigned flags;
    char *name;
};

void
    included_file_entry_clear
    (
        struct included_file_entry_t *self
    );

void
    included_file_entry_free
    (
        struct included_file_entry_t *self
    );

// List

struct included_files_t
{
    struct list_t list;
};

void
    included_files_clear
    (
        struct included_files_t *self
    );

bool
    included_files_add
    (
        struct included_files_t *self,
        unsigned line,
        unsigned flags,
        const char *name,
        struct included_file_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    included_files_find
    (
        struct included_files_t *self,
        const char *name,
        struct included_file_entry_t **result
    );

void
    included_files_free
    (
        struct included_files_t *self
    );

#endif  // !_L_IFILE_H_INCLUDED
