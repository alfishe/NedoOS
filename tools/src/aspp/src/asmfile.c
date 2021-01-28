/* asmfile.c - assembler file structure.

   This is free and unencumbered software released into the public domain.
   For more information, please refer to <http://unlicense.org>. */

#include "defs.h"

#include <stdbool.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "debug.h"
#include "l_list.h"
#include "asmfile.h"

void _asm_file_reset_pos (struct asm_file_t *self)
{
    self->pos = -1;             // invalid
    self->line = 0;             // invalid
    self->line_start = -1;      // invalid
    self->line_end = -1;        // invalid
}

void asm_file_clear (struct asm_file_t *self)
{
    if (!self)
        return; // Fail
    self->data = NULL;
    self->size = 0;
    _asm_file_reset_pos (self);
}

// Returns "false" on success.
bool asm_file_load (struct asm_file_t *self, const char *name)
{
    bool ok;
    FILE *f;
    long s;
    char *p;

    if (!self)
    {
        // Fail
        errno = EINVAL;
        return false;
    }

    ok = false;
    f = NULL;
    s = 0;
    p = NULL;

    _DBG_ ("File name = '%s'", name);

#if defined (_WIN32) || defined (_WIN64)
    f = fopen (name, "rb");
#else
    f = fopen (name, "r");
#endif
    if (!f)
    {
        // Fail
        _perror ("fopen");
        goto _local_exit;
    }

    errno = 0;

    fseek (f, 0, SEEK_END);
    if (errno)
    {
        // Fail
        _perror ("fseek");
        goto _local_exit;
    }

    s = ftell (f);
    if (s < 0)
    {
        // Fail
        _perror ("ftell");
        goto _local_exit;
    }

    fseek (f, 0, SEEK_SET);
    if (errno)
    {
        // Fail
        _perror ("fseek");
        goto _local_exit;
    }

    _DBG_ ("File size = %li", (long) s);

    if (s)
    {
        p = malloc (s);
        if (!p)
        {
            // Fail
            _perror ("malloc");
            goto _local_exit;
        }
        errno = 0;
        if (fread (p, s, 1, f) != 1)
        {
            // Fail
            _perror ("fread");
            goto _local_exit;
        }
        // Success
        ok = true;
    }

_local_exit:
    if (f)
        fclose (f);
    if (!ok)
    {
        if (p)
            free (p);
        p = NULL;
        s = 0;
    }
    self->data = p;
    self->size = s;
    _asm_file_reset_pos (self);
    return ok;
}

bool asm_file_eof (struct asm_file_t *self)
{
    if (!self)
    {
        // Fail
        errno = EINVAL;
        return true;
    }
    if (self->size)
    {
        // Success
        if (0         <= self->pos
        &&  self->pos <  self->size)
            return false;
        else
            return true;
    }
    else
    {
        // Fail
        errno = ENOENT;
        return true;
    }
}

bool asm_file_eol (struct asm_file_t *self)
{
    if (!self)
    {
        // Fail
        errno = EINVAL;
        return true;
    }
    if (!asm_file_eof (self))
    {
        // Success
        if (self->line_start <= self->pos
        &&  self->pos        <= self->line_end)
            return false;
        else
            return true;
    }
    else
        return true;    // Fail
}

const char *_find_line_end (const char *s, unsigned len)
{
    if (!s)
        return (char *) NULL;   // Fail
    while (len)
    {
        if (len && (*s == '\r' || *s == '\n'))
            break;
        s++;
        len--;
    }
    return s;   // Success
}

const char *_skip_line_end (const char *s, unsigned len)
{
    if (!s)
        return (char *) NULL;   // Fail
    if (len)
    {
        if (*s == '\r')
        {
            // found
            len--;
            s++;
            if (len && *s == '\n')
                s++;
        }
        else if (*s == '\n')
        {
            // found
            len--;
            s++;
            if (len && *s == '\r')
                s++;
        }
        else
            s += len;   // not found, skip to the end
    }
    return s;
}

bool asm_file_next_line (struct asm_file_t *self, const char **s, unsigned *len)
{
    const char *startp, *endp;
    unsigned sz;

    if (!self || !s || !len)
    {
        // Fail
        errno = EINVAL;
        return false;
    }
    if (self->pos < 0 || (self->pos >= 0 && !asm_file_eof (self)))
    {
        if (self->pos < 0)
        {
            // Start reading
            sz = self->size;
            startp = self->data;
        }
        else
        {
            // Continue reading
            sz = self->size - self->line_end;
            startp = _skip_line_end (self->data + self->line_end, sz);
            self->pos = startp - self->data;
            sz = self->size - self->pos;
        }
        endp = _find_line_end (startp, sz);
        self->pos = startp - self->data;
        if (!asm_file_eof (self))
        {
            // Success
            self->line++;
            self->line_start = self->pos;
            self->line_end = endp - self->data;
            *s = self->data + self->line_start;
            *len = self->line_end - self->line_start;
            return true;
        }
    }
    // Fail
    self->line_start = self->pos;
    self->line_end = self->pos;
    *s = (char *) NULL;
    *len = 0;
    return false;
}

void asm_file_free (struct asm_file_t *self)
{
    if (!self)
    {
        // Fail
        errno = EINVAL;
        return;
    }
    if (self->data)
        free (self->data);
    asm_file_clear (self);
}
