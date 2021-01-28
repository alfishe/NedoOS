/* l_err.h - declarations for "l_err.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _L_ERR_H_INCLUDED
#define _L_ERR_H_INCLUDED

#include "defs.h"

#include <stdbool.h>
#include <stdarg.h>
#include "l_list.h"

// Errors list structure

// Entry

struct error_entry_t
{
    struct list_entry_t list_entry;
    char *msg;
};

void
    error_entry_clear
    (
        struct error_entry_t *self
    );

void
    error_entry_free
    (
        struct error_entry_t *self
    );

// List

struct errors_t
{
    struct list_t list;
};

void
    errors_clear
    (
        struct errors_t *self
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    errors_add
    (
        struct errors_t *self,
        const char *msg,
        struct error_entry_t **result
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    errors_add_vfmt
    (
        struct errors_t *self,
        struct error_entry_t **result,
        unsigned bufsize,
        const char *format,
        va_list ap
    );

// Returns "false" on success ("result" if presents is set to list entry).
bool
    errors_add_fmt
    (
        struct errors_t *self,
        struct error_entry_t **result,
        unsigned bufsize,
        const char *format,
        ...
    );

void
    errors_free
    (
        struct errors_t *self
    );

#endif  // !_L_ERR_H_INCLUDED
