#ifndef _GLOBAL_H_
#define _GLOBAL_H_

struct global
{
	int buf_num;

	int test_sync;
};

extern struct global g;


void init_global(void);

#endif // _GLOBAL_H_
