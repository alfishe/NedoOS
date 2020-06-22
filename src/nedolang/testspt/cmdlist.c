enum {
        CMD_NOP,
        CMD_ADD,
        CMD_SUB, //CONST A CONST B SUB = A-B
        CMD_MUL,
        CMD_DIV, //CONST A CONST B DIV = A/B
        CMD_DIVSIGNED,
        CMD_IF0GOTO, //IF0GOTO ADDR
        CMD_GOTO, //GOTO ADDR
        CMD_DUP,
        CMD_DROP, /** ??? */
        CMD_SWAP, //CONST A CONST B SWAP SUB = B-A
        CMD_READVAR, //CONST A READVAR = VAR(A)
        CMD_WRITEVAR, //CONST A CONST B WRITEVAR: VAR(A) = B
        CMD_CONST, //CONST A
        CMD_RET,
        CMD_CALL, //CALL ADDR
        CMD_AND,
        CMD_OR,
        CMD_XOR,
        CMD_EQ,
        CMD_MOREEQ,
        CMD_MOREEQSIGNED,
        CMD_INV,
        CMD_RST, //RST <systemprocnum>
        CMD_SHR, //CONST A CONST B SHR = A>>B
        CMD_SHRSIGNED,
        CMD_SHL,
        CMD_MOD, //CONST A CONST B MOD = A % B NOT TESTED
        CMD_DONE, //end
        CMD_ADDFLOAT,
        CMD_SUBFLOAT,
        CMD_MULFLOAT,
        CMD_DIVFLOAT,
        CMD_NEGFLOAT,
        CMD_FLOATTOINT,
        CMD_INTTOFLOAT,
        CMD_EQFLOAT,
        CMD_MOREEQFLOAT,
        CMDS
};

enum {
        RST_SIN = 1,
        RST_COS,
        RST_ATAN,
        RST_ATAN2,
        RST_EXP,
        RST_LOG,
        RST_SQRT,
        RST_ABS,
        RST_ACOS,
        RST_ACOSH,
        RST_ASIN,
        RST_ASINH,
        RST_ATANH,
        RST_CBRT,
        RST_CEIL,
        RST_COSH,
        RST_HYPOT,
        RST_ISFINITE,
        RST_ISINF,
        RST_ISNAN,
        RST_J0,
        RST_J1,
        RST_JN,
        RST_LOG10,
        RST_LOG1P,
        RST_LOGB,
        RST_MAX,
        RST_MIN,
        RST_RINT,
        RST_SINH,
        RST_TAN,
        RST_TANH,
        RST_Y0,
        RST_Y1,
        RST_YN,
        RST_POW,
        RST_PRINT,
};
