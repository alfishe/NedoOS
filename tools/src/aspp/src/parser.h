/* parser.h - declarations for "parser.c".

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#ifndef _PARSER_H_INCLUDED
#define _PARSER_H_INCLUDED

#include "defs.h"

#include <stdbool.h>
#include "l_ifile.h"

// Syntax

#define SYNTAX_TASM  0
#define SYNTAX_SJASM 1

bool _str_to_syntax (const char *name, unsigned *syntax);
bool _syntax_to_str (unsigned syntax, const char **name);

// Parser status

#define PARST_OK   0
#define PARST_SKIP 1
#define PARST_ERR  2

// Parser

// Caller must free "name"
char get_include_tasm (const char *s, unsigned *flags, char **name);

// Caller must free "name"
char get_include_sjasm (const char *s, unsigned *flags, char **name);

typedef char get_include_proc_t (const char *s, unsigned *flags, char **name);

bool _find_get_include_proc (unsigned syntax, get_include_proc_t **proc);

#endif  // !_PARSER_H_INCLUDED
