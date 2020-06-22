#ifndef INTERPRETER_H
#define INTERPRETER_H

#include <math.h>
#include <inttypes.h>

#include "cmdlist.c"

void myprint(char * s);

//#define FOR_DEBUGGER

using namespace std;
#ifdef FOR_DEBUGGER
    extern uint64_t *pc;
    extern uint64_t *prog;
    #define MAINDISPATCH goto *labels[*pc++]
    #define DISPATCH return -1
    int interpret();
#else
    #define MAINDISPATCH DISPATCH
    #define DISPATCH goto *labels[*pc++]
    int interpret(uint64_t *prog);
#endif //FOR_DEBUGGER

#define GETPAR *pc++
#define PUSH(x) datastack[++datastackindex].u = x
#define PUSHFLOAT(x) datastack[++datastackindex].d = x
#define POP datastack[datastackindex--]
#define TOS datastack[datastackindex]
#define PUSHCALLSTACK(x) callstack[++callstackindex] = x
#define POPCALLSTACK callstack[callstackindex--]

#define STACKSIZE 256
typedef union {
    uint64_t u;
    int64_t i;
    double d;
    uint64_t *p;
} data64bit;

extern uint8_t datastackindex;
extern uint8_t callstackindex;
extern data64bit datastack[STACKSIZE];
extern uint64_t callstack[STACKSIZE];

uint64_t *loadscript(int state_index, char *waspath);


#endif // INTERPRETER_H
