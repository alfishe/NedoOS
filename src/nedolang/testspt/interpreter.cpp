#include "interpreter.h"
#include "global_mem.h"
#include <stdio.h>
#include <stdlib.h>
//#include <time.h>
#include <string>
#include <sstream>

uint8_t datastackindex = 0; //растёт вверх
uint8_t callstackindex = 0; //растёт вверх

data64bit datastack[STACKSIZE];
uint64_t callstack[STACKSIZE];

#ifdef FOR_DEBUGGER
    uint64_t *pc;
    uint64_t *prog;
    int interpret() {
#else //FOR_DEBUGGER
    int interpret(uint64_t *prog) {
        uint64_t *pc = prog;
#endif //FOR_DEBUGGER
#if 1
    const void *labels[CMDS] = {
        /*[CMD_NOP] = */&&op_nop, /* !!! НЕ ГЕНЕРИТСЯ !!! */
        /*[CMD_ADD] = */&&op_add, /* OK */
        /*[CMD_SUB] = */&&op_sub, /* OK */
        /*[CMD_MUL] = */&&op_mul, /* OK */
        /*[CMD_DIV] = */&&op_div, /* OK */
        /*[CMD_DIVSIGNED] = */&&op_divsigned, /* OK */
        /*[CMD_IF0GOTO] = */&&op_if0goto, /* OK */
        /*[CMD_GOTO] = */&&op_goto, /* OK */
        /*[CMD_DUP] = */&&op_dup, /* OK */
        /*[CMD_DROP] = */&&op_drop, /* !!! НЕ ГЕНЕРИТСЯ !!! */
        /*[CMD_SWAP] = */&&op_swap, /* OK */
        /*[CMD_READVAR] = */&&op_readvar, /* OK */
        /*[CMD_WRITEVAR] = */&&op_writevar, /* OK */
        /*[CMD_CONST] = */&&op_const, /* OK */
        /*[CMD_RET] = */&&op_ret, /* OK */
        /*[CMD_CALL] = */&&op_call, /* OK */
        /*[CMD_AND] = */&&op_and, /* OK */
        /*[CMD_OR] = */&&op_or, /* OK */
        /*[CMD_XOR] = */&&op_xor, /* OK */
        /*[CMD_EQ] = */&&op_eq, /* OK */
        /*[CMD_MOREEQ] = */&&op_moreeq, /* OK */
        /*[CMD_MOREEQSIGNED] = */&&op_moreeqsigned, /* OK */
        /*[CMD_INV] = */&&op_inv, /* OK */
        /*[CMD_RST] = */&&op_rst, /* OK */
        /*[CMD_SHR] = */&&op_shr, /* OK */
        /*[CMD_SHRSIGNED] = */&&op_shrsigned, /* OK */
        /*[CMD_SHL] = */&&op_shl, /* OK */
        /*[CMD_MOD] = */&&op_mod, /* !!! НЕ ГЕНЕРИТСЯ !!! */
        /*[CMD_DONE] = */&&op_done, /* OK */
        /*[CMD_ADDFLOAT] = */&&op_addfloat, /* OK */
        /*[CMD_SUBFLOAT] = */&&op_subfloat, /* OK */
        /*[CMD_MULFLOAT] = */&&op_mulfloat, /* OK */
        /*[CMD_DIVFLOAT] = */&&op_divfloat, /* OK */
        /*[CMD_NEGFLOAT] = */&&op_negfloat, /* OK */
        /*[CMD_FLOATTOINT] = */&&op_floattoint, /* OK */
        /*[CMD_INTTOFLOAT] = */&&op_inttofloat, /* OK */
        /*[CMD_EQFLOAT] = */&&op_eqfloat,
        /*[CMD_MOREEQFLOAT] = */&&op_moreeqfloat, /* OK */

    };

    MAINDISPATCH;/*!*/
op_nop: {
        DISPATCH;
    }
op_add: {/*!*/
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS;
        TOS.u = (TOS.u+par2);
        DISPATCH;
    }
op_sub: {/*!*/
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS;
        TOS.u = (TOS.u-par2);
        DISPATCH;
    }
op_mul: {
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS.u;
        TOS.u = (TOS.u*par2);
        DISPATCH;
    }
op_div: {
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS.u;
        if (par2)
            TOS.u = (TOS.u/par2);
        DISPATCH;
    }
op_divsigned: {/*!*/
        int64_t par2 = POP.i;
        //int64_t par1 = static_cast<int64_t>(TOS);
        if (par2)
            TOS.i = TOS.i/par2;
        DISPATCH;
    }
op_mod: {
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS.u;
        if (par2)
            TOS.u = (TOS.u-((TOS.u/par2)*par2));
        DISPATCH;
    }
op_and: {
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS.u;
        TOS.u = (TOS.u&par2);
        DISPATCH;
    }
op_or: {
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS.u;
        TOS.u = (TOS.u|par2);
        DISPATCH;
    }
op_xor: {
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS.u;
        TOS.u = (TOS.u^par2);
        DISPATCH;
    }
op_inv: {
        TOS.u = ~TOS.u;
        DISPATCH;
    }
op_shr: {
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS.u;
        TOS.u = (TOS.u>>par2);
        DISPATCH;
    }
op_shrsigned: {/*!*/
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS;
        TOS.i = (TOS.i>>par2);
        DISPATCH;
    }
op_shl: {/*!*/
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS;
        TOS.u = (TOS.u<<par2);
        DISPATCH;
    }
op_eq: {/*!*/
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS;
        TOS.i = (TOS.u==par2)?-1:0;
        DISPATCH;
    }
op_moreeq: {/*!*/
        uint64_t par2 = POP.u;
        //uint64_t par1 = TOS;
        TOS.i = (TOS.u>=par2)?-1:0;
        DISPATCH;
    }
op_moreeqsigned: {/*!*/
        int64_t par2 = POP.i;
        //int64_t par1 = TOS;
        TOS.i = (TOS.i>=par2)?-1:0;
        DISPATCH;
    }
op_const: {
        PUSH(GETPAR);
        DISPATCH;
    }
op_dup: {
        uint64_t par1 = TOS.u;
        PUSH(par1);
        DISPATCH;
    }
op_drop: {
        POP;
        DISPATCH;
    }
op_swap: {
        uint64_t par2 = POP.u;
        uint64_t par1 = TOS.u;
        TOS.u = par2;
        PUSH(par1);
        DISPATCH;
    }
op_readvar: {/*!*/
        if (TOS.u < static_cast<uint64_t>(N))
            TOS.u = VAL(TOS.u);
        DISPATCH;
    }
op_writevar: {/*!*/
        uint64_t vardata = POP.u;
        uint64_t varaddr = POP.u;
        if (varaddr < static_cast<uint64_t>(N))
            VAL(varaddr) = vardata;
        DISPATCH;
    }
op_goto: {
        pc = prog+(*pc); //нельзя GETPAR - делает pc++
        DISPATCH;
    }
op_if0goto: {
        if (!POP.u) {
            pc = prog+(*pc); //нельзя GETPAR - делает pc++
        }else {
            pc++;
        }
        DISPATCH;
    }
op_call: {
        uint64_t callpc = GETPAR;
        PUSHCALLSTACK(reinterpret_cast<uint64_t>(pc));
        pc = prog+callpc;
        DISPATCH;
    }
op_ret: {
        pc = reinterpret_cast<uint64_t*>(POPCALLSTACK);
        DISPATCH;
    }
op_rst: {/*!*/
        double par1 = POP.d;
        //double par0;
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
            case RST_ATAN2:{
                double par0 = POP.d; //записан в стек первым
                PUSHFLOAT(atan2(par0,par1));
                break;
            }
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
        }
        DISPATCH;
    }
op_addfloat: {/*!*/
        double par2 = POP.d;
        //double par1 = static_cast<double>(TOS);
        //double res = static_cast<double>(TOS)+par2;
        TOS.d = TOS.d+par2;
        DISPATCH;
    }
op_subfloat: {/*!*/
        double par2 = POP.d;
        //double par1 = *(double*)&(TOS);
        //double res = par1-par2;
        TOS.d = TOS.d - par2;
        DISPATCH;
    }
op_mulfloat: {
        double par2 = POP.d;
        //double par1 = *(double*)&(TOS);
        //double res = par1*par2;
        TOS.d = TOS.d * par2;
        DISPATCH;
    }
op_divfloat: {
        double par2 = POP.d;
        //double par1 = *(double*)&(TOS);
        //double res = par1/par2;
        TOS.d = TOS.d / par2;
        DISPATCH;
    }
op_negfloat: {
        //double par1 = *(double*)&(TOS);
        //double res = -static_cast<double>(TOS);
        TOS.d = -TOS.d;
        DISPATCH;
    }
op_floattoint: {
        //double par1 = TOS.d;
        TOS.i = static_cast<int64_t>(rint(TOS.d));
        //TOS = static_cast<uint64_t>(par1);
        DISPATCH;
    }
op_inttofloat: {
        //double par1 = TOS.d;
        TOS.d = TOS.i;
        DISPATCH;
    }
op_eqfloat: {/*!*/
        double par2 = POP.d;
        //uint64_t par1 = TOS;
        TOS.i = (TOS.d==par2)?-1:0;
        DISPATCH;
    }
op_moreeqfloat: {/*!*/
        double par2 = POP.d;
        //uint64_t par1 = TOS;
        TOS.i = (TOS.d>=par2)?-1:0;
        DISPATCH;
    }
op_done: {
        return static_cast<int>(stcSMData[0].current_value.i);
    }
#endif
    //return state;
}

#ifndef FOR_DEBUGGER
uint64_t *loadscript(int state_index, char *waspath) {
    uint64_t *prog;
    FILE *fileProg;

    stringstream strToInt;
    string stateIndex;
    string path = waspath;

    strToInt << state_index; // перевод из числа в строку
    strToInt >> stateIndex; //

    path += stateIndex;
    path += ".bin";

    int size;
    fileProg = fopen(path.c_str(), "r");
    if (fileProg) {
        fseek(fileProg,0,SEEK_END);
        size = ftell(fileProg);
        fseek(fileProg,0,SEEK_SET);
        prog = reinterpret_cast<uint64_t*>(malloc(size));
        fread(prog, 1, size, fileProg);
        fclose(fileProg);

    } else {
        prog = reinterpret_cast<uint64_t*>(malloc(sizeof(uint64_t)));
        prog[0] = CMD_DONE;
    }
    return prog;
}
#endif //FOR_DEBUGGER
