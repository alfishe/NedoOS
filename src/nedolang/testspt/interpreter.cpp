#include "interpreter.h"
#include "global_mem.h"
#include <stdio.h>
#include <stdlib.h>
//#include <time.h>
#include <string>
#include <sstream>

#ifdef FOR_DEBUGGER
#include "mainwindow.h"
//#include <QString>
//#include <QMessageBox>

uint8_t datastackindex = 0; //растёт вверх
uint8_t callstackindex = 0; //растёт вверх

data64bit datastack[STACKSIZE];
uint64_t callstack[STACKSIZE];

    uint64_t *pc;
    uint64_t *prog;
#endif //FOR_DEBUGGER
    void myprintstr(uint64_t *prog, uint64_t addr){
        char s[100];
        char *ps=s;
        uint64_t *tmppc=prog+addr;
        while(*tmppc)
            *ps++=static_cast<char>(*tmppc++);
        *ps=0;
        myprint(reinterpret_cast<char *>(s));
    }

#ifdef FOR_DEBUGGER
    int interpret() {
#else //FOR_DEBUGGER
    int interpret(uint64_t *prog) {
        uint64_t *pc = prog;
uint8_t datastackindex = 0; //растёт вверх
uint8_t callstackindex = 0; //растёт вверх

data64bit datastack[STACKSIZE];
uint64_t callstack[STACKSIZE];
#endif //FOR_DEBUGGER

    const void *labels[CMDS] = {
        &&op_nop, /* !!! НЕ ГЕНЕРИТСЯ !!! */
        &&op_add, /* OK */
        &&op_sub, /* OK */
        &&op_mul, /* OK */
        &&op_div, /* OK */
        &&op_divsigned, /* OK */
        &&op_if0goto, /* OK */
        &&op_goto, /* OK */
        &&op_dup, /* OK */
        &&op_drop, /* !!! НЕ ГЕНЕРИТСЯ !!! */
        &&op_swap, /* OK */
        &&op_readvar, /* OK */
        &&op_writevar, /* OK */
        &&op_const, /* OK */
        &&op_ret, /* OK */
        &&op_call, /* OK */
        &&op_and, /* OK */
        &&op_or, /* OK */
        &&op_xor, /* OK */
        &&op_eq, /* OK */
        &&op_moreeq, /* OK */
        &&op_moreeqsigned, /* OK */
        &&op_inv, /* OK */
        &&op_rst, /* OK */
        &&op_shr, /* OK */
        &&op_shrsigned, /* OK */
        &&op_shl, /* OK */
        &&op_mod, /* !!! НЕ ГЕНЕРИТСЯ !!! */
        &&op_done, /* OK */
        &&op_addfloat, /* OK */
        &&op_subfloat, /* OK */
        &&op_mulfloat, /* OK */
        &&op_divfloat, /* OK */
        &&op_negfloat, /* OK */
        &&op_floattoint, /* OK */
        &&op_inttofloat, /* OK */
        &&op_eqfloat,
        &&op_moreeqfloat /* OK */
    };
    MAINDISPATCH;/*!*/
op_nop: {
        DISPATCH;
    }
op_add: {
        uint64_t par2 = POP.u;
        TOS.u = (TOS.u+par2);
        DISPATCH;
    }
op_sub: {
        uint64_t par2 = POP.u;
        TOS.u = (TOS.u-par2);
        DISPATCH;
    }
op_mul: {
        uint64_t par2 = POP.u;
        TOS.u = (TOS.u*par2);
        DISPATCH;
    }
op_div: {
        uint64_t par2 = POP.u;
        if (par2)
            TOS.u = (TOS.u/par2);
        DISPATCH;
    }
op_divsigned: {/*!*/
        int64_t par2 = POP.i;
        if (par2)
            TOS.i = TOS.i/par2;
        DISPATCH;
    }
op_mod: {
        uint64_t par2 = POP.u;
        if (par2)
            TOS.u = (TOS.u-((TOS.u/par2)*par2));
        DISPATCH;
    }
op_and: {
        uint64_t par2 = POP.u;
        TOS.u = (TOS.u&par2);
        DISPATCH;
    }
op_or: {
        uint64_t par2 = POP.u;
        TOS.u = (TOS.u|par2);
        DISPATCH;
    }
op_xor: {
        uint64_t par2 = POP.u;
        TOS.u = (TOS.u^par2);
        DISPATCH;
    }
op_inv: {
        TOS.u = ~TOS.u;
        DISPATCH;
    }
op_shr: {
        uint64_t par2 = POP.u;
        TOS.u = (TOS.u>>par2);
        DISPATCH;
    }
op_shrsigned: {
        uint64_t par2 = POP.u;
        TOS.i = (TOS.i>>par2);
        DISPATCH;
    }
op_shl: {
        uint64_t par2 = POP.u;
        TOS.u = (TOS.u<<par2);
        DISPATCH;
    }
op_eq: {
        uint64_t par2 = POP.u;
        TOS.i = (TOS.u==par2)?-1:0;
        DISPATCH;
    }
op_moreeq: {
        uint64_t par2 = POP.u;
        TOS.i = (TOS.u>=par2)?-1:0;
        DISPATCH;
    }
op_moreeqsigned: {
        int64_t par2 = POP.i;
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
op_readvar: {
        if (TOS.u < static_cast<uint64_t>(N))
            TOS.u = VAL(TOS.u);
        DISPATCH;
    }
op_writevar: {
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
op_addfloat: {
        double par2 = POP.d;
        TOS.d = TOS.d+par2;
        DISPATCH;
    }
op_subfloat: {
        double par2 = POP.d;
        TOS.d = TOS.d - par2;
        DISPATCH;
    }
op_mulfloat: {
        double par2 = POP.d;
        TOS.d = TOS.d * par2;
        DISPATCH;
    }
op_divfloat: {
        double par2 = POP.d;
        TOS.d = TOS.d / par2;
        DISPATCH;
    }
op_negfloat: {
        TOS.d = -TOS.d;
        DISPATCH;
    }
op_floattoint: {
        TOS.i = static_cast<int64_t>(rint(TOS.d));
        DISPATCH;
    }
op_inttofloat: {
        TOS.d = TOS.i;
        DISPATCH;
    }
op_eqfloat: {
        double par2 = POP.d;
        TOS.i = (TOS.d==par2)?-1:0;
        DISPATCH;
    }
op_moreeqfloat: {
        double par2 = POP.d;
        TOS.i = (TOS.d>=par2)?-1:0;
        DISPATCH;
    }
op_done: {
        return static_cast<int>(stcSMData[0].current_value.i);
    }
op_rst: {
    uint64_t op = GETPAR;
    double par1;
    uint64_t upar1;
    switch (op) {
//case RST_NOP: //fn_nop:
//        break;
case RST_SIN: //fn_sin:{
        TOS.d=sin(TOS.d);
        break;
case RST_COS: //fn_cos:{
        TOS.d=cos(TOS.d);
        break;
case RST_ATAN: //fn_atan:{
        TOS.d=atan(TOS.d);
        break;
case RST_ATAN2: //fn_atan2:{
        par1 = POP.d;
        TOS.d = atan2(TOS.d,par1);
        break;
case RST_EXP: //fn_exp:{
        TOS.d=exp(TOS.d);
        break;
case RST_LOG: //fn_log:{
        TOS.d=log(TOS.d);
        break;
case RST_SQRT: //fn_sqrt:{
        TOS.d=sqrt(TOS.d);
        break;
case RST_ABS: //fn_abs:{
        TOS.d=abs(TOS.d);
        break;
case RST_ACOS: //fn_acos:{
        TOS.d=acos(TOS.d);
        break;
case RST_ACOSH: //fn_acosh:{
        TOS.d=acosh(TOS.d);
        break;
case RST_ASIN: //fn_asin:{
        TOS.d=asin(TOS.d);
        break;
case RST_ASINH: //fn_asinh:{
        TOS.d=asinh(TOS.d);
        break;
case RST_ATANH: //fn_atanh:{
        TOS.d=atanh(TOS.d);
        break;
case RST_CBRT: //fn_cbrt:{
        TOS.d=cbrt(TOS.d);
        break;
case RST_CEIL: //fn_ceil:{
        TOS.d=ceil(TOS.d);
        break;
case RST_COSH: //fn_cosh:{
        TOS.d=cosh(TOS.d);
        break;
case RST_HYPOT: //fn_hypot:{
        par1 = POP.d;
        TOS.d=hypot(TOS.d,par1);
        break;
case RST_ISFINITE: //fn_isfinite:{
        TOS.i=(isfinite(TOS.d)?-1:0);
        break;
case RST_ISINF: //fn_isinf:{
        TOS.i=(isinf(TOS.d)?-1:0);
        break;
case RST_ISNAN: //fn_isnan:{
        TOS.i=(isnan(TOS.d)?-1:0);
        break;
case RST_J0: //fn_j0:{
        //TOS.d=j0(TOS.d);
        break;
case RST_J1: //fn_j1:{
        //TOS.d=j1(TOS.d);
        break;
case RST_JN: //fn_jn:{
        par1 = POP.d;
        //TOS.d=jn(static_cast<int>(TOS.i),par1);
        break;
case RST_LOG10: //fn_log10:{
        TOS.d=log10(TOS.d);
        break;
case RST_LOG1P: //fn_log1p:{
        TOS.d=log1p(TOS.d);
        break;
case RST_LOGB: //fn_logb:{
        TOS.d=logb(TOS.d);
        break;
case RST_MAX: //fn_max:{
        par1 = POP.d;
        TOS.d=(TOS.d>par1?TOS.d:par1);
        break;
case RST_MIN: //fn_min:{
        par1 = POP.d;
        TOS.d=(TOS.d<par1?TOS.d:par1);
        break;
case RST_RINT: //fn_rint:{
        TOS.d=rint(TOS.d);
        break;
case RST_SINH: //fn_sinh:{
        TOS.d=sinh(TOS.d);
        break;
case RST_TAN: //fn_tan:{
        TOS.d=tan(TOS.d);
        break;
case RST_TANH: //fn_tanh:{
        TOS.d=tanh(TOS.d);
        break;
case RST_Y0: //fn_y0:{
        //TOS.d=y0(TOS.d);
        break;
case RST_Y1: //fn_y1:{
        //TOS.d=y1(TOS.d);
        break;
case RST_YN: //fn_yn:{
        par1 = POP.d;
        //TOS.d=yn(static_cast<int>(TOS.i),par1);
        break;
case RST_POW: //fn_pow:{
        par1 = POP.d;
        TOS.d=pow(TOS.d,par1);
        break;
case RST_PRINT: //fn_print:{
        upar1 = POP.u;
        myprintstr(prog, upar1);
        break;
default: ;
}
        DISPATCH;
    }
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
