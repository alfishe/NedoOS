#ifndef CRC32_H
#define CRC32_H

void crc32_reset(void);
void crc32_update(const unsigned char *buf, unsigned int len);
unsigned long crc32_get(void);

#endif
