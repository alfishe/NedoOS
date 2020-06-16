#ifndef INTERPRETER_H
#define INTERPRETER_H

#include <math.h>
#include <inttypes.h>

#include "cmdlist.c"

using namespace std;

#define DISPATCH /*printf("pc %u labels_pc %u stk %u(%x) %u %u\n",(unsigned int)(uint64_t)(pc-prog),(unsigned int)(*pc),(unsigned int)datastack[datastackindex],(unsigned int)datastack[datastackindex],(unsigned int)datastack[(uint8_t)(datastackindex-1)],(unsigned int)datastack[(uint8_t)(datastackindex-2)]);*/ goto *labels[*pc++]
#define GETPAR *pc++
#define PUSH(x) datastack[++datastackindex] = x
#define PUSHFLOAT(x) *(double*)&datastack[++datastackindex] = x
#define POP datastack[datastackindex--]
#define TOS datastack[datastackindex]
#define PUSHCALLSTACK(x) callstack[++callstackindex] = x
#define POPCALLSTACK callstack[callstackindex--]

#define STACKSIZE 256

void interpret(uint64_t *prog);
uint64_t *loadscript(int state_index, char *waspath);


#endif // INTERPRETER_H
