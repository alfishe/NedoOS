#ifndef TIMEGAL_SCRIPT_H
#define TIMEGAL_SCRIPT_H

unsigned char script_levels(void);
const char *script_file(unsigned char level);
void script_bind(unsigned char level);
void script_pump(void);
unsigned char script_failed(void);
const char *script_death(void);
void script_reset(void);
unsigned char script_take_life(void);
unsigned char script_lives(void);
void script_use_mirror(unsigned char on);
const char *script_level_file(unsigned char level);
unsigned char script_death_to_mirror(void);

#endif
