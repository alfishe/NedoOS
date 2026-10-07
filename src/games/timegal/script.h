#ifndef TIMEGAL_SCRIPT_H
#define TIMEGAL_SCRIPT_H

unsigned char script_levels(void);
const char *script_file(unsigned char level);
void script_bind(unsigned char level);
void script_pump(void);
unsigned char script_failed(void);
const char *script_death(void);

#endif
