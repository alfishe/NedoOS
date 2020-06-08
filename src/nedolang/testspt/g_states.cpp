#include "g_states.h"
#include <math.h>

#define STACKSIZE 256

uint64_t datastack[STACKSIZE];
uint64_t callstack[STACKSIZE];

g_states::g_states() {

}

//TODO проверка переполнения адреса в VAL()

#define DISPATCH /*printf("pc %u labels_pc %u stk %u(%x) %u %u\n",(unsigned int)(uint64_t)(pc-prog),(unsigned int)(*pc),(unsigned int)datastack[datastackindex],(unsigned int)datastack[datastackindex],(unsigned int)datastack[(uint8_t)(datastackindex-1)],(unsigned int)datastack[(uint8_t)(datastackindex-2)]);*/ goto *labels[*pc++]
#define GETPAR *pc++
#define PUSH(x) datastack[++datastackindex] = x
#define PUSHFLOAT(x) *(double*)&datastack[++datastackindex] = x
#define POP datastack[datastackindex--]
#define TOS datastack[datastackindex]
#define PUSHCALLSTACK(x) callstack[++callstackindex] = x
#define POPCALLSTACK callstack[callstackindex--]

void g_states::interpret(uint64_t *prog) {

    int state;
    uint64_t *pc = prog;
    uint8_t datastackindex = 0; //растёт вверх
    uint8_t callstackindex = 0; //растёт вверх

    const void *labels[CMDS] = {
        /*[CMD_NOP] = */&&op_nop,
        /*[CMD_ADD] = */&&op_add,
        /*[CMD_SUB] = */&&op_sub,
        /*[CMD_MUL] = */&&op_mul,
        /*[CMD_DIV] = */&&op_div,
        /*[CMD_DIVSIGNED] = */&&op_divsigned,
        /*[CMD_IF0GOTO] = */&&op_if0goto,
        /*[CMD_GOTO] = */&&op_goto,
        /*[CMD_DUP] = */&&op_dup,
        /*[CMD_DROP] = */&&op_drop,
        /*[CMD_SWAP] = */&&op_swap,
        /*[CMD_READVAR] = */&&op_readvar,
        /*[CMD_WRITEVAR] = */&&op_writevar,
        /*[CMD_CONST] = */&&op_const,
        /*[CMD_RET] = */&&op_ret,
        /*[CMD_CALL] = */&&op_call,
        /*[CMD_AND] = */&&op_and,
        /*[CMD_OR] = */&&op_or,
        /*[CMD_XOR] = */&&op_xor,
        /*[CMD_EQ] = */&&op_eq,
        /*[CMD_MOREEQ] = */&&op_moreeq,
        /*[CMD_MOREEQSIGNED] = */&&op_moreeqsigned,
        /*[CMD_INV] = */&&op_inv,
        /*[CMD_RST] = */&&op_rst,
        /*[CMD_SHR] = */&&op_shr,
        /*[CMD_SHRSIGNED] = */&&op_shrsigned,
        /*[CMD_SHL] = */&&op_shl,
        /*[CMD_MOD] = */&&op_mod,
        /*[CMD_DONE] = */&&op_done,
        /*[CMD_ADDFLOAT] = */&&op_addfloat,
        /*[CMD_SUBFLOAT] = */&&op_subfloat,
        /*[CMD_MULFLOAT] = */&&op_mulfloat,
        /*[CMD_DIVFLOAT] = */&&op_divfloat,
        /*[CMD_NEGFLOAT] = */&&op_negfloat,
        /*[CMD_FLOATTOINT] = */&&op_floattoint,
        /*[CMD_INTTOFLOAT] = */&&op_inttofloat,
    };

    DISPATCH;
op_nop: {
        DISPATCH;
    }
op_add: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1+par2);
        DISPATCH;
    }
op_sub: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1-par2);
        DISPATCH;
    }
op_mul: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1*par2);
        DISPATCH;
    }
op_div: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1/par2);
        DISPATCH;
    }
op_divsigned: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = ((uint64_t)((int64_t)par1/(int64_t)par2));
        DISPATCH;
    }
op_mod: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1-((par1/par2)*par2));
        DISPATCH;
    }
op_and: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1&par2);
        DISPATCH;
    }
op_or: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1|par2);
        DISPATCH;
    }
op_xor: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1^par2);
        DISPATCH;
    }
op_inv: {
        TOS = ~TOS;
        DISPATCH;
    }
op_shr: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1>>par2);
        DISPATCH;
    }
op_shrsigned: {
        int64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1>>par2);
        DISPATCH;
    }
op_shl: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1<<par2);
        DISPATCH;
    }
op_eq: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1==par2)?-1:0;
        DISPATCH;
    }
op_moreeq: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = (par1>=par2)?-1:0;
        DISPATCH;
    }
op_moreeqsigned: {
        int64_t par1 = POP;
        int64_t par2 = TOS;
        TOS = (par1>=par2)?-1:0;
        DISPATCH;
    }
op_const: {
        PUSH(GETPAR);
        DISPATCH;
    }
op_dup: {
        PUSH(TOS);
        DISPATCH;
    }
op_drop: {
        POP;
        DISPATCH;
    }
op_swap: {
        uint64_t par1 = POP;
        uint64_t par2 = TOS;
        TOS = par1;
        PUSH(par2);
        DISPATCH;
    }
op_readvar: {
        TOS = VAL(TOS);
        DISPATCH;
    }
op_writevar: {
        uint64_t vardata = POP;
        VAL(POP) = vardata;
        DISPATCH;
    }
op_goto: {
        //printf("goto %u\n",(unsigned int)(*pc));
        pc = prog+(*pc); //нельзя GETPAR - делает pc++
        DISPATCH;
    }
op_if0goto: {
        if (!POP) {
            pc = prog+(*pc); //нельзя GETPAR - делает pc++
        }else {
            pc++;
        }
        DISPATCH;
    }
op_call: {
        uint64_t callpc = GETPAR;
        PUSHCALLSTACK((uint64_t)pc);
        pc = prog+callpc;
        DISPATCH;
    }
op_ret: {
        pc = (uint64_t*)(POPCALLSTACK);
        DISPATCH;
    }
op_rst: {
        double par1 = *(double*)&(POP);
        uint64_t op = GETPAR;
        switch (op) {
        case RST_SIN:
            PUSHFLOAT(sin(par1));
                break;
        case RST_COS:
            PUSHFLOAT(cos(par1));
                break;
        case RST_ATAN:
            PUSHFLOAT(atan(par1));
                break;
        case RST_ATAN2:
            PUSHFLOAT(atan2(par1,*(double*)&(POP)));
                break;
        case RST_EXP:
            PUSHFLOAT(exp(par1));
                break;
        case RST_LOG:
            PUSHFLOAT(log(par1));
                break;
        case RST_SQRT:
            PUSHFLOAT(sqrt(par1));
                break;
        case RST_ABS:
            PUSHFLOAT(abs(par1));
                break;

            default: ;
        };
        DISPATCH;
    }
op_addfloat: {
        double par1 = *(double*)&(POP);
        double par2 = *(double*)&(TOS);
        double res = par1+par2;
        *(double*)&(TOS) = res;
        DISPATCH;
    }
op_subfloat: {
        double par1 = *(double*)&(POP);
        double par2 = *(double*)&(TOS);
        double res = par1-par2;
        *(double*)&(TOS) = res;
        DISPATCH;
    }
op_mulfloat: {
        double par1 = *(double*)&(POP);
        double par2 = *(double*)&(TOS);
        double res = par1*par2;
        *(double*)&(TOS) = res;
        DISPATCH;
    }
op_divfloat: {
        double par1 = *(double*)&(POP);
        double par2 = *(double*)&(TOS);
        double res = par1/par2;
        *(double*)&(TOS) = res;
        DISPATCH;
    }
op_negfloat: {
        double par1 = *(double*)&(TOS);
        double res = -par1;
        *(double*)&(TOS) = res;
        DISPATCH;
    }
op_floattoint: {
        double par1 = *(double*)&(TOS);
        TOS = static_cast<uint64_t>(par1);
        DISPATCH;
    }
op_inttofloat: {
        double par1 = static_cast<double>(TOS);
        *(double*)&(TOS) = par1;
        DISPATCH;
    }
op_done: {
        //state = POP;
    };
    //return state;
}
