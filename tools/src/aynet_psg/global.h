#ifndef _GLOBAL_H_
#define _GLOBAL_H_

struct global
{
	int prebuf;
	int syncchk;
	int framechk;
};

extern struct global g;


void init_global(void);

#endif // _GLOBAL_H_
