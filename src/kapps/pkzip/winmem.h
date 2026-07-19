#ifndef WINMEM_H
#define WINMEM_H

#define WIN_BASE ((unsigned char *)0x8000u)
#define WIN_SIZE 0x8000u
#define WIN_MASK 0x7FFFu

int win_alloc(void);
void win_free(void);

#define win_put(pos, b) (WIN_BASE[(pos) & WIN_MASK] = (unsigned char)(b))
#define win_get(pos) (WIN_BASE[(pos) & WIN_MASK])

#endif
