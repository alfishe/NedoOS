#ifndef _IFIFO_H_
#define _IFIFO_H_

void ififo_init(void);
void ififo_free(void);

void ififo_put(uint32_t);
uint32_t ififo_get(void);

size_t ififo_used(void);


#endif // _IFIFO_H_

