/* parser.c - source file parser library.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#include "defs.h"

#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "debug.h"
#include "l_ifile.h"
#include "parser.h"

const struct
{
    char *name;
    unsigned syntax;
}
syntaxes[] =
{
    { "tasm", SYNTAX_TASM },
    { "sjasm", SYNTAX_SJASM },
    { NULL, 0 }
};

bool _str_to_syntax (const char *name, unsigned *syntax)
{
    unsigned i;
    for (i = 0; syntaxes[i].name; i++)
    {
        if (!strcmp (syntaxes[i].name, name))
        {
            *syntax = syntaxes[i].syntax;
            return true;
        }
    }
    return false;
}

bool _syntax_to_str (unsigned syntax, const char **name)
{
    unsigned i;
    for (i = 0; syntaxes[i].name; i++)
    {
        if (syntaxes[i].syntax == syntax)
        {
            *name = syntaxes[i].name;
            return true;
        }
    }
    return false;
}

const char *_skip_blanks (const char *s)
{
    if (s) while (*s != '\0' && isblank(*s)) s++;
    return s;
}

const char *_skip_word (const char *s)
{
    if (s)
    {
        if (*s == '_' || isalpha(*s))
        {
            s++;
            while (*s != '\0' && isalnum(*s)) s++;
        }
    }
    return s;
}

const char *_skip_string (const char *s)
{
    const char *p;
    p = s;
    if (p)
    {
        if (*p == '"')
        {
            p++;        // Skip opening double quote character
            while (*p != '\0' && *p != '"') p++;
            if (*p == '"')
                p++;    // Skip closing double quote character
            else
                p = s;  // Fail
        }
    }
    return p;
}

#define TEXT_BUF_SIZE 15
char get_include_tasm (const char *s, unsigned *flags, char **name)
{
    char st;
    char buf[TEXT_BUF_SIZE+1];
    const char *endp, *np;
    unsigned sl, nl;
    unsigned inc_flags;
    char *inc_name;

    st = PARST_SKIP;
    inc_name = (char *) NULL;

    if (!flags || !name)
        goto _error_exit;

    // RegEx pattern: [[:space:]]*include[[:space:]]+"[^[:space:]]+"
    // The rest of a line is not analized.

    // blanks
    endp = _skip_blanks (s);
    if (*endp == '\0')
        goto _skip_line;
    // assembler directive
    s = endp;
    endp = _skip_word (s);
    if (s == endp || *endp == '\0')
        goto _skip_line;
    // (save it)
    sl = endp - s;
    if (sl > TEXT_BUF_SIZE)
        sl = TEXT_BUF_SIZE;
    memcpy (buf, s, sl);
    buf[sl] = '\0';
    // (check it)
    if (!strcasecmp (buf, "include"))
        inc_flags = SRCFL_PARSE;
    else
        goto _skip_line;
    // blanks
    s = endp;
    endp = _skip_blanks (s);
    if (s == endp || *endp == '\0')
        goto _skip_line;
    // string
    s = endp;
    endp = _skip_string (s);
    if (s == endp)
        goto _skip_line;
    // (save it)
    np = s + 1;         // skip opening double quotes character
    nl = endp - s - 2;  // excluding double quotes characters
    inc_name = malloc (nl + 1); // including terminating zero
    if (!inc_name)
    {
        // Fail
        _perror ("malloc");
        goto _error_exit;
    }
    memcpy (inc_name, np, nl);
    inc_name[nl] = '\0';
    // (done)
    st = PARST_OK;
    *flags = inc_flags;
    *name = inc_name;
    goto _local_exit;

_skip_line:
    st = PARST_SKIP;
    goto _local_exit;

_error_exit:
    st = PARST_ERR;

_local_exit:
    if (st != PARST_OK)
    {
        if (inc_name)
            free (inc_name);
    }
    return st;
}
#undef TEXT_BUF_SIZE

#define TEXT_BUF_SIZE 15
char get_include_sjasm (const char *s, unsigned *flags, char **name)
{
    char st;
    char buf[TEXT_BUF_SIZE+1];
    const char *endp, *np;
    unsigned sl, nl;
    unsigned inc_flags;
    char *inc_name;

    st = PARST_SKIP;
    inc_name = (char *) NULL;

    if (!flags || !name)
        goto _error_exit;

    // RegEx pattern: [[:space:]]+(include|incbin)[[:space:]]+"[^[:space:]]+"
    // The rest of a line is not analized.

    // blanks
    endp = _skip_blanks (s);
    if (s == endp || *endp == '\0')
        goto _skip_line;
    // assembler directive
    s = endp;
    endp = _skip_word (s);
    if (s == endp || *endp == '\0')
        goto _skip_line;
    // (save it)
    sl = endp - s;
    if (sl > TEXT_BUF_SIZE)
        sl = TEXT_BUF_SIZE;
    memcpy (buf, s, sl);
    buf[sl] = '\0';
    // (check it)
    if (!strcasecmp (buf, "incbin"))
        inc_flags = 0;
    else if (!strcasecmp (buf, "include"))
        inc_flags = SRCFL_PARSE;
    else
        goto _skip_line;
    // blanks
    s = endp;
    endp = _skip_blanks (s);
    if (s == endp || *endp == '\0')
        goto _skip_line;
    // string
    s = endp;
    endp = _skip_string (s);
    if (s == endp)
        goto _skip_line;
    // (save it)
    np = s + 1;         // skip opening double quotes character
    nl = endp - s - 2;  // excluding double quotes characters
    inc_name = malloc (nl + 1); // including terminating zero
    if (!inc_name)
    {
        // Fail
        _perror ("malloc");
        goto _error_exit;
    }
    memcpy (inc_name, np, nl);
    inc_name[nl] = '\0';
    // (done)
    st = PARST_OK;
    *flags = inc_flags;
    *name = inc_name;
    goto _local_exit;

_skip_line:
    st = PARST_SKIP;
    goto _local_exit;

_error_exit:
    st = PARST_ERR;

_local_exit:
    if (st != PARST_OK)
    {
        if (inc_name)
            free (inc_name);
    }
    return st;
}
#undef TEXT_BUF_SIZE

const struct
{
    get_include_proc_t *proc;
    unsigned syntax;
}
include_procs[] =
{
    { get_include_tasm, SYNTAX_TASM },
    { get_include_sjasm, SYNTAX_SJASM },
    { NULL, 0 }
};

bool _find_get_include_proc (unsigned syntax, get_include_proc_t **proc)
{
    unsigned i;
    for (i = 0; include_procs[i].proc; i++)
    {
        if (include_procs[i].syntax == syntax)
        {
            *proc = include_procs[i].proc;
            return true;
        }
    }
    return false;
}
