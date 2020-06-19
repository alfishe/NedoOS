#ifndef GLOBAL_MEM_H
#define GLOBAL_MEM_H
#include <inttypes.h>

// структура разделяемой памяти
struct g_SM {
    union {
        uint64_t u;
        int64_t i;
        double d;
    } current_value;
    uint64_t last_value;
    //uint64_t time;
};

extern int N; // число ячеек в разделяемой памяти
extern g_SM *stcSMData;

#define VAL(i) stcSMData[i].current_value.u
#define OLDVAL(i) stcSMData[i].last_value

#endif // GLOBAL_MEM_H
