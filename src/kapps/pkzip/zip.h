#ifndef ZIP_H
#define ZIP_H

/* level: DEFL_L0 / DEFL_L1 / DEFL_RLE from deflate.h */
int zip_create(const char *archive, int level, int file_count, char *files[]);

#endif
